/// Tests for the Operate storytelling and diagnostics layer.
///
/// Covers:
/// - Review queue pressure derivation
/// - Blocker cluster detection
/// - Proof-risk count computation
/// - Lane/status mismatch detection
/// - Overall risk level classification
/// - Empty task list handling
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_observatory/features/operate/operate_storytelling.dart';
import 'package:warp_prism_observatory/features/operate/task_projection.dart';
import 'package:warp_prism_observatory/data/models/task_contracts.dart';

/// Helper to create a [TaskProjection] with sensible defaults.
TaskProjection _task({
  required String id,
  required String title,
  TaskLane lane = TaskLane.open,
  String priority = 'P1',
  ProofState proofState = ProofState.complete,
  List<String> dependsOn = const [],
  double? reviewScore,
  String owner = 'agent:test',
}) {
  return TaskProjection(
    id: id,
    title: title,
    lane: lane,
    priority: priority,
    owner: owner,
    proofState: proofState,
    dependsOn: dependsOn,
    reviewScore: reviewScore,
    created: DateTime(2026, 1, 1),
    updated: DateTime(2026, 1, 2),
  );
}

void main() {
  group('deriveOperateStoryDiagnostics', () {
    test('returns empty diagnostics for empty task list', () {
      final result = deriveOperateStoryDiagnostics([]);
      expect(result, isA<OperateStoryDiagnostics>());
      expect(result.hasSignals, false);
      expect(result.insights, isEmpty);
      expect(result.overallRiskLevel, StoryRiskLevel.none);
    });

    test('detects review queue pressure', () {
      final tasks = [
        _task(id: 't1', title: 'Task 1', lane: TaskLane.review),
        _task(id: 't2', title: 'Task 2', lane: TaskLane.review),
        _task(id: 't3', title: 'Task 3', lane: TaskLane.review),
      ];

      final result = deriveOperateStoryDiagnostics(tasks);

      expect(result.reviewQueueCount, 3);
      expect(result.insights, isNotEmpty);

      final reviewInsight = result.insights.firstWhere(
        (i) => i.title.contains('Review queue'),
      );
      expect(reviewInsight.value, 3);
      expect(reviewInsight.riskLevel, StoryRiskLevel.medium);
    });

    test('review queue pressure escalates with count', () {
      final tasks = List.generate(
        6,
        (i) => _task(id: 't$i', title: 'Task $i', lane: TaskLane.review),
      );

      final result = deriveOperateStoryDiagnostics(tasks);
      final reviewInsight = result.insights.firstWhere(
        (i) => i.title.contains('Review queue'),
      );
      expect(reviewInsight.riskLevel, StoryRiskLevel.high);
    });

    test('detects blocker clusters', () {
      final tasks = [
        _task(id: 't1', title: 'Blocked A', dependsOn: ['t-dep']),
        _task(id: 't2', title: 'Blocked B', dependsOn: ['t-dep']),
        _task(id: 't-dep', title: 'Dependency'),
      ];

      final result = deriveOperateStoryDiagnostics(tasks);

      expect(result.blockedTaskCount, 2);
      expect(result.blockerClusters, isNotEmpty);

      final cluster = result.blockerClusters.first;
      expect(cluster.dependencyId, 't-dep');
      expect(cluster.size, 2);
      expect(cluster.dependencyExists, true);
    });

    test('detects missing dependencies in blocker clusters', () {
      final tasks = [
        _task(id: 't1', title: 'Blocked A', dependsOn: ['missing-dep']),
      ];

      final result = deriveOperateStoryDiagnostics(tasks);

      expect(result.blockerClusters, isNotEmpty);
      final cluster = result.blockerClusters.first;
      expect(cluster.dependencyExists, false);

      final blockerInsight = result.insights.firstWhere(
        (i) => i.title.contains('Blocker'),
      );
      expect(blockerInsight.riskLevel, StoryRiskLevel.high);
    });

    test('detects proof-risk tasks', () {
      final tasks = [
        _task(
          id: 't1',
          title: 'Review no proof',
          lane: TaskLane.review,
          proofState: ProofState.none,
        ),
        _task(
          id: 't2',
          title: 'Completed partial proof',
          lane: TaskLane.completed,
          proofState: ProofState.partial,
        ),
        _task(
          id: 't3',
          title: 'Open task ignored',
          lane: TaskLane.open,
          proofState: ProofState.none,
        ),
      ];

      final result = deriveOperateStoryDiagnostics(tasks);

      expect(result.proofRiskCount, 2);
      expect(result.proofRiskTaskIds, contains('t1'));
      expect(result.proofRiskTaskIds, contains('t2'));
      expect(result.proofRiskTaskIds, isNot(contains('t3')));

      final proofInsight = result.insights.firstWhere(
        (i) => i.title.contains('Proof'),
      );
      expect(proofInsight.value, 2);
      expect(proofInsight.riskLevel, StoryRiskLevel.high);
    });

    test('detects P0 tasks stuck in planning lane', () {
      final tasks = [
        _task(
          id: 't1',
          title: 'Critical planning task',
          priority: 'P0',
          lane: TaskLane.planning,
        ),
      ];

      final result = deriveOperateStoryDiagnostics(tasks);

      expect(result.laneMismatches, isNotEmpty);
      expect(result.laneMismatches.first.description, contains('P0'));
      expect(result.laneMismatches.first.description, contains('planning'));
    });

    test('detects review tasks without review score', () {
      final tasks = [
        _task(
          id: 't1',
          title: 'No score review',
          lane: TaskLane.review,
          reviewScore: null,
        ),
      ];

      final result = deriveOperateStoryDiagnostics(tasks);

      expect(result.laneMismatches, isNotEmpty);
      expect(
        result.laneMismatches.first.description,
        contains('no review score'),
      );
    });

    test('overall risk level matches highest insight', () {
      final tasks = [
        _task(id: 't1', title: 'Review', lane: TaskLane.review),
        _task(id: 't2', title: 'Review', lane: TaskLane.review),
        _task(id: 't3', title: 'Review', lane: TaskLane.review),
        _task(id: 't4', title: 'Review', lane: TaskLane.review),
        _task(id: 't5', title: 'Review', lane: TaskLane.review),
      ];

      final result = deriveOperateStoryDiagnostics(tasks);

      // 5 tasks in review = high risk
      expect(result.overallRiskLevel, StoryRiskLevel.high);
    });

    test('healthy workspace has no signals', () {
      final tasks = [
        _task(
          id: 't1',
          title: 'Good task',
          lane: TaskLane.doing,
          proofState: ProofState.complete,
          reviewScore: 8.0,
        ),
        _task(
          id: 't2',
          title: 'Done task',
          lane: TaskLane.completed,
          proofState: ProofState.complete,
          reviewScore: 9.0,
        ),
      ];

      final result = deriveOperateStoryDiagnostics(tasks);

      expect(result.hasSignals, false);
      expect(result.insights, isEmpty);
      expect(result.overallRiskLevel, StoryRiskLevel.none);
    });
  });

  group('OperateStoryDiagnostics', () {
    test('empty diagnostics has no signals', () {
      const diag = OperateStoryDiagnostics.empty();
      expect(diag.hasSignals, false);
      expect(diag.insights, isEmpty);
      expect(diag.overallRiskLevel, StoryRiskLevel.none);
    });
  });

  group('BlockerCluster', () {
    test('size equals blocked tasks count', () {
      final cluster = BlockerCluster(
        dependencyId: 'dep1',
        blockedTasks: [
          _task(id: 't1', title: 'A', dependsOn: ['dep1']),
          _task(id: 't2', title: 'B', dependsOn: ['dep1']),
        ],
      );
      expect(cluster.size, 2);
    });
  });

  // Path-to-100 residual (Task 0613): completed verified deps are not blockers
  group('Unresolved dependency refinement', () {
    test('completed verified dependency is not an unresolved blocker', () {
      final tasks = [
        _task(
          id: 't-dep',
          title: 'Dependency',
          lane: TaskLane.completed,
          proofState: ProofState.verified,
        ),
        _task(
          id: 't-blocked',
          title: 'Would-be blocked',
          lane: TaskLane.doing,
          dependsOn: const ['t-dep'],
        ),
      ];

      final result = deriveOperateStoryDiagnostics(tasks);
      final blockerInsights = result.insights.where(
        (i) => i.title.contains('Blocker'),
      );
      expect(blockerInsights, isEmpty);
    });

    test('missing dependency still forms a blocker cluster', () {
      final tasks = [
        _task(
          id: 't-blocked',
          title: 'Blocked',
          lane: TaskLane.doing,
          dependsOn: const ['missing-dep'],
        ),
      ];

      final result = deriveOperateStoryDiagnostics(tasks);
      final blockerInsight = result.insights.firstWhere(
        (i) => i.title.contains('Blocker'),
      );
      expect(blockerInsight.value, 1);
      expect(blockerInsight.detail, contains('missing'));
    });
  });
}
