import 'dart:async';
import 'package:meta/meta.dart';
import 'package:test/test.dart';
import 'package:warp_prism_runtime/warp_prism_runtime.dart';

/// Reusable contract compliance test suite for [EventStream] implementations.
///
/// Verifies subscription lifecycle, resource cleanup, deterministic ordering,
/// completion and error paths, producer-side operations, cleanup/termination guarantees,
/// growth notification semantics, stable payload identity preservation, and behavioral backpressure policies.
///
/// Can be executed against in-memory fakes and production native bridge adapters.
///
/// Lifecycle: EXPERIMENTAL (see `docs/architecture/layer-contracts-v2.md`).
@experimental
void verifyEventStreamContract<T>({
  required EventStream<T> Function({EventStreamBackpressurePolicy? policy})
  createStream,
  required void Function(EventStream<T> stream, T event) emitEvent,
  void Function(EventStream<T> stream, Object error, [StackTrace? stackTrace])?
  emitError,
  void Function(EventStream<T> stream)? emitDone,
  void Function(EventStream<T> stream, Iterable<T> events)? emitBatch,
  void Function(EventStream<T> stream, Iterable<T> events)? replaceAll,
  void Function(EventStream<T> stream)? clear,
  required T Function(int index) createSampleEvent,
  String description = 'EventStream Contract Compliance',
}) {
  group(description, () {
    late EventStream<T> stream;

    setUp(() {
      stream = createStream();
    });

    tearDown(() async {
      if (!stream.isClosed) {
        await stream.close();
      }
    });

    group('Growth notification & identity dispositions', () {
      test(
        'growth: emit N events delivers all in order and currentEvents grows to N (delivery IS notification)',
        () async {
          final growthStream = createStream();
          final received = <T>[];
          final sub = growthStream.subscribe(onData: received.add);

          const n = 5;
          final events = List.generate(n, (i) => createSampleEvent(i + 1));
          for (final event in events) {
            emitEvent(growthStream, event);
          }

          await Future<void>.delayed(const Duration(milliseconds: 10));

          expect(received, equals(events));
          expect(growthStream.currentEvents.length, equals(n));
          expect(growthStream.currentEvents, equals(events));

          await sub.cancel();
          await growthStream.close();
        },
      );

      test(
        'growth: emitBatch delivers all items in order and currentEvents grows to N',
        () async {
          final targetStream = createStream();
          final received = <T>[];
          final sub = targetStream.subscribe(onData: received.add);

          final batchEvents = List.generate(4, (i) => createSampleEvent(i + 10));

          if (targetStream is EventStreamSink<T>) {
            (targetStream as EventStreamSink<T>).emitBatch(batchEvents);
          } else if (emitBatch != null) {
            emitBatch(targetStream, batchEvents);
          } else {
            for (final e in batchEvents) {
              emitEvent(targetStream, e);
            }
          }

          await Future<void>.delayed(const Duration(milliseconds: 10));

          expect(received, equals(batchEvents));
          expect(targetStream.currentEvents.length, equals(4));
          expect(targetStream.currentEvents, equals(batchEvents));

          await sub.cancel();
          await targetStream.close();
        },
      );

      test(
        'growth: replaceAll resets currentEvents snapshot and notifies subscribers',
        () async {
          final targetStream = createStream();
          final initialEvents = [createSampleEvent(1), createSampleEvent(2)];
          final replacementEvents = [
            createSampleEvent(3),
            createSampleEvent(4),
            createSampleEvent(5),
          ];

          if (targetStream is EventStreamSink<T>) {
            (targetStream as EventStreamSink<T>).emitBatch(initialEvents);
          } else if (emitBatch != null) {
            emitBatch(targetStream, initialEvents);
          } else {
            for (final e in initialEvents) {
              emitEvent(targetStream, e);
            }
          }

          expect(targetStream.currentEvents, equals(initialEvents));

          final receivedAfterSubscribe = <T>[];
          final sub = targetStream.subscribe(
            onData: receivedAfterSubscribe.add,
          );

          if (targetStream is EventStreamSink<T>) {
            (targetStream as EventStreamSink<T>).replaceAll(replacementEvents);
          } else if (replaceAll != null) {
            replaceAll(targetStream, replacementEvents);
          }

          await Future<void>.delayed(const Duration(milliseconds: 10));

          expect(receivedAfterSubscribe, equals(replacementEvents));
          expect(targetStream.currentEvents, equals(replacementEvents));

          await sub.cancel();
          await targetStream.close();
        },
      );

      test(
        'identity: delivered events preserve original payload identity without duplication or reordering',
        () async {
          final targetStream = createStream();
          final received = <T>[];
          final sub = targetStream.subscribe(onData: received.add);

          const n = 5;
          final events = List.generate(n, (i) => createSampleEvent(i + 1));
          for (final event in events) {
            emitEvent(targetStream, event);
          }

          await Future<void>.delayed(const Duration(milliseconds: 10));

          expect(received.length, equals(n));
          for (var i = 0; i < n; i++) {
            final delivered = received[i];
            final expected = events[i];
            expect(delivered, equals(expected));
            if (delivered is RuntimeEvent && expected is RuntimeEvent) {
              expect(delivered.id, equals(expected.id));
              expect(delivered.timestamp, equals(expected.timestamp));
              expect(delivered.severity, equals(expected.severity));
              expect(delivered.source, equals(expected.source));
              expect(delivered.runGroupId, equals(expected.runGroupId));
              expect(delivered.payload, equals(expected.payload));
            }
          }

          if (received.isNotEmpty && received.first is RuntimeEvent) {
            final ids = received.map((e) => (e as RuntimeEvent).id).toList();
            expect(ids.toSet().length, equals(n));
            expect(ids, equals(events.map((e) => (e as RuntimeEvent).id).toList()));
          }

          await sub.cancel();
          await targetStream.close();
        },
      );

      test(
        'identity: MutableEventStream surface preserves RuntimeEvent identity across emit, emitBatch, and replaceAll',
        () async {
          if (stream is MutableEventStream<T>) {
            final mutable = stream as MutableEventStream<T>;
            final received = <T>[];
            final sub = mutable.subscribe(onData: received.add);

            final e1 = createSampleEvent(101);
            final e2 = createSampleEvent(102);
            final e3 = createSampleEvent(103);

            mutable.emit(e1);
            mutable.emitBatch([e2, e3]);

            await Future<void>.delayed(const Duration(milliseconds: 10));

            expect(received, equals([e1, e2, e3]));
            expect(mutable.currentEvents, equals([e1, e2, e3]));

            if (e1 is RuntimeEvent && e2 is RuntimeEvent && e3 is RuntimeEvent) {
              final deliveredEvents = received.cast<RuntimeEvent>();
              final ids = deliveredEvents.map((e) => e.id).toList();
              expect(ids, equals([e1.id, e2.id, e3.id]));
              expect(ids.toSet().length, equals(3));
            }

            final e4 = createSampleEvent(104);
            mutable.replaceAll([e4]);

            await Future<void>.delayed(const Duration(milliseconds: 10));

            expect(mutable.currentEvents, equals([e4]));
            expect(received.last, equals(e4));
            if (e4 is RuntimeEvent) {
              expect((received.last as RuntimeEvent).id, equals(e4.id));
            }

            await sub.cancel();
          }
        },
      );
    });

    test('subscription receives emitted events in order', () async {
      final received = <T>[];
      final subscription = stream.subscribe(
        onData: (event) => received.add(event),
      );

      final event1 = createSampleEvent(1);
      final event2 = createSampleEvent(2);
      final event3 = createSampleEvent(3);

      emitEvent(stream, event1);
      emitEvent(stream, event2);
      emitEvent(stream, event3);

      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(received, equals([event1, event2, event3]));
      expect(stream.currentEvents, equals([event1, event2, event3]));
      await subscription.cancel();
    });

    test(
      'cancelling subscription stops event delivery and releases resources',
      () async {
        final received = <T>[];
        final subscription = stream.subscribe(
          onData: (event) => received.add(event),
        );

        emitEvent(stream, createSampleEvent(1));
        await Future<void>.delayed(const Duration(milliseconds: 10));
        expect(received.length, equals(1));

        await subscription.cancel();

        emitEvent(stream, createSampleEvent(2));
        await Future<void>.delayed(const Duration(milliseconds: 10));
        expect(received.length, equals(1));
      },
    );

    test('pausing subscription suspends delivery until resumed', () async {
      final received = <T>[];
      final subscription = stream.subscribe(
        onData: (event) => received.add(event),
      );

      subscription.pause();
      expect(subscription.isPaused, isTrue);

      emitEvent(stream, createSampleEvent(1));
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(received, isEmpty);

      subscription.resume();
      expect(subscription.isPaused, isFalse);
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(received.length, equals(1));

      await subscription.cancel();
    });

    test(
      'pausing subscription with resumeSignal automatically resumes delivery when signal completes',
      () async {
        final received = <T>[];
        final subscription = stream.subscribe(
          onData: (event) => received.add(event),
        );

        final resumeCompleter = Completer<void>();
        subscription.pause(resumeCompleter.future);
        expect(subscription.isPaused, isTrue);

        final e1 = createSampleEvent(1);
        emitEvent(stream, e1);
        await Future<void>.delayed(const Duration(milliseconds: 10));
        expect(received, isEmpty);

        resumeCompleter.complete();
        await Future<void>.delayed(const Duration(milliseconds: 15));

        expect(received.length, equals(1));
        expect(received.first, equals(e1));

        // Subsequent event after auto-resume is delivered immediately
        final e2 = createSampleEvent(2);
        emitEvent(stream, e2);
        await Future<void>.delayed(const Duration(milliseconds: 10));
        expect(received.length, equals(2));
        expect(received.last, equals(e2));

        await subscription.cancel();
      },
    );

    test(
      'multiple independent subscriptions receive broadcast emissions',
      () async {
        final received1 = <T>[];
        final received2 = <T>[];

        final sub1 = stream.subscribe(onData: (e) => received1.add(e));
        final sub2 = stream.subscribe(onData: (e) => received2.add(e));

        final event = createSampleEvent(42);
        emitEvent(stream, event);
        await Future<void>.delayed(const Duration(milliseconds: 10));

        expect(received1, equals([event]));
        expect(received2, equals([event]));

        await sub1.cancel();
        await sub2.cancel();
      },
    );

    test(
      'stream completion triggers onDone callback and sets isClosed',
      () async {
        final streamToComplete = createStream();
        var doneFired = false;
        final sub = streamToComplete.subscribe(
          onData: (_) {},
          onDone: () => doneFired = true,
        );

        if (streamToComplete is EventStreamSink<T>) {
          (streamToComplete as EventStreamSink<T>).complete();
        } else if (emitDone != null) {
          emitDone(streamToComplete);
        } else {
          await streamToComplete.close();
        }

        await Future<void>.delayed(const Duration(milliseconds: 10));

        expect(doneFired, isTrue);
        expect(streamToComplete.isClosed, isTrue);
        await sub.cancel();
        if (!streamToComplete.isClosed) {
          await streamToComplete.close();
        }
      },
    );

    if (emitError != null) {
      test('stream error emission triggers onError callback', () async {
        Object? capturedError;
        final sub = stream.subscribe(
          onData: (_) {},
          onError: (err, st) => capturedError = err,
        );

        final testError = StateError('Stream error condition');
        emitError(stream, testError);
        await Future<void>.delayed(const Duration(milliseconds: 10));

        expect(capturedError, equals(testError));
        await sub.cancel();
      });

      test(
        'cancelOnError true automatically cancels subscription on error',
        () async {
          final received = <T>[];
          Object? capturedError;
          final sub = stream.subscribe(
            onData: received.add,
            onError: (err, st) => capturedError = err,
            cancelOnError: true,
          );

          final e1 = createSampleEvent(1);
          final e2 = createSampleEvent(2);
          final testError = StateError('Stream failure');

          emitEvent(stream, e1);
          await Future<void>.delayed(const Duration(milliseconds: 10));
          expect(received, equals([e1]));

          emitError(stream, testError);
          await Future<void>.delayed(const Duration(milliseconds: 10));
          expect(capturedError, equals(testError));

          // Subsequent event should NOT be received because subscription cancelled on error
          emitEvent(stream, e2);
          await Future<void>.delayed(const Duration(milliseconds: 10));
          expect(received, equals([e1]));

          await sub.cancel();
        },
      );

      test(
        'cancelOnError false allows subscription to continue receiving events after error',
        () async {
          final received = <T>[];
          Object? capturedError;
          final sub = stream.subscribe(
            onData: received.add,
            onError: (err, st) => capturedError = err,
            cancelOnError: false,
          );

          final e1 = createSampleEvent(1);
          final e2 = createSampleEvent(2);
          final testError = StateError('Recoverable stream error');

          emitEvent(stream, e1);
          await Future<void>.delayed(const Duration(milliseconds: 10));
          expect(received, equals([e1]));

          emitError(stream, testError);
          await Future<void>.delayed(const Duration(milliseconds: 10));
          expect(capturedError, equals(testError));

          // Subsequent event SHOULD be received because cancelOnError is false
          emitEvent(stream, e2);
          await Future<void>.delayed(const Duration(milliseconds: 10));
          expect(received, equals([e1, e2]));

          await sub.cancel();
        },
      );
    }

    test('declares and preserves backpressure policy', () {
      final boundedStream = createStream(
        policy: const EventStreamBackpressurePolicy.dropOldest(50),
      );
      expect(
        boundedStream.backpressurePolicy.strategy,
        equals(BackpressureStrategy.dropOldest),
      );
      expect(boundedStream.backpressurePolicy.capacity, equals(50));
      boundedStream.close();
    });

    test(
      'backpressure unbounded strategy buffers and delivers all events',
      () async {
        final unboundedStream = createStream(
          policy: const EventStreamBackpressurePolicy.unbounded(),
        );
        final received = <T>[];
        final sub = unboundedStream.subscribe(onData: received.add);

        final e1 = createSampleEvent(1);
        final e2 = createSampleEvent(2);
        final e3 = createSampleEvent(3);
        final e4 = createSampleEvent(4);

        emitEvent(unboundedStream, e1);
        emitEvent(unboundedStream, e2);
        emitEvent(unboundedStream, e3);
        emitEvent(unboundedStream, e4);

        await Future<void>.delayed(const Duration(milliseconds: 10));

        expect(received, equals([e1, e2, e3, e4]));
        expect(unboundedStream.currentEvents, equals([e1, e2, e3, e4]));

        await sub.cancel();
        await unboundedStream.close();
      },
    );

    test(
      'backpressure dropOldest strategy evicts oldest items at capacity',
      () async {
        final dropOldestStream = createStream(
          policy: const EventStreamBackpressurePolicy.dropOldest(2),
        );

        final e1 = createSampleEvent(1);
        final e2 = createSampleEvent(2);
        final e3 = createSampleEvent(3);

        emitEvent(dropOldestStream, e1);
        emitEvent(dropOldestStream, e2);
        emitEvent(dropOldestStream, e3);

        await Future<void>.delayed(const Duration(milliseconds: 10));

        expect(dropOldestStream.currentEvents.length, equals(2));
        expect(dropOldestStream.currentEvents, equals([e2, e3]));

        await dropOldestStream.close();
      },
    );

    test(
      'backpressure dropNewest strategy ignores incoming items at capacity',
      () async {
        final dropNewestStream = createStream(
          policy: const EventStreamBackpressurePolicy.dropNewest(2),
        );

        final e1 = createSampleEvent(1);
        final e2 = createSampleEvent(2);
        final e3 = createSampleEvent(3);

        emitEvent(dropNewestStream, e1);
        emitEvent(dropNewestStream, e2);
        emitEvent(dropNewestStream, e3);

        await Future<void>.delayed(const Duration(milliseconds: 10));

        expect(dropNewestStream.currentEvents.length, equals(2));
        expect(dropNewestStream.currentEvents, equals([e1, e2]));

        await dropNewestStream.close();
      },
    );

    test(
      'backpressure errorOnOverflow strategy signals error on overflow',
      () async {
        final errorStream = createStream(
          policy: const EventStreamBackpressurePolicy.errorOnOverflow(2),
        );

        Object? capturedError;
        final sub = errorStream.subscribe(
          onData: (_) {},
          onError: (err, st) => capturedError = err,
        );

        final e1 = createSampleEvent(1);
        final e2 = createSampleEvent(2);
        final e3 = createSampleEvent(3);

        emitEvent(errorStream, e1);
        emitEvent(errorStream, e2);
        expect(capturedError, isNull);

        // Third event exceeds capacity of 2
        emitEvent(errorStream, e3);
        await Future<void>.delayed(const Duration(milliseconds: 10));

        expect(capturedError, isNotNull);
        expect(capturedError, isA<StateError>());
        expect(errorStream.currentEvents.length, equals(2));
        expect(errorStream.currentEvents, equals([e1, e2]));

        await sub.cancel();
        await errorStream.close();
      },
    );

    test('producer single, batch, replaceAll, and clear operations', () async {
      final targetStream = createStream();
      final e1 = createSampleEvent(1);
      final e2 = createSampleEvent(2);
      final e3 = createSampleEvent(3);
      final e4 = createSampleEvent(4);

      if (targetStream is EventStreamSink<T>) {
        final sink = targetStream as EventStreamSink<T>;
        sink.emit(e1);
        expect(targetStream.currentEvents, equals([e1]));

        sink.emitBatch([e2, e3]);
        expect(targetStream.currentEvents, equals([e1, e2, e3]));

        sink.replaceAll([e3, e4]);
        expect(targetStream.currentEvents, equals([e3, e4]));

        sink.clear();
        expect(targetStream.currentEvents, isEmpty);
      } else {
        if (emitBatch != null) {
          emitBatch(targetStream, [e1, e2]);
          expect(targetStream.currentEvents, equals([e1, e2]));
        }
        if (replaceAll != null) {
          replaceAll(targetStream, [e3, e4]);
          expect(targetStream.currentEvents, equals([e3, e4]));
        }
        if (clear != null) {
          clear(targetStream);
          expect(targetStream.currentEvents, isEmpty);
        }
      }

      await targetStream.close();
    });

    test(
      'stream close terminates active subscriptions, watch stream, and updates isClosed',
      () async {
        final targetStream = createStream();
        var subDone = false;
        var rawStreamDone = false;

        final sub = targetStream.subscribe(
          onData: (_) {},
          onDone: () => subDone = true,
        );
        final rawSub = targetStream.stream.listen(
          (_) {},
          onDone: () => rawStreamDone = true,
        );

        expect(targetStream.isClosed, isFalse);
        await targetStream.close();

        await Future<void>.delayed(const Duration(milliseconds: 10));

        expect(targetStream.isClosed, isTrue);
        expect(subDone, isTrue);
        expect(rawStreamDone, isTrue);

        await sub.cancel();
        await rawSub.cancel();
      },
    );

    test(
      'post-close operations fail deterministically and close is idempotent',
      () async {
        final targetStream = createStream();
        await targetStream.close();
        expect(targetStream.isClosed, isTrue);

        // Subsequent close() call is idempotent
        await targetStream.close();
        expect(targetStream.isClosed, isTrue);

        if (targetStream is EventStreamSink<T>) {
          final sink = targetStream as EventStreamSink<T>;
          expect(
            () => sink.emit(createSampleEvent(1)),
            throwsA(isA<StateError>()),
          );
          expect(
            () => sink.emitBatch([createSampleEvent(1)]),
            throwsA(isA<StateError>()),
          );
          expect(
            () => sink.replaceAll([createSampleEvent(1)]),
            throwsA(isA<StateError>()),
          );
          expect(() => sink.clear(), throwsA(isA<StateError>()));
          expect(
            () => sink.emitError(StateError('post-close')),
            throwsA(isA<StateError>()),
          );
        }
      },
    );
  });
}

void main() {}
