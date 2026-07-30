/// Tests for [WorkspaceGraphBuilder] and [EdgeInferenceService].
///
/// Proves that:
/// - One canonical graph result is emitted with typed assets and typed edges.
/// - Edge inference covers containment, routing, dependency, reference,
///   changed-by, proves, and usage relationships.
/// - Source path and canonicality metadata are preserved.
/// - A changelog entry can link to a task through normalized edges.
/// - A task can link to a workflow/skill/agent chain through normalized edges.
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_observatory/data/models/workspace_graph.dart';
import 'package:warp_prism_observatory/data/models/task_contracts.dart';
import 'package:warp_prism_observatory/data/services/workspace_graph_builder.dart';
import 'package:warp_prism_observatory/data/services/workspace_graph.dart';
import 'package:warp_prism_observatory/data/services/edge_inference_service.dart';

void main() {
  group('WorkspaceGraphBuilder', () {
    const builder = WorkspaceGraphBuilder();

    test('builds canonical graph from flat asset list', () {
      final assets = _buildSampleAssets();
      final graph = builder.build(assets);

      expect(graph.nodeCount, equals(assets.length));
      expect(graph.isEmpty, isFalse);
      expect(graph.assetsById.length, equals(assets.length));
    });

    test('groups assets by kind', () {
      final assets = _buildSampleAssets();
      final graph = builder.build(assets);

      expect(graph.assetsByKind[AssetKind.agent]!.length, equals(1));
      expect(graph.assetsByKind[AssetKind.skill]!.length, equals(2));
      expect(graph.assetsByKind[AssetKind.workflow]!.length, equals(1));
      expect(graph.assetsByKind[AssetKind.task]!.length, equals(2));
      expect(graph.assetsByKind[AssetKind.changelog]!.length, equals(1));
    });

    test('preserves source path and canonicality', () {
      final assets = _buildSampleAssets();
      final graph = builder.build(assets);

      final agent = graph.getAsset('agent:orchestrator')!;
      expect(agent.path, contains('.agents'));
      expect(agent.canonicality, equals(Canonicality.parentCanonical));

      final changelog = graph.getAsset('changelog:cl-001')!;
      expect(changelog.canonicality, equals(Canonicality.appendOnly));
    });

    test('changelog entry links to task through changedBy edge', () {
      final assets = _buildSampleAssets();
      final graph = builder.build(assets);

      final changelogEdges = graph.outgoingEdges('changelog:cl-001');
      final changedByEdges = changelogEdges
          .where((e) => e.kind == EdgeKind.changedBy)
          .toList();

      expect(changedByEdges, isNotEmpty);
      expect(changedByEdges.first.targetId, equals('task:1001'));
    });

    test('task links to skill and workflow through reference edges', () {
      final assets = _buildSampleAssets();
      final graph = builder.build(assets);

      final taskEdges = graph.outgoingEdges('task:1001');
      final refEdges = taskEdges
          .where((e) => e.kind == EdgeKind.references)
          .toList();

      expect(refEdges, isNotEmpty);
      final targetIds = refEdges.map((e) => e.targetId).toSet();
      expect(targetIds, contains('skill:code-review'));
      expect(targetIds, contains('workflow:gt-code-review'));
    });

    test('task has dependsOn edges to other tasks', () {
      final assets = _buildSampleAssets();
      final graph = builder.build(assets);

      final taskEdges = graph.outgoingEdges('task:1001');
      final depEdges = taskEdges
          .where((e) => e.kind == EdgeKind.dependsOn)
          .toList();

      expect(depEdges, isNotEmpty);
      expect(depEdges.first.targetId, equals('task:0999'));
    });

    test('agent has uses edges to skills and workflows', () {
      final assets = _buildSampleAssets();
      final graph = builder.build(assets);

      final agentEdges = graph.outgoingEdges('agent:orchestrator');
      final usesEdges = agentEdges
          .where((e) => e.kind == EdgeKind.uses)
          .toList();

      expect(usesEdges, isNotEmpty);
      final targetIds = usesEdges.map((e) => e.targetId).toSet();
      expect(targetIds, contains('skill:code-review'));
    });

    test('skill has contains edges to sub-skills', () {
      final assets = _buildSampleAssets();
      final graph = builder.build(assets);

      final skillEdges = graph.outgoingEdges('skill:harness-arch');
      final containsEdges = skillEdges
          .where((e) => e.kind == EdgeKind.contains)
          .toList();

      expect(containsEdges, isNotEmpty);
      expect(containsEdges.first.targetId, equals('subskill:create-agent'));
    });

    test('workflow has dependsOn edges to skills', () {
      final assets = _buildSampleAssets();
      final graph = builder.build(assets);

      final wfEdges = graph.outgoingEdges('workflow:gt-code-review');
      final depEdges = wfEdges
          .where((e) => e.kind == EdgeKind.dependsOn)
          .toList();

      expect(depEdges, isNotEmpty);
      expect(depEdges.first.targetId, equals('skill:code-review'));
    });

    test('getAsset returns null for unknown id', () {
      final assets = _buildSampleAssets();
      final graph = builder.build(assets);

      expect(graph.getAsset('nonexistent'), isNull);
    });

    test('incomingEdges returns edges targeting the given asset', () {
      final assets = _buildSampleAssets();
      final graph = builder.build(assets);

      final incomingToTask = graph.incomingEdges('task:1001');
      expect(incomingToTask, isNotEmpty);
      // The changelog points to this task
      expect(
        incomingToTask.any((e) => e.sourceId == 'changelog:cl-001'),
        isTrue,
      );
    });

    test('neighbors returns connected assets', () {
      final assets = _buildSampleAssets();
      final graph = builder.build(assets);

      final taskNeighbors = graph.neighbors('task:1001');
      expect(taskNeighbors, isNotEmpty);
      final neighborIds = taskNeighbors.map((a) => a.id).toSet();
      expect(neighborIds, contains('skill:code-review'));
    });

    test('edgesByKind filters edges by kind', () {
      final assets = _buildSampleAssets();
      final graph = builder.build(assets);

      final containsEdges = graph.edgesByKind(EdgeKind.contains);
      expect(containsEdges, isNotEmpty);
      expect(containsEdges.every((e) => e.kind == EdgeKind.contains), isTrue);
    });

    test('deduplicates edges with same source, target, and kind', () {
      // Add duplicate edge to an asset
      final dupeEdge = WorkspaceEdge(
        sourceId: 'task:1001',
        targetId: 'skill:code-review',
        kind: EdgeKind.references,
      );
      final assets = [
        ..._buildSampleAssets(),
        WorkspaceAsset(
          id: 'task:1001-dup',
          kind: AssetKind.task,
          name: 'Dup task',
          path: 'docs/tasks/01-open/dup.md',
          edges: [dupeEdge], // Same edge as task:1001
        ),
      ];

      final graph = builder.build(assets);
      // Count edges with same source/target/kind
      final matching = graph.edges
          .where(
            (e) =>
                e.sourceId == 'task:1001' &&
                e.targetId == 'skill:code-review' &&
                e.kind == EdgeKind.references,
          )
          .toList();
      // Should be deduplicated per source — each source contributes its own edge
      // The dedup is per unique (source, target, kind) triple
      expect(matching.length, equals(1));
    });

    test('empty asset list produces empty graph', () {
      final graph = builder.build([]);
      expect(graph.isEmpty, isTrue);
      expect(graph.nodeCount, equals(0));
      expect(graph.edgeCount, equals(0));
    });
  });

  group('EdgeInferenceService', () {
    const inference = EdgeInferenceService();

    test('inferContainment creates edges from skill to sub-skills', () {
      final edges = inference.inferContainment(
        skillId: 'skill:parent',
        subSkills: ['child-a', 'child-b'],
      );
      expect(edges.length, equals(2));
      expect(edges[0].sourceId, equals('skill:parent'));
      expect(edges[0].targetId, equals('subskill:child-a'));
      expect(edges[0].kind, equals(EdgeKind.contains));
    });

    test('inferRouting creates routesTo edges', () {
      final edges = inference.inferRouting(
        skillId: 'skill:gateway',
        routesTo: ['subskill:handler', 'workflow:process'],
      );
      expect(edges.length, equals(2));
      expect(edges[0].kind, equals(EdgeKind.routesTo));
    });

    test('inferWorkflowDependencies creates dependsOn edges', () {
      final edges = inference.inferWorkflowDependencies(
        workflowId: 'workflow:build',
        usesSkills: ['compile', 'test'],
      );
      expect(edges.length, equals(2));
      expect(edges[0].kind, equals(EdgeKind.dependsOn));
      expect(edges[0].targetId, equals('skill:compile'));
    });

    test('inferChangelogLinkage creates changedBy edge', () {
      final edges = inference.inferChangelogLinkage(
        changelogId: 'changelog:cl-1',
        task: '42',
      );
      expect(edges.length, equals(1));
      expect(edges[0].kind, equals(EdgeKind.changedBy));
      expect(edges[0].targetId, equals('task:42'));
    });

    test('inferChangelogLinkage returns empty for null task', () {
      final edges = inference.inferChangelogLinkage(
        changelogId: 'changelog:cl-1',
        task: null,
      );
      expect(edges, isEmpty);
    });

    test('inferAgentUsage creates uses edges with exact targetIds', () {
      final edges = inference.inferAgentUsage(
        agentId: 'agent:builder',
        skills: ['skill:code-gen'],
        workflows: ['workflow:deploy'],
      );
      expect(edges.length, equals(2));
      expect(edges.every((e) => e.kind == EdgeKind.uses), isTrue);
      expect(edges[0].targetId, equals('skill:code-gen'));
      expect(edges[1].targetId, equals('workflow:deploy'));
      // Never double-prefix already-prefixed inputs.
      expect(edges.any((e) => e.targetId.contains('skill:skill:')), isFalse);
      expect(
        edges.any((e) => e.targetId.contains('workflow:workflow:')),
        isFalse,
      );
    });

    test('inferAgentUsage normalizes bare and double-prefixed ids', () {
      final edges = inference.inferAgentUsage(
        agentId: 'agent:builder',
        skills: ['code-gen', 'skill:code-gen', 'skill:skill:code-gen'],
        workflows: ['deploy', 'workflow:deploy'],
      );
      expect(edges.map((e) => e.targetId).toSet(), equals({
        'skill:code-gen',
        'workflow:deploy',
      }));
    });

    test('normalizeAssetId strips repeated kind prefixes', () {
      expect(normalizeAssetId('skill', 'code-gen'), equals('skill:code-gen'));
      expect(
        normalizeAssetId('skill', 'skill:code-gen'),
        equals('skill:code-gen'),
      );
      expect(
        normalizeAssetId('skill', 'skill:skill:code-gen'),
        equals('skill:code-gen'),
      );
      expect(
        normalizeAssetId('workflow', 'workflow:build'),
        equals('workflow:build'),
      );
    });

    test('inferPathContainment extracts skill from path', () {
      final edge = inference.inferPathContainment(
        workflowPath: '/root/.agents/skills/harness/workflows/build.md',
        skillDirectoryPattern: 'harness',
      );
      expect(edge, isNotNull);
      expect(edge!.sourceId, equals('skill:harness'));
      expect(edge.targetId, equals('workflow:build'));
      expect(edge.kind, equals(EdgeKind.contains));
    });

    test('inferPathContainment returns null for non-matching path', () {
      final edge = inference.inferPathContainment(
        workflowPath: '/root/.agents/workflows/build.md',
        skillDirectoryPattern: 'harness',
      );
      expect(edge, isNull);
    });

    test('inferPathContainment returns null when skill ≠ pattern', () {
      final edge = inference.inferPathContainment(
        workflowPath: '/root/.agents/skills/other/workflows/build.md',
        skillDirectoryPattern: 'harness',
      );
      expect(edge, isNull);
    });

    test('inferProofLinkage creates proves edge when proof state present', () {
      final edges = inference.inferProofLinkage(
        taskId: 'task:42',
        proofState: ProofState.complete,
        hasVerificationCommands: true,
      );
      expect(edges.length, equals(1));
      expect(edges[0].kind, equals(EdgeKind.proves));
      expect(edges[0].metadata['proofState'], equals('complete'));
    });

    test('inferProofLinkage returns empty when proof state is none', () {
      final edges = inference.inferProofLinkage(
        taskId: 'task:42',
        proofState: ProofState.none,
        hasVerificationCommands: true,
      );
      expect(edges, isEmpty);
    });
  });

  group('WorkspaceGraphResult', () {
    test('empty constructor produces empty graph', () {
      const graph = WorkspaceGraphResult.empty();
      expect(graph.isEmpty, isTrue);
      expect(graph.nodeCount, equals(0));
      expect(graph.edgeCount, equals(0));
    });

    test('referencingAssets finds assets with incoming edges', () {
      final assets = _buildSampleAssets();
      const builder = WorkspaceGraphBuilder();
      final graph = builder.build(assets);

      final referencing = graph.referencingAssets('task:1001');
      expect(referencing, isNotEmpty);
      expect(referencing.any((a) => a.id == 'changelog:cl-001'), isTrue);
    });
  });
}

/// Build a sample set of assets for testing.
List<WorkspaceAsset> _buildSampleAssets() {
  return [
    // Agent
    const WorkspaceAsset(
      id: 'agent:orchestrator',
      kind: AssetKind.agent,
      name: 'Orchestrator',
      path: '/ws/.agents/agents/orchestrator.md',
      description: 'Build orchestrator',
      canonicality: Canonicality.parentCanonical,
      frontmatter: {
        'name': 'Orchestrator',
        'skills': ['code-review'],
        'workflows': ['gt-code-review'],
      },
      tags: ['core'],
    ),

    // Skill with sub-skill
    const WorkspaceAsset(
      id: 'skill:harness-arch',
      kind: AssetKind.skill,
      name: 'Harness Architecture',
      path: '/ws/.agents/skills/harness-arch/SKILL.md',
      description: 'Harness architecture skill',
      frontmatter: {
        'name': 'Harness Architecture',
        'sub_skills': ['create-agent'],
      },
    ),

    // Sub-skill
    const WorkspaceAsset(
      id: 'subskill:create-agent',
      kind: AssetKind.subskill,
      name: 'Create Agent',
      path: '/ws/.agents/skills/harness-arch/sub-skills/create-agent/SKILL.md',
      description: 'Create agent sub-skill',
    ),

    // Skill referenced by tasks and workflows
    const WorkspaceAsset(
      id: 'skill:code-review',
      kind: AssetKind.skill,
      name: 'Code Review',
      path: '/ws/.agents/skills/code-review/SKILL.md',
      description: 'Code review skill',
      triggers: ['review code'],
    ),

    // Workflow with skill dependency
    const WorkspaceAsset(
      id: 'workflow:gt-code-review',
      kind: AssetKind.workflow,
      name: 'GT Code Review',
      path: '/ws/.agents/workflows/gt-code-review.md',
      description: 'Code review workflow',
      frontmatter: {
        'uses_skills': ['code-review'],
      },
    ),

    // Task with references and dependencies
    WorkspaceAsset(
      id: 'task:1001',
      kind: AssetKind.task,
      name: 'Build Parser',
      path: '/ws/docs/tasks/02-doing/1001-build-parser.md',
      description: 'Build the workspace parser',
      frontmatter: {
        'id': '1001',
        'title': 'Build Parser',
        'skills': ['code-review'],
        'workflows': ['gt-code-review'],
        'depends_on': ['0999'],
        '_taskMetadata': TaskMetadata(
          id: '1001',
          title: 'Build Parser',
          lane: TaskLane.doing,
          created: DateTime(2026, 6, 7),
          updated: DateTime(2026, 6, 7),
          skills: ['code-review'],
          workflows: ['gt-code-review'],
          dependsOn: ['0999'],
          proofState: ProofState.partial,
        ),
      },
    ),

    // Dependency target task
    const WorkspaceAsset(
      id: 'task:0999',
      kind: AssetKind.task,
      name: 'Design Contract',
      path: '/ws/docs/tasks/04-completed/0999-design-contract.md',
      frontmatter: {'id': '0999'},
    ),

    // Changelog entry linked to task
    const WorkspaceAsset(
      id: 'changelog:cl-001',
      kind: AssetKind.changelog,
      name: 'cl-001',
      path: '/ws/docs/changelog/2026-06-07-parser.md',
      canonicality: Canonicality.appendOnly,
      frontmatter: {'id': 'cl-001', 'task': '1001', 'type': 'feature'},
    ),
  ];
}
