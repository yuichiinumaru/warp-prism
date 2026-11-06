import 'package:meta/meta.dart';

import '../input/action_availability.dart';
import 'command_chord.dart';
import 'command_context.dart';

/// A single reusable command intent (identity + presentation hints +
/// eligibility), IDS-owned.
///
/// Eligibility resolves **through Task 1868's frozen outcome type**
/// ([ActionAvailability]): this file consumes it and never re-invents
/// availability. Capability *evaluation* stays product-local — the intent
/// carries a resolver over [CommandContext], not a product capability model.
///
/// Two independent gates (matching the 1868 law `denied ≠ hidden`):
/// - [isApplicable]: not-applicable commands are filtered (hidden as
///   not-applicable is legitimate here — it is *applicability*, not denial).
/// - [resolveAvailability]: denied commands render disabled-with-reason,
///   never hidden.
///
/// Lifecycle: EXPERIMENTAL (Task 1870, F-03). Spec + fake + suite only, no
/// barrel export, no STABLE promotion in this task.
@immutable
final class CommandIntent {
  /// Stable unique identity (e.g. `'workspace.refresh'`). Registry-enforced.
  final String id;

  /// Human-readable label shown in palettes and cheatsheets.
  final String label;

  /// Optional subtitle shown beneath the label.
  final String? description;

  /// Optional keyboard chord. Null ⇒ reachable by search/tap only.
  final CommandChord? chord;

  /// Applicability predicate over the projected context.
  ///
  /// Null ⇒ applicable everywhere. A false result filters the command from
  /// listings (not-applicable ≠ denied).
  final bool Function(CommandContext context)? isApplicable;

  /// Availability resolver returning the frozen 1868 outcome type.
  ///
  /// Null ⇒ [ActionAvailability.allow]. A deny result renders
  /// disabled-with-reason and refuses dispatch with its reason.
  final ActionAvailability Function(CommandContext context)?
  resolveAvailability;

  const CommandIntent({
    required this.id,
    required this.label,
    this.description,
    this.chord,
    this.isApplicable,
    this.resolveAvailability,
  }) : assert(id.length > 0, 'CommandIntent requires a non-empty id');

  /// Whether this intent applies in [context].
  bool appliesTo(CommandContext context) => isApplicable?.call(context) ?? true;

  /// The 1868 authority outcome for [context] (allow when no resolver).
  ActionAvailability availabilityIn(CommandContext context) =>
      resolveAvailability?.call(context) ?? const ActionAvailability.allow();

  /// Figcraft-style static self-documentation (donor A2 shape:
  /// `{id,label,params,menu,shortcut,undoable}` projected onto Prism terms).
  ///
  /// Drift-proof: the catalog UI renders from this map, never from a
  /// hand-maintained copy. Keys: `id`, `label`, `description`, `chord`
  /// (normalized, or null), `hasApplicability`, `hasAvailabilityResolver`.
  Map<String, Object?> describe() => {
    'id': id,
    'label': label,
    'description': description,
    'chord': chord?.normalized,
    'hasApplicability': isApplicable != null,
    'hasAvailabilityResolver': resolveAvailability != null,
  };

  /// Contextual self-documentation: [describe] plus the resolved
  /// applicability, availability kind, and reason for [context].
  Map<String, Object?> describeFor(CommandContext context) {
    final availability = availabilityIn(context);
    return {
      ...describe(),
      'applicable': appliesTo(context),
      'availability': availability is ActionAllow
          ? 'allow'
          : availability is ActionConstrain
          ? 'constrain'
          : 'deny',
      'reason': availability.reason,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CommandIntent &&
          other.id == id &&
          other.label == label &&
          other.description == description &&
          other.chord == chord);

  @override
  int get hashCode => Object.hash(id, label, description, chord);

  @override
  String toString() => 'CommandIntent(id: "$id", chord: ${chord?.normalized})';
}
