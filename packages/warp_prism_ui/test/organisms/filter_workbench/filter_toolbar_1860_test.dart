// Framework suite for the toolbar panel (Task 1860, F-12).
//
// Proves: closed → popover → typed-panel → reanchor transitions; option pick
// swaps popover for the typed panel; Done / scrim / Escape close and reanchor
// (focus returns to the button, onReanchored fires with the last panel id);
// keyboard activation opens the popover; 48dp targets; semantics labels.
//
// EXPERIMENTAL: imports via src paths; no barrel export yet.
// Run: flutter test packages/warp_prism_ui/test/organisms/filter_workbench/filter_toolbar_1860_test.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_ui/src/organisms/filter_workbench/ds_toolbar_panel.dart';

const _options = [
  DSToolbarPanelOption(id: 'filters', label: 'Filters'),
  DSToolbarPanelOption(id: 'views', label: 'Views'),
];

Widget wrapTest(DSToolbarPanel panel) => MaterialApp(
  home: Scaffold(body: Center(child: panel)),
);

DSToolbarPanel buildPanel({
  List<DSToolbarPanelPhase>? phases,
  List<String?>? reanchored,
}) => DSToolbarPanel(
  buttonLabel: 'Panels',
  options: _options,
  onPhaseChanged: phases?.add,
  onReanchored: reanchored?.add,
  panelBuilder: (context, panelId, close) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text('Typed panel: $panelId'),
      const SizedBox(height: 8),
      TextButton(
        key: const Key('typed-done'),
        onPressed: close,
        child: const Text('Done'),
      ),
    ],
  ),
);

void main() {
  group('filter_1860 DSToolbarPanel framework', () {
    testWidgets('button opens the popover with both options', (tester) async {
      await tester.pumpWidget(wrapTest(buildPanel()));

      expect(find.byKey(DSToolbarPanel.buttonKey), findsOneWidget);
      expect(find.byKey(DSToolbarPanel.popoverKey), findsNothing);

      await tester.tap(find.byKey(DSToolbarPanel.buttonKey));
      await tester.pumpAndSettle();

      expect(find.byKey(DSToolbarPanel.popoverKey), findsOneWidget);
      expect(find.byKey(DSToolbarPanel.optionKey('filters')), findsOneWidget);
      expect(find.byKey(DSToolbarPanel.optionKey('views')), findsOneWidget);
    });

    testWidgets('picking an option swaps popover for the typed panel', (
      tester,
    ) async {
      final phases = <DSToolbarPanelPhase>[];
      await tester.pumpWidget(wrapTest(buildPanel(phases: phases)));

      await tester.tap(find.byKey(DSToolbarPanel.buttonKey));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(DSToolbarPanel.optionKey('views')));
      await tester.pumpAndSettle();

      expect(find.byKey(DSToolbarPanel.popoverKey), findsNothing);
      expect(find.byKey(DSToolbarPanel.typedPanelKey('views')), findsOneWidget);
      expect(find.text('Typed panel: views'), findsOneWidget);
      expect(phases, [
        DSToolbarPanelPhase.popover,
        DSToolbarPanelPhase.typedPanel,
      ]);
    });

    testWidgets('Done closes and reanchors with the last panel id', (
      tester,
    ) async {
      final reanchored = <String?>[];
      await tester.pumpWidget(wrapTest(buildPanel(reanchored: reanchored)));

      await tester.tap(find.byKey(DSToolbarPanel.buttonKey));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(DSToolbarPanel.optionKey('filters')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();

      expect(find.byKey(DSToolbarPanel.typedPanelKey('filters')), findsNothing);
      expect(find.byType(DSToolbarPanel), findsOneWidget);
      expect(reanchored, ['filters']);
    });

    testWidgets('scrim tap closes and reanchors without a panel id', (
      tester,
    ) async {
      final phases = <DSToolbarPanelPhase>[];
      final reanchored = <String?>[];
      await tester.pumpWidget(
        wrapTest(buildPanel(phases: phases, reanchored: reanchored)),
      );

      await tester.tap(find.byKey(DSToolbarPanel.buttonKey));
      await tester.pumpAndSettle();
      expect(find.byKey(DSToolbarPanel.popoverKey), findsOneWidget);

      await tester.tap(find.byKey(DSToolbarPanel.scrimKey));
      await tester.pumpAndSettle();

      expect(find.byKey(DSToolbarPanel.popoverKey), findsNothing);
      expect(phases.last, DSToolbarPanelPhase.closed);
      expect(reanchored, [null]);
    });

    testWidgets('Escape closes the typed panel and reanchors', (tester) async {
      final reanchored = <String?>[];
      await tester.pumpWidget(wrapTest(buildPanel(reanchored: reanchored)));

      await tester.tap(find.byKey(DSToolbarPanel.buttonKey));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(DSToolbarPanel.optionKey('views')));
      await tester.pumpAndSettle();
      expect(find.byKey(DSToolbarPanel.typedPanelKey('views')), findsOneWidget);

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();

      expect(find.byKey(DSToolbarPanel.typedPanelKey('views')), findsNothing);
      expect(reanchored, ['views']);
    });

    testWidgets('focused button Enter opens the popover', (tester) async {
      await tester.pumpWidget(wrapTest(buildPanel()));

      final focusFinder = find.descendant(
        of: find.byType(DSToolbarPanel),
        matching: find.byType(Focus),
      );
      expect(focusFinder, findsWidgets);
      final focusNode = tester.widget<Focus>(focusFinder.first).focusNode;
      focusNode?.requestFocus();
      await tester.pump();

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      expect(find.byKey(DSToolbarPanel.popoverKey), findsOneWidget);
    });

    testWidgets('reanchor restores focus to the anchor button', (tester) async {
      await tester.pumpWidget(wrapTest(buildPanel()));

      await tester.tap(find.byKey(DSToolbarPanel.buttonKey));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(DSToolbarPanel.optionKey('filters')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();

      final focusFinder = find.descendant(
        of: find.byType(DSToolbarPanel),
        matching: find.byType(Focus),
      );
      final focusNode = tester.widget<Focus>(focusFinder.first).focusNode;
      expect(focusNode?.hasFocus, isTrue);
    });

    testWidgets('anchor button meets 48dp and exposes semantics', (
      tester,
    ) async {
      await tester.pumpWidget(wrapTest(buildPanel()));

      final size = tester.getSize(find.byKey(DSToolbarPanel.buttonKey));
      expect(size.height, greaterThanOrEqualTo(kMinInteractiveDimension));
      expect(size.width, greaterThanOrEqualTo(kMinInteractiveDimension));

      final semantics = tester.getSemantics(
        find.byKey(DSToolbarPanel.buttonKey),
      );
      expect(semantics.label, 'Open toolbar panel');
    });
  });
}
