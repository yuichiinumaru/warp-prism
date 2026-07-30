// State Surface Regression Test
// Task 1030 / Task 1309: Validates the shared DSStateSurface contract
//
// These tests verify that all seven DSStateType values (empty, loading,
// error, disabled, stale, degraded, excluded) are distinct, actionable,
// and well-structured. They test the widget contract without requiring a
// running app.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
// import 'package:warp_prism_ui/warp_prism_ui.dart'; // No public barrel, testing internal contract
import 'package:warp_prism_ui/src/molecules/molecules.dart';

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

void main() {
  group('DSStateSurface Contract', () {
    group('DSStateType enum', () {
      test('has exactly seven distinct states (3 data + 4 operational)', () {
        expect(DSStateType.values.length, equals(7));
      });

      test('defines empty, loading, and error', () {
        expect(DSStateType.values, contains(DSStateType.empty));
        expect(DSStateType.values, contains(DSStateType.loading));
        expect(DSStateType.values, contains(DSStateType.error));
      });

      test('defines disabled, stale, degraded, and excluded', () {
        expect(DSStateType.values, contains(DSStateType.disabled));
        expect(DSStateType.values, contains(DSStateType.stale));
        expect(DSStateType.values, contains(DSStateType.degraded));
        expect(DSStateType.values, contains(DSStateType.excluded));
      });
    });

    group('empty state constructor', () {
      test('creates with required title', () {
        const surface = DSStateSurface.empty(title: 'No tasks');
        expect(surface.stateType, equals(DSStateType.empty));
        expect(surface.title, equals('No tasks'));
      });

      test('accepts optional subtitle', () {
        const surface = DSStateSurface.empty(
          title: 'No tasks',
          subtitle: 'Tasks will appear here',
        );
        expect(surface.subtitle, equals('Tasks will appear here'));
      });

      test('accepts optional action callback', () {
        void onCreate() {}
        final surface = DSStateSurface.empty(
          title: 'No tasks',
          actionLabel: 'Create task',
          onAction: onCreate,
        );
        expect(surface.actionLabel, equals('Create task'));
        expect(surface.onAction, isNotNull);
      });

      test('accepts compact flag', () {
        const surface = DSStateSurface.empty(title: 'No tasks', compact: true);
        expect(surface.compact, isTrue);
      });
    });

    group('loading state constructor', () {
      test('creates with default title when none provided', () {
        const surface = DSStateSurface.loading();
        expect(surface.stateType, equals(DSStateType.loading));
        expect(surface.title, equals('Loading...'));
      });

      test('accepts custom title', () {
        const surface = DSStateSurface.loading(title: 'Parsing workspace...');
        expect(surface.title, equals('Parsing workspace...'));
      });
    });

    group('error state constructor', () {
      test('creates with required title', () {
        const surface = DSStateSurface.error(title: 'Failed to load');
        expect(surface.stateType, equals(DSStateType.error));
        expect(surface.title, equals('Failed to load'));
      });

      test('defaults action label to Retry', () {
        const surface = DSStateSurface.error(title: 'Failed to load');
        expect(surface.actionLabel, equals('Retry'));
      });

      test('accepts custom action label', () {
        const surface = DSStateSurface.error(
          title: 'Parse error',
          actionLabel: 'View log',
        );
        expect(surface.actionLabel, equals('View log'));
      });
    });

    group('state semantics are distinct', () {
      test('empty, loading, and error have different state types', () {
        const emptySurface = DSStateSurface.empty(title: 'Empty');
        const loadingSurface = DSStateSurface.loading();
        const errorSurface = DSStateSurface.error(title: 'Error');

        expect(emptySurface.stateType, isNot(equals(loadingSurface.stateType)));
        expect(loadingSurface.stateType, isNot(equals(errorSurface.stateType)));
        expect(emptySurface.stateType, isNot(equals(errorSurface.stateType)));
      });

      test(
        'operational states are distinct from data states and each other',
        () {
          final types = {
            DSStateType.empty,
            DSStateType.loading,
            DSStateType.error,
            DSStateType.disabled,
            DSStateType.stale,
            DSStateType.degraded,
            DSStateType.excluded,
          };
          expect(types.length, equals(7));
        },
      );
    });

    group('semantic labels match expanded vocabulary', () {
      // Labels merge with child title text in the semantics tree, so assert
      // with contains rather than exact bySemanticsLabel match.
      const expectedLabels = <DSStateType, String>{
        DSStateType.empty: 'Empty: no data available',
        DSStateType.loading: 'Loading: fetching data',
        DSStateType.error: 'Error: operation failed',
        DSStateType.disabled: 'Disabled: intentionally off',
        DSStateType.stale: 'Stale: needs refresh',
        DSStateType.degraded: 'Degraded: reduced quality',
        DSStateType.excluded: 'Excluded: outside scope',
      };

      for (final entry in expectedLabels.entries) {
        testWidgets('${entry.key.name} exposes "${entry.value}"', (
          tester,
        ) async {
          final handle = tester.ensureSemantics();
          await tester.pumpWidget(
            wrapInApp(
              DSStateSurface(stateType: entry.key, title: entry.key.name),
            ),
          );

          final semantics = tester.getSemantics(find.byType(DSStateSurface));
          expect(
            semantics.label,
            contains(entry.value),
            reason: '${entry.key.name} must expose vocabulary semantic label',
          );
          handle.dispose();
        });
      }
    });

    group('widget rendering', () {
      testWidgets('empty state renders title text', (tester) async {
        await tester.pumpWidget(
          wrapInApp(const DSStateSurface.empty(title: 'No assets found')),
        );

        expect(find.text('No assets found'), findsOneWidget);
      });

      testWidgets('empty state renders subtitle when provided', (tester) async {
        await tester.pumpWidget(
          wrapInApp(
            const DSStateSurface.empty(
              title: 'No assets found',
              subtitle: 'Load a workspace to see assets',
            ),
          ),
        );

        expect(find.text('No assets found'), findsOneWidget);
        expect(find.text('Load a workspace to see assets'), findsOneWidget);
      });

      testWidgets('loading state renders title', (tester) async {
        await tester.pumpWidget(
          wrapInApp(
            const DSStateSurface.loading(title: 'Loading workspace...'),
          ),
        );

        expect(find.text('Loading workspace...'), findsOneWidget);
      });

      testWidgets('loading state shows progress indicator', (tester) async {
        await tester.pumpWidget(wrapInApp(const DSStateSurface.loading()));

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('error state renders title and subtitle', (tester) async {
        await tester.pumpWidget(
          wrapInApp(
            const DSStateSurface.error(
              title: 'Failed to parse',
              subtitle: 'The YAML file is malformed',
            ),
          ),
        );

        expect(find.text('Failed to parse'), findsOneWidget);
        expect(find.text('The YAML file is malformed'), findsOneWidget);
      });

      testWidgets('error state renders retry button when onAction provided', (
        tester,
      ) async {
        var retried = false;
        await tester.pumpWidget(
          wrapInApp(
            DSStateSurface.error(
              title: 'Failed',
              onAction: () => retried = true,
            ),
          ),
        );

        expect(find.text('Retry'), findsOneWidget);

        await tester.tap(find.text('Retry'));
        await tester.pump();
        expect(retried, isTrue);
      });

      testWidgets('action button is not rendered when onAction is null', (
        tester,
      ) async {
        await tester.pumpWidget(
          wrapInApp(
            const DSStateSurface.error(
              title: 'Failed',
              actionLabel: 'Retry',
              // no onAction provided
            ),
          ),
        );

        expect(find.text('Retry'), findsNothing);
      });

      testWidgets('compact mode renders without error', (tester) async {
        await tester.pumpWidget(
          wrapInApp(
            const DSStateSurface.empty(title: 'No tasks', compact: true),
          ),
        );

        expect(find.text('No tasks'), findsOneWidget);
      });

      // ── Operational state constructors ────────────────────────────────
      testWidgets('disabled state renders title and block icon', (
        tester,
      ) async {
        await tester.pumpWidget(
          wrapInApp(const DSStateSurface.disabled(title: 'Feature Disabled')),
        );
        expect(find.text('Feature Disabled'), findsOneWidget);
        expect(find.byIcon(Icons.block), findsOneWidget);
      });

      testWidgets('stale state renders title and update icon', (tester) async {
        await tester.pumpWidget(
          wrapInApp(const DSStateSurface.stale(title: 'Data Outdated')),
        );
        expect(find.text('Data Outdated'), findsOneWidget);
        expect(find.byIcon(Icons.update), findsOneWidget);
      });

      testWidgets('degraded state renders title and warning icon', (
        tester,
      ) async {
        await tester.pumpWidget(
          wrapInApp(const DSStateSurface.degraded(title: 'Partial Data')),
        );
        expect(find.text('Partial Data'), findsOneWidget);
        expect(find.byIcon(Icons.warning_amber), findsOneWidget);
      });

      testWidgets('excluded state renders title and remove icon', (
        tester,
      ) async {
        await tester.pumpWidget(
          wrapInApp(const DSStateSurface.excluded(title: 'Filtered Out')),
        );
        expect(find.text('Filtered Out'), findsOneWidget);
        expect(find.byIcon(Icons.remove_circle_outline), findsOneWidget);
      });

      testWidgets('all 7 constructors render distinct titles', (tester) async {
        final constructors = <String, DSStateType>{
          'Empty': DSStateType.empty,
          'Loading': DSStateType.loading,
          'Error': DSStateType.error,
          'Disabled': DSStateType.disabled,
          'Stale': DSStateType.stale,
          'Degraded': DSStateType.degraded,
          'Excluded': DSStateType.excluded,
        };

        for (final entry in constructors.entries) {
          await tester.pumpWidget(
            wrapInApp(DSStateSurface(stateType: entry.value, title: entry.key)),
          );
          expect(
            find.text(entry.key),
            findsOneWidget,
            reason: '${entry.key} constructor should render its title',
          );
        }
      });

      testWidgets('stale default action label is Refresh', (tester) async {
        var called = false;
        await tester.pumpWidget(
          wrapInApp(
            DSStateSurface.stale(title: 'Stale', onAction: () => called = true),
          ),
        );
        expect(find.text('Refresh'), findsOneWidget);
        await tester.tap(find.text('Refresh'));
        await tester.pump();
        expect(called, isTrue);
      });

      testWidgets('action button enforces >=48x48 touch target', (
        tester,
      ) async {
        await tester.pumpWidget(
          wrapInApp(DSStateSurface.error(title: 'Failed', onAction: () {})),
        );

        final button = find.byType(OutlinedButton);
        expect(button, findsOneWidget);
        final size = tester.getSize(button);
        expect(
          size.width,
          greaterThanOrEqualTo(48),
          reason: 'action button width must meet 48dp minimum',
        );
        expect(
          size.height,
          greaterThanOrEqualTo(48),
          reason: 'action button height must meet 48dp minimum',
        );
      });
    });
  });
}
