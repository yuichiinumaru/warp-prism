/// Reusable state panel for the Map surface.
///
/// Provides explicit, semantically distinct visual states for loading,
/// empty corpus, no-results (filter/query), graph-no-edges, error, and
/// no-selection. Each state has contextual copy specific to the Map
/// surface so users can distinguish them without guessing.
///
/// This is NOT a generic placeholder — it communicates specific
/// degraded conditions that the Map surface can encounter.
library;

import 'package:flutter/material.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

/// The distinct state conditions the Map surface can be in.
enum MapSurfaceState {
  /// Data is loading.
  loading,

  /// No assets exist in the workspace for this tab.
  emptyCorpus,

  /// Assets exist but the current query/filter matches zero.
  noResults,

  /// Graph mode produced zero edges (all edges filtered out).
  graphNoEdges,

  /// A load/parse operation failed.
  error,

  /// Inspector has no asset selected.
  noSelection,
}

/// A reusable state panel for the Map surface.
///
/// Renders a contextual message with appropriate icon and optional
/// action button. Each [MapSurfaceState] produces a distinct visual
/// so downstream polish (EPIC 10) cannot collapse them into one
/// generic placeholder.
class MapStatePanel extends StatelessWidget {
  /// The current degraded state to display.
  final MapSurfaceState state;

  /// Optional detail message (e.g., error message text).
  final String? detail;

  /// The current search query (for no-results context).
  final String? query;

  /// Active filter count (for no-results context).
  final int? activeFilterCount;

  /// Action button label (e.g., "Retry", "Clear filters").
  final String? actionLabel;

  /// Action button callback.
  final VoidCallback? onAction;

  const MapStatePanel({
    super.key,
    required this.state,
    this.detail,
    this.query,
    this.activeFilterCount,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: _buildStateSurface(),
      ),
    );
  }

  Widget _buildStateSurface() {
    switch (state) {
      case MapSurfaceState.loading:
        return DSStateSurface.loading(
          icon: Icons.hourglass_empty,
          title: 'Loading map data...',
          subtitle: detail ?? 'Preparing workspace assets for visualization.',
        );

      case MapSurfaceState.emptyCorpus:
        return DSStateSurface.empty(
          icon: Icons.inventory_2_outlined,
          title: 'No assets in workspace',
          subtitle:
              'The workspace is loaded but contains no assets to display. '
              'Add agents, skills, or workflows to populate the map.',
        );

      case MapSurfaceState.noResults:
        final hasQuery = query != null && query!.isNotEmpty;
        final hasFilters = activeFilterCount != null && activeFilterCount! > 0;

        String title;
        String subtitle;

        if (hasQuery && hasFilters) {
          title = 'No results for "$query"';
          subtitle =
              '$activeFilterCount filter${activeFilterCount == 1 ? '' : 's'} active. '
              'Try adjusting your search or removing filters.';
        } else if (hasQuery) {
          title = 'No results for "$query"';
          subtitle = 'Try a different search term or clear the search.';
        } else if (hasFilters) {
          title = 'No matching assets';
          subtitle =
              '$activeFilterCount filter${activeFilterCount == 1 ? '' : 's'} active. '
              'Try removing some filters.';
        } else {
          title = 'No results';
          subtitle = 'No assets match the current view.';
        }

        return DSStateSurface.empty(
          icon: Icons.search_off_outlined,
          title: title,
          subtitle: subtitle,
          actionLabel: actionLabel ?? ((hasQuery || hasFilters) ? 'Clear filters' : null),
          onAction: onAction,
        );

      case MapSurfaceState.graphNoEdges:
        return DSStateSurface.empty(
          icon: Icons.device_hub_outlined,
          title: 'No edges in this mode',
          subtitle:
              'The current graph mode produced no visible connections. '
              'Switch modes or add edges between assets to see the graph.',
        );

      case MapSurfaceState.error:
        return DSStateSurface.error(
          icon: DSIcons.error,
          title: 'Failed to load map data',
          subtitle: detail ?? 'An error occurred while loading workspace data.',
          actionLabel: actionLabel ?? 'Retry',
          onAction: onAction,
        );

      case MapSurfaceState.noSelection:
        return DSStateSurface.empty(
          icon: Icons.touch_app_outlined,
          title: 'No asset selected',
          subtitle:
              'Select an asset from the catalog or graph to view its details, '
              'relationships, and provenance.',
          compact: true,
        );
    }
  }
}
