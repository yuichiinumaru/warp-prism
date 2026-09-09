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

    test(
      'FakeAsyncCommand concurrent re-entrant executions track full call history and resolve independently',
      () async {
        final completer1 = Completer<String>();
        final completer2 = Completer<String>();
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

        final fut1 = command.execute('first');
        final fut2 = command.execute('second');

        expect(command.callCount, equals(2));
        expect(command.callHistory, equals(['first', 'second']));
        expect(command.lastParam, equals('second'));

        completer1.complete('res_1');
        completer2.complete('res_2');

        final r1 = await fut1;
        final r2 = await fut2;

        expect((r1 as CommandSuccess<String>).value, equals('res_1'));
        expect((r2 as CommandSuccess<String>).value, equals('res_2'));

        await command.close();
      },
    );
  });
}
