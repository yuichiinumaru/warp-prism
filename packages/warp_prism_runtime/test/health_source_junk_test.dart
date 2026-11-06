// Health-source junk/adversarial sweep (Task 1867, part c).
//
// Mechanism mirror of `src/health_source/`. Stable test ids follow the
// canonical convention (`stableTestId` in the testkit):
// `[health_source_junk_<case>]`. Cell/provider/dimension ids are caller
// vocabularies — junk must round-trip, look up correctly, and stay
// deterministic under an injected clock (no wall-clock reads in the sweep).

import 'package:test/test.dart';
import 'package:warp_prism_runtime/warp_prism_runtime.dart';

List<String> _junkTexts() => <String>[
  '',
  'null',
  'cell:🔥:日本語',
  '<provider/>',
  '{{dimension}}',
  'a' * 300,
];

String _id(String c) => '[health_source_junk_$c]';

HealthCell _junkCell(String junk) => HealthCell(
  id: junk,
  providerId: junk,
  providerLabel: junk,
  dimensionId: junk,
  dimensionLabel: junk,
  state: HealthState.degraded,
);

void main() {
  group('health source junk sweep', () {
    test('${_id('cell_roundtrip')} junk cells round-trip', () {
      for (final junk in _junkTexts()) {
        final cell = _junkCell(junk);
        expect(cell.id, equals(junk));
        expect(cell.providerId, equals(junk));
        expect(cell.dimensionLabel, equals(junk));
        expect(cell, equals(_junkCell(junk)));
      }
    });

    test('${_id('snapshot_lookup')} junk cells look up by junk id', () {
      final fixed = DateTime(2026, 5, 1, 12);
      const junkId = '🔥-cell-日本語';
      final snapshot = HealthSnapshot(
        timestamp: fixed,
        cells: [_junkCell(junkId), _junkCell('other')],
        aggregateState: HealthState.degraded,
      );
      expect(snapshot.getCell(junkId)?.providerLabel, equals(junkId));
      expect(snapshot.getCell('missing:{{id}}'), isNull);
    });

    test('${_id('freshness_deterministic')} freshness uses injected clock', () {
      final stamped = DateTime(2026, 5, 1, 12);
      final snapshot = HealthSnapshot(
        timestamp: stamped,
        cells: const [],
        aggregateState: HealthState.healthy,
        freshnessTtl: const Duration(minutes: 5),
      );
      expect(
        snapshot.isFresh(asOf: stamped.add(const Duration(minutes: 4))),
        isTrue,
      );
      expect(
        snapshot.isFresh(asOf: stamped.add(const Duration(minutes: 6))),
        isFalse,
      );
    });
  });
}
