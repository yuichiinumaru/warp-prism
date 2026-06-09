/// Widget tests for governance issue panels (Task 0811).
///
/// Verifies:
/// - Issue groups render for orphaning, staleness, proof gaps, fan-in
/// - Category/severity filtering works
/// - Each issue shows asset title, category, severity, explanation
/// - Empty states render when no issues exist
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_observatory/data/models/governance_diagnostics.dart';
import 'package:warp_prism_observatory/features/governance/presentation/widgets/governance_issue_group.dart';
import 'package:warp_prism_observatory/features/governance/presentation/widgets/governance_issue_filters.dart';

GovernanceDiagnostic _diag({
  String assetId = 'task:0612',
  DiagnosticSeverity severity = DiagnosticSeverity.warning,
  DiagnosticCategory category = DiagnosticCategory.orphanAsset,
  String message = 'Test diagnostic message',
}) {
  return GovernanceDiagnostic(
    assetId: assetId,
    severity: severity,
    category: category,
    message: message,
    computedAt: DateTime(2026, 6, 7),
  );
}

List<GovernanceDiagnostic> _mixedDiagnostics() {
  return [
    _diag(
      assetId: 'skill:orphan-skill',
      category: DiagnosticCategory.orphanAsset,
      severity: DiagnosticSeverity.warning,
      message: 'Skill has no incoming or outgoing edges',
    ),
    _diag(
      assetId: 'workflow:broken-ref',
      category: DiagnosticCategory.staleReference,
      severity: DiagnosticSeverity.error,
      message: 'References non-existent target',
    ),
    _diag(
      assetId: 'task:0612',
      category: DiagnosticCategory.proofGap,
      severity: DiagnosticSeverity.error,
      message: 'Task in completed lane but has no proof',
    ),
    _diag(
      assetId: 'task:0613',
      category: DiagnosticCategory.proofGap,
      severity: DiagnosticSeverity.warning,
      message: 'Task in completed lane but only partial proof',
    ),
    _diag(
      assetId: 'skill:hub-skill',
      category: DiagnosticCategory.brokenEdge,
      severity: DiagnosticSeverity.warning,
      message: 'Asset has 5 incoming edges (fan-in ≥ 3)',
    ),
  ];
}

Widget _wrapInApp(Widget child) {
  return MaterialApp(
    home: Scaffold(body: SizedBox(width: 1200, height: 900, child: child)),
  );
}

void main() {
  group('GovernanceIssueGroup', () {
    testWidgets('renders group title', (tester) async {
      final groups = buildIssueGroups(_mixedDiagnostics());
      await tester.pumpWidget(_wrapInApp(
        GovernanceIssueGroup(group: groups.first),
      ));
      expect(find.text('Orphan Assets'), findsOneWidget);
    });

    testWidgets('renders issue count', (tester) async {
      final groups = buildIssueGroups(_mixedDiagnostics());
      await tester.pumpWidget(_wrapInApp(
        GovernanceIssueGroup(group: groups.first),
      ));
      expect(find.textContaining('1 issue'), findsOneWidget);
    });

    testWidgets('renders issue message', (tester) async {
      final groups = buildIssueGroups(_mixedDiagnostics());
      await tester.pumpWidget(_wrapInApp(
        GovernanceIssueGroup(group: groups.first),
      ));
      expect(find.text('Skill has no incoming or outgoing edges'), findsOneWidget);
    });

    testWidgets('renders asset id', (tester) async {
      final groups = buildIssueGroups(_mixedDiagnostics());
      await tester.pumpWidget(_wrapInApp(
        GovernanceIssueGroup(group: groups.first),
      ));
      expect(find.text('skill:orphan-skill'), findsOneWidget);
    });

    testWidgets('renders empty state when no issues in category',
        (tester) async {
      final emptyGroups = buildIssueGroups([]);
      await tester.pumpWidget(_wrapInApp(
        GovernanceIssueGroup(group: emptyGroups.first),
      ));
      expect(find.textContaining('No orphan assets found'), findsOneWidget);
    });

    testWidgets('renders severity badges', (tester) async {
      final groups = buildIssueGroups(_mixedDiagnostics());
      final proofGroup =
          groups.firstWhere((g) => g.category == DiagnosticCategory.proofGap);
      await tester.pumpWidget(_wrapInApp(
        GovernanceIssueGroup(group: proofGroup),
      ));
      // proof gaps group has 2 issues: 1 error + 1 warning
      expect(find.textContaining('error'), findsOneWidget);
      expect(find.textContaining('warn'), findsOneWidget);
    });

    testWidgets('renders description text', (tester) async {
      final groups = buildIssueGroups(_mixedDiagnostics());
      await tester.pumpWidget(_wrapInApp(
        GovernanceIssueGroup(group: groups.first),
      ));
      expect(
        find.textContaining('isolated in the graph'),
        findsOneWidget,
      );
    });
  });

  group('buildIssueGroups', () {
    test('creates four category groups', () {
      final groups = buildIssueGroups([]);
      expect(groups.length, 4);
      expect(
        groups.map((g) => g.category).toList(),
        containsAll([
          DiagnosticCategory.orphanAsset,
          DiagnosticCategory.staleReference,
          DiagnosticCategory.proofGap,
          DiagnosticCategory.brokenEdge,
        ]),
      );
    });

    test('distributes diagnostics into correct groups', () {
      final groups = buildIssueGroups(_mixedDiagnostics());
      final orphanGroup =
          groups.firstWhere((g) => g.category == DiagnosticCategory.orphanAsset);
      final staleGroup = groups
          .firstWhere((g) => g.category == DiagnosticCategory.staleReference);
      final proofGroup =
          groups.firstWhere((g) => g.category == DiagnosticCategory.proofGap);
      final fanInGroup =
          groups.firstWhere((g) => g.category == DiagnosticCategory.brokenEdge);

      expect(orphanGroup.count, 1);
      expect(staleGroup.count, 1);
      expect(proofGroup.count, 2);
      expect(fanInGroup.count, 1);
    });

    test('counts errors and warnings correctly', () {
      final groups = buildIssueGroups(_mixedDiagnostics());
      final proofGroup =
          groups.firstWhere((g) => g.category == DiagnosticCategory.proofGap);
      expect(proofGroup.errorCount, 1);
      expect(proofGroup.warningCount, 1);
    });
  });

  group('GovernanceFilterState', () {
    test('matches all when no filters active', () {
      const state = GovernanceFilterState();
      final diag = _diag();
      expect(state.matches(diag), isTrue);
    });

    test('filters by category', () {
      final state = GovernanceFilterState(
        selectedCategories: {DiagnosticCategory.orphanAsset},
      );
      expect(state.matches(_diag(category: DiagnosticCategory.orphanAsset)), isTrue);
      expect(
        state.matches(_diag(category: DiagnosticCategory.staleReference)),
        isFalse,
      );
    });

    test('filters by severity', () {
      final state = GovernanceFilterState(
        selectedSeverities: {DiagnosticSeverity.error},
      );
      expect(state.matches(_diag(severity: DiagnosticSeverity.error)), isTrue);
      expect(state.matches(_diag(severity: DiagnosticSeverity.warning)), isFalse);
    });

    test('filters by both category and severity', () {
      final state = GovernanceFilterState(
        selectedCategories: {DiagnosticCategory.proofGap},
        selectedSeverities: {DiagnosticSeverity.error},
      );
      expect(
        state.matches(_diag(
          category: DiagnosticCategory.proofGap,
          severity: DiagnosticSeverity.error,
        )),
        isTrue,
      );
      // Wrong category
      expect(
        state.matches(_diag(
          category: DiagnosticCategory.orphanAsset,
          severity: DiagnosticSeverity.error,
        )),
        isFalse,
      );
      // Wrong severity
      expect(
        state.matches(_diag(
          category: DiagnosticCategory.proofGap,
          severity: DiagnosticSeverity.warning,
        )),
        isFalse,
      );
    });

    test('isActive is false when empty', () {
      const state = GovernanceFilterState();
      expect(state.isActive, isFalse);
    });

    test('isActive is true when category filter set', () {
      final state = GovernanceFilterState(
        selectedCategories: {DiagnosticCategory.orphanAsset},
      );
      expect(state.isActive, isTrue);
    });

    test('copyWith clears filters', () {
      final state = GovernanceFilterState(
        selectedCategories: {DiagnosticCategory.orphanAsset},
        selectedSeverities: {DiagnosticSeverity.error},
      );
      final cleared = state.copyWith(
        clearCategories: true,
        clearSeverities: true,
      );
      expect(cleared.selectedCategories, isEmpty);
      expect(cleared.selectedSeverities, isEmpty);
    });
  });

  group('GovernanceIssueFilters', () {
    testWidgets('renders category filter labels', (tester) async {
      await tester.pumpWidget(_wrapInApp(
        GovernanceIssueFilters(
          filterState: const GovernanceFilterState(),
          onFilterChanged: (_) {},
        ),
      ));
      expect(find.text('Orphans'), findsOneWidget);
      expect(find.text('Stale'), findsOneWidget);
      expect(find.text('Proof Gaps'), findsOneWidget);
      expect(find.text('Fan-In'), findsOneWidget);
    });

    testWidgets('renders severity filter labels', (tester) async {
      await tester.pumpWidget(_wrapInApp(
        GovernanceIssueFilters(
          filterState: const GovernanceFilterState(),
          onFilterChanged: (_) {},
        ),
      ));
      expect(find.text('Error'), findsOneWidget);
      expect(find.text('Warning'), findsOneWidget);
      expect(find.text('Info'), findsOneWidget);
    });

    testWidgets('tapping filter chip triggers callback', (tester) async {
      GovernanceFilterState? captured;
      await tester.pumpWidget(_wrapInApp(
        GovernanceIssueFilters(
          filterState: const GovernanceFilterState(),
          onFilterChanged: (state) => captured = state,
        ),
      ));

      await tester.tap(find.text('Orphans'));
      expect(captured, isNotNull);
      expect(
        captured!.selectedCategories,
        contains(DiagnosticCategory.orphanAsset),
      );
    });

    testWidgets('clear all button appears when filters active',
        (tester) async {
      await tester.pumpWidget(_wrapInApp(
        GovernanceIssueFilters(
          filterState: GovernanceFilterState(
            selectedCategories: {DiagnosticCategory.orphanAsset},
          ),
          onFilterChanged: (_) {},
        ),
      ));
      expect(find.text('Clear all filters'), findsOneWidget);
    });

    testWidgets('clear all button hidden when no filters active',
        (tester) async {
      await tester.pumpWidget(_wrapInApp(
        GovernanceIssueFilters(
          filterState: const GovernanceFilterState(),
          onFilterChanged: (_) {},
        ),
      ));
      expect(find.text('Clear all filters'), findsNothing);
    });
  });
}
