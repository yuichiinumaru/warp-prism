import 'package:meta/meta.dart';

import '../input/action_availability.dart';
import 'command_chord.dart';
import 'command_context.dart';
import 'command_intent.dart';

/// Deterministic chord-collision report for one normalized chord.
///
/// Precedence law: the lexicographically smallest command id wins; every
/// other claimant is shadowed. Same registry content ⇒ same winner, every
/// run — collision resolution is a pure function of registration content.
@immutable
final class CommandCollision {
  /// The contested chord in canonical normalized form.
  final String chord;

  /// Winning command id (lexicographically smallest claimant).
  final String winnerId;

  /// Shadowed command ids, sorted ascending (deterministic).
  final List<String> shadowedIds;

  CommandCollision({
    required this.chord,
    required this.winnerId,
    required List<String> shadowedIds,
  }) : shadowedIds = List.unmodifiable((shadowedIds.toList()..sort()));

  Map<String, Object?> describe() => {
    'chord': chord,
    'winnerId': winnerId,
    'shadowedIds': shadowedIds,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CommandCollision &&
          other.chord == chord &&
          other.winnerId == winnerId &&
          _listsEqual(other.shadowedIds, shadowedIds));

  @override
  int get hashCode => Object.hash(chord, winnerId, Object.hashAll(shadowedIds));

  @override
  String toString() =>
      'CommandCollision(chord: "$chord", winner: "$winnerId", '
      'shadowed: $shadowedIds)';
}

bool _listsEqual(List<String> a, List<String> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

/// Resolution of one chord against the registry content.
@immutable
final class ChordResolution {
  /// The winning intent, or null when no registered command claims [chord].
  final CommandIntent? winner;

  /// The normalized chord that was resolved.
  final String chord;

  /// Shadowed claimant ids (empty when uncontested or unmatched).
  final List<String> shadowedIds;

  const ChordResolution({
    required this.chord,
    this.winner,
    this.shadowedIds = const [],
  });

  /// True when at least one command claims the chord.
  bool get matched => winner != null;

  /// True when more than one command claims the chord.
  bool get contested => shadowedIds.isNotEmpty;
}

/// Mutable-registration, stable-enumeration command registry (IDS).
///
/// - Registration rejects duplicate ids ([StateError]) — identity collisions
///   are programming errors, never silent overwrites.
/// - [enumerate] returns intents sorted by id: stable across runs for the
///   same content (enumeration stability).
/// - Chord precedence is a pure function of content (smallest id wins);
///   [collisions] and [resolveChord] agree by construction.
///
/// Lifecycle: EXPERIMENTAL (Task 1870, F-03). No barrel export.
final class CommandRegistry {
  final Map<String, CommandIntent> _byId = {};

  /// Registers [intent]. Duplicate ids throw [StateError].
  void register(CommandIntent intent) {
    if (_byId.containsKey(intent.id)) {
      throw StateError('Duplicate command id: "${intent.id}"');
    }
    _byId[intent.id] = intent;
  }

  /// Registers every intent in [intents] in order.
  void registerAll(Iterable<CommandIntent> intents) {
    for (final intent in intents) {
      register(intent);
    }
  }

  /// Number of registered commands.
  int get length => _byId.length;

  /// True when no commands are registered.
  bool get isEmpty => _byId.isEmpty;

  /// Looks up a command by id, or null when unknown.
  CommandIntent? byId(String id) => _byId[id];

  /// Stable enumeration: intents sorted by id ascending.
  ///
  /// Same content ⇒ same order, every run. Palettes and cheatsheets render
  /// from this order; never from registration order.
  List<CommandIntent> enumerate() {
    final intents = _byId.values.toList(growable: false)
      ..sort((a, b) => a.id.compareTo(b.id));
    return List.unmodifiable(intents);
  }

  /// Enumerates only intents applicable in [context] (stable order kept).
  List<CommandIntent> enumerateApplicable(CommandContext context) =>
      List.unmodifiable(
        enumerate().where((intent) => intent.appliesTo(context)),
      );

  /// All contested chords, sorted by chord (deterministic).
  List<CommandCollision> collisions() {
    final byChord = <String, List<String>>{};
    for (final intent in _byId.values) {
      final chord = intent.chord;
      if (chord == null) continue;
      byChord.putIfAbsent(chord.normalized, () => []).add(intent.id);
    }
    final result = <CommandCollision>[];
    for (final entry in byChord.entries) {
      if (entry.value.length < 2) continue;
      final sorted = entry.value.toList()..sort();
      result.add(
        CommandCollision(
          chord: entry.key,
          winnerId: sorted.first,
          shadowedIds: sorted.sublist(1),
        ),
      );
    }
    result.sort((a, b) => a.chord.compareTo(b.chord));
    return result;
  }

  /// Resolves [chord] to its winning intent under precedence law.
  ///
  /// Accepts a parsed [CommandChord] or a display string (parsed with
  /// [CommandChord.parse]). Unmatched chords resolve to [matched] == false.
  ChordResolution resolveChord(Object chord) {
    final String normalized;
    if (chord is CommandChord) {
      normalized = chord.normalized;
    } else if (chord is String) {
      normalized = CommandChord.parse(chord).normalized;
    } else {
      throw ArgumentError.value(
        chord,
        'chord',
        'Expected a CommandChord or a chord display string',
      );
    }
    CommandIntent? winner;
    final shadowed = <String>[];
    for (final intent in enumerate()) {
      if (intent.chord?.normalized == normalized) {
        if (winner == null) {
          winner = intent;
        } else {
          shadowed.add(intent.id);
        }
      }
    }
    return ChordResolution(
      chord: normalized,
      winner: winner,
      shadowedIds: shadowed,
    );
  }

  /// Self-doc catalog: stable enumeration with indices plus collisions.
  ///
  /// When [context] is supplied, each entry is the contextual
  /// [CommandIntent.describeFor] form; otherwise the static
  /// [CommandIntent.describe] form. `index` is the stable enumeration
  /// position (0-based, id-sorted).
  Map<String, Object?> describe([CommandContext? context]) {
    final intents = enumerate();
    final entries = <Map<String, Object?>>[];
    for (var i = 0; i < intents.length; i++) {
      entries.add({
        'index': i,
        ...(context == null
            ? intents[i].describe()
            : intents[i].describeFor(context)),
      });
    }
    return {
      'count': intents.length,
      'commands': entries,
      'collisions': collisions().map((c) => c.describe()).toList(),
    };
  }
}

/// Deterministic reference catalog for the conformance suite.
///
/// Fixed content (sorted illustration commands, one contested chord, one
/// availability-gated command) so the suite proves enumeration stability,
/// collision determinism, and disabled-reason propagation against a frozen
/// fixture — not against ad-hoc test data.
abstract final class ReferenceCommandCatalog {
  /// Builds the frozen reference registry (fresh instance per call).
  static CommandRegistry build() {
    final registry = CommandRegistry();
    registry.registerAll([
      const CommandIntent(
        id: 'catalog.open',
        label: 'Open Catalog',
        description: 'Navigate to the component gallery',
        chord: CommandChord(ctrl: true, key: 'k'),
      ),
      const CommandIntent(
        id: 'session.abort',
        label: 'Abort Session',
        description: 'Abort the active session',
        chord: CommandChord(ctrl: true, shift: true, key: 'a'),
      ),
      const CommandIntent(
        id: 'theme.toggle',
        label: 'Toggle Theme',
        description: 'Switch between dark and light themes',
        chord: CommandChord(ctrl: true, key: 't'),
      ),
      // Contested chord: 'ctrl+k' is claimed by both catalog.open and
      // workspace.search — precedence law elects 'catalog.open'.
      const CommandIntent(
        id: 'workspace.search',
        label: 'Search Workspace',
        description: 'Search across workspace symbols',
        chord: CommandChord(ctrl: true, key: 'k'),
      ),
    ]);
    return registry;
  }

  /// Builds the reference registry plus a deny-gated command whose reason
  /// names the missing capability (1868 fail-closed shape).
  static CommandRegistry buildWithGated() {
    final registry = build();
    registry.register(
      CommandIntent(
        id: 'deploy.promote',
        label: 'Promote Deploy',
        description: 'Promote the staged deploy to production',
        chord: const CommandChord(ctrl: true, key: 'd'),
        resolveAvailability: (context) => context.flag('deployer')
            ? const ActionAvailability.allow()
            : ActionAvailability.missing('deploy.promote'),
      ),
    );
    return registry;
  }
}
