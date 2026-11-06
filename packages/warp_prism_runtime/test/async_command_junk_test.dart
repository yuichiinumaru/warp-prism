// Async-command junk/adversarial sweep (Task 1867, part c).
//
// Mechanism mirror of `src/async_command/`. Stable test ids follow the
// canonical convention (`stableTestId` in the testkit):
// `[async_command_junk_<case>]`. Params are opaque caller data — the executor
// must round-trip junk, keep per-execution identity distinct, and fail closed
// (pre-cancelled ⇒ cancelled, submit-after-close ⇒ StateError).

import 'dart:async';

import 'package:test/test.dart';
import 'package:warp_prism_runtime/warp_prism_runtime.dart';

/// Minimal echo double: one instance per execution, cooperative.
class _EchoCommand implements AsyncCommand<String, String> {
  AsyncCommandStatus _status = AsyncCommandStatus.idle;

  @override
  AsyncCommandStatus get status => _status;

  @override
  bool get isClosed => false;

  @override
  Stream<AsyncCommandStatus> watchStatus() => const Stream.empty();

  @override
  Future<void> close() async {}

  @override
  Future<CommandResult<String>> execute(
    String param, {
    CancellationToken? cancellationToken,
  }) async {
    final token = cancellationToken ?? CancellationToken();
    final stopwatch = Stopwatch()..start();
    if (token.isCancelled) {
      _status = AsyncCommandStatus.cancelled;
      stopwatch.stop();
      return CommandCancelled<String>(
        reason: token.cancellationReason,
        duration: stopwatch.elapsed,
        timestamp: DateTime.now(),
      );
    }
    _status = AsyncCommandStatus.running;
    await Future<void>.delayed(Duration.zero);
    if (token.isCancelled) {
      _status = AsyncCommandStatus.cancelled;
      stopwatch.stop();
      return CommandCancelled<String>(
        reason: token.cancellationReason,
        duration: stopwatch.elapsed,
        timestamp: DateTime.now(),
      );
    }
    _status = AsyncCommandStatus.succeeded;
    stopwatch.stop();
    return CommandSuccess<String>(
      value: param,
      duration: stopwatch.elapsed,
      timestamp: DateTime.now(),
    );
  }
}

List<String> _junkParams() => <String>[
  '',
  ' ',
  'null',
  'param:🔥:日本語',
  '<payload/>',
  '{{param}}',
  'a' * 1000,
  'line one\nline two',
];

String _id(String c) => '[async_command_junk_$c]';

void main() {
  group('async command junk sweep', () {
    test('${_id('echo_roundtrip')} junk params echo back', () async {
      final executor = AsyncJobExecutor<String, String>(
        commandFactory: _EchoCommand.new,
      );
      for (final junk in _junkParams()) {
        final handle = executor.submit(junk);
        final result = await handle.result;
        expect(result, isA<CommandSuccess<String>>());
        expect((result as CommandSuccess<String>).value, equals(junk));
      }
      await executor.close();
    });

    test('${_id('identity_distinct')} concurrent junk keeps identity', () {
      final executor = AsyncJobExecutor<String, String>(
        commandFactory: _EchoCommand.new,
      );
      final first = executor.submit('🔥');
      final second = executor.submit('🔥');
      expect(first.executionId, isNot(equals(second.executionId)));
      expect(executor.activeExecutionIds.length, 2);
    });

    test('${_id('precancelled')} pre-cancelled token fails closed', () async {
      final executor = AsyncJobExecutor<String, String>(
        commandFactory: _EchoCommand.new,
      );
      final token = CancellationToken()..cancel('junk-proof-cancel');
      final handle = executor.submit('payload', cancellationToken: token);
      final result = await handle.result;
      expect(result, isA<CommandCancelled<String>>());
      expect(
        (result as CommandCancelled<String>).reason,
        equals('junk-proof-cancel'),
      );
      await executor.close();
    });

    test(
      '${_id('submit_after_close')} closed executor rejects submit',
      () async {
        final executor = AsyncJobExecutor<String, String>(
          commandFactory: _EchoCommand.new,
        );
        await executor.close();
        expect(() => executor.submit('late'), throwsStateError);
      },
    );
  });
}
