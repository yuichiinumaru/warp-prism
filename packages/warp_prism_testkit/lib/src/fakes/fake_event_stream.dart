import 'dart:async';
import 'package:meta/meta.dart';
import 'package:warp_prism_runtime/warp_prism_runtime.dart';

/// In-memory fake implementation of [MutableEventStream] for deterministic testing.
///
/// Provides programmatic emission controls, subscription tracking,
/// buffer inspection, and configurable backpressure policy handling.
///
/// Lifecycle: EXPERIMENTAL (see `.project/architecture/layer-contracts.md`).
@experimental
class FakeEventStream<T> implements MutableEventStream<T> {
  @override
  final EventStreamBackpressurePolicy backpressurePolicy;

  final StreamController<T> _controller;
  final List<T> _emittedEvents = [];
  final List<_FakeSubscription<T>> _subscriptions = [];
  bool _isClosed = false;

  /// Creates a [FakeEventStream] with optional backpressure policy and sync delivery flag.
  FakeEventStream({
    this.backpressurePolicy = const EventStreamBackpressurePolicy.unbounded(),
    bool sync = true,
  }) : _controller = StreamController<T>.broadcast(sync: sync);

  @override
  Stream<T> get stream => _controller.stream;

  @override
  bool get isClosed => _isClosed;

  @override
  List<T> get currentEvents => List.unmodifiable(_emittedEvents);

  /// Unmodifiable view of all events emitted by this fake.
  List<T> get emittedEvents => List.unmodifiable(_emittedEvents);

  /// Total number of active (non-cancelled) subscriptions.
  int get activeSubscriptionCount =>
      _subscriptions.where((s) => !s.isCancelled).length;

  /// Total count of all subscriptions created on this stream.
  int get totalSubscriptionCount => _subscriptions.length;

  @override
  void emit(T event) => emitEvent(event);

  @override
  void emitBatch(Iterable<T> events) => emitEvents(events);

  @override
  void replaceAll(Iterable<T> events) {
    if (_isClosed) {
      throw StateError('Cannot replace events on closed FakeEventStream');
    }
    _emittedEvents.clear();
    emitBatch(events);
  }

  /// Programmatically emits a single event.
  void emitEvent(T event) {
    if (_isClosed) {
      throw StateError('Cannot emit event on closed FakeEventStream');
    }

    final cap = backpressurePolicy.capacity;
    switch (backpressurePolicy.strategy) {
      case BackpressureStrategy.unbounded:
        _emittedEvents.add(event);
        _controller.add(event);
      case BackpressureStrategy.dropOldest:
        if (cap != null && _emittedEvents.length >= cap) {
          _emittedEvents.removeAt(0);
        }
        _emittedEvents.add(event);
        _controller.add(event);
      case BackpressureStrategy.dropNewest:
        if (cap != null && _emittedEvents.length >= cap) {
          // Drop newest incoming event
          return;
        }
        _emittedEvents.add(event);
        _controller.add(event);
      case BackpressureStrategy.errorOnOverflow:
        if (cap != null && _emittedEvents.length >= cap) {
          _controller.addError(
            StateError('Buffer overflow: capacity of $cap exceeded'),
          );
          return;
        }
        _emittedEvents.add(event);
        _controller.add(event);
    }
  }

  /// Programmatically emits an ordered sequence of events.
  void emitEvents(Iterable<T> events) {
    for (final event in events) {
      emitEvent(event);
    }
  }

  @override
  void emitError(Object error, [StackTrace? stackTrace]) {
    if (_isClosed) {
      throw StateError('Cannot emit error on closed FakeEventStream');
    }
    _controller.addError(error, stackTrace);
  }

  @override
  void complete() {
    _isClosed = true;
    if (!_controller.isClosed) {
      _controller.close();
    }
  }

  @override
  void clear() {
    if (_isClosed) {
      throw StateError('Cannot clear closed FakeEventStream');
    }
    _emittedEvents.clear();
  }

  @override
  EventStreamSubscription<T> subscribe({
    required void Function(T event) onData,
    void Function(Object error, StackTrace stackTrace)? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    final sub = _FakeSubscription<T>(
      stream: _controller.stream,
      onData: onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
      onDispose: (s) => _subscriptions.remove(s),
    );
    _subscriptions.add(sub);
    return sub;
  }

  @override
  Future<void> close() async {
    _isClosed = true;
    if (!_controller.isClosed) {
      await _controller.close();
    }
    _subscriptions.clear();
  }
}

class _FakeSubscription<T> implements EventStreamSubscription<T> {
  final StreamSubscription<T> _nativeSubscription;
  final void Function(_FakeSubscription<T>) onDispose;
  bool _isCancelled = false;
  bool _isPaused = false;

  _FakeSubscription({
    required Stream<T> stream,
    required void Function(T event) onData,
    void Function(Object error, StackTrace stackTrace)? onError,
    void Function()? onDone,
    bool? cancelOnError,
    required this.onDispose,
  }) : _nativeSubscription = stream.listen(
         onData,
         onError: onError,
         onDone: onDone,
         cancelOnError: cancelOnError,
       );

  bool get isCancelled => _isCancelled;

  @override
  bool get isPaused => _isPaused;

  @override
  Future<void> cancel() async {
    if (_isCancelled) return;
    _isCancelled = true;
    await _nativeSubscription.cancel();
    onDispose(this);
  }

  @override
  void pause([Future<void>? resumeSignal]) {
    if (_isCancelled || _isPaused) return;
    _isPaused = true;
    _nativeSubscription.pause(resumeSignal);
    if (resumeSignal != null) {
      resumeSignal.then((_) {
        _isPaused = false;
      });
    }
  }

  @override
  void resume() {
    if (_isCancelled || !_isPaused) return;
    _isPaused = false;
    _nativeSubscription.resume();
  }
}
