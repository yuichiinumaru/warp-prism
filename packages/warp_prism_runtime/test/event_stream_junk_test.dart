// Event-stream junk/adversarial sweep (Task 1867, part c).
//
// Mechanism mirror of `src/event_stream/`. Stable test ids follow the
// canonical convention (`stableTestId` in the testkit):
// `[event_stream_junk_<case>]`. Events are opaque caller payloads — models
// must round-trip junk (ids, sources, payloads, metadata) without crashing
// and stay equal for identical junk.

import 'package:test/test.dart';
import 'package:warp_prism_runtime/warp_prism_runtime.dart';

List<String> _junkTexts() => <String>[
  '',
  'null',
  'source:🔥:日本語',
  '<event/>',
  '{{payload}}',
  'a' * 500,
  'line one\nline two',
];

String _id(String c) => '[event_stream_junk_$c]';

void main() {
  group('event stream junk sweep', () {
    test('${_id('event_roundtrip')} junk events round-trip', () {
      final fixed = DateTime(2026, 1, 1);
      for (final junk in _junkTexts()) {
        final event = RuntimeEvent<String>(
          id: junk,
          timestamp: fixed,
          payload: junk,
          source: junk,
          runGroupId: junk,
        );
        expect(event.id, equals(junk));
        expect(event.payload, equals(junk));
        expect(event.source, equals(junk));
        expect(
          event,
          equals(
            RuntimeEvent<String>(
              id: junk,
              timestamp: fixed,
              payload: junk,
              source: junk,
              runGroupId: junk,
            ),
          ),
        );
      }
    });

    test('${_id('copy_preserves')} copyWith keeps junk unless overridden', () {
      final event = RuntimeEvent<String>(
        id: '🔥',
        timestamp: DateTime(2026, 1, 1),
        payload: '<x/>',
      );
      final copied = event.copyWith(source: '日本語');
      expect(copied.id, equals('🔥'));
      expect(copied.payload, equals('<x/>'));
      expect(copied.source, equals('日本語'));
    });

    test('${_id('metadata_junk')} junk metadata maps survive', () {
      final event = RuntimeEvent<String>(
        id: 'm',
        timestamp: DateTime(2026, 1, 1),
        payload: 'p',
        metadata: {'🔥': '<v/>', 'nested\nkey': '{{v}}'},
      );
      expect(event.metadata['🔥'], equals('<v/>'));
      expect(event.metadata['nested\nkey'], equals('{{v}}'));
    });
  });
}
