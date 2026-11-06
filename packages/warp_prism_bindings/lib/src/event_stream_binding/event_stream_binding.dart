import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';
import 'package:warp_prism_runtime/warp_prism_runtime.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

import 'event_stream_view_model.dart';

/// Projection binding connecting a runtime [EventStream] to reactive UI view models.
///
/// Manages:
/// - Subscription lifecycle and deterministic resource cleanup on [dispose].
/// - Retained event buffer synchronization with optional bounded capacity.
/// - Pause, resume, and clear controls.
/// - Error and completion propagation.
/// - Projection helpers for [PrismExecutionConsole] ([PrismExecutionLine]) and
///   [PrismLogViewer] ([PrismLogEntry]).
///
/// **PURGE LAW**: This binding contains strictly zero widget rendering,
/// layout offsets, or auto-scrolling ticker loops.
///
/// Lifecycle: EXPERIMENTAL (see `.project/architecture/layer-contracts.md`).
@experimental
class EventStreamBinding<T> extends ChangeNotifier {
  /// The underlying runtime event stream source.
  final EventStream<T> source;

  /// Optional maximum number of events retained in the local buffer.
  final int? maxRetainedEvents;

  /// Deterministic epoch-0 UTC fallback timestamp for non-[RuntimeEvent] log projections.
  static final DateTime deterministicFallbackTimestamp =
      DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);

  EventStreamFollowState _followState;
  EventStreamSubscription<T>? _subscription;
  final List<T> _events = [];
  EventStreamBindingStatus _status = EventStreamBindingStatus.active;
  Object? _error;
  StackTrace? _stackTrace;
  bool _isDisposed = false;

  final StreamController<T> _eventStreamController =
      StreamController<T>.broadcast();
  final StreamController<List<T>> _bufferedStreamController =
      StreamController<List<T>>.broadcast();

  /// Creates an [EventStreamBinding] for the given [source].
  EventStreamBinding({
    required this.source,
    this.maxRetainedEvents,
    EventStreamFollowState initialFollowState =
        EventStreamFollowState.following,
    bool autoSubscribe = true,
  }) : _followState = initialFollowState {
    if (source.currentEvents.isNotEmpty) {
      _events.addAll(source.currentEvents);
      _enforceCapacity();
    }

    if (source.isClosed) {
      _status = EventStreamBindingStatus.completed;
    } else if (autoSubscribe) {
      _subscribe();
    }
  }

  void _subscribe() {
    _subscription = source.subscribe(
      onData: _handleData,
      onError: _handleError,
      onDone: _handleDone,
    );
  }

  void _handleData(T event) {
    if (_isDisposed) return;
    _events.add(event);
    _enforceCapacity();
    _eventStreamController.add(event);
    _bufferedStreamController.add(events);
    notifyListeners();
  }

  void _handleError(Object error, StackTrace stackTrace) {
    if (_isDisposed) return;
    _status = EventStreamBindingStatus.error;
    _error = error;
    _stackTrace = stackTrace;
    _eventStreamController.addError(error, stackTrace);
    _bufferedStreamController.addError(error, stackTrace);
    notifyListeners();
  }

  void _handleDone() {
    if (_isDisposed) return;
    _status = EventStreamBindingStatus.completed;
    notifyListeners();
  }

  void _enforceCapacity() {
    if (maxRetainedEvents != null && _events.length > maxRetainedEvents!) {
      _events.removeRange(0, _events.length - maxRetainedEvents!);
    }
  }

  /// Pauses event delivery from the source stream.
  void pause() {
    if (_isDisposed || _status != EventStreamBindingStatus.active) return;
    _subscription?.pause();
    _status = EventStreamBindingStatus.paused;
    notifyListeners();
  }

  /// Resumes event delivery from the source stream.
  void resume() {
    if (_isDisposed || _status != EventStreamBindingStatus.paused) return;
    _subscription?.resume();
    _status = EventStreamBindingStatus.active;
    notifyListeners();
  }

  /// Clears the retained events buffer.
  void clear() {
    if (_isDisposed || _events.isEmpty) return;
    _events.clear();
    _bufferedStreamController.add(const []);
    notifyListeners();
  }

  /// Immutable snapshot of retained events in order of arrival.
  List<T> get events => List.unmodifiable(_events);

  /// Current binding lifecycle status.
  EventStreamBindingStatus get status => _status;

  /// Optional presentation-side follow/scroll tracking hook for consumer widgets.
  ///
  /// **PURGE LAW**: The binding does not act on this value internally (no
  /// timers, tickers, or auto-scrolling engine). Policy stays entirely in widgets.
  /// This field exists as an advisory state hook that widgets MAY read or mutate
  /// to synchronize UI scroll status.
  EventStreamFollowState get followState => _followState;

  set followState(EventStreamFollowState value) {
    if (_followState != value) {
      _followState = value;
      notifyListeners();
    }
  }

  /// Captured error object if status is [EventStreamBindingStatus.error].
  Object? get error => _error;

  /// Captured stack trace if status is [EventStreamBindingStatus.error].
  StackTrace? get stackTrace => _stackTrace;

  /// Whether event delivery is paused.
  bool get isPaused => _status == EventStreamBindingStatus.paused;

  /// Whether the source stream has finished and closed.
  bool get isCompleted => _status == EventStreamBindingStatus.completed;

  /// Whether this binding instance has been disposed.
  bool get isDisposed => _isDisposed;

  /// Whether the retained events buffer is empty.
  bool get isEmpty => _events.isEmpty;

  /// Number of retained events in the local buffer.
  int get count => _events.length;

  /// Reactive stream of individual events emitted by the source.
  Stream<T> get eventStream => _eventStreamController.stream;

  /// Reactive stream of the updated full event buffer snapshot.
  Stream<List<T>> get bufferedStream => _bufferedStreamController.stream;

  /// Projects retained events to [PrismExecutionLine] presentation models for [PrismExecutionConsole].
  List<PrismExecutionLine> toExecutionLines({
    PrismExecutionLine Function(T event)? mapper,
  }) {
    if (mapper != null) {
      return _events.map(mapper).toList(growable: false);
    }
    return _events
        .asMap()
        .entries
        .map((entry) {
          final item = entry.value;
          if (item is RuntimeEvent<dynamic>) {
            return EventStreamMappers.runtimeEventToExecutionLine(item);
          }
          return PrismExecutionLine(
            id: 'line-${entry.key}',
            message: item.toString(),
            level: PrismExecutionLineLevel.stdout,
          );
        })
        .toList(growable: false);
  }

  /// Projects retained events to [PrismLogEntry] presentation models for [PrismLogViewer].
  ///
  /// If an event is a [RuntimeEvent], its timestamp and metadata are mapped
  /// deterministically via [EventStreamMappers.runtimeEventToLogEntry].
  ///
  /// For non-[RuntimeEvent] events lacking native timestamp metadata, a deterministic
  /// epoch-0 UTC sentinel timestamp ([deterministicFallbackTimestamp]) is used.
  List<PrismLogEntry> toLogEntries({PrismLogEntry Function(T event)? mapper}) {
    if (mapper != null) {
      return _events.map(mapper).toList(growable: false);
    }
    return _events
        .asMap()
        .entries
        .map((entry) {
          final item = entry.value;
          if (item is RuntimeEvent<dynamic>) {
            return EventStreamMappers.runtimeEventToLogEntry(item);
          }
          return PrismLogEntry(
            id: 'log-${entry.key}',
            timestamp: deterministicFallbackTimestamp,
            severity: PrismLogSeverity.info,
            source: 'binding',
            message: item.toString(),
          );
        })
        .toList(growable: false);
  }

  @override
  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;
    _status = EventStreamBindingStatus.disposed;
    _subscription?.cancel();
    _subscription = null;
    _eventStreamController.close();
    _bufferedStreamController.close();
    super.dispose();
  }
}
