/// Operate surface storytelling and risk-signaling layer.
///
/// Derives deterministic hotspot signals from task projections:
/// - Review queue pressure: tasks stacking up in review lane
/// - Blocker clusters: groups of tasks with unresolved dependencies
/// - Proof-risk counts: tasks in review/completed without proof
/// - Lane/status mismatch: tasks whose declared status conflicts
///   with their current lane position
///
/// These signals are pure and derived — they do not fabricate narratives
/// from static prose. Every insight traces back to parsed task metadata.
library;

import 'package:flutter/foundation.dart';
import 'package:warp_prism_observatory/data/models/task_contracts.dart';
import 'package:warp_prism_observatory/features/operate/task_projection.dart';

// ---------------------------------------------------------------------------
// Storytelling Data Contracts
// ---------------------------------------------------------------------------

/// Severity level for operational risk signals.
enum StoryRiskLevel {
  /// No risk — normal operational state.
  none,

  /// Low risk — minor concern, does not block workflow.
  low,

  /// Medium risk — degrades throughput, should be reviewed.
  medium,

  /// High risk — significant blocker or gap, needs attention.
  high,

  /// Critical risk — blocks core workflow or demo readiness.
  critical,
}

/// A single operational insight derived from task data.
@immutable
class OperateInsight {
  /// Human-readable summary of the insight.
  final String title;

  /// Supporting detail or explanation.
  final String detail;

  /// Risk severity of this insight.
  final StoryRiskLevel riskLevel;

  /// Numeric value (count, percentage, etc.) for display.
  final int? value;

  /// Asset IDs involved in this insight (for drill-down).
  final List<String> involvedAssetIds;

  const OperateInsight({
    required this.title,
    required this.detail,
    this.riskLevel = StoryRiskLevel.none,
    this.value,
    this.involvedAssetIds = const [],
  });
}

/// A cluster of blocked tasks sharing a common dependency.
@immutable
class BlockerCluster {
  /// The dependency ID that is blocking these tasks.
  final String dependencyId;

  /// Tasks blocked by this dependency.
  final List<TaskProjection> blockedTasks;

  /// Whether this dependency itself exists in the workspace.
  final bool dependencyExists;

  const BlockerCluster({
    required this.dependencyId,
    required this.blockedTasks,
    this.dependencyExists = true,
  });

  /// Number of tasks blocked by this dependency.
  int get size => blockedTasks.length;
}

/// A detected lane/status mismatch.
@immutable
class LaneMismatch {
  /// The task with the mismatch.
  final TaskProjection task;

  /// Description of the mismatch.
  final String description;

  const LaneMismatch({required this.task, required this.description});
}

/// Complete storytelling diagnostics for the Operate surface.
///
/// Contains all derived signals that make blocked work, review pressure,
/// and proof-risk tasks obvious on the board.
@immutable
class OperateStoryDiagnostics {
  /// Review queue pressure: number of tasks in review lane.
  final int reviewQueueCount;

  /// Blocker clusters: groups of tasks blocked by the same dependency.
  final List<BlockerCluster> blockerClusters;

  /// Total number of blocked tasks.
  final int blockedTaskCount;

  /// Number of tasks in review/completed lacking proof.
  final int proofRiskCount;

  /// Task IDs with proof risk (for visual emphasis).
  final List<String> proofRiskTaskIds;

  /// Detected lane/status mismatches.
  final List<LaneMismatch> laneMismatches;

  /// All derived insights for the story panel.
  final List<OperateInsight> insights;

  /// Overall risk level for the workspace.
  final StoryRiskLevel overallRiskLevel;

  const OperateStoryDiagnostics({
    required this.reviewQueueCount,
    required this.blockerClusters,
    required this.blockedTaskCount,
    required this.proofRiskCount,
    required this.proofRiskTaskIds,
    required this.laneMismatches,
    required this.insights,
    required this.overallRiskLevel,
  });

  /// An empty diagnostics with no signals.
  const OperateStoryDiagnostics.empty()
    : reviewQueueCount = 0,
      blockerClusters = const [],
      blockedTaskCount = 0,
      proofRiskCount = 0,
      proofRiskTaskIds = const [],
      laneMismatches = const [],
      insights = const [],
      overallRiskLevel = StoryRiskLevel.none;

  /// Whether there are any signals to show.
  bool get hasSignals =>
      reviewQueueCount > 0 ||
      blockerClusters.isNotEmpty ||
      proofRiskCount > 0 ||
      laneMismatches.isNotEmpty;
}

// ---------------------------------------------------------------------------
// Storytelling Derivation
// ---------------------------------------------------------------------------

/// Derives operational risk signals from a list of [TaskProjection]s.
///
/// This is a pure function — same inputs always produce the same outputs.
/// No hard-coded fixture data; all signals are derived from actual task
/// metadata.
///
/// Usage:
/// ```dart
/// final diagnostics = deriveOperateStoryDiagnostics(tasks);
/// ```
OperateStoryDiagnostics deriveOperateStoryDiagnostics(
  List<TaskProjection> tasks,
) {
  if (tasks.isEmpty) return const OperateStoryDiagnostics.empty();

  final insights = <OperateInsight>[];

  // ---- Review Queue Pressure ----
  final reviewTasks = tasks.where((t) => t.lane == TaskLane.review).toList();
  final reviewQueueCount = reviewTasks.length;

  if (reviewQueueCount > 0) {
    final risk = reviewQueueCount >= 5
        ? StoryRiskLevel.high
        : reviewQueueCount >= 3
        ? StoryRiskLevel.medium
        : StoryRiskLevel.low;
    insights.add(
      OperateInsight(
        title: 'Review queue pressure',
        detail: reviewQueueCount == 1
            ? '1 task awaiting review'
            : '$reviewQueueCount tasks awaiting review',
        riskLevel: risk,
        value: reviewQueueCount,
        involvedAssetIds: reviewTasks.map((t) => t.id).toList(),
      ),
    );
  }

  // ---- Blocker Clusters ----
  // Only count *unresolved* dependencies: missing from the board, or present
  // but not completed with full/verified proof (Task 0613 path-to-100 residual).
  bool isDependencyResolved(String depId) {
    final dep = tasks.where((t) => t.id == depId).firstOrNull;
    if (dep == null) return false;
    if (dep.lane != TaskLane.completed) return false;
    return dep.proofState == ProofState.complete ||
        dep.proofState == ProofState.verified;
  }

  final unresolvedByTask = <TaskProjection, List<String>>{};
  for (final task in tasks) {
    if (task.dependsOn.isEmpty) continue;
    final unresolved = task.dependsOn
        .where((dep) => !isDependencyResolved(dep))
        .toList();
    if (unresolved.isNotEmpty) {
      unresolvedByTask[task] = unresolved;
    }
  }

  final blockerMap = <String, List<TaskProjection>>{};
  for (final entry in unresolvedByTask.entries) {
    for (final dep in entry.value) {
      blockerMap.putIfAbsent(dep, () => []).add(entry.key);
    }
  }
  final blockedTasks = unresolvedByTask.keys.toList();
  final blockerClusters =
      blockerMap.entries
          .where((e) => e.value.isNotEmpty)
          .map(
            (e) => BlockerCluster(
              dependencyId: e.key,
              blockedTasks: e.value,
              dependencyExists: tasks.any((t) => t.id == e.key),
            ),
          )
          .toList()
        ..sort((a, b) => b.size.compareTo(a.size));

  if (blockerClusters.isNotEmpty) {
    final totalBlocked = blockedTasks.length;
    final missingDeps = blockerClusters
        .where((c) => !c.dependencyExists)
        .length;

    final baseDetail = totalBlocked == 1
        ? '1 task has unresolved dependencies'
        : '$totalBlocked tasks have unresolved dependencies';
    final missingSuffix = missingDeps > 0
        ? ' ($missingDeps missing dependencies)'
        : '';
    insights.add(
      OperateInsight(
        title: 'Blocker clusters',
        detail: '$baseDetail$missingSuffix',
        riskLevel: missingDeps > 0
            ? StoryRiskLevel.high
            : totalBlocked >= 5
            ? StoryRiskLevel.medium
            : StoryRiskLevel.low,
        value: totalBlocked,
        involvedAssetIds: blockedTasks.map((t) => t.id).toList(),
      ),
    );
  }

  // ---- Proof-Risk Tasks ----
  final proofRiskTasks = tasks.where((t) {
    if (t.lane != TaskLane.review && t.lane != TaskLane.completed) {
      return false;
    }
    return t.proofState == ProofState.none ||
        t.proofState == ProofState.partial;
  }).toList();

  if (proofRiskTasks.isNotEmpty) {
    final noProof = proofRiskTasks
        .where((t) => t.proofState == ProofState.none)
        .length;
    final partialProof = proofRiskTasks.length - noProof;

    insights.add(
      OperateInsight(
        title: 'Proof-risk tasks',
        detail: proofRiskTasks.length == 1
            ? '1 task in review/completed without full proof'
            : '${proofRiskTasks.length} tasks in review/completed without full proof'
                  ' ($noProof missing, $partialProof partial)',
        riskLevel: noProof > 0 ? StoryRiskLevel.high : StoryRiskLevel.medium,
        value: proofRiskTasks.length,
        involvedAssetIds: proofRiskTasks.map((t) => t.id).toList(),
      ),
    );
  }

  // ---- Lane/Status Mismatches ----
  final laneMismatches = <LaneMismatch>[];
  for (final task in tasks) {
    // Detect tasks with high-priority but stuck in planning/open
    if (task.priority == 'P0' && task.lane == TaskLane.planning) {
      laneMismatches.add(
        LaneMismatch(
          task: task,
          description: 'P0 task "${task.title}" still in planning lane',
        ),
      );
    }
    // Detect review tasks with no review score
    if (task.lane == TaskLane.review && task.reviewScore == null) {
      laneMismatches.add(
        LaneMismatch(
          task: task,
          description: 'Task "${task.title}" in review with no review score',
        ),
      );
    }
  }

  if (laneMismatches.isNotEmpty) {
    insights.add(
      OperateInsight(
        title: 'Lane mismatches',
        detail: laneMismatches.length == 1
            ? '1 task has a lane/status mismatch'
            : '${laneMismatches.length} tasks have lane/status mismatches',
        riskLevel: StoryRiskLevel.medium,
        value: laneMismatches.length,
        involvedAssetIds: laneMismatches.map((m) => m.task.id).toList(),
      ),
    );
  }

  // ---- Overall Risk Level ----
  StoryRiskLevel overallRisk = StoryRiskLevel.none;
  for (final insight in insights) {
    if (insight.riskLevel.index > overallRisk.index) {
      overallRisk = insight.riskLevel;
    }
  }

  return OperateStoryDiagnostics(
    reviewQueueCount: reviewQueueCount,
    blockerClusters: blockerClusters,
    blockedTaskCount: blockedTasks.length,
    proofRiskCount: proofRiskTasks.length,
    proofRiskTaskIds: proofRiskTasks.map((t) => t.id).toList(),
    laneMismatches: laneMismatches,
    insights: insights,
    overallRiskLevel: overallRisk,
  );
}
