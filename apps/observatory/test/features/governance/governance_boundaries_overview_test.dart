/// Widget tests for the Governance canonicality boundaries overview.
///
/// Verifies:
/// - Page renders canonicality counts from fixture data (not hardcoded)
/// - Legend distinguishes canonical, generated, append-only, archive, mock, child-local
/// - Read-only messaging is present
/// - Empty state renders when no diagnostics available
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_observatory/data/models/governance_diagnostics.dart';
import 'package:warp_prism_observatory/features/governance/presentation/governance_overview_page.dart';
import 'package:warp_prism_observatory/features/governance/presentation/widgets/governance_boundary_legend.dart';

/// Build a representative [CanonicalityBoundarySummary] fixture.
CanonicalityBoundarySummary _testSummary({
  Map<String, int>? counts,
  int totalAssets = 42,
  List<GovernanceDiagnostic>? diagnostics,
}) {
  return CanonicalityBoundarySummary(
    counts: counts ??
        const {
          'parentCanonical': 18,
          'childLocal': 4,
          'generated': 8,
          'appendOnly': 6,
          'archive': 3,
          'mock': 3,
        },
    totalAssets: totalAssets,
    diagnostics: diagnostics ?? [],
  );
}

GovernanceDiagnostic _testDiagnostic({
  String assetId = 'task:0612',
  DiagnosticSeverity severity = DiagnosticSeverity.warning,
  DiagnosticCategory category = DiagnosticCategory.proofGap,
  String message = 'Task claims completion but no evidence found',
}) {
  return GovernanceDiagnostic(
    assetId: assetId,
    severity: severity,
    category: category,
    message: message,
    computedAt: DateTime(2026, 6, 7),
  );
}

Widget _wrapInApp(Widget child) {
  return MaterialApp(
    home: Scaffold(body: SizedBox(width: 1200, height: 900, child: child)),
  );
}

void main() {
  group('GovernanceOverviewPage', () {
    testWidgets('renders read-only banner', (tester) async {
      await tester.pumpWidget(_wrapInApp(
        GovernanceOverviewPage(summary: _testSummary()),
      ));

      expect(find.textContaining('read-only'), findsOneWidget);
    });

    testWidgets('renders total assets count from fixture data', (tester) async {
      await tester.pumpWidget(_wrapInApp(
        GovernanceOverviewPage(summary: _testSummary()),
      ));

      expect(find.text('42'), findsOneWidget);
      expect(find.text('Total Assets'), findsOneWidget);
    });

    testWidgets('renders canonical count from fixture data', (tester) async {
      await tester.pumpWidget(_wrapInApp(
        GovernanceOverviewPage(summary: _testSummary()),
      ));

      expect(find.text('18'), findsOneWidget);
      expect(find.text('Canonical'), findsOneWidget);
    });

    testWidgets('renders generated count from fixture data', (tester) async {
      await tester.pumpWidget(_wrapInApp(
        GovernanceOverviewPage(summary: _testSummary()),
      ));

      expect(find.text('8'), findsOneWidget);
      expect(find.text('Generated'), findsOneWidget);
    });

    testWidgets('renders all six boundary classes in legend', (tester) async {
      await tester.pumpWidget(_wrapInApp(
        GovernanceOverviewPage(summary: _testSummary()),
      ));

      // Legend should show all six classes
      expect(find.text('Canonical'), findsWidgets);
      expect(find.text('Child-Local'), findsOneWidget);
      expect(find.text('Generated'), findsWidgets);
      expect(find.text('Append-Only'), findsOneWidget);
      expect(find.text('Archive'), findsOneWidget);
      expect(find.text('Mock'), findsOneWidget);
    });

    testWidgets('renders diagnostics when present', (tester) async {
      final diag = _testDiagnostic();
      await tester.pumpWidget(_wrapInApp(
        GovernanceOverviewPage(
          summary: _testSummary(diagnostics: [diag]),
        ),
      ));

      expect(find.text('DIAGNOSTICS'), findsOneWidget);
      expect(find.textContaining('proofGap'), findsOneWidget);
      expect(find.text('Task claims completion but no evidence found'),
          findsOneWidget);
    });

    testWidgets('does not render diagnostics section when empty',
        (tester) async {
      await tester.pumpWidget(_wrapInApp(
        GovernanceOverviewPage(summary: _testSummary(diagnostics: [])),
      ));

      expect(find.text('DIAGNOSTICS'), findsNothing);
    });

    testWidgets('renders empty state when no data', (tester) async {
      await tester.pumpWidget(_wrapInApp(
        GovernanceOverviewPage(
          summary: _testSummary(counts: {}, totalAssets: 0),
        ),
      ));

      expect(find.text('No governance data'), findsOneWidget);
    });

    testWidgets('renders non-canonical count calculation', (tester) async {
      await tester.pumpWidget(_wrapInApp(
        GovernanceOverviewPage(summary: _testSummary()),
      ));

      // 42 total - 18 canonical = 24 non-canonical
      expect(find.text('24'), findsOneWidget);
      expect(find.text('Non-Canonical'), findsOneWidget);
    });
  });

  group('GovernanceBoundaryLegend', () {
    testWidgets('renders all six canonicality class labels', (tester) async {
      await tester.pumpWidget(_wrapInApp(
        const GovernanceBoundaryLegend(),
      ));

      expect(find.text('Canonical'), findsOneWidget);
      expect(find.text('Child-Local'), findsOneWidget);
      expect(find.text('Generated'), findsOneWidget);
      expect(find.text('Append-Only'), findsOneWidget);
      expect(find.text('Archive'), findsOneWidget);
      expect(find.text('Mock'), findsOneWidget);
    });

    testWidgets('renders counts when provided', (tester) async {
      await tester.pumpWidget(_wrapInApp(
        GovernanceBoundaryLegend(
          counts: const {
            'parentCanonical': 10,
            'generated': 5,
          },
        ),
      ));

      expect(find.text('10'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('has semantic label for accessibility', (tester) async {
      await tester.pumpWidget(_wrapInApp(
        const GovernanceBoundaryLegend(),
      ));

      expect(find.bySemanticsLabel('Canonicality boundary legend'), findsOneWidget);
    });
  });

  group('GovernanceReadOnlyBanner', () {
    testWidgets('renders read-only message', (tester) async {
      await tester.pumpWidget(_wrapInApp(
        const GovernanceReadOnlyBanner(),
      ));

      expect(find.textContaining('read-only'), findsOneWidget);
      expect(find.byIcon(Icons.lock_outline), findsOneWidget);
    });
  });
}
