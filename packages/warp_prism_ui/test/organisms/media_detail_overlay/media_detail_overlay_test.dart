import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

/// Task 1523: PrismMediaDetailOverlay widget tests
///
/// Covers: open surface, close, empty media, next/prev, a11y labels.
void main() {
  Widget harness({
    List<PrismMediaDetailItem>? items,
    int initialIndex = 0,
    VoidCallback? onClose,
    ValueChanged<int>? onIndexChanged,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 900,
          height: 700,
          child: PrismMediaDetailOverlay(
            items: items ?? PrismMediaDetailFixtures.defaultItems(),
            initialIndex: initialIndex,
            onClose: onClose,
            onIndexChanged: onIndexChanged,
          ),
        ),
      ),
    );
  }

  group('PrismMediaDetailOverlay', () {
    testWidgets('renders title, caption, and placeholder frame', (
      tester,
    ) async {
      await tester.pumpWidget(harness());

      expect(find.byType(PrismMediaDetailOverlay), findsOneWidget);
      expect(
        find.byKey(PrismMediaDetailOverlay.panelRegionKey),
        findsOneWidget,
      );
      expect(find.byKey(PrismMediaDetailOverlay.mediaFrameKey), findsOneWidget);
      expect(find.text('Region overview · Alpha sector'), findsWidgets);
      expect(find.textContaining('Fixture still'), findsOneWidget);
    });

    testWidgets('close button fires onClose', (tester) async {
      var closed = false;
      await tester.pumpWidget(harness(onClose: () => closed = true));

      await tester.tap(find.byKey(PrismMediaDetailOverlay.dismissKey));
      await tester.pump();

      expect(closed, isTrue);
    });

    testWidgets('backdrop tap closes', (tester) async {
      var closed = false;
      await tester.pumpWidget(harness(onClose: () => closed = true));
      await tester.pumpAndSettle();

      // Center of the stack is the modal panel; hit the scrim at a corner.
      await tester.tapAt(const Offset(8, 8));
      await tester.pump();

      expect(closed, isTrue);
    });

    testWidgets('empty media shows placeholder', (tester) async {
      await tester.pumpWidget(harness(items: const <PrismMediaDetailItem>[]));

      expect(find.byKey(PrismMediaDetailOverlay.emptyKey), findsOneWidget);
      expect(find.text('No media items'), findsOneWidget);
      expect(find.byKey(PrismMediaDetailOverlay.nextKey), findsNothing);
    });

    testWidgets('next/prev navigates multi-item fixture', (tester) async {
      final indices = <int>[];
      await tester.pumpWidget(harness(onIndexChanged: indices.add));

      expect(find.textContaining('1 / 3'), findsOneWidget);

      await tester.tap(find.byKey(PrismMediaDetailOverlay.nextKey));
      await tester.pump();

      expect(indices, equals([1]));
      expect(find.text('Perimeter cam · North gate'), findsWidgets);
      expect(find.textContaining('2 / 3'), findsOneWidget);

      await tester.tap(find.byKey(PrismMediaDetailOverlay.nextKey));
      await tester.pump();
      expect(indices, equals([1, 2]));

      await tester.tap(find.byKey(PrismMediaDetailOverlay.previousKey));
      await tester.pump();
      expect(indices.last, equals(1));
    });

    testWidgets('single item hides next/prev controls', (tester) async {
      await tester.pumpWidget(
        harness(items: PrismMediaDetailFixtures.singleItem()),
      );

      expect(find.byKey(PrismMediaDetailOverlay.nextKey), findsNothing);
      expect(find.byKey(PrismMediaDetailOverlay.previousKey), findsNothing);
      expect(find.text('Solo fixture still'), findsWidgets);
    });

    testWidgets('exposes close and nav a11y labels', (tester) async {
      await tester.pumpWidget(harness());

      expect(
        tester
            .getSemantics(find.byKey(PrismMediaDetailOverlay.dismissKey))
            .label,
        contains('Close media detail'),
      );
      expect(
        tester.getSemantics(find.byKey(PrismMediaDetailOverlay.nextKey)).label,
        contains('Next media'),
      );
      expect(
        tester
            .getSemantics(find.byKey(PrismMediaDetailOverlay.previousKey))
            .label,
        contains('Previous media'),
      );
    });

    testWidgets('escape closes overlay', (tester) async {
      var closed = false;
      await tester.pumpWidget(harness(onClose: () => closed = true));
      await tester.pump();

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();

      expect(closed, isTrue);
    });

    testWidgets('arrow keys navigate multi-item fixture', (tester) async {
      final indices = <int>[];
      await tester.pumpWidget(harness(onIndexChanged: indices.add));
      await tester.pump();

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(indices, equals([1]));
      expect(find.textContaining('2 / 3'), findsOneWidget);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pump();
      expect(indices.last, equals(0));
      expect(find.textContaining('1 / 3'), findsOneWidget);
    });

    testWidgets('preserves index when items append (didUpdateWidget)', (
      tester,
    ) async {
      final items = List<PrismMediaDetailItem>.from(
        PrismMediaDetailFixtures.defaultItems(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 900,
              height: 700,
              child: PrismMediaDetailOverlay(items: items, initialIndex: 1),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.textContaining('2 / 3'), findsOneWidget);

      final grown = [
        ...items,
        const PrismMediaDetailItem(
          id: 'media-region-4',
          title: 'Appended still',
          caption: 'Append must not snap index',
        ),
      ];
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 900,
              height: 700,
              child: PrismMediaDetailOverlay(items: grown, initialIndex: 1),
            ),
          ),
        ),
      );
      await tester.pump();

      // Position preserved at index 1 (2/4), not snapped to initial-only reset.
      expect(find.textContaining('2 / 4'), findsOneWidget);
      expect(find.text('Perimeter cam · North gate'), findsWidgets);
    });
  });
}
