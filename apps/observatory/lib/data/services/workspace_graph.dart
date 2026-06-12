/// Canonical graph result type for the workspace graph builder.
///
/// This is the single normalized graph object that all downstream consumers
/// (Map, Operate, History, Governance) should consume instead of building
/// their own relationship models independently.
library;

import 'package:flutter/foundation.dart';
import '../models/workspace_graph.dart';

/// The canonical workspace graph result returned by [WorkspaceGraphBuilder].
///
/// Contains all typed nodes ([WorkspaceAsset]) and typed edges
/// ([WorkspaceEdge]) plus a lookup index for O(1) asset access by id.
/// This is the single truth model for all workspace relationships.
@immutable
class WorkspaceGraphResult {
  /// All assets in the workspace, keyed by asset id.
  final Map<String, WorkspaceAsset> assetsById;

  /// All unique edges in the normalized graph.
  final List<WorkspaceEdge> edges;

  /// Assets grouped by kind for quick filtering.
  final Map<AssetKind, List<WorkspaceAsset>> assetsByKind;

  const WorkspaceGraphResult({
    required this.assetsById,
    required this.edges,
    required this.assetsByKind,
  });

  /// An empty graph with no assets or edges.
  const WorkspaceGraphResult.empty()
    : assetsById = const {},
      edges = const [],
      assetsByKind = const {};

  /// Total number of nodes (assets) in the graph.
  int get nodeCount => assetsById.length;

  /// Total number of edges in the graph.
  int get edgeCount => edges.length;

  /// Whether the graph is empty (no nodes).
  bool get isEmpty => assetsById.isEmpty;

  /// Look up an asset by id. Returns null if not found.
  WorkspaceAsset? getAsset(String id) => assetsById[id];

  /// Get all edges originating from [sourceId].
  List<WorkspaceEdge> outgoingEdges(String sourceId) =>
      edges.where((e) => e.sourceId == sourceId).toList();

  /// Get all edges targeting [targetId].
  List<WorkspaceEdge> incomingEdges(String targetId) =>
      edges.where((e) => e.targetId == targetId).toList();

  /// Get all edges of a specific [kind].
  List<WorkspaceEdge> edgesByKind(EdgeKind kind) =>
      edges.where((e) => e.kind == kind).toList();

  /// Get all assets that [sourceId] has outgoing edges to.
  List<WorkspaceAsset> neighbors(String sourceId) {
    final neighborIds = edges
        .where((e) => e.sourceId == sourceId)
        .map((e) => e.targetId);
    return neighborIds
        .map((id) => assetsById[id])
        .where((a) => a != null)
        .cast<WorkspaceAsset>()
        .toList();
  }

  /// Get all assets that reference [targetId] via incoming edges.
  List<WorkspaceAsset> referencingAssets(String targetId) {
    final refIds = edges
        .where((e) => e.targetId == targetId)
        .map((e) => e.sourceId);
    return refIds
        .map((id) => assetsById[id])
        .where((a) => a != null)
        .cast<WorkspaceAsset>()
        .toList();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkspaceGraphResult &&
          runtimeType == other.runtimeType &&
          nodeCount == other.nodeCount &&
          edgeCount == other.edgeCount;

  @override
  int get hashCode => Object.hash(nodeCount, edgeCount);

  @override
  String toString() =>
      'WorkspaceGraphResult(nodes: $nodeCount, edges: $edgeCount)';
}
