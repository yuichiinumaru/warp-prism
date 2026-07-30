/// Tests for ShellStateHandler — loading, empty, error, and deep-link fallback.
///
/// Covers:
/// - Loading state renders with progress indicator and message
/// - Empty state renders with contextual surface name
/// - Error state renders with retry affordance
/// - Unresolved asset fallback renders asset ID and navigation buttons
/// - Narrow-layout inspector fallback renders correctly
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_observatory/features/shell/shell_state_handler.dart';

void main() {
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

  // ===========================================================================
  // Loading state
  // ===========================================================================
  group('ShellStateHandler - Loading', () {
    testWidgets('renders loading indicator with default message', (
      tester,
    ) async {
      await tester.pumpWidget(wrapInApp(ShellStateHandler.buildLoading()));

      expect(find.text('Loading workspace...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders loading indicator with custom message', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrapInApp(
          ShellStateHandler.buildLoading(
            title: 'Parsing markdown...',
            subtitle: 'This may take a moment',
          ),
        ),
      );

      expect(find.text('Parsing markdown...'), findsOneWidget);
      expect(find.text('This may take a moment'), findsOneWidget);
    });

    testWidgets('compact loading renders without subtitle', (tester) async {
      await tester.pumpWidget(
        wrapInApp(ShellStateHandler.buildLoadingCompact(title: 'Loading...')),
      );

      expect(find.text('Loading...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  // ===========================================================================
  // Empty state
  // ===========================================================================
  group('ShellStateHandler - Empty', () {
    testWidgets('renders empty state with surface name', (tester) async {
      await tester.pumpWidget(
        wrapInApp(ShellStateHandler.buildEmpty(surfaceName: 'Overview')),
      );

      expect(find.text('No Overview data'), findsOneWidget);
      expect(
        find.text(
          'The workspace is loaded but contains no assets to display here.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('renders empty state with custom subtitle', (tester) async {
      await tester.pumpWidget(
        wrapInApp(
          ShellStateHandler.buildEmpty(
            surfaceName: 'Agent Catalog',
            subtitle: 'No agents were found in the workspace.',
          ),
        ),
      );

      expect(find.text('No Agent Catalog data'), findsOneWidget);
      expect(
        find.text('No agents were found in the workspace.'),
        findsOneWidget,
      );
    });

    testWidgets('renders empty state with action button when callback given', (
      tester,
    ) async {
      var tapped = false;
      await tester.pumpWidget(
        wrapInApp(
          ShellStateHandler.buildEmpty(
            surfaceName: 'Skills',
            actionLabel: 'Load workspace',
            onAction: () => tapped = true,
          ),
        ),
      );

      expect(find.text('Load workspace'), findsOneWidget);
      await tester.tap(find.text('Load workspace'));
      await tester.pump();
      expect(tapped, isTrue);
    });
  });

  // ===========================================================================
  // Error state
  // ===========================================================================
  group('ShellStateHandler - Error', () {
    testWidgets('renders error state with message', (tester) async {
      await tester.pumpWidget(
        wrapInApp(
          ShellStateHandler.buildError(
            title: 'Failed to load workspace',
            errorMessage: 'Permission denied: /workspace',
          ),
        ),
      );

      expect(find.text('Failed to load workspace'), findsOneWidget);
      expect(find.text('Permission denied: /workspace'), findsOneWidget);
    });

    testWidgets('renders retry button when onRetry provided', (tester) async {
      var retried = false;
      await tester.pumpWidget(
        wrapInApp(
          ShellStateHandler.buildError(
            title: 'Load failed',
            onRetry: () => retried = true,
          ),
        ),
      );

      expect(find.text('Retry'), findsOneWidget);
      await tester.tap(find.text('Retry'));
      await tester.pump();
      expect(retried, isTrue);
    });

    testWidgets('hides retry button when onRetry is null', (tester) async {
      await tester.pumpWidget(
        wrapInApp(ShellStateHandler.buildError(title: 'Load failed')),
      );

      expect(find.text('Retry'), findsNothing);
    });
  });

  // ===========================================================================
  // Unresolved asset fallback (deep-link)
  // ===========================================================================
  group('ShellStateHandler - Unresolved Asset', () {
    testWidgets('renders asset ID and explanation', (tester) async {
      await tester.pumpWidget(
        wrapInApp(
          ShellStateHandler.buildUnresolvedAssetFallback(
            assetId: 'agent:nonexistent',
          ),
        ),
      );

      expect(find.text('Asset not found'), findsOneWidget);
      expect(find.text('agent:nonexistent'), findsOneWidget);
      expect(find.text('Could not resolve asset:'), findsOneWidget);
    });

    testWidgets('renders navigation button when callback provided', (
      tester,
    ) async {
      var navigated = false;
      await tester.pumpWidget(
        wrapInApp(
          ShellStateHandler.buildUnresolvedAssetFallback(
            assetId: 'skill:missing',
            onNavigateHome: () => navigated = true,
          ),
        ),
      );

      expect(find.text('Go to Overview'), findsOneWidget);
      await tester.tap(find.text('Go to Overview'));
      await tester.pump();
      expect(navigated, isTrue);
    });

    testWidgets('renders retry button when callback provided', (tester) async {
      var retried = false;
      await tester.pumpWidget(
        wrapInApp(
          ShellStateHandler.buildUnresolvedAssetFallback(
            assetId: 'workflow:broken',
            onRetry: () => retried = true,
          ),
        ),
      );

      expect(find.text('Retry'), findsOneWidget);
      await tester.tap(find.text('Retry'));
      await tester.pump();
      expect(retried, isTrue);
    });

    testWidgets('renders both retry and navigate when both provided', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrapInApp(
          ShellStateHandler.buildUnresolvedAssetFallback(
            assetId: 'task:0999',
            onRetry: () {},
            onNavigateHome: () {},
          ),
        ),
      );

      expect(find.text('Retry'), findsOneWidget);
      expect(find.text('Go to Overview'), findsOneWidget);
    });

    testWidgets('renders with empty asset ID', (tester) async {
      await tester.pumpWidget(
        wrapInApp(ShellStateHandler.buildUnresolvedAssetFallback(assetId: '')),
      );

      // Empty asset ID should still show the fallback
      expect(find.text('Asset not found'), findsOneWidget);
    });
  });

  // ===========================================================================
  // Narrow-layout inspector fallback
  // ===========================================================================
  group('ShellStateHandler - Narrow Layout', () {
    testWidgets('renders narrow layout message', (tester) async {
      await tester.pumpWidget(
        wrapInApp(ShellStateHandler.buildNarrowLayoutInspectorFallback()),
      );

      expect(find.text('Detail panel unavailable'), findsOneWidget);
    });
  });
}
