/// Overview dashboard page for the ASW Observatory.
///
/// This is the first real product page inside the shell. It composes
/// DS primitives (DSMetricTile, DSStoryPanel) to display derived
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
      padding: const EdgeInsets.all(DSSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // -- Totals section --
          DSText.headingSmall('Totals', color: DSColors.textPrimary),
          const SizedBox(height: DSSpacing.md),
          _buildTotalsGrid(context),

          const SizedBox(height: DSSpacing.xl),

          // -- Tasks by lane section --
          DSText.headingSmall('Tasks by Lane', color: DSColors.textPrimary),
          const SizedBox(height: DSSpacing.md),
          _buildLaneGrid(context),

          const SizedBox(height: DSSpacing.xl),

          // -- Operational risk section --
          DSText.headingSmall('Operational Risk', color: DSColors.textPrimary),
          const SizedBox(height: DSSpacing.md),
          _buildRiskGrid(context),

          const SizedBox(height: DSSpacing.xl),

          // -- Current story panel --
          _buildStoryPanel(context),

          const SizedBox(height: DSSpacing.lg),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Totals grid
  // ---------------------------------------------------------------------------

  Widget _buildTotalsGrid(BuildContext context) {
    return Wrap(
      spacing: DSSpacing.md,
      runSpacing: DSSpacing.md,
      children: [
        DSMetricTile(
          label: 'Agents',
          value: '${metrics.agentCount}',
          icon: Icons.smart_toy_outlined,
          color: DSColors.accentCyan,
        ),
        DSMetricTile(
          label: 'Skills',
          value: '${metrics.skillCount}',
          icon: Icons.psychology_outlined,
          color: DSColors.accentViolet,
          subtitle: '${metrics.subSkillCount} sub-skills',
        ),
        DSMetricTile(
          label: 'Workflows',
          value: '${metrics.workflowCount}',
          icon: Icons.account_tree_outlined,
          color: DSColors.accentGold,
        ),
        DSMetricTile(
          label: 'Changelog',
          value: '${metrics.changelogEntryCount}',
          icon: Icons.article_outlined,
          color: DSColors.statusInfo,
        ),
        DSMetricTile(
          label: 'Total Assets',
          value: '${metrics.totalAssets}',
          icon: Icons.inventory_2_outlined,
          color: DSColors.textSecondary,
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
        DSColors.lanePlanning,
        Icons.edit_note_outlined,
      ),
      ('Open', metrics.openTaskCount, DSColors.laneOpen, Icons.inbox_outlined),
      (
        'Doing',
        metrics.doingTaskCount,
        DSColors.laneDoing,
        Icons.play_circle_outline,
      ),
      (
        'Review',
        metrics.reviewQueueCount,
        DSColors.laneReview,
        Icons.rate_review_outlined,
      ),
      (
        'Completed',
        metrics.completedTaskCount,
        DSColors.laneCompleted,
        Icons.check_circle_outline,
      ),
    ];

    return Wrap(
      spacing: DSSpacing.md,
      runSpacing: DSSpacing.md,
      children: laneData
          .map(
            (data) => DSMetricTile(
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
      spacing: DSSpacing.md,
      runSpacing: DSSpacing.md,
      children: [
        DSMetricTile(
          label: 'Active Blockers',
          value: '${metrics.activeBlockers}',
          icon: Icons.block_outlined,
          color: metrics.activeBlockers > 0
              ? DSColors.statusError
              : DSColors.statusSuccess,
          subtitle: metrics.activeBlockers > 0 ? 'Needs attention' : 'Clear',
        ),
        DSMetricTile(
          label: 'Review Queue',
          value: '${metrics.reviewQueueCount}',
          icon: Icons.queue_outlined,
          color: metrics.reviewQueueCount > 3
              ? DSColors.statusWarning
              : DSColors.accentCyan,
          subtitle: metrics.reviewQueueCount > 3 ? 'High pressure' : 'Normal',
        ),
        DSMetricTile(
          label: 'Gov Warnings',
          value: '${metrics.governanceWarningCount}',
          icon: Icons.warning_amber_outlined,
          color: metrics.governanceWarningCount > 0
              ? DSColors.statusWarning
              : DSColors.statusSuccess,
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
          (insight) => DSStoryInsight(
            text: insight.text,
            detail: insight.detail,
            value: insight.value,
            color: _severityColor(insight.severity),
          ),
        )
        .toList();

    return DSStoryPanel(
      title: 'Current Story',
      subtitle: metrics.currentStoryTitle,
      icon: Icons.auto_stories_outlined,
      accentColor: DSColors.accentCyan,
      insights: insights,
      footer: DSText.bodySmall(
        'Based on ${metrics.totalAssets} assets · ${metrics.totalEdges} edges',
        color: DSColors.textTertiary,
      ),
    );
  }

  Color _severityColor(OverviewInsightSeverity severity) {
    switch (severity) {
      case OverviewInsightSeverity.info:
        return DSColors.accentCyan;
      case OverviewInsightSeverity.positive:
        return DSColors.statusSuccess;
      case OverviewInsightSeverity.warning:
        return DSColors.statusWarning;
      case OverviewInsightSeverity.critical:
        return DSColors.statusError;
    }
  }
}
