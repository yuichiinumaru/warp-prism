/// Review pressure panel for Governance analytics.
///
/// Calculates and renders review-queue pressure indicators from
/// lane/status diagnostics. Uses the same lane vocabulary as
/// the Operate surface for consistency.
library;

import 'package:flutter/material.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';
import '../../../../data/models/governance_diagnostics.dart';

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

  /// Extract review-pressure indicators from proof-gap diagnostics.
  ///
  /// Proof-gap diagnostics in review/completed lanes represent tasks
  /// that are under review pressure (they moved forward without proof).
  static List<ReviewPressureIndicator> fromDiagnostics(
    List<GovernanceDiagnostic> diagnostics,
  ) {
    final indicators = <ReviewPressureIndicator>[];

    for (final d in diagnostics) {
      if (d.category != DiagnosticCategory.proofGap) continue;

      final ctx = d.context;
      final lane = ctx['taskLane']?.toString() ?? 'unknown';
      final title = ctx['taskTitle']?.toString() ?? d.assetId;

      indicators.add(ReviewPressureIndicator(
        assetId: d.assetId,
        taskTitle: title,
        lane: lane,
        severity: d.severity,
        explanation: d.severity == DiagnosticSeverity.error
            ? 'Task "$title" is in $lane with zero proof. '
                'This creates review pressure because the task cannot '
                'be verified before progressing further.'
            : 'Task "$title" is in $lane with only partial proof. '
                'Reviewers must determine if the available evidence '
                'is sufficient for advancement.',
      ));
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
        'creating review pressure across ${pressureByLane.length} lane${pressureByLane.length == 1 ? '' : 's'}. '
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
  }) : summary = summary ??
            ReviewPressureSummary.fromIndicators(indicators);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: DSColors.obsidianElevated,
        borderRadius: BorderRadius.circular(DSRadii.lg),
        border: Border.all(color: DSColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(DSSpacing.lg),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: DSColors.statusError.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(DSRadii.md),
                  ),
                  child: DSIcon(Icons.queue_outlined, color: DSColors.statusError),
                ),
                const SizedBox(width: DSSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DSText.headingSmall('Review Queue Pressure'),
                      const SizedBox(height: 2),
                      DSText.bodySmall(
                        summary.overviewExplanation,
                        color: DSColors.textSecondary,
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

          const DSDivider.subtle(),

          // Lane breakdown (if any pressure exists)
          if (summary.pressureByLane.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(
                DSSpacing.lg,
                DSSpacing.sm,
                DSSpacing.lg,
                0,
              ),
              child: Row(
                children: summary.pressureByLane.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(right: DSSpacing.md),
                    child: _LaneChip(
                      lane: entry.key,
                      count: entry.value,
                    ),
                  );
                }).toList(),
              ),
            ),
          ],

          // Task indicators
          if (indicators.isEmpty)
            _buildHealthyState()
          else
            ...indicators.map((ind) => _PressureRow(indicator: ind)),

          const SizedBox(height: DSSpacing.sm),
        ],
      ),
    );
  }

  Widget _buildHealthyState() {
    return Padding(
      padding: const EdgeInsets.all(DSSpacing.lg),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline,
              size: 16, color: DSColors.statusSuccess),
          const SizedBox(width: DSSpacing.sm),
          Expanded(
            child: DSText.bodySmall(
              'No review pressure. All tasks have adequate proof '
              'for their lane position.',
              color: DSColors.statusSuccess,
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
        color: DSColors.statusError.withOpacity(0.15),
        borderRadius: BorderRadius.circular(DSRadii.sm),
      ),
      child: DSText.labelSmall(
        '$total under pressure',
        color: DSColors.statusError,
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
        color: DSColors.statusWarning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(DSRadii.sm),
        border: Border.all(
          color: DSColors.statusWarning.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          DSText.labelSmall(lane, color: DSColors.statusWarning),
          const SizedBox(width: DSSpacing.xs),
          DSText.numeric(count.toString(), color: DSColors.statusWarning),
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
        ? DSColors.statusError
        : DSColors.statusWarning;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.lg,
        vertical: DSSpacing.xs,
      ),
      child: Container(
        padding: const EdgeInsets.all(DSSpacing.sm),
        decoration: BoxDecoration(
          color: DSColors.obsidianBase,
          borderRadius: BorderRadius.circular(DSRadii.sm),
          border: Border(
            left: BorderSide(color: color, width: 3),
          ),
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
                const SizedBox(width: DSSpacing.sm),
                Expanded(
                  child: DSText.labelSmall(
                    indicator.taskTitle,
                    color: color,
                  ),
                ),
                DSChip(label: indicator.lane),
              ],
            ),
            const SizedBox(height: 4),
            DSText.bodySmall(
              indicator.explanation,
              color: DSColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
