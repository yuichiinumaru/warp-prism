// Widget tests for DSErrorBoundary and DSFallbackView.
//
// DSFallbackView: icon/title/retry/token styling.
// DSErrorBoundary: real throw-in-build capture, custom fallbackBuilder,
// retry rebuild, dispose restore of FlutterError.onError, nested stack.
//
// Run: flutter test test/molecules/ds_error_boundary_test.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_ui/src/organisms/organisms.dart';
import 'package:warp_prism_ui/src/tokens/tokens.dart';
import 'package:warp_prism_ui/src/atoms/atoms.dart';

void main() {
  group('DSFallbackView', () {
    testWidgets('renders error icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: DSFallbackView(error: 'Something failed')),
        ),
      );

      expect(find.byIcon(DSIcons.error), findsOneWidget);
    });

    testWidgets('renders default title', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: DSFallbackView(error: 'Something failed')),
        ),
      );

      expect(find.text('Something went wrong'), findsOneWidget);
    });

    testWidgets('renders custom title', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DSFallbackView(
              error: 'Something failed',
              title: 'Panel Crashed',
            ),
          ),
        ),
      );

      expect(find.text('Panel Crashed'), findsOneWidget);
    });

    testWidgets('shows error details in debug mode', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DSFallbackView(error: 'TestError("detail message")'),
          ),
        ),
      );

      if (kDebugMode) {
        expect(find.text('TestError("detail message")'), findsOneWidget);
      } else {
        expect(find.text('An unexpected error occurred.'), findsOneWidget);
      }
    });

    testWidgets('shows friendly message in release mode context', (
      tester,
    ) async {
      // The widget always shows kDebugMode-dependent text.
      // In test, kDebugMode is always true, so we verify the debug path.
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: DSFallbackView(error: 'InternalStateError')),
        ),
      );

      // The error message is shown (debug mode in tests)
      expect(find.textContaining('InternalStateError'), findsOneWidget);
    });

    testWidgets('shows retry button when onRetry is provided', (tester) async {
      var retried = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DSFallbackView(
              error: 'Failed',
              onRetry: () => retried = true,
            ),
          ),
        ),
      );

      expect(find.text('Retry'), findsOneWidget);
      await tester.tap(find.text('Retry'));
      expect(retried, true);
    });

    testWidgets('hides retry button when onRetry is null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: DSFallbackView(error: 'Failed')),
        ),
      );

      expect(find.text('Retry'), findsNothing);
    });

    testWidgets('uses DSGlassPanelSimple container', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: DSFallbackView(error: 'Test')),
        ),
      );

      expect(find.byType(DSGlassPanelSimple), findsOneWidget);
    });

    testWidgets('uses DSColors.statusError accent', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DSFallbackView(error: 'Test', onRetry: () {}),
          ),
        ),
      );

      // The icon should use DSColors.statusError
      final icon = tester.widget<Icon>(find.byIcon(DSIcons.error));
      expect(icon.color, DSColors.statusError);
    });

    testWidgets('renders stack trace in debug mode', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DSFallbackView(
              error: 'Crash',
              stackTrace: StackTrace.fromString('#0 main\n#1 test'),
            ),
          ),
        ),
      );

      // In debug mode, stack trace container is rendered
      if (kDebugMode) {
        expect(find.textContaining('#0 main'), findsOneWidget);
      }
    });
  });

  group('DSErrorBoundary', () {
    testWidgets('renders child normally when no error', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: DSErrorBoundary(child: Text('Healthy child'))),
        ),
      );

      expect(find.text('Healthy child'), findsOneWidget);
      expect(find.byType(DSFallbackView), findsNothing);
    });

    testWidgets('renders withDefaultFallback variant', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DSErrorBoundary.withDefaultFallback(child: Text('OK')),
          ),
        ),
      );

      expect(find.text('OK'), findsOneWidget);
      expect(find.byType(DSErrorBoundary), findsOneWidget);
    });

    // Path-to-100: real catch / retry / restore / nested / custom-fallback proofs.
    // These must fail if DSErrorBoundary install/capture/retry/dispose is broken.

    testWidgets('child that throws in build shows fallback UI', (tester) async {
      final previous = FlutterError.onError;
      addTearDown(() {
        FlutterError.onError = previous;
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DSErrorBoundary(child: _ThrowingChild(shouldThrow: true)),
          ),
        ),
      );

      // Framework reports the exception; take it so the test harness is clean.
      final thrown = tester.takeException();
      expect(thrown, isNotNull);

      // Post-frame capture → fallback.
      await tester.pump();
      await tester.pump();

      expect(find.byType(DSFallbackView), findsOneWidget);
      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.byIcon(DSIcons.error), findsOneWidget);
    });

    testWidgets('custom fallbackBuilder runs when child throws', (
      tester,
    ) async {
      final previous = FlutterError.onError;
      addTearDown(() {
        FlutterError.onError = previous;
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DSErrorBoundary(
              fallbackBuilder: (context, error, stackTrace) {
                return Text('Custom fallback: $error');
              },
              child: const _ThrowingChild(shouldThrow: true),
            ),
          ),
        ),
      );

      tester.takeException();
      await tester.pump();
      await tester.pump();

      expect(find.textContaining('Custom fallback:'), findsOneWidget);
      expect(find.byType(DSFallbackView), findsNothing);
    });

    testWidgets('retry clears error and rebuilds healthy child', (
      tester,
    ) async {
      final previous = FlutterError.onError;
      addTearDown(() {
        FlutterError.onError = previous;
      });

      // Static flag read on each build — flip before retry so the rebuild is healthy.
      _ThrowingChild.nextShouldThrow = true;
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DSErrorBoundary(
              child: _ThrowingChild(healthyLabel: 'Recovered child'),
            ),
          ),
        ),
      );

      tester.takeException();
      await tester.pump();
      await tester.pump();
      expect(find.byType(DSFallbackView), findsOneWidget);

      _ThrowingChild.nextShouldThrow = false;
      await tester.tap(find.text('Retry'));
      await tester.pump();
      await tester.pump();

      expect(find.text('Recovered child'), findsOneWidget);
      expect(find.byType(DSFallbackView), findsNothing);
    });

    testWidgets('dispose restores previous FlutterError.onError', (
      tester,
    ) async {
      void sentinel(FlutterErrorDetails details) {}
      FlutterError.onError = sentinel;
      addTearDown(() {
        FlutterError.onError = FlutterError.presentError;
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: DSErrorBoundary(child: Text('Healthy child'))),
        ),
      );
      expect(FlutterError.onError, isNot(equals(sentinel)));

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();

      expect(FlutterError.onError, same(sentinel));
    });

    testWidgets('nested boundary dispose restores outer then root', (
      tester,
    ) async {
      void rootHandler(FlutterErrorDetails details) {}
      FlutterError.onError = rootHandler;
      addTearDown(() {
        FlutterError.onError = FlutterError.presentError;
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DSErrorBoundary(
              child: DSErrorBoundary(child: Text('Nested healthy')),
            ),
          ),
        ),
      );
      expect(find.text('Nested healthy'), findsOneWidget);

      // Drop both boundaries.
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();

      expect(FlutterError.onError, same(rootHandler));
    });

    testWidgets('innermost nested boundary captures throw', (tester) async {
      final previous = FlutterError.onError;
      addTearDown(() {
        FlutterError.onError = previous;
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DSErrorBoundary(
              child: Column(
                children: [
                  Text('Outer healthy'),
                  DSErrorBoundary(child: _ThrowingChild(shouldThrow: true)),
                ],
              ),
            ),
          ),
        ),
      );

      tester.takeException();
      await tester.pump();
      await tester.pump();

      // Outer still healthy; only the inner boundary shows fallback.
      expect(find.text('Outer healthy'), findsOneWidget);
      expect(find.byType(DSFallbackView), findsOneWidget);
      expect(find.byType(DSErrorBoundary), findsNWidgets(2));
    });
  });
}

/// Test child that optionally throws during build.
class _ThrowingChild extends StatelessWidget {
  /// When non-null, overrides [nextShouldThrow] for this instance.
  final bool? shouldThrow;
  final String healthyLabel;

  /// Shared flag so retry tests can flip behavior without rebuilding ancestors.
  static bool nextShouldThrow = false;

  const _ThrowingChild({this.shouldThrow, this.healthyLabel = 'Healthy child'});

  @override
  Widget build(BuildContext context) {
    final willThrow = shouldThrow ?? nextShouldThrow;
    if (willThrow) {
      throw StateError('forced boundary test error');
    }
    return Text(healthyLabel);
  }
}
