import 'package:meta/meta.dart';

/// Runtime self-documentation seam (Task 1870, F-03).
///
/// Figcraft-style `describe()` for the runtime side of command dispatch:
/// every dispatch decision carries a drift-proof structured description, so
/// host-exercise traces and diagnostics render from data, never from a
/// hand-maintained copy.
///
/// Layer law: this file is pure Dart (no Flutter framework imports),
/// carries no presentation policy, and does NOT import
/// `warp_prism_interaction` — the runtime package is the dependency leaf.
/// Outcome vocabulary is intentionally plain strings (`'dispatched'` /
/// `'refused'`), not the IDS `ActionAvailability` type; the binding/composition
/// site maps between them. Structural compatibility (same `describe()` map
/// shape) is proven by the conformance suite, not by a shared import.
///
/// Lifecycle: EXPERIMENTAL (see `.project/architecture/layer-contracts.md`
/// §9). Spec + suite only; no barrel export, no STABLE promotion in this
/// task.
abstract interface class RuntimeDescribable {
  /// Structured self-description. Keys are stable strings; values are JSON-
  /// compatible scalars, lists, or nested maps.
  Map<String, Object?> describe();
}

/// Outcome of a dispatch decision on the runtime side.
enum CommandDispatchOutcome {
  /// The command dispatched.
  dispatched,

  /// Dispatch was refused; [CommandDispatchRecord.reason] explains why.
  refused,
}

/// A single dispatch decision record (data, not behavior).
///
/// Produced by the composition site that bridges the IDS router
/// (`CommandRouter.route`) to the product's execution path. This record is
/// what host-exercise traces and diagnostics persist: command identity, the
/// chord that triggered it, the outcome, and the refusal reason when any.
///
/// No execution backends live here (non-goal): the record describes the
/// decision; the product executes.
@immutable
final class CommandDispatchRecord implements RuntimeDescribable {
  /// Stable command identity (mirrors the IDS `CommandIntent.id`).
  final String id;

  /// Normalized chord that triggered the decision, or null for
  /// search/tap-dispatched commands.
  final String? chord;

  /// Whether the command dispatched or was refused.
  final CommandDispatchOutcome outcome;

  /// Human-readable refusal reason. Non-empty when [outcome] is refused.
  final String? reason;

  /// Stable enumeration index of the command in the catalog, when known.
  final int? index;

  const CommandDispatchRecord({
    required this.id,
    this.chord,
    required this.outcome,
    this.reason,
    this.index,
  }) : assert(
         outcome == CommandDispatchOutcome.dispatched || reason != null,
         'A refused dispatch must carry its reason',
       );

  /// Convenience constructor for a dispatched command.
  const CommandDispatchRecord.dispatched({
    required String id,
    String? chord,
    int? index,
  }) : this(
         id: id,
         chord: chord,
         outcome: CommandDispatchOutcome.dispatched,
         index: index,
       );

  /// Convenience constructor for a refused dispatch.
  ///
  /// [reason] must be non-empty; asserted in debug, guarded in release.
  factory CommandDispatchRecord.refused({
    required String id,
    String? chord,
    required String reason,
    int? index,
  }) {
    assert(reason.trim().isNotEmpty, 'A refusal requires a non-empty reason');
    final safe = reason.trim().isEmpty ? 'Refused (reason missing)' : reason;
    return CommandDispatchRecord(
      id: id,
      chord: chord,
      outcome: CommandDispatchOutcome.refused,
      reason: safe,
      index: index,
    );
  }

  /// True when the command dispatched.
  bool get dispatched => outcome == CommandDispatchOutcome.dispatched;

  @override
  Map<String, Object?> describe() => {
    'id': id,
    'chord': chord,
    'outcome': outcome.name,
    'reason': reason,
    'index': index,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CommandDispatchRecord &&
          other.id == id &&
          other.chord == chord &&
          other.outcome == outcome &&
          other.reason == reason &&
          other.index == index);

  @override
  int get hashCode => Object.hash(id, chord, outcome, reason, index);

  @override
  String toString() =>
      'CommandDispatchRecord(id: "$id", outcome: ${outcome.name}'
      '${reason == null ? '' : ', reason: "$reason"'})';
}
