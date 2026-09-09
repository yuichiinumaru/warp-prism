import 'package:meta/meta.dart';

/// Service Level Objective (SLO) metric declarations for [AsyncCommand].
///
/// Declares target dispatch and cancellation latency bounds for asynchronous command invocations.
///
/// Lifecycle: EXPERIMENTAL (see `docs/architecture/layer-contracts-v2.md`).
@experimental
@immutable
class AsyncCommandSlo {
  /// Target maximum dispatch and execution overhead in microseconds.
  final int targetMaxExecutionOverheadMicros;

  /// Target maximum cancellation propagation latency in microseconds.
  final int targetMaxCancellationLatencyMicros;

  /// Creates an immutable [AsyncCommandSlo] declaration.
  const AsyncCommandSlo({
    this.targetMaxExecutionOverheadMicros = 500,
    this.targetMaxCancellationLatencyMicros = 500,
  });

  /// Default standard baseline SLO for async commands.
  static const AsyncCommandSlo standard = AsyncCommandSlo();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AsyncCommandSlo &&
          runtimeType == other.runtimeType &&
          targetMaxExecutionOverheadMicros ==
              other.targetMaxExecutionOverheadMicros &&
          targetMaxCancellationLatencyMicros ==
              other.targetMaxCancellationLatencyMicros;

  @override
  int get hashCode => Object.hash(
    targetMaxExecutionOverheadMicros,
    targetMaxCancellationLatencyMicros,
  );

  @override
  String toString() =>
      'AsyncCommandSlo(maxOverhead: $targetMaxExecutionOverheadMicros µs, maxCancelLatency: $targetMaxCancellationLatencyMicros µs)';
}
