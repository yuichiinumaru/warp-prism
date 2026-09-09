import 'package:meta/meta.dart';
import 'dart:async';
import 'package:warp_prism_runtime/warp_prism_runtime.dart';
import 'rust/api.dart' as frb_api;

/// FRB native-backed implementation of [AsyncCommand].
/// Lifecycle: EXPERIMENTAL (see `docs/architecture/layer-contracts-v2.md`).
@experimental
class FrbAsyncCommand implements AsyncCommand<String, String> {
  final String commandType;
  final StreamController<AsyncCommandStatus> _statusController;
  AsyncCommandStatus _status = AsyncCommandStatus.idle;
  bool _isClosed = false;

  FrbAsyncCommand({required this.commandType})
      : _statusController =
            StreamController<AsyncCommandStatus>.broadcast();

  @override
  AsyncCommandStatus get status => _status;

  @override
  bool get isClosed => _isClosed;

  @override
  Stream<AsyncCommandStatus> watchStatus() => _statusController.stream;

  void _setStatus(AsyncCommandStatus newStatus) {
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

    // Preflight cancellation check
    if (cancellationToken != null && cancellationToken.isCancelled) {
      _setStatus(AsyncCommandStatus.cancelled);
      return CommandCancelled<String>(
        reason: cancellationToken.cancellationReason,
        duration: Duration.zero,
        timestamp: DateTime.now(),
      );
    }

    _setStatus(AsyncCommandStatus.running);
    final stopwatch = Stopwatch()..start();
    final cmdId = 'cmd-${DateTime.now().microsecondsSinceEpoch}';

    void cancelListener(String? reason) {
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

      if (nativeRes.isCancelled || (cancellationToken?.isCancelled ?? false)) {
        _setStatus(AsyncCommandStatus.cancelled);
        return CommandCancelled<String>(
          reason: cancellationToken?.cancellationReason ?? 'Native execution cancelled',
          duration: duration,
          timestamp: timestamp,
        );
      }

      if (nativeRes.errorMessage != null) {
        _setStatus(AsyncCommandStatus.failed);
        return CommandFailure<String>(
          error: CommandExecutionError(message: nativeRes.errorMessage!),
          duration: duration,
          timestamp: timestamp,
        );
      }

      _setStatus(AsyncCommandStatus.succeeded);
      return CommandSuccess<String>(
        value: nativeRes.value ?? '',
        duration: duration,
        timestamp: timestamp,
      );
    } catch (error, stackTrace) {
      stopwatch.stop();
      if (cancellationToken?.isCancelled ?? false) {
        _setStatus(AsyncCommandStatus.cancelled);
        return CommandCancelled<String>(
          reason: cancellationToken?.cancellationReason ?? 'Cancelled during execution',
          duration: stopwatch.elapsed,
          timestamp: DateTime.now(),
        );
      }
      _setStatus(AsyncCommandStatus.failed);
      return CommandFailure<String>(
        error: CommandGenericError(
          message: error.toString(),
          cause: error,
          stackTrace: stackTrace,
        ),
        duration: stopwatch.elapsed,
        timestamp: DateTime.now(),
      );
    } finally {
      if (cancellationToken != null) {
        cancellationToken.detachListener(cancelListener);
      }
    }
  }

  @override
  Future<void> close() async {
    if (_isClosed) return;
    _isClosed = true;
    await _statusController.close();
  }
}

