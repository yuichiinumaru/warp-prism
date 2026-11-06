import 'package:meta/meta.dart';

import '../input/action_availability.dart';
import 'command_chord.dart';
import 'command_context.dart';
import 'command_intent.dart';
import 'command_registry.dart';

/// Why dispatch was refused. Deterministic strings for tests and telemetry.
enum CommandRefusalKind {
  /// No registered command claims the chord.
  noMatch,

  /// The winning command is not applicable in the current context.
  notApplicable,

  /// The winning command is denied by its 1868 availability outcome.
  denied,

  /// A bare key was pressed while editing has focus (keyboard guard).
  editingFocus,
}

/// The outcome of routing one chord in one context (IDS semantics).
///
/// Sealed: exactly one of [CommandDispatch], [CommandRefusal].
/// Lifecycle: EXPERIMENTAL (Task 1870, F-03). No barrel export.
sealed class CommandRoute {
  const CommandRoute();
}

/// The chord resolves to a dispatchable command.
@immutable
final class CommandDispatch extends CommandRoute {
  /// The winning intent under precedence law.
  final CommandIntent intent;

  /// Shadowed claimant ids for the same chord (empty when uncontested).
  final List<String> shadowedIds;

  const CommandDispatch({required this.intent, this.shadowedIds = const []});

  @override
  String toString() =>
      'CommandDispatch(intent: "${intent.id}", shadowed: $shadowedIds)';
}

/// The chord does not dispatch; [reason] is shown/announced, never hidden.
@immutable
final class CommandRefusal extends CommandRoute {
  /// Machine-readable refusal class.
  final CommandRefusalKind kind;

  /// Human-readable reason propagated to presentation.
  final String reason;

  /// The normalized chord that was refused.
  final String chord;

  /// The winning intent id when a command claimed the chord, else null.
  final String? commandId;

  const CommandRefusal({
    required this.kind,
    required this.reason,
    required this.chord,
    this.commandId,
  });

  @override
  String toString() =>
      'CommandRefusal(kind: $kind, chord: "$chord", reason: "$reason")';
}

/// Pure-Dart dispatch router over a [CommandRegistry].
///
/// Resolution order for a chord in a context:
/// 1. No claimant ⇒ [CommandRefusal] `noMatch`.
/// 2. Winner not applicable ⇒ [CommandRefusal] `notApplicable`.
/// 3. Winner denied (1868 outcome) ⇒ [CommandRefusal] `denied` carrying the
///    availability reason.
/// 4. Bare key while [editingHasFocus] ⇒ [CommandRefusal] `editingFocus`
///    (the edit-focus guard; typing never dispatches).
/// 5. Otherwise ⇒ [CommandDispatch].
///
/// The guard (4) runs before applicability/denial evaluation so the reason
/// for a suppressed keystroke is always the focus guard, deterministically.
/// Same inputs ⇒ same route: no time, no randomness, no IO.
///
/// This router never executes commands (non-goal: no execution backends) —
/// it only decides *whether* a chord dispatches and *why not*.
///
/// Lifecycle: EXPERIMENTAL (Task 1870, F-03). No barrel export.
abstract final class CommandRouter {
  /// Routes [chord] (parsed chord or display string) in [context].
  static CommandRoute route(
    CommandRegistry registry,
    Object chord, {
    CommandContext context = CommandContext.empty,
    bool editingHasFocus = false,
  }) {
    final normalized = chord is CommandChord
        ? chord.normalized
        : chord is String
        ? CommandChord.parse(chord).normalized
        : throw ArgumentError.value(
            chord,
            'chord',
            'Expected a CommandChord or a chord display string',
          );

    if (editingHasFocus && _isBareKeyNormalized(normalized)) {
      return CommandRefusal(
        kind: CommandRefusalKind.editingFocus,
        reason: 'Editing has focus — "$normalized" not dispatched',
        chord: normalized,
      );
    }

    final resolution = registry.resolveChord(normalized);
    final winner = resolution.winner;
    if (winner == null) {
      return CommandRefusal(
        kind: CommandRefusalKind.noMatch,
        reason: 'No command claims "$normalized"',
        chord: normalized,
      );
    }

    if (!winner.appliesTo(context)) {
      return CommandRefusal(
        kind: CommandRefusalKind.notApplicable,
        reason: '"${winner.label}" is not applicable here',
        chord: normalized,
        commandId: winner.id,
      );
    }

    final availability = winner.availabilityIn(context);
    if (availability is ActionDeny) {
      final detail = availability.reason ?? 'Unavailable';
      return CommandRefusal(
        kind: CommandRefusalKind.denied,
        reason: detail,
        chord: normalized,
        commandId: winner.id,
      );
    }

    return CommandDispatch(intent: winner, shadowedIds: resolution.shadowedIds);
  }
}

/// True when the normalized chord is a single printable char, no modifiers.
bool _isBareKeyNormalized(String normalized) =>
    !normalized.contains('+') && normalized.length == 1;
