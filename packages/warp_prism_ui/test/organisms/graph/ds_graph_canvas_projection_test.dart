/// Caller-supplied kind projection for DSGraphCanvas (Task 1884, HOLD branch).
///
/// Proves the canvas input extension: a host projects its own open node-kind
/// vocabulary through [nodeColorResolver]/[nodeIconResolver] with no fixed
/// verb set in Prism core. Real-DAG host proof is deferred (HOLD); this
/// exercises the seam with caller-supplied kinds only.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_ui/src/organisms/ds_graph_canvas.dart';
import 'package:warp_prism_ui/src/organisms/graph/graph_canvas.dart';

void main() {
  group('DSGraphCanvas caller-supplied kind projection', () {
    testWidgets('defaults preserve legacy rendering without resolvers', (
      tester,
    ) async {
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
      await tester.pump();

      expect(find.text('Alpha'), findsOneWidget);
      final canvas = tester.widget<GraphCanvas>(find.byType(GraphCanvas));
      expect(canvas.nodeColorResolver, isNull);
      expect(canvas.nodeIconResolver, isNull);
    });

    testWidgets('forwards caller resolvers into GraphCanvas', (tester) async {
      final nodes = [
        GraphNode(id: 'v1', label: 'Version', type: 'project.version'),
      ];
      const edges = <GraphEdge>[];

      Color resolveColor(String type) =>
          type == 'project.version' ? Colors.teal : Colors.grey;
      IconData resolveIcon(String type) =>
          type == 'project.version' ? Icons.history : Icons.circle_outlined;

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
                nodeColorResolver: resolveColor,
                nodeIconResolver: resolveIcon,
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Version'), findsOneWidget);
      final canvas = tester.widget<GraphCanvas>(find.byType(GraphCanvas));
      expect(canvas.nodeColorResolver, isNotNull);
      expect(canvas.nodeIconResolver, isNotNull);
      expect(canvas.nodeColorResolver!('project.version'), equals(Colors.teal));
      expect(
        canvas.nodeIconResolver!('project.version'),
        equals(Icons.history),
      );
    });

    testWidgets('caller vocabularies need no core verb registration', (
      tester,
    ) async {
      // An arbitrary host kind string renders without any Prism-side lookup.
      final nodes = [
        GraphNode(id: 'n1', label: 'Custom', type: 'myhost.custom_kind'),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 800,
              height: 600,
              child: DSGraphCanvas(
                nodes: nodes,
                edges: const [],
                enablePhysics: false,
                nodeColorResolver: (_) => Colors.purple,
                nodeIconResolver: (_) => Icons.star_outline,
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Custom'), findsOneWidget);
      expect(find.byIcon(Icons.star_outline), findsOneWidget);
    });
  });
}
