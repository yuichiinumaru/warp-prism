// State Surface Regression Test
// Task 1030: Validates the shared DSStateSurface contract
//
// These tests verify that the three fundamental states (empty, loading, error)
// are distinct, actionable, and well-structured. They test the widget contract
// without requiring a running app.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

void main() {
  group('DSStateSurface Contract', () {
    group('DSStateType enum', () {
      test('has exactly three distinct states', () {
        expect(DSStateType.values.length, equals(3));
      });

      test('defines empty, loading, and error', () {
        expect(DSStateType.values, contains(DSStateType.empty));
        expect(DSStateType.values, contains(DSStateType.loading));
        expect(DSStateType.values, contains(DSStateType.error));
      });
    });

    group('empty state constructor', () {
      test('creates with required title', () {
        const surface = DSStateSurface.empty(
          title: 'No tasks',
        );
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
        const surface = DSStateSurface.empty(
          title: 'No tasks',
          compact: true,
        );
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
        const surface = DSStateSurface.loading(
          title: 'Parsing workspace...',
        );
        expect(surface.title, equals('Parsing workspace...'));
      });
    });

    group('error state constructor', () {
      test('creates with required title', () {
        const surface = DSStateSurface.error(
          title: 'Failed to load',
        );
        expect(surface.stateType, equals(DSStateType.error));
        expect(surface.title, equals('Failed to load'));
      });

      test('defaults action label to Retry', () {
        const surface = DSStateSurface.error(
          title: 'Failed to load',
        );
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
    });

    group('widget rendering', () {
      testWidgets('empty state renders title text', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: DSStateSurface.empty(
                title: 'No assets found',
              ),
            ),
          ),
        );

        expect(find.text('No assets found'), findsOneWidget);
      });

      testWidgets('empty state renders subtitle when provided', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: DSStateSurface.empty(
                title: 'No assets found',
                subtitle: 'Load a workspace to see assets',
              ),
            ),
          ),
        );

        expect(find.text('No assets found'), findsOneWidget);
        expect(find.text('Load a workspace to see assets'), findsOneWidget);
      });

      testWidgets('loading state renders title', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: DSStateSurface.loading(
                title: 'Loading workspace...',
              ),
            ),
          ),
        );

        expect(find.text('Loading workspace...'), findsOneWidget);
      });

      testWidgets('loading state shows progress indicator', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: DSStateSurface.loading(),
            ),
          ),
        );

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('error state renders title and subtitle', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: DSStateSurface.error(
                title: 'Failed to parse',
                subtitle: 'The YAML file is malformed',
              ),
            ),
          ),
        );

        expect(find.text('Failed to parse'), findsOneWidget);
        expect(find.text('The YAML file is malformed'), findsOneWidget);
      });

      testWidgets('error state renders retry button when onAction provided',
          (tester) async {
        var retried = false;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DSStateSurface.error(
                title: 'Failed',
                onAction: () => retried = true,
              ),
            ),
          ),
        );

        expect(find.text('Retry'), findsOneWidget);

        await tester.tap(find.text('Retry'));
        expect(retried, isTrue);
      });

      testWidgets('action button is not rendered when onAction is null',
          (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: DSStateSurface.error(
                title: 'Failed',
                actionLabel: 'Retry',
                // no onAction provided
              ),
            ),
          ),
        );

        expect(find.text('Retry'), findsNothing);
      });

      testWidgets('compact mode renders without error', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: DSStateSurface.empty(
                title: 'No tasks',
                compact: true,
              ),
            ),
          ),
        );

        expect(find.text('No tasks'), findsOneWidget);
      });
    });
  });
}
