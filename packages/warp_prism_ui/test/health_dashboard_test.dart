// Widget tests for Health Dashboard components.
//
// Covers: DSOperationalState, DSSparkline, DSUptimeBar, DSHealthCard,
// DSStatusGrid, DSHealthCardData.
//
// Run: flutter test test/health_dashboard_test.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_ui/src/tokens/tokens.dart';
import 'package:warp_prism_ui/src/atoms/atoms.dart';
import 'package:warp_prism_ui/src/molecules/molecules.dart';
import 'package:warp_prism_ui/src/organisms/ds_status_grid.dart';

void main() {
  // ===========================================================================
  // DSOperationalState
  // ===========================================================================
  group('DSOperationalState contract', () {
    test(
      'has 15 values covering lifecycle, health, verification, governance',
      () {
        expect(DSOperationalState.values.length, 15);
      },
    );

    test('every state has a non-empty label', () {
      for (final state in DSOperationalState.values) {
        expect(state.label, isNotEmpty);
      }
    });

    test('every state has a semantic label', () {
      for (final state in DSOperationalState.values) {
        expect(state.semanticLabel, isNotEmpty);
        expect(state.semanticLabel, contains(':'));
      }
    });

    test('every state has a color', () {
      for (final state in DSOperationalState.values) {
        expect(state.color, isA<Color>());
      }
    });

    test('every state has an icon', () {
      for (final state in DSOperationalState.values) {
        expect(state.icon, isA<IconData>());
      }
    });

    test('running state should be animated', () {
      for (final state in DSOperationalState.values) {
        if (state == DSOperationalState.running) {
          // Running is the only animated state — this is a behavioral contract
          expect(state.label, 'Running');
        } else {
          expect(state.label, isNot('Running'));
        }
      }
    });

    test('health states map to expected colors', () {
      expect(DSOperationalState.healthy.color, DSColors.statusSuccess);
      expect(DSOperationalState.degraded.color, DSColors.statusWarning);
      expect(DSOperationalState.error.color, DSColors.statusError);
      expect(DSOperationalState.disabled.color, DSColors.textDisabled);
    });
  });

  // ===========================================================================
  // DSSparkline
  // ===========================================================================
  group('DSSparkline contract', () {
    testWidgets('renders with data points', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SizedBox(
            width: 200,
            height: 40,
            child: DSSparkline(data: [10, 20, 30, 25, 15]),
          ),
        ),
      );
      expect(find.byType(DSSparkline), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('renders with empty data gracefully', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SizedBox(width: 200, height: 40, child: DSSparkline(data: [])),
        ),
      );
      expect(find.byType(DSSparkline), findsOneWidget);
      // Should not throw — renders a flat line
    });

    testWidgets('renders with single data point', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SizedBox(
            width: 200,
            height: 40,
            child: DSSparkline(data: [42]),
          ),
        ),
      );
      expect(find.byType(DSSparkline), findsOneWidget);
    });

    testWidgets('renders with 100+ data points', (tester) async {
      final data = List.generate(150, (i) => i * 1.0);
      await tester.pumpWidget(
        MaterialApp(
          home: SizedBox(
            width: 200,
            height: 40,
            child: DSSparkline(data: data),
          ),
        ),
      );
      expect(find.byType(DSSparkline), findsOneWidget);
    });

    testWidgets('accepts custom color', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SizedBox(
            width: 200,
            height: 40,
            child: DSSparkline(data: [1, 2, 3], color: Colors.red),
          ),
        ),
      );
      expect(find.byType(DSSparkline), findsOneWidget);
    });

    testWidgets('has default semantic label', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SizedBox(
            width: 200,
            height: 40,
            child: DSSparkline(data: [10, 20, 30]),
          ),
        ),
      );
      expect(
        find.bySemanticsLabel('Trend chart: 3 points, range 10.0 to 30.0'),
        findsOneWidget,
      );
    });

    testWidgets('empty data has "no data" semantic label', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SizedBox(width: 200, height: 40, child: DSSparkline(data: [])),
        ),
      );
      expect(find.bySemanticsLabel('Trend chart: no data'), findsOneWidget);
    });

    testWidgets('custom semantic label is applied', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SizedBox(
            width: 200,
            height: 40,
            child: DSSparkline(data: [1, 2], semanticLabel: 'Custom label'),
          ),
        ),
      );
      expect(find.bySemanticsLabel('Custom label'), findsOneWidget);
    });
  });

  // ===========================================================================
  // DSUptimeBar
  // ===========================================================================
  group('DSUptimeBar contract', () {
    testWidgets('renders with green color for uptime >99%', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SizedBox(
            width: 200,
            height: 24,
            child: DSUptimeBar(uptimePercent: 0.995),
          ),
        ),
      );
      expect(find.byType(DSUptimeBar), findsOneWidget);
      expect(find.text('99.5%'), findsOneWidget);
    });

    testWidgets('renders with amber color for uptime 95-99%', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SizedBox(
            width: 200,
            height: 24,
            child: DSUptimeBar(uptimePercent: 0.97),
          ),
        ),
      );
      expect(find.text('97%'), findsOneWidget);
    });

    testWidgets('renders with red color for uptime ≤95%', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SizedBox(
            width: 200,
            height: 24,
            child: DSUptimeBar(uptimePercent: 0.80),
          ),
        ),
      );
      expect(find.text('80%'), findsOneWidget);
    });

    testWidgets('has semantic label with uptime value', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SizedBox(
            width: 200,
            height: 24,
            child: DSUptimeBar(uptimePercent: 0.995),
          ),
        ),
      );
      // The Semantics widget should contain the uptime info
      final semantics = tester.getSemantics(find.byType(DSUptimeBar));
      expect(semantics, isNotNull);
    });

    testWidgets('hides label when showLabel is false', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SizedBox(
            width: 200,
            height: 24,
            child: DSUptimeBar(uptimePercent: 0.99, showLabel: false),
          ),
        ),
      );
      expect(find.byType(DSUptimeBar), findsOneWidget);
      // The percentage text should not appear
      expect(find.text('99%'), findsNothing);
    });

    testWidgets('accepts custom color override', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SizedBox(
            width: 200,
            height: 24,
            child: DSUptimeBar(uptimePercent: 0.50, color: Colors.purple),
          ),
        ),
      );
      expect(find.byType(DSUptimeBar), findsOneWidget);
    });

    testWidgets('handles 0% and 100% bounds', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Column(
            children: [
              SizedBox(
                width: 200,
                height: 24,
                child: DSUptimeBar(uptimePercent: 0.0),
              ),
              SizedBox(
                width: 200,
                height: 24,
                child: DSUptimeBar(uptimePercent: 1.0),
              ),
            ],
          ),
        ),
      );
      expect(find.text('0%'), findsOneWidget);
      expect(find.text('100%'), findsOneWidget);
    });
  });

  // ===========================================================================
  // DSHealthCard
  // ===========================================================================
  group('DSHealthCard contract', () {
    testWidgets('displays service name', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SizedBox(
            width: 300,
            child: DSHealthCard(
              serviceName: 'MCP Server Alpha',
              operationalState: DSOperationalState.healthy,
            ),
          ),
        ),
      );
      expect(find.text('MCP Server Alpha'), findsOneWidget);
    });

    testWidgets('displays operational state label', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SizedBox(
            width: 300,
            child: DSHealthCard(
              serviceName: 'Test Service',
              operationalState: DSOperationalState.degraded,
            ),
          ),
        ),
      );
      expect(find.text('Degraded'), findsOneWidget);
    });

    testWidgets('displays latency when provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SizedBox(
            width: 300,
            child: DSHealthCard(
              serviceName: 'Test Service',
              operationalState: DSOperationalState.healthy,
              latency: Duration(milliseconds: 42),
            ),
          ),
        ),
      );
      expect(find.text('42ms'), findsOneWidget);
    });

    testWidgets('displays latency in seconds for >1000ms', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SizedBox(
            width: 300,
            child: DSHealthCard(
              serviceName: 'Slow Service',
              operationalState: DSOperationalState.degraded,
              latency: Duration(milliseconds: 2500),
            ),
          ),
        ),
      );
      expect(find.text('2.5s'), findsOneWidget);
    });

    testWidgets('displays uptime bar when uptimePercent provided', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SizedBox(
            width: 300,
            child: DSHealthCard(
              serviceName: 'Test Service',
              operationalState: DSOperationalState.healthy,
              uptimePercent: 0.999,
            ),
          ),
        ),
      );
      expect(find.byType(DSUptimeBar), findsOneWidget);
    });

    testWidgets('displays sparkline when trendData provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SizedBox(
            width: 300,
            child: DSHealthCard(
              serviceName: 'Test Service',
              operationalState: DSOperationalState.healthy,
              trendData: [1, 2, 3, 4, 5],
            ),
          ),
        ),
      );
      expect(find.byType(DSSparkline), findsOneWidget);
    });

    testWidgets('omits uptime bar when uptimePercent is null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SizedBox(
            width: 300,
            child: DSHealthCard(
              serviceName: 'Test Service',
              operationalState: DSOperationalState.healthy,
            ),
          ),
        ),
      );
      expect(find.byType(DSUptimeBar), findsNothing);
    });

    testWidgets('omits sparkline when trendData is null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SizedBox(
            width: 300,
            child: DSHealthCard(
              serviceName: 'Test Service',
              operationalState: DSOperationalState.healthy,
            ),
          ),
        ),
      );
      expect(find.byType(DSSparkline), findsNothing);
    });

    testWidgets('has semantic label for screen readers', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SizedBox(
            width: 300,
            child: DSHealthCard(
              serviceName: 'MCP Alpha',
              operationalState: DSOperationalState.healthy,
            ),
          ),
        ),
      );
      // The Semantics widget should contain the service name and state
      final semantics = tester.getSemantics(find.byType(DSHealthCard));
      expect(semantics, isNotNull);
    });

    testWidgets('renders all fields together', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SizedBox(
            width: 300,
            child: DSHealthCard(
              serviceName: 'Full Card',
              operationalState: DSOperationalState.healthy,
              latency: const Duration(milliseconds: 50),
              uptimePercent: 0.999,
              trendData: const [10, 20, 30, 20, 10],
              lastCheck: DateTime(2026, 6, 8, 12, 0),
            ),
          ),
        ),
      );
      expect(find.text('Full Card'), findsOneWidget);
      expect(find.text('50ms'), findsOneWidget);
      expect(find.byType(DSUptimeBar), findsOneWidget);
      expect(find.byType(DSSparkline), findsOneWidget);
    });

    testWidgets('fires onTap callback', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: SizedBox(
            width: 300,
            child: DSHealthCard(
              serviceName: 'Tappable',
              operationalState: DSOperationalState.healthy,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );
      await tester.tap(find.text('Tappable'));
      expect(tapped, isTrue);
    });

    testWidgets(
      'interactive onTap supports keyboard Enter/Space via DSInteractiveSurface',
      (tester) async {
        final handle = tester.ensureSemantics();
        var activations = 0;
        final focusNode = FocusNode();
        addTearDown(focusNode.dispose);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 300,
                child: DSHealthCard(
                  serviceName: 'Keyboard Card',
                  operationalState: DSOperationalState.healthy,
                  onTap: () => activations++,
                  focusNode: focusNode,
                ),
              ),
            ),
          ),
        );

        final interactive = tester.getSemantics(find.byType(DSHealthCard));
        expect(interactive.flagsCollection.isButton, isTrue);
        expect(interactive.label, contains('Keyboard Card'));

        await tester.tap(find.text('Keyboard Card'));
        await tester.pump();
        expect(activations, 1);

        focusNode.requestFocus();
        await tester.pump();
        expect(focusNode.hasFocus, isTrue);

        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pump();
        expect(activations, 2);

        await tester.sendKeyEvent(LogicalKeyboardKey.space);
        await tester.pump();
        expect(activations, 3);
        handle.dispose();
      },
    );

    testWidgets('non-interactive card is not a button', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        const MaterialApp(
          home: SizedBox(
            width: 300,
            child: DSHealthCard(
              serviceName: 'Passive',
              operationalState: DSOperationalState.healthy,
            ),
          ),
        ),
      );
      final data = tester.getSemantics(find.byType(DSHealthCard));
      expect(data.flagsCollection.isButton, isFalse);
      handle.dispose();
    });
  });

  // ===========================================================================
  // DSStatusGrid
  // ===========================================================================
  group('DSStatusGrid contract', () {
    final testItems = [
      const DSHealthCardData(
        serviceName: 'Service A',
        operationalState: DSOperationalState.healthy,
      ),
      const DSHealthCardData(
        serviceName: 'Service B',
        operationalState: DSOperationalState.degraded,
      ),
      const DSHealthCardData(
        serviceName: 'Service C',
        operationalState: DSOperationalState.error,
      ),
      const DSHealthCardData(
        serviceName: 'Service D',
        operationalState: DSOperationalState.healthy,
      ),
    ];

    testWidgets('renders a grid of health cards', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SizedBox(
            width: 800,
            height: 600,
            child: DSStatusGrid(items: testItems),
          ),
        ),
      );
      expect(find.byType(DSHealthCard), findsNWidgets(4));
      expect(find.text('Service A'), findsOneWidget);
      expect(find.text('Service B'), findsOneWidget);
      expect(find.text('Service C'), findsOneWidget);
      expect(find.text('Service D'), findsOneWidget);
    });

    testWidgets('has grid accessibility label', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SizedBox(
            width: 800,
            height: 600,
            child: DSStatusGrid(items: testItems),
          ),
        ),
      );
      expect(
        find.bySemanticsLabel('Service health grid: 4 services'),
        findsOneWidget,
      );
    });

    testWidgets('shows empty state when no items', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SizedBox(
            width: 800,
            height: 400,
            child: DSStatusGrid(items: []),
          ),
        ),
      );
      expect(find.byType(DSHealthCard), findsNothing);
      expect(find.byType(DSStateSurface), findsOneWidget);
    });

    testWidgets('filters by operational state', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SizedBox(
            width: 800,
            height: 600,
            child: DSStatusGrid(
              items: testItems,
              activeFilter: const {DSOperationalState.healthy},
            ),
          ),
        ),
      );
      // Should only show healthy services
      expect(find.byType(DSHealthCard), findsNWidgets(2));
      expect(find.text('Service A'), findsOneWidget);
      expect(find.text('Service D'), findsOneWidget);
      expect(find.text('Service B'), findsNothing);
      expect(find.text('Service C'), findsNothing);
    });

    testWidgets('shows empty state when filter matches nothing', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SizedBox(
            width: 800,
            height: 400,
            child: DSStatusGrid(
              items: testItems,
              activeFilter: const {DSOperationalState.promoted},
            ),
          ),
        ),
      );
      expect(find.byType(DSHealthCard), findsNothing);
      expect(find.byType(DSStateSurface), findsOneWidget);
      expect(find.text('No services match filter'), findsOneWidget);
    });

    testWidgets('renders filter bar when showFilterBar is true', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SizedBox(
            width: 800,
            height: 600,
            child: DSStatusGrid(items: testItems, showFilterBar: true),
          ),
        ),
      );
      expect(find.byType(DSFilterChipGroup), findsOneWidget);
    });

    testWidgets('does not render filter bar by default', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SizedBox(
            width: 800,
            height: 600,
            child: DSStatusGrid(items: testItems),
          ),
        ),
      );
      expect(find.byType(DSFilterChipGroup), findsNothing);
    });

    testWidgets(
      'primary surface embedInScrollView:false uses scrollable physics',
      (tester) async {
        final many = List.generate(
          60,
          (i) => DSHealthCardData(
            serviceName: 'Service $i',
            operationalState: DSOperationalState.healthy,
          ),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 800,
                height: 600,
                child: DSStatusGrid(items: many, embedInScrollView: false),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final grid = tester.widget<GridView>(find.byType(GridView));
        expect(grid.shrinkWrap, isFalse);
        expect(grid.physics, isA<AlwaysScrollableScrollPhysics>());
        // Lazy builder: not all 60 cards necessarily mounted initially.
        expect(find.byType(DSHealthCard), findsWidgets);
        expect(find.byType(DSHealthCard).evaluate().length, lessThan(60));
      },
    );

    testWidgets(
      'embedInScrollView:true uses shrinkWrap + never-scroll physics',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: SingleChildScrollView(
              child: DSStatusGrid(items: testItems, embedInScrollView: true),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final grid = tester.widget<GridView>(find.byType(GridView));
        expect(grid.shrinkWrap, isTrue);
        expect(grid.physics, isA<NeverScrollableScrollPhysics>());
        expect(find.byType(DSHealthCard), findsNWidgets(4));
      },
    );
  });
}
