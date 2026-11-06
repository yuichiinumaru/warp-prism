import 'dart:async';

import 'package:test/test.dart';
import 'package:warp_prism_runtime/warp_prism_runtime.dart';

/// Minimal in-test command double: one instance per execution, cooperative.
///
/// Each instance is single-flight by construction (it serves exactly one
/// [execute] at a time in these tests); the executor mints one per submit.
class _SingleUseCommand implements AsyncCommand<String, String> {
  _SingleUseCommand(this._handler);

  final Future<String> Function(String param, CancellationToken? token)
  _handler;
  AsyncCommandStatus _status = AsyncCommandStatus.idle;
  final StreamController<AsyncCommandStatus> _controller =
      StreamController<AsyncCommandStatus>.broadcast();
  bool _isClosed = false;

  @override
  AsyncCommandStatus get status => _status;

  @override
  bool get isClosed => _isClosed;

  @override
  Stream<AsyncCommandStatus> watchStatus() => _controller.stream;

  void _set(AsyncCommandStatus next) {
    _status = next;
    if (!_isClosed) _controller.add(next);
  }

  @override
  Future<CommandResult<String>> execute(
    String param, {
    CancellationToken? cancellationToken,
  }) async {
    final token = cancellationToken ?? CancellationToken();
    final stopwatch = Stopwatch()..start();
    if (token.isCancelled) {
      _set(AsyncCommandStatus.cancelled);
      stopwatch.stop();
      return CommandCancelled<String>(
        reason: token.cancellationReason,
        duration: stopwatch.elapsed,
        timestamp: DateTime.now(),
      );
    }
    _set(AsyncCommandStatus.running);
    try {
      final value = await _handler(param, token);
      if (token.isCancelled) {
        _set(AsyncCommandStatus.cancelled);
        stopwatch.stop();
        return CommandCancelled<String>(
          reason: token.cancellationReason,
          duration: stopwatch.elapsed,
          timestamp: DateTime.now(),
        );
      }
      _set(AsyncCommandStatus.succeeded);
      stopwatch.stop();
      return CommandSuccess<String>(
        value: value,
        duration: stopwatch.elapsed,
        timestamp: DateTime.now(),
      );
    } on CommandCancellationException catch (e) {
      _set(AsyncCommandStatus.cancelled);
      stopwatch.stop();
      return CommandCancelled<String>(
        reason: e.reason,
        duration: stopwatch.elapsed,
        timestamp: DateTime.now(),
      );
    } catch (e, st) {
      if (token.isCancelled) {
        _set(AsyncCommandStatus.cancelled);
        stopwatch.stop();
        return CommandCancelled<String>(
          reason: token.cancellationReason,
          duration: stopwatch.elapsed,
          timestamp: DateTime.now(),
        );
      }
      _set(AsyncCommandStatus.failed);
      stopwatch.stop();
      return CommandFailure<String>(
        error: CommandGenericError(
          message: e.toString(),
          cause: e,
          stackTrace: st,
        ),
        duration: stopwatch.elapsed,
        timestamp: DateTime.now(),
      );
    }
  }

  @override
  Future<void> close() async {
    _isClosed = true;
    await _controller.close();
  }
}

void main() {
  group('AsyncJobExecutor per-execution identity (Task 1859)', () {
    test('concurrent executions carry distinct identity', () async {
      final gateA = Completer<String>();
      final gateB = Completer<String>();
      var calls = 0;
      final executor = AsyncJobExecutor<String, String>(
        commandFactory: () => _SingleUseCommand((param, token) async {
          calls++;
          return calls == 1 ? await gateA.future : await gateB.future;
        }),
      );

      final handleA = executor.submit('a');
      final handleB = executor.submit('b');

      expect(handleA.executionId, isNot(equals(handleB.executionId)));
      expect(executor.activeCount, equals(2));
      expect(
        executor.activeExecutionIds,
        containsAll([handleA.executionId, handleB.executionId]),
      );

      gateB.complete('res-b');
      gateA.complete('res-a');
      final resA = await handleA.result;
      final resB = await handleB.result;

      expect(resA, isA<CommandSuccess<String>>());
      expect((resA as CommandSuccess<String>).value, equals('res-a'));
      expect((resB as CommandSuccess<String>).value, equals('res-b'));
      expect(executor.activeCount, equals(0));

      await executor.close();
    });

    test('sequential executions mint strictly newer identity', () async {
      final executor = AsyncJobExecutor<String, String>(
        commandFactory: () =>
            _SingleUseCommand((param, token) async => 'echo:$param'),
      );

      final first = executor.submit('one');
      final firstId = first.executionId;
      expect(
        (await first.result as CommandSuccess<String>).value,
        equals('echo:one'),
      );

      final second = executor.submit('two');
      expect(second.executionId, isNot(equals(firstId)));
      expect(
        (await second.result as CommandSuccess<String>).value,
        equals('echo:two'),
      );

      await executor.close();
    });

    test('cancelling one execution leaves its sibling unaffected', () async {
      final gateB = Completer<String>();
      var calls = 0;
      final executor = AsyncJobExecutor<String, String>(
        commandFactory: () => _SingleUseCommand((param, token) async {
          calls++;
          if (calls == 1) {
            final completer = Completer<String>();
            void onCancel(String? reason) {
              if (!completer.isCompleted) {
                completer.completeError(CommandCancellationException(reason));
              }
            }

            token?.attachListener(onCancel);
            try {
              return await completer.future;
            } finally {
              token?.detachListener(onCancel);
            }
          }
          return await gateB.future;
        }),
      );

      final handleA = executor.submit('a');
      final handleB = executor.submit('b');
      await Future<void>.delayed(const Duration(milliseconds: 10));

      handleA.cancel('user aborted A');
      gateB.complete('res-b');

      final resA = await handleA.result;
      final resB = await handleB.result;

      expect(resA, isA<CommandCancelled<String>>());
      expect(
        (resA as CommandCancelled<String>).reason,
        equals('user aborted A'),
      );
      expect(resB, isA<CommandSuccess<String>>());
      expect((resB as CommandSuccess<String>).value, equals('res-b'));

      await executor.close();
    });

    test('cancelAll discloses the reason on every active execution', () async {
      final executor = AsyncJobExecutor<String, String>(
        commandFactory: () => _SingleUseCommand((param, token) async {
          final completer = Completer<String>();
          void onCancel(String? reason) {
            if (!completer.isCompleted) {
              completer.completeError(CommandCancellationException(reason));
            }
          }

          token?.attachListener(onCancel);
          try {
            return await completer.future;
          } finally {
            token?.detachListener(onCancel);
          }
        }),
      );

      final handleA = executor.submit('a');
      final handleB = executor.submit('b');
      await Future<void>.delayed(const Duration(milliseconds: 10));

      await executor.cancelAll('shutdown');
      expect(executor.activeCount, equals(0));

      for (final handle in [handleA, handleB]) {
        final res = await handle.result;
        expect(res, isA<CommandCancelled<String>>());
        expect((res as CommandCancelled<String>).reason, equals('shutdown'));
      }

      await executor.close();
    });

    test('submit after close throws; close is idempotent', () async {
      final executor = AsyncJobExecutor<String, String>(
        commandFactory: () =>
            _SingleUseCommand((param, token) async => 'value'),
      );
      await executor.close();
      expect(executor.isClosed, isTrue);
      expect(() => executor.submit('late'), throwsA(isA<StateError>()));
      await executor.close();
      expect(executor.isClosed, isTrue);
    });
  });

  group('Terminality and refusal standard (Task 1859)', () {
    test('pathRefusedPrefix is the verbatim cross-boundary invariant', () {
      expect(pathRefusedPrefix, equals('path refused ['));
    });

    test('isTerminalMediaError: only decode/seek are non-terminal', () {
      expect(
        isTerminalMediaError(PrismMediaErrorKind.decodeFailed),
        isFalse,
        reason: 'transient decode glitch may recover or pause',
      );
      expect(
        isTerminalMediaError(PrismMediaErrorKind.seekFailed),
        isFalse,
        reason: 'bounded seek miss or range clamp',
      );
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

    test('describePathRefusal extracts detail only for refusal messages', () {
      expect(
        describePathRefusal('path refused [sandbox]: EACCES denied'),
        equals('sandbox'),
      );
      expect(describePathRefusal('plain Invalid input'), isNull);
      expect(describePathRefusal('path refused [unterminated'), isNull);
    });

    test('mediaErrorLabel checks refusal before the variant label', () {
      expect(
        mediaErrorLabel(
          PrismMediaErrorKind.invalid,
          message: 'path refused [sandbox]: EACCES denied',
        ),
        equals('Path refused (sandbox)'),
        reason: 'a policy refusal must never render as plain "Invalid"',
      );
      expect(mediaErrorLabel(PrismMediaErrorKind.invalid), equals('Invalid'));
      expect(
        mediaErrorLabel(PrismMediaErrorKind.decodeFailed),
        contains('transient'),
      );
    });

    test(
      'executor failure messages resolve through describePathRefusal',
      () async {
        final executor = AsyncJobExecutor<String, String>(
          commandFactory: () => _SingleUseCommand((param, token) async {
            throw StateError('path refused [sandbox]: EACCES denied');
          }),
        );

        // Handler throws are surfaced by the test double as transport-style
        // failures; the refusal detail must still be recoverable verbatim.
        final handle = executor.submit('open /etc/shadow');
        final res = await handle.result;
        expect(res, isA<CommandFailure<String>>());
        final message = (res as CommandFailure<String>).error.message;
        expect(describePathRefusal(message), equals('sandbox'));

        await executor.close();
      },
    );
  });
}
