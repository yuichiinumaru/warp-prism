import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../atoms/atoms.dart';
import '../../molecules/ds_interactive_surface.dart';
import '../../molecules/ds_state_surface.dart';
import '../../tokens/tokens.dart';
import '../ds_graph_canvas.dart';

// =============================================================================
// Workflow node / edge kinds (DAG semantics — not geo, not MapLibre layers)
// =============================================================================

/// Semantic kind of a [DSWorkflowNode] in a workflow DAG.
///
/// Distinct from ASW map/geo feature types and from EPIC-15
/// `PrismMapCanvasStage` layer registry entries. These kinds describe
/// **pipeline steps**, not map assets.
enum DSWorkflowNodeKind {
  /// Entry trigger / webhook / schedule.
  trigger,

  /// Ingest / intake step.
  ingest,

  /// Generic transform / process.
  process,

  /// Routing / fan-out decision.
  route,

  /// Response / egress step.
  respond,

  /// Agent invocation step.
  agent,

  /// Tool / skill call step.
  tool,

  /// Branch / condition gate.
  condition,

  /// Terminal output / sink.
  output,

  /// Extension / custom step label.
  custom,
}

/// Semantic kind of a directed [DSWorkflowEdge].
enum DSWorkflowEdgeKind {
  /// Default sequential control flow.
  sequence,

  /// Data / payload handoff.
  data,

  /// Condition evaluated true.
  conditionTrue,

  /// Condition evaluated false.
  conditionFalse,

  /// Error / failure path.
  error,
}

extension DSWorkflowNodeKindX on DSWorkflowNodeKind {
  /// Short display label for chrome and a11y.
  String get label => switch (this) {
    DSWorkflowNodeKind.trigger => 'Trigger',
    DSWorkflowNodeKind.ingest => 'Ingest',
    DSWorkflowNodeKind.process => 'Process',
    DSWorkflowNodeKind.route => 'Route',
    DSWorkflowNodeKind.respond => 'Respond',
    DSWorkflowNodeKind.agent => 'Agent',
    DSWorkflowNodeKind.tool => 'Tool',
    DSWorkflowNodeKind.condition => 'Condition',
    DSWorkflowNodeKind.output => 'Output',
    DSWorkflowNodeKind.custom => 'Custom',
  };

  /// Stable id token.
  String get id => name;

  /// Accent color for node chrome.
  Color get accentColor => switch (this) {
    DSWorkflowNodeKind.trigger => DSColors.accentGold,
    DSWorkflowNodeKind.ingest => DSColors.accentCyan,
    DSWorkflowNodeKind.process => DSColors.accentViolet,
    DSWorkflowNodeKind.route => DSColors.accentCyan,
    DSWorkflowNodeKind.respond => DSColors.statusSuccess,
    DSWorkflowNodeKind.agent => DSColors.assetAgent,
    DSWorkflowNodeKind.tool => DSColors.assetSkill,
    DSWorkflowNodeKind.condition => DSColors.accentGold,
    DSWorkflowNodeKind.output => DSColors.statusPromoted,
    DSWorkflowNodeKind.custom => DSColors.textSecondary,
  };

  /// Material icon for node chip.
  IconData get icon => switch (this) {
    DSWorkflowNodeKind.trigger => Icons.bolt_outlined,
    DSWorkflowNodeKind.ingest => Icons.input_outlined,
    DSWorkflowNodeKind.process => Icons.settings_outlined,
    DSWorkflowNodeKind.route => Icons.alt_route_outlined,
    DSWorkflowNodeKind.respond => Icons.outbox_outlined,
    DSWorkflowNodeKind.agent => Icons.smart_toy_outlined,
    DSWorkflowNodeKind.tool => Icons.extension_outlined,
    DSWorkflowNodeKind.condition => Icons.call_split_outlined,
    DSWorkflowNodeKind.output => Icons.flag_outlined,
    DSWorkflowNodeKind.custom => Icons.circle_outlined,
  };

  /// Maps to legacy [GraphNode.type] for optional [DSGraphCanvas] composition.
  String get graphType => switch (this) {
    DSWorkflowNodeKind.trigger => 'workflow',
    DSWorkflowNodeKind.ingest => 'workflow',
    DSWorkflowNodeKind.process => 'skill',
    DSWorkflowNodeKind.route => 'workflow',
    DSWorkflowNodeKind.respond => 'workflow',
    DSWorkflowNodeKind.agent => 'agent',
    DSWorkflowNodeKind.tool => 'skill',
    DSWorkflowNodeKind.condition => 'task',
    DSWorkflowNodeKind.output => 'doc',
    DSWorkflowNodeKind.custom => 'task',
  };
}

extension DSWorkflowEdgeKindX on DSWorkflowEdgeKind {
  /// Short display label.
  String get label => switch (this) {
    DSWorkflowEdgeKind.sequence => 'sequence',
    DSWorkflowEdgeKind.data => 'data',
    DSWorkflowEdgeKind.conditionTrue => 'true',
    DSWorkflowEdgeKind.conditionFalse => 'false',
    DSWorkflowEdgeKind.error => 'error',
  };

  String get id => name;

  /// Stroke color for painted connectors.
  Color get strokeColor => switch (this) {
    DSWorkflowEdgeKind.sequence => DSColors.borderDefault,
    DSWorkflowEdgeKind.data => DSColors.accentCyan,
    DSWorkflowEdgeKind.conditionTrue => DSColors.statusSuccess,
    DSWorkflowEdgeKind.conditionFalse => DSColors.accentGold,
    DSWorkflowEdgeKind.error => DSColors.statusError,
  };

  /// Maps to legacy [GraphEdge.edgeType] for optional composition.
  String get graphEdgeType => switch (this) {
    DSWorkflowEdgeKind.sequence => 'triggers',
    DSWorkflowEdgeKind.data => 'uses',
    DSWorkflowEdgeKind.conditionTrue => 'triggers',
    DSWorkflowEdgeKind.conditionFalse => 'references',
    DSWorkflowEdgeKind.error => 'references',
  };
}

// =============================================================================
// Models
// =============================================================================

/// Immutable workflow DAG node for [DSWorkflowCanvasStage].
///
/// **Contract fields**:
/// - [id] — stable unique id within the graph (selection key).
/// - [label] — human-readable step name.
/// - [kind] — [DSWorkflowNodeKind] semantic role (ingest/route/respond/…).
/// - [status] — optional operational status string (running, idle, …).
/// - [position] — optional layout hint in stage local coordinates; when null,
///   the stage auto-lays out by DAG level (left → right).
/// - [metadata] — optional opaque bag for hosts (fixture tags only here).
///
/// **Not** a geo feature, map layer, or MapLibre source. For map stages see
/// EPIC-15 `PrismMapCanvasStage` (Task 1512) — separate product class.
@immutable
class DSWorkflowNode {
  /// Stable unique id within the workflow graph.
  final String id;

  /// Display label for the step.
  final String label;

  /// Semantic pipeline role.
  final DSWorkflowNodeKind kind;

  /// Optional operational status (fixture string).
  final String? status;

  /// Optional layout position (top-left of node chrome). Auto-layout when null.
  final Offset? position;

  /// Opaque host metadata (fixtures only in this package).
  final Map<String, dynamic> metadata;

  const DSWorkflowNode({
    required this.id,
    required this.label,
    required this.kind,
    this.status,
    this.position,
    this.metadata = const {},
  });

  /// Screen-reader label.
  String get semanticLabel {
    final buf = StringBuffer('${kind.label}: $label');
    if (status != null && status!.isNotEmpty) {
      buf.write(', $status');
    }
    return buf.toString();
  }

  DSWorkflowNode copyWith({
    String? id,
    String? label,
    DSWorkflowNodeKind? kind,
    String? status,
    Offset? position,
    Map<String, dynamic>? metadata,
    bool clearStatus = false,
    bool clearPosition = false,
  }) {
    return DSWorkflowNode(
      id: id ?? this.id,
      label: label ?? this.label,
      kind: kind ?? this.kind,
      status: clearStatus ? null : (status ?? this.status),
      position: clearPosition ? null : (position ?? this.position),
      metadata: metadata ?? this.metadata,
    );
  }

  /// Adapter for composing [DSGraphCanvas] / [PrismGraphCanvas].
  GraphNode toGraphNode({Offset? resolvedPosition}) {
    return GraphNode(
      id: id,
      label: label,
      type: kind.graphType,
      status: status,
      metadata: {...metadata, 'workflowKind': kind.id},
      position: resolvedPosition ?? position,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DSWorkflowNode &&
        other.id == id &&
        other.label == label &&
        other.kind == kind &&
        other.status == status &&
        other.position == position;
  }

  @override
  int get hashCode => Object.hash(id, label, kind, status, position);
}

/// Immutable directed workflow DAG edge for [DSWorkflowCanvasStage].
///
/// **Contract fields**:
/// - [id] — stable unique edge id (selection key).
/// - [fromId] — source node id.
/// - [toId] — target node id.
/// - [kind] — [DSWorkflowEdgeKind] (sequence/data/condition/error).
/// - [label] — optional connector label.
///
/// Directed only. No geo coordinates. Not a map polyline layer.
@immutable
class DSWorkflowEdge {
  /// Stable unique id within the workflow graph.
  final String id;

  /// Source node id (`from`).
  final String fromId;

  /// Target node id (`to`).
  final String toId;

  /// Semantic connector kind.
  final DSWorkflowEdgeKind kind;

  /// Optional display label on the connector / edge strip.
  final String? label;

  const DSWorkflowEdge({
    required this.id,
    required this.fromId,
    required this.toId,
    this.kind = DSWorkflowEdgeKind.sequence,
    this.label,
  });

  /// Convenience: auto-id from endpoints when host does not supply one.
  factory DSWorkflowEdge.connect({
    required String fromId,
    required String toId,
    DSWorkflowEdgeKind kind = DSWorkflowEdgeKind.sequence,
    String? label,
    String? id,
  }) {
    return DSWorkflowEdge(
      id: id ?? '$fromId->$toId',
      fromId: fromId,
      toId: toId,
      kind: kind,
      label: label,
    );
  }

  /// Display label (explicit or kind default).
  String get displayLabel => label ?? kind.label;

  /// Screen-reader label.
  String get semanticLabel => 'Edge $displayLabel from $fromId to $toId';

  DSWorkflowEdge copyWith({
    String? id,
    String? fromId,
    String? toId,
    DSWorkflowEdgeKind? kind,
    String? label,
    bool clearLabel = false,
  }) {
    return DSWorkflowEdge(
      id: id ?? this.id,
      fromId: fromId ?? this.fromId,
      toId: toId ?? this.toId,
      kind: kind ?? this.kind,
      label: clearLabel ? null : (label ?? this.label),
    );
  }

  /// Adapter for composing [DSGraphCanvas].
  GraphEdge toGraphEdge() {
    return GraphEdge(
      sourceId: fromId,
      targetId: toId,
      label: displayLabel,
      edgeType: kind.graphEdgeType,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DSWorkflowEdge &&
        other.id == id &&
        other.fromId == fromId &&
        other.toId == toId &&
        other.kind == kind &&
        other.label == label;
  }

  @override
  int get hashCode => Object.hash(id, fromId, toId, kind, label);
}

/// Selection bus payload for the workflow stage.
///
/// Exactly one of [nodeId] / [edgeId] is set for a concrete selection;
/// both null means cleared. Distinct from map feature selection (geo ids /
/// layer registry) on EPIC-15 map canvas stage.
@immutable
class DSWorkflowSelection {
  /// Selected node id, if any.
  final String? nodeId;

  /// Selected edge id, if any.
  final String? edgeId;

  const DSWorkflowSelection({this.nodeId, this.edgeId});

  /// Empty / cleared selection.
  const DSWorkflowSelection.cleared() : nodeId = null, edgeId = null;

  /// Node-focused selection.
  const DSWorkflowSelection.node(String id) : nodeId = id, edgeId = null;

  /// Edge-focused selection.
  const DSWorkflowSelection.edge(String id) : nodeId = null, edgeId = id;

  bool get isEmpty => nodeId == null && edgeId == null;
  bool get hasNode => nodeId != null;
  bool get hasEdge => edgeId != null;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DSWorkflowSelection &&
        other.nodeId == nodeId &&
        other.edgeId == edgeId;
  }

  @override
  int get hashCode => Object.hash(nodeId, edgeId);
}

// =============================================================================
// Layout (pure — unit-testable)
// =============================================================================

/// Deterministic left-to-right DAG layout for workflow nodes.
///
/// Pure Flutter coordinate math — **no** force-graph JS, MapLibre, or
/// physics simulation. Prefer explicit [DSWorkflowNode.position] when set.
abstract final class DSWorkflowCanvasLayout {
  /// Default node chrome size.
  static const Size nodeSize = Size(148, 64);

  /// Horizontal gap between DAG levels.
  static const double levelGap = 56;

  /// Vertical gap between nodes in the same level.
  static const double rowGap = 28;

  /// Canvas padding around the laid-out graph.
  static const EdgeInsets padding = EdgeInsets.all(24);

  /// Computes positions for nodes missing [DSWorkflowNode.position].
  ///
  /// Level = longest path distance from any root (node with no inbound edges).
  /// Nodes with explicit positions are preserved.
  static Map<String, Offset> resolvePositions({
    required List<DSWorkflowNode> nodes,
    required List<DSWorkflowEdge> edges,
  }) {
    final byId = <String, DSWorkflowNode>{for (final n in nodes) n.id: n};
    final inbound = <String, int>{for (final n in nodes) n.id: 0};
    final outbound = <String, List<String>>{
      for (final n in nodes) n.id: <String>[],
    };
    for (final e in edges) {
      if (!byId.containsKey(e.fromId) || !byId.containsKey(e.toId)) continue;
      inbound[e.toId] = (inbound[e.toId] ?? 0) + 1;
      outbound[e.fromId]!.add(e.toId);
    }

    final level = <String, int>{};
    final queue = <String>[
      for (final n in nodes)
        if ((inbound[n.id] ?? 0) == 0) n.id,
    ];
    for (final id in queue) {
      level[id] = 0;
    }
    // Kahn-style relaxation: take max level from parents.
    var guard = 0;
    final maxGuard = nodes.length * nodes.length + 4;
    while (queue.isNotEmpty && guard < maxGuard) {
      guard++;
      final id = queue.removeAt(0);
      final base = level[id] ?? 0;
      for (final next in outbound[id] ?? const <String>[]) {
        final candidate = base + 1;
        if (candidate > (level[next] ?? -1)) {
          level[next] = candidate;
        }
        // Always enqueue once to propagate (bounded by guard).
        if (!queue.contains(next)) queue.add(next);
      }
    }
    for (final n in nodes) {
      level.putIfAbsent(n.id, () => 0);
    }

    // Group by level for vertical packing.
    final byLevel = <int, List<String>>{};
    for (final n in nodes) {
      final lv = level[n.id] ?? 0;
      byLevel.putIfAbsent(lv, () => <String>[]).add(n.id);
    }
    for (final list in byLevel.values) {
      list.sort();
    }

    final result = <String, Offset>{};
    for (final entry in byLevel.entries) {
      final lv = entry.key;
      final ids = entry.value;
      for (var i = 0; i < ids.length; i++) {
        final id = ids[i];
        final node = byId[id]!;
        if (node.position != null) {
          result[id] = node.position!;
          continue;
        }
        final x = padding.left + lv * (nodeSize.width + levelGap);
        final y = padding.top + i * (nodeSize.height + rowGap);
        result[id] = Offset(x, y);
      }
    }
    return result;
  }

  /// Bounding size that fits all resolved positions + node size + padding.
  static Size resolveCanvasSize(Map<String, Offset> positions) {
    if (positions.isEmpty) {
      return const Size(320, 200);
    }
    var maxX = 0.0;
    var maxY = 0.0;
    for (final p in positions.values) {
      maxX = math.max(maxX, p.dx + nodeSize.width);
      maxY = math.max(maxY, p.dy + nodeSize.height);
    }
    return Size(maxX + padding.right, maxY + padding.bottom);
  }
}

// =============================================================================
// Stage organism
// =============================================================================

/// ASW Observatory Organism — Workflow Canvas Stage (contract + fake stage)
///
/// **C-11 / Task 1610.** Stage host for **workflow DAGs** (nodes + directed
/// edges + selection bus). Fixture-first; read-only interact selection only —
/// not a full Sim Studio / React Flow editor, not MapLibre, not force-graph JS.
///
/// ### Contract
/// - [nodes] / [edges] — workflow models ([DSWorkflowNode], [DSWorkflowEdge]).
/// - Selection: [selectedNodeId] / [selectedEdgeId] (controlled) +
///   [onNodeSelected] / [onEdgeSelected] / [onSelectionChanged] /
///   [onSelectionCleared].
/// - Empty graph → [DSStateSurface.empty]; [isLoading] → loading surface.
/// - Viewport host paints connectors + node chips; optional edge strip for
///   reliable edge selection (MVP).
/// - Optional [DSGraphCanvas] adapters via [DSWorkflowNode.toGraphNode] /
///   [DSWorkflowEdge.toGraphEdge] for hosts that compose the graph module.
///
/// ### Distinction from EPIC-15 map stage
/// | Concern | This organism | Map canvas stage (1512) |
/// | --- | --- | --- |
/// | Domain | Workflow DAG steps | Geo / map layers |
/// | Models | node kind / edge kind | layer registry + features |
/// | Engine | Pure Flutter layout | Placeholder — no MapLibre |
/// | Selection | nodeId / edgeId | feature + layer selection |
///
/// Usage:
/// ```dart
/// DSWorkflowCanvasStage(
///   nodes: dsWorkflowCanvasStageFixtureNodes(),
///   edges: dsWorkflowCanvasStageFixtureEdges(),
///   onNodeSelected: (n) => ...,
///   onEdgeSelected: (e) => ...,
/// )
/// ```
class DSWorkflowCanvasStage extends StatelessWidget {
  /// Workflow DAG nodes.
  final List<DSWorkflowNode> nodes;

  /// Directed workflow edges.
  final List<DSWorkflowEdge> edges;

  /// Controlled selected node id (highlight).
  final String? selectedNodeId;

  /// Controlled selected edge id (highlight).
  final String? selectedEdgeId;

  /// Fired when a node chip is activated.
  final ValueChanged<DSWorkflowNode>? onNodeSelected;

  /// Fired when an edge is activated (edge strip or future hit target).
  final ValueChanged<DSWorkflowEdge>? onEdgeSelected;

  /// Fired with the full selection bus payload after any change.
  final ValueChanged<DSWorkflowSelection>? onSelectionChanged;

  /// Fired when the user clears selection (stage background tap).
  final VoidCallback? onSelectionCleared;

  /// When true, shows a loading surface instead of the canvas.
  final bool isLoading;

  /// Region semantic label.
  final String semanticLabel;

  /// Optional stage title chrome.
  final String? title;

  /// Optional subtitle chrome.
  final String? subtitle;

  /// When true and graph is empty (and not loading), show empty placeholder.
  final bool showEmptyPlaceholder;

  /// Empty-state title.
  final String emptyTitle;

  /// Empty-state subtitle.
  final String emptySubtitle;

  /// Loading-state title.
  final String loadingTitle;

  /// Whether to show the edge selection strip under the canvas.
  final bool showEdgeStrip;

  /// Whether to wrap the stage in glass panel chrome.
  final bool wrapInGlass;

  /// Minimum stage height for the viewport.
  final double minHeight;

  const DSWorkflowCanvasStage({
    super.key,
    required this.nodes,
    required this.edges,
    this.selectedNodeId,
    this.selectedEdgeId,
    this.onNodeSelected,
    this.onEdgeSelected,
    this.onSelectionChanged,
    this.onSelectionCleared,
    this.isLoading = false,
    this.semanticLabel = 'Workflow canvas stage',
    this.title,
    this.subtitle,
    this.showEmptyPlaceholder = true,
    this.emptyTitle = 'No workflow nodes',
    this.emptySubtitle =
        'Load a fixture DAG (e.g. ingest → route → respond) to inspect steps',
    this.loadingTitle = 'Loading workflow…',
    this.showEdgeStrip = true,
    this.wrapInGlass = true,
    this.minHeight = 240,
  });

  /// Stable keys for tests and gallery.
  static const Key stageKey = Key('ds-workflow-canvas-stage');
  static const Key emptyKey = Key('ds-workflow-canvas-stage-empty');
  static const Key loadingKey = Key('ds-workflow-canvas-stage-loading');
  static const Key canvasKey = Key('ds-workflow-canvas-stage-canvas');
  static const Key edgeStripKey = Key('ds-workflow-canvas-stage-edge-strip');

  static Key nodeKey(String id) => Key('ds-workflow-canvas-stage-node-$id');
  static Key edgeKey(String id) => Key('ds-workflow-canvas-stage-edge-$id');

  @override
  Widget build(BuildContext context) {
    final Widget body;
    if (isLoading) {
      body = _buildLoading();
    } else if (nodes.isEmpty) {
      body = showEmptyPlaceholder ? _buildEmpty() : const SizedBox.shrink();
    } else {
      body = _buildCanvas();
    }

    final content = Semantics(
      container: true,
      label: _regionLabel(),
      child: Column(
        key: stageKey,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null || subtitle != null) _buildHeader(),
          if (title != null || subtitle != null) const DSDivider.subtle(),
          body,
        ],
      ),
    );

    if (!wrapInGlass) return content;

    return DSGlassPanelSimple(
      backgroundColor: DSColors.obsidianBase.withValues(alpha: 0.95),
      borderColor: DSColors.borderSubtle,
      padding: EdgeInsets.zero,
      child: content,
    );
  }

  String _regionLabel() {
    if (isLoading) return '$semanticLabel: loading';
    if (nodes.isEmpty) return '$semanticLabel: empty';
    return '$semanticLabel: ${nodes.length} nodes, ${edges.length} edges';
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.lg,
        vertical: DSSpacing.md,
      ),
      child: Row(
        children: [
          const DSIcon(
            Icons.account_tree_outlined,
            color: DSColors.accentCyan,
            size: 18,
          ),
          const SizedBox(width: DSSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null)
                  DSText.labelLarge(title!, color: DSColors.textPrimary),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  DSText.bodySmall(subtitle!, color: DSColors.textTertiary),
                ],
              ],
            ),
          ),
          DSBadge(
            label: '${nodes.length}n · ${edges.length}e',
            color: DSColors.accentCyan,
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return SizedBox(
      key: emptyKey,
      height: minHeight,
      child: DSStateSurface.empty(
        icon: Icons.account_tree_outlined,
        title: emptyTitle,
        subtitle: emptySubtitle,
        compact: true,
      ),
    );
  }

  Widget _buildLoading() {
    return SizedBox(
      key: loadingKey,
      height: minHeight,
      child: DSStateSurface.loading(title: loadingTitle, compact: true),
    );
  }

  Widget _buildCanvas() {
    final positions = DSWorkflowCanvasLayout.resolvePositions(
      nodes: nodes,
      edges: edges,
    );
    final canvasSize = DSWorkflowCanvasLayout.resolveCanvasSize(positions);
    final height = math.max(minHeight, canvasSize.height);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          key: canvasKey,
          height: height,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              onSelectionCleared?.call();
              onSelectionChanged?.call(const DSWorkflowSelection.cleared());
            },
            child: ClipRect(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  child: SizedBox(
                    width: math.max(canvasSize.width, 320),
                    height: height,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned.fill(
                          child: CustomPaint(
                            painter: _WorkflowEdgePainter(
                              nodes: nodes,
                              edges: edges,
                              positions: positions,
                              selectedEdgeId: selectedEdgeId,
                              selectedNodeId: selectedNodeId,
                              nodeSize: DSWorkflowCanvasLayout.nodeSize,
                            ),
                          ),
                        ),
                        for (final node in nodes)
                          if (positions[node.id] != null)
                            Positioned(
                              left: positions[node.id]!.dx,
                              top: positions[node.id]!.dy,
                              width: DSWorkflowCanvasLayout.nodeSize.width,
                              height: DSWorkflowCanvasLayout.nodeSize.height,
                              child: _WorkflowNodeChip(
                                key: nodeKey(node.id),
                                node: node,
                                selected: selectedNodeId == node.id,
                                onTap: () {
                                  onNodeSelected?.call(node);
                                  onSelectionChanged?.call(
                                    DSWorkflowSelection.node(node.id),
                                  );
                                },
                              ),
                            ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        if (showEdgeStrip && edges.isNotEmpty) ...[
          const DSDivider.subtle(),
          _buildEdgeStrip(),
        ],
      ],
    );
  }

  Widget _buildEdgeStrip() {
    return SizedBox(
      key: edgeStripKey,
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: DSSpacing.md,
          vertical: DSSpacing.sm,
        ),
        itemCount: edges.length,
        separatorBuilder: (_, __) => const SizedBox(width: DSSpacing.sm),
        itemBuilder: (context, index) {
          final edge = edges[index];
          final selected = selectedEdgeId == edge.id;
          return DSInteractiveSurface(
            key: edgeKey(edge.id),
            semanticLabel: edge.semanticLabel,
            selected: selected,
            onTap: () {
              onEdgeSelected?.call(edge);
              onSelectionChanged?.call(DSWorkflowSelection.edge(edge.id));
            },
            padding: const EdgeInsets.symmetric(
              horizontal: DSSpacing.sm,
              vertical: DSSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: selected
                  ? edge.kind.strokeColor.withValues(alpha: 0.18)
                  : DSColors.obsidianElevated.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(DSRadii.sm),
              border: Border.all(
                color: selected ? edge.kind.strokeColor : DSColors.borderSubtle,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.arrow_forward,
                  size: 12,
                  color: edge.kind.strokeColor,
                ),
                const SizedBox(width: 4),
                DSText.labelSmall(
                  edge.displayLabel,
                  color: selected
                      ? DSColors.textPrimary
                      : DSColors.textSecondary,
                ),
                const SizedBox(width: 4),
                DSText.bodySmall(
                  '${edge.fromId}→${edge.toId}',
                  color: DSColors.textTertiary,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// =============================================================================
// Private chrome
// =============================================================================

class _WorkflowNodeChip extends StatelessWidget {
  final DSWorkflowNode node;
  final bool selected;
  final VoidCallback? onTap;

  const _WorkflowNodeChip({
    super.key,
    required this.node,
    required this.selected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accent = node.kind.accentColor;
    return DSInteractiveSurface(
      semanticLabel: node.semanticLabel,
      selected: selected,
      onTap: onTap,
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.sm,
        vertical: DSSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: DSColors.obsidianElevated.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(DSRadii.md),
        border: Border.all(
          color: selected ? accent : DSColors.borderSubtle,
          width: selected ? 2 : 1,
        ),
        boxShadow: selected
            ? [
                BoxShadow(
                  color: accent.withValues(alpha: 0.25),
                  blurRadius: 10,
                  spreadRadius: 0,
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(DSRadii.sm),
            ),
            alignment: Alignment.center,
            child: Icon(node.kind.icon, size: 16, color: accent),
          ),
          const SizedBox(width: DSSpacing.sm),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DSText.labelSmall(
                  node.label,
                  color: DSColors.textPrimary,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                DSText.bodySmall(
                  node.status ?? node.kind.label,
                  color: DSColors.textTertiary,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkflowEdgePainter extends CustomPainter {
  final List<DSWorkflowNode> nodes;
  final List<DSWorkflowEdge> edges;
  final Map<String, Offset> positions;
  final String? selectedEdgeId;
  final String? selectedNodeId;
  final Size nodeSize;

  _WorkflowEdgePainter({
    required this.nodes,
    required this.edges,
    required this.positions,
    required this.selectedEdgeId,
    required this.selectedNodeId,
    required this.nodeSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final edge in edges) {
      final from = positions[edge.fromId];
      final to = positions[edge.toId];
      if (from == null || to == null) continue;

      final start = Offset(
        from.dx + nodeSize.width,
        from.dy + nodeSize.height / 2,
      );
      final end = Offset(to.dx, to.dy + nodeSize.height / 2);

      final highlighted =
          selectedEdgeId == edge.id ||
          selectedNodeId == edge.fromId ||
          selectedNodeId == edge.toId;
      final color = highlighted
          ? edge.kind.strokeColor
          : edge.kind.strokeColor.withValues(alpha: 0.55);
      final stroke = highlighted ? 2.0 : 1.25;

      final paint = Paint()
        ..color = color
        ..strokeWidth = stroke
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      final midX = (start.dx + end.dx) / 2;
      final path = Path()
        ..moveTo(start.dx, start.dy)
        ..cubicTo(midX, start.dy, midX, end.dy, end.dx, end.dy);
      canvas.drawPath(path, paint);

      // Arrow head at end.
      final angle = math.atan2(end.dy - start.dy, end.dx - start.dx);
      const arrow = 7.0;
      final tip = end;
      final p1 = Offset(
        tip.dx - arrow * math.cos(angle - 0.4),
        tip.dy - arrow * math.sin(angle - 0.4),
      );
      final p2 = Offset(
        tip.dx - arrow * math.cos(angle + 0.4),
        tip.dy - arrow * math.sin(angle + 0.4),
      );
      final arrowPath = Path()
        ..moveTo(tip.dx, tip.dy)
        ..lineTo(p1.dx, p1.dy)
        ..lineTo(p2.dx, p2.dy)
        ..close();
      canvas.drawPath(
        arrowPath,
        Paint()
          ..color = color
          ..style = PaintingStyle.fill,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WorkflowEdgePainter oldDelegate) {
    return oldDelegate.nodes != nodes ||
        oldDelegate.edges != edges ||
        oldDelegate.positions != positions ||
        oldDelegate.selectedEdgeId != selectedEdgeId ||
        oldDelegate.selectedNodeId != selectedNodeId ||
        oldDelegate.nodeSize != nodeSize;
  }
}

// =============================================================================
// Fixtures (gallery + tests) — mock workflow IDs only
// =============================================================================

/// Gallery fixture: ingest → route → respond (+ tool side branch).
List<DSWorkflowNode> dsWorkflowCanvasStageFixtureNodes() {
  return const [
    DSWorkflowNode(
      id: 'n-ingest',
      label: 'Ingest',
      kind: DSWorkflowNodeKind.ingest,
      status: 'ready',
    ),
    DSWorkflowNode(
      id: 'n-route',
      label: 'Route',
      kind: DSWorkflowNodeKind.route,
      status: 'idle',
    ),
    DSWorkflowNode(
      id: 'n-tool',
      label: 'Enrich',
      kind: DSWorkflowNodeKind.tool,
      status: 'idle',
    ),
    DSWorkflowNode(
      id: 'n-respond',
      label: 'Respond',
      kind: DSWorkflowNodeKind.respond,
      status: 'idle',
    ),
  ];
}

/// Edges for [dsWorkflowCanvasStageFixtureNodes].
List<DSWorkflowEdge> dsWorkflowCanvasStageFixtureEdges() {
  return [
    DSWorkflowEdge.connect(
      id: 'e-ingest-route',
      fromId: 'n-ingest',
      toId: 'n-route',
      kind: DSWorkflowEdgeKind.sequence,
      label: 'next',
    ),
    DSWorkflowEdge.connect(
      id: 'e-route-tool',
      fromId: 'n-route',
      toId: 'n-tool',
      kind: DSWorkflowEdgeKind.data,
      label: 'enrich',
    ),
    DSWorkflowEdge.connect(
      id: 'e-tool-respond',
      fromId: 'n-tool',
      toId: 'n-respond',
      kind: DSWorkflowEdgeKind.sequence,
      label: 'reply',
    ),
    DSWorkflowEdge.connect(
      id: 'e-route-respond',
      fromId: 'n-route',
      toId: 'n-respond',
      kind: DSWorkflowEdgeKind.conditionTrue,
      label: 'fast-path',
    ),
  ];
}

/// Compact two-node fixture for unit/widget tests.
List<DSWorkflowNode> dsWorkflowCanvasStageMinimalNodes() {
  return const [
    DSWorkflowNode(id: 'a', label: 'Ingest', kind: DSWorkflowNodeKind.ingest),
    DSWorkflowNode(id: 'b', label: 'Respond', kind: DSWorkflowNodeKind.respond),
  ];
}

/// Edges for [dsWorkflowCanvasStageMinimalNodes].
List<DSWorkflowEdge> dsWorkflowCanvasStageMinimalEdges() {
  return [
    DSWorkflowEdge.connect(
      id: 'e-a-b',
      fromId: 'a',
      toId: 'b',
      kind: DSWorkflowEdgeKind.sequence,
      label: 'flow',
    ),
  ];
}
