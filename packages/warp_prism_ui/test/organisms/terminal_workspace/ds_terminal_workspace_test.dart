import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_ui/src/organisms/terminal_workspace/ds_terminal_workspace.dart';

// Local mirrors of public Prism* typedefs (src/prism_aliases.dart). Avoids
// importing package:warp_prism_ui/warp_prism_ui.dart which currently pulls
// unrelated in-progress organism compile breaks under concurrent builders.
// Alias source contract is asserted by the pure file test below.
typedef PrismTerminalWorkspace = DSTerminalWorkspace;
typedef PrismTerminalPane = DSTerminalPane;
typedef PrismTerminalLayoutMode = DSTerminalLayoutMode;
typedef PrismTerminalWorkspaceController = DSTerminalWorkspaceController;

void main() {
  Widget harness({
    required Widget child,
    double width = 800,
    double height = 600,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: SizedBox(width: width, height: height, child: child),
      ),
    );
  }

  group('PrismTerminalWorkspace / DSTerminalWorkspace', () {
    testWidgets('renders multiple panes in horizontal/vertical split layout', (
      tester,
    ) async {
      final controller = DSTerminalWorkspaceController(
        panes: [
          const DSTerminalPane(
            id: 't-1',
            title: 'Main Terminal',
            history: ['line 1-1'],
          ),
          const DSTerminalPane(
            id: 't-2',
            title: 'Agent Logs',
            history: ['line 2-1'],
          ),
        ],
        layoutMode: DSTerminalLayoutMode.splitHorizontal,
      );

      await tester.pumpWidget(
        harness(
          child: DSTerminalWorkspace(
            controller: controller,
            title: 'Test Console',
          ),
        ),
      );

      expect(find.text('Test Console'), findsOneWidget);
      expect(find.text('Main Terminal'), findsOneWidget);
      expect(find.text('Agent Logs'), findsOneWidget);
      expect(find.text('line 1-1'), findsOneWidget);
      expect(find.text('line 2-1'), findsOneWidget);

      // Change to vertical split
      controller.setLayoutMode(DSTerminalLayoutMode.splitVertical);
      await tester.pumpAndSettle();

      expect(find.text('line 1-1'), findsOneWidget);
      expect(find.text('line 2-1'), findsOneWidget);
    });

    testWidgets('supports switching focus on tap', (tester) async {
      final controller = DSTerminalWorkspaceController(
        panes: [
          const DSTerminalPane(
            id: 't-1',
            title: 'Main Terminal',
            history: ['line 1-1'],
          ),
          const DSTerminalPane(
            id: 't-2',
            title: 'Agent Logs',
            history: ['line 2-1'],
          ),
        ],
        layoutMode: DSTerminalLayoutMode.splitHorizontal,
      );

      await tester.pumpWidget(
        harness(child: DSTerminalWorkspace(controller: controller)),
      );

      // Initially, t-1 has focus (since it's the first pane)
      expect(controller.focusedPaneId, equals('t-1'));

      // Tap on the second pane header or body to switch focus
      await tester.tap(find.text('Agent Logs'));
      await tester.pumpAndSettle();

      expect(controller.focusedPaneId, equals('t-2'));
    });

    testWidgets('empty state renders correct message when no panes exist', (
      tester,
    ) async {
      bool addPaneCalled = false;
      final controller = DSTerminalWorkspaceController(panes: []);

      await tester.pumpWidget(
        harness(
          child: DSTerminalWorkspace(
            controller: controller,
            onAddPane: () => addPaneCalled = true,
          ),
        ),
      );

      // Finds empty state surface
      expect(find.text('No console panes'), findsOneWidget);
      expect(
        find.text('Open a new terminal pane to begin monitoring workspaces.'),
        findsOneWidget,
      );

      // Action button present
      final actionButton = find.text('Create Console');
      expect(actionButton, findsOneWidget);
      await tester.tap(actionButton);
      expect(addPaneCalled, isTrue);
    });

    testWidgets('renders and handles tab layout correctly', (tester) async {
      final controller = DSTerminalWorkspaceController(
        panes: [
          const DSTerminalPane(
            id: 't-1',
            title: 'Main Terminal',
            history: ['line 1-1'],
          ),
          const DSTerminalPane(
            id: 't-2',
            title: 'Agent Logs',
            history: ['line 2-1'],
          ),
        ],
        layoutMode: DSTerminalLayoutMode.tabs,
      );

      await tester.pumpWidget(
        harness(child: DSTerminalWorkspace(controller: controller)),
      );

      // In tab layout, both tab headers should exist
      expect(find.text('Main Terminal'), findsOneWidget);
      expect(find.text('Agent Logs'), findsOneWidget);

      // Since 't-1' is active, 'line 1-1' is shown, but 'line 2-1' should not be visible
      // (it might stand in the widget tree under IndexedStack but offstage/inactive)
      expect(find.text('line 1-1'), findsOneWidget);

      // Tap on second tab
      await tester.tap(find.text('Agent Logs'));
      await tester.pumpAndSettle();

      expect(controller.focusedPaneId, equals('t-2'));
    });

    testWidgets('command submit triggers callback', (tester) async {
      String? submittedPaneId;
      String? submittedCommand;

      final controller = DSTerminalWorkspaceController(
        panes: [
          const DSTerminalPane(id: 't-1', title: 'Main Terminal', history: []),
        ],
        layoutMode: DSTerminalLayoutMode.tabs,
      );

      await tester.pumpWidget(
        harness(
          child: DSTerminalWorkspace(
            controller: controller,
            onCommandSubmitted: (paneId, command) {
              submittedPaneId = paneId;
              submittedCommand = command;
            },
          ),
        ),
      );

      // Find textfield
      final textField = find.byType(TextField);
      expect(textField, findsOneWidget);

      await tester.enterText(textField, 'ping');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      expect(submittedPaneId, equals('t-1'));
      expect(submittedCommand, equals('ping'));
    });

    testWidgets('clears output and closes pane via buttons', (tester) async {
      final controller = DSTerminalWorkspaceController(
        panes: [
          const DSTerminalPane(
            id: 't-1',
            title: 'Main Terminal',
            history: ['output line'],
          ),
        ],
        layoutMode: DSTerminalLayoutMode.splitHorizontal,
      );

      await tester.pumpWidget(
        harness(child: DSTerminalWorkspace(controller: controller)),
      );

      expect(find.text('output line'), findsOneWidget);

      // Find clear button via tooltip or type
      final clearButton = find.byTooltip('Clear Output');
      expect(clearButton, findsOneWidget);
      await tester.tap(clearButton);
      await tester.pumpAndSettle();

      // History should now be empty, empty state message shows
      expect(find.text('output line'), findsNothing);

      // Find close button and tap it
      final closeButton = find.byTooltip('Close Pane');
      expect(closeButton, findsOneWidget);
      await tester.tap(closeButton);
      await tester.pumpAndSettle();

      expect(controller.panes, isEmpty);
    });

    testWidgets(
      'closing a pane disposes per-pane controllers (no resource leak)',
      (tester) async {
        final workspaceKey = GlobalKey();
        final controller = DSTerminalWorkspaceController(
          panes: [
            const DSTerminalPane(
              id: 'pane-a',
              title: 'Pane A',
              history: ['alpha'],
            ),
            const DSTerminalPane(
              id: 'pane-b',
              title: 'Pane B',
              history: ['beta'],
            ),
          ],
          layoutMode: DSTerminalLayoutMode.splitHorizontal,
        );

        await tester.pumpWidget(
          harness(
            child: DSTerminalWorkspace(
              key: workspaceKey,
              controller: controller,
            ),
          ),
        );
        await tester.pumpAndSettle();

        final state = workspaceKey.currentState! as dynamic;
        expect(state.debugOwnedPaneResourceCount, equals(2));

        controller.closePane('pane-a');
        await tester.pumpAndSettle();

        expect(controller.panes.map((p) => p.id), equals(['pane-b']));
        expect(state.debugOwnedPaneResourceCount, equals(1));
        expect(find.text('alpha'), findsNothing);
        expect(find.text('beta'), findsOneWidget);

        // Re-open same id allocates clean resources (no dispose-after-use crash).
        controller.addPane(
          const DSTerminalPane(
            id: 'pane-a',
            title: 'Pane A',
            history: ['alpha-2'],
          ),
        );
        await tester.pumpAndSettle();

        expect(state.debugOwnedPaneResourceCount, equals(2));
        expect(find.text('alpha-2'), findsOneWidget);

        controller.closePane('pane-a');
        controller.closePane('pane-b');
        await tester.pumpAndSettle();

        expect(controller.panes, isEmpty);
        expect(state.debugOwnedPaneResourceCount, equals(0));
      },
    );

    testWidgets('pane chrome clear/close meet 48dp min touch targets', (
      tester,
    ) async {
      final controller = DSTerminalWorkspaceController(
        panes: [
          const DSTerminalPane(
            id: 't-1',
            title: 'Main Terminal',
            history: ['line'],
          ),
        ],
        layoutMode: DSTerminalLayoutMode.splitHorizontal,
      );

      await tester.pumpWidget(
        harness(child: DSTerminalWorkspace(controller: controller)),
      );
      await tester.pumpAndSettle();

      // Measure the fixed 48×48 host boxes around chrome IconButtons.
      final clearHost = find.ancestor(
        of: find.byTooltip('Clear Output'),
        matching: find.byWidgetPredicate(
          (w) => w is SizedBox && w.width == 48 && w.height == 48,
        ),
      );
      final closeHost = find.ancestor(
        of: find.byTooltip('Close Pane'),
        matching: find.byWidgetPredicate(
          (w) => w is SizedBox && w.width == 48 && w.height == 48,
        ),
      );
      expect(tester.getSize(clearHost), equals(const Size(48, 48)));
      expect(tester.getSize(closeHost), equals(const Size(48, 48)));

      // Resolve IconButtons by tooltip field (find.byTooltip may hit RawTooltip).
      IconButton buttonWithTooltip(String tooltip) {
        return tester
            .widgetList<IconButton>(find.byType(IconButton))
            .firstWhere((b) => b.tooltip == tooltip);
      }

      final clearButton = buttonWithTooltip('Clear Output');
      final closeButton = buttonWithTooltip('Close Pane');
      expect(clearButton.constraints?.minWidth, greaterThanOrEqualTo(48));
      expect(clearButton.constraints?.minHeight, greaterThanOrEqualTo(48));
      expect(closeButton.constraints?.minWidth, greaterThanOrEqualTo(48));
      expect(closeButton.constraints?.minHeight, greaterThanOrEqualTo(48));
    });

    testWidgets('history growth auto-scrolls; focus change does not thrash', (
      tester,
    ) async {
      final controller = DSTerminalWorkspaceController(
        panes: [
          DSTerminalPane(
            id: 't-1',
            title: 'Main Terminal',
            history: List<String>.generate(40, (i) => 'seed-line-$i'),
          ),
        ],
        layoutMode: DSTerminalLayoutMode.splitHorizontal,
      );

      await tester.pumpWidget(
        harness(child: DSTerminalWorkspace(controller: controller)),
      );
      await tester.pumpAndSettle();

      final listFinder = find.byType(Scrollable);
      expect(listFinder, findsWidgets);

      // Scroll up away from bottom so thrash would be observable.
      final scrollable = find.byType(Scrollable).first;
      await tester.drag(scrollable, const Offset(0, 200));
      await tester.pumpAndSettle();

      final scrolledOffset = tester
          .state<ScrollableState>(scrollable)
          .position
          .pixels;

      // Focus-only notify must not force-scroll back to bottom.
      controller.focusPane('t-1');
      await tester.pumpAndSettle();
      final afterFocus = tester
          .state<ScrollableState>(scrollable)
          .position
          .pixels;
      expect(afterFocus, closeTo(scrolledOffset, 1.0));

      // New history line should auto-scroll toward max extent.
      controller.addHistoryLine('t-1', 'fresh-tail-line');
      await tester.pumpAndSettle();
      final afterGrow = tester
          .state<ScrollableState>(scrollable)
          .position
          .pixels;
      expect(afterGrow, greaterThan(afterFocus));
      expect(find.text('fresh-tail-line'), findsOneWidget);
    });

    testWidgets('public alias works interchangeably', (tester) async {
      final controller = PrismTerminalWorkspaceController(
        panes: [const PrismTerminalPane(id: 't-1', title: 'Alias Check')],
        layoutMode: PrismTerminalLayoutMode.splitHorizontal,
      );

      final widget = PrismTerminalWorkspace(controller: controller);

      expect(widget, isA<PrismTerminalWorkspace>());
      expect(widget, isA<DSTerminalWorkspace>());
      await tester.pumpWidget(harness(child: widget));
      expect(find.text('Alias Check'), findsOneWidget);
    });

    test('prism_aliases.dart declares PrismTerminal* typedefs', () {
      // Resolve package lib path from this test file location.
      final aliases = File(
        '${Directory.current.path}/lib/src/prism_aliases.dart',
      );
      expect(aliases.existsSync(), isTrue);
      final src = aliases.readAsStringSync();
      expect(
        src,
        contains('typedef PrismTerminalWorkspace = DSTerminalWorkspace;'),
      );
      expect(src, contains('typedef PrismTerminalPane = DSTerminalPane;'));
      expect(
        src,
        contains('typedef PrismTerminalLayoutMode = DSTerminalLayoutMode;'),
      );
      expect(
        src,
        contains(
          'typedef PrismTerminalWorkspaceController = DSTerminalWorkspaceController;',
        ),
      );
    });
  });
}
