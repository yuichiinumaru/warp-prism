import 'package:flutter/material.dart';

import '../../atoms/ds_badge.dart';
import '../../atoms/ds_icon.dart';
import '../../atoms/ds_text.dart';
import '../../molecules/ds_metric_tile.dart';
import '../../tokens/tokens.dart';
import 'ds_floating_analytics_hud.dart';

/// Chrome header: drag handle, title drag target, minimize, optional close.
///
/// Package-private composition widget for [DSFloatingAnalyticsHud].
class FloatingAnalyticsHudHeader extends StatelessWidget {
  final String title;
  final int sectionCount;
  final bool minimized;
  final bool showClose;
  final GestureDragUpdateCallback onPanUpdate;
  final VoidCallback onToggleMinimized;
  final VoidCallback onClose;

  const FloatingAnalyticsHudHeader({
    super.key,
    required this.title,
    required this.sectionCount,
    required this.minimized,
    required this.showClose,
    required this.onPanUpdate,
    required this.onToggleMinimized,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    const minTouch = DSFloatingAnalyticsHud.minInteractiveSize;

    return Row(
      children: [
        // Drag handle — primary reposition affordance (desktop pointer first).
        MouseRegion(
          cursor: SystemMouseCursors.move,
          child: GestureDetector(
            key: DSFloatingAnalyticsHud.dragHandleKey,
            behavior: HitTestBehavior.opaque,
            onPanUpdate: onPanUpdate,
            child: Semantics(
              label: DSFloatingAnalyticsHud.dragSemanticLabel(),
              child: const SizedBox(
                width: DSFloatingAnalyticsHud.minInteractiveSize,
                height: DSFloatingAnalyticsHud.minInteractiveSize,
                child: Center(
                  child: DSIcon(
                    Icons.drag_indicator,
                    size: 18,
                    color: DSColors.textTertiary,
                  ),
                ),
              ),
            ),
          ),
        ),
        // Title also drags for a larger grab target (labeled for a11y).
        Expanded(
          child: MouseRegion(
            cursor: SystemMouseCursors.move,
            child: GestureDetector(
              key: DSFloatingAnalyticsHud.titleDragKey,
              behavior: HitTestBehavior.opaque,
              onPanUpdate: onPanUpdate,
              child: Semantics(
                label: DSFloatingAnalyticsHud.dragSemanticLabel(),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    minHeight: DSFloatingAnalyticsHud.minInteractiveSize,
                  ),
                  child: Row(
                    children: [
                      const DSIcon(
                        Icons.analytics_outlined,
                        size: 16,
                        color: DSColors.accentCyan,
                      ),
                      const SizedBox(width: DSSpacing.xs),
                      Expanded(
                        child: DSText.labelLarge(
                          title,
                          color: DSColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        DSBadge.count(
          sectionCount,
          size: DSBadgeSize.small,
          color: DSColors.accentCyan,
        ),
        const SizedBox(width: DSSpacing.xs),
        Semantics(
          button: true,
          label: DSFloatingAnalyticsHud.minimizeSemanticLabel(
            minimized: minimized,
          ),
          child: IconButton(
            key: DSFloatingAnalyticsHud.minimizeToggleKey,
            tooltip: DSFloatingAnalyticsHud.minimizeSemanticLabel(
              minimized: minimized,
            ),
            iconSize: 18,
            visualDensity: VisualDensity.standard,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: minTouch,
              minHeight: minTouch,
            ),
            onPressed: onToggleMinimized,
            icon: Icon(
              minimized ? Icons.open_in_full : Icons.remove,
              color: DSColors.textSecondary,
            ),
          ),
        ),
        if (showClose)
          Semantics(
            button: true,
            label: DSFloatingAnalyticsHud.closeSemanticLabel(),
            child: IconButton(
              key: DSFloatingAnalyticsHud.closeButtonKey,
              tooltip: DSFloatingAnalyticsHud.closeSemanticLabel(),
              iconSize: 18,
              visualDensity: VisualDensity.standard,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(
                minWidth: minTouch,
                minHeight: minTouch,
              ),
              onPressed: onClose,
              icon: const Icon(Icons.close, color: DSColors.textSecondary),
            ),
          ),
      ],
    );
  }
}

/// Scrollable multi-section metrics body for the expanded HUD.
class FloatingAnalyticsHudSections extends StatelessWidget {
  final List<DSFloatingAnalyticsSection> sections;
  final bool compactMetrics;

  const FloatingAnalyticsHudSections({
    super.key,
    required this.sections,
    required this.compactMetrics,
  });

  @override
  Widget build(BuildContext context) {
    if (sections.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(DSSpacing.md),
        child: DSText.bodySmall(
          'No analytics sections',
          color: DSColors.textTertiary,
        ),
      );
    }

    return KeyedSubtree(
      key: DSFloatingAnalyticsHud.sectionsListKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < sections.length; i++) ...[
              if (i > 0) const SizedBox(height: DSSpacing.md),
              FloatingAnalyticsHudSectionBlock(
                section: sections[i],
                compactMetrics: compactMetrics,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// One analytics section title + metric tiles.
class FloatingAnalyticsHudSectionBlock extends StatelessWidget {
  final DSFloatingAnalyticsSection section;
  final bool compactMetrics;

  const FloatingAnalyticsHudSectionBlock({
    super.key,
    required this.section,
    required this.compactMetrics,
  });

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: DSFloatingAnalyticsHud.sectionKey(section.id),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: DSText.labelMedium(
                  section.title,
                  color: DSColors.textSecondary,
                ),
              ),
              if (section.badge != null && section.badge!.isNotEmpty)
                DSBadge(
                  label: section.badge!,
                  size: DSBadgeSize.small,
                  color: DSColors.accentViolet,
                ),
            ],
          ),
          const SizedBox(height: DSSpacing.xs),
          if (compactMetrics)
            Wrap(
              spacing: DSSpacing.xs,
              runSpacing: DSSpacing.xs,
              children: [
                for (final metric in section.metrics)
                  KeyedSubtree(
                    key: DSFloatingAnalyticsHud.metricKey(
                      section.id,
                      metric.id,
                    ),
                    child: DSMetricTileCompact(
                      label: metric.label,
                      value: metric.value,
                      color: metric.color,
                      health: metric.health,
                    ),
                  ),
              ],
            )
          else
            Column(
              children: [
                for (final metric in section.metrics) ...[
                  KeyedSubtree(
                    key: DSFloatingAnalyticsHud.metricKey(
                      section.id,
                      metric.id,
                    ),
                    child: DSMetricTile(
                      label: metric.label,
                      value: metric.value,
                      icon: metric.icon,
                      color: metric.color,
                      subtitle: metric.subtitle,
                      trend: metric.trend,
                      health: metric.health,
                    ),
                  ),
                  const SizedBox(height: DSSpacing.xs),
                ],
              ],
            ),
        ],
      ),
    );
  }
}
