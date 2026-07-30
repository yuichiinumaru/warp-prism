/// Map workspace page for the ASW Observatory.
///
/// Gives warp-prism a real Map route with a feature-local state contract
/// and a DS-composed shell hosting the catalog panel, graph panel, and
/// universal [AssetDetailView] via [AssetDetailConsumer].
///
/// The page exposes four subviews: Agents, Skills, Workflows, and Graph.
/// The first three render the catalog panel with search, filters, and
/// asset cards driven by repository data. Graph renders the interactive
/// graph canvas. All subviews share a single selection state via
/// [MapSelectionController]; selection opens the shared responsive detail
/// shell with descriptor-backed [AssetDetailView].
library;

import 'package:flutter/material.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';
import '../asset_detail/asset_detail.dart';
import 'map_workspace_state.dart';
import 'map_workspace_provider.dart';
import 'map_selection_controller.dart';
import 'widgets/map_catalog_panel.dart';
import 'widgets/map_graph_panel.dart';
import 'widgets/map_state_panel.dart';
import 'graph/map_graph_projection.dart';

/// Map workspace page with four tabs and shared responsive asset detail.
///
/// This page is a StatefulWidget that manages its own [MapWorkspaceProvider].
/// It composes public [Prism]* primitives and renders the catalog panel for
/// the three catalog tabs (Agents, Skills, Workflows), the graph panel for
/// Graph, and [AssetDetailView] when an asset is selected.
class MapWorkspacePage extends StatefulWidget {
  /// Optional initial state for testing / parent shell injection.
  final MapWorkspaceState? initialState;

  /// Optional retry callback for workspace reload (e.g. invalidate
  /// [workspaceSnapshotAsyncProvider] from [MapPageShell]).
  ///
  /// When null, the error Retry control only clears the local error flag
  /// (test-friendly). When set, Retry invokes this callback so the shell
  /// reloads the workspace snapshot rather than papering over the error.
  final VoidCallback? onRetry;

  const MapWorkspacePage({super.key, this.initialState, this.onRetry});

  @override
  State<MapWorkspacePage> createState() => _MapWorkspacePageState();
}

class _MapWorkspacePageState extends State<MapWorkspacePage> {
  late final MapWorkspaceProvider _provider;
  late final MapSelectionController _selectionController;
  late final PrismTabController _tabController;

  /// Fixed Map subviews — order is the public tab contract for Task 0510.
  static const _tabs = [
    (
      subview: MapSubview.agents,
      id: 'agents',
      label: 'Agents',
      icon: Icons.smart_toy_outlined,
    ),
    (
      subview: MapSubview.skills,
      id: 'skills',
      label: 'Skills',
      icon: Icons.psychology_outlined,
    ),
    (
      subview: MapSubview.workflows,
      id: 'workflows',
      label: 'Workflows',
      icon: Icons.account_tree_outlined,
    ),
    (
      subview: MapSubview.graph,
      id: 'graph',
      label: 'Graph',
      icon: Icons.hub_outlined,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _provider = MapWorkspaceProvider(initialState: widget.initialState);
    _selectionController = MapSelectionController(_provider);

    final initialIndex = _tabs.indexWhere(
      (t) => t.subview == _provider.state.activeSubview,
    );
    // Content is rendered from MapWorkspaceState via IndexedStack below;
    // PrismTab only needs headers for the public PrismTabBar surface.
    _tabController = PrismTabController(
      tabs: [
        for (final t in _tabs)
          PrismTab(
            id: t.id,
            label: t.label,
            icon: t.icon,
            content: (_) => const SizedBox.shrink(),
          ),
      ],
      activeIndex: initialIndex < 0 ? 0 : initialIndex,
    );
    _tabController.addListener(_onTabChanged);
  }

  @override
  void didUpdateWidget(MapWorkspacePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Merge every new parent-provided state *instance*. Do not gate solely on
    // [MapWorkspaceState.==]: [WorkspaceAsset.==] is identity-light
    // (id/kind/name/path/canonicality) and can miss description/tags/triggers/
    // edges updates that must still refresh the catalog. [syncState] is
    // merge-safe for interactive UI fields.
    if (widget.initialState != null &&
        !identical(widget.initialState, oldWidget.initialState)) {
      _provider.syncState(widget.initialState!);
      _syncTabControllerToState(_provider.state.activeSubview);
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _provider.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    final index = _tabController.activeIndex;
    if (index < 0 || index >= _tabs.length) return;
    _provider.changeSubview(_tabs[index].subview);
  }

  void _syncTabControllerToState(MapSubview subview) {
    final index = _tabs.indexWhere((t) => t.subview == subview);
    if (index >= 0 && index != _tabController.activeIndex) {
      _tabController.select(index);
    }
  }

  void _onQueryChanged(String query) {
    _provider.updateQuery(query);
  }

  void _onFilterToggle(String filter) {
    _provider.toggleFilter(filter);
  }

  void _onClearFilters() {
    _provider.clearFilters();
  }

  void _onAssetTap(String assetId) {
    _selectionController.selectAsset(assetId);
  }

  void _onNodeTap(PrismGraphNode node) {
    _selectionController.selectAsset(node.id);
  }

  /// Retry: prefer shell reload callback; fall back to clearing local error.
  void _onRetry() {
    final retry = widget.onRetry;
    if (retry != null) {
      retry();
      return;
    }
    _provider.clearError();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<MapWorkspaceState>(
      stream: _provider.stateStream,
      initialData: _provider.state,
      builder: (context, snapshot) {
        final state = snapshot.data ?? _provider.state;

        return AssetDetailConsumer(
          selectedAssetId: state.selectedAssetId,
          onDetailClose: () => _selectionController.deselectAsset(),
          detailTitle: state.selectedAssetId != null
              ? _selectionController.selectedAsset?.name ?? 'Asset Detail'
              : null,
          detailKind: state.selectedAssetId != null
              ? _selectionController.selectedAsset?.kind.name
              : null,
          detailBuilder: (context, assetId) {
            return _buildUniversalDetail(assetId, state);
          },
          child: _buildMasterContent(context, state),
        );
      },
    );
  }

  /// Universal asset detail via descriptor → [AssetDetailView]
  /// (Task 0905 path-to-100: no surface-local MapInspectorPanel).
  Widget _buildUniversalDetail(String assetId, MapWorkspaceState state) {
    final asset = _selectionController.selectedAsset;
    if (asset == null) {
      return const AssetDetailEmpty();
    }

    final allEdges = state.resolvedGraphEdges;
    final assetNames = {for (final a in state.catalogAssets) a.id: a.name};
    final descriptor = descriptorFromWorkspaceAsset(
      asset,
      allEdges: allEdges,
      assetNames: assetNames,
    );

    return AssetDetailView(
      descriptor: descriptor,
      onClose: () => _selectionController.deselectAsset(),
    );
  }

  Widget _buildMasterContent(BuildContext context, MapWorkspaceState state) {
    final activeIndex = _tabs
        .indexWhere((t) => t.subview == state.activeSubview)
        .clamp(0, _tabs.length - 1);

    return Column(
      children: [
        PrismTabBar(controller: _tabController),
        Expanded(
          // IndexedStack keeps each subview mounted so catalog scroll/query
          // state is not discarded when switching tabs.
          child: IndexedStack(
            index: activeIndex,
            children: [
              _buildCatalogTab(context, state, MapCatalogTab.agents),
              _buildCatalogTab(context, state, MapCatalogTab.skills),
              _buildCatalogTab(context, state, MapCatalogTab.workflows),
              _buildGraphTab(context, state),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Catalog tab (Agents, Skills, Workflows)
  // ---------------------------------------------------------------------------

  Widget _buildCatalogTab(
    BuildContext context,
    MapWorkspaceState state,
    MapCatalogTab tab,
  ) {
    // Loading state
    if (state.isLoading) {
      return MapStatePanel(
        state: MapSurfaceState.loading,
        detail: 'Loading ${tab.label.toLowerCase()}...',
      );
    }

    // Error state
    if (state.error != null) {
      return MapStatePanel(
        state: MapSurfaceState.error,
        detail: state.error,
        actionLabel: 'Retry',
        onAction: _onRetry,
      );
    }

    // Empty corpus state (no assets at all in workspace)
    if (state.catalogAssets.isEmpty) {
      return const MapStatePanel(state: MapSurfaceState.emptyCorpus);
    }

    // Empty family: workspace has assets, but none for this catalog tab
    // and no filters are hiding them.
    if (state.assetsForTab.isEmpty && !state.hasFilters) {
      return MapStatePanel(
        state: MapSurfaceState.emptyFamily,
        detail: 'No ${tab.label.toLowerCase()} in this workspace corpus.',
      );
    }

    // No-results: query/filter eliminated all visible assets for this tab
    // (includes empty-family + active filters, not only non-empty families).
    if (state.filteredAssets.isEmpty) {
      return MapStatePanel(
        state: MapSurfaceState.noResults,
        query: state.query,
        activeFilterCount: state.activeFilters.length,
        onAction: _onClearFilters,
      );
    }

    // Catalog panel with search, filters, and cards
    return MapCatalogPanel(
      activeTab: tab,
      filteredAssets: state.filteredAssets,
      allAssets: state.assetsForTab,
      query: state.query,
      activeFilters: state.activeFilters,
      selectedAssetId: state.selectedAssetId,
      onQueryChanged: _onQueryChanged,
      onFilterToggle: _onFilterToggle,
      onClearFilters: _onClearFilters,
      onAssetTap: _onAssetTap,
    );
  }

  // ---------------------------------------------------------------------------
  // Graph tab
  // ---------------------------------------------------------------------------

  Widget _buildGraphTab(BuildContext context, MapWorkspaceState state) {
    // Loading state
    if (state.isLoading) {
      return const MapStatePanel(
        state: MapSurfaceState.loading,
        detail: 'Loading graph data...',
      );
    }

    // Error state
    if (state.error != null) {
      return MapStatePanel(
        state: MapSurfaceState.error,
        detail: state.error,
        actionLabel: 'Retry',
        onAction: _onRetry,
      );
    }

    // Empty corpus
    if (state.catalogAssets.isEmpty) {
      return const MapStatePanel(state: MapSurfaceState.emptyCorpus);
    }

    // Prefer WorkspaceGraphBuilder edges (inferred + frontmatter) when the
    // shell injected them; fall back to per-asset frontmatter edges in tests.
    final allEdges = state.resolvedGraphEdges;

    // Compute the graph projection for the current mode
    final projection = projectGraph(
      assets: state.catalogAssets,
      edges: allEdges,
      mode: state.activeGraphMode,
    );

    // Keep the graph panel (and mode selector) mounted even when the active
    // mode has zero edges so users can switch modes without leaving Graph.
    return MapGraphPanel(
      projection: projection,
      onModeChanged: (mode) => _provider.changeGraphMode(mode),
      onNodeTap: _onNodeTap,
    );
  }
}
