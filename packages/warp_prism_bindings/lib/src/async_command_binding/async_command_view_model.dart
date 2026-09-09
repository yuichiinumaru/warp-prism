import 'package:meta/meta.dart';
import 'package:warp_prism_runtime/warp_prism_runtime.dart';

/// Immutable presentation state of an [AsyncCommandBinding].
///
/// Encapsulates execution lifecycle status, last evaluated result,
/// typed success payloads, structured errors, and execution metrics
/// for direct consumption by loading indicators, buttons, and state surfaces.
///
/// Lifecycle: EXPERIMENTAL (see `docs/architecture/layer-contracts-v2.md`).
@experimental
@immutable
class AsyncCommandBindingState<TResult> {
  /// Current lifecycle execution status.
  final AsyncCommandStatus status;

  /// The most recent command execution result, if any.
  final CommandResult<TResult>? lastResult;

  /// The most recent successful result value, if any.
  final TResult? lastSuccess;

  /// The most recent execution error, if any.
  final CommandError? lastError;

  /// Cancellation reason if the last execution was cancelled.
  final String? cancellationReason;

  /// Execution duration of the last completed run.
  final Duration? lastDuration;

  /// Timestamp when the last run completed.
  final DateTime? lastTimestamp;

  /// Creates an [AsyncCommandBindingState].
  const AsyncCommandBindingState({
    this.status = AsyncCommandStatus.idle,
    this.lastResult,
    this.lastSuccess,
    this.lastError,
    this.cancellationReason,
    this.lastDuration,
    this.lastTimestamp,
  });

  /// Creates an initial idle state.
  const AsyncCommandBindingState.idle() : this(status: AsyncCommandStatus.idle);

  /// Creates a running state preserving previous success value if available.
  AsyncCommandBindingState<TResult> toRunning() {
    return AsyncCommandBindingState<TResult>(
      status: AsyncCommandStatus.running,
      lastSuccess: lastSuccess,
      lastError: null,
      cancellationReason: null,
      lastResult: null,
      lastDuration: null,
      lastTimestamp: null,
    );
  }

  /// Creates a succeeded state from a [CommandSuccess] result.
  AsyncCommandBindingState<TResult> toSuccess(CommandSuccess<TResult> result) {
    return AsyncCommandBindingState<TResult>(
      status: AsyncCommandStatus.succeeded,
      lastResult: result,
      lastSuccess: result.value,
      lastError: null,
      cancellationReason: null,
      lastDuration: result.duration,
      lastTimestamp: result.timestamp,
    );
  }

  /// Creates a failed state from a [CommandFailure] result.
  AsyncCommandBindingState<TResult> toFailure(CommandFailure<TResult> result) {
    return AsyncCommandBindingState<TResult>(
      status: AsyncCommandStatus.failed,
      lastResult: result,
      lastSuccess: null,
      lastError: result.error,
      cancellationReason: null,
      lastDuration: result.duration,
      lastTimestamp: result.timestamp,
    );
  }

  /// Creates a cancelled state from a [CommandCancelled] result.
  AsyncCommandBindingState<TResult> toCancelled(
    CommandCancelled<TResult> result,
  ) {
    return AsyncCommandBindingState<TResult>(
      status: AsyncCommandStatus.cancelled,
      lastResult: result,
      lastSuccess: lastSuccess,
      lastError: null,
      cancellationReason: result.reason,
      lastDuration: result.duration,
      lastTimestamp: result.timestamp,
    );
  }

  /// Whether the command is ready for execution.
  bool get isIdle => status == AsyncCommandStatus.idle;

  /// Whether the command is currently executing.
  bool get isRunning => status == AsyncCommandStatus.running;

  /// Whether the command completed successfully.
  bool get isSuccess => status == AsyncCommandStatus.succeeded;

  /// Whether the command encountered an error.
  bool get isFailure => status == AsyncCommandStatus.failed;

  /// Whether the command was cancelled.
  bool get isCancelled => status == AsyncCommandStatus.cancelled;

  /// User-friendly error message if execution failed.
  String? get errorMessage => lastError?.message;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AsyncCommandBindingState<TResult> &&
          runtimeType == other.runtimeType &&
          status == other.status &&
          lastSuccess == other.lastSuccess &&
          lastError == other.lastError &&
          cancellationReason == other.cancellationReason;

  @override
  int get hashCode =>
      Object.hash(status, lastSuccess, lastError, cancellationReason);

  @override
  String toString() =>
      'AsyncCommandBindingState(status: $status, lastSuccess: $lastSuccess, lastError: $lastError)';
}
