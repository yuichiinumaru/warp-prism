import 'dart:async';
import 'package:meta/meta.dart';
import 'package:warp_prism_runtime/warp_prism_runtime.dart';

/// In-memory fake implementation of [GraphSource] for deterministic testing.
///
/// Enables programmatic topological mutations (adding, updating, removing nodes and edges)
/// and reactive broadcast of [GraphUpdate] events.
///
/// Lifecycle: EXPERIMENTAL (see `.project/architecture/layer-contracts.md`).
@experimental
class FakeGraphSource<TNodePayload, TEdgePayload>
    implements GraphSource<TNodePayload, TEdgePayload> {
  final Map<String, GraphNode<TNodePayload>> _nodes = {};
  final Map<String, GraphEdge<TEdgePayload>> _edges = {};
  final StreamController<GraphUpdate<TNodePayload, TEdgePayload>> _controller;
  int _snapshotQueryCount = 0;
  bool _isClosed = false;

  /// Creates a [FakeGraphSource] with optional initial nodes and edges.
  FakeGraphSource({
    Iterable<GraphNode<TNodePayload>>? initialNodes,
    Iterable<GraphEdge<TEdgePayload>>? initialEdges,
    bool sync = true,
  }) : _controller =
           StreamController<GraphUpdate<TNodePayload, TEdgePayload>>.broadcast(
             sync: sync,
           ) {
    if (initialNodes != null) {
      for (final node in initialNodes) {
        _nodes[node.id] = node;
      }
    }
    if (initialEdges != null) {
      for (final edge in initialEdges) {
        _edges[edge.id] = edge;
      }
    }
  }

  @override
  bool get isClosed => _isClosed;

  /// Total number of times [getSnapshot] was invoked.
  int get snapshotQueryCount => _snapshotQueryCount;

  @override
  Future<GraphSnapshot<TNodePayload, TEdgePayload>> getSnapshot() async {
    if (_isClosed) {
      throw StateError('Cannot query snapshot on closed FakeGraphSource');
    }
    _snapshotQueryCount++;
    return GraphSnapshot<TNodePayload, TEdgePayload>(
      nodes: Map.unmodifiable(_nodes),
      edges: Map.unmodifiable(_edges),
      timestamp: DateTime.now(),
    );
  }

  @override
  Stream<GraphUpdate<TNodePayload, TEdgePayload>> watchUpdates() =>
      _controller.stream;

  /// Adds a new node to the graph and broadcasts [NodeAdded].
  void addNode(GraphNode<TNodePayload> node) {
    if (_isClosed) {
      throw StateError('Cannot mutate closed FakeGraphSource');
    }
    _nodes[node.id] = node;
    _controller.add(NodeAdded(node));
  }

  /// Updates an existing node in the graph and broadcasts [NodeUpdated].
  void updateNode(GraphNode<TNodePayload> node) {
    if (_isClosed) {
      throw StateError('Cannot mutate closed FakeGraphSource');
    }
    final previous = _nodes[node.id];
    _nodes[node.id] = node;
    _controller.add(NodeUpdated(node, previousNode: previous));
  }

  /// Removes a node and its incident edges, broadcasting removal events.
  void removeNode(String nodeId) {
    if (_isClosed) {
      throw StateError('Cannot mutate closed FakeGraphSource');
    }
    final removedNode = _nodes.remove(nodeId);

    // Cascade removal of connected edges
    final connectedEdgeIds = _edges.values
        .where((e) => e.fromNodeId == nodeId || e.toNodeId == nodeId)
        .map((e) => e.id)
        .toList();

    for (final edgeId in connectedEdgeIds) {
      removeEdge(edgeId);
    }

    _controller.add(NodeRemoved(nodeId, removedNode: removedNode));
  }

  /// Adds a new directed edge and broadcasts [EdgeAdded].
  void addEdge(GraphEdge<TEdgePayload> edge) {
    if (_isClosed) {
      throw StateError('Cannot mutate closed FakeGraphSource');
    }
    _edges[edge.id] = edge;
    _controller.add(EdgeAdded(edge));
  }

  /// Updates an existing edge and broadcasts [EdgeUpdated].
  void updateEdge(GraphEdge<TEdgePayload> edge) {
    if (_isClosed) {
      throw StateError('Cannot mutate closed FakeGraphSource');
    }
    final previous = _edges[edge.id];
    _edges[edge.id] = edge;
    _controller.add(EdgeUpdated(edge, previousEdge: previous));
  }

  /// Removes an edge and broadcasts [EdgeRemoved].
  void removeEdge(String edgeId) {
    if (_isClosed) {
      throw StateError('Cannot mutate closed FakeGraphSource');
    }
    final removedEdge = _edges.remove(edgeId);
    _controller.add(EdgeRemoved(edgeId, removedEdge: removedEdge));
  }

  /// Replaces the entire graph structure and broadcasts [GraphReset].
  void setGraph({
    Iterable<GraphNode<TNodePayload>>? nodes,
    Iterable<GraphEdge<TEdgePayload>>? edges,
  }) {
    if (_isClosed) {
      throw StateError('Cannot mutate closed FakeGraphSource');
    }
    _nodes.clear();
    _edges.clear();

    if (nodes != null) {
      for (final node in nodes) {
        _nodes[node.id] = node;
      }
    }
    if (edges != null) {
      for (final edge in edges) {
        _edges[edge.id] = edge;
      }
    }

    final snapshot = GraphSnapshot<TNodePayload, TEdgePayload>(
      nodes: Map.unmodifiable(_nodes),
      edges: Map.unmodifiable(_edges),
      timestamp: DateTime.now(),
    );
    _controller.add(GraphReset(snapshot));
  }

  /// Clears all nodes and edges, broadcasting an empty [GraphReset].
  void resetGraph() {
    setGraph(nodes: const [], edges: const []);
  }

  /// Emits an error across the reactive [watchUpdates] stream.
  void emitUpdateError(Object error, [StackTrace? stackTrace]) {
    if (_isClosed) {
      throw StateError('Cannot emit update error on closed FakeGraphSource');
    }
    _controller.addError(error, stackTrace);
  }

  @override
  Future<void> close() async {
    _isClosed = true;
    if (!_controller.isClosed) {
      await _controller.close();
    }
  }
}
