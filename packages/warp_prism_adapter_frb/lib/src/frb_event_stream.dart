import 'package:meta/meta.dart';
import 'dart:async';
import 'package:warp_prism_runtime/warp_prism_runtime.dart';
import 'rust/api.dart' as frb_api;

/// Converts an FRB generated event to a Warp Prism [RuntimeEvent].
RuntimeEvent<String> _convertFromNative(frb_api.FrbEvent e) {
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

/// Internal subscription handle for the FRB event-stream variants.
class _FrbEventStreamSubscription<T> implements EventStreamSubscription<T> {
  final StreamSubscription<T> _subscription;
  bool _isPaused = false;

  /// Invoked when a consumer pauses this handle, so an owner with an upstream
  /// source can propagate the pause. Null for purely local streams.
  void Function()? onPauseRequested;

  /// Invoked when a consumer resumes this handle. Null for local streams.
  void Function()? onResumeRequested;

  /// Invoked when this handle is cancelled, so an owner can drop it from its
  /// live-subscriber accounting. Null for purely local streams.
  void Function()? onCancelRequested;

  _FrbEventStreamSubscription(this._subscription);

  @override
  bool get isPaused => _isPaused;

  @override
  void pause([Future<void>? resumeSignal]) {
    if (_isPaused) return;
    _isPaused = true;
    onPauseRequested?.call();
    if (resumeSignal != null) {
      // The auto-resume path bypasses `resume()`, so re-sync when it fires or
      // upstream pause accounting would stay stuck at "paused".
      resumeSignal.whenComplete(() {
        if (_isPaused && !_subscription.isPaused) {
          // Already resumed by the subscription itself.
          _isPaused = false;
          onResumeRequested?.call();
        }
      });
    }
    _subscription.pause(resumeSignal);
  }

  @override
  void resume() {
    if (!_isPaused) return;
    _isPaused = false;
    onResumeRequested?.call();
    _subscription.resume();
  }

  @override
  Future<void> cancel() async {
    onCancelRequested?.call();
    await _subscription.cancel();
  }
}

/// Local, in-process [MutableEventStream] implementation.
///
/// **This class does not touch the native Rust substrate.** It allocates a Dart
/// [StreamController] and retains events pushed through [emit]. If you need an
/// event stream actually fed by the native FRB source, use
/// [FrbNativeEventStream] instead.
///
/// Lifecycle: EXPERIMENTAL (see `.project/architecture/layer-contracts.md`).
@experimental
class FrbLocalEventStream implements MutableEventStream<RuntimeEvent<String>> {
  final StreamController<RuntimeEvent<String>> _controller;
  final List<RuntimeEvent<String>> _buffer = [];
  @override
  final EventStreamBackpressurePolicy backpressurePolicy;
  bool _isClosed = false;

  FrbLocalEventStream({
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
    final handle = _FrbEventStreamSubscription<RuntimeEvent<String>>(sub);
    _liveSubscriptions.add(handle);
    _onSubscriptionCreated(handle);
    return handle;
  }

  /// Live subscription handles owned by this stream.
  ///
  /// Tracked by the base class so [close] can deterministically terminate every
  /// consumer. F7 depends on this set for reference-counted upstream pause.
  final Set<_FrbEventStreamSubscription<RuntimeEvent<String>>>
  _liveSubscriptions = {};

  /// Number of live Dart subscriptions currently held in their paused state.
  @visibleForTesting
  int get pausedSubscriptionCount =>
      _liveSubscriptions.where((h) => h.isPaused).length;

  /// Number of live Dart subscriptions on this stream.
  @visibleForTesting
  int get liveSubscriptionCount => _liveSubscriptions.length;

  /// Hook invoked for every new [subscribe] handle.
  ///
  /// Purely local streams have no upstream producer, so the default is a no-op.
  /// Subclasses in this library with an upstream source override this to wire
  /// pause/resume propagation (see [FrbNativeEventStream]).
  void _onSubscriptionCreated(
    _FrbEventStreamSubscription<RuntimeEvent<String>> handle,
  ) {}

  @override
  void emit(RuntimeEvent<String> event) {
    if (_isClosed) {
      throw StateError('Cannot emit event on closed FrbLocalEventStream');
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
      throw StateError('Cannot emit batch on closed FrbLocalEventStream');
    }
    for (final e in events) {
      emit(e);
    }
  }

  @override
  void replaceAll(Iterable<RuntimeEvent<String>> events) {
    if (_isClosed) {
      throw StateError('Cannot replace events on closed FrbLocalEventStream');
    }
    _buffer.clear();
    for (final e in events) {
      emit(e);
    }
  }

  @override
  void clear() {
    if (_isClosed) {
      throw StateError('Cannot clear closed FrbLocalEventStream');
    }
    _buffer.clear();
  }

  @override
  void emitError(Object error, [StackTrace? stackTrace]) {
    if (_isClosed) {
      throw StateError('Cannot emit error on closed FrbLocalEventStream');
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
    // Resume every live subscription before closing the controller.
    //
    // A broadcast controller cannot deliver `done` to a paused subscriber, so
    // `close()` would never complete while any handle stays paused and the
    // stream would hang instead of closing. Resuming first lets each consumer
    // observe the close deterministically. Paused handles flush their
    // per-subscription backlog during this resume — per-subscription buffering
    // is the only place a paused consumer's events are held (F7).
    for (final handle in List.of(_liveSubscriptions)) {
      if (handle.isPaused) handle.resume();
    }
    _liveSubscriptions.clear();
    if (!_controller.isClosed) {
      await _controller.close();
    }
  }
}

/// FRB native-backed [MutableEventStream] implementation.
///
/// Unlike [FrbLocalEventStream], this class **does** reach the native substrate
/// on the default construction path: the constructor immediately subscribes to
/// `frb_api.streamEvents(...)` and forwards every native event through [emit].
///
/// ## Backpressure (WP-018)
///
/// Native events are funnelled through [FrbLocalEventStream.emit], so the
/// configured [backpressurePolicy] is applied to the retained buffer and to
/// delivery for **every** native event — this is not a separate ungoverned
/// path.
///
/// **Documented limit**: the Rust producer (`stream_events`) runs on its own
/// thread and pushes into a `StreamSink`; pausing the Dart side cannot
/// retroactively stop events already in flight, and the buffer policy remains
/// the authoritative bound on retained state. The policy — not the transport —
/// is what guarantees bounded memory. A paused consumer is absorbed by
/// **per-subscription buffering** in the underlying broadcast subscription, not
/// by any new unbounded shared queue.
///
/// ## Multi-subscriber pause semantics (F7)
///
/// **Model: (b) — the shared upstream pauses only when ALL live subscribers are
/// paused, with reference-counted lifecycle.**
///
/// Chosen over (a) "pause is local-only" because (a) would throw away the
/// producer flow-control that WP-018 deliberately added: a fully idle stream
/// would keep a native thread hot and keep draining the pipe. Chosen because
/// forwarding any single subscriber's pause directly to the one shared native
/// subscription is what caused the F7 starvation: subscriber A pausing would
/// pause the producer and starve B, which never paused — and B's later resume
/// would release a source A still believed paused.
///
/// The rules, all reference-counted over live subscriptions:
///
/// 1. [EventStreamSubscription.pause] / [resume] are **local to that handle**.
///    A paused subscriber stops receiving immediately, exactly as a broadcast
///    subscription must.
/// 2. The shared native producer is paused **only when every live subscriber is
///    paused** ([pausedSubscriptionCount] == [liveSubscriptionCount] > 0).
/// 3. Any single resume re-opens the upstream, because the remaining paused
///    subscribers are buffered **per subscription** and still receive their
///    backlog in order on resume.
/// 4. Cancelling a handle removes it from the count; it never pauses, resumes,
///    or otherwise disturbs the producer for the others.
/// 5. With zero live subscribers the upstream is left running and is cancelled
///    deterministically by [close].
///
/// Lifecycle: EXPERIMENTAL (see `.project/architecture/layer-contracts.md`).
@experimental
class FrbNativeEventStream extends FrbLocalEventStream {
  /// The retained subscription to the native FRB stream.
  ///
  /// WP-012: the previous implementation returned this subscription to the
  /// caller and retained nothing, so [close] could not cancel it and the native
  /// producer kept running after the Dart stream was closed.
  StreamSubscription<frb_api.FrbEvent>? _nativeSubscription;

  /// Incremented every time [close] actually cancels the native subscription.
  int _nativeSubscriptionCancellations = 0;

  /// True when this stream has already closed upstream, so late resume/pause
  /// bookkeeping cannot restart the native producer.
  bool _upstreamClosed = false;

  /// How many times the native subscription was genuinely cancelled by [close].
  ///
  /// Lifecycle observability for WP-012: this distinguishes "the native producer
  /// was actually stopped" from "Dart merely stopped listening". A count of `0`
  /// after a `close()` means the native producer was left running.
  int get nativeSubscriptionCancellations => _nativeSubscriptionCancellations;

  /// Creates a stream already fed by the native substrate.
  FrbNativeEventStream({
    super.backpressurePolicy,
    int nativeEventCount = 8,
    String nativeEventPrefix = 'native',
  }) {
    _nativeSubscription =
        frb_api
            .streamEvents(count: nativeEventCount, prefix: nativeEventPrefix)
            .listen(
              (nativeEvt) {
                if (isClosed) return;
                emit(_convertFromNative(nativeEvt));
              },
              onError: (Object error, StackTrace stackTrace) {
                if (isClosed) return;
                emitError(error, stackTrace);
              },
            );
  }

  /// Whether the native source subscription is still active.
  bool get hasActiveNativeSubscription => _nativeSubscription != null;

  @override
  void _onSubscriptionCreated(
    _FrbEventStreamSubscription<RuntimeEvent<String>> handle,
  ) {
    // F7: pause/resume are LOCAL to this handle. They are never forwarded
    // straight to the shared native subscription — that starved every other
    // subscriber. Upstream is paused only when ALL live subscribers are paused.
    handle.onPauseRequested = () => _syncUpstreamPauseState();
    handle.onResumeRequested = () => _syncUpstreamPauseState();
    handle.onCancelRequested = () {
      // Dropping the handle first means a cancel cannot resurrect upstream
      // pause accounting, and a cancel never disturbs other subscribers.
      _liveSubscriptions.remove(handle);
      _syncUpstreamPauseState();
    };

    // A subscription created while every other subscriber is paused inherits a
    // paused upstream; it must not silently resume it.
    _syncUpstreamPauseState();
  }

  /// Whether the shared native producer is currently paused.
  ///
  /// True only when every live subscriber is paused. Exposed so the F7
  /// reference-counting contract is externally observable.
  @visibleForTesting
  bool get isUpstreamPaused {
    final sub = _nativeSubscription;
    return sub != null && sub.isPaused;
  }

  /// Applies the F7 rule: pause the shared upstream only when there is at least
  /// one live subscriber and *all* of them are paused; otherwise ensure it is
  /// running.
  ///
  /// With zero live subscribers the upstream is left running and will be
  /// cancelled by [close] — it is deliberately not paused, because pausing a
  /// producer nobody listens to would retain a native thread for no consumer.
  void _syncUpstreamPauseState() {
    if (_upstreamClosed) return;
    final sub = _nativeSubscription;
    if (sub == null) return;

    final shouldPause =
        _liveSubscriptions.isNotEmpty &&
        _liveSubscriptions.every((h) => h.isPaused);

    if (shouldPause && !sub.isPaused) {
      sub.pause();
    } else if (!shouldPause && sub.isPaused) {
      sub.resume();
    }
  }

  @override
  Future<void> close() async {
    // Cancel the native producer FIRST so no further events are emitted into a
    // controller that is about to close, then close the Dart side.
    _upstreamClosed = true;
    final sub = _nativeSubscription;
    _nativeSubscription = null;
    if (sub != null) {
      if (sub.isPaused) sub.resume();
      await sub.cancel();
      _nativeSubscriptionCancellations++;
    }
    await super.close();
  }
}

/// Compatibility alias retained for existing call sites.
///
/// This class is **identical to [FrbLocalEventStream]** and, like it, never
/// touches the native substrate. It previously carried the docstring "FRB
/// native-backed implementation", which was false for its only construction
/// path — see WP-003. Use [FrbLocalEventStream] for a local stream and
/// [FrbNativeEventStream] for a genuinely native-backed one.
///
/// Lifecycle: EXPERIMENTAL (see `.project/architecture/layer-contracts.md`).
@Deprecated(
  'FrbEventStream never touched the native substrate. '
  'Use FrbLocalEventStream for a local stream, '
  'or FrbNativeEventStream for a native-backed one.',
)
@experimental
class FrbEventStream extends FrbLocalEventStream {
  FrbEventStream({
    super.backpressurePolicy,
  });
}
