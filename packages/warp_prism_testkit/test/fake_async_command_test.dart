import 'dart:async';
import 'package:test/test.dart';
import 'package:warp_prism_runtime/warp_prism_runtime.dart';
import 'package:warp_prism_testkit/warp_prism_testkit.dart';

void main() {
  group('FakeAsyncCommand Contract Verification', () {
    verifyAsyncCommandContract<String, String>(
      createCommand: ({handler}) => FakeAsyncCommand<String, String>(
        handler: handler,
        initialResult: 'default_result',
      ),
      sampleParam: 'test_param',
      sampleResult: 'test_result',
      sampleError: const CommandExecutionError(
        message: 'simulated error',
        errorCode: 'ERR_TEST',
      ),
    );

    test(
      'FakeAsyncCommand tracks callCount, lastParam, callHistory, and reset',
      () async {
        final command = FakeAsyncCommand<int, String>(
          handler: (n, token) async => 'value_$n',
        );

        expect(command.callCount, equals(0));
        expect(command.lastParam, isNull);
        expect(command.callHistory, isEmpty);

        await command.execute(10);
        await command.execute(20);

        expect(command.callCount, equals(2));
        expect(command.lastParam, equals(20));
        expect(command.callHistory, equals([10, 20]));

        command.reset();
        expect(command.callCount, equals(0));
        expect(command.lastParam, isNull);
        expect(command.callHistory, isEmpty);
        expect(command.status, equals(AsyncCommandStatus.idle));

        await command.close();
      },
    );

    test(
      'FakeAsyncCommand simulated delay can be cooperatively cancelled',
      () async {
        final command = FakeAsyncCommand<String, String>(
          initialResult: 'delayed_result',
          simulatedDelay: const Duration(milliseconds: 200),
        );

        final token = CancellationToken();
        final future = command.execute('input', cancellationToken: token);

        // Cancel mid-delay
        await Future<void>.delayed(const Duration(milliseconds: 50));
        token.cancel('aborted during delay');

        final result = await future;
        expect(result, isA<CommandCancelled<String>>());
        expect(command.status, equals(AsyncCommandStatus.cancelled));
        expect(command.cancellationCount, equals(1));

        await command.close();
      },
    );

    test('FakeAsyncCommand custom error override', () async {
      final command = FakeAsyncCommand<String, String>(initialResult: 'ok');

      final res1 = await command.execute('a');
      expect(res1, isA<CommandSuccess<String>>());

      command.setError(
        const CommandValidationError(message: 'Invalid input', field: 'query'),
      );

      final res2 = await command.execute('b');
      expect(res2, isA<CommandFailure<String>>());
      final failure = res2 as CommandFailure<String>;
      expect(failure.error, isA<CommandValidationError>());

      await command.close();
    });

    test(
      'FakeAsyncCommand configured with CommandTimeoutError transitions to failed with typed error',
      () async {
        const timeout = Duration(seconds: 5);
        const timeoutError = CommandTimeoutError(
          message: 'Operation timed out after 5s',
          timeout: timeout,
        );

        final command = FakeAsyncCommand<String, String>(
          initialError: timeoutError,
        );

        final result = await command.execute('payload');
        expect(result, isA<CommandFailure<String>>());
        final failure = result as CommandFailure<String>;
        expect(failure.error, isA<CommandTimeoutError>());
        final err = failure.error as CommandTimeoutError;
        expect(err.timeout, equals(timeout));
        expect(err.message, equals('Operation timed out after 5s'));
        expect(command.status, equals(AsyncCommandStatus.failed));

        await command.close();
      },
    );

    // F1 — CHANGED EXPECTATION (previously: 'concurrent re-entrant executions track
    // full call history and resolve independently').
    //
    // That test encoded MULTI-FLIGHT: it expected BOTH overlapping executions to
    // resolve as CommandSuccess with independent values. Under the adopted
    // single-flight, cancel-and-replace model the first execution is superseded
    // and signalled, so it CANNOT resolve as a success. The multi-flight
    // expectation was an artefact of the old model, not a consumer requirement:
    // no production code constructs AsyncCommandBinding, and the only two
    // AsyncCommand implementations are this fake and the FRB adapter.
    //
    // Bookkeeping assertions (callCount / callHistory / lastParam) are
    // PRESERVED verbatim — they are independent of the concurrency model and
    // remain valuable.
    test(
      'FakeAsyncCommand re-entrant executions track full call history; the '
      'superseded run is cancelled (single-flight, cancel-and-replace)',
      () async {
        final completer1 = Completer<String>();
        final completer2 = Completer<String>();
        final token1 = CancellationToken();
        var index = 0;

        final command = FakeAsyncCommand<String, String>(
          handler: (param, token) async {
            index++;
            if (index == 1) {
              return await completer1.future;
            } else {
              return await completer2.future;
            }
          },
        );

        final fut1 = command.execute('first', cancellationToken: token1);
        final fut2 = command.execute('second');

        // Bookkeeping is unchanged by the model choice.
        expect(command.callCount, equals(2));
        expect(command.callHistory, equals(['first', 'second']));
        expect(command.lastParam, equals('second'));

        // F1: the second execute superseded (and signalled) the first.
        expect(
          token1.isCancelled,
          isTrue,
          reason: 'cancel-and-replace must signal the superseded token',
        );

        completer1.complete('res_1');
        completer2.complete('res_2');

        // The authoritative (second) execution succeeds.
        final r2 = await fut2;
        expect((r2 as CommandSuccess<String>).value, equals('res_2'));
        expect(command.status, equals(AsyncCommandStatus.succeeded));

        // The superseded execution reports cancellation, not a stale success.
        final r1 = await fut1;
        expect(
          r1,
          isA<CommandCancelled<String>>(),
          reason:
              'a superseded execution must not resolve as a success under the '
              'single-flight model',
        );
        expect(command.status, equals(AsyncCommandStatus.succeeded));

        await command.close();
      },
    );

    test('FakeAsyncCommand exposes execution generation; only the last-started '
        'execution is authoritative', () async {
      final completer1 = Completer<String>();
      final completer2 = Completer<String>();
      var index = 0;

      final command = FakeAsyncCommand<String, String>(
        handler: (param, token) async {
          index++;
          return index == 1 ? await completer1.future : await completer2.future;
        },
      );

      final generationBefore = command.authoritativeGeneration;

      final fut1 = command.execute('first');
      final generationA = command.authoritativeGeneration;
      expect(generationA, greaterThan(generationBefore));
      expect(command.isExecuting, isTrue);

      final fut2 = command.execute('second');
      final generationB = command.authoritativeGeneration;
      expect(
        generationB,
        greaterThan(generationA),
        reason: 'each execute must claim a strictly newer generation',
      );

      completer2.complete('res_2');
      await fut2;
      expect(command.authoritativeGeneration, equals(generationB));
      expect(command.status, equals(AsyncCommandStatus.succeeded));

      // Superseded A finishing late must not move status or authority.
      completer1.completeError(
        const CommandCancellationException('superseded'),
      );
      await fut1;
      expect(command.authoritativeGeneration, equals(generationB));
      expect(command.status, equals(AsyncCommandStatus.succeeded));

      await command.close();
    });
  });
}
