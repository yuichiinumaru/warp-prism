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
  // GROUP: PrismVirtualGrid — fixed cross axis count
  // ---------------------------------------------------------------------------
  group('PrismVirtualGrid fixed crossAxisCount', () {
    testWidgets('renders items in grid layout', (tester) async {
      await tester.pumpWidget(
        wrap(
          PrismVirtualGrid(
            itemCount: 12,
            crossAxisCount: 4,
            itemBuilder: (context, index) =>
                Card(child: Center(child: Text('Grid $index'))),
          ),
        ),
      );

      expect(find.text('Grid 0'), findsOneWidget);
      expect(find.text('Grid 1'), findsOneWidget);
    });

    testWidgets('applies crossAxisCount', (tester) async {
      await tester.pumpWidget(
        wrap(
          PrismVirtualGrid(
            itemCount: 8,
            crossAxisCount: 2,
            itemBuilder: (context, index) => Text('G$index'),
          ),
        ),
      );

      expect(find.text('G0'), findsOneWidget);
    });

    testWidgets('applies custom aspect ratio and spacing', (tester) async {
      await tester.pumpWidget(
        wrap(
          PrismVirtualGrid(
            itemCount: 4,
            crossAxisCount: 2,
            childAspectRatio: 1.5,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            itemBuilder: (context, index) => Text('G$index'),
          ),
        ),
      );

      expect(find.text('G0'), findsOneWidget);
    });

    testWidgets('renders empty grid without error', (tester) async {
      await tester.pumpWidget(
        wrap(
          PrismVirtualGrid(
            itemCount: 0,
            crossAxisCount: 4,
            itemBuilder: (context, index) => const SizedBox.shrink(),
          ),
        ),
      );

      expect(find.byType(PrismVirtualGrid), findsOneWidget);
    });

    testWidgets('has semantic label when provided', (tester) async {
      await tester.pumpWidget(
        wrap(
          PrismVirtualGrid(
            itemCount: 4,
            crossAxisCount: 2,
            semanticLabel: 'Dashboard grid',
            itemBuilder: (context, index) => Text('G$index'),
          ),
        ),
      );

      expect(find.bySemanticsLabel('Dashboard grid'), findsOneWidget);
    });

    testWidgets('only builds visible items', (tester) async {
      var buildCount = 0;

      await tester.pumpWidget(
        wrap(
          PrismVirtualGrid(
            itemCount: 1000,
            crossAxisCount: 4,
            itemBuilder: (context, index) {
              buildCount++;
              return Text('G$index');
            },
          ),
        ),
      );

      // Should NOT build all 1000
      expect(buildCount, lessThan(100));
    });
  });

  // ---------------------------------------------------------------------------
  // GROUP: PrismVirtualGrid — responsive mode
  // ---------------------------------------------------------------------------
  group('PrismVirtualGrid responsive', () {
    testWidgets('renders in responsive mode', (tester) async {
      await tester.pumpWidget(
        wrap(
          PrismVirtualGrid.responsive(
            itemCount: 8,
            minCrossAxisExtent: 200,
            itemBuilder: (context, index) => Text('R$index'),
          ),
        ),
      );

      expect(find.text('R0'), findsOneWidget);
    });

    testWidgets('responsive has responsive=true', (tester) async {
      final grid = PrismVirtualGrid.responsive(
        itemCount: 4,
        minCrossAxisExtent: 200,
        itemBuilder: (context, index) => Text('R$index'),
      );

      expect(grid.responsive, isTrue);
      expect(grid.minCrossAxisExtent, 200);
    });

    testWidgets('fixed has responsive=false', (tester) async {
      const grid = PrismVirtualGrid(
        itemCount: 4,
        crossAxisCount: 2,
        itemBuilder: _noopBuilder,
      );

      expect(grid.responsive, isFalse);
    });
  });

  // ---------------------------------------------------------------------------
  // GROUP: PrismVirtualGrid — single item
  // ---------------------------------------------------------------------------
  group('PrismVirtualGrid edge cases', () {
    testWidgets('renders single item', (tester) async {
      await tester.pumpWidget(
        wrap(
          PrismVirtualGrid(
            itemCount: 1,
            crossAxisCount: 4,
            itemBuilder: (context, index) => const Text('Only grid item'),
          ),
        ),
      );

      expect(find.text('Only grid item'), findsOneWidget);
    });
  });
}

Widget _noopBuilder(BuildContext context, int index) => const SizedBox.shrink();
