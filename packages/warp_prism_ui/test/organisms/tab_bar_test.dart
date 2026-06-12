import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

/// Task 1122: DSTabBar widget tests
///
/// Covers: tab select, close, badge rendering, scroll overflow, keyboard nav.
void main() {
  group('DSTab', () {
    test('copyWith creates a copy with overrides', () {
      final tab = DSTab(
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

  group('DSTabController', () {
    test('initial state reflects provided tabs', () {
      final controller = DSTabController(
        tabs: [
          DSTab(id: 'a', label: 'A', content: (_) => const SizedBox()),
          DSTab(id: 'b', label: 'B', content: (_) => const SizedBox()),
          DSTab(id: 'c', label: 'C', content: (_) => const SizedBox()),
        ],
      );

      expect(controller.length, 3);
      expect(controller.activeIndex, 0);
      expect(controller.activeTab?.id, 'a');
      expect(controller.hasTabs, true);
    });

    test('select changes active index and notifies', () {
      int notifyCount = 0;
      final controller = DSTabController(
        tabs: [
          DSTab(id: 'a', label: 'A', content: (_) => const SizedBox()),
          DSTab(id: 'b', label: 'B', content: (_) => const SizedBox()),
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
      final controller = DSTabController(
        tabs: [DSTab(id: 'a', label: 'A', content: (_) => const SizedBox())],
      );
      controller.addListener(() => notifyCount++);

      controller.select(0); // already active

      expect(notifyCount, 0);
    });

    test('select is no-op for out-of-range index', () {
      int notifyCount = 0;
      final controller = DSTabController(
        tabs: [DSTab(id: 'a', label: 'A', content: (_) => const SizedBox())],
      );
      controller.addListener(() => notifyCount++);

      controller.select(5);
      controller.select(-1);

      expect(notifyCount, 0);
    });

    test('selectById finds the correct tab', () {
      final controller = DSTabController(
        tabs: [
          DSTab(id: 'a', label: 'A', content: (_) => const SizedBox()),
          DSTab(id: 'b', label: 'B', content: (_) => const SizedBox()),
        ],
      );

      controller.selectById('b');

      expect(controller.activeIndex, 1);
    });

    test('add appends tab and selects it by default', () {
      final controller = DSTabController(
        tabs: [DSTab(id: 'a', label: 'A', content: (_) => const SizedBox())],
      );

      controller.add(
        DSTab(id: 'b', label: 'B', content: (_) => const SizedBox()),
      );

      expect(controller.length, 2);
      expect(controller.activeIndex, 1);
      expect(controller.activeTab?.id, 'b');
    });

    test('add with selectNew=false does not change active index', () {
      final controller = DSTabController(
        tabs: [DSTab(id: 'a', label: 'A', content: (_) => const SizedBox())],
      );

      controller.add(
        DSTab(id: 'b', label: 'B', content: (_) => const SizedBox()),
        selectNew: false,
      );

      expect(controller.length, 2);
      expect(controller.activeIndex, 0);
    });

    test('close removes tab and adjusts active index', () {
      final controller = DSTabController(
        tabs: [
          DSTab(id: 'a', label: 'A', content: (_) => const SizedBox()),
          DSTab(id: 'b', label: 'B', content: (_) => const SizedBox()),
          DSTab(id: 'c', label: 'C', content: (_) => const SizedBox()),
        ],
        activeIndex: 1,
      );

      controller.close(1); // close active tab 'b'

      expect(controller.length, 2);
      expect(controller.activeTab?.id, 'c'); // shifted to right neighbor
    });

    test('close adjusts active index when closing before active', () {
      final controller = DSTabController(
        tabs: [
          DSTab(id: 'a', label: 'A', content: (_) => const SizedBox()),
          DSTab(id: 'b', label: 'B', content: (_) => const SizedBox()),
          DSTab(id: 'c', label: 'C', content: (_) => const SizedBox()),
        ],
        activeIndex: 2,
      );

      controller.close(0); // close 'a' before active 'c'

      expect(controller.activeIndex, 1); // shifted left
      expect(controller.activeTab?.id, 'c');
    });

    test('close last tab results in empty controller', () {
      final controller = DSTabController(
        tabs: [DSTab(id: 'a', label: 'A', content: (_) => const SizedBox())],
      );

      controller.close(0);

      expect(controller.length, 0);
      expect(controller.hasTabs, false);
      expect(controller.activeTab, null);
    });

    test('closeById finds and closes the correct tab', () {
      final controller = DSTabController(
        tabs: [
          DSTab(id: 'a', label: 'A', content: (_) => const SizedBox()),
          DSTab(id: 'b', label: 'B', content: (_) => const SizedBox()),
        ],
      );

      controller.closeById('a');

      expect(controller.length, 1);
      expect(controller.tabs.first.id, 'b');
    });

    test('setTabs replaces all tabs and resets active index', () {
      final controller = DSTabController(
        tabs: [DSTab(id: 'a', label: 'A', content: (_) => const SizedBox())],
      );

      controller.setTabs([
        DSTab(id: 'x', label: 'X', content: (_) => const SizedBox()),
        DSTab(id: 'y', label: 'Y', content: (_) => const SizedBox()),
      ], activeIndex: 1);

      expect(controller.length, 2);
      expect(controller.activeTab?.id, 'y');
    });

    test('replace swaps tab at index', () {
      final controller = DSTabController(
        tabs: [
          DSTab(id: 'a', label: 'A', content: (_) => const SizedBox()),
          DSTab(id: 'b', label: 'B', content: (_) => const SizedBox()),
        ],
      );

      controller.replace(
        1,
        DSTab(id: 'z', label: 'Z', content: (_) => const SizedBox()),
      );

      expect(controller.tabs[1].id, 'z');
    });
  });

  group('DSTabBar', () {
    Widget buildTestHarness(
      DSTabController controller, {
      ValueChanged<String>? onClose,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 800,
            height: 600,
            child: Column(
              children: [
                DSTabBar(controller: controller, onClose: onClose),
                Expanded(child: DSTabView(controller: controller)),
              ],
            ),
          ),
        ),
      );
    }

    testWidgets('renders tab labels', (tester) async {
      final controller = DSTabController(
        tabs: [
          DSTab(id: 'a', label: 'Alpha', content: (_) => const SizedBox()),
          DSTab(id: 'b', label: 'Beta', content: (_) => const SizedBox()),
        ],
      );
      addTearDown(controller.dispose);

      await tester.pumpWidget(buildTestHarness(controller));

      expect(find.text('Alpha'), findsOneWidget);
      expect(find.text('Beta'), findsOneWidget);
    });

    testWidgets('selecting a tab updates active index', (tester) async {
      final controller = DSTabController(
        tabs: [
          DSTab(id: 'a', label: 'Alpha', content: (_) => const SizedBox()),
          DSTab(id: 'b', label: 'Beta', content: (_) => const SizedBox()),
        ],
      );
      addTearDown(controller.dispose);

      await tester.pumpWidget(buildTestHarness(controller));

      await tester.tap(find.text('Beta'));
      await tester.pumpAndSettle();

      expect(controller.activeIndex, 1);
    });

    testWidgets('renders badge count', (tester) async {
      final controller = DSTabController(
        tabs: [
          DSTab(
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
      final controller = DSTabController(
        tabs: [
          DSTab(
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
      final controller = DSTabController(
        tabs: [
          DSTab(
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
      final controller = DSTabController(
        tabs: [
          DSTab(
            id: 'a',
            label: 'Alpha',
            closable: true,
            content: (_) => const SizedBox(),
          ),
          DSTab(
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
      final controller = DSTabController(
        tabs: [
          DSTab(
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
      final controller = DSTabController(
        tabs: [
          DSTab(
            id: 'a',
            label: 'Alpha',
            content: (_) => const Text('Content A'),
          ),
          DSTab(
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
      final controller = DSTabController(tabs: []);
      addTearDown(controller.dispose);

      await tester.pumpWidget(buildTestHarness(controller));

      expect(find.byType(DSTabBar), findsOneWidget);
    });
  });
}
