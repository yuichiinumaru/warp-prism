// Host-composition proof for the staged job banner (Task 1858, F-10,
// AGENTS.md §7.1).
//
// Exercises DSJobBanner on two host-shaped routes in one composition: a
// Tempest-like separation route (multi-stage progress + cancel + injected
// elapsed label, mirroring `ProgressCard` in
// references/ganthritor-tempest/.../progress_card.dart) and a
// Command-center-like loading route (queued + terminal receipt banners
// inside a min-height guarded region, mirroring `StateRegion` +
// `LoadingRow`/`LoadingPane` in
// references/ganthritor-command-center/.../integration/loading.dart).
// Covers: real named-route entry, at least one meaningful interaction per
// route (cancel tap, route push), zero framework errors, no ErrorWidget,
// no RenderFlex overflow, representative viewport/text-scale conditions,
// and theme/focus propagation via the shared Prism theme.
//
// LIMITATION (recorded): the real Tempest, command-center, and Warpblade
// product hosts live outside this workspace boundary and no display host
// was available in this environment, so this is a flutter_tester
// headless composition sweep against host-shaped routes with real
// named-route navigation — not execution inside the real product hosts.
// Source provenance for the donor shapes is INHERITED REPORT:
//   - Tempest ProgressCard: references/ganthritor-tempest/flutter/lib/
//     features/separate/presentation/widgets/progress_card.dart
//     (prepare→chunk→post stages, progress bar, stopwatch, cancel) plus
//     docs/bridge/tempest/ads-debt.md and macro-review C6.
//   - Command-center loading trio: references/ganthritor-command-center/
//     apps/command_center/lib/integration/loading.dart
//     (non-animated determinism rationale loading.dart:3-11) plus
//     docs/bridge/command-center/prism-gap-components.md.
//   - Warpblade export banners: references/ganthritor-warpblade/apps/
//     warpblade-app/lib/src/ui/banners.dart
//     (indeterminate spinner vs terminal receipt, no lifecycle link).
// Run: flutter test packages/warp_prism_ui/test/molecules/job_banner_host_composition_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_ui/src/molecules/ds_job_banner.dart';
import 'package:warp_prism_ui/src/theme/ds_theme.dart';
import 'package:warp_prism_ui/src/tokens/tokens.dart';

/// Tempest-like separation route: staged job with cancel.
///
/// Mirrors the ProgressCard donor: prepare → model → separate → chunks →
/// combine → export stages, determinate progress, injected elapsed text
/// (time arrives caller-formatted; the banner runs no stopwatch), and a
/// cancel control with an announced reason.
class SeparateRoute extends StatelessWidget {
  final List<String> events;
  final FocusNode cancelFocus;
  const SeparateRoute({
    super.key,
    required this.events,
    required this.cancelFocus,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Separate')),
      body: SingleChildScrollView(
        child: DSJobBanner(
          title: 'Separate vocals',
          subtitle: 'Session 7 · take 3',
          phase: DSJobBannerPhase.running,
          progress: 0.5,
          stages: const [
            DSJobStage(
              label: 'Preparing',
              progress: 1.0,
              state: DSJobStageState.done,
            ),
            DSJobStage(
              label: 'Loading model',
              progress: 1.0,
              state: DSJobStageState.done,
            ),
            DSJobStage(
              label: 'Separating vocals',
              progress: 0.5,
              state: DSJobStageState.active,
            ),
            DSJobStage(label: 'Processing chunks'),
            DSJobStage(label: 'Combining results'),
            DSJobStage(label: 'Exporting'),
          ],
          elapsedLabel: '00:42',
          cancellable: true,
          cancelReason: 'Separation takes too long',
          onCancel: () => events.add('cancel:separate'),
          cancelFocusNode: cancelFocus,
        ),
      ),
    );
  }
}

/// Command-center-like loading route: queued + terminal receipt banners in
/// a min-height guarded region.
///
/// Mirrors StateRegion (min-height + scroll-when-short so a squeezed pane
/// degrades to scrollbars, never an overflow stripe) with the static
/// LoadingRow-equivalent banner chrome: deterministic, non-animated.
class LoadingRoute extends StatelessWidget {
  final List<String> events;
  const LoadingRoute({super.key, required this.events});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Loading')),
      body: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 120),
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 120),
            child: Column(
              children: [
                const DSJobBanner(
                  title: 'Daemon bootstrap',
                  phase: DSJobBannerPhase.queued,
                  stages: [
                    DSJobStage(label: 'Connect'),
                    DSJobStage(label: 'Sync state'),
                  ],
                ),
                const SizedBox(height: DSSpacing.md),
                DSJobBanner(
                  title: 'Session snapshot',
                  phase: DSJobBannerPhase.succeeded,
                  progress: 1.0,
                  receipt: TextButton(
                    onPressed: () => events.add('receipt:open'),
                    child: const Text('SESSION 7 · 42 events'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget _hostApp(List<String> events, FocusNode cancelFocus) {
  return MaterialApp(
    theme: DSTheme.dark(),
    initialRoute: '/separate',
    routes: {
      '/separate': (context) =>
          SeparateRoute(events: events, cancelFocus: cancelFocus),
      '/loading': (context) => LoadingRoute(events: events),
    },
  );
}

void main() {
  group('job banner host composition (Tempest + command-center sites)', () {
    testWidgets('named routes compose with interaction and no errors', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(1400, 2400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final errors = <FlutterErrorDetails>[];
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (details) {
        final message = details.exceptionAsString();
        if (message.contains('overflow') ||
            message.contains('RenderFlex') ||
            message.contains('ErrorWidget')) {
          errors.add(details);
          return;
        }
        originalOnError?.call(details);
      };
      addTearDown(() => FlutterError.onError = originalOnError);

      final events = <String>[];
      final cancelFocus = FocusNode();
      addTearDown(cancelFocus.dispose);

      await tester.pumpWidget(_hostApp(events, cancelFocus));
      await tester.pump();

      // Tempest-like site: staged banner renders, cancel offered.
      expect(find.text('Separate vocals'), findsOneWidget);
      expect(find.text('Separating vocals'), findsOneWidget);
      expect(find.text('50%'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      // The banner honors the loading-trio GOLD rule: no spinners.
      expect(find.byType(CircularProgressIndicator), findsNothing);

      // Meaningful interaction 1: cancel tap dispatches with the reason.
      await tester.tap(find.text('Cancel'));
      await tester.pump();
      expect(events, equals(['cancel:separate']));

      // Focus propagation: the cancel control is keyboard-reachable.
      cancelFocus.requestFocus();
      await tester.pump();
      expect(cancelFocus.hasFocus, isTrue);

      // Named-route entry 2: command-center-like loading route.
      Navigator.of(
        tester.element(find.text('Separate vocals')),
      ).pushNamed('/loading');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Daemon bootstrap'), findsOneWidget);
      expect(find.text('RECEIPT'), findsOneWidget);

      // Meaningful interaction 2: receipt action dispatches.
      await tester.tap(find.text('SESSION 7 · 42 events'));
      await tester.pump();
      expect(events, contains('receipt:open'));

      expect(
        errors,
        isEmpty,
        reason: 'Host composition must not produce framework errors',
      );
    });

    testWidgets('compact viewport and high text scale stay overflow-free', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(400, 700));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      var overflows = 0;
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (details) {
        final message = details.exceptionAsString();
        if (message.contains('overflow') || message.contains('RenderFlex')) {
          overflows++;
          return;
        }
        originalOnError?.call(details);
      };
      addTearDown(() => FlutterError.onError = originalOnError);

      final events = <String>[];
      final cancelFocus = FocusNode();
      addTearDown(cancelFocus.dispose);

      await tester.pumpWidget(
        Builder(
          builder: (context) {
            final data = MediaQuery.of(context);
            return MediaQuery(
              data: data.copyWith(textScaler: const TextScaler.linear(2.0)),
              child: _hostApp(events, cancelFocus),
            );
          },
        ),
      );
      await tester.pump();

      expect(find.text('Separate vocals'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pump();
      expect(events, equals(['cancel:separate']));

      expect(overflows, 0, reason: 'Compact + 2x text must not overflow');
    });
  });
}
