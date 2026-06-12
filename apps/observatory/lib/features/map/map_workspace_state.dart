/// State contract for the Map workspace feature.
///
/// Defines the four subviews required by the Map surface (Agents, Skills,
/// Workflows, Graph) and the shared selection/query/filter state that
/// follow-up tasks (catalog, graph, inspector) can extend without
/// reworking the page's public API.
///
/// The catalog extension adds [catalogAssets] (the normalized asset
/// collection) and [filteredAssets] (derived from the active tab,
/// query, and filters). Follow-up tasks can add graph layout state
/// and inspector content via [additionalState].
library;

import 'package:flutter/foundation.dart';
import '../../data/models/workspace_graph.dart';
import 'graph/map_graph_mode.dart';

/// The four subviews of the Map workspace.
///
/// Each tab maps to a specific content mode:
/// - [MapSubview.agents]: agent catalog/list
/// - [MapSubview.skills]: skill catalog with hierarchy
/// - [MapSubview.workflows]: workflow catalog
/// - [MapSubview.graph]: interactive asset graph
enum MapSubview {
  /// Agent catalog list.
  agents,

  /// Skill catalog with hierarchy.
  skills,

  /// Workflow catalog.
  workflows,

  /// Interactive graph visualization.
  graph,
}

/// Typed state for the Map workspace page.
///
/// This is a pure data class — no Flutter dependency — that holds
/// the current subview, query, filters, selected asset, and the
/// catalog asset collection. The page renders from this state; the
/// provider mutates it.
///
/// The catalog extension adds:
/// - [catalogAssets]: the full normalized asset collection
/// - [filteredAssets]: derived from tab + query + filters (computed by provider)
///
/// Follow-up tasks can add graph layout state and inspector content
/// via [additionalState].
@immutable
class MapWorkspaceState {
  /// Currently active subview/tab.
  final MapSubview activeSubview;

  /// Current search query (empty string = no filter).
  final String query;

  /// Active filter tags (e.g., ['can:canonical', 'tag:orchestration']).
  final Set<String> activeFilters;

  /// Currently selected asset id (null = nothing selected).
  final String? selectedAssetId;

  /// Whether the workspace data is still loading.
  final bool isLoading;

  /// Error message if workspace loading failed (null = no error).
  final String? error;

  /// Full catalog of workspace assets (all kinds).
  ///
  /// This is the single source of truth for the catalog.
  /// The provider derives [filteredAssets] from this collection
  /// using the active tab, query, and filters.
  final List<WorkspaceAsset> catalogAssets;

  /// Active graph mode for the Graph subview.
  final MapGraphMode activeGraphMode;

  /// Open-ended extension point for follow-up tasks.
  ///
  /// Catalog data, graph layout state, and inspector content can be
  /// added here without changing the public API of [MapWorkspaceState].
  final Map<String, dynamic> additionalState;

  const MapWorkspaceState({
    this.activeSubview = MapSubview.agents,
    this.query = '',
    this.activeFilters = const {},
    this.selectedAssetId,
    this.isLoading = false,
    this.error,
    this.catalogAssets = const [],
    this.activeGraphMode = MapGraphMode.containment,
    this.additionalState = const {},
  });

  /// Create a copy with optional overrides.
  MapWorkspaceState copyWith({
    MapSubview? activeSubview,
    String? query,
    Set<String>? activeFilters,
    String? selectedAssetId,
    bool clearSelectedAsset = false,
    bool? isLoading,
    String? error,
    bool clearError = false,
    List<WorkspaceAsset>? catalogAssets,
    MapGraphMode? activeGraphMode,
    Map<String, dynamic>? additionalState,
  }) {
    return MapWorkspaceState(
      activeSubview: activeSubview ?? this.activeSubview,
      query: query ?? this.query,
      activeFilters: activeFilters ?? this.activeFilters,
      selectedAssetId: clearSelectedAsset
          ? null
          : (selectedAssetId ?? this.selectedAssetId),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      catalogAssets: catalogAssets ?? this.catalogAssets,
      activeGraphMode: activeGraphMode ?? this.activeGraphMode,
      additionalState: additionalState ?? this.additionalState,
    );
  }

  /// Whether an asset is currently selected.
  bool get hasSelection => selectedAssetId != null;

  /// Whether any filters are active.
  bool get hasFilters => activeFilters.isNotEmpty || query.isNotEmpty;

  /// Derive the asset family for the current tab.
  ///
  /// Returns the appropriate subset of [catalogAssets] based on
  /// [activeSubview]. The graph tab returns all assets.
  List<WorkspaceAsset> get assetsForTab {
    switch (activeSubview) {
      case MapSubview.agents:
        return catalogAssets.where((a) => a.kind == AssetKind.agent).toList();
      case MapSubview.skills:
        return catalogAssets
            .where(
              (a) => a.kind == AssetKind.skill || a.kind == AssetKind.subskill,
            )
            .toList();
      case MapSubview.workflows:
        return catalogAssets
            .where((a) => a.kind == AssetKind.workflow)
            .toList();
      case MapSubview.graph:
        return catalogAssets;
    }
  }

  /// Derive the filtered asset list for the current tab.
  ///
  /// Applies [query] (name/description substring match) and
  /// [activeFilters] (canonicality and tag filters) to [assetsForTab].
  List<WorkspaceAsset> get filteredAssets {
    var result = assetsForTab;

    // Apply search query (case-insensitive substring match on name + description)
    if (query.isNotEmpty) {
      final lowerQuery = query.toLowerCase();
      result = result.where((a) {
        return a.name.toLowerCase().contains(lowerQuery) ||
            a.description.toLowerCase().contains(lowerQuery);
      }).toList();
    }

    // Apply filter chips
    if (activeFilters.isNotEmpty) {
      result = result.where((a) {
        return activeFilters.every((filter) => _matchesFilter(a, filter));
      }).toList();
    }

    return result;
  }

  /// Check if an asset matches a single filter chip.
  ///
  /// Filter format:
  /// - `can:<canonicality>` matches canonicality
  /// - `tag:<tag>` matches tags
  static bool _matchesFilter(WorkspaceAsset asset, String filter) {
    if (filter.startsWith('can:')) {
      final canValue = filter.substring(4);
      return _canonicalityLabel(asset.canonicality) == canValue;
    }
    if (filter.startsWith('tag:')) {
      final tagValue = filter.substring(4);
      return asset.tags.contains(tagValue);
    }
    return false;
  }

  static String _canonicalityLabel(Canonicality c) {
    switch (c) {
      case Canonicality.parentCanonical:
        return 'canonical';
      case Canonicality.childLocal:
        return 'child-local';
      case Canonicality.generated:
        return 'generated';
      case Canonicality.appendOnly:
        return 'append-only';
      case Canonicality.archive:
        return 'archive';
      case Canonicality.mock:
        return 'mock';
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MapWorkspaceState &&
          runtimeType == other.runtimeType &&
          activeSubview == other.activeSubview &&
          query == other.query &&
          selectedAssetId == other.selectedAssetId &&
          isLoading == other.isLoading &&
          error == other.error &&
          catalogAssets.length == other.catalogAssets.length;

  @override
  int get hashCode => Object.hash(
    activeSubview,
    query,
    selectedAssetId,
    isLoading,
    error,
    catalogAssets.length,
  );

  @override
  String toString() =>
      'MapWorkspaceState(subview:$activeSubview query:"$query" '
      'selected:$selectedAssetId loading:$isLoading error:$error '
      'assets:${catalogAssets.length})';
}
