/// No-results state for the Map catalog when search/filter eliminates all assets.
///
/// Distinct from the shell-level empty state (which means "no data loaded").
/// This state means data IS loaded but the current query/filter combination
/// matched zero assets. The user needs to adjust their search.
library;

import 'package:flutter/material.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

/// No-results state shown when search or filter produces zero visible assets.
///
/// Provides a contextual message and optional "Clear filters" action.
class MapNoResultsState extends StatelessWidget {
  /// The current search query (empty if no query active).
  final String query;

  /// The currently active filter tags.
  final Set<String> activeFilters;

  /// Called when the user wants to clear all filters and query.
  final VoidCallback? onClearFilters;

  const MapNoResultsState({
    super.key,
    this.query = '',
    this.activeFilters = const {},
    this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    final hasQuery = query.isNotEmpty;
    final hasFilters = activeFilters.isNotEmpty;

    String title;
    String subtitle;

    if (hasQuery && hasFilters) {
      title = 'No results for "$query"';
      subtitle =
          '${activeFilters.length} filter${activeFilters.length == 1 ? '' : 's'} active. '
          'Try adjusting your search or removing filters.';
    } else if (hasQuery) {
      title = 'No results for "$query"';
      subtitle = 'Try a different search term or clear the search.';
    } else if (hasFilters) {
      title = 'No matching assets';
      subtitle =
          '${activeFilters.length} filter${activeFilters.length == 1 ? '' : 's'} active. '
          'Try removing some filters.';
    } else {
      title = 'No assets to display';
      subtitle = 'This catalog is empty.';
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: DSStateSurface.empty(
          icon: Icons.search_off_outlined,
          title: title,
          subtitle: subtitle,
          actionLabel: (hasQuery || hasFilters) ? 'Clear filters' : null,
          onAction: onClearFilters,
        ),
      ),
    );
  }
}
