import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_adapter_frb/warp_prism_adapter_frb.dart';
import 'package:warp_prism_bindings/warp_prism_bindings.dart';
import 'package:warp_prism_runtime/warp_prism_runtime.dart';
import 'package:warp_prism_testkit/warp_prism_testkit.dart';

String? _resolveDylib() {
  final candidates = [
    '${Directory.current.path}/../../rust/target/debug/libwarp_bridge_frb.so',
    '${Directory.current.path}/../../rust/target/release/libwarp_bridge_frb.so',
    '${Directory.current.path}/../rust/target/debug/libwarp_bridge_frb.so',
    '${Directory.current.path}/../rust/target/release/libwarp_bridge_frb.so',
    '${Directory.current.path}/rust/target/debug/libwarp_bridge_frb.so',
    '${Directory.current.path}/rust/target/release/libwarp_bridge_frb.so',
  ];
  for (final candidate in candidates) {
    if (File(candidate).existsSync()) return candidate;
  }
  return null;
}

RuntimeEvent<String> _sampleEvent(int index) => RuntimeEvent<String>(
  id: 'executor-1859-evt-$index',
  timestamp: DateTime.fromMillisecondsSinceEpoch(1700000000000 + index),
  severity: index.isEven ? EventSeverity.info : EventSeverity.warning,
  source: 'parity-probe',
  runGroupId: 'executor-1859',
  payload: 'payload-$index',
);

HealthSnapshot _sampleSnapshot() => HealthSnapshot(
  timestamp: DateTime.fromMillisecondsSinceEpoch(1700000000000),
  cells: const [
    HealthCell(
      id: 'executor-1859-cpu',
      providerId: 'native-core',
      providerLabel: 'Native Core Substrate',
      dimensionId: 'cpu',
      dimensionLabel: 'CPU',
      state: HealthState.healthy,
    ),
    HealthCell(
      id: 'executor-1859-mem',
      providerId: 'native-core',
      providerLabel: 'Native Core Substrate',
      dimensionId: 'memory',
      dimensionLabel: 'Memory',
      state: HealthState.degraded,
    ),
  ],
  aggregateState: HealthState.degraded,
  freshnessTtl: const Duration(seconds: 30),
);

void main() {
  group('executor_1859 binding parity: fake vs adapter (Task 1859)', () {
    test('EventStreamBinding projects identically for FakeEventStream and '
        'FrbLocalEventStream', () async {
      final fakeSource = FakeEventStream<RuntimeEvent<String>>();
      final liveSource = FrbLocalEventStream();

      final fakeBinding = EventStreamBinding<RuntimeEvent<String>>(
        source: fakeSource,
      );
      final liveBinding = EventStreamBinding<RuntimeEvent<String>>(
        source: liveSource,
      );

      for (var i = 0; i < 3; i++) {
        fakeSource.emit(_sampleEvent(i));
        liveSource.emit(_sampleEvent(i));
      }
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(liveBinding.events, equals(fakeBinding.events));
      expect(liveBinding.count, equals(fakeBinding.count));

      final fakeLines = fakeBinding.toExecutionLines();
      final liveLines = liveBinding.toExecutionLines();
      expect(liveLines.map((l) => l.id), equals(fakeLines.map((l) => l.id)));
      expect(
        liveLines.map((l) => l.message),
        equals(fakeLines.map((l) => l.message)),
      );

      final fakeEntries = fakeBinding.toLogEntries();
      final liveEntries = liveBinding.toLogEntries();
      expect(
        liveEntries.map((e) => e.message),
        equals(fakeEntries.map((e) => e.message)),
      );
      expect(
        liveEntries.map((e) => e.timestamp),
        equals(fakeEntries.map((e) => e.timestamp)),
      );

      fakeBinding.dispose();
      liveBinding.dispose();
      await fakeSource.close();
      await liveSource.close();
    });

    test('HealthSourceBinding projects identically for FakeHealthSource and '
        'FrbHealthSource', () async {
      final dylibPath = _resolveDylib();
      if (dylibPath == null) {
        markTestSkipped(
          'executor_1859: no libwarp_bridge_frb.so found; run the Rust build '
          'then re-run this test to unlock the adapter-backed health proof.',
        );
        return;
      }
      await WarpBridge.init(dylibPath: dylibPath);

      final snapshot = _sampleSnapshot();
      final fakeSource = FakeHealthSource(initialSnapshot: snapshot);
      final liveSource = FrbHealthSource();
      await liveSource.setSnapshot(snapshot);

      final fakeBinding = HealthSourceBinding(
        source: fakeSource,
        autoInitialize: false,
      );
      final liveBinding = HealthSourceBinding(
        source: liveSource,
        autoInitialize: false,
      );
      await fakeBinding.initialize();
      await liveBinding.initialize();
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(liveBinding.aggregateState, equals(fakeBinding.aggregateState));
      expect(liveBinding.cellCount, equals(fakeBinding.cellCount));
      expect(liveBinding.isStale, equals(fakeBinding.isStale));
      expect(
        liveBinding.providers.map((p) => p.id),
        equals(fakeBinding.providers.map((p) => p.id)),
      );
      expect(
        liveBinding.providers.map((p) => p.aggregateState),
        equals(fakeBinding.providers.map((p) => p.aggregateState)),
      );

      fakeBinding.dispose();
      liveBinding.dispose();
      await fakeSource.close();
      await liveSource.close();
    });
  });
}
