// Input junk/adversarial sweep (Task 1867, part c).
//
// Mechanism mirror of `src/input/`. Stable test ids follow the canonical
// convention (`stableTestId` in the testkit): `[input_junk_<case>]`.
// Raw descriptors carry caller-controlled names — normalization must never
// throw and must be deterministic (same descriptor ⇒ equal intent).

import 'package:test/test.dart';
import 'package:warp_prism_interaction/warp_prism_interaction.dart';

List<String> _junkNames() => <String>[
  '',
  ' ',
  'null',
  'Enter',
  '🔥Key',
  'Key:日本語',
  '<tab>',
  '{{modifier}}',
  'a' * 200,
];

String _id(String c) => '[input_junk_$c]';

void main() {
  group('input junk sweep', () {
    test('${_id('keyboard_roundtrip')} junk key names normalize safely', () {
      const normalizer = DefaultInputNormalizer();
      for (final junk in _junkNames()) {
        final intent = normalizer.normalizeKeyboard(
          RawKeyDescriptor(
            keyName: junk,
            code: junk,
            isDown: true,
            targetId: junk,
          ),
        );
        expect(intent.key, equals(junk));
        expect(intent.code, equals(junk));
        expect(intent.targetId, equals(junk));
        expect(intent.action, equals(KeyboardAction.press));
      }
    });

    test('${_id('release_action')} key-up stays release on junk', () {
      const normalizer = DefaultInputNormalizer();
      final intent = normalizer.normalizeKeyboard(
        const RawKeyDescriptor(keyName: '🔥', isDown: false),
      );
      expect(intent.action, equals(KeyboardAction.release));
      expect(intent.key, equals('🔥'));
    });

    test('${_id('pointer_coordinates')} junk pointers keep coordinates', () {
      const normalizer = DefaultInputNormalizer();
      for (final junk in _junkNames()) {
        final intent = normalizer.normalizePointer(
          RawPointerDescriptor(
            kindName: junk,
            x: -12345.678,
            y: 1e308,
            buttonIndex: 99,
            targetId: junk,
          ),
        );
        expect(intent.x, equals(-12345.678));
        expect(intent.y, equals(1e308));
        expect(intent.targetId, equals(junk));
        expect(intent.kind, isA<PointerIntentKind>());
      }
    });

    test('${_id('deterministic')} same descriptor gives equal intents', () {
      const normalizer = DefaultInputNormalizer();
      for (final junk in _junkNames()) {
        final first = normalizer.normalizeA11y(
          RawA11yDescriptor(actionName: junk, role: junk, targetId: junk),
        );
        final second = normalizer.normalizeA11y(
          RawA11yDescriptor(actionName: junk, role: junk, targetId: junk),
        );
        expect(first, equals(second));
        expect(first.targetId, equals(junk));
      }
    });
  });
}
