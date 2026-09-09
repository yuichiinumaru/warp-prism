import 'package:meta/meta.dart';

/// Semantic operational health state.
///
/// Lifecycle: EXPERIMENTAL (see `docs/architecture/layer-contracts-v2.md`).
@experimental
enum HealthState {
  /// The component or provider is fully operational within nominal parameters.
  healthy,

  /// The component is operational but experiencing degraded performance or warnings.
  degraded,

  /// The component or provider is unreachable or experiencing a fatal outage.
  unreachable,

  /// The health status cannot be determined or has not yet been probed.
  unknown,
}

/// A discrete health evaluation cell representing a single dimension of a provider.
///
/// Pure semantic data representation free of layout, table geometry,
/// or polling timer logic.
///
/// Lifecycle: EXPERIMENTAL (see `docs/architecture/layer-contracts-v2.md`).
@experimental
@immutable
class HealthCell {
  /// Unique cell identifier.
  final String id;

  /// Identifier of the provider or subsystem being monitored.
  final String providerId;

  /// Human-readable label for the provider.
  final String providerLabel;

  /// Identifier of the monitored health dimension (e.g. latency, error-rate, auth).
  final String dimensionId;

  /// Human-readable label for the health dimension.
  final String dimensionLabel;

  /// Current operational state of this cell.
  final HealthState state;

  /// Optional measured latency duration.
  final Duration? latency;

  /// Semantic metadata attributes.
  final Map<String, Object?> metadata;

  /// Creates an immutable [HealthCell].
  const HealthCell({
    required this.id,
    required this.providerId,
    required this.providerLabel,
    required this.dimensionId,
    required this.dimensionLabel,
    required this.state,
    this.latency,
    this.metadata = const {},
  });

  /// Derives an updated copy with substituted fields.
  HealthCell copyWith({
    String? id,
    String? providerId,
    String? providerLabel,
    String? dimensionId,
    String? dimensionLabel,
    HealthState? state,
    Duration? latency,
    Map<String, Object?>? metadata,
  }) {
    return HealthCell(
      id: id ?? this.id,
      providerId: providerId ?? this.providerId,
      providerLabel: providerLabel ?? this.providerLabel,
      dimensionId: dimensionId ?? this.dimensionId,
      dimensionLabel: dimensionLabel ?? this.dimensionLabel,
      state: state ?? this.state,
      latency: latency ?? this.latency,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HealthCell &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          providerId == other.providerId &&
          providerLabel == other.providerLabel &&
          dimensionId == other.dimensionId &&
          dimensionLabel == other.dimensionLabel &&
          state == other.state &&
          latency == other.latency;

  @override
  int get hashCode => Object.hash(
    id,
    providerId,
    providerLabel,
    dimensionId,
    dimensionLabel,
    state,
    latency,
  );

  @override
  String toString() =>
      'HealthCell(id: $id, provider: $providerLabel ($providerId), dimension: $dimensionLabel ($dimensionId), state: $state, latency: $latency)';
}

/// Point-in-time snapshot of system or provider health cells.
///
/// Carries timestamp and freshness metadata for downstream evaluation.
///
/// Lifecycle: EXPERIMENTAL (see `docs/architecture/layer-contracts-v2.md`).
@experimental
@immutable
class HealthSnapshot {
  /// Point-in-time timestamp when this snapshot was evaluated.
  final DateTime timestamp;

  /// List of health dimension cells evaluated in this snapshot.
  final List<HealthCell> cells;

  /// Aggregated operational state derived from individual cells.
  final HealthState aggregateState;

  /// Optional declared time-to-live after which this snapshot is considered stale.
  final Duration? freshnessTtl;

  /// Semantic metadata attributes.
  final Map<String, Object?> metadata;

  /// Creates an immutable [HealthSnapshot].
  const HealthSnapshot({
    required this.timestamp,
    required this.cells,
    required this.aggregateState,
    this.freshnessTtl,
    this.metadata = const {},
  });

  /// Evaluates whether this snapshot remains fresh at [asOf] time.
  bool isFresh({DateTime? asOf, Duration? maxAge}) {
    final referenceTime = asOf ?? DateTime.now();
    final allowedAge = maxAge ?? freshnessTtl;
    if (allowedAge == null) return true;
    final age = referenceTime.difference(timestamp);
    return age <= allowedAge;
  }

  /// Looks up a cell by its unique [cellId].
  HealthCell? getCell(String cellId) {
    for (final cell in cells) {
      if (cell.id == cellId) return cell;
    }
    return null;
  }

  /// Filters cells belonging to [providerId].
  List<HealthCell> cellsForProvider(String providerId) =>
      cells.where((c) => c.providerId == providerId).toList(growable: false);

  /// Filters cells belonging to [dimensionId].
  List<HealthCell> cellsForDimension(String dimensionId) =>
      cells.where((c) => c.dimensionId == dimensionId).toList(growable: false);

  /// Derives aggregate [HealthState] using standard worst-state fold.
  ///
  /// Priority: [HealthState.unreachable] > [HealthState.degraded] >
  /// [HealthState.unknown] > [HealthState.healthy].
  static HealthState deriveAggregateState(Iterable<HealthCell> cells) {
    if (cells.isEmpty) return HealthState.unknown;

    var hasDegraded = false;
    var hasUnknown = false;

    for (final cell in cells) {
      if (cell.state == HealthState.unreachable) {
        return HealthState.unreachable;
      } else if (cell.state == HealthState.degraded) {
        hasDegraded = true;
      } else if (cell.state == HealthState.unknown) {
        hasUnknown = true;
      }
    }

    if (hasDegraded) return HealthState.degraded;
    if (hasUnknown) return HealthState.unknown;
    return HealthState.healthy;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HealthSnapshot &&
          runtimeType == other.runtimeType &&
          timestamp == other.timestamp &&
          aggregateState == other.aggregateState &&
          freshnessTtl == other.freshnessTtl;

  @override
  int get hashCode => Object.hash(timestamp, aggregateState, freshnessTtl);

  @override
  String toString() =>
      'HealthSnapshot(timestamp: $timestamp, cellsCount: ${cells.length}, aggregate: $aggregateState, ttl: $freshnessTtl)';
}
