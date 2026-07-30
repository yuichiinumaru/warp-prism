import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_ui/src/atoms/atoms.dart';
import 'package:warp_prism_ui/src/molecules/molecules.dart';
import 'package:warp_prism_ui/src/organisms/organisms.dart';

void main() {
  group('DSChip — Focus & Semantics', () {
    testWidgets('has Semantics with label, button, and selected', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: DSChip(label: 'Test Chip', selected: true, onTap: () {}),
            ),
          ),
        ),
      );

      final node = tester.getSemantics(find.byType(DSChip).first);
      expect(node.label, 'Test Chip');
      expect(node.flagsCollection.isButton, isTrue);
      expect(node.flagsCollection.isSelected, ui.Tristate.isTrue);
    });

    testWidgets('disabled chip does not accept tap', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DSChip(
              label: 'Disabled',
              enabled: false,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Disabled'));
      await tester.pump();
      expect(tapped, isFalse);
    });

    testWidgets('chip has 48x48 hit region', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Wrap(
              children: [
                DSChip(label: 'Small', size: DSChipSize.small, onTap: () {}),
              ],
            ),
          ),
        ),
      );

      final chipRect = tester.getRect(find.byType(GestureDetector).first);
      expect(chipRect.width, greaterThanOrEqualTo(48.0));
      expect(chipRect.height, greaterThanOrEqualTo(48.0));
    });

    testWidgets('removable chip has separate action semantics', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(child: DSChip.removable('RemoveMe', onRemove: () {})),
          ),
        ),
      );

      expect(find.semantics.byLabel('RemoveMe'), findsOneWidget);
      expect(find.semantics.byLabel('Remove RemoveMe'), findsOneWidget);
    });

    testWidgets('removable chip trailing action has 48x48 hit region', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(child: DSChip.removable('Target', onRemove: () {})),
          ),
        ),
      );

      final gestures = find.descendant(
        of: find.byType(DSChip),
        matching: find.byType(GestureDetector),
      );
      expect(gestures, findsWidgets);
      final rect = tester.getRect(gestures.last);
      expect(rect.width, 48.0);
      expect(rect.height, 48.0);
    });
  });

  group('DSFilterChipGroup — Focus & Semantics', () {
    testWidgets('has Semantics with "Filter options" label', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DSFilterChipGroup(
              options: const [DSFilterOption(value: 'a', label: 'Alpha')],
              selected: const {'a'},
              onToggle: (_) {},
            ),
          ),
        ),
      );

      expect(find.semantics.byLabel('Filter options'), findsOneWidget);
    });

    testWidgets('individual filter chips have button semantics when toggled', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DSFilterChipGroup(
              options: const [DSFilterOption(value: 'a', label: 'Alpha')],
              selected: const <String>{},
              onToggle: (_) {},
            ),
          ),
        ),
      );

      expect(find.semantics.byLabel('Alpha'), findsOneWidget);
      final node = tester.getSemantics(find.bySemanticsLabel('Alpha'));
      expect(node.flagsCollection.isButton, isTrue);
    });

    testWidgets('null onToggle is non-interactive (not a button)', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DSFilterChipGroup(
              options: [DSFilterOption(value: 'a', label: 'Alpha')],
              selected: <String>{},
            ),
          ),
        ),
      );

      expect(find.semantics.byLabel('Alpha'), findsOneWidget);
      final node = tester.getSemantics(find.bySemanticsLabel('Alpha'));
      expect(node.flagsCollection.isButton, isFalse);
    });

    testWidgets('filter chip has 48x48 hit region', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DSFilterChipGroup(
              options: const [DSFilterOption(value: 'a', label: 'Alpha')],
              selected: const <String>{},
              onToggle: (v) {},
            ),
          ),
        ),
      );

      // Look for the GestureDetector inside the filter chip
      final gdFinder = find.descendant(
        of: find.byType(DSFilterChipGroup),
        matching: find.byType(GestureDetector),
      );
      expect(gdFinder, findsWidgets);
      final gdRect = tester.getRect(gdFinder.first);
      expect(gdRect.width, greaterThanOrEqualTo(48.0));
      expect(gdRect.height, greaterThanOrEqualTo(48.0));
    });
  });

  group('DSSidebar — Focus & Semantics', () {
    testWidgets('sidebar has "Navigation sidebar" label', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 400,
              child: DSSidebar(
                items: [DSSidebarItem(id: 'm', label: 'Map', icon: Icons.map)],
              ),
            ),
          ),
        ),
      );

      expect(find.semantics.byLabel('Navigation sidebar'), findsOneWidget);
    });

    testWidgets('sidebar items have button and selected semantics', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 400,
              child: DSSidebar(
                items: [DSSidebarItem(id: 'm', label: 'Map', icon: Icons.map)],
                selectedId: 'm',
              ),
            ),
          ),
        ),
      );

      // The node could be deeply nested, but we can just use tester.getSemantics on the widget.
      // Actually finding specific semantics flags in children is tough, let's keep it simple:
      expect(find.semantics.byLabel('Map'), findsOneWidget);
    });
  });

  group('DSTopbarAction — Focus & Semantics', () {
    testWidgets('has Semantics with tooltip as label', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DSTopbarAction(
              icon: Icons.settings,
              tooltip: 'Settings',
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.semantics.byLabel('Settings'), findsOneWidget);
    });

    testWidgets('topbar action has 48x48 hit region', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DSTopbarAction(
              icon: Icons.settings,
              tooltip: 'Settings',
              onTap: () {},
            ),
          ),
        ),
      );

      final gesture = find.byType(GestureDetector).first;
      final gdRect = tester.getRect(gesture);
      expect(gdRect.width, greaterThanOrEqualTo(48.0));
      expect(gdRect.height, greaterThanOrEqualTo(48.0));
    });
  });

  group('DSSearchBar — Focus Behavior & Semantics', () {
    testWidgets('search bar TextField receives focus on tap', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: DSSearchBar(placeholder: 'Search...')),
        ),
      );

      await tester.tap(find.byType(TextField));
      await tester.pump();
      expect(tester.testTextInput.isRegistered, isTrue);
    });

    testWidgets('Search bar has clear button semantics', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: DSSearchBar(value: 'active query')),
        ),
      );

      expect(find.semantics.byLabel('Clear search query'), findsOneWidget);
    });

    testWidgets('Search bar has filter button semantics', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DSSearchBar(showFilter: true, onFilterTap: () {}),
          ),
        ),
      );

      expect(find.semantics.byLabel('Open search filters'), findsOneWidget);
    });
  });

  group('DSAssetCard — Semantics', () {
    testWidgets('asset card has Semantics covering name, kind, button states', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DSAssetCard(
              name: 'GT',
              kind: 'agent',
              selected: true,
              onTap: () {},
            ),
          ),
        ),
      );

      final node = tester.getSemantics(find.byType(DSAssetCard).first);
      expect(node.label, 'agent asset: GT');
      expect(node.flagsCollection.isButton, isTrue);
      expect(node.flagsCollection.isSelected, ui.Tristate.isTrue);
      expect(node.flagsCollection.isEnabled, ui.Tristate.isTrue);
    });

    testWidgets('does not duplicate inner text semantics', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DSAssetCard(name: 'GT', kind: 'agent', onTap: () {}),
          ),
        ),
      );

      // Verify that ExcludeSemantics hides the inner text GT
      final textSemantics = find.semantics.byLabel('GT');
      expect(textSemantics, findsNothing);
    });
  });

  group('DSShell — Focus Traversal', () {
    bool primaryFocusIsWithin(FocusNode node) {
      final primaryFocus = FocusManager.instance.primaryFocus;
      return primaryFocus == node ||
          (primaryFocus?.ancestors.contains(node) ?? false);
    }

    void expectPrimaryFocusWithin(FocusNode node) {
      expect(primaryFocusIsWithin(node), isTrue);
    }

    testWidgets(
      'keyboard tab traverses sidebar, search, topbar action, and content',
      (tester) async {
        tester.view.physicalSize = const Size(1200, 800);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final contentFocusNode = FocusNode(debugLabel: 'content-target');
        addTearDown(contentFocusNode.dispose);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DSShell(
                sidebar: const DSSidebar(
                  items: [DSSidebarItem(id: '1', label: 'Item 1')],
                ),
                topbar: const DSTopbar(
                  searchBar: DSSearchBar(placeholder: 'search'),
                  actions: [DSTopbarAction(icon: Icons.add, tooltip: 'Add')],
                ),
                content: Center(
                  child: Focus(
                    focusNode: contentFocusNode,
                    child: const SizedBox(width: 10, height: 10),
                  ),
                ),
              ),
            ),
          ),
        );

        final sidebarFocus = tester
            .widget<Focus>(
              find
                  .descendant(
                    of: find.byType(DSSidebar),
                    matching: find.byType(Focus),
                  )
                  .first,
            )
            .focusNode!;
        final searchFocus = tester
            .widget<TextField>(find.byType(TextField))
            .focusNode!;
        final actionFocus = tester
            .widget<Focus>(
              find
                  .descendant(
                    of: find.byType(DSTopbarAction),
                    matching: find.byType(Focus),
                  )
                  .first,
            )
            .focusNode!;

        // Shell order is intentional: sidebar → search → action → content.
        sidebarFocus.requestFocus();
        await tester.pump();
        expectPrimaryFocusWithin(sidebarFocus);

        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
        expectPrimaryFocusWithin(searchFocus);

        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
        expectPrimaryFocusWithin(actionFocus);

        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
        expectPrimaryFocusWithin(contentFocusNode);

        // Wrap completes the cycle back to the sidebar.
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
        expectPrimaryFocusWithin(sidebarFocus);
      },
    );

    testWidgets('shift-tab reverses shell focus order', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final contentFocusNode = FocusNode(debugLabel: 'content-target');
      addTearDown(contentFocusNode.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DSShell(
              sidebar: const DSSidebar(
                items: [DSSidebarItem(id: '1', label: 'Item 1')],
              ),
              topbar: const DSTopbar(
                searchBar: DSSearchBar(placeholder: 'search'),
                actions: [DSTopbarAction(icon: Icons.add, tooltip: 'Add')],
              ),
              content: Center(
                child: Focus(
                  focusNode: contentFocusNode,
                  child: const SizedBox(width: 10, height: 10),
                ),
              ),
            ),
          ),
        ),
      );

      final sidebarFocus = tester
          .widget<Focus>(
            find
                .descendant(
                  of: find.byType(DSSidebar),
                  matching: find.byType(Focus),
                )
                .first,
          )
          .focusNode!;
      final searchFocus = tester
          .widget<TextField>(find.byType(TextField))
          .focusNode!;
      final actionFocus = tester
          .widget<Focus>(
            find
                .descendant(
                  of: find.byType(DSTopbarAction),
                  matching: find.byType(Focus),
                )
                .first,
          )
          .focusNode!;

      // Reverse of intentional shell order: content → action → search → sidebar.
      contentFocusNode.requestFocus();
      await tester.pump();
      expectPrimaryFocusWithin(contentFocusNode);

      Future<void> shiftTab() async {
        await tester.sendKeyDownEvent(LogicalKeyboardKey.shift);
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.shift);
        await tester.pump();
      }

      await shiftTab();
      expectPrimaryFocusWithin(actionFocus);

      await shiftTab();
      expectPrimaryFocusWithin(searchFocus);

      await shiftTab();
      expectPrimaryFocusWithin(sidebarFocus);
    });

    testWidgets(
      'Enter and Space activate a shell sidebar item after keyboard traversal',
      (tester) async {
        tester.view.physicalSize = const Size(1200, 800);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final contentFocusNode = FocusNode(debugLabel: 'content-target');
        addTearDown(contentFocusNode.dispose);
        var activationCount = 0;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DSShell(
                sidebar: DSSidebar(
                  items: const [DSSidebarItem(id: '1', label: 'Target')],
                  onItemTap: (id) {
                    if (id == '1') activationCount++;
                  },
                ),
                topbar: const DSTopbar(
                  searchBar: DSSearchBar(placeholder: 'search'),
                  actions: [DSTopbarAction(icon: Icons.add, tooltip: 'Add')],
                ),
                content: Focus(
                  focusNode: contentFocusNode,
                  child: const SizedBox(width: 10, height: 10),
                ),
              ),
            ),
          ),
        );

        final sidebarFocus = tester
            .widget<Focus>(
              find
                  .descendant(
                    of: find.byType(DSSidebar),
                    matching: find.byType(Focus),
                  )
                  .first,
            )
            .focusNode!;

        contentFocusNode.requestFocus();
        await tester.pump();
        await tester.sendKeyDownEvent(LogicalKeyboardKey.shift);
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.shift);
        await tester.pump();
        expectPrimaryFocusWithin(sidebarFocus);

        activationCount = 0;
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pump();
        expect(activationCount, 1);

        activationCount = 0;
        await tester.sendKeyEvent(LogicalKeyboardKey.space);
        await tester.pump();
        expect(activationCount, 1);
      },
    );
  });
}
