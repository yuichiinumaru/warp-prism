/// Page for the Operate workspace (tasks, lanes).
///
/// Wires the Task 0610 workspace snapshot into [OperateWorkspaceView] so the
/// `/operate` route renders populated canonical lanes instead of the empty
/// state. Filter and board logic stay in the feature view model.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers/workspace_providers.dart';
import '../../data/repositories/workspace_load_state.dart';
import '../../features/operate/operate_projection_builder.dart';
import '../../features/operate/operate_workspace_view.dart';
import '../../features/operate/task_projection.dart';
import '../../features/shell/shell_state_handler.dart';

/// Operate page shell — loads the workspace projection and hosts the board.
class OperatePage extends ConsumerWidget {
  /// Optional forced projection for widget tests (skips provider watches).
  final OperateProjection? forcedProjection;

  /// Optional forced error message for widget tests.
  final String? forcedError;

  /// When true, renders the loading surface regardless of provider state.
  final bool forceLoading;

  const OperatePage({
    super.key,
    this.forcedProjection,
    this.forcedError,
    this.forceLoading = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (forceLoading) {
      return ShellStateHandler.buildLoading(
        title: 'Loading tasks...',
        subtitle: 'Parsing workspace task projections',
      );
    }

    if (forcedError != null) {
      return ShellStateHandler.buildError(
        title: 'Failed to load tasks',
        errorMessage: forcedError!,
      );
    }

    if (forcedProjection != null) {
      return OperateWorkspaceView(initialProjection: forcedProjection);
    }

    final loadStateAsync = ref.watch(workspaceSnapshotAsyncProvider);

    return loadStateAsync.when(
      loading: () => ShellStateHandler.buildLoading(
        title: 'Loading tasks...',
        subtitle: 'Parsing workspace task projections',
      ),
      error: (error, _) => ShellStateHandler.buildError(
        title: 'Failed to load tasks',
        errorMessage: error.toString(),
        onRetry: () => ref.invalidate(workspaceSnapshotAsyncProvider),
      ),
      data: (loadState) => _buildFromLoadState(
        loadState,
        onRetry: () => ref.invalidate(workspaceSnapshotAsyncProvider),
      ),
    );
  }

  Widget _buildFromLoadState(
    WorkspaceLoadState loadState, {
    required VoidCallback onRetry,
  }) {
    if (loadState.status == WorkspaceLoadStatus.error) {
      return ShellStateHandler.buildError(
        title: 'Failed to load tasks',
        errorMessage: loadState.errorMessage ?? 'An unexpected error occurred.',
        onRetry: onRetry,
      );
    }

    if (loadState.status == WorkspaceLoadStatus.loading) {
      return ShellStateHandler.buildLoading(
        title: 'Loading tasks...',
        subtitle: 'Parsing workspace task projections',
      );
    }

    final tasks = loadState.snapshot?.tasks ?? const [];
    final projection = buildOperateProjection(tasks);

    // Empty corpus still mounts the board surface so five empty lanes and
    // filter chrome remain reachable for operators.
    return OperateWorkspaceView(initialProjection: projection);
  }
}
