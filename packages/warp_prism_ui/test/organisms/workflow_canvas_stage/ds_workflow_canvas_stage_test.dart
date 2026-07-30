import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

/// Task 1610: PrismWorkflowCanvasStage / DSWorkflowCanvasStage widget tests.
///
/// Covers: fixture DAG render; node + edge selection callbacks; empty graph;
/// loading surface; layout auto-positions; graph adapters; map-stage distinction
/// (workflow models only — no geo/MapLibre).
void main() {
  Widget harness({
    required Widget child,
    double width = 720,
    double height = 400,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: SizedBox(width: width, height: height, child: child),
      ),
    );
  }

  group('PrismWorkflowCanvasLayout', () {
    test('resolvePositions lays out roots left of dependents', () {
      final nodes = prismWorkflowCanvasStageMinimalNodes();
      final edges = prismWorkflowCanvasStageMinimalEdges();
      final positions = PrismWorkflowCanvasLayout.resolvePositions(
        nodes: nodes,
        edges: edges,
      );

      expect(positions.containsKey('a'), isTrue);
      expect(positions.containsKey('b'), isTrue);
      expect(positions['a']!.dx, lessThan(positions['b']!.dx));
    });

    test('explicit position is preserved', () {
      const nodes = [
        PrismWorkflowNode(
          id: 'x',
          label: 'Pinned',
          kind: PrismWorkflowNodeKind.process,
          position: Offset(12, 34),
        ),
      ];
      final positions = PrismWorkflowCanvasLayout.resolvePositions(
        nodes: nodes,
        edges: const [],
      );
      expect(positions['x'], const Offset(12, 34));
    });

    test('resolveCanvasSize grows with nodes', () {
      final positions = PrismWorkflowCanvasLayout.resolvePositions(
        nodes: prismWorkflowCanvasStageFixtureNodes(),
        edges: prismWorkflowCanvasStageFixtureEdges(),
      );
      final size = PrismWorkflowCanvasLayout.resolveCanvasSize(positions);
      expect(size.width, greaterThan(200));
      expect(size.height, greaterThan(100));
    });
  });

  group('PrismWorkflowNode / Edge contract', () {
    test('semantic labels include kind and endpoints', () {
      const node = PrismWorkflowNode(
        id: 'n1',
        label: 'Ingest',
        kind: PrismWorkflowNodeKind.ingest,
        status: 'ready',
      );
      expect(node.semanticLabel, contains('Ingest'));
      expect(node.semanticLabel, contains('ready'));

      final edge = PrismWorkflowEdge.connect(
        fromId: 'a',
        toId: 'b',
        kind: PrismWorkflowEdgeKind.data,
        label: 'payload',
      );
      expect(edge.displayLabel, 'payload');
      expect(edge.semanticLabel, contains('a'));
      expect(edge.semanticLabel, contains('b'));
    });

    test(
      'toGraphNode / toGraphEdge adapt for PrismGraphCanvas composition',
      () {
        const node = PrismWorkflowNode(
          id: 'n1',
          label: 'Agent step',
          kind: PrismWorkflowNodeKind.agent,
        );
        final graphNode = node.toGraphNode(
          resolvedPosition: const Offset(1, 2),
        );
        expect(graphNode.id, 'n1');
        expect(graphNode.type, 'agent');
        expect(graphNode.position, const Offset(1, 2));
        expect(graphNode.metadata['workflowKind'], 'agent');

        final edge = PrismWorkflowEdge.connect(
          fromId: 'a',
          toId: 'b',
          kind: PrismWorkflowEdgeKind.sequence,
        );
        final graphEdge = edge.toGraphEdge();
        expect(graphEdge.sourceId, 'a');
        expect(graphEdge.targetId, 'b');
      },
    );

    test('selection bus payloads', () {
      const cleared = PrismWorkflowSelection.cleared();
      expect(cleared.isEmpty, isTrue);

      const nodeSel = PrismWorkflowSelection.node('n1');
      expect(nodeSel.hasNode, isTrue);
      expect(nodeSel.nodeId, 'n1');
      expect(nodeSel.hasEdge, isFalse);

      const edgeSel = PrismWorkflowSelection.edge('e1');
      expect(edgeSel.hasEdge, isTrue);
      expect(edgeSel.edgeId, 'e1');
    });
  });

  group('PrismWorkflowCanvasStage', () {
    testWidgets('renders fixture DAG with node labels', (tester) async {
      await tester.pumpWidget(
        harness(
          child: PrismWorkflowCanvasStage(
            nodes: prismWorkflowCanvasStageFixtureNodes(),
            edges: prismWorkflowCanvasStageFixtureEdges(),
          ),
        ),
      );

      expect(find.byType(PrismWorkflowCanvasStage), findsOneWidget);
      expect(find.byKey(PrismWorkflowCanvasStage.stageKey), findsOneWidget);
      expect(find.byKey(PrismWorkflowCanvasStage.canvasKey), findsOneWidget);
      expect(find.text('Ingest'), findsOneWidget);
      expect(find.text('Route'), findsOneWidget);
      expect(find.text('Respond'), findsOneWidget);
      expect(find.text('Enrich'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('fires onNodeSelected when node chip is tapped', (
      tester,
    ) async {
      PrismWorkflowNode? selected;
      PrismWorkflowSelection? bus;

      await tester.pumpWidget(
        harness(
          child: PrismWorkflowCanvasStage(
            nodes: prismWorkflowCanvasStageMinimalNodes(),
            edges: prismWorkflowCanvasStageMinimalEdges(),
            onNodeSelected: (n) => selected = n,
            onSelectionChanged: (s) => bus = s,
          ),
        ),
      );

      await tester.tap(find.byKey(PrismWorkflowCanvasStage.nodeKey('b')));
      await tester.pumpAndSettle();

      expect(selected, isNotNull);
      expect(selected!.id, 'b');
      expect(selected!.kind, PrismWorkflowNodeKind.respond);
      expect(bus?.nodeId, 'b');
      expect(bus?.edgeId, isNull);
    });

    testWidgets('fires onEdgeSelected from edge strip', (tester) async {
      PrismWorkflowEdge? selected;
      PrismWorkflowSelection? bus;

      await tester.pumpWidget(
        harness(
          child: PrismWorkflowCanvasStage(
            nodes: prismWorkflowCanvasStageMinimalNodes(),
            edges: prismWorkflowCanvasStageMinimalEdges(),
            onEdgeSelected: (e) => selected = e,
            onSelectionChanged: (s) => bus = s,
          ),
        ),
      );

      expect(find.byKey(PrismWorkflowCanvasStage.edgeStripKey), findsOneWidget);
      await tester.tap(find.byKey(PrismWorkflowCanvasStage.edgeKey('e-a-b')));
      await tester.pumpAndSettle();

      expect(selected, isNotNull);
      expect(selected!.id, 'e-a-b');
      expect(selected!.fromId, 'a');
      expect(selected!.toId, 'b');
      expect(bus?.edgeId, 'e-a-b');
      expect(bus?.nodeId, isNull);
    });

    testWidgets('empty graph shows empty surface and does not crash', (
      tester,
    ) async {
      await tester.pumpWidget(
        harness(
          child: const PrismWorkflowCanvasStage(
            nodes: [],
            edges: [],
            emptyTitle: 'No workflow nodes',
            emptySubtitle: 'Fixture empty',
          ),
        ),
      );

      expect(find.byKey(PrismWorkflowCanvasStage.emptyKey), findsOneWidget);
      expect(find.text('No workflow nodes'), findsOneWidget);
      expect(find.text('Fixture empty'), findsOneWidget);
      expect(find.byKey(PrismWorkflowCanvasStage.canvasKey), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('loading shows loading surface', (tester) async {
      await tester.pumpWidget(
        harness(
          child: const PrismWorkflowCanvasStage(
            nodes: [],
            edges: [],
            isLoading: true,
            loadingTitle: 'Loading workflow…',
          ),
        ),
      );

      expect(find.byKey(PrismWorkflowCanvasStage.loadingKey), findsOneWidget);
      expect(find.text('Loading workflow…'), findsOneWidget);
      expect(find.byKey(PrismWorkflowCanvasStage.canvasKey), findsNothing);
    });

    testWidgets('highlights controlled selectedNodeId', (tester) async {
      await tester.pumpWidget(
        harness(
          child: PrismWorkflowCanvasStage(
            nodes: prismWorkflowCanvasStageMinimalNodes(),
            edges: prismWorkflowCanvasStageMinimalEdges(),
            selectedNodeId: 'a',
          ),
        ),
      );

      // Node key present; selection is controlled styling only.
      expect(find.byKey(PrismWorkflowCanvasStage.nodeKey('a')), findsOneWidget);
      expect(find.byKey(PrismWorkflowCanvasStage.nodeKey('b')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('public API is distinct from map canvas stage type', (
      tester,
    ) async {
      // Smoke: workflow stage type is not the map stage type.
      await tester.pumpWidget(
        harness(
          child: PrismWorkflowCanvasStage(
            nodes: prismWorkflowCanvasStageMinimalNodes(),
            edges: prismWorkflowCanvasStageMinimalEdges(),
          ),
        ),
      );
      expect(find.byType(PrismWorkflowCanvasStage), findsOneWidget);
      // Map stage (if exported) must not be in this tree.
      expect(find.byType(PrismMapCanvasStage), findsNothing);
    });
  });
}
