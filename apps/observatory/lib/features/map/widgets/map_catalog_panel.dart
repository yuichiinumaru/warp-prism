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
import 'package:warp_prism_observatory/data/models/workspace_graph.dart';
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
            PrismSpacing.md,
            PrismSpacing.md,
            PrismSpacing.md,
            PrismSpacing.xs,
          ),
          child: PrismSearchBar(
            placeholder: 'Search ${activeTab.label.toLowerCase()}...',
            value: query,
            onChanged: onQueryChanged,
            onClear: onClearFilters,
            activeFilterCount: activeFilters.isEmpty
                ? null
                : activeFilters.length,
          ),
        ),

        // -- Filter chips --
        if (filterOptions.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              PrismSpacing.md,
              PrismSpacing.xs,
              PrismSpacing.md,
              PrismSpacing.sm,
            ),
            child: PrismFilterChipGroup(
              options: filterOptions,
              selected: activeFilters,
              onToggle: onFilterToggle,
            ),
          ),

        // -- Result count --
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: PrismSpacing.md),
          child: Row(
            children: [
              PrismText.labelSmall(
                '${filteredAssets.length} result${filteredAssets.length == 1 ? '' : 's'}',
                color: PrismColors.textTertiary,
              ),
              const Spacer(),
              if (activeFilters.isNotEmpty || query.isNotEmpty)
                Semantics(
                  button: true,
                  label: 'Clear all filters',
                  excludeSemantics: true,
                  child: TextButton(
                    onPressed: onClearFilters,
                    style: TextButton.styleFrom(
                      minimumSize: const Size(48, 48),
                      padding: const EdgeInsets.symmetric(
                        horizontal: PrismSpacing.sm,
                      ),
                      foregroundColor: PrismColors.accentCyan,
                    ),
                    child: const PrismText.labelSmall(
                      'Clear all',
                      color: PrismColors.accentCyan,
                    ),
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(height: PrismSpacing.sm),

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
  List<PrismFilterOption> _buildFilterOptions(List<WorkspaceAsset> assets) {
    // Count assets by canonicality
    final canonicalityCounts = <String, int>{};
    // Count assets by tag
    final tagCounts = <String, int>{};

    for (final asset in assets) {
      final canLabel = _canonicalityLabel(asset.canonicality);
      canonicalityCounts[canLabel] = (canonicalityCounts[canLabel] ?? 0) + 1;

      for (final tag in asset.tags) {
        tagCounts[tag] = (tagCounts[tag] ?? 0) + 1;
      }
    }

    final options = <PrismFilterOption>[];

    // Canonicality filters
    for (final entry in canonicalityCounts.entries) {
      options.add(
        PrismFilterOption(
          value: 'can:${entry.key}',
          label: entry.key,
          icon: _canonicalityIcon(entry.key),
          color: PrismColors.forCanonicity(entry.key),
          count: entry.value,
        ),
      );
    }

    // Tag filters (limit to top 8 to avoid overflow)
    final sortedTags = tagCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    for (final entry in sortedTags.take(8)) {
      options.add(
        PrismFilterOption(
          value: 'tag:${entry.key}',
          label: entry.key,
          count: entry.value,
        ),
      );
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
        return PrismIcons.canonical;
      case 'child-local':
        return PrismIcons.local;
      case 'generated':
        return PrismIcons.generated;
      case 'append-only':
        return PrismIcons.appendOnly;
      case 'archive':
        return PrismIcons.archive;
      case 'mock':
        return PrismIcons.mock;
      default:
        return PrismIcons.info;
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
