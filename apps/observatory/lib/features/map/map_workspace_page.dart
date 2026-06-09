/// Map workspace page for the ASW Observatory.
///
/// Gives warp-prism a real Map route with a feature-local state contract
/// and a DS-composed shell hosting the catalog panel, graph panel, and
/// inspector panel.
///
/// The page exposes four subviews: Agents, Skills, Workflows, and Graph.
/// The first three render the catalog panel with search, filters, and
/// asset cards driven by repository data. Graph renders the interactive
/// graph canvas. All subviews share a single selection state via
/// [MapSelectionController], and the inspector panel renders asset
/// details for the selected asset.
library;

import 'package:flutter/material.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';
import '../asset_detail/asset_detail.dart';
import 'map_workspace_state.dart';
import 'map_workspace_provider.dart';
import 'map_selection_controller.dart';
import 'widgets/map_catalog_panel.dart';
import 'widgets/map_graph_panel.dart';
import 'widgets/map_inspector_panel.dart';
import 'widgets/map_state_panel.dart';
import 'graph/map_graph_projection.dart';

/// Map workspace page with four tabs and an inspector panel.
///
/// This page is a StatefulWidget that manages its own [MapWorkspaceProvider].
/// It composes DS primitives and renders the catalog panel for the three
/// catalog tabs (Agents, Skills, Workflows), the graph panel for Graph,
/// and an inspector panel when an asset is selected.
class MapWorkspacePage extends StatefulWidget {
  /// Optional initial state for testing.
  final MapWorkspaceState? initialState;

  const MapWorkspacePage({super.key, this.initialState});

  @override
  State<MapWorkspacePage> createState() => _MapWorkspacePageState();
}

class _MapWorkspacePageState extends State<MapWorkspacePage>
    with SingleTickerProviderStateMixin {
  late final MapWorkspaceProvider _provider;
  late final MapSelectionController _selectionController;
  late final TabController _tabController;

  static const _tabs = [
    (subview: MapSubview.agents, label: 'Agents', icon: Icons.smart_toy_outlined),
    (subview: MapSubview.skills, label: 'Skills', icon: Icons.psychology_outlined),
    (subview: MapSubview.workflows, label: 'Workflows', icon: Icons.account_tree_outlined),
    (subview: MapSubview.graph, label: 'Graph', icon: Icons.hub_outlined),
  ];

  @override
  void initState() {
    super.initState();
    _provider = MapWorkspaceProvider(initialState: widget.initialState);
    _selectionController = MapSelectionController(_provider);
    _tabController = TabController(length: _tabs.length, vsync: this);

    // Sync tab controller with state
    _tabController.index = _tabs.indexWhere(
      (t) => t.subview == _provider.state.activeSubview,
    );
    _tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _provider.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) return;
    final subview = _tabs[_tabController.index].subview;
    _provider.changeSubview(subview);
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

  void _onNodeTap(GraphNode node) {
    _selectionController.selectAsset(node.id);
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
            return MapInspectorPanel(
              controller: _selectionController,
              onClose: () => _selectionController.deselectAsset(),
            );
          },
          child: _buildMasterContent(context, state),
        );
      },
    );
  }

  Widget _buildMasterContent(BuildContext context, MapWorkspaceState state) {
    return Column(
      children: [
        _buildTabBar(context, state),
        Expanded(
          child: TabBarView(
            controller: _tabController,
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
  // Tab bar
  // ---------------------------------------------------------------------------

  Widget _buildTabBar(BuildContext context, MapWorkspaceState state) {
    return Container(
      decoration: BoxDecoration(
        color: DSColors.obsidianBase,
        border: Border(
          bottom: BorderSide(color: DSColors.borderSubtle, width: 1),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorColor: DSColors.accentCyan,
        indicatorSize: TabBarIndicatorSize.label,
        labelColor: DSColors.accentCyan,
        unselectedLabelColor: DSColors.textTertiary,
        labelStyle: DSTypography.labelMedium,
        unselectedLabelStyle: DSTypography.labelMedium,
        tabs: _tabs
            .map(
              (t) => Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DSIcon(t.icon, iconSize: DSIconSize.small),
                    const SizedBox(width: DSSpacing.xs),
                    Text(t.label),
                  ],
                ),
              ),
            )
            .toList(),
      ),
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
        onAction: () => _provider.clearError(),
      );
    }

    // Empty corpus state (no assets at all for this tab)
    if (state.catalogAssets.isEmpty) {
      return MapStatePanel(
        state: MapSurfaceState.emptyCorpus,
      );
    }

    // No-results state (query/filter eliminated all assets)
    if (state.filteredAssets.isEmpty && state.assetsForTab.isNotEmpty) {
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
      return MapStatePanel(
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
        onAction: () => _provider.clearError(),
      );
    }

    // Empty corpus
    if (state.catalogAssets.isEmpty) {
      return MapStatePanel(
        state: MapSurfaceState.emptyCorpus,
      );
    }

    // Build edges from all catalog assets
    final allEdges = state.catalogAssets
        .expand((a) => a.edges)
        .toList();

    // Compute the graph projection for the current mode
    final projection = projectGraph(
      assets: state.catalogAssets,
      edges: allEdges,
      mode: state.activeGraphMode,
    );

    // Graph no-edges state
    if (projection.isEmpty) {
      return MapStatePanel(
        state: MapSurfaceState.graphNoEdges,
      );
    }

    return MapGraphPanel(
      projection: projection,
      onModeChanged: (mode) => _provider.changeGraphMode(mode),
      onNodeTap: _onNodeTap,
    );
  }
}
