/// Graph canvas organism for the Map workspace.
///
/// Backward-compatible wrapper around the composable graph layers.
/// Delegates to [GraphCanvas] (model + layout + painter + interaction).
///
/// Original API surface preserved:
/// - `GraphNode` (string ID, mutable position for widget-local physics)
/// - `GraphEdge` (string source/target IDs)
/// - `DSGraphCanvas(nodes, edges, onNodeTap, ...)` — all parameters unchanged
///
/// New composable API available via `graph/` sub-barrel:
/// - `GraphModel`, `GraphNode` (typed ID), `GraphEdge` (typed ID)
/// - `GraphLayoutEngine`, `ForceDirectedLayout`
/// - `GraphPainter` (public, testable)
/// - `GraphCanvas` (orchestrator)
library;

import 'package:flutter/material.dart';
import 'graph/graph.dart' as graph;

// =============================================================================
// Backward-compatible data classes (string IDs, mutable interaction state)
// =============================================================================

/// Represents a node in the graph — backward-compatible data class.
///
/// Uses string IDs and mutable position/interaction state for widget-local
/// physics. For the immutable, typed-ID model, see `graph.GraphNode`.
class GraphNode {
  final String id;
  final String label;
  final String type; // agent, skill, workflow, task, doc
  final String? status;
  final Map<String, dynamic> metadata;
  Offset position;
  Offset velocity;
  bool isDragging;
  bool isHovered;
  bool isSelected;

  GraphNode({
    required this.id,
    required this.label,
    required this.type,
    this.status,
    this.metadata = const {},
    Offset? position,
  }) : position = position ?? Offset.zero,
       velocity = Offset.zero,
       isDragging = false,
       isHovered = false,
       isSelected = false;

  GraphNode copyWith({
    String? id,
    String? label,
    String? type,
    String? status,
    Map<String, dynamic>? metadata,
    Offset? position,
    Offset? velocity,
    bool? isDragging,
    bool? isHovered,
    bool? isSelected,
  }) {
    return GraphNode(
        id: id ?? this.id,
        label: label ?? this.label,
        type: type ?? this.type,
        status: status ?? this.status,
        metadata: metadata ?? this.metadata,
        position: position ?? this.position,
      )
      ..velocity = velocity ?? this.velocity
      ..isDragging = isDragging ?? this.isDragging
      ..isHovered = isHovered ?? this.isHovered
      ..isSelected = isSelected ?? this.isSelected;
  }
}

/// Represents an edge connecting two nodes — backward-compatible data class.
class GraphEdge {
  final String sourceId;
  final String targetId;
  final String? label;
  final String edgeType; // uses, triggers, references

  const GraphEdge({
    required this.sourceId,
    required this.targetId,
    this.label,
    this.edgeType = 'references',
  });
}

// =============================================================================
// Backward-compatible widget (delegates to composable graph layers)
// =============================================================================

/// Interactive graph canvas with force-directed layout.
///
/// This is the backward-compatible public API. Internally it delegates to
/// [graph.GraphCanvas] which composes model, layout engine, painter, and
/// interaction handlers.
///
/// All original parameters are preserved. New features are available via
/// the `graph/` sub-barrel.
///
/// Caller-supplied kinds (Task 1884, HOLD branch): node [type] and edge
/// [edgeType] are open caller vocabularies — Prism core defines no fixed
/// verb set (boundary B14). Hosts project their domain kinds through
/// [nodeColorResolver]/[nodeIconResolver]; the defaults preserve the legacy
/// design-system mapping. Real-DAG host proof is deferred (no observed
/// consumer DAG surface); see Task 1884 HOLD record.
class DSGraphCanvas extends StatefulWidget {
  final List<GraphNode> nodes;
  final List<GraphEdge> edges;
  final void Function(GraphNode)? onNodeTap;
  final void Function(GraphNode)? onNodeDoubleTap;
  final void Function(GraphNode, Offset)? onNodeDragEnd;
  final bool enablePhysics;
  final double nodeSpacing;

  /// Caller-supplied color projection for node [type] values.
  /// Defaults to the design-system mapping ([graph.defaultNodeColor]).
  final Color Function(String type)? nodeColorResolver;

  /// Caller-supplied icon projection for node [type] values.
  /// Defaults to the design-system mapping ([graph.defaultNodeIcon]).
  final IconData Function(String type)? nodeIconResolver;

  const DSGraphCanvas({
    super.key,
    required this.nodes,
    required this.edges,
    this.onNodeTap,
    this.onNodeDoubleTap,
    this.onNodeDragEnd,
    this.enablePhysics = true,
    this.nodeSpacing = 150.0,
    this.nodeColorResolver,
    this.nodeIconResolver,
  });

  @override
  State<DSGraphCanvas> createState() => _DSGraphCanvasState();
}

class _DSGraphCanvasState extends State<DSGraphCanvas> {
  /// Convert legacy string-ID nodes to typed model nodes.
  List<graph.GraphNode> _toModelNodes() {
    return widget.nodes.map((n) {
      return graph.GraphNode(
        id: graph.GraphNodeId(n.id),
        label: n.label,
        type: n.type,
        status: n.status,
        metadata: n.metadata,
        position: n.position,
      );
    }).toList();
  }

  /// Convert legacy string-ID edges to typed model edges.
  List<graph.GraphEdge> _toModelEdges() {
    return widget.edges.map((e) {
      final src = graph.GraphNodeId(e.sourceId);
      final tgt = graph.GraphNodeId(e.targetId);
      return graph.GraphEdge(
        id: graph.GraphEdgeId.fromNodes(src, tgt),
        sourceId: src,
        targetId: tgt,
        label: e.label,
        edgeType: e.edgeType,
      );
    }).toList();
  }

  /// Find the original legacy GraphNode by string ID.
  GraphNode? _findLegacyNode(String id) {
    for (final n in widget.nodes) {
      if (n.id == id) return n;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final model = graph.GraphModel(
      nodes: _toModelNodes(),
      edges: _toModelEdges(),
    );

    return graph.GraphCanvas(
      model: model,
      enablePhysics: widget.enablePhysics,
      // Forward nodeSpacing into the force-directed layout config so the
      // public DSGraphCanvas API actually affects spacing (was dead wiring).
      layoutEngine: graph.ForceDirectedLayout(
        config: graph.ForceDirectedConfig(nodeSpacing: widget.nodeSpacing),
      ),
      // Caller-supplied kind projection (Task 1884): null preserves the
      // design-system defaults inside GraphCanvas.
      nodeColorResolver: widget.nodeColorResolver,
      nodeIconResolver: widget.nodeIconResolver,
      onNodeTap: widget.onNodeTap != null
          ? (modelNode) {
              final legacy = _findLegacyNode(modelNode.id.value);
              if (legacy != null) widget.onNodeTap!(legacy);
            }
          : null,
      onNodeDoubleTap: widget.onNodeDoubleTap != null
          ? (modelNode) {
              final legacy = _findLegacyNode(modelNode.id.value);
              if (legacy != null) widget.onNodeDoubleTap!(legacy);
            }
          : null,
      onNodeDragEnd: widget.onNodeDragEnd != null
          ? (modelNode, position) {
              final legacy = _findLegacyNode(modelNode.id.value);
              if (legacy != null) widget.onNodeDragEnd!(legacy, position);
            }
          : null,
    );
  }
}
