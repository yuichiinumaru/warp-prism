/// Overview dashboard — wired to the feature module and workspace providers.
///
/// This page demonstrates the shell-level state contract:
/// it shows loading → data → empty/error transitions using
/// [ShellStateHandler] for consistent fallback rendering.
///
/// Metrics are derived from [workspaceSnapshotAsyncProvider] and
/// [workspaceDiagnosticsAsyncProvider] via [OverviewProvider] — never
/// hardcoded in the widget tree.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/data_models.dart';
import '../../data/providers/workspace_providers.dart';
import '../../data/repositories/workspace_load_state.dart';
import '../../features/overview/overview.dart';
import '../../features/shell/shell_state_handler.dart';

/// Overview dashboard with shell-level state handling.
///
/// Demonstrates four distinct states:
/// 1. **Loading**: shown during initial data fetch
/// 2. **Data**: rendered by [OverviewPage] when metrics are available
/// 3. **Empty**: shown when workspace has no assets (still renders zero metrics)
/// 4. **Error**: shown when a load/parse failure occurs
class OverviewPageShell extends ConsumerWidget {
  /// Optional pre-computed metrics for widget tests.
  ///
  /// When non-null, the shell skips provider watches and renders
  /// [OverviewPage] directly. Production code leaves this null.
  final OverviewMetrics? forcedMetrics;

  /// Optional forced error message for widget tests.
  final String? forcedError;

  /// When true, renders the loading surface regardless of provider state.
  final bool forceLoading;

  const OverviewPageShell({
    super.key,
    this.forcedMetrics,
    this.forcedError,
    this.forceLoading = false,
  });

  static const _provider = OverviewProvider();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (forceLoading) {
      return ShellStateHandler.buildLoading(
        title: 'Loading workspace...',
        subtitle: 'Parsing repository data and computing metrics',
      );
    }

    if (forcedError != null) {
      return ShellStateHandler.buildError(
        title: 'Failed to load workspace',
        errorMessage: forcedError!,
      );
    }

    if (forcedMetrics != null) {
      return OverviewPage(metrics: forcedMetrics!);
    }

    final loadStateAsync = ref.watch(workspaceSnapshotAsyncProvider);
    final diagnosticsAsync = ref.watch(workspaceDiagnosticsAsyncProvider);

    return loadStateAsync.when(
      loading: () => ShellStateHandler.buildLoading(
        title: 'Loading workspace...',
        subtitle: 'Parsing repository data and computing metrics',
      ),
      error: (error, _) => ShellStateHandler.buildError(
        title: 'Failed to load workspace',
        errorMessage: error.toString(),
        onRetry: () => ref.invalidate(workspaceSnapshotAsyncProvider),
      ),
      data: (loadState) => _buildFromLoadState(
        loadState,
        diagnostics: diagnosticsAsync.asData?.value.diagnostics ?? const [],
        onRetry: () => ref.invalidate(workspaceSnapshotAsyncProvider),
      ),
    );
  }

  Widget _buildFromLoadState(
    WorkspaceLoadState loadState, {
    required List<GovernanceDiagnostic> diagnostics,
    required VoidCallback onRetry,
  }) {
    if (loadState.status == WorkspaceLoadStatus.error) {
      return ShellStateHandler.buildError(
        title: 'Failed to load workspace',
        errorMessage: loadState.errorMessage ?? 'An unexpected error occurred.',
        onRetry: onRetry,
      );
    }

    final assets = loadState.snapshot?.allAssets.toList() ?? const [];

    // Unified empty chrome via ShellStateHandler (Task 0413 path-to-100).
    if (assets.isEmpty) {
      return ShellStateHandler.buildEmpty(
        surfaceName: 'Overview',
        icon: Icons.dashboard_outlined,
        subtitle:
            'The workspace is loaded but contains no assets. '
            'Totals and operational risk will appear once the corpus is populated.',
        actionLabel: 'Retry load',
        onAction: onRetry,
      );
    }

    final metrics = _provider.compute(assets: assets, diagnostics: diagnostics);
    return OverviewPage(metrics: metrics);
  }
}
