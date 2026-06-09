import 'package:flutter/material.dart';
import 'ds_colors.dart';
import '../atoms/ds_icon.dart';

/// ASW Observatory Design Tokens — Operational State Vocabulary
///
/// Canonical 15-state vocabulary covering CyberCore entity lifecycle,
/// health, verification, and governance semantics.
///
/// This is orthogonal to [DSStateType] which covers UI data-loading
/// states (empty/loading/error). A screen may show [DSStateType.loading]
/// while fetching data, then display entities each carrying an
/// [DSOperationalState].
///
/// Design source: `docs/design/operational-state-vocabulary.md` (Task 1102)
/// Behavioral contracts: `docs/design/operational-state-behavioral-contracts.md`
/// Transition rules: `docs/design/operational-state-transitions.md`
enum DSOperationalState {
  // ── Lifecycle ────────────────────────────────────────────────────────────────
  /// Entity exists but has not started processing.
  /// No active work. Awaiting assignment or dependency resolution.
  pending,

  /// Entity is actively being worked on.
  /// Resources committed. Progress may be partial.
  running,

  /// Entity has passed review/approval gate.
  /// Ready for promotion or use.
  approved,

  /// Entity failed review or quality gate.
  /// Requires rework or archival.
  rejected,

  /// Entity has been advanced to a higher trust or canonicality level.
  promoted,

  /// Entity is no longer active but preserved for provenance.
  /// Read-only. Cannot transition back to running.
  archived,

  // ── Health ──────────────────────────────────────────────────────────────────
  /// Entity is operating normally. All dependencies resolved. No warnings.
  healthy,

  /// Entity is operational but with reduced quality or missing dependencies.
  /// Attention needed but not blocking.
  degraded,

  /// Entity has encountered a failure. May be recoverable. Requires intervention.
  error,

  /// Entity has been intentionally deactivated. Not available for use.
  /// May be re-enabled. Preserves configuration.
  disabled,

  // ── Verification ────────────────────────────────────────────────────────────
  /// Entity has not yet been subjected to verification. No proof attempted.
  unverified,

  /// Entity has been published/made visible but not reviewed for safety
  /// or governance compliance. Risk of leakage.
  exposed,

  /// Entity has been intentionally obscured or access-restricted.
  /// Sensitive content hidden. Display shows placeholder.
  redacted,

  // ── Governance ──────────────────────────────────────────────────────────────
  /// Entity has not been updated within expected timeframe, or depends
  /// on outdated data. May be functionally correct but governance risk.
  stale,

  /// Entity is intentionally excluded from a scope, filter, or analysis.
  /// Not an error — deliberate boundary.
  excluded,
}

/// Severity classification for operational states.
///
/// Used for ambient color routing, notification priority, and
/// dashboard aggregation.
enum DSOperationalSeverity {
  /// Informational — no action required.
  info,

  /// Positive outcome — things are working as expected.
  success,

  /// Attention needed — not blocking but requires awareness.
  warning,

  /// Failure detected — intervention required.
  error,

  /// Critical failure — immediate escalation required.
  critical,
}

/// Extension providing UI metadata and behavioral contracts for each
/// [DSOperationalState].
///
/// Color, icon, label, and behavioral properties are derived from the
/// canonical vocabulary defined in `docs/design/operational-state-vocabulary.md`.
extension DSOperationalStateUI on DSOperationalState {
  // ── Color mapping ───────────────────────────────────────────────────────────
  /// Canonical color for this operational state.
  ///
  /// Reuses existing [DSColors] tokens through semantic aliases.
  /// No new hex values are introduced — the existing palette covers
  /// all operational states.
  Color get color {
    switch (this) {
      case DSOperationalState.pending:
        return DSColors.statusPending;
      case DSOperationalState.running:
        return DSColors.statusRunning;
      case DSOperationalState.approved:
        return DSColors.statusApproved;
      case DSOperationalState.rejected:
        return DSColors.statusRejected;
      case DSOperationalState.promoted:
        return DSColors.statusPromoted;
      case DSOperationalState.archived:
        return DSColors.statusArchived;
      case DSOperationalState.healthy:
        return DSColors.statusHealthy;
      case DSOperationalState.degraded:
        return DSColors.statusDegraded;
      case DSOperationalState.error:
        return DSColors.statusOpError;
      case DSOperationalState.disabled:
        return DSColors.statusDisabled;
      case DSOperationalState.unverified:
        return DSColors.statusUnverified;
      case DSOperationalState.exposed:
        return DSColors.statusExposed;
      case DSOperationalState.redacted:
        return DSColors.statusRedacted;
      case DSOperationalState.stale:
        return DSColors.statusStale;
      case DSOperationalState.excluded:
        return DSColors.statusExcluded;
    }
  }

  // ── Icon mapping ────────────────────────────────────────────────────────────
  /// Canonical Material icon for this operational state.
  ///
  /// All icons already exist in [DSIcons]. No new constants needed.
  IconData get icon {
    switch (this) {
      case DSOperationalState.pending:
        return DSIcons.pending;
      case DSOperationalState.running:
        return DSIcons.doing;
      case DSOperationalState.approved:
        return DSIcons.success;
      case DSOperationalState.rejected:
        return DSIcons.error;
      case DSOperationalState.promoted:
        return DSIcons.canonical;
      case DSOperationalState.archived:
        return DSIcons.archive;
      case DSOperationalState.healthy:
        return DSIcons.success;
      case DSOperationalState.degraded:
        return DSIcons.warning;
      case DSOperationalState.error:
        return DSIcons.error;
      case DSOperationalState.disabled:
        return DSIcons.blocked;
      case DSOperationalState.unverified:
        return DSIcons.pending;
      case DSOperationalState.exposed:
        return DSIcons.warning;
      case DSOperationalState.redacted:
        return DSIcons.local;
      case DSOperationalState.stale:
        return DSIcons.warning;
      case DSOperationalState.excluded:
        return DSIcons.blocked;
    }
  }

  // ── Human-readable label ────────────────────────────────────────────────────
  /// Human-readable label for screen display and accessibility.
  String get label {
    switch (this) {
      case DSOperationalState.pending:
        return 'Pending';
      case DSOperationalState.running:
        return 'Running';
      case DSOperationalState.approved:
        return 'Approved';
      case DSOperationalState.rejected:
        return 'Rejected';
      case DSOperationalState.promoted:
        return 'Promoted';
      case DSOperationalState.archived:
        return 'Archived';
      case DSOperationalState.healthy:
        return 'Healthy';
      case DSOperationalState.degraded:
        return 'Degraded';
      case DSOperationalState.error:
        return 'Error';
      case DSOperationalState.disabled:
        return 'Disabled';
      case DSOperationalState.unverified:
        return 'Unverified';
      case DSOperationalState.exposed:
        return 'Exposed';
      case DSOperationalState.redacted:
        return 'Redacted';
      case DSOperationalState.stale:
        return 'Stale';
      case DSOperationalState.excluded:
        return 'Excluded';
    }
  }

  // ── Behavioral contracts ────────────────────────────────────────────────────
  /// Whether a user can initiate actions (edit, approve, retry) in this state.
  ///
  /// Terminal states (`archived`, `excluded`) and states requiring
  /// external intervention (`disabled`) return `false`.
  bool get allowsActions {
    switch (this) {
      case DSOperationalState.pending:
        return true;
      case DSOperationalState.running:
        return true;
      case DSOperationalState.approved:
        return true;
      case DSOperationalState.rejected:
        return true;
      case DSOperationalState.promoted:
        return true;
      case DSOperationalState.archived:
        return false;
      case DSOperationalState.healthy:
        return false;
      case DSOperationalState.degraded:
        return true;
      case DSOperationalState.error:
        return true;
      case DSOperationalState.disabled:
        return true;
      case DSOperationalState.unverified:
        return true;
      case DSOperationalState.exposed:
        return true;
      case DSOperationalState.redacted:
        return true;
      case DSOperationalState.stale:
        return true;
      case DSOperationalState.excluded:
        return false;
    }
  }

  /// Whether this is a final state with no automatic transitions.
  ///
  /// Terminal states require explicit user action or external event
  /// to leave. UI should not show "next step" affordances.
  bool get isTerminal {
    switch (this) {
      case DSOperationalState.pending:
        return false;
      case DSOperationalState.running:
        return false;
      case DSOperationalState.approved:
        return false;
      case DSOperationalState.rejected:
        return false;
      case DSOperationalState.promoted:
        return false;
      case DSOperationalState.archived:
        return true;
      case DSOperationalState.healthy:
        return false;
      case DSOperationalState.degraded:
        return false;
      case DSOperationalState.error:
        return false;
      case DSOperationalState.disabled:
        return false;
      case DSOperationalState.unverified:
        return false;
      case DSOperationalState.exposed:
        return false;
      case DSOperationalState.redacted:
        return false;
      case DSOperationalState.stale:
        return false;
      case DSOperationalState.excluded:
        return true;
    }
  }

  /// Whether UI surfaces should display a warning indicator.
  ///
  /// Warning states require user awareness but may not block workflow.
  bool get showsWarning {
    switch (this) {
      case DSOperationalState.pending:
        return false;
      case DSOperationalState.running:
        return false;
      case DSOperationalState.approved:
        return false;
      case DSOperationalState.rejected:
        return true;
      case DSOperationalState.promoted:
        return false;
      case DSOperationalState.archived:
        return false;
      case DSOperationalState.healthy:
        return false;
      case DSOperationalState.degraded:
        return true;
      case DSOperationalState.error:
        return true;
      case DSOperationalState.disabled:
        return false;
      case DSOperationalState.unverified:
        return false;
      case DSOperationalState.exposed:
        return true;
      case DSOperationalState.redacted:
        return false;
      case DSOperationalState.stale:
        return true;
      case DSOperationalState.excluded:
        return false;
    }
  }

  /// Severity classification for ambient color and notification routing.
  DSOperationalSeverity get severity {
    switch (this) {
      case DSOperationalState.pending:
        return DSOperationalSeverity.info;
      case DSOperationalState.running:
        return DSOperationalSeverity.info;
      case DSOperationalState.approved:
        return DSOperationalSeverity.success;
      case DSOperationalState.rejected:
        return DSOperationalSeverity.error;
      case DSOperationalState.promoted:
        return DSOperationalSeverity.success;
      case DSOperationalState.archived:
        return DSOperationalSeverity.info;
      case DSOperationalState.healthy:
        return DSOperationalSeverity.success;
      case DSOperationalState.degraded:
        return DSOperationalSeverity.warning;
      case DSOperationalState.error:
        return DSOperationalSeverity.error;
      case DSOperationalState.disabled:
        return DSOperationalSeverity.info;
      case DSOperationalState.unverified:
        return DSOperationalSeverity.info;
      case DSOperationalState.exposed:
        return DSOperationalSeverity.error;
      case DSOperationalState.redacted:
        return DSOperationalSeverity.warning;
      case DSOperationalState.stale:
        return DSOperationalSeverity.warning;
      case DSOperationalState.excluded:
        return DSOperationalSeverity.info;
    }
  }

  /// Screen reader label for accessibility.
  String get semanticLabel {
    switch (this) {
      case DSOperationalState.pending:
        return 'Pending: awaiting start';
      case DSOperationalState.running:
        return 'Running: in progress';
      case DSOperationalState.approved:
        return 'Approved: passed review';
      case DSOperationalState.rejected:
        return 'Rejected: failed review';
      case DSOperationalState.promoted:
        return 'Promoted: advanced';
      case DSOperationalState.archived:
        return 'Archived: read-only';
      case DSOperationalState.healthy:
        return 'Healthy: operating normally';
      case DSOperationalState.degraded:
        return 'Degraded: reduced quality';
      case DSOperationalState.error:
        return 'Error: failure detected';
      case DSOperationalState.disabled:
        return 'Disabled: intentionally off';
      case DSOperationalState.unverified:
        return 'Unverified: no proof yet';
      case DSOperationalState.exposed:
        return 'Exposed: visible but unreviewed';
      case DSOperationalState.redacted:
        return 'Redacted: sensitive hidden';
      case DSOperationalState.stale:
        return 'Stale: needs refresh';
      case DSOperationalState.excluded:
        return 'Excluded: outside scope';
    }
  }

  /// State category for grouping in UI surfaces.
  DSOperationalCategory get category {
    switch (this) {
      case DSOperationalState.pending:
      case DSOperationalState.running:
      case DSOperationalState.approved:
      case DSOperationalState.rejected:
      case DSOperationalState.promoted:
      case DSOperationalState.archived:
        return DSOperationalCategory.lifecycle;
      case DSOperationalState.healthy:
      case DSOperationalState.degraded:
      case DSOperationalState.error:
      case DSOperationalState.disabled:
        return DSOperationalCategory.health;
      case DSOperationalState.unverified:
      case DSOperationalState.exposed:
      case DSOperationalState.redacted:
        return DSOperationalCategory.verification;
      case DSOperationalState.stale:
      case DSOperationalState.excluded:
        return DSOperationalCategory.governance;
    }
  }
}

/// Categories grouping [DSOperationalState] values by semantic domain.
enum DSOperationalCategory {
  /// Entity lifecycle progression (pending → running → approved → archived).
  lifecycle,

  /// Current health or quality (healthy → degraded → error → disabled).
  health,

  /// Proof/verification position (unverified → exposed → redacted).
  verification,

  /// Staleness and provenance governance (stale, excluded).
  governance,
}
