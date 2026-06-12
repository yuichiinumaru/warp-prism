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
import '../services/workspace_graph_builder.dart';
import '../services/workspace_graph.dart';
import '../services/workspace_metrics_service.dart';
import '../services/workspace_diagnostics_service.dart';
import '../sources/preset_local_workspace_source.dart';

// ---------------------------------------------------------------------------
// Configuration
// ---------------------------------------------------------------------------

/// The workspace root path, configurable via `--dart-define`.
const _workspaceRoot = String.fromEnvironment(
  'ASW_WORKSPACE_ROOT',
  defaultValue: '..',
);

/// Provides the configured workspace root path.
final workspaceRootPathProvider = Provider<String>((ref) => _workspaceRoot);

// ---------------------------------------------------------------------------
// Repository
// ---------------------------------------------------------------------------

/// Provides the [WorkspaceRepository] implementation.
///
/// Uses [MockWorkspaceRepository] for now; swap for a real repository
/// when the live workspace source is ready.
final workspaceRepositoryProvider = Provider<WorkspaceRepository>((ref) {
  return MockWorkspaceRepository(
    rootPath: ref.watch(workspaceRootPathProvider),
  );
});

/// Lightweight mock that uses [PresetLocalWorkspaceSource] internally.
///
/// This bridges the existing source-based loading to the repository
/// interface expected by the provider layer.
class MockWorkspaceRepository implements WorkspaceRepository {
  static const _source = PresetLocalWorkspaceSource();

  @override
  final String rootPath;

  const MockWorkspaceRepository({required this.rootPath});

  @override
  Future<WorkspaceLoadState> load() async {
    try {
      final snapshot = await _source.load(rootPath);
      if (snapshot.allAssets.isEmpty) {
        return WorkspaceLoadState.empty(rootPath: rootPath);
      }
      return WorkspaceLoadState.success(snapshot: snapshot, rootPath: rootPath);
    } catch (e) {
      return WorkspaceLoadState.error(
        message: e.toString(),
        rootPath: rootPath,
      );
    }
  }
}

// ---------------------------------------------------------------------------
// Snapshot Provider
// ---------------------------------------------------------------------------

/// Async notifier that loads the workspace snapshot via the repository.
///
/// Exposes loading, empty, error, and success states to consumers.
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
/// Consumers see [AsyncValue<WorkspaceLoadState>] which carries typed
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
/// Returns [WorkspaceGraphResult.empty()] during loading or on error.
/// Consumers should not need to handle loading states directly — the
/// graph is only available after a successful snapshot load.
final workspaceGraphAsyncProvider =
    AsyncNotifierProvider<WorkspaceGraphAsyncNotifier, WorkspaceGraphResult>(
      WorkspaceGraphAsyncNotifier.new,
    );

class WorkspaceGraphAsyncNotifier extends AsyncNotifier<WorkspaceGraphResult> {
  @override
  Future<WorkspaceGraphResult> build() async {
    final loadState = await ref.watch(workspaceSnapshotAsyncProvider.future);

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
/// Returns an empty summary during loading or when the graph is empty.
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
/// Returns an empty report during loading or when the graph is empty.
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
