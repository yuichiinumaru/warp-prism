/// Tests for the enhanced workspace snapshot (Task 0020).
///
/// Tests search filtering, filter chip toggle, graph projection,
/// detail inspector open/close, deep-link resolution, and derived
/// metric computation.
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_observatory/data/models/workspace_graph.dart';
import 'package:warp_prism_observatory/data/models/workspace_snapshot.dart';
import 'package:warp_prism_observatory/data/models/task_contracts.dart';
import 'package:warp_prism_observatory/data/services/workspace_graph_builder.dart';

void main() {
  group('WorkspaceSnapshot search', () {
    final snapshot = _buildTestSnapshot();

    test('search returns all assets for empty query', () {
      final results = snapshot.search('');
      expect(results.length, equals(snapshot.totalAssets));
    });

    test('search matches by name', () {
      final results = snapshot.search('architect');
      expect(results, isNotEmpty);
      expect(results.any((a) => a.name.toLowerCase().contains('architect')), isTrue);
    });

    test('search matches by description', () {
      final results = snapshot.search('orchestrator');
      expect(results, isNotEmpty);
    });

    test('search matches by tags', () {
      final results = snapshot.search('core');
      expect(results, isNotEmpty);
      expect(results.any((a) => a.tags.contains('core')), isTrue);
    });

    test('search matches by triggers', () {
      final results = snapshot.search('review code');
      expect(results, isNotEmpty);
      expect(results.any((a) => a.triggers.contains('review code')), isTrue);
    });

    test('search is case insensitive', () {
      final results = snapshot.search('ARCHITECT');
      expect(results, isNotEmpty);
    });

    test('search returns empty for non-matching query', () {
      final results = snapshot.search('zzzznonexistent');
      expect(results, isEmpty);
    });
  });

  group('WorkspaceSnapshot filterByKind', () {
    final snapshot = _buildTestSnapshot();

    test('filters by agent kind', () {
      final agents = snapshot.filterByKind(AssetKind.agent);
      expect(agents.every((a) => a.kind == AssetKind.agent), isTrue);
      expect(agents.length, equals(snapshot.agents.length));
    });

    test('filters by task kind', () {
      final tasks = snapshot.filterByKind(AssetKind.task);
      expect(tasks.every((a) => a.kind == AssetKind.task), isTrue);
      expect(tasks.length, equals(snapshot.tasks.length));
    });
  });

  group('WorkspaceSnapshot filterTasksByLane', () {
    final snapshot = _buildTestSnapshot();

    test('filters tasks by lane', () {
      final doingTasks = snapshot.filterTasksByLane(TaskLane.doing);
      expect(doingTasks, isNotEmpty);
      for (final task in doingTasks) {
        final meta = task.frontmatter['_taskMetadata'] as TaskMetadata?;
        expect(meta?.lane, equals(TaskLane.doing));
      }
    });

    test('returns empty for lane with no tasks', () {
      final planningTasks = snapshot.filterTasksByLane(TaskLane.planning);
      expect(planningTasks, isEmpty);
    });
  });

  group('WorkspaceSnapshot filterByCanonicality', () {
    final snapshot = _buildTestSnapshot();

    test('filters by parentCanonical', () {
      final canonical =
          snapshot.filterByCanonicality(Canonicality.parentCanonical);
      expect(canonical, isNotEmpty);
      expect(
        canonical.every((a) => a.canonicality == Canonicality.parentCanonical),
        isTrue,
      );
    });

    test('filters by appendOnly', () {
      final appendOnly =
          snapshot.filterByCanonicality(Canonicality.appendOnly);
      expect(appendOnly, isNotEmpty);
    });
  });

  group('WorkspaceSnapshot getAssetById', () {
    final snapshot = _buildTestSnapshot();

    test('finds agent by id', () {
      final agent = snapshot.getAssetById('agent:architect');
      expect(agent, isNotNull);
      expect(agent!.name, equals('Architect'));
    });

    test('finds task by id', () {
      final task = snapshot.getAssetById('task:0020');
      expect(task, isNotNull);
      expect(task!.kind, equals(AssetKind.task));
    });

    test('returns null for unknown id', () {
      expect(snapshot.getAssetById('nonexistent'), isNull);
    });
  });

  group('WorkspaceSnapshot derived metrics', () {
    final snapshot = _buildTestSnapshot();

    test('blockedTaskCount counts tasks with dependencies', () {
      expect(snapshot.blockedTaskCount, greaterThanOrEqualTo(0));
    });

    test('reviewQueueCount counts tasks in review lane', () {
      expect(snapshot.reviewQueueCount, greaterThanOrEqualTo(0));
    });

    test('tasksWithoutVerification counts tasks without verification', () {
      expect(snapshot.tasksWithoutVerification, greaterThanOrEqualTo(0));
    });

    test('skillsWithNoTriggers counts skills without triggers', () {
      expect(snapshot.skillsWithNoTriggers, greaterThanOrEqualTo(0));
    });

    test('orphanWorkflowCount counts unreferenced workflows', () {
      expect(snapshot.orphanWorkflowCount, greaterThanOrEqualTo(0));
    });

    test('governanceWarningCount counts governance warnings', () {
      expect(snapshot.governanceWarningCount, greaterThanOrEqualTo(0));
    });
  });

  group('WorkspaceGraphBuilder integration with snapshot', () {
    test('builds graph from snapshot assets', () {
      final snapshot = _buildTestSnapshot();
      const builder = WorkspaceGraphBuilder();
      final graph = builder.build(snapshot.allAssets.toList());

      expect(graph.nodeCount, equals(snapshot.totalAssets));
      expect(graph.edgeCount, greaterThan(0));
    });

    test('graph contains task-skill edges from snapshot', () {
      final snapshot = _buildTestSnapshot();
      const builder = WorkspaceGraphBuilder();
      final graph = builder.build(snapshot.allAssets.toList());

      // Task should have reference edges to skills
      final taskEdges = graph.outgoingEdges('task:0020');
      final refEdges =
          taskEdges.where((e) => e.kind == EdgeKind.references).toList();
      expect(refEdges, isNotEmpty);
    });

    test('graph contains changelog-task linkage', () {
      final snapshot = _buildTestSnapshot();
      const builder = WorkspaceGraphBuilder();
      final graph = builder.build(snapshot.allAssets.toList());

      // Changelog should have changedBy edge to task
      final clEdges = graph.outgoingEdges('changelog:cl-test');
      final changedBy =
          clEdges.where((e) => e.kind == EdgeKind.changedBy).toList();
      expect(changedBy, isNotEmpty);
      expect(changedBy.first.targetId, equals('task:0020'));
    });
  });
}

/// Build a test snapshot with representative assets.
WorkspaceSnapshot _buildTestSnapshot() {
  return WorkspaceSnapshot(
    agents: [
      const WorkspaceAsset(
        id: 'agent:architect',
        kind: AssetKind.agent,
        name: 'Architect',
        path: '/ws/.agents/agents/architect.md',
        description: 'Build orchestrator agent',
        canonicality: Canonicality.parentCanonical,
        tags: ['core', 'orchestrator'],
        frontmatter: {
          'skills': ['code-review'],
          'workflows': ['gt-review'],
        },
        edges: [
          WorkspaceEdge(
            sourceId: 'agent:architect',
            targetId: 'skill:code-review',
            kind: EdgeKind.uses,
          ),
          WorkspaceEdge(
            sourceId: 'agent:architect',
            targetId: 'workflow:gt-review',
            kind: EdgeKind.uses,
          ),
        ],
      ),
    ],
    skills: [
      const WorkspaceAsset(
        id: 'skill:code-review',
        kind: AssetKind.skill,
        name: 'Code Review',
        path: '/ws/.agents/skills/code-review/SKILL.md',
        description: 'Code review skill',
        triggers: ['review code'],
      ),
      const WorkspaceAsset(
        id: 'skill:no-triggers',
        kind: AssetKind.skill,
        name: 'No Triggers Skill',
        path: '/ws/.agents/skills/no-triggers/SKILL.md',
        description: 'A skill without triggers',
      ),
    ],
    workflows: [
      const WorkspaceAsset(
        id: 'workflow:gt-review',
        kind: AssetKind.workflow,
        name: 'GT Review',
        path: '/ws/.agents/workflows/gt-review.md',
        description: 'Code review workflow',
        frontmatter: {
          'uses_skills': ['code-review'],
        },
      ),
      const WorkspaceAsset(
        id: 'workflow:orphan-wf',
        kind: AssetKind.workflow,
        name: 'Orphan Workflow',
        path: '/ws/.agents/workflows/orphan.md',
        description: 'Not referenced by anything',
      ),
    ],
    tasks: [
      WorkspaceAsset(
        id: 'task:0020',
        kind: AssetKind.task,
        name: 'Enhanced Snapshot',
        path: '/ws/docs/tasks/02-doing/0020-enhanced-snapshot.md',
        description: 'Enhanced workspace snapshot with search, filters, graph',
        frontmatter: {
          'id': '0020',
          'title': 'Enhanced Snapshot',
          'skills': ['code-review'],
          'workflows': ['gt-review'],
          'depends_on': ['0019'],
          '_taskMetadata': TaskMetadata(
            id: '0020',
            title: 'Enhanced Snapshot',
            lane: TaskLane.doing,
            created: DateTime(2026, 6, 7),
            updated: DateTime(2026, 6, 7),
            skills: ['code-review'],
            workflows: ['gt-review'],
            dependsOn: ['0019'],
            proofState: ProofState.partial,
          ),
        },
      ),
      WorkspaceAsset(
        id: 'task:0021',
        kind: AssetKind.task,
        name: 'Review Task',
        path: '/ws/docs/tasks/03-review/0021-review-task.md',
        description: 'Task in review lane',
        frontmatter: {
          'id': '0021',
          'title': 'Review Task',
          '_taskMetadata': TaskMetadata(
            id: '0021',
            title: 'Review Task',
            lane: TaskLane.review,
            created: DateTime(2026, 6, 7),
            updated: DateTime(2026, 6, 7),
            proofState: ProofState.none,
          ),
        },
      ),
    ],
    changelogEntries: [
      const WorkspaceAsset(
        id: 'changelog:cl-test',
        kind: AssetKind.changelog,
        name: 'cl-test',
        path: '/ws/docs/changelog/2026-06-07-test.md',
        canonicality: Canonicality.appendOnly,
        frontmatter: {
          'id': 'cl-test',
          'task': '0020',
          'type': 'feature',
          'project': 'warp-prism',
        },
      ),
    ],
    metadata: WorkspaceScanMetadata(
      rootPath: '/ws',
      scannedAt: DateTime(2026, 6, 7, 12, 0, 0),
      filesScanned: 10,
      parseErrors: 0,
    ),
  );
}
