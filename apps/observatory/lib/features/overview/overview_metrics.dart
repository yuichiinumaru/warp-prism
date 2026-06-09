/// Derived metrics contract for the Overview dashboard.
///
/// This is a pure data class — no Flutter dependency — that carries
/// all computed values the Overview page needs to render. The metric
/// derivation logic lives in [OverviewProvider], not in widgets.
///
/// Metrics fall into two groups:
///   1. **Totals**: agents, skills, sub-skills, workflows, tasks-by-lane,
///      changelog entries.
///   2. **Operational risk**: active blockers, review queue pressure,
///      governance warnings, current-story summary.
library;

import 'package:flutter/foundation.dart';
import '../../../data/models/data_models.dart';

/// Snapshot of all derived Overview metrics at a point in time.
///
/// The page receives one of these and renders it; the provider computes it
/// from repository/workspace data. This keeps derivation outside the widget
/// tree per the task's refactoring requirement.
@immutable
class OverviewMetrics {
  // -- Totals --
  /// Number of agents in the workspace.
  final int agentCount;

  /// Number of super-skills (top-level skill roots).
  final int skillCount;

  /// Number of sub-skills (children of super-skills).
  final int subSkillCount;

  /// Number of workflows.
  final int workflowCount;

  /// Number of changelog entries.
  final int changelogEntryCount;

  /// Task counts broken down by lane.
  final Map<TaskLane, int> tasksByLane;

  // -- Operational risk --
  /// Number of tasks that are blocked or have critical priority with
  /// proof-state below complete.
  final int activeBlockers;

  /// Number of tasks currently in the review lane.
  final int reviewQueueCount;

  /// Number of governance diagnostics at warning severity or above.
  final int governanceWarningCount;

  // -- Current story --
  /// Summary text for the current-story panel.
  final String currentStoryTitle;

  /// Bullet-point insights for the story panel.
  final List<OverviewStoryInsight> currentStoryInsights;

  // -- Workspace health --
  /// Total asset count across all kinds.
  final int totalAssets;

  /// Total edge count in the workspace graph.
  final int totalEdges;

  const OverviewMetrics({
    required this.agentCount,
    required this.skillCount,
    required this.subSkillCount,
    required this.workflowCount,
    required this.changelogEntryCount,
    required this.tasksByLane,
    required this.activeBlockers,
    required this.reviewQueueCount,
    required this.governanceWarningCount,
    required this.currentStoryTitle,
    required this.currentStoryInsights,
    required this.totalAssets,
    required this.totalEdges,
  });

  /// Total task count across all lanes.
  int get totalTaskCount =>
      tasksByLane.values.fold(0, (sum, count) => sum + count);

  /// Number of tasks currently in the doing lane.
  int get doingTaskCount => tasksByLane[TaskLane.doing] ?? 0;

  /// Number of tasks in the open (backlog) lane.
  int get openTaskCount => tasksByLane[TaskLane.open] ?? 0;

  /// Number of completed tasks.
  int get completedTaskCount => tasksByLane[TaskLane.completed] ?? 0;

  /// Whether the workspace has any data at all.
  bool get isEmpty => totalAssets == 0;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OverviewMetrics &&
          runtimeType == other.runtimeType &&
          agentCount == other.agentCount &&
          skillCount == other.skillCount &&
          subSkillCount == other.subSkillCount &&
          workflowCount == other.workflowCount &&
          changelogEntryCount == other.changelogEntryCount &&
          activeBlockers == other.activeBlockers &&
          reviewQueueCount == other.reviewQueueCount &&
          governanceWarningCount == other.governanceWarningCount &&
          totalAssets == other.totalAssets &&
          totalEdges == other.totalEdges;

  @override
  int get hashCode => Object.hash(
        agentCount,
        skillCount,
        subSkillCount,
        workflowCount,
        changelogEntryCount,
        activeBlockers,
        reviewQueueCount,
        governanceWarningCount,
        totalAssets,
        totalEdges,
      );

  @override
  String toString() =>
      'OverviewMetrics(agents:$agentCount skills:$skillCount '
      'subSkills:$subSkillCount workflows:$workflowCount '
      'tasks:$totalTaskCount changelog:$changelogEntryCount '
      'blockers:$activeBlockers review:$reviewQueueCount '
      'govWarnings:$governanceWarningCount)';
}

/// A single insight in the current-story panel.
@immutable
class OverviewStoryInsight {
  /// Brief description of what this insight means.
  final String text;

  /// Optional detail or context.
  final String? detail;

  /// Optional numeric value to display alongside.
  final String? value;

  /// Severity hint for the story panel renderer.
  final OverviewInsightSeverity severity;

  const OverviewStoryInsight({
    required this.text,
    this.detail,
    this.value,
    this.severity = OverviewInsightSeverity.info,
  });
}

/// Severity classification for story insights.
enum OverviewInsightSeverity {
  /// Informational — no action needed.
  info,

  /// Positive signal (e.g., tasks completed, healthy metrics).
  positive,

  /// Warning — should be reviewed.
  warning,

  /// Critical — needs immediate attention.
  critical,
}
