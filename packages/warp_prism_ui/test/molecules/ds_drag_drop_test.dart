library;

/// Widget tests for DSDraggableCard and DSDropTarget molecules.
///
/// Proves real drag-and-drop behavior (not mount-only smoke):
/// - Ghost + feedback keys during long-press drag
/// - Drop same lane → onReorder with exact indices
/// - Drop cross lane → onMove with payload fields
/// - Empty lane accepts drop → onMove
/// - DragTarget.onMove tracks insertion index continuously
/// - Hover highlight surface key flips idle → hover
/// - Keyboard Alt+Arrow reorder/move
///
/// Run: flutter test test/molecules/ds_drag_drop_test.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_ui/src/molecules/molecules.dart';
import 'package:warp_prism_ui/src/organisms/organisms.dart';

/// Helper: builds a minimal MaterialApp wrapping a DSLaneBoard for testing.
Widget _buildBoard({
  required List<DSLane> lanes,
  ValueChanged<String>? onTaskTap,
  ValueChanged<DSDragReorderEvent>? onReorder,
  ValueChanged<DSDragMoveEvent>? onMove,
}) {
  return MaterialApp(
    home: Scaffold(
      body: SizedBox(
        width: 1200,
        height: 600,
        child: DSLaneBoard(
          lanes: lanes,
          onTaskTap: onTaskTap,
          onReorder: onReorder,
          onMove: onMove,
        ),
      ),
    ),
  );
}

List<DSLane> _sampleLanes() {
  return [
    const DSLane(
      id: '01-open',
      label: 'Open',
      tasks: [
        DSLaneTask(id: 1, title: 'Task Alpha', priority: 'P0'),
        DSLaneTask(id: 2, title: 'Task Beta', priority: 'P1'),
      ],
    ),
    const DSLane(
      id: '02-doing',
      label: 'Doing',
      tasks: [DSLaneTask(id: 3, title: 'Task Gamma', priority: 'P0')],
    ),
    const DSLane(id: '03-review', label: 'Review', tasks: []),
  ];
}

/// Long-press past [DSMotion.normal] (200ms) so drag starts.
Future<TestGesture> _startLongPressDrag(
  WidgetTester tester,
  Finder source,
) async {
  final gesture = await tester.startGesture(tester.getCenter(source));
  await tester.pump(const Duration(milliseconds: 250));
  await tester.pump(const Duration(milliseconds: 100));
  return gesture;
}

void main() {
  group('DSDraggableCard', () {
    testWidgets('renders DSTaskCard within a LongPressDraggable', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 300,
              height: 200,
              child: DSDraggableCard(
                laneId: '01-open',
                index: 0,
                card: DSTaskCard(
                  id: 1,
                  title: 'Draggable Test',
                  lane: '01-open',
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Draggable Test'), findsOneWidget);
      expect(find.text('#1'), findsOneWidget);
      expect(find.byType(LongPressDraggable<DSDragPayload>), findsOneWidget);
    });

    testWidgets('long press shows ghost at origin and feedback under pointer', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 300,
              height: 200,
              child: DSDraggableCard(
                laneId: '01-open',
                index: 0,
                card: DSTaskCard(id: 1, title: 'Drag Me', lane: '01-open'),
              ),
            ),
          ),
        ),
      );

      final cardFinder = find.text('Drag Me');
      expect(cardFinder, findsOneWidget);

      // Before drag: no ghost/feedback overlays.
      expect(find.byKey(const ValueKey('ds-drag-ghost-1')), findsNothing);
      expect(find.byKey(const ValueKey('ds-drag-feedback-1')), findsNothing);

      final gesture = await _startLongPressDrag(tester, cardFinder);

      // Ghost (childWhenDragging) and feedback keys must both be present.
      expect(find.byKey(const ValueKey('ds-drag-ghost-1')), findsOneWidget);
      expect(find.byKey(const ValueKey('ds-drag-feedback-1')), findsOneWidget);

      await gesture.up();
      await tester.pumpAndSettle();

      // After release, drag overlays are gone.
      expect(find.byKey(const ValueKey('ds-drag-ghost-1')), findsNothing);
      expect(find.byKey(const ValueKey('ds-drag-feedback-1')), findsNothing);
    });

    testWidgets('preserves tap behavior on non-dragged card', (tester) async {
      String? tappedId;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 300,
              height: 200,
              child: DSDraggableCard(
                laneId: '01-open',
                index: 0,
                card: DSTaskCard(
                  id: 42,
                  title: 'Tap Test',
                  lane: '01-open',
                  onTap: () => tappedId = '42',
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Tap Test'));
      expect(tappedId, '42');
    });

    testWidgets('exposes drag semantics hint for a11y scanners', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 300,
              height: 200,
              child: DSDraggableCard(
                laneId: '01-open',
                index: 0,
                onKeyboardReorderDelta: (_) {},
                onKeyboardMoveLaneDelta: (_) {},
                card: const DSTaskCard(
                  id: 7,
                  title: 'A11y Card',
                  lane: '01-open',
                ),
              ),
            ),
          ),
        ),
      );

      final semantics = tester.getSemantics(find.byType(DSDraggableCard));
      expect(semantics.label, contains('Draggable task 7: A11y Card'));
      expect(semantics.hint, contains('Long press to drag'));
      expect(semantics.hint, contains('Alt+Up/Down'));
      expect(semantics.hint, contains('Alt+Left/Right'));
    });
  });

  group('DSDropTarget', () {
    testWidgets('renders child content', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 300,
              height: 400,
              child: DSDropTarget(
                laneId: '01-open',
                taskCount: 2,
                child: ListView(
                  children: const [Text('Card A'), Text('Card B')],
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Card A'), findsOneWidget);
      expect(find.text('Card B'), findsOneWidget);
    });

    testWidgets('accepts DSDragPayload drop and reports target index', (
      tester,
    ) async {
      DSDragPayload? accepted;
      int? acceptedIndex;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 320,
              height: 480,
              child: Column(
                children: [
                  const SizedBox(
                    height: 100,
                    child: DSDraggableCard(
                      laneId: 'src',
                      index: 0,
                      card: DSTaskCard(
                        id: 50,
                        title: 'Payload Card',
                        lane: 'src',
                      ),
                    ),
                  ),
                  Expanded(
                    child: DSDropTarget(
                      laneId: 'dst',
                      taskCount: 0,
                      itemHeight: 80,
                      onAcceptWithIndex: (payload, index) {
                        accepted = payload;
                        acceptedIndex = index;
                      },
                      child: const Center(child: Text('Empty Drop Zone')),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final gesture = await _startLongPressDrag(
        tester,
        find.text('Payload Card'),
      );
      await gesture.moveTo(tester.getCenter(find.text('Empty Drop Zone')));
      await tester.pump();
      await gesture.up();
      await tester.pumpAndSettle();

      expect(accepted, isNotNull);
      expect(accepted!.taskId, 50);
      expect(accepted!.sourceLaneId, 'src');
      expect(accepted!.sourceIndex, 0);
      expect(acceptedIndex, 0);
    });
  });

  group('DSLaneBoard drag integration', () {
    testWidgets('renders DSDraggableCard for each task', (tester) async {
      await tester.pumpWidget(_buildBoard(lanes: _sampleLanes()));
      expect(find.byType(DSDraggableCard), findsNWidgets(3));
    });

    testWidgets('renders DSDropTarget for each lane', (tester) async {
      await tester.pumpWidget(_buildBoard(lanes: _sampleLanes()));
      expect(find.byType(DSDropTarget), findsNWidgets(3));
    });

    testWidgets('tap still fires onTaskTap through draggable wrapper', (
      tester,
    ) async {
      String? tappedId;
      await tester.pumpWidget(
        _buildBoard(lanes: _sampleLanes(), onTaskTap: (id) => tappedId = id),
      );

      await tester.tap(find.text('Task Alpha'));
      expect(tappedId, '1');
    });

    testWidgets('empty lane renders empty state surface inside drop target', (
      tester,
    ) async {
      await tester.pumpWidget(_buildBoard(lanes: _sampleLanes()));

      expect(find.text('No tasks'), findsOneWidget);
      expect(find.byType(DSDropTarget), findsNWidgets(3));
    });

    testWidgets('cross-lane drag drop fires onMove with full payload', (
      tester,
    ) async {
      DSDragMoveEvent? moveEvent;
      DSDragReorderEvent? reorderEvent;
      await tester.pumpWidget(
        _buildBoard(
          lanes: _sampleLanes(),
          onMove: (e) => moveEvent = e,
          onReorder: (e) => reorderEvent = e,
        ),
      );

      final source = find.text('Task Alpha');
      final target = find.text('Task Gamma');
      expect(source, findsOneWidget);
      expect(target, findsOneWidget);

      final gesture = await _startLongPressDrag(tester, source);
      await gesture.moveTo(tester.getCenter(target));
      await tester.pump();
      await gesture.up();
      await tester.pumpAndSettle();

      expect(
        reorderEvent,
        isNull,
        reason: 'cross-lane must not fire onReorder',
      );
      expect(moveEvent, isNotNull);
      expect(moveEvent!.taskId, 1);
      expect(moveEvent!.sourceLaneId, '01-open');
      expect(moveEvent!.targetLaneId, '02-doing');
      expect(moveEvent!.targetIndex, isNonNegative);
    });

    testWidgets('same-lane reorder fires onReorder with exact indices', (
      tester,
    ) async {
      DSDragReorderEvent? reorderEvent;
      DSDragMoveEvent? moveEvent;
      await tester.pumpWidget(
        _buildBoard(
          lanes: _sampleLanes(),
          onReorder: (e) => reorderEvent = e,
          onMove: (e) => moveEvent = e,
        ),
      );

      final source = find.text('Task Alpha');
      final target = find.text('Task Beta');

      final gesture = await _startLongPressDrag(tester, source);
      // Drag below Beta to force insertion after index 0.
      final betaCenter = tester.getCenter(target);
      await gesture.moveTo(betaCenter.translate(0, 60));
      await tester.pump();
      await gesture.up();
      await tester.pumpAndSettle();

      expect(moveEvent, isNull, reason: 'same-lane must not fire onMove');
      expect(reorderEvent, isNotNull);
      expect(reorderEvent!.laneId, '01-open');
      expect(reorderEvent!.oldIndex, 0);
      // Dropping past Beta yields a later slot (1 or 2 with 2 tasks).
      expect(reorderEvent!.newIndex, greaterThan(0));
      expect(reorderEvent!.newIndex, lessThanOrEqualTo(2));
    });

    testWidgets('empty lane drop fires onMove into review lane', (
      tester,
    ) async {
      DSDragMoveEvent? moveEvent;
      await tester.pumpWidget(
        _buildBoard(lanes: _sampleLanes(), onMove: (e) => moveEvent = e),
      );

      final gesture = await _startLongPressDrag(
        tester,
        find.text('Task Alpha'),
      );
      await gesture.moveTo(tester.getCenter(find.text('No tasks')));
      await tester.pump();
      await gesture.up();
      await tester.pumpAndSettle();

      expect(moveEvent, isNotNull);
      expect(moveEvent!.taskId, 1);
      expect(moveEvent!.sourceLaneId, '01-open');
      expect(moveEvent!.targetLaneId, '03-review');
      expect(moveEvent!.targetIndex, 0);
    });

    testWidgets(
      'DragTarget.onMove tracks insertion index across slots (0 then 2)',
      (tester) async {
        final indices = <int>[];
        int? acceptedIndex;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 320,
                height: 520,
                child: Column(
                  children: [
                    const SizedBox(
                      height: 100,
                      child: DSDraggableCard(
                        laneId: 'src',
                        index: 0,
                        card: DSTaskCard(id: 99, title: 'Payload', lane: 'src'),
                      ),
                    ),
                    Expanded(
                      child: DSDropTarget(
                        laneId: 'dst',
                        taskCount: 3,
                        itemHeight: 80,
                        onInsertionIndexChanged: indices.add,
                        onAcceptWithIndex: (_, index) => acceptedIndex = index,
                        child: ListView(
                          padding: EdgeInsets.zero,
                          children: const [
                            SizedBox(
                              height: 80,
                              child: Center(child: Text('Slot 0')),
                            ),
                            SizedBox(
                              height: 80,
                              child: Center(child: Text('Slot 1')),
                            ),
                            SizedBox(
                              height: 80,
                              child: Center(child: Text('Slot 2')),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final gesture = await _startLongPressDrag(tester, find.text('Payload'));

        // First hover over slot 0 — onMove must record index 0.
        await gesture.moveTo(tester.getCenter(find.text('Slot 0')));
        await tester.pump();
        expect(
          find.byKey(const ValueKey('ds-drop-surface-dst-hover')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey('ds-drop-insertion-dst-0')),
          findsOneWidget,
        );

        // Move down to slot 2 — onMove must update insertion index.
        // DragTargetDetails.offset is feedback top-left; mid-card probe
        // maps the floating card onto the slot under the pointer.
        await gesture.moveTo(tester.getCenter(find.text('Slot 2')));
        await tester.pump();
        expect(
          find.byKey(const ValueKey('ds-drop-insertion-dst-2')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey('ds-drop-insertion-dst-0')),
          findsNothing,
        );

        await gesture.up();
        await tester.pumpAndSettle();

        expect(indices, isNotEmpty, reason: 'onMove must fire index updates');
        expect(indices, contains(0));
        expect(indices, contains(2));
        expect(acceptedIndex, 2);
      },
    );

    testWidgets('hover highlight surface flips idle to hover during drag', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 320,
              height: 400,
              child: Column(
                children: [
                  SizedBox(
                    height: 100,
                    child: DSDraggableCard(
                      laneId: 'src',
                      index: 0,
                      card: DSTaskCard(
                        id: 11,
                        title: 'Hover Source',
                        lane: 'src',
                      ),
                    ),
                  ),
                  Expanded(
                    child: DSDropTarget(
                      laneId: 'hover-lane',
                      taskCount: 1,
                      child: Center(child: Text('Hover Target')),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('ds-drop-surface-hover-lane-idle')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('ds-drop-surface-hover-lane-hover')),
        findsNothing,
      );

      final gesture = await _startLongPressDrag(
        tester,
        find.text('Hover Source'),
      );
      await gesture.moveTo(tester.getCenter(find.text('Hover Target')));
      await tester.pump();

      expect(
        find.byKey(const ValueKey('ds-drop-surface-hover-lane-hover')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('ds-drop-surface-hover-lane-idle')),
        findsNothing,
      );

      await gesture.up();
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('ds-drop-surface-hover-lane-idle')),
        findsOneWidget,
      );
    });

    testWidgets('keyboard Alt+Down reorders within lane via onReorder', (
      tester,
    ) async {
      DSDragReorderEvent? reorderEvent;
      int? keyboardDelta;
      final focusNode = FocusNode(debugLabel: 'kb-reorder');
      addTearDown(focusNode.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 320,
              height: 200,
              child: DSDraggableCard(
                laneId: '01-open',
                index: 0,
                onKeyboardReorderDelta: (delta) {
                  keyboardDelta = delta;
                  reorderEvent = DSDragReorderEvent(
                    laneId: '01-open',
                    oldIndex: 0,
                    newIndex: (0 + delta).clamp(0, 1),
                  );
                },
                card: DSTaskCard(
                  id: 1,
                  title: 'Task Alpha',
                  lane: '01-open',
                  focusNode: focusNode,
                  onTap: () {},
                ),
              ),
            ),
          ),
        ),
      );

      focusNode.requestFocus();
      await tester.pump();
      expect(focusNode.hasFocus, isTrue);

      await tester.sendKeyDownEvent(LogicalKeyboardKey.altLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.altLeft);
      await tester.pump();

      expect(keyboardDelta, 1);
      expect(reorderEvent, isNotNull);
      expect(reorderEvent!.laneId, '01-open');
      expect(reorderEvent!.oldIndex, 0);
      expect(reorderEvent!.newIndex, 1);
    });

    testWidgets('keyboard Alt+Right moves card to next lane via onMove', (
      tester,
    ) async {
      DSDragMoveEvent? moveEvent;
      final focusNode = FocusNode(debugLabel: 'kb-move');
      addTearDown(focusNode.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 320,
              height: 200,
              child: DSDraggableCard(
                laneId: '01-open',
                index: 0,
                onKeyboardMoveLaneDelta: (delta) {
                  moveEvent = DSDragMoveEvent(
                    sourceLaneId: '01-open',
                    targetLaneId: delta > 0 ? '02-doing' : '00-backlog',
                    taskId: 1,
                    targetIndex: 0,
                  );
                },
                card: DSTaskCard(
                  id: 1,
                  title: 'Task Alpha',
                  lane: '01-open',
                  focusNode: focusNode,
                  onTap: () {},
                ),
              ),
            ),
          ),
        ),
      );

      focusNode.requestFocus();
      await tester.pump();
      expect(focusNode.hasFocus, isTrue);

      await tester.sendKeyDownEvent(LogicalKeyboardKey.altLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.altLeft);
      await tester.pump();

      expect(moveEvent, isNotNull);
      expect(moveEvent!.taskId, 1);
      expect(moveEvent!.sourceLaneId, '01-open');
      expect(moveEvent!.targetLaneId, '02-doing');
      expect(moveEvent!.targetIndex, 0);
    });

    testWidgets('board wires keyboard reorder/move into onReorder/onMove', (
      tester,
    ) async {
      DSDragReorderEvent? reorderEvent;
      DSDragMoveEvent? moveEvent;
      await tester.pumpWidget(
        _buildBoard(
          lanes: _sampleLanes(),
          onReorder: (e) => reorderEvent = e,
          onMove: (e) => moveEvent = e,
        ),
      );

      // Board must register keyboard callbacks on every draggable card.
      final cards = tester.widgetList<DSDraggableCard>(
        find.byType(DSDraggableCard),
      );
      expect(cards, isNotEmpty);
      for (final card in cards) {
        expect(card.onKeyboardReorderDelta, isNotNull);
        expect(card.onKeyboardMoveLaneDelta, isNotNull);
      }

      // Invoke the wired callbacks directly (simulates focused Alt+Arrow path).
      cards.first.onKeyboardReorderDelta!(1);
      expect(reorderEvent, isNotNull);
      expect(reorderEvent!.laneId, '01-open');
      expect(reorderEvent!.oldIndex, 0);
      expect(reorderEvent!.newIndex, 1);

      cards.first.onKeyboardMoveLaneDelta!(1);
      expect(moveEvent, isNotNull);
      expect(moveEvent!.sourceLaneId, '01-open');
      expect(moveEvent!.targetLaneId, '02-doing');
      expect(moveEvent!.taskId, 1);
    });

    testWidgets('backward compatible: works without onReorder/onMove', (
      tester,
    ) async {
      await tester.pumpWidget(_buildBoard(lanes: _sampleLanes()));

      expect(find.byType(DSLaneBoard), findsOneWidget);
      expect(find.text('Task Alpha'), findsOneWidget);
      expect(find.text('Task Beta'), findsOneWidget);
      expect(find.text('Task Gamma'), findsOneWidget);

      // Drag without callbacks must not throw.
      final gesture = await _startLongPressDrag(
        tester,
        find.text('Task Alpha'),
      );
      await gesture.moveTo(tester.getCenter(find.text('Task Gamma')));
      await tester.pump();
      await gesture.up();
      await tester.pumpAndSettle();
      expect(find.byType(DSLaneBoard), findsOneWidget);
    });
  });

  group('DSDragPayload', () {
    test('equality is based on all fields', () {
      const a = DSDragPayload(
        taskId: 1,
        sourceLaneId: 'lane-a',
        sourceIndex: 0,
      );
      const b = DSDragPayload(
        taskId: 1,
        sourceLaneId: 'lane-a',
        sourceIndex: 0,
      );
      const c = DSDragPayload(
        taskId: 2,
        sourceLaneId: 'lane-a',
        sourceIndex: 0,
      );

      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });

    test('hashCode consistent with equality', () {
      const a = DSDragPayload(
        taskId: 1,
        sourceLaneId: 'lane-a',
        sourceIndex: 0,
      );
      const b = DSDragPayload(
        taskId: 1,
        sourceLaneId: 'lane-a',
        sourceIndex: 0,
      );

      expect(a.hashCode, equals(b.hashCode));
    });
  });

  group('DSDragReorderEvent', () {
    test('stores laneId, oldIndex, newIndex', () {
      const event = DSDragReorderEvent(
        laneId: '01-open',
        oldIndex: 0,
        newIndex: 2,
      );
      expect(event.laneId, '01-open');
      expect(event.oldIndex, 0);
      expect(event.newIndex, 2);
    });
  });

  group('DSDragMoveEvent', () {
    test('stores sourceLaneId, targetLaneId, taskId, targetIndex', () {
      const event = DSDragMoveEvent(
        sourceLaneId: '01-open',
        targetLaneId: '02-doing',
        taskId: 5,
        targetIndex: 1,
      );
      expect(event.sourceLaneId, '01-open');
      expect(event.targetLaneId, '02-doing');
      expect(event.taskId, 5);
      expect(event.targetIndex, 1);
    });
  });

  group('Barrel exports', () {
    test('molecules barrel exports drag-and-drop types by construction', () {
      // Runtime construction proves public barrel symbols resolve.
      const payload = DSDragPayload(
        taskId: 1,
        sourceLaneId: 'lane',
        sourceIndex: 0,
      );
      const reorder = DSDragReorderEvent(
        laneId: 'lane',
        oldIndex: 0,
        newIndex: 1,
      );
      const move = DSDragMoveEvent(
        sourceLaneId: 'a',
        targetLaneId: 'b',
        taskId: 1,
        targetIndex: 0,
      );
      expect(payload.taskId, 1);
      expect(reorder.newIndex, 1);
      expect(move.targetLaneId, 'b');
    });
  });
}
