/// Overview dashboard page for the ASW Observatory.
///
/// This is the first real product page inside the shell. It composes
/// Prism primitives (PrismMetricTile, PrismStoryPanel) to display derived
/// metrics from workspace data — not hardcoded widget literals.
///
/// The page receives pre-computed [OverviewMetrics] and renders them.
/// Derivation logic lives in [OverviewProvider], not here.
library;

import 'package:flutter/material.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';
import 'package:warp_prism_observatory/data/models/data_models.dart';
import 'overview_metrics.dart';

/// Overview dashboard page.
///
/// Renders metric tiles for totals and operational risk, plus a
/// current-story panel. All values come from [OverviewMetrics],
/// which is computed by [OverviewProvider] from workspace data.
class OverviewPage extends StatelessWidget {
  /// Pre-computed metrics to display.
  final OverviewMetrics metrics;

  const OverviewPage({super.key, required this.metrics});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(PrismSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // -- Totals section --
          const PrismText.headingSmall(
            'Totals',
            color: PrismColors.textPrimary,
          ),
          const SizedBox(height: PrismSpacing.md),
          _buildTotalsGrid(context),

          const SizedBox(height: PrismSpacing.xl),

          // -- Tasks by lane section --
          const PrismText.headingSmall(
            'Tasks by Lane',
            color: PrismColors.textPrimary,
          ),
          const SizedBox(height: PrismSpacing.md),
          _buildLaneGrid(context),

          const SizedBox(height: PrismSpacing.xl),

          // -- Operational risk section --
          const PrismText.headingSmall(
            'Operational Risk',
            color: PrismColors.textPrimary,
          ),
          const SizedBox(height: PrismSpacing.md),
          _buildRiskGrid(context),

          const SizedBox(height: PrismSpacing.xl),

          // -- Current story panel --
          _buildStoryPanel(context),

          const SizedBox(height: PrismSpacing.lg),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Totals grid
  // ---------------------------------------------------------------------------

  Widget _buildTotalsGrid(BuildContext context) {
    return Wrap(
      spacing: PrismSpacing.md,
      runSpacing: PrismSpacing.md,
      children: [
        PrismMetricTile(
          label: 'Agents',
          value: '${metrics.agentCount}',
          icon: Icons.smart_toy_outlined,
          color: PrismColors.accentCyan,
        ),
        PrismMetricTile(
          label: 'Skills',
          value: '${metrics.skillCount}',
          icon: Icons.psychology_outlined,
          color: PrismColors.accentViolet,
          subtitle: '${metrics.subSkillCount} sub-skills',
        ),
        PrismMetricTile(
          label: 'Workflows',
          value: '${metrics.workflowCount}',
          icon: Icons.account_tree_outlined,
          color: PrismColors.accentGold,
        ),
        PrismMetricTile(
          label: 'Changelog',
          value: '${metrics.changelogEntryCount}',
          icon: Icons.article_outlined,
          color: PrismColors.statusInfo,
        ),
        PrismMetricTile(
          label: 'Total Assets',
          value: '${metrics.totalAssets}',
          icon: Icons.inventory_2_outlined,
          color: PrismColors.textSecondary,
          subtitle: '${metrics.totalEdges} edges',
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Tasks by lane grid
  // ---------------------------------------------------------------------------

  Widget _buildLaneGrid(BuildContext context) {
    final laneData = [
      (
        'Planning',
        metrics.tasksByLane[TaskLane.planning] ?? 0,
        PrismColors.lanePlanning,
        Icons.edit_note_outlined,
      ),
      (
        'Open',
        metrics.openTaskCount,
        PrismColors.laneOpen,
        Icons.inbox_outlined,
      ),
      (
        'Doing',
        metrics.doingTaskCount,
        PrismColors.laneDoing,
        Icons.play_circle_outline,
      ),
      (
        'Review',
        metrics.reviewQueueCount,
        PrismColors.laneReview,
        Icons.rate_review_outlined,
      ),
      (
        'Completed',
        metrics.completedTaskCount,
        PrismColors.laneCompleted,
        Icons.check_circle_outline,
      ),
    ];

    return Wrap(
      spacing: PrismSpacing.md,
      runSpacing: PrismSpacing.md,
      children: laneData
          .map(
            (data) => PrismMetricTile(
              label: data.$1,
              value: '${data.$2}',
              icon: data.$4,
              color: data.$3,
            ),
          )
          .toList(),
    );
  }

  // ---------------------------------------------------------------------------
  // Operational risk grid
  // ---------------------------------------------------------------------------

  Widget _buildRiskGrid(BuildContext context) {
    return Wrap(
      spacing: PrismSpacing.md,
      runSpacing: PrismSpacing.md,
      children: [
        PrismMetricTile(
          label: 'Active Blockers',
          value: '${metrics.activeBlockers}',
          icon: Icons.block_outlined,
          color: metrics.activeBlockers > 0
              ? PrismColors.statusError
              : PrismColors.statusSuccess,
          subtitle: metrics.activeBlockers > 0 ? 'Needs attention' : 'Clear',
        ),
        PrismMetricTile(
          label: 'Review Queue',
          value: '${metrics.reviewQueueCount}',
          icon: Icons.queue_outlined,
          color: metrics.reviewQueueCount > 3
              ? PrismColors.statusWarning
              : PrismColors.accentCyan,
          subtitle: metrics.reviewQueueCount > 3 ? 'High pressure' : 'Normal',
        ),
        PrismMetricTile(
          label: 'Gov Warnings',
          value: '${metrics.governanceWarningCount}',
          icon: Icons.warning_amber_outlined,
          color: metrics.governanceWarningCount > 0
              ? PrismColors.statusWarning
              : PrismColors.statusSuccess,
          subtitle: metrics.governanceWarningCount > 0
              ? 'Diagnostics flagged'
              : 'Healthy',
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Current story panel
  // ---------------------------------------------------------------------------

  Widget _buildStoryPanel(BuildContext context) {
    final insights = metrics.currentStoryInsights
        .map(
          (insight) => PrismStoryInsight(
            text: insight.text,
            detail: insight.detail,
            value: insight.value,
            color: _severityColor(insight.severity),
          ),
        )
        .toList();

    return PrismStoryPanel(
      title: 'Current Story',
      subtitle: metrics.currentStoryTitle,
      icon: Icons.auto_stories_outlined,
      accentColor: PrismColors.accentCyan,
      insights: insights,
      footer: PrismText.bodySmall(
        'Based on ${metrics.totalAssets} assets · ${metrics.totalEdges} edges',
        color: PrismColors.textTertiary,
      ),
    );
  }

  Color _severityColor(OverviewInsightSeverity severity) {
    switch (severity) {
      case OverviewInsightSeverity.info:
        return PrismColors.accentCyan;
      case OverviewInsightSeverity.positive:
        return PrismColors.statusSuccess;
      case OverviewInsightSeverity.warning:
        return PrismColors.statusWarning;
      case OverviewInsightSeverity.critical:
        return PrismColors.statusError;
    }
  }
}
