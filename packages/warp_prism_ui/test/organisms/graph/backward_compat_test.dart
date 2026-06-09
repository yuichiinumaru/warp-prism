/// Backward-compatibility tests for DSGraphCanvas.
///
/// Task 1117: Verifies that the refactored DSGraphCanvas maintains
/// backward compatibility with the original API surface.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:warp_prism_ui/src/organisms/ds_graph_canvas.dart';
import 'package:warp_prism_ui/src/organisms/graph/graph_model.dart' as graph;
import 'package:warp_prism_ui/src/organisms/graph/graph_layout_engine.dart';
import 'package:warp_prism_ui/src/organisms/graph/force_directed_layout.dart';
import 'package:warp_prism_ui/src/organisms/graph/graph_painter.dart';
import 'package:warp_prism_ui/src/organisms/graph/graph_canvas.dart';

void main() {
  group('DSGraphCanvas backward compatibility', () {
    testWidgets('renders empty state when no nodes provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 800,
              height: 600,
              child: DSGraphCanvas(
                nodes: [],
                edges: [],
              ),
            ),
          ),
        ),
      );

      expect(find.text('No assets to display'), findsOneWidget);
    });

    testWidgets('renders nodes when provided', (tester) async {
      final nodes = [
        GraphNode(id: 'a', label: 'Alpha', type: 'agent'),
        GraphNode(id: 'b', label: 'Beta', type: 'skill'),
      ];
      const edges = [
        GraphEdge(sourceId: 'a', targetId: 'b'),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 800,
              height: 600,
              child: DSGraphCanvas(nodes: nodes, edges: edges),
            ),
          ),
        ),
      );

      expect(find.text('Alpha'), findsOneWidget);
      expect(find.text('Beta'), findsOneWidget);
    });

    testWidgets('renders with all optional parameters', (tester) async {
      final nodes = [
        GraphNode(id: 'x', label: 'NodeX', type: 'workflow'),
      ];
      const edges = <GraphEdge>[];

      String? tappedId;
      String? doubleTappedId;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 800,
              height: 600,
              child: DSGraphCanvas(
                nodes: nodes,
                edges: edges,
                onNodeTap: (node) => tappedId = node.id,
                onNodeDoubleTap: (node) => doubleTappedId = node.id,
                enablePhysics: false,
                nodeSpacing: 200.0,
              ),
            ),
          ),
        ),
      );

      // Widget should render without errors
      expect(find.text('NodeX'), findsOneWidget);
    });

    test('GraphNode backward-compatible API', () {
      final node = GraphNode(
        id: 'test',
        label: 'Test Node',
        type: 'agent',
        status: 'active',
        metadata: {'key': 'value'},
      );

      // All original fields accessible
      expect(node.id, 'test');
      expect(node.label, 'Test Node');
      expect(node.type, 'agent');
      expect(node.status, 'active');
      expect(node.metadata['key'], 'value');
      expect(node.position, Offset.zero);
      expect(node.velocity, Offset.zero);
      expect(node.isDragging, false);
      expect(node.isHovered, false);
      expect(node.isSelected, false);

      // Mutable state fields work
      node.position = const Offset(10, 20);
      node.isDragging = true;
      expect(node.position, const Offset(10, 20));
      expect(node.isDragging, true);

      // copyWith works
      final copy = node.copyWith(label: 'Modified');
      expect(copy.label, 'Modified');
      expect(copy.id, 'test'); // preserved
    });

    test('GraphEdge backward-compatible API', () {
      const edge = GraphEdge(
        sourceId: 'a',
        targetId: 'b',
        label: 'connects',
        edgeType: 'uses',
      );

      expect(edge.sourceId, 'a');
      expect(edge.targetId, 'b');
      expect(edge.label, 'connects');
      expect(edge.edgeType, 'uses');
    });

    test('GraphEdge default edgeType is references', () {
      const edge = GraphEdge(sourceId: 'a', targetId: 'b');
      expect(edge.edgeType, 'references');
    });
  });

  group('GraphModel typed API (new)', () {
    test('GraphModel, GraphNodeId, GraphLayoutEngine are accessible', () {
      // These are exported through the organisms barrel with no conflicts
      expect(graph.GraphModel, isNotNull);
      expect(graph.GraphNodeId, isNotNull);
      expect(graph.GraphEdgeId, isNotNull);
      expect(GraphLayoutEngine, isNotNull);
      expect(ForceDirectedLayout, isNotNull);
      expect(GraphPainter, isNotNull);
      expect(GraphCanvas, isNotNull);
    });
  });
}
