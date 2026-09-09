import 'package:meta/meta.dart';
import 'dart:async';
import 'package:warp_prism_runtime/warp_prism_runtime.dart';
import 'rust/api.dart' as frb_api;

/// Internal subscription handle for [FrbEventStream].
class _FrbEventStreamSubscription<T> implements EventStreamSubscription<T> {
  final StreamSubscription<T> _subscription;
  bool _isPaused = false;

  _FrbEventStreamSubscription(this._subscription);

  @override
  bool get isPaused => _isPaused;

  @override
  void pause([Future<void>? resumeSignal]) {
    _isPaused = true;
    _subscription.pause(resumeSignal);
  }

  @override
  void resume() {
    _isPaused = false;
    _subscription.resume();
  }

  @override
  Future<void> cancel() async {
    await _subscription.cancel();
  }
}

/// FRB native-backed implementation of [MutableEventStream].
/// Lifecycle: EXPERIMENTAL (see `docs/architecture/layer-contracts-v2.md`).
@experimental
class FrbEventStream implements MutableEventStream<RuntimeEvent<String>> {
  final StreamController<RuntimeEvent<String>> _controller;
  final List<RuntimeEvent<String>> _buffer = [];
  @override
  final EventStreamBackpressurePolicy backpressurePolicy;
  bool _isClosed = false;

  FrbEventStream({
    this.backpressurePolicy = const EventStreamBackpressurePolicy.unbounded(),
  }) : _controller = StreamController<RuntimeEvent<String>>.broadcast();

  @override
  List<RuntimeEvent<String>> get currentEvents => List.unmodifiable(_buffer);

  @override
  bool get isClosed => _isClosed;

  @override
  Stream<RuntimeEvent<String>> get stream => _controller.stream;

  @override
  EventStreamSubscription<RuntimeEvent<String>> subscribe({
    required void Function(RuntimeEvent<String> event) onData,
    void Function(Object error, StackTrace stackTrace)? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    final sub = _controller.stream.listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
    return _FrbEventStreamSubscription(sub);
  }

  @override
  void emit(RuntimeEvent<String> event) {
    if (_isClosed) {
      throw StateError('Cannot emit event on closed FrbEventStream');
    }

    final cap = backpressurePolicy.capacity;
    switch (backpressurePolicy.strategy) {
      case BackpressureStrategy.unbounded:
        _buffer.add(event);
        _controller.add(event);
      case BackpressureStrategy.dropOldest:
        if (cap != null && _buffer.length >= cap) {
          _buffer.removeAt(0);
        }
        _buffer.add(event);
        _controller.add(event);
      case BackpressureStrategy.dropNewest:
        if (cap != null && _buffer.length >= cap) {
          return;
        }
        _buffer.add(event);
        _controller.add(event);
      case BackpressureStrategy.errorOnOverflow:
        if (cap != null && _buffer.length >= cap) {
          _controller.addError(
            StateError('Buffer overflow: capacity of $cap exceeded'),
          );
          return;
        }
        _buffer.add(event);
        _controller.add(event);
    }
  }

  @override
  void emitBatch(Iterable<RuntimeEvent<String>> events) {
    if (_isClosed) {
      throw StateError('Cannot emit batch on closed FrbEventStream');
    }
    for (final e in events) {
      emit(e);
    }
  }

  @override
  void replaceAll(Iterable<RuntimeEvent<String>> events) {
    if (_isClosed) {
      throw StateError('Cannot replace events on closed FrbEventStream');
    }
    _buffer.clear();
    for (final e in events) {
      emit(e);
    }
  }

  @override
  void clear() {
    if (_isClosed) {
      throw StateError('Cannot clear closed FrbEventStream');
    }
    _buffer.clear();
  }

  @override
  void emitError(Object error, [StackTrace? stackTrace]) {
    if (_isClosed) {
      throw StateError('Cannot emit error on closed FrbEventStream');
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
  Future<void> close() async {
    _isClosed = true;
    if (!_controller.isClosed) {
      await _controller.close();
    }
  }

  /// Streams events directly from the native Rust substrate into this event stream.
  StreamSubscription<frb_api.FrbEvent> pipeFromNativeStream({
    required int count,
    required String prefix,
  }) {
    final nativeStream = frb_api.streamEvents(count: count, prefix: prefix);
    return nativeStream.listen((nativeEvt) {
      final runtimeEvt = _convertFromNative(nativeEvt);
      emit(runtimeEvt);
    });
  }

  /// Converts an FRB generated event to a Warp Prism [RuntimeEvent].
  static RuntimeEvent<String> _convertFromNative(frb_api.FrbEvent e) {
    final millis = e.timestampMillis.toInt();

    final severity = switch (e.severity) {
      frb_api.FrbEventSeverity.stdout => EventSeverity.stdout,
      frb_api.FrbEventSeverity.stderr => EventSeverity.stderr,
      frb_api.FrbEventSeverity.info => EventSeverity.info,
      frb_api.FrbEventSeverity.warning => EventSeverity.warning,
      frb_api.FrbEventSeverity.error => EventSeverity.error,
      frb_api.FrbEventSeverity.system => EventSeverity.system,
    };

    return RuntimeEvent<String>(
      id: e.id,
      timestamp: DateTime.fromMillisecondsSinceEpoch(millis),
      severity: severity,
      source: e.source,
      runGroupId: e.runGroupId,
      payload: e.payload,
    );
  }
}
