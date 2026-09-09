import 'package:test/test.dart';
import 'package:warp_prism_interaction/warp_prism_interaction.dart';

/// Input contract normalization test suite for Task 1817.
///
/// Asserts:
/// 1. Same input descriptor -> identical intent payload equality (value equality & hashCode).
/// 2. Deterministic normalization across pointer, keyboard, and accessibility channels.
/// 3. Cross-alias normalization produces identical semantic intent values.
/// 4. Pure-Dart execution verified on Linux desktop host CI environment.
void main() {
  const normalizer = DefaultInputNormalizer();

  group('Pointer Input Normalization & Payload Equality', () {
    test('same pointer descriptor yields identical normalized intent payload', () {
      const descriptor1 = RawPointerDescriptor(
        kindName: 'click',
        x: 120.0,
        y: 84.5,
        buttonIndex: 0,
        modifiers: InputModifiers(isShiftPressed: true),
        targetId: 'node-stage-1',
      );

      const descriptor2 = RawPointerDescriptor(
        kindName: 'click',
        x: 120.0,
        y: 84.5,
        buttonIndex: 0,
        modifiers: InputModifiers(isShiftPressed: true),
        targetId: 'node-stage-1',
      );

      final intent1 = normalizer.normalizePointer(descriptor1);
      final intent2 = normalizer.normalizePointer(descriptor2);

      expect(intent1, equals(intent2));
      expect(intent1.hashCode, equals(intent2.hashCode));
      expect(intent1.kind, equals(PointerIntentKind.click));
      expect(intent1.button, equals(PointerButton.primary));
      expect(intent1.x, equals(120.0));
      expect(intent1.y, equals(84.5));
      expect(intent1.modifiers.isShiftPressed, isTrue);
      expect(intent1.targetId, equals('node-stage-1'));
    });

    test('pointer kind aliases map to identical PointerIntentKind values', () {
      final clickIntent = normalizer.normalizePointer(
        const RawPointerDescriptor(kindName: 'click', x: 10, y: 10),
      );
      final tapIntent = normalizer.normalizePointer(
        const RawPointerDescriptor(kindName: 'tap', x: 10, y: 10),
      );
      expect(clickIntent.kind, equals(PointerIntentKind.click));
      expect(tapIntent.kind, equals(PointerIntentKind.click));
      expect(clickIntent, equals(tapIntent));

      final hoverIntent = normalizer.normalizePointer(
        const RawPointerDescriptor(kindName: 'hover', x: 0, y: 0),
      );
      final moveIntent = normalizer.normalizePointer(
        const RawPointerDescriptor(kindName: 'move', x: 0, y: 0),
      );
      expect(hoverIntent.kind, equals(PointerIntentKind.hover));
      expect(moveIntent.kind, equals(PointerIntentKind.hover));
      expect(hoverIntent, equals(moveIntent));

      final doubleClick1 = normalizer.normalizePointer(
        const RawPointerDescriptor(kindName: 'doubleclick', x: 5, y: 5),
      );
      final doubleClick2 = normalizer.normalizePointer(
        const RawPointerDescriptor(kindName: 'doubletap', x: 5, y: 5),
      );
      final doubleClick3 = normalizer.normalizePointer(
        const RawPointerDescriptor(kindName: 'double_click', x: 5, y: 5),
      );
      expect(doubleClick1.kind, equals(PointerIntentKind.doubleClick));
      expect(doubleClick2.kind, equals(PointerIntentKind.doubleClick));
      expect(doubleClick3.kind, equals(PointerIntentKind.doubleClick));
      expect(doubleClick1, equals(doubleClick2));
      expect(doubleClick2, equals(doubleClick3));

      final ctx1 = normalizer.normalizePointer(
        const RawPointerDescriptor(kindName: 'contextmenu', x: 0, y: 0, buttonIndex: 1),
      );
      final ctx2 = normalizer.normalizePointer(
        const RawPointerDescriptor(kindName: 'secondary_click', x: 0, y: 0, buttonIndex: 1),
      );
      final ctx3 = normalizer.normalizePointer(
        const RawPointerDescriptor(kindName: 'right_click', x: 0, y: 0, buttonIndex: 1),
      );
      expect(ctx1.kind, equals(PointerIntentKind.contextMenu));
      expect(ctx1.button, equals(PointerButton.secondary));
      expect(ctx1, equals(ctx2));
      expect(ctx2, equals(ctx3));
    });

    test('pointer button mapping covers primary, secondary, tertiary, and none', () {
      final p0 = normalizer.normalizePointer(
        const RawPointerDescriptor(kindName: 'press', x: 0, y: 0, buttonIndex: 0),
      );
      final p1 = normalizer.normalizePointer(
        const RawPointerDescriptor(kindName: 'press', x: 0, y: 0, buttonIndex: 1),
      );
      final p2 = normalizer.normalizePointer(
        const RawPointerDescriptor(kindName: 'press', x: 0, y: 0, buttonIndex: 2),
      );
      final p99 = normalizer.normalizePointer(
        const RawPointerDescriptor(kindName: 'press', x: 0, y: 0, buttonIndex: 99),
      );

      expect(p0.button, equals(PointerButton.primary));
      expect(p1.button, equals(PointerButton.secondary));
      expect(p2.button, equals(PointerButton.tertiary));
      expect(p99.button, equals(PointerButton.none));
    });
  });

  group('Keyboard Input Normalization & Payload Equality', () {
    test('same key descriptor yields identical normalized intent payload', () {
      const k1 = RawKeyDescriptor(
        keyName: 'Enter',
        code: 'Enter',
        isDown: true,
        modifiers: InputModifiers(isControlPressed: true),
        targetId: 'filter-search',
      );

      const k2 = RawKeyDescriptor(
        keyName: 'Enter',
        code: 'Enter',
        isDown: true,
        modifiers: InputModifiers(isControlPressed: true),
        targetId: 'filter-search',
      );

      final intent1 = normalizer.normalizeKeyboard(k1);
      final intent2 = normalizer.normalizeKeyboard(k2);

      expect(intent1, equals(intent2));
      expect(intent1.hashCode, equals(intent2.hashCode));
      expect(intent1.action, equals(KeyboardAction.shortcut));
      expect(intent1.key, equals('Enter'));
      expect(intent1.code, equals('Enter'));
      expect(intent1.modifiers.isControlPressed, isTrue);
      expect(intent1.targetId, equals('filter-search'));
    });

    test('keyboard action distinguishes press, release, and shortcut', () {
      const pressRaw = RawKeyDescriptor(keyName: 'Space', isDown: true);
      final pressIntent = normalizer.normalizeKeyboard(pressRaw);
      expect(pressIntent.action, equals(KeyboardAction.press));

      const releaseRaw = RawKeyDescriptor(keyName: 'Space', isDown: false);
      final releaseIntent = normalizer.normalizeKeyboard(releaseRaw);
      expect(releaseIntent.action, equals(KeyboardAction.release));

      const shortcutRaw = RawKeyDescriptor(
        keyName: 'k',
        isDown: true,
        modifiers: InputModifiers(isMetaPressed: true),
      );
      final shortcutIntent = normalizer.normalizeKeyboard(shortcutRaw);
      expect(shortcutIntent.action, equals(KeyboardAction.shortcut));
    });
  });

  group('Accessibility Input Normalization & Payload Equality', () {
    test('same a11y descriptor yields identical normalized intent payload', () {
      const a1 = RawA11yDescriptor(
        actionName: 'activate',
        role: 'button',
        targetId: 'apply-filter-btn',
      );

      const a2 = RawA11yDescriptor(
        actionName: 'activate',
        role: 'button',
        targetId: 'apply-filter-btn',
      );

      final intent1 = normalizer.normalizeA11y(a1);
      final intent2 = normalizer.normalizeA11y(a2);

      expect(intent1, equals(intent2));
      expect(intent1.hashCode, equals(intent2.hashCode));
      expect(intent1.action, equals(A11yAction.activate));
      expect(intent1.semanticRole, equals('button'));
      expect(intent1.targetId, equals('apply-filter-btn'));
    });

    test('a11y action aliases map to canonical A11yAction values', () {
      final act1 = normalizer.normalizeA11y(
        const RawA11yDescriptor(actionName: 'activate'),
      );
      final act2 = normalizer.normalizeA11y(
        const RawA11yDescriptor(actionName: 'tap'),
      );
      expect(act1.action, equals(A11yAction.activate));
      expect(act2.action, equals(A11yAction.activate));
      expect(act1, equals(act2));

      final dis1 = normalizer.normalizeA11y(
        const RawA11yDescriptor(actionName: 'dismiss'),
      );
      final dis2 = normalizer.normalizeA11y(
        const RawA11yDescriptor(actionName: 'escape'),
      );
      expect(dis1.action, equals(A11yAction.dismiss));
      expect(dis2.action, equals(A11yAction.dismiss));
      expect(dis1, equals(dis2));

      final foc = normalizer.normalizeA11y(
        const RawA11yDescriptor(actionName: 'focus'),
      );
      expect(foc.action, equals(A11yAction.focus));

      final scr = normalizer.normalizeA11y(
        const RawA11yDescriptor(actionName: 'scroll'),
      );
      expect(scr.action, equals(A11yAction.scroll));

      final custom = normalizer.normalizeA11y(
        const RawA11yDescriptor(actionName: 'custom_voice_trigger'),
      );
      expect(custom.action, equals(A11yAction.custom));
    });
  });

  group('Cross-Modal Activation Intent Alignment', () {
    test('pointer click, keyboard activation, and a11y activation target same entity', () {
      const target = 'stage-node-enrich';

      final pointerClick = normalizer.normalizePointer(
        const RawPointerDescriptor(
          kindName: 'tap',
          x: 100,
          y: 50,
          targetId: target,
        ),
      );

      final keyboardPress = normalizer.normalizeKeyboard(
        const RawKeyDescriptor(
          keyName: 'Enter',
          isDown: true,
          targetId: target,
        ),
      );

      final a11yActivate = normalizer.normalizeA11y(
        const RawA11yDescriptor(
          actionName: 'activate',
          role: 'button',
          targetId: target,
        ),
      );

      // All channels preserve the target entity correlation
      expect(pointerClick.targetId, equals(target));
      expect(keyboardPress.targetId, equals(target));
      expect(a11yActivate.targetId, equals(target));

      // Actions are activation semantics in their respective models
      expect(pointerClick.kind, equals(PointerIntentKind.click));
      expect(keyboardPress.action, equals(KeyboardAction.press));
      expect(a11yActivate.action, equals(A11yAction.activate));
    });
  });
}
