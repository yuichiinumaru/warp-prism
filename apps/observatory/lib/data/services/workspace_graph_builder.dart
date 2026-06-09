/// Builds a canonical [WorkspaceGraphResult] from parsed workspace assets.
///
/// This is the single graph build pipeline that normalizes all assets
/// into one navigable graph with typed edges. Downstream consumers
/// (Map, Operate, History, Governance) should consume the result instead
/// of building their own relationship models.
///
/// The builder is pure and stateless — it takes assets and returns a graph.
library;

import '../models/workspace_graph.dart';
import '../models/task_contracts.dart';
import 'workspace_graph.dart';
import 'edge_inference_service.dart';

/// Builds a normalized workspace graph from a flat list of assets.
///
/// Usage:
/// ```dart
/// const builder = WorkspaceGraphBuilder();
/// final graph = builder.build(assets);
/// ```
class WorkspaceGraphBuilder {
  static const _edgeInference = EdgeInferenceService();

  const WorkspaceGraphBuilder();

  /// Build a canonical [WorkspaceGraphResult] from the given [assets].
  ///
  /// Steps:
  /// 1. Index assets by id and group by kind.
  /// 2. Collect all edges already present on each asset (from parsers).
  /// 3. Apply additional inference rules for metadata not yet covered.
  /// 4. Deduplicate edges by (sourceId, targetId, kind).
  /// 5. Return the canonical graph.
  WorkspaceGraphResult build(List<WorkspaceAsset> assets) {
    // Step 1: Index by id and group by kind
    final assetsById = <String, WorkspaceAsset>{};
    final assetsByKind = <AssetKind, List<WorkspaceAsset>>{};

    for (final kind in AssetKind.values) {
      assetsByKind[kind] = [];
    }

    for (final asset in assets) {
      assetsById[asset.id] = asset;
      assetsByKind[asset.kind]!.add(asset);
    }

    // Step 2: Collect all edges from asset-level edges (from parsers)
    final allEdges = <_EdgeKey, WorkspaceEdge>{};
    for (final asset in assets) {
      for (final edge in asset.edges) {
        allEdges[_EdgeKey(edge.sourceId, edge.targetId, edge.kind)] = edge;
      }
    }

    // Step 3: Apply additional inference rules
    for (final asset in assets) {
      switch (asset.kind) {
        case AssetKind.agent:
          _inferAgentEdges(asset, allEdges);
          break;
        case AssetKind.skill:
        case AssetKind.subskill:
          _inferSkillEdges(asset, allEdges, assetsById);
          break;
        case AssetKind.workflow:
          _inferWorkflowEdges(asset, allEdges, assetsById);
          break;
        case AssetKind.task:
          _inferTaskEdges(asset, allEdges);
          break;
        case AssetKind.changelog:
          _inferChangelogEdges(asset, allEdges);
          break;
        default:
          break;
      }
    }

    // Step 4: Return canonical graph
    return WorkspaceGraphResult(
      assetsById: assetsById,
      edges: allEdges.values.toList(),
      assetsByKind: assetsByKind,
    );
  }

  // ---------------------------------------------------------------------------
  // Agent inference
  // ---------------------------------------------------------------------------

  void _inferAgentEdges(
    WorkspaceAsset agent,
    Map<_EdgeKey, WorkspaceEdge> edges,
  ) {
    final fm = agent.frontmatter;
    // Agent → skills (uses relationship from frontmatter)
    final usageEdges = _edgeInference.inferAgentUsage(
      agentId: agent.id,
      skills: _parseStringList(fm['skills']),
      workflows: _parseStringList(fm['workflows']),
    );
    for (final edge in usageEdges) {
      edges[_EdgeKey(edge.sourceId, edge.targetId, edge.kind)] = edge;
    }
  }

  // ---------------------------------------------------------------------------
  // Skill inference
  // ---------------------------------------------------------------------------

  void _inferSkillEdges(
    WorkspaceAsset skill,
    Map<_EdgeKey, WorkspaceEdge> edges,
    Map<String, WorkspaceAsset> assetsById,
  ) {
    final fm = skill.frontmatter;

    // Containment: sub_skills
    final containment = _edgeInference.inferContainment(
      skillId: skill.id,
      subSkills: _parseStringList(fm['sub_skills']),
    );
    for (final edge in containment) {
      edges[_EdgeKey(edge.sourceId, edge.targetId, edge.kind)] = edge;
    }

    // Routing: routes_to field
    final routesTo = _parseStringList(fm['routes_to']);
    if (routesTo.isNotEmpty) {
      final routing = _edgeInference.inferRouting(
        skillId: skill.id,
        routesTo: routesTo,
      );
      for (final edge in routing) {
        edges[_EdgeKey(edge.sourceId, edge.targetId, edge.kind)] = edge;
      }
    }

    // Path-based containment for skill-local workflows
    final skillName = fm['name']?.toString() ?? '';
    if (skillName.isNotEmpty) {
      for (final entry in assetsById.entries) {
        if (entry.value.kind == AssetKind.workflow) {
          final pathEdge = _edgeInference.inferPathContainment(
            workflowPath: entry.value.path,
            skillDirectoryPattern: skillName,
          );
          if (pathEdge != null) {
            edges[_EdgeKey(pathEdge.sourceId, pathEdge.targetId, pathEdge.kind)] =
                pathEdge;
          }
        }
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Workflow inference
  // ---------------------------------------------------------------------------

  void _inferWorkflowEdges(
    WorkspaceAsset workflow,
    Map<_EdgeKey, WorkspaceEdge> edges,
    Map<String, WorkspaceAsset> assetsById,
  ) {
    final fm = workflow.frontmatter;
    final depEdges = _edgeInference.inferWorkflowDependencies(
      workflowId: workflow.id,
      usesSkills: _parseStringList(fm['uses_skills']),
    );
    for (final edge in depEdges) {
      edges[_EdgeKey(edge.sourceId, edge.targetId, edge.kind)] = edge;
    }
  }

  // ---------------------------------------------------------------------------
  // Task inference
  // ---------------------------------------------------------------------------

  void _inferTaskEdges(
    WorkspaceAsset task,
    Map<_EdgeKey, WorkspaceEdge> edges,
  ) {
    final fm = task.frontmatter;

    // References: skills and workflows
    final refEdges = _edgeInference.inferTaskReferences(
      taskId: task.id,
      skills: _parseStringList(fm['skills']),
      workflows: _parseStringList(fm['workflows']),
    );
    for (final edge in refEdges) {
      edges[_EdgeKey(edge.sourceId, edge.targetId, edge.kind)] = edge;
    }

    // Dependencies: depends_on
    final depEdges = _edgeInference.inferTaskDependencies(
      taskId: task.id,
      dependsOn: _parseStringList(fm['depends_on']),
    );
    for (final edge in depEdges) {
      edges[_EdgeKey(edge.sourceId, edge.targetId, edge.kind)] = edge;
    }

    // Proof linkage
    final taskMeta = fm['_taskMetadata'] as TaskMetadata?;
    if (taskMeta != null) {
      final proofEdges = _edgeInference.inferProofLinkage(
        taskId: task.id,
        proofState: taskMeta.proofState,
        hasVerificationCommands: taskMeta.verificationCommands != null,
      );
      for (final edge in proofEdges) {
        edges[_EdgeKey(edge.sourceId, edge.targetId, edge.kind)] = edge;
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Changelog inference
  // ---------------------------------------------------------------------------

  void _inferChangelogEdges(
    WorkspaceAsset changelog,
    Map<_EdgeKey, WorkspaceEdge> edges,
  ) {
    final fm = changelog.frontmatter;
    final clEdges = _edgeInference.inferChangelogLinkage(
      changelogId: changelog.id,
      task: fm['task']?.toString(),
    );
    for (final edge in clEdges) {
      edges[_EdgeKey(edge.sourceId, edge.targetId, edge.kind)] = edge;
    }
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  static List<String> _parseStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) return value.map((e) => e.toString()).toList();
    return [];
  }
}

/// Composite key for edge deduplication.
class _EdgeKey {
  final String sourceId;
  final String targetId;
  final EdgeKind kind;

  const _EdgeKey(this.sourceId, this.targetId, this.kind);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _EdgeKey &&
          sourceId == other.sourceId &&
          targetId == other.targetId &&
          kind == other.kind;

  @override
  int get hashCode => Object.hash(sourceId, targetId, kind);
}
