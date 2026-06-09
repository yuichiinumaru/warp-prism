import 'package:flutter/material.dart';
import '../tokens/tokens.dart';
import '../molecules/molecules.dart';

/// Data model for a single service in the [DSStatusGrid].
///
/// Holds all the fields needed to render a [DSHealthCard].
class DSHealthCardData {
  /// Name of the service or entity.
  final String serviceName;

  /// Current operational state.
  final DSOperationalState operationalState;

  /// Response latency (optional).
  final Duration? latency;

  /// Uptime percentage 0.0–1.0 (optional).
  final double? uptimePercent;

  /// Trend data points for sparkline (optional).
  final List<double>? trendData;

  /// Last health check timestamp (optional).
  final DateTime? lastCheck;

  const DSHealthCardData({
    required this.serviceName,
    required this.operationalState,
    this.latency,
    this.uptimePercent,
    this.trendData,
    this.lastCheck,
  });
}

/// ASW Observatory Organism — Status Grid
///
/// Responsive grid of [DSHealthCard] widgets for monitoring 50+ services.
///
/// Contract:
/// - Uses [GridView.builder] with lazy rendering for performance.
/// - Supports filtering by [DSOperationalState] via [activeFilter].
/// - Shows [DSStateSurface.empty] when no items match the filter.
/// - Optional [maxCrossAxisExtent] controls card width (default 320).
/// - Optional [childAspectRatio] controls card shape (default 1.6).
/// - Supports an optional filter bar via [showFilterBar].
class DSStatusGrid extends StatelessWidget {
  /// List of service health data to render.
  final List<DSHealthCardData> items;

  /// Set of states to show. Null or empty = show all.
  final Set<DSOperationalState>? activeFilter;

  /// Maximum cross-axis extent per grid item. Default 320.
  final double maxCrossAxisExtent;

  /// Aspect ratio of each grid item. Default 1.6.
  final double childAspectRatio;

  /// Spacing between grid items. Default 12.
  final double mainAxisSpacing;

  /// Spacing between grid items cross-axis. Default 12.
  final double crossAxisSpacing;

  /// Whether to show the state filter bar above the grid. Default false.
  final bool showFilterBar;

  /// Callback when a filter chip is toggled. Provides the toggled state.
  final ValueChanged<DSOperationalState>? onFilterToggle;

  /// Callback when a health card is tapped.
  final ValueChanged<DSHealthCardData>? onItemTap;

  const DSStatusGrid({
    super.key,
    required this.items,
    this.activeFilter,
    this.maxCrossAxisExtent = 320,
    this.childAspectRatio = 1.6,
    this.mainAxisSpacing = 12,
    this.crossAxisSpacing = 12,
    this.showFilterBar = false,
    this.onFilterToggle,
    this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    final filteredItems = _applyFilter(items, activeFilter);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Filter bar
        if (showFilterBar) ...[
          _buildFilterBar(),
          const SizedBox(height: DSSpacing.md),
        ],

        // Grid or empty state
        if (filteredItems.isEmpty)
          DSStateSurface.empty(
            icon: Icons.filter_list_off,
            title: 'No services match filter',
            subtitle: 'Try adjusting the operational state filter',
            compact: true,
          )
        else
          Semantics(
            label: 'Service health grid: ${filteredItems.length} services',
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: maxCrossAxisExtent,
                mainAxisSpacing: mainAxisSpacing,
                crossAxisSpacing: crossAxisSpacing,
                childAspectRatio: childAspectRatio,
              ),
              itemCount: filteredItems.length,
              itemBuilder: (context, index) {
                final item = filteredItems[index];
                return DSHealthCard(
                  serviceName: item.serviceName,
                  operationalState: item.operationalState,
                  latency: item.latency,
                  uptimePercent: item.uptimePercent,
                  trendData: item.trendData,
                  lastCheck: item.lastCheck,
                  onTap: onItemTap != null ? () => onItemTap!(item) : null,
                );
              },
            ),
          ),
      ],
    );
  }

  List<DSHealthCardData> _applyFilter(
    List<DSHealthCardData> items,
    Set<DSOperationalState>? filter,
  ) {
    if (filter == null || filter.isEmpty) return items;
    return items
        .where((item) => filter.contains(item.operationalState))
        .toList();
  }

  Widget _buildFilterBar() {
    // Count items per state for filter chip badges
    final stateCounts = <DSOperationalState, int>{};
    for (final item in items) {
      stateCounts[item.operationalState] =
          (stateCounts[item.operationalState] ?? 0) + 1;
    }

    // Build filter options from states present in data
    final presentStates = stateCounts.keys.toList()
      ..sort((a, b) => a.index.compareTo(b.index));

    final options = presentStates.map((state) {
      return DSFilterOption(
        value: state.name,
        label: state.label,
        icon: state.icon,
        color: state.color,
        count: stateCounts[state],
      );
    }).toList();

    final selected = activeFilter?.map((s) => s.name).toSet() ?? <String>{};

    return DSFilterChipGroup(
      options: options,
      selected: selected,
      onToggle: onFilterToggle != null
          ? (value) {
              final state = DSOperationalState.values.byName(value);
              onFilterToggle!(state);
            }
          : null,
    );
  }
}
