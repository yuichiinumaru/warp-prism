import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

/// Task 1122: PrismTabBar widget tests
///
/// Covers: tab select, close, badge rendering, scroll overflow, keyboard nav.
void main() {
  group('PrismTab', () {
    test('copyWith creates a copy with overrides', () {
      final tab = PrismTab(
        id: 'a',
        label: 'Alpha',
        closable: true,
        badgeCount: 3,
        content: (_) => const SizedBox(),
      );

      final copy = tab.copyWith(label: 'Beta', badgeCount: 0);

      expect(copy.id, 'a'); // unchanged
      expect(copy.label, 'Beta'); // overridden
      expect(copy.closable, true); // unchanged
      expect(copy.badgeCount, 0); // overridden
    });
  });

  group('PrismTabController', () {
    test('initial state reflects provided tabs', () {
      final controller = PrismTabController(
        tabs: [
          PrismTab(id: 'a', label: 'A', content: (_) => const SizedBox()),
          PrismTab(id: 'b', label: 'B', content: (_) => const SizedBox()),
          PrismTab(id: 'c', label: 'C', content: (_) => const SizedBox()),
        ],
      );

      expect(controller.length, 3);
      expect(controller.activeIndex, 0);
      expect(controller.activeTab?.id, 'a');
      expect(controller.hasTabs, true);
    });

    test('select changes active index and notifies', () {
      int notifyCount = 0;
      final controller = PrismTabController(
        tabs: [
          PrismTab(id: 'a', label: 'A', content: (_) => const SizedBox()),
          PrismTab(id: 'b', label: 'B', content: (_) => const SizedBox()),
        ],
      );
      controller.addListener(() => notifyCount++);

      controller.select(1);

      expect(controller.activeIndex, 1);
      expect(controller.activeTab?.id, 'b');
      expect(notifyCount, 1);
    });

    test('select is no-op for same index', () {
      int notifyCount = 0;
      final controller = PrismTabController(
        tabs: [PrismTab(id: 'a', label: 'A', content: (_) => const SizedBox())],
      );
      controller.addListener(() => notifyCount++);

      controller.select(0); // already active

      expect(notifyCount, 0);
    });

    test('select is no-op for out-of-range index', () {
      int notifyCount = 0;
      final controller = PrismTabController(
        tabs: [PrismTab(id: 'a', label: 'A', content: (_) => const SizedBox())],
      );
      controller.addListener(() => notifyCount++);

      controller.select(5);
      controller.select(-1);

      expect(notifyCount, 0);
    });

    test('selectById finds the correct tab', () {
      final controller = PrismTabController(
        tabs: [
          PrismTab(id: 'a', label: 'A', content: (_) => const SizedBox()),
          PrismTab(id: 'b', label: 'B', content: (_) => const SizedBox()),
        ],
      );

      controller.selectById('b');

      expect(controller.activeIndex, 1);
    });

    test('add appends tab and selects it by default', () {
      final controller = PrismTabController(
        tabs: [PrismTab(id: 'a', label: 'A', content: (_) => const SizedBox())],
      );

      controller.add(
        PrismTab(id: 'b', label: 'B', content: (_) => const SizedBox()),
      );

      expect(controller.length, 2);
      expect(controller.activeIndex, 1);
      expect(controller.activeTab?.id, 'b');
    });

    test('add with selectNew=false does not change active index', () {
      final controller = PrismTabController(
        tabs: [PrismTab(id: 'a', label: 'A', content: (_) => const SizedBox())],
      );

      controller.add(
        PrismTab(id: 'b', label: 'B', content: (_) => const SizedBox()),
        selectNew: false,
      );

      expect(controller.length, 2);
      expect(controller.activeIndex, 0);
    });

    test('close removes tab and adjusts active index', () {
      final controller = PrismTabController(
        tabs: [
          PrismTab(id: 'a', label: 'A', content: (_) => const SizedBox()),
          PrismTab(id: 'b', label: 'B', content: (_) => const SizedBox()),
          PrismTab(id: 'c', label: 'C', content: (_) => const SizedBox()),
        ],
        activeIndex: 1,
      );

      controller.close(1); // close active tab 'b'

      expect(controller.length, 2);
      expect(controller.activeTab?.id, 'c'); // shifted to right neighbor
    });

    test('close adjusts active index when closing before active', () {
      final controller = PrismTabController(
        tabs: [
          PrismTab(id: 'a', label: 'A', content: (_) => const SizedBox()),
          PrismTab(id: 'b', label: 'B', content: (_) => const SizedBox()),
          PrismTab(id: 'c', label: 'C', content: (_) => const SizedBox()),
        ],
        activeIndex: 2,
      );

      controller.close(0); // close 'a' before active 'c'

      expect(controller.activeIndex, 1); // shifted left
      expect(controller.activeTab?.id, 'c');
    });

    test('close last tab results in empty controller', () {
      final controller = PrismTabController(
        tabs: [PrismTab(id: 'a', label: 'A', content: (_) => const SizedBox())],
      );

      controller.close(0);

      expect(controller.length, 0);
      expect(controller.hasTabs, false);
      expect(controller.activeTab, null);
    });

    test('closeById finds and closes the correct tab', () {
      final controller = PrismTabController(
        tabs: [
          PrismTab(id: 'a', label: 'A', content: (_) => const SizedBox()),
          PrismTab(id: 'b', label: 'B', content: (_) => const SizedBox()),
        ],
      );

      controller.closeById('a');

      expect(controller.length, 1);
      expect(controller.tabs.first.id, 'b');
    });

    test('setTabs replaces all tabs and resets active index', () {
      final controller = PrismTabController(
        tabs: [PrismTab(id: 'a', label: 'A', content: (_) => const SizedBox())],
      );

      controller.setTabs([
        PrismTab(id: 'x', label: 'X', content: (_) => const SizedBox()),
        PrismTab(id: 'y', label: 'Y', content: (_) => const SizedBox()),
      ], activeIndex: 1);

      expect(controller.length, 2);
      expect(controller.activeTab?.id, 'y');
    });

    test('replace swaps tab at index', () {
      final controller = PrismTabController(
        tabs: [
          PrismTab(id: 'a', label: 'A', content: (_) => const SizedBox()),
          PrismTab(id: 'b', label: 'B', content: (_) => const SizedBox()),
        ],
      );

      controller.replace(
        1,
        PrismTab(id: 'z', label: 'Z', content: (_) => const SizedBox()),
      );

      expect(controller.tabs[1].id, 'z');
    });
  });

  group('PrismTabBar', () {
    Widget buildTestHarness(
      PrismTabController controller, {
      ValueChanged<String>? onClose,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 800,
            height: 600,
            child: Column(
              children: [
                PrismTabBar(controller: controller, onClose: onClose),
                Expanded(child: PrismTabView(controller: controller)),
              ],
            ),
          ),
        ),
      );
    }

    testWidgets('renders tab labels', (tester) async {
      final controller = PrismTabController(
        tabs: [
          PrismTab(id: 'a', label: 'Alpha', content: (_) => const SizedBox()),
          PrismTab(id: 'b', label: 'Beta', content: (_) => const SizedBox()),
        ],
      );
      addTearDown(controller.dispose);

      await tester.pumpWidget(buildTestHarness(controller));

      expect(find.text('Alpha'), findsOneWidget);
      expect(find.text('Beta'), findsOneWidget);
    });

    testWidgets('selecting a tab updates active index', (tester) async {
      final controller = PrismTabController(
        tabs: [
          PrismTab(id: 'a', label: 'Alpha', content: (_) => const SizedBox()),
          PrismTab(id: 'b', label: 'Beta', content: (_) => const SizedBox()),
        ],
      );
      addTearDown(controller.dispose);

      await tester.pumpWidget(buildTestHarness(controller));

      await tester.tap(find.text('Beta'));
      await tester.pumpAndSettle();

      expect(controller.activeIndex, 1);
    });

    testWidgets('renders badge count', (tester) async {
      final controller = PrismTabController(
        tabs: [
          PrismTab(
            id: 'a',
            label: 'Alpha',
            badgeCount: 5,
            content: (_) => const SizedBox(),
          ),
        ],
      );
      addTearDown(controller.dispose);

      await tester.pumpWidget(buildTestHarness(controller));

      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('renders close button for closable tabs', (tester) async {
      final controller = PrismTabController(
        tabs: [
          PrismTab(
            id: 'a',
            label: 'Alpha',
            closable: true,
            content: (_) => const SizedBox(),
          ),
        ],
      );
      addTearDown(controller.dispose);

      await tester.pumpWidget(buildTestHarness(controller));

      expect(find.bySemanticsLabel('Close tab'), findsOneWidget);
    });

    testWidgets('does not render close button for non-closable tabs', (
      tester,
    ) async {
      final controller = PrismTabController(
        tabs: [
          PrismTab(
            id: 'a',
            label: 'Alpha',
            closable: false,
            content: (_) => const SizedBox(),
          ),
        ],
      );
      addTearDown(controller.dispose);

      await tester.pumpWidget(buildTestHarness(controller));

      expect(find.bySemanticsLabel('Close tab'), findsNothing);
    });

    testWidgets('onClose callback receives correct tab id', (tester) async {
      String? closedId;
      final controller = PrismTabController(
        tabs: [
          PrismTab(
            id: 'a',
            label: 'Alpha',
            closable: true,
            content: (_) => const SizedBox(),
          ),
          PrismTab(
            id: 'b',
            label: 'Beta',
            closable: true,
            content: (_) => const SizedBox(),
          ),
        ],
      );
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        buildTestHarness(controller, onClose: (id) => closedId = id),
      );

      // Tap the close button on the first tab (Alpha)
      await tester.tap(find.bySemanticsLabel('Close tab').first);
      await tester.pumpAndSettle();

      expect(closedId, 'a');
    });

    testWidgets('renders icon when provided', (tester) async {
      final controller = PrismTabController(
        tabs: [
          PrismTab(
            id: 'a',
            label: 'Alpha',
            icon: Icons.star,
            content: (_) => const SizedBox(),
          ),
        ],
      );
      addTearDown(controller.dispose);

      await tester.pumpWidget(buildTestHarness(controller));

      expect(find.byIcon(Icons.star), findsOneWidget);
    });

    testWidgets('tab view renders active tab content', (tester) async {
      final controller = PrismTabController(
        tabs: [
          PrismTab(
            id: 'a',
            label: 'Alpha',
            content: (_) => const Text('Content A'),
          ),
          PrismTab(
            id: 'b',
            label: 'Beta',
            content: (_) => const Text('Content B'),
          ),
        ],
      );
      addTearDown(controller.dispose);

      await tester.pumpWidget(buildTestHarness(controller));

      // Initially, tab A is active — Content A is visible
      expect(find.text('Content A'), findsOneWidget);

      // Switch to tab B
      controller.select(1);
      await tester.pumpAndSettle();

      // After switching, Content B should be visible
      expect(find.text('Content B'), findsOneWidget);
    });

    testWidgets('empty controller renders tab bar without crashing', (
      tester,
    ) async {
      final controller = PrismTabController(tabs: []);
      addTearDown(controller.dispose);

      await tester.pumpWidget(buildTestHarness(controller));

      expect(find.byType(PrismTabBar), findsOneWidget);
    });

    testWidgets('many tabs overflow enables horizontal scroll extent', (
      tester,
    ) async {
      // Narrow viewport so long tab labels exceed available width.
      final tabs = List.generate(
        12,
        (i) => PrismTab(
          id: 't$i',
          label: 'Very Long Tab Label $i',
          content: (_) => const SizedBox(),
        ),
      );
      final controller = PrismTabController(tabs: tabs);
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 320,
              height: 400,
              child: Column(
                children: [
                  PrismTabBar(controller: controller),
                  Expanded(child: PrismTabView(controller: controller)),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // ListView.builder horizontal scroll must overflow.
      final scrollables = find.byType(Scrollable);
      expect(scrollables, findsWidgets);

      final scrollable = tester.widget<Scrollable>(scrollables.first);
      final position = scrollable.controller?.position;
      // Prefer controller position when present; fall back to primary scroll.
      final maxExtent =
          position?.maxScrollExtent ??
          tester
              .state<ScrollableState>(scrollables.first)
              .position
              .maxScrollExtent;
      expect(
        maxExtent,
        greaterThan(0),
        reason: 'Many tabs in a narrow bar must overflow (maxScrollExtent>0)',
      );

      // Right scroll arrow appears when overflow is present (showScrollFades default).
      expect(find.bySemanticsLabel('Scroll tab bar'), findsWidgets);
    });
  });
}
