import 'package:test/test.dart';
import 'package:warp_prism_interaction/warp_prism_interaction.dart';

enum TestState { initial, loading, ready, failed }

enum TestTrigger { start, succeed, fail, reset }

void main() {
  group('InteractionState enum', () {
    test('all expected states are represented', () {
      expect(InteractionState.values, contains(InteractionState.idle));
      expect(InteractionState.values, contains(InteractionState.active));
      expect(InteractionState.values, contains(InteractionState.busy));
      expect(InteractionState.values, contains(InteractionState.disabled));
      expect(InteractionState.values, contains(InteractionState.error));
      expect(InteractionState.values, contains(InteractionState.success));
    });
  });

  group('InteractionTransitionTable', () {
    const table = InteractionTransitionTable<TestState, TestTrigger>(
      allowedTriggers: {
        TestState.initial: {TestTrigger.start},
        TestState.loading: {TestTrigger.succeed, TestTrigger.fail},
        TestState.ready: {TestTrigger.reset},
        TestState.failed: {TestTrigger.reset},
      },
      targetStates: {
        (TestState.initial, TestTrigger.start): TestState.loading,
        (TestState.loading, TestTrigger.succeed): TestState.ready,
        (TestState.loading, TestTrigger.fail): TestState.failed,
        (TestState.ready, TestTrigger.reset): TestState.initial,
        (TestState.failed, TestTrigger.reset): TestState.initial,
      },
    );

    test('valid transition checks and target resolution', () {
      expect(table.canTransition(TestState.initial, TestTrigger.start), isTrue);
      expect(
        table.canTransition(TestState.initial, TestTrigger.succeed),
        isFalse,
      );

      expect(
        table.resolveNextState(TestState.initial, TestTrigger.start),
        equals(TestState.loading),
      );
    });

    test('illegal transition throws StateError with diagnostics', () {
      expect(
        () => table.validateTransition(TestState.initial, TestTrigger.succeed),
        throwsStateError,
      );

      try {
        table.validateTransition(TestState.initial, TestTrigger.succeed);
        fail('Should have thrown StateError');
      } on StateError catch (e) {
        expect(e.message, contains('Illegal state transition'));
        expect(e.message, contains('TestState.initial'));
        expect(e.message, contains('TestTrigger.succeed'));
      }
    });
  });

  group('InteractionStateMachine', () {
    const table = InteractionTransitionTable<TestState, TestTrigger>(
      allowedTriggers: {
        TestState.initial: {TestTrigger.start},
        TestState.loading: {TestTrigger.succeed, TestTrigger.fail},
        TestState.ready: {TestTrigger.reset},
        TestState.failed: {TestTrigger.reset},
      },
      targetStates: {
        (TestState.initial, TestTrigger.start): TestState.loading,
        (TestState.loading, TestTrigger.succeed): TestState.ready,
        (TestState.loading, TestTrigger.fail): TestState.failed,
        (TestState.ready, TestTrigger.reset): TestState.initial,
        (TestState.failed, TestTrigger.reset): TestState.initial,
      },
    );

    test('triggering valid transitions and notifying listeners', () {
      final sm = InteractionStateMachine<TestState, TestTrigger>(
        initialState: TestState.initial,
        table: table,
      );

      final transitions = <(TestState, TestState, TestTrigger)>[];
      sm.addListener((prev, next, trig) {
        transitions.add((prev, next, trig));
      });

      expect(sm.currentState, equals(TestState.initial));
      expect(sm.canTrigger(TestTrigger.start), isTrue);
      expect(sm.canTrigger(TestTrigger.succeed), isFalse);

      final next = sm.trigger(TestTrigger.start);
      expect(next, equals(TestState.loading));
      expect(sm.currentState, equals(TestState.loading));
      expect(transitions.length, equals(1));
      expect(
        transitions.first,
        equals((TestState.initial, TestState.loading, TestTrigger.start)),
      );

      sm.trigger(TestTrigger.succeed);
      expect(sm.currentState, equals(TestState.ready));
      expect(transitions.length, equals(2));
    });

    test('transitionTo with trigger validation', () {
      final sm = InteractionStateMachine<TestState, TestTrigger>(
        initialState: TestState.initial,
        table: table,
      );

      // Mismatched target state for allowed trigger throws StateError
      expect(
        () => sm.transitionTo(TestState.ready, trigger: TestTrigger.start),
        throwsStateError,
      );

      sm.transitionTo(TestState.loading, trigger: TestTrigger.start);
      expect(sm.currentState, equals(TestState.loading));

      // Disallowed trigger in current state throws StateError
      expect(
        () => sm.transitionTo(TestState.initial, trigger: TestTrigger.start),
        throwsStateError,
      );
    });

    test('disposal prevents triggering', () {
      final sm = InteractionStateMachine<TestState, TestTrigger>(
        initialState: TestState.initial,
        table: table,
      );

      sm.dispose();
      expect(sm.isDisposed, isTrue);
      expect(sm.canTrigger(TestTrigger.start), isFalse);
      expect(() => sm.trigger(TestTrigger.start), throwsStateError);
    });
  });
}
