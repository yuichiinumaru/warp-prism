import 'package:meta/meta.dart';
import 'dart:async';
import 'package:warp_prism_runtime/warp_prism_runtime.dart';
import 'rust/api.dart' as frb_api;

/// FRB native-backed implementation of [GraphSource].
/// Lifecycle: EXPERIMENTAL (see `.project/architecture/layer-contracts.md`).
@experimental
class FrbGraphSource implements GraphSource<String, String> {
  final int? maxEvents;
  final StreamController<GraphUpdate<String, String>> _controller;
  StreamSubscription<frb_api.FrbGraphUpdate>? _nativeSubscription;
  GraphSnapshot<String, String>? _cachedSnapshot;
  bool _isClosed = false;

  FrbGraphSource({this.maxEvents})
      : _controller =
            StreamController<GraphUpdate<String, String>>.broadcast();

  void _ensureNativeStream() {
    _nativeSubscription ??=
        frb_api.watchGraphUpdates(maxEvents: maxEvents).listen(
      (nativeUpdate) {
        if (_isClosed) return;
        _cachedSnapshot = null;
        final update = _convertUpdateFromNative(nativeUpdate);
        _controller.add(update);
      },
      onError: (Object error, StackTrace stackTrace) {
        if (!_isClosed) {
          _controller.addError(error, stackTrace);
        }
      },
    );
  }

  @override
  bool get isClosed => _isClosed;

  @override
  Future<GraphSnapshot<String, String>> getSnapshot() async {
    if (_isClosed) {
      throw StateError('Cannot getSnapshot on closed FrbGraphSource');
    }
    if (_cachedSnapshot != null) return _cachedSnapshot!;
    final nativeSnap = await frb_api.getSampleGraphSnapshot();
    _cachedSnapshot = _convertFromNative(nativeSnap);
    return _cachedSnapshot!;
  }

  @override
  Stream<GraphUpdate<String, String>> watchUpdates() {
    if (_isClosed) {
      throw StateError('Cannot watchUpdates on closed FrbGraphSource');
    }
    _ensureNativeStream();
    return _controller.stream;
  }

  /// Adds a node via the Rust native substrate.
  ///
  /// The native substrate broadcasts the update back through [watchUpdates].
  Future<void> addNode(GraphNode<String> node) async {
    if (_isClosed) {
      throw StateError('Cannot addNode on closed FrbGraphSource');
    }
    final nativeNode = frb_api.FrbGraphNode(
      id: node.id,
      kind: node.kind,
      label: node.label,
      status: node.status,
      payload: node.payload,
    );

    final updatedNativeSnap = await frb_api.applyGraphNodeAdd(
      node: nativeNode,
    );
    _cachedSnapshot = _convertFromNative(updatedNativeSnap);
  }

  /// Updates a node via the Rust native substrate.
  ///
  /// The native substrate broadcasts the update back through [watchUpdates].
  Future<void> updateNode(GraphNode<String> node) async {
    if (_isClosed) {
      throw StateError('Cannot updateNode on closed FrbGraphSource');
    }
    final nativeNode = frb_api.FrbGraphNode(
      id: node.id,
      kind: node.kind,
      label: node.label,
      status: node.status,
      payload: node.payload,
    );

    final updatedNativeSnap = await frb_api.applyGraphNodeUpdate(
      node: nativeNode,
    );
    _cachedSnapshot = _convertFromNative(updatedNativeSnap);
  }

  /// Removes a node by ID via the Rust native substrate.
  ///
  /// The native substrate broadcasts the update back through [watchUpdates].
  Future<void> removeNode(String nodeId) async {
    if (_isClosed) {
      throw StateError('Cannot removeNode on closed FrbGraphSource');
    }
    final updatedNativeSnap = await frb_api.applyGraphNodeRemove(
      nodeId: nodeId,
    );
    _cachedSnapshot = _convertFromNative(updatedNativeSnap);
  }

  /// Adds an edge via the Rust native substrate.
  ///
  /// The native substrate broadcasts the update back through [watchUpdates].
  Future<void> addEdge(GraphEdge<String> edge) async {
    if (_isClosed) {
      throw StateError('Cannot addEdge on closed FrbGraphSource');
    }
    final nativeEdge = frb_api.FrbGraphEdge(
      id: edge.id,
      kind: edge.kind,
      fromNodeId: edge.fromNodeId,
      toNodeId: edge.toNodeId,
      payload: edge.payload,
    );

    final updatedNativeSnap = await frb_api.applyGraphEdgeAdd(
      edge: nativeEdge,
    );
    _cachedSnapshot = _convertFromNative(updatedNativeSnap);
  }

  /// Updates an edge via the Rust native substrate.
  ///
  /// The native substrate broadcasts the update back through [watchUpdates].
  Future<void> updateEdge(GraphEdge<String> edge) async {
    if (_isClosed) {
      throw StateError('Cannot updateEdge on closed FrbGraphSource');
    }
    final nativeEdge = frb_api.FrbGraphEdge(
      id: edge.id,
      kind: edge.kind,
      fromNodeId: edge.fromNodeId,
      toNodeId: edge.toNodeId,
      payload: edge.payload,
    );

    final updatedNativeSnap = await frb_api.applyGraphEdgeUpdate(
      edge: nativeEdge,
    );
    _cachedSnapshot = _convertFromNative(updatedNativeSnap);
  }

  /// Removes an edge by ID via the Rust native substrate.
  ///
  /// The native substrate broadcasts the update back through [watchUpdates].
  Future<void> removeEdge(String edgeId) async {
    if (_isClosed) {
      throw StateError('Cannot removeEdge on closed FrbGraphSource');
    }
    final updatedNativeSnap = await frb_api.applyGraphEdgeRemove(
      edgeId: edgeId,
    );
    _cachedSnapshot = _convertFromNative(updatedNativeSnap);
  }

  /// Resets the whole graph with new nodes and edges via the Rust native substrate.
  ///
  /// The native substrate broadcasts [GraphReset] back through [watchUpdates].
  Future<void> setGraph({
    Iterable<GraphNode<String>>? nodes,
    Iterable<GraphEdge<String>>? edges,
  }) async {
    if (_isClosed) {
      throw StateError('Cannot setGraph on closed FrbGraphSource');
    }
    final nativeNodes = (nodes ?? const []).map(
      (n) => frb_api.FrbGraphNode(
        id: n.id,
        kind: n.kind,
        label: n.label,
        status: n.status,
        payload: n.payload,
      ),
    ).toList(growable: false);

    final nativeEdges = (edges ?? const []).map(
      (e) => frb_api.FrbGraphEdge(
        id: e.id,
        kind: e.kind,
        fromNodeId: e.fromNodeId,
        toNodeId: e.toNodeId,
        payload: e.payload,
      ),
    ).toList(growable: false);

    final nativeSnap = frb_api.FrbGraphSnapshot(
      timestampMillis: DateTime.now().millisecondsSinceEpoch,
      nodes: nativeNodes,
      edges: nativeEdges,
    );

    final updatedNativeSnap = await frb_api.applyGraphReset(
      snapshot: nativeSnap,
    );
    _cachedSnapshot = _convertFromNative(updatedNativeSnap);
  }

  @override
  Future<void> close() async {
    if (_isClosed) return;
    _isClosed = true;
    final sub = _nativeSubscription;
    _nativeSubscription = null;
    unawaited(sub?.cancel());
    if (!_controller.isClosed) {
      await _controller.close();
    }
  }

  static GraphUpdate<String, String> _convertUpdateFromNative(
    frb_api.FrbGraphUpdate u,
  ) {
    return switch (u.kind) {
      frb_api.FrbGraphUpdateKind.nodeAdded => NodeAdded(
          _convertNodeFromNative(u.node!),
        ),
      frb_api.FrbGraphUpdateKind.nodeUpdated => NodeUpdated(
          _convertNodeFromNative(u.node!),
          previousNode: u.previousNode != null
              ? _convertNodeFromNative(u.previousNode!)
              : null,
        ),
      frb_api.FrbGraphUpdateKind.nodeRemoved => NodeRemoved(
          u.removedId ?? u.node?.id ?? '',
          removedNode: u.previousNode != null
              ? _convertNodeFromNative(u.previousNode!)
              : null,
        ),
      frb_api.FrbGraphUpdateKind.edgeAdded => EdgeAdded(
          _convertEdgeFromNative(u.edge!),
        ),
      frb_api.FrbGraphUpdateKind.edgeUpdated => EdgeUpdated(
          _convertEdgeFromNative(u.edge!),
          previousEdge: u.previousEdge != null
              ? _convertEdgeFromNative(u.previousEdge!)
              : null,
        ),
      frb_api.FrbGraphUpdateKind.edgeRemoved => EdgeRemoved(
          u.removedId ?? u.edge?.id ?? '',
          removedEdge: u.previousEdge != null
              ? _convertEdgeFromNative(u.previousEdge!)
              : null,
        ),
      frb_api.FrbGraphUpdateKind.graphReset => GraphReset(
          _convertFromNative(u.snapshot!),
        ),
    };
  }

  static GraphNode<String> _convertNodeFromNative(frb_api.FrbGraphNode n) {
    return GraphNode<String>(
      id: n.id,
      kind: n.kind,
      label: n.label,
      status: n.status,
      payload: n.payload,
    );
  }

  static GraphEdge<String> _convertEdgeFromNative(frb_api.FrbGraphEdge e) {
    return GraphEdge<String>(
      id: e.id,
      kind: e.kind,
      fromNodeId: e.fromNodeId,
      toNodeId: e.toNodeId,
      payload: e.payload,
    );
  }

  static GraphSnapshot<String, String> _convertFromNative(
    frb_api.FrbGraphSnapshot s,
  ) {
    final millis = s.timestampMillis.toInt();

    final nodeMap = <String, GraphNode<String>>{};
    for (final n in s.nodes) {
      nodeMap[n.id] = _convertNodeFromNative(n);
    }

    final edgeMap = <String, GraphEdge<String>>{};
    for (final e in s.edges) {
      edgeMap[e.id] = _convertEdgeFromNative(e);
    }

    return GraphSnapshot<String, String>(
      nodes: nodeMap,
      edges: edgeMap,
      timestamp: DateTime.fromMillisecondsSinceEpoch(millis),
    );
  }
}
