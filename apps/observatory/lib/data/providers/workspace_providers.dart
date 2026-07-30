/// Canonical Riverpod providers for the Warp-Prism data backbone.
///
/// Exposes typed [AsyncNotifierProvider] instances for:
/// - Workspace snapshot loading
/// - Normalized graph building
/// - Derived metrics computation
/// - Governance diagnostics
///
/// All providers compose repository and service layers — they do not
/// own domain rules or duplicate data logic.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/workspace_repository.dart';
import '../repositories/workspace_load_state.dart';
import '../repositories/mock_workspace_repository.dart';
import '../repositories/history_repository.dart';
import '../services/workspace_graph_builder.dart';
import '../services/workspace_graph.dart';
import '../services/workspace_metrics_service.dart';
import '../services/workspace_diagnostics_service.dart';
import 'workspace_view_models.dart';

// ---------------------------------------------------------------------------
// Configuration
// ---------------------------------------------------------------------------

/// The workspace root path, configurable via `--dart-define`.
///
/// Defaults to the bundled mock corpus so providers work without extra
/// launch flags. Override with `ASW_WORKSPACE_ROOT` for live scans.
const _workspaceRoot = String.fromEnvironment(
  'ASW_WORKSPACE_ROOT',
  defaultValue: 'assets/mock_workspace',
);

/// Provides the configured workspace root path.
final workspaceRootPathProvider = Provider<String>((ref) => _workspaceRoot);

// ---------------------------------------------------------------------------
// Repository
// ---------------------------------------------------------------------------

/// Provides the [WorkspaceRepository] implementation.
///
/// Uses the canonical [MockWorkspaceRepository] from the repository layer.
/// Override in tests via [workspaceRepositoryProvider.overrideWithValue].
final workspaceRepositoryProvider = Provider<WorkspaceRepository>((ref) {
  return MockWorkspaceRepository(
    rootPath: ref.watch(workspaceRootPathProvider),
  );
});

// ---------------------------------------------------------------------------
// Snapshot Provider
// ---------------------------------------------------------------------------

/// Async notifier that loads the workspace snapshot via the repository.
///
/// Exposes loading, empty, error, and success states to consumers through
/// [AsyncValue] plus the typed [WorkspaceLoadState] payload.
class WorkspaceSnapshotAsyncNotifier extends AsyncNotifier<WorkspaceLoadState> {
  @override
  Future<WorkspaceLoadState> build() async {
    final repo = ref.read(workspaceRepositoryProvider);
    return repo.load();
  }

  /// Reload the workspace (e.g., after retry).
  Future<void> reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(build);
  }
}

/// The main workspace snapshot provider.
///
/// Consumers see [AsyncValue]<[WorkspaceLoadState]> which carries typed
/// loading/empty/error/success semantics.
final workspaceSnapshotAsyncProvider =
    AsyncNotifierProvider<WorkspaceSnapshotAsyncNotifier, WorkspaceLoadState>(
      WorkspaceSnapshotAsyncNotifier.new,
    );

// ---------------------------------------------------------------------------
// Graph Provider
// ---------------------------------------------------------------------------

const _graphBuilder = WorkspaceGraphBuilder();

/// Builds the normalized [WorkspaceGraphResult] from the loaded snapshot.
///
/// Returns [WorkspaceGraphResult.empty] when the snapshot is empty or missing.
/// Graph derivation only runs after a successful/empty snapshot load; repository
/// errors surface as [AsyncValue.error] on this provider as well.
final workspaceGraphAsyncProvider =
    AsyncNotifierProvider<WorkspaceGraphAsyncNotifier, WorkspaceGraphResult>(
      WorkspaceGraphAsyncNotifier.new,
    );

class WorkspaceGraphAsyncNotifier extends AsyncNotifier<WorkspaceGraphResult> {
  @override
  Future<WorkspaceGraphResult> build() async {
    final loadState = await ref.watch(workspaceSnapshotAsyncProvider.future);

    if (loadState.status == WorkspaceLoadStatus.error) {
      throw StateError(loadState.errorMessage ?? 'Workspace load failed');
    }

    if (loadState.status == WorkspaceLoadStatus.empty ||
        loadState.snapshot == null) {
      return const WorkspaceGraphResult.empty();
    }

    return _graphBuilder.build(loadState.snapshot!.allAssets.toList());
  }

  /// Rebuild the graph (triggers when snapshot changes).
  Future<void> rebuild() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(build);
  }
}

// ---------------------------------------------------------------------------
// Metrics Provider
// ---------------------------------------------------------------------------

const _metricsService = WorkspaceMetricsService();

/// Computes [WorkspaceMetricsSummary] from the normalized graph.
///
/// Returns an empty summary when the graph is empty.
final workspaceMetricsAsyncProvider =
    AsyncNotifierProvider<
      WorkspaceMetricsAsyncNotifier,
      WorkspaceMetricsSummary
    >(WorkspaceMetricsAsyncNotifier.new);

class WorkspaceMetricsAsyncNotifier
    extends AsyncNotifier<WorkspaceMetricsSummary> {
  @override
  Future<WorkspaceMetricsSummary> build() async {
    final graph = await ref.watch(workspaceGraphAsyncProvider.future);
    if (graph.isEmpty) return const WorkspaceMetricsSummary.empty();
    return _metricsService.compute(graph);
  }
}

// ---------------------------------------------------------------------------
// Diagnostics Provider
// ---------------------------------------------------------------------------

const _diagnosticsService = WorkspaceDiagnosticsService();

/// Computes [DiagnosticsReport] from the normalized graph.
///
/// Returns an empty report when the graph is empty.
final workspaceDiagnosticsAsyncProvider =
    AsyncNotifierProvider<WorkspaceDiagnosticsAsyncNotifier, DiagnosticsReport>(
      WorkspaceDiagnosticsAsyncNotifier.new,
    );

class WorkspaceDiagnosticsAsyncNotifier
    extends AsyncNotifier<DiagnosticsReport> {
  @override
  Future<DiagnosticsReport> build() async {
    final graph = await ref.watch(workspaceGraphAsyncProvider.future);
    if (graph.isEmpty) return const DiagnosticsReport.empty();
    return _diagnosticsService.analyze(graph);
  }
}

// ---------------------------------------------------------------------------
// History Timeline Provider
// ---------------------------------------------------------------------------

/// Provides the pure [HistoryRepository] used to build the History read model.
///
/// Override in tests via [historyRepositoryProvider.overrideWithValue].
final historyRepositoryProvider = Provider<HistoryRepository>((ref) {
  return const HistoryRepository();
});

/// Builds the [HistoryTimeline] from the loaded workspace snapshot.
///
/// Wires changelog entries plus task/skill/workflow assets into
/// [HistoryRepository.buildTimeline] so multi-hop impact edges
/// (`changelog -> task -> skill/workflow`) are available to consumers.
/// Returns [HistoryTimeline.empty] when the snapshot is empty or missing.
final historyTimelineAsyncProvider =
    AsyncNotifierProvider<HistoryTimelineAsyncNotifier, HistoryTimeline>(
      HistoryTimelineAsyncNotifier.new,
    );

class HistoryTimelineAsyncNotifier extends AsyncNotifier<HistoryTimeline> {
  @override
  Future<HistoryTimeline> build() async {
    final loadState = await ref.watch(workspaceSnapshotAsyncProvider.future);
    final historyRepo = ref.watch(historyRepositoryProvider);

    if (loadState.status == WorkspaceLoadStatus.error) {
      throw StateError(loadState.errorMessage ?? 'Workspace load failed');
    }

    if (loadState.status == WorkspaceLoadStatus.empty ||
        loadState.snapshot == null) {
      return const HistoryTimeline.empty();
    }

    final snapshot = loadState.snapshot!;
    return historyRepo.buildTimeline(
      snapshot.changelogEntries,
      tasks: snapshot.tasks,
      skills: snapshot.skills,
      workflows: snapshot.workflows,
    );
  }
}

// ---------------------------------------------------------------------------
// Shell view-model providers (compose metrics + diagnostics for UI)
// ---------------------------------------------------------------------------

/// Overview shell VM: metrics + diagnostics composition.
final overviewViewModelProvider = FutureProvider<WorkspaceOverviewViewModel>((
  ref,
) async {
  final metrics = await ref.watch(workspaceMetricsAsyncProvider.future);
  final diagnostics = await ref.watch(workspaceDiagnosticsAsyncProvider.future);
  return WorkspaceOverviewViewModel.from(
    metrics: metrics,
    diagnostics: diagnostics,
  );
});

/// Map shell VM: graph composition.
final mapViewModelProvider = FutureProvider<MapViewModel>((ref) async {
  final graph = await ref.watch(workspaceGraphAsyncProvider.future);
  return MapViewModel(graph: graph);
});

/// Operate shell VM: metrics composition.
final operateViewModelProvider = FutureProvider<OperateViewModel>((ref) async {
  final metrics = await ref.watch(workspaceMetricsAsyncProvider.future);
  return OperateViewModel.fromMetrics(metrics);
});

/// History shell VM: metrics composition.
final historyViewModelProvider = FutureProvider<HistoryViewModel>((ref) async {
  final metrics = await ref.watch(workspaceMetricsAsyncProvider.future);
  return HistoryViewModel.fromMetrics(metrics);
});

/// Governance shell VM: diagnostics composition.
final governanceViewModelProvider = FutureProvider<GovernanceViewModel>((
  ref,
) async {
  final report = await ref.watch(workspaceDiagnosticsAsyncProvider.future);
  return GovernanceViewModel.fromReport(report);
});
