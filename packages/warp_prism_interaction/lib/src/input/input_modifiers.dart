import 'package:meta/meta.dart';

/// Immutable record of active keyboard modifier keys.
///
/// Lifecycle: PROVEN (see `.project/architecture/layer-contracts.md`).
@immutable
class InputModifiers {
  /// Shift modifier state.
  final bool isShiftPressed;

  /// Control modifier state.
  final bool isControlPressed;

  /// Alt / Option modifier state.
  final bool isAltPressed;

  /// Meta / Command / Windows modifier state.
  final bool isMetaPressed;

  const InputModifiers({
    this.isShiftPressed = false,
    this.isControlPressed = false,
    this.isAltPressed = false,
    this.isMetaPressed = false,
  });

  /// No modifiers active.
  const InputModifiers.none()
    : isShiftPressed = false,
      isControlPressed = false,
      isAltPressed = false,
      isMetaPressed = false;

  /// True if any modifier key is currently depressed.
  bool get isAnyPressed =>
      isShiftPressed || isControlPressed || isAltPressed || isMetaPressed;

  /// True if a platform-standard command modifier (Ctrl or Meta) is depressed.
  bool get isPrimaryModifierPressed => isControlPressed || isMetaPressed;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! InputModifiers) return false;
    return other.isShiftPressed == isShiftPressed &&
        other.isControlPressed == isControlPressed &&
        other.isAltPressed == isAltPressed &&
        other.isMetaPressed == isMetaPressed;
  }

  @override
  int get hashCode => Object.hash(
    isShiftPressed,
    isControlPressed,
    isAltPressed,
    isMetaPressed,
  );

  @override
  String toString() =>
      'InputModifiers(shift: $isShiftPressed, ctrl: $isControlPressed, alt: $isAltPressed, meta: $isMetaPressed)';
}
