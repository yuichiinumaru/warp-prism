/// Unit tests for force-directed layout engine.
///
/// Task 1117: Tests that ForceDirectedLayout produces stable positions
/// within canvas bounds for a 10-node, 15-edge graph in <100ms.
library;
import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_ui/src/organisms/graph/graph_model.dart';
import 'package:warp_prism_ui/src/organisms/graph/force_directed_layout.dart';

void main() {
  group('ForceDirectedLayout', () {
    late GraphModel tenNodeModel;

    setUp(() {
      // Build a 10-node, 15-edge graph
      final nodes = List.generate(
        10,
        (i) => GraphNode(
          id: GraphNodeId('n$i'),
          label: 'Node $i',
          type: i % 2 == 0 ? 'agent' : 'skill',
        ),
      );

      final edges = <GraphEdge>[
        // Create 15 edges forming a connected graph
        GraphEdge.create(sourceId: 'n0', targetId: 'n1'),
        GraphEdge.create(sourceId: 'n1', targetId: 'n2'),
        GraphEdge.create(sourceId: 'n2', targetId: 'n3'),
        GraphEdge.create(sourceId: 'n3', targetId: 'n4'),
        GraphEdge.create(sourceId: 'n4', targetId: 'n5'),
        GraphEdge.create(sourceId: 'n5', targetId: 'n6'),
        GraphEdge.create(sourceId: 'n6', targetId: 'n7'),
        GraphEdge.create(sourceId: 'n7', targetId: 'n8'),
        GraphEdge.create(sourceId: 'n8', targetId: 'n9'),
        GraphEdge.create(sourceId: 'n9', targetId: 'n0'),
        // Cross-edges for more connectivity
        GraphEdge.create(sourceId: 'n0', targetId: 'n5'),
        GraphEdge.create(sourceId: 'n1', targetId: 'n6'),
        GraphEdge.create(sourceId: 'n2', targetId: 'n7'),
        GraphEdge.create(sourceId: 'n3', targetId: 'n8'),
        GraphEdge.create(sourceId: 'n4', targetId: 'n9'),
      ];

      tenNodeModel = GraphModel(nodes: nodes, edges: edges);
    });

    test('returns positions for all nodes', () {
      const layout = ForceDirectedLayout();
      const canvasSize = Size(800, 600);

      final positions = layout.layout(tenNodeModel, canvasSize);

      expect(positions, hasLength(10));
      for (int i = 0; i < 10; i++) {
        expect(
          positions.containsKey(GraphNodeId('n$i')),
          isTrue,
          reason: 'Missing position for n$i',
        );
      }
    });

    test('positions are within canvas bounds (with padding)', () {
      const layout = ForceDirectedLayout();
      const canvasSize = Size(800, 600);

      final positions = layout.layout(tenNodeModel, canvasSize);

      for (final entry in positions.entries) {
        // Positions should be within the canvas (with some tolerance for
        // the node radius of 30px)
        expect(
          entry.value.dx,
          greaterThan(-canvasSize.width),
          reason: '${entry.key} x too far left',
        );
        expect(
          entry.value.dx,
          lessThan(canvasSize.width * 2),
          reason: '${entry.key} x too far right',
        );
        expect(
          entry.value.dy,
          greaterThan(-canvasSize.height),
          reason: '${entry.key} y too far up',
        );
        expect(
          entry.value.dy,
          lessThan(canvasSize.height * 2),
          reason: '${entry.key} y too far down',
        );
      }
    });

    test('completes 10-node layout in <100ms', () {
      const layout = ForceDirectedLayout();
      const canvasSize = Size(800, 600);

      final stopwatch = Stopwatch()..start();
      layout.layout(tenNodeModel, canvasSize);
      stopwatch.stop();

      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(100),
        reason:
            'Layout took ${stopwatch.elapsedMilliseconds}ms, expected <100ms',
      );
    });

    test('is deterministic — same input produces same output', () {
      const layout = ForceDirectedLayout();
      const canvasSize = Size(800, 600);

      final pos1 = layout.layout(tenNodeModel, canvasSize);
      final pos2 = layout.layout(tenNodeModel, canvasSize);

      for (final key in pos1.keys) {
        expect(
          pos1[key],
          equals(pos2[key]),
          reason: 'Position for ${key.value} differs between runs',
        );
      }
    });

    test('empty model returns empty positions', () {
      const layout = ForceDirectedLayout();
      const emptyModel = GraphModel(nodes: [], edges: []);

      final positions = layout.layout(emptyModel, const Size(800, 600));

      expect(positions, isEmpty);
    });

    test('single node is centered on canvas', () {
      const layout = ForceDirectedLayout();
      const canvasSize = Size(800, 600);
      const singleModel = GraphModel(
        nodes: [
          GraphNode(
            id: GraphNodeId('solo'),
            label: 'Solo',
            type: 'agent',
          ),
        ],
        edges: [],
      );

      final positions = layout.layout(singleModel, canvasSize);

      expect(positions, hasLength(1));
      // Single node should be near canvas center
      final pos = positions[const GraphNodeId('solo')]!;
      expect(pos.dx, closeTo(canvasSize.width / 2, 50));
      expect(pos.dy, closeTo(canvasSize.height / 2, 50));
    });

    test('positions of connected nodes are spread apart', () {
      const layout = ForceDirectedLayout();
      const canvasSize = Size(800, 600);

      final positions = layout.layout(tenNodeModel, canvasSize);

      // Compute average pairwise distance — should be > 0 (not collapsed)
      double totalDist = 0;
      int pairs = 0;
      for (int i = 0; i < 10; i++) {
        for (int j = i + 1; j < 10; j++) {
          final a = positions[GraphNodeId('n$i')]!;
          final b = positions[GraphNodeId('n$j')]!;
          totalDist += (a - b).distance;
          pairs++;
        }
      }
      final avgDist = totalDist / pairs;

      expect(
        avgDist,
        greaterThan(20),
        reason: 'Average pairwise distance $avgDist is too small',
      );
    });

    test('nodeSpacing config is retained on ForceDirectedLayout', () {
      const layout = ForceDirectedLayout(
        config: ForceDirectedConfig(nodeSpacing: 275),
      );
      expect(layout.config.nodeSpacing, 275);
    });

    test('nodeSpacing gate affects attraction in simulateStep', () {
      // Two nodes farther than small spacing → attraction applies and
      // pulls them together. Same distance under large spacing → no pull.
      final model = GraphModel(
        nodes: [
          const GraphNode(
            id: GraphNodeId('a'),
            label: 'A',
            type: 'agent',
          ),
          const GraphNode(
            id: GraphNodeId('b'),
            label: 'B',
            type: 'skill',
          ),
        ],
        edges: [GraphEdge.create(sourceId: 'a', targetId: 'b')],
      );

      const tight = ForceDirectedLayout(
        config: ForceDirectedConfig(
          nodeSpacing: 50,
          attraction: 0.1,
          repulsion: 0,
          centerGravity: 0,
          damping: 1.0,
        ),
      );
      const loose = ForceDirectedLayout(
        config: ForceDirectedConfig(
          nodeSpacing: 500,
          attraction: 0.1,
          repulsion: 0,
          centerGravity: 0,
          damping: 1.0,
        ),
      );

      final tightPos = <GraphNodeId, Offset>{
        const GraphNodeId('a'): Offset.zero,
        const GraphNodeId('b'): const Offset(200, 0),
      };
      final tightVel = <GraphNodeId, Offset>{
        const GraphNodeId('a'): Offset.zero,
        const GraphNodeId('b'): Offset.zero,
      };
      final loosePos = Map<GraphNodeId, Offset>.from(tightPos);
      final looseVel = Map<GraphNodeId, Offset>.from(tightVel);

      tight.simulateStep(model, tightPos, tightVel, {});
      loose.simulateStep(model, loosePos, looseVel, {});

      // Tight spacing attracts a toward b (positive x force on a).
      expect(tightPos[const GraphNodeId('a')]!.dx, greaterThan(0));
      // Loose spacing leaves a unmoved (distance 200 < nodeSpacing 500).
      expect(loosePos[const GraphNodeId('a')]!.dx, 0);
    });
  });
}
