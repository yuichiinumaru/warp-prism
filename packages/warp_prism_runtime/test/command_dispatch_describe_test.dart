// Conformance suite for the runtime describe() seam (Task 1870, F-03).
//
// Proves: dispatch records carry identity/chord/outcome/reason, refusals
// require a reason (asserted in debug, fail-closed in release), describe()
// is JSON-compatible and stable, and the record stays presentation-free.
//
// EXPERIMENTAL: imports the seam via its src/describe/ path; no barrel
// export yet. Run: dart test packages/warp_prism_runtime/test/command_dispatch_describe_test.dart

import 'package:test/test.dart';
import 'package:warp_prism_runtime/src/describe/runtime_describe.dart';

void main() {
  group('CommandDispatchRecord', () {
    test('dispatched record describes identity, chord and outcome', () {
      const record = CommandDispatchRecord.dispatched(
        id: 'theme.toggle',
        chord: 'ctrl+t',
        index: 2,
      );
      expect(record.dispatched, isTrue);
      expect(record.reason, isNull);
      final described = record.describe();
      expect(described['id'], equals('theme.toggle'));
      expect(described['chord'], equals('ctrl+t'));
      expect(described['outcome'], equals('dispatched'));
      expect(described['index'], equals(2));
    });

    test('refused record carries its reason', () {
      final record = CommandDispatchRecord.refused(
        id: 'deploy.promote',
        chord: 'ctrl+d',
        reason: 'Missing capability: deploy.promote',
      );
      expect(record.dispatched, isFalse);
      expect(record.reason, equals('Missing capability: deploy.promote'));
      expect(record.describe()['outcome'], equals('refused'));
    });

    test('refusals require a non-empty reason', () {
      expect(
        () => CommandDispatchRecord.refused(id: 'x', reason: '   '),
        throwsA(isA<AssertionError>()),
      );
    });

    test('describe() output is stable and JSON-compatible', () {
      const record = CommandDispatchRecord.dispatched(
        id: 'catalog.open',
        chord: 'ctrl+k',
      );
      final first = record.describe();
      final second = record.describe();
      expect(second, equals(first));
      for (final value in first.values) {
        expect(
          value == null || value is String || value is num || value is bool,
          isTrue,
          reason: 'describe() values must be JSON-compatible scalars',
        );
      }
    });

    test('records compare by value', () {
      const a = CommandDispatchRecord.dispatched(id: 'x', chord: 'ctrl+x');
      const b = CommandDispatchRecord.dispatched(id: 'x', chord: 'ctrl+x');
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });
  });
}
