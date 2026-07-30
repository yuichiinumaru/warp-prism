/// Graph projection layer for the Map surface.
///
/// Converts normalized [WorkspaceAsset] and [WorkspaceEdge] from the
/// backbone into mode-specific node and edge lists consumable by
/// [PrismGraphCanvas]. The projection is a pure function of the input
/// assets plus a [MapGraphMode] — no hardcoded demo lists, no widget
/// state coupling.
library;

import 'package:warp_prism_observatory/data/models/workspace_graph.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';
import 'map_graph_mode.dart';

/// The result of projecting a workspace graph into a specific mode.
///
/// Contains the nodes and edges that should be rendered, plus counts
/// for deterministic test assertions.
class MapGraphProjection {
  /// Nodes derived from the normalized asset list.
  final List<PrismGraphNode> nodes;

  /// Edges filtered by the active mode's edge-kind rules.
  final List<PrismGraphEdge> edges;

  /// The mode that produced this projection.
  final MapGraphMode mode;

  /// Total number of assets that were eligible (had at least one
  /// qualifying edge in this mode). May be less than [nodes.length]
  /// because isolated nodes are still included.
  final int assetsWithEdges;

  const MapGraphProjection({
    required this.nodes,
    required this.edges,
    required this.mode,
    this.assetsWithEdges = 0,
  });

  /// Convenience: true when the projection has no edges for this mode.
  bool get isEmpty => edges.isEmpty;

  /// Convenience: edge count for quick assertions.
  int get edgeCount => edges.length;

  /// Convenience: node count for quick assertions.
  int get nodeCount => nodes.length;
}

/// Builds a [MapGraphProjection] from the normalized backbone.
///
/// All assets are projected as nodes. Only edges whose [EdgeKind]
/// is in the active mode's allowed set are included. Assets that
/// participate in at least one qualifying edge are counted in
/// [MapGraphProjection.assetsWithEdges].
MapGraphProjection projectGraph({
  required List<WorkspaceAsset> assets,
  required List<WorkspaceEdge> edges,
  required MapGraphMode mode,
}) {
  final allowedKinds = edgeKindsForMode(mode);

  // Filter edges to those matching the mode's rules.
  final filteredEdges = edges
      .where((e) => allowedKinds.contains(e.kind))
      .toList();

  // Collect asset ids that participate in at least one edge.
  final connectedIds = <String>{};
  for (final edge in filteredEdges) {
    connectedIds.add(edge.sourceId);
    connectedIds.add(edge.targetId);
  }

  // Build nodes for ALL assets (isolated nodes are still visible).
  final nodes = assets.map((a) => _assetToNode(a)).toList();

  // Build graph edges from the filtered set.
  final graphEdges = filteredEdges
      .map(
        (e) => PrismGraphEdge(
          sourceId: e.sourceId,
          targetId: e.targetId,
          label: e.kind.name,
          edgeType: e.kind.name,
        ),
      )
      .toList();

  return MapGraphProjection(
    nodes: nodes,
    edges: graphEdges,
    mode: mode,
    assetsWithEdges: connectedIds.length,
  );
}

/// Converts a [WorkspaceAsset] into a [PrismGraphNode] for the canvas.
PrismGraphNode _assetToNode(WorkspaceAsset asset) {
  return PrismGraphNode(
    id: asset.id,
    label: asset.name,
    type: asset.kind.name,
    status: asset.canonicality.name,
    metadata: {
      'path': asset.path,
      'description': asset.description,
      'canonicality': asset.canonicality.name,
    },
  );
}
