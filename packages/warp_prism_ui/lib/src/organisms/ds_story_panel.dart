import 'package:flutter/material.dart';
import '../tokens/tokens.dart';
import '../atoms/atoms.dart';
import '../molecules/molecules.dart';

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
                    color: color.withValues(alpha: 0.15),
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
          if (insights.isEmpty)
            const DSStateSurface.empty(
              icon: Icons.insights_outlined,
              title: 'No insights available',
              subtitle:
                  'Narrative insights will appear here once data is analyzed',
              compact: true,
            )
          else
            ...insights.map(
              (insight) => Padding(
                padding: const EdgeInsets.only(bottom: DSSpacing.md),
                child: _InsightRow(insight: insight),
              ),
            ),

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
    final narrative = insight is DSStoryNarrativeInsight
        ? insight as DSStoryNarrativeInsight
        : null;
    final indicatorColor =
        insight.color ??
        (narrative != null
            ? _riskColor(narrative.riskLevel)
            : DSColors.accentCyan);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Indicator
        Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.only(top: 6),
          decoration: BoxDecoration(
            color: indicatorColor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: DSSpacing.sm),

        // Content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: DSText.bodyMedium(insight.text)),
                  if (narrative != null &&
                      narrative.riskLevel != InsightRiskLevel.none) ...[
                    const SizedBox(width: DSSpacing.sm),
                    _RiskBadge(level: narrative.riskLevel),
                  ],
                ],
              ),
              if (insight.detail != null) ...[
                const SizedBox(height: 2),
                DSText.bodySmall(insight.detail!, color: DSColors.textTertiary),
              ],
              if (narrative?.evidence != null) ...[
                const SizedBox(height: 4),
                DSText.bodySmall(
                  'Evidence: ${narrative!.evidence}',
                  color: DSColors.textSecondary,
                ),
              ],
              if (narrative?.connection != null) ...[
                const SizedBox(height: 2),
                DSText.bodySmall(
                  'Connection: ${narrative!.connection}',
                  color: DSColors.textSecondary,
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
            color: indicatorColor,
          ),
        ],
      ],
    );
  }
}

class _RiskBadge extends StatelessWidget {
  final InsightRiskLevel level;

  const _RiskBadge({required this.level});

  @override
  Widget build(BuildContext context) {
    final color = _riskColor(level);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(DSRadii.sm),
      ),
      child: DSText.labelSmall(_riskLabel(level), color: color),
    );
  }
}

Color _riskColor(InsightRiskLevel level) {
  switch (level) {
    case InsightRiskLevel.none:
      return DSColors.accentCyan;
    case InsightRiskLevel.low:
      return DSColors.statusInfo;
    case InsightRiskLevel.medium:
      return DSColors.statusWarning;
    case InsightRiskLevel.high:
    case InsightRiskLevel.critical:
      return DSColors.statusError;
  }
}

String _riskLabel(InsightRiskLevel level) {
  switch (level) {
    case InsightRiskLevel.none:
      return 'none';
    case InsightRiskLevel.low:
      return 'low';
    case InsightRiskLevel.medium:
      return 'medium';
    case InsightRiskLevel.high:
      return 'high';
    case InsightRiskLevel.critical:
      return 'critical';
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

/// Risk severity for narrative insights.
///
/// Used by [DSStoryNarrativeInsight] to classify how dangerous
/// a gap, blocker, or staleness finding is.
enum InsightRiskLevel {
  /// No risk — pure informational insight.
  none,

  /// Low risk — minor gap, does not block demo flow.
  low,

  /// Medium risk — degrades experience but not a blocker.
  medium,

  /// High risk — significant gap that should be addressed before demo.
  high,

  /// Critical risk — blocks core functionality or demo flow entirely.
  critical,
}

/// Extended narrative insight with evidence, risk, and relational context.
///
/// Extends [DSStoryInsight] with three narrative layers required by the
/// EPIC 10 demo script:
/// - **Evidence**: file path or URL to verify the claim
/// - **Risk**: [InsightRiskLevel] classification of the gap/blocker
/// - **Connection**: how this insight relates to other assets or blocks
class DSStoryNarrativeInsight extends DSStoryInsight {
  /// File path, URL, or reference where this insight can be verified.
  final String? evidence;

  /// Risk severity of the gap or blocker this insight describes.
  final InsightRiskLevel riskLevel;

  /// Relational context — how this asset connects to others.
  final String? connection;

  const DSStoryNarrativeInsight({
    required super.text,
    super.detail,
    super.value,
    super.color,
    this.evidence,
    this.riskLevel = InsightRiskLevel.none,
    this.connection,
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
        cursor: onTap != null
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic,
        child: DSGlassPanelSimple(
          padding: const EdgeInsets.all(DSSpacing.md),
          borderColor: accentColor.withValues(alpha: 0.2),
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
                    DSText.labelSmall(title, color: DSColors.textSecondary),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.15),
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
