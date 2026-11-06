import 'dart:async';
import 'package:meta/meta.dart';
import 'event_stream_models.dart';

/// Active subscription handle for an [EventStream].
///
/// Enables consumers to pause, resume, or cancel event delivery with
/// deterministic resource cleanup.
///
/// Lifecycle: EXPERIMENTAL (see `.project/architecture/layer-contracts.md`).
@experimental
abstract interface class EventStreamSubscription<T> {
  /// Cancels this subscription and releases associated resources.
  Future<void> cancel();

  /// Pauses event delivery.
  ///
  /// If [resumeSignal] is provided, delivery automatically resumes when
  /// [resumeSignal] completes.
  void pause([Future<void>? resumeSignal]);

  /// Resumes event delivery if paused.
  void resume();

  /// Whether this subscription is currently paused.
  bool get isPaused;
}

/// Backend-agnostic reactive event stream contract.
///
/// Models append-only event delivery with deterministic FIFO ordering,
/// stream completion, error signaling, and declared backpressure policy.
///
/// **Growth Notification Decision**:
/// The stream delivery itself IS the formal growth notification — a subscriber
/// observing the stream (via [stream] or [subscribe]) observes every appended event;
/// [currentEvents] provides the retained snapshot buffer. There is no separate
/// growth event because that would duplicate delivery.
///
/// **Stable Identity Decision**:
/// Identity is payload-side by design — [EventStream] is generic so `T` MAY be
/// any type. When stable identity is required, consumers use the identity-bearing
/// reference model [RuntimeEvent] (which carries `id`, timestamp, severity, source,
/// and run-group metadata). The contract does not constrain `T extends` an identity
/// base because that would couple all consumers to one event shape.
///
/// Reference: `.project/architecture/runtime-consumer-audit.md §6` and
/// `.project/architecture/layer-contracts.md`.
///
/// **PURGE LAW**: This contract contains strictly zero presentation policy,
/// viewport mechanics, or UI filter states.
///
/// Lifecycle: EXPERIMENTAL (see `.project/architecture/layer-contracts.md`).
@experimental
abstract interface class EventStream<T> {
  /// Underlying Dart [Stream] exposing emitted events.
  Stream<T> get stream;

  /// The backpressure policy governing this stream's buffer.
  EventStreamBackpressurePolicy get backpressurePolicy;

  /// Ordered snapshot of current retained events in the stream buffer.
  List<T> get currentEvents;

  /// Whether this event stream has been closed.
  bool get isClosed;

  /// Subscribes a listener to events emitted by this stream.
  ///
  /// Returns an [EventStreamSubscription] that must be cancelled when no
  /// longer needed to ensure resource cleanup.
  EventStreamSubscription<T> subscribe({
    required void Function(T event) onData,
    void Function(Object error, StackTrace stackTrace)? onError,
    void Function()? onDone,
    bool? cancelOnError,
  });

  /// Closes the event stream and releases all underlying resources.
  Future<void> close();
}

/// Source/producer-side contract for writing and controlling an event stream.
///
/// Complements [EventStream] (the read/consumer side) with write-side capabilities
/// required by runtime adapters and producer engines:
/// - Single event emission ([emit])
/// - Batch event emission ([emitBatch])
/// - Full buffer replacement ([replaceAll])
/// - Buffer clearing ([clear])
/// - Error emission ([emitError])
/// - Terminal stream completion ([complete])
///
/// Lifecycle: EXPERIMENTAL (see `.project/architecture/layer-contracts.md`).
@experimental
abstract interface class EventStreamSink<T> {
  /// Appends a single event to the stream and buffer.
  void emit(T event);

  /// Appends an ordered batch of events to the stream and buffer.
  void emitBatch(Iterable<T> events);

  /// Atomically replaces all existing events in the buffer with [events].
  void replaceAll(Iterable<T> events);

  /// Clears all events from the stream buffer.
  void clear();

  /// Emits an error condition across the stream.
  void emitError(Object error, [StackTrace? stackTrace]);

  /// Signals terminal completion of the event stream.
  void complete();

  /// Whether this sink is closed.
  bool get isClosed;
}

/// A combined read-write event stream combining consumer-side [EventStream]
/// and producer-side [EventStreamSink] capabilities.
///
/// Lifecycle: EXPERIMENTAL (see `.project/architecture/layer-contracts.md`).
@experimental
abstract interface class MutableEventStream<T>
    implements EventStream<T>, EventStreamSink<T> {}

/// Alias for [MutableEventStream] representing a mutable source of events.
///
/// Lifecycle: EXPERIMENTAL (see `.project/architecture/layer-contracts.md`).
@experimental
typedef MutableEventSource<T> = MutableEventStream<T>;
