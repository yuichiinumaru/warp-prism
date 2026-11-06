// Task F6 — QueryController structural stale-result protection.
//
// Pins the four required properties plus the legacy-path hardening. Each test
// names the F6 requirement it enforces.

import 'package:test/test.dart';
import 'package:warp_prism_interaction/warp_prism_interaction.dart';

void main() {
  group('F6: correlation is structurally mandatory', () {
    test('late A completion after B submit is rejected (no state change)', () {
      final controller = QueryController<String>();

      final a = controller.submit(
        QueryIntent(rawQuery: 'q-a', queryToken: 'tok-a'),
      );
      final b = controller.submit(
        QueryIntent(rawQuery: 'q-b', queryToken: 'tok-b'),
      );

      expect(controller.isCurrentExecution(b), isTrue);
      expect(controller.isCurrentExecution(a), isFalse);

      // The stale completion from A must be ignored entirely.
      final committed = controller.completeExecution(
        a,
        QueryResultReference<String>(token: 'res-a', totalCount: 1),
      );

      expect(committed, isFalse);
      expect(controller.state.isRunning, isTrue);
      expect(controller.state.isComplete, isFalse);
      expect(controller.state.result, isNull);
      expect(controller.state.intent!.queryToken, equals('tok-b'));

      // B can still commit normally.
      expect(
        controller.completeExecution(
          b,
          QueryResultReference<String>(token: 'res-b', totalCount: 2),
        ),
        isTrue,
      );
      expect(controller.state.result!.token, equals('res-b'));
    });

    test('late A error after B submit cannot poison B', () {
      final controller = QueryController<String>();

      final a = controller.submit(
        QueryIntent(rawQuery: 'q-a', queryToken: 'tok-a'),
      );
      final b = controller.submit(
        QueryIntent(rawQuery: 'q-b', queryToken: 'tok-b'),
      );

      final applied = controller.failExecution(
        a,
        Exception('A timed out'),
        StackTrace.current,
      );

      expect(applied, isFalse);
      expect(controller.state.isError, isFalse, reason: 'B must not be poisoned');
      expect(controller.state.isRunning, isTrue);
      expect(controller.state.intent!.queryToken, equals('tok-b'));

      // B remains committable.
      expect(
        controller.completeExecution(
          b,
          QueryResultReference<String>(token: 'res-b', totalCount: 7),
        ),
        isTrue,
      );
      expect(controller.state.isComplete, isTrue);
    });

    test('two submits of the SAME intent text get distinct execution identity', () {
      final controller = QueryController<String>();

      // Identical rawQuery AND identical queryToken: identity must still differ,
      // because identity comes from the controller, not the intent payload.
      final intent = QueryIntent(rawQuery: 'same', queryToken: 'same-token');

      final first = controller.submit(intent);
      final second = controller.submit(intent);

      expect(identical(first, second), isFalse);
      expect(first.sequence, isNot(equals(second.sequence)));
      expect(controller.isCurrentExecution(first), isFalse);
      expect(controller.isCurrentExecution(second), isTrue);

      // The first handle cannot commit the second execution's result.
      expect(
        controller.completeExecution(
          first,
          QueryResultReference<String>(token: 'stale', totalCount: 1),
        ),
        isFalse,
      );
      expect(controller.state.isRunning, isTrue);

      expect(
        controller.completeExecution(
          second,
          QueryResultReference<String>(token: 'fresh', totalCount: 2),
        ),
        isTrue,
      );
    });

    test('cancelling A cannot cancel or complete a later execution B', () {
      final controller = QueryController<String>();

      final a = controller.submit(
        QueryIntent(rawQuery: 'q-a', queryToken: 'tok-a'),
      );
      final b = controller.submit(
        QueryIntent(rawQuery: 'q-b', queryToken: 'tok-b'),
      );

      // Stale cancel is a no-op.
      expect(controller.cancelExecution(a), isFalse);
      expect(controller.state.isRunning, isTrue);
      expect(controller.state.isCancelled, isFalse);

      // A is still unable to complete B.
      expect(
        controller.completeExecution(
          a,
          QueryResultReference<String>(token: 'res-a', totalCount: 1),
        ),
        isFalse,
      );
      expect(controller.state.isRunning, isTrue);

      // Cancelling the current execution works.
      expect(controller.cancelExecution(b), isTrue);
      expect(controller.state.isCancelled, isTrue);
    });

    test('a handle cannot commit after the execution is cancelled', () {
      // NOTE: `reset()` is not a legal transition from `running` per the query
      // transition table, so the reachable "handle outlives its execution" path
      // is cancel -> reset, which is what this test exercises.
      final controller = QueryController<String>();

      final a = controller.submit(
        QueryIntent(rawQuery: 'q-a', queryToken: 'tok-a'),
      );
      expect(controller.cancelExecution(a), isTrue);
      expect(controller.state.isCancelled, isTrue);

      controller.reset();
      expect(controller.state.isIdle, isTrue);
      expect(
        controller.activeExecution,
        isNull,
        reason: 'reset must clear the active execution so no handle can commit',
      );

      // Late result for the pre-reset execution must not resurrect the query.
      expect(
        controller.completeExecution(
          a,
          QueryResultReference<String>(token: 'res-a', totalCount: 1),
        ),
        isFalse,
      );
      expect(controller.state.isIdle, isTrue);
    });

    test('handle API rejects use after disposal', () {
      final controller = QueryController<String>();
      final a = controller.submit(
        QueryIntent(rawQuery: 'q-a', queryToken: 'tok-a'),
      );
      controller.dispose();

      expect(
        () => controller.completeExecution(
          a,
          QueryResultReference<String>(token: 'r', totalCount: 0),
        ),
        throwsStateError,
      );
      expect(
        () => controller.failExecution(a, Exception('x')),
        throwsStateError,
      );
      expect(() => controller.cancelExecution(a), throwsStateError);
    });

    test('activeExecution is read-only and cannot be forged', () {
      final controller = QueryController<String>();
      final a = controller.submit(
        QueryIntent(rawQuery: 'q-a', queryToken: 'tok-a'),
      );

      expect(controller.activeExecution, same(a));
      expect(controller.isCurrentExecution(a), isTrue);

      // Handles carry no equality override, so identity comparison is exact.
      final b = controller.submit(
        QueryIntent(rawQuery: 'q-b', queryToken: 'tok-b'),
      );
      expect(a == b, isFalse);
      expect(controller.isCurrentExecution(a), isFalse);
    });
  });

  group('F6: legacy correlation path cannot be bypassed by omission', () {
    test('uncorrelated complete() is rejected, not committed', () {
      final controller = QueryController<String>();
      controller.submit(
        QueryIntent(rawQuery: 'q', queryToken: 'tok-1'),
      );

      // No queryToken, no executionSequence: previously committed unconditionally.
      final ok = controller.complete(
        QueryResultReference<String>(token: 'unrelated', totalCount: 99),
      );

      expect(ok, isFalse, reason: 'uncorrelated commit must be refused');
      expect(controller.state.isRunning, isTrue);
      expect(controller.state.isComplete, isFalse);
    });

    test('uncorrelated fail() is rejected, not committed', () {
      final controller = QueryController<String>();
      controller.submit(
        QueryIntent(rawQuery: 'q', queryToken: 'tok-1'),
      );

      final ok = controller.fail(Exception('uncorrelated'));

      expect(ok, isFalse);
      expect(controller.state.isError, isFalse);
      expect(controller.state.isRunning, isTrue);
    });

    test('legacy path still works when correlation IS supplied', () {
      final controller = QueryController<String>();
      controller.submit(
        QueryIntent(rawQuery: 'q', queryToken: 'tok-1'),
      );

      expect(
        controller.complete(
          QueryResultReference<String>(token: 'r', totalCount: 1),
          queryToken: 'tok-1',
        ),
        isTrue,
      );
      expect(controller.state.isComplete, isTrue);
    });

    test('legacy stale token still rejected', () {
      final controller = QueryController<String>();
      controller.submit(
        QueryIntent(rawQuery: 'q', queryToken: 'tok-new'),
      );

      expect(
        controller.complete(
          QueryResultReference<String>(token: 'r', totalCount: 1),
          queryToken: 'tok-old',
        ),
        isFalse,
      );
      expect(controller.state.isRunning, isTrue);
    });
  });
}