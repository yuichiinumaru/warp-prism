import 'package:meta/meta.dart';
import 'input_modifiers.dart';

/// Interaction gesture kind for pointer inputs.
///
/// Lifecycle: PROVEN (see `docs/architecture/layer-contracts-v2.md`).
enum PointerIntentKind {
  hover,
  press,
  release,
  click,
  doubleClick,
  contextMenu,
  drag,
}

/// Physical pointer button identification.
///
/// Lifecycle: PROVEN (see `docs/architecture/layer-contracts-v2.md`).
enum PointerButton { primary, secondary, tertiary, none }

/// Keyboard event action category.
///
/// Lifecycle: PROVEN (see `docs/architecture/layer-contracts-v2.md`).
enum KeyboardAction { press, release, shortcut }

/// Accessibility semantics intent action.
///
/// Lifecycle: PROVEN (see `docs/architecture/layer-contracts-v2.md`).
enum A11yAction { activate, focus, dismiss, scroll, custom }

/// Root sealed contract for normalized input intents.
///
/// Converts platform and device input streams into standardized semantic
/// intent representations without importing framework UI classes.
///
/// Lifecycle: PROVEN (see `docs/architecture/layer-contracts-v2.md`).
@immutable
sealed class InputIntent {
  /// Optional target identifier associated with the input.
  final String? targetId;

  /// Timestamp when the input intent was captured.
  final DateTime timestamp;

  const InputIntent({this.targetId, required this.timestamp});
}

/// Normalized pointer interaction intent.
///
/// Lifecycle: PROVEN (see `docs/architecture/layer-contracts-v2.md`).
@immutable
class PointerIntent extends InputIntent {
  /// Category of pointer event.
  final PointerIntentKind kind;

  /// Horizontal position coordinate (device or canvas-relative).
  final double x;

  /// Vertical position coordinate (device or canvas-relative).
  final double y;

  /// Pointer button pressed, if applicable.
  final PointerButton button;

  /// Active modifier keys at the time of input.
  final InputModifiers modifiers;

  PointerIntent({
    required this.kind,
    required this.x,
    required this.y,
    this.button = PointerButton.primary,
    this.modifiers = const InputModifiers.none(),
    super.targetId,
    DateTime? timestamp,
  }) : super(timestamp: timestamp ?? DateTime.now());

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! PointerIntent) return false;
    return other.kind == kind &&
        other.x == x &&
        other.y == y &&
        other.button == button &&
        other.modifiers == modifiers &&
        other.targetId == targetId;
  }

  @override
  int get hashCode => Object.hash(kind, x, y, button, modifiers, targetId);

  @override
  String toString() =>
      'PointerIntent($kind, pos: ($x, $y), button: $button, target: $targetId)';
}

/// Normalized keyboard input intent.
///
/// Lifecycle: PROVEN (see `docs/architecture/layer-contracts-v2.md`).
@immutable
class KeyboardIntent extends InputIntent {
  /// Key action classification.
  final KeyboardAction action;

  /// Logical key string representation (e.g. 'Enter', 'Escape', 'ArrowDown').
  final String key;

  /// Physical or platform key code identifier (e.g. 'KeyA', 'Enter').
  final String? code;

  /// Active modifier keys at the time of key event.
  final InputModifiers modifiers;

  KeyboardIntent({
    required this.action,
    required this.key,
    this.code,
    this.modifiers = const InputModifiers.none(),
    super.targetId,
    DateTime? timestamp,
  }) : super(timestamp: timestamp ?? DateTime.now());

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! KeyboardIntent) return false;
    return other.action == action &&
        other.key == key &&
        other.code == code &&
        other.modifiers == modifiers &&
        other.targetId == targetId;
  }

  @override
  int get hashCode => Object.hash(action, key, code, modifiers, targetId);

  @override
  String toString() =>
      'KeyboardIntent($action, key: "$key", code: $code, modifiers: $modifiers, target: $targetId)';
}

/// Normalized accessibility / screen-reader input intent.
///
/// Lifecycle: PROVEN (see `docs/architecture/layer-contracts-v2.md`).
@immutable
class A11yIntent extends InputIntent {
  /// The semantic accessibility action requested.
  final A11yAction action;

  /// Optional semantic role or accessibility node label.
  final String? semanticRole;

  A11yIntent({
    required this.action,
    this.semanticRole,
    super.targetId,
    DateTime? timestamp,
  }) : super(timestamp: timestamp ?? DateTime.now());

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! A11yIntent) return false;
    return other.action == action &&
        other.semanticRole == semanticRole &&
        other.targetId == targetId;
  }

  @override
  int get hashCode => Object.hash(action, semanticRole, targetId);

  @override
  String toString() =>
      'A11yIntent($action, role: $semanticRole, target: $targetId)';
}
