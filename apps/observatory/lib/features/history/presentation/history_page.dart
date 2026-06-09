/// History workspace page — the primary timeline experience.
///
/// Renders a chronological changelog timeline using [DSTimeline],
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
import '../../../data/models/changelog_contracts.dart';
import '../../asset_detail/presentation/responsive_detail_shell.dart';
import 'history_controller.dart';
import 'history_view_mode.dart';
import 'widgets/history_story_view.dart';
import 'widgets/history_impact_view.dart';

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

  void _toggleFilter(HistoryFilterCategory category, String value) {
    setState(() {
      final current =
          Set<String>.from(_state.activeFilters[category] ?? {});
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
    // Loading state
    if (_state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: DSColors.accentCyan),
      );
    }

    // Error state
    if (_state.error != null) {
      return DSStateSurface.error(
        icon: DSIcons.error,
        title: 'Failed to load history',
        subtitle: _state.error!,
        actionLabel: null,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Mode switcher + Filter bar
        _buildToolbar(),

        // Result count
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: DSSpacing.lg,
            vertical: DSSpacing.xs,
          ),
          child: DSText.labelSmall(
            '${_state.filteredEntries.length} of ${_state.allEntries.length} entries',
            color: DSColors.textTertiary,
          ),
        ),

        // Main content area
        Expanded(
          child: _buildContent(),
        ),
      ],
    );
  }

  Widget _buildToolbar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        DSSpacing.lg,
        DSSpacing.md,
        DSSpacing.lg,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // View mode switcher
          _buildViewModeSwitcher(),
          const SizedBox(height: DSSpacing.sm),
          // Filter bar (scrolls horizontally)
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
          const SizedBox(width: DSSpacing.xs),
          _ModeChip(
            label: 'Project Story',
            icon: Icons.auto_stories_outlined,
            isActive: _state.viewMode == HistoryViewMode.projectStory,
            onTap: () => _setViewMode(HistoryViewMode.projectStory),
          ),
          const SizedBox(width: DSSpacing.xs),
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
          const SizedBox(width: DSSpacing.md),
          _buildFilterCategory(
            'Type',
            HistoryFilterCategory.type,
            Icons.category_outlined,
          ),
          const SizedBox(width: DSSpacing.md),
          _buildFilterCategory(
            'Task',
            HistoryFilterCategory.task,
            DSIcons.task,
          ),
          const SizedBox(width: DSSpacing.md),
          _buildFilterCategory(
            'Skills',
            HistoryFilterCategory.skillWorkflow,
            DSIcons.skill,
          ),
          const SizedBox(width: DSSpacing.md),
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
        DSIcon.small(icon, color: DSColors.textTertiary),
        const SizedBox(width: DSSpacing.xs),
        DSFilterChipGroup(
          options: options
              .map((o) => DSFilterOption(value: o, label: o))
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

    final timeline = DSTimeline(
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
    return HistoryStoryView(
      groups: groups,
      onEntryTap: _selectEntry,
      selectedEntryId: _state.selectedEntryId,
    );
  }

  Widget _buildImpactStory() {
    final nodes = _state.toImpactPathNodes();
    return HistoryImpactView(
      nodes: nodes,
      onEntryTap: _selectEntry,
      selectedEntryId: _state.selectedEntryId,
    );
  }

  Widget _buildDetailPanel(ChangelogMetadata entry) {
    return DSDetailInspector(
      title: entry.id,
      kind: 'changelog',
      subtitle: '${entry.project} • ${entry.type.name}',
      onClose: () => setState(() {
        _state = _state.copyWith(clearSelection: true);
      }),
      sections: [
        DSDetailSection(
          title: 'Metadata',
          icon: Icons.info_outline,
          child: Column(
            children: [
              DSPropertyRow(label: 'Project', value: entry.project),
              DSPropertyRow(label: 'Task', value: entry.task),
              DSPropertyRow(label: 'Type', value: entry.type.name),
              DSPropertyRow(
                label: 'Date',
                value:
                    '${entry.date.year}-${entry.date.month.toString().padLeft(2, '0')}-${entry.date.day.toString().padLeft(2, '0')}',
              ),
            ],
          ),
        ),
        if (entry.impact.isNotEmpty)
          DSDetailSection(
            title: 'Impact Tags',
            icon: Icons.label_outline,
            count: entry.impact.length,
            child: Wrap(
              spacing: DSSpacing.xs,
              runSpacing: DSSpacing.xs,
              children: entry.impact
                  .map((t) => DSChip(label: t))
                  .toList(),
            ),
          ),
        if (entry.why != null)
          DSDetailSection(
            title: 'Why',
            icon: Icons.question_mark,
            child: DSText.bodySmall(
              entry.why!,
              color: DSColors.textSecondary,
            ),
          ),
        if (entry.changed != null)
          DSDetailSection(
            title: 'Changed',
            icon: Icons.change_circle_outlined,
            child: DSText.bodySmall(
              entry.changed!,
              color: DSColors.textSecondary,
            ),
          ),
        if (entry.evidence != null)
          DSDetailSection(
            title: 'Evidence',
            icon: Icons.fact_check,
            child: DSText.bodySmall(
              entry.evidence!,
              color: DSColors.textSecondary,
            ),
          ),
      ],
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
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: DSSpacing.sm,
            vertical: DSSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: isActive
                ? DSColors.accentCyan.withOpacity(0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(DSRadii.sm),
            border: Border.all(
              color: isActive
                  ? DSColors.accentCyan.withOpacity(0.4)
                  : DSColors.borderSubtle,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              DSIcon.small(
                icon,
                color: isActive
                    ? DSColors.accentCyan
                    : DSColors.textTertiary,
              ),
              const SizedBox(width: DSSpacing.xs),
              DSText.labelSmall(
                label,
                color: isActive
                    ? DSColors.accentCyan
                    : DSColors.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
