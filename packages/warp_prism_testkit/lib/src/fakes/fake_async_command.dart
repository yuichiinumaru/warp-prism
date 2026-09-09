import 'dart:async';
import 'package:meta/meta.dart';
import 'package:warp_prism_runtime/warp_prism_runtime.dart';

/// In-memory fake implementation of [AsyncCommand] for deterministic testing.
///
/// Supports configurable responses, simulated execution delays, custom handlers,
/// invocation tracking, and cooperative cancellation checking.
///
/// Lifecycle: EXPERIMENTAL (see `docs/architecture/layer-contracts-v2.md`).
@experimental
class FakeAsyncCommand<TParam, TResult>
    implements AsyncCommand<TParam, TResult> {
  TResult? _configuredResult;
  CommandError? _configuredError;
  Duration _simulatedDelay;
  Future<TResult> Function(TParam param, CancellationToken? token)? _handler;

  AsyncCommandStatus _status = AsyncCommandStatus.idle;
  final StreamController<AsyncCommandStatus> _statusController;

  int _callCount = 0;
  int _cancellationCount = 0;
  TParam? _lastParam;
  final List<TParam> _callHistory = [];
  bool _isClosed = false;

  /// Creates a [FakeAsyncCommand] with optional initial result or custom handler.
  FakeAsyncCommand({
    TResult? initialResult,
    CommandError? initialError,
    this._simulatedDelay = Duration.zero,
    this._handler,
    bool sync = true,
  }) : _configuredResult = initialResult,
       _configuredError = initialError,
       _statusController = StreamController<AsyncCommandStatus>.broadcast(
         sync: sync,
       );

  @override
  AsyncCommandStatus get status => _status;

  @override
  bool get isClosed => _isClosed;

  /// Total number of times [execute] was invoked.
  int get callCount => _callCount;

  /// Total number of executions that terminated via cancellation.
  int get cancellationCount => _cancellationCount;

  /// Parameter supplied in the most recent [execute] call.
  TParam? get lastParam => _lastParam;

  /// Ordered list of all parameter payloads supplied to [execute].
  List<TParam> get callHistory => List.unmodifiable(_callHistory);

  /// Configures a static result value returned on subsequent executions.
  void setResult(TResult result) {
    _configuredResult = result;
    _configuredError = null;
  }

  /// Configures a static error returned on subsequent executions.
  void setError(CommandError error) {
    _configuredError = error;
    _configuredResult = null;
  }

  /// Configures simulated execution delay.
  void setDelay(Duration delay) {
    _simulatedDelay = delay;
  }

  /// Sets a dynamic execution handler callback.
  void setHandler(
    Future<TResult> Function(TParam param, CancellationToken? token) handler,
  ) {
    _handler = handler;
  }

  void _updateStatus(AsyncCommandStatus newStatus) {
    if (_status == newStatus) return;
    _status = newStatus;
    _statusController.add(newStatus);
  }

  @override
  Stream<AsyncCommandStatus> watchStatus() => _statusController.stream;

  @override
  Future<CommandResult<TResult>> execute(
    TParam param, {
    CancellationToken? cancellationToken,
  }) async {
    if (_isClosed) {
      throw StateError('Cannot execute closed FakeAsyncCommand');
    }

    _callCount++;
    _lastParam = param;
    _callHistory.add(param);

    final stopwatch = Stopwatch()..start();
    _updateStatus(AsyncCommandStatus.running);

    if (cancellationToken != null && cancellationToken.isCancelled) {
      _cancellationCount++;
      _updateStatus(AsyncCommandStatus.cancelled);
      stopwatch.stop();
      return CommandCancelled<TResult>(
        reason: cancellationToken.cancellationReason,
        duration: stopwatch.elapsed,
        timestamp: DateTime.now(),
      );
    }

    if (_simulatedDelay > Duration.zero) {
      if (cancellationToken != null) {
        final completer = Completer<void>();
        void listener(String? reason) {
          if (!completer.isCompleted) {
            completer.complete();
          }
        }

        cancellationToken.attachListener(listener);
        final timer = Timer(_simulatedDelay, () {
          if (!completer.isCompleted) {
            completer.complete();
          }
        });

        await completer.future;
        timer.cancel();
        cancellationToken.detachListener(listener);

        if (cancellationToken.isCancelled) {
          _cancellationCount++;
          _updateStatus(AsyncCommandStatus.cancelled);
          stopwatch.stop();
          return CommandCancelled<TResult>(
            reason: cancellationToken.cancellationReason,
            duration: stopwatch.elapsed,
            timestamp: DateTime.now(),
          );
        }
      } else {
        await Future<void>.delayed(_simulatedDelay);
      }
    }

    try {
      TResult resultValue;

      if (_handler != null) {
        resultValue = await _handler!(param, cancellationToken);
      } else if (_configuredError != null) {
        _updateStatus(AsyncCommandStatus.failed);
        stopwatch.stop();
        return CommandFailure<TResult>(
          error: _configuredError!,
          duration: stopwatch.elapsed,
          timestamp: DateTime.now(),
        );
      } else if (_configuredResult != null) {
        resultValue = _configuredResult as TResult;
      } else {
        throw StateError(
          'FakeAsyncCommand has no result, error, or handler configured',
        );
      }

      if (cancellationToken != null && cancellationToken.isCancelled) {
        _cancellationCount++;
        _updateStatus(AsyncCommandStatus.cancelled);
        stopwatch.stop();
        return CommandCancelled<TResult>(
          reason: cancellationToken.cancellationReason,
          duration: stopwatch.elapsed,
          timestamp: DateTime.now(),
        );
      }

      _updateStatus(AsyncCommandStatus.succeeded);
      stopwatch.stop();
      return CommandSuccess<TResult>(
        value: resultValue,
        duration: stopwatch.elapsed,
        timestamp: DateTime.now(),
      );
    } on CommandCancellationException catch (e) {
      _cancellationCount++;
      _updateStatus(AsyncCommandStatus.cancelled);
      stopwatch.stop();
      return CommandCancelled<TResult>(
        reason: e.reason,
        duration: stopwatch.elapsed,
        timestamp: DateTime.now(),
      );
    } catch (e, st) {
      if (cancellationToken != null && cancellationToken.isCancelled) {
        _cancellationCount++;
        _updateStatus(AsyncCommandStatus.cancelled);
        stopwatch.stop();
        return CommandCancelled<TResult>(
          reason: cancellationToken.cancellationReason,
          duration: stopwatch.elapsed,
          timestamp: DateTime.now(),
        );
      }

      _updateStatus(AsyncCommandStatus.failed);
      stopwatch.stop();
      return CommandFailure<TResult>(
        error: CommandGenericError(
          message: e.toString(),
          cause: e,
          stackTrace: st,
        ),
        duration: stopwatch.elapsed,
        timestamp: DateTime.now(),
      );
    }
  }

  /// Resets invocation history and status to idle.
  void reset() {
    _callCount = 0;
    _cancellationCount = 0;
    _lastParam = null;
    _callHistory.clear();
    _updateStatus(AsyncCommandStatus.idle);
  }

  @override
  Future<void> close() async {
    _isClosed = true;
    if (!_statusController.isClosed) {
      await _statusController.close();
    }
  }
}
