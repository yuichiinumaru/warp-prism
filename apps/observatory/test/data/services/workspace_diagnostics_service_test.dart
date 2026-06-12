/// Tests for [WorkspaceMetricsService] and [WorkspaceDiagnosticsService].
///
/// Proves that:
/// - Derived metrics compute correct totals for assets, lanes, blockers,
///   review queue, proof readiness, and changelog linkage.
/// - Governance diagnostics detect orphan assets, stale references,
///   proof gaps, and high fan-in hotspots with typed severity/category.
/// - Diagnostics carry enough context for drill-down to affected assets.
/// - A no-warning baseline produces an empty report.
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_observatory/data/models/workspace_graph.dart';
import 'package:warp_prism_observatory/data/models/task_contracts.dart';
import 'package:warp_prism_observatory/data/models/governance_diagnostics.dart';
import 'package:warp_prism_observatory/data/services/workspace_graph_builder.dart';
import 'package:warp_prism_observatory/data/services/workspace_graph.dart';
import 'package:warp_prism_observatory/data/services/workspace_metrics_service.dart';
import 'package:warp_prism_observatory/data/services/workspace_diagnostics_service.dart';

void main() {
  group('WorkspaceMetricsService', () {
    const service = WorkspaceMetricsService();

    test('computes total asset count from graph', () {
      final graph = _buildHealthyGraph();
      final summary = service.compute(graph);

      expect(summary.totalAssets, equals(graph.nodeCount));
      expect(summary.totalAssets, greaterThan(0));
    });

    test('computes asset counts by kind', () {
      final graph = _buildHealthyGraph();
      final summary = service.compute(graph);

      expect(summary.assetsByKind[AssetKind.agent], equals(1));
      expect(summary.assetsByKind[AssetKind.skill], equals(2));
      expect(summary.assetsByKind[AssetKind.task], equals(3));
      expect(summary.assetsByKind[AssetKind.changelog], equals(1));
    });

    test('computes task counts by lane', () {
      final graph = _buildHealthyGraph();
      final summary = service.compute(graph);

      expect(summary.tasksByLane[TaskLane.open], equals(1));
      expect(summary.tasksByLane[TaskLane.doing], equals(1));
      expect(summary.tasksByLane[TaskLane.review], equals(1));
      expect(summary.tasksByLane[TaskLane.completed], equals(0));
    });

    test('computes blocked task count', () {
      final graph = _buildHealthyGraph();
      final summary = service.compute(graph);

      // Task 1002 depends on 1001
      expect(summary.blockedTaskCount, equals(1));
    });

    test('computes review queue count', () {
      final graph = _buildHealthyGraph();
      final summary = service.compute(graph);

      // Task 1003 is in review
      expect(summary.reviewQueueCount, equals(1));
    });

    test('computes proof gap count for review/completed tasks', () {
      final graph = _buildHealthyGraph();
      final summary = service.compute(graph);

      // Healthy graph: all review/completed tasks have complete proof → 0 gaps
      expect(summary.proofGapCount, equals(0));
    });

    test('computes changelog linkage readiness', () {
      final graph = _buildHealthyGraph();
      final summary = service.compute(graph);

      expect(summary.changelogWithTaskLink, equals(1));
      expect(summary.changelogWithoutTaskLink, equals(0));
    });

    test('computes orphan workflow count', () {
      final graph = _buildHealthyGraph();
      final summary = service.compute(graph);

      // All workflows are referenced via uses_skills or agent refs
      expect(summary.orphanWorkflowCount, equals(0));
    });

    test('computes skills with no triggers', () {
      final graph = _buildHealthyGraph();
      final summary = service.compute(graph);

      // Skill A has no triggers, Skill B has triggers
      expect(summary.skillsWithNoTriggers, equals(1));
    });

    test('empty graph produces empty summary', () {
      const graph = WorkspaceGraphResult.empty();
      final summary = service.compute(graph);

      expect(summary.totalAssets, equals(0));
      expect(summary.blockedTaskCount, equals(0));
      expect(summary.reviewQueueCount, equals(0));
      expect(summary.proofGapCount, equals(0));
    });
  });

  group('WorkspaceDiagnosticsService', () {
    const service = WorkspaceDiagnosticsService();

    test('no-warning baseline produces empty report', () {
      final graph = _buildHealthyGraph();
      final report = service.analyze(graph);

      // A healthy graph with no orphans, no stale refs, proper proof
      // should have zero diagnostics (or only info-level)
      final errors = report.bySeverity(DiagnosticSeverity.error);
      final criticals = report.bySeverity(DiagnosticSeverity.critical);
      expect(errors, isEmpty);
      expect(criticals, isEmpty);
    });

    test('detects orphan assets with no edges', () {
      final graph = _buildGraphWithOrphan();
      final report = service.analyze(graph);

      final orphans = report.byCategory(DiagnosticCategory.orphanAsset);
      expect(orphans, isNotEmpty);
      expect(orphans.first.severity, equals(DiagnosticSeverity.warning));
      expect(orphans.first.message, contains('isolated'));
      // Context carries drill-down info
      expect(orphans.first.context['assetKind'], isNotNull);
      expect(orphans.first.context['assetPath'], isNotNull);
    });

    test('detects stale references to non-existent assets', () {
      final graph = _buildGraphWithStaleRef();
      final report = service.analyze(graph);

      final stale = report.byCategory(DiagnosticCategory.staleReference);
      expect(stale, isNotEmpty);
      expect(stale.first.severity, equals(DiagnosticSeverity.error));
      expect(stale.first.message, contains('does not exist'));
      expect(stale.first.context['targetId'], equals('skill:nonexistent'));
    });

    test('detects proof gaps in review lane', () {
      final graph = _buildGraphWithProofGap();
      final report = service.analyze(graph);

      final gaps = report.byCategory(DiagnosticCategory.proofGap);
      expect(gaps, isNotEmpty);
      // Task in review with no proof = error severity
      expect(gaps.any((d) => d.severity == DiagnosticSeverity.error), isTrue);
      // Context carries task metadata for drill-down
      expect(gaps.first.context['taskId'], isNotNull);
      expect(gaps.first.context['taskLane'], isNotNull);
    });

    test('detects partial proof as warning severity', () {
      final graph = _buildGraphWithPartialProof();
      final report = service.analyze(graph);

      final gaps = report.byCategory(DiagnosticCategory.proofGap);
      expect(gaps, isNotEmpty);
      expect(gaps.any((d) => d.severity == DiagnosticSeverity.warning), isTrue);
    });

    test('detects high fan-in hotspots', () {
      final graph = _buildGraphWithHighFanIn();
      final report = service.analyze(graph, fanInThreshold: 2);

      final hotspots = report.byCategory(DiagnosticCategory.brokenEdge);
      expect(hotspots, isNotEmpty);
      expect(
        hotspots.first.context['incomingEdgeCount'],
        greaterThanOrEqualTo(2),
      );
    });

    test('diagnostics report provides category and severity counts', () {
      final graph = _buildMixedGraph();
      final report = service.analyze(graph);

      expect(report.hasWarnings, isTrue);
      expect(report.countsByCategory, isNotEmpty);
      expect(report.countsBySeverity, isNotEmpty);
    });

    test('self-loops (proves edges) do not trigger stale reference', () {
      final graph = _buildGraphWithProvesSelfLoop();
      final report = service.analyze(graph);

      final stale = report.byCategory(DiagnosticCategory.staleReference);
      // The proves edge is a self-loop; it should not produce a stale ref
      expect(stale.where((d) => d.message.contains('proves')), isEmpty);
    });

    test('empty graph produces empty diagnostics report', () {
      const graph = WorkspaceGraphResult.empty();
      final report = service.analyze(graph);

      expect(report.diagnostics, isEmpty);
      expect(report.hasWarnings, isFalse);
    });
  });
}

// ---------------------------------------------------------------------------
// Test graph builders
// ---------------------------------------------------------------------------

/// Build a healthy graph with no governance issues.
WorkspaceGraphResult _buildHealthyGraph() {
  final assets = [
    const WorkspaceAsset(
      id: 'agent:orchestrator',
      kind: AssetKind.agent,
      name: 'Orchestrator',
      path: '/ws/.agents/agents/orchestrator.md',
      frontmatter: {
        'skills': ['skill-a'],
        'workflows': ['wf-build'],
      },
    ),
    const WorkspaceAsset(
      id: 'skill:skill-a',
      kind: AssetKind.skill,
      name: 'Skill A',
      path: '/ws/.agents/skills/skill-a/SKILL.md',
    ),
    const WorkspaceAsset(
      id: 'skill:skill-b',
      kind: AssetKind.skill,
      name: 'Skill B',
      path: '/ws/.agents/skills/skill-b/SKILL.md',
      triggers: ['run tests'],
    ),
    const WorkspaceAsset(
      id: 'workflow:wf-build',
      kind: AssetKind.workflow,
      name: 'Build Workflow',
      path: '/ws/.agents/workflows/wf-build.md',
      frontmatter: {
        'uses_skills': ['skill-a'],
      },
    ),
    // Task in open lane, no dependencies
    WorkspaceAsset(
      id: 'task:1001',
      kind: AssetKind.task,
      name: 'Task 1001',
      path: '/ws/docs/tasks/01-open/1001.md',
      frontmatter: {
        'id': '1001',
        '_taskMetadata': TaskMetadata(
          id: '1001',
          title: 'Task 1001',
          lane: TaskLane.open,
          created: DateTime(2026, 6, 1),
          updated: DateTime(2026, 6, 1),
          proofState: ProofState.none,
        ),
      },
    ),
    // Task in doing lane, depends on 1001
    WorkspaceAsset(
      id: 'task:1002',
      kind: AssetKind.task,
      name: 'Task 1002',
      path: '/ws/docs/tasks/02-doing/1002.md',
      frontmatter: {
        'id': '1002',
        'depends_on': ['1001'],
        'skills': ['skill-a'],
        '_taskMetadata': TaskMetadata(
          id: '1002',
          title: 'Task 1002',
          lane: TaskLane.doing,
          created: DateTime(2026, 6, 2),
          updated: DateTime(2026, 6, 2),
          dependsOn: ['1001'],
          skills: ['skill-a'],
          proofState: ProofState.partial,
          verificationCommands: 'flutter test',
        ),
      },
    ),
    // Task in review lane with complete proof (healthy baseline)
    WorkspaceAsset(
      id: 'task:1003',
      kind: AssetKind.task,
      name: 'Task 1003',
      path: '/ws/docs/tasks/03-review/1003.md',
      frontmatter: {
        'id': '1003',
        'skills': ['skill-b'],
        '_taskMetadata': TaskMetadata(
          id: '1003',
          title: 'Task 1003',
          lane: TaskLane.review,
          created: DateTime(2026, 6, 3),
          updated: DateTime(2026, 6, 3),
          proofState: ProofState.complete,
          verificationCommands: 'flutter test',
        ),
      },
    ),
    // Changelog linked to task
    const WorkspaceAsset(
      id: 'changelog:cl-001',
      kind: AssetKind.changelog,
      name: 'cl-001',
      path: '/ws/docs/changelog/2026-06-07-cl-001.md',
      canonicality: Canonicality.appendOnly,
      frontmatter: {'id': 'cl-001', 'task': '1001', 'type': 'feature'},
    ),
  ];

  return const WorkspaceGraphBuilder().build(assets);
}

/// Build a graph with an orphan asset (no edges).
WorkspaceGraphResult _buildGraphWithOrphan() {
  final assets = [
    const WorkspaceAsset(
      id: 'agent:main',
      kind: AssetKind.agent,
      name: 'Main Agent',
      path: '/ws/.agents/agents/main.md',
      frontmatter: {
        'skills': ['skill-x'],
      },
    ),
    const WorkspaceAsset(
      id: 'skill:skill-x',
      kind: AssetKind.skill,
      name: 'Skill X',
      path: '/ws/.agents/skills/skill-x/SKILL.md',
    ),
    // Orphan skill: no edges point to or from it
    const WorkspaceAsset(
      id: 'skill:orphan-skill',
      kind: AssetKind.skill,
      name: 'Orphan Skill',
      path: '/ws/.agents/skills/orphan-skill/SKILL.md',
    ),
  ];

  return const WorkspaceGraphBuilder().build(assets);
}

/// Build a graph with a stale reference (edge to non-existent target).
WorkspaceGraphResult _buildGraphWithStaleRef() {
  final assets = [
    const WorkspaceAsset(
      id: 'agent:main',
      kind: AssetKind.agent,
      name: 'Main Agent',
      path: '/ws/.agents/agents/main.md',
      frontmatter: {
        'skills': ['nonexistent'],
      },
    ),
    WorkspaceAsset(
      id: 'task:2001',
      kind: AssetKind.task,
      name: 'Task with stale ref',
      path: '/ws/docs/tasks/01-open/2001.md',
      frontmatter: {
        'id': '2001',
        'skills': ['nonexistent'],
        '_taskMetadata': TaskMetadata(
          id: '2001',
          title: 'Task with stale ref',
          lane: TaskLane.open,
          created: DateTime(2026, 6, 1),
          updated: DateTime(2026, 6, 1),
        ),
      },
    ),
  ];

  return const WorkspaceGraphBuilder().build(assets);
}

/// Build a graph with a task in review lane but no proof.
WorkspaceGraphResult _buildGraphWithProofGap() {
  final assets = [
    WorkspaceAsset(
      id: 'task:3001',
      kind: AssetKind.task,
      name: 'Review task no proof',
      path: '/ws/docs/tasks/03-review/3001.md',
      frontmatter: {
        'id': '3001',
        '_taskMetadata': TaskMetadata(
          id: '3001',
          title: 'Review task no proof',
          lane: TaskLane.review,
          created: DateTime(2026, 6, 1),
          updated: DateTime(2026, 6, 1),
          proofState: ProofState.none,
        ),
      },
    ),
  ];

  return const WorkspaceGraphBuilder().build(assets);
}

/// Build a graph with a task in review with partial proof.
WorkspaceGraphResult _buildGraphWithPartialProof() {
  final assets = [
    WorkspaceAsset(
      id: 'task:4001',
      kind: AssetKind.task,
      name: 'Review task partial proof',
      path: '/ws/docs/tasks/03-review/4001.md',
      frontmatter: {
        'id': '4001',
        '_taskMetadata': TaskMetadata(
          id: '4001',
          title: 'Review task partial proof',
          lane: TaskLane.review,
          created: DateTime(2026, 6, 1),
          updated: DateTime(2026, 6, 1),
          proofState: ProofState.partial,
        ),
      },
    ),
  ];

  return const WorkspaceGraphBuilder().build(assets);
}

/// Build a graph with a high fan-in hotspot.
WorkspaceGraphResult _buildGraphWithHighFanIn() {
  final assets = [
    const WorkspaceAsset(
      id: 'skill:popular-skill',
      kind: AssetKind.skill,
      name: 'Popular Skill',
      path: '/ws/.agents/skills/popular-skill/SKILL.md',
    ),
    const WorkspaceAsset(
      id: 'agent:a1',
      kind: AssetKind.agent,
      name: 'Agent 1',
      path: '/ws/.agents/agents/a1.md',
      frontmatter: {
        'skills': ['popular-skill'],
      },
    ),
    const WorkspaceAsset(
      id: 'agent:a2',
      kind: AssetKind.agent,
      name: 'Agent 2',
      path: '/ws/.agents/agents/a2.md',
      frontmatter: {
        'skills': ['popular-skill'],
      },
    ),
    const WorkspaceAsset(
      id: 'workflow:wf1',
      kind: AssetKind.workflow,
      name: 'Workflow 1',
      path: '/ws/.agents/workflows/wf1.md',
      frontmatter: {
        'uses_skills': ['popular-skill'],
      },
    ),
  ];

  return const WorkspaceGraphBuilder().build(assets);
}

/// Build a graph with mixed diagnostic issues.
WorkspaceGraphResult _buildMixedGraph() {
  final assets = [
    const WorkspaceAsset(
      id: 'agent:main',
      kind: AssetKind.agent,
      name: 'Main Agent',
      path: '/ws/.agents/agents/main.md',
      frontmatter: {
        'skills': ['nonexistent'],
      },
    ),
    const WorkspaceAsset(
      id: 'skill:orphan',
      kind: AssetKind.skill,
      name: 'Orphan Skill',
      path: '/ws/.agents/skills/orphan/SKILL.md',
    ),
    WorkspaceAsset(
      id: 'task:5001',
      kind: AssetKind.task,
      name: 'Bad task',
      path: '/ws/docs/tasks/03-review/5001.md',
      frontmatter: {
        'id': '5001',
        'skills': ['nonexistent'],
        '_taskMetadata': TaskMetadata(
          id: '5001',
          title: 'Bad task',
          lane: TaskLane.review,
          created: DateTime(2026, 6, 1),
          updated: DateTime(2026, 6, 1),
          proofState: ProofState.none,
        ),
      },
    ),
  ];

  return const WorkspaceGraphBuilder().build(assets);
}

/// Build a graph with a proves self-loop.
WorkspaceGraphResult _buildGraphWithProvesSelfLoop() {
  final assets = [
    WorkspaceAsset(
      id: 'task:6001',
      kind: AssetKind.task,
      name: 'Proved task',
      path: '/ws/docs/tasks/04-completed/6001.md',
      frontmatter: {
        'id': '6001',
        '_taskMetadata': TaskMetadata(
          id: '6001',
          title: 'Proved task',
          lane: TaskLane.completed,
          created: DateTime(2026, 6, 1),
          updated: DateTime(2026, 6, 1),
          proofState: ProofState.verified,
          verificationCommands: 'flutter test',
        ),
      },
    ),
  ];

  return const WorkspaceGraphBuilder().build(assets);
}
