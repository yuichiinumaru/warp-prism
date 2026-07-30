import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

/// Task 1502: PrismToolStripSlideout widget tests
///
/// Covers: open, exclusive switch, close/collapse, empty tools, a11y labels.
void main() {
  List<PrismToolStripItem> fixtureTools() => [
    PrismToolStripItem(
      id: 'recon',
      icon: Icons.radar_outlined,
      label: 'Recon',
      builder: (_) => const Text('BODY_RECON'),
    ),
    PrismToolStripItem(
      id: 'alerts',
      icon: Icons.notifications_outlined,
      label: 'Alerts',
      builder: (_) => const Text('BODY_ALERTS'),
    ),
  ];

  Widget harness({
    List<PrismToolStripItem>? tools,
    String? activeToolId,
    ValueChanged<String?>? onActiveToolChanged,
    bool showCloseButton = true,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 800,
          height: 600,
          child: Align(
            alignment: Alignment.centerRight,
            child: PrismToolStripSlideout(
              tools: tools ?? fixtureTools(),
              activeToolId: activeToolId,
              onActiveToolChanged: onActiveToolChanged,
              showCloseButton: showCloseButton,
            ),
          ),
        ),
      ),
    );
  }

  group('PrismToolStripSlideout', () {
    testWidgets('starts collapsed: strip only, no panel body', (tester) async {
      await tester.pumpWidget(harness());

      expect(find.byKey(PrismToolStripSlideout.stripRegionKey), findsOneWidget);
      expect(find.byKey(PrismToolStripSlideout.panelRegionKey), findsNothing);
      expect(find.text('BODY_RECON'), findsNothing);
      expect(find.text('BODY_ALERTS'), findsNothing);
      expect(
        find.byKey(PrismToolStripSlideout.toolButtonKey('recon')),
        findsOneWidget,
      );
      expect(
        find.byKey(PrismToolStripSlideout.toolButtonKey('alerts')),
        findsOneWidget,
      );
    });

    testWidgets('opening a tool shows its body', (tester) async {
      await tester.pumpWidget(harness());

      await tester.tap(
        find.byKey(PrismToolStripSlideout.toolButtonKey('recon')),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(PrismToolStripSlideout.panelRegionKey), findsOneWidget);
      expect(find.text('BODY_RECON'), findsOneWidget);
      expect(find.text('BODY_ALERTS'), findsNothing);
      // Header title uses tool label.
      expect(find.text('Recon'), findsOneWidget);
    });

    testWidgets('exclusive: opening tool B closes tool A', (tester) async {
      await tester.pumpWidget(harness());

      await tester.tap(
        find.byKey(PrismToolStripSlideout.toolButtonKey('recon')),
      );
      await tester.pumpAndSettle();
      expect(find.text('BODY_RECON'), findsOneWidget);

      await tester.tap(
        find.byKey(PrismToolStripSlideout.toolButtonKey('alerts')),
      );
      await tester.pumpAndSettle();

      expect(find.text('BODY_ALERTS'), findsOneWidget);
      expect(find.text('BODY_RECON'), findsNothing);
      // Only one panel region.
      expect(find.byKey(PrismToolStripSlideout.panelRegionKey), findsOneWidget);
    });

    testWidgets('re-tapping active tool collapses to strip-only', (
      tester,
    ) async {
      await tester.pumpWidget(harness());

      await tester.tap(
        find.byKey(PrismToolStripSlideout.toolButtonKey('recon')),
      );
      await tester.pumpAndSettle();
      expect(find.text('BODY_RECON'), findsOneWidget);

      await tester.tap(
        find.byKey(PrismToolStripSlideout.toolButtonKey('recon')),
      );
      await tester.pumpAndSettle();

      expect(find.text('BODY_RECON'), findsNothing);
      expect(find.byKey(PrismToolStripSlideout.panelRegionKey), findsNothing);
      expect(find.byKey(PrismToolStripSlideout.stripRegionKey), findsOneWidget);
    });

    testWidgets('close button collapses panel', (tester) async {
      await tester.pumpWidget(harness());

      await tester.tap(
        find.byKey(PrismToolStripSlideout.toolButtonKey('alerts')),
      );
      await tester.pumpAndSettle();
      expect(find.text('BODY_ALERTS'), findsOneWidget);
      expect(find.byKey(PrismToolStripSlideout.closeButtonKey), findsOneWidget);

      await tester.tap(find.byKey(PrismToolStripSlideout.closeButtonKey));
      await tester.pumpAndSettle();

      expect(find.text('BODY_ALERTS'), findsNothing);
      expect(find.byKey(PrismToolStripSlideout.panelRegionKey), findsNothing);
    });

    testWidgets('empty tools list renders strip without buttons or panel', (
      tester,
    ) async {
      await tester.pumpWidget(harness(tools: const []));

      expect(find.byKey(PrismToolStripSlideout.stripRegionKey), findsOneWidget);
      expect(find.byKey(PrismToolStripSlideout.panelRegionKey), findsNothing);
      expect(
        find.byKey(PrismToolStripSlideout.toolButtonKey('recon')),
        findsNothing,
      );
    });

    testWidgets('onActiveToolChanged reports open and collapse', (
      tester,
    ) async {
      final events = <String?>[];
      await tester.pumpWidget(harness(onActiveToolChanged: events.add));

      await tester.tap(
        find.byKey(PrismToolStripSlideout.toolButtonKey('recon')),
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(PrismToolStripSlideout.toolButtonKey('alerts')),
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(PrismToolStripSlideout.toolButtonKey('alerts')),
      );
      await tester.pumpAndSettle();

      expect(events, equals(['recon', 'alerts', null]));
    });

    testWidgets('controlled activeToolId opens matching tool', (tester) async {
      await tester.pumpWidget(harness(activeToolId: 'alerts'));

      expect(find.text('BODY_ALERTS'), findsOneWidget);
      expect(find.text('BODY_RECON'), findsNothing);
      expect(find.byKey(PrismToolStripSlideout.panelRegionKey), findsOneWidget);
    });

    testWidgets(
      'controlled activeToolId rebuild null collapses panel without strip tap',
      (tester) async {
        await tester.pumpWidget(harness(activeToolId: 'recon'));
        expect(find.text('BODY_RECON'), findsOneWidget);
        expect(
          find.byKey(PrismToolStripSlideout.panelRegionKey),
          findsOneWidget,
        );

        await tester.pumpWidget(harness(activeToolId: null));
        await tester.pumpAndSettle();

        expect(find.text('BODY_RECON'), findsNothing);
        expect(find.byKey(PrismToolStripSlideout.panelRegionKey), findsNothing);
        expect(
          find.byKey(PrismToolStripSlideout.stripRegionKey),
          findsOneWidget,
        );
      },
    );

    testWidgets('tool buttons have Semantics labels (tool name)', (
      tester,
    ) async {
      await tester.pumpWidget(harness());

      final reconHandle = tester.getSemantics(
        find.byKey(PrismToolStripSlideout.toolButtonKey('recon')),
      );
      expect(
        reconHandle.label,
        PrismToolStripSlideout.toolSemanticLabel('Recon', selected: false),
      );
      expect(reconHandle.flagsCollection.isButton, isTrue);

      await tester.tap(
        find.byKey(PrismToolStripSlideout.toolButtonKey('recon')),
      );
      await tester.pumpAndSettle();

      final selectedHandle = tester.getSemantics(
        find.byKey(PrismToolStripSlideout.toolButtonKey('recon')),
      );
      expect(
        selectedHandle.label,
        PrismToolStripSlideout.toolSemanticLabel('Recon', selected: true),
      );

      final closeHandle = tester.getSemantics(
        find.byKey(PrismToolStripSlideout.closeButtonKey),
      );
      expect(closeHandle.label, PrismToolStripSlideout.closeSemanticLabel);
      expect(closeHandle.flagsCollection.isButton, isTrue);

      expect(
        tester.getSemantics(find.byType(PrismToolStripSlideout)).label,
        contains(PrismToolStripSlideout.stripSemanticLabel),
      );
    });

    testWidgets('public Prism alias constructs and mounts', (tester) async {
      await tester.pumpWidget(harness());
      expect(find.byType(PrismToolStripSlideout), findsOneWidget);
      // typedef identity
      const item = PrismToolStripItem(
        id: 'x',
        icon: Icons.circle,
        label: 'X',
        builder: _emptyBuilder,
      );
      expect(item, isA<PrismToolStripItem>());
    });
  });
}

Widget _emptyBuilder(BuildContext context) => const SizedBox.shrink();
