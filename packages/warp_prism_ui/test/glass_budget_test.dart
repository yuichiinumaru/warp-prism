// Glass Performance Budget Regression Test
// Task 1040: Validates that blur usage matches the documented performance budget
//
// Policy source of truth:
//   docs/reports/epic-10-glass-performance-budget.md
//
// Public API only: consumer-facing Prism* names via warp_prism_ui.dart.
// DS* implementation names are intentionally not exported by the public barrel.
//
// Allow-listed product blur hosts (must stay in sync with the budget report):
//   - PrismStoryPanel  (PrismGlassPanel.elevated, sigma 15)
//   - PrismCommandPalette (modal BackdropFilter, sigma 20)
// Stackable / high-frequency hosts must remain blur-free (e.g. PrismToast).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

/// Product hosts that may introduce BackdropFilter. Update the budget report
/// in the same change if this set grows or shrinks.
const Set<String> kJustifiedBlurHosts = {
  'PrismStoryPanel',
  'PrismCommandPalette',
};

void main() {
  group('Glass Performance Budget', () {
    group('PrismGlassPanel tier contracts', () {
      test('subtle tier uses blur sigma 5', () {
        const panel = PrismGlassPanel.subtle(child: SizedBox());
        expect(panel.blur, equals(5));
      });

      test('default tier uses blur sigma 10', () {
        const panel = PrismGlassPanel(child: SizedBox());
        expect(panel.blur, equals(10));
      });

      test('elevated tier uses blur sigma 15', () {
        const panel = PrismGlassPanel.elevated(child: SizedBox());
        expect(panel.blur, equals(15));
      });

      test('modal tier uses blur sigma 20', () {
        const panel = PrismGlassPanel.modal(child: SizedBox());
        expect(panel.blur, equals(20));
      });

      test('blur tiers are ordered from least to most expensive', () {
        const subtle = PrismGlassPanel.subtle(child: SizedBox());
        const default_ = PrismGlassPanel(child: SizedBox());
        const elevated = PrismGlassPanel.elevated(child: SizedBox());
        const modal = PrismGlassPanel.modal(child: SizedBox());

        expect(subtle.blur, lessThan(default_.blur));
        expect(default_.blur, lessThan(elevated.blur));
        expect(elevated.blur, lessThan(modal.blur));
      });
    });

    group('PrismGlassPanelSimple is blur-free', () {
      testWidgets('PrismGlassPanelSimple does not introduce BackdropFilter', (
        tester,
      ) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: PrismGlassPanelSimple(child: Text('simple')),
            ),
          ),
        );

        expect(find.byType(BackdropFilter), findsNothing);
        expect(find.text('simple'), findsOneWidget);
      });
    });

    group('High-frequency surfaces use simple / no-blur paths', () {
      testWidgets('PrismStoryCardQuick renders without BackdropFilter', (
        tester,
      ) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: PrismStoryCardQuick(title: 'Test', value: '42'),
            ),
          ),
        );

        expect(find.byType(BackdropFilter), findsNothing);
        expect(find.byType(PrismGlassPanelSimple), findsOneWidget);
      });

      testWidgets('PrismMetricTile renders without BackdropFilter', (
        tester,
      ) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: PrismMetricTile(label: 'Test Metric', value: '100'),
            ),
          ),
        );

        expect(find.byType(BackdropFilter), findsNothing);
      });

      testWidgets('PrismAssetCard renders without any glass panel blur', (
        tester,
      ) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: PrismAssetCard(name: 'test-skill', kind: 'skill'),
            ),
          ),
        );

        expect(find.byType(BackdropFilter), findsNothing);
        expect(find.byType(PrismGlassPanel), findsNothing);
      });

      testWidgets('PrismTaskCard renders without any glass panel blur', (
        tester,
      ) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: PrismTaskCard(id: 1, title: 'Test task', lane: '02-doing'),
            ),
          ),
        );

        expect(find.byType(BackdropFilter), findsNothing);
        expect(find.byType(PrismGlassPanel), findsNothing);
      });
    });

    group('Toast stack stays blur-free (multi-instance budget)', () {
      testWidgets('PrismToast uses PrismGlassPanelSimple without BackdropFilter', (
        tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PrismToast(
                entry: PrismToastEntry(
                  id: 'budget-toast',
                  severity: PrismToastSeverity.info,
                  title: 'Budget toast',
                  message: 'No blur on stackable overlays',
                  duration: Duration.zero,
                ),
              ),
            ),
          ),
        );

        expect(find.byType(PrismToast), findsOneWidget);
        expect(find.byType(PrismGlassPanelSimple), findsOneWidget);
        expect(find.byType(PrismGlassPanel), findsNothing);
        expect(find.byType(BackdropFilter), findsNothing);
      });

      testWidgets(
        'multiple PrismToast instances do not introduce BackdropFilter',
        (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: Column(
                  children: [
                    for (var i = 0; i < 3; i++)
                      PrismToast(
                        entry: PrismToastEntry(
                          id: 'stack-$i',
                          severity: PrismToastSeverity.success,
                          title: 'Stacked $i',
                          duration: Duration.zero,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );

          expect(find.byType(PrismToast), findsNWidgets(3));
          expect(find.byType(BackdropFilter), findsNothing);
          expect(find.byType(PrismGlassPanel), findsNothing);
        },
      );
    });

    group('Justified blur hosts', () {
      testWidgets(
        'PrismStoryPanel uses PrismGlassPanel.elevated (exactly one filter)',
        (tester) async {
          await tester.pumpWidget(
            const MaterialApp(
              home: Scaffold(
                body: PrismStoryPanel(title: 'Test Story', insights: []),
              ),
            ),
          );

          expect(find.byType(PrismGlassPanel), findsOneWidget);
          expect(find.byType(BackdropFilter), findsOneWidget);
        },
      );

      testWidgets(
        'PrismStoryPanel does not nest BackdropFilter inside BackdropFilter',
        (tester) async {
          await tester.pumpWidget(
            const MaterialApp(
              home: Scaffold(
                body: PrismStoryPanel(
                  title: 'Test',
                  insights: [PrismStoryInsight(text: 'Insight 1')],
                ),
              ),
            ),
          );

          expect(find.byType(BackdropFilter), findsOneWidget);
        },
      );

      testWidgets(
        'PrismCommandPalette uses exactly one modal BackdropFilter',
        (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: PrismCommandPalette(
                  commands: const [
                    PrismCommand(
                      id: 'nav-home',
                      label: 'Go home',
                      category: PrismCommandCategory.navigate,
                    ),
                  ],
                  onClose: () {},
                ),
              ),
            ),
          );
          // Auto-focus post-frame callback.
          await tester.pump();

          expect(find.byType(PrismCommandPalette), findsOneWidget);
          expect(find.byType(BackdropFilter), findsOneWidget);
        },
      );
    });

    group('Budget surface allow-list', () {
      test('justified blur host set matches documented inventory', () {
        // Fail closed: if you add or remove a blur host, update BOTH:
        //   1. docs/reports/epic-10-glass-performance-budget.md §2.3
        //   2. kJustifiedBlurHosts and the widget tests in this file
        expect(
          kJustifiedBlurHosts,
          equals({'PrismStoryPanel', 'PrismCommandPalette'}),
        );
        expect(kJustifiedBlurHosts.contains('PrismToast'), isFalse);
        expect(kJustifiedBlurHosts.length, equals(2));
      });

      test('allow-list excludes high-frequency public card hosts', () {
        const highFrequency = {
          'PrismStoryCardQuick',
          'PrismMetricTile',
          'PrismAssetCard',
          'PrismTaskCard',
          'PrismToast',
        };
        expect(kJustifiedBlurHosts.intersection(highFrequency), isEmpty);
      });
    });
  });
}
