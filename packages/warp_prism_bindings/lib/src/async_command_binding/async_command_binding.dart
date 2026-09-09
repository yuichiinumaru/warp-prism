import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';
import 'package:warp_prism_interaction/warp_prism_interaction.dart';
import 'package:warp_prism_runtime/warp_prism_runtime.dart';

import 'async_command_view_model.dart';

/// Projection binding connecting UI triggers and IDS intents to runtime [AsyncCommand] execution.
///
/// Provides:
/// - Reactive [AsyncCommandBindingState] tracking execution status (`idle`, `running`,
///   `succeeded`, `failed`, `cancelled`).
/// - Direct convergence with the IDS kernel via [executeWithIntent] and [executeWithQueryIntent].
/// - Cooperative cancellation management via [CancellationToken].
/// - Deterministic resource cleanup on [dispose].
///
/// **PURGE LAW**: This binding contains strictly zero retry loops,
/// exponential backoff timers, or dialog/toast UI presentation code.
///
/// Lifecycle: EXPERIMENTAL (see `docs/architecture/layer-contracts-v2.md`).
@experimental
class AsyncCommandBinding<TParam, TResult> extends ChangeNotifier {
  /// The underlying runtime async command implementation.
  final AsyncCommand<TParam, TResult> command;

  AsyncCommandBindingState<TResult> _state =
      const AsyncCommandBindingState.idle();
  CancellationToken? _activeCancellationToken;
  StreamSubscription<AsyncCommandStatus>? _statusSubscription;
  bool _isDisposed = false;

  final StreamController<AsyncCommandBindingState<TResult>>
  _stateStreamController =
      StreamController<AsyncCommandBindingState<TResult>>.broadcast();

  /// Creates an [AsyncCommandBinding] for the given [command].
  AsyncCommandBinding({required this.command, bool watchCommandStatus = true}) {
    if (watchCommandStatus && !command.isClosed) {
      _statusSubscription = command.watchStatus().listen(
        _handleStatusChange,
        onError: (Object error, StackTrace stackTrace) {
          // Status stream errors are ignored; execution handles result errors.
        },
      );
    }
  }

  void _handleStatusChange(AsyncCommandStatus status) {
    if (_isDisposed) return;
    if (_state.status != status) {
      _state = AsyncCommandBindingState<TResult>(
        status: status,
        lastResult: _state.lastResult,
        lastSuccess: _state.lastSuccess,
        lastError: _state.lastError,
        cancellationReason: _state.cancellationReason,
        lastDuration: _state.lastDuration,
        lastTimestamp: _state.lastTimestamp,
      );
      _notifyAndDispatch();
    }
  }

  void _notifyAndDispatch() {
    notifyListeners();
    _stateStreamController.add(_state);
  }

  /// Executes the command with the provided [param].
  ///
  /// If an execution is already running, its cancellation token is signalled.
  Future<CommandResult<TResult>> execute(
    TParam param, {
    CancellationToken? cancellationToken,
  }) async {
    if (_isDisposed) {
      throw StateError('Cannot execute on a disposed AsyncCommandBinding.');
    }

    if (_state.isRunning) {
      _activeCancellationToken?.cancel('Re-executed with new input');
    }

    final token = cancellationToken ?? CancellationToken();
    _activeCancellationToken = token;

    _state = _state.toRunning();
    _notifyAndDispatch();

    try {
      final result = await command.execute(param, cancellationToken: token);
      if (_isDisposed) return result;

      switch (result) {
        case CommandSuccess<TResult>():
          _state = _state.toSuccess(result);
        case CommandFailure<TResult>():
          _state = _state.toFailure(result);
        case CommandCancelled<TResult>():
          _state = _state.toCancelled(result);
      }

      _notifyAndDispatch();
      return result;
    } catch (e, st) {
      if (_isDisposed) rethrow;

      final failure = CommandFailure<TResult>(
        error: CommandGenericError(
          message: 'Unhandled execution error: $e',
          cause: e,
          stackTrace: st,
        ),
        duration: Duration.zero,
        timestamp: DateTime.now(),
      );
      _state = _state.toFailure(failure);
      _notifyAndDispatch();
      return failure;
    } finally {
      if (identical(_activeCancellationToken, token)) {
        _activeCancellationToken = null;
      }
    }
  }

  /// Executes the command using a normalized IDS [InputIntent] payload.
  ///
  /// Convergence point between `warp_prism_interaction` and `warp_prism_runtime`.
  Future<CommandResult<TResult>> executeWithIntent<TIntent extends InputIntent>(
    TIntent intent,
    TParam Function(TIntent intent) paramBuilder, {
    CancellationToken? cancellationToken,
  }) {
    final param = paramBuilder(intent);
    return execute(param, cancellationToken: cancellationToken);
  }

  /// Executes the command using a structured IDS [QueryIntent] payload.
  ///
  /// Convergence point between `warp_prism_interaction` query model and runtime RPC.
  Future<CommandResult<TResult>> executeWithQueryIntent(
    QueryIntent intent,
    TParam Function(QueryIntent intent) paramBuilder, {
    CancellationToken? cancellationToken,
  }) {
    final param = paramBuilder(intent);
    return execute(param, cancellationToken: cancellationToken);
  }

  /// Requests cancellation of the currently executing operation.
  void cancel([String? reason]) {
    if (_isDisposed || !_state.isRunning) return;
    _activeCancellationToken?.cancel(reason);
  }

  /// Resets the binding state to [AsyncCommandStatus.idle].
  void reset() {
    if (_isDisposed) return;
    _state = const AsyncCommandBindingState.idle();
    _notifyAndDispatch();
  }

  /// Current presentation state snapshot.
  AsyncCommandBindingState<TResult> get state => _state;

  /// Current lifecycle execution status.
  AsyncCommandStatus get status => _state.status;

  /// Whether the command is idle and ready for execution.
  bool get isIdle => _state.isIdle;

  /// Whether the command is currently running.
  bool get isRunning => _state.isRunning;

  /// Whether the last command run completed successfully.
  bool get isSuccess => _state.isSuccess;

  /// Whether the last command run failed.
  bool get isFailure => _state.isFailure;

  /// Whether the last command run was cancelled.
  bool get isCancelled => _state.isCancelled;

  /// Most recent successful result value, if any.
  TResult? get lastSuccess => _state.lastSuccess;

  /// Most recent command execution error, if any.
  CommandError? get lastError => _state.lastError;

  /// Most recent command result, if any.
  CommandResult<TResult>? get lastResult => _state.lastResult;

  /// Reactive stream of updated [AsyncCommandBindingState] transitions.
  Stream<AsyncCommandBindingState<TResult>> get stateStream =>
      _stateStreamController.stream;

  /// Whether this binding instance is disposed.
  bool get isDisposed => _isDisposed;

  @override
  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;
    _activeCancellationToken?.cancel('Binding disposed');
    _activeCancellationToken = null;
    _statusSubscription?.cancel();
    _statusSubscription = null;
    _stateStreamController.close();
    super.dispose();
  }
}
