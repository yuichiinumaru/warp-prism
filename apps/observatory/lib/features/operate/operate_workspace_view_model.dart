/// View model for the Operate board surface.
///
/// Consumes [OperateProjection] from Task 0610 and manages:
/// - Lane grouping and counts
/// - Filter derivation and application
/// - Task selection
/// - Filter options (unique owners, skills, workflows, proof states)
///
/// The view model is purely presentational logic — it does not own
/// data loading or parsing. Data is injected via [loadProjection].
library;

import 'dart:async';

import 'package:warp_prism_observatory/data/models/task_contracts.dart';
import 'package:warp_prism_observatory/features/operate/operate_filters.dart';
import 'package:warp_prism_observatory/features/operate/operate_storytelling.dart';
import 'package:warp_prism_observatory/features/operate/task_projection.dart';

/// View model for the Operate board surface.
class OperateWorkspaceViewModel {
  /// Current filter state.
  OperateFilters _filters = OperateFilters.none;

  /// All task projections from the data layer.
  List<TaskProjection> _allTasks = const [];

  /// Currently selected task id (null = nothing selected).
  String? _selectedTaskId;

  /// Whether data is loading.
  bool _isLoading = false;

  /// Error message if loading failed.
  String? _error;

  /// Stream controller for state changes.
  final _controller = StreamController<OperateBoardState>.broadcast();

  /// Current state snapshot.
  OperateBoardState get state => OperateBoardState(
    filters: _filters,
    lanes: _buildLanes(),
    allTasks: _allTasks,
    selectedTaskId: _selectedTaskId,
    isLoading: _isLoading,
    error: _error,
    filterOptions: _buildFilterOptions(),
    storyDiagnostics: deriveOperateStoryDiagnostics(_allTasks),
  );

  /// Stream of state changes.
  Stream<OperateBoardState> get stateStream => _controller.stream;

  // ---------------------------------------------------------------------------
  // Data loading
  // ---------------------------------------------------------------------------

  /// Load task projections into the view model.
  void loadProjection(OperateProjection projection) {
    _allTasks = projection.allTasks;
    _isLoading = false;
    _error = null;
    _emit();
  }

  /// Set loading state.
  void setLoading(bool loading) {
    _isLoading = loading;
    _emit();
  }

  /// Set error state.
  void setError(String error) {
    _error = error;
    _isLoading = false;
    _emit();
  }

  /// Clear error.
  void clearError() {
    _error = null;
    _emit();
  }

  // ---------------------------------------------------------------------------
  // Filters
  // ---------------------------------------------------------------------------

  /// Current filters.
  OperateFilters get filters => _filters;

  /// Set the lane filter.
  void filterByLane(TaskLane? lane) {
    _filters = lane == null
        ? _filters.copyWith(clearLane: true)
        : _filters.copyWith(lane: lane);
    _emit();
  }

  /// Set the owner filter.
  void filterByOwner(String? owner) {
    _filters = owner == null
        ? _filters.copyWith(clearOwner: true)
        : _filters.copyWith(owner: owner);
    _emit();
  }

  /// Set the skill filter.
  void filterBySkill(String? skill) {
    _filters = skill == null
        ? _filters.copyWith(clearSkill: true)
        : _filters.copyWith(skill: skill);
    _emit();
  }

  /// Set the workflow filter.
  void filterByWorkflow(String? workflow) {
    _filters = workflow == null
        ? _filters.copyWith(clearWorkflow: true)
        : _filters.copyWith(workflow: workflow);
    _emit();
  }

  /// Set the proof state filter.
  void filterByProofState(ProofState? proofState) {
    _filters = proofState == null
        ? _filters.copyWith(clearProofState: true)
        : _filters.copyWith(proofState: proofState);
    _emit();
  }

  /// Update search query.
  void updateQuery(String query) {
    _filters = _filters.copyWith(query: query);
    _emit();
  }

  /// Clear all filters.
  void clearFilters() {
    _filters = OperateFilters.none;
    _emit();
  }

  // ---------------------------------------------------------------------------
  // Selection
  // ---------------------------------------------------------------------------

  /// Currently selected task id.
  String? get selectedTaskId => _selectedTaskId;

  /// Select a task by id.
  void selectTask(String taskId) {
    _selectedTaskId = taskId;
    _emit();
  }

  /// Deselect the current task.
  void deselectTask() {
    _selectedTaskId = null;
    _emit();
  }

  // ---------------------------------------------------------------------------
  // Internal
  // ---------------------------------------------------------------------------

  /// Build lane groupings from the filtered task list.
  List<OperateLaneState> _buildLanes() {
    final filtered = _applyFilters(_allTasks);

    return TaskLane.values.map((lane) {
      final laneTasks = filtered.where((t) => t.lane == lane).toList();
      final totalCount = _allTasks.where((t) => t.lane == lane).length;
      return OperateLaneState(
        lane: lane,
        tasks: laneTasks,
        totalCount: totalCount,
        isFiltered: _filters.isActive,
      );
    }).toList();
  }

  /// Apply current filters to the task list.
  List<TaskProjection> _applyFilters(List<TaskProjection> tasks) {
    return tasks.where((task) {
      if (_filters.lane != null && task.lane != _filters.lane) return false;
      if (_filters.owner != null && task.owner != _filters.owner) return false;
      if (_filters.skill != null &&
          !task.linkedSkills.contains(_filters.skill)) {
        return false;
      }
      if (_filters.workflow != null &&
          !task.linkedWorkflows.contains(_filters.workflow)) {
        return false;
      }
      if (_filters.proofState != null &&
          task.proofState != _filters.proofState) {
        return false;
      }
      if (_filters.query.isNotEmpty) {
        final q = _filters.query.toLowerCase();
        if (!task.title.toLowerCase().contains(q) &&
            !task.id.toLowerCase().contains(q) &&
            !task.owner.toLowerCase().contains(q)) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  /// Build available filter options from the current task set.
  OperateFilterOptions _buildFilterOptions() {
    final owners = _allTasks.map((t) => t.owner).toSet().toList()..sort();
    final skills = _allTasks.expand((t) => t.linkedSkills).toSet().toList()
      ..sort();
    final workflows =
        _allTasks.expand((t) => t.linkedWorkflows).toSet().toList()..sort();
    final proofStates = _allTasks.map((t) => t.proofState).toSet().toList();

    return OperateFilterOptions(
      owners: owners,
      skills: skills,
      workflows: workflows,
      proofStates: proofStates,
    );
  }

  void _emit() {
    _controller.add(state);
  }

  /// Dispose of the stream controller.
  void dispose() {
    _controller.close();
  }
}

/// Snapshot of the Operate board state.
class OperateBoardState {
  final OperateFilters filters;
  final List<OperateLaneState> lanes;
  final List<TaskProjection> allTasks;
  final String? selectedTaskId;
  final bool isLoading;
  final String? error;
  final OperateFilterOptions filterOptions;
  final OperateStoryDiagnostics storyDiagnostics;

  const OperateBoardState({
    required this.filters,
    required this.lanes,
    required this.allTasks,
    this.selectedTaskId,
    this.isLoading = false,
    this.error,
    required this.filterOptions,
    this.storyDiagnostics = const OperateStoryDiagnostics.empty(),
  });

  /// Total task count across all lanes (unfiltered).
  int get totalTaskCount => allTasks.length;

  /// Total filtered task count.
  int get filteredTaskCount =>
      lanes.fold(0, (sum, lane) => sum + lane.tasks.length);
}

/// State for a single lane on the board.
class OperateLaneState {
  final TaskLane lane;
  final List<TaskProjection> tasks;
  final int totalCount;
  final bool isFiltered;

  const OperateLaneState({
    required this.lane,
    required this.tasks,
    required this.totalCount,
    this.isFiltered = false,
  });

  /// Number of tasks in this lane after filtering.
  int get filteredCount => tasks.length;

  /// Whether this lane has no tasks after filtering.
  bool get isEmpty => tasks.isEmpty;
}

/// Available filter options derived from the task set.
class OperateFilterOptions {
  final List<String> owners;
  final List<String> skills;
  final List<String> workflows;
  final List<ProofState> proofStates;

  const OperateFilterOptions({
    required this.owners,
    required this.skills,
    required this.workflows,
    required this.proofStates,
  });
}
