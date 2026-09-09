import 'dart:async';
import 'package:test/test.dart';
import 'package:warp_prism_runtime/warp_prism_runtime.dart';
import 'package:warp_prism_testkit/warp_prism_testkit.dart';

void main() {
  group('FakeEventStream Contract Verification', () {
    verifyEventStreamContract<RuntimeEvent<String>>(
      createStream: ({policy}) => FakeEventStream<RuntimeEvent<String>>(
        backpressurePolicy:
            policy ?? const EventStreamBackpressurePolicy.unbounded(),
      ),
      emitEvent: (stream, event) =>
          (stream as FakeEventStream<RuntimeEvent<String>>).emitEvent(event),
      emitError: (stream, error, [st]) =>
          (stream as FakeEventStream<RuntimeEvent<String>>).emitError(
            error,
            st,
          ),
      emitDone: (stream) =>
          (stream as FakeEventStream<RuntimeEvent<String>>).complete(),
      createSampleEvent: (index) => RuntimeEvent<String>(
        id: 'evt_$index',
        timestamp: DateTime.now(),
        payload: 'payload_$index',
      ),
    );

    test('FakeEventStream records emittedEvents history and allows clear', () {
      final stream = FakeEventStream<String>();
      stream.emitEvent('first');
      stream.emitEvents(['second', 'third']);

      expect(stream.emittedEvents, equals(['first', 'second', 'third']));
      stream.clear();
      expect(stream.emittedEvents, isEmpty);
      stream.close();
    });

    test('FakeEventStream tracks total and active subscriptions', () async {
      final stream = FakeEventStream<String>();
      expect(stream.totalSubscriptionCount, equals(0));
      expect(stream.activeSubscriptionCount, equals(0));

      final sub1 = stream.subscribe(onData: (_) {});
      final sub2 = stream.subscribe(onData: (_) {});

      expect(stream.totalSubscriptionCount, equals(2));
      expect(stream.activeSubscriptionCount, equals(2));

      await sub1.cancel();
      expect(stream.activeSubscriptionCount, equals(1));

      await sub2.cancel();
      expect(stream.activeSubscriptionCount, equals(0));

      await stream.close();
    });

    test('FakeEventStream dropOldest drops oldest from emitted buffer', () {
      final stream = FakeEventStream<String>(
        backpressurePolicy: const EventStreamBackpressurePolicy.dropOldest(2),
      );

      stream.emitEvents(['a', 'b', 'c']);
      expect(stream.emittedEvents, equals(['b', 'c']));
      stream.close();
    });

    test(
      'FakeEventStream dropNewest drops newest incoming items at capacity',
      () {
        final stream = FakeEventStream<String>(
          backpressurePolicy: const EventStreamBackpressurePolicy.dropNewest(2),
        );

        stream.emitEvents(['a', 'b', 'c']);
        expect(stream.emittedEvents, equals(['a', 'b']));
        stream.close();
      },
    );

    test('FakeEventStream producer methods (emit, emitBatch, replaceAll)', () {
      final stream = FakeEventStream<String>();
      stream.emit('item1');
      stream.emitBatch(['item2', 'item3']);
      expect(stream.currentEvents, equals(['item1', 'item2', 'item3']));

      stream.replaceAll(['new1', 'new2']);
      expect(stream.currentEvents, equals(['new1', 'new2']));

      stream.clear();
      expect(stream.currentEvents, isEmpty);
      stream.close();
    });

    test('FakeEventStream complete sets isClosed true and completes controller', () {
      final stream = FakeEventStream<String>();
      expect(stream.isClosed, isFalse);
      stream.complete();
      expect(stream.isClosed, isTrue);
      expect(() => stream.emit('post_complete'), throwsA(isA<StateError>()));
    });

    test(
      'FakeEventStream pause with resumeSignal auto-resumes and tracks isPaused flag',
      () async {
        final stream = FakeEventStream<String>();
        final received = <String>[];
        final sub = stream.subscribe(onData: received.add);

        final resumeCompleter = Completer<void>();
        sub.pause(resumeCompleter.future);
        expect(sub.isPaused, isTrue);

        stream.emit('delayed_item');
        await Future<void>.delayed(const Duration(milliseconds: 10));
        expect(received, isEmpty);

        resumeCompleter.complete();
        await Future<void>.delayed(const Duration(milliseconds: 10));

        expect(sub.isPaused, isFalse);
        expect(received, equals(['delayed_item']));

        await sub.cancel();
        await stream.close();
      },
    );

    test(
      'FakeEventStream MutableEventStream surface preserves RuntimeEvent id and notifies subscribers',
      () async {
        final MutableEventStream<RuntimeEvent<String>> stream =
            FakeEventStream<RuntimeEvent<String>>();
        final received = <RuntimeEvent<String>>[];
        final sub = stream.subscribe(onData: received.add);

        final e1 = RuntimeEvent<String>(
          id: 'evt_log_1',
          timestamp: DateTime(2026, 9, 1, 12, 0, 0),
          severity: EventSeverity.stdout,
          source: 'process_runner',
          runGroupId: 'group_42',
          payload: 'Process started',
        );
        final e2 = RuntimeEvent<String>(
          id: 'evt_log_2',
          timestamp: DateTime(2026, 9, 1, 12, 0, 1),
          severity: EventSeverity.info,
          source: 'process_runner',
          runGroupId: 'group_42',
          payload: 'Initialization complete',
        );

        stream.emit(e1);
        stream.emitBatch([e2]);

        await Future<void>.delayed(const Duration(milliseconds: 10));

        expect(received, equals([e1, e2]));
        expect(stream.currentEvents, equals([e1, e2]));
        expect(received.map((e) => e.id), equals(['evt_log_1', 'evt_log_2']));

        final e3 = RuntimeEvent<String>(
          id: 'evt_log_3',
          timestamp: DateTime(2026, 9, 1, 12, 0, 2),
          severity: EventSeverity.system,
          payload: 'Snapshot reset',
        );
        stream.replaceAll([e3]);

        await Future<void>.delayed(const Duration(milliseconds: 10));

        expect(stream.currentEvents, equals([e3]));
        expect(received.last.id, equals('evt_log_3'));

        await sub.cancel();
        await stream.close();
      },
    );
  });
}
