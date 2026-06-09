/// Typed metadata contracts for task assets.
///
/// These classes represent task lane, verification, dependency, and
/// completion-evidence metadata as structured typed objects rather than
/// forcing downstream code to parse markdown bodies directly.
library;

import 'package:flutter/foundation.dart';

/// Canonical task lanes matching the directory structure:
/// `docs/tasks/00-planning/` through `docs/tasks/04-completed/`.
enum TaskLane {
  /// 00-planning — RF8 upstream planning contracts.
  planning,

  /// 01-open — backlog, not yet started.
  open,

  /// 02-doing — active in-progress work.
  doing,

  /// 03-review — awaiting review or verification.
  review,

  /// 04-completed — done with evidence.
  completed,
}

/// Proof/verification state for a task.
enum ProofState {
  /// No proof or verification attempted yet.
  none,

  /// Partial evidence exists; not all exit conditions verified.
  partial,

  /// All exit conditions have evidence; pending independent review.
  complete,

  /// Independently verified and confirmed.
  verified,
}

/// Structured metadata for a task asset, extracted from YAML frontmatter.
///
/// Maps directly to the frontmatter schema required by the mock corpus
/// contract: `id`, `title`, `status`, `priority`, `owner`, `created`,
/// `updated`, `skills`, `workflows`, `depends_on`, `proof_state`,
/// `review_score`.
@immutable
class TaskMetadata {
  /// Task identifier (e.g., "0310").
  final String id;

  /// Human-readable task title.
  final String title;

  /// Current lane (derived from directory path or frontmatter `status`).
  final TaskLane lane;

  /// Priority label (e.g., "P0", "P1", "P2").
  final String priority;

  /// Owner agent or person (e.g., "builder-orchestrator").
  final String owner;

  /// Creation date.
  final DateTime created;

  /// Last update date.
  final DateTime updated;

  /// Skill names this task relates to.
  final List<String> skills;

  /// Workflow names this task uses.
  final List<String> workflows;

  /// Task ids this task depends on.
  final List<String> dependsOn;

  /// Current proof/verification state.
  final ProofState proofState;

  /// Review score (null if not yet reviewed).
  final double? reviewScore;

  /// Verification commands from the task body (markdown fenced blocks).
  final String? verificationCommands;

  /// Completion evidence summary from the task body.
  final String? completionEvidence;

  const TaskMetadata({
    required this.id,
    required this.title,
    this.lane = TaskLane.open,
    this.priority = 'P2',
    this.owner = 'unassigned',
    required this.created,
    required this.updated,
    this.skills = const [],
    this.workflows = const [],
    this.dependsOn = const [],
    this.proofState = ProofState.none,
    this.reviewScore,
    this.verificationCommands,
    this.completionEvidence,
  });

  TaskMetadata copyWith({
    String? id,
    String? title,
    TaskLane? lane,
    String? priority,
    String? owner,
    DateTime? created,
    DateTime? updated,
    List<String>? skills,
    List<String>? workflows,
    List<String>? dependsOn,
    ProofState? proofState,
    double? reviewScore,
    String? verificationCommands,
    String? completionEvidence,
  }) {
    return TaskMetadata(
      id: id ?? this.id,
      title: title ?? this.title,
      lane: lane ?? this.lane,
      priority: priority ?? this.priority,
      owner: owner ?? this.owner,
      created: created ?? this.created,
      updated: updated ?? this.updated,
      skills: skills ?? this.skills,
      workflows: workflows ?? this.workflows,
      dependsOn: dependsOn ?? this.dependsOn,
      proofState: proofState ?? this.proofState,
      reviewScore: reviewScore ?? this.reviewScore,
      verificationCommands: verificationCommands ?? this.verificationCommands,
      completionEvidence: completionEvidence ?? this.completionEvidence,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskMetadata &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          lane == other.lane &&
          proofState == other.proofState;

  @override
  int get hashCode => Object.hash(id, lane, proofState);

  @override
  String toString() =>
      'TaskMetadata(id: $id, title: $title, lane: $lane, proof: $proofState)';
}

/// Extension to map directory name prefixes to [TaskLane] values.
extension TaskLaneParsing on TaskLane {
  /// Parse a lane from a directory prefix like "00-planning", "02-doing", etc.
  static TaskLane fromDirectoryPrefix(String prefix) {
    switch (prefix) {
      case '00-planning':
        return TaskLane.planning;
      case '01-open':
        return TaskLane.open;
      case '02-doing':
        return TaskLane.doing;
      case '03-review':
        return TaskLane.review;
      case '04-completed':
        return TaskLane.completed;
      default:
        return TaskLane.open;
    }
  }

  /// Parse a lane from a frontmatter status string.
  static TaskLane fromStatus(String status) {
    return fromDirectoryPrefix(status);
  }

  /// The canonical directory prefix for this lane.
  String get directoryPrefix {
    switch (this) {
      case TaskLane.planning:
        return '00-planning';
      case TaskLane.open:
        return '01-open';
      case TaskLane.doing:
        return '02-doing';
      case TaskLane.review:
        return '03-review';
      case TaskLane.completed:
        return '04-completed';
    }
  }
}

/// Extension to parse [ProofState] from frontmatter strings.
extension ProofStateParsing on ProofState {
  static ProofState fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'none':
        return ProofState.none;
      case 'partial':
        return ProofState.partial;
      case 'complete':
        return ProofState.complete;
      case 'verified':
        return ProofState.verified;
      default:
        return ProofState.none;
    }
  }
}
