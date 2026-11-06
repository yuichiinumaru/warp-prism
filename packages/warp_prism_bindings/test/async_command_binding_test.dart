import 'dart:async';

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

  // ===== F2: stale completion race ========================================
  //
  // Ordering is enforced with explicit Completers, never with cooperative
  // timing (no `delayed` racing). Each test states exactly which execution is
  // authoritative and asserts the late one cannot overwrite it.
  group('AsyncCommandBinding stale-completion guard (F2)', () {
    /// Builds a fake whose Nth execute parks on its own Completer, so tests can
    /// release executions in an exact, chosen order.
    FakeAsyncCommand<String, String> parkedCommand(
      List<Completer<String>> park,
    ) {
      var index = 0;
      return FakeAsyncCommand<String, String>(
        handler: (param, token) async => park[index++].future,
      );
    }

    test(
      'A starts, B starts, B succeeds first, A returns success late -> '
      'state remains B success',
      () async {
        final parkA = Completer<String>();
        final parkB = Completer<String>();
        final command = parkedCommand(<Completer<String>>[parkA, parkB]);
        final binding = AsyncCommandBinding<String, String>(command: command);

        final futureA = binding.execute('A');
        await Future<void>.delayed(Duration.zero);
        final generationA = binding.authoritativeGeneration;

        final futureB = binding.execute('B');
        await Future<void>.delayed(Duration.zero);
        final generationB = binding.authoritativeGeneration;
        expect(generationB, greaterThan(generationA));

        // B completes FIRST and becomes the authoritative terminal state.
        parkB.complete('B-result');
        final resultB = await futureB;
        expect(resultB, isA<CommandSuccess<String>>());
        expect(binding.status, equals(AsyncCommandStatus.succeeded));
        expect(binding.lastSuccess, equals('B-result'));

        // A completes late. Its result MUST still be delivered to A's own
        // caller, but it must not mutate the state owned by B.
        //
        // Note on A's result type: under the adopted cancel-and-replace model
        // (F1) A's token was signalled when B superseded it, so A correctly
        // reports CommandCancelled rather than a stale success. The F2
        // invariant under test is not *which* result A produces — it is that
        // the result is RETURNED to A's caller while [state] remains untouched
        // by A. Both branches below assert exactly that.
        parkA.complete('A-result');
        final resultA = await futureA;
        expect(
          resultA,
          isA<CommandResult<String>>(),
          reason: 'a late execution still receives its own terminal result',
        );
        expect(
          binding.status,
          equals(AsyncCommandStatus.succeeded),
          reason: 'status must remain B-derived success',
        );
        expect(
          binding.lastSuccess,
          equals('B-result'),
          reason: "A's late completion must not overwrite B's lastSuccess",
        );
        expect(
          binding.authoritativeGeneration,
          equals(generationB),
          reason: 'authority must stay with B',
        );

        binding.dispose();
      },
    );

    test(
      'A starts, B starts, B succeeds, A returns cancellation late -> '
      'state remains B success',
      () async {
        final parkA = Completer<String>();
        final parkB = Completer<String>();
        final command = parkedCommand(<Completer<String>>[parkA, parkB]);
        final binding = AsyncCommandBinding<String, String>(command: command);

        final futureA = binding.execute('A');
        await Future<void>.delayed(Duration.zero);
        final futureB = binding.execute('B');
        await Future<void>.delayed(Duration.zero);

        parkB.complete('B-result');
        await futureB;
        expect(binding.status, equals(AsyncCommandStatus.succeeded));

        // A terminates as cancellation, late. This is the exact F2 scenario:
        // a stale `toCancelled` must not downgrade the authoritative success.
        parkA.completeError(
          const CommandCancellationException('cancelled-late'),
        );
        final resultA = await futureA;
        expect(resultA, isA<CommandCancelled<String>>());
        expect(
          binding.status,
          equals(AsyncCommandStatus.succeeded),
          reason:
              'a stale cancellation must not downgrade B success to cancelled',
        );
        expect(binding.lastSuccess, equals('B-result'));

        binding.dispose();
      },
    );

    test(
      'A starts, B starts, B fails, A finishes late -> state remains B failure',
      () async {
        final parkA = Completer<String>();
        final parkB = Completer<String>();
        final command = parkedCommand(<Completer<String>>[parkA, parkB]);
        final binding = AsyncCommandBinding<String, String>(command: command);

        final futureA = binding.execute('A');
        await Future<void>.delayed(Duration.zero);
        final futureB = binding.execute('B');
        await Future<void>.delayed(Duration.zero);

        parkB.completeError(StateError('B failed'));
        final resultB = await futureB;
        expect(resultB, isA<CommandFailure<String>>());
        expect(binding.status, equals(AsyncCommandStatus.failed));

        // A completes late. Must not clear or overwrite B's failure.
        parkA.complete('A-result');
        await futureA;
        expect(
          binding.status,
          equals(AsyncCommandStatus.failed),
          reason: "a stale A success must not overwrite B's failure",
        );
        expect(
          binding.lastSuccess,
          isNull,
          reason: "a stale A must not publish lastSuccess over B's failure",
        );
        expect(binding.lastError, isNotNull);

        binding.dispose();
      },
    );

    test(
      'A starts, B starts, B fails, A also fails late -> state remains B failure',
      () async {
        final parkA = Completer<String>();
        final parkB = Completer<String>();
        final command = parkedCommand(<Completer<String>>[parkA, parkB]);
        final binding = AsyncCommandBinding<String, String>(command: command);

        final futureA = binding.execute('A');
        await Future<void>.delayed(Duration.zero);
        final futureB = binding.execute('B');
        await Future<void>.delayed(Duration.zero);

        parkB.completeError(StateError('B failed'));
        await futureB;
        expect(binding.status, equals(AsyncCommandStatus.failed));

        // A also fails late. B remains authoritative, so state is unchanged.
        parkA.completeError(StateError('A failed late'));
        final resultA = await futureA;
        expect(
          resultA,
          isA<CommandResult<String>>(),
          reason: 'a late execution still receives its own terminal result',
        );
        expect(
          binding.status,
          equals(AsyncCommandStatus.failed),
          reason: 'B remains the authoritative terminal state',
        );
        expect(
          binding.lastSuccess,
          isNull,
          reason: "a stale A failure must not clear B's authoritative failure",
        );

        binding.dispose();
      },
    );
  });
}
