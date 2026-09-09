import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';
import 'package:warp_prism_runtime/warp_prism_runtime.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

/// Operational lifecycle status of a [HealthSourceBinding].
///
/// Lifecycle: EXPERIMENTAL (see `docs/architecture/layer-contracts-v2.md`).
@experimental
enum HealthSourceBindingStatus {
  /// Uninitialized, waiting for initial snapshot evaluation.
  uninitialized,

  /// Actively receiving and projecting health snapshot observations.
  active,

  /// Source watch stream encountered an error.
  error,

  /// Source stream has terminated and completed.
  completed,

  /// Binding has been disposed and released all subscriptions.
  disposed,
}

/// Immutable presentation view model snapshot of system and provider health.
///
/// Projects point-in-time [HealthSnapshot] evaluations into UI-ready models
/// with freshness tracking, aggregate worst-state rollup, and direct
/// convergence helpers for [PrismProviderHealthMatrix] surfaces.
///
/// **PURGE LAW**: This view model contains strictly zero timer objects,
/// polling tickers, or network loops.
///
/// Lifecycle: EXPERIMENTAL (see `docs/architecture/layer-contracts-v2.md`).
@experimental
@immutable
class HealthSourceViewModel {
  /// Point-in-time timestamp when this health snapshot was evaluated.
  final DateTime timestamp;

  /// Health dimension cells included in this projection.
  final List<HealthCell> cells;

  /// Aggregated operational state derived across all cells.
  final HealthState aggregateState;

  /// Optional declared time-to-live after which this snapshot is considered stale.
  final Duration? freshnessTtl;

  /// Whether this snapshot is considered stale as of its evaluation time.
  final bool isStale;

  /// Semantic metadata attributes.
  final Map<String, Object?> metadata;

  /// Deterministic epoch-0 UTC fallback timestamp for uninitialized or empty view models.
  static final DateTime deterministicFallbackTimestamp =
      DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);

  /// Creates an immutable [HealthSourceViewModel].
  const HealthSourceViewModel({
    required this.timestamp,
    required this.cells,
    required this.aggregateState,
    this.freshnessTtl,
    this.isStale = false,
    this.metadata = const {},
  });

  /// Creates an empty initial [HealthSourceViewModel].
  HealthSourceViewModel.empty({DateTime? timestamp})
    : timestamp = timestamp ?? deterministicFallbackTimestamp,
      cells = const [],
      aggregateState = HealthState.unknown,
      freshnessTtl = null,
      isStale = false,
      metadata = const {};

  /// Factory constructing a view model from a runtime [HealthSnapshot].
  factory HealthSourceViewModel.fromSnapshot(
    HealthSnapshot snapshot, {
    DateTime? asOf,
    Duration? maxAge,
  }) {
    final fresh = snapshot.isFresh(asOf: asOf, maxAge: maxAge);
    return HealthSourceViewModel(
      timestamp: snapshot.timestamp,
      cells: snapshot.cells,
      aggregateState: snapshot.aggregateState,
      freshnessTtl: snapshot.freshnessTtl,
      isStale: !fresh,
      metadata: snapshot.metadata,
    );
  }

  /// Total count of health cells in this snapshot.
  int get cellCount => cells.length;

  /// Whether this view model contains zero cells.
  bool get isEmpty => cells.isEmpty;

  /// Whether this view model contains at least one cell.
  bool get isNotEmpty => cells.isNotEmpty;

  /// Whether this snapshot is fresh (not stale).
  bool get isFresh => !isStale;

  /// Unique provider IDs in first-encountered order.
  List<String> get providerIds {
    final seen = <String>{};
    final result = <String>[];
    for (final cell in cells) {
      if (seen.add(cell.providerId)) {
        result.add(cell.providerId);
      }
    }
    return List.unmodifiable(result);
  }

  /// Unique dimension IDs in first-encountered order.
  List<String> get dimensionIds {
    final seen = <String>{};
    final result = <String>[];
    for (final cell in cells) {
      if (seen.add(cell.dimensionId)) {
        result.add(cell.dimensionId);
      }
    }
    return List.unmodifiable(result);
  }

  /// Looks up a cell by its unique string identifier.
  HealthCell? cellById(String id) {
    for (final cell in cells) {
      if (cell.id == id) return cell;
    }
    return null;
  }

  /// Filters cells belonging to [providerId].
  List<HealthCell> cellsForProvider(String providerId) =>
      cells.where((c) => c.providerId == providerId).toList(growable: false);

  /// Filters cells belonging to [dimensionId].
  List<HealthCell> cellsForDimension(String dimensionId) =>
      cells.where((c) => c.dimensionId == dimensionId).toList(growable: false);

  /// Projects cells into a list of [PrismProviderHealthProvider] models for [PrismProviderHealthMatrix].
  ///
  /// When [markStaleAsStale] is `true` and this view model [isStale], cell operational
  /// states and provider aggregates are mapped to [PrismOperationalState.stale].
  List<PrismProviderHealthProvider> toProviderHealthProviders({
    bool markStaleAsStale = false,
  }) {
    return HealthSourceMappers.snapshotToProviderHealthProviders(
      HealthSnapshot(
        timestamp: timestamp,
        cells: cells,
        aggregateState: aggregateState,
        freshnessTtl: freshnessTtl,
        metadata: metadata,
      ),
      isStale: markStaleAsStale && isStale,
    );
  }

  /// Projects individual cells to [PrismProviderHealthCell] models.
  List<PrismProviderHealthCell> toProviderHealthCells({
    bool markStaleAsStale = false,
  }) {
    final applyStale = markStaleAsStale && isStale;
    return cells
        .map(
          (cell) => HealthSourceMappers.cellToProviderHealthCell(
            cell,
            isStale: applyStale,
          ),
        )
        .toList(growable: false);
  }

  /// Creates a copy with substituted fields.
  HealthSourceViewModel copyWith({
    DateTime? timestamp,
    List<HealthCell>? cells,
    HealthState? aggregateState,
    Duration? freshnessTtl,
    bool? isStale,
    Map<String, Object?>? metadata,
  }) {
    return HealthSourceViewModel(
      timestamp: timestamp ?? this.timestamp,
      cells: cells ?? this.cells,
      aggregateState: aggregateState ?? this.aggregateState,
      freshnessTtl: freshnessTtl ?? this.freshnessTtl,
      isStale: isStale ?? this.isStale,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HealthSourceViewModel &&
          runtimeType == other.runtimeType &&
          timestamp == other.timestamp &&
          aggregateState == other.aggregateState &&
          freshnessTtl == other.freshnessTtl &&
          isStale == other.isStale &&
          listEquals(cells, other.cells);

  @override
  int get hashCode => Object.hash(
    timestamp,
    aggregateState,
    freshnessTtl,
    isStale,
    Object.hashAll(cells),
  );

  @override
  String toString() =>
      'HealthSourceViewModel(timestamp: $timestamp, cells: ${cells.length}, aggregate: $aggregateState, isStale: $isStale)';
}

/// Utility mappers projecting runtime health objects to UI presentation models.
///
/// Lifecycle: EXPERIMENTAL (see `docs/architecture/layer-contracts-v2.md`).
@experimental
class HealthSourceMappers {
  const HealthSourceMappers._();

  /// Maps a semantic [HealthState] to a presentation [PrismOperationalState].
  ///
  /// When [isStale] is `true`, maps to [PrismOperationalState.stale].
  static PrismOperationalState healthStateToOperationalState(
    HealthState state, {
    bool isStale = false,
  }) {
    if (isStale) {
      return PrismOperationalState.stale;
    }
    switch (state) {
      case HealthState.healthy:
        return PrismOperationalState.healthy;
      case HealthState.degraded:
        return PrismOperationalState.degraded;
      case HealthState.unreachable:
        return PrismOperationalState.error;
      case HealthState.unknown:
        return PrismOperationalState.unverified;
    }
  }

  /// Maps a presentation [PrismOperationalState] to a semantic [HealthState].
  static HealthState operationalStateToHealthState(PrismOperationalState state) {
    switch (state) {
      case PrismOperationalState.healthy:
      case PrismOperationalState.approved:
      case PrismOperationalState.promoted:
        return HealthState.healthy;
      case PrismOperationalState.degraded:
      case PrismOperationalState.stale:
      case PrismOperationalState.running:
      case PrismOperationalState.pending:
        return HealthState.degraded;
      case PrismOperationalState.error:
      case PrismOperationalState.rejected:
      case PrismOperationalState.exposed:
        return HealthState.unreachable;
      case PrismOperationalState.disabled:
      case PrismOperationalState.unverified:
      case PrismOperationalState.redacted:
      case PrismOperationalState.excluded:
      case PrismOperationalState.archived:
        return HealthState.unknown;
    }
  }

  /// Maps a runtime [HealthCell] to a presentation [PrismProviderHealthCell].
  static PrismProviderHealthCell cellToProviderHealthCell(
    HealthCell cell, {
    bool isStale = false,
  }) {
    final metaValue =
        cell.metadata['meta']?.toString() ??
        cell.metadata['region']?.toString() ??
        (cell.metadata.isNotEmpty ? cell.metadata.toString() : null);

    return PrismProviderHealthCell(
      id: cell.id,
      providerId: cell.providerId,
      providerLabel: cell.providerLabel,
      dimensionId: cell.dimensionId,
      dimensionLabel: cell.dimensionLabel,
      operationalState: healthStateToOperationalState(
        cell.state,
        isStale: isStale,
      ),
      latency: cell.latency,
      meta: metaValue,
    );
  }

  /// Groups and projects a [HealthSnapshot] into [PrismProviderHealthProvider] row models.
  static List<PrismProviderHealthProvider> snapshotToProviderHealthProviders(
    HealthSnapshot snapshot, {
    bool isStale = false,
  }) {
    final providerGroups = <String, List<HealthCell>>{};
    final providerLabels = <String, String>{};

    for (final cell in snapshot.cells) {
      providerGroups.putIfAbsent(cell.providerId, () => []).add(cell);
      providerLabels.putIfAbsent(cell.providerId, () => cell.providerLabel);
    }

    final result = <PrismProviderHealthProvider>[];
    for (final entry in providerGroups.entries) {
      final providerId = entry.key;
      final providerCells = entry.value;
      final providerLabel = providerLabels[providerId] ?? providerId;

      final projectedCells = providerCells
          .map((c) => cellToProviderHealthCell(c, isStale: isStale))
          .toList(growable: false);

      final providerWorstHealthState = HealthSnapshot.deriveAggregateState(
        providerCells,
      );
      final providerAggregate = healthStateToOperationalState(
        providerWorstHealthState,
        isStale: isStale,
      );

      result.add(
        PrismProviderHealthProvider(
          id: providerId,
          label: providerLabel,
          cells: projectedCells,
          aggregateState: providerAggregate,
        ),
      );
    }

    return List.unmodifiable(result);
  }
}
