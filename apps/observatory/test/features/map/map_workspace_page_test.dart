/// Widget and unit tests for the Map workspace feature.
///
/// Covers:
/// - MapWorkspaceState contract: copyWith, equality, defaults
/// - MapWorkspaceProvider: state mutations, catalog loading
/// - MapWorkspacePage: renders 4 tabs, handles catalog, empty/loading states
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_observatory/app/pages/map_page.dart';
import 'package:warp_prism_observatory/data/models/workspace_graph.dart';
import 'package:warp_prism_observatory/data/models/workspace_snapshot.dart';
import 'package:warp_prism_observatory/data/providers/workspace_providers.dart';
import 'package:warp_prism_observatory/data/repositories/workspace_load_state.dart';
import 'package:warp_prism_observatory/data/services/workspace_graph.dart';
import 'package:warp_prism_observatory/features/map/graph/map_graph_mode.dart';
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

    test(
      'equality includes activeFilters, graph mode, and catalog identity',
      () {
        const base = MapWorkspaceState(
          query: 'harness',
          activeFilters: {'tag:core'},
          activeGraphMode: MapGraphMode.operational,
        );
        const sameFilters = MapWorkspaceState(
          query: 'harness',
          activeFilters: {'tag:core'},
          activeGraphMode: MapGraphMode.operational,
        );
        const differentFilters = MapWorkspaceState(
          query: 'harness',
          activeFilters: {'tag:other'},
          activeGraphMode: MapGraphMode.operational,
        );
        const differentMode = MapWorkspaceState(
          query: 'harness',
          activeFilters: {'tag:core'},
          activeGraphMode: MapGraphMode.containment,
        );

        expect(base, equals(sameFilters));
        expect(base.hashCode, equals(sameFilters.hashCode));
        expect(base, isNot(equals(differentFilters)));
        expect(base, isNot(equals(differentMode)));

        // Same length, different catalog identity must not equal.
        const assetA = WorkspaceAsset(
          id: 'agent:a',
          kind: AssetKind.agent,
          name: 'A',
          path: 'a.md',
        );
        const assetB = WorkspaceAsset(
          id: 'agent:b',
          kind: AssetKind.agent,
          name: 'B',
          path: 'b.md',
        );
        const withA = MapWorkspaceState(catalogAssets: [assetA]);
        const withB = MapWorkspaceState(catalogAssets: [assetB]);
        expect(withA, isNot(equals(withB)));
        expect(withA.catalogAssets.length, withB.catalogAssets.length);
      },
    );

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

    test('syncState merges catalog without wiping interactive UI state', () {
      provider.changeSubview(MapSubview.skills);
      provider.updateQuery('harness');
      provider.toggleFilter('tag:core');
      provider.selectAsset('skill:1');
      provider.changeGraphMode(MapGraphMode.operational);

      const refreshed = WorkspaceAsset(
        id: 'agent:2',
        kind: AssetKind.agent,
        name: 'Agent 2',
        path: 'a2.md',
      );
      provider.syncState(
        const MapWorkspaceState(
          catalogAssets: [refreshed],
          isLoading: false,
          // Parent injects defaults for interactive fields — must not wipe.
          activeSubview: MapSubview.agents,
          query: '',
          activeFilters: {},
        ),
      );

      expect(provider.state.catalogAssets, [refreshed]);
      expect(provider.state.activeSubview, MapSubview.skills);
      expect(provider.state.query, 'harness');
      expect(provider.state.activeFilters, {'tag:core'});
      expect(provider.state.selectedAssetId, 'skill:1');
      expect(provider.state.activeGraphMode, MapGraphMode.operational);
    });

    test('syncState retains graphEdges when incoming edges are null', () {
      const edge = WorkspaceEdge(
        sourceId: 'a',
        targetId: 'b',
        kind: EdgeKind.uses,
      );
      provider.syncState(
        const MapWorkspaceState(
          catalogAssets: [
            WorkspaceAsset(
              id: 'a',
              kind: AssetKind.agent,
              name: 'A',
              path: 'a.md',
            ),
          ],
          graphEdges: [edge],
        ),
      );
      provider.syncState(
        const MapWorkspaceState(
          catalogAssets: [
            WorkspaceAsset(
              id: 'a',
              kind: AssetKind.agent,
              name: 'A',
              path: 'a.md',
            ),
          ],
        ),
      );
      expect(provider.state.graphEdges, [edge]);
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

    const dummyAssets = [
      WorkspaceAsset(
        id: 'agent:1',
        kind: AssetKind.agent,
        name: 'A',
        path: 'a.md',
      ),
      WorkspaceAsset(
        id: 'skill:1',
        kind: AssetKind.skill,
        name: 'S',
        path: 's.md',
      ),
    ];

    testWidgets('renders four tabs: Agents, Skills, Workflows, Graph', (
      tester,
    ) async {
      await tester.pumpWidget(wrapInApp(const MapWorkspacePage()));
      await tester.pump();

      expect(find.text('Agents'), findsOneWidget);
      expect(find.text('Skills'), findsOneWidget);
      expect(find.text('Workflows'), findsOneWidget);
      expect(find.text('Graph'), findsOneWidget);
    });

    testWidgets('shows catalog panel on first tab (Agents)', (tester) async {
      await tester.pumpWidget(
        wrapInApp(
          const MapWorkspacePage(
            initialState: MapWorkspaceState(catalogAssets: dummyAssets),
          ),
        ),
      );
      await tester.pump();

      // The first tab (Agents) should be active by default.
      expect(find.byType(PrismSearchBar), findsWidgets);
    });

    testWidgets('switching tabs shows correct content', (tester) async {
      await tester.pumpWidget(
        wrapInApp(
          const MapWorkspacePage(
            initialState: MapWorkspaceState(catalogAssets: dummyAssets),
          ),
        ),
      );
      await tester.pump();

      // Tap Skills tab — PrismTabBar headers are tappable text labels.
      await tester.tap(find.text('Skills'));
      // Prefer pump over pumpAndSettle to avoid Material ink/shader animation stalls.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      // Should still show catalog panel (search bar)
      expect(find.byType(PrismSearchBar), findsWidgets);

      // Tap Graph tab
      await tester.tap(find.text('Graph'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('No edges in this mode'), findsOneWidget);
    });

    testWidgets('renders with initial state specifying a subview', (
      tester,
    ) async {
      const state = MapWorkspaceState(
        activeSubview: MapSubview.graph,
        catalogAssets: dummyAssets,
      );
      await tester.pumpWidget(
        wrapInApp(const MapWorkspacePage(initialState: state)),
      );
      await tester.pump();

      // Search bar should NOT be shown for Graph; empty-edge panel should.
      expect(find.byType(PrismSearchBar), findsNothing);
      expect(find.text('No edges in this mode'), findsOneWidget);
      // Mode selector remains available for switching projections.
      expect(find.text('Containment'), findsOneWidget);
    });

    testWidgets('empty/loading state renders without errors', (tester) async {
      await tester.pumpWidget(
        wrapInApp(
          const MapWorkspacePage(
            initialState: MapWorkspaceState(isLoading: true),
          ),
        ),
      );
      await tester.pump();

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
      await tester.pump();

      // Should show the asset card via public Prism* API
      expect(find.byType(PrismAssetCard), findsOneWidget);
    });

    testWidgets('error Retry invokes onRetry callback', (tester) async {
      var retried = false;
      await tester.pumpWidget(
        wrapInApp(
          MapWorkspacePage(
            initialState: const MapWorkspaceState(error: 'load failed'),
            onRetry: () => retried = true,
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Retry'), findsOneWidget);
      await tester.tap(find.text('Retry'));
      await tester.pump();
      expect(retried, isTrue);
    });

    testWidgets('empty-family tab shows dedicated empty-family panel', (
      tester,
    ) async {
      // Skills-only corpus on Agents tab → empty family (not no-results).
      await tester.pumpWidget(
        wrapInApp(
          const MapWorkspacePage(
            initialState: MapWorkspaceState(
              activeSubview: MapSubview.agents,
              catalogAssets: [
                WorkspaceAsset(
                  id: 'skill:1',
                  kind: AssetKind.skill,
                  name: 'Only Skill',
                  path: 's.md',
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('No assets in this family'), findsOneWidget);
      expect(find.byType(PrismSearchBar), findsNothing);
    });

    testWidgets(
      'empty-family + active filters shows no-results (not empty-family)',
      (tester) async {
        // Skills-only corpus on Agents with a filter active → no-results UX
        // so Clear filters remains available; empty-family is filter-free only.
        await tester.pumpWidget(
          wrapInApp(
            const MapWorkspacePage(
              initialState: MapWorkspaceState(
                activeSubview: MapSubview.agents,
                catalogAssets: [
                  WorkspaceAsset(
                    id: 'skill:1',
                    kind: AssetKind.skill,
                    name: 'Only Skill',
                    path: 's.md',
                  ),
                ],
                activeFilters: {'tag:core'},
              ),
            ),
          ),
        );
        await tester.pump();

        expect(find.text('No assets in this family'), findsNothing);
        expect(find.text('No matching assets'), findsOneWidget);
        expect(find.text('Clear filters'), findsOneWidget);
      },
    );

    testWidgets(
      'parent inject with value-equal identity still refreshes description',
      (tester) async {
        // WorkspaceAsset.== ignores description; parent still must sync when
        // a new MapWorkspaceState instance is injected (didUpdateWidget).
        const first = WorkspaceAsset(
          id: 'agent:1',
          kind: AssetKind.agent,
          name: 'Agent One',
          path: 'a.md',
          description: 'First description',
        );
        const second = WorkspaceAsset(
          id: 'agent:1',
          kind: AssetKind.agent,
          name: 'Agent One',
          path: 'a.md',
          description: 'Updated description after reload',
        );
        // Prove the equality trap this test guards against.
        expect(first, equals(second));
        expect(
          const MapWorkspaceState(catalogAssets: [first]),
          equals(const MapWorkspaceState(catalogAssets: [second])),
        );

        await tester.pumpWidget(
          wrapInApp(
            const MapWorkspacePage(
              initialState: MapWorkspaceState(catalogAssets: [first]),
            ),
          ),
        );
        await tester.pump();
        expect(find.text('First description'), findsOneWidget);
        expect(find.text('Updated description after reload'), findsNothing);

        await tester.pumpWidget(
          wrapInApp(
            const MapWorkspacePage(
              initialState: MapWorkspaceState(catalogAssets: [second]),
            ),
          ),
        );
        await tester.pump();
        expect(find.text('Updated description after reload'), findsOneWidget);
        expect(find.text('First description'), findsNothing);
      },
    );
  });

  // ===========================================================================
  // MapPageShell — provider override path (Task 0510 path-to-100)
  // ===========================================================================
  group('MapPageShell provider path', () {
    Widget wrapShell({required List<Override> overrides}) {
      return ProviderScope(
        overrides: overrides,
        child: const MaterialApp(home: Scaffold(body: MapPageShell())),
      );
    }

    testWidgets('loading → data hydrates catalog from snapshot', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrapShell(
          overrides: [
            workspaceSnapshotAsyncProvider.overrideWith(
              () => _DelayedMapSnapshotNotifier(),
            ),
            workspaceGraphAsyncProvider.overrideWith(
              () => _EmptyMapGraphNotifier(),
            ),
          ],
        ),
      );

      // First frame: loading state from shell.
      expect(find.text('Loading map data...'), findsWidgets);

      await tester.pumpAndSettle();

      // After load: Agents tab + agent card from snapshot.
      expect(find.text('Agents'), findsOneWidget);
      expect(find.byType(PrismAssetCard), findsOneWidget);
      expect(find.text('Map Agent'), findsOneWidget);
    });

    testWidgets('error surface exposes Retry that invalidates snapshot', (
      tester,
    ) async {
      final notifier = _FlippingErrorMapSnapshotNotifier();
      await tester.pumpWidget(
        wrapShell(
          overrides: [
            workspaceSnapshotAsyncProvider.overrideWith(() => notifier),
            workspaceGraphAsyncProvider.overrideWith(
              () => _EmptyMapGraphNotifier(),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Failed to load map data'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);

      await tester.tap(find.text('Retry'));
      await tester.pump();
      // After invalidate, reload succeeds with empty corpus panel.
      await tester.pumpAndSettle();

      expect(find.text('No assets in workspace'), findsOneWidget);
      expect(notifier.buildCount, greaterThanOrEqualTo(2));
    });
  });
}

class _DelayedMapSnapshotNotifier extends WorkspaceSnapshotAsyncNotifier {
  @override
  Future<WorkspaceLoadState> build() async {
    await Future<void>.delayed(const Duration(milliseconds: 20));
    return WorkspaceLoadState.success(
      rootPath: 'test://map',
      snapshot: WorkspaceSnapshot(
        agents: const [
          WorkspaceAsset(
            id: 'agent:map',
            kind: AssetKind.agent,
            name: 'Map Agent',
            path: 'map.md',
          ),
        ],
        metadata: WorkspaceScanMetadata(
          rootPath: 'test://map',
          scannedAt: DateTime(2026, 7, 18),
        ),
      ),
    );
  }
}

class _EmptyMapGraphNotifier extends WorkspaceGraphAsyncNotifier {
  @override
  Future<WorkspaceGraphResult> build() async =>
      const WorkspaceGraphResult.empty();
}

/// First build throws; subsequent builds return empty success so Retry
/// invalidation can be observed end-to-end through [MapPageShell].
class _FlippingErrorMapSnapshotNotifier extends WorkspaceSnapshotAsyncNotifier {
  int buildCount = 0;

  @override
  Future<WorkspaceLoadState> build() async {
    buildCount++;
    if (buildCount == 1) {
      throw StateError('map boom');
    }
    return const WorkspaceLoadState.empty(rootPath: 'test://map-retry');
  }
}
