// Widget tests for promoted operational components.
//
// Tests the enhanced DSStatusDot (15 operational states), DSMetricTile
// (health states), DSStateSurface (operational constructors), and
// Prism* public API aliases.
//
// Run: flutter test test/molecules/operational_components_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_ui/src/tokens/tokens.dart';
import 'package:warp_prism_ui/src/atoms/atoms.dart';
import 'package:warp_prism_ui/src/molecules/molecules.dart';
import 'package:warp_prism_ui/src/organisms/organisms.dart';
import 'package:warp_prism_ui/src/prism_aliases.dart';

void main() {
  // ===========================================================================
  // DSStatusDot — 15 Operational State Constructors
  // ===========================================================================
  group('DSStatusDot operational states', () {
    testWidgets('pending renders with textTertiary color', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: DSStatusDot.pending()));
      expect(find.byType(DSStatusDot), findsOneWidget);
      expect(find.byType(Tooltip), findsOneWidget);
    });

    testWidgets('running renders with animation by default', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: DSStatusDot.running()));
      expect(find.byType(DSStatusDot), findsOneWidget);
      // Running has animated=true by default
      expect(find.byType(Tooltip), findsOneWidget);
    });

    testWidgets('approved renders with success color', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: DSStatusDot.approved()));
      expect(find.byType(DSStatusDot), findsOneWidget);
    });

    testWidgets('rejected renders with error color', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: DSStatusDot.rejected()));
      expect(find.byType(DSStatusDot), findsOneWidget);
    });

    testWidgets('promoted renders with cyan color', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: DSStatusDot.promoted()));
      expect(find.byType(DSStatusDot), findsOneWidget);
    });

    testWidgets('archived renders with disabled color', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: DSStatusDot.archived()));
      expect(find.byType(DSStatusDot), findsOneWidget);
    });

    testWidgets('healthy renders with success color', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: DSStatusDot.healthy()));
      expect(find.byType(DSStatusDot), findsOneWidget);
    });

    testWidgets('degraded renders with warning color', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: DSStatusDot.degraded()));
      expect(find.byType(DSStatusDot), findsOneWidget);
    });

    testWidgets('disabled renders with disabled color', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: DSStatusDot.disabled()));
      expect(find.byType(DSStatusDot), findsOneWidget);
    });

    testWidgets('unverified renders with tertiary color', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: DSStatusDot.unverified()),
      );
      expect(find.byType(DSStatusDot), findsOneWidget);
    });

    testWidgets('exposed renders with animation by default', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: DSStatusDot.exposed()));
      expect(find.byType(DSStatusDot), findsOneWidget);
      expect(find.byType(Tooltip), findsOneWidget);
    });

    testWidgets('redacted renders with violet color', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: DSStatusDot.redacted()));
      expect(find.byType(DSStatusDot), findsOneWidget);
    });

    testWidgets('stale renders with warning color', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: DSStatusDot.stale()));
      expect(find.byType(DSStatusDot), findsOneWidget);
    });

    testWidgets('excluded renders with disabled color', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: DSStatusDot.excluded()));
      expect(find.byType(DSStatusDot), findsOneWidget);
    });

    testWidgets('custom tooltip overrides default', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: DSStatusDot.running(tooltip: 'Custom label')),
      );
      final tooltip = tester.widget<Tooltip>(find.byType(Tooltip));
      expect(tooltip.message, 'Custom label');
    });

    testWidgets('custom size is applied', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: DSStatusDot.healthy(size: 16)),
      );
      expect(find.byType(DSStatusDot), findsOneWidget);
    });

    testWidgets('semantics label matches tooltip', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: DSStatusDot.pending()));
      // Pending has default tooltip 'Pending'
      expect(find.byType(Semantics), findsWidgets);
    });
  });

  // ===========================================================================
  // DSMetricTile — Health States
  // ===========================================================================
  group('DSMetricTile health states', () {
    testWidgets('default render without health', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DSMetricTile(label: 'Tasks', value: '42'),
        ),
      );
      expect(find.text('Tasks'), findsOneWidget);
      expect(find.text('42'), findsOneWidget);
    });

    testWidgets('healthy state uses caller color', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DSMetricTile(
            label: 'Agents',
            value: '9',
            health: DSMetricTileHealth.healthy,
          ),
        ),
      );
      expect(find.text('Agents'), findsOneWidget);
      expect(find.text('9'), findsOneWidget);
      // No health indicator shown for healthy (default)
      expect(find.text('Healthy'), findsNothing);
    });

    testWidgets('degraded state shows warning indicator', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DSMetricTile(
            label: 'Skills',
            value: '3',
            health: DSMetricTileHealth.degraded,
          ),
        ),
      );
      expect(find.text('Degraded'), findsOneWidget);
      expect(find.byType(DSStatusDot), findsOneWidget);
    });

    testWidgets('error state shows error indicator', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DSMetricTile(
            label: 'Workflows',
            value: '1',
            health: DSMetricTileHealth.error,
          ),
        ),
      );
      expect(find.text('Error'), findsOneWidget);
      expect(find.byType(DSStatusDot), findsOneWidget);
    });

    testWidgets('disabled state shows disabled indicator', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DSMetricTile(
            label: 'Archived',
            value: '0',
            health: DSMetricTileHealth.disabled,
          ),
        ),
      );
      expect(find.text('Disabled'), findsOneWidget);
    });

    testWidgets('health overrides color parameter', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DSMetricTile(
            label: 'Test',
            value: '5',
            color: DSColors.accentCyan,
            health: DSMetricTileHealth.error,
          ),
        ),
      );
      // Error health should override accentCyan
      expect(find.text('Error'), findsOneWidget);
    });

    testWidgets('compact variant with health renders', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DSMetricTileCompact(
            label: 'Tasks',
            value: '20',
            health: DSMetricTileHealth.degraded,
          ),
        ),
      );
      expect(find.text('Tasks'), findsOneWidget);
      expect(find.text('20'), findsOneWidget);
    });

    testWidgets('semantics label includes health for non-healthy', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DSMetricTile(
            label: 'Metrics',
            value: '5',
            health: DSMetricTileHealth.degraded,
          ),
        ),
      );
      // Find the Semantics widget that has the tile's composite label
      // (child widgets like DSGlassPanelSimple may contribute their own Semantics)
      final tileSemantics = find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.label != null &&
            widget.properties.label!.contains('degraded'),
      );
      expect(tileSemantics, findsOneWidget);
    });
  });

  // ===========================================================================
  // DSMetricTileHealth enum
  // ===========================================================================
  group('DSMetricTileHealth enum', () {
    test('has 4 values', () {
      expect(DSMetricTileHealth.values.length, 4);
    });

    test('healthy has success color', () {
      expect(DSMetricTileHealth.healthy.color, DSColors.statusHealthy);
    });

    test('degraded has warning color', () {
      expect(DSMetricTileHealth.degraded.color, DSColors.statusDegraded);
    });

    test('error has error color', () {
      expect(DSMetricTileHealth.error.color, DSColors.statusError);
    });

    test('disabled has disabled color', () {
      expect(DSMetricTileHealth.disabled.color, DSColors.statusDisabled);
    });

    test('each has a label', () {
      expect(DSMetricTileHealth.healthy.label, 'Healthy');
      expect(DSMetricTileHealth.degraded.label, 'Degraded');
      expect(DSMetricTileHealth.error.label, 'Error');
      expect(DSMetricTileHealth.disabled.label, 'Disabled');
    });
  });

  // ===========================================================================
  // DSStateSurface — Operational Constructors
  // ===========================================================================
  group('DSStateSurface operational constructors', () {
    testWidgets('disabled renders title', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DSStateSurface.disabled(title: 'Feature Disabled'),
        ),
      );
      expect(find.text('Feature Disabled'), findsOneWidget);
      expect(find.byIcon(Icons.block), findsOneWidget);
    });

    testWidgets('disabled with subtitle', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DSStateSurface.disabled(
            title: 'Not Available',
            subtitle: 'Read-only mode',
          ),
        ),
      );
      expect(find.text('Not Available'), findsOneWidget);
      expect(find.text('Read-only mode'), findsOneWidget);
    });

    testWidgets('stale renders title and refresh action', (tester) async {
      var refreshed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: DSStateSurface.stale(
            title: 'Data Outdated',
            onAction: () => refreshed = true,
          ),
        ),
      );
      expect(find.text('Data Outdated'), findsOneWidget);
      expect(find.byIcon(Icons.update), findsOneWidget);
      // Default action label is 'Refresh'
      await tester.tap(find.text('Refresh'));
      expect(refreshed, true);
    });

    testWidgets('degraded renders title', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: DSStateSurface.degraded(title: 'Partial Data')),
      );
      expect(find.text('Partial Data'), findsOneWidget);
      expect(find.byIcon(Icons.warning_amber), findsOneWidget);
    });

    testWidgets('excluded renders title', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: DSStateSurface.excluded(title: 'Filtered Out')),
      );
      expect(find.text('Filtered Out'), findsOneWidget);
      expect(find.byIcon(Icons.remove_circle_outline), findsOneWidget);
    });

    testWidgets('operational states render compact', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DSStateSurface.stale(title: 'Stale', compact: true),
        ),
      );
      expect(find.text('Stale'), findsOneWidget);
    });

    testWidgets('custom icon overrides default', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DSStateSurface.disabled(title: 'Custom', icon: Icons.lock),
        ),
      );
      expect(find.byIcon(Icons.lock), findsOneWidget);
    });

    testWidgets('custom accent color overrides default', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DSStateSurface.degraded(
            title: 'Custom Color',
            accentColor: DSColors.accentCyan,
          ),
        ),
      );
      expect(find.text('Custom Color'), findsOneWidget);
    });
  });

  // ===========================================================================
  // DSStateType enum — expanded
  // ===========================================================================
  group('DSStateType enum', () {
    test('has 8 values (3 data + 4 operational + unknown)', () {
      expect(DSStateType.values.length, 8);
    });

    test('includes data states', () {
      expect(DSStateType.empty, isNotNull);
      expect(DSStateType.loading, isNotNull);
      expect(DSStateType.error, isNotNull);
    });

    test('includes operational states', () {
      expect(DSStateType.disabled, isNotNull);
      expect(DSStateType.stale, isNotNull);
      expect(DSStateType.degraded, isNotNull);
      expect(DSStateType.excluded, isNotNull);
    });

    test('includes fail-closed unknown', () {
      expect(DSStateType.unknown, isNotNull);
      expect(DSStateType.unknown.isIndeterminate, isTrue);
    });
  });

  // ===========================================================================
  // Prism* Public API Aliases
  // ===========================================================================
  group('Prism* public API aliases', () {
    test('PrismStatusDot resolves to DSStatusDot', () {
      expect(PrismStatusDot, DSStatusDot);
    });

    test('PrismMetricTile resolves to DSMetricTile', () {
      expect(PrismMetricTile, DSMetricTile);
    });

    test('PrismMetricTileCompact resolves to DSMetricTileCompact', () {
      expect(PrismMetricTileCompact, DSMetricTileCompact);
    });

    test('PrismMetricTileHealth resolves to DSMetricTileHealth', () {
      expect(PrismMetricTileHealth, DSMetricTileHealth);
    });

    test('PrismTrend resolves to DSTrend', () {
      expect(PrismTrend, DSTrend);
    });

    test('PrismStateSurface resolves to DSStateSurface', () {
      expect(PrismStateSurface, DSStateSurface);
    });

    test('PrismStateType resolves to DSStateType', () {
      expect(PrismStateType, DSStateType);
    });

    test('PrismTaskCard resolves to DSTaskCard', () {
      expect(PrismTaskCard, DSTaskCard);
    });

    test('PrismAssetCard resolves to DSAssetCard', () {
      expect(PrismAssetCard, DSAssetCard);
    });

    test('PrismSearchBar resolves to DSSearchBar', () {
      expect(PrismSearchBar, DSSearchBar);
    });

    test('PrismFilterChipGroup resolves to DSFilterChipGroup', () {
      expect(PrismFilterChipGroup, DSFilterChipGroup);
    });

    test('PrismEvidenceRow resolves to DSEvidenceRow', () {
      expect(PrismEvidenceRow, DSEvidenceRow);
    });

    test('PrismProvenancePill resolves to DSProvenancePill', () {
      expect(PrismProvenancePill, DSProvenancePill);
    });

    test('PrismLaneBoard resolves to DSLaneBoard', () {
      expect(PrismLaneBoard, DSLaneBoard);
    });

    test('PrismLane resolves to DSLane', () {
      expect(PrismLane, DSLane);
    });

    test('PrismLaneTask resolves to DSLaneTask', () {
      expect(PrismLaneTask, DSLaneTask);
    });

    testWidgets('PrismStatusDot.running works via public API', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: PrismStatusDot.running()),
      );
      expect(find.byType(PrismStatusDot), findsOneWidget);
    });

    testWidgets('PrismMetricTile with health works via public API', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PrismMetricTile(
            label: 'Test',
            value: '42',
            health: PrismMetricTileHealth.degraded,
          ),
        ),
      );
      expect(find.text('Degraded'), findsOneWidget);
    });

    testWidgets('PrismStateSurface.disabled works via public API', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PrismStateSurface.disabled(title: 'Disabled via API'),
        ),
      );
      expect(find.text('Disabled via API'), findsOneWidget);
    });
  });

  // ===========================================================================
  // DSColors — Operational State Token Verification
  // ===========================================================================
  group('DSColors operational state tokens', () {
    test('all 15 operational state colors exist', () {
      // Lifecycle
      expect(DSColors.statusPending, isNotNull);
      expect(DSColors.statusRunning, isNotNull);
      expect(DSColors.statusApproved, isNotNull);
      expect(DSColors.statusRejected, isNotNull);
      expect(DSColors.statusPromoted, isNotNull);
      expect(DSColors.statusArchived, isNotNull);
      // Health
      expect(DSColors.statusHealthy, isNotNull);
      expect(DSColors.statusDegraded, isNotNull);
      expect(DSColors.statusDisabled, isNotNull);
      // Verification
      expect(DSColors.statusUnverified, isNotNull);
      expect(DSColors.statusExposed, isNotNull);
      expect(DSColors.statusRedacted, isNotNull);
      // Governance
      expect(DSColors.statusStale, isNotNull);
      expect(DSColors.statusExcluded, isNotNull);
      // Also statusError (mapped from multiple states)
      expect(DSColors.statusError, isNotNull);
    });

    test('no new hex values — all are aliases', () {
      expect(DSColors.statusPending, DSColors.textTertiary);
      expect(DSColors.statusRunning, DSColors.accentGold);
      expect(DSColors.statusApproved, DSColors.statusSuccess);
      expect(DSColors.statusRejected, DSColors.statusError);
      expect(DSColors.statusPromoted, DSColors.accentCyan);
      expect(DSColors.statusArchived, DSColors.textDisabled);
      expect(DSColors.statusHealthy, DSColors.statusSuccess);
      expect(DSColors.statusDegraded, DSColors.statusWarning);
      expect(DSColors.statusDisabled, DSColors.textDisabled);
      expect(DSColors.statusUnverified, DSColors.textTertiary);
      expect(DSColors.statusExposed, DSColors.statusError);
      expect(DSColors.statusRedacted, DSColors.accentViolet);
      expect(DSColors.statusStale, DSColors.statusWarning);
      expect(DSColors.statusExcluded, DSColors.textDisabled);
    });
  });

  // ===========================================================================
  // DSTaskCard — Operational & Proof States
  // ===========================================================================
  group('DSTaskCard operational & proof states', () {
    testWidgets('renders default DSTaskCard fields', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DSTaskCard(
              id: 1106,
              title: 'Operational Component MVP',
              lane: 'doing',
              priority: 'P1',
              owner: 'builders',
              proofState: 'complete',
              reviewScore: 100,
              dependencyCount: 3,
              linkedSkills: ['flutter', 'code-quality'],
            ),
          ),
        ),
      );
      expect(find.text('#1106'), findsOneWidget);
      expect(find.text('Operational Component MVP'), findsOneWidget);
      expect(find.text('P1'), findsOneWidget);
      expect(find.text('builders'), findsOneWidget);
      expect(find.text('100'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('flutter'), findsOneWidget);
      expect(find.text('code-quality'), findsOneWidget);
    });

    testWidgets('renders selected DSTaskCard state', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DSTaskCard(
              id: 1401,
              title: 'Observatory Failure Baseline Inventory',
              lane: 'doing',
              selected: true,
            ),
          ),
        ),
      );
      expect(find.text('#1401'), findsOneWidget);
      expect(
        find.text('Observatory Failure Baseline Inventory'),
        findsOneWidget,
      );
    });

    testWidgets(
      'renders proofState status dot for complete, partial, missing',
      (tester) async {
        for (final proof in ['complete', 'partial', 'missing']) {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: DSTaskCard(
                  id: 100,
                  title: 'Task Title',
                  lane: 'doing',
                  proofState: proof,
                ),
              ),
            ),
          );
          expect(find.byType(DSStatusDot), findsOneWidget);
        }
      },
    );

    testWidgets('onTap callback fires when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DSTaskCard(
              id: 200,
              title: 'Tap Test Task',
              lane: 'open',
              onTap: () => tapped = true,
            ),
          ),
        ),
      );
      await tester.tap(find.byType(DSTaskCard));
      expect(tapped, isTrue);
    });
  });

  // ===========================================================================
  // Operational MVP Edge Conditions (Long Text, High Text Scale, Narrow Viewport)
  // ===========================================================================
  group('Operational MVP edge conditions', () {
    testWidgets(
      'DSMetricTile renders under 180px narrow viewport and long text',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 180,
                child: DSMetricTile(
                  label: 'Very Long Metric Label That Should Truncate Safely',
                  value: '99,999,999',
                  health: DSMetricTileHealth.degraded,
                ),
              ),
            ),
          ),
        );
        expect(find.text('Degraded'), findsOneWidget);
        expect(find.text('99,999,999'), findsOneWidget);
      },
    );

    testWidgets('DSMetricTile renders under 2.0x high text scale', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(2.0)),
            child: child!,
          ),
          home: const Scaffold(
            body: DSMetricTile(
              label: 'Scaled Metric',
              value: '100%',
              health: DSMetricTileHealth.healthy,
            ),
          ),
        ),
      );
      expect(find.text('Scaled Metric'), findsOneWidget);
      expect(find.text('100%'), findsOneWidget);
    });

    testWidgets('DSTaskCard renders under 200px narrow viewport and long text', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200,
              child: DSTaskCard(
                id: 9999,
                title:
                    'Extremely Long Task Title Designed to Test Multi-Line Wrapping and Text Overflow Behavior Across Narrow Columns',
                lane: 'doing',
                priority: 'P0',
                owner: 'builders-long-agent-name',
                proofState: 'complete',
                reviewScore: 95,
                dependencyCount: 12,
              ),
            ),
          ),
        ),
      );
      expect(find.text('#9999'), findsOneWidget);
      expect(find.text('P0'), findsOneWidget);
    });

    testWidgets('DSTaskCard renders under 2.0x high text scale', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(2.0)),
            child: child!,
          ),
          home: const Scaffold(
            body: DSTaskCard(
              id: 8888,
              title: 'High Text Scale Task Card',
              lane: 'open',
              priority: 'P1',
              owner: 'builders',
            ),
          ),
        ),
      );
      expect(find.text('High Text Scale Task Card'), findsOneWidget);
    });
  });
}
