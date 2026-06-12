/// Filter state types for the Operate board.
///
/// Encapsulates all filter dimensions: lane, owner, skill, workflow,
/// and proof state. Filter state is deterministic and testable in
/// isolation — the view model applies it to the task projection.
library;

import 'package:flutter/foundation.dart';
import 'package:warp_prism_observatory/data/models/task_contracts.dart';

/// Immutable filter state for the Operate board.
///
/// Each field is optional; null means "no filter on this dimension".
/// Multiple dimensions combine with AND semantics.
@immutable
class OperateFilters {
  /// Filter by specific lane (null = show all lanes).
  final TaskLane? lane;

  /// Filter by owner (null = show all owners).
  final String? owner;

  /// Filter by linked skill name (null = show all).
  final String? skill;

  /// Filter by linked workflow name (null = show all).
  final String? workflow;

  /// Filter by proof state (null = show all).
  final ProofState? proofState;

  /// Free-text search query (matches title, id, owner).
  final String query;

  const OperateFilters({
    this.lane,
    this.owner,
    this.skill,
    this.workflow,
    this.proofState,
    this.query = '',
  });

  /// Whether any filter is active.
  bool get isActive =>
      lane != null ||
      owner != null ||
      skill != null ||
      workflow != null ||
      proofState != null ||
      query.isNotEmpty;

  /// Number of active filters.
  int get activeCount {
    var count = 0;
    if (lane != null) count++;
    if (owner != null) count++;
    if (skill != null) count++;
    if (workflow != null) count++;
    if (proofState != null) count++;
    if (query.isNotEmpty) count++;
    return count;
  }

  /// Create a copy with optional overrides.
  OperateFilters copyWith({
    TaskLane? lane,
    bool clearLane = false,
    String? owner,
    bool clearOwner = false,
    String? skill,
    bool clearSkill = false,
    String? workflow,
    bool clearWorkflow = false,
    ProofState? proofState,
    bool clearProofState = false,
    String? query,
  }) {
    return OperateFilters(
      lane: clearLane ? null : (lane ?? this.lane),
      owner: clearOwner ? null : (owner ?? this.owner),
      skill: clearSkill ? null : (skill ?? this.skill),
      workflow: clearWorkflow ? null : (workflow ?? this.workflow),
      proofState: clearProofState ? null : (proofState ?? this.proofState),
      query: query ?? this.query,
    );
  }

  /// Reset all filters to defaults.
  static const none = OperateFilters();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OperateFilters &&
          runtimeType == other.runtimeType &&
          lane == other.lane &&
          owner == other.owner &&
          skill == other.skill &&
          workflow == other.workflow &&
          proofState == other.proofState &&
          query == other.query;

  @override
  int get hashCode =>
      Object.hash(lane, owner, skill, workflow, proofState, query);

  @override
  String toString() =>
      'OperateFilters(lane:$lane owner:$owner skill:$skill '
      'workflow:$workflow proof:$proofState query:"$query")';
}
