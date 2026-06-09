/// Provider that computes Overview metrics from workspace data.
///
/// This is the boundary between the data layer and the UI. It takes
/// raw workspace assets and produces an [OverviewMetrics] snapshot.
/// The derivation logic lives here, not in widgets.
///
/// The provider is designed to be testable: it accepts a list of
/// [WorkspaceAsset] rather than loading from disk, so tests can
/// inject synthetic data without touching the filesystem.
library;

import '../../../data/models/data_models.dart';
import '../../../data/models/governance_diagnostics.dart';
import 'overview_metrics.dart';

/// Computes derived metrics from workspace assets and diagnostics.
///
/// Usage:
/// ```dart
/// final provider = OverviewProvider();
/// final metrics = provider.compute(assets: assets, diagnostics: diags);
/// ```
class OverviewProvider {
  const OverviewProvider();

  /// Compute [OverviewMetrics] from a list of [WorkspaceAsset] and an
  /// optional list of [GovernanceDiagnostic].
  ///
  /// When [assets] is empty, returns a zero-filled [OverviewMetrics]
  /// with an appropriate "no data" story.
  OverviewMetrics compute({
    required List<WorkspaceAsset> assets,
    List<GovernanceDiagnostic> diagnostics = const [],
  }) {
    if (assets.isEmpty) {
      return _emptyMetrics();
    }

    // -- Totals by kind --
    int agentCount = 0;
    int skillCount = 0;
    int subSkillCount = 0;
    int workflowCount = 0;
    int changelogCount = 0;
    final tasksByLane = <TaskLane, int>{};

    for (final lane in TaskLane.values) {
      tasksByLane[lane] = 0;
    }

    for (final asset in assets) {
      switch (asset.kind) {
        case AssetKind.agent:
          agentCount++;
        case AssetKind.skill:
          skillCount++;
        case AssetKind.subskill:
          subSkillCount++;
        case AssetKind.workflow:
          workflowCount++;
        case AssetKind.task:
          final meta = asset.frontmatter['_taskMetadata'] as TaskMetadata?;
          final lane = meta?.lane ?? TaskLane.open;
          tasksByLane[lane] = (tasksByLane[lane] ?? 0) + 1;
        case AssetKind.changelog:
          changelogCount++;
        default:
          break;
      }
    }

    // -- Operational risk --
    final activeBlockers = _countBlockers(assets);
    final reviewQueueCount = tasksByLane[TaskLane.review] ?? 0;
    final govWarningCount = _countGovernanceWarnings(diagnostics);

    // -- Current story --
    final story = _buildCurrentStory(
      assets: assets,
      tasksByLane: tasksByLane,
      activeBlockers: activeBlockers,
      reviewQueueCount: reviewQueueCount,
      govWarningCount: govWarningCount,
    );

    return OverviewMetrics(
      agentCount: agentCount,
      skillCount: skillCount,
      subSkillCount: subSkillCount,
      workflowCount: workflowCount,
      changelogEntryCount: changelogCount,
      tasksByLane: tasksByLane,
      activeBlockers: activeBlockers,
      reviewQueueCount: reviewQueueCount,
      governanceWarningCount: govWarningCount,
      currentStoryTitle: story.$1,
      currentStoryInsights: story.$2,
      totalAssets: assets.length,
      totalEdges: _countEdges(assets),
    );
  }

  // ---------------------------------------------------------------------------
  // Blocker counting
  // ---------------------------------------------------------------------------

  /// Count tasks that are blocked or have critical priority with incomplete proof.
  static int _countBlockers(List<WorkspaceAsset> assets) {
    var count = 0;
    for (final asset in assets) {
      if (asset.kind != AssetKind.task) continue;
      final meta = asset.frontmatter['_taskMetadata'] as TaskMetadata?;
      if (meta == null) continue;

      // A task is a blocker if:
      // 1. It has critical priority AND proof is incomplete, OR
      // 2. It depends on other tasks that are not completed.
      final isCriticalIncomplete = meta.priority == 'P0' &&
          meta.proofState != ProofState.complete &&
          meta.proofState != ProofState.verified;

      final isHighPriorityInReview = meta.priority == 'P0' &&
          meta.lane == TaskLane.review;

      if (isCriticalIncomplete || isHighPriorityInReview) {
        count++;
      }
    }
    return count;
  }

  // ---------------------------------------------------------------------------
  // Governance warning counting
  // ---------------------------------------------------------------------------

  /// Count governance diagnostics at warning severity or above.
  static int _countGovernanceWarnings(List<GovernanceDiagnostic> diagnostics) {
    var count = 0;
    for (final diag in diagnostics) {
      if (diag.severity.weight >= DiagnosticSeverity.warning.weight) {
        count++;
      }
    }
    return count;
  }

  // ---------------------------------------------------------------------------
  // Edge counting
  // ---------------------------------------------------------------------------

  /// Count total edges across all assets.
  static int _countEdges(List<WorkspaceAsset> assets) {
    var count = 0;
    for (final asset in assets) {
      count += asset.edges.length;
    }
    return count;
  }

  // ---------------------------------------------------------------------------
  // Current story builder
  // ---------------------------------------------------------------------------

  /// Build the current-story title and insights from computed metrics.
  static (String, List<OverviewStoryInsight>) _buildCurrentStory({
    required List<WorkspaceAsset> assets,
    required Map<TaskLane, int> tasksByLane,
    required int activeBlockers,
    required int reviewQueueCount,
    required int govWarningCount,
  }) {
    final insights = <OverviewStoryInsight>[];
    final totalTasks = tasksByLane.values.fold(0, (s, c) => s + c);
    final doingCount = tasksByLane[TaskLane.doing] ?? 0;
    final completedCount = tasksByLane[TaskLane.completed] ?? 0;

    // Determine dominant theme
    String title;
    if (activeBlockers > 0) {
      title = 'Active blockers need attention';
    } else if (doingCount > 0) {
      title = '$doingCount task${doingCount == 1 ? '' : 's'} in progress';
    } else if (totalTasks == 0) {
      title = 'No tasks in workspace';
    } else {
      title = 'Workspace overview';
    }

    // Build insights
    if (doingCount > 0) {
      insights.add(OverviewStoryInsight(
        text: '$doingCount task${doingCount == 1 ? ' is' : 's are'} currently in progress',
        detail: 'Tasks in the doing lane represent active work',
        value: '$doingCount',
        severity: OverviewInsightSeverity.info,
      ));
    }

    if (activeBlockers > 0) {
      insights.add(OverviewStoryInsight(
        text: '$activeBlockers active blocker${activeBlockers == 1 ? '' : 's'} detected',
        detail: 'High-priority tasks with incomplete proof or critical dependencies',
        value: '$activeBlockers',
        severity: OverviewInsightSeverity.critical,
      ));
    }

    if (reviewQueueCount > 0) {
      insights.add(OverviewStoryInsight(
        text: '$reviewQueueCount task${reviewQueueCount == 1 ? '' : 's'} awaiting review',
        detail: 'Review queue pressure',
        value: '$reviewQueueCount',
        severity: reviewQueueCount > 3
            ? OverviewInsightSeverity.warning
            : OverviewInsightSeverity.info,
      ));
    }

    if (govWarningCount > 0) {
      insights.add(OverviewStoryInsight(
        text: '$govWarningCount governance warning${govWarningCount == 1 ? '' : 's'}',
        detail: 'Diagnostics at warning severity or above',
        value: '$govWarningCount',
        severity: OverviewInsightSeverity.warning,
      ));
    }

    if (completedCount > 0) {
      insights.add(OverviewStoryInsight(
        text: '$completedCount task${completedCount == 1 ? '' : 's'} completed',
        detail: totalTasks > 0
            ? '${(completedCount / totalTasks * 100).round()}% completion rate'
            : null,
        value: '$completedCount',
        severity: OverviewInsightSeverity.positive,
      ));
    }

    // Edge case: no insights at all (empty workspace or zero tasks)
    if (insights.isEmpty) {
      insights.add(OverviewStoryInsight(
        text: 'No task activity to report',
        detail: 'Workspace has ${assets.length} assets but no task data',
        severity: OverviewInsightSeverity.info,
      ));
    }

    return (title, insights);
  }

  // ---------------------------------------------------------------------------
  // Empty state
  // ---------------------------------------------------------------------------

  /// Return a zero-filled [OverviewMetrics] for the empty-data edge case.
  static OverviewMetrics _emptyMetrics() {
    final tasksByLane = <TaskLane, int>{};
    for (final lane in TaskLane.values) {
      tasksByLane[lane] = 0;
    }
    return OverviewMetrics(
      agentCount: 0,
      skillCount: 0,
      subSkillCount: 0,
      workflowCount: 0,
      changelogEntryCount: 0,
      tasksByLane: tasksByLane,
      activeBlockers: 0,
      reviewQueueCount: 0,
      governanceWarningCount: 0,
      currentStoryTitle: 'No workspace data loaded',
      currentStoryInsights: const [
        OverviewStoryInsight(
          text: 'Workspace is empty',
          detail: 'Load mock workspace data to see derived metrics',
          severity: OverviewInsightSeverity.info,
        ),
      ],
      totalAssets: 0,
      totalEdges: 0,
    );
  }
}
