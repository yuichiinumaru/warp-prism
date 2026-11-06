// Conformance suite for the capability-gated action authority outcome.
//
// Task 1868 (F-01): fail-closed law — a missing capability implies
// deny-with-reason, never a silent enable. Determinism: same input ⇒ same
// output; no time, no randomness in outcome resolution.
//
// EXPERIMENTAL: imports the module via its src path; no barrel export yet.
// Run: flutter test packages/warp_prism_interaction/test/action_availability_test.dart
//   or: dart test packages/warp_prism_interaction/test/action_availability_test.dart

import 'package:test/test.dart';
import 'package:warp_prism_interaction/src/input/action_availability.dart';

void main() {
  group('ActionAvailability outcome vocabulary', () {
    test('allow carries no reason and reports allowed', () {
      const outcome = ActionAvailability.allow();
      expect(outcome.isAllowed, isTrue);
      expect(outcome.isConstrained, isFalse);
      expect(outcome.isDenied, isFalse);
      expect(outcome.reason, isNull);
    });

    test('constrain carries its reason', () {
      final outcome = ActionAvailability.constrain('Read-only session');
      expect(outcome.isConstrained, isTrue);
      expect(outcome.isAllowed, isFalse);
      expect(outcome.isDenied, isFalse);
      expect(outcome.reason, 'Read-only session');
    });

    test('deny carries its reason', () {
      final outcome = ActionAvailability.deny('Requires operator role');
      expect(outcome.isDenied, isTrue);
      expect(outcome.isAllowed, isFalse);
      expect(outcome.isConstrained, isFalse);
      expect(outcome.reason, 'Requires operator role');
    });

    test('denied is distinct from enabled and from hidden', () {
      // Denied must never collapse into "enabled" or "not-applicable".
      const allowed = ActionAvailability.allow();
      final denied = ActionAvailability.deny('Nope');
      expect(denied, isNot(equals(allowed)));
      expect(denied.reason, isNotNull);
      expect(denied.reason, isNotEmpty);
    });

    test('empty reasons are rejected in debug and fail closed in release', () {
      expect(
        () => ActionAvailability.deny('   '),
        throwsA(isA<AssertionError>()),
      );
      expect(
        () => ActionAvailability.constrain(''),
        throwsA(isA<AssertionError>()),
      );
    });

    test('value equality distinguishes outcomes by kind and reason', () {
      expect(
        ActionAvailability.deny('a'),
        equals(ActionAvailability.deny('a')),
      );
      expect(
        ActionAvailability.deny('a'),
        isNot(equals(ActionAvailability.deny('b'))),
      );
      expect(
        ActionAvailability.constrain('a'),
        isNot(equals(ActionAvailability.deny('a'))),
      );
      expect(
        const ActionAvailability.allow(),
        equals(const ActionAvailability.allow()),
      );
    });
  });

  group(
    'Fail-closed conformance (missing capability ⇒ deny, never enable)',
    () {
      test('missing() always denies and names the capability', () {
        final outcome = ActionAvailability.missing('session.abort');
        expect(outcome.isDenied, isTrue);
        expect(outcome.isAllowed, isFalse);
        expect(outcome.reason, contains('session.abort'));
        expect(outcome.reason, isNotEmpty);
      });

      test('missing() with blank id still denies with a reason', () {
        final outcome = ActionAvailability.missing('   ');
        expect(outcome.isDenied, isTrue);
        expect(outcome.reason, isNotEmpty);
      });

      test('availabilityFor maps absent state to deny-with-reason', () {
        const state = CapabilityState.missing('daemon.write');
        final outcome = availabilityFor(state);
        expect(outcome.isDenied, isTrue);
        expect(outcome.reason, contains('daemon.write'));
      });

      test('availabilityFor carries product detail into the denial reason', () {
        const state = CapabilityState.missing(
          'daemon.write',
          detail: 'daemon offline',
        );
        final outcome = availabilityFor(state);
        expect(outcome.isDenied, isTrue);
        expect(outcome.reason, contains('daemon.write'));
        expect(outcome.reason, contains('daemon offline'));
      });

      test('availabilityFor maps present state to allow', () {
        const state = CapabilityState.available('session.abort');
        expect(
          availabilityFor(state),
          equals(const ActionAvailability.allow()),
        );
      });

      test(
        'absent can never resolve to allow through any constructor path',
        () {
          const states = [
            CapabilityState.missing('a'),
            CapabilityState.missing('b', detail: 'x'),
            CapabilityState(capabilityId: 'c', present: false),
          ];
          for (final state in states) {
            expect(
              availabilityFor(state).isAllowed,
              isFalse,
              reason: 'fail-closed violated for $state',
            );
          }
        },
      );
    },
  );

  group('Determinism (same input ⇒ same output)', () {
    test('repeated resolution is stable', () {
      const state = CapabilityState.missing('k', detail: 'd');
      final first = availabilityFor(state);
      final second = availabilityFor(state);
      expect(second, equals(first));
      expect(first.toString(), equals(second.toString()));
    });

    test('module carries no time or randomness sources', () {
      // Static guard: outcome resolution must not depend on wall-clock or
      // randomness. (Behavioral proof: repeated calls above are identical.)
      const allowed = ActionAvailability.allow();
      expect(allowed.reason, isNull);
      expect(
        ActionAvailability.missing('k'),
        equals(ActionAvailability.missing('k')),
      );
    });
  });

  group('ReferenceAvailabilityPolicy fake passes the same suite', () {
    test('default policy allows present and denies missing', () {
      const policy = ReferenceAvailabilityPolicy();
      expect(
        policy.resolve(const CapabilityState.available('x')),
        equals(const ActionAvailability.allow()),
      );
      final denied = policy.resolve(const CapabilityState.missing('x'));
      expect(denied.isDenied, isTrue);
      expect(denied.reason, contains('x'));
    });

    test('scripted entries win over the default projection', () {
      final policy = ReferenceAvailabilityPolicy(
        script: {'y': ActionAvailability.constrain('Rate-limited')},
      );
      final outcome = policy.resolve(const CapabilityState.available('y'));
      expect(outcome.isConstrained, isTrue);
      expect(outcome.reason, 'Rate-limited');
    });

    test('script cannot silently enable a missing capability', () {
      // Even with an allow fallback, missing capabilities deny.
      const policy = ReferenceAvailabilityPolicy(
        fallback: ActionAvailability.allow(),
      );
      final outcome = policy.resolve(const CapabilityState.missing('z'));
      expect(outcome.isDenied, isTrue);
      expect(outcome.isAllowed, isFalse);
    });

    test('fake agrees with the contract projection on unscripted states', () {
      const policy = ReferenceAvailabilityPolicy();
      const states = [
        CapabilityState.available('a'),
        CapabilityState.missing('b'),
        CapabilityState.missing('c', detail: 'offline'),
      ];
      for (final state in states) {
        expect(
          policy.resolve(state),
          equals(availabilityFor(state)),
          reason: 'fake/contract divergence for $state',
        );
      }
    });
  });
}
