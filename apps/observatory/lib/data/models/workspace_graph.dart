/// Normalized graph backbone for the Warp-Prism ASW Observatory.
///
/// This is the canonical data contract that all parsers, repositories,
/// graph builders, and providers should target. It supersedes the legacy
/// [Asset]/[AssetType]/[AssetEdge] contract in `models.dart`.
library;

import 'package:flutter/foundation.dart';

/// Every graphable asset in the workspace has exactly one kind.
///
/// Covers all asset types required by the product contract:
/// agents, skills (super-skill root), subskills (child of super-skill),
/// workflows, tasks, changelog entries, scripts, references, and rules.
enum AssetKind {
  agent,
  skill,
  subskill,
  workflow,
  task,
  changelog,
  script,
  reference,
  rule,
}

/// Typed edge label for the workspace graph.
///
/// Replaces the freeform `edgeType: String` in the legacy [AssetEdge].
enum EdgeKind {
  /// super-skill -> sub-skill, skill -> skill-local workflow
  contains,

  /// gateway skill -> sub-skill or workflow (routing intent)
  routesTo,

  /// task/workflow/agent -> skill/rule/script/reference (dependency)
  dependsOn,

  /// generic cross-reference (agent -> skill, workflow -> skill, etc.)
  references,

  /// changelog entry -> task (what motivated this change)
  changedBy,

  /// task -> evidence (proof linkage)
  proves,

  /// agent -> skill/workflow (active usage)
  uses,
}

/// Provenance classification for workspace assets.
///
/// Distinguishes source-of-truth assets from generated projections,
/// child-local overlays, append-only ledgers, archived artifacts,
/// and mock/test data.
enum Canonicality {
  /// The canonical source-of-truth definition (e.g., parent skill root).
  parentCanonical,

  /// A child-local overlay or override (e.g., child project skill mirror).
  childLocal,

  /// A generated/read-model projection (e.g., tasklist.md, index files).
  generated,

  /// Append-only canonical ledger (e.g., changelog entries).
  appendOnly,

  /// Archived/legacy artifact kept for provenance but not active.
  archive,

  /// Mock or test data for development/demo purposes.
  mock,
}

/// A single node in the normalized workspace graph.
///
/// Every asset — agent, skill, workflow, task, changelog entry, script,
/// reference, or rule — is represented as a [WorkspaceAsset]. Typed
/// metadata for specific asset kinds (task lanes, changelog linkage,
/// governance diagnostics) lives in separate companion classes that
/// reference assets by [id].
@immutable
class WorkspaceAsset {
  /// Unique identifier (e.g., "agent:architect-orchestrator", "task:0310").
  final String id;

  /// The asset kind — exactly one of [AssetKind].
  final AssetKind kind;

  /// Human-readable name (from frontmatter `name` or derived from filename).
  final String name;

  /// Filesystem path relative to the workspace root.
  final String path;

  /// Description (from frontmatter or first markdown paragraph).
  final String description;

  /// Provenance classification.
  final Canonicality canonicality;

  /// Raw YAML frontmatter as parsed from the markdown file.
  /// Carries all fields that specific kind-parsers extract.
  final Map<String, dynamic> frontmatter;

  /// Tags from frontmatter.
  final List<String> tags;

  /// Trigger phrases (relevant for skills; empty for other kinds).
  final List<String> triggers;

  /// Edges originating from this asset.
  final List<WorkspaceEdge> edges;

  const WorkspaceAsset({
    required this.id,
    required this.kind,
    required this.name,
    required this.path,
    this.description = '',
    this.canonicality = Canonicality.parentCanonical,
    this.frontmatter = const {},
    this.tags = const [],
    this.triggers = const [],
    this.edges = const [],
  });

  WorkspaceAsset copyWith({
    String? id,
    AssetKind? kind,
    String? name,
    String? path,
    String? description,
    Canonicality? canonicality,
    Map<String, dynamic>? frontmatter,
    List<String>? tags,
    List<String>? triggers,
    List<WorkspaceEdge>? edges,
  }) {
    return WorkspaceAsset(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      name: name ?? this.name,
      path: path ?? this.path,
      description: description ?? this.description,
      canonicality: canonicality ?? this.canonicality,
      frontmatter: frontmatter ?? this.frontmatter,
      tags: tags ?? this.tags,
      triggers: triggers ?? this.triggers,
      edges: edges ?? this.edges,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkspaceAsset &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          kind == other.kind &&
          name == other.name &&
          path == other.path &&
          description == other.description &&
          canonicality == other.canonicality &&
          _listEquals(tags, other.tags) &&
          _listEquals(triggers, other.triggers);

  @override
  int get hashCode => Object.hash(id, kind, name, path, canonicality);

  @override
  String toString() =>
      'WorkspaceAsset(id: $id, kind: $kind, name: $name, path: $path)';
}

/// A typed, directed edge in the workspace graph.
///
/// Replaces the legacy [AssetEdge] which used a freeform [String] edge type.
@immutable
class WorkspaceEdge {
  /// Source asset id.
  final String sourceId;

  /// Target asset id.
  final String targetId;

  /// Typed edge label.
  final EdgeKind kind;

  /// Optional metadata (e.g., weight, condition, context).
  final Map<String, dynamic> metadata;

  const WorkspaceEdge({
    required this.sourceId,
    required this.targetId,
    required this.kind,
    this.metadata = const {},
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkspaceEdge &&
          runtimeType == other.runtimeType &&
          sourceId == other.sourceId &&
          targetId == other.targetId &&
          kind == other.kind;

  @override
  int get hashCode => Object.hash(sourceId, targetId, kind);

  @override
  String toString() =>
      'WorkspaceEdge($sourceId -[${kind.name}]-> $targetId)';
}

/// Helper for list equality in [WorkspaceAsset] and [WorkspaceEdge].
bool _listEquals<T>(List<T> a, List<T> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
