import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_observatory/features/map/graph/map_graph_mode.dart';
import 'package:warp_prism_observatory/features/map/graph/map_graph_projection.dart';
import 'package:warp_prism_observatory/features/map/widgets/map_graph_panel.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

void main() {
  group('MapGraphPanel', () {
    testWidgets('renders mode chips and canvas', (tester) async {
      var currentMode = MapGraphMode.containment;
      final projection = MapGraphProjection(
        nodes: [PrismGraphNode(id: 'node-1', label: 'Node 1', type: 'asset')],
        edges: [
          const PrismGraphEdge(
            sourceId: 'node-1',
            targetId: 'node-2',
            label: 'edge',
          ),
        ],
        mode: currentMode,
        assetsWithEdges: 2,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MapGraphPanel(
              projection: projection,
              onModeChanged: (mode) => currentMode = mode,
            ),
          ),
        ),
      );

      // Verify active mode chip
      expect(find.text('Containment'), findsOneWidget);
      expect(find.text('Operational'), findsOneWidget);
      expect(find.text('Evidence'), findsOneWidget);

      // Canvas renders
      expect(find.byType(PrismGraphCanvas), findsOneWidget);

      // Semantics labels may be merged under FocusableActionDetector; assert
      // the visible mode labels and selection via tap instead.
      expect(find.text('Containment'), findsOneWidget);
      expect(find.text('Operational'), findsOneWidget);

      // Tap on Operational
      await tester.tap(find.text('Operational'));
      await tester.pump(const Duration(milliseconds: 300));

      expect(currentMode, equals(MapGraphMode.operational));
    });

    testWidgets('compact width layout does not overflow', (tester) async {
      // Create a narrow logical size simulating compact width.
      tester.view.physicalSize = const Size(300, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());
      addTearDown(() => tester.view.resetDevicePixelRatio());

      const projection = MapGraphProjection(
        nodes: [],
        edges: [],
        mode: MapGraphMode.evidence,
        assetsWithEdges: 0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 300,
                child: MapGraphPanel(
                  projection: projection,
                  onModeChanged: (_) {},
                ),
              ),
            ),
          ),
        ),
      );

      // Verify no Exception happens
      expect(tester.takeException(), isNull);
    });

    testWidgets('displays node and edge counts correctly', (tester) async {
      const projection = MapGraphProjection(
        nodes: [],
        edges: [],
        mode: MapGraphMode.containment,
        assetsWithEdges: 0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MapGraphPanel(projection: projection, onModeChanged: (_) {}),
          ),
        ),
      );

      expect(find.text('0 nodes · 0 edges'), findsOneWidget);
    });

    testWidgets('graph mode chips have minimum 48x48 touch targets', (
      tester,
    ) async {
      const projection = MapGraphProjection(
        nodes: [],
        edges: [],
        mode: MapGraphMode.containment,
        assetsWithEdges: 0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MapGraphPanel(projection: projection, onModeChanged: (_) {}),
          ),
        ),
      );

      for (final label in ['Containment', 'Operational', 'Evidence']) {
        final chipFinder = find
            .ancestor(
              of: find.text(label),
              matching: find.byType(GestureDetector),
            )
            .first;

        final size = tester.getSize(chipFinder);
        expect(
          size.width,
          greaterThanOrEqualTo(48.0),
          reason: '$label chip width should be >= 48',
        );
        expect(
          size.height,
          greaterThanOrEqualTo(48.0),
          reason: '$label chip height should be >= 48',
        );
      }
    });

    testWidgets('empty-edge projection keeps mode selector and empty guidance', (
      tester,
    ) async {
      var currentMode = MapGraphMode.containment;
      final projection = MapGraphProjection(
        nodes: [PrismGraphNode(id: 'a', label: 'A', type: 'agent')],
        edges: const [],
        mode: MapGraphMode.containment,
        assetsWithEdges: 0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MapGraphPanel(
              projection: projection,
              onModeChanged: (mode) => currentMode = mode,
            ),
          ),
        ),
      );

      // Empty mode still shows selector + empty guidance, not a hard dead-end.
      expect(find.text('No edges in this mode'), findsOneWidget);
      expect(find.text('Containment'), findsOneWidget);
      expect(find.text('Operational'), findsOneWidget);
      expect(find.text('Evidence'), findsOneWidget);
      expect(find.byType(PrismGraphCanvas), findsNothing);

      await tester.tap(find.text('Evidence'));
      await tester.pump(const Duration(milliseconds: 100));
      expect(currentMode, MapGraphMode.evidence);
    });
  });
}
