import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

/// Task 1509: PrismMapLegend widget tests
///
/// Covers: categorized entries, visibility toggle, collapse, empty, a11y.
void main() {
  List<PrismMapLegendCategory> fixtureCategories() =>
      List<PrismMapLegendCategory>.from(
        PrismMapLegendFixtures.defaultCategories,
      );

  Widget harness({
    List<PrismMapLegendCategory>? categories,
    bool allowVisibilityToggle = true,
    Set<String>? visibleItemIds,
    void Function(String itemId, bool visible)? onVisibilityChanged,
    ValueChanged<Set<String>>? onVisibleItemsChanged,
    ValueChanged<Set<String>>? onExpandedCategoryIdsChanged,
    VoidCallback? onClose,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 320,
          height: 520,
          child: PrismMapLegend(
            categories: categories ?? fixtureCategories(),
            allowVisibilityToggle: allowVisibilityToggle,
            visibleItemIds: visibleItemIds,
            onVisibilityChanged: onVisibilityChanged,
            onVisibleItemsChanged: onVisibleItemsChanged,
            onExpandedCategoryIdsChanged: onExpandedCategoryIdsChanged,
            onClose: onClose,
          ),
        ),
      ),
    );
  }

  group('PrismMapLegend', () {
    testWidgets('renders categories and legend items', (tester) async {
      await tester.pumpWidget(harness());

      expect(find.byType(PrismMapLegend), findsOneWidget);
      expect(find.byKey(PrismMapLegend.panelRegionKey), findsOneWidget);
      expect(find.text('Map legend'), findsOneWidget);
      expect(find.text('Entities'), findsOneWidget);
      expect(find.text('Signals'), findsOneWidget);
      expect(find.text('Agent'), findsOneWidget);
      expect(find.text('Alert'), findsOneWidget);
      expect(find.byKey(PrismMapLegend.itemRowKey('agent')), findsOneWidget);
      expect(find.byKey(PrismMapLegend.listKey), findsOneWidget);
    });

    testWidgets('visibility toggle fires callbacks', (tester) async {
      final changes = <(String, bool)>[];
      Set<String>? lastSet;

      await tester.pumpWidget(
        harness(
          onVisibilityChanged: (id, visible) => changes.add((id, visible)),
          onVisibleItemsChanged: (ids) => lastSet = ids,
        ),
      );

      // Agent starts visible — toggle hides.
      await tester.tap(find.byKey(PrismMapLegend.itemToggleKey('agent')));
      await tester.pump();

      expect(changes, equals([('agent', false)]));
      expect(lastSet, isNotNull);
      expect(lastSet!.contains('agent'), isFalse);

      // Toggle back on.
      await tester.tap(find.byKey(PrismMapLegend.itemToggleKey('agent')));
      await tester.pump();

      expect(changes.last, equals(('agent', true)));
      expect(lastSet!.contains('agent'), isTrue);
    });

    testWidgets('category collapse hides items', (tester) async {
      final expansions = <Set<String>>[];
      await tester.pumpWidget(
        harness(onExpandedCategoryIdsChanged: expansions.add),
      );

      expect(find.text('Agent'), findsOneWidget);

      await tester.tap(
        find.byKey(PrismMapLegend.categoryHeaderKey('entities')),
      );
      await tester.pump();

      expect(expansions, isNotEmpty);
      expect(expansions.last.contains('entities'), isFalse);
      expect(find.text('Agent'), findsNothing);
      // Other category still open.
      expect(find.text('Alert'), findsOneWidget);
    });

    testWidgets('empty catalog shows placeholder', (tester) async {
      await tester.pumpWidget(
        harness(categories: const <PrismMapLegendCategory>[]),
      );

      expect(find.byKey(PrismMapLegend.emptyPlaceholderKey), findsOneWidget);
      expect(find.text('No legend entries'), findsOneWidget);
    });

    testWidgets('close button fires when provided', (tester) async {
      var closed = false;
      await tester.pumpWidget(harness(onClose: () => closed = true));

      expect(find.byKey(PrismMapLegend.closeButtonKey), findsOneWidget);
      await tester.tap(find.byKey(PrismMapLegend.closeButtonKey));
      await tester.pump();
      expect(closed, isTrue);
    });

    testWidgets('exposes interactive a11y labels', (tester) async {
      await tester.pumpWidget(harness(onClose: () {}));

      expect(
        tester.getSemantics(find.byType(PrismMapLegend)).label,
        contains('Map legend'),
      );

      expect(find.byTooltip('Close map legend'), findsOneWidget);
      expect(
        find.byTooltip(
          PrismMapLegend.itemToggleSemanticLabel('Agent', visible: true),
        ),
        findsOneWidget,
      );
      // Incident starts hidden in fixtures.
      expect(
        find.byTooltip(
          PrismMapLegend.itemToggleSemanticLabel('Incident', visible: false),
        ),
        findsOneWidget,
      );

      final entities = tester.getSemantics(
        find.byKey(PrismMapLegend.categoryHeaderKey('entities')),
      );
      expect(
        entities.label,
        PrismMapLegend.categorySemanticLabel('Entities', expanded: true),
      );
      expect(entities.flagsCollection.isButton, isTrue);
    });

    testWidgets('interactive controls enforce >=48dp touch targets', (
      tester,
    ) async {
      await tester.pumpWidget(harness(onClose: () {}));

      final closeSize = tester.getSize(
        find.byKey(PrismMapLegend.closeButtonKey),
      );
      expect(closeSize.width, greaterThanOrEqualTo(48));
      expect(closeSize.height, greaterThanOrEqualTo(48));

      final toggleSize = tester.getSize(
        find.byKey(PrismMapLegend.itemToggleKey('agent')),
      );
      expect(toggleSize.width, greaterThanOrEqualTo(48));
      expect(toggleSize.height, greaterThanOrEqualTo(48));

      final categorySize = tester.getSize(
        find.byKey(PrismMapLegend.categoryHeaderKey('entities')),
      );
      expect(categorySize.height, greaterThanOrEqualTo(48));
    });

    testWidgets('public aliases resolve to Prism types', (tester) async {
      const item = PrismMapLegendItem(
        id: 'x',
        label: 'X',
        color: Color(0xFF00D4FF),
      );
      const cat = PrismMapLegendCategory(id: 'c', label: 'C', items: [item]);
      expect(item.visible, isTrue);
      expect(cat.items, hasLength(1));
      expect(PrismMapLegendFixtures.defaultCategories, isNotEmpty);
      await tester.pumpWidget(harness(categories: [cat]));
      expect(find.byType(PrismMapLegend), findsOneWidget);
      expect(find.text('X'), findsOneWidget);
    });
  });
}
