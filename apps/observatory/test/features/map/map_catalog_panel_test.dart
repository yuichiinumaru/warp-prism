/// Tests for the Map catalog panel — tabs, search, filters, and zero results.
///
/// Covers:
/// - Catalog panel renders search bar, filter chips, and asset cards
/// - Tab changes show only assets of the correct family
/// - Search query filters assets deterministically
/// - Filter chips alter visible card set
/// - No-results state renders when filters eliminate all assets
/// - Clear filters restores full list
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_observatory/data/models/workspace_graph.dart';
import 'package:warp_prism_observatory/features/map/map_workspace_state.dart';
import 'package:warp_prism_observatory/features/map/map_workspace_provider.dart';
import 'package:warp_prism_observatory/features/map/widgets/map_catalog_panel.dart';
import 'package:warp_prism_observatory/features/map/widgets/map_no_results_state.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

/// Synthetic test assets for catalog testing.
List<WorkspaceAsset> _testAssets = [
  const WorkspaceAsset(
    id: 'agent:orchestrator',
    kind: AssetKind.agent,
    name: 'Architect Orchestrator',
    path: '.agents/agents/orchestrator.md',
    description: 'Main orchestration agent',
    canonicality: Canonicality.parentCanonical,
    tags: ['core', 'orchestration'],
    edges: [],
  ),
  const WorkspaceAsset(
    id: 'agent:reviewer',
    kind: AssetKind.agent,
    name: 'Code Reviewer',
    path: '.agents/agents/reviewer.md',
    description: 'Automated code review agent',
    canonicality: Canonicality.parentCanonical,
    tags: ['review'],
    edges: [
      WorkspaceEdge(sourceId: 'agent:reviewer', targetId: 'skill:review', kind: EdgeKind.uses),
    ],
  ),
  const WorkspaceAsset(
    id: 'skill:harness',
    kind: AssetKind.skill,
    name: 'Test Harness',
    path: '.agents/skills/harness.md',
    description: 'Testing framework skill',
    canonicality: Canonicality.parentCanonical,
    tags: ['testing', 'core'],
    triggers: ['run tests', 'test harness'],
    edges: [],
  ),
  const WorkspaceAsset(
    id: 'skill:review',
    kind: AssetKind.skill,
    name: 'Code Review',
    path: '.agents/skills/review.md',
    description: 'Review automation skill',
    canonicality: Canonicality.childLocal,
    tags: ['review'],
    triggers: ['review code'],
    edges: [],
  ),
  const WorkspaceAsset(
    id: 'workflow:ci',
    kind: AssetKind.workflow,
    name: 'CI Pipeline',
    path: '.agents/workflows/ci.md',
    description: 'Continuous integration workflow',
    canonicality: Canonicality.parentCanonical,
    tags: ['ci', 'automation'],
    edges: [
      WorkspaceEdge(sourceId: 'workflow:ci', targetId: 'skill:harness', kind: EdgeKind.dependsOn),
    ],
  ),
  const WorkspaceAsset(
    id: 'workflow:deploy',
    kind: AssetKind.workflow,
    name: 'Deploy Workflow',
    path: '.agents/workflows/deploy.md',
    description: 'Deployment automation',
    canonicality: Canonicality.mock,
    tags: ['deploy'],
    edges: [],
  ),
];

void main() {
  Widget wrapInApp(Widget child) {
    return MaterialApp(home: Scaffold(body: SizedBox(width: 800, height: 600, child: child)));
  }

  // ===========================================================================
  // MapWorkspaceState catalog filtering
  // ===========================================================================
  group('MapWorkspaceState - catalog filtering', () {
    test('assetsForTab returns only agents for agents subview', () {
      final state = MapWorkspaceState(
        activeSubview: MapSubview.agents,
        catalogAssets: _testAssets,
      );

      expect(state.assetsForTab.length, 2);
      expect(state.assetsForTab.every((a) => a.kind == AssetKind.agent), isTrue);
    });

    test('assetsForTab returns skills and subskills for skills subview', () {
      final state = MapWorkspaceState(
        activeSubview: MapSubview.skills,
        catalogAssets: _testAssets,
      );

      expect(state.assetsForTab.length, 2);
      expect(
        state.assetsForTab.every(
          (a) => a.kind == AssetKind.skill || a.kind == AssetKind.subskill,
        ),
        isTrue,
      );
    });

    test('assetsForTab returns only workflows for workflows subview', () {
      final state = MapWorkspaceState(
        activeSubview: MapSubview.workflows,
        catalogAssets: _testAssets,
      );

      expect(state.assetsForTab.length, 2);
      expect(state.assetsForTab.every((a) => a.kind == AssetKind.workflow), isTrue);
    });

    test('assetsForTab returns all assets for graph subview', () {
      final state = MapWorkspaceState(
        activeSubview: MapSubview.graph,
        catalogAssets: _testAssets,
      );

      expect(state.assetsForTab.length, _testAssets.length);
    });

    test('filteredAssets applies query to name', () {
      final state = MapWorkspaceState(
        activeSubview: MapSubview.agents,
        catalogAssets: _testAssets,
        query: 'orchestrator',
      );

      expect(state.filteredAssets.length, 1);
      expect(state.filteredAssets.first.name, 'Architect Orchestrator');
    });

    test('filteredAssets applies query to description', () {
      final state = MapWorkspaceState(
        activeSubview: MapSubview.skills,
        catalogAssets: _testAssets,
        query: 'testing',
      );

      expect(state.filteredAssets.length, 1);
      expect(state.filteredAssets.first.name, 'Test Harness');
    });

    test('filteredAssets is case-insensitive', () {
      final state = MapWorkspaceState(
        activeSubview: MapSubview.agents,
        catalogAssets: _testAssets,
        query: 'ORCHESTRATOR',
      );

      expect(state.filteredAssets.length, 1);
    });

    test('filteredAssets applies canonicality filter', () {
      final state = MapWorkspaceState(
        activeSubview: MapSubview.workflows,
        catalogAssets: _testAssets,
        activeFilters: {'can:mock'},
      );

      expect(state.filteredAssets.length, 1);
      expect(state.filteredAssets.first.name, 'Deploy Workflow');
    });

    test('filteredAssets applies tag filter', () {
      final state = MapWorkspaceState(
        activeSubview: MapSubview.agents,
        catalogAssets: _testAssets,
        activeFilters: {'tag:review'},
      );

      expect(state.filteredAssets.length, 1);
      expect(state.filteredAssets.first.name, 'Code Reviewer');
    });

    test('filteredAssets applies both query and filter', () {
      final state = MapWorkspaceState(
        activeSubview: MapSubview.skills,
        catalogAssets: _testAssets,
        query: 'review',
        activeFilters: {'can:child-local'},
      );

      expect(state.filteredAssets.length, 1);
      expect(state.filteredAssets.first.name, 'Code Review');
    });

    test('filteredAssets returns empty when no match', () {
      final state = MapWorkspaceState(
        activeSubview: MapSubview.agents,
        catalogAssets: _testAssets,
        query: 'nonexistent',
      );

      expect(state.filteredAssets, isEmpty);
    });

    test('hasFilters returns true when query is active', () {
      const state = MapWorkspaceState(query: 'test');
      expect(state.hasFilters, isTrue);
    });

    test('hasFilters returns true when chips are active', () {
      const state = MapWorkspaceState(activeFilters: {'tag:core'});
      expect(state.hasFilters, isTrue);
    });
  });

  // ===========================================================================
  // MapWorkspaceProvider - catalog operations
  // ===========================================================================
  group('MapWorkspaceProvider - catalog', () {
    late MapWorkspaceProvider provider;

    setUp(() {
      provider = MapWorkspaceProvider();
    });

    tearDown(() {
      provider.dispose();
    });

    test('loadAssets sets catalog assets and clears loading', () {
      provider.setLoading(true);
      provider.loadAssets(_testAssets);

      expect(provider.state.catalogAssets.length, _testAssets.length);
      expect(provider.state.isLoading, isFalse);
    });

    test('loadAssets clears previous error', () {
      provider.setError('some error');
      provider.loadAssets(_testAssets);

      expect(provider.state.error, isNull);
    });

    test('updateQuery affects filteredAssets', () {
      provider.loadAssets(_testAssets);
      provider.updateQuery('orchestrator');

      expect(provider.state.query, 'orchestrator');
      // filteredAssets is derived from state, so we verify via state
      expect(provider.state.filteredAssets.length, 1);
    });

    test('toggleFilter affects filteredAssets', () {
      provider.loadAssets(_testAssets);
      provider.changeSubview(MapSubview.workflows);
      provider.toggleFilter('can:mock');

      expect(provider.state.filteredAssets.length, 1);
      expect(provider.state.filteredAssets.first.name, 'Deploy Workflow');
    });

    test('clearFilters resets query and activeFilters', () {
      provider.loadAssets(_testAssets);
      provider.updateQuery('test');
      provider.toggleFilter('tag:core');
      provider.clearFilters();

      expect(provider.state.query, '');
      expect(provider.state.activeFilters, isEmpty);
    });
  });

  // ===========================================================================
  // MapCatalogPanel widget
  // ===========================================================================
  group('MapCatalogPanel widget', () {
    testWidgets('renders search bar', (tester) async {
      final assets = _testAssets
          .where((a) => a.kind == AssetKind.agent)
          .toList();

      await tester.pumpWidget(wrapInApp(
        MapCatalogPanel(
          activeTab: MapCatalogTab.agents,
          filteredAssets: assets,
          allAssets: assets,
        ),
      ));

      expect(find.byType(DSSearchBar), findsOneWidget);
    });

    testWidgets('renders asset cards', (tester) async {
      final assets = _testAssets
          .where((a) => a.kind == AssetKind.agent)
          .toList();

      await tester.pumpWidget(wrapInApp(
        MapCatalogPanel(
          activeTab: MapCatalogTab.agents,
          filteredAssets: assets,
          allAssets: assets,
        ),
      ));

      expect(find.byType(DSAssetCard), findsNWidgets(2));
    });

    testWidgets('renders result count', (tester) async {
      final assets = _testAssets
          .where((a) => a.kind == AssetKind.agent)
          .toList();

      await tester.pumpWidget(wrapInApp(
        MapCatalogPanel(
          activeTab: MapCatalogTab.agents,
          filteredAssets: assets,
          allAssets: assets,
        ),
      ));

      expect(find.text('2 results'), findsOneWidget);
    });

    testWidgets('renders no-results state when filteredAssets is empty',
        (tester) async {
      await tester.pumpWidget(wrapInApp(
        MapCatalogPanel(
          activeTab: MapCatalogTab.agents,
          filteredAssets: const [],
          allAssets: _testAssets
              .where((a) => a.kind == AssetKind.agent)
              .toList(),
          query: 'nonexistent',
        ),
      ));

      expect(find.byType(MapNoResultsState), findsOneWidget);
      expect(find.text('No results for "nonexistent"'), findsOneWidget);
    });

    testWidgets('renders filter chips when tags available', (tester) async {
      final assets = _testAssets
          .where((a) => a.kind == AssetKind.agent)
          .toList();

      await tester.pumpWidget(wrapInApp(
        MapCatalogPanel(
          activeTab: MapCatalogTab.agents,
          filteredAssets: assets,
          allAssets: assets,
        ),
      ));

      expect(find.byType(DSFilterChipGroup), findsOneWidget);
    });

    testWidgets('renders singular result count for 1 result', (tester) async {
      final assets = [_testAssets.first]; // 1 agent

      await tester.pumpWidget(wrapInApp(
        MapCatalogPanel(
          activeTab: MapCatalogTab.agents,
          filteredAssets: assets,
          allAssets: assets,
        ),
      ));

      expect(find.text('1 result'), findsOneWidget);
    });
  });

  // ===========================================================================
  // MapNoResultsState widget
  // ===========================================================================
  group('MapNoResultsState widget', () {
    testWidgets('shows message for query with no results', (tester) async {
      await tester.pumpWidget(wrapInApp(
        const MapNoResultsState(query: 'nonexistent'),
      ));

      expect(find.text('No results for "nonexistent"'), findsOneWidget);
      expect(find.text('Clear filters'), findsOneWidget);
    });

    testWidgets('shows message for filters with no results', (tester) async {
      await tester.pumpWidget(wrapInApp(
        const MapNoResultsState(activeFilters: {'tag:core'}),
      ));

      expect(find.text('No matching assets'), findsOneWidget);
    });

    testWidgets('shows message for combined query and filters', (tester) async {
      await tester.pumpWidget(wrapInApp(
        const MapNoResultsState(
          query: 'test',
          activeFilters: {'can:canonical'},
        ),
      ));

      expect(find.text('No results for "test"'), findsOneWidget);
    });

    testWidgets('clear filters callback fires', (tester) async {
      var cleared = false;
      await tester.pumpWidget(wrapInApp(
        MapNoResultsState(
          query: 'test',
          onClearFilters: () => cleared = true,
        ),
      ));

      await tester.tap(find.text('Clear filters'));
      expect(cleared, isTrue);
    });

    testWidgets('shows generic message when no query or filters', (tester) async {
      await tester.pumpWidget(wrapInApp(
        const MapNoResultsState(),
      ));

      expect(find.text('No assets to display'), findsOneWidget);
    });
  });
}
