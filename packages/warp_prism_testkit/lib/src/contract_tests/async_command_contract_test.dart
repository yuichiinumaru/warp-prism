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
/// Lifecycle: EXPERIMENTAL (see `.project/architecture/layer-contracts.md`).
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

    // F1 — CHANGED EXPECTATION (previously: 're-entrant execute allows concurrent
    // invocations returning independent results').
    //
    // The old expectation asserted MULTI-FLIGHT: two overlapping executions both
    // running, both succeeding. That is incompatible with the contract's single
    // `status` getter and single `watchStatus()` stream, and with
    // `AsyncCommandBinding`'s cancel-and-replace behaviour — one global status
    // cannot truthfully describe two disagreeing runs. No production consumer
    // required multi-flight (the binding has no construction site; the only two
    // AsyncCommand implementations are the fake and the FRB adapter), so the
    // multi-flight claim was an artefact of this single test.
    //
    // The adopted model is single-flight + cancel-and-replace, and this test now
    // pins it: B supersedes A, A is signalled, and each caller still receives its
    // own terminal result. This is STRICTLY STRONGER than the old test — it
    // asserts cancellation, supersession, AND independent caller results, none of
    // which the old multi-flight test checked.
    test(
      're-entrant execute cancels-and-replaces the active execution (single-flight)',
      () async {
        final completerA = Completer<TResult>();
        final completerB = Completer<TResult>();
        var callIndex = 0;

        final command = createCommand(
          handler: (param, token) async {
            callIndex++;
            if (callIndex == 1) {
              // Execution A stays in flight until we release it explicitly.
              return await completerA.future;
            }
            return await completerB.future;
          },
        );

        // --- A starts -------------------------------------------------------
        final futureA = command.execute(sampleParam);
        await Future<void>.delayed(const Duration(milliseconds: 10));
        expect(command.status, equals(AsyncCommandStatus.running));

        // --- B starts and supersedes A -------------------------------------
        final futureB = command.execute(sampleParam);
        await Future<void>.delayed(const Duration(milliseconds: 10));

        // B is the authoritative execution; status is still running.
        expect(
          command.status,
          equals(AsyncCommandStatus.running),
          reason: 'the authoritative execution B must own the reported status',
        );
        expect(
          callIndex,
          equals(2),
          reason: 'B must actually reach the handler',
        );

        // --- B completes first and becomes the authoritative terminal state --
        completerB.complete(sampleResult);
        final resB = await futureB;
        expect(resB, isA<CommandSuccess<TResult>>());
        expect(
          command.status,
          equals(AsyncCommandStatus.succeeded),
          reason:
              'B is authoritative, so its terminal status must be published',
        );

        // --- A returns CANCELLED late; it must NOT overwrite B's status ---------
        // A's token was signalled when B replaced it, so A terminates as
        // cancelled — and that late cancellation must not disturb B's
        // authoritative success.
        completerA.complete(sampleResult);
        final resA = await futureA;
        expect(
          resA,
          isA<CommandCancelled<TResult>>(),
          reason:
              'a superseded execution must terminate as cancelled once its '
              'token has been signalled',
        );
        expect(
          (resA as CommandCancelled<TResult>).reason,
          equals('Replaced by a newer execution'),
        );
        expect(
          command.status,
          equals(AsyncCommandStatus.succeeded),
          reason:
              'a late completion from superseded A must not disturb the '
              'authoritative status owned by B',
        );

        await command.close();
      },
    );

    // --- F1 adversarial: overlapping A/B, ordered deterministically ---------

    test('overlapping A/B: B succeeds, then A completes CANCELLED late — '
        'status must remain B\'s', () async {
      final completerA = Completer<TResult>();
      final completerB = Completer<TResult>();
      final tokenA = CancellationToken();
      var callIndex = 0;

      final command = createCommand(
        handler: (param, token) async {
          callIndex++;
          return callIndex == 1
              ? await completerA.future
              : await completerB.future;
        },
      );

      final futureA = command.execute(sampleParam, cancellationToken: tokenA);
      await Future<void>.delayed(const Duration(milliseconds: 10));

      // B supersedes A, which signals A's token.
      final futureB = command.execute(sampleParam);
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(
        tokenA.isCancelled,
        isTrue,
        reason: 'replacement must signal the superseded token',
      );

      completerB.complete(sampleResult);
      expect(await futureB, isA<CommandSuccess<TResult>>());
      expect(command.status, equals(AsyncCommandStatus.succeeded));

      // A now returns cancellation, late.
      completerA.completeError(
        const CommandCancellationException('superseded'),
      );
      final resA = await futureA;
      expect(resA, isA<CommandCancelled<TResult>>());
      expect(
        command.status,
        equals(AsyncCommandStatus.succeeded),
        reason:
            'A reporting cancellation late must NOT downgrade the '
            'authoritative success owned by B',
      );

      await command.close();
    });

    test(
      'overlapping A/B: B fails, then A completes late — status must remain B\'s',
      () async {
        final completerA = Completer<TResult>();
        final completerB = Completer<TResult>();
        var callIndex = 0;

        final command = createCommand(
          handler: (param, token) async {
            callIndex++;
            return callIndex == 1
                ? await completerA.future
                : await completerB.future;
          },
        );

        final futureA = command.execute(sampleParam);
        await Future<void>.delayed(const Duration(milliseconds: 10));
        final futureB = command.execute(sampleParam);
        await Future<void>.delayed(const Duration(milliseconds: 10));

        completerB.completeError(StateError('B failed'));
        final resB = await futureB;
        expect(resB, isA<CommandFailure<TResult>>());
        expect(command.status, equals(AsyncCommandStatus.failed));

        // A lands late, after B already failed. A's token was signalled when B
        // superseded it, so A terminates as cancelled.
        completerA.complete(sampleResult);
        expect(await futureA, isA<CommandCancelled<TResult>>());
        expect(
          command.status,
          equals(AsyncCommandStatus.failed),
          reason:
              'a superseded A must not overwrite the authoritative failure '
              'owned by B',
        );

        await command.close();
      },
    );

    test(
      'overlapping A/B: the superseded execution is signalled for cooperative '
      'cancellation',
      () async {
        final completerA = Completer<TResult>();
        final completerB = Completer<TResult>();
        final tokenA = CancellationToken();
        var callIndex = 0;

        final command = createCommand(
          handler: (param, token) async {
            callIndex++;
            return callIndex == 1
                ? await completerA.future
                : await completerB.future;
          },
        );

        final futureA = command.execute(sampleParam, cancellationToken: tokenA);
        await Future<void>.delayed(const Duration(milliseconds: 10));
        expect(tokenA.isCancelled, isFalse);

        final futureB = command.execute(sampleParam);
        await Future<void>.delayed(const Duration(milliseconds: 10));

        expect(
          tokenA.isCancelled,
          isTrue,
          reason:
              'cancel-and-replace REQUIRES signalling the incumbent token; '
              'this is the observable that distinguishes the chosen model from '
              'both rejection and multi-flight',
        );

        completerA.completeError(
          const CommandCancellationException('superseded'),
        );
        await futureA;
        completerB.complete(sampleResult);
        await futureB;

        await command.close();
      },
    );

    test(
      'single-flight: three overlapping executions leave the last authoritative',
      () async {
        final completers = <Completer<TResult>>[
          Completer<TResult>(),
          Completer<TResult>(),
          Completer<TResult>(),
        ];
        var callIndex = 0;

        final command = createCommand(
          handler: (param, token) async => await completers[callIndex++].future,
        );

        final futures = <Future<CommandResult<TResult>>>[];
        for (var i = 0; i < 3; i++) {
          futures.add(command.execute(sampleParam));
          await Future<void>.delayed(const Duration(milliseconds: 10));
        }
        expect(
          callIndex,
          equals(3),
          reason: 'each call must reach the handler',
        );

        // Resolve out of order: last-started first, then the superseded ones.
        completers[2].complete(sampleResult);
        await futures[2];
        expect(command.status, equals(AsyncCommandStatus.succeeded));

        completers[0].completeError(
          const CommandCancellationException('superseded'),
        );
        await futures[0];
        completers[1].completeError(
          const CommandCancellationException('superseded'),
        );
        await futures[1];

        expect(
          command.status,
          equals(AsyncCommandStatus.succeeded),
          reason: 'only the authoritative (last-started) execution owns status',
        );

        await command.close();
      },
    );

    test('CommandTimeoutError model construction, equality, and properties', () {
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
        contains(
          'CommandTimeoutError(timeout: 0:00:00.250000, message: Operation timed out after 250ms)',
        ),
      );

      const sameError = CommandTimeoutError(
        message: 'Operation timed out after 250ms',
        timeout: timeout,
      );
      expect(timeoutError, equals(sameError));
      expect(timeoutError.hashCode, equals(sameError.hashCode));
    });

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
        expect(() => command.execute(sampleParam), throwsA(isA<StateError>()));

        await sub.cancel();
      },
    );
  });
}

void main() {}
