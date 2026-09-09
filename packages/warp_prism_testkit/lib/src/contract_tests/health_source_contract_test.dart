import 'dart:async';
import 'package:meta/meta.dart';
import 'package:test/test.dart';
import 'package:warp_prism_runtime/warp_prism_runtime.dart';

/// Reusable contract compliance test suite for [HealthSource] implementations.
///
/// Verifies snapshot querying, freshness metadata, cell filtering helpers,
/// aggregate state calculations, and reactive watch stream updates.
///
/// Lifecycle: EXPERIMENTAL (see `docs/architecture/layer-contracts-v2.md`).
@experimental
void verifyHealthSourceContract({
  required HealthSource Function() createSource,
  void Function(HealthSource source, HealthSnapshot snapshot)? emitSnapshot,
  void Function(HealthSource source, HealthCell cell)? updateCell,
  void Function(HealthSource source, Object error, [StackTrace? stackTrace])?
  emitWatchError,
  String description = 'HealthSource Contract Compliance',
}) {
  group(description, () {
    late HealthSource source;

    setUp(() {
      source = createSource();
    });

    tearDown(() async {
      if (!source.isClosed) {
        await source.close();
      }
    });

    test('getSnapshot returns a valid point-in-time HealthSnapshot', () async {
      final snapshot = await source.getSnapshot();
      expect(snapshot, isNotNull);
      expect(snapshot.timestamp, isNotNull);
      expect(snapshot.cells, isA<List<HealthCell>>());
      expect(snapshot.aggregateState, isA<HealthState>());
    });

    test('HealthSnapshot freshness evaluation checks expiration TTL', () {
      final now = DateTime.now();
      final freshSnapshot = HealthSnapshot(
        timestamp: now,
        cells: const [],
        aggregateState: HealthState.healthy,
        freshnessTtl: const Duration(seconds: 30),
      );

      expect(freshSnapshot.isFresh(asOf: now), isTrue);
      expect(
        freshSnapshot.isFresh(asOf: now.add(const Duration(seconds: 45))),
        isFalse,
      );
    });

    test('HealthSnapshot cell query helpers filter correctly', () {
      const cell1 = HealthCell(
        id: 'c1',
        providerId: 'p1',
        providerLabel: 'Provider 1',
        dimensionId: 'latency',
        dimensionLabel: 'Latency',
        state: HealthState.healthy,
      );
      const cell2 = HealthCell(
        id: 'c2',
        providerId: 'p1',
        providerLabel: 'Provider 1',
        dimensionId: 'error_rate',
        dimensionLabel: 'Error Rate',
        state: HealthState.degraded,
      );
      const cell3 = HealthCell(
        id: 'c3',
        providerId: 'p2',
        providerLabel: 'Provider 2',
        dimensionId: 'latency',
        dimensionLabel: 'Latency',
        state: HealthState.unreachable,
      );

      final snapshot = HealthSnapshot(
        timestamp: DateTime.now(),
        cells: const [cell1, cell2, cell3],
        aggregateState: HealthState.unreachable,
      );

      expect(snapshot.getCell('c2'), equals(cell2));
      expect(snapshot.getCell('c_missing'), isNull);

      final p1Cells = snapshot.cellsForProvider('p1');
      expect(p1Cells.length, equals(2));
      expect(p1Cells.map((c) => c.id), containsAll(['c1', 'c2']));

      final latencyCells = snapshot.cellsForDimension('latency');
      expect(latencyCells.length, equals(2));
      expect(latencyCells.map((c) => c.id), containsAll(['c1', 'c3']));
    });

    test('HealthSnapshot deriveAggregateState computes worst-state fold', () {
      expect(
        HealthSnapshot.deriveAggregateState(const []),
        equals(HealthState.unknown),
      );

      const healthyCell = HealthCell(
        id: '1',
        providerId: 'p',
        providerLabel: 'P',
        dimensionId: 'd',
        dimensionLabel: 'D',
        state: HealthState.healthy,
      );
      const degradedCell = HealthCell(
        id: '2',
        providerId: 'p',
        providerLabel: 'P',
        dimensionId: 'd',
        dimensionLabel: 'D',
        state: HealthState.degraded,
      );
      const unreachableCell = HealthCell(
        id: '3',
        providerId: 'p',
        providerLabel: 'P',
        dimensionId: 'd',
        dimensionLabel: 'D',
        state: HealthState.unreachable,
      );

      expect(
        HealthSnapshot.deriveAggregateState([healthyCell]),
        equals(HealthState.healthy),
      );
      expect(
        HealthSnapshot.deriveAggregateState([healthyCell, degradedCell]),
        equals(HealthState.degraded),
      );
      expect(
        HealthSnapshot.deriveAggregateState([
          healthyCell,
          degradedCell,
          unreachableCell,
        ]),
        equals(HealthState.unreachable),
      );
    });

    if (emitSnapshot != null) {
      test('watch stream emits updated snapshots when state changes', () async {
        final received = <HealthSnapshot>[];
        final sub = source.watch().listen(received.add);

        final newSnapshot = HealthSnapshot(
          timestamp: DateTime.now(),
          cells: const [
            HealthCell(
              id: 'c_test',
              providerId: 'p_test',
              providerLabel: 'Test Provider',
              dimensionId: 'dim',
              dimensionLabel: 'Dimension',
              state: HealthState.degraded,
            ),
          ],
          aggregateState: HealthState.degraded,
        );

        emitSnapshot(source, newSnapshot);
        await Future<void>.delayed(const Duration(milliseconds: 10));

        expect(received.length, equals(1));
        expect(received.first.aggregateState, equals(HealthState.degraded));

        await sub.cancel();
      });
    }

    if (updateCell != null) {
      test(
        'updateCell triggers snapshot update with revised aggregate state',
        () async {
          final received = <HealthSnapshot>[];
          final sub = source.watch().listen(received.add);

          const cell = HealthCell(
            id: 'c_live',
            providerId: 'p_live',
            providerLabel: 'Live Provider',
            dimensionId: 'auth',
            dimensionLabel: 'Auth Probe',
            state: HealthState.unreachable,
          );

          updateCell(source, cell);
          await Future<void>.delayed(const Duration(milliseconds: 10));

          expect(received.isNotEmpty, isTrue);
          expect(received.last.aggregateState, equals(HealthState.unreachable));

          await sub.cancel();
        },
      );
    }

    if (emitWatchError != null) {
      test(
        'watch stream emits errors to subscriber without closing or corrupting source',
        () async {
          Object? capturedError;
          final sub = source.watch().listen(
            (_) {},
            onError: (err, st) => capturedError = err,
          );

          final testError = StateError('Health observation probe failed');
          emitWatchError(source, testError);
          await Future<void>.delayed(const Duration(milliseconds: 10));

          expect(capturedError, equals(testError));
          expect(source.isClosed, isFalse);

          // Subsequent point-in-time snapshot retrieval remains functional
          final snapshot = await source.getSnapshot();
          expect(snapshot, isNotNull);
          expect(snapshot.aggregateState, isA<HealthState>());

          await sub.cancel();
        },
      );
    }

    test(
      'source close terminates watch stream, updates isClosed, and post-close queries fail',
      () async {
        final testSource = createSource();
        var watchDone = false;
        final sub = testSource.watch().listen(
          (_) {},
          onDone: () => watchDone = true,
        );

        expect(testSource.isClosed, isFalse);
        await testSource.close();

        await Future<void>.delayed(const Duration(milliseconds: 10));

        expect(testSource.isClosed, isTrue);
        expect(watchDone, isTrue);

        // Subsequent close() call is idempotent
        await testSource.close();
        expect(testSource.isClosed, isTrue);

        // Post-close queries fail deterministically
        expect(() => testSource.getSnapshot(), throwsA(isA<StateError>()));

        await sub.cancel();
      },
    );
  });
}

void main() {}
