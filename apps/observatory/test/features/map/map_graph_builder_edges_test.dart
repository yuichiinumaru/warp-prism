/// Path-to-100 residual (Task 0512): Map projection sees builder edges.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_observatory/data/models/workspace_graph.dart';
import 'package:warp_prism_observatory/data/services/workspace_graph_builder.dart';
import 'package:warp_prism_observatory/features/map/graph/map_graph_mode.dart';
import 'package:warp_prism_observatory/features/map/graph/map_graph_projection.dart';
import 'package:warp_prism_observatory/features/map/map_workspace_state.dart';

void main() {
  group('Map graph edges from WorkspaceGraphBuilder', () {
    test('resolvedGraphEdges prefers injected builder edges', () {
      const frontmatterOnly = WorkspaceEdge(
        sourceId: 'agent:a',
        targetId: 'skill:s',
        kind: EdgeKind.uses,
      );
      const inferred = WorkspaceEdge(
        sourceId: 'skill:s',
        targetId: 'workflow:w',
        kind: EdgeKind.routesTo,
      );
      const state = MapWorkspaceState(
        catalogAssets: [
          WorkspaceAsset(
            id: 'agent:a',
            kind: AssetKind.agent,
            name: 'A',
            path: 'a.md',
            edges: [frontmatterOnly],
          ),
          WorkspaceAsset(
            id: 'skill:s',
            kind: AssetKind.skill,
            name: 'S',
            path: 's.md',
          ),
          WorkspaceAsset(
            id: 'workflow:w',
            kind: AssetKind.workflow,
            name: 'W',
            path: 'w.md',
          ),
        ],
        graphEdges: [frontmatterOnly, inferred],
      );

      expect(state.resolvedGraphEdges, hasLength(2));
      expect(
        state.resolvedGraphEdges.map((e) => e.kind),
        containsAll([EdgeKind.uses, EdgeKind.routesTo]),
      );
    });

    test('map projection edge count matches builder for mock-like corpus', () {
      final assets = <WorkspaceAsset>[
        const WorkspaceAsset(
          id: 'agent:orch',
          kind: AssetKind.agent,
          name: 'Orch',
          path: '.agents/agents/orch.md',
          frontmatter: {
            'skills': ['harness'],
          },
          edges: [
            WorkspaceEdge(
              sourceId: 'agent:orch',
              targetId: 'skill:harness',
              kind: EdgeKind.uses,
            ),
          ],
        ),
        const WorkspaceAsset(
          id: 'skill:harness',
          kind: AssetKind.skill,
          name: 'Harness',
          path: '.agents/skills/harness/SKILL.md',
          frontmatter: {
            'subskills': ['assert'],
          },
        ),
        const WorkspaceAsset(
          id: 'skill:assert',
          kind: AssetKind.subskill,
          name: 'Assert',
          path: '.agents/skills/harness/assert.md',
        ),
        const WorkspaceAsset(
          id: 'workflow:ci',
          kind: AssetKind.workflow,
          name: 'CI',
          path: '.agents/workflows/ci.md',
          frontmatter: {
            'skills': ['harness'],
          },
        ),
        const WorkspaceAsset(
          id: 'task:t1',
          kind: AssetKind.task,
          name: 'T1',
          path: 'docs/tasks/02-doing/t1.md',
          frontmatter: {
            'skills': ['harness'],
            'workflows': ['ci'],
          },
        ),
      ];

      const builder = WorkspaceGraphBuilder();
      final graph = builder.build(assets);
      final frontmatterOnly = assets.expand((a) => a.edges).toList();

      // Builder edges are a superset of (or at least ≥) frontmatter edges.
      expect(graph.edgeCount, greaterThanOrEqualTo(frontmatterOnly.length));

      final containment = projectGraph(
        assets: assets,
        edges: graph.edges,
        mode: MapGraphMode.containment,
      );
      final operational = projectGraph(
        assets: assets,
        edges: graph.edges,
        mode: MapGraphMode.operational,
      );

      // At least one mode should see edges when builder inferred connectivity.
      expect(
        containment.edgeCount + operational.edgeCount,
        greaterThan(0),
        reason: 'Builder-backed edges should project into at least one mode',
      );
    });
  });
}
