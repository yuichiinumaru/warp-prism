/// Workspace search bar integration.
///
/// Wraps [DSSearchBar] with Riverpod state management for the workspace
/// snapshot search feature.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';
import '../workspace_snapshot_provider.dart';

/// Search bar for the workspace snapshot page.
///
/// Connects to [searchQueryProvider] and shows active filter count.
class WorkspaceSearchBar extends ConsumerWidget {
  const WorkspaceSearchBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(searchQueryProvider);
    final kindFilters = ref.watch(kindFilterProvider);
    final laneFilters = ref.watch(laneFilterProvider);
    final canonFilters = ref.watch(canonicalityFilterProvider);
    final activeFilterCount =
        kindFilters.length + laneFilters.length + canonFilters.length;

    return DSSearchBar(
      value: query,
      placeholder: 'Search assets by name, description, tags...',
      onChanged: (value) {
        ref.read(searchQueryProvider.notifier).state = value;
      },
      onClear: () {
        ref.read(searchQueryProvider.notifier).state = '';
      },
      activeFilterCount: activeFilterCount > 0 ? activeFilterCount : null,
      autofocus: false,
    );
  }
}
