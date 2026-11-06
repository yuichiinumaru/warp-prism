import 'package:flutter/material.dart';
import '../atoms/atoms.dart';
import '../molecules/ds_action_gate.dart';
import '../molecules/ds_evidence_row.dart';
import '../molecules/ds_state_surface.dart';
import '../tokens/ds_action_authority.dart';
import '../tokens/tokens.dart';
import 'ds_detail_inspector.dart';
import 'ds_review_verdict.dart';

/// Decision-review surface (Task 1871, F-04).
///
/// EXPERIMENTAL organism composing the review framing that three donors built
/// independently: Warpblade `ProposalPanel` + `AssurancePanel` + `RepairDialog`,
/// Tempest `CommandBarDialog` + `PromptEnhancerDialog`, command-center
/// `ControlPanel` + `_GatedAction`. All parts already exist
/// (`DSDetailInspector`, `DSEvidenceRow`, `DSAssetCard`,
/// `MasterDetailTemplate`); this file supplies the framing, not the parts.
///
/// Unification decision (macro review — unify/improve, never copy blindly):
/// - Kept from WB: inspector-led framing (title/kind/sections carry the
///   decision identity) and the RepairDialog shape (dialog chrome with an
///   explicit confirm path) — the former via [DSDetailInspector] reuse, the
///   latter via the bounded-repair molecule.
/// - Kept from TP: caller-supplied diff/command content as an opaque slot plus
///   a keyboard-accessible action row — [diff] and the [DSActionGate] bar.
/// - Kept from CC: a gated action is never hidden — it renders
///   disabled-with-reason with the refusal surfaced to the caller — via
///   [DSActionGate] per action plus [DSReviewAction.onRefused].
/// - Rejected: WB-local proposal computation (non-goal), TP prompt-enhancement
///   models (non-goal), CC product-local abort/permission sections (domain
///   stays caller-local — callers project domain onto [diff]/[actions]),
///   and any STABLE barrel/API surface (EXPERIMENTAL by contract).
///
/// Donor provenance: WB/TP shapes are report-grade (revision-UNKNOWN,
/// inherited-report until read); the CC shape is re-verified through this
/// task's live Where-file (`docs/bridge/command-center/prism-gap-components.md`)
/// plus Task 1868's citation of `control_panel.dart:49-138`.
///
/// Verdict law (shared invariant): the displayed verdict is always computed by
/// [resolveReviewVerdict] from [evidence] — unknown evidence ⇒ unknown
/// verdict, never pass (Task 1869) — and every gated action resolves through
/// Task 1868's [DSActionAuthority] with a tooltip reason per verdict.
///
/// Lifecycle: EXPERIMENTAL (Task 1871). Intentionally **not** exported from
/// any barrel and without a `Prism*` alias until the promotion task wires the
/// public surface.
class DSDecisionReviewSurface extends StatelessWidget {
  /// Decision title carried by the inspector header.
  final String title;

  /// Decision kind carried by the inspector header (drives the kind color).
  final String kind;

  /// Optional subtitle carried by the inspector header.
  final String? subtitle;

  /// Caller detail sections rendered first, inside the inspector base.
  ///
  /// Reuses [DSDetailSection]/[DSPropertyRow] — never forked.
  final List<DSDetailSection> inspectorSections;

  /// Evidence set driving the verdict. Displayed as [DSEvidenceRow] rows
  /// (reused, never forked) under an 'Evidence' section.
  final List<DSReviewEvidence> evidence;

  /// Caller-supplied diff content (opaque slot). Domain stays caller-local:
  /// the surface never inspects this subtree.
  final Widget? diff;

  /// Gated actions rendered as the caller action bar. Each action resolves
  /// through [DSActionAuthority] (Task 1868) and carries its tooltip reason.
  final List<DSReviewAction> actions;

  /// Optional close affordance forwarded to the inspector header.
  final VoidCallback? onClose;

  const DSDecisionReviewSurface({
    super.key,
    required this.title,
    required this.kind,
    this.subtitle,
    this.inspectorSections = const [],
    required this.evidence,
    this.diff,
    this.actions = const [],
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final verdict = resolveReviewVerdict(evidence);
    final verdictReason = verdictReasonFor(verdict, evidence);

    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: 'Decision review: $title. ${verdict.semanticLabel}',
      child: DSDetailInspector(
        title: title,
        kind: kind,
        subtitle: subtitle,
        onClose: onClose,
        sections: [
          DSDetailSection(
            title: 'Verdict',
            icon: Icons.fact_check_outlined,
            child: Tooltip(
              message: verdictReason,
              child: _VerdictBanner(verdict: verdict, reason: verdictReason),
            ),
          ),
          ...inspectorSections,
          DSDetailSection(
            title: 'Evidence',
            icon: Icons.playlist_add_check_outlined,
            count: evidence.length,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final item in evidence)
                  Padding(
                    padding: const EdgeInsets.only(bottom: DSSpacing.xs),
                    child: DSEvidenceRow(
                      label: item.label,
                      value: _evidenceValue(item),
                      state: _evidenceState(item),
                    ),
                  ),
              ],
            ),
          ),
          if (diff != null)
            DSDetailSection(
              title: 'Diff',
              icon: Icons.difference_outlined,
              child: diff!,
            ),
          if (actions.isNotEmpty)
            DSDetailSection(
              title: 'Actions',
              icon: Icons.bolt_outlined,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final action in actions)
                    Padding(
                      padding: const EdgeInsets.only(bottom: DSSpacing.xs),
                      child: Tooltip(
                        message: action.reason ?? verdictReason,
                        child: DSActionGate(
                          authority: action.authority,
                          actionLabel: action.actionLabel,
                          reason: action.reason,
                          onPressed: action.onPressed,
                          onRefused: action.onRefused,
                          icon: action.icon,
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// One caller action in the review action bar.
///
/// Carries Task 1868's authority outcome as data (never evaluated here) plus
/// an optional reason override. When [reason] is null, the surface falls back
/// to the verdict tooltip reason, so every gated action always has a reason.
class DSReviewAction {
  /// Visible label of the gated action.
  final String actionLabel;

  /// Authority outcome governing this action (Task 1868 outcome type).
  final DSActionAuthority authority;

  /// Reason for constrain/deny. Falls back to the verdict reason when null.
  final String? reason;

  /// Dispatch callback. Invoked only when [authority] permits dispatch.
  final VoidCallback? onPressed;

  /// Refusal callback. Invoked with the reason when a denied gate is tapped.
  final ValueChanged<String>? onRefused;

  /// Optional leading icon for the action button.
  final IconData? icon;

  const DSReviewAction({
    required this.actionLabel,
    required this.authority,
    this.reason,
    this.onPressed,
    this.onRefused,
    this.icon,
  });
}

/// Verdict banner: the fail-closed announcement of the review outcome.
///
/// - unknown ⇒ [DSStateSurface.unknown] (neutral token, no animation,
///   live-region announcement — Task 1869 vocabulary, never success);
/// - fail ⇒ [DSStateSurface.error] (compact, with the blocking reason);
/// - pass ⇒ a determinate success row (success token, announced once).
/// Unknown never maps to a success, enabled, or verified affordance.
class _VerdictBanner extends StatelessWidget {
  final DSReviewVerdict verdict;
  final String reason;

  const _VerdictBanner({required this.verdict, required this.reason});

  @override
  Widget build(BuildContext context) {
    switch (verdict) {
      case DSReviewVerdict.unknown:
        return DSStateSurface.unknown(
          title: 'Verdict withheld',
          subtitle: reason,
          compact: true,
        );
      case DSReviewVerdict.fail:
        return DSStateSurface.error(
          title: 'Review failed',
          subtitle: reason,
          compact: true,
        );
      case DSReviewVerdict.pass:
        return Semantics(
          container: true,
          label: '${verdict.semanticLabel}: $reason',
          child: Row(
            children: [
              const Icon(
                Icons.check_circle,
                size: 16,
                color: DSColors.statusSuccess,
              ),
              const SizedBox(width: DSSpacing.sm),
              Expanded(
                child: DSText.labelMedium(
                  'Passed — $reason',
                  color: DSColors.statusSuccess,
                ),
              ),
            ],
          ),
        );
    }
  }
}

/// Row-state projection for review evidence (triage hint, not authority).
///
/// The verdict — not the row — enforces the fail-closed law. Indeterminate
/// evidence renders as `pending` with explicit 'Unknown' wording (neutral,
/// never success/enabled/verified); the verdict banner carries the refusal.
DSEvidenceState _evidenceState(DSReviewEvidence item) {
  switch (item.state) {
    case DSStateType.error:
      return DSEvidenceState.missing;
    case DSStateType.loading:
    case DSStateType.unknown:
      return DSEvidenceState.pending;
    case DSStateType.stale:
    case DSStateType.degraded:
      return DSEvidenceState.partial;
    case DSStateType.empty:
    case DSStateType.disabled:
    case DSStateType.excluded:
      return DSEvidenceState.verified;
  }
}

/// Row value text: indeterminate evidence names its withheld detail.
String? _evidenceValue(DSReviewEvidence item) {
  final detail = item.detail?.trim();
  if (item.isIndeterminate) {
    return detail == null || detail.isEmpty
        ? 'Unknown: not yet determined'
        : 'Unknown: $detail';
  }
  return detail;
}
