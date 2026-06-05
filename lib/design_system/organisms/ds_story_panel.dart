import 'package:flutter/material.dart';
import '../tokens/tokens.dart';
import '../atoms/atoms.dart';

/// ASW Observatory Organism - Story Panel
/// 
/// Narrative panel for data storytelling
class DSStoryPanel extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Color? accentColor;
  final List<DSStoryInsight> insights;
  final Widget? footer;

  const DSStoryPanel({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.accentColor,
    required this.insights,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? DSColors.accentCyan;
    
    return DSGlassPanel.elevated(
      padding: const EdgeInsets.all(DSSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            children: [
              if (icon != null) ...[
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(DSRadii.md),
                  ),
                  child: DSIcon(icon!, color: color),
                ),
                const SizedBox(width: DSSpacing.md),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DSText.headingSmall(title),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      DSText.bodySmall(
                        subtitle!,
                        color: DSColors.textSecondary,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: DSSpacing.lg),
          const DSDivider.subtle(),
          const SizedBox(height: DSSpacing.lg),
          
          // Insights
          ...insights.map((insight) => Padding(
            padding: const EdgeInsets.only(bottom: DSSpacing.md),
            child: _InsightRow(insight: insight),
          )),
          
          // Footer
          if (footer != null) ...[
            const SizedBox(height: DSSpacing.sm),
            footer!,
          ],
        ],
      ),
    );
  }
}

class _InsightRow extends StatelessWidget {
  final DSStoryInsight insight;

  const _InsightRow({required this.insight});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Indicator
        Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.only(top: 6),
          decoration: BoxDecoration(
            color: insight.color ?? DSColors.accentCyan,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: DSSpacing.sm),
        
        // Content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DSText.bodyMedium(insight.text),
              if (insight.detail != null) ...[
                const SizedBox(height: 2),
                DSText.bodySmall(
                  insight.detail!,
                  color: DSColors.textTertiary,
                ),
              ],
            ],
          ),
        ),
        
        // Value
        if (insight.value != null) ...[
          const SizedBox(width: DSSpacing.sm),
          DSText(
            insight.value!,
            variant: DSTextVariant.numericMedium,
            color: insight.color ?? DSColors.accentCyan,
          ),
        ],
      ],
    );
  }
}

class DSStoryInsight {
  final String text;
  final String? detail;
  final String? value;
  final Color? color;

  const DSStoryInsight({
    required this.text,
    this.detail,
    this.value,
    this.color,
  });
}

/// Quick story card for dashboard highlights
class DSStoryCardQuick extends StatelessWidget {
  final String title;
  final String value;
  final String? trend;
  final Color? color;
  final IconData? icon;
  final VoidCallback? onTap;

  const DSStoryCardQuick({
    super.key,
    required this.title,
    required this.value,
    this.trend,
    this.color,
    this.icon,
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
          padding: const EdgeInsets.all(DSSpacing.md),
          borderColor: accentColor.withOpacity(0.2),
          child: Row(
            children: [
              if (icon != null) ...[
                DSIcon(icon!, color: accentColor, iconSize: DSIconSize.large),
                const SizedBox(width: DSSpacing.md),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DSText.labelSmall(
                      title,
                      color: DSColors.textSecondary,
                    ),
                    const SizedBox(height: 2),
                    DSText(
                      value,
                      variant: DSTextVariant.numericMedium,
                      color: accentColor,
                    ),
                  ],
                ),
              ),
              if (trend != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(DSRadii.sm),
                  ),
                  child: DSText.labelSmall(trend!, color: accentColor),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
