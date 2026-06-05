import 'package:flutter/material.dart';
import '../tokens/tokens.dart';
import '../atoms/atoms.dart';

/// ASW Observatory Molecule - Metric Tile
/// 
/// Displays a numeric metric with label and optional trend
class DSMetricTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final Color? color;
  final String? subtitle;
  final DSTrend? trend;
  final VoidCallback? onTap;

  const DSMetricTile({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.color,
    this.subtitle,
    this.trend,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = color ?? DSColors.accentCyan;
    
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
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
              
              // Subtitle
              if (subtitle != null) ...[
                const SizedBox(height: DSSpacing.xs),
                DSText.bodySmall(
                  subtitle!,
                  color: DSColors.textTertiary,
                ),
              ],
            ],
          ),
        ),
      ),
    );
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

/// Compact version of metric tile for dashboards
class DSMetricTileCompact extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  final VoidCallback? onTap;

  const DSMetricTileCompact({
    super.key,
    required this.label,
    required this.value,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = color ?? DSColors.accentCyan;
    
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
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
              DSText.labelSmall(
                label,
                color: DSColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
