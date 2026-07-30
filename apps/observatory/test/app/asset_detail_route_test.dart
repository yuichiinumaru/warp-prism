/// Tests for the asset detail route contract and selection controller.
///
/// Covers:
/// - Canonical /assets/:assetId route shape
/// - Deep-link restoration from URL
/// - Unknown/empty asset fallback
/// - Selection synchronization on data refresh
/// - Close/back navigation
/// - Legacy /asset/:id redirect
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:warp_prism_observatory/app/asset_selection_controller.dart';
import 'package:warp_prism_observatory/app/pages/asset_detail_page.dart';
import 'package:warp_prism_observatory/data/providers/workspace_providers.dart';
import 'package:warp_prism_observatory/data/services/workspace_graph.dart';
import 'package:warp_prism_observatory/data/models/workspace_graph.dart';
import 'package:warp_prism_observatory/features/asset_detail/presentation/asset_detail_view.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

const _sampleAsset = WorkspaceAsset(
  id: 'agent:test-agent',
  kind: AssetKind.agent,
  name: 'Test Agent',
  path: 'agents/test-agent.md',
  description: 'A test agent for unit testing',
);

const _sampleGraph = WorkspaceGraphResult(
  assetsById: {
    'agent:test-agent': _sampleAsset,
    'skill:test-skill': WorkspaceAsset(
      id: 'skill:test-skill',
      kind: AssetKind.skill,
      name: 'Test Skill',
      path: 'skills/test-skill.md',
    ),
  },
  edges: [
    WorkspaceEdge(
      sourceId: 'agent:test-agent',
      targetId: 'skill:test-skill',
      kind: EdgeKind.uses,
    ),
  ],
  assetsByKind: {
    AssetKind.agent: [_sampleAsset],
    AssetKind.skill: [
      WorkspaceAsset(
        id: 'skill:test-skill',
        kind: AssetKind.skill,
        name: 'Test Skill',
        path: 'skills/test-skill.md',
      ),
    ],
  },
);

void main() {
  group('AssetSelectionController', () {
    late ProviderContainer container;
    late AssetSelectionController controller;

    setUp(() {
      container = ProviderContainer();
      addTearDown(container.dispose);
      controller = container.read(assetSelectionControllerProvider.notifier);
    });

    test('starts in idle state', () {
      final state = container.read(assetSelectionControllerProvider);
      expect(state.status, AssetSelectionStatus.idle);
      expect(state.assetId, isNull);
      expect(state.asset, isNull);
    });

    test('select resolves a known asset', () {
      controller.select('agent:test-agent', graph: _sampleGraph);

      final state = container.read(assetSelectionControllerProvider);
      expect(state.status, AssetSelectionStatus.resolved);
      expect(state.assetId, 'agent:test-agent');
      expect(state.asset, isNotNull);
      expect(state.asset!.name, 'Test Agent');
      expect(state.isResolved, true);
    });

    test('select resolves unknown asset to unresolved', () {
      controller.select('agent:nonexistent', graph: _sampleGraph);

      final state = container.read(assetSelectionControllerProvider);
      expect(state.status, AssetSelectionStatus.unresolved);
      expect(state.asset, isNull);
      expect(state.isUnresolved, true);
    });

    test('select with empty graph marks as unresolved', () {
      controller.select(
        'agent:test-agent',
        graph: const WorkspaceGraphResult.empty(),
      );

      final state = container.read(assetSelectionControllerProvider);
      expect(state.status, AssetSelectionStatus.unresolved);
    });

    test('select with null graph marks as unresolved', () {
      controller.select('agent:test-agent');

      final state = container.read(assetSelectionControllerProvider);
      expect(state.status, AssetSelectionStatus.unresolved);
    });

    test('select records origin surface', () {
      controller.select('agent:test-agent', graph: _sampleGraph, origin: 'map');

      final state = container.read(assetSelectionControllerProvider);
      expect(state.origin, 'map');
    });

    test('clear resets to idle', () {
      controller.select('agent:test-agent', graph: _sampleGraph);
      expect(container.read(assetSelectionControllerProvider).isResolved, true);

      controller.clear();

      final state = container.read(assetSelectionControllerProvider);
      expect(state.status, AssetSelectionStatus.idle);
      expect(state.assetId, isNull);
      expect(state.asset, isNull);
    });

    test('resolveAgainst updates selection with new graph', () {
      controller.select('agent:test-agent', graph: _sampleGraph);
      expect(container.read(assetSelectionControllerProvider).isResolved, true);

      // Simulate graph refresh without the asset
      controller.resolveAgainst(const WorkspaceGraphResult.empty());

      final state = container.read(assetSelectionControllerProvider);
      expect(state.status, AssetSelectionStatus.unresolved);
      expect(state.asset, isNull);
    });

    test('resolveAgainst resolves asset from refreshed graph', () {
      // Start with empty graph — unresolved
      controller.select(
        'agent:test-agent',
        graph: const WorkspaceGraphResult.empty(),
      );
      expect(
        container.read(assetSelectionControllerProvider).isUnresolved,
        true,
      );

      // Refresh with graph that now has the asset
      controller.resolveAgainst(_sampleGraph);

      final state = container.read(assetSelectionControllerProvider);
      expect(state.status, AssetSelectionStatus.resolved);
      expect(state.asset, isNotNull);
      expect(state.asset!.name, 'Test Agent');
    });

    test('incoming and outgoing edges are populated', () {
      controller.select('agent:test-agent', graph: _sampleGraph);

      final state = container.read(assetSelectionControllerProvider);
      // agent:test-agent has one outgoing edge (uses -> skill:test-skill)
      expect(state.outgoingEdges, hasLength(1));
      expect(state.outgoingEdges.first.targetId, 'skill:test-skill');
      // No incoming edges for this asset
      expect(state.incomingEdges, isEmpty);
    });

    test('incoming edges are populated for target asset', () {
      controller.select('skill:test-skill', graph: _sampleGraph);

      final state = container.read(assetSelectionControllerProvider);
      // skill:test-skill has one incoming edge from agent:test-agent
      expect(state.incomingEdges, hasLength(1));
      expect(state.incomingEdges.first.sourceId, 'agent:test-agent');
    });

    test('detailRoute builds canonical encoded path', () {
      expect(
        AssetSelectionController.detailRoute('agent:test-agent'),
        '/assets/${Uri.encodeComponent('agent:test-agent')}',
      );
      expect(
        AssetSelectionController.detailRoute('task:0315'),
        '/assets/${Uri.encodeComponent('task:0315')}',
      );
      expect(
        AssetSelectionController.detailRoute('agent:test-agent'),
        '/assets/agent%3Atest-agent',
      );
    });
  });

  group('AssetSelectionState', () {
    test('idle is a valid constant', () {
      const state = AssetSelectionState.idle;
      expect(state.status, AssetSelectionStatus.idle);
      expect(state.isResolved, false);
      expect(state.isActive, false);
      expect(state.isUnresolved, false);
    });

    test('copyWith preserves unmodified fields', () {
      const state = AssetSelectionState(
        status: AssetSelectionStatus.resolved,
        assetId: 'test',
        origin: 'map',
      );

      final updated = state.copyWith(status: AssetSelectionStatus.pending);
      expect(updated.status, AssetSelectionStatus.pending);
      expect(updated.assetId, 'test');
      expect(updated.origin, 'map');
    });

    test('copyWith clearAsset nullifies asset', () {
      const state = AssetSelectionState(
        status: AssetSelectionStatus.resolved,
        assetId: 'test',
        asset: _sampleAsset,
      );

      final updated = state.copyWith(clearAsset: true);
      expect(updated.asset, isNull);
      expect(updated.assetId, 'test');
    });

    test('equality compares status, assetId, and origin', () {
      const a = AssetSelectionState(
        status: AssetSelectionStatus.resolved,
        assetId: 'test',
        origin: 'map',
      );
      const b = AssetSelectionState(
        status: AssetSelectionStatus.resolved,
        assetId: 'test',
        origin: 'map',
      );
      const c = AssetSelectionState(
        status: AssetSelectionStatus.resolved,
        assetId: 'test',
        origin: 'operate',
      );

      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });
  });

  group('Convenience providers', () {
    test('selectedAssetDetailProvider returns null when idle', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final asset = container.read(selectedAssetDetailProvider);
      expect(asset, isNull);
    });

    test('isAssetDetailOpenProvider is false when idle', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final isOpen = container.read(isAssetDetailOpenProvider);
      expect(isOpen, false);
    });

    test('isAssetDetailOpenProvider is true when resolved', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container
          .read(assetSelectionControllerProvider.notifier)
          .select('agent:test-agent', graph: _sampleGraph);

      final isOpen = container.read(isAssetDetailOpenProvider);
      expect(isOpen, true);
    });

    test('selectedAssetDetailProvider returns asset when resolved', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container
          .read(assetSelectionControllerProvider.notifier)
          .select('agent:test-agent', graph: _sampleGraph);

      final asset = container.read(selectedAssetDetailProvider);
      expect(asset, isNotNull);
      expect(asset!.name, 'Test Agent');
    });
  });

  group('GoRouter asset detail route contract', () {
    /// Minimal router mirroring production `/assets/:assetId` contract without
    /// loading product shell branches (keeps suite OOM-safe and fast).
    GoRouter buildContractRouter({String initialLocation = '/overview'}) {
      return GoRouter(
        initialLocation: initialLocation,
        routes: [
          GoRoute(
            path: '/overview',
            builder: (context, state) =>
                const Scaffold(body: Center(child: Text('overview-surface'))),
          ),
          GoRoute(
            path: '/assets/:assetId',
            builder: (context, state) {
              final assetId = state.pathParameters['assetId'] ?? 'unknown';
              return AssetDetailPage(assetId: assetId);
            },
          ),
          GoRoute(
            path: '/asset/:id',
            redirect: (context, state) {
              final id = state.pathParameters['id'] ?? 'unknown';
              return '/assets/$id';
            },
          ),
          GoRoute(path: '/', redirect: (context, state) => '/overview'),
        ],
      );
    }

    Widget pumpRouter(
      GoRouter router, {
      WorkspaceGraphResult graph = _sampleGraph,
    }) {
      return ProviderScope(
        overrides: [
          workspaceGraphAsyncProvider.overrideWith(
            () => _StaticGraphNotifier(graph),
          ),
        ],
        child: MaterialApp.router(
          theme: ThemeData(
            brightness: Brightness.dark,
            useMaterial3: true,
            splashFactory: NoSplash.splashFactory,
            highlightColor: Colors.transparent,
            scaffoldBackgroundColor: PrismColors.obsidianDeep,
          ),
          routerConfig: router,
        ),
      );
    }

    testWidgets('deep-link open restores assetId into detail page', (
      tester,
    ) async {
      final router = buildContractRouter(
        initialLocation: '/assets/agent:test-agent',
      );
      await tester.pumpWidget(pumpRouter(router));
      await tester.pumpAndSettle();

      expect(find.byType(AssetDetailView), findsOneWidget);
      expect(find.text('Test Agent'), findsWidgets);
      expect(find.text('Asset not found'), findsNothing);
      expect(
        router.routeInformationProvider.value.uri.toString(),
        '/assets/agent:test-agent',
      );
    });

    testWidgets('unknown assetId degrades to fallback without crash', (
      tester,
    ) async {
      final router = buildContractRouter(initialLocation: '/assets/unknown');
      await tester.pumpWidget(pumpRouter(router));
      await tester.pumpAndSettle();

      expect(find.text('Asset not found'), findsOneWidget);
      expect(find.text('unknown'), findsOneWidget);
      expect(find.text('Go to Overview'), findsOneWidget);
    });

    testWidgets('legacy /asset/:id redirects to canonical /assets/:id', (
      tester,
    ) async {
      final router = buildContractRouter(
        initialLocation: '/asset/agent:test-agent',
      );
      await tester.pumpWidget(pumpRouter(router));
      await tester.pumpAndSettle();

      expect(find.byType(AssetDetailView), findsOneWidget);
      expect(find.text('Test Agent'), findsWidgets);
      expect(
        router.routeInformationProvider.value.uri.toString(),
        '/assets/agent:test-agent',
      );
    });

    testWidgets('close/back navigates away from detail to overview', (
      tester,
    ) async {
      final router = buildContractRouter(
        initialLocation: '/assets/agent:test-agent',
      );
      await tester.pumpWidget(pumpRouter(router));
      await tester.pumpAndSettle();

      expect(find.byType(AssetDetailView), findsOneWidget);

      // Leading back button on AssetDetailPage uses context.go('/overview').
      await tester.tap(find.byTooltip('Back to Overview'));
      await tester.pumpAndSettle();

      expect(find.text('overview-surface'), findsOneWidget);
      expect(find.byType(AssetDetailView), findsNothing);
      expect(router.routeInformationProvider.value.uri.toString(), '/overview');
    });

    testWidgets('detailRoute helper matches router path parameter shape', (
      tester,
    ) async {
      final path = AssetSelectionController.detailRoute('agent:test-agent');
      final router = buildContractRouter(initialLocation: path);
      await tester.pumpWidget(pumpRouter(router));
      await tester.pumpAndSettle();

      expect(find.byType(AssetDetailView), findsOneWidget);
      expect(path, '/assets/agent%3Atest-agent');
    });

    testWidgets('missing graph asset degrades without navigation loop', (
      tester,
    ) async {
      final router = buildContractRouter(
        initialLocation: '/assets/agent:missing',
      );
      await tester.pumpWidget(pumpRouter(router));
      await tester.pumpAndSettle();

      expect(find.text('Asset not found'), findsOneWidget);
      expect(find.text('agent:missing'), findsOneWidget);
      expect(
        router.routeInformationProvider.value.uri.toString(),
        '/assets/agent:missing',
      );
    });
  });
}

class _StaticGraphNotifier extends WorkspaceGraphAsyncNotifier {
  _StaticGraphNotifier(this._graph);

  final WorkspaceGraphResult _graph;

  @override
  Future<WorkspaceGraphResult> build() async => _graph;
}
