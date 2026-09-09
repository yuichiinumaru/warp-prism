import 'dart:async';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';
import 'package:warp_prism_runtime/warp_prism_runtime.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

import 'graph_layout_strategy.dart';
import 'graph_view_model.dart';

/// Projection binding connecting a semantic runtime [GraphSource] to reactive UI graph models.
///
/// **Separation of Concerns**:
/// - Semantic runtime contracts (`GraphSource`, `GraphNode`, `GraphEdge`) hold
///   zero spatial coordinates (`Offset`), layout physics, or rendering styles.
/// - This binding layer owns and manages [Offset] positions via deterministic
///   layout strategies (e.g. [CircleGraphLayoutStrategy], [GridGraphLayoutStrategy])
///   and supports user interactive repositioning ([updateNodePosition]).
///
/// Lifecycle: EXPERIMENTAL (see `docs/architecture/layer-contracts-v2.md`).
@experimental
class GraphSourceBinding<TNodePayload, TEdgePayload> extends ChangeNotifier {
  /// The underlying runtime semantic graph source.
  final GraphSource<TNodePayload, TEdgePayload> source;

  /// Layout strategy used to compute initial/incremental node positions.
  final GraphLayoutStrategy layoutStrategy;

  StreamSubscription<GraphUpdate<TNodePayload, TEdgePayload>>? _subscription;
  final Map<String, GraphNode<TNodePayload>> _runtimeNodes = {};
  final Map<String, GraphEdge<TEdgePayload>> _runtimeEdges = {};
  final Map<String, Offset> _positions = {};

  bool _isDisposed = false;
  bool _isInitialized = false;

  final StreamController<GraphViewModel> _modelStreamController =
      StreamController<GraphViewModel>.broadcast();

  /// Creates a [GraphSourceBinding] for the given [source].
  GraphSourceBinding({
    required this.source,
    this.layoutStrategy = const CircleGraphLayoutStrategy(),
    bool autoInitialize = true,
  }) {
    if (autoInitialize) {
      initialize();
    }
  }

  /// Initializes the binding by fetching current snapshot and subscribing to updates.
  Future<void> initialize() async {
    if (_isDisposed || _isInitialized) return;
    _isInitialized = true;

    try {
      final snapshot = await source.getSnapshot();
      if (!_isDisposed) {
        _applySnapshot(snapshot);
      }
    } catch (e, st) {
      if (!_isDisposed) {
        _modelStreamController.addError(e, st);
      }
    }

    if (!_isDisposed && !source.isClosed) {
      _subscription = source.watchUpdates().listen(
        _handleUpdate,
        onError: (Object error, StackTrace stackTrace) {
          if (!_isDisposed) {
            _modelStreamController.addError(error, stackTrace);
          }
        },
      );
    }
  }

  void _handleUpdate(GraphUpdate<TNodePayload, TEdgePayload> update) {
    if (_isDisposed) return;

    switch (update) {
      case NodeAdded<TNodePayload, TEdgePayload>(node: final node):
        _runtimeNodes[node.id] = node;
        if (!_positions.containsKey(node.id)) {
          _positions[node.id] = layoutStrategy.computeNodePosition(
            nodeId: node.id,
            index: _runtimeNodes.length - 1,
            totalNodes: _runtimeNodes.length,
            existingPositions: _positions,
          );
        }
      case NodeUpdated<TNodePayload, TEdgePayload>(node: final node):
        _runtimeNodes[node.id] = node;
      // Existing position is intentionally preserved across payload/label updates.
      case NodeRemoved<TNodePayload, TEdgePayload>(nodeId: final nodeId):
        _runtimeNodes.remove(nodeId);
        _positions.remove(nodeId);
        _runtimeEdges.removeWhere(
          (_, edge) => edge.fromNodeId == nodeId || edge.toNodeId == nodeId,
        );
      case EdgeAdded<TNodePayload, TEdgePayload>(edge: final edge):
        _runtimeEdges[edge.id] = edge;
      case EdgeUpdated<TNodePayload, TEdgePayload>(edge: final edge):
        _runtimeEdges[edge.id] = edge;
      case EdgeRemoved<TNodePayload, TEdgePayload>(edgeId: final edgeId):
        _runtimeEdges.remove(edgeId);
      case GraphReset<TNodePayload, TEdgePayload>(snapshot: final snapshot):
        _applySnapshot(snapshot);
        return; // _applySnapshot already notifies and dispatches
    }

    _notifyAndDispatch();
  }

  void _applySnapshot(GraphSnapshot<TNodePayload, TEdgePayload> snapshot) {
    _runtimeNodes.clear();
    _runtimeNodes.addAll(snapshot.nodes);

    _runtimeEdges.clear();
    _runtimeEdges.addAll(snapshot.edges);

    final computedPositions = layoutStrategy.computeLayout(
      _runtimeNodes.keys.toList(growable: false),
      existingPositions: _positions,
    );
    _positions.clear();
    _positions.addAll(computedPositions);

    _notifyAndDispatch();
  }

  void _notifyAndDispatch() {
    notifyListeners();
    _modelStreamController.add(viewModel);
  }

  /// Manually updates or overrides the layout position of a specific node.
  ///
  /// Useful for handling user drag and canvas repositioning in UI organisms.
  void updateNodePosition(String nodeId, Offset newPosition) {
    if (_isDisposed || !_runtimeNodes.containsKey(nodeId)) return;
    _positions[nodeId] = newPosition;
    _notifyAndDispatch();
  }

  /// Recomputes all node positions using [layoutStrategy].
  void relayout() {
    if (_isDisposed || _runtimeNodes.isEmpty) return;
    final newPositions = layoutStrategy.computeLayout(
      _runtimeNodes.keys.toList(growable: false),
    );
    _positions.clear();
    _positions.addAll(newPositions);
    _notifyAndDispatch();
  }

  /// Current immutable presentation view model snapshot.
  GraphViewModel get viewModel {
    final projectedNodes = _runtimeNodes.values
        .map((node) {
          final pos = _positions[node.id] ?? Offset.zero;
          return PrismGraphNode(
            id: node.id,
            label: node.label,
            type: node.kind,
            status: node.status,
            position: pos,
            metadata: {
              ...node.metadata,
              if (node.payload != null) 'payload': node.payload,
            },
          );
        })
        .toList(growable: false);

    final projectedEdges = _runtimeEdges.values
        .map((edge) {
          return PrismGraphEdge(
            sourceId: edge.fromNodeId,
            targetId: edge.toNodeId,
            label: edge.kind,
            edgeType: edge.kind,
          );
        })
        .toList(growable: false);

    return GraphViewModel(
      nodes: projectedNodes,
      edges: projectedEdges,
      positions: Map.unmodifiable(_positions),
    );
  }

  /// Current renderable nodes list for [PrismGraphCanvas].
  List<PrismGraphNode> get nodes => viewModel.nodes;

  /// Current renderable edges list for [PrismGraphCanvas].
  List<PrismGraphEdge> get edges => viewModel.edges;

  /// Read-only snapshot of current layout positions.
  Map<String, Offset> get positions => Map.unmodifiable(_positions);

  /// Number of nodes in the graph.
  int get nodeCount => _runtimeNodes.length;

  /// Number of edges in the graph.
  int get edgeCount => _runtimeEdges.length;

  /// Whether the binding is disposed.
  bool get isDisposed => _isDisposed;

  /// Whether the initial snapshot has been fetched.
  bool get isInitialized => _isInitialized;

  /// Reactive stream of updated [GraphViewModel] snapshots.
  Stream<GraphViewModel> get modelStream => _modelStreamController.stream;

  @override
  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;
    _subscription?.cancel();
    _subscription = null;
    _modelStreamController.close();
    super.dispose();
  }
}
