import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

/// Task 1522: PrismKeyboardCheatsheet widget tests
///
/// Covers: open surface render, fixture shortcuts, dismiss close, a11y labels.
void main() {
  Widget harness({
    List<PrismKeyboardShortcutGroup>? groups,
    VoidCallback? onClose,
    bool dismissOnBackdrop = true,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 800,
          height: 600,
          child: PrismKeyboardCheatsheet(
            groups: groups ?? PrismKeyboardCheatsheetFixtures.defaultGroups(),
            onClose: onClose,
            dismissOnBackdrop: dismissOnBackdrop,
          ),
        ),
      ),
    );
  }

  group('PrismKeyboardCheatsheet', () {
    testWidgets('renders fixture shortcut groups and rows', (tester) async {
      await tester.pumpWidget(harness());

      expect(find.byType(PrismKeyboardCheatsheet), findsOneWidget);
      expect(
        find.byKey(PrismKeyboardCheatsheet.panelRegionKey),
        findsOneWidget,
      );
      expect(find.text('Keyboard shortcuts'), findsOneWidget);
      // Group headers are rendered uppercase for chrome density.
      expect(find.text('NAVIGATION'), findsOneWidget);
      expect(find.text('Open command palette'), findsOneWidget);
      expect(
        find.byKey(PrismKeyboardCheatsheet.shortcutRowKey('cmd-palette')),
        findsOneWidget,
      );
    });

    testWidgets('dismiss button closes via onClose', (tester) async {
      var closed = false;
      await tester.pumpWidget(harness(onClose: () => closed = true));

      await tester.tap(find.byKey(PrismKeyboardCheatsheet.dismissKey));
      await tester.pump();

      expect(closed, isTrue);
    });

    testWidgets('backdrop tap closes when enabled', (tester) async {
      var closed = false;
      await tester.pumpWidget(harness(onClose: () => closed = true));
      await tester.pumpAndSettle();

      // Center of the stack is the modal panel; hit the scrim at a corner.
      await tester.tapAt(const Offset(8, 8));
      await tester.pump();

      expect(closed, isTrue);
    });

    testWidgets('escape key closes', (tester) async {
      var closed = false;
      await tester.pumpWidget(harness(onClose: () => closed = true));
      await tester.pump();

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();

      expect(closed, isTrue);
    });

    testWidgets('exposes dismiss a11y label', (tester) async {
      await tester.pumpWidget(harness());

      expect(
        tester
            .getSemantics(find.byKey(PrismKeyboardCheatsheet.dismissKey))
            .label,
        contains('Dismiss keyboard cheatsheet'),
      );
    });

    testWidgets('minimal fixture renders Core group', (tester) async {
      await tester.pumpWidget(
        harness(groups: PrismKeyboardCheatsheetFixtures.minimalGroups()),
      );

      expect(find.text('CORE'), findsOneWidget);
      expect(find.text('Show help'), findsOneWidget);
      expect(find.text('Close overlay'), findsOneWidget);
    });

    testWidgets('empty groups show placeholder', (tester) async {
      await tester.pumpWidget(
        harness(groups: const <PrismKeyboardShortcutGroup>[]),
      );

      expect(find.text('No shortcuts configured'), findsOneWidget);
    });

    testWidgets('backdrop tap does not close when dismissOnBackdrop is false', (
      tester,
    ) async {
      var closed = false;
      await tester.pumpWidget(
        harness(onClose: () => closed = true, dismissOnBackdrop: false),
      );
      await tester.pumpAndSettle();

      await tester.tapAt(const Offset(8, 8));
      await tester.pump();

      expect(closed, isFalse);
    });
  });
}
