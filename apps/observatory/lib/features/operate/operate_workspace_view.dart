/// Operate board surface for the ASW Observatory.
///
/// Renders the five canonical task lanes using [PrismLaneBoard] with
/// filter controls for lane, owner, skill, workflow, and proof state.
/// The board surface composes DS primitives directly (not via the
/// broken MasterDetailTemplate) and delegates all filter/group logic
/// to [OperateWorkspaceViewModel].
library;

import 'package:flutter/material.dart';
import 'package:warp_prism_observatory/data/models/task_contracts.dart';
import 'package:warp_prism_observatory/features/asset_detail/asset_detail.dart';
import 'package:warp_prism_observatory/features/operate/operate_filters.dart';
import 'package:warp_prism_observatory/features/operate/operate_storytelling.dart';
import 'package:warp_prism_observatory/features/operate/operate_workspace_view_model.dart';
import 'package:warp_prism_observatory/features/operate/task_projection.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

/// Main Operate board surface.
///
/// Renders a filter bar and a 5-lane kanban board. Filters are
/// managed by [OperateWorkspaceViewModel] — the view is purely
/// presentational.
class OperateWorkspaceView extends StatefulWidget {
  /// Optional initial projection to load.
  final OperateProjection? initialProjection;

  const OperateWorkspaceView({super.key, this.initialProjection});

  @override
  State<OperateWorkspaceView> createState() => _OperateWorkspaceViewState();
}

class _OperateWorkspaceViewState extends State<OperateWorkspaceView> {
  late final OperateWorkspaceViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = OperateWorkspaceViewModel();
    if (widget.initialProjection != null) {
      _viewModel.loadProjection(widget.initialProjection!);
    }
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<OperateBoardState>(
      stream: _viewModel.stateStream,
      initialData: _viewModel.state,
      builder: (context, snapshot) {
        final state = snapshot.data ?? _viewModel.state;
        final selectedTask = _taskById(state, state.selectedTaskId);

        // Shared responsive detail shell (Task 0905) — same contract as
        // Map/History: split-pane / overlay / full-screen by breakpoint.
        return AssetDetailConsumer(
          selectedAssetId: state.selectedTaskId,
          onDetailClose: _viewModel.deselectTask,
          detailTitle: selectedTask != null
              ? '${selectedTask.id} — ${selectedTask.title}'
              : null,
          detailKind: 'task',
          detailBuilder: (context, taskId) {
            final task = _taskById(state, taskId);
            if (task == null) {
              return const AssetDetailEmpty(
                message:
                    'Select a task card from the board to inspect its details',
              );
            }
            // Universal descriptor → AssetDetailView (Task 0905 path-to-100).
            return AssetDetailView(
              descriptor: descriptorFromTaskProjection(task),
              onClose: _viewModel.deselectTask,
            );
          },
          child: Column(
            children: [
              // Filter bar
              _FilterBar(
                filters: state.filters,
                filterOptions: state.filterOptions,
                viewModel: _viewModel,
              ),

              // Task counts
              _CountBar(
                filteredCount: state.filteredTaskCount,
                totalCount: state.totalTaskCount,
                isFiltered: state.filters.isActive,
                onClearFilters: _viewModel.clearFilters,
              ),

              // Storytelling panel — only when there are signals
              if (state.storyDiagnostics.hasSignals)
                _OperateStoryPanel(diagnostics: state.storyDiagnostics),

              // Board or state
              Expanded(child: _buildBoard(state)),
            ],
          ),
        );
      },
    );
  }

  TaskProjection? _taskById(OperateBoardState state, String? taskId) {
    if (taskId == null || taskId.isEmpty) {
      return null;
    }
    for (final task in state.allTasks) {
      if (task.id == taskId) {
        return task;
      }
    }
    return null;
  }

  Widget _buildBoard(OperateBoardState state) {
    // Loading state
    if (state.isLoading) {
      return Center(
        child: PrismStateSurface.loading(
          title: 'Loading tasks...',
          compact: true,
        ),
      );
    }

    // Error state
    if (state.error != null) {
      return Center(
        child: PrismStateSurface.error(
          icon: PrismIcons.error,
          title: 'Failed to load tasks',
          subtitle: state.error,
          actionLabel: 'Retry',
          onAction: () => _viewModel.clearError(),
        ),
      );
    }

    // Empty state
    if (state.allTasks.isEmpty) {
      return Center(
        child: PrismStateSurface.empty(
          icon: Icons.inbox_outlined,
          title: 'No tasks found',
          subtitle:
              'Tasks will appear here when the workspace has parsed task files.',
        ),
      );
    }

    // Build PrismLane objects from lane states
    final lanes = state.lanes.map((laneState) {
      return PrismLane(
        id: laneState.lane.directoryPrefix,
        label: _laneLabel(laneState.lane),
        tasks: laneState.tasks.map(_toLaneTask).toList(),
      );
    }).toList();

    return PrismLaneBoard(
      lanes: lanes,
      selectedTaskId: state.selectedTaskId,
      onTaskTap: _viewModel.selectTask,
    );
  }

  /// Convert a [TaskProjection] to a [PrismLaneTask].
  PrismLaneTask _toLaneTask(TaskProjection task) {
    return PrismLaneTask(
      id: int.tryParse(task.id.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0,
      title: task.title,
      priority: task.priority,
      owner: task.owner,
      proofState: task.proofState.name,
      reviewScore: task.reviewScore?.round(),
      linkedSkills: task.linkedSkills,
      dependencyCount: task.dependencyCount,
    );
  }

  String _laneLabel(TaskLane lane) {
    switch (lane) {
      case TaskLane.planning:
        return 'Planning';
      case TaskLane.open:
        return 'Open';
      case TaskLane.doing:
        return 'Doing';
      case TaskLane.review:
        return 'Review';
      case TaskLane.completed:
        return 'Completed';
    }
  }
}

/// Horizontal filter bar for the Operate board.
class _FilterBar extends StatelessWidget {
  final OperateFilters filters;
  final OperateFilterOptions filterOptions;
  final OperateWorkspaceViewModel viewModel;

  const _FilterBar({
    required this.filters,
    required this.filterOptions,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: PrismSpacing.md,
        vertical: PrismSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: PrismColors.obsidianElevated,
        border: Border(
          bottom: BorderSide(color: PrismColors.borderSubtle, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Search field
          Expanded(
            child: _SearchField(
              query: filters.query,
              onChanged: viewModel.updateQuery,
            ),
          ),
          const SizedBox(width: PrismSpacing.md),

          // Filter dropdowns
          _FilterDropdown<TaskLane>(
            label: 'Lane',
            value: filters.lane,
            items: TaskLane.values,
            itemLabel: (l) => _laneLabel(l),
            onChanged: (v) => viewModel.filterByLane(v),
            onClear: () => viewModel.filterByLane(null),
          ),
          const SizedBox(width: PrismSpacing.sm),

          _FilterDropdown<String>(
            label: 'Owner',
            value: filters.owner,
            items: filterOptions.owners,
            itemLabel: (o) => o,
            onChanged: (v) => viewModel.filterByOwner(v),
            onClear: () => viewModel.filterByOwner(null),
          ),
          const SizedBox(width: PrismSpacing.sm),

          _FilterDropdown<String>(
            label: 'Skill',
            value: filters.skill,
            items: filterOptions.skills,
            itemLabel: (s) => s,
            onChanged: (v) => viewModel.filterBySkill(v),
            onClear: () => viewModel.filterBySkill(null),
          ),
          const SizedBox(width: PrismSpacing.sm),

          _FilterDropdown<String>(
            label: 'Workflow',
            value: filters.workflow,
            items: filterOptions.workflows,
            itemLabel: (w) => w,
            onChanged: (v) => viewModel.filterByWorkflow(v),
            onClear: () => viewModel.filterByWorkflow(null),
          ),
          const SizedBox(width: PrismSpacing.sm),

          _FilterDropdown<ProofState>(
            label: 'Proof',
            value: filters.proofState,
            items: filterOptions.proofStates,
            itemLabel: (p) => p.name,
            onChanged: (v) => viewModel.filterByProofState(v),
            onClear: () => viewModel.filterByProofState(null),
          ),
        ],
      ),
    );
  }

  String _laneLabel(TaskLane lane) {
    switch (lane) {
      case TaskLane.planning:
        return 'Planning';
      case TaskLane.open:
        return 'Open';
      case TaskLane.doing:
        return 'Doing';
      case TaskLane.review:
        return 'Review';
      case TaskLane.completed:
        return 'Completed';
    }
  }
}

/// Search field for the filter bar.
class _SearchField extends StatefulWidget {
  final String query;
  final ValueChanged<String> onChanged;

  const _SearchField({required this.query, required this.onChanged});

  @override
  State<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<_SearchField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.query);
  }

  @override
  void didUpdateWidget(_SearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.query != _controller.text) {
      _controller.text = widget.query;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Search tasks',
      textField: true,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 48),
        child: TextField(
          controller: _controller,
          onChanged: widget.onChanged,
          style: PrismTypography.bodySmall.copyWith(
            color: PrismColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: 'Search tasks...',
            hintStyle: PrismTypography.bodySmall.copyWith(
              color: PrismColors.textTertiary,
            ),
            prefixIcon: PrismIcon.small(
              Icons.search,
              color: PrismColors.textTertiary,
            ),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: PrismSpacing.sm,
              vertical: PrismSpacing.xs,
            ),
            filled: true,
            fillColor: PrismColors.obsidianBase,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(PrismRadii.sm),
              borderSide: BorderSide(color: PrismColors.borderSubtle),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(PrismRadii.sm),
              borderSide: BorderSide(color: PrismColors.borderSubtle),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(PrismRadii.sm),
              borderSide: BorderSide(color: PrismColors.accentCyan, width: 1.5),
            ),
          ),
        ),
      ),
    );
  }
}

/// A filter dropdown for one dimension.
class _FilterDropdown<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<T> items;
  final String Function(T) itemLabel;
  final ValueChanged<T?> onChanged;
  final VoidCallback onClear;

  const _FilterDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$label filter',
      button: true,
      container: true,
      child: PopupMenuButton<T>(
        tooltip: '$label filter',
        onSelected: onChanged,
        itemBuilder: (context) => [
          if (value != null)
            PopupMenuItem<T>(
              value: null,
              onTap: onClear,
              child: PrismText.bodySmall(
                'Clear $label',
                color: PrismColors.textTertiary,
              ),
            ),
          for (final item in items)
            PopupMenuItem<T>(
              value: item,
              child: Row(
                children: [
                  if (item == value)
                    PrismIcon.small(Icons.check, color: PrismColors.accentCyan)
                  else
                    const SizedBox(width: 16),
                  const SizedBox(width: PrismSpacing.xs),
                  PrismText.bodySmall(
                    itemLabel(item),
                    color: item == value
                        ? PrismColors.accentCyan
                        : PrismColors.textPrimary,
                  ),
                ],
              ),
            ),
        ],
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48, minWidth: 48),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: PrismSpacing.sm,
              vertical: PrismSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: value != null
                  ? PrismColors.accentCyan.withValues(alpha: 0.15)
                  : PrismColors.obsidianBase,
              borderRadius: BorderRadius.circular(PrismRadii.sm),
              border: Border.all(
                color: value != null
                    ? PrismColors.accentCyan.withValues(alpha: 0.4)
                    : PrismColors.borderSubtle,
              ),
            ),
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                PrismText.labelSmall(
                  value != null ? itemLabel(value as T) : label,
                  color: value != null
                      ? PrismColors.accentCyan
                      : PrismColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_drop_down,
                  size: 16,
                  color: value != null
                      ? PrismColors.accentCyan
                      : PrismColors.textTertiary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Count bar showing filtered/total task counts.
class _CountBar extends StatelessWidget {
  final int filteredCount;
  final int totalCount;
  final bool isFiltered;
  final VoidCallback onClearFilters;

  const _CountBar({
    required this.filteredCount,
    required this.totalCount,
    required this.isFiltered,
    required this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: PrismSpacing.md,
        vertical: PrismSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: PrismColors.obsidianBase,
        border: Border(
          bottom: BorderSide(color: PrismColors.borderSubtle, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          PrismText.labelSmall(
            isFiltered
                ? '$filteredCount of $totalCount tasks'
                : '$totalCount tasks',
            color: PrismColors.textTertiary,
          ),
          const Spacer(),
          if (isFiltered)
            Semantics(
              button: true,
              label: 'Clear filters',
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
                child: PrismText.labelSmall(
                  'Clear filters',
                  color: PrismColors.accentCyan,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Storytelling panel for the Operate surface.
///
/// Renders operational risk insights using [PrismStoryPanel] to make
/// blocked work, review pressure, and proof-risk tasks visible
/// without opening each task individually.
class _OperateStoryPanel extends StatelessWidget {
  final OperateStoryDiagnostics diagnostics;

  const _OperateStoryPanel({required this.diagnostics});

  @override
  Widget build(BuildContext context) {
    final accentColor = _riskColor(diagnostics.overallRiskLevel);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: PrismSpacing.md,
        vertical: PrismSpacing.sm,
      ),
      child: PrismStoryPanel(
        title: 'Operational Risk',
        subtitle: _riskSubtitle(diagnostics.overallRiskLevel),
        icon: Icons.warning_amber_rounded,
        accentColor: accentColor,
        insights: diagnostics.insights.map(_toStoryInsight).toList(),
      ),
    );
  }

  Color _riskColor(StoryRiskLevel level) {
    switch (level) {
      case StoryRiskLevel.none:
        return PrismColors.accentCyan;
      case StoryRiskLevel.low:
        return PrismColors.accentCyan;
      case StoryRiskLevel.medium:
        return PrismColors.statusWarning;
      case StoryRiskLevel.high:
        return PrismColors.statusError;
      case StoryRiskLevel.critical:
        return PrismColors.statusError;
    }
  }

  String _riskSubtitle(StoryRiskLevel level) {
    switch (level) {
      case StoryRiskLevel.none:
        return 'No operational risks detected';
      case StoryRiskLevel.low:
        return 'Minor concerns — monitoring recommended';
      case StoryRiskLevel.medium:
        return 'Moderate risk — review recommended';
      case StoryRiskLevel.high:
        return 'High risk — action required';
      case StoryRiskLevel.critical:
        return 'Critical risk — immediate action required';
    }
  }

  PrismStoryInsight _toStoryInsight(OperateInsight insight) {
    return PrismStoryInsight(
      text: insight.title,
      detail: insight.detail,
      value: insight.value?.toString(),
      color: _riskColor(insight.riskLevel),
    );
  }
}
