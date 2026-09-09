import 'dart:async';
import 'package:test/test.dart';
import 'package:warp_prism_runtime/warp_prism_runtime.dart';
import 'package:warp_prism_testkit/warp_prism_testkit.dart';

void main() {
  group('FakeHealthSource Contract Verification', () {
    verifyHealthSourceContract(
      createSource: () => FakeHealthSource(
        initialSnapshot: HealthSnapshot(
          timestamp: DateTime.now(),
          cells: const [
            HealthCell(
              id: 'c_init',
              providerId: 'p_init',
              providerLabel: 'Initial Provider',
              dimensionId: 'status',
              dimensionLabel: 'Status',
              state: HealthState.healthy,
            ),
          ],
          aggregateState: HealthState.healthy,
        ),
      ),
      emitSnapshot: (source, snapshot) =>
          (source as FakeHealthSource).setSnapshot(snapshot),
      updateCell: (source, cell) =>
          (source as FakeHealthSource).updateCell(cell),
      emitWatchError: (source, error, [st]) =>
          (source as FakeHealthSource).emitWatchError(error, st),
    );

    test(
      'FakeHealthSource tracks snapshot queries and simulates degradation',
      () async {
        final source = FakeHealthSource(
          initialSnapshot: HealthSnapshot(
            timestamp: DateTime.now(),
            cells: const [
              HealthCell(
                id: 'c1',
                providerId: 'p1',
                providerLabel: 'P1',
                dimensionId: 'dim',
                dimensionLabel: 'Dim',
                state: HealthState.healthy,
              ),
            ],
            aggregateState: HealthState.healthy,
          ),
        );

        expect(source.snapshotQueryCount, equals(0));
        final s1 = await source.getSnapshot();
        expect(source.snapshotQueryCount, equals(1));
        expect(s1.aggregateState, equals(HealthState.healthy));

        source.simulateDegradation('c1');
        final s2 = await source.getSnapshot();
        expect(source.snapshotQueryCount, equals(2));
        expect(s2.aggregateState, equals(HealthState.degraded));
        expect(
          s2.getCell('c1')?.latency,
          equals(const Duration(milliseconds: 500)),
        );

        source.simulateState(HealthState.unreachable);
        final s3 = await source.getSnapshot();
        expect(s3.aggregateState, equals(HealthState.unreachable));

        await source.close();
      },
    );

    test(
      'FakeHealthSource emitWatchError delivers error to watch stream subscribers',
      () async {
        final source = FakeHealthSource();
        Object? capturedError;
        final sub = source.watch().listen(
          (_) {},
          onError: (err, st) => capturedError = err,
        );

        const error = FormatException('Bad health packet');
        source.emitWatchError(error);
        await Future<void>.delayed(const Duration(milliseconds: 10));

        expect(capturedError, equals(error));
        expect(source.isClosed, isFalse);

        await sub.cancel();
        await source.close();

        expect(
          () => source.emitWatchError(StateError('Closed')),
          throwsA(isA<StateError>()),
        );
      },
    );
  });
}
