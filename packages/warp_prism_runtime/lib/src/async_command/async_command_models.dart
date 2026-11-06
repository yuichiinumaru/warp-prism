import 'package:meta/meta.dart';

/// Lifecycle status of an asynchronous command execution.
///
/// Lifecycle: EXPERIMENTAL (see `.project/architecture/layer-contracts.md`).
@experimental
enum AsyncCommandStatus {
  /// Command is initialized and ready for execution.
  idle,

  /// Command is currently executing.
  running,

  /// Command completed execution successfully.
  succeeded,

  /// Command execution encountered an error.
  failed,

  /// Command execution was cancelled before or during execution.
  cancelled,
}

/// Cooperative cancellation token passed to asynchronous operations.
///
/// Enables callers to signal cancellation requests and allows command handlers
/// to cooperatively abort work.
///
/// Lifecycle: EXPERIMENTAL (see `.project/architecture/layer-contracts.md`).
@experimental
class CancellationToken {
  bool _isCancelled = false;
  String? _cancellationReason;
  final List<void Function(String? reason)> _listeners = [];

  /// Creates a [CancellationToken].
  CancellationToken();

  /// Whether cancellation has been requested.
  bool get isCancelled => _isCancelled;

  /// The reason provided when cancellation was requested, if any.
  String? get cancellationReason => _cancellationReason;

  /// Requests cancellation of the associated operation.
  void cancel([String? reason]) {
    if (_isCancelled) return;
    _isCancelled = true;
    _cancellationReason = reason;

    final listenersCopy = List<void Function(String? reason)>.from(_listeners);
    for (final listener in listenersCopy) {
      listener(reason);
    }
  }

  /// Registers a callback invoked when cancellation is requested.
  ///
  /// If already cancelled, the callback is invoked synchronously.
  void attachListener(void Function(String? reason) listener) {
    if (_isCancelled) {
      listener(_cancellationReason);
      return;
    }
    _listeners.add(listener);
  }

  /// Detaches a previously registered cancellation listener.
  void detachListener(void Function(String? reason) listener) {
    _listeners.remove(listener);
  }

  /// Throws a [CommandCancellationException] if cancellation has been requested.
  void throwIfCancelled() {
    if (_isCancelled) {
      throw CommandCancellationException(_cancellationReason);
    }
  }
}

/// Exception thrown when an operation is cancelled via [CancellationToken].
///
/// Lifecycle: EXPERIMENTAL (see `.project/architecture/layer-contracts.md`).
@experimental
@immutable
class CommandCancellationException implements Exception {
  /// Reason for cancellation, if provided.
  final String? reason;

  /// Creates a [CommandCancellationException].
  const CommandCancellationException([this.reason]);

  @override
  String toString() =>
      reason != null ? 'Command cancelled: $reason' : 'Command cancelled';
}

/// Base sealed class representing a typed command execution failure.
///
/// Lifecycle: EXPERIMENTAL (see `.project/architecture/layer-contracts.md`).
@experimental
sealed class CommandError {
  /// Human-readable error message.
  String get message;

  /// Underlying causal exception or error, if any.
  Object? get cause;

  /// Captured stack trace associated with the failure, if available.
  StackTrace? get stackTrace;

  const CommandError();
}

/// Execution error produced by the command logic or handler.
///
/// Lifecycle: EXPERIMENTAL (see `.project/architecture/layer-contracts.md`).
@experimental
@immutable
class CommandExecutionError extends CommandError {
  @override
  final String message;

  @override
  final Object? cause;

  @override
  final StackTrace? stackTrace;

  /// Optional machine-readable error code.
  final String? errorCode;

  /// Creates a [CommandExecutionError].
  const CommandExecutionError({
    required this.message,
    this.cause,
    this.stackTrace,
    this.errorCode,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CommandExecutionError &&
          runtimeType == other.runtimeType &&
          message == other.message &&
          errorCode == other.errorCode;

  @override
  int get hashCode => Object.hash(message, errorCode);

  @override
  String toString() =>
      'CommandExecutionError(message: $message, code: $errorCode, cause: $cause)';
}

/// Validation error produced when command parameters fail preconditions.
///
/// Lifecycle: EXPERIMENTAL (see `.project/architecture/layer-contracts.md`).
@experimental
@immutable
class CommandValidationError extends CommandError {
  @override
  final String message;

  /// Name of the parameter field that failed validation.
  final String field;

  /// The rejected value that caused the validation failure.
  final Object? rejectedValue;

  @override
  Object? get cause => null;

  @override
  StackTrace? get stackTrace => null;

  /// Creates a [CommandValidationError].
  const CommandValidationError({
    required this.message,
    required this.field,
    this.rejectedValue,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CommandValidationError &&
          runtimeType == other.runtimeType &&
          message == other.message &&
          field == other.field &&
          rejectedValue == other.rejectedValue;

  @override
  int get hashCode => Object.hash(message, field, rejectedValue);

  @override
  String toString() =>
      'CommandValidationError(field: $field, rejectedValue: $rejectedValue, message: $message)';
}

/// Timeout error produced when a command exceeds its maximum allowed duration.
///
/// Lifecycle: EXPERIMENTAL (see `.project/architecture/layer-contracts.md`).
@experimental
@immutable
class CommandTimeoutError extends CommandError {
  @override
  final String message;

  /// The timeout threshold that was exceeded.
  final Duration timeout;

  @override
  Object? get cause => null;

  @override
  StackTrace? get stackTrace => null;

  /// Creates a [CommandTimeoutError].
  const CommandTimeoutError({required this.message, required this.timeout});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CommandTimeoutError &&
          runtimeType == other.runtimeType &&
          message == other.message &&
          timeout == other.timeout;

  @override
  int get hashCode => Object.hash(message, timeout);

  @override
  String toString() =>
      'CommandTimeoutError(timeout: $timeout, message: $message)';
}

/// Transport or bridge error produced when communicating with a native or remote backend.
///
/// Lifecycle: EXPERIMENTAL (see `.project/architecture/layer-contracts.md`).
@experimental
@immutable
class CommandTransportError extends CommandError {
  @override
  final String message;

  @override
  final Object? cause;

  @override
  final StackTrace? stackTrace;

  /// Creates a [CommandTransportError].
  const CommandTransportError({
    required this.message,
    this.cause,
    this.stackTrace,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CommandTransportError &&
          runtimeType == other.runtimeType &&
          message == other.message;

  @override
  int get hashCode => message.hashCode;

  @override
  String toString() =>
      'CommandTransportError(message: $message, cause: $cause)';
}

/// Generic fallback error for unspecified command failures.
///
/// Lifecycle: EXPERIMENTAL (see `.project/architecture/layer-contracts.md`).
@experimental
@immutable
class CommandGenericError extends CommandError {
  @override
  final String message;

  @override
  final Object? cause;

  @override
  final StackTrace? stackTrace;

  /// Creates a [CommandGenericError].
  const CommandGenericError({
    required this.message,
    this.cause,
    this.stackTrace,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CommandGenericError &&
          runtimeType == other.runtimeType &&
          message == other.message;

  @override
  int get hashCode => message.hashCode;

  @override
  String toString() => 'CommandGenericError(message: $message, cause: $cause)';
}

/// Sealed result returned by [AsyncCommand.execute].
///
/// Lifecycle: EXPERIMENTAL (see `.project/architecture/layer-contracts.md`).
@experimental
sealed class CommandResult<TResult> {
  /// Execution duration measured from invocation to result resolution.
  Duration get duration;

  /// Timestamp when execution completed or terminated.
  DateTime get timestamp;

  /// Metadata attributes attached to this execution result.
  Map<String, Object?> get metadata;

  const CommandResult();
}

/// Successful command execution result carrying typed value [value].
///
/// Lifecycle: EXPERIMENTAL (see `.project/architecture/layer-contracts.md`).
@experimental
@immutable
class CommandSuccess<TResult> extends CommandResult<TResult> {
  /// The typed result value.
  final TResult value;

  @override
  final Duration duration;

  @override
  final DateTime timestamp;

  @override
  final Map<String, Object?> metadata;

  /// Creates a [CommandSuccess] result.
  const CommandSuccess({
    required this.value,
    required this.duration,
    required this.timestamp,
    this.metadata = const {},
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CommandSuccess<TResult> &&
          runtimeType == other.runtimeType &&
          value == other.value &&
          duration == other.duration &&
          timestamp == other.timestamp;

  @override
  int get hashCode => Object.hash(value, duration, timestamp);

  @override
  String toString() =>
      'CommandSuccess(value: $value, duration: ${duration.inMilliseconds}ms)';
}

/// Failed command execution result carrying typed [error].
///
/// Lifecycle: EXPERIMENTAL (see `.project/architecture/layer-contracts.md`).
@experimental
@immutable
class CommandFailure<TResult> extends CommandResult<TResult> {
  /// The typed error describing why execution failed.
  final CommandError error;

  @override
  final Duration duration;

  @override
  final DateTime timestamp;

  @override
  final Map<String, Object?> metadata;

  /// Creates a [CommandFailure] result.
  const CommandFailure({
    required this.error,
    required this.duration,
    required this.timestamp,
    this.metadata = const {},
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CommandFailure<TResult> &&
          runtimeType == other.runtimeType &&
          error == other.error &&
          duration == other.duration &&
          timestamp == other.timestamp;

  @override
  int get hashCode => Object.hash(error, duration, timestamp);

  @override
  String toString() =>
      'CommandFailure(error: $error, duration: ${duration.inMilliseconds}ms)';
}

/// Cancelled command execution result.
///
/// Lifecycle: EXPERIMENTAL (see `.project/architecture/layer-contracts.md`).
@experimental
@immutable
class CommandCancelled<TResult> extends CommandResult<TResult> {
  /// The reason why cancellation occurred, if provided.
  final String? reason;

  @override
  final Duration duration;

  @override
  final DateTime timestamp;

  @override
  final Map<String, Object?> metadata;

  /// Creates a [CommandCancelled] result.
  const CommandCancelled({
    this.reason,
    required this.duration,
    required this.timestamp,
    this.metadata = const {},
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CommandCancelled<TResult> &&
          runtimeType == other.runtimeType &&
          reason == other.reason &&
          duration == other.duration &&
          timestamp == other.timestamp;

  @override
  int get hashCode => Object.hash(reason, duration, timestamp);

  @override
  String toString() =>
      'CommandCancelled(reason: $reason, duration: ${duration.inMilliseconds}ms)';
}
