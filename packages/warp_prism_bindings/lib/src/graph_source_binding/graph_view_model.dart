import 'dart:ui';
import 'package:meta/meta.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

/// Presentation view model snapshot of a renderable graph.
///
/// Combines projected [PrismGraphNode]s (with binding-owned [Offset] positions)
/// and [PrismGraphEdge]s for direct consumption by [PrismGraphCanvas].
///
/// **Equality Semantics**: This class intentionally relies on default identity
/// (reference) equality rather than value equality, because [PrismGraphNode]
/// contains widget-local mutable interaction state (such as [PrismGraphNode.velocity],
/// [PrismGraphNode.isDragging], [PrismGraphNode.isHovered], [PrismGraphNode.isSelected]).
/// Each projection produced by `GraphSourceBinding.viewModel` is a discrete snapshot instance.
///
/// Lifecycle: EXPERIMENTAL (see `docs/architecture/layer-contracts-v2.md`).
@experimental
class GraphViewModel {
  /// All positioned renderable nodes in the graph.
  final List<PrismGraphNode> nodes;

  /// All renderable directed edges in the graph.
  final List<PrismGraphEdge> edges;

  /// Quick position lookup map keyed by node ID string.
  final Map<String, Offset> positions;

  /// Creates a [GraphViewModel].
  const GraphViewModel({
    required this.nodes,
    required this.edges,
    required this.positions,
  });

  /// Creates an empty [GraphViewModel].
  const GraphViewModel.empty()
    : nodes = const [],
      edges = const [],
      positions = const {};

  /// Total count of renderable nodes.
  int get nodeCount => nodes.length;

  /// Total count of renderable edges.
  int get edgeCount => edges.length;

  /// Whether the graph contains zero nodes.
  bool get isEmpty => nodes.isEmpty;

  /// Looks up a node by its string ID.
  PrismGraphNode? nodeById(String id) {
    for (final node in nodes) {
      if (node.id == id) return node;
    }
    return null;
  }

  /// Looks up an edge by its source and target IDs.
  PrismGraphEdge? edgeBetween(String sourceId, String targetId) {
    for (final edge in edges) {
      if (edge.sourceId == sourceId && edge.targetId == targetId) return edge;
    }
    return null;
  }

  /// Looks up the computed center position for a node.
  Offset? positionOf(String nodeId) => positions[nodeId];

  @override
  String toString() =>
      'GraphViewModel(nodes: ${nodes.length}, edges: ${edges.length})';
}
