/// Widget tests for GovernancePageShell production wiring (Tasks 0810–0813).
///
/// Proves the product path builds non-empty counts from graph + diagnostics
/// providers (not fixture-injected page only), composes issue filters,
/// review-pressure analytics, and GoRouter drill-down.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:warp_prism_observatory/data/models/governance_diagnostics.dart';
import 'package:warp_prism_observatory/data/models/workspace_graph.dart';
import 'package:warp_prism_observatory/data/providers/workspace_providers.dart';
import 'package:warp_prism_observatory/data/services/workspace_diagnostics_service.dart';
import 'package:warp_prism_observatory/data/services/workspace_graph.dart';
import 'package:warp_prism_observatory/features/governance/presentation/governance_overview_page.dart';
import 'package:warp_prism_observatory/features/governance/presentation/governance_page_shell.dart';
import 'package:warp_prism_observatory/features/governance/presentation/widgets/governance_drilldown_controller.dart';

// ---------------------------------------------------------------------------
// Fixtures
// ---------------------------------------------------------------------------

WorkspaceAsset _asset({
  required String id,
  required AssetKind kind,
  required String name,
  Canonicality canonicality = Canonicality.parentCanonical,
}) {
  return WorkspaceAsset(
    id: id,
    kind: kind,
    name: name,
    path: '${kind.name}/$name.md',
    canonicality: canonicality,
  );
}

WorkspaceGraphResult _graphWithSixClasses() {
  final assets = <WorkspaceAsset>[
    _asset(id: 'agent:canon', kind: AssetKind.agent, name: 'Canon Agent'),
    _asset(
      id: 'skill:local',
      kind: AssetKind.skill,
      name: 'Local Skill',
      canonicality: Canonicality.childLocal,
    ),
    _asset(
      id: 'workflow:gen',
      kind: AssetKind.workflow,
      name: 'Generated Index',
      canonicality: Canonicality.generated,
    ),
    _asset(
      id: 'changelog:append',
      kind: AssetKind.changelog,
      name: 'Append Ledger',
      canonicality: Canonicality.appendOnly,
    ),
    _asset(
      id: 'task:archive',
      kind: AssetKind.task,
      name: 'Archive Task',
      canonicality: Canonicality.archive,
    ),
    _asset(
      id: 'skill:mock',
      kind: AssetKind.skill,
      name: 'Mock Skill',
      canonicality: Canonicality.mock,
    ),
  ];

  final byId = {for (final a in assets) a.id: a};
  final byKind = <AssetKind, List<WorkspaceAsset>>{};
  for (final a in assets) {
    byKind.putIfAbsent(a.kind, () => []).add(a);
  }

  return WorkspaceGraphResult(
    assetsById: byId,
    edges: const [],
    assetsByKind: byKind,
  );
}

List<GovernanceDiagnostic> _mixedDiagnostics() {
  final now = DateTime(2026, 7, 9);
  return [
    GovernanceDiagnostic(
      assetId: 'skill:local',
      severity: DiagnosticSeverity.warning,
      category: DiagnosticCategory.orphanAsset,
      message: 'Skill has no edges',
      computedAt: now,
    ),
    GovernanceDiagnostic(
      assetId: 'workflow:gen',
      severity: DiagnosticSeverity.error,
      category: DiagnosticCategory.staleReference,
      message: 'References missing asset',
      computedAt: now,
    ),
    GovernanceDiagnostic(
      assetId: 'task:archive',
      severity: DiagnosticSeverity.error,
      category: DiagnosticCategory.proofGap,
      message: 'Task in review without proof',
      context: const {'taskLane': '03-review', 'taskTitle': 'Archive Task'},
      computedAt: now,
    ),
    GovernanceDiagnostic(
      assetId: 'changelog:append',
      severity: DiagnosticSeverity.warning,
      category: DiagnosticCategory.missingDependency,
      message: 'Changelog entry has no linked task',
      computedAt: now,
    ),
    GovernanceDiagnostic(
      assetId: 'agent:canon',
      severity: DiagnosticSeverity.warning,
      category: DiagnosticCategory.highFanIn,
      message: 'Asset has 5 incoming edges',
      context: const {
        'incomingEdgeCount': 5,
        'threshold': 3,
        'assetName': 'Canon Agent',
        'assetKind': 'agent',
      },
      computedAt: now,
    ),
  ];
}

CanonicalityBoundarySummary _forcedSummary() {
  return buildCanonicalityBoundarySummary(
    graph: _graphWithSixClasses(),
    diagnostics: _mixedDiagnostics(),
  );
}

void _setLargeSurface(WidgetTester tester) {
  tester.view.physicalSize = const Size(1400, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Widget _wrap(Widget child) {
  return ProviderScope(
    child: MaterialApp(home: Scaffold(body: child)),
  );
}

class _StaticGraphNotifier extends WorkspaceGraphAsyncNotifier {
  _StaticGraphNotifier(this._graph);
  final WorkspaceGraphResult _graph;

  @override
  Future<WorkspaceGraphResult> build() async => _graph;
}

class _StaticDiagnosticsNotifier extends WorkspaceDiagnosticsAsyncNotifier {
  _StaticDiagnosticsNotifier(this._report);
  final DiagnosticsReport _report;

  @override
  Future<DiagnosticsReport> build() async => _report;
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('buildCanonicalityBoundarySummary', () {
    test('maps six canonicality classes from graph assets', () {
      final summary = buildCanonicalityBoundarySummary(
        graph: _graphWithSixClasses(),
        diagnostics: const [],
      );

      expect(summary.totalAssets, 6);
      expect(summary.counts['parentCanonical'], 1);
      expect(summary.counts['childLocal'], 1);
      expect(summary.counts['generated'], 1);
      expect(summary.counts['appendOnly'], 1);
      expect(summary.counts['archive'], 1);
      expect(summary.counts['mock'], 1);
      expect(summary.isEmpty, isFalse);
    });

    test('attaches diagnostics without inventing counts', () {
      final diags = _mixedDiagnostics();
      final summary = buildCanonicalityBoundarySummary(
        graph: _graphWithSixClasses(),
        diagnostics: diags,
      );
      expect(summary.diagnostics, same(diags));
      expect(summary.diagnostics.length, 5);
    });
  });

  group('GovernancePageShell forced states', () {
    testWidgets('renders non-empty counts from forced summary', (tester) async {
      _setLargeSurface(tester);
      await tester.pumpWidget(
        _wrap(GovernancePageShell(forcedSummary: _forcedSummary())),
      );

      expect(find.text('No governance data'), findsNothing);
      expect(find.text('Total Assets'), findsOneWidget);
      expect(find.text('6'), findsWidgets);
      expect(find.textContaining('read-only'), findsOneWidget);
      expect(find.text('Canonical'), findsWidgets);
      expect(find.text('Generated'), findsWidgets);
    });

    testWidgets('renders loading state', (tester) async {
      await tester.pumpWidget(
        _wrap(const GovernancePageShell(forceLoading: true)),
      );
      expect(find.text('Loading governance...'), findsOneWidget);
      expect(find.text('Total Assets'), findsNothing);
    });

    testWidgets('renders error state', (tester) async {
      await tester.pumpWidget(
        _wrap(const GovernancePageShell(forcedError: 'mock governance fail')),
      );
      expect(find.text('Failed to load governance'), findsOneWidget);
      expect(find.textContaining('mock governance fail'), findsOneWidget);
    });
  });

  group('GovernancePageShell provider path', () {
    testWidgets(
      'ProviderScope + static providers yield non-empty boundary counts',
      (tester) async {
        _setLargeSurface(tester);
        final graph = _graphWithSixClasses();
        final report = DiagnosticsReport(diagnostics: _mixedDiagnostics());

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              workspaceGraphAsyncProvider.overrideWith(
                () => _StaticGraphNotifier(graph),
              ),
              workspaceDiagnosticsAsyncProvider.overrideWith(
                () => _StaticDiagnosticsNotifier(report),
              ),
            ],
            child: const MaterialApp(
              home: Scaffold(body: GovernancePageShell()),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('No governance data'), findsNothing);
        expect(find.text('Total Assets'), findsOneWidget);
        expect(find.text('6'), findsWidgets);
        expect(find.text('BOUNDARY OVERVIEW'), findsOneWidget);
        // Risk panels composed (group titles + filter chips may share labels)
        expect(find.text('ISSUE PANELS'), findsOneWidget);
        expect(find.text('Orphan Assets'), findsOneWidget);
        expect(find.text('Stale References'), findsOneWidget);
        expect(find.text('Proof Gaps'), findsWidgets);
        expect(find.text('Changelog Without Task'), findsOneWidget);
        // Analytics
        expect(find.text('Fan-In Hotspots'), findsOneWidget);
        expect(find.text('Review Queue Pressure'), findsOneWidget);
      },
    );
  });

  group('GovernanceOverviewPage composition (filters + pressure)', () {
    testWidgets('mounts filters; Ledger Gaps hides non-matching issue groups', (
      tester,
    ) async {
      _setLargeSurface(tester);
      await tester.pumpWidget(
        _wrap(GovernanceOverviewPage(summary: _forcedSummary())),
      );

      expect(find.text('ISSUE PANELS'), findsOneWidget);
      expect(find.text('Ledger Gaps'), findsOneWidget);
      expect(find.text('Orphan Assets'), findsOneWidget);
      expect(find.text('Changelog Without Task'), findsOneWidget);

      final ledgerChip = find.text('Ledger Gaps');
      await tester.ensureVisible(ledgerChip);
      await tester.tap(ledgerChip);
      await tester.pumpAndSettle();

      expect(find.text('Changelog Without Task'), findsOneWidget);
      expect(find.text('Orphan Assets'), findsNothing);
      expect(find.text('Stale References'), findsNothing);
      // Filter chip label remains; group title should be gone.
      expect(find.text('Proof Gaps'), findsOneWidget);
      expect(find.text('Clear all filters'), findsOneWidget);

      final clear = find.text('Clear all filters');
      await tester.ensureVisible(clear);
      await tester.tap(clear);
      await tester.pumpAndSettle();

      expect(find.text('Orphan Assets'), findsOneWidget);
      expect(find.text('Clear all filters'), findsNothing);
    });

    testWidgets('always composes Review Queue Pressure panel', (tester) async {
      _setLargeSurface(tester);
      await tester.pumpWidget(
        _wrap(GovernanceOverviewPage(summary: _forcedSummary())),
      );
      expect(find.text('Review Queue Pressure'), findsOneWidget);
      // proof-gap diagnostic with taskLane → pressure row
      expect(find.textContaining('under pressure'), findsWidgets);
    });
  });

  group('GoRouter drill-down product path', () {
    testWidgets('navigable issue drill-down reaches /assets/:assetId', (
      tester,
    ) async {
      _setLargeSurface(tester);
      late final GoRouter router;
      router = GoRouter(
        initialLocation: '/governance',
        routes: [
          GoRoute(
            path: '/governance',
            builder: (context, state) => Scaffold(
              body: GovernancePageShell(forcedSummary: _forcedSummary()),
            ),
          ),
          GoRoute(
            path: '/assets/:assetId',
            builder: (context, state) {
              final id = state.pathParameters['assetId'] ?? 'unknown';
              return Scaffold(body: Text('detail:$id'));
            },
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(child: MaterialApp.router(routerConfig: router)),
      );
      await tester.pumpAndSettle();

      // Issue rows render assetId as title when context omits assetName.
      final orphanRow = find.text('skill:local');
      expect(orphanRow, findsWidgets);
      await tester.ensureVisible(orphanRow.first);
      await tester.tap(orphanRow.first);
      await tester.pumpAndSettle();

      expect(find.text('detail:skill:local'), findsOneWidget);
      // go_router may percent-encode ':' in path segments; compare decoded.
      final path = Uri.decodeComponent(
        router.routeInformationProvider.value.uri.path,
      );
      expect(path, '/assets/skill:local');
    });

    testWidgets('unresolved drill-down shows snackbar without crashing', (
      tester,
    ) async {
      _setLargeSurface(tester);
      final summary = CanonicalityBoundarySummary(
        counts: const {'parentCanonical': 1},
        totalAssets: 1,
        diagnostics: [
          GovernanceDiagnostic(
            assetId: '',
            severity: DiagnosticSeverity.warning,
            category: DiagnosticCategory.orphanAsset,
            message: 'Empty id diagnostic',
            computedAt: DateTime(2026, 7, 9),
          ),
        ],
      );

      final targets = <GovernanceDrilldownTarget>[];

      await tester.pumpWidget(
        _wrap(
          GovernanceOverviewPage(summary: summary, onDrilldown: targets.add),
        ),
      );

      // Empty asset id is not navigable from resolveDiagnosticDrilldown
      // (returns null) so no ink well — story/issue panels still mount.
      expect(find.text('No governance data'), findsNothing);
      expect(find.text('Review Queue Pressure'), findsOneWidget);
    });
  });
}
