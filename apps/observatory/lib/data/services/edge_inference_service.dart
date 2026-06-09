/// Edge inference rules for the workspace graph.
///
/// Encodes the logic that turns parsed frontmatter metadata into typed
/// [WorkspaceEdge] instances. Rules are applied from structured metadata
/// first; path heuristics complement only when the contract does not
/// expose the relationship explicitly.
///
/// This service is pure and stateless — all rules are static methods
/// that take parsed data and return edges.
library;

import '../models/workspace_graph.dart';
import '../models/task_contracts.dart';

/// Pure, stateless edge inference rules.
///
/// Each rule takes asset metadata and produces a list of [WorkspaceEdge].
/// The graph builder applies all rules and deduplicates the result.
class EdgeInferenceService {
  const EdgeInferenceService();

  // ---------------------------------------------------------------------------
  // Containment: super-skill → sub-skill, skill → skill-local workflow
  // ---------------------------------------------------------------------------

  /// Infer containment edges from skill frontmatter.
  ///
  /// - `sub_skills` list → [EdgeKind.contains] from this skill to each sub-skill.
  /// - Skill-local workflows (path under this skill's directory) →
  ///   [EdgeKind.contains].
  List<WorkspaceEdge> inferContainment({
    required String skillId,
    required List<String> subSkills,
    List<String>? skillLocalWorkflowIds,
  }) {
    final edges = <WorkspaceEdge>[];
    for (final sub in subSkills) {
      edges.add(WorkspaceEdge(
        sourceId: skillId,
        targetId: 'subskill:$sub',
        kind: EdgeKind.contains,
      ));
    }
    if (skillLocalWorkflowIds != null) {
      for (final wf in skillLocalWorkflowIds) {
        edges.add(WorkspaceEdge(
          sourceId: skillId,
          targetId: 'workflow:$wf',
          kind: EdgeKind.contains,
        ));
      }
    }
    return edges;
  }

  // ---------------------------------------------------------------------------
  // Routing: gateway skill → sub-skill or workflow
  // ---------------------------------------------------------------------------

  /// Infer routing edges from a gateway skill.
  ///
  /// Skills with a `routes_to` frontmatter field route to their targets.
  List<WorkspaceEdge> inferRouting({
    required String skillId,
    required List<String> routesTo,
  }) {
    return routesTo.map((target) => WorkspaceEdge(
      sourceId: skillId,
      targetId: target,
      kind: EdgeKind.routesTo,
    )).toList();
  }

  // ---------------------------------------------------------------------------
  // Dependency: task/workflow/agent → skill/rule/script/reference
  // ---------------------------------------------------------------------------

  /// Infer dependency edges from a workflow's `uses_skills` list.
  List<WorkspaceEdge> inferWorkflowDependencies({
    required String workflowId,
    required List<String> usesSkills,
  }) {
    return usesSkills.map((skill) => WorkspaceEdge(
      sourceId: workflowId,
      targetId: 'skill:$skill',
      kind: EdgeKind.dependsOn,
    )).toList();
  }

  /// Infer dependency edges from a task's `depends_on` list.
  List<WorkspaceEdge> inferTaskDependencies({
    required String taskId,
    required List<String> dependsOn,
  }) {
    return dependsOn.map((dep) => WorkspaceEdge(
      sourceId: taskId,
      targetId: 'task:$dep',
      kind: EdgeKind.dependsOn,
    )).toList();
  }

  // ---------------------------------------------------------------------------
  // References: generic cross-reference (agent → skill, task → skill, etc.)
  // ---------------------------------------------------------------------------

  /// Infer reference edges from an agent's `skills` and `workflows` lists.
  List<WorkspaceEdge> inferAgentReferences({
    required String agentId,
    required List<String> skills,
    required List<String> workflows,
  }) {
    final edges = <WorkspaceEdge>[];
    for (final skill in skills) {
      edges.add(WorkspaceEdge(
        sourceId: agentId,
        targetId: 'skill:$skill',
        kind: EdgeKind.references,
      ));
    }
    for (final wf in workflows) {
      edges.add(WorkspaceEdge(
        sourceId: agentId,
        targetId: 'workflow:$wf',
        kind: EdgeKind.references,
      ));
    }
    return edges;
  }

  /// Infer reference edges from a task's `skills` and `workflows` lists.
  List<WorkspaceEdge> inferTaskReferences({
    required String taskId,
    required List<String> skills,
    required List<String> workflows,
  }) {
    final edges = <WorkspaceEdge>[];
    for (final skill in skills) {
      edges.add(WorkspaceEdge(
        sourceId: taskId,
        targetId: 'skill:$skill',
        kind: EdgeKind.references,
      ));
    }
    for (final wf in workflows) {
      edges.add(WorkspaceEdge(
        sourceId: taskId,
        targetId: 'workflow:$wf',
        kind: EdgeKind.references,
      ));
    }
    return edges;
  }

  // ---------------------------------------------------------------------------
  // Changed-by: changelog entry → task
  // ---------------------------------------------------------------------------

  /// Infer changed-by edges from a changelog's `task` field.
  List<WorkspaceEdge> inferChangelogLinkage({
    required String changelogId,
    String? task,
  }) {
    if (task == null || task.isEmpty) return const [];
    return [
      WorkspaceEdge(
        sourceId: changelogId,
        targetId: 'task:$task',
        kind: EdgeKind.changedBy,
      ),
    ];
  }

  // ---------------------------------------------------------------------------
  // Proves: task → evidence
  // ---------------------------------------------------------------------------

  /// Infer proves edges from task proof_state and completion_evidence.
  ///
  /// When a task has verification commands or completion evidence,
  /// we can infer a proves relationship to the task itself as evidence.
  List<WorkspaceEdge> inferProofLinkage({
    required String taskId,
    ProofState? proofState,
    bool hasVerificationCommands = false,
  }) {
    if (proofState == null || proofState == ProofState.none) return const [];
    if (!hasVerificationCommands) return const [];
    // The proves edge is from the task to itself conceptually, but in
    // practice it's a metadata marker. We encode it as a self-reference
    // for now — downstream can filter self-loops if needed.
    return [
      WorkspaceEdge(
        sourceId: taskId,
        targetId: taskId,
        kind: EdgeKind.proves,
        metadata: {'proofState': proofState.name},
      ),
    ];
  }

  // ---------------------------------------------------------------------------
  // Usage: agent → skill/workflow (active usage)
  // ---------------------------------------------------------------------------

  /// Infer usage edges from an agent's skills and workflows.
  ///
  /// This is semantically different from [inferAgentReferences]:
  /// `uses` implies active runtime dependency, while `references` is
  /// a weaker cross-reference. Use `uses` when the frontmatter explicitly
  /// declares runtime usage (e.g., `uses_skills:` field).
  List<WorkspaceEdge> inferAgentUsage({
    required String agentId,
    required List<String> skills,
    required List<String> workflows,
  }) {
    final edges = <WorkspaceEdge>[];
    for (final skill in skills) {
      edges.add(WorkspaceEdge(
        sourceId: agentId,
        targetId: 'skill:$skill',
        kind: EdgeKind.uses,
      ));
    }
    for (final wf in workflows) {
      edges.add(WorkspaceEdge(
        sourceId: agentId,
        targetId: 'workflow:$wf',
        kind: EdgeKind.uses,
      ));
    }
    return edges;
  }

  // ---------------------------------------------------------------------------
  // Path heuristic: skill-local workflow from directory structure
  // ---------------------------------------------------------------------------

  /// Infer containment from filesystem path structure.
  ///
  /// A workflow at `skills/<skill-name>/workflows/<wf>.md` is considered
  /// skill-local and contained by that skill. This complements the
  /// structured metadata when the frontmatter doesn't explicitly declare
  /// the containment relationship.
  WorkspaceEdge? inferPathContainment({
    required String workflowPath,
    required String skillDirectoryPattern,
  }) {
    // Match pattern: .../skills/<name>/workflows/<file>.md
    final skillMatch = RegExp(
      r'/skills/([^/]+)/workflows/',
    ).firstMatch(workflowPath);
    if (skillMatch == null) return null;

    final skillName = skillMatch.group(1)!;
    return WorkspaceEdge(
      sourceId: 'skill:$skillName',
      targetId: 'workflow:${workflowPath.split('/').last.replaceAll('.md', '')}',
      kind: EdgeKind.contains,
    );
  }
}
