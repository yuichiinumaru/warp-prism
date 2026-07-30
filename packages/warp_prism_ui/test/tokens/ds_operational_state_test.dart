// Operational State Vocabulary Tests
// Task 1118: Validates the DSOperationalState enum, its extensions,
// DSStatusDot.operational(), DSBadge.operational(), and backward compatibility
// with the existing DSStateType.
//
// Run: flutter test test/tokens/ds_operational_state_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_ui/src/tokens/tokens.dart';
import 'package:warp_prism_ui/src/atoms/ds_status_dot.dart';
import 'package:warp_prism_ui/src/atoms/ds_badge.dart';
import 'package:warp_prism_ui/src/molecules/ds_state_surface.dart';

void main() {
  // ===========================================================================
  // DSOperationalState enum contract
  // ===========================================================================
  group('DSOperationalState enum', () {
    test('has exactly 15 states', () {
      expect(DSOperationalState.values.length, equals(15));
    });

    test('defines all lifecycle states', () {
      expect(DSOperationalState.values, contains(DSOperationalState.pending));
      expect(DSOperationalState.values, contains(DSOperationalState.running));
      expect(DSOperationalState.values, contains(DSOperationalState.approved));
      expect(DSOperationalState.values, contains(DSOperationalState.rejected));
      expect(DSOperationalState.values, contains(DSOperationalState.promoted));
      expect(DSOperationalState.values, contains(DSOperationalState.archived));
    });

    test('defines all health states', () {
      expect(DSOperationalState.values, contains(DSOperationalState.healthy));
      expect(DSOperationalState.values, contains(DSOperationalState.degraded));
      expect(DSOperationalState.values, contains(DSOperationalState.error));
      expect(DSOperationalState.values, contains(DSOperationalState.disabled));
    });

    test('defines all verification states', () {
      expect(
        DSOperationalState.values,
        contains(DSOperationalState.unverified),
      );
      expect(DSOperationalState.values, contains(DSOperationalState.exposed));
      expect(DSOperationalState.values, contains(DSOperationalState.redacted));
    });

    test('defines all governance states', () {
      expect(DSOperationalState.values, contains(DSOperationalState.stale));
      expect(DSOperationalState.values, contains(DSOperationalState.excluded));
    });

    test('every state has a unique label', () {
      final labels = DSOperationalState.values.map((s) => s.label).toSet();
      expect(labels.length, equals(DSOperationalState.values.length));
    });

    test('every state has a non-null color', () {
      for (final state in DSOperationalState.values) {
        // Accessing color should not throw
        expect(state.color, isNotNull);
      }
    });

    test('every state has a non-null icon', () {
      for (final state in DSOperationalState.values) {
        expect(state.icon, isNotNull);
      }
    });

    test('every state has a non-empty semanticLabel', () {
      for (final state in DSOperationalState.values) {
        expect(state.semanticLabel, isNotEmpty);
        expect(state.semanticLabel, contains(':'));
      }
    });
  });

  // ===========================================================================
  // Color mapping — each state has exactly one canonical color
  // ===========================================================================
  group('DSOperationalState color mapping', () {
    test('pending uses textTertiary', () {
      expect(DSOperationalState.pending.color, equals(DSColors.textTertiary));
    });

    test('running uses accentGold', () {
      expect(DSOperationalState.running.color, equals(DSColors.accentGold));
    });

    test('approved uses statusSuccess', () {
      expect(DSOperationalState.approved.color, equals(DSColors.statusSuccess));
    });

    test('rejected uses statusError', () {
      expect(DSOperationalState.rejected.color, equals(DSColors.statusError));
    });

    test('promoted uses accentCyan', () {
      expect(DSOperationalState.promoted.color, equals(DSColors.accentCyan));
    });

    test('archived uses textDisabled', () {
      expect(DSOperationalState.archived.color, equals(DSColors.textDisabled));
    });

    test('healthy uses statusSuccess', () {
      expect(DSOperationalState.healthy.color, equals(DSColors.statusSuccess));
    });

    test('degraded uses statusWarning', () {
      expect(DSOperationalState.degraded.color, equals(DSColors.statusWarning));
    });

    test('error uses statusError', () {
      expect(DSOperationalState.error.color, equals(DSColors.statusError));
    });

    test('disabled uses textDisabled', () {
      expect(DSOperationalState.disabled.color, equals(DSColors.textDisabled));
    });

    test('unverified uses textTertiary', () {
      expect(
        DSOperationalState.unverified.color,
        equals(DSColors.textTertiary),
      );
    });

    test('exposed uses statusError', () {
      expect(DSOperationalState.exposed.color, equals(DSColors.statusError));
    });

    test('redacted uses accentViolet', () {
      expect(DSOperationalState.redacted.color, equals(DSColors.accentViolet));
    });

    test('stale uses statusWarning', () {
      expect(DSOperationalState.stale.color, equals(DSColors.statusWarning));
    });

    test('excluded uses textDisabled', () {
      expect(DSOperationalState.excluded.color, equals(DSColors.textDisabled));
    });
  });

  // ===========================================================================
  // Icon mapping — each state maps to a Material icon
  // ===========================================================================
  group('DSOperationalState icon mapping', () {
    test('pending uses schedule icon', () {
      expect(DSOperationalState.pending.icon, equals(Icons.schedule));
    });

    test('running uses trending_up icon', () {
      expect(DSOperationalState.running.icon, equals(Icons.trending_up));
    });

    test('approved uses check_circle_outline icon', () {
      expect(
        DSOperationalState.approved.icon,
        equals(Icons.check_circle_outline),
      );
    });

    test('rejected uses error_outline icon', () {
      expect(DSOperationalState.rejected.icon, equals(Icons.error_outline));
    });

    test('promoted uses verified_outlined icon', () {
      expect(DSOperationalState.promoted.icon, equals(Icons.verified_outlined));
    });

    test('archived uses inventory_2_outlined icon', () {
      expect(
        DSOperationalState.archived.icon,
        equals(Icons.inventory_2_outlined),
      );
    });

    test('healthy uses check_circle_outline icon', () {
      expect(
        DSOperationalState.healthy.icon,
        equals(Icons.check_circle_outline),
      );
    });

    test('degraded uses warning_amber_outlined icon', () {
      expect(
        DSOperationalState.degraded.icon,
        equals(Icons.warning_amber_outlined),
      );
    });

    test('disabled uses block icon', () {
      expect(DSOperationalState.disabled.icon, equals(Icons.block));
    });

    test('unverified uses schedule icon', () {
      expect(DSOperationalState.unverified.icon, equals(Icons.schedule));
    });

    test('exposed uses warning_amber_outlined icon', () {
      expect(
        DSOperationalState.exposed.icon,
        equals(Icons.warning_amber_outlined),
      );
    });

    test('redacted uses home_outlined icon', () {
      expect(DSOperationalState.redacted.icon, equals(Icons.home_outlined));
    });

    test('stale uses warning_amber_outlined icon', () {
      expect(
        DSOperationalState.stale.icon,
        equals(Icons.warning_amber_outlined),
      );
    });

    test('excluded uses block icon', () {
      expect(DSOperationalState.excluded.icon, equals(Icons.block));
    });
  });

  // ===========================================================================
  // Behavioral contracts
  // ===========================================================================
  group('DSOperationalState behavioral contracts', () {
    test('terminal states are archived and excluded', () {
      expect(DSOperationalState.archived.isTerminal, isTrue);
      expect(DSOperationalState.excluded.isTerminal, isTrue);
    });

    test('non-terminal states are not terminal', () {
      final nonTerminal = DSOperationalState.values.where(
        (s) =>
            s != DSOperationalState.archived &&
            s != DSOperationalState.excluded,
      );
      for (final state in nonTerminal) {
        expect(
          state.isTerminal,
          isFalse,
          reason: '${state.label} should not be terminal',
        );
      }
    });

    test('terminal states do not allow actions', () {
      expect(DSOperationalState.archived.allowsActions, isFalse);
      expect(DSOperationalState.excluded.allowsActions, isFalse);
    });

    test('healthy does not allow actions (no action needed)', () {
      expect(DSOperationalState.healthy.allowsActions, isFalse);
    });

    test('warning states show warning indicator', () {
      final warningStates = [
        DSOperationalState.rejected,
        DSOperationalState.degraded,
        DSOperationalState.error,
        DSOperationalState.exposed,
        DSOperationalState.stale,
      ];
      for (final state in warningStates) {
        expect(
          state.showsWarning,
          isTrue,
          reason: '${state.label} should show warning',
        );
      }
    });

    test('non-warning states do not show warning', () {
      final nonWarning = DSOperationalState.values.where(
        (s) => ![
          DSOperationalState.rejected,
          DSOperationalState.degraded,
          DSOperationalState.error,
          DSOperationalState.exposed,
          DSOperationalState.stale,
        ].contains(s),
      );
      for (final state in nonWarning) {
        expect(
          state.showsWarning,
          isFalse,
          reason: '${state.label} should not show warning',
        );
      }
    });

    test('severity classifications are correct', () {
      expect(
        DSOperationalState.pending.severity,
        equals(DSOperationalSeverity.info),
      );
      expect(
        DSOperationalState.running.severity,
        equals(DSOperationalSeverity.info),
      );
      expect(
        DSOperationalState.approved.severity,
        equals(DSOperationalSeverity.success),
      );
      expect(
        DSOperationalState.rejected.severity,
        equals(DSOperationalSeverity.error),
      );
      expect(
        DSOperationalState.promoted.severity,
        equals(DSOperationalSeverity.success),
      );
      expect(
        DSOperationalState.archived.severity,
        equals(DSOperationalSeverity.info),
      );
      expect(
        DSOperationalState.healthy.severity,
        equals(DSOperationalSeverity.success),
      );
      expect(
        DSOperationalState.degraded.severity,
        equals(DSOperationalSeverity.warning),
      );
      expect(
        DSOperationalState.error.severity,
        equals(DSOperationalSeverity.error),
      );
      expect(
        DSOperationalState.disabled.severity,
        equals(DSOperationalSeverity.info),
      );
      expect(
        DSOperationalState.unverified.severity,
        equals(DSOperationalSeverity.info),
      );
      expect(
        DSOperationalState.exposed.severity,
        equals(DSOperationalSeverity.error),
      );
      expect(
        DSOperationalState.redacted.severity,
        equals(DSOperationalSeverity.warning),
      );
      expect(
        DSOperationalState.stale.severity,
        equals(DSOperationalSeverity.warning),
      );
      expect(
        DSOperationalState.excluded.severity,
        equals(DSOperationalSeverity.info),
      );
    });
  });

  // ===========================================================================
  // Category classification
  // ===========================================================================
  group('DSOperationalState category', () {
    test('lifecycle states are categorized correctly', () {
      for (final state in [
        DSOperationalState.pending,
        DSOperationalState.running,
        DSOperationalState.approved,
        DSOperationalState.rejected,
        DSOperationalState.promoted,
        DSOperationalState.archived,
      ]) {
        expect(
          state.category,
          equals(DSOperationalCategory.lifecycle),
          reason: '${state.label} should be lifecycle',
        );
      }
    });

    test('health states are categorized correctly', () {
      for (final state in [
        DSOperationalState.healthy,
        DSOperationalState.degraded,
        DSOperationalState.error,
        DSOperationalState.disabled,
      ]) {
        expect(
          state.category,
          equals(DSOperationalCategory.health),
          reason: '${state.label} should be health',
        );
      }
    });

    test('verification states are categorized correctly', () {
      for (final state in [
        DSOperationalState.unverified,
        DSOperationalState.exposed,
        DSOperationalState.redacted,
      ]) {
        expect(
          state.category,
          equals(DSOperationalCategory.verification),
          reason: '${state.label} should be verification',
        );
      }
    });

    test('governance states are categorized correctly', () {
      for (final state in [
        DSOperationalState.stale,
        DSOperationalState.excluded,
      ]) {
        expect(
          state.category,
          equals(DSOperationalCategory.governance),
          reason: '${state.label} should be governance',
        );
      }
    });
  });

  // ===========================================================================
  // DSStatusDot.operational() factory
  // ===========================================================================
  group('DSStatusDot.operational', () {
    testWidgets('renders for each operational state', (tester) async {
      for (final state in DSOperationalState.values) {
        await tester.pumpWidget(
          MaterialApp(home: Scaffold(body: DSStatusDot.operational(state))),
        );
        expect(find.byType(DSStatusDot), findsOneWidget);
      }
    });

    testWidgets('uses state color', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DSStatusDot.operational(DSOperationalState.healthy),
          ),
        ),
      );
      final dot = tester.widget<DSStatusDot>(find.byType(DSStatusDot));
      expect(dot.color, equals(DSColors.statusSuccess));
    });

    testWidgets('uses state semanticLabel for tooltip', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DSStatusDot.operational(DSOperationalState.running),
          ),
        ),
      );
      expect(find.byType(Tooltip), findsOneWidget);
      final tooltip = tester.widget<Tooltip>(find.byType(Tooltip));
      expect(tooltip.message, equals(DSOperationalState.running.semanticLabel));
    });

    testWidgets('accepts custom tooltip', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DSStatusDot.operational(
              DSOperationalState.healthy,
              tooltip: 'Custom',
            ),
          ),
        ),
      );
      final tooltip = tester.widget<Tooltip>(find.byType(Tooltip));
      expect(tooltip.message, equals('Custom'));
    });

    testWidgets('running state defaults to animated', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DSStatusDot.operational(DSOperationalState.running),
          ),
        ),
      );
      final dot = tester.widget<DSStatusDot>(find.byType(DSStatusDot));
      expect(dot.animated, isTrue);
    });

    testWidgets('non-running states default to not animated', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DSStatusDot.operational(DSOperationalState.healthy),
          ),
        ),
      );
      final dot = tester.widget<DSStatusDot>(find.byType(DSStatusDot));
      expect(dot.animated, isFalse);
    });
  });

  // ===========================================================================
  // DSBadge.operational() factory
  // ===========================================================================
  group('DSBadge.operational', () {
    testWidgets('renders for each operational state', (tester) async {
      for (final state in DSOperationalState.values) {
        await tester.pumpWidget(
          MaterialApp(home: Scaffold(body: DSBadge.operational(state))),
        );
        expect(find.byType(DSBadge), findsOneWidget);
      }
    });

    testWidgets('displays state label by default', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DSBadge.operational(DSOperationalState.pending)),
        ),
      );
      expect(find.text('Pending'), findsOneWidget);
    });

    testWidgets('accepts custom label', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DSBadge.operational(
              DSOperationalState.healthy,
              label: 'All Clear',
            ),
          ),
        ),
      );
      expect(find.text('All Clear'), findsOneWidget);
    });

    testWidgets('displays count when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DSBadge.operational(DSOperationalState.error, count: 5),
          ),
        ),
      );
      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('exposes semantic label', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DSBadge.operational(DSOperationalState.running)),
        ),
      );

      final Semantics badgeSemantics = tester.widget(
        find
            .descendant(
              of: find.byType(DSBadge),
              matching: find.byType(Semantics),
            )
            .first,
      );

      expect(
        badgeSemantics.properties.label,
        equals(DSOperationalState.running.semanticLabel),
      );
    });

    testWidgets('exposes count in semantic label', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DSBadge.operational(DSOperationalState.error, count: 5),
          ),
        ),
      );

      final Semantics badgeSemantics = tester.widget(
        find
            .descendant(
              of: find.byType(DSBadge),
              matching: find.byType(Semantics),
            )
            .first,
      );

      expect(
        badgeSemantics.properties.label,
        equals('${DSOperationalState.error.semanticLabel}, count 5'),
      );
    });

    testWidgets('uses state color', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DSBadge.operational(DSOperationalState.promoted),
          ),
        ),
      );
      final badge = tester.widget<DSBadge>(find.byType(DSBadge));
      expect(badge.color, equals(DSColors.accentCyan));
    });
  });

  // ===========================================================================
  // Backward compatibility — DSStateType is unchanged
  // ===========================================================================
  group('DSStateType backward compatibility', () {
    test('DSStateType still defines empty, loading, and error', () {
      expect(DSStateType.values, contains(DSStateType.empty));
      expect(DSStateType.values, contains(DSStateType.loading));
      expect(DSStateType.values, contains(DSStateType.error));
    });

    test('DSStateType has at least 3 states', () {
      // DSStateType may have been expanded by other tasks (disabled, stale,
      // degraded, excluded). The original 3 must still exist.
      expect(DSStateType.values.length, greaterThanOrEqualTo(3));
    });

    testWidgets('DSStateSurface.empty still works', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DSStateSurface.empty(
              title: 'No tasks',
              subtitle: 'Tasks will appear here',
            ),
          ),
        ),
      );
      expect(find.text('No tasks'), findsOneWidget);
      expect(find.text('Tasks will appear here'), findsOneWidget);
    });

    testWidgets('DSStateSurface.loading still works', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: DSStateSurface.loading(title: 'Loading...')),
        ),
      );
      expect(find.text('Loading...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('DSStateSurface.error still works', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DSStateSurface.error(title: 'Failed', onAction: () {}),
          ),
        ),
      );
      expect(find.text('Failed'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });
  });

  // ===========================================================================
  // DSColors operational state semantic aliases
  // ===========================================================================
  group('DSColors operational state aliases', () {
    test('statusPending equals textTertiary', () {
      expect(DSColors.statusPending, equals(DSColors.textTertiary));
    });

    test('statusRunning equals accentGold', () {
      expect(DSColors.statusRunning, equals(DSColors.accentGold));
    });

    test('statusApproved equals statusSuccess', () {
      expect(DSColors.statusApproved, equals(DSColors.statusSuccess));
    });

    test('statusRejected equals statusError', () {
      expect(DSColors.statusRejected, equals(DSColors.statusError));
    });

    test('statusPromoted equals accentCyan', () {
      expect(DSColors.statusPromoted, equals(DSColors.accentCyan));
    });

    test('statusArchived equals textDisabled', () {
      expect(DSColors.statusArchived, equals(DSColors.textDisabled));
    });

    test('statusHealthy equals statusSuccess', () {
      expect(DSColors.statusHealthy, equals(DSColors.statusSuccess));
    });

    test('statusDegraded equals statusWarning', () {
      expect(DSColors.statusDegraded, equals(DSColors.statusWarning));
    });

    test('statusOpError equals statusError', () {
      expect(DSColors.statusOpError, equals(DSColors.statusError));
    });

    test('statusDisabled equals textDisabled', () {
      expect(DSColors.statusDisabled, equals(DSColors.textDisabled));
    });

    test('statusUnverified equals textTertiary', () {
      expect(DSColors.statusUnverified, equals(DSColors.textTertiary));
    });

    test('statusExposed equals statusError', () {
      expect(DSColors.statusExposed, equals(DSColors.statusError));
    });

    test('statusRedacted equals accentViolet', () {
      expect(DSColors.statusRedacted, equals(DSColors.accentViolet));
    });

    test('statusStale equals statusWarning', () {
      expect(DSColors.statusStale, equals(DSColors.statusWarning));
    });

    test('statusExcluded equals textDisabled', () {
      expect(DSColors.statusExcluded, equals(DSColors.textDisabled));
    });
  });

  // ===========================================================================
  // Existing DSStatusDot constructors still work
  // ===========================================================================
  group('DSStatusDot backward compatibility', () {
    testWidgets('existing named constructors render', (tester) async {
      for (final ctor in [
        () => const DSStatusDot.success(),
        () => const DSStatusDot.warning(),
        () => const DSStatusDot.error(),
        () => const DSStatusDot.info(),
        () => const DSStatusDot.neutral(),
      ]) {
        await tester.pumpWidget(MaterialApp(home: ctor()));
        expect(find.byType(DSStatusDot), findsOneWidget);
      }
    });
  });

  // ===========================================================================
  // Existing DSBadge constructors still work
  // ===========================================================================
  group('DSBadge backward compatibility', () {
    testWidgets('existing named constructors render', (tester) async {
      for (final ctor in [
        () => const DSBadge.success(label: 'ok'),
        () => const DSBadge.warning(label: 'warn'),
        () => const DSBadge.error(label: 'err'),
        () => const DSBadge.info(label: 'info'),
      ]) {
        await tester.pumpWidget(MaterialApp(home: ctor()));
        expect(find.byType(DSBadge), findsOneWidget);
      }
    });
  });
}
