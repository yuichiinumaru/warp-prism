import 'package:meta/meta.dart';

/// Service Level Objective (SLO) metric declarations for [HealthSource].
///
/// Declares target responsiveness bounds for on-demand snapshot queries
/// and reactive state change broadcasts.
///
/// Lifecycle: EXPERIMENTAL (see `docs/architecture/layer-contracts-v2.md`).
@experimental
@immutable
class HealthSourceSlo {
  /// Target maximum latency in milliseconds for evaluating a point-in-time snapshot.
  final int targetMaxSnapshotLatencyMs;

  /// Target maximum delay in milliseconds from state change to stream emission.
  final int targetMaxWatchPropagationDelayMs;

  /// Creates an immutable [HealthSourceSlo] declaration.
  const HealthSourceSlo({
    this.targetMaxSnapshotLatencyMs = 50,
    this.targetMaxWatchPropagationDelayMs = 100,
  });

  /// Default standard baseline SLO for health sources.
  static const HealthSourceSlo standard = HealthSourceSlo();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HealthSourceSlo &&
          runtimeType == other.runtimeType &&
          targetMaxSnapshotLatencyMs == other.targetMaxSnapshotLatencyMs &&
          targetMaxWatchPropagationDelayMs ==
              other.targetMaxWatchPropagationDelayMs;

  @override
  int get hashCode =>
      Object.hash(targetMaxSnapshotLatencyMs, targetMaxWatchPropagationDelayMs);

  @override
  String toString() =>
      'HealthSourceSlo(maxSnapshotLatency: ${targetMaxSnapshotLatencyMs}ms, maxWatchDelay: ${targetMaxWatchPropagationDelayMs}ms)';
}
