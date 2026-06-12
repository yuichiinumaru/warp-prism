/// Asset selection controller for universal asset detail.
///
/// Centralizes selection and resolution of [assetId] against the
/// normalized repository state. Handles:
/// - Valid asset selection (resolves to a loaded asset)
/// - Unknown/unresolved asset (falls back gracefully)
/// - Selection synchronization between route, data refresh, and
///   inspector close/open
///
/// This controller is the single entry point for the asset detail
/// surface. All consumers (Map, Operate, History, Governance) use
/// this controller instead of managing selection locally.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/services/workspace_graph.dart';
import '../data/models/workspace_graph.dart';

// ---------------------------------------------------------------------------
// Selection State
// ---------------------------------------------------------------------------

/// The resolved state of an asset selection.
enum AssetSelectionStatus {
  /// No asset selected (detail panel closed).
  idle,

  /// Asset ID received but not yet resolved.
  pending,

  /// Asset successfully resolved from the graph.
  resolved,

  /// Asset ID could not be resolved (unknown or missing).
  unresolved,
}

/// Immutable selection state for the asset detail surface.
class AssetSelectionState {
  /// Current selection status.
  final AssetSelectionStatus status;

  /// The raw asset ID from the route or selection trigger.
  final String? assetId;

  /// The resolved asset (non-null when [status] is [AssetSelectionStatus.resolved]).
  final WorkspaceAsset? asset;

  /// Incoming edges for the resolved asset.
  final List<WorkspaceEdge> incomingEdges;

  /// Outgoing edges for the resolved asset.
  final List<WorkspaceEdge> outgoingEdges;

  /// The origin surface that triggered this selection (e.g., 'map', 'operate').
  final String? origin;

  const AssetSelectionState({
    this.status = AssetSelectionStatus.idle,
    this.assetId,
    this.asset,
    this.incomingEdges = const [],
    this.outgoingEdges = const [],
    this.origin,
  });

  /// An idle state with no selection.
  static const idle = AssetSelectionState();

  /// Whether an asset is selected and resolved.
  bool get isResolved =>
      status == AssetSelectionStatus.resolved && asset != null;

  /// Whether the selection is unresolved (unknown asset).
  bool get isUnresolved => status == AssetSelectionStatus.unresolved;

  /// Whether a selection is active (pending or resolved).
  bool get isActive =>
      status == AssetSelectionStatus.pending ||
      status == AssetSelectionStatus.resolved;

  AssetSelectionState copyWith({
    AssetSelectionStatus? status,
    String? assetId,
    WorkspaceAsset? asset,
    List<WorkspaceEdge>? incomingEdges,
    List<WorkspaceEdge>? outgoingEdges,
    String? origin,
    bool clearAsset = false,
    bool clearOrigin = false,
  }) {
    return AssetSelectionState(
      status: status ?? this.status,
      assetId: assetId ?? this.assetId,
      asset: clearAsset ? null : (asset ?? this.asset),
      incomingEdges: incomingEdges ?? this.incomingEdges,
      outgoingEdges: outgoingEdges ?? this.outgoingEdges,
      origin: clearOrigin ? null : (origin ?? this.origin),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AssetSelectionState &&
          runtimeType == other.runtimeType &&
          status == other.status &&
          assetId == other.assetId &&
          origin == other.origin;

  @override
  int get hashCode => Object.hash(status, assetId, origin);

  @override
  String toString() =>
      'AssetSelectionState(${status.name}, id: $assetId, '
      'resolved: ${asset?.name ?? "null"}, origin: $origin)';
}

// ---------------------------------------------------------------------------
// Selection Controller
// ---------------------------------------------------------------------------

/// Riverpod notifier that manages asset selection state.
///
/// Resolves an [assetId] against the workspace graph, handles fallback
/// for unknown assets, and keeps selection synchronized across route
/// changes and data refreshes.
class AssetSelectionController extends Notifier<AssetSelectionState> {
  @override
  AssetSelectionState build() {
    return AssetSelectionState.idle;
  }

  /// Select an asset by ID, resolving it from the graph.
  ///
  /// If [origin] is provided, records which surface triggered the selection.
  /// Unknown assets resolve to [AssetSelectionStatus.unresolved] instead
  /// of crashing or entering a navigation loop.
  void select(String assetId, {String? origin, WorkspaceGraphResult? graph}) {
    // Mark as pending while resolving
    state = state.copyWith(
      status: AssetSelectionStatus.pending,
      assetId: assetId,
      origin: origin,
    );

    if (graph == null || graph.isEmpty) {
      // No graph available — mark as unresolved
      state = state.copyWith(status: AssetSelectionStatus.unresolved);
      return;
    }

    _resolveFromGraph(assetId, graph);
  }

  /// Resolve the current selection against a refreshed graph.
  ///
  /// Called after data reload to keep the selection synchronized.
  void resolveAgainst(WorkspaceGraphResult graph) {
    if (state.assetId == null) return;
    _resolveFromGraph(state.assetId!, graph);
  }

  /// Clear the current selection (close the detail inspector).
  void clear() {
    state = AssetSelectionState.idle;
  }

  /// Build the canonical detail route path for an asset ID.
  static String detailRoute(String assetId) => '/assets/$assetId';

  void _resolveFromGraph(String assetId, WorkspaceGraphResult graph) {
    final asset = graph.getAsset(assetId);

    if (asset != null) {
      state = state.copyWith(
        status: AssetSelectionStatus.resolved,
        asset: asset,
        incomingEdges: graph.incomingEdges(assetId),
        outgoingEdges: graph.outgoingEdges(assetId),
      );
    } else {
      state = state.copyWith(
        status: AssetSelectionStatus.unresolved,
        clearAsset: true,
      );
    }
  }
}

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

/// The asset selection controller provider.
final assetSelectionControllerProvider =
    NotifierProvider<AssetSelectionController, AssetSelectionState>(
      AssetSelectionController.new,
    );

/// Convenience provider: the currently selected asset (null if none).
final selectedAssetDetailProvider = Provider<WorkspaceAsset?>((ref) {
  return ref.watch(assetSelectionControllerProvider).asset;
});

/// Convenience provider: whether the detail inspector is open.
final isAssetDetailOpenProvider = Provider<bool>((ref) {
  final status = ref.watch(assetSelectionControllerProvider).status;
  return status == AssetSelectionStatus.resolved ||
      status == AssetSelectionStatus.unresolved;
});
