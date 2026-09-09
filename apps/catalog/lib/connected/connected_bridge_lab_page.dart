import 'dart:async';
import 'package:flutter/material.dart';
import 'package:warp_prism_adapter_frb/warp_prism_adapter_frb.dart';
import 'package:warp_prism_bindings/warp_prism_bindings.dart';
import 'package:warp_prism_runtime/warp_prism_runtime.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

/// One-page connected proof surface demonstrating live Flutter ↔ Rust bridge integration.
///
/// Architecture:
/// - Late-initializes [WarpBridge.init] and connects [FrbGraphSource].
/// - Projects semantic runtime graph state through [GraphSourceBinding].
/// - Renders in pure presentation layer via [PrismGraphCanvas].
/// - Interactive: "Add Native Node" sends a mutation to the adapter substrate,
///   triggering reactive stream updates through the binding to the canvas.
/// - Fallback: When the native bridge library is unavailable, gracefully degrades
///   to a deterministic in-memory fixture double (labeled FAKE) without crashing.
class ConnectedBridgeLabPage extends StatefulWidget {
  /// Optional injected graph source for testing or custom orchestration.
  final GraphSource<String, String>? source;

  /// Optional bridge initializer hook. Defaults to [WarpBridge.init].
  final Future<void> Function()? bridgeInit;

  /// Whether to animate force-directed physics continuously in the graph canvas.
  final bool enablePhysics;

  const ConnectedBridgeLabPage({
    super.key,
    this.source,
    this.bridgeInit,
    this.enablePhysics = true,
  });

  @override
  State<ConnectedBridgeLabPage> createState() => _ConnectedBridgeLabPageState();
}

class _ConnectedBridgeLabPageState extends State<ConnectedBridgeLabPage> {
  GraphSource<String, String>? _source;
  GraphSourceBinding<String, String>? _binding;
  bool _isLoading = true;
  bool _isLive = false;
  bool _ownsSource = false;
  String _statusMessage = 'Initializing bridge connection...';
  String? _errorMessage;
  int _mutationCounter = 0;

  @override
  void initState() {
    super.initState();
    _initSourceAndBinding();
  }

  Future<void> _initSourceAndBinding() async {
    if (widget.source != null) {
      _source = widget.source;
      _ownsSource = false;
      _isLive = widget.source is FrbGraphSource;
      _statusMessage = _isLive
          ? 'Native Rust Bridge active (FRB FFI connected)'
          : 'Injected test fixture mode (Deterministic double)';
      _setupBinding();
      if (mounted) {
        setState(() => _isLoading = false);
      }
      return;
    }

    _ownsSource = true;
    try {
      final initFn = widget.bridgeInit ?? WarpBridge.init;
      if (!WarpBridge.isInitialized) {
        await initFn();
      }
      final liveSource = FrbGraphSource();
      _source = liveSource;
      _isLive = true;
      _statusMessage = 'Native Rust Bridge active (FRB FFI connected)';
    } catch (e) {
      // Deterministic graceful degradation: fixture mode double
      _isLive = false;
      _source = _createFallbackSource();
      _statusMessage =
          'Bridge unavailable — fixture mode (offline fallback active)';
      _errorMessage = e.toString();
    }

    _setupBinding();
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _setupBinding() {
    final src = _source;
    if (src == null) return;
    _binding = GraphSourceBinding<String, String>(
      source: src,
      layoutStrategy: const CircleGraphLayoutStrategy(),
    );
    _binding!.addListener(_onBindingChanged);
  }

  void _onBindingChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  GraphSource<String, String> _createFallbackSource() {
    const initialNodes = [
      GraphNode<String>(
        id: 'fixture-node-alpha',
        kind: 'agent',
        label: 'Alpha (FAKE)',
        status: 'standby',
        payload: 'payload-alpha',
      ),
      GraphNode<String>(
        id: 'fixture-node-beta',
        kind: 'skill',
        label: 'Beta (FAKE)',
        status: 'ready',
        payload: 'payload-beta',
      ),
      GraphNode<String>(
        id: 'fixture-node-gamma',
        kind: 'workflow',
        label: 'Gamma (FAKE)',
        status: 'active',
        payload: 'payload-gamma',
      ),
    ];

    const initialEdges = [
      GraphEdge<String>(
        id: 'fixture-edge-1',
        kind: 'depends_on',
        fromNodeId: 'fixture-node-alpha',
        toNodeId: 'fixture-node-beta',
        payload: 'edge-1',
      ),
      GraphEdge<String>(
        id: 'fixture-edge-2',
        kind: 'communicates_with',
        fromNodeId: 'fixture-node-beta',
        toNodeId: 'fixture-node-gamma',
        payload: 'edge-2',
      ),
    ];

    return _InMemoryFallbackGraphSource(
      initialNodes: initialNodes,
      initialEdges: initialEdges,
    );
  }

  Future<void> _onAddNode() async {
    final currentCount = (_binding?.nodeCount ?? 0) + 1;
    _mutationCounter++;
    final id = 'node-$currentCount-$_mutationCounter';
    final node = GraphNode<String>(
      id: id,
      kind: currentCount % 2 == 0 ? 'skill' : 'agent',
      label: _isLive
          ? 'Native Node $currentCount'
          : 'Fixture Node $currentCount (FAKE)',
      status: 'active',
      payload: 'payload-$id',
    );

    final src = _source;
    if (src is FrbGraphSource) {
      await src.addNode(node);
    } else if (src is _InMemoryFallbackGraphSource) {
      src.addNode(node);
    } else if (src != null) {
      // Dynamic invocation for test fakes (e.g. FakeGraphSource)
      try {
        (src as dynamic).addNode(node);
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _binding?.removeListener(_onBindingChanged);
    _binding?.dispose();
    if (_ownsSource) {
      _source?.close();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: PrismColors.obsidianDeep,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(PrismSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            const SizedBox(height: PrismSpacing.lg),
            _buildStatusCard(),
            const SizedBox(height: PrismSpacing.lg),
            _buildControlsBar(),
            const SizedBox(height: PrismSpacing.lg),
            _buildCanvasArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.hub_outlined,
              color: PrismColors.accentBlue,
              size: 28,
            ),
            const SizedBox(width: PrismSpacing.sm),
            const Expanded(
              child: PrismText.headingMedium('Connected Bridge Lab'),
            ),
            if (_isLive)
              const PrismBadge(
                label: 'CONNECTED (LIVE FRB)',
                color: PrismColors.statusSuccess,
              )
            else
              const PrismBadge(
                label: 'FIXTURE MODE (FAKE)',
                color: PrismColors.statusWarning,
              ),
          ],
        ),
        const SizedBox(height: PrismSpacing.xs),
        const PrismText.bodySmall(
          'M01 L1 Integration Proof — Live FRB Native Substrate ↔ Bindings ↔ UI Canvas',
        ),
      ],
    );
  }

  Widget _buildStatusCard() {
    final nodeCount = _binding?.nodeCount ?? 0;
    final edgeCount = _binding?.edgeCount ?? 0;

    return Container(
      padding: const EdgeInsets.all(PrismSpacing.md),
      decoration: BoxDecoration(
        color: PrismColors.obsidianBase,
        borderRadius: BorderRadius.circular(PrismRadii.md),
        border: Border.all(
          color: _isLive
              ? PrismColors.statusSuccess.withValues(alpha: 0.3)
              : PrismColors.borderSubtle,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _isLive ? Icons.sensors : Icons.sensors_off,
                size: 20,
                color: _isLive
                    ? PrismColors.statusSuccess
                    : PrismColors.statusWarning,
              ),
              const SizedBox(width: PrismSpacing.sm),
              Expanded(
                child: PrismText.labelLarge(
                  _statusMessage,
                ),
              ),
              Wrap(
                spacing: PrismSpacing.xs,
                children: [
                  PrismBadge(
                    label: 'Nodes: $nodeCount',
                    color: PrismColors.accentBlue,
                  ),
                  PrismBadge(
                    label: 'Edges: $edgeCount',
                    color: PrismColors.accentCyan,
                  ),
                  PrismBadge(
                    label: _isLive ? 'Rust FFI: OK' : 'Rust FFI: OFFLINE',
                    color: _isLive
                        ? PrismColors.statusSuccess
                        : PrismColors.textDisabled,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: PrismSpacing.sm),
          const Divider(color: PrismColors.borderSubtle, height: 1),
          const SizedBox(height: PrismSpacing.sm),
          Row(
            children: [
              const Icon(
                Icons.memory,
                size: 16,
                color: PrismColors.textSecondary,
              ),
              const SizedBox(width: PrismSpacing.xs),
              Expanded(
                child: PrismText.code(
                  _isLive
                      ? 'Live Stream: FrbGraphSource.watchUpdates() → GraphSourceBinding.modelStream → PrismGraphCanvas'
                      : 'Fallback Stream: _InMemoryFallbackGraphSource.watchUpdates() → GraphSourceBinding (Deterministic fixture)',
                ),
              ),
            ],
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: PrismSpacing.xs),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.info_outline,
                  size: 16,
                  color: PrismColors.statusWarning,
                ),
                const SizedBox(width: PrismSpacing.xs),
                Expanded(
                  child: PrismText.bodySmall(
                    'Fallback reason: $_errorMessage',
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildControlsBar() {
    return Wrap(
      spacing: PrismSpacing.md,
      runSpacing: PrismSpacing.sm,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        PrismButton(
          label: _isLive ? 'Add Native Node' : 'Add Fixture Node',
          icon: Icons.add_circle_outline,
          variant: PrismButtonVariant.primary,
          onPressed: _isLoading ? null : _onAddNode,
        ),
        PrismButton(
          label: 'Relayout Circle',
          icon: Icons.refresh,
          variant: PrismButtonVariant.secondary,
          onPressed: _isLoading ? null : () => _binding?.relayout(),
        ),
      ],
    );
  }

  Widget _buildCanvasArea() {
    if (_isLoading) {
      return Container(
        height: 480,
        decoration: BoxDecoration(
          color: PrismColors.obsidianBase,
          borderRadius: BorderRadius.circular(PrismRadii.lg),
          border: Border.all(color: PrismColors.borderSubtle),
        ),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: PrismSpacing.md),
              PrismText.bodyMedium('Initializing native graph substrate...'),
            ],
          ),
        ),
      );
    }

    final nodes = _binding?.nodes ?? const [];
    final edges = _binding?.edges ?? const [];

    return Container(
      height: 520,
      decoration: BoxDecoration(
        color: PrismColors.obsidianBase,
        borderRadius: BorderRadius.circular(PrismRadii.lg),
        border: Border.all(
          color: _isLive
              ? PrismColors.accentBlue.withValues(alpha: 0.4)
              : PrismColors.borderSubtle,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          PrismGraphCanvas(
            nodes: nodes,
            edges: edges,
            enablePhysics: widget.enablePhysics,
          ),
          Positioned(
            top: PrismSpacing.sm,
            right: PrismSpacing.sm,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: PrismSpacing.sm,
                vertical: PrismSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: PrismColors.glassOverlay.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(PrismRadii.sm),
                border: Border.all(color: PrismColors.borderSubtle),
              ),
              child: PrismText.labelSmall(
                'PrismGraphCanvas · ${nodes.length} nodes · ${edges.length} edges',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Lightweight in-memory fallback graph source for offline and fallback operation.
class _InMemoryFallbackGraphSource implements GraphSource<String, String> {
  final Map<String, GraphNode<String>> _nodes = {};
  final Map<String, GraphEdge<String>> _edges = {};
  final StreamController<GraphUpdate<String, String>> _controller =
      StreamController<GraphUpdate<String, String>>.broadcast();
  bool _isClosed = false;

  _InMemoryFallbackGraphSource({
    Iterable<GraphNode<String>>? initialNodes,
    Iterable<GraphEdge<String>>? initialEdges,
  }) {
    if (initialNodes != null) {
      for (final n in initialNodes) {
        _nodes[n.id] = n;
      }
    }
    if (initialEdges != null) {
      for (final e in initialEdges) {
        _edges[e.id] = e;
      }
    }
  }

  @override
  bool get isClosed => _isClosed;

  @override
  Future<GraphSnapshot<String, String>> getSnapshot() async {
    if (_isClosed) {
      throw StateError(
        'Cannot query snapshot on closed _InMemoryFallbackGraphSource',
      );
    }
    return GraphSnapshot<String, String>(
      nodes: Map.unmodifiable(_nodes),
      edges: Map.unmodifiable(_edges),
      timestamp: DateTime.now(),
    );
  }

  @override
  Stream<GraphUpdate<String, String>> watchUpdates() => _controller.stream;

  void addNode(GraphNode<String> node) {
    if (_isClosed) return;
    _nodes[node.id] = node;
    _controller.add(NodeAdded(node));
  }

  @override
  Future<void> close() async {
    if (_isClosed) return;
    _isClosed = true;
    await _controller.close();
  }
}
