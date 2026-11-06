import '../molecules/ds_state_surface.dart';
import '../tokens/ds_action_authority.dart';

/// Review verdict contract (Task 1871, F-04).
///
/// Presentation-side verdict vocabulary for the decision-review surface.
/// Consumes two frozen contracts without re-inventing either:
///
/// - Task 1869 (`DSStateType.unknown` + `DSStateTypeHonestUnknown`): the
///   pass-through invariant — any indeterminate evidence forces
///   [DSReviewVerdict.unknown], never pass (fail-closed).
/// - Task 1868 (`DSActionAuthority`): every gated action resolves through
///   [authorityForVerdict], so an unknown or failed verdict can never
///   silently enable dispatch.
///
/// Capability *evaluation*, proposal computation, prompt enhancement, approval
/// policy, repair *execution*, and decision reconstruction are product-local
/// non-goals and never live here. This file is pure presentation data plus a
/// deterministic resolver: same input ⇒ same output, no time, no randomness,
/// no Flutter imports beyond the token/state vocabulary.
///
/// Lifecycle: EXPERIMENTAL (Task 1871). Intentionally **not** exported from
/// any barrel and without a `Prism*` alias until the promotion task wires the
/// public surface.

/// Outcome of reviewing a decision's evidence set.
enum DSReviewVerdict {
  /// Every evidence item is determinate and none failed: dispatch may proceed.
  pass,

  /// At least one evidence item failed: dispatch must not proceed.
  fail,

  /// At least one evidence item withholds determination (or none was
  /// presented): the verdict is withheld. Never pass, never silent allow.
  unknown,
}

/// UI metadata for [DSReviewVerdict]: every verdict carries its reason.
extension DSReviewVerdictUI on DSReviewVerdict {
  /// Human-readable label for display.
  String get label {
    switch (this) {
      case DSReviewVerdict.pass:
        return 'Passed';
      case DSReviewVerdict.fail:
        return 'Failed';
      case DSReviewVerdict.unknown:
        return 'Unknown';
    }
  }

  /// Screen-reader label for accessibility announcements.
  String get semanticLabel {
    switch (this) {
      case DSReviewVerdict.pass:
        return 'Review passed: all evidence determined';
      case DSReviewVerdict.fail:
        return 'Review failed: blocking evidence present';
      case DSReviewVerdict.unknown:
        return 'Review unknown: determination withheld, no action taken';
    }
  }

  /// Whether the reviewed decision may proceed to dispatch.
  ///
  /// Fail-closed: only [pass] proceeds. Unknown never proceeds.
  bool get mayProceed => this == DSReviewVerdict.pass;
}

/// One evidence item presented to the review surface.
///
/// The [state] uses Task 1869's frozen ADS vocabulary (`DSStateType`), so
/// indeterminacy (`unknown`) flows through `isIndeterminate` instead of a
/// local re-invention. [detail] carries the human reason; it is required
/// (non-empty) whenever [state] is indeterminate or failed, because the
/// verdict tooltip must name the blocking evidence.
class DSReviewEvidence {
  /// Short label identifying the evidence (e.g. 'Sync status').
  final String label;

  /// Determination state of this evidence (Task 1869 vocabulary).
  final DSStateType state;

  /// Human reason: why unknown, why failed, or supporting detail.
  final String? detail;

  const DSReviewEvidence({
    required this.label,
    required this.state,
    this.detail,
  });

  /// True when this evidence withholds determination.
  bool get isIndeterminate => state.isIndeterminate;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DSReviewEvidence &&
          other.label == label &&
          other.state == state &&
          other.detail == detail);

  @override
  int get hashCode => Object.hash(label, state, detail);

  @override
  String toString() =>
      'DSReviewEvidence(label: "$label", state: $state'
      '${detail == null ? '' : ', detail: "$detail"'})';
}

/// Deterministic resolver: evidence set ⇒ verdict.
///
/// Order of checks is the fail-closed law:
/// 1. empty set or any indeterminate evidence ⇒ [DSReviewVerdict.unknown];
/// 2. else any `error` evidence ⇒ [DSReviewVerdict.fail];
/// 3. else [DSReviewVerdict.pass].
///
/// Unknown can never resolve to pass: the indeterminate check runs first and
/// short-circuits. Same input ⇒ same output.
DSReviewVerdict resolveReviewVerdict(List<DSReviewEvidence> evidence) {
  if (evidence.isEmpty) return DSReviewVerdict.unknown;
  for (final item in evidence) {
    if (item.isIndeterminate) return DSReviewVerdict.unknown;
  }
  for (final item in evidence) {
    if (item.state == DSStateType.error) return DSReviewVerdict.fail;
  }
  return DSReviewVerdict.pass;
}

/// Tooltip reason for a [verdict] over [evidence].
///
/// Every verdict carries a non-empty reason naming the deciding evidence, so
/// the surface can render a tooltip per verdict without product logic.
String verdictReasonFor(
  DSReviewVerdict verdict,
  List<DSReviewEvidence> evidence,
) {
  switch (verdict) {
    case DSReviewVerdict.pass:
      return 'Passed: all ${evidence.length} evidence '
          'item${evidence.length == 1 ? '' : 's'} determined, none failed';
    case DSReviewVerdict.fail:
      final blocking = evidence
          .where((item) => item.state == DSStateType.error)
          .map(
            (item) => item.detail?.trim().isNotEmpty ?? false
                ? '${item.label} (${item.detail!.trim()})'
                : item.label,
          )
          .toList(growable: false);
      final names = blocking.isEmpty
          ? 'blocking evidence'
          : blocking.join(', ');
      return 'Failed: $names';
    case DSReviewVerdict.unknown:
      if (evidence.isEmpty) {
        return 'Unknown: no evidence presented — determination withheld';
      }
      final blocking = evidence
          .where((item) => item.isIndeterminate)
          .map(
            (item) => item.detail?.trim().isNotEmpty ?? false
                ? '${item.label} (${item.detail!.trim()})'
                : item.label,
          )
          .toList(growable: false);
      final names = blocking.isEmpty
          ? 'withheld evidence'
          : blocking.join(', ');
      return 'Unknown: $names — determination withheld, no action taken';
  }
}

/// Gated-action decision for a reviewed verdict (Task 1868 outcome type).
///
/// Carries the ADS authority plus its reason so the surface can render every
/// gated action through `DSActionGate` with a tooltip reason per verdict.
class DSVerdictGate {
  /// Authority outcome governing the gated action.
  final DSActionAuthority authority;

  /// Reason for constrain/deny; null only when [authority] allows.
  final String? reason;

  const DSVerdictGate({required this.authority, this.reason});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DSVerdictGate &&
          other.authority == authority &&
          other.reason == reason);

  @override
  int get hashCode => Object.hash(authority, reason);

  @override
  String toString() => 'DSVerdictGate(authority: $authority, reason: $reason)';
}

/// Projects a [verdict] onto Task 1868's authority outcome.
///
/// Fail-closed: only [DSReviewVerdict.pass] allows. Both [fail] and [unknown]
/// deny with the verdict reason, so an unknown verdict can never silently
/// enable dispatch. Same input ⇒ same output.
DSVerdictGate authorityForVerdict(
  DSReviewVerdict verdict,
  List<DSReviewEvidence> evidence,
) {
  switch (verdict) {
    case DSReviewVerdict.pass:
      return const DSVerdictGate(authority: DSActionAuthority.allow);
    case DSReviewVerdict.fail:
    case DSReviewVerdict.unknown:
      return DSVerdictGate(
        authority: DSActionAuthority.deny,
        reason: verdictReasonFor(verdict, evidence),
      );
  }
}

/// Deterministic reference/fake for the review-verdict contract.
///
/// Implements the same fail-closed resolution as [resolveReviewVerdict]
/// through an injectable script, so the conformance suite can prove the fake
/// and the contract agree. Scripted single-evidence labels win; everything
/// else falls back to the shared resolver, so unscripted evidence can never
/// diverge. No time, no randomness, no IO.
///
/// Lifecycle: EXPERIMENTAL (Task 1871).
class ReferenceReviewPolicy {
  /// Scripted verdicts keyed by evidence label. Absent labels fall back.
  final Map<String, DSReviewVerdict> script;

  const ReferenceReviewPolicy({this.script = const {}});

  /// Resolves [evidence] against the script, fail-closed on misses.
  ///
  /// A scripted entry wins only for a single evidence item whose label is
  /// scripted; every other shape (including multi-item sets containing a
  /// scripted label) goes through [resolveReviewVerdict], preserving the
  /// unknown-never-pass invariant against script misuse.
  DSReviewVerdict resolve(List<DSReviewEvidence> evidence) {
    if (evidence.length == 1) {
      final scripted = script[evidence.single.label];
      if (scripted != null) return scripted;
    }
    return resolveReviewVerdict(evidence);
  }
}
