// Query junk/adversarial sweep (Task 1867, part c).
//
// Mechanism mirror of `src/query/`. Stable test ids follow the canonical
// convention (`stableTestId` in the testkit): `[query_junk_<case>]`.
// Raw queries are opaque caller text — the controller must accept junk
// without crashing and keep fail-closed correlation (stale tokens never
// commit).

import 'package:test/test.dart';
import 'package:warp_prism_interaction/warp_prism_interaction.dart';

List<String> _junkQueries() => <String>[
  '',
  '   ',
  '\t\n',
  'null',
  'service:auth status:🔥',
  'SELECT * FROM events; --',
  '<img src=x onerror=alert(1)>',
  '{{filter}}',
  '%s %d',
  '日本語 クエリ テスト',
  'a' * 1000,
  'line one\ninjected: line two',
];

String _id(String c) => '[query_junk_$c]';

void main() {
  group('query junk sweep', () {
    test('${_id('intent_roundtrip')} junk intents preserve raw text', () {
      for (final junk in _junkQueries()) {
        final intent = QueryIntent(rawQuery: junk, queryToken: junk);
        expect(intent.rawQuery, equals(junk));
        expect(intent.queryToken, equals(junk));
        expect(
          intent.isEmpty,
          equals(junk.trim().isEmpty),
          reason: 'isEmpty for "$junk"',
        );
      }
    });

    test('${_id('submit_preserves')} submit keeps junk intent running', () {
      for (final junk in _junkQueries()) {
        final controller = QueryController<String>();
        final intent = QueryIntent(rawQuery: junk, queryToken: 'tok-$junk');
        controller.submit(intent);
        expect(controller.isRunning, isTrue);
        expect(controller.state.isRunning, isTrue);
        expect(controller.state.intent?.rawQuery, equals(junk));
      }
    });

    test('${_id('empty_submit_no_crash')} empty query submits cleanly', () {
      final controller = QueryController<String>();
      final execution = controller.submit(QueryIntent());
      expect(controller.isRunning, isTrue);
      expect(controller.isCurrentExecution(execution), isTrue);
      expect(controller.state.intent?.isEmpty, isTrue);
    });

    test(
      '${_id('supersede_deterministic')} resubmit supersedes junk state',
      () {
        final controller = QueryController<String>();
        controller.submit(QueryIntent(rawQuery: 'first', queryToken: 'tok-1'));
        final second = controller.submit(
          QueryIntent(rawQuery: '日本語🔥', queryToken: 'tok-2'),
        );
        expect(controller.isRunning, isTrue);
        expect(controller.state.intent?.rawQuery, equals('日本語🔥'));
        expect(controller.isCurrentExecution(second), isTrue);
      },
    );
  });
}
