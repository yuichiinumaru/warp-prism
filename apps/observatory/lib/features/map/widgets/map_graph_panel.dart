/// Graph subview panel for the Map workspace.
///
/// Renders a mode selector bar and the [DSGraphCanvas] with the
/// current projection. The panel is a pure consumer of
/// [MapGraphProjection] — it does not compute projections itself.
library;

import 'package:flutter/material.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';
import '../graph/map_graph_mode.dart';
import '../graph/map_graph_projection.dart';

/// Displays the graph canvas with a mode-switching toolbar.
///
/// The panel receives a pre-computed [MapGraphProjection] and an
/// [onModeChanged] callback. It does not own the projection logic
/// or the workspace state — that responsibility lives in the
/// provider and projection layer.
class MapGraphPanel extends StatelessWidget {
  /// The current projection to render.
  final MapGraphProjection projection;

  /// Called when the user selects a different graph mode.
  final ValueChanged<MapGraphMode> onModeChanged;

  /// Called when a node is tapped.
  final void Function(GraphNode)? onNodeTap;

  const MapGraphPanel({
    super.key,
    required this.projection,
    required this.onModeChanged,
    this.onNodeTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Mode selector bar
        _ModeSelector(
          activeMode: projection.mode,
          onChanged: onModeChanged,
          nodeCount: projection.nodeCount,
          edgeCount: projection.edgeCount,
        ),

        // Graph canvas
        Expanded(
          child: DSGraphCanvas(
            nodes: projection.nodes,
            edges: projection.edges,
            onNodeTap: onNodeTap,
          ),
        ),
      ],
    );
  }
}

/// Horizontal chip bar for switching between graph modes.
class _ModeSelector extends StatelessWidget {
  final MapGraphMode activeMode;
  final ValueChanged<MapGraphMode> onChanged;
  final int nodeCount;
  final int edgeCount;

  const _ModeSelector({
    required this.activeMode,
    required this.onChanged,
    required this.nodeCount,
    required this.edgeCount,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Graph mode selector',
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: DSSpacing.md,
          vertical: DSSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: DSColors.obsidianElevated,
          border: Border(
            bottom: BorderSide(color: DSColors.borderSubtle, width: 1),
          ),
        ),
        child: Row(
          children: [
            // Mode chips
            for (final mode in MapGraphMode.values) ...[
              _ModeChip(
                mode: mode,
                isActive: mode == activeMode,
                onTap: () => onChanged(mode),
              ),
              if (mode != MapGraphMode.values.last)
                const SizedBox(width: DSSpacing.sm),
            ],

            const Spacer(),

            // Counts
            Semantics(
              label:
                  '$nodeCount nodes, $edgeCount edges in ${labelForMode(activeMode)} mode',
              child: DSText.labelSmall(
                '$nodeCount nodes · $edgeCount edges',
                color: DSColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A single mode chip in the selector bar.
class _ModeChip extends StatelessWidget {
  final MapGraphMode mode;
  final bool isActive;
  final VoidCallback onTap;

  const _ModeChip({
    required this.mode,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? DSColors.accentCyan : DSColors.textSecondary;

    return Semantics(
      label: '${labelForMode(mode)} mode${isActive ? ", active" : ""}',
      button: true,
      selected: isActive,
      child: GestureDetector(
        onTap: onTap,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: AnimatedContainer(
            duration: DSMotion.fast,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isActive
                  ? DSColors.accentCyan.withOpacity(0.15)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(DSRadii.md),
              border: Border.all(
                color: isActive
                    ? DSColors.accentCyan.withOpacity(0.4)
                    : DSColors.borderSubtle,
                width: isActive ? 1.5 : 1,
              ),
            ),
            child: DSText.labelMedium(labelForMode(mode), color: color),
          ),
        ),
      ),
    );
  }
}
