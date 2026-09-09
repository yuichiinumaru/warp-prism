import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_bindings/warp_prism_bindings.dart';
import 'package:warp_prism_runtime/warp_prism_runtime.dart';
import 'package:warp_prism_testkit/warp_prism_testkit.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

void main() {
  group('EventStreamBinding', () {
    test('initializes with current retained events from source', () {
      final fakeStream = FakeEventStream<String>();
      fakeStream.emitBatch(const ['event-0', 'event-1']);

      final binding = EventStreamBinding<String>(source: fakeStream);

      expect(binding.count, equals(2));
      expect(binding.events, equals(['event-0', 'event-1']));
      expect(binding.status, equals(EventStreamBindingStatus.active));
      expect(binding.isEmpty, isFalse);

      binding.dispose();
    });

    test(
      'enforces maxRetainedEvents capacity limit on initialization and stream emission',
      () async {
        final fakeStream = FakeEventStream<String>();
        fakeStream.emitBatch(const ['e0', 'e1', 'e2']);

        final binding = EventStreamBinding<String>(
          source: fakeStream,
          maxRetainedEvents: 3,
        );

        expect(binding.events, equals(['e0', 'e1', 'e2']));

        fakeStream.emit('e3');
        await Future<void>.delayed(Duration.zero);

        expect(binding.events, equals(['e1', 'e2', 'e3']));
        expect(binding.count, equals(3));

        fakeStream.emit('e4');
        await Future<void>.delayed(Duration.zero);

        expect(binding.events, equals(['e2', 'e3', 'e4']));

        binding.dispose();
      },
    );

    test('receives incremental events and notifies listeners', () async {
      final fakeStream = FakeEventStream<String>();
      final binding = EventStreamBinding<String>(source: fakeStream);

      final notifications = <List<String>>[];
      binding.addListener(() {
        notifications.add(binding.events);
      });

      fakeStream.emit('first');
      await Future<void>.delayed(Duration.zero);

      fakeStream.emit('second');
      await Future<void>.delayed(Duration.zero);

      expect(notifications.length, equals(2));
      expect(binding.events, equals(['first', 'second']));

      binding.dispose();
    });

    test('supports pause, resume, and clear controls', () async {
      final fakeStream = FakeEventStream<String>();
      final binding = EventStreamBinding<String>(source: fakeStream);

      binding.pause();
      expect(binding.isPaused, isTrue);
      expect(binding.status, equals(EventStreamBindingStatus.paused));

      binding.resume();
      expect(binding.isPaused, isFalse);
      expect(binding.status, equals(EventStreamBindingStatus.active));

      fakeStream.emit('item-1');
      await Future<void>.delayed(Duration.zero);
      expect(binding.count, equals(1));

      binding.clear();
      expect(binding.isEmpty, isTrue);
      expect(binding.events, isEmpty);

      binding.dispose();
    });

    test('captures and exposes stream error conditions', () async {
      final fakeStream = FakeEventStream<String>();
      final binding = EventStreamBinding<String>(source: fakeStream);

      final errors = <Object>[];
      binding.eventStream.listen((_) {}, onError: (e) => errors.add(e));

      fakeStream.emitError(Exception('Stream network drop'));
      await Future<void>.delayed(Duration.zero);

      expect(binding.status, equals(EventStreamBindingStatus.error));
      expect(binding.error, isNotNull);
      expect(binding.error.toString(), contains('Stream network drop'));
      expect(errors.length, equals(1));

      binding.dispose();
    });

    test('propagates terminal stream completion', () async {
      final fakeStream = FakeEventStream<String>();
      final binding = EventStreamBinding<String>(source: fakeStream);

      expect(binding.isCompleted, isFalse);

      fakeStream.complete();
      await Future<void>.delayed(Duration.zero);

      expect(binding.isCompleted, isTrue);
      expect(binding.status, equals(EventStreamBindingStatus.completed));

      binding.dispose();
    });

    test('dispose cancels subscription and closes streams safely', () async {
      final fakeStream = FakeEventStream<String>();
      final binding = EventStreamBinding<String>(source: fakeStream);

      binding.dispose();
      expect(binding.isDisposed, isTrue);
      expect(binding.status, equals(EventStreamBindingStatus.disposed));

      // Emitting after dispose does not throw or mutate binding
      fakeStream.emit('after-dispose');
      await Future<void>.delayed(Duration.zero);

      expect(binding.events, isEmpty);
    });

    test('projects RuntimeEvent payloads to PrismExecutionLine models', () {
      final timestamp = DateTime(2026, 9, 1, 14, 30, 0);
      final events = [
        RuntimeEvent<String>(
          id: 'evt-1',
          timestamp: timestamp,
          payload: 'Building target binary',
          severity: EventSeverity.stdout,
          source: 'compiler',
          runGroupId: 'run-101',
        ),
        RuntimeEvent<String>(
          id: 'evt-2',
          timestamp: timestamp,
          payload: 'Deprecation warning',
          severity: EventSeverity.warning,
          source: 'linter',
          runGroupId: 'run-101',
        ),
        RuntimeEvent<String>(
          id: 'evt-3',
          timestamp: timestamp,
          payload: 'Compilation failed',
          severity: EventSeverity.error,
          source: 'compiler',
          runGroupId: 'run-101',
        ),
      ];

      final fakeStream = FakeEventStream<RuntimeEvent<String>>();
      fakeStream.emitBatch(events);

      final binding = EventStreamBinding<RuntimeEvent<String>>(
        source: fakeStream,
      );

      final lines = binding.toExecutionLines();

      expect(lines.length, equals(3));
      expect(lines[0].id, equals('evt-1'));
      expect(lines[0].message, equals('Building target binary'));
      expect(lines[0].level, equals(PrismExecutionLineLevel.stdout));
      expect(lines[0].runGroupId, equals('run-101'));
      expect(lines[0].source, equals('compiler'));

      expect(lines[1].level, equals(PrismExecutionLineLevel.warning));
      expect(lines[2].level, equals(PrismExecutionLineLevel.error));

      binding.dispose();
    });

    test('projects RuntimeEvent payloads to PrismLogEntry models', () {
      final timestamp = DateTime(2026, 9, 1, 15, 0, 0);
      final events = [
        RuntimeEvent<String>(
          id: 'log-1',
          timestamp: timestamp,
          payload: 'Observed daemon heartbeat',
          severity: EventSeverity.info,
          source: 'obs-daemon',
          metadata: const {'pid': 1234},
        ),
        RuntimeEvent<String>(
          id: 'log-2',
          timestamp: timestamp,
          payload: 'Connection timed out',
          severity: EventSeverity.error,
          source: 'obs-daemon',
        ),
      ];

      final fakeStream = FakeEventStream<RuntimeEvent<String>>();
      fakeStream.emitBatch(events);

      final binding = EventStreamBinding<RuntimeEvent<String>>(
        source: fakeStream,
      );

      final logEntries = binding.toLogEntries();

      expect(logEntries.length, equals(2));
      expect(logEntries[0].id, equals('log-1'));
      expect(logEntries[0].message, equals('Observed daemon heartbeat'));
      expect(logEntries[0].severity, equals(PrismLogSeverity.info));
      expect(logEntries[0].source, equals('obs-daemon'));
      expect(logEntries[0].detail, contains('pid: 1234'));

      expect(logEntries[1].severity, equals(PrismLogSeverity.error));

      binding.dispose();
    });

    test(
      'projects non-RuntimeEvent payloads to PrismLogEntry using deterministic fallback timestamp',
      () {
        final fakeStream = FakeEventStream<String>();
        fakeStream.emitBatch(const ['raw line 1', 'raw line 2']);

        final binding = EventStreamBinding<String>(source: fakeStream);

        final logEntries = binding.toLogEntries();

        expect(logEntries.length, equals(2));
        expect(logEntries[0].id, equals('log-0'));
        expect(logEntries[0].message, equals('raw line 1'));
        expect(logEntries[0].severity, equals(PrismLogSeverity.info));
        expect(logEntries[0].source, equals('binding'));
        expect(
          logEntries[0].timestamp,
          equals(EventStreamBinding.deterministicFallbackTimestamp),
        );
        expect(
          logEntries[0].timestamp,
          equals(DateTime.fromMillisecondsSinceEpoch(0, isUtc: true)),
        );

        expect(logEntries[1].id, equals('log-1'));
        expect(logEntries[1].message, equals('raw line 2'));
        expect(
          logEntries[1].timestamp,
          equals(EventStreamBinding.deterministicFallbackTimestamp),
        );

        binding.dispose();
      },
    );

    test('supports optional followState property and change notification', () {
      final fakeStream = FakeEventStream<String>();
      final binding = EventStreamBinding<String>(
        source: fakeStream,
        initialFollowState: EventStreamFollowState.following,
      );

      expect(binding.followState, equals(EventStreamFollowState.following));

      var notifications = 0;
      binding.addListener(() {
        notifications++;
      });

      // Mutate followState
      binding.followState = EventStreamFollowState.unlocked;
      expect(binding.followState, equals(EventStreamFollowState.unlocked));
      expect(notifications, equals(1));

      // Setting same value is a no-op and does not notify
      binding.followState = EventStreamFollowState.unlocked;
      expect(notifications, equals(1));

      // Mutate to paused
      binding.followState = EventStreamFollowState.paused;
      expect(binding.followState, equals(EventStreamFollowState.paused));
      expect(notifications, equals(2));

      binding.dispose();
    });
  });
}
