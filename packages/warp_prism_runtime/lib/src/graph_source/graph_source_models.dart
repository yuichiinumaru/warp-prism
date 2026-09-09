import 'package:meta/meta.dart';

/// Semantic node kind identifier.
///
/// An open string vocabulary representing the semantic role or category of a graph node.
/// Applications and adapters may define custom namespaced constants
/// (e.g. `service.daemon`, `pipeline.step`, `workspace.asset`, `data.table`).
///
/// Lifecycle: EXPERIMENTAL (see `docs/architecture/layer-contracts-v2.md`).
@experimental
typedef GraphNodeKind = String;

/// Semantic edge kind identifier.
///
/// An open string vocabulary representing the relationship type between two graph nodes.
/// Applications and adapters may define custom namespaced constants
/// (e.g. `depends_on`, `data_flow`, `parent_child`, `communicates_with`).
///
/// Lifecycle: EXPERIMENTAL (see `docs/architecture/layer-contracts-v2.md`).
@experimental
typedef GraphEdgeKind = String;

/// A discrete, pure semantic graph node.
///
/// **PURGE LAW**: This model contains strictly zero spatial coordinates
/// (`position: Offset`), layout bounds, rendering styles, or selection flags.
///
/// Lifecycle: EXPERIMENTAL (see `docs/architecture/layer-contracts-v2.md`).
@experimental
@immutable
class GraphNode<T> {
  /// Unique identifier for this graph node.
  final String id;

  /// Semantic kind or role category of this node.
  final GraphNodeKind kind;

  /// Human-readable display label.
  final String label;

  /// Optional operational or lifecycle status label.
  final String? status;

  /// Typed semantic domain payload.
  final T payload;

  /// Semantic metadata attributes.
  final Map<String, Object?> metadata;

  /// Creates an immutable [GraphNode].
  const GraphNode({
    required this.id,
    required this.kind,
    required this.label,
    required this.payload,
    this.status,
    this.metadata = const {},
  });

  /// Derives an updated copy with substituted fields.
  GraphNode<T> copyWith({
    String? id,
    GraphNodeKind? kind,
    String? label,
    String? status,
    T? payload,
    Map<String, Object?>? metadata,
  }) {
    return GraphNode<T>(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      label: label ?? this.label,
      status: status ?? this.status,
      payload: payload ?? this.payload,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GraphNode<T> &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          kind == other.kind &&
          label == other.label &&
          status == other.status &&
          payload == other.payload;

  @override
  int get hashCode => Object.hash(id, kind, label, status, payload);

  @override
  String toString() =>
      'GraphNode(id: $id, kind: $kind, label: $label, status: $status, payload: $payload)';
}

/// A discrete, pure semantic directed edge connecting two graph nodes.
///
/// **PURGE LAW**: This model contains strictly zero routing points,
/// spline controls, canvas coordinates, or visual styling attributes.
///
/// Lifecycle: EXPERIMENTAL (see `docs/architecture/layer-contracts-v2.md`).
@experimental
@immutable
class GraphEdge<T> {
  /// Unique identifier for this graph edge.
  final String id;

  /// Semantic relationship kind of this edge.
  final GraphEdgeKind kind;

  /// Node ID from which this directed edge originates.
  final String fromNodeId;

  /// Node ID at which this directed edge terminates.
  final String toNodeId;

  /// Typed semantic domain payload.
  final T payload;

  /// Semantic metadata attributes.
  final Map<String, Object?> metadata;

  /// Creates an immutable [GraphEdge].
  const GraphEdge({
    required this.id,
    required this.kind,
    required this.fromNodeId,
    required this.toNodeId,
    required this.payload,
    this.metadata = const {},
  });

  /// Derives an updated copy with substituted fields.
  GraphEdge<T> copyWith({
    String? id,
    GraphEdgeKind? kind,
    String? fromNodeId,
    String? toNodeId,
    T? payload,
    Map<String, Object?>? metadata,
  }) {
    return GraphEdge<T>(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      fromNodeId: fromNodeId ?? this.fromNodeId,
      toNodeId: toNodeId ?? this.toNodeId,
      payload: payload ?? this.payload,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GraphEdge<T> &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          kind == other.kind &&
          fromNodeId == other.fromNodeId &&
          toNodeId == other.toNodeId &&
          payload == other.payload;

  @override
  int get hashCode => Object.hash(id, kind, fromNodeId, toNodeId, payload);

  @override
  String toString() =>
      'GraphEdge(id: $id, kind: $kind, from: $fromNodeId -> to: $toNodeId, payload: $payload)';
}

/// Point-in-time immutable snapshot of a complete semantic graph.
///
/// Houses indexed nodes, edges, and provides fast adjacency lookup helpers.
///
/// Lifecycle: EXPERIMENTAL (see `docs/architecture/layer-contracts-v2.md`).
@experimental
@immutable
class GraphSnapshot<TNodePayload, TEdgePayload> {
  /// Map of all nodes in this graph keyed by unique [GraphNode.id].
  final Map<String, GraphNode<TNodePayload>> nodes;

  /// Map of all directed edges in this graph keyed by unique [GraphEdge.id].
  final Map<String, GraphEdge<TEdgePayload>> edges;

  /// Timestamp when this snapshot was captured.
  final DateTime timestamp;

  /// Semantic metadata attributes.
  final Map<String, Object?> metadata;

  /// Creates an immutable [GraphSnapshot].
  const GraphSnapshot({
    required this.nodes,
    required this.edges,
    required this.timestamp,
    this.metadata = const {},
  });

  /// Creates an empty graph snapshot.
  factory GraphSnapshot.empty({DateTime? timestamp}) => GraphSnapshot(
    nodes: const {},
    edges: const {},
    timestamp: timestamp ?? DateTime.now(),
  );

  /// Looks up a node by [nodeId].
  GraphNode<TNodePayload>? getNode(String nodeId) => nodes[nodeId];

  /// Looks up an edge by [edgeId].
  GraphEdge<TEdgePayload>? getEdge(String edgeId) => edges[edgeId];

  /// Whether this graph contains a node with [nodeId].
  bool containsNode(String nodeId) => nodes.containsKey(nodeId);

  /// Whether this graph contains an edge with [edgeId].
  bool containsEdge(String edgeId) => edges.containsKey(edgeId);

  /// Returns all outgoing edges originating from [nodeId].
  List<GraphEdge<TEdgePayload>> outgoingEdges(String nodeId) =>
      edges.values.where((e) => e.fromNodeId == nodeId).toList(growable: false);

  /// Returns all incoming edges terminating at [nodeId].
  List<GraphEdge<TEdgePayload>> incomingEdges(String nodeId) =>
      edges.values.where((e) => e.toNodeId == nodeId).toList(growable: false);

  /// Returns all adjacent neighbor nodes directly reachable from [nodeId] via outgoing edges.
  List<GraphNode<TNodePayload>> adjacentNodes(String nodeId) {
    final neighborIds = outgoingEdges(nodeId).map((e) => e.toNodeId).toSet();
    final result = <GraphNode<TNodePayload>>[];
    for (final id in neighborIds) {
      final node = nodes[id];
      if (node != null) result.add(node);
    }
    return result;
  }

  /// Returns all edges directly connecting [fromNodeId] to [toNodeId].
  List<GraphEdge<TEdgePayload>> edgesBetween(
    String fromNodeId,
    String toNodeId,
  ) => edges.values
      .where((e) => e.fromNodeId == fromNodeId && e.toNodeId == toNodeId)
      .toList(growable: false);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GraphSnapshot<TNodePayload, TEdgePayload> &&
          runtimeType == other.runtimeType &&
          timestamp == other.timestamp &&
          nodes.length == other.nodes.length &&
          edges.length == other.edges.length;

  @override
  int get hashCode => Object.hash(timestamp, nodes.length, edges.length);

  @override
  String toString() =>
      'GraphSnapshot(timestamp: $timestamp, nodesCount: ${nodes.length}, edgesCount: ${edges.length})';
}

/// Base sealed class representing an incremental or whole-graph update event.
///
/// Lifecycle: EXPERIMENTAL (see `docs/architecture/layer-contracts-v2.md`).
@experimental
sealed class GraphUpdate<TNodePayload, TEdgePayload> {
  const GraphUpdate();
}

/// Update event signaling a new node was added to the graph.
///
/// Lifecycle: EXPERIMENTAL (see `docs/architecture/layer-contracts-v2.md`).
@experimental
@immutable
class NodeAdded<TNodePayload, TEdgePayload>
    extends GraphUpdate<TNodePayload, TEdgePayload> {
  /// The newly added node.
  final GraphNode<TNodePayload> node;

  /// Creates a [NodeAdded] event.
  const NodeAdded(this.node);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NodeAdded<TNodePayload, TEdgePayload> &&
          runtimeType == other.runtimeType &&
          node == other.node;

  @override
  int get hashCode => node.hashCode;

  @override
  String toString() => 'NodeAdded(node: $node)';
}

/// Update event signaling an existing node was modified.
///
/// Lifecycle: EXPERIMENTAL (see `docs/architecture/layer-contracts-v2.md`).
@experimental
@immutable
class NodeUpdated<TNodePayload, TEdgePayload>
    extends GraphUpdate<TNodePayload, TEdgePayload> {
  /// The updated node state.
  final GraphNode<TNodePayload> node;

  /// The previous node state prior to the update, if known.
  final GraphNode<TNodePayload>? previousNode;

  /// Creates a [NodeUpdated] event.
  const NodeUpdated(this.node, {this.previousNode});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NodeUpdated<TNodePayload, TEdgePayload> &&
          runtimeType == other.runtimeType &&
          node == other.node &&
          previousNode == other.previousNode;

  @override
  int get hashCode => Object.hash(node, previousNode);

  @override
  String toString() => 'NodeUpdated(node: $node, previous: $previousNode)';
}

/// Update event signaling a node was removed from the graph.
///
/// Lifecycle: EXPERIMENTAL (see `docs/architecture/layer-contracts-v2.md`).
@experimental
@immutable
class NodeRemoved<TNodePayload, TEdgePayload>
    extends GraphUpdate<TNodePayload, TEdgePayload> {
  /// The identifier of the removed node.
  final String nodeId;

  /// The node state before removal, if known.
  final GraphNode<TNodePayload>? removedNode;

  /// Creates a [NodeRemoved] event.
  const NodeRemoved(this.nodeId, {this.removedNode});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NodeRemoved<TNodePayload, TEdgePayload> &&
          runtimeType == other.runtimeType &&
          nodeId == other.nodeId &&
          removedNode == other.removedNode;

  @override
  int get hashCode => Object.hash(nodeId, removedNode);

  @override
  String toString() => 'NodeRemoved(id: $nodeId, removed: $removedNode)';
}

/// Update event signaling a new edge was added to the graph.
///
/// Lifecycle: EXPERIMENTAL (see `docs/architecture/layer-contracts-v2.md`).
@experimental
@immutable
class EdgeAdded<TNodePayload, TEdgePayload>
    extends GraphUpdate<TNodePayload, TEdgePayload> {
  /// The newly added edge.
  final GraphEdge<TEdgePayload> edge;

  /// Creates an [EdgeAdded] event.
  const EdgeAdded(this.edge);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EdgeAdded<TNodePayload, TEdgePayload> &&
          runtimeType == other.runtimeType &&
          edge == other.edge;

  @override
  int get hashCode => edge.hashCode;

  @override
  String toString() => 'EdgeAdded(edge: $edge)';
}

/// Update event signaling an existing edge was modified.
///
/// Lifecycle: EXPERIMENTAL (see `docs/architecture/layer-contracts-v2.md`).
@experimental
@immutable
class EdgeUpdated<TNodePayload, TEdgePayload>
    extends GraphUpdate<TNodePayload, TEdgePayload> {
  /// The updated edge state.
  final GraphEdge<TEdgePayload> edge;

  /// The previous edge state prior to the update, if known.
  final GraphEdge<TEdgePayload>? previousEdge;

  /// Creates an [EdgeUpdated] event.
  const EdgeUpdated(this.edge, {this.previousEdge});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EdgeUpdated<TNodePayload, TEdgePayload> &&
          runtimeType == other.runtimeType &&
          edge == other.edge &&
          previousEdge == other.previousEdge;

  @override
  int get hashCode => Object.hash(edge, previousEdge);

  @override
  String toString() => 'EdgeUpdated(edge: $edge, previous: $previousEdge)';
}

/// Update event signaling an edge was removed from the graph.
///
/// Lifecycle: EXPERIMENTAL (see `docs/architecture/layer-contracts-v2.md`).
@experimental
@immutable
class EdgeRemoved<TNodePayload, TEdgePayload>
    extends GraphUpdate<TNodePayload, TEdgePayload> {
  /// The identifier of the removed edge.
  final String edgeId;

  /// The edge state before removal, if known.
  final GraphEdge<TEdgePayload>? removedEdge;

  /// Creates an [EdgeRemoved] event.
  const EdgeRemoved(this.edgeId, {this.removedEdge});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EdgeRemoved<TNodePayload, TEdgePayload> &&
          runtimeType == other.runtimeType &&
          edgeId == other.edgeId &&
          removedEdge == other.removedEdge;

  @override
  int get hashCode => Object.hash(edgeId, removedEdge);

  @override
  String toString() => 'EdgeRemoved(id: $edgeId, removed: $removedEdge)';
}

/// Update event signaling the entire graph was reset or replaced with a new snapshot.
///
/// Lifecycle: EXPERIMENTAL (see `docs/architecture/layer-contracts-v2.md`).
@experimental
@immutable
class GraphReset<TNodePayload, TEdgePayload>
    extends GraphUpdate<TNodePayload, TEdgePayload> {
  /// The new complete graph snapshot replacing the previous graph state.
  final GraphSnapshot<TNodePayload, TEdgePayload> snapshot;

  /// Creates a [GraphReset] event.
  const GraphReset(this.snapshot);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GraphReset<TNodePayload, TEdgePayload> &&
          runtimeType == other.runtimeType &&
          snapshot == other.snapshot;

  @override
  int get hashCode => snapshot.hashCode;

  @override
  String toString() => 'GraphReset(snapshot: $snapshot)';
}
