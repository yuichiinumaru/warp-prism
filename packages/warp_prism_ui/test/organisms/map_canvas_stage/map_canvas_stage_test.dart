import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

/// Task 1512: PrismMapCanvasStage contract + placeholder stage tests.
///
/// Covers: layer registry (add/remove/toggle), selection bus, popup host,
/// clear selection, a11y labels, public Prism alias. No MapLibre.
void main() {
  Widget harness({
    required Widget child,
    double width = 640,
    double height = 420,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: SizedBox(width: width, height: height, child: child),
      ),
    );
  }

  List<PrismMapStageLayerEntry> sampleLayers() => const [
    PrismMapStageLayerEntry(
      id: 'agents',
      label: 'Agents',
      visible: true,
      zIndex: 10,
    ),
    PrismMapStageLayerEntry(
      id: 'alerts',
      label: 'Alerts',
      visible: true,
      zIndex: 20,
    ),
  ];

  List<PrismMapStageFeature> sampleFeatures() => const [
    PrismMapStageFeature(
      id: 'f-alpha',
      layerId: 'agents',
      label: 'Agent Alpha',
      position: Offset(0.3, 0.4),
      properties: {'kind': 'agent'},
    ),
    PrismMapStageFeature(
      id: 'f-alert',
      layerId: 'alerts',
      label: 'Alert One',
      position: Offset(0.7, 0.3),
      properties: {'kind': 'alert'},
    ),
  ];

  group('PrismMapStage contracts', () {
    test('layer entry copyWith and equality', () {
      const a = PrismMapStageLayerEntry(id: 'l1', label: 'Layer 1');
      final b = a.copyWith(visible: false);
      expect(a.visible, isTrue);
      expect(b.visible, isFalse);
      expect(a == b, isFalse);
      expect(a.copyWith(), equals(a));
    });

    test('feature equality and selection events', () {
      const feature = PrismMapStageFeature(
        id: 'f1',
        layerId: 'agents',
        label: 'Alpha',
        position: Offset(0.5, 0.5),
      );
      final selected = PrismMapStageSelectionEvent.selected(feature);
      expect(selected.hasSelection, isTrue);
      expect(selected.kind, PrismMapStageSelectionKind.selected);
      expect(selected.featureId, 'f1');
      expect(selected.layerId, 'agents');

      const cleared = PrismMapStageSelectionEvent.cleared();
      expect(cleared.hasSelection, isFalse);
      expect(cleared.kind, PrismMapStageSelectionKind.cleared);
    });
  });

  group('PrismMapCanvasStageController', () {
    test('add/remove/toggle layer visibility', () {
      final controller = PrismMapCanvasStageController(
        initialLayers: sampleLayers(),
        initialFeatures: sampleFeatures(),
      );

      expect(controller.layers.length, 2);
      expect(controller.isLayerVisible('agents'), isTrue);

      controller.toggleLayerVisibility('agents');
      expect(controller.isLayerVisible('agents'), isFalse);
      expect(controller.visibleFeatures.map((f) => f.id), ['f-alert']);

      controller.setLayerVisibility('agents', true);
      expect(controller.visibleFeatures.length, 2);

      controller.addLayer(
        const PrismMapStageLayerEntry(
          id: 'intel',
          label: 'Intel',
          visible: true,
        ),
      );
      expect(controller.layerById('intel')?.label, 'Intel');

      controller.removeLayer('intel');
      expect(controller.layerById('intel'), isNull);

      controller.dispose();
    });

    test('selection bus emits select and clear', () {
      final controller = PrismMapCanvasStageController(
        initialLayers: sampleLayers(),
        initialFeatures: sampleFeatures(),
      );
      final events = <PrismMapStageSelectionEvent>[];
      controller.addSelectionListener(events.add);

      controller.selectFeature('f-alpha');
      expect(controller.selectedFeatureId, 'f-alpha');
      expect(events, hasLength(1));
      expect(events.single.kind, PrismMapStageSelectionKind.selected);
      expect(events.single.featureId, 'f-alpha');

      controller.clearSelection();
      expect(controller.hasSelection, isFalse);
      expect(events, hasLength(2));
      expect(events.last.kind, PrismMapStageSelectionKind.cleared);

      // Hiding selected layer clears selection.
      controller.selectFeature('f-alpha');
      controller.setLayerVisibility('agents', false);
      expect(controller.hasSelection, isFalse);
      expect(events.last.kind, PrismMapStageSelectionKind.cleared);

      controller.dispose();
    });

    test('cannot select feature on hidden layer', () {
      final controller = PrismMapCanvasStageController(
        initialLayers: sampleLayers(),
        initialFeatures: sampleFeatures(),
      );
      controller.setLayerVisibility('agents', false);
      controller.selectFeature('f-alpha');
      expect(controller.hasSelection, isFalse);
      controller.dispose();
    });
  });

  group('PrismMapCanvasStage widget', () {
    testWidgets('renders stage, markers, and status strip', (tester) async {
      final controller = PrismMapCanvasStageController(
        initialLayers: sampleLayers(),
        initialFeatures: sampleFeatures(),
      );

      await tester.pumpWidget(
        harness(child: PrismMapCanvasStage(controller: controller)),
      );

      expect(find.byType(PrismMapCanvasStage), findsOneWidget);
      expect(find.byKey(PrismMapCanvasStage.stageRegionKey), findsOneWidget);
      expect(find.byKey(PrismMapCanvasStage.statusStripKey), findsOneWidget);
      expect(
        find.byKey(PrismMapCanvasStage.featureMarkerKey('f-alpha')),
        findsOneWidget,
      );
      expect(
        find.byKey(PrismMapCanvasStage.featureMarkerKey('f-alert')),
        findsOneWidget,
      );

      controller.dispose();
    });

    testWidgets('register layer via controller updates visible markers', (
      tester,
    ) async {
      final controller = PrismMapCanvasStageController(
        initialLayers: const [
          PrismMapStageLayerEntry(id: 'agents', label: 'Agents'),
        ],
        initialFeatures: const [
          PrismMapStageFeature(
            id: 'f-alpha',
            layerId: 'agents',
            label: 'Agent Alpha',
            position: Offset(0.3, 0.4),
          ),
        ],
      );

      await tester.pumpWidget(
        harness(child: PrismMapCanvasStage(controller: controller)),
      );

      expect(
        find.byKey(PrismMapCanvasStage.featureMarkerKey('f-new')),
        findsNothing,
      );

      controller.addLayer(
        const PrismMapStageLayerEntry(id: 'extra', label: 'Extra'),
      );
      controller.addFeature(
        const PrismMapStageFeature(
          id: 'f-new',
          layerId: 'extra',
          label: 'New Feature',
          position: Offset(0.5, 0.5),
        ),
      );
      await tester.pump();

      expect(
        find.byKey(PrismMapCanvasStage.featureMarkerKey('f-new')),
        findsOneWidget,
      );

      controller.toggleLayerVisibility('extra');
      await tester.pump();
      expect(
        find.byKey(PrismMapCanvasStage.featureMarkerKey('f-new')),
        findsNothing,
      );

      controller.dispose();
    });

    testWidgets('select feature shows popup; clear hides popup', (
      tester,
    ) async {
      final controller = PrismMapCanvasStageController(
        initialLayers: sampleLayers(),
        initialFeatures: sampleFeatures(),
      );
      final events = <PrismMapStageSelectionEvent>[];

      await tester.pumpWidget(
        harness(
          child: PrismMapCanvasStage(
            controller: controller,
            onSelectionChanged: events.add,
          ),
        ),
      );

      expect(find.byKey(PrismMapCanvasStage.popupHostKey), findsNothing);

      await tester.tap(
        find.byKey(PrismMapCanvasStage.featureMarkerKey('f-alpha')),
      );
      await tester.pumpAndSettle();

      expect(controller.selectedFeatureId, 'f-alpha');
      expect(find.byKey(PrismMapCanvasStage.popupHostKey), findsOneWidget);
      expect(find.text('Agent Alpha'), findsWidgets);
      expect(events, isNotEmpty);
      expect(events.last.kind, PrismMapStageSelectionKind.selected);

      await tester.tap(find.byKey(PrismMapCanvasStage.popupDismissKey));
      await tester.pumpAndSettle();

      expect(controller.hasSelection, isFalse);
      expect(find.byKey(PrismMapCanvasStage.popupHostKey), findsNothing);
      expect(events.last.kind, PrismMapStageSelectionKind.cleared);

      controller.dispose();
    });

    testWidgets('custom popup factory is hosted', (tester) async {
      final controller = PrismMapCanvasStageController(
        initialLayers: sampleLayers(),
        initialFeatures: sampleFeatures(),
      );

      await tester.pumpWidget(
        harness(
          child: PrismMapCanvasStage(
            controller: controller,
            popupBuilder: (context, feature, dismiss) {
              return Material(
                child: ListTile(
                  title: Text('CUSTOM:${feature.id}'),
                  trailing: IconButton(
                    key: const Key('custom-dismiss'),
                    icon: const Icon(Icons.close),
                    onPressed: dismiss,
                  ),
                ),
              );
            },
          ),
        ),
      );

      await tester.tap(
        find.byKey(PrismMapCanvasStage.featureMarkerKey('f-alert')),
      );
      await tester.pumpAndSettle();

      expect(find.text('CUSTOM:f-alert'), findsOneWidget);
      expect(find.byKey(PrismMapCanvasStage.popupHostKey), findsOneWidget);

      await tester.tap(find.byKey(const Key('custom-dismiss')));
      await tester.pumpAndSettle();
      expect(find.text('CUSTOM:f-alert'), findsNothing);

      controller.dispose();
    });

    testWidgets('stage and markers have a11y labels', (tester) async {
      final controller = PrismMapCanvasStageController(
        initialLayers: sampleLayers(),
        initialFeatures: sampleFeatures(),
      );

      await tester.pumpWidget(
        harness(child: PrismMapCanvasStage(controller: controller)),
      );

      expect(
        tester.getSemantics(find.byType(PrismMapCanvasStage)).label,
        contains(PrismMapCanvasStage.stageSemanticLabel),
      );

      final markerHandle = tester.getSemantics(
        find.byKey(PrismMapCanvasStage.featureMarkerKey('f-alpha')),
      );
      expect(
        markerHandle.label,
        PrismMapCanvasStage.featureSemanticLabel('Agent Alpha'),
      );
      expect(markerHandle.flagsCollection.isButton, isTrue);

      controller.dispose();
    });

    testWidgets('public Prism alias constructs and mounts', (tester) async {
      await tester.pumpWidget(
        harness(
          child: PrismMapCanvasStage(
            initialLayers: sampleLayers(),
            initialFeatures: sampleFeatures(),
          ),
        ),
      );
      expect(find.byType(PrismMapCanvasStage), findsOneWidget);
    });

    testWidgets('interactive hit targets meet 48dp minimum', (tester) async {
      final controller = PrismMapCanvasStageController(
        initialLayers: sampleLayers(),
        initialFeatures: sampleFeatures(),
      );

      await tester.pumpWidget(
        harness(child: PrismMapCanvasStage(controller: controller)),
      );

      final markerSize = tester.getSize(
        find.byKey(PrismMapCanvasStage.featureMarkerKey('f-alpha')),
      );
      expect(markerSize.width, greaterThanOrEqualTo(48.0));
      expect(markerSize.height, greaterThanOrEqualTo(48.0));

      await tester.tap(
        find.byKey(PrismMapCanvasStage.featureMarkerKey('f-alpha')),
      );
      await tester.pumpAndSettle();

      final clearSize = tester.getSize(
        find.byKey(PrismMapCanvasStage.clearSelectionKey),
      );
      expect(clearSize.width, greaterThanOrEqualTo(48.0));
      expect(clearSize.height, greaterThanOrEqualTo(48.0));

      final dismissSize = tester.getSize(
        find.byKey(PrismMapCanvasStage.popupDismissKey),
      );
      expect(dismissSize.width, greaterThanOrEqualTo(48.0));
      expect(dismissSize.height, greaterThanOrEqualTo(48.0));

      controller.dispose();
    });

    testWidgets('background clear target exposes accessible label', (
      tester,
    ) async {
      final controller = PrismMapCanvasStageController(
        initialLayers: sampleLayers(),
        initialFeatures: sampleFeatures(),
      );

      await tester.pumpWidget(
        harness(child: PrismMapCanvasStage(controller: controller)),
      );

      // No selection → background is pointer-clearable but not a button.
      final idleBg = tester.getSemantics(
        find.byKey(PrismMapCanvasStage.backgroundClearKey),
      );
      expect(idleBg.flagsCollection.isButton, isFalse);

      controller.selectFeature('f-alpha');
      await tester.pumpAndSettle();
      expect(controller.hasSelection, isTrue);

      final bgSemantics = tester.getSemantics(
        find.byKey(PrismMapCanvasStage.backgroundClearKey),
      );
      expect(bgSemantics.label, contains('Clear map selection'));
      expect(bgSemantics.flagsCollection.isButton, isTrue);

      // Tap an empty corner of the stage background (avoid markers/popup).
      final bgRect = tester.getRect(
        find.byKey(PrismMapCanvasStage.backgroundClearKey),
      );
      await tester.tapAt(bgRect.topLeft + const Offset(12, 12));
      await tester.pumpAndSettle();
      expect(controller.hasSelection, isFalse);

      controller.dispose();
    });
  });
}
