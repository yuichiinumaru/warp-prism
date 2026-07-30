/// Graph subview panel for the Map workspace.
///
/// Renders a mode selector bar and the [PrismGraphCanvas] with the
/// current projection. The panel is a pure consumer of
/// [MapGraphProjection] — it does not compute projections itself.
library;

import 'package:flutter/material.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';
import '../graph/map_graph_mode.dart';
import '../graph/map_graph_projection.dart';
import 'map_state_panel.dart';

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
  final void Function(PrismGraphNode)? onNodeTap;

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

        // Graph canvas, or explicit empty-edge guidance when projection has
        // no edges for the active mode.
        Expanded(
          child: projection.isEmpty
              ? const MapStatePanel(state: MapSurfaceState.graphNoEdges)
              : PrismGraphCanvas(
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
      container: true,
      explicitChildNodes: true,
      label: 'Graph mode selector',
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: PrismSpacing.md,
          vertical: PrismSpacing.sm,
        ),
        decoration: const BoxDecoration(
          color: PrismColors.obsidianElevated,
          border: Border(
            bottom: BorderSide(color: PrismColors.borderSubtle, width: 1),
          ),
        ),
        child: Wrap(
          spacing: PrismSpacing.md,
          runSpacing: PrismSpacing.sm,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Wrap(
              spacing: PrismSpacing.sm,
              runSpacing: PrismSpacing.xs,
              children: [
                for (final mode in MapGraphMode.values)
                  _ModeChip(
                    mode: mode,
                    isActive: mode == activeMode,
                    onTap: () => onChanged(mode),
                  ),
              ],
            ),
            Semantics(
              label:
                  '$nodeCount nodes, $edgeCount edges in ${labelForMode(activeMode)} mode',
              child: PrismText.labelSmall(
                '$nodeCount nodes · $edgeCount edges',
                color: PrismColors.textTertiary,
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
    final color = isActive ? PrismColors.accentCyan : PrismColors.textSecondary;

    return Semantics(
      label: '${labelForMode(mode)} mode${isActive ? ", active" : ""}',
      button: true,
      selected: isActive,
      child: FocusableActionDetector(
        actions: <Type, Action<Intent>>{
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              onTap();
              return null;
            },
          ),
        },
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              child: AnimatedContainer(
                duration: PrismMotion.fast,
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isActive
                      ? PrismColors.accentCyan.withValues(alpha: 0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(PrismRadii.md),
                  border: Border.all(
                    color: isActive
                        ? PrismColors.accentCyan.withValues(alpha: 0.4)
                        : PrismColors.borderSubtle,
                    width: isActive ? 1.5 : 1,
                  ),
                ),
                child: PrismText.labelMedium(labelForMode(mode), color: color),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
