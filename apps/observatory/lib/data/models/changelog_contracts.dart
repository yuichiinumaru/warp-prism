/// Typed metadata contracts for changelog assets.
///
/// These classes represent changelog project/task/type/impact/skills
/// linkage as structured typed objects rather than loose string blobs
/// parsed from heading-based markdown.
library;

import 'package:flutter/foundation.dart';

/// Changelog entry type, matching the frontmatter `type` field.
enum ChangelogType {
  /// New feature or capability added.
  feature,

  /// Bug fix or correction.
  fix,

  /// Code or structure refactoring.
  refactor,

  /// Documentation changes.
  docs,

  /// Maintenance, tooling, or housekeeping.
  chore,

  /// Governance policy or audit change.
  governance,

  /// Audit result or compliance finding.
  audit,

  /// Migration or structural migration.
  migration,
}

/// Structured metadata for a changelog entry, extracted from YAML frontmatter.
///
/// Maps directly to the frontmatter schema: `id`, `date`, `project`,
/// `task`, `type`, `impact`, `skills`. Body sections (Why, Changed,
/// Evidence) are captured as string fields.
@immutable
class ChangelogMetadata {
  /// Changelog entry identifier (e.g., "2026-06-05-0310-backbone-audit").
  final String id;

  /// Date of the change.
  final DateTime date;

  /// Project this change belongs to (e.g., "warp-prism").
  final String project;

  /// Task id that motivated this change (e.g., "0310").
  final String task;

  /// Type of change.
  final ChangelogType type;

  /// Areas impacted by this change (e.g., ["parser", "graph-model"]).
  final List<String> impact;

  /// Skills related to this change.
  final List<String> skills;

  /// Why this change was made (from markdown body `## Why` section).
  final String? why;

  /// What was changed (from markdown body `## Changed` section).
  final String? changed;

  /// Evidence of the change (from markdown body `## Evidence` section).
  final String? evidence;

  const ChangelogMetadata({
    required this.id,
    required this.date,
    required this.project,
    required this.task,
    this.type = ChangelogType.chore,
    this.impact = const [],
    this.skills = const [],
    this.why,
    this.changed,
    this.evidence,
  });

  ChangelogMetadata copyWith({
    String? id,
    DateTime? date,
    String? project,
    String? task,
    ChangelogType? type,
    List<String>? impact,
    List<String>? skills,
    String? why,
    String? changed,
    String? evidence,
  }) {
    return ChangelogMetadata(
      id: id ?? this.id,
      date: date ?? this.date,
      project: project ?? this.project,
      task: task ?? this.task,
      type: type ?? this.type,
      impact: impact ?? this.impact,
      skills: skills ?? this.skills,
      why: why ?? this.why,
      changed: changed ?? this.changed,
      evidence: evidence ?? this.evidence,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChangelogMetadata &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          project == other.project &&
          task == other.task;

  @override
  int get hashCode => Object.hash(id, project, task);

  @override
  String toString() =>
      'ChangelogMetadata(id: $id, project: $project, task: $task, type: $type)';
}

/// Extension to parse [ChangelogType] from frontmatter strings.
extension ChangelogTypeParsing on ChangelogType {
  static ChangelogType fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'feature':
        return ChangelogType.feature;
      case 'fix':
        return ChangelogType.fix;
      case 'refactor':
        return ChangelogType.refactor;
      case 'docs':
        return ChangelogType.docs;
      case 'chore':
        return ChangelogType.chore;
      case 'governance':
        return ChangelogType.governance;
      case 'audit':
        return ChangelogType.audit;
      case 'migration':
        return ChangelogType.migration;
      default:
        return ChangelogType.chore;
    }
  }
}
