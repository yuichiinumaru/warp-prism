/// Backward-compatibility tests for DSGraphCanvas.
///
/// Task 1117: Verifies that the refactored DSGraphCanvas maintains
/// backward compatibility with the original API surface.
library;

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
              child: DSGraphCanvas(nodes: [], edges: []),
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
      const edges = [GraphEdge(sourceId: 'a', targetId: 'b')];

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

    testWidgets('graph nodes expose Semantics button labels', (tester) async {
      final nodes = [GraphNode(id: 'a', label: 'Alpha', type: 'agent')];
      const edges = <GraphEdge>[];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 800,
              height: 600,
              child: DSGraphCanvas(
                nodes: nodes,
                edges: edges,
                enablePhysics: false,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Widget-tree proof: GraphCanvas wraps each node in Semantics(button).
      // Merged semantics nodes may prefer child text over the wrapper label.
      final nodeSemantics = find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.button == true &&
            (widget.properties.label?.startsWith('Graph node:') ?? false),
      );
      expect(nodeSemantics, findsOneWidget);
      expect(find.text('Alpha'), findsOneWidget);
    });

    testWidgets('renders with all optional parameters', (tester) async {
      final nodes = [GraphNode(id: 'x', label: 'NodeX', type: 'workflow')];
      const edges = <GraphEdge>[];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 800,
              height: 600,
              child: DSGraphCanvas(
                nodes: nodes,
                edges: edges,
                onNodeTap: (node) => expect(node.id, isNotEmpty),
                onNodeDoubleTap: (node) => expect(node.id, isNotEmpty),
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

  group('layoutEngine + nodeSpacing wiring', () {
    testWidgets(
      'custom GraphLayoutEngine.layout is invoked and controls positions',
      (tester) async {
        final spy = _SpyLayoutEngine(
          positions: {
            const graph.GraphNodeId('a'): const Offset(120, 40),
            const graph.GraphNodeId('b'): const Offset(-80, -60),
          },
        );
        const model = graph.GraphModel(
          nodes: [
            graph.GraphNode(
              id: graph.GraphNodeId('a'),
              label: 'A',
              type: 'agent',
            ),
            graph.GraphNode(
              id: graph.GraphNodeId('b'),
              label: 'B',
              type: 'skill',
            ),
          ],
          edges: [],
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 800,
                height: 600,
                child: GraphCanvas(
                  model: model,
                  enablePhysics: false,
                  layoutEngine: spy,
                ),
              ),
            ),
          ),
        );
        await tester.pump();

        // Proof F1 is closed: injected engine is not dead wiring.
        expect(spy.callCount, greaterThanOrEqualTo(1));
        expect(spy.lastModel, isNotNull);
        expect(spy.lastModel!.nodes, hasLength(2));

        // Node labels render from the orchestrator using engine positions.
        expect(find.text('A'), findsOneWidget);
        expect(find.text('B'), findsOneWidget);

        // Screen placement derives from engine offsets:
        // left = dx * scale + pan + width/2 - 30, top = dy * scale + pan + height/2 - 30
        // Flutter test default surface is 800x600 (MediaQuery used by GraphCanvas).
        const mediaW = 800.0;
        const mediaH = 600.0;
        final positioned = tester
            .widgetList<Positioned>(find.byType(Positioned))
            .toList();
        expect(positioned, hasLength(2));

        const expectedALeft = 120 + mediaW / 2 - 30;
        const expectedATop = 40 + mediaH / 2 - 30;
        const expectedBLeft = -80 + mediaW / 2 - 30;
        const expectedBTop = -60 + mediaH / 2 - 30;

        bool near(double? actual, double expected) =>
            actual != null && (actual - expected).abs() < 0.5;

        expect(
          positioned.any(
            (p) => near(p.left, expectedALeft) && near(p.top, expectedATop),
          ),
          isTrue,
          reason: 'Node A should be placed from spy offset (120, 40)',
        );
        expect(
          positioned.any(
            (p) => near(p.left, expectedBLeft) && near(p.top, expectedBTop),
          ),
          isTrue,
          reason: 'Node B should be placed from spy offset (-80, -60)',
        );
      },
    );

    testWidgets(
      'GraphCanvas uses ForceDirectedLayout config from layoutEngine',
      (tester) async {
        const engine = ForceDirectedLayout(
          config: ForceDirectedConfig(nodeSpacing: 220),
        );
        const model = graph.GraphModel(
          nodes: [
            graph.GraphNode(
              id: graph.GraphNodeId('a'),
              label: 'A',
              type: 'agent',
            ),
            graph.GraphNode(
              id: graph.GraphNodeId('b'),
              label: 'B',
              type: 'skill',
            ),
          ],
          edges: [],
        );

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 800,
                height: 600,
                child: GraphCanvas(
                  model: model,
                  enablePhysics: false,
                  layoutEngine: engine,
                ),
              ),
            ),
          ),
        );
        await tester.pump();

        final canvas = tester.widget<GraphCanvas>(find.byType(GraphCanvas));
        final resolved = canvas.layoutEngine! as ForceDirectedLayout;
        expect(resolved.config.nodeSpacing, 220);
        expect(find.text('A'), findsOneWidget);
        expect(find.text('B'), findsOneWidget);
      },
    );

    testWidgets(
      'DSGraphCanvas forwards nodeSpacing into ForceDirectedLayout config',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 800,
                height: 600,
                child: DSGraphCanvas(
                  nodes: [
                    GraphNode(id: 'n1', label: 'N1', type: 'agent'),
                    GraphNode(id: 'n2', label: 'N2', type: 'skill'),
                  ],
                  edges: const [GraphEdge(sourceId: 'n1', targetId: 'n2')],
                  enablePhysics: false,
                  nodeSpacing: 300,
                ),
              ),
            ),
          ),
        );
        await tester.pump();

        // Proof F2 is closed: legacy nodeSpacing is not inert.
        final canvas = tester.widget<GraphCanvas>(find.byType(GraphCanvas));
        expect(canvas.layoutEngine, isA<ForceDirectedLayout>());
        final force = canvas.layoutEngine! as ForceDirectedLayout;
        expect(force.config.nodeSpacing, 300);
        expect(find.text('N1'), findsOneWidget);
        expect(find.text('N2'), findsOneWidget);
      },
    );

    testWidgets(
      'DSGraphCanvas default nodeSpacing matches ForceDirectedConfig default',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 800,
                height: 600,
                child: DSGraphCanvas(
                  nodes: [GraphNode(id: 'n1', label: 'N1', type: 'agent')],
                  edges: const [],
                  enablePhysics: false,
                ),
              ),
            ),
          ),
        );
        await tester.pump();

        final canvas = tester.widget<GraphCanvas>(find.byType(GraphCanvas));
        final force = canvas.layoutEngine! as ForceDirectedLayout;
        expect(force.config.nodeSpacing, 150.0);
      },
    );
  });
}

/// Test double that records layout invocations and returns fixed positions.
class _SpyLayoutEngine implements GraphLayoutEngine {
  _SpyLayoutEngine({required this.positions});

  final Map<graph.GraphNodeId, Offset> positions;
  int callCount = 0;
  graph.GraphModel? lastModel;
  Size? lastCanvasSize;

  @override
  Map<graph.GraphNodeId, Offset> layout(
    graph.GraphModel model,
    Size canvasSize,
  ) {
    callCount++;
    lastModel = model;
    lastCanvasSize = canvasSize;
    return Map<graph.GraphNodeId, Offset>.from(positions);
  }
}
