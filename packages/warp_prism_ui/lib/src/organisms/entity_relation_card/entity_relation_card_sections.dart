import 'package:flutter/material.dart';

import '../../atoms/ds_badge.dart';
import '../../atoms/ds_divider.dart';
import '../../atoms/ds_icon.dart';
import '../../atoms/ds_text.dart';
import '../../molecules/ds_state_surface.dart';
import '../../tokens/tokens.dart';
import '../ds_graph_canvas.dart';
import 'entity_relation_card_legend.dart';

/// Header row: icon, title/subtitle, collapse control.
class EntityRelationCardHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String type;
  final Color typeColor;
  final bool collapsed;
  final VoidCallback onToggleCollapsed;
  final Key? headerKey;
  final Key? collapseButtonKey;

  const EntityRelationCardHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.type,
    required this.typeColor,
    required this.collapsed,
    required this.onToggleCollapsed,
    this.headerKey,
    this.collapseButtonKey,
  });

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: headerKey,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(DSSpacing.sm),
            decoration: BoxDecoration(
              color: typeColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(DSRadii.md),
            ),
            child: DSIcon(
              DSIcons.forAssetKind(type),
              color: typeColor,
              iconSize: DSIconSize.medium,
            ),
          ),
          const SizedBox(width: DSSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: DSText.headingSmall(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: DSSpacing.xs),
                    DSBadge(
                      label: type.toUpperCase(),
                      color: typeColor,
                      size: DSBadgeSize.small,
                    ),
                  ],
                ),
                if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
                  const SizedBox(height: DSSpacing.xxs),
                  DSText.bodySmall(
                    subtitle!,
                    color: DSColors.textSecondary,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          Semantics(
            key: collapseButtonKey,
            button: true,
            label: collapsed
                ? 'Expand relationships'
                : 'Collapse relationships',
            child: IconButton(
              icon: Icon(
                collapsed ? Icons.expand_more : Icons.expand_less,
                color: DSColors.textSecondary,
              ),
              onPressed: onToggleCollapsed,
              tooltip: collapsed ? 'Expand' : 'Collapse',
            ),
          ),
        ],
      ),
    );
  }
}

/// Body: graph/empty surface, legend, footer actions.
class EntityRelationCardBody extends StatelessWidget {
  final String title;
  final Color typeColor;
  final List<GraphNode> nodes;
  final List<GraphEdge> edges;
  final double graphHeight;
  final String? emptyMessage;
  final Map<String, String>? customLegendLabels;
  final void Function(GraphNode)? onNodeTap;
  final void Function(String)? onLegendTap;
  final VoidCallback? onInspectEntity;
  final VoidCallback? onExpandGraph;
  final Key? bodyKey;
  final Key? inspectButtonKey;
  final Key? expandButtonKey;

  const EntityRelationCardBody({
    super.key,
    required this.title,
    required this.typeColor,
    required this.nodes,
    required this.edges,
    required this.graphHeight,
    required this.emptyMessage,
    required this.customLegendLabels,
    required this.onNodeTap,
    required this.onLegendTap,
    required this.onInspectEntity,
    required this.onExpandGraph,
    this.bodyKey,
    this.inspectButtonKey,
    this.expandButtonKey,
  });

  @override
  Widget build(BuildContext context) {
    final uniqueTypes = nodes
        .map((node) => node.type)
        .where((t) => t.isNotEmpty)
        .toSet()
        .toList();

    return KeyedSubtree(
      key: bodyKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: DSSpacing.sm),
          const DSDivider.subtle(),
          const SizedBox(height: DSSpacing.sm),
          if (nodes.isEmpty)
            DSStateSurface.empty(
              title: emptyMessage ?? 'No related entities',
              subtitle:
                  'Select another asset or rebuild the workspace connections.',
              compact: true,
            )
          else ...[
            Container(
              height: graphHeight,
              decoration: BoxDecoration(
                color: DSColors.obsidianDeep,
                borderRadius: BorderRadius.circular(DSRadii.md),
                border: Border.all(color: DSColors.borderSubtle),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(DSRadii.md),
                child: DSGraphCanvas(
                  nodes: nodes,
                  edges: edges,
                  enablePhysics: false,
                  onNodeTap: onNodeTap,
                ),
              ),
            ),
            const SizedBox(height: DSSpacing.md),
            Semantics(
              label: 'Relation legend',
              child: Wrap(
                spacing: DSSpacing.xs,
                runSpacing: DSSpacing.xs,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const DSText.labelSmall(
                    'LEGEND:',
                    color: DSColors.textTertiary,
                  ),
                  const SizedBox(width: DSSpacing.xxs),
                  for (final nodeType in uniqueTypes)
                    EntityRelationLegendButton(
                      type: nodeType,
                      label:
                          customLegendLabels?[nodeType] ??
                          _capitalize(nodeType),
                      onTap: onLegendTap == null
                          ? null
                          : () => onLegendTap!(nodeType),
                    ),
                ],
              ),
            ),
          ],
          const SizedBox(height: DSSpacing.md),
          const DSDivider.subtle(),
          const SizedBox(height: DSSpacing.sm),
          EntityRelationCardFooter(
            title: title,
            typeColor: typeColor,
            onInspectEntity: onInspectEntity,
            onExpandGraph: onExpandGraph,
            inspectButtonKey: inspectButtonKey,
            expandButtonKey: expandButtonKey,
          ),
        ],
      ),
    );
  }

  static String _capitalize(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
  }
}

/// Footer action row for inspect / expand graph.
class EntityRelationCardFooter extends StatelessWidget {
  final String title;
  final Color typeColor;
  final VoidCallback? onInspectEntity;
  final VoidCallback? onExpandGraph;
  final Key? inspectButtonKey;
  final Key? expandButtonKey;

  const EntityRelationCardFooter({
    super.key,
    required this.title,
    required this.typeColor,
    required this.onInspectEntity,
    required this.onExpandGraph,
    this.inspectButtonKey,
    this.expandButtonKey,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (onInspectEntity != null) ...[
          Semantics(
            key: inspectButtonKey,
            button: true,
            label: 'Inspect detail specifications for $title',
            child: OutlinedButton(
              onPressed: onInspectEntity,
              style: OutlinedButton.styleFrom(
                foregroundColor: DSColors.textSecondary,
                side: const BorderSide(color: DSColors.borderSubtle),
                minimumSize: const Size(
                  kMinInteractiveDimension,
                  kMinInteractiveDimension,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: DSSpacing.md,
                  vertical: DSSpacing.sm,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(DSRadii.sm),
                ),
              ),
              child: const DSText.labelMedium('Inspect Detail'),
            ),
          ),
          const SizedBox(width: DSSpacing.sm),
        ],
        if (onExpandGraph != null)
          Semantics(
            key: expandButtonKey,
            button: true,
            label: 'Open full graph view for $title',
            child: ElevatedButton(
              onPressed: onExpandGraph,
              style: ElevatedButton.styleFrom(
                backgroundColor: typeColor.withValues(alpha: 0.2),
                foregroundColor: typeColor,
                disabledBackgroundColor: DSColors.obsidianHover,
                side: BorderSide(color: typeColor.withValues(alpha: 0.5)),
                minimumSize: const Size(
                  kMinInteractiveDimension,
                  kMinInteractiveDimension,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: DSSpacing.md,
                  vertical: DSSpacing.sm,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(DSRadii.sm),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DSIcon.small(DSIcons.graph, color: typeColor),
                  const SizedBox(width: DSSpacing.xs),
                  const DSText.labelMedium('Expand Graph'),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
