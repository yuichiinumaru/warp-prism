/// Operate task projection contract.
///
/// Defines the structured read model that the Operate surface consumes
/// to render task cards, lane boards, inspectors, and filters. This
/// projection is derived from parsed task markdown files — it does not
/// duplicate parsing logic or depend on the legacy queue.md format.
library;

import 'package:flutter/foundation.dart';
import 'package:warp_prism_observatory/data/models/task_contracts.dart';

/// Structured projection of a single task for the Operate surface.
///
/// Contains all fields required by [DSTaskCard] and the inspector,
/// plus raw body text for later inspector rendering. The projection
/// is lane-neutral — the lane is a mutable status field, not part
/// of the task's identity.
@immutable
class TaskProjection {
  /// Task identifier from frontmatter (e.g., "T009").
  final String id;

  /// Filename-derived slug without extension (e.g., "T009-implement-task-lane-board-ui").
  final String slug;

  /// Human-readable title from frontmatter.
  final String title;

  /// Current lane (derived from directory path, with status fallback).
  final TaskLane lane;

  /// Declared status label from frontmatter (e.g., "doing", "review").
  final String statusLabel;

  /// Task type from frontmatter (e.g., "feature", "bugfix").
  final String type;

  /// Priority label (e.g., "P0", "P1", "P2", "high", "medium").
  final String priority;

  /// Owner agent or person.
  final String owner;

  /// Proof/verification state.
  final ProofState proofState;

  /// Review score (null if not yet reviewed or "n/a").
  final double? reviewScore;

  /// Skill names this task relates to.
  final List<String> linkedSkills;

  /// Workflow names this task uses.
  final List<String> linkedWorkflows;

  /// Task IDs this task depends on.
  final List<String> dependsOn;

  /// Task IDs or asset IDs currently blocking this task.
  final List<String> blockers;

  /// Creation date.
  final DateTime created;

  /// Last update date.
  final DateTime updated;

  /// Verification commands extracted from the Verification/Validation Commands section.
  final List<String> verificationCommands;

  /// Completion evidence text from the task body.
  final String? completionEvidenceSummary;

  /// Structured evidence rows (bullet/key-value) from Completion Evidence.
  final List<EvidenceRow> completionEvidenceRows;

  /// Named markdown body sections (heading → body text).
  final List<MarkdownSection> sections;

  /// Exit conditions as structured items.
  final List<ExitCondition> exitConditions;

  /// Raw markdown body for inspector rendering.
  final String bodyMarkdown;

  /// Filesystem path where this task file lives.
  final String filePath;

  const TaskProjection({
    required this.id,
    this.slug = '',
    required this.title,
    required this.lane,
    this.statusLabel = '',
    this.type = 'task',
    this.priority = 'P2',
    this.owner = 'unassigned',
    this.proofState = ProofState.none,
    this.reviewScore,
    this.linkedSkills = const [],
    this.linkedWorkflows = const [],
    this.dependsOn = const [],
    this.blockers = const [],
    required this.created,
    required this.updated,
    this.verificationCommands = const [],
    this.completionEvidenceSummary,
    this.completionEvidenceRows = const [],
    this.sections = const [],
    this.exitConditions = const [],
    this.bodyMarkdown = '',
    this.filePath = '',
  });

  /// Dependency count for card display.
  int get dependencyCount => dependsOn.length;

  /// Whether this task has any verification commands.
  bool get hasVerificationCommands => verificationCommands.isNotEmpty;

  /// Whether this task has completion evidence.
  ///
  /// Strips markdown emphasis markers before checking for placeholder text
  /// like "Not yet completed".
  bool get hasCompletionEvidence {
    if (completionEvidenceRows.isNotEmpty) {
      return completionEvidenceRows.any((row) => row.isMeaningful);
    }
    if (completionEvidenceSummary == null) return false;
    final stripped = completionEvidenceSummary!
        .replaceAll(RegExp(r'^\*+'), '')
        .replaceAll(RegExp(r'\*+$'), '')
        .trim();
    return stripped.isNotEmpty && !stripped.toLowerCase().startsWith('not yet');
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskProjection &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          lane == other.lane &&
          proofState == other.proofState;

  @override
  int get hashCode => Object.hash(id, lane, proofState);

  @override
  String toString() =>
      'TaskProjection(id: $id, title: $title, lane: $lane, proof: $proofState)';
}

/// A single exit condition extracted from the task body.
@immutable
class ExitCondition {
  /// The condition text.
  final String text;

  /// Whether this condition is checked off (`[x]` vs `[ ]`).
  final bool isComplete;

  const ExitCondition({required this.text, this.isComplete = false});
}

/// One structured completion-evidence row for UI rendering without re-parsing.
@immutable
class EvidenceRow {
  /// Optional label (e.g., "Files created") when the source is key-value style.
  final String? label;

  /// Evidence value/text.
  final String value;

  const EvidenceRow({this.label, required this.value});

  /// Whether this row looks like real evidence rather than a placeholder.
  bool get isMeaningful {
    final stripped = value
        .replaceAll(RegExp(r'^\*+'), '')
        .replaceAll(RegExp(r'\*+$'), '')
        .trim();
    return stripped.isNotEmpty && !stripped.toLowerCase().startsWith('not yet');
  }
}

/// A named markdown body section preserved for inspector rendering.
@immutable
class MarkdownSection {
  /// Heading text without leading `##` / emoji decoration stripped of noise.
  final String name;

  /// Section body (markdown) until the next same/higher-level heading.
  final String body;

  const MarkdownSection({required this.name, required this.body});
}

/// Groups task projections by lane for the Operate board.
@immutable
class TaskLaneProjection {
  /// The lane this group represents.
  final TaskLane lane;

  /// Tasks in this lane, ordered by priority then creation date.
  final List<TaskProjection> tasks;

  const TaskLaneProjection({required this.lane, required this.tasks});

  /// Number of tasks in this lane.
  int get count => tasks.length;

  /// Whether this lane is empty.
  bool get isEmpty => tasks.isEmpty;
}

/// The full Operate projection: all tasks grouped by lane.
@immutable
class OperateProjection {
  /// All task projections, grouped by lane.
  final List<TaskLaneProjection> lanes;

  /// Total task count across all lanes.
  final int totalTasks;

  const OperateProjection({required this.lanes, required this.totalTasks});

  /// Get the projection for a specific lane.
  TaskLaneProjection laneFor(TaskLane lane) {
    return lanes.firstWhere(
      (l) => l.lane == lane,
      orElse: () => TaskLaneProjection(lane: lane, tasks: const []),
    );
  }

  /// Get all tasks across all lanes as a flat list.
  List<TaskProjection> get allTasks => lanes.expand((l) => l.tasks).toList();
}
