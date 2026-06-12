/// Widget and unit tests for the Map workspace feature.
///
/// Covers:
/// - MapWorkspaceState contract: copyWith, equality, defaults
/// - MapWorkspaceProvider: state mutations, catalog loading
/// - MapWorkspacePage: renders 4 tabs, handles catalog, empty/loading states
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_observatory/data/models/workspace_graph.dart';
import 'package:warp_prism_observatory/features/map/map_workspace_state.dart';
import 'package:warp_prism_observatory/features/map/map_workspace_provider.dart';
import 'package:warp_prism_observatory/features/map/map_workspace_page.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

void main() {
  // ===========================================================================
  // MapWorkspaceState contract
  // ===========================================================================
  group('MapWorkspaceState', () {
    test('defaults to agents subview, empty query, no selection', () {
      const state = MapWorkspaceState();
      expect(state.activeSubview, MapSubview.agents);
      expect(state.query, '');
      expect(state.activeFilters, isEmpty);
      expect(state.selectedAssetId, isNull);
      expect(state.isLoading, false);
      expect(state.error, isNull);
      expect(state.hasSelection, false);
      expect(state.hasFilters, false);
      expect(state.catalogAssets, isEmpty);
    });

    test('copyWith overrides only specified fields', () {
      const original = MapWorkspaceState();
      final copied = original.copyWith(
        activeSubview: MapSubview.graph,
        query: 'test',
      );

      expect(copied.activeSubview, MapSubview.graph);
      expect(copied.query, 'test');
      // These should be unchanged
      expect(copied.selectedAssetId, isNull);
      expect(copied.isLoading, false);
      expect(copied.catalogAssets, isEmpty);
    });

    test('copyWith clearSelectedAsset sets selection to null', () {
      const original = MapWorkspaceState(selectedAssetId: 'asset:1');
      final cleared = original.copyWith(clearSelectedAsset: true);
      expect(cleared.selectedAssetId, isNull);
    });

    test('copyWith clearError sets error to null', () {
      const original = MapWorkspaceState(error: 'some error');
      final cleared = original.copyWith(clearError: true);
      expect(cleared.error, isNull);
    });

    test('equality is based on key fields', () {
      const a = MapWorkspaceState(activeSubview: MapSubview.skills);
      const b = MapWorkspaceState(activeSubview: MapSubview.skills);
      const c = MapWorkspaceState(activeSubview: MapSubview.graph);

      expect(a, equals(b));
      expect(a, isNot(equals(c)));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('assetsForTab returns correct family per tab', () {
      final assets = [
        const WorkspaceAsset(
          id: 'agent:1',
          kind: AssetKind.agent,
          name: 'Agent 1',
          path: 'a.md',
        ),
        const WorkspaceAsset(
          id: 'skill:1',
          kind: AssetKind.skill,
          name: 'Skill 1',
          path: 's.md',
        ),
        const WorkspaceAsset(
          id: 'workflow:1',
          kind: AssetKind.workflow,
          name: 'Workflow 1',
          path: 'w.md',
        ),
      ];

      final agentsState = MapWorkspaceState(
        activeSubview: MapSubview.agents,
        catalogAssets: assets,
      );
      expect(agentsState.assetsForTab.length, 1);
      expect(agentsState.assetsForTab.first.kind, AssetKind.agent);

      final skillsState = MapWorkspaceState(
        activeSubview: MapSubview.skills,
        catalogAssets: assets,
      );
      expect(skillsState.assetsForTab.length, 1);
      expect(skillsState.assetsForTab.first.kind, AssetKind.skill);

      final graphState = MapWorkspaceState(
        activeSubview: MapSubview.graph,
        catalogAssets: assets,
      );
      expect(graphState.assetsForTab.length, 3);
    });
  });

  // ===========================================================================
  // MapWorkspaceProvider
  // ===========================================================================
  group('MapWorkspaceProvider', () {
    late MapWorkspaceProvider provider;

    setUp(() {
      provider = MapWorkspaceProvider();
    });

    tearDown(() {
      provider.dispose();
    });

    test('initial state is default MapWorkspaceState', () {
      expect(provider.state, const MapWorkspaceState());
    });

    test('changeSubview updates activeSubview and clears selection', () {
      provider.selectAsset('asset:1');
      provider.changeSubview(MapSubview.workflows);

      expect(provider.state.activeSubview, MapSubview.workflows);
      expect(provider.state.selectedAssetId, isNull);
    });

    test('changeSubview with same value is a no-op', () {
      final before = provider.state;
      provider.changeSubview(MapSubview.agents); // same as default
      expect(provider.state, same(before));
    });

    test('updateQuery updates query', () {
      provider.updateQuery('harness');
      expect(provider.state.query, 'harness');
    });

    test('toggleFilter adds and removes filters', () {
      provider.toggleFilter('super-skill');
      expect(provider.state.activeFilters, {'super-skill'});
      expect(provider.state.hasFilters, true);

      provider.toggleFilter('super-skill');
      expect(provider.state.activeFilters, isEmpty);
      expect(provider.state.hasFilters, false);
    });

    test('clearFilters removes all filters and query', () {
      provider.toggleFilter('f1');
      provider.toggleFilter('f2');
      provider.updateQuery('test');
      provider.clearFilters();

      expect(provider.state.activeFilters, isEmpty);
      expect(provider.state.query, '');
    });

    test('selectAsset and deselectAsset', () {
      provider.selectAsset('asset:1');
      expect(provider.state.selectedAssetId, 'asset:1');
      expect(provider.state.hasSelection, true);

      provider.deselectAsset();
      expect(provider.state.selectedAssetId, isNull);
      expect(provider.state.hasSelection, false);
    });

    test('setLoading and clearError', () {
      provider.setLoading(true);
      expect(provider.state.isLoading, true);

      provider.setError('oops');
      expect(provider.state.error, 'oops');

      provider.clearError();
      expect(provider.state.error, isNull);
    });

    test('loadAssets sets catalog and clears loading', () {
      provider.setLoading(true);
      provider.loadAssets([
        const WorkspaceAsset(
          id: 'agent:1',
          kind: AssetKind.agent,
          name: 'Agent 1',
          path: 'a.md',
        ),
      ]);

      expect(provider.state.catalogAssets.length, 1);
      expect(provider.state.isLoading, isFalse);
    });

    test('stateStream emits state changes', () async {
      final states = <MapWorkspaceState>[];
      final sub = provider.stateStream.listen(states.add);

      provider.changeSubview(MapSubview.skills);
      provider.updateQuery('test');

      await Future<void>.delayed(Duration.zero);
      await sub.cancel();

      expect(states, hasLength(2));
      expect(states[0].activeSubview, MapSubview.skills);
      expect(states[1].query, 'test');
    });
  });

  // ===========================================================================
  // MapWorkspacePage widget
  // ===========================================================================
  group('MapWorkspacePage widget', () {
    Widget wrapInApp(Widget child) {
      return MaterialApp(home: Scaffold(body: child));
    }

    testWidgets('renders four tabs: Agents, Skills, Workflows, Graph', (
      tester,
    ) async {
      await tester.pumpWidget(wrapInApp(const MapWorkspacePage()));

      expect(find.text('Agents'), findsOneWidget);
      expect(find.text('Skills'), findsOneWidget);
      expect(find.text('Workflows'), findsOneWidget);
      expect(find.text('Graph'), findsOneWidget);
    });

    testWidgets('shows catalog panel on first tab (Agents)', (tester) async {
      await tester.pumpWidget(wrapInApp(const MapWorkspacePage()));

      // The first tab (Agents) should be active by default.
      // With empty assets, the search bar should still be visible.
      expect(find.byType(DSSearchBar), findsWidgets);
    });

    testWidgets('switching tabs shows correct content', (tester) async {
      await tester.pumpWidget(wrapInApp(const MapWorkspacePage()));

      // Tap Skills tab
      await tester.tap(find.text('Skills'));
      await tester.pumpAndSettle();
      // Should still show catalog panel (search bar)
      expect(find.byType(DSSearchBar), findsWidgets);

      // Tap Graph tab
      await tester.tap(find.text('Graph'));
      await tester.pumpAndSettle();
      expect(find.text('Asset Graph'), findsOneWidget);
    });

    testWidgets('renders with initial state specifying a subview', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrapInApp(
          const MapWorkspacePage(
            initialState: MapWorkspaceState(activeSubview: MapSubview.graph),
          ),
        ),
      );

      // Graph tab content should be visible
      expect(find.text('Asset Graph'), findsWidgets);
    });

    testWidgets('empty/loading state renders without errors', (tester) async {
      await tester.pumpWidget(
        wrapInApp(
          const MapWorkspacePage(
            initialState: MapWorkspaceState(isLoading: true),
          ),
        ),
      );

      // Should render without throwing
      expect(find.text('Agents'), findsOneWidget);
    });

    testWidgets('renders with catalog assets', (tester) async {
      final assets = [
        const WorkspaceAsset(
          id: 'agent:1',
          kind: AssetKind.agent,
          name: 'Test Agent',
          path: 'a.md',
          description: 'A test agent',
        ),
      ];

      await tester.pumpWidget(
        wrapInApp(
          MapWorkspacePage(
            initialState: MapWorkspaceState(catalogAssets: assets),
          ),
        ),
      );

      // Should show the asset card
      expect(find.byType(DSAssetCard), findsOneWidget);
    });
  });
}
