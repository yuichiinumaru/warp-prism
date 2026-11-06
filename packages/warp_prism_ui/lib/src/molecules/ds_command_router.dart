import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../organisms/command_palette/ds_command_palette.dart';

/// Command dispatch router molecule with edit-focus guard (Task 1870, F-03).
///
/// Routes keyboard chords to [DSCommand] entries WITHOUT rendering a
/// palette: given a chord, it resolves the winning command under precedence
/// law (lexicographically smallest id wins — parity with the IDS
/// `CommandRegistry` in `packages/warp_prism_interaction/lib/src/command/`;
/// proven by the router conformance test, not by a shared import, since the
/// `ui → interaction` production import is dev-only by layer law).
///
/// Resolution for a chord:
/// 1. No claimant ⇒ ignored (typing must keep working; [onUnknownChord]
///    observes for diagnostics).
/// 2. Bare printable key while [editingHasFocus] ⇒ [onRefused] with the
///    focus-guard reason (typing never dispatches). Modified chords still
///    dispatch while editing (e.g. `Ctrl+K` opens the palette).
/// 3. Winner disabled ([DSCommand.disabledReason] != null) ⇒ [onRefused]
///    with the propagated reason; the command never dispatches.
/// 4. Otherwise ⇒ [onDispatch].
///
/// The keyboard guard stays presentation: eligibility semantics stay IDS.
/// The palette stays presentation: it renders and reports taps; it never
/// routes chords.
///
/// Lifecycle: EXPERIMENTAL (Task 1870, F-03). Intentionally **not** exported
/// from any barrel and without a `Prism*` alias until the promotion task
/// wires the public surface (mirrors the Task 1868 `DSActionGate` precedent).
class DSCommandRouter extends StatefulWidget {
  /// Routable commands (normally the same list handed to the palette).
  final List<DSCommand> commands;

  /// Child subtree the router listens over.
  final Widget child;

  /// Whether a text-editing surface currently has focus.
  ///
  /// Product-owned: the composition site projects its focus state here.
  /// When true, bare keys are suppressed with a refusal reason.
  final bool editingHasFocus;

  /// Called with the winning command when a chord dispatches.
  final ValueChanged<DSCommand>? onDispatch;

  /// Called with the command and its reason when dispatch is refused
  /// (disabled-with-reason or edit-focus guard).
  final void Function(DSCommand command, String reason)? onRefused;

  /// Observes unmatched chords for diagnostics. Never dispatches.
  final ValueChanged<String>? onUnknownChord;

  /// Focus node for the key listener; created internally when null.
  final FocusNode? focusNode;

  /// Whether the router grabs focus on mount. Defaults to true so bare
  /// chords resolve without an extra tap in host-exercise sweeps.
  final bool autofocus;

  const DSCommandRouter({
    super.key,
    required this.commands,
    required this.child,
    this.editingHasFocus = false,
    this.onDispatch,
    this.onRefused,
    this.onUnknownChord,
    this.focusNode,
    this.autofocus = true,
  });

  /// Announcement for a refused dispatch: label plus reason.
  static String refusalAnnouncement(DSCommand command, String reason) =>
      '${command.label}. Refused: $reason';

  /// Canonical chord normalization (parity with IDS `CommandChord.normalized`).
  ///
  /// Lowercases, trims, splits on `+`, sorts modifiers into the fixed order
  /// `ctrl, meta, alt, shift`, and rejoins with the key last. Aliases:
  /// `control`→`ctrl`, `cmd`/`command`→`meta`, `option`/`opt`→`alt`.
  /// A chord with no key returns null (unroutable).
  static String? normalizeChordDisplay(String display) {
    final tokens = display
        .split('+')
        .map((part) => part.trim().toLowerCase())
        .where((part) => part.isNotEmpty)
        .toList(growable: false);
    if (tokens.isEmpty) return null;
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
    if (key == null || key.isEmpty) return null;
    final parts = <String>[];
    if (ctrl) parts.add('ctrl');
    if (meta) parts.add('meta');
    if (alt) parts.add('alt');
    if (shift) parts.add('shift');
    parts.add(key);
    return parts.join('+');
  }

  @override
  State<DSCommandRouter> createState() => _DSCommandRouterState();
}

class _DSCommandRouterState extends State<DSCommandRouter> {
  FocusNode? _internalNode;

  FocusNode get _node =>
      widget.focusNode ??
      (_internalNode ??= FocusNode(debugLabel: 'DSCommandRouter'));

  @override
  void dispose() {
    _internalNode?.dispose();
    super.dispose();
  }

  /// Builds the normalized chord for [event] from live modifier state.
  static String _chordForEvent(KeyDownEvent event) {
    final parts = <String>[];
    if (HardwareKeyboard.instance.isControlPressed) parts.add('ctrl');
    if (HardwareKeyboard.instance.isMetaPressed) parts.add('meta');
    if (HardwareKeyboard.instance.isAltPressed) parts.add('alt');
    if (HardwareKeyboard.instance.isShiftPressed) parts.add('shift');
    parts.add(event.logicalKey.keyLabel.toLowerCase());
    return parts.join('+');
  }

  /// Ordered claimants for [normalized]: id-sorted, smallest id first.
  List<DSCommand> _claimants(String normalized) {
    final matches =
        widget.commands
            .where((cmd) {
              final shortcut = cmd.shortcut;
              if (shortcut == null) return false;
              return DSCommandRouter.normalizeChordDisplay(shortcut) ==
                  normalized;
            })
            .toList(growable: false)
          ..sort((a, b) => a.id.compareTo(b.id));
    return matches;
  }

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    // Modifier-only presses never route.
    if (event.logicalKey == LogicalKeyboardKey.controlLeft ||
        event.logicalKey == LogicalKeyboardKey.controlRight ||
        event.logicalKey == LogicalKeyboardKey.metaLeft ||
        event.logicalKey == LogicalKeyboardKey.metaRight ||
        event.logicalKey == LogicalKeyboardKey.altLeft ||
        event.logicalKey == LogicalKeyboardKey.altRight ||
        event.logicalKey == LogicalKeyboardKey.shiftLeft ||
        event.logicalKey == LogicalKeyboardKey.shiftRight) {
      return KeyEventResult.ignored;
    }

    final normalized = _chordForEvent(event);
    final claimants = _claimants(normalized);
    if (claimants.isEmpty) {
      widget.onUnknownChord?.call(normalized);
      return KeyEventResult.ignored;
    }

    final winner = claimants.first;
    final bareKey = !normalized.contains('+') && normalized.length == 1;

    if (widget.editingHasFocus && bareKey) {
      widget.onRefused?.call(
        winner,
        'Editing has focus — "$normalized" not dispatched',
      );
      return KeyEventResult.handled;
    }

    final reason = winner.disabledReason;
    if (reason != null) {
      widget.onRefused?.call(winner, reason);
      return KeyEventResult.handled;
    }

    widget.onDispatch?.call(winner);
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _node,
      autofocus: widget.autofocus,
      onKeyEvent: _handleKey,
      child: widget.child,
    );
  }
}
