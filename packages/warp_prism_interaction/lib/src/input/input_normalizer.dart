import 'package:meta/meta.dart';
import 'input_intent.dart';
import 'input_modifiers.dart';

/// Pure Dart raw input description record for pointer events.
///
/// Lifecycle: PROVEN (see `docs/architecture/layer-contracts-v2.md`).
@immutable
class RawPointerDescriptor {
  final String kindName;
  final double x;
  final double y;
  final int buttonIndex;
  final InputModifiers modifiers;
  final String? targetId;

  const RawPointerDescriptor({
    required this.kindName,
    required this.x,
    required this.y,
    this.buttonIndex = 0,
    this.modifiers = const InputModifiers.none(),
    this.targetId,
  });
}

/// Pure Dart raw input description record for keyboard events.
///
/// Lifecycle: PROVEN (see `docs/architecture/layer-contracts-v2.md`).
@immutable
class RawKeyDescriptor {
  final String keyName;
  final String? code;
  final bool isDown;
  final InputModifiers modifiers;
  final String? targetId;

  const RawKeyDescriptor({
    required this.keyName,
    this.code,
    required this.isDown,
    this.modifiers = const InputModifiers.none(),
    this.targetId,
  });
}

/// Pure Dart raw input description record for accessibility events.
///
/// Lifecycle: PROVEN (see `docs/architecture/layer-contracts-v2.md`).
@immutable
class RawA11yDescriptor {
  final String actionName;
  final String? role;
  final String? targetId;

  const RawA11yDescriptor({required this.actionName, this.role, this.targetId});
}

/// Interface contract for mapping raw input descriptions to normalized intents.
///
/// Lifecycle: PROVEN (see `docs/architecture/layer-contracts-v2.md`).
abstract interface class InputNormalizer {
  /// Normalizes a raw pointer descriptor into a [PointerIntent].
  PointerIntent normalizePointer(RawPointerDescriptor descriptor);

  /// Normalizes a raw key descriptor into a [KeyboardIntent].
  KeyboardIntent normalizeKeyboard(RawKeyDescriptor descriptor);

  /// Normalizes a raw accessibility descriptor into an [A11yIntent].
  A11yIntent normalizeA11y(RawA11yDescriptor descriptor);
}

/// Standard reference implementation of [InputNormalizer].
///
/// Lifecycle: PROVEN (see `docs/architecture/layer-contracts-v2.md`).
class DefaultInputNormalizer implements InputNormalizer {
  const DefaultInputNormalizer();

  @override
  PointerIntent normalizePointer(RawPointerDescriptor descriptor) {
    final kind = _resolvePointerKind(descriptor.kindName);
    final button = _resolvePointerButton(descriptor.buttonIndex);

    return PointerIntent(
      kind: kind,
      x: descriptor.x,
      y: descriptor.y,
      button: button,
      modifiers: descriptor.modifiers,
      targetId: descriptor.targetId,
    );
  }

  @override
  KeyboardIntent normalizeKeyboard(RawKeyDescriptor descriptor) {
    final action = descriptor.isDown
        ? (descriptor.modifiers.isAnyPressed
              ? KeyboardAction.shortcut
              : KeyboardAction.press)
        : KeyboardAction.release;

    return KeyboardIntent(
      action: action,
      key: descriptor.keyName,
      code: descriptor.code,
      modifiers: descriptor.modifiers,
      targetId: descriptor.targetId,
    );
  }

  @override
  A11yIntent normalizeA11y(RawA11yDescriptor descriptor) {
    final action = _resolveA11yAction(descriptor.actionName);

    return A11yIntent(
      action: action,
      semanticRole: descriptor.role,
      targetId: descriptor.targetId,
    );
  }

  PointerIntentKind _resolvePointerKind(String name) {
    final normalized = name.toLowerCase().trim();
    switch (normalized) {
      case 'hover':
      case 'move':
        return PointerIntentKind.hover;
      case 'press':
      case 'down':
        return PointerIntentKind.press;
      case 'release':
      case 'up':
        return PointerIntentKind.release;
      case 'click':
      case 'tap':
        return PointerIntentKind.click;
      case 'doubleclick':
      case 'doubletap':
      case 'double_click':
        return PointerIntentKind.doubleClick;
      case 'contextmenu':
      case 'secondary_click':
      case 'right_click':
        return PointerIntentKind.contextMenu;
      case 'drag':
      case 'pan':
        return PointerIntentKind.drag;
      default:
        return PointerIntentKind.click;
    }
  }

  PointerButton _resolvePointerButton(int index) {
    switch (index) {
      case 0:
        return PointerButton.primary;
      case 1:
        return PointerButton.secondary;
      case 2:
        return PointerButton.tertiary;
      default:
        return PointerButton.none;
    }
  }

  A11yAction _resolveA11yAction(String name) {
    final normalized = name.toLowerCase().trim();
    switch (normalized) {
      case 'activate':
      case 'tap':
        return A11yAction.activate;
      case 'focus':
        return A11yAction.focus;
      case 'dismiss':
      case 'escape':
        return A11yAction.dismiss;
      case 'scroll':
        return A11yAction.scroll;
      default:
        return A11yAction.custom;
    }
  }
}
