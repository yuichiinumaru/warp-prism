import 'package:meta/meta.dart';

/// Declares the ordering guarantee provided by an [EventStream] implementation.
///
/// In Warp Prism, event streams adhere to strict append-only FIFO ordering
/// where emissions are delivered to listeners in the exact sequence they
/// were produced.
///
/// Lifecycle: EXPERIMENTAL (see `docs/architecture/layer-contracts-v2.md`).
@experimental
enum EventOrderingGuarantee {
  /// Strict append-only chronological ordering (oldest to newest).
  appendOnlyOrdered,
}

/// Service Level Objective (SLO) metric declarations for [EventStream].
///
/// Declares runtime performance and ordering expectations as pure contract
/// data without speculative low-level optimization machinery.
///
/// Lifecycle: EXPERIMENTAL (see `docs/architecture/layer-contracts-v2.md`).
@experimental
@immutable
class EventStreamSlo {
  /// Target minimum throughput in events per second.
  final int targetThroughputEventsPerSecond;

  /// Target maximum dispatch latency in microseconds under standard load.
  final int targetMaxDispatchLatencyMicros;

  /// The formal ordering guarantee provided by the stream implementation.
  final EventOrderingGuarantee orderingGuarantee;

  /// Creates an immutable [EventStreamSlo] declaration.
  const EventStreamSlo({
    this.targetThroughputEventsPerSecond = 10000,
    this.targetMaxDispatchLatencyMicros = 500,
    this.orderingGuarantee = EventOrderingGuarantee.appendOnlyOrdered,
  });

  /// Default baseline SLO for in-memory and bridge event streams.
  static const EventStreamSlo standard = EventStreamSlo();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EventStreamSlo &&
          runtimeType == other.runtimeType &&
          targetThroughputEventsPerSecond ==
              other.targetThroughputEventsPerSecond &&
          targetMaxDispatchLatencyMicros ==
              other.targetMaxDispatchLatencyMicros &&
          orderingGuarantee == other.orderingGuarantee;

  @override
  int get hashCode => Object.hash(
    targetThroughputEventsPerSecond,
    targetMaxDispatchLatencyMicros,
    orderingGuarantee,
  );

  @override
  String toString() =>
      'EventStreamSlo(throughput: $targetThroughputEventsPerSecond/s, maxLatency: $targetMaxDispatchLatencyMicros µs, ordering: $orderingGuarantee)';
}
