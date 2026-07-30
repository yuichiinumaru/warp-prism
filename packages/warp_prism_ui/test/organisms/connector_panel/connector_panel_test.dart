import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

/// Task 1515: PrismConnectorPanel widget tests
///
/// Covers: header title, badge, refresh, minimize/expand, body slot, a11y.
void main() {
  Widget harness({
    String title = PrismConnectorPanelFixtures.defaultTitle,
    String? subtitle,
    String? badgeLabel = PrismConnectorPanelFixtures.defaultBadgeLabel,
    Widget? child,
    bool? minimized,
    bool initiallyMinimized = false,
    ValueChanged<bool>? onMinimizedChanged,
    VoidCallback? onRefresh,
    bool showRefresh = true,
    bool showMinimize = true,
    Widget? leading,
    Widget? trailing,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 360,
            child: PrismConnectorPanel(
              title: title,
              subtitle: subtitle,
              badgeLabel: badgeLabel,
              minimized: minimized,
              initiallyMinimized: initiallyMinimized,
              onMinimizedChanged: onMinimizedChanged,
              onRefresh: onRefresh,
              showRefresh: showRefresh,
              showMinimize: showMinimize,
              leading: leading,
              trailing: trailing,
              child:
                  child ??
                  const Text(PrismConnectorPanelFixtures.minimalBodyText),
            ),
          ),
        ),
      ),
    );
  }

  group('PrismConnectorPanel', () {
    testWidgets('renders header title, badge, and body slot', (tester) async {
      await tester.pumpWidget(harness());

      expect(find.byType(PrismConnectorPanel), findsOneWidget);
      expect(find.byKey(PrismConnectorPanel.panelRegionKey), findsOneWidget);
      expect(find.byKey(PrismConnectorPanel.headerKey), findsOneWidget);
      expect(find.byKey(PrismConnectorPanel.bodyKey), findsOneWidget);
      expect(
        find.text(PrismConnectorPanelFixtures.defaultTitle),
        findsOneWidget,
      );
      expect(
        find.text(PrismConnectorPanelFixtures.defaultBadgeLabel),
        findsOneWidget,
      );
      expect(
        find.text(PrismConnectorPanelFixtures.minimalBodyText),
        findsOneWidget,
      );
    });

    testWidgets('minimize hides body; expand restores (uncontrolled)', (
      tester,
    ) async {
      final events = <bool>[];
      await tester.pumpWidget(harness(onMinimizedChanged: events.add));

      expect(find.byKey(PrismConnectorPanel.bodyKey), findsOneWidget);
      expect(
        find.text(PrismConnectorPanelFixtures.minimalBodyText),
        findsOneWidget,
      );

      await tester.tap(find.byKey(PrismConnectorPanel.minimizeButtonKey));
      await tester.pump();

      expect(events, equals([true]));
      expect(find.byKey(PrismConnectorPanel.bodyKey), findsNothing);
      expect(
        find.text(PrismConnectorPanelFixtures.minimalBodyText),
        findsNothing,
      );
      // Header remains visible when minimized.
      expect(find.byKey(PrismConnectorPanel.headerKey), findsOneWidget);
      expect(
        find.text(PrismConnectorPanelFixtures.defaultTitle),
        findsOneWidget,
      );

      await tester.tap(find.byKey(PrismConnectorPanel.minimizeButtonKey));
      await tester.pump();

      expect(events, equals([true, false]));
      expect(find.byKey(PrismConnectorPanel.bodyKey), findsOneWidget);
      expect(
        find.text(PrismConnectorPanelFixtures.minimalBodyText),
        findsOneWidget,
      );
    });

    testWidgets('initiallyMinimized starts with body hidden', (tester) async {
      await tester.pumpWidget(harness(initiallyMinimized: true));

      expect(find.byKey(PrismConnectorPanel.bodyKey), findsNothing);
      expect(find.byKey(PrismConnectorPanel.headerKey), findsOneWidget);
    });

    testWidgets('controlled minimized follows parent prop', (tester) async {
      var minimized = false;
      late StateSetter setParent;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                setParent = setState;
                return Center(
                  child: SizedBox(
                    width: 360,
                    child: PrismConnectorPanel(
                      title: 'Controlled',
                      minimized: minimized,
                      onMinimizedChanged: (v) => setState(() => minimized = v),
                      onRefresh: () {},
                      child: const Text('CONTROLLED_BODY'),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('CONTROLLED_BODY'), findsOneWidget);

      await tester.tap(find.byKey(PrismConnectorPanel.minimizeButtonKey));
      await tester.pump();
      expect(find.text('CONTROLLED_BODY'), findsNothing);
      expect(minimized, isTrue);

      setParent(() => minimized = false);
      await tester.pump();
      expect(find.text('CONTROLLED_BODY'), findsOneWidget);
    });

    testWidgets('refresh callback fires when enabled', (tester) async {
      var refreshCount = 0;
      await tester.pumpWidget(harness(onRefresh: () => refreshCount++));

      expect(find.byKey(PrismConnectorPanel.refreshButtonKey), findsOneWidget);
      await tester.tap(find.byKey(PrismConnectorPanel.refreshButtonKey));
      await tester.pump();
      expect(refreshCount, 1);
    });

    testWidgets('refresh control disabled when onRefresh is null', (
      tester,
    ) async {
      await tester.pumpWidget(harness(onRefresh: null));

      // Key is on Semantics wrapper; child IconButton has null onPressed.
      final button = tester.widget<IconButton>(
        find.descendant(
          of: find.byKey(PrismConnectorPanel.refreshButtonKey),
          matching: find.byType(IconButton),
        ),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('can hide refresh and minimize controls', (tester) async {
      await tester.pumpWidget(harness(showRefresh: false, showMinimize: false));

      expect(find.byKey(PrismConnectorPanel.refreshButtonKey), findsNothing);
      expect(find.byKey(PrismConnectorPanel.minimizeButtonKey), findsNothing);
      expect(find.byKey(PrismConnectorPanel.bodyKey), findsOneWidget);
    });

    testWidgets('subtitle and trailing slot render', (tester) async {
      await tester.pumpWidget(
        harness(subtitle: 'Fixture subtitle', trailing: const Text('TRAILING')),
      );

      expect(find.text('Fixture subtitle'), findsOneWidget);
      expect(find.text('TRAILING'), findsOneWidget);
    });

    testWidgets('exposes a11y labels on panel and header actions', (
      tester,
    ) async {
      await tester.pumpWidget(harness(onRefresh: () {}));

      expect(
        tester.getSemantics(find.byType(PrismConnectorPanel)).label,
        contains('Connector panel'),
      );

      expect(
        tester
            .getSemantics(find.byKey(PrismConnectorPanel.refreshButtonKey))
            .label,
        contains('Refresh connector'),
      );

      expect(
        tester
            .getSemantics(find.byKey(PrismConnectorPanel.minimizeButtonKey))
            .label,
        contains('Minimize connector panel'),
      );

      await tester.tap(find.byKey(PrismConnectorPanel.minimizeButtonKey));
      await tester.pump();

      expect(
        tester
            .getSemantics(find.byKey(PrismConnectorPanel.minimizeButtonKey))
            .label,
        contains('Expand connector panel'),
      );
    });

    testWidgets('open/minimize exclusive body visibility with header', (
      tester,
    ) async {
      // Body and minimized chrome are exclusive: never both empty chrome
      // without header, and body only when expanded.
      await tester.pumpWidget(harness(onRefresh: () {}));

      expect(find.byKey(PrismConnectorPanel.headerKey), findsOneWidget);
      expect(find.byKey(PrismConnectorPanel.bodyKey), findsOneWidget);

      await tester.tap(find.byKey(PrismConnectorPanel.minimizeButtonKey));
      await tester.pump();

      expect(find.byKey(PrismConnectorPanel.headerKey), findsOneWidget);
      expect(find.byKey(PrismConnectorPanel.bodyKey), findsNothing);
    });

    testWidgets('refresh and minimize meet 48dp touch targets', (tester) async {
      await tester.pumpWidget(harness(onRefresh: () {}));

      final refreshSize = tester.getSize(
        find.byKey(PrismConnectorPanel.refreshButtonKey),
      );
      expect(refreshSize.width, greaterThanOrEqualTo(48.0));
      expect(refreshSize.height, greaterThanOrEqualTo(48.0));

      final minimizeSize = tester.getSize(
        find.byKey(PrismConnectorPanel.minimizeButtonKey),
      );
      expect(minimizeSize.width, greaterThanOrEqualTo(48.0));
      expect(minimizeSize.height, greaterThanOrEqualTo(48.0));
    });
  });
}
