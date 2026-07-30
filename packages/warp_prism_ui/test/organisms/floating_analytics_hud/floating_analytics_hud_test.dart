import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

/// Task 1514: PrismFloatingAnalyticsHud widget tests
///
/// Covers: section render, minimize/expand, close, drag via controller,
/// a11y labels, public Prism aliases.
void main() {
  List<PrismFloatingAnalyticsSection> fixtureSections() =>
      PrismFloatingAnalyticsFixtures.minimalSections();

  Widget harness({
    List<PrismFloatingAnalyticsSection>? sections,
    PrismFloatingAnalyticsHudController? controller,
    bool initiallyMinimized = false,
    bool? minimized,
    bool showClose = true,
    Offset initialOffset = const Offset(16, 16),
    ValueChanged<bool>? onMinimizedChanged,
    ValueChanged<Offset>? onOffsetChanged,
    VoidCallback? onClose,
    double width = 640,
    double height = 480,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: width,
          height: height,
          child: PrismFloatingAnalyticsHud(
            sections: sections ?? fixtureSections(),
            controller: controller,
            initiallyMinimized: initiallyMinimized,
            minimized: minimized,
            showClose: showClose,
            initialOffset: initialOffset,
            onMinimizedChanged: onMinimizedChanged,
            onOffsetChanged: onOffsetChanged,
            onClose: onClose,
            panelWidth: 280,
            maxBodyHeight: 280,
          ),
        ),
      ),
    );
  }

  group('PrismFloatingAnalyticsHud', () {
    testWidgets('renders multi-section fixture metrics', (tester) async {
      await tester.pumpWidget(harness());

      expect(find.byType(PrismFloatingAnalyticsHud), findsOneWidget);
      expect(
        find.byKey(PrismFloatingAnalyticsHud.panelRegionKey),
        findsOneWidget,
      );
      expect(find.text('Analytics'), findsOneWidget);
      expect(find.text('Core'), findsOneWidget);
      expect(find.text('Aux'), findsOneWidget);
      expect(find.text('Alpha'), findsOneWidget);
      expect(find.text('10'), findsOneWidget);
      expect(find.text('Gamma'), findsOneWidget);
      expect(
        find.byKey(PrismFloatingAnalyticsHud.sectionKey('core')),
        findsOneWidget,
      );
      expect(
        find.byKey(PrismFloatingAnalyticsHud.metricKey('core', 'm1')),
        findsOneWidget,
      );
      expect(find.byKey(PrismFloatingAnalyticsHud.bodyKey), findsOneWidget);
    });

    testWidgets('minimize hides body; expand restores sections', (
      tester,
    ) async {
      final states = <bool>[];
      await tester.pumpWidget(harness(onMinimizedChanged: states.add));

      expect(find.text('Alpha'), findsOneWidget);
      expect(find.byKey(PrismFloatingAnalyticsHud.bodyKey), findsOneWidget);

      await tester.tap(find.byKey(PrismFloatingAnalyticsHud.minimizeToggleKey));
      await tester.pump();

      expect(states, equals([true]));
      expect(find.byKey(PrismFloatingAnalyticsHud.bodyKey), findsNothing);
      expect(find.text('Alpha'), findsNothing);
      expect(find.text('Analytics'), findsOneWidget);

      await tester.tap(find.byKey(PrismFloatingAnalyticsHud.minimizeToggleKey));
      await tester.pump();

      expect(states, equals([true, false]));
      expect(find.byKey(PrismFloatingAnalyticsHud.bodyKey), findsOneWidget);
      expect(find.text('Alpha'), findsOneWidget);
    });

    testWidgets('controller minimize/expand drives state', (tester) async {
      final controller = PrismFloatingAnalyticsHudController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(harness(controller: controller));
      expect(find.text('Alpha'), findsOneWidget);

      controller.minimize();
      await tester.pump();
      expect(controller.isMinimized, isTrue);
      expect(find.byKey(PrismFloatingAnalyticsHud.bodyKey), findsNothing);

      controller.expand();
      await tester.pump();
      expect(controller.isMinimized, isFalse);
      expect(find.text('Alpha'), findsOneWidget);
    });

    testWidgets('drag reposition via controller moves panel', (tester) async {
      final controller = PrismFloatingAnalyticsHudController(
        offset: const Offset(10, 10),
      );
      addTearDown(controller.dispose);
      final offsets = <Offset>[];

      await tester.pumpWidget(
        harness(controller: controller, onOffsetChanged: offsets.add),
      );

      final before = tester.getTopLeft(
        find.byKey(PrismFloatingAnalyticsHud.panelRegionKey),
      );

      controller.moveTo(const Offset(80, 60));
      await tester.pump();

      final after = tester.getTopLeft(
        find.byKey(PrismFloatingAnalyticsHud.panelRegionKey),
      );

      expect(after.dx, greaterThan(before.dx));
      expect(after.dy, greaterThan(before.dy));
      expect(controller.offset, const Offset(80, 60));
    });

    testWidgets('pointer drag on handle updates offset', (tester) async {
      final controller = PrismFloatingAnalyticsHudController(
        offset: const Offset(20, 20),
      );
      addTearDown(controller.dispose);

      await tester.pumpWidget(harness(controller: controller));

      final handle = find.byKey(PrismFloatingAnalyticsHud.dragHandleKey);
      expect(handle, findsOneWidget);

      await tester.drag(handle, const Offset(40, 30));
      await tester.pump();

      expect(controller.offset.dx, greaterThan(20));
      expect(controller.offset.dy, greaterThan(20));
    });

    testWidgets('close hides panel and fires callback', (tester) async {
      var closed = false;
      await tester.pumpWidget(harness(onClose: () => closed = true));

      expect(
        find.byKey(PrismFloatingAnalyticsHud.panelRegionKey),
        findsOneWidget,
      );

      await tester.tap(find.byKey(PrismFloatingAnalyticsHud.closeButtonKey));
      await tester.pump();

      expect(closed, isTrue);
      expect(
        find.byKey(PrismFloatingAnalyticsHud.panelRegionKey),
        findsNothing,
      );
      expect(find.byType(PrismFloatingAnalyticsHud), findsOneWidget);
    });

    testWidgets('controller close hides panel', (tester) async {
      final controller = PrismFloatingAnalyticsHudController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(harness(controller: controller));
      expect(
        find.byKey(PrismFloatingAnalyticsHud.panelRegionKey),
        findsOneWidget,
      );

      controller.close();
      await tester.pump();

      expect(controller.isVisible, isFalse);
      expect(
        find.byKey(PrismFloatingAnalyticsHud.panelRegionKey),
        findsNothing,
      );
    });

    testWidgets('exposes interactive a11y labels', (tester) async {
      await tester.pumpWidget(harness());

      expect(
        tester.getSemantics(find.byType(PrismFloatingAnalyticsHud)).label,
        contains('Floating analytics HUD'),
      );

      expect(
        find.byTooltip(
          PrismFloatingAnalyticsHud.minimizeSemanticLabel(minimized: false),
        ),
        findsOneWidget,
      );
      expect(
        find.byTooltip(PrismFloatingAnalyticsHud.closeSemanticLabel()),
        findsOneWidget,
      );

      final drag = tester.getSemantics(
        find.byKey(PrismFloatingAnalyticsHud.dragHandleKey),
      );
      expect(
        drag.label,
        contains(PrismFloatingAnalyticsHud.dragSemanticLabel()),
      );
    });

    testWidgets('initiallyMinimized starts collapsed', (tester) async {
      await tester.pumpWidget(harness(initiallyMinimized: true));

      expect(find.byKey(PrismFloatingAnalyticsHud.bodyKey), findsNothing);
      expect(find.text('Analytics'), findsOneWidget);
      expect(
        find.byTooltip(
          PrismFloatingAnalyticsHud.minimizeSemanticLabel(minimized: true),
        ),
        findsOneWidget,
      );
    });

    testWidgets('public model aliases are Prism-typed', (tester) async {
      const metric = PrismFloatingAnalyticsMetric(
        id: 'x',
        label: 'X',
        value: '1',
      );
      const section = PrismFloatingAnalyticsSection(
        id: 's',
        title: 'Section',
        metrics: [metric],
      );
      expect(section.metrics.single.label, 'X');
      expect(PrismFloatingAnalyticsFixtures.defaultSections(), isNotEmpty);

      await tester.pumpWidget(harness(sections: [section]));
      expect(find.byType(PrismFloatingAnalyticsHud), findsOneWidget);
      expect(find.text('Section'), findsOneWidget);
      expect(find.text('X'), findsOneWidget);
    });

    testWidgets('default fixture sections render in gallery-shaped host', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 720,
              height: 420,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  const ColoredBox(color: Color(0xFF0A0A0F)),
                  PrismFloatingAnalyticsHud(
                    sections: PrismFloatingAnalyticsFixtures.defaultSections(),
                    initialOffset: const Offset(24, 24),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.text('Throughput'), findsOneWidget);
      expect(find.text('Coverage'), findsOneWidget);
      expect(find.text('Cost window'), findsOneWidget);
      expect(find.text('Req/s'), findsOneWidget);
    });

    testWidgets('header controls meet 48dp touch targets', (tester) async {
      await tester.pumpWidget(harness());

      const min = PrismFloatingAnalyticsHud.minInteractiveSize;
      expect(min, greaterThanOrEqualTo(48.0));

      void expectMinTouch(Key key) {
        final size = tester.getSize(find.byKey(key));
        expect(
          size.width,
          greaterThanOrEqualTo(min),
          reason: '$key width ${size.width} < $min',
        );
        expect(
          size.height,
          greaterThanOrEqualTo(min),
          reason: '$key height ${size.height} < $min',
        );
      }

      expectMinTouch(PrismFloatingAnalyticsHud.dragHandleKey);
      expectMinTouch(PrismFloatingAnalyticsHud.minimizeToggleKey);
      expectMinTouch(PrismFloatingAnalyticsHud.closeButtonKey);

      final titleSize = tester.getSize(
        find.byKey(PrismFloatingAnalyticsHud.titleDragKey),
      );
      expect(titleSize.height, greaterThanOrEqualTo(min));
    });

    testWidgets('every draggable target exposes drag semantic label', (
      tester,
    ) async {
      await tester.pumpWidget(harness());

      final dragLabel = PrismFloatingAnalyticsHud.dragSemanticLabel();

      final handleSemantics = tester.getSemantics(
        find.byKey(PrismFloatingAnalyticsHud.dragHandleKey),
      );
      expect(handleSemantics.label, contains(dragLabel));

      final titleSemantics = tester.getSemantics(
        find.byKey(PrismFloatingAnalyticsHud.titleDragKey),
      );
      expect(titleSemantics.label, contains(dragLabel));
    });
  });
}
