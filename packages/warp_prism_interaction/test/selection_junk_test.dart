// Selection junk/adversarial sweep (Task 1867, part c).
//
// Mechanism mirror of `src/selection/selection_state.dart`. Stable test ids
// follow the canonical convention (`stableTestId` in
// `package:warp_prism_testkit/src/junk/junk_sweep.dart`):
// `[selection_junk_<case>]`. Selection ids are opaque data — junk must
// round-trip without crashing and fail closed (no-ops stay no-ops).

import 'package:test/test.dart';
import 'package:warp_prism_interaction/warp_prism_interaction.dart';

/// Representative hostile ids (canonical corpus lives in the testkit).
List<String> _junkIds() => <String>[
  '',
  ' ',
  '\n',
  'null',
  '<script>alert(1)</script>',
  '%s %d %@',
  '{{template}}',
  '🔥🚀',
  '日本語テスト',
  '../../etc/passwd',
  'SELECT * FROM t; --',
  'a' * 500,
  'zero​width',
];

String _id(String c) => '[selection_junk_$c]';

void main() {
  group('selection junk sweep', () {
    test('${_id('corpus_roundtrip')} select/toggle/deselect survive junk', () {
      for (final junk in _junkIds()) {
        final selected = const SelectionState<String>.empty().select(junk);
        expect(selected.contains(junk), isTrue, reason: 'select $junk');

        final toggledOff = selected.toggle(junk);
        expect(toggledOff.contains(junk), isFalse, reason: 'toggle $junk');

        const empty = SelectionState<String>.empty();
        final noop = empty.deselect(junk);
        expect(noop.isEmpty, isTrue, reason: 'deselect-absent $junk');
      }
    });

    test('${_id('select_all_dedup')} bulk junk dedups deterministically', () {
      final junk = _junkIds();
      final first = const SelectionState<String>.empty().selectAll(junk);
      final second = const SelectionState<String>.empty().selectAll(
        junk.reversed,
      );
      expect(first.count, equals(Set<String>.of(junk).length));
      expect(first.selectedItems, equals(second.selectedItems));
      expect(first.primarySelection, equals(junk.last));
    });

    test('${_id('clear_anchor')} junk anchors survive preserveAnchor', () {
      const junkAnchor = '🔥-anchor-日本語';
      final anchored = const SelectionState<String>.empty()
          .select('item')
          .withAnchor(junkAnchor);
      final kept = anchored.clear(preserveAnchor: true);
      expect(kept.isEmpty, isTrue);
      expect(kept.anchor, equals(junkAnchor));

      final dropped = anchored.clear();
      expect(dropped.isEmpty, isTrue);
      expect(dropped.anchor, isNull);
    });

    test('${_id('mode_none_noop')} none-mode stays a no-op on junk', () {
      final populated = SelectionState<String>.single('keep');
      for (final junk in _junkIds()) {
        expect(
          populated.select(junk, mode: SelectionMode.none).selectedItems,
          equals({'keep'}),
        );
        expect(
          populated.toggle(junk, mode: SelectionMode.none).selectedItems,
          equals({'keep'}),
        );
      }
    });
  });
}
