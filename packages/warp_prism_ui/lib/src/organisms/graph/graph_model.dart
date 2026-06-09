/// Graph data model — pure data classes for nodes, edges, and graph container.
///
/// This file has no Flutter widget dependency (only dart:ui for Offset).
/// It is testable without a widget tree.
library;

import 'dart:ui';

/// Typed wrapper around a node identifier string.
///
/// Use this instead of raw `String` for node lookups to prevent
/// source/target confusion at compile time.
class GraphNodeId {
  final String value;

  const GraphNodeId(this.value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GraphNodeId && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'GraphNodeId($value)';
}

/// Typed wrapper around an edge identifier string.
///
/// Encodes source→target as `"sourceId->targetId"` for uniqueness.
class GraphEdgeId {
  final String value;

  const GraphEdgeId(this.value);

  /// Creates an edge ID from source and target node IDs.
  factory GraphEdgeId.fromNodes(GraphNodeId source, GraphNodeId target) {
    return GraphEdgeId('${source.value}->${target.value}');
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GraphEdgeId && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'GraphEdgeId($value)';
}

/// Represents a node in the graph — pure data, immutable.
///
/// Position is part of the data model (initial layout hint). The layout
/// engine and interaction layer overlay mutable position/selection state
/// in the orchestrator widget.
class GraphNode {
  final GraphNodeId id;
  final String label;
  final String type; // agent, skill, workflow, task, doc
  final String? status;
  final Map<String, dynamic> metadata;
  final Offset position;

  const GraphNode({
    required this.id,
    required this.label,
    required this.type,
    this.status,
    this.metadata = const {},
    this.position = Offset.zero,
  });

  /// Convenience constructor accepting raw string ID.
  factory GraphNode.create({
    required String id,
    required String label,
    required String type,
    String? status,
    Map<String, dynamic> metadata = const {},
    Offset position = Offset.zero,
  }) {
    return GraphNode(
      id: GraphNodeId(id),
      label: label,
      type: type,
      status: status,
      metadata: metadata,
      position: position,
    );
  }

  GraphNode copyWith({
    GraphNodeId? id,
    String? label,
    String? type,
    String? status,
    Map<String, dynamic>? metadata,
    Offset? position,
  }) {
    return GraphNode(
      id: id ?? this.id,
      label: label ?? this.label,
      type: type ?? this.type,
      status: status ?? this.status,
      metadata: metadata ?? this.metadata,
      position: position ?? this.position,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GraphNode &&
          id == other.id &&
          label == other.label &&
          type == other.type &&
          status == other.status &&
          position == other.position;

  @override
  int get hashCode => Object.hash(id, label, type, status, position);

  @override
  String toString() => 'GraphNode(${id.value}, "$label", $type)';
}

/// Represents a directed edge connecting two nodes — pure data, immutable.
class GraphEdge {
  final GraphEdgeId id;
  final GraphNodeId sourceId;
  final GraphNodeId targetId;
  final String? label;
  final String edgeType; // uses, triggers, references

  const GraphEdge({
    required this.id,
    required this.sourceId,
    required this.targetId,
    this.label,
    this.edgeType = 'references',
  });

  /// Convenience constructor that auto-generates an edge ID.
  factory GraphEdge.create({
    required String sourceId,
    required String targetId,
    String? label,
    String edgeType = 'references',
  }) {
    final src = GraphNodeId(sourceId);
    final tgt = GraphNodeId(targetId);
    return GraphEdge(
      id: GraphEdgeId.fromNodes(src, tgt),
      sourceId: src,
      targetId: tgt,
      label: label,
      edgeType: edgeType,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GraphEdge && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'GraphEdge(${sourceId.value} -> ${targetId.value}, $edgeType)';
}

/// Container for a graph — holds nodes and edges with query methods.
///
/// Pure data. No mutation. Use `copyWith` to produce new instances.
class GraphModel {
  final List<GraphNode> nodes;
  final List<GraphEdge> edges;

  const GraphModel({
    required this.nodes,
    required this.edges,
  });

  /// Look up a node by its typed ID. Returns `null` if not found.
  GraphNode? nodeById(GraphNodeId id) {
    for (final node in nodes) {
      if (node.id == id) return node;
    }
    return null;
  }

  /// All edges where [nodeId] is either source or target.
  List<GraphEdge> edgesForNode(GraphNodeId nodeId) {
    return edges
        .where((e) => e.sourceId == nodeId || e.targetId == nodeId)
        .toList();
  }

  /// IDs of all nodes directly connected to [nodeId] via any edge.
  List<GraphNodeId> adjacentNodes(GraphNodeId nodeId) {
    final result = <GraphNodeId>{};
    for (final edge in edges) {
      if (edge.sourceId == nodeId) {
        result.add(edge.targetId);
      } else if (edge.targetId == nodeId) {
        result.add(edge.sourceId);
      }
    }
    return result.toList();
  }

  /// Build a model from raw string-based node/edge data.
  ///
  /// Convenience factory for backward compatibility with call sites that
  /// use string IDs (like the original `DSGraphCanvas` API).
  factory GraphModel.fromRaw({
    required List<GraphNode> nodes,
    required List<GraphEdge> edges,
  }) {
    return GraphModel(nodes: nodes, edges: edges);
  }

  GraphModel copyWith({
    List<GraphNode>? nodes,
    List<GraphEdge>? edges,
  }) {
    return GraphModel(
      nodes: nodes ?? this.nodes,
      edges: edges ?? this.edges,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GraphModel &&
          _listEquals(nodes, other.nodes) &&
          _listEquals(edges, other.edges);

  @override
  int get hashCode => Object.hash(
        Object.hashAll(nodes),
        Object.hashAll(edges),
      );

  static bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
