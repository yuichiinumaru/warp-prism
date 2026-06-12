/// Typed workspace snapshot aggregate for the Warp-Prism ASW Observatory.
///
/// Aggregates parsed [WorkspaceAsset] collections by kind, task lane
/// breakdowns, relationship edges, derived metrics, and scan metadata
/// into a single immutable result that repositories and providers can
/// return without coupling to specific file-system or asset-bundle backends.
library;

import 'package:flutter/foundation.dart';
import 'workspace_graph.dart';
import 'task_contracts.dart';

/// Aggregate result of loading or scanning a workspace.
///
/// Holds typed asset collections, task lane breakdown, relationship edges,
/// derived metrics, and scan metadata. Produced by [WorkspaceSource]
/// implementations and consumed by UI providers, graph services, and the
/// workspace snapshot page.
@immutable
class WorkspaceSnapshot {
  /// All agent assets discovered in the workspace.
  final List<WorkspaceAsset> agents;

  /// All skill and sub-skill assets discovered in the workspace.
  final List<WorkspaceAsset> skills;

  /// All workflow assets discovered in the workspace.
  final List<WorkspaceAsset> workflows;

  /// All task assets discovered in the workspace.
  final List<WorkspaceAsset> tasks;

  /// All changelog entry assets discovered in the workspace.
  final List<WorkspaceAsset> changelogEntries;

  /// Relationship edges across all assets (from frontmatter cross-references).
  final List<WorkspaceEdge> edges;

  /// Scan or load metadata (root path, timing, counts).
  final WorkspaceScanMetadata metadata;

  /// Total number of assets across all kinds.
  int get totalAssets =>
      agents.length +
      skills.length +
      workflows.length +
      tasks.length +
      changelogEntries.length;

  /// Task counts grouped by lane.
  ///
  /// Computed from [tasks] by inspecting [TaskMetadata] in each task's
  /// [WorkspaceAsset.frontmatter] map.
  Map<TaskLane, int> get tasksByLane {
    final counts = <TaskLane, int>{};
    for (final lane in TaskLane.values) {
      counts[lane] = 0;
    }
    for (final task in tasks) {
      final taskMeta = task.frontmatter['_taskMetadata'] as TaskMetadata?;
      final lane = taskMeta?.lane ?? TaskLane.open;
      counts[lane] = (counts[lane] ?? 0) + 1;
    }
    return counts;
  }

  // ---------------------------------------------------------------------------
  // Derived metrics
  // ---------------------------------------------------------------------------

  /// Count of tasks that have blockers (depends_on entries).
  int get blockedTaskCount {
    var count = 0;
    for (final task in tasks) {
      final meta = task.frontmatter['_taskMetadata'] as TaskMetadata?;
      if (meta != null && meta.dependsOn.isNotEmpty) count++;
    }
    return count;
  }

  /// Count of tasks in the review lane (03-review).
  int get reviewQueueCount {
    var count = 0;
    for (final task in tasks) {
      final meta = task.frontmatter['_taskMetadata'] as TaskMetadata?;
      if (meta != null && meta.lane == TaskLane.review) count++;
    }
    return count;
  }

  /// Count of tasks without verification commands.
  int get tasksWithoutVerification {
    var count = 0;
    for (final task in tasks) {
      final meta = task.frontmatter['_taskMetadata'] as TaskMetadata?;
      if (meta == null || meta.verificationCommands == null) count++;
    }
    return count;
  }

  /// Count of skills with no trigger phrases.
  int get skillsWithNoTriggers {
    var count = 0;
    for (final skill in skills) {
      if (skill.triggers.isEmpty) count++;
    }
    return count;
  }

  /// Count of orphan workflows (not referenced by any agent or skill).
  int get orphanWorkflowCount {
    final referencedIds = <String>{};
    for (final agent in agents) {
      for (final edge in agent.edges) {
        if (edge.kind == EdgeKind.uses || edge.kind == EdgeKind.references) {
          referencedIds.add(edge.targetId);
        }
      }
    }
    for (final skill in skills) {
      for (final edge in skill.edges) {
        if (edge.kind == EdgeKind.references ||
            edge.kind == EdgeKind.contains) {
          referencedIds.add(edge.targetId);
        }
      }
    }
    var count = 0;
    for (final wf in workflows) {
      if (!referencedIds.contains(wf.id)) count++;
    }
    return count;
  }

  /// Count of tasks with governance warnings (proof_state none or partial
  /// when in review or completed lane).
  int get governanceWarningCount {
    var count = 0;
    for (final task in tasks) {
      final meta = task.frontmatter['_taskMetadata'] as TaskMetadata?;
      if (meta == null) continue;
      if ((meta.lane == TaskLane.review || meta.lane == TaskLane.completed) &&
          (meta.proofState == ProofState.none ||
              meta.proofState == ProofState.partial)) {
        count++;
      }
    }
    return count;
  }

  const WorkspaceSnapshot({
    this.agents = const [],
    this.skills = const [],
    this.workflows = const [],
    this.tasks = const [],
    this.changelogEntries = const [],
    this.edges = const [],
    required this.metadata,
  });

  /// An empty snapshot with zero counts and the given root path.
  factory WorkspaceSnapshot.empty(String rootPath) {
    return WorkspaceSnapshot(
      metadata: WorkspaceScanMetadata(
        rootPath: rootPath,
        scannedAt: DateTime.now(),
      ),
    );
  }

  /// All assets as a flat iterable, regardless of kind.
  Iterable<WorkspaceAsset> get allAssets sync* {
    yield* agents;
    yield* skills;
    yield* workflows;
    yield* tasks;
    yield* changelogEntries;
  }

  /// Find an asset by its id. Returns null if not found.
  WorkspaceAsset? getAssetById(String id) {
    for (final asset in allAssets) {
      if (asset.id == id) return asset;
    }
    return null;
  }

  /// Search assets by query string matching name, description, tags, triggers.
  List<WorkspaceAsset> search(String query) {
    if (query.isEmpty) return allAssets.toList();
    final lower = query.toLowerCase();
    return allAssets.where((asset) {
      return asset.name.toLowerCase().contains(lower) ||
          asset.description.toLowerCase().contains(lower) ||
          asset.tags.any((t) => t.toLowerCase().contains(lower)) ||
          asset.triggers.any((t) => t.toLowerCase().contains(lower));
    }).toList();
  }

  /// Filter assets by kind.
  List<WorkspaceAsset> filterByKind(AssetKind kind) {
    return allAssets.where((a) => a.kind == kind).toList();
  }

  /// Filter tasks by lane.
  List<WorkspaceAsset> filterTasksByLane(TaskLane lane) {
    return tasks.where((task) {
      final meta = task.frontmatter['_taskMetadata'] as TaskMetadata?;
      return (meta?.lane ?? TaskLane.open) == lane;
    }).toList();
  }

  /// Filter assets by canonicality.
  List<WorkspaceAsset> filterByCanonicality(Canonicality canonicality) {
    return allAssets.where((a) => a.canonicality == canonicality).toList();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkspaceSnapshot &&
          runtimeType == other.runtimeType &&
          agents.length == other.agents.length &&
          skills.length == other.skills.length &&
          workflows.length == other.workflows.length &&
          tasks.length == other.tasks.length &&
          changelogEntries.length == other.changelogEntries.length;

  @override
  int get hashCode => Object.hash(
    agents.length,
    skills.length,
    workflows.length,
    tasks.length,
    changelogEntries.length,
  );

  @override
  String toString() =>
      'WorkspaceSnapshot(agents: ${agents.length}, skills: ${skills.length}, '
      'workflows: ${workflows.length}, tasks: ${tasks.length}, '
      'changelog: ${changelogEntries.length}, edges: ${edges.length})';
}

/// Metadata about a workspace scan or load operation.
@immutable
class WorkspaceScanMetadata {
  /// The root path that was scanned or loaded.
  final String rootPath;

  /// When the scan or load completed.
  final DateTime scannedAt;

  /// Total number of files examined during the scan.
  final int filesScanned;

  /// Number of files that failed to parse.
  final int parseErrors;

  /// Optional error message if the scan encountered a critical failure.
  final String? error;

  const WorkspaceScanMetadata({
    required this.rootPath,
    required this.scannedAt,
    this.filesScanned = 0,
    this.parseErrors = 0,
    this.error,
  });

  @override
  String toString() =>
      'WorkspaceScanMetadata(root: $rootPath, files: $filesScanned, '
      'errors: $parseErrors)';
}
