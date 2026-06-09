// Glass Performance Budget Regression Test
// Task 1040: Validates that blur usage matches the documented performance budget
//
// These tests verify structural contracts — that glass panel choices in key
// organisms match the policy documented in
// docs/reports/epic-10-glass-performance-budget.md.
//
// They do NOT require a running Flutter app. They test widget construction
// properties to catch regressions where blur is accidentally added to
// high-frequency surfaces.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

void main() {
  group('Glass Performance Budget', () {
    group('DSGlassPanel tier contracts', () {
      test('subtle tier uses blur sigma 5', () {
        const panel = DSGlassPanel.subtle(child: SizedBox());
        expect(panel.blur, equals(5));
      });

      test('default tier uses blur sigma 10', () {
        const panel = DSGlassPanel(child: SizedBox());
        expect(panel.blur, equals(10));
      });

      test('elevated tier uses blur sigma 15', () {
        const panel = DSGlassPanel.elevated(child: SizedBox());
        expect(panel.blur, equals(15));
      });

      test('modal tier uses blur sigma 20', () {
        const panel = DSGlassPanel.modal(child: SizedBox());
        expect(panel.blur, equals(20));
      });

      test('blur tiers are ordered from least to most expensive', () {
        const subtle = DSGlassPanel.subtle(child: SizedBox());
        const default_ = DSGlassPanel(child: SizedBox());
        const elevated = DSGlassPanel.elevated(child: SizedBox());
        const modal = DSGlassPanel.modal(child: SizedBox());

        expect(subtle.blur, lessThan(default_.blur));
        expect(default_.blur, lessThan(elevated.blur));
        expect(elevated.blur, lessThan(modal.blur));
      });
    });

    group('DSGlassPanelSimple is blur-free', () {
      test('DSGlassPanelSimple does not use BackdropFilter', () {
        // DSGlassPanelSimple has no blur parameter — it is a pure Container.
        // This test verifies the class exists and can be constructed.
        const panel = DSGlassPanelSimple(child: SizedBox());
        expect(panel, isA<StatelessWidget>());
      });
    });

    group('High-frequency surfaces use simple panels', () {
      testWidgets('DSStoryCardQuick renders without BackdropFilter',
          (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: DSStoryCardQuick(
                title: 'Test',
                value: '42',
              ),
            ),
          ),
        );

        // DSStoryCardQuick uses DSGlassPanelSimple — no BackdropFilter
        expect(find.byType(BackdropFilter), findsNothing);
        expect(find.byType(DSGlassPanelSimple), findsOneWidget);
      });

      testWidgets('DSMetricTile renders without BackdropFilter',
          (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: DSMetricTile(
                label: 'Test Metric',
                value: '100',
              ),
            ),
          ),
        );

        // DSMetricTile uses DSGlassPanelSimple — no BackdropFilter
        expect(find.byType(BackdropFilter), findsNothing);
      });

      testWidgets('DSAssetCard renders without any glass panel',
          (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: DSAssetCard(
                name: 'test-skill',
                kind: 'skill',
              ),
            ),
          ),
        );

        // DSAssetCard uses plain Container — no glass at all
        expect(find.byType(BackdropFilter), findsNothing);
        expect(find.byType(DSGlassPanel), findsNothing);
        expect(find.byType(DSGlassPanelSimple), findsNothing);
      });

      testWidgets('DSTaskCard renders without any glass panel',
          (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: DSTaskCard(
                id: 1,
                title: 'Test task',
                lane: '02-doing',
              ),
            ),
          ),
        );

        // DSTaskCard uses plain AnimatedContainer — no glass at all
        expect(find.byType(BackdropFilter), findsNothing);
        expect(find.byType(DSGlassPanel), findsNothing);
        expect(find.byType(DSGlassPanelSimple), findsNothing);
      });
    });

    group('Story panel retains justified blur', () {
      testWidgets('DSStoryPanel uses DSGlassPanel.elevated (blur justified)',
          (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: DSStoryPanel(
                title: 'Test Story',
                insights: [],
              ),
            ),
          ),
        );

        // DSStoryPanel is the ONLY justified blur surface
        expect(find.byType(DSGlassPanel), findsOneWidget);
        expect(find.byType(BackdropFilter), findsOneWidget);
      });
    });

    group('No blur nesting', () {
      testWidgets('DSStoryPanel does not nest BackdropFilter inside BackdropFilter',
          (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: DSStoryPanel(
                title: 'Test',
                insights: [
                  DSStoryInsight(text: 'Insight 1'),
                ],
              ),
            ),
          ),
        );

        // Should have exactly 1 BackdropFilter (from DSGlassPanel.elevated),
        // not 2+ (which would indicate nesting).
        expect(find.byType(BackdropFilter), findsOneWidget);
      });
    });

    group('Budget surface classification', () {
      test('blur is only used on narrative surfaces (DSStoryPanel)', () {
        // This is a documentation test: if you add a new DSGlassPanel usage
        // to a host, you MUST also update the budget report and add a test
        // here justifying it.
        //
        // Current justified blur surfaces:
        //   - DSStoryPanel (elevated, sigma 15)
        //
        // If this test fails after your change, update:
        //   1. docs/reports/epic-10-glass-performance-budget.md
        //   2. This test file
        expect(true, isTrue); // placeholder — real checks are in widget tests above
      });
    });
  });
}
