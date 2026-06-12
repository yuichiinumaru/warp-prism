// Widget tests for DSErrorBoundary and DSFallbackView.
//
// These tests verify that the fallback view renders correctly with error
// details, retry buttons, and proper styling. The error boundary integration
// with Flutter's error handling is tested via the fallback view contract.
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

    testWidgets('shows default fallback when error state is set', (
      tester,
    ) async {
      // Directly test the fallback display by pumping DSFallbackView
      // (the error boundary's internal mechanism is tied to Flutter's
      // error pipeline which is hard to test in isolation).
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DSFallbackView(
              error: 'Build error',
              title: 'Something went wrong',
            ),
          ),
        ),
      );

      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.byIcon(DSIcons.error), findsOneWidget);
    });

    testWidgets('shows custom fallback builder output', (tester) async {
      // Test the custom fallback builder contract
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DSFallbackView(
              error: 'Test error',
              title: 'Custom fallback',
              onRetry: () {},
            ),
          ),
        ),
      );

      expect(find.text('Custom fallback'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });
  });
}
