// Widget tests for the decision-review surface (Task 1871, F-04).
//
// Proves the organism renders inspector + evidence + caller-diff +
// caller-action-bar, that the verdict banner follows the shared pass-through
// invariant (unknown evidence ⇒ unknown banner, never pass), and that every
// gated action carries its tooltip reason.
// Run: flutter test packages/warp_prism_ui/test/organisms/decision_review_surface_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_ui/src/molecules/ds_action_gate.dart';
import 'package:warp_prism_ui/src/molecules/ds_state_surface.dart';
import 'package:warp_prism_ui/src/organisms/ds_decision_review_surface.dart';
import 'package:warp_prism_ui/src/organisms/ds_detail_inspector.dart';
import 'package:warp_prism_ui/src/organisms/ds_review_verdict.dart';
import 'package:warp_prism_ui/src/tokens/ds_action_authority.dart';

Widget wrapInApp(Widget child) {
  return MaterialApp(
    home: Scaffold(body: SizedBox(height: 1200, child: child)),
  );
}

const unknownEvidence = [
  DSReviewEvidence(
    label: 'Sync status',
    state: DSStateType.unknown,
    detail: 'daemon unreachable',
  ),
  DSReviewEvidence(label: 'Policy check', state: DSStateType.empty),
];

void main() {
  group('review_1871 surface composition', () {
    testWidgets('renders inspector + evidence + diff + action bar', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrapInApp(
          DSDecisionReviewSurface(
            title: 'Promote deploy',
            kind: 'deploy',
            subtitle: 'staged build 42',
            inspectorSections: const [
              DSDetailSection(title: 'Detail', child: Text('caller detail')),
            ],
            evidence: const [
              DSReviewEvidence(label: 'Policy check', state: DSStateType.empty),
            ],
            diff: const Text('caller diff'),
            actions: [
              DSReviewAction(
                actionLabel: 'Promote',
                authority: DSActionAuthority.allow,
                onPressed: () {},
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Inspector framing carries the decision identity.
      expect(find.text('Promote deploy'), findsOneWidget);
      expect(find.text('caller detail'), findsOneWidget);
      // Evidence section with its row.
      expect(find.text('Evidence'), findsOneWidget);
      expect(find.text('Policy check'), findsOneWidget);
      // Caller diff slot passes through untouched.
      expect(find.text('caller diff'), findsOneWidget);
      // Caller action bar renders the gated action.
      expect(find.text('Promote'), findsOneWidget);
      expect(find.byType(DSActionGate), findsOneWidget);
    });

    testWidgets('unknown evidence renders the unknown banner, never pass', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrapInApp(
          const DSDecisionReviewSurface(
            title: 'Promote deploy',
            kind: 'deploy',
            evidence: unknownEvidence,
            actions: [
              DSReviewAction(
                actionLabel: 'Promote',
                authority: DSActionAuthority.deny,
                reason: 'Unknown: Sync status — determination withheld',
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Verdict withheld'), findsOneWidget);
      expect(find.byType(DSStateSurface), findsOneWidget);
      // Indeterminate rows name their withheld detail.
      expect(find.text('Unknown: daemon unreachable'), findsOneWidget);
      // No pass affordance anywhere.
      expect(find.textContaining('Passed'), findsNothing);
    });

    testWidgets('every gated action carries its tooltip reason', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrapInApp(
          const DSDecisionReviewSurface(
            title: 'Promote deploy',
            kind: 'deploy',
            evidence: unknownEvidence,
            actions: [
              DSReviewAction(
                actionLabel: 'Promote',
                authority: DSActionAuthority.deny,
                reason: 'Missing capability: deploy.promote',
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      final tooltips = tester
          .widgetList<Tooltip>(find.byType(Tooltip))
          .map((t) => t.message)
          .toList();
      expect(
        tooltips,
        contains('Missing capability: deploy.promote'),
        reason: 'gated action must expose its reason as a tooltip',
      );
    });

    testWidgets('denied action refuses with its reason, never dispatches', (
      tester,
    ) async {
      var pressed = 0;
      String? refused;
      await tester.pumpWidget(
        wrapInApp(
          DSDecisionReviewSurface(
            title: 'Abort session',
            kind: 'session',
            evidence: unknownEvidence,
            actions: [
              DSReviewAction(
                actionLabel: 'Abort',
                authority: DSActionAuthority.deny,
                reason: 'Requires operator role',
                onPressed: () => pressed++,
                onRefused: (reason) => refused = reason,
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Denied stays mounted with its reason visible (never hidden).
      expect(find.text('Abort'), findsOneWidget);
      expect(find.text('Requires operator role'), findsOneWidget);
      await tester.tap(find.text('Abort'));
      await tester.pump();
      expect(pressed, 0);
      expect(refused, 'Requires operator role');
    });

    testWidgets('surface announces the review outcome to assistive tech', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        wrapInApp(
          const DSDecisionReviewSurface(
            title: 'Promote deploy',
            kind: 'deploy',
            evidence: unknownEvidence,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final semantics = tester.getSemantics(
        find.byType(DSDecisionReviewSurface),
      );
      expect(semantics.label, contains('Decision review: Promote deploy'));
      expect(semantics.label, contains('unknown'));
      handle.dispose();
    });
  });
}
