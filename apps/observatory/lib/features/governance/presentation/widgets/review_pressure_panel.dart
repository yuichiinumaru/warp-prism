/// Review pressure panel for Governance analytics.
///
/// Calculates and renders review-queue pressure indicators from
/// lane/status diagnostics. Uses the same lane vocabulary as
/// the Operate surface for consistency.
library;

import 'package:flutter/material.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';
import 'package:warp_prism_observatory/data/models/governance_diagnostics.dart';

/// Review pressure indicator derived from diagnostics.
@immutable
class ReviewPressureIndicator {
  final String assetId;
  final String taskTitle;
  final String lane;
  final DiagnosticSeverity severity;
  final String explanation;

  const ReviewPressureIndicator({
    required this.assetId,
    required this.taskTitle,
    required this.lane,
    required this.severity,
    required this.explanation,
  });

  /// Extract review-pressure indicators from diagnostics.
  ///
  /// Prefers dedicated [DiagnosticCategory.reviewPressure] emissions
  /// (elevated-priority review-lane tasks). Also includes proof-gap
  /// diagnostics in review/completed lanes, which historically modeled
  /// "moved forward without proof" pressure for the same panel.
  static List<ReviewPressureIndicator> fromDiagnostics(
    List<GovernanceDiagnostic> diagnostics,
  ) {
    final indicators = <ReviewPressureIndicator>[];

    for (final d in diagnostics) {
      final isReviewPressure = d.category == DiagnosticCategory.reviewPressure;
      final isProofGapPressure = d.category == DiagnosticCategory.proofGap;
      if (!isReviewPressure && !isProofGapPressure) continue;

      final ctx = d.context;
      final lane = ctx['taskLane']?.toString() ?? 'unknown';
      final title = ctx['taskTitle']?.toString() ?? d.assetId;
      final priority = ctx['priority']?.toString();

      final String explanation;
      if (isReviewPressure) {
        explanation = priority == null
            ? 'Task "$title" is in $lane under review pressure.'
            : 'Task "$title" is in $lane with elevated priority $priority. '
                  'Queue pressure requires reviewer attention.';
      } else if (d.severity == DiagnosticSeverity.error) {
        explanation =
            'Task "$title" is in $lane with zero proof. '
            'This creates review pressure because the task cannot '
            'be verified before progressing further.';
      } else {
        explanation =
            'Task "$title" is in $lane with only partial proof. '
            'Reviewers must determine if the available evidence '
            'is sufficient for advancement.';
      }

      indicators.add(
        ReviewPressureIndicator(
          assetId: d.assetId,
          taskTitle: title,
          lane: lane,
          severity: d.severity,
          explanation: explanation,
        ),
      );
    }

    return indicators
      ..sort((a, b) => b.severity.weight.compareTo(a.severity.weight));
  }
}

/// Summary of review queue pressure across all lanes.
@immutable
class ReviewPressureSummary {
  final int totalUnderPressure;
  final int errorCount;
  final int warningCount;
  final Map<String, int> pressureByLane;

  const ReviewPressureSummary({
    required this.totalUnderPressure,
    required this.errorCount,
    required this.warningCount,
    required this.pressureByLane,
  });

  factory ReviewPressureSummary.fromIndicators(
    List<ReviewPressureIndicator> indicators,
  ) {
    final byLane = <String, int>{};
    var errors = 0;
    var warnings = 0;

    for (final ind in indicators) {
      byLane[ind.lane] = (byLane[ind.lane] ?? 0) + 1;
      if (ind.severity == DiagnosticSeverity.error) {
        errors++;
      } else {
        warnings++;
      }
    }

    return ReviewPressureSummary(
      totalUnderPressure: indicators.length,
      errorCount: errors,
      warningCount: warnings,
      pressureByLane: byLane,
    );
  }

  /// Explanation of overall queue pressure state.
  String get overviewExplanation {
    if (totalUnderPressure == 0) {
      return 'No review pressure detected. All tasks have sufficient proof '
          'for their current lane position.';
    }
    return '$totalUnderPressure task${totalUnderPressure == 1 ? '' : 's'} '
        'creating review pressure across ${pressureByLane.length} '
        'lane${pressureByLane.length == 1 ? '' : 's'}. '
        'Tasks advancing without proof accumulate review debt and '
        'risk undermining verification integrity.';
  }
}

/// Renders review queue pressure as a panel.
///
/// Shows lane-level pressure summary and individual task indicators.
/// Uses the same lane vocabulary as the Operate surface.
class ReviewPressurePanel extends StatelessWidget {
  final List<ReviewPressureIndicator> indicators;
  final ReviewPressureSummary summary;

  ReviewPressurePanel({
    super.key,
    required this.indicators,
    ReviewPressureSummary? summary,
  }) : summary = summary ?? ReviewPressureSummary.fromIndicators(indicators);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: PrismColors.obsidianElevated,
        borderRadius: BorderRadius.circular(PrismRadii.lg),
        border: Border.all(color: PrismColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(PrismSpacing.lg),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: PrismColors.statusError.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(PrismRadii.md),
                  ),
                  child: const PrismIcon(
                    Icons.queue_outlined,
                    color: PrismColors.statusError,
                  ),
                ),
                const SizedBox(width: PrismSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const PrismText.headingSmall('Review Queue Pressure'),
                      const SizedBox(height: 2),
                      PrismText.bodySmall(
                        summary.overviewExplanation,
                        color: PrismColors.textSecondary,
                      ),
                    ],
                  ),
                ),
                if (indicators.isNotEmpty)
                  _PressureBadge(
                    total: summary.totalUnderPressure,
                    errors: summary.errorCount,
                  ),
              ],
            ),
          ),
          const PrismDivider.subtle(),
          if (summary.pressureByLane.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(
                PrismSpacing.lg,
                PrismSpacing.sm,
                PrismSpacing.lg,
                0,
              ),
              child: Wrap(
                spacing: PrismSpacing.md,
                runSpacing: PrismSpacing.xs,
                children: summary.pressureByLane.entries
                    .map(
                      (entry) => _LaneChip(lane: entry.key, count: entry.value),
                    )
                    .toList(),
              ),
            ),
          ],
          if (indicators.isEmpty)
            _buildHealthyState()
          else
            ...indicators.map((ind) => _PressureRow(indicator: ind)),
          const SizedBox(height: PrismSpacing.sm),
        ],
      ),
    );
  }

  Widget _buildHealthyState() {
    return const Padding(
      padding: EdgeInsets.all(PrismSpacing.lg),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 16,
            color: PrismColors.statusSuccess,
          ),
          SizedBox(width: PrismSpacing.sm),
          Expanded(
            child: PrismText.bodySmall(
              'No review pressure. All tasks have adequate proof '
              'for their lane position.',
              color: PrismColors.statusSuccess,
            ),
          ),
        ],
      ),
    );
  }
}

class _PressureBadge extends StatelessWidget {
  final int total;
  final int errors;

  const _PressureBadge({required this.total, required this.errors});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: PrismColors.statusError.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(PrismRadii.sm),
      ),
      child: PrismText.labelSmall(
        '$total under pressure',
        color: PrismColors.statusError,
      ),
    );
  }
}

class _LaneChip extends StatelessWidget {
  final String lane;
  final int count;

  const _LaneChip({required this.lane, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: PrismColors.statusWarning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(PrismRadii.sm),
        border: Border.all(
          color: PrismColors.statusWarning.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          PrismText.labelSmall(lane, color: PrismColors.statusWarning),
          const SizedBox(width: PrismSpacing.xs),
          PrismText.numeric(count.toString(), color: PrismColors.statusWarning),
        ],
      ),
    );
  }
}

class _PressureRow extends StatelessWidget {
  final ReviewPressureIndicator indicator;

  const _PressureRow({required this.indicator});

  @override
  Widget build(BuildContext context) {
    final color = indicator.severity == DiagnosticSeverity.error
        ? PrismColors.statusError
        : PrismColors.statusWarning;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: PrismSpacing.lg,
        vertical: PrismSpacing.xs,
      ),
      child: Container(
        padding: const EdgeInsets.all(PrismSpacing.sm),
        decoration: BoxDecoration(
          color: PrismColors.obsidianBase,
          borderRadius: BorderRadius.circular(PrismRadii.sm),
          border: Border(left: BorderSide(color: color, width: 3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  indicator.severity == DiagnosticSeverity.error
                      ? Icons.error_outline
                      : Icons.warning_amber_outlined,
                  size: 16,
                  color: color,
                ),
                const SizedBox(width: PrismSpacing.sm),
                Expanded(
                  child: PrismText.labelSmall(
                    indicator.taskTitle,
                    color: color,
                  ),
                ),
                PrismChip(label: indicator.lane),
              ],
            ),
            const SizedBox(height: 4),
            PrismText.bodySmall(
              indicator.explanation,
              color: PrismColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
