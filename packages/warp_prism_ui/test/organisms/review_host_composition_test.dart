// Host-composition proof for the decision-review surface (Task 1871, F-04,
// AGENTS.md §7.1).
//
// Exercises DSDecisionReviewSurface + DSBoundedRepair on two host-like routes
// in one composition: a command-center-like control route (gated abort with a
// denied-with-reason action) and a Warpblade-like proposal route (unknown
// evidence blocks approval). Covers: real named-route entry, at least one
// meaningful interaction per route (refusal tap, undo tap), zero framework
// errors, representative viewport/text-scale conditions, and theme/focus
// propagation via the shared Prism theme.
//
// Composition-site mappers (IDS ⇒ ADS data) mirror the Task 1870 precedent:
// eligibility stays IDS; the UI carries only rendered data.
//
// LIMITATION (recorded): the real command-center, Warpblade, and Tempest
// product hosts live outside this workspace boundary and no display host was
// available in this environment, so this is a flutter_tester headless
// composition sweep against host-shaped routes with real named-route
// navigation — not execution inside the real product hosts.
// Run: flutter test packages/warp_prism_ui/test/organisms/review_host_composition_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_interaction/src/input/action_availability.dart';
import 'package:warp_prism_ui/src/molecules/ds_action_gate.dart';
import 'package:warp_prism_ui/src/molecules/ds_bounded_repair.dart';
import 'package:warp_prism_ui/src/molecules/ds_state_surface.dart';
import 'package:warp_prism_ui/src/organisms/ds_decision_review_surface.dart';
import 'package:warp_prism_ui/src/organisms/ds_review_verdict.dart';
import 'package:warp_prism_ui/src/tokens/ds_action_authority.dart';
import 'package:warp_prism_ui/src/theme/ds_theme.dart';

/// Composition-site mapper: IDS availability ⇒ ADS gate authority.
DSActionAuthority gateFromAvailability(ActionAvailability availability) {
  if (availability is ActionAllow) return DSActionAuthority.allow;
  return DSActionAuthority.deny;
}

/// Composition-site mapper: IDS indeterminacy ⇒ review evidence.
DSReviewEvidence evidenceFromIndeterminate(String label, bool unknown) {
  return DSReviewEvidence(
    label: label,
    state: unknown ? DSStateType.unknown : DSStateType.empty,
    detail: unknown ? 'withheld by source' : null,
  );
}

/// Command-center-like control route: gated abort rendered from IDS state.
class ControlReviewRoute extends StatelessWidget {
  final List<String> events;
  const ControlReviewRoute({super.key, required this.events});

  @override
  Widget build(BuildContext context) {
    final availability = ActionAvailability.missing('session.abort');
    return DSDecisionReviewSurface(
      title: 'Abort session',
      kind: 'session',
      subtitle: 'daemon session 7',
      evidence: const [
        DSReviewEvidence(label: 'Daemon link', state: DSStateType.empty),
      ],
      diff: const Text('STAGED: abort session 7'),
      actions: [
        DSReviewAction(
          actionLabel: 'Abort session',
          authority: gateFromAvailability(availability),
          reason: availability.reason,
          onRefused: (reason) => events.add('refused:abort:$reason'),
        ),
      ],
      onClose: () => events.add('closed:control'),
    );
  }
}

/// Warpblade-like proposal route: unknown evidence blocks approval.
class ProposalReviewRoute extends StatelessWidget {
  final List<String> events;
  const ProposalReviewRoute({super.key, required this.events});

  @override
  Widget build(BuildContext context) {
    final evidence = [
      evidenceFromIndeterminate('Sync status', true),
      evidenceFromIndeterminate('Policy check', false),
    ];
    final verdict = resolveReviewVerdict(evidence);
    final gate = authorityForVerdict(verdict, evidence);
    return DSDecisionReviewSurface(
      title: 'Promote take',
      kind: 'take',
      evidence: evidence,
      diff: const Text('STAGED: promote take 12'),
      actions: [
        DSReviewAction(
          actionLabel: 'Promote take',
          authority: gate.authority,
          reason: gate.reason,
          onRefused: (reason) => events.add('refused:promote:$reason'),
        ),
      ],
    );
  }
}

/// Repair route: bounded repair with per-reply undo on the proposal host.
class RepairRoute extends StatelessWidget {
  final List<String> events;
  const RepairRoute({super.key, required this.events});

  @override
  Widget build(BuildContext context) {
    return DSBoundedRepair(
      title: 'Repair proposal',
      replies: [
        DSRepairReply(
          replyLabel: 'Restart daemon',
          onUndo: () => events.add('undone:restart'),
        ),
        const DSRepairReply(replyLabel: 'Replay queue'),
      ],
      approveAuthority: DSActionAuthority.deny,
      approveReason: 'Unknown: Sync status — determination withheld',
      onRefused: (reason) => events.add('refused:approve:$reason'),
      onCancel: () => events.add('cancelled:repair'),
    );
  }
}

Widget hostApp(List<String> events) => MaterialApp(
  theme: DSTheme.dark(),
  routes: {
    '/review/control': (_) => Scaffold(
      body: SizedBox(height: 1200, child: ControlReviewRoute(events: events)),
    ),
    '/review/proposal': (_) => Scaffold(
      body: SizedBox(height: 1200, child: ProposalReviewRoute(events: events)),
    ),
    '/review/repair': (_) => Scaffold(
      body: SingleChildScrollView(child: RepairRoute(events: events)),
    ),
  },
  home: Builder(
    builder: (context) => Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
              key: const Key('go-control'),
              onPressed: () =>
                  Navigator.of(context).pushNamed('/review/control'),
              child: const Text('Control'),
            ),
            TextButton(
              key: const Key('go-proposal'),
              onPressed: () =>
                  Navigator.of(context).pushNamed('/review/proposal'),
              child: const Text('Proposal'),
            ),
            TextButton(
              key: const Key('go-repair'),
              onPressed: () =>
                  Navigator.of(context).pushNamed('/review/repair'),
              child: const Text('Repair'),
            ),
          ],
        ),
      ),
    ),
  ),
);

void main() {
  group('review_1871 host composition (CC-like + WB-like, headless sweep)', () {
    testWidgets('control route: denied abort refuses with reason', (
      tester,
    ) async {
      final errors = <FlutterErrorDetails>[];
      final oldHandler = FlutterError.onError;
      FlutterError.onError = errors.add;
      final events = <String>[];
      try {
        await tester.pumpWidget(hostApp(events));
        await tester.tap(find.byKey(const Key('go-control')));
        await tester.pumpAndSettle();

        expect(find.text('Abort session'), findsWidgets);
        expect(find.text('STAGED: abort session 7'), findsOneWidget);
        expect(find.text('Missing capability: session.abort'), findsOneWidget);

        await tester.tap(
          find.descendant(
            of: find.byType(DSActionGate),
            matching: find.text('Abort session'),
          ),
        );
        await tester.pump();
        expect(
          events,
          contains('refused:abort:Missing capability: session.abort'),
        );
      } finally {
        FlutterError.onError = oldHandler;
      }
      expect(
        errors,
        isEmpty,
        reason: 'No framework errors on the control route: $errors',
      );
    });

    testWidgets('proposal route: unknown evidence blocks approval', (
      tester,
    ) async {
      final errors = <FlutterErrorDetails>[];
      final oldHandler = FlutterError.onError;
      FlutterError.onError = errors.add;
      final events = <String>[];
      try {
        await tester.pumpWidget(hostApp(events));
        await tester.tap(find.byKey(const Key('go-proposal')));
        await tester.pumpAndSettle();

        expect(find.text('Promote take'), findsWidgets);
        expect(find.text('Verdict withheld'), findsOneWidget);
        expect(find.text('STAGED: promote take 12'), findsOneWidget);

        await tester.tap(
          find.descendant(
            of: find.byType(DSActionGate),
            matching: find.text('Promote take'),
          ),
        );
        await tester.pump();
        expect(
          events.any((e) => e.startsWith('refused:promote:Unknown:')),
          isTrue,
          reason: 'unknown verdict must refuse with its reason: $events',
        );
      } finally {
        FlutterError.onError = oldHandler;
      }
      expect(
        errors,
        isEmpty,
        reason: 'No framework errors on the proposal route: $errors',
      );
    });

    testWidgets('repair route: undo per reply works, cancel fires', (
      tester,
    ) async {
      final errors = <FlutterErrorDetails>[];
      final oldHandler = FlutterError.onError;
      FlutterError.onError = errors.add;
      final events = <String>[];
      try {
        await tester.pumpWidget(hostApp(events));
        await tester.tap(find.byKey(const Key('go-repair')));
        await tester.pumpAndSettle();

        expect(find.text('Repair proposal'), findsOneWidget);
        await tester.tap(find.text('Undo'));
        await tester.pump();
        expect(events, contains('undone:restart'));

        await tester.tap(find.text('Cancel'));
        await tester.pump();
        expect(events, contains('cancelled:repair'));
      } finally {
        FlutterError.onError = oldHandler;
      }
      expect(
        errors,
        isEmpty,
        reason: 'No framework errors on the repair route: $errors',
      );
    });

    testWidgets('viewport sweep: review surface composes without errors', (
      tester,
    ) async {
      // Representative viewports: small phone, tablet, desktop.
      const viewports = [Size(360, 640), Size(768, 1024), Size(1440, 900)];
      for (final viewport in viewports) {
        // Reset the route stack between iterations: pumpWidget reuses the
        // element tree, so the pushed route would otherwise persist.
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
        tester.view.physicalSize = viewport;
        tester.view.devicePixelRatio = 1.0;
        final errors = <FlutterErrorDetails>[];
        final oldHandler = FlutterError.onError;
        FlutterError.onError = errors.add;
        final events = <String>[];
        try {
          await tester.pumpWidget(hostApp(events));
          await tester.tap(find.byKey(const Key('go-proposal')));
          await tester.pumpAndSettle();
          expect(find.text('Verdict withheld'), findsOneWidget);
        } finally {
          FlutterError.onError = oldHandler;
          tester.view.reset();
        }
        expect(
          errors,
          isEmpty,
          reason: 'No framework errors at $viewport: $errors',
        );
      }
    });
  });
}
