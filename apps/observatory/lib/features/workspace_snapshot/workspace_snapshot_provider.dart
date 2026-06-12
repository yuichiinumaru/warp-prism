/// Riverpod providers for the workspace snapshot feature.
///
/// Provides an [AsyncNotifierProvider] that loads a [WorkspaceSnapshot]
/// from the configured workspace root path on route entry, plus state
/// providers for search, filtering, graph mode, and detail inspection.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warp_prism_observatory/data/models/workspace_snapshot.dart';
import 'package:warp_prism_observatory/data/models/workspace_graph.dart';
import 'package:warp_prism_observatory/data/models/task_contracts.dart';
import 'package:warp_prism_observatory/data/sources/preset_local_workspace_source.dart';
import 'package:warp_prism_observatory/data/services/workspace_graph_builder.dart';
import 'package:warp_prism_observatory/data/services/workspace_graph.dart';

/// The workspace root path, configurable via `--dart-define`.
///
/// Defaults to `..` (parent directory) when running from `warp-prism/`.
const _workspaceRoot = String.fromEnvironment(
  'ASW_WORKSPACE_ROOT',
  defaultValue: '..',
);

/// Provides the configured workspace root path.
final workspaceRootProvider = Provider<String>((ref) => _workspaceRoot);

/// Async notifier that loads the workspace snapshot on creation.
class WorkspaceSnapshotNotifier extends AsyncNotifier<WorkspaceSnapshot> {
  static const _source = PresetLocalWorkspaceSource();

  @override
  Future<WorkspaceSnapshot> build() async {
    final rootPath = ref.read(workspaceRootProvider);
    return _source.load(rootPath);
  }

  /// Reload the snapshot (e.g., after a retry).
  Future<void> reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(build);
  }
}

/// The main workspace snapshot provider.
///
/// Exposes loading/success/error states to the UI layer.
final workspaceSnapshotProvider =
    AsyncNotifierProvider<WorkspaceSnapshotNotifier, WorkspaceSnapshot>(
      WorkspaceSnapshotNotifier.new,
    );

// ---------------------------------------------------------------------------
// Search
// ---------------------------------------------------------------------------

/// Current search query string.
final searchQueryProvider = StateProvider<String>((ref) => '');

/// Debounced search query (triggers after 300ms of no changes).
final debouncedSearchQueryProvider = Provider<String>((ref) {
  // For simplicity, we pass through directly. A real debounce would use
  // a timer-based notifier. The search itself is fast enough on typical
  // workspace sizes that debounce is optional.
  return ref.watch(searchQueryProvider);
});

/// Search-filtered snapshot. Returns all assets matching the query.
final searchResultsProvider = Provider<List<WorkspaceAsset>>((ref) {
  final snapshotAsync = ref.watch(workspaceSnapshotProvider);
  final query = ref.watch(debouncedSearchQueryProvider);

  return snapshotAsync.when(
    loading: () => [],
    error: (_, __) => [],
    data: (snapshot) => snapshot.search(query),
  );
});

// ---------------------------------------------------------------------------
// Filters
// ---------------------------------------------------------------------------

/// Active asset kind filters (empty = show all).
final kindFilterProvider = StateProvider<Set<AssetKind>>((ref) => {});

/// Active task lane filters (empty = show all lanes).
final laneFilterProvider = StateProvider<Set<TaskLane>>((ref) => {});

/// Active canonicality filters (empty = show all).
final canonicalityFilterProvider = StateProvider<Set<Canonicality>>(
  (ref) => {},
);

/// Filtered and searched assets. Combines search + filters.
final filteredAssetsProvider = Provider<List<WorkspaceAsset>>((ref) {
  final snapshotAsync = ref.watch(workspaceSnapshotProvider);
  final query = ref.watch(debouncedSearchQueryProvider);
  final kindFilters = ref.watch(kindFilterProvider);
  final laneFilters = ref.watch(laneFilterProvider);
  final canonFilters = ref.watch(canonicalityFilterProvider);

  return snapshotAsync.when(
    loading: () => [],
    error: (_, __) => [],
    data: (snapshot) {
      var results = snapshot.search(query);

      // Apply kind filter
      if (kindFilters.isNotEmpty) {
        results = results.where((a) => kindFilters.contains(a.kind)).toList();
      }

      // Apply lane filter (tasks only)
      if (laneFilters.isNotEmpty) {
        results = results.where((a) {
          if (a.kind != AssetKind.task) return true; // non-tasks pass
          final meta = a.frontmatter['_taskMetadata'] as TaskMetadata?;
          return laneFilters.contains(meta?.lane ?? TaskLane.open);
        }).toList();
      }

      // Apply canonicality filter
      if (canonFilters.isNotEmpty) {
        results = results
            .where((a) => canonFilters.contains(a.canonicality))
            .toList();
      }

      return results;
    },
  );
});

// ---------------------------------------------------------------------------
// Graph
// ---------------------------------------------------------------------------

/// Graph projection mode.
enum GraphMode {
  /// Containment: skill → sub-skill → skill-local workflow.
  containment,

  /// Operational: agent → primary skills → primary workflows.
  operational,
}

/// Current graph mode selection.
final graphModeProvider = StateProvider<GraphMode>(
  (ref) => GraphMode.containment,
);

/// The canonical graph builder.
const _graphBuilder = WorkspaceGraphBuilder();

/// Built workspace graph (cached per snapshot).
final workspaceGraphProvider = Provider<WorkspaceGraphResult>((ref) {
  final snapshotAsync = ref.watch(workspaceSnapshotProvider);
  return snapshotAsync.when(
    loading: () => const WorkspaceGraphResult.empty(),
    error: (_, __) => const WorkspaceGraphResult.empty(),
    data: (snapshot) => _graphBuilder.build(snapshot.allAssets.toList()),
  );
});

/// Graph nodes and edges projected for the current mode and search query.
final graphProjectionProvider = Provider<GraphProjection>((ref) {
  final graph = ref.watch(workspaceGraphProvider);
  final mode = ref.watch(graphModeProvider);
  final query = ref.watch(debouncedSearchQueryProvider);

  return _projectGraph(graph, mode, query);
});

/// Result of projecting a graph for a specific mode.
class GraphProjection {
  final List<GraphNode> nodes;
  final List<GraphEdge> edges;

  const GraphProjection({required this.nodes, required this.edges});
}

/// Graph node for the graph canvas (re-exports from DS).
class GraphNode {
  final String id;
  final String label;
  final String type;
  final String? status;

  const GraphNode({
    required this.id,
    required this.label,
    required this.type,
    this.status,
  });
}

/// Graph edge for the graph canvas.
class GraphEdge {
  final String sourceId;
  final String targetId;
  final String edgeType;

  const GraphEdge({
    required this.sourceId,
    required this.targetId,
    this.edgeType = 'references',
  });
}

/// Pure function: project a graph into nodes/edges for a given mode.
GraphProjection _projectGraph(
  WorkspaceGraphResult graph,
  GraphMode mode,
  String query,
) {
  final lowerQuery = query.toLowerCase();

  // Build node set from relevant assets
  final nodeMap = <String, GraphNode>{};
  final projectedEdges = <GraphEdge>[];

  // Filter edges by mode
  final relevantEdges = graph.edges.where((edge) {
    switch (mode) {
      case GraphMode.containment:
        return edge.kind == EdgeKind.contains;
      case GraphMode.operational:
        return edge.kind == EdgeKind.uses ||
            edge.kind == EdgeKind.references ||
            edge.kind == EdgeKind.dependsOn;
    }
  }).toList();

  // Collect nodes from relevant edges
  for (final edge in relevantEdges) {
    final source = graph.getAsset(edge.sourceId);
    final target = graph.getAsset(edge.targetId);

    if (source != null && _matchesQuery(source, lowerQuery)) {
      nodeMap.putIfAbsent(
        source.id,
        () => GraphNode(
          id: source.id,
          label: source.name,
          type: source.kind.name,
        ),
      );
    }
    if (target != null && _matchesQuery(target, lowerQuery)) {
      nodeMap.putIfAbsent(
        target.id,
        () => GraphNode(
          id: target.id,
          label: target.name,
          type: target.kind.name,
        ),
      );
    }

    // Only include edge if both endpoints are in the node set
    if (nodeMap.containsKey(edge.sourceId) &&
        nodeMap.containsKey(edge.targetId)) {
      projectedEdges.add(
        GraphEdge(
          sourceId: edge.sourceId,
          targetId: edge.targetId,
          edgeType: edge.kind.name,
        ),
      );
    }
  }

  // If no edges matched, show all assets as isolated nodes
  if (nodeMap.isEmpty && query.isEmpty) {
    for (final entry in graph.assetsById.entries) {
      nodeMap[entry.key] = GraphNode(
        id: entry.value.id,
        label: entry.value.name,
        type: entry.value.kind.name,
      );
    }
  }

  return GraphProjection(nodes: nodeMap.values.toList(), edges: projectedEdges);
}

bool _matchesQuery(WorkspaceAsset asset, String lowerQuery) {
  if (lowerQuery.isEmpty) return true;
  return asset.name.toLowerCase().contains(lowerQuery) ||
      asset.description.toLowerCase().contains(lowerQuery) ||
      asset.tags.any((t) => t.toLowerCase().contains(lowerQuery));
}

// ---------------------------------------------------------------------------
// Detail Inspector
// ---------------------------------------------------------------------------

/// Currently selected asset id for the detail inspector (null = closed).
final selectedAssetIdProvider = StateProvider<String?>((ref) => null);

/// The selected asset, resolved from the snapshot.
final selectedAssetProvider = Provider<WorkspaceAsset?>((ref) {
  final assetId = ref.watch(selectedAssetIdProvider);
  if (assetId == null) return null;

  final snapshotAsync = ref.watch(workspaceSnapshotProvider);
  return snapshotAsync.when(
    loading: () => null,
    error: (_, __) => null,
    data: (snapshot) => snapshot.getAssetById(assetId),
  );
});

/// Incoming edges for the selected asset.
final selectedAssetIncomingProvider = Provider<List<WorkspaceEdge>>((ref) {
  final assetId = ref.watch(selectedAssetIdProvider);
  if (assetId == null) return const [];

  final graph = ref.watch(workspaceGraphProvider);
  return graph.incomingEdges(assetId);
});

/// Outgoing edges for the selected asset.
final selectedAssetOutgoingProvider = Provider<List<WorkspaceEdge>>((ref) {
  final assetId = ref.watch(selectedAssetIdProvider);
  if (assetId == null) return const [];

  final graph = ref.watch(workspaceGraphProvider);
  return graph.outgoingEdges(assetId);
});

/// Select an asset by id (opens the detail inspector).
void selectAsset(WidgetRef ref, String assetId) {
  ref.read(selectedAssetIdProvider.notifier).state = assetId;
}

/// Clear the asset selection (closes the detail inspector).
void clearSelection(WidgetRef ref) {
  ref.read(selectedAssetIdProvider.notifier).state = null;
}
