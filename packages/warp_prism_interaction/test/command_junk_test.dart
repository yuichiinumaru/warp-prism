// Command junk/adversarial sweep (Task 1867, part c).
//
// Mechanism mirror of `src/command/`. Stable test ids follow the canonical
// convention (`stableTestId` in the testkit): `[command_junk_<case>]`.
// Identity collisions are programming errors: empty ids are rejected at
// construction, duplicate ids at registration — never silent overwrites.

import 'package:test/test.dart';
import 'package:warp_prism_interaction/src/command/command.dart';

List<String> _junkIds() => <String>[
  ' ',
  'null',
  'cmd:🔥:日本語',
  '<b>label</b>',
  '{{command}}',
  'a' * 300,
  'trailing space ',
  'UPPER.lower_Mixed',
];

String _id(String c) => '[command_junk_$c]';

void main() {
  group('command junk sweep', () {
    test('${_id('empty_id_rejected')} empty id fails at construction', () {
      expect(
        () => CommandIntent(id: '', label: 'Empty'),
        throwsA(isA<AssertionError>()),
      );
    });

    test('${_id('ids_roundtrip')} junk ids register and enumerate stably', () {
      final first = CommandRegistry();
      final second = CommandRegistry();
      for (final junk in _junkIds().reversed) {
        first.register(CommandIntent(id: junk, label: 'label $junk'));
      }
      for (final junk in _junkIds()) {
        second.register(CommandIntent(id: junk, label: 'label $junk'));
      }
      expect(first.length, equals(_junkIds().length));
      expect(
        first.enumerate().map((intent) => intent.id).toList(),
        equals(second.enumerate().map((intent) => intent.id).toList()),
      );
      for (final junk in _junkIds()) {
        expect(first.byId(junk)?.label, equals('label $junk'));
      }
    });

    test('${_id('duplicate_rejected')} duplicate junk id throws', () {
      final registry = CommandRegistry();
      registry.register(const CommandIntent(id: '🔥-dup', label: 'First'));
      expect(
        () => registry.register(
          const CommandIntent(id: '🔥-dup', label: 'Second'),
        ),
        throwsStateError,
      );
      expect(registry.byId('🔥-dup')?.label, equals('First'));
    });

    test('${_id('unknown_lookup_null')} unknown junk lookup is null', () {
      final registry = CommandRegistry();
      for (final junk in _junkIds()) {
        expect(registry.byId('missing:$junk'), isNull);
      }
      expect(registry.enumerateApplicable(CommandContext.empty), isEmpty);
    });
  });
}
