/// Workspace graph visualization panel.
///
/// Renders the workspace asset graph using [PrismGraphCanvas] with mode
/// switching between containment and operational projections.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';
import '../workspace_snapshot_provider.dart' hide GraphNode, GraphEdge;

/// Graph panel for the workspace snapshot page.
///
/// Shows a mode toggle and renders the graph canvas with projected
/// nodes and edges from the workspace data.
class WorkspaceGraphPanel extends ConsumerWidget {
  /// When false, freezes force-directed layout (useful for widget tests).
  final bool enablePhysics;

  const WorkspaceGraphPanel({super.key, this.enablePhysics = true});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(graphModeProvider);
    final projection = ref.watch(graphProjectionProvider);

    // Convert provider GraphNode/GraphEdge to Prism graph types
    final prismNodes = projection.nodes
        .map(
          (n) => PrismGraphNode(
            id: n.id,
            label: n.label,
            type: n.type,
            status: n.status,
          ),
        )
        .toList();

    final prismEdges = projection.edges
        .map(
          (e) => PrismGraphEdge(
            sourceId: e.sourceId,
            targetId: e.targetId,
            edgeType: e.edgeType,
          ),
        )
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Mode toggle
        _GraphModeToggle(
          currentMode: mode,
          onModeChanged: (newMode) {
            ref.read(graphModeProvider.notifier).state = newMode;
          },
        ),
        const SizedBox(height: PrismSpacing.sm),
        // Node/edge counts
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: PrismSpacing.sm),
          child: Row(
            children: [
              PrismText.labelSmall(
                '${prismNodes.length} nodes',
                color: PrismColors.textTertiary,
              ),
              const SizedBox(width: PrismSpacing.md),
              PrismText.labelSmall(
                '${prismEdges.length} edges',
                color: PrismColors.textTertiary,
              ),
            ],
          ),
        ),
        const SizedBox(height: PrismSpacing.sm),
        // Graph canvas
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(PrismRadii.card),
            child: PrismGraphCanvas(
              nodes: prismNodes,
              edges: prismEdges,
              enablePhysics: enablePhysics,
              onNodeTap: (node) {
                selectAsset(ref, node.id);
              },
            ),
          ),
        ),
      ],
    );
  }
}

/// Toggle between containment and operational graph modes.
class _GraphModeToggle extends StatelessWidget {
  final GraphMode currentMode;
  final ValueChanged<GraphMode> onModeChanged;

  const _GraphModeToggle({
    required this.currentMode,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const PrismText.labelMedium('GRAPH MODE', color: PrismColors.textSecondary),
        const SizedBox(width: PrismSpacing.md),
        _ModeButton(
          label: 'Containment',
          isActive: currentMode == GraphMode.containment,
          onTap: () => onModeChanged(GraphMode.containment),
          tooltip: 'skill → sub-skill → workflow',
        ),
        const SizedBox(width: PrismSpacing.xs),
        _ModeButton(
          label: 'Operational',
          isActive: currentMode == GraphMode.operational,
          onTap: () => onModeChanged(GraphMode.operational),
          tooltip: 'agent → skills → workflows',
        ),
      ],
    );
  }
}

class _ModeButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final String tooltip;

  const _ModeButton({
    required this.label,
    required this.isActive,
    required this.onTap,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? PrismColors.accentCyan : PrismColors.textTertiary;
    final bgColor = isActive
        ? PrismColors.accentCyan.withValues(alpha: 0.15)
        : PrismColors.obsidianElevated;
    final borderColor = isActive
        ? PrismColors.accentCyan.withValues(alpha: 0.5)
        : PrismColors.borderSubtle;

    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: AnimatedContainer(
            duration: PrismMotion.fast,
            padding: const EdgeInsets.symmetric(
              horizontal: PrismSpacing.md,
              vertical: PrismSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(PrismRadii.chip),
              border: Border.all(color: borderColor, width: 1),
            ),
            child: PrismText.labelMedium(label, color: color),
          ),
        ),
      ),
    );
  }
}
