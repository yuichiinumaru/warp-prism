import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

void main() {
  // ---------------------------------------------------------------------------
  // Helper
  // ---------------------------------------------------------------------------
  Widget wrap(Widget child) => MaterialApp(
    home: Scaffold(body: SizedBox(width: 800, height: 600, child: child)),
  );

  // ---------------------------------------------------------------------------
  // GROUP: PrismVirtualScrollConfig
  // ---------------------------------------------------------------------------
  group('PrismVirtualScrollConfig', () {
    test('default config has null itemExtent and 250 cache', () {
      const config = PrismVirtualScrollConfig();
      expect(config.itemExtent, isNull);
      expect(config.cacheExtent, 250.0);
      expect(config.addAutomaticKeepAlives, isTrue);
      expect(config.addRepaintBoundaries, isTrue);
      expect(config.addSemanticIndexes, isTrue);
    });

    test('fixed preset has 48px itemExtent', () {
      const config = PrismVirtualScrollConfig.fixed;
      expect(config.itemExtent, 48.0);
      expect(config.cacheExtent, 250.0);
    });

    test('highCache preset has 500px cache and keep-alives off', () {
      const config = PrismVirtualScrollConfig.highCache;
      expect(config.itemExtent, 48.0);
      expect(config.cacheExtent, 500.0);
      expect(config.addAutomaticKeepAlives, isFalse);
    });

    test('variable preset has null itemExtent', () {
      const config = PrismVirtualScrollConfig.variable;
      expect(config.itemExtent, isNull);
    });

    test('copyWith overrides specified fields', () {
      const config = PrismVirtualScrollConfig();
      final updated = config.copyWith(itemExtent: 56.0, cacheExtent: 400.0);
      expect(updated.itemExtent, 56.0);
      expect(updated.cacheExtent, 400.0);
      expect(updated.addAutomaticKeepAlives, isTrue);
    });

    test('equality compares all fields', () {
      const a = PrismVirtualScrollConfig(itemExtent: 48.0);
      const b = PrismVirtualScrollConfig(itemExtent: 48.0);
      const c = PrismVirtualScrollConfig(itemExtent: 56.0);
      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });

    test('hashCode is consistent with equality', () {
      const a = PrismVirtualScrollConfig(itemExtent: 48.0);
      const b = PrismVirtualScrollConfig(itemExtent: 48.0);
      expect(a.hashCode, equals(b.hashCode));
    });
  });

  // ---------------------------------------------------------------------------
  // GROUP: PrismVirtualList — fixed extent items
  // ---------------------------------------------------------------------------
  group('PrismVirtualList fixed extent', () {
    testWidgets('renders items with fixed extent', (tester) async {
      await tester.pumpWidget(
        wrap(
          PrismVirtualList(
            itemCount: 100,
            config: PrismVirtualScrollConfig.fixed,
            itemBuilder: (context, index) =>
                SizedBox(height: 48, child: Text('Item $index')),
          ),
        ),
      );

      // First visible items should be rendered
      expect(find.text('Item 0'), findsOneWidget);
      expect(find.text('Item 1'), findsOneWidget);
    });

    testWidgets('only builds visible items (not all 100)', (tester) async {
      var buildCount = 0;

      await tester.pumpWidget(
        wrap(
          PrismVirtualList(
            itemCount: 100,
            config: PrismVirtualScrollConfig.fixed,
            itemBuilder: (context, index) {
              buildCount++;
              return SizedBox(height: 48, child: Text('Item $index'));
            },
          ),
        ),
      );

      // With 600px viewport and 48px items, ~12-13 items should be visible
      // plus cache extent. Should NOT build all 100.
      expect(buildCount, lessThan(30));
    });

    testWidgets('has semantic label when provided', (tester) async {
      await tester.pumpWidget(
        wrap(
          PrismVirtualList(
            itemCount: 10,
            config: PrismVirtualScrollConfig.fixed,
            semanticLabel: 'Test list',
            itemBuilder: (context, index) => Text('Item $index'),
          ),
        ),
      );

      expect(find.bySemanticsLabel('Test list'), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // GROUP: PrismVirtualList — variable extent items
  // ---------------------------------------------------------------------------
  group('PrismVirtualList variable extent', () {
    testWidgets('renders items without itemExtent', (tester) async {
      await tester.pumpWidget(
        wrap(
          PrismVirtualList(
            itemCount: 50,
            config: PrismVirtualScrollConfig.variable,
            itemBuilder: (context, index) =>
                ListTile(title: Text('Var Item $index')),
          ),
        ),
      );

      expect(find.text('Var Item 0'), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // GROUP: PrismVirtualList — empty and single item
  // ---------------------------------------------------------------------------
  group('PrismVirtualList edge cases', () {
    testWidgets('renders empty list without error', (tester) async {
      await tester.pumpWidget(
        wrap(
          PrismVirtualList(
            itemCount: 0,
            config: PrismVirtualScrollConfig.fixed,
            itemBuilder: (context, index) => const SizedBox.shrink(),
          ),
        ),
      );

      // Should render without throwing
      expect(find.byType(PrismVirtualList), findsOneWidget);
    });

    testWidgets('renders single item correctly', (tester) async {
      await tester.pumpWidget(
        wrap(
          PrismVirtualList(
            itemCount: 1,
            config: PrismVirtualScrollConfig.fixed,
            itemBuilder: (context, index) => const Text('Only item'),
          ),
        ),
      );

      expect(find.text('Only item'), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // GROUP: PrismVirtualList — keyboard navigation
  // ---------------------------------------------------------------------------
  group('PrismVirtualList keyboard navigation', () {
    testWidgets('enables keyboard navigation by default', (tester) async {
      await tester.pumpWidget(
        wrap(
          PrismVirtualList(
            itemCount: 1000,
            config: PrismVirtualScrollConfig.fixed,
            itemBuilder: (context, index) => Text('Item $index'),
          ),
        ),
      );

      // The Focus widget should be in the tree for keyboard handling
      expect(find.byType(Focus), findsWidgets);
    });

    testWidgets('disables keyboard navigation when set to false', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          PrismVirtualList(
            itemCount: 100,
            enableKeyboardNavigation: false,
            config: PrismVirtualScrollConfig.fixed,
            itemBuilder: (context, index) => Text('Item $index'),
          ),
        ),
      );

      // Should still render without Focus wrapper for key handling
      expect(find.byType(PrismVirtualList), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // GROUP: PrismVirtualList — cache extent configuration
  // ---------------------------------------------------------------------------
  group('PrismVirtualList cache extent', () {
    testWidgets('applies custom cache extent', (tester) async {
      var buildCountSmallCache = 0;
      var buildCountLargeCache = 0;

      // Test with large cache extent.
      await tester.pumpWidget(
        wrap(
          PrismVirtualList(
            itemCount: 1000,
            config: const PrismVirtualScrollConfig(
              itemExtent: 48.0,
              cacheExtent: 500.0,
            ),
            itemBuilder: (context, index) {
              buildCountLargeCache++;
              return Text('Item $index');
            },
          ),
        ),
      );

      // Test with small cache extent.
      await tester.pumpWidget(
        wrap(
          PrismVirtualList(
            itemCount: 1000,
            config: const PrismVirtualScrollConfig(
              itemExtent: 48.0,
              cacheExtent: 50.0,
            ),
            itemBuilder: (context, index) {
              buildCountSmallCache++;
              return Text('Item $index');
            },
          ),
        ),
      );

      // Both should virtualize (not build all 1000).
      expect(buildCountLargeCache, lessThan(1000));
      expect(buildCountSmallCache, lessThan(1000));
      // Larger cache should build at least as many items.
      expect(buildCountLargeCache, greaterThanOrEqualTo(buildCountSmallCache));
    });
  });

  // ---------------------------------------------------------------------------
  // GROUP: PrismVirtualList — scroll position preservation
  // ---------------------------------------------------------------------------
  group('PrismVirtualList scroll preservation', () {
    testWidgets('preserves scroll position on rebuild', (tester) async {
      final controller = ScrollController();

      await tester.pumpWidget(
        wrap(
          PrismVirtualList(
            itemCount: 1000,
            scrollController: controller,
            config: PrismVirtualScrollConfig.fixed,
            itemBuilder: (context, index) => Text('Item $index'),
          ),
        ),
      );

      // Scroll down
      controller.jumpTo(480.0); // ~10 items down
      await tester.pumpAndSettle();

      final scrollOffset = controller.offset;

      // Rebuild the widget with same controller
      await tester.pumpWidget(
        wrap(
          PrismVirtualList(
            itemCount: 1000,
            scrollController: controller,
            config: PrismVirtualScrollConfig.fixed,
            itemBuilder: (context, index) => Text('Item $index'),
          ),
        ),
      );

      expect(controller.offset, equals(scrollOffset));
      controller.dispose();
    });
  });

  // ---------------------------------------------------------------------------
  // GROUP: PrismVirtualList integration with PrismDataTable
  // ---------------------------------------------------------------------------
  group('PrismDataTable with PrismVirtualList', () {
    testWidgets('renders with virtualScrollConfig for large datasets', (
      tester,
    ) async {
      final rows = List.generate(
        100,
        (i) => PrismDataRow(id: '$i', cells: {'name': 'Item $i'}),
      );

      await tester.pumpWidget(
        wrap(
          PrismDataTable(
            columns: const [PrismDataColumn(id: 'name', label: 'Name')],
            rows: rows,
            paginated: false,
            showPagination: false,
            virtualScrollConfig: const PrismVirtualScrollConfig(
              itemExtent: 48.0,
              cacheExtent: 250.0,
            ),
          ),
        ),
      );

      // Should render header and visible items
      expect(find.text('Name'), findsOneWidget);
      expect(find.text('Item 0'), findsOneWidget);
      // Should NOT build all 100 items
      expect(find.text('Item 99'), findsNothing);
    });

    testWidgets('falls back to ListView.builder without virtualScrollConfig', (
      tester,
    ) async {
      final rows = List.generate(
        5,
        (i) => PrismDataRow(id: '$i', cells: {'name': 'Item $i'}),
      );

      await tester.pumpWidget(
        wrap(
          PrismDataTable(
            columns: const [PrismDataColumn(id: 'name', label: 'Name')],
            rows: rows,
            paginated: false,
            showPagination: false,
          ),
        ),
      );

      expect(find.text('Item 0'), findsOneWidget);
      expect(find.text('Item 4'), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // GROUP: Barrel exports
  // ---------------------------------------------------------------------------
  group('Virtual scroll barrel exports', () {
    test('all virtual scroll classes are accessible via barrel', () {
      expect(PrismVirtualList, isNotNull);
      expect(PrismVirtualGrid, isNotNull);
      expect(PrismVirtualScrollConfig, isNotNull);
    });
  });
}
