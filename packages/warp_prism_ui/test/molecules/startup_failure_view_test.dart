// Startup-failure view + loading-chrome convergence tests (Task 1876, F-09).
//
// EXPERIMENTAL scope: `DSStartupFailureView` sanitizes bootstrap failure —
// no stack trace, exception string, or daemon internals ever render — and
// `DSStateSurface` convergence constructors map the CC bootstrap donors
// (LoadingPane / LoadingRow / StateRegion) plus Warpblade inline errors onto
// state-surface modes built on Task 1869's frozen unknown vocabulary.
//
// Failing-first provenance: written before `ds_startup_failure_view.dart`
// and the convergence constructors existed (Red), turned green by the
// implementation. Determinism: failure view is non-animated and excluded
// from golden capture; loading states are excluded from goldens.
//
// Run: flutter test packages/warp_prism_ui/test/molecules/startup_failure_view_test.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_ui/src/molecules/ds_state_surface.dart';
import 'package:warp_prism_ui/src/molecules/ds_shimmer.dart';
import 'package:warp_prism_ui/src/molecules/ds_startup_failure_view.dart';
import 'package:warp_prism_ui/src/organisms/ds_error_boundary.dart';
import 'package:warp_prism_ui/src/tokens/tokens.dart';

/// Test harness that avoids Material 3 InkSparkle (needs GPU shader stages
/// unavailable in headless CI / some Linux test backends).
Widget wrapInApp(Widget child) {
  return MaterialApp(
    theme: ThemeData(
      useMaterial3: true,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
    ),
    home: Scaffold(body: child),
  );
}

/// Adversarial daemon internals that must NEVER appear in the render tree.
const _adversarialPayloads = <String>[
  'cc-daemon.sock',
  'connection reset by peer',
  'FRB bridge panicked',
  'package:command_center/main.dart:42',
  '#0 DaemonBootstrap',
  'SocketException',
  'daemon token sk-live',
];

Object _adversarialCause() => StateError(
  'Daemon socket /run/cc-daemon.sock refused: connection reset by peer '
  '(SocketException, package:command_center/main.dart:42) '
  'FRB bridge panicked; daemon token sk-live-0000 '
  '#0 DaemonBootstrap.init #1 DaemonNotConnected.build',
);

void main() {
  group('DSStartupFailureView exists (EXPERIMENTAL)', () {
    test('declares sanitized failure + indeterminate constructors', () {
      const failed = DSStartupFailureView(cause: null);
      expect(failed.title, equals('Startup failed'));
      expect(failed.onRetry, isNull);
      expect(failed.compact, isFalse);

      const unclear = DSStartupFailureView.indeterminate();
      expect(unclear.title, equals('Startup state unclear'));
    });

    test('default guidance is fixed sanitized copy', () {
      expect(
        DSStartupFailureView.defaultGuidance,
        equals(
          'The workspace could not start. '
          'Check the connection and try again.',
        ),
      );
    });

    test('guard() composes with DSErrorBoundary', () {
      final guarded = DSStartupFailureView.guard(child: const Text('booting'));
      expect(guarded, isA<DSErrorBoundary>());
    });
  });

  group('leak-negative: internals never render', () {
    for (final payload in _adversarialPayloads) {
      testWidgets('adversarial fragment "$payload" absent', (tester) async {
        await tester.pumpWidget(
          wrapInApp(DSStartupFailureView(cause: _adversarialCause())),
        );

        expect(
          find.textContaining(payload),
          findsNothing,
          reason: 'daemon/exception internals must never render: $payload',
        );
      });
    }

    testWidgets('stack-trace-shaped text never renders', (tester) async {
      final tracedCause = StateError(
        'Daemon socket /run/cc-daemon.sock refused\n'
        '#0 DaemonBootstrap.init (package:command_center/main.dart:42)\n'
        '#1 DaemonNotConnected.build (package:command_center/main.dart:87)',
      );
      await tester.pumpWidget(
        wrapInApp(DSStartupFailureView(cause: tracedCause)),
      );

      expect(find.textContaining('#0'), findsNothing);
      expect(find.textContaining('package:'), findsNothing);
      expect(find.textContaining('StateError'), findsNothing);
    });

    testWidgets('sanitized copy renders instead of internals', (tester) async {
      await tester.pumpWidget(
        wrapInApp(DSStartupFailureView(cause: _adversarialCause())),
      );

      expect(find.text('Startup failed'), findsOneWidget);
      expect(find.text(DSStartupFailureView.defaultGuidance), findsOneWidget);
    });

    testWidgets('guard fallback sanitizes a throwing child', (tester) async {
      final previous = FlutterError.onError;
      addTearDown(() {
        FlutterError.onError = previous;
      });

      await tester.pumpWidget(
        wrapInApp(
          DSStartupFailureView.guard(
            child: _ThrowingBootChild(cause: _adversarialCause()),
          ),
        ),
      );

      tester.takeException();
      await tester.pump();
      await tester.pump();

      expect(find.byType(DSStartupFailureView), findsOneWidget);
      expect(find.text('Startup failed'), findsOneWidget);
      for (final payload in _adversarialPayloads) {
        expect(
          find.textContaining(payload),
          findsNothing,
          reason: 'boundary fallback must sanitize: $payload',
        );
      }
      expect(tester.takeException(), isNull);
    });
  });

  group('fail-closed on Task 1869 frozen vocabulary', () {
    testWidgets('indeterminate renders unknown, never success', (tester) async {
      await tester.pumpWidget(
        wrapInApp(const DSStartupFailureView.indeterminate()),
      );

      expect(find.byIcon(Icons.help_outline), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsNothing);
      expect(find.byIcon(Icons.verified), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(OutlinedButton), findsNothing);
    });

    test('indeterminate consumes the frozen unknown surface', () {
      expect(
        DSStateType.unknown.isIndeterminate,
        isTrue,
        reason: 'Task 1869 interface: unknown stays the indeterminate state',
      );
      const surface = DSStateSurface.unknown(title: 'x');
      expect(surface.stateType.isIndeterminate, isTrue);
    });
  });

  group('loading-chrome convergence onto DSStateSurface modes', () {
    test('LoadingPane maps onto the loading mode', () {
      const pane = DSStateSurface.loadingPane(title: 'Connecting…');
      expect(pane.stateType, equals(DSStateType.loading));
      expect(pane.title, equals('Connecting…'));
      expect(pane.compact, isFalse);
    });

    test('LoadingRow maps onto compact loading', () {
      const row = DSStateSurface.loadingRow(title: 'Connecting…');
      expect(row.stateType, equals(DSStateType.loading));
      expect(row.compact, isTrue);
    });

    test('Warpblade inline errors map onto compact error', () {
      const inline = DSStateSurface.inlineError(title: 'Parse failed');
      expect(inline.stateType, equals(DSStateType.error));
      expect(inline.compact, isTrue);
    });

    test('startupFailure carries sanitized defaults, no action by default', () {
      const failed = DSStateSurface.startupFailure();
      expect(failed.stateType, equals(DSStateType.error));
      expect(failed.title, equals('Startup failed'));
      expect(failed.subtitle, equals(DSStartupFailureView.defaultGuidance));
      expect(failed.onAction, isNull);
    });

    test('bootstrapLoading carries the starting title', () {
      const loading = DSStateSurface.bootstrapLoading();
      expect(loading.stateType, equals(DSStateType.loading));
      expect(loading.title, equals('Starting…'));
    });

    testWidgets('converged modes render titles without leaking', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrapInApp(const DSStateSurface.loadingPane(title: 'Connecting…')),
      );
      expect(find.text('Connecting…'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpWidget(
        wrapInApp(const DSStateSurface.loadingRow(title: 'Connecting…')),
      );
      expect(find.text('Connecting…'), findsOneWidget);

      await tester.pumpWidget(
        wrapInApp(const DSStateSurface.inlineError(title: 'Parse failed')),
      );
      expect(find.text('Parse failed'), findsOneWidget);
      expect(find.byType(OutlinedButton), findsNothing);
    });
  });

  group('determinism: non-animated, excluded from goldens', () {
    testWidgets('failure view never animates', (tester) async {
      await tester.pumpWidget(
        wrapInApp(DSStartupFailureView(cause: _adversarialCause())),
      );

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(DSShimmer), findsNothing);
    });

    test('no golden captures startup or converged loading states', () {
      final candidates = [
        Directory('test/goldens'),
        Directory('packages/warp_prism_ui/test/goldens'),
      ];
      final goldensDir = candidates.firstWhere(
        (d) => d.existsSync(),
        orElse: () => candidates.first,
      );
      expect(
        goldensDir.existsSync(),
        isTrue,
        reason: 'run from warp-prism root or packages/warp_prism_ui',
      );
      final pattern = RegExp(
        r'StartupFailure|startupFailure|bootstrapLoading|loadingPane|loadingRow|inlineError',
      );
      final offenders = <String>[];
      for (final file
          in goldensDir
              .listSync(recursive: false)
              .whereType<File>()
              .where((f) => f.path.endsWith('_test.dart'))) {
        if (pattern.hasMatch(file.readAsStringSync())) {
          offenders.add(file.path);
        }
      }
      expect(
        offenders,
        isEmpty,
        reason:
            'startup/loading states must stay out of golden capture: $offenders',
      );
    });
  });

  group('a11y: failure and loading transitions announce', () {
    testWidgets('failure view raises a live-region announcement', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        wrapInApp(DSStartupFailureView(cause: _adversarialCause())),
      );

      final semantics = tester.getSemantics(find.byType(DSStartupFailureView));
      expect(semantics.label, contains('Startup failed'));
      expect(
        semantics.flagsCollection.isLiveRegion,
        isTrue,
        reason: 'bootstrap failure must announce when it appears',
      );
      handle.dispose();
    });

    testWidgets('loading-to-failure transition keeps announcements', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        wrapInApp(const DSStateSurface.bootstrapLoading()),
      );
      expect(
        tester.getSemantics(find.byType(DSStateSurface)).label,
        contains('Loading'),
      );

      // Simulated daemon failure: bootstrap route swaps to sanitized failure.
      await tester.pumpWidget(
        wrapInApp(DSStartupFailureView(cause: _adversarialCause())),
      );
      final failure = tester.getSemantics(find.byType(DSStartupFailureView));
      expect(failure.label, contains('Startup failed'));
      expect(failure.flagsCollection.isLiveRegion, isTrue);
      expect(tester.takeException(), isNull);
      handle.dispose();
    });
  });

  group('host proof: CC bootstrap route with simulated daemon failure', () {
    // INHERITED-REPORT donors (workspace boundary denies direct read of
    // sibling repos; shapes re-verified via docs/bridge/command-center/
    // prism-gap-components.md §§2.1/4): CC `DaemonBootstrap` (loading) →
    // `DaemonNotConnected` (failure) on the bootstrap route; WB inline
    // errors; CC LoadingPane/LoadingRow/StateRegion integration chrome.
    //
    // Limitation: real display host unavailable in this headless env; proof
    // runs as a `flutter_tester` headless sweep across representative
    // viewports. No pixels were visually inspected.
    Future<void> pumpBootstrapRoute(
      WidgetTester tester,
      Widget body,
      Size size,
    ) async {
      await tester.binding.setSurfaceSize(size);
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            useMaterial3: true,
            splashFactory: NoSplash.splashFactory,
            highlightColor: Colors.transparent,
            scaffoldBackgroundColor: DSColors.obsidianDeep,
          ),
          home: Scaffold(body: Center(child: body)),
        ),
      );
      await tester.pump();
    }

    for (final size in [const Size(320, 568), const Size(1280, 800)]) {
      testWidgets(
        'bootstrap loading then sanitized failure at ${size.width.toInt()}x${size.height.toInt()}',
        (tester) async {
          // 1. Enter the bootstrap route (loading, theme-provided obsidian).
          await pumpBootstrapRoute(
            tester,
            const DSStateSurface.bootstrapLoading(),
            size,
          );
          expect(find.text('Starting…'), findsOneWidget);
          expect(tester.takeException(), isNull);

          // 2. Simulated daemon failure: route swaps to sanitized failure.
          await pumpBootstrapRoute(
            tester,
            DSStartupFailureView(cause: _adversarialCause(), onRetry: () {}),
            size,
          );
          expect(find.text('Startup failed'), findsOneWidget);
          for (final payload in _adversarialPayloads) {
            expect(find.textContaining(payload), findsNothing);
          }
          expect(find.text('Retry'), findsOneWidget);

          // 3. Theme intact: obsidian scaffold still hosts the failure card.
          final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
          expect(scaffold.backgroundColor, isNull);

          // 4. Focus intact: retry affordance accepts focus.
          final focusNode = FocusNode();
          addTearDown(focusNode.dispose);
          await tester.pumpWidget(
            wrapInApp(
              DSStartupFailureView(
                cause: _adversarialCause(),
                onRetry: () {},
                focusNode: focusNode,
              ),
            ),
          );
          focusNode.requestFocus();
          await tester.pump();
          expect(focusNode.hasFocus, isTrue);
          expect(tester.takeException(), isNull);
        },
      );
    }
  });
}

/// Child that throws a daemon-shaped error during build.
class _ThrowingBootChild extends StatelessWidget {
  final Object cause;

  const _ThrowingBootChild({required this.cause});

  @override
  Widget build(BuildContext context) {
    Error.throwWithStackTrace(
      cause,
      StackTrace.fromString(
        '#0 DaemonBootstrap.init (package:command_center/main.dart:42)',
      ),
    );
  }
}
