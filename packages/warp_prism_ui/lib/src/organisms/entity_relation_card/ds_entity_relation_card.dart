import 'package:flutter/material.dart';

import '../../atoms/ds_glass_panel.dart';
import '../../tokens/tokens.dart';
import '../ds_graph_canvas.dart';
import 'entity_relation_card_sections.dart';

/// ASW Observatory Organism - Entity Relation Card.
///
/// Compact relation preview with a mini-graph preview showing related nodes and
/// edges, dynamic/custom legend, and footer actions.
///
/// EPIC-15 O-10 / Task 1513.
class DSEntityRelationCard extends StatefulWidget {
  /// The title of the entity.
  final String title;

  /// Optional subtitle.
  final String? subtitle;

  /// The type of the entity (e.g. 'agent', 'skill', 'workflow', etc.). All
  /// styling is automatically derived from this kind color.
  final String type;

  /// Connected nodes.
  final List<GraphNode> nodes;

  /// Connected edges.
  final List<GraphEdge> edges;

  /// Optional height of the mini-graph canvas viewport. Defaults to 200.0.
  final double graphHeight;

  /// Optional text to override default empty relations notice.
  final String? emptyMessage;

  /// Callback when "Inspect Entity" button is clicked in the footer.
  final VoidCallback? onInspectEntity;

  /// Callback when "Expand Graph" button is clicked in the footer.
  final VoidCallback? onExpandGraph;

  /// Optional callback for tapping a node in the graph preview.
  final void Function(GraphNode)? onNodeTap;

  /// Callback when a legend category is tapped.
  final void Function(String)? onLegendTap;

  /// Map of category labels for custom override in the legend.
  final Map<String, String>? customLegendLabels;

  /// Controlled minimize/collapsed state. If null, card manages its state
  /// internally.
  final bool? collapsed;

  /// Defaults to false. Controlled or internal.
  final bool initiallyCollapsed;

  /// Callback when collapsed state changes.
  final ValueChanged<bool>? onCollapsedChanged;

  const DSEntityRelationCard({
    super.key,
    required this.title,
    required this.type,
    required this.nodes,
    required this.edges,
    this.subtitle,
    this.graphHeight = 200.0,
    this.emptyMessage,
    this.onInspectEntity,
    this.onExpandGraph,
    this.onNodeTap,
    this.onLegendTap,
    this.customLegendLabels,
    this.collapsed,
    this.initiallyCollapsed = false,
    this.onCollapsedChanged,
  });

  /// Key definitions for testing and accessibility
  static const Key cardRegionKey = Key('ds-relation-card');
  static const Key headerKey = Key('ds-relation-header');
  static const Key bodyKey = Key('ds-relation-body');
  static const Key collapseButtonKey = Key('ds-relation-collapse-btn');
  static const Key inspectButtonKey = Key('ds-relation-inspect-btn');
  static const Key expandButtonKey = Key('ds-relation-expand-btn');

  /// Legend filter key for a node type (Task 1513 a11y path-to-100).
  static Key legendKey(String type) => Key('ds-relation-legend-$type');

  @override
  State<DSEntityRelationCard> createState() => _DSEntityRelationCardState();
}

class _DSEntityRelationCardState extends State<DSEntityRelationCard> {
  late bool _internalCollapsed;

  @override
  void initState() {
    super.initState();
    _internalCollapsed = widget.initiallyCollapsed;
  }

  bool get _isCollapsed => widget.collapsed ?? _internalCollapsed;

  void _toggleCollapsed() {
    final next = !_isCollapsed;
    if (widget.collapsed == null) {
      setState(() => _internalCollapsed = next);
    }
    widget.onCollapsedChanged?.call(next);
  }

  @override
  Widget build(BuildContext context) {
    final collapsed = _isCollapsed;
    final typeColor = DSColors.forAssetKind(widget.type);

    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: 'Relations preview for ${widget.title}',
      child: KeyedSubtree(
        key: DSEntityRelationCard.cardRegionKey,
        child: DSGlassPanel.elevated(
          padding: const EdgeInsets.all(DSSpacing.md),
          child: AnimatedSize(
            duration: DSMotion.normal,
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                EntityRelationCardHeader(
                  title: widget.title,
                  subtitle: widget.subtitle,
                  type: widget.type,
                  typeColor: typeColor,
                  collapsed: collapsed,
                  onToggleCollapsed: _toggleCollapsed,
                  headerKey: DSEntityRelationCard.headerKey,
                  collapseButtonKey: DSEntityRelationCard.collapseButtonKey,
                ),
                if (!collapsed)
                  EntityRelationCardBody(
                    title: widget.title,
                    typeColor: typeColor,
                    nodes: widget.nodes,
                    edges: widget.edges,
                    graphHeight: widget.graphHeight,
                    emptyMessage: widget.emptyMessage,
                    customLegendLabels: widget.customLegendLabels,
                    onNodeTap: widget.onNodeTap,
                    onLegendTap: widget.onLegendTap,
                    onInspectEntity: widget.onInspectEntity,
                    onExpandGraph: widget.onExpandGraph,
                    bodyKey: DSEntityRelationCard.bodyKey,
                    inspectButtonKey: DSEntityRelationCard.inspectButtonKey,
                    expandButtonKey: DSEntityRelationCard.expandButtonKey,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
