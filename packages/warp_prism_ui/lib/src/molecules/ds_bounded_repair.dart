import 'package:flutter/material.dart';
import '../atoms/atoms.dart';
import '../tokens/ds_action_authority.dart';
import '../tokens/tokens.dart';
import 'dialog/ds_dialog.dart';
import 'ds_action_gate.dart';
import 'ds_evidence_row.dart';
import 'ds_state_surface.dart';
import '../organisms/ds_detail_inspector.dart' show DSPropertyRow;
import '../organisms/ds_review_verdict.dart';

/// Bounded-repair molecule (Task 1871, F-04).
///
/// The `RepairDialog` shape the three donors built independently (WB
/// `RepairDialog`, TP `CommandBarDialog`, CC `ControlPanel` repair affordance)
/// converged onto one reusable framing: a bounded set of repair replies with
/// an explicit approval mode and per-reply undo — rendered on [DSDialog]
/// chrome, gated through Task 1868's [DSActionAuthority], and honest about
/// indeterminacy through Task 1869's [DSStateType].
///
/// Options (not policy): [approvalMode] selects how approval is taken;
/// [undoPerReply] is the master switch for per-reply undo affordances. Repair
/// *execution* backends are product-local non-goals and never live here:
/// [onApprove]/[DSRepairReply.onUndo] are caller callbacks carrying
/// caller-domain effects.
///
/// Lifecycle: EXPERIMENTAL (Task 1871). Intentionally **not** exported from
/// any barrel and without a `Prism*` alias until the promotion task wires the
/// public surface.
class DSBoundedRepair extends StatelessWidget {
  /// Dialog title (e.g. the repair proposal name).
  final String title;

  /// Optional dialog subtitle.
  final String? subtitle;

  /// Bounded repair replies presented for approval.
  final List<DSRepairReply> replies;

  /// How approval is taken for this repair set.
  final DSRepairApprovalMode approvalMode;

  /// Master switch for per-reply undo affordances.
  ///
  /// When false, no undo buttons render even when a reply offers undo.
  final bool undoPerReply;

  /// Optional evidence rows shown above the replies (reused, never forked).
  final List<DSReviewEvidence> evidence;

  /// Visible label of the approve action.
  final String approveLabel;

  /// Authority governing the approve action (Task 1868 outcome type).
  final DSActionAuthority approveAuthority;

  /// Reason for a constrained/denied approve. Falls back to a fail-closed
  /// default when null, so the gate always has a reason.
  final String? approveReason;

  /// Approve dispatch callback. Invoked only when [approveAuthority] permits.
  final VoidCallback? onApprove;

  /// Refusal callback. Invoked with the reason when a denied approve is
  /// tapped, so terminal-for-dispatch refusals reach the caller.
  final ValueChanged<String>? onRefused;

  /// Cancel callback for the secondary dialog action.
  final VoidCallback? onCancel;

  const DSBoundedRepair({
    super.key,
    required this.title,
    this.subtitle,
    required this.replies,
    this.approvalMode = DSRepairApprovalMode.confirmEach,
    this.undoPerReply = true,
    this.evidence = const [],
    this.approveLabel = 'Approve repair',
    this.approveAuthority = DSActionAuthority.deny,
    this.approveReason,
    this.onApprove,
    this.onRefused,
    this.onCancel,
  });

  /// Fail-closed approve reason: an indeterminate or unreasoned gate still
  /// tells the operator why dispatch is withheld.
  String get effectiveApproveReason {
    final detail = approveReason?.trim();
    if (detail != null && detail.isNotEmpty) return detail;
    return 'Approval withheld: no reason supplied — determination withheld';
  }

  @override
  Widget build(BuildContext context) {
    return DSDialog(
      title: title,
      subtitle: subtitle,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DSPropertyRow(label: 'Approval', value: approvalMode.label),
          DSPropertyRow(label: 'Mode detail', value: approvalMode.description),
          if (evidence.isNotEmpty) ...[
            const SizedBox(height: DSSpacing.sm),
            for (final item in evidence)
              Padding(
                padding: const EdgeInsets.only(bottom: DSSpacing.xs),
                child: DSEvidenceRow(
                  label: item.label,
                  value: item.detail,
                  state: item.isIndeterminate
                      ? DSEvidenceState.pending
                      : item.state == DSStateType.error
                      ? DSEvidenceState.missing
                      : DSEvidenceState.verified,
                ),
              ),
          ],
          const SizedBox(height: DSSpacing.sm),
          for (var i = 0; i < replies.length; i++)
            _RepairReplyRow(
              reply: replies[i],
              index: i,
              showUndo: undoPerReply,
            ),
        ],
      ),
      customFooter: (context) => Container(
        padding: const EdgeInsets.symmetric(
          horizontal: DSSpacing.lg,
          vertical: DSSpacing.md,
        ),
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: DSColors.borderSubtle, width: 1),
          ),
        ),
        // Note: DSDialog prefers customFooter over actions, so BOTH the
        // cancel action and the gated approve live here — passing actions
        // alongside a customFooter would silently drop Cancel.
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            DSButton.secondary(
              label: 'Cancel',
              size: DSButtonSize.sm,
              onPressed: onCancel,
            ),
            const SizedBox(width: DSSpacing.sm),
            Flexible(
              child: Tooltip(
                message: effectiveApproveReason,
                child: DSActionGate(
                  authority: approveAuthority,
                  actionLabel: approveLabel,
                  reason: effectiveApproveReason,
                  onPressed: onApprove,
                  onRefused: onRefused,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// How approval is taken for a bounded repair set (option, not policy).
enum DSRepairApprovalMode {
  /// Apply immediately once approved (single gate).
  immediate,

  /// Confirm each reply before it applies.
  confirmEach,

  /// Collect approvals, then apply as one batch.
  batched,
}

/// UI metadata for [DSRepairApprovalMode].
extension DSRepairApprovalModeUI on DSRepairApprovalMode {
  /// Human-readable label for display.
  String get label {
    switch (this) {
      case DSRepairApprovalMode.immediate:
        return 'Immediate';
      case DSRepairApprovalMode.confirmEach:
        return 'Confirm each';
      case DSRepairApprovalMode.batched:
        return 'Batched';
    }
  }

  /// One-line description of what the mode means.
  String get description {
    switch (this) {
      case DSRepairApprovalMode.immediate:
        return 'Applies immediately once approved';
      case DSRepairApprovalMode.confirmEach:
        return 'Confirms each reply before it applies';
      case DSRepairApprovalMode.batched:
        return 'Collects approvals, applies as one batch';
    }
  }
}

/// One bounded repair reply with an optional per-reply undo affordance.
class DSRepairReply {
  /// Visible label of the reply (e.g. the proposed fix).
  final String replyLabel;

  /// Optional supporting detail.
  final String? detail;

  /// Whether this reply offers undo. Honored only when the dialog's
  /// [DSBoundedRepair.undoPerReply] master switch is on.
  final bool undoAvailable;

  /// Undo callback for this reply. The undo button renders only when both
  /// [undoAvailable] and this callback are present.
  final VoidCallback? onUndo;

  const DSRepairReply({
    required this.replyLabel,
    this.detail,
    this.undoAvailable = true,
    this.onUndo,
  });
}

/// One reply row: label + detail with an undo button when offered.
class _RepairReplyRow extends StatelessWidget {
  final DSRepairReply reply;
  final int index;
  final bool showUndo;

  const _RepairReplyRow({
    required this.reply,
    required this.index,
    required this.showUndo,
  });

  @override
  Widget build(BuildContext context) {
    final canUndo = showUndo && reply.undoAvailable && reply.onUndo != null;
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: 'Repair ${index + 1}: ${reply.replyLabel}',
      child: Container(
        margin: const EdgeInsets.only(bottom: DSSpacing.xs),
        padding: const EdgeInsets.all(DSSpacing.sm),
        decoration: BoxDecoration(
          color: DSColors.obsidianElevated,
          borderRadius: BorderRadius.circular(DSRadii.sm),
          border: Border.all(color: DSColors.borderSubtle, width: 1),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  DSText.labelMedium(reply.replyLabel),
                  if (reply.detail != null) ...[
                    const SizedBox(height: 2),
                    DSText.bodySmall(
                      reply.detail!,
                      color: DSColors.textSecondary,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            if (canUndo) ...[
              const SizedBox(width: DSSpacing.sm),
              DSButton.secondary(
                label: 'Undo',
                size: DSButtonSize.sm,
                onPressed: reply.onUndo,
                semanticLabel: 'Undo ${reply.replyLabel}',
              ),
            ],
          ],
        ),
      ),
    );
  }
}
