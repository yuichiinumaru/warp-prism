import 'package:meta/meta.dart';

/// Service Level Objective (SLO) metric declarations for [GraphSource].
///
/// Declares target performance metrics for graph node/edge lookups and
/// reactive topological update broadcasts.
///
/// Lifecycle: EXPERIMENTAL (see `.project/architecture/layer-contracts.md`).
@experimental
@immutable
class GraphSourceSlo {
  /// Target maximum lookup latency in microseconds for node/edge indexed access.
  final int targetMaxSnapshotLookupMicros;

  /// Target maximum broadcast latency in microseconds for update stream notifications.
  final int targetMaxUpdateBroadcastLatencyMicros;

  /// Creates an immutable [GraphSourceSlo] declaration.
  const GraphSourceSlo({
    this.targetMaxSnapshotLookupMicros = 100,
    this.targetMaxUpdateBroadcastLatencyMicros = 500,
  });

  /// Default standard baseline SLO for graph sources.
  static const GraphSourceSlo standard = GraphSourceSlo();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GraphSourceSlo &&
          runtimeType == other.runtimeType &&
          targetMaxSnapshotLookupMicros ==
              other.targetMaxSnapshotLookupMicros &&
          targetMaxUpdateBroadcastLatencyMicros ==
              other.targetMaxUpdateBroadcastLatencyMicros;

  @override
  int get hashCode => Object.hash(
    targetMaxSnapshotLookupMicros,
    targetMaxUpdateBroadcastLatencyMicros,
  );

  @override
  String toString() =>
      'GraphSourceSlo(maxLookup: $targetMaxSnapshotLookupMicros µs, maxBroadcast: $targetMaxUpdateBroadcastLatencyMicros µs)';
}
