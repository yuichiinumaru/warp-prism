import 'package:flutter/material.dart';
import '../tokens/tokens.dart';
import '../atoms/atoms.dart';

/// Metric Tile — displays a numeric metric with label, trend, and optional
/// health state.
///
/// The [health] parameter maps operational health states to accent colors
/// automatically. When [health] is null, the accent [color] is used.
///
/// ## Health State Matrix
///
/// | Health | Accent Color | Use Case |
/// |--------|-------------|----------|
/// | healthy (default) | Caller color or accentCyan | Normal operation |
/// | degraded | statusWarning | Partial impairment |
/// | error | statusError | Operational failure |
/// | disabled | textDisabled | Intentionally inactive |
class DSMetricTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final Color? color;
  final String? subtitle;
  final DSTrend? trend;
  final VoidCallback? onTap;

  /// Operational health state. Overrides [color] accent when set.
  final DSMetricTileHealth? health;

  const DSMetricTile({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.color,
    this.subtitle,
    this.trend,
    this.onTap,
    this.health,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = _resolveAccentColor();

    return Semantics(
      label:
          '$label: $value${health != null && health != DSMetricTileHealth.healthy ? ', ${health!.name}' : ''}',
      child: GestureDetector(
        onTap: onTap,
        child: MouseRegion(
          cursor: onTap != null
              ? SystemMouseCursors.click
              : SystemMouseCursors.basic,
          child: DSGlassPanelSimple(
            padding: const EdgeInsets.all(DSSpacing.insetCard),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  children: [
                    if (icon != null) ...[
                      DSIcon.small(icon!, color: accentColor),
                      const SizedBox(width: DSSpacing.xs),
                    ],
                    Expanded(
                      child: DSText.labelMedium(
                        label,
                        color: DSColors.textSecondary,
                      ),
                    ),
                    if (trend != null) _TrendIndicator(trend: trend!),
                  ],
                ),

                const SizedBox(height: DSSpacing.sm),

                // Value
                DSText(
                  value,
                  variant: DSTextVariant.numericLarge,
                  color: accentColor,
                ),

                // Health indicator
                if (health != null && health != DSMetricTileHealth.healthy) ...[
                  const SizedBox(height: DSSpacing.xs),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DSStatusDot(
                        color: accentColor,
                        size: 6,
                        animated: health == DSMetricTileHealth.error,
                      ),
                      const SizedBox(width: 4),
                      DSText.labelSmall(health!.label, color: accentColor),
                    ],
                  ),
                ],

                // Subtitle
                if (subtitle != null) ...[
                  const SizedBox(height: DSSpacing.xs),
                  DSText.bodySmall(subtitle!, color: DSColors.textTertiary),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _resolveAccentColor() {
    if (health != null) return health!.color;
    return color ?? DSColors.accentCyan;
  }
}

class _TrendIndicator extends StatelessWidget {
  final DSTrend trend;

  const _TrendIndicator({required this.trend});

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (trend) {
      DSTrend.up => (Icons.trending_up, DSColors.statusSuccess),
      DSTrend.down => (Icons.trending_down, DSColors.statusError),
      DSTrend.flat => (Icons.trending_flat, DSColors.textTertiary),
    };

    return Icon(icon, size: 16, color: color);
  }
}

enum DSTrend { up, down, flat }

/// Health state for metric tiles.
///
/// Maps operational health to semantic accent colors.
enum DSMetricTileHealth {
  /// Normal operation — uses caller-specified accent or accentCyan.
  healthy(DSColors.statusHealthy, 'Healthy'),

  /// Partial impairment — amber warning.
  degraded(DSColors.statusDegraded, 'Degraded'),

  /// Operational failure — error red.
  error(DSColors.statusError, 'Error'),

  /// Intentionally inactive — disabled gray.
  disabled(DSColors.statusDisabled, 'Disabled');

  final Color color;
  final String label;

  const DSMetricTileHealth(this.color, this.label);
}

/// Compact version of metric tile for dashboards.
class DSMetricTileCompact extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  final VoidCallback? onTap;

  /// Operational health state. Overrides [color] accent when set.
  final DSMetricTileHealth? health;

  const DSMetricTileCompact({
    super.key,
    required this.label,
    required this.value,
    this.color,
    this.onTap,
    this.health,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = health != null
        ? health!.color
        : (color ?? DSColors.accentCyan);

    return Semantics(
      label: '$label: $value',
      child: GestureDetector(
        onTap: onTap,
        child: MouseRegion(
          cursor: onTap != null
              ? SystemMouseCursors.click
              : SystemMouseCursors.basic,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: DSSpacing.md,
              vertical: DSSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: DSColors.obsidianElevated,
              borderRadius: BorderRadius.circular(DSRadii.card),
              border: Border.all(color: DSColors.borderSubtle, width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                DSText(
                  value,
                  variant: DSTextVariant.numericMedium,
                  color: accentColor,
                ),
                const SizedBox(width: DSSpacing.sm),
                DSText.labelSmall(label, color: DSColors.textSecondary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
