import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_bindings/warp_prism_bindings.dart';
import 'package:warp_prism_interaction/warp_prism_interaction.dart';
import 'package:warp_prism_runtime/warp_prism_runtime.dart';
import 'package:warp_prism_testkit/warp_prism_testkit.dart';

void main() {
  group('AsyncCommandBinding', () {
    test('initializes in idle state', () {
      final fakeCommand = FakeAsyncCommand<String, int>(initialResult: 42);
      final binding = AsyncCommandBinding<String, int>(command: fakeCommand);

      expect(binding.isIdle, isTrue);
      expect(binding.status, equals(AsyncCommandStatus.idle));
      expect(binding.isRunning, isFalse);
      expect(binding.lastSuccess, isNull);
      expect(binding.lastError, isNull);

      binding.dispose();
    });

    test(
      'executes successfully and transitions idle -> running -> succeeded',
      () async {
        final fakeCommand = FakeAsyncCommand<String, String>(
          initialResult: 'output-success',
        );
        final binding = AsyncCommandBinding<String, String>(
          command: fakeCommand,
        );

        final stateTransitions = <AsyncCommandStatus>[];
        binding.addListener(() {
          stateTransitions.add(binding.status);
        });

        final result = await binding.execute('test-input');

        expect(result, isA<CommandSuccess<String>>());
        expect(
          (result as CommandSuccess<String>).value,
          equals('output-success'),
        );

        expect(binding.isSuccess, isTrue);
        expect(binding.status, equals(AsyncCommandStatus.succeeded));
        expect(binding.lastSuccess, equals('output-success'));
        expect(binding.lastError, isNull);
        expect(binding.state.lastDuration, isNotNull);

        expect(stateTransitions, contains(AsyncCommandStatus.running));
        expect(stateTransitions.last, equals(AsyncCommandStatus.succeeded));

        binding.dispose();
      },
    );

    test(
      'handles execution failure and captures structured CommandError',
      () async {
        final fakeCommand = FakeAsyncCommand<String, String>(
          initialError: const CommandExecutionError(
            message: 'Backend execution failed: code 500',
            errorCode: 'ERR_500',
          ),
        );
        final binding = AsyncCommandBinding<String, String>(
          command: fakeCommand,
        );

        final result = await binding.execute('faulty-input');

        expect(result, isA<CommandFailure<String>>());
        expect(binding.isFailure, isTrue);
        expect(binding.status, equals(AsyncCommandStatus.failed));
        expect(binding.lastSuccess, isNull);
        expect(binding.lastError, isNotNull);
        expect(
          binding.state.errorMessage,
          contains('Backend execution failed'),
        );

        binding.dispose();
      },
    );

    test(
      'supports cooperative cancellation during delayed execution',
      () async {
        final fakeCommand = FakeAsyncCommand<String, String>(
          initialResult: 'delayed-result',
        )..setDelay(const Duration(milliseconds: 50));
        final binding = AsyncCommandBinding<String, String>(
          command: fakeCommand,
        );

        final future = binding.execute('slow-input');
        expect(binding.isRunning, isTrue);

        binding.cancel('User clicked cancel');
        final result = await future;

        expect(result, isA<CommandCancelled<String>>());
        expect(binding.isCancelled, isTrue);
        expect(binding.status, equals(AsyncCommandStatus.cancelled));
        expect(binding.state.cancellationReason, equals('User clicked cancel'));

        binding.dispose();
      },
    );

    test(
      'auto-cancels previous execution when re-executed while running',
      () async {
        final fakeCommand = FakeAsyncCommand<String, String>(
          initialResult: 'done',
        )..setDelay(const Duration(milliseconds: 50));
        final binding = AsyncCommandBinding<String, String>(
          command: fakeCommand,
        );

        final firstExecution = binding.execute('req-1');
        expect(binding.isRunning, isTrue);

        final secondExecution = binding.execute('req-2');
        final firstResult = await firstExecution;
        final secondResult = await secondExecution;

        expect(firstResult, isA<CommandCancelled<String>>());
        expect(secondResult, isA<CommandSuccess<String>>());
        expect(binding.isSuccess, isTrue);

        binding.dispose();
      },
    );

    test(
      'executeWithIntent converges with IDS normalized InputIntent',
      () async {
        final fakeCommand = FakeAsyncCommand<Map<String, Object?>, String>(
          initialResult: 'intent-acknowledged',
        );
        final binding = AsyncCommandBinding<Map<String, Object?>, String>(
          command: fakeCommand,
        );

        final pointerIntent = PointerIntent(
          kind: PointerIntentKind.click,
          x: 120.0,
          y: 240.0,
          targetId: 'btn-submit',
        );

        final result = await binding.executeWithIntent(
          pointerIntent,
          (intent) => {
            'action': intent.kind.name,
            'target': intent.targetId,
            'x': intent.x,
            'y': intent.y,
          },
        );

        expect(result, isA<CommandSuccess<String>>());
        expect(fakeCommand.lastParam!['action'], equals('click'));
        expect(fakeCommand.lastParam!['target'], equals('btn-submit'));

        binding.dispose();
      },
    );

    test('executeWithQueryIntent converges with IDS QueryIntent', () async {
      final fakeCommand = FakeAsyncCommand<String, int>(initialResult: 42);
      final binding = AsyncCommandBinding<String, int>(command: fakeCommand);

      final queryIntent = QueryIntent(
        rawQuery: 'agents:active',
        filters: const {'status': 'active'},
        queryToken: 'tok-99',
      );

      final result = await binding.executeWithQueryIntent(
        queryIntent,
        (intent) => intent.rawQuery,
      );

      expect(result, isA<CommandSuccess<int>>());
      expect((result as CommandSuccess<int>).value, equals(42));
      expect(fakeCommand.lastParam, equals('agents:active'));

      binding.dispose();
    });

    test('reset clears state back to idle', () async {
      final fakeCommand = FakeAsyncCommand<String, int>(initialResult: 100);
      final binding = AsyncCommandBinding<String, int>(command: fakeCommand);

      await binding.execute('do-calc');
      expect(binding.isSuccess, isTrue);

      binding.reset();
      expect(binding.isIdle, isTrue);
      expect(binding.status, equals(AsyncCommandStatus.idle));
      expect(binding.lastSuccess, isNull);

      binding.dispose();
    });

    test(
      'dispose cancels active execution and prevents new executions',
      () async {
        final fakeCommand = FakeAsyncCommand<String, String>(
          initialResult: 'done',
        )..setDelay(const Duration(milliseconds: 50));
        final binding = AsyncCommandBinding<String, String>(
          command: fakeCommand,
        );

        final future = binding.execute('task');
        binding.dispose();

        expect(binding.isDisposed, isTrue);
        final result = await future;
        expect(result, isA<CommandCancelled<String>>());

        expect(() => binding.execute('after'), throwsStateError);
      },
    );
  });
}
