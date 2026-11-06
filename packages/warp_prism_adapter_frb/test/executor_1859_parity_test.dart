import 'dart:io';

import 'package:test/test.dart';
import 'package:warp_prism_adapter_frb/warp_prism_adapter_frb.dart';
import 'package:warp_prism_runtime/warp_prism_runtime.dart';
import 'package:warp_prism_testkit/warp_prism_testkit.dart';

String _resolveDylib() {
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
  throw StateError(
    'Could not locate libwarp_bridge_frb.so in candidate paths: $candidates',
  );
}

void main() {
  setUpAll(() async {
    await WarpBridge.init(dylibPath: _resolveDylib());
  });

  group('FrbAsyncJobExecutor Contract Verification (Task 1859)', () {
    // The IDENTICAL suite the fake passes in
    // packages/warp_prism_testkit/test/async_job_executor_contract_test.dart,
    // executed here against an FRB-backed command factory (MISSION §6 item 6).
    verifyAsyncJobExecutorContract<String, String>(
      createExecutor: () => AsyncJobExecutor<String, String>(
        commandFactory: () => FrbAsyncCommand(commandType: 'echo'),
      ),
      sampleParam: (index) => 'parity-$index',
      sampleResult: 'echo: parity-1',
      description: 'FrbAsyncJobExecutor Contract Compliance',
    );
  });

  group('Fake-vs-adapter parity (Task 1859)', () {
    test('executor terminal kinds match: success, cancelled, closed', () async {
      final fake = FakeAsyncJobExecutor<String, String>(
        initialResult: 'fake-ok',
      );
      final live = AsyncJobExecutor<String, String>(
        commandFactory: () => FrbAsyncCommand(commandType: 'echo'),
      );

      final fakeHandle = fake.submit('job');
      final liveHandle = live.submit('job');
      expect(fakeHandle.executionId, isNotEmpty);
      expect(liveHandle.executionId, isNotEmpty);
      expect(await fakeHandle.result, isA<CommandSuccess<String>>());
      expect(await liveHandle.result, isA<CommandSuccess<String>>());

      final doomed = CancellationToken()..cancel('parity abort');
      final fakeCancelled = fake.submit('job', cancellationToken: doomed);
      final liveCancelled = live.submit(
        'job',
        cancellationToken: CancellationToken()..cancel('parity abort'),
      );
      expect(await fakeCancelled.result, isA<CommandCancelled<String>>());
      expect(await liveCancelled.result, isA<CommandCancelled<String>>());

      await fake.close();
      await live.close();
      expect(() => fake.submit('late'), throwsA(isA<StateError>()));
      expect(() => live.submit('late'), throwsA(isA<StateError>()));
    });

    test(
      'health snapshots match: same cells, same aggregate, same freshness',
      () async {
        final timestamp = DateTime.fromMillisecondsSinceEpoch(1700000000000);
        final snapshot = HealthSnapshot(
          timestamp: timestamp,
          cells: const [
            HealthCell(
              id: 'parity-cpu',
              providerId: 'native-core',
              providerLabel: 'Native Core Substrate',
              dimensionId: 'cpu',
              dimensionLabel: 'CPU',
              state: HealthState.healthy,
            ),
            HealthCell(
              id: 'parity-mem',
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

        final fake = FakeHealthSource(initialSnapshot: snapshot);
        final live = FrbHealthSource();
        await live.setSnapshot(snapshot);

        final fakeSnap = await fake.getSnapshot();
        final liveSnap = await live.getSnapshot();

        expect(liveSnap.aggregateState, equals(fakeSnap.aggregateState));
        expect(liveSnap.cells.length, equals(fakeSnap.cells.length));
        for (final cell in fakeSnap.cells) {
          expect(liveSnap.getCell(cell.id)?.state, equals(cell.state));
        }
        expect(
          liveSnap.isFresh(asOf: timestamp),
          equals(fakeSnap.isFresh(asOf: timestamp)),
        );
        expect(
          liveSnap.isFresh(asOf: timestamp.add(const Duration(seconds: 45))),
          equals(
            fakeSnap.isFresh(asOf: timestamp.add(const Duration(seconds: 45))),
          ),
        );

        await fake.close();
        await live.close();
      },
    );
  });
}
