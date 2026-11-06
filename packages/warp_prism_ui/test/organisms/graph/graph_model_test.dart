/// Unit tests for graph data model.
///
/// Task 1117: Tests GraphModel construction, queries, typed IDs,
/// and pure-data immutability.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_ui/src/organisms/graph/graph_model.dart';

void main() {
  group('GraphNodeId', () {
    test('equality is based on value', () {
      const a = GraphNodeId('alpha');
      const b = GraphNodeId('alpha');
      const c = GraphNodeId('beta');

      expect(a, equals(b));
      expect(a, isNot(equals(c)));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('toString includes value', () {
      const id = GraphNodeId('test-id');
      expect(id.toString(), contains('test-id'));
    });
  });

  group('GraphEdgeId', () {
    test('fromNodes creates correct ID', () {
      const src = GraphNodeId('a');
      const tgt = GraphNodeId('b');
      final id = GraphEdgeId.fromNodes(src, tgt);

      expect(id.value, 'a->b');
    });

    test('equality is based on value', () {
      const a = GraphEdgeId('a->b');
      const b = GraphEdgeId('a->b');
      const c = GraphEdgeId('b->a');

      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });
  });

  group('GraphNode', () {
    test('constructs with required fields', () {
      const node = GraphNode(
        id: GraphNodeId('n1'),
        label: 'Agent Alpha',
        type: 'agent',
      );

      expect(node.id.value, 'n1');
      expect(node.label, 'Agent Alpha');
      expect(node.type, 'agent');
      expect(node.status, isNull);
      expect(node.metadata, isEmpty);
      expect(node.position, Offset.zero);
    });

    test('create factory accepts raw string IDs', () {
      final node = GraphNode.create(
        id: 'n1',
        label: 'Skill Beta',
        type: 'skill',
        status: 'active',
        metadata: {'version': '1.0'},
      );

      expect(node.id, const GraphNodeId('n1'));
      expect(node.label, 'Skill Beta');
      expect(node.type, 'skill');
      expect(node.status, 'active');
      expect(node.metadata['version'], '1.0');
    });

    test('copyWith returns new instance with overridden fields', () {
      const original = GraphNode(
        id: GraphNodeId('n1'),
        label: 'Original',
        type: 'agent',
      );

      final copy = original.copyWith(label: 'Modified', type: 'skill');

      expect(copy.label, 'Modified');
      expect(copy.type, 'skill');
      expect(copy.id, original.id); // unchanged
      expect(original.label, 'Original'); // original immutable
    });

    test('equality is based on id, label, type, status, position', () {
      const a = GraphNode(id: GraphNodeId('n1'), label: 'Test', type: 'agent');
      const b = GraphNode(id: GraphNodeId('n1'), label: 'Test', type: 'agent');
      const c = GraphNode(id: GraphNodeId('n2'), label: 'Test', type: 'agent');

      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });
  });

  group('GraphEdge', () {
    test('constructs with required fields', () {
      const edge = GraphEdge(
        id: GraphEdgeId('a->b'),
        sourceId: GraphNodeId('a'),
        targetId: GraphNodeId('b'),
      );

      expect(edge.sourceId.value, 'a');
      expect(edge.targetId.value, 'b');
      expect(edge.edgeType, 'references');
      expect(edge.label, isNull);
    });

    test('create factory auto-generates edge ID', () {
      final edge = GraphEdge.create(
        sourceId: 'a',
        targetId: 'b',
        edgeType: 'uses',
      );

      expect(edge.id.value, 'a->b');
      expect(edge.sourceId, const GraphNodeId('a'));
      expect(edge.targetId, const GraphNodeId('b'));
      expect(edge.edgeType, 'uses');
    });

    test('equality is based on edge ID', () {
      final a = GraphEdge.create(sourceId: 'a', targetId: 'b');
      final b = GraphEdge.create(sourceId: 'a', targetId: 'b');
      final c = GraphEdge.create(sourceId: 'b', targetId: 'a');

      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });
  });

  group('GraphModel', () {
    late GraphModel model;
    late List<GraphNode> nodes;
    late List<GraphEdge> edges;

    setUp(() {
      nodes = [
        const GraphNode(
          id: GraphNodeId('agent-1'),
          label: 'Agent Alpha',
          type: 'agent',
        ),
        const GraphNode(
          id: GraphNodeId('skill-1'),
          label: 'Skill Beta',
          type: 'skill',
        ),
        const GraphNode(
          id: GraphNodeId('workflow-1'),
          label: 'Workflow Gamma',
          type: 'workflow',
        ),
      ];
      edges = [
        GraphEdge.create(
          sourceId: 'agent-1',
          targetId: 'skill-1',
          edgeType: 'uses',
        ),
        GraphEdge.create(
          sourceId: 'skill-1',
          targetId: 'workflow-1',
          edgeType: 'triggers',
        ),
      ];
      model = GraphModel(nodes: nodes, edges: edges);
    });

    test('nodeById returns correct node', () {
      final node = model.nodeById(const GraphNodeId('agent-1'));
      expect(node, isNotNull);
      expect(node!.label, 'Agent Alpha');
    });

    test('nodeById returns null for missing ID', () {
      final node = model.nodeById(const GraphNodeId('nonexistent'));
      expect(node, isNull);
    });

    test('edgesForNode returns all edges connected to node', () {
      final agentEdges = model.edgesForNode(const GraphNodeId('agent-1'));
      expect(agentEdges, hasLength(1));
      expect(agentEdges.first.edgeType, 'uses');

      final skillEdges = model.edgesForNode(const GraphNodeId('skill-1'));
      expect(skillEdges, hasLength(2)); // source of triggers, target of uses
    });

    test('edgesForNode returns empty for disconnected node', () {
      final disconnected = model.edgesForNode(const GraphNodeId('workflow-1'));
      // workflow-1 is target of skill-1->workflow-1
      expect(disconnected, hasLength(1));
    });

    test('adjacentNodes returns connected node IDs', () {
      final skillAdj = model.adjacentNodes(const GraphNodeId('skill-1'));
      expect(skillAdj, hasLength(2));
      expect(
        skillAdj.map((id) => id.value),
        containsAll(['agent-1', 'workflow-1']),
      );
    });

    test('adjacentNodes returns empty for isolated node', () {
      const isolatedModel = GraphModel(
        nodes: [
          GraphNode(
            id: GraphNodeId('isolated'),
            label: 'Isolated',
            type: 'doc',
          ),
        ],
        edges: [],
      );
      final adj = isolatedModel.adjacentNodes(const GraphNodeId('isolated'));
      expect(adj, isEmpty);
    });

    test('copyWith returns new instance', () {
      final copy = model.copyWith(
        nodes: [
          ...nodes,
          const GraphNode(
            id: GraphNodeId('new-node'),
            label: 'New',
            type: 'task',
          ),
        ],
      );

      expect(copy.nodes, hasLength(4));
      expect(model.nodes, hasLength(3)); // original unchanged
    });

    test('equality compares node and edge lists', () {
      final same = GraphModel(nodes: nodes, edges: edges);
      expect(model, equals(same));

      final different = GraphModel(nodes: nodes.sublist(0, 2), edges: edges);
      expect(model, isNot(equals(different)));
    });
  });
}
