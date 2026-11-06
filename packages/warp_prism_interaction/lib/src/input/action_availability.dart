import 'package:meta/meta.dart';

/// Capability-gated action authority outcome (IDS semantics, pure Dart).
///
/// A product decides *whether* a capability holds (capability evaluation is
/// product-local and intentionally absent here). This module carries only the
/// *outcome* of that decision plus its human-readable reason, so every
/// consumer renders the same three states:
///
/// - [ActionAllow]: the action may dispatch.
/// - [ActionConstrain]: the action may dispatch with a stated limitation.
/// - [ActionDeny]: the action must not dispatch; the reason is shown and
///   announced, never hidden.
///
/// Invariant: denied ≠ hidden ≠ enabled. A denied action renders
/// disabled-with-reason, never as not-applicable/hidden, and terminal
/// refusals carry their reason to the caller.
///
/// Fail-closed law: a missing capability implies deny-with-reason, never a
/// silent enable. Use [ActionAvailability.missing] or [availabilityFor] to
/// construct that outcome deterministically.
///
/// No capability *evaluation* lives here: no product domain types, no async,
/// no time, no randomness. Same input ⇒ same output.
///
/// Lifecycle: EXPERIMENTAL (see `.project/architecture/layer-contracts.md`
/// §9). Spec + fake + suite only; no barrel export, no STABLE promotion in
/// this task (Task 1868).
///
/// Does not duplicate `inspection_state.dart`: that file owns the inspection
/// lifecycle (proposed/active/dismissed) and its transition table. This file
/// owns authority outcomes for capability-gated dispatch.
sealed class ActionAvailability {
  const ActionAvailability();

  /// The action may dispatch without limitation.
  const factory ActionAvailability.allow() = ActionAllow;

  /// The action may dispatch with the stated limitation.
  ///
  /// [reason] must be non-empty; asserted in debug and guarded in release.
  factory ActionAvailability.constrain(String reason) =
      ActionConstrain.withReason;

  /// The action must not dispatch; [reason] explains why.
  ///
  /// [reason] must be non-empty; asserted in debug and guarded in release.
  factory ActionAvailability.deny(String reason) = ActionDeny.withReason;

  /// Fail-closed outcome for a missing capability.
  ///
  /// Never a silent enable: always returns [ActionDeny] whose reason names
  /// the missing capability. Deterministic string mapping, no evaluation.
  factory ActionAvailability.missing(String capabilityId) {
    final id = capabilityId.trim().isEmpty ? '<unnamed>' : capabilityId.trim();
    return ActionDeny.withReason('Missing capability: $id');
  }

  /// True when the action may dispatch without limitation.
  bool get isAllowed => this is ActionAllow;

  /// True when the action may dispatch with a stated limitation.
  bool get isConstrained => this is ActionConstrain;

  /// True when the action must not dispatch.
  bool get isDenied => this is ActionDeny;

  /// Human-readable reason, or null when [isAllowed].
  ///
  /// Never null or empty when [isConstrained] or [isDenied].
  String? get reason;
}

/// The action may dispatch without limitation.
///
/// Lifecycle: EXPERIMENTAL (Task 1868).
@immutable
final class ActionAllow extends ActionAvailability {
  const ActionAllow();

  @override
  String? get reason => null;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ActionAllow;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'ActionAvailability.allow()';
}

/// The action may dispatch with the stated limitation.
///
/// Lifecycle: EXPERIMENTAL (Task 1868).
@immutable
final class ActionConstrain extends ActionAvailability {
  /// Non-empty limitation description shown alongside the enabled action.
  final String limitation;

  ActionConstrain.withReason(String reason)
    : limitation = _requireReason(reason, 'constrain');

  @override
  String? get reason => limitation;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ActionConstrain && other.limitation == limitation);

  @override
  int get hashCode => Object.hash(runtimeType, limitation);

  @override
  String toString() => 'ActionAvailability.constrain(reason: "$limitation")';
}

/// The action must not dispatch; the reason is shown, never hidden.
///
/// Lifecycle: EXPERIMENTAL (Task 1868).
@immutable
final class ActionDeny extends ActionAvailability {
  /// Non-empty refusal reason surfaced to the UI and to the dispatch caller.
  final String refusal;

  ActionDeny.withReason(String reason)
    : refusal = _requireReason(reason, 'deny');

  @override
  String? get reason => refusal;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ActionDeny && other.refusal == refusal);

  @override
  int get hashCode => Object.hash(runtimeType, refusal);

  @override
  String toString() => 'ActionAvailability.deny(reason: "$refusal")';
}

/// Guards the non-empty-reason invariant in release mode.
///
/// Debug callers additionally get an [AssertionError] via [assert]; release
/// callers get a substituted fail-closed reason so a refusal can never go
/// reason-less.
String _requireReason(String reason, String kind) {
  assert(
    reason.trim().isNotEmpty,
    'ActionAvailability.$kind requires a non-empty reason',
  );
  if (reason.trim().isEmpty) {
    return 'Unavailable ($kind reason missing)';
  }
  return reason;
}

/// Pure-data record of a single capability's presence.
///
/// This is *data*, not evaluation: the product reports whether the
/// capability is present; this record only carries that fact plus the
/// identifier needed for fail-closed reasoning. No async, no time, no IO.
///
/// Lifecycle: EXPERIMENTAL (Task 1868).
@immutable
final class CapabilityState {
  /// Stable identifier of the capability (e.g. `'session.abort'`).
  final String capabilityId;

  /// Whether the product reports the capability as present.
  final bool present;

  /// Optional product-supplied explanation for absence or limitation.
  final String? detail;

  const CapabilityState({
    required this.capabilityId,
    required this.present,
    this.detail,
  });

  /// Convenience constructor for a present capability.
  const CapabilityState.available(String capabilityId)
    : this(capabilityId: capabilityId, present: true);

  /// Convenience constructor for a missing capability.
  const CapabilityState.missing(String capabilityId, {String? detail})
    : this(capabilityId: capabilityId, present: false, detail: detail);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CapabilityState &&
          other.capabilityId == capabilityId &&
          other.present == present &&
          other.detail == detail);

  @override
  int get hashCode => Object.hash(capabilityId, present, detail);

  @override
  String toString() =>
      'CapabilityState(id: "$capabilityId", present: $present'
      '${detail == null ? '' : ', detail: "$detail"'})';
}

/// Deterministic fail-closed projection from [CapabilityState] to outcome.
///
/// - present ⇒ [ActionAllow] (the product already evaluated presence);
/// - absent ⇒ [ActionDeny] naming the capability, never a silent enable.
///
/// This is a *projection*, not evaluation: it does not decide whether the
/// capability holds, it only refuses to enable when the product reports it
/// missing. Same input ⇒ same output.
ActionAvailability availabilityFor(CapabilityState state) {
  if (state.present) {
    return const ActionAvailability.allow();
  }
  final detail = state.detail?.trim();
  if (detail != null && detail.isNotEmpty) {
    return ActionAvailability.deny(
      'Missing capability: ${state.capabilityId} — $detail',
    );
  }
  return ActionAvailability.missing(state.capabilityId);
}

/// Deterministic reference/fake for the authority-outcome contract.
///
/// Implements the same fail-closed projection as [availabilityFor] through
/// an injectable script, so the conformance suite can prove the fake and
/// the contract agree. No time, no randomness, no IO.
///
/// Lifecycle: EXPERIMENTAL (Task 1868).
@immutable
final class ReferenceAvailabilityPolicy {
  /// Scripted per-capability overrides. Absent keys fall back to [fallback].
  final Map<String, ActionAvailability> script;

  /// Outcome used for capabilities absent from [script].
  final ActionAvailability fallback;

  const ReferenceAvailabilityPolicy({
    this.script = const {},
    this.fallback = const ActionAvailability.allow(),
  });

  /// Resolves [state] against the script, fail-closed on missing keys.
  ///
  /// A scripted entry wins; otherwise a present capability allows and a
  /// missing one denies via [availabilityFor]. The [fallback] applies only
  /// to present capabilities, so a missing capability can never silently
  /// enable through this policy.
  ActionAvailability resolve(CapabilityState state) {
    final scripted = script[state.capabilityId];
    if (scripted != null) {
      return scripted;
    }
    if (state.present) {
      return fallback;
    }
    return availabilityFor(state);
  }
}
