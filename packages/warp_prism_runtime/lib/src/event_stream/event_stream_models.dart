import 'package:meta/meta.dart';

/// Severity level associated with a runtime event or log emission.
///
/// Lifecycle: EXPERIMENTAL (see `.project/architecture/layer-contracts.md`).
@experimental
enum EventSeverity {
  /// Standard process output stream.
  stdout,

  /// Standard process error stream.
  stderr,

  /// Informational event.
  info,

  /// Warning condition event.
  warning,

  /// Error condition event.
  error,

  /// System-level lifecycle or diagnostic event.
  system,
}

/// Backpressure buffering strategy for an event stream.
///
/// Declares buffer behavior when consumers cannot process events as fast
/// as they are produced.
///
/// Lifecycle: EXPERIMENTAL (see `.project/architecture/layer-contracts.md`).
@experimental
enum BackpressureStrategy {
  /// Unbounded buffering without dropping.
  unbounded,

  /// Drops the oldest events when buffer capacity is reached.
  dropOldest,

  /// Drops the newest incoming events when buffer capacity is reached.
  dropNewest,

  /// Emits an error event or throws when buffer capacity is reached.
  errorOnOverflow,
}

/// Backpressure policy specification for an [EventStream].
///
/// Lifecycle: EXPERIMENTAL (see `.project/architecture/layer-contracts.md`).
@experimental
@immutable
class EventStreamBackpressurePolicy {
  /// The buffer management strategy.
  final BackpressureStrategy strategy;

  /// The buffer capacity limit, if bounded.
  final int? capacity;

  /// Creates a backpressure policy configuration.
  const EventStreamBackpressurePolicy({required this.strategy, this.capacity});

  /// Unbounded buffering policy.
  const EventStreamBackpressurePolicy.unbounded()
    : strategy = BackpressureStrategy.unbounded,
      capacity = null;

  /// Drops oldest events when buffer exceeds [capacity].
  const EventStreamBackpressurePolicy.dropOldest(this.capacity)
    : strategy = BackpressureStrategy.dropOldest;

  /// Drops newest events when buffer exceeds [capacity].
  const EventStreamBackpressurePolicy.dropNewest(this.capacity)
    : strategy = BackpressureStrategy.dropNewest;

  /// Signals error when buffer exceeds [capacity].
  const EventStreamBackpressurePolicy.errorOnOverflow(this.capacity)
    : strategy = BackpressureStrategy.errorOnOverflow;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EventStreamBackpressurePolicy &&
          runtimeType == other.runtimeType &&
          strategy == other.strategy &&
          capacity == other.capacity;

  @override
  int get hashCode => Object.hash(strategy, capacity);

  @override
  String toString() =>
      'EventStreamBackpressurePolicy(strategy: $strategy, capacity: $capacity)';
}

/// A discrete, ordered runtime event payload with provenance metadata.
///
/// Runtime events represent append-only data emissions (e.g. execution output,
/// telemetry pulses, trace items). They carry semantic identification and
/// ordering metadata, strictly free of viewport or presentation flags.
///
/// Lifecycle: EXPERIMENTAL (see `.project/architecture/layer-contracts.md`).
@experimental
@immutable
class RuntimeEvent<T> {
  /// Unique identifier for this event.
  final String id;

  /// Timestamp when the event occurred.
  final DateTime timestamp;

  /// Severity channel of this event.
  final EventSeverity severity;

  /// Optional source or subsystem attribution.
  final String? source;

  /// Optional execution or run group attribution for correlation.
  final String? runGroupId;

  /// The typed payload data carried by this event.
  final T payload;

  /// Additional semantic metadata attributes.
  final Map<String, Object?> metadata;

  /// Creates an immutable [RuntimeEvent].
  const RuntimeEvent({
    required this.id,
    required this.timestamp,
    required this.payload,
    this.severity = EventSeverity.info,
    this.source,
    this.runGroupId,
    this.metadata = const {},
  });

  /// Derives an updated copy with substituted fields.
  RuntimeEvent<T> copyWith({
    String? id,
    DateTime? timestamp,
    EventSeverity? severity,
    String? source,
    String? runGroupId,
    T? payload,
    Map<String, Object?>? metadata,
  }) {
    return RuntimeEvent<T>(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      severity: severity ?? this.severity,
      source: source ?? this.source,
      runGroupId: runGroupId ?? this.runGroupId,
      payload: payload ?? this.payload,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RuntimeEvent<T> &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          timestamp == other.timestamp &&
          severity == other.severity &&
          source == other.source &&
          runGroupId == other.runGroupId &&
          payload == other.payload;

  @override
  int get hashCode =>
      Object.hash(id, timestamp, severity, source, runGroupId, payload);

  @override
  String toString() =>
      'RuntimeEvent(id: $id, timestamp: $timestamp, severity: $severity, source: $source, runGroupId: $runGroupId, payload: $payload)';
}
