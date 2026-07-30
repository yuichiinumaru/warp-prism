import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/map/map_workspace.dart';
import '../../data/providers/workspace_providers.dart';

/// Map workspace — wired to the feature module.
///
/// This page renders the [MapWorkspacePage] with four subviews
/// (Agents, Skills, Workflows, Graph) using the feature-local
/// state contract. Graph edges come from [workspaceGraphAsyncProvider]
/// so modes see inferred containment/operational/evidence edges
/// (Task 0512 path-to-100 residual).
class MapPageShell extends ConsumerWidget {
  const MapPageShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loadStateAsync = ref.watch(workspaceSnapshotAsyncProvider);
    final graphAsync = ref.watch(workspaceGraphAsyncProvider);

    void onRetry() {
      ref.invalidate(workspaceSnapshotAsyncProvider);
      ref.invalidate(workspaceGraphAsyncProvider);
    }

    return loadStateAsync.when(
      data: (loadState) {
        final assets = loadState.snapshot?.allAssets.toList() ?? const [];
        final graph = graphAsync.asData?.value;
        // Prefer builder edges when available (may be empty list intentionally).
        final graphEdges = graph?.edges;
        return MapWorkspacePage(
          initialState: MapWorkspaceState(
            catalogAssets: assets,
            isLoading: false,
            error: loadState.errorMessage,
            graphEdges: graphEdges,
          ),
          onRetry: onRetry,
        );
      },
      loading: () => MapWorkspacePage(
        initialState: const MapWorkspaceState(isLoading: true),
        onRetry: onRetry,
      ),
      error: (error, _) => MapWorkspacePage(
        initialState: MapWorkspaceState(error: error.toString()),
        onRetry: onRetry,
      ),
    );
  }
}
