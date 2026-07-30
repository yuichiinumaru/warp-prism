/// History workspace page — the primary timeline experience.
///
/// Renders a chronological changelog timeline using [PrismTimeline],
/// wired to a [HistoryState] read model. Supports desktop-first
/// master/detail layout with filter controls for project, type,
/// task, skill/workflow, and impact_tags.
///
/// Supports three view modes: Timeline, Project Story, Impact Story.
///
/// All data comes from the shared History read model — no inline mocks.
library;

import 'package:flutter/material.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';
import 'package:warp_prism_observatory/data/repositories/history_repository.dart';
import 'package:warp_prism_observatory/features/asset_detail/asset_detail.dart';
import 'package:warp_prism_observatory/features/history/presentation/history_controller.dart';
import 'package:warp_prism_observatory/features/history/presentation/history_view_mode.dart';
import 'package:warp_prism_observatory/features/history/presentation/widgets/history_story_view.dart';
import 'package:warp_prism_observatory/features/history/presentation/widgets/history_impact_view.dart';

/// The main History workspace page.
///
/// Accepts a pre-built [HistoryState] from a provider/repository
/// to avoid embedding mock data in the widget tree.
class HistoryWorkspacePage extends StatefulWidget {
  /// The initial state from the read model.
  /// If null, starts with empty state (for router instantiation
  /// before a provider wires real data).
  final HistoryState? initialState;

  const HistoryWorkspacePage({super.key, this.initialState});

  @override
  State<HistoryWorkspacePage> createState() => _HistoryWorkspacePageState();
}

class _HistoryWorkspacePageState extends State<HistoryWorkspacePage> {
  late HistoryState _state;

  @override
  void initState() {
    super.initState();
    _state = widget.initialState ?? const HistoryState();
  }

  @override
  void didUpdateWidget(covariant HistoryWorkspacePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialState != null &&
        widget.initialState != oldWidget.initialState) {
      // Preserve local selection/filters when parent reloads data.
      _state = widget.initialState!.copyWith(
        activeFilters: _state.activeFilters,
        selectedEntryId: _state.selectedEntryId,
        viewMode: _state.viewMode,
      );
    }
  }

  void _toggleFilter(HistoryFilterCategory category, String value) {
    setState(() {
      final current = Set<String>.from(_state.activeFilters[category] ?? {});
      if (current.contains(value)) {
        current.remove(value);
      } else {
        current.add(value);
      }
      final next = Map<HistoryFilterCategory, Set<String>>.from(
        _state.activeFilters,
      );
      next[category] = current;
      _state = _state.copyWith(activeFilters: next);
    });
  }

  void _selectEntry(String id) {
    setState(() {
      _state = _state.copyWith(
        selectedEntryId: id == _state.selectedEntryId ? null : id,
        clearSelection: id == _state.selectedEntryId,
      );
    });
  }

  void _setViewMode(HistoryViewMode mode) {
    setState(() {
      _state = _state.copyWith(viewMode: mode);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_state.isLoading) {
      return const Center(
        child: PrismStateSurface.loading(
          icon: Icons.hourglass_empty,
          title: 'Loading history...',
          subtitle: 'Parsing changelog timeline',
        ),
      );
    }

    if (_state.error != null) {
      return PrismStateSurface.error(
        icon: PrismIcons.error,
        title: 'Failed to load history',
        subtitle: _state.error!,
        actionLabel: null,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildToolbar(),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: PrismSpacing.lg,
            vertical: PrismSpacing.xs,
          ),
          child: PrismText.labelSmall(
            '${_state.filteredEntries.length} of ${_state.allEntries.length} entries',
            color: PrismColors.textTertiary,
          ),
        ),
        Expanded(child: _buildContent()),
      ],
    );
  }

  Widget _buildToolbar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        PrismSpacing.lg,
        PrismSpacing.md,
        PrismSpacing.lg,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildViewModeSwitcher(),
          const SizedBox(height: PrismSpacing.sm),
          _buildFilterBar(),
        ],
      ),
    );
  }

  Widget _buildViewModeSwitcher() {
    return Semantics(
      label: 'History view mode',
      child: Row(
        children: [
          _ModeChip(
            label: 'Timeline',
            icon: Icons.timeline,
            isActive: _state.viewMode == HistoryViewMode.timeline,
            onTap: () => _setViewMode(HistoryViewMode.timeline),
          ),
          const SizedBox(width: PrismSpacing.xs),
          _ModeChip(
            label: 'Project Story',
            icon: Icons.auto_stories_outlined,
            isActive: _state.viewMode == HistoryViewMode.projectStory,
            onTap: () => _setViewMode(HistoryViewMode.projectStory),
          ),
          const SizedBox(width: PrismSpacing.xs),
          _ModeChip(
            label: 'Impact Story',
            icon: Icons.account_tree_outlined,
            isActive: _state.viewMode == HistoryViewMode.impactStory,
            onTap: () => _setViewMode(HistoryViewMode.impactStory),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterCategory(
            'Project',
            HistoryFilterCategory.project,
            Icons.folder_outlined,
          ),
          const SizedBox(width: PrismSpacing.md),
          _buildFilterCategory(
            'Type',
            HistoryFilterCategory.type,
            Icons.category_outlined,
          ),
          const SizedBox(width: PrismSpacing.md),
          _buildFilterCategory(
            'Task',
            HistoryFilterCategory.task,
            PrismIcons.task,
          ),
          const SizedBox(width: PrismSpacing.md),
          _buildFilterCategory(
            'Skills',
            HistoryFilterCategory.skillWorkflow,
            PrismIcons.skill,
          ),
          const SizedBox(width: PrismSpacing.md),
          _buildFilterCategory(
            'Impacts',
            HistoryFilterCategory.impactTag,
            Icons.label_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterCategory(
    String label,
    HistoryFilterCategory category,
    IconData icon,
  ) {
    final options = _state.availableFilters(category);
    if (options.isEmpty) return const SizedBox.shrink();

    final selected = _state.activeFilters[category] ?? {};

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        PrismIcon.small(icon, color: PrismColors.textTertiary),
        const SizedBox(width: PrismSpacing.xs),
        PrismFilterChipGroup(
          options: options
              .map((o) => PrismFilterOption(value: o, label: o))
              .toList(),
          selected: selected,
          onToggle: (value) => _toggleFilter(category, value),
        ),
      ],
    );
  }

  Widget _buildContent() {
    switch (_state.viewMode) {
      case HistoryViewMode.timeline:
        return _buildTimeline();
      case HistoryViewMode.projectStory:
        return _buildProjectStory();
      case HistoryViewMode.impactStory:
        return _buildImpactStory();
    }
  }

  Widget _buildTimeline() {
    final entries = _state.toTimelineEntries();
    final selectedEntry = _state.selectedEntryId != null
        ? _state.allEntries
              .where((e) => e.id == _state.selectedEntryId)
              .firstOrNull
        : null;

    if (entries.isEmpty) {
      return const PrismStateSurface.empty(
        icon: Icons.history_outlined,
        title: 'No history entries',
        subtitle:
            'Changelog entries will appear here after the workspace timeline loads',
      );
    }

    final timeline = PrismTimeline(
      entries: entries,
      selectedId: _state.selectedEntryId,
      onEntryTap: _selectEntry,
      showFilters: false,
    );

    return ResponsiveDetailShell(
      showDetail: selectedEntry != null,
      onDetailClose: () => setState(() {
        _state = _state.copyWith(clearSelection: true);
      }),
      detailTitle: selectedEntry?.id,
      detailKind: 'changelog',
      masterContent: timeline,
      detailContent: selectedEntry != null
          ? _buildDetailPanel(selectedEntry)
          : const SizedBox.shrink(),
    );
  }

  Widget _buildProjectStory() {
    final groups = _state.toProjectStoryGroups();
    final selectedEntry = _state.selectedEntry;
    final master = HistoryStoryView(
      groups: groups,
      onEntryTap: _selectEntry,
      selectedEntryId: _state.selectedEntryId,
    );

    return ResponsiveDetailShell(
      showDetail: selectedEntry != null,
      onDetailClose: () => setState(() {
        _state = _state.copyWith(clearSelection: true);
      }),
      detailTitle: selectedEntry?.id,
      detailKind: 'changelog',
      masterContent: master,
      detailContent: selectedEntry != null
          ? _buildDetailPanel(selectedEntry)
          : const SizedBox.shrink(),
    );
  }

  Widget _buildImpactStory() {
    final nodes = _state.toImpactPathNodes();
    final selectedEntry = _state.selectedEntry;
    final master = HistoryImpactView(
      nodes: nodes,
      onEntryTap: _selectEntry,
      selectedEntryId: _state.selectedEntryId,
    );

    return ResponsiveDetailShell(
      showDetail: selectedEntry != null,
      onDetailClose: () => setState(() {
        _state = _state.copyWith(clearSelection: true);
      }),
      detailTitle: selectedEntry?.id,
      detailKind: 'changelog',
      masterContent: master,
      detailContent: selectedEntry != null
          ? _buildDetailPanel(selectedEntry)
          : const SizedBox.shrink(),
    );
  }

  /// Universal changelog detail via descriptor → [AssetDetailView]
  /// (Task 0905 path-to-100: no surface-local PrismDetailInspector).
  Widget _buildDetailPanel(HistoryEntry entry) {
    return AssetDetailView(
      descriptor: descriptorFromHistoryEntry(entry),
      onClose: () => setState(() {
        _state = _state.copyWith(clearSelection: true);
      }),
    );
  }
}

/// View mode chip for the mode switcher.
class _ModeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _ModeChip({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isActive,
      label: label,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(
                horizontal: PrismSpacing.sm,
                vertical: PrismSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: isActive
                    ? PrismColors.accentCyan.withValues(alpha: 0.15)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(PrismRadii.sm),
                border: Border.all(
                  color: isActive
                      ? PrismColors.accentCyan.withValues(alpha: 0.4)
                      : PrismColors.borderSubtle,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  PrismIcon.small(
                    icon,
                    color: isActive
                        ? PrismColors.accentCyan
                        : PrismColors.textTertiary,
                  ),
                  const SizedBox(width: PrismSpacing.xs),
                  PrismText.labelSmall(
                    label,
                    color: isActive
                        ? PrismColors.accentCyan
                        : PrismColors.textTertiary,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
