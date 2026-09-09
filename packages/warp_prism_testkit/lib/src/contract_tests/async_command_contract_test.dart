import 'dart:async';
import 'package:meta/meta.dart';
import 'package:test/test.dart';
import 'package:warp_prism_runtime/warp_prism_runtime.dart';

/// Reusable contract compliance test suite for [AsyncCommand] implementations.
///
/// Verifies lifecycle state transitions (`idle` -> `running` -> `succeeded` / `failed` / `cancelled`),
/// typed parameter passing, structured result returns, sealed error handling,
/// and cooperative cancellation mechanics.
///
/// Lifecycle: EXPERIMENTAL (see `docs/architecture/layer-contracts-v2.md`).
@experimental
void verifyAsyncCommandContract<TParam, TResult>({
  required AsyncCommand<TParam, TResult> Function({
    Future<TResult> Function(TParam param, CancellationToken? token)? handler,
  })
  createCommand,
  required TParam sampleParam,
  required TResult sampleResult,
  required CommandError sampleError,
  String description = 'AsyncCommand Contract Compliance',
}) {
  group(description, () {
    test('initial status is idle', () {
      final command = createCommand(handler: (p, t) async => sampleResult);
      expect(command.status, equals(AsyncCommandStatus.idle));
      command.close();
    });

    test(
      'successful execution returns CommandSuccess with value and duration',
      () async {
        final command = createCommand(
          handler: (param, token) async => sampleResult,
        );

        final result = await command.execute(sampleParam);

        expect(result, isA<CommandSuccess<TResult>>());
        final success = result as CommandSuccess<TResult>;
        expect(success.value, equals(sampleResult));
        expect(success.duration.inMicroseconds, isNonNegative);
        expect(command.status, equals(AsyncCommandStatus.succeeded));

        await command.close();
      },
    );

    test(
      'failed execution returns CommandFailure with typed CommandError',
      () async {
        final command = createCommand(
          handler: (param, token) async => throw StateError('Handler failure'),
        );

        final result = await command.execute(sampleParam);

        expect(result, isA<CommandFailure<TResult>>());
        final failure = result as CommandFailure<TResult>;
        expect(failure.error, isA<CommandError>());
        expect(command.status, equals(AsyncCommandStatus.failed));

        await command.close();
      },
    );

    test(
      'pre-cancelled token returns CommandCancelled and updates status',
      () async {
        final token = CancellationToken();
        final command = createCommand(
          handler: (param, cancelToken) async {
            cancelToken?.throwIfCancelled();
            await Future<void>.delayed(const Duration(milliseconds: 100));
            cancelToken?.throwIfCancelled();
            return sampleResult;
          },
        );

        // Cancel token before execute
        token.cancel('User requested abort');

        final result = await command.execute(
          sampleParam,
          cancellationToken: token,
        );

        expect(result, isA<CommandCancelled<TResult>>());
        final cancelled = result as CommandCancelled<TResult>;
        expect(cancelled.reason, equals('User requested abort'));
        expect(command.status, equals(AsyncCommandStatus.cancelled));

        await command.close();
      },
    );

    test(
      'in-flight cooperative cancellation while running returns CommandCancelled and updates status',
      () async {
        final token = CancellationToken();
        final command = createCommand(
          handler: (param, cancelToken) async {
            final completer = Completer<TResult>();
            void onCancel(String? reason) {
              if (!completer.isCompleted) {
                completer.completeError(CommandCancellationException(reason));
              }
            }

            cancelToken?.attachListener(onCancel);
            try {
              return await completer.future;
            } finally {
              cancelToken?.detachListener(onCancel);
            }
          },
        );

        final statuses = <AsyncCommandStatus>[];
        final sub = command.watchStatus().listen(statuses.add);

        final future = command.execute(sampleParam, cancellationToken: token);

        await Future<void>.delayed(const Duration(milliseconds: 20));
        expect(command.status, equals(AsyncCommandStatus.running));

        token.cancel('In-flight abort');

        final result = await future;

        expect(result, isA<CommandCancelled<TResult>>());
        final cancelled = result as CommandCancelled<TResult>;
        expect(cancelled.reason, equals('In-flight abort'));
        expect(command.status, equals(AsyncCommandStatus.cancelled));
        expect(
          statuses,
          containsAllInOrder([
            AsyncCommandStatus.running,
            AsyncCommandStatus.cancelled,
          ]),
        );

        await sub.cancel();
        await command.close();
      },
    );

    test('watchStatus stream emits lifecycle state transitions', () async {
      final statuses = <AsyncCommandStatus>[];
      final command = createCommand(
        handler: (param, token) async => sampleResult,
      );

      final sub = command.watchStatus().listen(statuses.add);

      await command.execute(sampleParam);
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(
        statuses,
        containsAllInOrder([
          AsyncCommandStatus.running,
          AsyncCommandStatus.succeeded,
        ]),
      );

      await sub.cancel();
      await command.close();
    });

    test('handler receives input parameter payload intact', () async {
      TParam? receivedParam;
      final command = createCommand(
        handler: (param, token) async {
          receivedParam = param;
          return sampleResult;
        },
      );

      await command.execute(sampleParam);
      expect(receivedParam, equals(sampleParam));

      await command.close();
    });

    test(
      're-entrant execute allows concurrent invocations returning independent results',
      () async {
        final completer1 = Completer<TResult>();
        final completer2 = Completer<TResult>();
        var callIndex = 0;

        final command = createCommand(
          handler: (param, token) async {
            callIndex++;
            if (callIndex == 1) {
              return await completer1.future;
            } else {
              return await completer2.future;
            }
          },
        );

        final future1 = command.execute(sampleParam);
        await Future<void>.delayed(const Duration(milliseconds: 10));
        expect(command.status, equals(AsyncCommandStatus.running));

        final future2 = command.execute(sampleParam);
        await Future<void>.delayed(const Duration(milliseconds: 10));
        expect(command.status, equals(AsyncCommandStatus.running));

        completer1.complete(sampleResult);
        final res1 = await future1;
        expect(res1, isA<CommandSuccess<TResult>>());
        expect((res1 as CommandSuccess<TResult>).value, equals(sampleResult));

        completer2.complete(sampleResult);
        final res2 = await future2;
        expect(res2, isA<CommandSuccess<TResult>>());
        expect((res2 as CommandSuccess<TResult>).value, equals(sampleResult));

        await command.close();
      },
    );

    test(
      'CommandTimeoutError model construction, equality, and properties',
      () {
        const timeout = Duration(milliseconds: 250);
        const timeoutError = CommandTimeoutError(
          message: 'Operation timed out after 250ms',
          timeout: timeout,
        );

        expect(timeoutError.message, equals('Operation timed out after 250ms'));
        expect(timeoutError.timeout, equals(timeout));
        expect(timeoutError.cause, isNull);
        expect(timeoutError.stackTrace, isNull);
        expect(
          timeoutError.toString(),
          contains('CommandTimeoutError(timeout: 0:00:00.250000, message: Operation timed out after 250ms)'),
        );

        const sameError = CommandTimeoutError(
          message: 'Operation timed out after 250ms',
          timeout: timeout,
        );
        expect(timeoutError, equals(sameError));
        expect(timeoutError.hashCode, equals(sameError.hashCode));
      },
    );

    test(
      'command close terminates status stream, updates isClosed, and post-close execute throws',
      () async {
        final command = createCommand(handler: (p, t) async => sampleResult);
        var streamDone = false;
        final sub = command.watchStatus().listen(
          (_) {},
          onDone: () => streamDone = true,
        );

        expect(command.isClosed, isFalse);
        await command.close();

        await Future<void>.delayed(const Duration(milliseconds: 10));

        expect(command.isClosed, isTrue);
        expect(streamDone, isTrue);

        // Subsequent close() call is idempotent
        await command.close();
        expect(command.isClosed, isTrue);

        // Post-close execute fails deterministically
        expect(
          () => command.execute(sampleParam),
          throwsA(isA<StateError>()),
        );

        await sub.cancel();
      },
    );
  });
}

void main() {}
