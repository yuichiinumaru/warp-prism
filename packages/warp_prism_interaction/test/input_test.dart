import 'package:test/test.dart';
import 'package:warp_prism_interaction/warp_prism_interaction.dart';

void main() {
  group('InputModifiers', () {
    test('default, none, and boolean queries', () {
      const none = InputModifiers.none();
      expect(none.isShiftPressed, isFalse);
      expect(none.isControlPressed, isFalse);
      expect(none.isAltPressed, isFalse);
      expect(none.isMetaPressed, isFalse);
      expect(none.isAnyPressed, isFalse);
      expect(none.isPrimaryModifierPressed, isFalse);

      const shiftOnly = InputModifiers(isShiftPressed: true);
      expect(shiftOnly.isShiftPressed, isTrue);
      expect(shiftOnly.isAnyPressed, isTrue);
      expect(shiftOnly.isPrimaryModifierPressed, isFalse);

      const ctrlShift = InputModifiers(
        isControlPressed: true,
        isShiftPressed: true,
      );
      expect(ctrlShift.isPrimaryModifierPressed, isTrue);

      const metaOnly = InputModifiers(isMetaPressed: true);
      expect(metaOnly.isPrimaryModifierPressed, isTrue);
    });

    test('value equality and hashCode', () {
      const m1 = InputModifiers(isShiftPressed: true);
      const m2 = InputModifiers(isShiftPressed: true);
      const m3 = InputModifiers(isAltPressed: true);

      expect(m1, equals(m2));
      expect(m1.hashCode, equals(m2.hashCode));
      expect(m1, isNot(equals(m3)));
    });
  });

  group('InputIntent models', () {
    test('PointerIntent creation and properties', () {
      final intent = PointerIntent(
        kind: PointerIntentKind.click,
        x: 100.5,
        y: 200.0,
        button: PointerButton.primary,
        modifiers: const InputModifiers(isShiftPressed: true),
        targetId: 'node-1',
      );

      expect(intent.kind, equals(PointerIntentKind.click));
      expect(intent.x, equals(100.5));
      expect(intent.y, equals(200.0));
      expect(intent.button, equals(PointerButton.primary));
      expect(intent.modifiers.isShiftPressed, isTrue);
      expect(intent.targetId, equals('node-1'));
    });

    test('KeyboardIntent creation and properties', () {
      final intent = KeyboardIntent(
        action: KeyboardAction.shortcut,
        key: 'k',
        code: 'KeyK',
        modifiers: const InputModifiers(isMetaPressed: true),
        targetId: 'search_bar',
      );

      expect(intent.action, equals(KeyboardAction.shortcut));
      expect(intent.key, equals('k'));
      expect(intent.code, equals('KeyK'));
      expect(intent.modifiers.isMetaPressed, isTrue);
      expect(intent.targetId, equals('search_bar'));
    });

    test('A11yIntent creation and properties', () {
      final intent = A11yIntent(
        action: A11yAction.activate,
        semanticRole: 'button',
        targetId: 'btn-submit',
      );

      expect(intent.action, equals(A11yAction.activate));
      expect(intent.semanticRole, equals('button'));
      expect(intent.targetId, equals('btn-submit'));
    });
  });

  group('DefaultInputNormalizer', () {
    const normalizer = DefaultInputNormalizer();

    test('normalizePointer maps descriptors deterministically', () {
      const rawClick = RawPointerDescriptor(
        kindName: 'tap',
        x: 50.0,
        y: 75.0,
        buttonIndex: 0,
        targetId: 'chip-1',
      );

      final intent = normalizer.normalizePointer(rawClick);
      expect(intent.kind, equals(PointerIntentKind.click));
      expect(intent.x, equals(50.0));
      expect(intent.y, equals(75.0));
      expect(intent.button, equals(PointerButton.primary));
      expect(intent.targetId, equals('chip-1'));

      const rawSecondary = RawPointerDescriptor(
        kindName: 'contextmenu',
        x: 10.0,
        y: 20.0,
        buttonIndex: 1,
      );
      final secIntent = normalizer.normalizePointer(rawSecondary);
      expect(secIntent.kind, equals(PointerIntentKind.contextMenu));
      expect(secIntent.button, equals(PointerButton.secondary));
    });

    test('normalizeKeyboard maps key down/up and shortcut actions', () {
      const rawKeyDown = RawKeyDescriptor(
        keyName: 'Enter',
        code: 'Enter',
        isDown: true,
      );
      final enterIntent = normalizer.normalizeKeyboard(rawKeyDown);
      expect(enterIntent.action, equals(KeyboardAction.press));
      expect(enterIntent.key, equals('Enter'));

      const rawShortcut = RawKeyDescriptor(
        keyName: 's',
        code: 'KeyS',
        isDown: true,
        modifiers: InputModifiers(isControlPressed: true),
      );
      final saveIntent = normalizer.normalizeKeyboard(rawShortcut);
      expect(saveIntent.action, equals(KeyboardAction.shortcut));
      expect(saveIntent.modifiers.isControlPressed, isTrue);

      const rawKeyUp = RawKeyDescriptor(keyName: 'Shift', isDown: false);
      final releaseIntent = normalizer.normalizeKeyboard(rawKeyUp);
      expect(releaseIntent.action, equals(KeyboardAction.release));
    });

    test('normalizeA11y maps semantic actions', () {
      const rawA11y = RawA11yDescriptor(
        actionName: 'activate',
        role: 'button',
        targetId: 'ok-btn',
      );
      final a11yIntent = normalizer.normalizeA11y(rawA11y);
      expect(a11yIntent.action, equals(A11yAction.activate));
      expect(a11yIntent.semanticRole, equals('button'));
      expect(a11yIntent.targetId, equals('ok-btn'));
    });
  });
}
