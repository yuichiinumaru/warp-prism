import 'package:meta/meta.dart';

/// A normalized keyboard chord for command dispatch (IDS semantics).
///
/// Pure Dart: the key is a plain string (never `LogicalKeyboardKey`), so IDS
/// stays Flutter-free per the layer contracts. Presentation layers
/// (`DSCommandPaletteShortcut`, `DSCommandRouter`) re-implement the same
/// canonical normalization over `shortcut` display strings; parity is proven
/// by the router molecule conformance test, not by a shared import (the
/// `ui → interaction` production import is dev-only by law).
///
/// Lifecycle: EXPERIMENTAL (Task 1870, F-03). Spec + fake + suite only, no
/// barrel export, no STABLE promotion in this task.
@immutable
final class CommandChord implements Comparable<CommandChord> {
  /// Whether the Control modifier participates.
  final bool ctrl;

  /// Whether the Meta/Command modifier participates.
  final bool meta;

  /// Whether the Alt/Option modifier participates.
  final bool alt;

  /// Whether the Shift modifier participates.
  final bool shift;

  /// The chord key, lowercased and trimmed (e.g. `'k'`, `'enter'`, `' '`).
  ///
  /// Never empty; enforced by the constructor assertion and the parser.
  final String key;

  const CommandChord({
    this.ctrl = false,
    this.meta = false,
    this.alt = false,
    this.shift = false,
    required this.key,
  }) : assert(key.length > 0, 'CommandChord requires a non-empty key');

  /// Parses a display string such as `'Ctrl+K'`, `'cmd+shift+p'`, `'Space'`.
  ///
  /// Case-insensitive, whitespace-tolerant. Modifier aliases: `control`/`ctrl`,
  /// `cmd`/`command`/`meta`, `alt`/`option`/`opt`, `shift`. The last
  /// non-modifier token is the key; a chord with no key throws
  /// [ArgumentError]. Deterministic: same input ⇒ same chord.
  factory CommandChord.parse(String display) {
    final tokens = display
        .split('+')
        .map((part) => part.trim().toLowerCase())
        .where((part) => part.isNotEmpty)
        .toList(growable: false);
    if (tokens.isEmpty) {
      throw ArgumentError.value(display, 'display', 'Empty chord string');
    }
    var ctrl = false;
    var meta = false;
    var alt = false;
    var shift = false;
    String? key;
    for (final token in tokens) {
      switch (token) {
        case 'ctrl':
        case 'control':
          ctrl = true;
        case 'meta':
        case 'cmd':
        case 'command':
          meta = true;
        case 'alt':
        case 'option':
        case 'opt':
          alt = true;
        case 'shift':
          shift = true;
        default:
          key = token;
      }
    }
    final resolved = key;
    if (resolved == null || resolved.isEmpty) {
      throw ArgumentError.value(
        display,
        'display',
        'Chord has modifiers but no key',
      );
    }
    return CommandChord(
      ctrl: ctrl,
      meta: meta,
      alt: alt,
      shift: shift,
      key: resolved,
    );
  }

  /// Canonical machine form: modifiers in fixed order + key (`'ctrl+k'`).
  ///
  /// Modifier order is `ctrl, meta, alt, shift`. Two chords collide exactly
  /// when their [normalized] forms are equal, so collision detection is a
  /// string equality — deterministic across runs.
  String get normalized {
    final parts = <String>[];
    if (ctrl) parts.add('ctrl');
    if (meta) parts.add('meta');
    if (alt) parts.add('alt');
    if (shift) parts.add('shift');
    parts.add(key);
    return parts.join('+');
  }

  /// Human display form (`'Ctrl+K'`, `'Shift+Enter'`, `'Space'`).
  String get displayString {
    final parts = <String>[];
    if (ctrl) parts.add('Ctrl');
    if (meta) parts.add('Meta');
    if (alt) parts.add('Alt');
    if (shift) parts.add('Shift');
    parts.add(key.length == 1 ? key.toUpperCase() : _titleCase(key));
    return parts.join('+');
  }

  /// True when this chord is a bare printable key (no modifiers).
  ///
  /// Bare keys are suppressed while editing has focus (edit-focus guard):
  /// typing must never dispatch commands.
  bool get isBareKey => !ctrl && !meta && !alt && !shift && key.length == 1;

  @override
  int compareTo(CommandChord other) => normalized.compareTo(other.normalized);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CommandChord &&
          other.ctrl == ctrl &&
          other.meta == meta &&
          other.alt == alt &&
          other.shift == shift &&
          other.key == key);

  @override
  int get hashCode => Object.hash(ctrl, meta, alt, shift, key);

  @override
  String toString() => 'CommandChord($normalized)';
}

String _titleCase(String input) {
  if (input.isEmpty) return input;
  return input[0].toUpperCase() + input.substring(1);
}
