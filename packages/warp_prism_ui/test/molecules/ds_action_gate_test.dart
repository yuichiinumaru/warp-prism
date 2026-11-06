// Contract tests for DSActionGate (Task 1868, F-01).
//
// Proves: allow renders enabled; constrain renders enabled with a visible
// reason; deny renders disabled WITH a visible reason (never hidden) plus an
// a11y announcement; terminal-for-dispatch refusals surface the reason via
// onRefused; minimum 48x48 target; headless viewport/text-scale sweep.
//
// EXPERIMENTAL: imports the molecule via its src path; no barrel export yet.
// Run: flutter test packages/warp_prism_ui/test/molecules/ds_action_gate_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_ui/src/molecules/ds_action_gate.dart';
import 'package:warp_prism_ui/src/tokens/ds_action_authority.dart';

void main() {
  group('DSActionGate allow', () {
    testWidgets('renders enabled and dispatches on tap', (tester) async {
      var pressed = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DSActionGate.allowed(
              actionLabel: 'Abort session',
              onPressed: () => pressed++,
            ),
          ),
        ),
      );

      expect(find.text('Abort session'), findsOneWidget);
      await tester.tap(find.text('Abort session'));
      await tester.pump();
      expect(pressed, 1);
    });

    testWidgets('announces the allowed outcome', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DSActionGate.allowed(actionLabel: 'Abort session'),
          ),
        ),
      );

      final semantics = tester.getSemantics(find.byType(DSActionGate));
      expect(semantics.label, contains('Abort session'));
      expect(semantics.label, contains('Allowed'));
      handle.dispose();
    });
  });

  group('DSActionGate constrain', () {
    testWidgets('renders enabled with the limitation reason visible', (
      tester,
    ) async {
      var pressed = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DSActionGate.constrained(
              actionLabel: 'Deploy',
              reason: 'Read-only session: audit only',
              onPressed: () => pressed++,
            ),
          ),
        ),
      );

      expect(find.text('Deploy'), findsOneWidget);
      expect(find.text('Read-only session: audit only'), findsOneWidget);
      await tester.tap(find.text('Deploy'));
      await tester.pump();
      expect(pressed, 1);
    });

    testWidgets('announces the limitation', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DSActionGate.constrained(
              actionLabel: 'Deploy',
              reason: 'Rate-limited',
            ),
          ),
        ),
      );

      final semantics = tester.getSemantics(find.byType(DSActionGate));
      expect(semantics.label, contains('Constrained'));
      expect(semantics.label, contains('Rate-limited'));
      handle.dispose();
    });
  });

  group('DSActionGate deny (never hidden)', () {
    testWidgets('renders disabled WITH the reason visible', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DSActionGate.denied(
              actionLabel: 'Abort session',
              reason: 'Requires operator role',
            ),
          ),
        ),
      );

      // The action stays on screen: label AND reason both visible.
      expect(find.text('Abort session'), findsOneWidget);
      expect(find.text('Requires operator role'), findsOneWidget);
      expect(find.byType(DSActionGate), findsOneWidget);
    });

    testWidgets('does not dispatch when denied', (tester) async {
      var pressed = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DSActionGate(
              authority: DSActionAuthority.deny,
              actionLabel: 'Abort session',
              reason: 'Requires operator role',
              onPressed: () => pressed++,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Abort session'));
      await tester.pump();
      expect(pressed, 0);
    });

    testWidgets('announces the denial with its reason', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DSActionGate.denied(
              actionLabel: 'Abort session',
              reason: 'Requires operator role',
            ),
          ),
        ),
      );

      final semantics = tester.getSemantics(find.byType(DSActionGate));
      expect(semantics.label, contains('Abort session'));
      expect(semantics.label, contains('Denied'));
      expect(semantics.label, contains('Requires operator role'));
      handle.dispose();
    });

    testWidgets('terminal refusal surfaces the reason via onRefused', (
      tester,
    ) async {
      String? refused;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DSActionGate.denied(
              actionLabel: 'Abort session',
              reason: 'Requires operator role',
              onRefused: (reason) => refused = reason,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Abort session'));
      await tester.pump();
      expect(refused, 'Requires operator role');
    });

    testWidgets('denied gate keeps a minimum 48x48 target', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DSActionGate.denied(
              actionLabel: 'Abort session',
              reason: 'Requires operator role',
            ),
          ),
        ),
      );

      final size = tester.getSize(find.byType(DSActionGate));
      expect(size.width, greaterThanOrEqualTo(48));
      expect(size.height, greaterThanOrEqualTo(48));
    });

    testWidgets('all three outcomes stay mounted (none hidden)', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                DSActionGate.allowed(
                  actionLabel: 'Allowed action',
                  onPressed: () {},
                ),
                const DSActionGate.constrained(
                  actionLabel: 'Constrained action',
                  reason: 'Limited quota',
                ),
                const DSActionGate.denied(
                  actionLabel: 'Denied action',
                  reason: 'Missing capability: x',
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Allowed action'), findsOneWidget);
      expect(find.text('Constrained action'), findsOneWidget);
      expect(find.text('Limited quota'), findsOneWidget);
      expect(find.text('Denied action'), findsOneWidget);
      expect(find.text('Missing capability: x'), findsOneWidget);
      expect(find.byType(DSActionGate), findsNWidgets(3));
      // Every gate keeps a non-zero footprint: nothing collapses to hidden.
      for (final gate in find.byType(DSActionGate).evaluate()) {
        final size = tester.getSize(find.byWidget(gate.widget));
        expect(size.width, greaterThan(0));
        expect(size.height, greaterThan(0));
      }
    });
  });

  group('DSActionGate headless host sweep (AGENTS 7.1 fallback)', () {
    // Real-host exercise (command-center + Warpblade routes) is unavailable
    // from this workspace: those hosts live outside the authorized workspace
    // boundary. This sweep proves compositional robustness headlessly across
    // representative viewports and text scales instead, and records the
    // limitation. See the Worker Handoff Packet for the exact limitation.
    const viewports = [Size(360, 640), Size(800, 600), Size(1920, 1080)];
    const textScales = [1.0, 2.0];

    for (final viewport in viewports) {
      for (final textScale in textScales) {
        testWidgets('denied gate composes without framework errors '
            'at ${viewport.width}x${viewport.height} @${textScale}x', (
          tester,
        ) async {
          final errors = <FlutterErrorDetails>[];
          final previousOnError = FlutterError.onError;
          FlutterError.onError = errors.add;

          try {
            tester.view.physicalSize = viewport;
            tester.view.devicePixelRatio = 1.0;

            await tester.pumpWidget(
              MediaQuery(
                data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
                child: MaterialApp(
                  home: Scaffold(
                    body: SingleChildScrollView(
                      child: Column(
                        children: [
                          DSActionGate.allowed(
                            actionLabel: 'Retry',
                            onPressed: () {},
                          ),
                          const DSActionGate.constrained(
                            actionLabel: 'Deploy',
                            reason: 'Sweep limitation reason',
                          ),
                          const DSActionGate.denied(
                            actionLabel: 'Abort',
                            reason: 'Sweep denial reason',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
            await tester.pump();
          } finally {
            FlutterError.onError = previousOnError;
            tester.view.reset();
          }

          expect(find.text('Retry'), findsOneWidget);
          expect(find.text('Deploy'), findsOneWidget);
          expect(find.text('Sweep limitation reason'), findsOneWidget);
          expect(find.text('Abort'), findsOneWidget);
          expect(find.text('Sweep denial reason'), findsOneWidget);
          expect(
            errors,
            isEmpty,
            reason: 'framework errors during headless sweep: $errors',
          );
        });
      }
    }
  });
}
