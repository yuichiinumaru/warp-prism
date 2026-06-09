/// Dashboard-ready derived metrics from the canonical workspace graph.
///
/// Computes aggregated totals for assets, task lane breakdowns, review
/// pressure, blocker counts, proof readiness, and cross-link completeness.
/// Downstream consumers (Overview, Governance) should consume these typed
/// summaries instead of recomputing analytics in view models or widgets.
///
/// This service is pure and stateless — it takes a [WorkspaceGraphResult]
/// and returns a [WorkspaceMetricsSummary].
library;

import '../models/workspace_graph.dart';
import '../models/task_contracts.dart';
import 'workspace_graph.dart';

/// Dashboard-ready metrics summary computed from the workspace graph.
///
/// All fields are immutable snapshots of the graph state at computation
/// time. No references to the graph are held after construction.
class WorkspaceMetricsSummary {
  /// Total number of assets across all kinds.
  final int totalAssets;

  /// Asset counts grouped by kind.
  final Map<AssetKind, int> assetsByKind;

  /// Task counts grouped by lane.
  final Map<TaskLane, int> tasksByLane;

  /// Number of tasks with unresolved dependencies (blocked).
  final int blockedTaskCount;

  /// Number of tasks currently in the review lane.
  final int reviewQueueCount;

  /// Number of tasks in review or completed lanes lacking proof.
  final int proofGapCount;

  /// Number of tasks without verification commands.
  final int tasksWithoutVerification;

  /// Number of changelog entries linked to tasks.
  final int changelogWithTaskLink;

  /// Number of changelog entries without a task link.
  final int changelogWithoutTaskLink;

  /// Total number of edges in the graph.
  final int totalEdges;

  /// Number of skills with no trigger phrases.
  final int skillsWithNoTriggers;

  /// Number of orphan workflows (not referenced by any agent or skill).
  final int orphanWorkflowCount;

  const WorkspaceMetricsSummary({
    required this.totalAssets,
    required this.assetsByKind,
    required this.tasksByLane,
    required this.blockedTaskCount,
    required this.reviewQueueCount,
    required this.proofGapCount,
    required this.tasksWithoutVerification,
    required this.changelogWithTaskLink,
    required this.changelogWithoutTaskLink,
    required this.totalEdges,
    required this.skillsWithNoTriggers,
    required this.orphanWorkflowCount,
  });

  /// An empty summary with all zeroes.
  const WorkspaceMetricsSummary.empty()
      : totalAssets = 0,
        assetsByKind = const {},
        tasksByLane = const {},
        blockedTaskCount = 0,
        reviewQueueCount = 0,
        proofGapCount = 0,
        tasksWithoutVerification = 0,
        changelogWithTaskLink = 0,
        changelogWithoutTaskLink = 0,
        totalEdges = 0,
        skillsWithNoTriggers = 0,
        orphanWorkflowCount = 0;

  @override
  String toString() =>
      'WorkspaceMetricsSummary(assets: $totalAssets, tasks: '
      '${tasksByLane.values.fold(0, (a, b) => a + b)}, '
      'review: $reviewQueueCount, blockers: $blockedTaskCount, '
      'proofGaps: $proofGapCount)';
}

/// Computes derived metrics from a [WorkspaceGraphResult].
///
/// Usage:
/// ```dart
/// const service = WorkspaceMetricsService();
/// final summary = service.compute(graph);
/// ```
class WorkspaceMetricsService {
  const WorkspaceMetricsService();

  /// Compute a [WorkspaceMetricsSummary] from the given [graph].
  WorkspaceMetricsSummary compute(WorkspaceGraphResult graph) {
    // Asset counts by kind
    final assetsByKind = <AssetKind, int>{};
    for (final kind in AssetKind.values) {
      assetsByKind[kind] = graph.assetsByKind[kind]?.length ?? 0;
    }

    // Task lane breakdown
    final tasksByLane = <TaskLane, int>{};
    for (final lane in TaskLane.values) {
      tasksByLane[lane] = 0;
    }
    final tasks = graph.assetsByKind[AssetKind.task] ?? [];
    for (final task in tasks) {
      final meta = task.frontmatter['_taskMetadata'] as TaskMetadata?;
      final lane = meta?.lane ?? TaskLane.open;
      tasksByLane[lane] = (tasksByLane[lane] ?? 0) + 1;
    }

    // Blocked tasks: tasks with depends_on entries
    var blockedTaskCount = 0;
    for (final task in tasks) {
      final meta = task.frontmatter['_taskMetadata'] as TaskMetadata?;
      if (meta != null && meta.dependsOn.isNotEmpty) blockedTaskCount++;
    }

    // Review queue
    var reviewQueueCount = 0;
    for (final task in tasks) {
      final meta = task.frontmatter['_taskMetadata'] as TaskMetadata?;
      if (meta != null && meta.lane == TaskLane.review) reviewQueueCount++;
    }

    // Proof gaps: tasks in review/completed with no proof or partial proof
    var proofGapCount = 0;
    for (final task in tasks) {
      final meta = task.frontmatter['_taskMetadata'] as TaskMetadata?;
      if (meta == null) continue;
      if ((meta.lane == TaskLane.review || meta.lane == TaskLane.completed) &&
          (meta.proofState == ProofState.none ||
              meta.proofState == ProofState.partial)) {
        proofGapCount++;
      }
    }

    // Tasks without verification commands
    var tasksWithoutVerification = 0;
    for (final task in tasks) {
      final meta = task.frontmatter['_taskMetadata'] as TaskMetadata?;
      if (meta == null || meta.verificationCommands == null) {
        tasksWithoutVerification++;
      }
    }

    // Changelog linkage
    var changelogWithTaskLink = 0;
    var changelogWithoutTaskLink = 0;
    final changelogEdges = graph.edgesByKind(EdgeKind.changedBy);
    final changelogs = graph.assetsByKind[AssetKind.changelog] ?? [];
    final linkedChangelogIds = changelogEdges.map((e) => e.sourceId).toSet();
    for (final cl in changelogs) {
      if (linkedChangelogIds.contains(cl.id)) {
        changelogWithTaskLink++;
      } else {
        changelogWithoutTaskLink++;
      }
    }

    // Skills with no triggers
    var skillsWithNoTriggers = 0;
    final skills = graph.assetsByKind[AssetKind.skill] ?? [];
    for (final skill in skills) {
      if (skill.triggers.isEmpty) skillsWithNoTriggers++;
    }

    // Orphan workflows
    var orphanWorkflowCount = 0;
    final workflows = graph.assetsByKind[AssetKind.workflow] ?? [];
    final referencedIds = <String>{};
    for (final edge in graph.edges) {
      if (edge.kind == EdgeKind.uses ||
          edge.kind == EdgeKind.references ||
          edge.kind == EdgeKind.contains ||
          edge.kind == EdgeKind.dependsOn ||
          edge.kind == EdgeKind.routesTo) {
        referencedIds.add(edge.targetId);
      }
    }
    for (final wf in workflows) {
      if (!referencedIds.contains(wf.id)) orphanWorkflowCount++;
    }

    return WorkspaceMetricsSummary(
      totalAssets: graph.nodeCount,
      assetsByKind: assetsByKind,
      tasksByLane: tasksByLane,
      blockedTaskCount: blockedTaskCount,
      reviewQueueCount: reviewQueueCount,
      proofGapCount: proofGapCount,
      tasksWithoutVerification: tasksWithoutVerification,
      changelogWithTaskLink: changelogWithTaskLink,
      changelogWithoutTaskLink: changelogWithoutTaskLink,
      totalEdges: graph.edgeCount,
      skillsWithNoTriggers: skillsWithNoTriggers,
      orphanWorkflowCount: orphanWorkflowCount,
    );
  }
}
