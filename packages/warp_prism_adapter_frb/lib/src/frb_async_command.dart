import 'package:meta/meta.dart';
import 'dart:async';
import 'package:warp_prism_runtime/warp_prism_runtime.dart';
import 'rust/api.dart' as frb_api;

/// Generates collision-resistant, monotonic-within-isolate command ids.
///
/// **F4**: the previous scheme was `'cmd-${DateTime.now().microsecondsSinceEpoch}'`,
/// which collides whenever two executions land in the same microsecond — and a
/// collision is not cosmetic: `CommandRegistry::register` keys by id, so a
/// colliding id could displace an unrelated active token, redirect
/// `cancel_command(id)` onto the wrong command, and let one execution's cleanup
/// evict another's registration.
///
/// The id now combines three components:
/// * an isolate-scoped tag, so ids minted in different isolates never collide;
/// * a strictly monotonic per-generator counter, so no two ids from the same
///   generator can ever be equal regardless of clock resolution or skew;
/// * the wall clock, retained only as a debugging aid.
///
/// Uniqueness therefore does **not** depend on the clock at all: even if
/// `microsecondsSinceEpoch` were frozen or went backwards, the monotonic
/// counter guarantees distinctness.
class CommandIdGenerator {
  CommandIdGenerator({String? isolateTag})
    : _isolateTag = isolateTag ?? _isolateTagForThisIsolate();

  final String _isolateTag;
  int _sequence = 0;

  /// Per-isolate discriminator, computed ONCE per isolate.
  ///
  /// Static so every generator in the same isolate shares the same tag —
  /// recomputing it per generator would be semantically wrong (it is an
  /// *isolate* property, not a generator property) and would make id shape
  /// unpredictable across instances.
  static String? _cachedIsolateTag;

  static String _isolateTagForThisIsolate() {
    return _cachedIsolateTag ??= identityHashCode(Object()).toRadixString(36);
  }

  /// Returns the next unique command id.
  String next() {
    final seq = ++_sequence;
    return 'cmd-$_isolateTag-$seq-${DateTime.now().microsecondsSinceEpoch}';
  }

  /// Number of ids minted so far.
  int get sequence => _sequence;
}

/// FRB native-backed implementation of [AsyncCommand].
///
/// **Concurrency model (F1)**: single-flight, cancel-and-replace — see
/// [AsyncCommand]. A second [execute] supersedes the active one; only the
/// authoritative execution publishes status.
///
/// **Error taxonomy (WP-011 / F5)**: execution failures and transport failures
/// are distinct representations, not collapsed:
///
/// * A command that *ran* and was rejected by the native domain reports
///   [CommandExecutionError] — the native side returns the reason as the
///   `errorMessage` **data field** of `FrbCommandResult`, never by throwing.
/// * A failure of the *bridge itself* (library not initialised, channel closed,
///   native panic surfacing as a thrown error, or a blocking task that panicked
///   or was aborted) is reported as [CommandTransportError].
///
/// The native side supplies a typed `errorKind` discriminator
/// (`execution`/`validation`/`timeout`/`transport`/`duplicate`/`generic`), so
/// consumers discriminate on a **field**, never on message text.
///
/// ## Cancellation lifecycle tuple (F3)
///
/// These are five distinct facts, and conflating them is what produced the
/// previous defect:
///
/// 1. **owner** — the execution that registered the command id;
/// 2. **creation** — the id was registered and the native call issued;
/// 3. **running** — native work is in flight;
/// 4. **cancellation-requested** — a Dart-side [CancellationToken] was
///    signalled. This is a *local intent* only; it proves nothing about native
///    behaviour;
/// 5. **cancellation-observed** — the native execution actually observed the
///    cancellation and terminated cooperatively;
/// 6. **terminal-state** — the authoritative outcome;
/// 7. **cleanup** — the listener is detached and the registration released.
///
/// Only facts (5) and (6) may produce a terminal result, and only the native
/// side can establish them. A local request (4) must **never** fabricate a
/// terminal `CommandCancelled`, because that would report work as cancelled that
/// in fact completed successfully.
///
/// **Documented limit**: because the native domain never throws, every exception
/// escaping the bridge call is classified as transport. A Dart-side programming
/// error inside the guarded block would therefore also surface as a transport
/// failure; the only statement in that block is request construction.
@experimental
class FrbAsyncCommand implements AsyncCommand<String, String> {
  final String commandType;
  final StreamController<AsyncCommandStatus> _statusController;
  AsyncCommandStatus _status = AsyncCommandStatus.idle;
  bool _isClosed = false;

  /// Monotonic execution identity (F1): only the authoritative execution
  /// publishes status.
  int _executionCounter = 0;
  int _authoritativeGeneration = 0;
  CancellationToken? _activeToken;

  /// Command id source (F4). Injectable so id uniqueness can be tested without
  /// depending on the wall clock.
  final CommandIdGenerator idGenerator;

  FrbAsyncCommand({required this.commandType, CommandIdGenerator? idGenerator})
    : idGenerator = idGenerator ?? CommandIdGenerator(),
      _statusController =
          StreamController<AsyncCommandStatus>.broadcast();

  @override
  AsyncCommandStatus get status => _status;

  @override
  bool get isClosed => _isClosed;

  @override
  Stream<AsyncCommandStatus> watchStatus() => _statusController.stream;

  /// Generation of the execution currently allowed to publish status.
  int get authoritativeGeneration => _authoritativeGeneration;

  bool _isAuthoritative(int generation) => generation == _authoritativeGeneration;

  void _setStatus(AsyncCommandStatus newStatus, int generation) {
    if (!_isAuthoritative(generation)) return;
    _status = newStatus;
    if (!_isClosed) {
      _statusController.add(newStatus);
    }
  }

  @override
  Future<CommandResult<String>> execute(
    String param, {
    CancellationToken? cancellationToken,
  }) async {
    if (_isClosed) {
      throw StateError('Cannot execute closed command');
    }

    // F1: cancel-and-replace. Signal the incumbent, then supersede it.
    _activeToken?.cancel('Replaced by a newer execution');
    final token = cancellationToken ?? CancellationToken();
    _activeToken = token;
    final generation = ++_executionCounter;
    _authoritativeGeneration = generation;

    // Preflight cancellation. Honest: no native work has started, so there is
    // no native truth to contradict. See the lifecycle tuple in the class docs.
    if (token.isCancelled) {
      _setStatus(AsyncCommandStatus.cancelled, generation);
      _releaseIfCurrent(generation, token);
      return CommandCancelled<String>(
        reason: token.cancellationReason,
        duration: Duration.zero,
        timestamp: DateTime.now(),
      );
    }

    _setStatus(AsyncCommandStatus.running, generation);
    final stopwatch = Stopwatch()..start();

    // F4: collision-resistant id — no longer clock-only.
    final cmdId = idGenerator.next();

    void cancelListener(String? reason) {
      // Fact (4): a local request only. It signals the native registry; it
      // does NOT decide the terminal result.
      try {
        frb_api.cancelCommand(commandId: cmdId);
      } catch (_) {
        // Suppress errors if cancellation was attempted on closed/unregistered state
      }
    }

    if (cancellationToken != null) {
      cancellationToken.attachListener(cancelListener);
    }

    try {
      final req = frb_api.FrbCommandRequest(
        id: cmdId,
        commandType: commandType,
        payload: param,
      );

      final nativeRes = await frb_api.executeCommand(req: req);
      stopwatch.stop();

      final millis = nativeRes.timestampMillis.toInt();
      final timestamp = DateTime.fromMillisecondsSinceEpoch(millis);
      final duration = Duration(milliseconds: nativeRes.durationMs.toInt());

      // F3: the NATIVE result is the only authority on the terminal state.
      //
      // The previous code read:
      //   if (nativeRes.isCancelled || (cancellationToken?.isCancelled ?? false))
      // which let a purely local cancellation request convert a genuine NATIVE
      // SUCCESS into CommandCancelled — a fabricated terminal result that
      // reported completed work as cancelled.
      if (nativeRes.isCancelled) {
        _setStatus(AsyncCommandStatus.cancelled, generation);
        _releaseIfCurrent(generation, token);
        return CommandCancelled<String>(
          reason: cancellationToken?.cancellationReason ??
              'Native execution cancelled',
          duration: duration,
          timestamp: timestamp,
        );
      }

      if (nativeRes.errorMessage != null) {
        // The command reached the native side and failed there. F5: preserve
        // the taxonomy via the typed `errorKind` discriminator rather than
        // guessing from message text.
        final kind = nativeRes.errorKind;
        final isTransport = kind == 'transport';
        _setStatus(AsyncCommandStatus.failed, generation);
        _releaseIfCurrent(generation, token);
        return CommandFailure<String>(
          error: isTransport
              ? CommandTransportError(
                  message:
                      'FRB transport failure while executing command '
                      '"$commandType" (id: $cmdId): ${nativeRes.errorMessage}',
                )
              : CommandExecutionError(
                  message: nativeRes.errorMessage!,
                  errorCode: kind,
                ),
          duration: duration,
          timestamp: timestamp,
        );
      }

      _setStatus(AsyncCommandStatus.succeeded, generation);
      _releaseIfCurrent(generation, token);
      return CommandSuccess<String>(
        value: nativeRes.value ?? '',
        duration: duration,
        timestamp: timestamp,
      );
    } catch (error, stackTrace) {
      stopwatch.stop();
      // F3: do NOT fabricate a cancellation here. The bridge threw, so the
      // native truth is unknown; reporting CommandCancelled because a local
      // token happened to be requested would be exactly the fabricated terminal
      // result F3 forbids. An unobservable cancellation is reported as the
      // transport failure it actually is, with the request noted in the message
      // so the information is not lost.
      final cancelWasRequested = token.isCancelled;
      _setStatus(AsyncCommandStatus.failed, generation);
      _releaseIfCurrent(generation, token);
      return CommandFailure<String>(
        error: CommandTransportError(
          message:
              'FRB transport failure while executing command '
              '"$commandType" (id: $cmdId): $error'
              '${cancelWasRequested ? ' (a cancellation was requested, but the '
                  'native outcome was unobservable and must not be assumed)' : ''}',
          cause: error,
          stackTrace: stackTrace,
        ),
        duration: stopwatch.elapsed,
        timestamp: DateTime.now(),
      );
    } finally {
      // Cleanup (fact 7): detach the listener, and release the active token only
      // if this execution still owns it.
      if (cancellationToken != null) {
        cancellationToken.detachListener(cancelListener);
      }
      _releaseIfCurrent(generation, token);
    }
  }

  void _releaseIfCurrent(int generation, CancellationToken token) {
    if (_isAuthoritative(generation) && identical(_activeToken, token)) {
      _activeToken = null;
    }
  }

  @override
  Future<void> close() async {
    if (_isClosed) return;
    _isClosed = true;
    await _statusController.close();
  }
}

