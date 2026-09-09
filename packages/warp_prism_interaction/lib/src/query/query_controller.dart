import 'query_intent.dart';
import 'query_result_reference.dart';
import 'query_state.dart';

/// Callback signature for query state changes.
///
/// Lifecycle: PROVEN (see `docs/architecture/layer-contracts-v2.md`).
typedef QueryListener<T extends Object> = void Function(QueryState<T> state);

/// Observable controller for executing and tracking query interaction lifecycles.
///
/// Ensures state transition safety, supports cancellation, and ignores
/// out-of-order completions via correlation tokens.
///
/// Lifecycle: PROVEN (see `docs/architecture/layer-contracts-v2.md`).
class QueryController<T extends Object> {
  QueryState<T> _state = const QueryState.idle();
  final List<QueryListener<T>> _listeners = [];
  bool _isDisposed = false;
  int _executionSequence = 0;

  /// Creates a [QueryController] with an initial state.
  QueryController({QueryState<T>? initialState})
    : _state = initialState ?? const QueryState.idle();

  /// Current immutable query state.
  QueryState<T> get state => _state;

  /// True if query is actively running.
  bool get isRunning => _state.isRunning;

  /// True if this controller has been disposed.
  bool get isDisposed => _isDisposed;

  /// Adds a listener callback for state changes.
  void addListener(QueryListener<T> listener) {
    if (_isDisposed) return;
    _listeners.add(listener);
  }

  /// Removes a listener callback.
  void removeListener(QueryListener<T> listener) {
    _listeners.remove(listener);
  }

  void _notify() {
    final listenersCopy = List<QueryListener<T>>.from(_listeners);
    for (final listener in listenersCopy) {
      listener(_state);
    }
  }

  /// Submits and starts execution of [intent].
  ///
  /// Increments the internal execution sequence to guard against stale results.
  void submit(QueryIntent intent) {
    if (_isDisposed) {
      throw StateError('Cannot submit query after disposal');
    }
    queryTransitionTable.validateTransition(_state.status, QueryTrigger.submit);

    _executionSequence++;
    _state = QueryState.running(intent);
    _notify();
  }

  /// Marks the current query complete with [result].
  ///
  /// If [queryToken] is supplied, it is validated against the active intent;
  /// mismatched tokens from stale executions are safely discarded without state change.
  bool complete(
    QueryResultReference<T> result, {
    String? queryToken,
    int? executionSequence,
  }) {
    if (_isDisposed) {
      throw StateError('Cannot complete query after disposal');
    }
    if (_state.status != QueryStatus.running) {
      // Cannot complete a non-running query
      queryTransitionTable.validateTransition(
        _state.status,
        QueryTrigger.complete,
      );
    }

    final activeIntent = _state.intent;
    if (activeIntent == null) {
      throw StateError('Cannot complete query: no active intent found');
    }

    if (queryToken != null && activeIntent.queryToken != null) {
      if (queryToken != activeIntent.queryToken) {
        // Out-of-order stale result: ignore
        return false;
      }
    }

    if (executionSequence != null && executionSequence != _executionSequence) {
      // Out-of-order sequence: ignore
      return false;
    }

    queryTransitionTable.validateTransition(
      _state.status,
      QueryTrigger.complete,
    );

    _state = QueryState.complete(intent: activeIntent, result: result);
    _notify();
    return true;
  }

  /// Marks the current query failed with [error] and optional [stackTrace].
  ///
  /// If [queryToken] is supplied, it is validated against the active intent;
  /// mismatched tokens from stale executions are safely discarded.
  bool fail(
    Object error, [
    StackTrace? stackTrace,
    String? queryToken,
    int? executionSequence,
  ]) {
    if (_isDisposed) {
      throw StateError('Cannot fail query after disposal');
    }
    if (_state.status != QueryStatus.running) {
      queryTransitionTable.validateTransition(_state.status, QueryTrigger.fail);
    }

    final activeIntent = _state.intent;
    if (activeIntent == null) {
      throw StateError('Cannot fail query: no active intent found');
    }

    if (queryToken != null && activeIntent.queryToken != null) {
      if (queryToken != activeIntent.queryToken) {
        return false;
      }
    }

    if (executionSequence != null && executionSequence != _executionSequence) {
      return false;
    }

    queryTransitionTable.validateTransition(_state.status, QueryTrigger.fail);

    _state = QueryState.error(
      intent: activeIntent,
      error: error,
      stackTrace: stackTrace,
    );
    _notify();
    return true;
  }

  /// Cancels the currently running query.
  void cancel([String? queryToken]) {
    if (_isDisposed) {
      throw StateError('Cannot cancel query after disposal');
    }
    if (_state.status != QueryStatus.running) {
      // If not running, cancel is either illegal or a no-op if validated
      queryTransitionTable.validateTransition(
        _state.status,
        QueryTrigger.cancel,
      );
    }

    final activeIntent = _state.intent;
    if (activeIntent == null) {
      throw StateError('Cannot cancel query: no active intent found');
    }

    if (queryToken != null && activeIntent.queryToken != null) {
      if (queryToken != activeIntent.queryToken) {
        return;
      }
    }

    queryTransitionTable.validateTransition(_state.status, QueryTrigger.cancel);

    _state = QueryState.cancelled(intent: activeIntent);
    _notify();
  }

  /// Resets the query back to idle state.
  void reset() {
    if (_isDisposed) {
      throw StateError('Cannot reset query after disposal');
    }
    if (_state.status == QueryStatus.idle) {
      return;
    }
    queryTransitionTable.validateTransition(_state.status, QueryTrigger.reset);
    _state = const QueryState.idle();
    _notify();
  }

  /// Disposes this controller and clears all listeners.
  void dispose() {
    _isDisposed = true;
    _listeners.clear();
  }
}
