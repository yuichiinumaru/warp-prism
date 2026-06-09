/// Workspace graph visualization panel.
///
/// Renders the workspace asset graph using [DSGraphCanvas] with mode
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
  const WorkspaceGraphPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(graphModeProvider);
    final projection = ref.watch(graphProjectionProvider);

    // Convert provider GraphNode/GraphEdge to DS GraphNode/GraphEdge
    final dsNodes = projection.nodes.map((n) => GraphNode(
      id: n.id,
      label: n.label,
      type: n.type,
      status: n.status,
    )).toList();

    final dsEdges = projection.edges.map((e) => GraphEdge(
      sourceId: e.sourceId,
      targetId: e.targetId,
      edgeType: e.edgeType,
    )).toList();

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
        const SizedBox(height: DSSpacing.sm),
        // Node/edge counts
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: DSSpacing.sm),
          child: Row(
            children: [
              DSText.labelSmall(
                '${dsNodes.length} nodes',
                color: DSColors.textTertiary,
              ),
              const SizedBox(width: DSSpacing.md),
              DSText.labelSmall(
                '${dsEdges.length} edges',
                color: DSColors.textTertiary,
              ),
            ],
          ),
        ),
        const SizedBox(height: DSSpacing.sm),
        // Graph canvas
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(DSRadii.card),
            child: DSGraphCanvas(
              nodes: dsNodes,
              edges: dsEdges,
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
        DSText.labelMedium('GRAPH MODE', color: DSColors.textSecondary),
        const SizedBox(width: DSSpacing.md),
        _ModeButton(
          label: 'Containment',
          isActive: currentMode == GraphMode.containment,
          onTap: () => onModeChanged(GraphMode.containment),
          tooltip: 'skill → sub-skill → workflow',
        ),
        const SizedBox(width: DSSpacing.xs),
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
    final color = isActive ? DSColors.accentCyan : DSColors.textTertiary;
    final bgColor = isActive
        ? DSColors.accentCyan.withOpacity(0.15)
        : DSColors.obsidianElevated;
    final borderColor = isActive
        ? DSColors.accentCyan.withOpacity(0.5)
        : DSColors.borderSubtle;

    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: AnimatedContainer(
            duration: DSMotion.fast,
            padding: const EdgeInsets.symmetric(
              horizontal: DSSpacing.md,
              vertical: DSSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(DSRadii.chip),
              border: Border.all(color: borderColor, width: 1),
            ),
            child: DSText.labelMedium(label, color: color),
          ),
        ),
      ),
    );
  }
}
