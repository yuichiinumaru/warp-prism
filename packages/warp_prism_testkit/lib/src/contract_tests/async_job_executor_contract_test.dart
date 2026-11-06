import 'package:meta/meta.dart';
import 'package:test/test.dart';
import 'package:warp_prism_runtime/warp_prism_runtime.dart';

/// Reusable contract compliance test suite for [AsyncJobExecutor] peers.
///
/// Runs identically against the fake executor and the FRB-backed executor:
/// per-execution identity, concurrent-job isolation, cancellation/refusal
/// disclosure, the verbatim refusal contract, and deterministic health
/// snapshots. Fake and adapter must pass this identical suite (MISSION §6
/// item 6).
///
/// [createExecutor] must return a fresh executor whose command factory serves
/// [sampleResult] for [sampleParam] (fake: configured result; FRB adapter: a
/// command type whose native behavior echoes the input).
///
/// Lifecycle: EXPERIMENTAL (see `.project/architecture/layer-contracts.md`).
@experimental
void verifyAsyncJobExecutorContract<TParam, TResult>({
  required AsyncJobExecutor<TParam, TResult> Function() createExecutor,
  required TParam Function(int index) sampleParam,
  required TResult sampleResult,
  String description = 'AsyncJobExecutor Contract Compliance',
}) {
  group(description, () {
    group('per-execution identity', () {
      test('concurrent executions carry distinct identity', () async {
        final executor = createExecutor();
        final handleA = executor.submit(sampleParam(1));
        final handleB = executor.submit(sampleParam(2));

        expect(
          handleA.executionId,
          isNot(equals(handleB.executionId)),
          reason: 'concurrent jobs must never share execution identity',
        );
        expect(executor.activeCount, equals(2));
        expect(
          executor.activeExecutionIds,
          containsAll([handleA.executionId, handleB.executionId]),
        );

        final resA = await handleA.result;
        final resB = await handleB.result;
        expect(resA, isA<CommandSuccess<TResult>>());
        expect(resB, isA<CommandSuccess<TResult>>());
        expect(executor.activeCount, equals(0));

        await executor.close();
      });

      test('sequential executions mint strictly newer identity', () async {
        final executor = createExecutor();

        final first = executor.submit(sampleParam(1));
        final firstId = first.executionId;
        expect(await first.result, isA<CommandSuccess<TResult>>());

        final second = executor.submit(sampleParam(2));
        expect(
          second.executionId,
          isNot(equals(firstId)),
          reason: 'each submit must claim a strictly newer identity',
        );
        expect(await second.result, isA<CommandSuccess<TResult>>());

        await executor.close();
      });

      test('concurrent executions resolve independently', () async {
        final executor = createExecutor();
        final handles = List.generate(
          3,
          (i) => executor.submit(sampleParam(i)),
        );
        final ids = handles.map((h) => h.executionId).toList();
        expect(ids.toSet().length, equals(3));

        for (final handle in handles) {
          expect(await handle.result, isA<CommandSuccess<TResult>>());
        }
        expect(executor.activeCount, equals(0));

        await executor.close();
      });
    });

    group('cancellation and refusal disclosure', () {
      test(
        'pre-cancelled execution reports CommandCancelled with reason',
        () async {
          final executor = createExecutor();
          final token = CancellationToken()..cancel('abort before dispatch');

          final handle = executor.submit(
            sampleParam(1),
            cancellationToken: token,
          );
          final res = await handle.result;

          expect(res, isA<CommandCancelled<TResult>>());
          expect(
            (res as CommandCancelled<TResult>).reason,
            equals('abort before dispatch'),
          );

          await executor.close();
        },
      );

      test('cancelling one execution leaves its sibling unaffected', () async {
        final executor = createExecutor();
        final doomedToken = CancellationToken()..cancel('abort A');

        final handleA = executor.submit(
          sampleParam(1),
          cancellationToken: doomedToken,
        );
        final handleB = executor.submit(sampleParam(2));

        final resA = await handleA.result;
        final resB = await handleB.result;

        expect(resA, isA<CommandCancelled<TResult>>());
        expect((resA as CommandCancelled<TResult>).reason, equals('abort A'));
        expect(resB, isA<CommandSuccess<TResult>>());
        expect(handleB.isCancellationRequested, isFalse);

        await executor.close();
      });

      test('submit after close throws; close is idempotent', () async {
        final executor = createExecutor();
        await executor.close();
        expect(executor.isClosed, isTrue);
        expect(
          () => executor.submit(sampleParam(1)),
          throwsA(isA<StateError>()),
        );
        await executor.close();
        expect(executor.isClosed, isTrue);
      });
    });

    group('terminality and refusal standard', () {
      test('pathRefusedPrefix is the verbatim cross-boundary invariant', () {
        expect(pathRefusedPrefix, equals('path refused ['));
      });

      test('isTerminalMediaError: only decode/seek are non-terminal', () {
        expect(isTerminalMediaError(PrismMediaErrorKind.decodeFailed), isFalse);
        expect(isTerminalMediaError(PrismMediaErrorKind.seekFailed), isFalse);
        for (final kind in [
          PrismMediaErrorKind.sessionClosed,
          PrismMediaErrorKind.unknownHandle,
          PrismMediaErrorKind.ioError,
          PrismMediaErrorKind.noVideoStream,
          PrismMediaErrorKind.unsupportedCodec,
          PrismMediaErrorKind.probeFailed,
          PrismMediaErrorKind.surfaceError,
          PrismMediaErrorKind.invalid,
        ]) {
          expect(isTerminalMediaError(kind), isTrue, reason: '$kind');
        }
      });

      test('refusal detail is extracted before the variant label', () {
        expect(
          describePathRefusal('path refused [sandbox]: EACCES denied'),
          equals('sandbox'),
        );
        expect(describePathRefusal('plain Invalid input'), isNull);
        expect(
          mediaErrorLabel(
            PrismMediaErrorKind.invalid,
            message: 'path refused [sandbox]: EACCES denied',
          ),
          equals('Path refused (sandbox)'),
          reason: 'a policy refusal must never render as plain "Invalid"',
        );
      });

      test('sample result round-trips through CommandSuccess', () {
        final result = CommandSuccess<TResult>(
          value: sampleResult,
          duration: Duration.zero,
          timestamp: DateTime.fromMillisecondsSinceEpoch(0),
        );
        expect(result.value, equals(sampleResult));
      });
    });

    group('deterministic health snapshots', () {
      HealthSnapshot sampleSnapshot(DateTime timestamp) => HealthSnapshot(
        timestamp: timestamp,
        cells: const [
          HealthCell(
            id: 'executor-c-latency',
            providerId: 'executor-provider',
            providerLabel: 'Executor Provider',
            dimensionId: 'latency',
            dimensionLabel: 'Latency',
            state: HealthState.healthy,
          ),
          HealthCell(
            id: 'executor-c-errors',
            providerId: 'executor-provider',
            providerLabel: 'Executor Provider',
            dimensionId: 'error-rate',
            dimensionLabel: 'Error Rate',
            state: HealthState.degraded,
          ),
        ],
        aggregateState: HealthState.degraded,
        freshnessTtl: const Duration(seconds: 30),
      );

      test('same cells always derive the same aggregate', () {
        final timestamp = DateTime.fromMillisecondsSinceEpoch(1000);
        final first = sampleSnapshot(timestamp);
        final second = sampleSnapshot(timestamp);

        expect(first.aggregateState, equals(HealthState.degraded));
        expect(
          HealthSnapshot.deriveAggregateState(first.cells),
          equals(first.aggregateState),
        );
        expect(second.aggregateState, equals(first.aggregateState));
        expect(second.cells.length, equals(first.cells.length));
      });

      test('freshness is deterministic for an explicit asOf', () {
        final timestamp = DateTime.fromMillisecondsSinceEpoch(1000);
        final snapshot = sampleSnapshot(timestamp);

        expect(snapshot.isFresh(asOf: timestamp), isTrue);
        expect(
          snapshot.isFresh(asOf: timestamp.add(const Duration(seconds: 45))),
          isFalse,
        );
      });
    });
  });
}

void main() {}
