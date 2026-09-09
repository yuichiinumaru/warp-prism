import 'package:test/test.dart';
import 'package:warp_prism_interaction/warp_prism_interaction.dart';

void main() {
  group('QueryIntent', () {
    test('attributes, isEmpty/isNotEmpty, and value equality', () {
      final q1 = QueryIntent(
        rawQuery: 'status:error',
        filters: {'level': 'severe'},
        queryToken: 'tok-1',
      );

      final q2 = QueryIntent(
        rawQuery: 'status:error',
        filters: {'level': 'severe'},
        queryToken: 'tok-1',
      );

      final q3 = QueryIntent(
        rawQuery: 'status:warn',
        filters: {'level': 'severe'},
        queryToken: 'tok-1',
      );

      expect(q1.rawQuery, equals('status:error'));
      expect(q1.filters['level'], equals('severe'));
      expect(q1.queryToken, equals('tok-1'));
      expect(q1.isEmpty, isFalse);
      expect(q1.isNotEmpty, isTrue);
      expect(q1, equals(q2));
      expect(q1.hashCode, equals(q2.hashCode));
      expect(q1, isNot(equals(q3)));

      final empty = QueryIntent();
      expect(empty.isEmpty, isTrue);
      expect(empty.isNotEmpty, isFalse);
    });

    test('copyWith derives updated instance', () {
      final original = QueryIntent(rawQuery: 'hello', queryToken: 't1');
      final updated = original.copyWith(rawQuery: 'world');

      expect(updated.rawQuery, equals('world'));
      expect(updated.queryToken, equals('t1'));
    });
  });

  group('QueryResultReference', () {
    test('token, counts, and provenance', () {
      final ref = QueryResultReference<String>(
        token: 'res-100',
        totalCount: 42,
        provenance: 'observatory.workspace_search',
        items: ['item1', 'item2'],
      );

      expect(ref.token, equals('res-100'));
      expect(ref.totalCount, equals(42));
      expect(ref.provenance, equals('observatory.workspace_search'));
      expect(ref.items, equals(['item1', 'item2']));
      expect(ref.isEmpty, isFalse);
      expect(ref.isNotEmpty, isTrue);
    });
  });

  group('QueryTransitionTable', () {
    test('valid lifecycle transitions', () {
      expect(
        queryTransitionTable.canTransition(
          QueryStatus.idle,
          QueryTrigger.submit,
        ),
        isTrue,
      );
      expect(
        queryTransitionTable.canTransition(
          QueryStatus.running,
          QueryTrigger.complete,
        ),
        isTrue,
      );
      expect(
        queryTransitionTable.canTransition(
          QueryStatus.running,
          QueryTrigger.fail,
        ),
        isTrue,
      );
      expect(
        queryTransitionTable.canTransition(
          QueryStatus.running,
          QueryTrigger.cancel,
        ),
        isTrue,
      );
      expect(
        queryTransitionTable.canTransition(
          QueryStatus.complete,
          QueryTrigger.reset,
        ),
        isTrue,
      );
    });

    test('illegal transition throws StateError', () {
      expect(
        () => queryTransitionTable.validateTransition(
          QueryStatus.idle,
          QueryTrigger.complete,
        ),
        throwsStateError,
      );
    });
  });

  group('QueryController', () {
    test(
      'successful execution workflow (idle -> submit -> complete -> reset)',
      () {
        final controller = QueryController<String>();
        final events = <QueryState<String>>[];

        controller.addListener(events.add);

        expect(controller.state.isIdle, isTrue);

        final intent = QueryIntent(rawQuery: 'build', queryToken: 'req-1');
        controller.submit(intent);

        expect(controller.state.isRunning, isTrue);
        expect(controller.state.intent, equals(intent));
        expect(events.length, equals(1));

        final results = QueryResultReference<String>(
          token: 'res-1',
          totalCount: 5,
          items: ['a', 'b'],
        );

        final completed = controller.complete(results, queryToken: 'req-1');
        expect(completed, isTrue);
        expect(controller.state.isComplete, isTrue);
        expect(controller.state.result, equals(results));
        expect(events.length, equals(2));

        controller.reset();
        expect(controller.state.isIdle, isTrue);
        expect(events.length, equals(3));
      },
    );

    test('failure workflow (idle -> submit -> fail)', () {
      final controller = QueryController<String>();
      final intent = QueryIntent(rawQuery: 'test', queryToken: 'req-err');

      controller.submit(intent);
      expect(controller.state.isRunning, isTrue);

      final errorObj = Exception('network failure');
      controller.fail(errorObj, null, 'req-err');

      expect(controller.state.isError, isTrue);
      expect(controller.state.error, equals(errorObj));
    });

    test('cancellation workflow (idle -> submit -> cancel)', () {
      final controller = QueryController<String>();
      final intent = QueryIntent(rawQuery: 'long-search', queryToken: 'req-c');

      controller.submit(intent);
      expect(controller.state.isRunning, isTrue);

      controller.cancel('req-c');
      expect(controller.state.isCancelled, isTrue);
    });

    test('stale query token is safely ignored', () {
      final controller = QueryController<String>();
      final intent = QueryIntent(rawQuery: 'fresh', queryToken: 'token-new');

      controller.submit(intent);

      final staleResult = QueryResultReference<String>(
        token: 'res-stale',
        totalCount: 1,
      );

      // Complete with stale token should return false and not alter state
      final completed = controller.complete(
        staleResult,
        queryToken: 'token-old',
      );
      expect(completed, isFalse);
      expect(controller.state.isRunning, isTrue);

      final validResult = QueryResultReference<String>(
        token: 'res-fresh',
        totalCount: 2,
      );
      final validCompleted = controller.complete(
        validResult,
        queryToken: 'token-new',
      );
      expect(validCompleted, isTrue);
      expect(controller.state.isComplete, isTrue);
    });

    test('illegal operations throw StateError', () {
      final controller = QueryController<String>();
      // Complete while idle
      expect(
        () => controller.complete(
          QueryResultReference<String>(token: 't', totalCount: 0),
        ),
        throwsStateError,
      );

      // Cancel while idle
      expect(() => controller.cancel(), throwsStateError);
    });
  });
}
