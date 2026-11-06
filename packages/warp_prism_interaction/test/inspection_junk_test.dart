// Inspection junk/adversarial sweep (Task 1867, part c).
//
// Mechanism mirror of `src/inspection/`. Stable test ids follow the canonical
// convention (`stableTestId` in the testkit): `[inspection_junk_<case>]`.
// Targets are opaque caller data; the transition table must agree with
// itself (can/validate/trigger) on every (state, trigger) pair — fail-closed
// both ways.

import 'package:test/test.dart';
import 'package:warp_prism_interaction/warp_prism_interaction.dart';

List<String> _junkTargets() => <String>[
  '',
  ' ',
  'null',
  'node:🔥:日本語',
  '<b>label</b>',
  '{{target}}',
  '../../secret',
  'a' * 300,
];

String _id(String c) => '[inspection_junk_$c]';

void main() {
  group('inspection junk sweep', () {
    test('${_id('intent_roundtrip')} junk targets round-trip', () {
      for (final junk in _junkTargets()) {
        final intent = InspectionIntent<String>(
          target: junk,
          targetType: junk,
          reason: junk,
        );
        expect(intent.target, equals(junk));
        expect(intent.targetType, equals(junk));
        expect(intent.reason, equals(junk));
        expect(
          intent,
          equals(
            InspectionIntent<String>(
              target: junk,
              targetType: junk,
              reason: junk,
            ),
          ),
        );
      }
    });

    test('${_id('unknown_payload_flags')} unknown stays indeterminate', () {
      final payload = InspectionPayload<String>(
        intent: InspectionIntent<String>(target: '🔥'),
        status: InspectionLifecycle.unknown,
      );
      expect(payload.status, equals(InspectionLifecycle.unknown));
      expect(payload.isUnknown, isTrue);
      expect(payload.isActive, isFalse);
      expect(payload.isProposed, isFalse);
      expect(payload.isDismissed, isFalse);
    });

    for (final state in InspectionLifecycle.values) {
      test(
        '${_id('table_${state.name}')} table agrees with itself from $state',
        () {
          const table = inspectionTransitionTable;
          for (final trigger in InspectionTrigger.values) {
            final allowed = table.canTransition(state, trigger);
            final probe =
                InteractionStateMachine<InspectionLifecycle, InspectionTrigger>(
                  initialState: state,
                  table: table,
                );
            expect(probe.canTrigger(trigger), equals(allowed));
            if (allowed) {
              expect(
                () => table.validateTransition(state, trigger),
                returnsNormally,
              );
              probe.trigger(trigger);
              expect(
                probe.currentState,
                equals(table.resolveNextState(state, trigger)),
              );
            } else {
              expect(
                () => table.validateTransition(state, trigger),
                throwsStateError,
              );
              expect(() => probe.trigger(trigger), throwsStateError);
              expect(probe.currentState, equals(state));
            }
          }
        },
      );
    }
  });
}
