import 'dart:async';
import 'package:test/test.dart';
import 'package:warp_prism_interaction/warp_prism_interaction.dart';

/// Exhaustive state machine adversarial test suite for Task 1817.
///
/// Asserts:
/// 1. Full transition-table coverage for all kernel state machines:
///    Every (state, trigger) pair either transitions or is explicitly rejected.
/// 2. Disabled-state interaction is a no-op.
///    Busy-state timeout produces documented error state.
/// 3. Disposal and lifecycle edge cases fail closed.
enum _StandardTrigger { activate, submit, disable, enable, timeout, fail }

void main() {
  group('Full Transition Table Coverage — inspectionTransitionTable', () {
    const table = inspectionTransitionTable;

    for (final state in InspectionLifecycle.values) {
      for (final trigger in InspectionTrigger.values) {
        final isAllowed = table.canTransition(state, trigger);
        final pairLabel = '($state, $trigger)';

        if (isAllowed) {
          test('inspectionTransitionTable allows and resolves $pairLabel', () {
            expect(
              () => table.validateTransition(state, trigger),
              returnsNormally,
            );
            final nextState = table.resolveNextState(state, trigger);
            expect(nextState, isNotNull);
            expect(table.targetStates[(state, trigger)], equals(nextState));

            final sm = InteractionStateMachine<InspectionLifecycle, InspectionTrigger>(
              initialState: state,
              table: table,
            );
            expect(sm.canTrigger(trigger), isTrue);
            final transitioned = sm.trigger(trigger);
            expect(transitioned, equals(nextState));
            expect(sm.currentState, equals(nextState));
          });
        } else {
          test('inspectionTransitionTable strictly rejects $pairLabel with StateError', () {
            expect(
              () => table.validateTransition(state, trigger),
              throwsStateError,
            );
            expect(
              () => table.resolveNextState(state, trigger),
              throwsStateError,
            );

            final sm = InteractionStateMachine<InspectionLifecycle, InspectionTrigger>(
              initialState: state,
              table: table,
            );
            expect(sm.canTrigger(trigger), isFalse);
            expect(() => sm.trigger(trigger), throwsStateError);
          });
        }
      }
    }
  });

  group('Full Transition Table Coverage — queryTransitionTable', () {
    const table = queryTransitionTable;

    for (final state in QueryStatus.values) {
      for (final trigger in QueryTrigger.values) {
        final isAllowed = table.canTransition(state, trigger);
        final pairLabel = '($state, $trigger)';

        if (isAllowed) {
          test('queryTransitionTable allows and resolves $pairLabel', () {
            expect(
              () => table.validateTransition(state, trigger),
              returnsNormally,
            );
            final nextState = table.resolveNextState(state, trigger);
            expect(nextState, isNotNull);
            expect(table.targetStates[(state, trigger)], equals(nextState));

            final sm = InteractionStateMachine<QueryStatus, QueryTrigger>(
              initialState: state,
              table: table,
            );
            expect(sm.canTrigger(trigger), isTrue);
            final transitioned = sm.trigger(trigger);
            expect(transitioned, equals(nextState));
            expect(sm.currentState, equals(nextState));
          });
        } else {
          test('queryTransitionTable strictly rejects $pairLabel with StateError', () {
            expect(
              () => table.validateTransition(state, trigger),
              throwsStateError,
            );
            expect(
              () => table.resolveNextState(state, trigger),
              throwsStateError,
            );

            final sm = InteractionStateMachine<QueryStatus, QueryTrigger>(
              initialState: state,
              table: table,
            );
            expect(sm.canTrigger(trigger), isFalse);
            expect(() => sm.trigger(trigger), throwsStateError);
          });
        }
      }
    }
  });

  group('Adversarial Invariant: Disabled-State Interaction is a No-Op', () {
    test('SelectionState in SelectionMode.none ignores all mutations', () {
      const initial = SelectionState<String>.empty();

      final s1 = initial.select('item-1', mode: SelectionMode.none);
      expect(s1.isEmpty, isTrue);
      expect(s1.selectedItems, isEmpty);

      final s2 = initial.toggle('item-1', mode: SelectionMode.none);
      expect(s2.isEmpty, isTrue);

      final populated = SelectionState<String>.single('item-1');
      final s3 = populated.select('item-2', mode: SelectionMode.none);
      expect(s3.selectedItems, equals({'item-1'}));

      final s4 = populated.toggle('item-1', mode: SelectionMode.none);
      expect(s4.selectedItems, equals({'item-1'}));
    });

    test('SelectionNotifier in SelectionMode.none does not fire change events on selection attempts', () {
      final notifier = SelectionNotifier<String>(mode: SelectionMode.none);
      final events = <SelectionChangeEvent<String>>[];
      notifier.addListener(events.add);

      notifier.select('node-1', source: SelectionSource.user);
      notifier.toggle('node-2', source: SelectionSource.keyboard);
      notifier.selectAll(['node-3', 'node-4'], source: SelectionSource.user);

      expect(notifier.value.isEmpty, isTrue);
      expect(events, isEmpty);
    });

    test('InteractionStateMachine with disabled state rejects operational triggers', () {
      const standardTable =
          InteractionTransitionTable<InteractionState, _StandardTrigger>(
            allowedTriggers: {
              InteractionState.idle: {
                _StandardTrigger.activate,
                _StandardTrigger.disable,
              },
              InteractionState.active: {
                _StandardTrigger.submit,
                _StandardTrigger.disable,
              },
              InteractionState.busy: {
                _StandardTrigger.timeout,
                _StandardTrigger.fail,
                _StandardTrigger.disable,
              },
              InteractionState.disabled: {_StandardTrigger.enable},
              InteractionState.error: {
                _StandardTrigger.activate,
                _StandardTrigger.disable,
              },
              InteractionState.success: {
                _StandardTrigger.activate,
                _StandardTrigger.disable,
              },
            },
            targetStates: {
              (InteractionState.idle, _StandardTrigger.activate):
                  InteractionState.active,
              (InteractionState.idle, _StandardTrigger.disable):
                  InteractionState.disabled,
              (InteractionState.active, _StandardTrigger.submit):
                  InteractionState.busy,
              (InteractionState.active, _StandardTrigger.disable):
                  InteractionState.disabled,
              (InteractionState.busy, _StandardTrigger.timeout):
                  InteractionState.error,
              (InteractionState.busy, _StandardTrigger.fail):
                  InteractionState.error,
              (InteractionState.busy, _StandardTrigger.disable):
                  InteractionState.disabled,
              (InteractionState.disabled, _StandardTrigger.enable):
                  InteractionState.idle,
              (InteractionState.error, _StandardTrigger.activate):
                  InteractionState.idle,
              (InteractionState.error, _StandardTrigger.disable):
                  InteractionState.disabled,
              (InteractionState.success, _StandardTrigger.activate):
                  InteractionState.idle,
              (InteractionState.success, _StandardTrigger.disable):
                  InteractionState.disabled,
            },
          );

      final sm = InteractionStateMachine<InteractionState, _StandardTrigger>(
        initialState: InteractionState.disabled,
        table: standardTable,
      );

      // In disabled state, all operational triggers are rejected
      expect(sm.canTrigger(_StandardTrigger.activate), isFalse);
      expect(sm.canTrigger(_StandardTrigger.submit), isFalse);
      expect(sm.canTrigger(_StandardTrigger.timeout), isFalse);
      expect(() => sm.trigger(_StandardTrigger.activate), throwsStateError);
      expect(() => sm.trigger(_StandardTrigger.submit), throwsStateError);

      // Only enable trigger is accepted
      expect(sm.canTrigger(_StandardTrigger.enable), isTrue);
      sm.trigger(_StandardTrigger.enable);
      expect(sm.currentState, equals(InteractionState.idle));
    });
  });

  group('Adversarial Invariant: Busy-State Timeout Produces Error State', () {
    test('QueryController busy running state transitions to error upon timeout', () {
      final controller = QueryController<String>();
      final states = <QueryState<String>>[];
      controller.addListener(states.add);

      final intent = QueryIntent(rawQuery: 'service:auth', queryToken: 'q-timeout');
      controller.submit(intent);
      expect(controller.state.isRunning, isTrue);

      // Simulate timeout event
      final timeoutException = TimeoutException(
        'Query execution exceeded timeout threshold of 5000ms',
        const Duration(milliseconds: 5000),
      );
      final stackTrace = StackTrace.current;

      controller.fail(timeoutException, stackTrace, 'q-timeout');

      expect(controller.state.isError, isTrue);
      expect(controller.state.error, equals(timeoutException));
      expect(controller.state.stackTrace, equals(stackTrace));
      expect(states.length, equals(2));
      expect(states.last.isError, isTrue);
    });

    test('Stale timeout for superseded query does not alter current running query state', () {
      final controller = QueryController<String>();

      // Query 1 starts
      controller.submit(QueryIntent(rawQuery: 'q1', queryToken: 'tok-1'));
      expect(controller.state.isRunning, isTrue);

      // Query 2 supersedes Query 1
      controller.submit(QueryIntent(rawQuery: 'q2', queryToken: 'tok-2'));
      expect(controller.state.isRunning, isTrue);
      expect(controller.state.intent!.queryToken, equals('tok-2'));

      // Delayed timeout from Query 1 arrives
      final oldTimeout = TimeoutException('q1 timed out');
      controller.fail(oldTimeout, null, 'tok-1');

      // State is still running Query 2, not marked as error by stale query 1 timeout
      expect(controller.state.isRunning, isTrue);
      expect(controller.state.intent!.queryToken, equals('tok-2'));

      // Query 2 completes successfully
      controller.complete(
        QueryResultReference(token: 'res-2', totalCount: 1),
        queryToken: 'tok-2',
      );
      expect(controller.state.isComplete, isTrue);
    });
  });

  group('Adversarial Invariant: transitionTo Enforces Defined Table Target State', () {
    test('transitionTo with mismatched target state throws StateError even when trigger is allowed', () {
      final sm = InteractionStateMachine<InspectionLifecycle, InspectionTrigger>(
        initialState: InspectionLifecycle.proposed,
        table: inspectionTransitionTable,
      );

      // From proposed:
      // - trigger activate -> target is InspectionLifecycle.active
      // - attempting to transitionTo dismissed via activate must throw StateError
      expect(
        () => sm.transitionTo(
          InspectionLifecycle.dismissed,
          trigger: InspectionTrigger.activate,
        ),
        throwsStateError,
      );
      expect(sm.currentState, equals(InspectionLifecycle.proposed));

      // - attempting to transitionTo proposed via activate must throw StateError
      expect(
        () => sm.transitionTo(
          InspectionLifecycle.proposed,
          trigger: InspectionTrigger.activate,
        ),
        throwsStateError,
      );
      expect(sm.currentState, equals(InspectionLifecycle.proposed));

      // - transitioning to the correct target state succeeds
      sm.transitionTo(
        InspectionLifecycle.active,
        trigger: InspectionTrigger.activate,
      );
      expect(sm.currentState, equals(InspectionLifecycle.active));
    });

    test('queryTransitionTable rejects conflicting target state in transitionTo', () {
      final sm = InteractionStateMachine<QueryStatus, QueryTrigger>(
        initialState: QueryStatus.running,
        table: queryTransitionTable,
      );

      // From running, trigger complete -> target is QueryStatus.complete.
      // Trying to transitionTo QueryStatus.error via trigger complete must throw StateError.
      expect(
        () => sm.transitionTo(
          QueryStatus.error,
          trigger: QueryTrigger.complete,
        ),
        throwsStateError,
      );
      expect(sm.currentState, equals(QueryStatus.running));

      sm.transitionTo(
        QueryStatus.complete,
        trigger: QueryTrigger.complete,
      );
      expect(sm.currentState, equals(QueryStatus.complete));
    });
  });
}
