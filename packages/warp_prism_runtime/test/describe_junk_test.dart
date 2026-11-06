// Describe junk/adversarial sweep (Task 1867, part c).
//
// Mechanism mirror of `src/describe/`. Stable test ids follow the canonical
// convention (`stableTestId` in the testkit): `[describe_junk_<case>]`.
// Dispatch records carry caller ids/chords/reasons — junk must survive
// `describe()` verbatim, and a refused dispatch without a reason stays
// rejected at construction.

import 'package:test/test.dart';
import 'package:warp_prism_runtime/src/describe/runtime_describe.dart';

String _id(String c) => '[describe_junk_$c]';

void main() {
  group('describe junk sweep', () {
    test('${_id('dispatched_roundtrip')} junk ids survive describe', () {
      const junkId = '🔥-cmd-日本語 {{id}}';
      const record = CommandDispatchRecord(
        id: junkId,
        chord: '<chord/>',
        outcome: CommandDispatchOutcome.dispatched,
      );
      final described = record.describe();
      expect(described['id'], equals(junkId));
      expect(described['chord'], equals('<chord/>'));
      expect(described['outcome'], equals('dispatched'));
      expect(record.dispatched, isTrue);
    });

    test(
      '${_id('refused_keeps_reason')} junk refusal reasons are verbatim',
      () {
        const junkReason = 'Missing capability: 🔥 {{cap}}';
        const record = CommandDispatchRecord(
          id: 'cmd',
          outcome: CommandDispatchOutcome.refused,
          reason: junkReason,
        );
        expect(record.dispatched, isFalse);
        expect(record.describe()['reason'], equals(junkReason));
      },
    );

    test('${_id('refused_requires_reason')} reasonless refusal rejected', () {
      expect(
        () => CommandDispatchRecord(
          id: 'cmd',
          outcome: CommandDispatchOutcome.refused,
        ),
        throwsA(isA<AssertionError>()),
      );
    });
  });
}
