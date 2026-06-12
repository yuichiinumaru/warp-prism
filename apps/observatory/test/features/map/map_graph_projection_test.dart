/// Tests for Map graph projection by mode.
///
/// Verifies that the same normalized asset/edge set produces different
/// node/edge projections under containment, operational, and evidence
/// modes — and that an empty-edge dataset returns zero edges for any
/// mode.
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_observatory/data/models/workspace_graph.dart';
import 'package:warp_prism_observatory/features/map/graph/map_graph_mode.dart';
import 'package:warp_prism_observatory/features/map/graph/map_graph_projection.dart';

void main() {
  // Shared test corpus: a small normalized graph with diverse edge kinds.
  final assets = [
    const WorkspaceAsset(
      id: 'agent:a1',
      kind: AssetKind.agent,
      name: 'Agent A',
      path: '.agents/agents/a1.md',
    ),
    const WorkspaceAsset(
      id: 'skill:s1',
      kind: AssetKind.skill,
      name: 'Skill S1',
      path: '.agents/skills/s1.md',
    ),
    const WorkspaceAsset(
      id: 'workflow:w1',
      kind: AssetKind.workflow,
      name: 'Workflow W1',
      path: '.agents/workflows/w1.md',
    ),
    const WorkspaceAsset(
      id: 'task:t1',
      kind: AssetKind.task,
      name: 'Task T1',
      path: 'docs/tasks/02-doing/t1.md',
    ),
    const WorkspaceAsset(
      id: 'changelog:c1',
      kind: AssetKind.changelog,
      name: 'Changelog C1',
      path: 'docs/changelog/c1.md',
    ),
  ];

  // Edges covering all seven EdgeKind values.
  final edges = [
    // containment edges
    const WorkspaceEdge(
      sourceId: 'skill:s1',
      targetId: 'skill:sub1',
      kind: EdgeKind.contains,
    ),
    const WorkspaceEdge(
      sourceId: 'skill:s1',
      targetId: 'workflow:w1',
      kind: EdgeKind.routesTo,
    ),
    // operational edges
    const WorkspaceEdge(
      sourceId: 'agent:a1',
      targetId: 'skill:s1',
      kind: EdgeKind.uses,
    ),
    const WorkspaceEdge(
      sourceId: 'task:t1',
      targetId: 'skill:s1',
      kind: EdgeKind.dependsOn,
    ),
    // evidence edges
    const WorkspaceEdge(
      sourceId: 'task:t1',
      targetId: 'skill:s1',
      kind: EdgeKind.proves,
    ),
    const WorkspaceEdge(
      sourceId: 'changelog:c1',
      targetId: 'task:t1',
      kind: EdgeKind.changedBy,
    ),
    const WorkspaceEdge(
      sourceId: 'agent:a1',
      targetId: 'skill:s1',
      kind: EdgeKind.references,
    ),
  ];

  group('MapGraphProjection', () {
    test('containment mode includes only contains and routesTo edges', () {
      final projection = projectGraph(
        assets: assets,
        edges: edges,
        mode: MapGraphMode.containment,
      );

      expect(projection.mode, MapGraphMode.containment);
      // 2 containment edges (contains + routesTo)
      expect(projection.edgeCount, 2);
      // All 5 assets are nodes
      expect(projection.nodeCount, 5);
      expect(projection.isEmpty, isFalse);

      // Verify edge types
      final edgeTypes = projection.edges.map((e) => e.edgeType).toSet();
      expect(edgeTypes, {'contains', 'routesTo'});
    });

    test('operational mode includes uses, dependsOn, and routesTo edges', () {
      final projection = projectGraph(
        assets: assets,
        edges: edges,
        mode: MapGraphMode.operational,
      );

      expect(projection.mode, MapGraphMode.operational);
      // 3 operational edges (uses + dependsOn + routesTo)
      expect(projection.edgeCount, 3);
      expect(projection.nodeCount, 5);

      final edgeTypes = projection.edges.map((e) => e.edgeType).toSet();
      expect(edgeTypes, {'uses', 'dependsOn', 'routesTo'});
    });

    test('evidence mode includes proves, changedBy, and references edges', () {
      final projection = projectGraph(
        assets: assets,
        edges: edges,
        mode: MapGraphMode.evidence,
      );

      expect(projection.mode, MapGraphMode.evidence);
      // 3 evidence edges (proves + changedBy + references)
      expect(projection.edgeCount, 3);
      expect(projection.nodeCount, 5);

      final edgeTypes = projection.edges.map((e) => e.edgeType).toSet();
      expect(edgeTypes, {'proves', 'changedBy', 'references'});
    });

    test('all three modes derive from the same asset list', () {
      for (final mode in MapGraphMode.values) {
        final projection = projectGraph(
          assets: assets,
          edges: edges,
          mode: mode,
        );
        // Every mode has the same number of nodes
        expect(
          projection.nodeCount,
          5,
          reason: 'Mode ${mode.name} should have 5 nodes',
        );
      }
    });

    test('empty edges returns zero edges for every mode', () {
      for (final mode in MapGraphMode.values) {
        final projection = projectGraph(
          assets: assets,
          edges: const [],
          mode: mode,
        );
        expect(
          projection.isEmpty,
          isTrue,
          reason: 'Mode ${mode.name} should have 0 edges with empty input',
        );
        expect(projection.edgeCount, 0);
        expect(projection.nodeCount, 5); // nodes still present
      }
    });

    test('assetsWithEdges counts only connected assets', () {
      final projection = projectGraph(
        assets: assets,
        edges: edges,
        mode: MapGraphMode.containment,
      );
      // Containment edges: skill:s1 -> skill:sub1, skill:s1 -> workflow:w1
      // Connected: skill:s1, skill:sub1, workflow:w1
      expect(projection.assetsWithEdges, 3);
    });

    test('mode with no matching edges returns zero edges but all nodes', () {
      // Only containment edges available
      final containmentOnlyEdges = [
        const WorkspaceEdge(
          sourceId: 'skill:s1',
          targetId: 'workflow:w1',
          kind: EdgeKind.contains,
        ),
      ];

      final projection = projectGraph(
        assets: assets,
        edges: containmentOnlyEdges,
        mode: MapGraphMode.evidence,
      );

      expect(projection.edgeCount, 0);
      expect(projection.nodeCount, 5);
      expect(projection.isEmpty, isTrue);
    });

    test('edgeKindsForMode returns correct sets', () {
      expect(edgeKindsForMode(MapGraphMode.containment), {
        EdgeKind.contains,
        EdgeKind.routesTo,
      });
      expect(edgeKindsForMode(MapGraphMode.operational), {
        EdgeKind.uses,
        EdgeKind.dependsOn,
        EdgeKind.routesTo,
      });
      expect(edgeKindsForMode(MapGraphMode.evidence), {
        EdgeKind.proves,
        EdgeKind.changedBy,
        EdgeKind.references,
      });
    });

    test('labelForMode returns human-readable names', () {
      expect(labelForMode(MapGraphMode.containment), 'Containment');
      expect(labelForMode(MapGraphMode.operational), 'Operational');
      expect(labelForMode(MapGraphMode.evidence), 'Evidence');
    });
  });
}
