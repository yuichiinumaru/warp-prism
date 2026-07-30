import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

/// Task 1509: PrismWatchlistDock widget tests
///
/// Covers: render, select, unpin, empty state, expand/collapse, a11y labels.
void main() {
  List<PrismWatchlistItem> fixtureItems() =>
      List<PrismWatchlistItem>.from(PrismWatchlistFixtures.defaultItems);

  Widget harness({
    List<PrismWatchlistItem>? items,
    ValueChanged<PrismWatchlistItem>? onSelect,
    ValueChanged<PrismWatchlistItem>? onUnpin,
    ValueChanged<bool>? onExpandedChanged,
    bool? expanded,
    bool initiallyExpanded = true,
    String? selectedId,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 320,
          height: 480,
          child: PrismWatchlistDock(
            items: items ?? fixtureItems(),
            onSelect: onSelect,
            onUnpin: onUnpin,
            onExpandedChanged: onExpandedChanged,
            expanded: expanded,
            initiallyExpanded: initiallyExpanded,
            selectedId: selectedId,
          ),
        ),
      ),
    );
  }

  group('PrismWatchlistDock', () {
    testWidgets('renders pinned items with panel region key', (tester) async {
      await tester.pumpWidget(harness());

      expect(find.byType(PrismWatchlistDock), findsOneWidget);
      expect(find.byKey(PrismWatchlistDock.panelRegionKey), findsOneWidget);
      expect(find.text('Watchlist'), findsOneWidget);
      expect(find.text('Orion Scout'), findsOneWidget);
      expect(find.text('Stage chrome pack'), findsOneWidget);
      expect(
        find.byKey(PrismWatchlistDock.itemRowKey('agent-orion')),
        findsOneWidget,
      );
    });

    testWidgets('select callback fires on row tap', (tester) async {
      PrismWatchlistItem? selected;
      await tester.pumpWidget(harness(onSelect: (item) => selected = item));

      await tester.tap(
        find.byKey(PrismWatchlistDock.itemRowKey('agent-orion')),
      );
      await tester.pump();

      expect(selected, isNotNull);
      expect(selected!.id, 'agent-orion');
      expect(selected!.entityType, 'agent');
    });

    testWidgets('unpin callback fires and removes local row', (tester) async {
      final unpinned = <String>[];
      await tester.pumpWidget(
        harness(onUnpin: (item) => unpinned.add(item.id)),
      );

      expect(find.text('Orion Scout'), findsOneWidget);
      await tester.tap(find.byKey(PrismWatchlistDock.unpinKey('agent-orion')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(unpinned, equals(['agent-orion']));
      expect(find.text('Orion Scout'), findsNothing);
    });

    testWidgets('empty state shows placeholder', (tester) async {
      await tester.pumpWidget(harness(items: const <PrismWatchlistItem>[]));

      expect(
        find.byKey(PrismWatchlistDock.emptyPlaceholderKey),
        findsOneWidget,
      );
      expect(find.text('No pinned entities'), findsOneWidget);
      expect(find.byKey(PrismWatchlistDock.listKey), findsNothing);
    });

    testWidgets('collapse hides list; expand restores', (tester) async {
      final expansions = <bool>[];
      await tester.pumpWidget(harness(onExpandedChanged: expansions.add));

      expect(find.text('Orion Scout'), findsOneWidget);

      await tester.tap(find.byKey(PrismWatchlistDock.expandToggleKey));
      await tester.pump();

      expect(expansions, equals([false]));
      expect(find.text('Orion Scout'), findsNothing);

      await tester.tap(find.byKey(PrismWatchlistDock.expandToggleKey));
      await tester.pump();

      expect(expansions, equals([false, true]));
      expect(find.text('Orion Scout'), findsOneWidget);
    });

    testWidgets('exposes interactive a11y labels', (tester) async {
      await tester.pumpWidget(harness());

      expect(
        tester.getSemantics(find.byType(PrismWatchlistDock)).label,
        contains('Watchlist dock'),
      );

      // IconButtons expose labels via tooltip + outer Semantics.
      expect(
        find.byTooltip(PrismWatchlistDock.expandSemanticLabel(expanded: true)),
        findsOneWidget,
      );
      expect(
        find.byTooltip(PrismWatchlistDock.unpinSemanticLabel('Orion Scout')),
        findsOneWidget,
      );

      final row = tester.getSemantics(
        find.byKey(PrismWatchlistDock.itemRowKey('agent-orion')),
      );
      expect(row.label, 'Orion Scout, agent');
      expect(row.flagsCollection.isButton, isTrue);

      // Unpin remains an independent button (not swallowed by row semantics).
      final unpin = tester.getSemantics(
        find.byKey(PrismWatchlistDock.unpinKey('agent-orion')),
      );
      expect(unpin.flagsCollection.isButton, isTrue);
      expect(unpin.label, PrismWatchlistDock.unpinSemanticLabel('Orion Scout'));
    });

    testWidgets('interactive controls enforce >=48dp touch targets', (
      tester,
    ) async {
      await tester.pumpWidget(harness());

      final expandSize = tester.getSize(
        find.byKey(PrismWatchlistDock.expandToggleKey),
      );
      expect(expandSize.width, greaterThanOrEqualTo(48));
      expect(expandSize.height, greaterThanOrEqualTo(48));

      final unpinSize = tester.getSize(
        find.byKey(PrismWatchlistDock.unpinKey('agent-orion')),
      );
      expect(unpinSize.width, greaterThanOrEqualTo(48));
      expect(unpinSize.height, greaterThanOrEqualTo(48));

      final rowSize = tester.getSize(
        find.byKey(PrismWatchlistDock.itemRowKey('agent-orion')),
      );
      expect(rowSize.height, greaterThanOrEqualTo(48));
    });

    testWidgets('public model aliases are Prism-typed', (tester) async {
      const item = PrismWatchlistItem(id: 'x', label: 'X', entityType: 'agent');
      expect(item.id, 'x');
      expect(item.hasCoordinates, isFalse);
      expect(PrismWatchlistFixtures.defaultItems, isNotEmpty);
      await tester.pumpWidget(harness(items: [item]));
      expect(find.byType(PrismWatchlistDock), findsOneWidget);
      expect(find.text('X'), findsOneWidget);
    });
  });
}
