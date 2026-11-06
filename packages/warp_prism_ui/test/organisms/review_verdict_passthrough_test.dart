// Verdict pass-through suite (Task 1871, F-04).
//
// Proves the shared invariant: unknown/abstained evidence ⇒ unknown verdict,
// NEVER pass. Consumes Task 1869's frozen vocabulary (`DSStateType.unknown`
// + `isIndeterminate`) and Task 1868's frozen outcome type
// (`DSActionAuthority`) — nothing re-invented.
//
// Composition-site mappers (IDS `QueryState`/`ActionAvailability` ⇒ ADS data)
// live in this test only, mirroring the `mapIntent` precedent of Task 1870's
// `command_disabled_reason_test.dart`: eligibility stays IDS, the UI carries
// only rendered data.
//
// Failing-first provenance: written before `ds_review_verdict.dart` existed
// (Red), turned green by the implementation.
// Run: flutter test packages/warp_prism_ui/test/organisms/review_verdict_passthrough_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_interaction/src/inspection/inspection_state.dart';
import 'package:warp_prism_interaction/src/input/action_availability.dart';
import 'package:warp_prism_interaction/src/query/query_intent.dart';
import 'package:warp_prism_interaction/src/query/query_state.dart';
import 'package:warp_prism_ui/src/molecules/ds_state_surface.dart';
import 'package:warp_prism_ui/src/organisms/ds_review_verdict.dart';
import 'package:warp_prism_ui/src/tokens/ds_action_authority.dart';

/// Composition-site mapper: IDS query state ⇒ review evidence.
///
/// Indeterminacy projects through Task 1869's frozen vocabulary; determinate
/// states project onto the review evidence shape without inventing new
/// semantics.
DSReviewEvidence evidenceFromQuery<T extends Object>(
  String label,
  QueryState<T> state,
) {
  if (state.isIndeterminate) {
    final detail = state.detail ?? state.reason ?? state.status.name;
    return DSReviewEvidence(
      label: label,
      state: DSStateType.unknown,
      detail: detail,
    );
  }
  if (state.isError) {
    return DSReviewEvidence(
      label: label,
      state: DSStateType.error,
      detail: '$label failed',
    );
  }
  return DSReviewEvidence(label: label, state: DSStateType.empty);
}

/// Composition-site mapper: IDS authority outcome ⇒ ADS gate authority.
///
/// Same projection as `DSActionGate`'s token layer; the UI never evaluates
/// capability presence.
DSActionAuthority authorityFromAvailability(ActionAvailability availability) {
  if (availability is ActionAllow) return DSActionAuthority.allow;
  if (availability is ActionConstrain) {
    return DSActionAuthority.constrain;
  }
  return DSActionAuthority.deny;
}

QueryIntent testIntent(String id) => QueryIntent(rawQuery: id);

void main() {
  group(
    'review_1871 verdict pass-through: unknown evidence ⇒ unknown verdict',
    () {
      test('unknown query evidence never resolves to pass', () {
        final evidence = [
          evidenceFromQuery(
            'Sync status',
            QueryState<String>.unknown(
              intent: testIntent('sync'),
              detail: 'daemon unreachable',
            ),
          ),
          const DSReviewEvidence(
            label: 'Policy check',
            state: DSStateType.empty,
          ),
        ];

        final verdict = resolveReviewVerdict(evidence);

        expect(verdict, equals(DSReviewVerdict.unknown));
        expect(verdict, isNot(equals(DSReviewVerdict.pass)));
      });

      test('abstained query evidence never resolves to pass', () {
        final evidence = [
          evidenceFromQuery(
            'Operator review',
            QueryState<String>.abstained(
              intent: testIntent('op'),
              reason: 'operator declined',
            ),
          ),
        ];

        final verdict = resolveReviewVerdict(evidence);

        expect(verdict, equals(DSReviewVerdict.unknown));
        expect(verdict, isNot(equals(DSReviewVerdict.pass)));
      });

      test('notAttempted query evidence never resolves to pass', () {
        final evidence = [
          evidenceFromQuery(
            'Deferred probe',
            QueryState<String>.notAttempted(intent: testIntent('probe')),
          ),
        ];

        expect(resolveReviewVerdict(evidence), equals(DSReviewVerdict.unknown));
      });

      test('unknown inspection lifecycle never resolves to pass', () {
        const evidence = DSReviewEvidence(
          label: 'Inspector position',
          state: DSStateType.unknown,
          detail: 'restored without status',
        );
        expect(
          resolveReviewVerdict([evidence]),
          equals(DSReviewVerdict.unknown),
        );
        // The IDS lifecycle agrees: unknown holds no position.
        expect(InspectionLifecycle.unknown, isNot(InspectionLifecycle.active));
      });

      test('single unknown among passing evidence still blocks pass', () {
        final evidence = [
          const DSReviewEvidence(label: 'A', state: DSStateType.empty),
          const DSReviewEvidence(label: 'B', state: DSStateType.empty),
          const DSReviewEvidence(
            label: 'C',
            state: DSStateType.unknown,
            detail: 'withheld',
          ),
        ];

        expect(resolveReviewVerdict(evidence), isNot(DSReviewVerdict.pass));
      });

      test('error evidence resolves to fail, never pass or silent allow', () {
        final evidence = [
          evidenceFromQuery(
            'Policy check',
            QueryState<String>.error(
              intent: testIntent('policy'),
              error: 'denied by policy',
            ),
          ),
        ];

        expect(resolveReviewVerdict(evidence), equals(DSReviewVerdict.fail));
      });

      test('fully determinate evidence resolves to pass', () {
        const evidence = [
          DSReviewEvidence(label: 'A', state: DSStateType.empty),
          DSReviewEvidence(label: 'B', state: DSStateType.stale),
        ];

        expect(resolveReviewVerdict(evidence), equals(DSReviewVerdict.pass));
      });
    },
  );

  group('review_1871 tooltip reason per verdict', () {
    test('every verdict carries a non-empty tooltip reason', () {
      for (final verdict in DSReviewVerdict.values) {
        final reason = verdictReasonFor(verdict, const [
          DSReviewEvidence(label: 'A', state: DSStateType.empty),
        ]);
        expect(
          reason.trim(),
          isNotEmpty,
          reason: '$verdict must carry a tooltip reason',
        );
      }
    });

    test('unknown reason names the blocking evidence', () {
      final reason = verdictReasonFor(DSReviewVerdict.unknown, const [
        DSReviewEvidence(label: 'Sync status', state: DSStateType.unknown),
      ]);
      expect(reason, contains('Sync status'));
    });

    test('fail reason names the failing evidence', () {
      final reason = verdictReasonFor(DSReviewVerdict.fail, const [
        DSReviewEvidence(
          label: 'Policy check',
          state: DSStateType.error,
          detail: 'denied by policy',
        ),
      ]);
      expect(reason, contains('Policy check'));
    });
  });

  group('review_1871 gated actions resolve through Task 1868 outcome', () {
    test('unknown verdict maps to deny (fail-closed), never allow', () {
      final authority = authorityForVerdict(DSReviewVerdict.unknown, const [
        DSReviewEvidence(label: 'Sync status', state: DSStateType.unknown),
      ]);

      expect(authority.authority, equals(DSActionAuthority.deny));
      expect(authority.reason, isNotNull);
      expect(authority.reason!.trim(), isNotEmpty);
    });

    test('fail verdict maps to deny with the failure reason', () {
      final authority = authorityForVerdict(DSReviewVerdict.fail, const [
        DSReviewEvidence(
          label: 'Policy check',
          state: DSStateType.error,
          detail: 'denied by policy',
        ),
      ]);

      expect(authority.authority, equals(DSActionAuthority.deny));
      expect(authority.reason, contains('denied by policy'));
    });

    test('pass verdict maps to allow without a reason', () {
      final authority = authorityForVerdict(DSReviewVerdict.pass, const [
        DSReviewEvidence(label: 'A', state: DSStateType.empty),
      ]);

      expect(authority.authority, equals(DSActionAuthority.allow));
    });

    test('IDS deny projects onto the ADS deny authority at composition', () {
      final availability = ActionAvailability.missing('session.abort');
      expect(availability.isDenied, isTrue);
      expect(
        authorityFromAvailability(availability),
        equals(DSActionAuthority.deny),
      );
    });
  });

  group('review_1871 fake/reference conformance + determinism', () {
    test('reference policy agrees with the resolver on scripted cases', () {
      const policy = ReferenceReviewPolicy(
        script: {
          'sync': DSReviewVerdict.unknown,
          'policy': DSReviewVerdict.fail,
        },
      );
      const syncEvidence = DSReviewEvidence(
        label: 'sync',
        state: DSStateType.unknown,
      );
      const policyEvidence = DSReviewEvidence(
        label: 'policy',
        state: DSStateType.error,
      );

      expect(policy.resolve([syncEvidence]), equals(DSReviewVerdict.unknown));
      expect(policy.resolve([policyEvidence]), equals(DSReviewVerdict.fail));
      // Unscripted evidence falls back to the shared resolver: same input ⇒
      // same output, no divergence between fake and reference.
      const openEvidence = DSReviewEvidence(
        label: 'open',
        state: DSStateType.empty,
      );
      expect(
        policy.resolve([openEvidence]),
        equals(resolveReviewVerdict([openEvidence])),
      );
    });

    test('resolution is deterministic: repeated calls agree', () {
      const evidence = [
        DSReviewEvidence(
          label: 'Sync status',
          state: DSStateType.unknown,
          detail: 'daemon unreachable',
        ),
        DSReviewEvidence(label: 'Policy check', state: DSStateType.error),
      ];

      final first = resolveReviewVerdict(evidence);
      final second = resolveReviewVerdict(evidence);
      expect(second, equals(first));
      expect(
        verdictReasonFor(first, evidence),
        equals(verdictReasonFor(second, evidence)),
      );
    });
  });
}
