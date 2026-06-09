/// Catalog panel for the Map surface.
///
/// Renders the catalog side of the Map workspace: a search bar,
/// filter chips, and a list of asset cards for the active tab
/// (Agents, Skills, or Workflows). Search and filter operations
/// are applied to the same normalized collection to keep tabs,
/// counters, and empty states coherent.
///
/// This widget is purely presentational — it receives pre-filtered
/// data and callbacks from [MapWorkspacePage].
library;

import 'package:flutter/material.dart';
import '../../../data/models/workspace_graph.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';
import 'map_asset_card_grid.dart';
import 'map_no_results_state.dart';

/// Catalog panel with search, filters, and asset card list.
///
/// Shows only assets of the correct family for [activeTab].
/// The [filteredAssets] are already filtered by the provider —
/// this widget renders them and the no-results state when empty.
class MapCatalogPanel extends StatelessWidget {
  /// The currently active catalog tab.
  final MapCatalogTab activeTab;

  /// Pre-filtered assets to display (already filtered by query + chips).
  final List<WorkspaceAsset> filteredAssets;

  /// All unfiltered assets (used for filter chip counts).
  final List<WorkspaceAsset> allAssets;

  /// Current search query.
  final String query;

  /// Active filter chips.
  final Set<String> activeFilters;

  /// Currently selected asset ID.
  final String? selectedAssetId;

  /// Called when search query changes.
  final ValueChanged<String>? onQueryChanged;

  /// Called when a filter chip is toggled.
  final ValueChanged<String>? onFilterToggle;

  /// Called when all filters should be cleared.
  final VoidCallback? onClearFilters;

  /// Called when an asset card is tapped.
  final ValueChanged<String>? onAssetTap;

  const MapCatalogPanel({
    super.key,
    required this.activeTab,
    required this.filteredAssets,
    required this.allAssets,
    this.query = '',
    this.activeFilters = const {},
    this.selectedAssetId,
    this.onQueryChanged,
    this.onFilterToggle,
    this.onClearFilters,
    this.onAssetTap,
  });

  @override
  Widget build(BuildContext context) {
    // Compute available filter options for this tab's asset family.
    final filterOptions = _buildFilterOptions(allAssets);

    return Column(
      children: [
        // -- Search bar --
        Padding(
          padding: const EdgeInsets.fromLTRB(
            DSSpacing.md,
            DSSpacing.md,
            DSSpacing.md,
            DSSpacing.xs,
          ),
          child: DSSearchBar(
            placeholder: 'Search ${activeTab.label.toLowerCase()}...',
            value: query,
            onChanged: onQueryChanged,
            onClear: onClearFilters,
            activeFilterCount: activeFilters.isEmpty ? null : activeFilters.length,
          ),
        ),

        // -- Filter chips --
        if (filterOptions.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              DSSpacing.md,
              DSSpacing.xs,
              DSSpacing.md,
              DSSpacing.sm,
            ),
            child: DSFilterChipGroup(
              options: filterOptions,
              selected: activeFilters,
              onToggle: onFilterToggle,
            ),
          ),

        // -- Result count --
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: DSSpacing.md),
          child: Row(
            children: [
              DSText.labelSmall(
                '${filteredAssets.length} result${filteredAssets.length == 1 ? '' : 's'}',
                color: DSColors.textTertiary,
              ),
              const Spacer(),
              if (activeFilters.isNotEmpty || query.isNotEmpty)
                GestureDetector(
                  onTap: onClearFilters,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: DSText.labelSmall(
                      'Clear all',
                      color: DSColors.accentCyan,
                    ),
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(height: DSSpacing.sm),

        // -- Asset cards or no-results state --
        Expanded(
          child: filteredAssets.isEmpty
              ? MapNoResultsState(
                  query: query,
                  activeFilters: activeFilters,
                  onClearFilters: onClearFilters,
                )
              : MapAssetCardGrid(
                  assets: filteredAssets,
                  selectedAssetId: selectedAssetId,
                  onAssetTap: onAssetTap,
                ),
        ),
      ],
    );
  }

  /// Build filter chip options from available asset metadata.
  ///
  /// Extracts unique canonicality values and tag values from the
  /// asset collection to create filterable chips.
  List<DSFilterOption> _buildFilterOptions(List<WorkspaceAsset> assets) {
    // Count assets by canonicality
    final canonicalityCounts = <String, int>{};
    // Count assets by tag
    final tagCounts = <String, int>{};

    for (final asset in assets) {
      final canLabel = _canonicalityLabel(asset.canonicality);
      canonicalityCounts[canLabel] =
          (canonicalityCounts[canLabel] ?? 0) + 1;

      for (final tag in asset.tags) {
        tagCounts[tag] = (tagCounts[tag] ?? 0) + 1;
      }
    }

    final options = <DSFilterOption>[];

    // Canonicality filters
    for (final entry in canonicalityCounts.entries) {
      options.add(DSFilterOption(
        value: 'can:${entry.key}',
        label: entry.key,
        icon: _canonicalityIcon(entry.key),
        color: DSColors.forCanonicity(entry.key),
        count: entry.value,
      ));
    }

    // Tag filters (limit to top 8 to avoid overflow)
    final sortedTags = tagCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    for (final entry in sortedTags.take(8)) {
      options.add(DSFilterOption(
        value: 'tag:${entry.key}',
        label: entry.key,
        count: entry.value,
      ));
    }

    return options;
  }

  String _canonicalityLabel(Canonicality c) {
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

  IconData _canonicalityIcon(String label) {
    switch (label) {
      case 'canonical':
        return DSIcons.canonical;
      case 'child-local':
        return DSIcons.local;
      case 'generated':
        return DSIcons.generated;
      case 'append-only':
        return DSIcons.appendOnly;
      case 'archive':
        return DSIcons.archive;
      case 'mock':
        return DSIcons.mock;
      default:
        return DSIcons.info;
    }
  }
}

/// The three catalog tabs.
enum MapCatalogTab {
  agents('Agents', Icons.smart_toy_outlined),
  skills('Skills', Icons.psychology_outlined),
  workflows('Workflows', Icons.account_tree_outlined);

  const MapCatalogTab(this.label, this.icon);

  final String label;
  final IconData icon;
}
