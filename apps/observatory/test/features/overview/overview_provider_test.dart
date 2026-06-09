/// Tests for OverviewProvider and OverviewMetrics.
///
/// Covers:
/// - Non-empty dataset: verifies derived metrics are data-driven
/// - Empty dataset (zero-data edge case): verifies graceful empty state
/// - Blocker counting logic
/// - Task lane aggregation
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_observatory/data/models/data_models.dart';
import 'package:warp_prism_observatory/data/models/governance_diagnostics.dart';
import 'package:warp_prism_observatory/features/overview/overview_metrics.dart';
import 'package:warp_prism_observatory/features/overview/overview_provider.dart';

void main() {
  const provider = OverviewProvider();

  // ---------------------------------------------------------------------------
  // Helper: build a minimal WorkspaceAsset for testing
  // ---------------------------------------------------------------------------
  WorkspaceAsset _asset({
    required String id,
    required AssetKind kind,
    String name = 'test',
    String path = 'test/path',
    TaskMetadata? taskMeta,
    List<WorkspaceEdge> edges = const [],
  }) {
    final fm = <String, dynamic>{};
    if (taskMeta != null) fm['_taskMetadata'] = taskMeta;
    return WorkspaceAsset(
      id: id,
      kind: kind,
      name: name,
      path: path,
      frontmatter: fm,
      edges: edges,
    );
  }

  group('OverviewProvider', () {
    // =========================================================================
    // Non-empty dataset
    // =========================================================================
    test('computes correct totals from a non-empty dataset', () {
      final now = DateTime.now();
      final assets = [
        _asset(id: 'agent:a1', kind: AssetKind.agent, name: 'agent-1'),
        _asset(id: 'agent:a2', kind: AssetKind.agent, name: 'agent-2'),
        _asset(id: 'skill:s1', kind: AssetKind.skill, name: 'skill-1'),
        _asset(id: 'subskill:ss1', kind: AssetKind.subskill, name: 'sub-1'),
        _asset(id: 'subskill:ss2', kind: AssetKind.subskill, name: 'sub-2'),
        _asset(id: 'subskill:ss3', kind: AssetKind.subskill, name: 'sub-3'),
        _asset(id: 'workflow:w1', kind: AssetKind.workflow, name: 'wf-1'),
        _asset(id: 'workflow:w2', kind: AssetKind.workflow, name: 'wf-2'),
        _asset(id: 'task:t1', kind: AssetKind.task, name: 'task-1',
            taskMeta: TaskMetadata(
                id: '1', title: 'Task 1', lane: TaskLane.doing,
                created: now, updated: now)),
        _asset(id: 'task:t2', kind: AssetKind.task, name: 'task-2',
            taskMeta: TaskMetadata(
                id: '2', title: 'Task 2', lane: TaskLane.doing,
                created: now, updated: now)),
        _asset(id: 'task:t3', kind: AssetKind.task, name: 'task-3',
            taskMeta: TaskMetadata(
                id: '3', title: 'Task 3', lane: TaskLane.review,
                created: now, updated: now)),
        _asset(id: 'task:t4', kind: AssetKind.task, name: 'task-4',
            taskMeta: TaskMetadata(
                id: '4', title: 'Task 4', lane: TaskLane.completed,
                created: now, updated: now)),
        _asset(id: 'task:t5', kind: AssetKind.task, name: 'task-5',
            taskMeta: TaskMetadata(
                id: '5', title: 'Task 5', lane: TaskLane.open,
                created: now, updated: now)),
        _asset(id: 'cl:c1', kind: AssetKind.changelog, name: 'cl-1'),
        _asset(id: 'cl:c2', kind: AssetKind.changelog, name: 'cl-2'),
        _asset(id: 'cl:c3', kind: AssetKind.changelog, name: 'cl-3'),
      ];

      final metrics = provider.compute(assets: assets);

      // Totals
      expect(metrics.agentCount, 2);
      expect(metrics.skillCount, 1);
      expect(metrics.subSkillCount, 3);
      expect(metrics.workflowCount, 2);
      expect(metrics.changelogEntryCount, 3);
      expect(metrics.totalTaskCount, 5);

      // Tasks by lane
      expect(metrics.tasksByLane[TaskLane.doing], 2);
      expect(metrics.tasksByLane[TaskLane.review], 1);
      expect(metrics.tasksByLane[TaskLane.completed], 1);
      expect(metrics.tasksByLane[TaskLane.open], 1);
      expect(metrics.tasksByLane[TaskLane.planning], 0);

      // Derived convenience getters
      expect(metrics.doingTaskCount, 2);
      expect(metrics.openTaskCount, 1);
      expect(metrics.completedTaskCount, 1);

      // Total assets
      expect(metrics.totalAssets, 16);

      // Workspace is not empty
      expect(metrics.isEmpty, false);
    });

    test('computes edge count from assets with edges', () {
      final assets = [
        _asset(
          id: 'agent:a1',
          kind: AssetKind.agent,
          name: 'agent-1',
          edges: [
            const WorkspaceEdge(
                sourceId: 'agent:a1', targetId: 'skill:s1', kind: EdgeKind.uses),
            const WorkspaceEdge(
                sourceId: 'agent:a1', targetId: 'workflow:w1', kind: EdgeKind.uses),
          ],
        ),
        _asset(id: 'skill:s1', kind: AssetKind.skill, name: 'skill-1'),
      ];

      final metrics = provider.compute(assets: assets);
      expect(metrics.totalEdges, 2);
    });

    // =========================================================================
    // Zero-data edge case
    // =========================================================================
    test('returns zero-filled metrics for empty asset list', () {
      final metrics = provider.compute(assets: const []);

      expect(metrics.agentCount, 0);
      expect(metrics.skillCount, 0);
      expect(metrics.subSkillCount, 0);
      expect(metrics.workflowCount, 0);
      expect(metrics.changelogEntryCount, 0);
      expect(metrics.totalTaskCount, 0);
      expect(metrics.activeBlockers, 0);
      expect(metrics.reviewQueueCount, 0);
      expect(metrics.governanceWarningCount, 0);
      expect(metrics.totalAssets, 0);
      expect(metrics.totalEdges, 0);
      expect(metrics.isEmpty, true);
      expect(metrics.currentStoryTitle, 'No workspace data loaded');
      expect(metrics.currentStoryInsights, isNotEmpty);
    });

    // =========================================================================
    // Blocker counting
    // =========================================================================
    test('counts P0 tasks with incomplete proof as blockers', () {
      final now = DateTime.now();
      final assets = [
        _asset(
          id: 'task:t1',
          kind: AssetKind.task,
          name: 'critical-task',
          taskMeta: TaskMetadata(
            id: '1',
            title: 'Critical Task',
            lane: TaskLane.doing,
            priority: 'P0',
            proofState: ProofState.partial,
            created: now,
            updated: now,
          ),
        ),
        _asset(
          id: 'task:t2',
          kind: AssetKind.task,
          name: 'normal-task',
          taskMeta: TaskMetadata(
            id: '2',
            title: 'Normal Task',
            lane: TaskLane.doing,
            priority: 'P1',
            proofState: ProofState.none,
            created: now,
            updated: now,
          ),
        ),
      ];

      final metrics = provider.compute(assets: assets);
      expect(metrics.activeBlockers, 1);
    });

    test('P0 tasks with complete proof are not blockers', () {
      final now = DateTime.now();
      final assets = [
        _asset(
          id: 'task:t1',
          kind: AssetKind.task,
          name: 'done-task',
          taskMeta: TaskMetadata(
            id: '1',
            title: 'Done Task',
            lane: TaskLane.completed,
            priority: 'P0',
            proofState: ProofState.complete,
            created: now,
            updated: now,
          ),
        ),
      ];

      final metrics = provider.compute(assets: assets);
      expect(metrics.activeBlockers, 0);
    });

    // =========================================================================
    // Governance warnings from diagnostics
    // =========================================================================
    test('counts governance diagnostics at warning or above', () {
      final diags = [
        GovernanceDiagnostic(
          assetId: 'task:t1',
          severity: DiagnosticSeverity.warning,
          category: DiagnosticCategory.staleReference,
          message: 'Stale ref',
          computedAt: DateTime.now(),
        ),
        GovernanceDiagnostic(
          assetId: 'task:t2',
          severity: DiagnosticSeverity.error,
          category: DiagnosticCategory.proofGap,
          message: 'Proof gap',
          computedAt: DateTime.now(),
        ),
        GovernanceDiagnostic(
          assetId: 'task:t3',
          severity: DiagnosticSeverity.info,
          category: DiagnosticCategory.orphanAsset,
          message: 'Orphan',
          computedAt: DateTime.now(),
        ),
      ];

      final metrics = provider.compute(assets: const [], diagnostics: diags);
      expect(metrics.governanceWarningCount, 2);
    });

    // =========================================================================
    // Current story
    // =========================================================================
    test('story panel reflects active work state', () {
      final now = DateTime.now();
      final assets = [
        _asset(
          id: 'task:t1',
          kind: AssetKind.task,
          name: 'doing-task',
          taskMeta: TaskMetadata(
            id: '1',
            title: 'Doing Task',
            lane: TaskLane.doing,
            created: now,
            updated: now,
          ),
        ),
      ];

      final metrics = provider.compute(assets: assets);
      expect(metrics.currentStoryTitle, contains('in progress'));
      expect(metrics.currentStoryInsights, isNotEmpty);
    });

    test('story panel handles zero tasks gracefully', () {
      final assets = [
        _asset(id: 'agent:a1', kind: AssetKind.agent, name: 'agent-1'),
      ];

      final metrics = provider.compute(assets: assets);
      expect(metrics.currentStoryTitle, isNotEmpty);
      expect(metrics.currentStoryInsights, isNotEmpty);
    });
  });

  // ===========================================================================
  // OverviewMetrics value equality
  // ===========================================================================
  group('OverviewMetrics equality', () {
    test('equal instances are equal', () {
      const a = OverviewMetrics(
        agentCount: 1, skillCount: 2, subSkillCount: 3,
        workflowCount: 4, changelogEntryCount: 5,
        tasksByLane: {}, activeBlockers: 0,
        reviewQueueCount: 0, governanceWarningCount: 0,
        currentStoryTitle: 'title', currentStoryInsights: [],
        totalAssets: 10, totalEdges: 5,
      );
      const b = OverviewMetrics(
        agentCount: 1, skillCount: 2, subSkillCount: 3,
        workflowCount: 4, changelogEntryCount: 5,
        tasksByLane: {}, activeBlockers: 0,
        reviewQueueCount: 0, governanceWarningCount: 0,
        currentStoryTitle: 'title', currentStoryInsights: [],
        totalAssets: 10, totalEdges: 5,
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });
  });
}
