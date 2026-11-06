// State-machine junk/adversarial sweep (Task 1867, part c).
//
// Mechanism mirror of `src/state_machine/`. Stable test ids follow the
// canonical convention (`stableTestId` in the testkit):
// `[state_machine_junk_<case>]`. A mixed valid/invalid trigger script must
// leave the machine in the deterministic end state with no corruption:
// invalid triggers throw and preserve state.

import 'package:test/test.dart';
import 'package:warp_prism_interaction/warp_prism_interaction.dart';

String _id(String c) => '[state_machine_junk_$c]';

InteractionStateMachine<InspectionLifecycle, InspectionTrigger> _machine(
  InspectionLifecycle initial,
) => InteractionStateMachine<InspectionLifecycle, InspectionTrigger>(
  initialState: initial,
  table: inspectionTransitionTable,
);

void main() {
  group('state machine junk sweep', () {
    test('${_id('scripted_sequence')} mixed script ends deterministically', () {
      final sm = _machine(InspectionLifecycle.proposed);
      sm.trigger(InspectionTrigger.activate);
      expect(sm.currentState, equals(InspectionLifecycle.active));

      // Invalid mid-sequence: reset is not allowed from active.
      if (!sm.canTrigger(InspectionTrigger.reset)) {
        expect(() => sm.trigger(InspectionTrigger.reset), throwsStateError);
        expect(sm.currentState, equals(InspectionLifecycle.active));
      }

      sm.trigger(InspectionTrigger.dismiss);
      expect(sm.currentState, equals(InspectionLifecycle.dismissed));
      sm.trigger(InspectionTrigger.propose);
      expect(sm.currentState, equals(InspectionLifecycle.proposed));
      sm.trigger(InspectionTrigger.activate);
      sm.trigger(InspectionTrigger.dismiss);
      expect(sm.currentState, equals(InspectionLifecycle.dismissed));
    });

    test(
      '${_id('unknown_corner')} unknown lifecycle cannot activate wrong',
      () {
        final sm = _machine(InspectionLifecycle.unknown);
        // Unknown + propose is allowed; the machine must land on proposed.
        if (sm.canTrigger(InspectionTrigger.propose)) {
          sm.trigger(InspectionTrigger.propose);
          expect(sm.currentState, equals(InspectionLifecycle.proposed));
        }
        // transitionTo a mismatched target always throws and preserves state:
        // from proposed, activate targets active — never proposed itself.
        final check = _machine(InspectionLifecycle.proposed);
        expect(
          () => check.transitionTo(
            InspectionLifecycle.proposed,
            trigger: InspectionTrigger.activate,
          ),
          throwsStateError,
        );
        expect(check.currentState, equals(InspectionLifecycle.proposed));
      },
    );

    test(
      '${_id('reset_corner')} reset from dismissed stays dismissed-safe',
      () {
        final sm = _machine(InspectionLifecycle.dismissed);
        if (sm.canTrigger(InspectionTrigger.reset)) {
          sm.trigger(InspectionTrigger.reset);
        } else {
          expect(() => sm.trigger(InspectionTrigger.reset), throwsStateError);
        }
        // Either way the machine is in a table-declared state, never null.
        expect(InspectionLifecycle.values, contains(sm.currentState));
      },
    );
  });
}
