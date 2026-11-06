import 'query_intent.dart';
import 'query_result_reference.dart';
import 'query_state.dart';

/// Callback signature for query state changes.
///
/// Lifecycle: PROVEN (see `.project/architecture/layer-contracts.md`).
typedef QueryListener<T extends Object> = void Function(QueryState<T> state);

/// Opaque, controller-issued identity for a single query execution.
///
/// Issued by [QueryController.submit] and required to commit an outcome through
/// [QueryController.completeExecution] or [QueryController.failExecution].
///
/// **Why this exists (F6):** stale-result protection used to depend on the
/// caller *choosing* to pass a `queryToken` or `executionSequence`. Both were
/// nullable, and `submit()` returned `void`, so a caller had no way to learn the
/// authoritative sequence and could silently omit correlation — letting a late
/// result from execution A commit into execution B. Correlation is now
/// structural: the handle is unforgeable-by-accident (no public constructor)
/// and validated by identity inside the controller, so protection cannot be
/// bypassed by forgetting an argument.
///
/// The identity is [QueryIntent]-independent: two submissions of identical
/// intent text (even with identical `queryToken`) still receive distinct
/// handles, because each [QueryController.submit] allocates a new one.
///
/// Lifecycle: PROVEN (see `.project/architecture/layer-contracts.md`).
class QueryExecution<T extends Object> {
  final int _sequence;

  /// Monotonic per-controller counter. Private so no external code can fabricate
  /// a handle that compares equal to a live execution.
  const QueryExecution._(this._sequence);

  /// The controller-assigned execution sequence number.
  ///
  /// Exposed read-only for logging and diagnostics. It is **not** accepted as
  /// correlation by [QueryController.completeExecution]; only handle identity is.
  int get sequence => _sequence;

  @override
  String toString() => 'QueryExecution(sequence: $_sequence)';
}

/// Observable controller for executing and tracking query interaction lifecycles.
///
/// Ensures state transition safety, supports cancellation, and **structurally**
/// rejects out-of-order completions.
///
/// ## Stale-result protection (F6)
///
/// Protection is no longer opt-in. [submit] returns an opaque [QueryExecution]
/// handle, and [completeExecution] / [failExecution] accept nothing else — there
/// is no parameter a caller can forget. A handle that is not the currently
/// active execution is rejected and returns `false` without touching state, so a
/// late result or a late error from a superseded execution cannot commit into,
/// or poison, a newer one.
///
/// ### Legacy correlation API
///
/// [complete] and [fail] are retained for source compatibility, but an
/// **uncorrelated** call — one supplying neither a matching `queryToken` nor a
/// matching `executionSequence` — is now **rejected** rather than accepted. That
/// is a deliberate behaviour change: previously such a call committed
/// unconditionally. Use [completeExecution] / [failExecution] instead.
///
/// Lifecycle: PROVEN (see `.project/architecture/layer-contracts.md`).
class QueryController<T extends Object> {
  QueryState<T> _state = const QueryState.idle();
  final List<QueryListener<T>> _listeners = [];
  bool _isDisposed = false;
  int _executionSequence = 0;

  /// The handle for the most recent [submit], or `null` when nothing has been
  /// submitted. Only this handle may commit an outcome.
  QueryExecution<T>? _activeExecution;

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

  /// Submits and starts execution of [intent], returning its opaque handle.
  ///
  /// The returned [QueryExecution] is the **only** accepted correlation for
  /// [completeExecution] and [failExecution]. Each call allocates a fresh
  /// handle, so re-submitting the same [QueryIntent] — including one with an
  /// identical `queryToken` — yields a distinct execution identity.
  QueryExecution<T> submit(QueryIntent intent) {
    if (_isDisposed) {
      throw StateError('Cannot submit query after disposal');
    }
    queryTransitionTable.validateTransition(_state.status, QueryTrigger.submit);

    _executionSequence++;
    final execution = QueryExecution<T>._(_executionSequence);
    _activeExecution = execution;
    _state = QueryState.running(intent);
    _notify();
    return execution;
  }

  /// The handle for the most recent [submit], or `null` if none is active.
  ///
  /// Read-only. Callers cannot construct a handle, so this cannot be used to
  /// forge correlation.
  QueryExecution<T>? get activeExecution => _activeExecution;

  /// True when [execution] is the currently active execution.
  bool isCurrentExecution(QueryExecution<T> execution) =>
      identical(execution, _activeExecution);

  /// Commits [result] for [execution].
  ///
  /// Returns `false` and leaves state untouched when [execution] is not the
  /// active execution — the stale-result case. Returns `true` when the result
  /// was committed.
  ///
  /// Throws [StateError] after disposal, or when the current state does not
  /// permit the `complete` transition.
  bool completeExecution(
    QueryExecution<T> execution,
    QueryResultReference<T> result,
  ) {
    if (_isDisposed) {
      throw StateError('Cannot complete query after disposal');
    }
    if (!identical(execution, _activeExecution)) {
      // Stale execution: ignore without touching state.
      return false;
    }

    final activeIntent = _state.intent;
    if (activeIntent == null) {
      throw StateError('Cannot complete query: no active intent found');
    }

    queryTransitionTable.validateTransition(
      _state.status,
      QueryTrigger.complete,
    );

    _state = QueryState.complete(intent: activeIntent, result: result);
    _notify();
    return true;
  }

  /// Marks the execution identified by [execution] as failed with [error].
  ///
  /// Returns `false` and leaves state untouched when [execution] is stale, so a
  /// late error cannot poison a newer running execution.
  bool failExecution(
    QueryExecution<T> execution,
    Object error, [
    StackTrace? stackTrace,
  ]) {
    if (_isDisposed) {
      throw StateError('Cannot fail query after disposal');
    }
    if (!identical(execution, _activeExecution)) {
      // Stale execution: a late error must not poison the newer execution.
      return false;
    }

    final activeIntent = _state.intent;
    if (activeIntent == null) {
      throw StateError('Cannot fail query: no active intent found');
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

  /// Cancels the execution identified by [execution].
  ///
  /// Returns `false` when [execution] is stale, so cancelling a superseded
  /// execution cannot cancel a newer one.
  bool cancelExecution(QueryExecution<T> execution) {
    if (_isDisposed) {
      throw StateError('Cannot cancel query after disposal');
    }
    if (!identical(execution, _activeExecution)) {
      return false;
    }
    return _cancelActive();
  }

  /// Marks the current query complete with [result].
  ///
  /// **Prefer [completeExecution].** This legacy entry point validates
  /// correlation only from caller-supplied [queryToken] / [executionSequence].
  /// A call that supplies neither is now **rejected** (`false`) instead of
  /// committing unconditionally, because an uncorrelated commit is exactly the
  /// stale-result hole F6 describes. Correlation can no longer be omitted by
  /// accident and still succeed.
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

    // F6: no correlation was supplied at all. Previously this fell through and
    // committed unconditionally, which let a late result from a superseded
    // execution overwrite the active one. Reject instead.
    if (queryToken == null && executionSequence == null) {
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
  /// **Prefer [failExecution].** Like [complete], an uncorrelated call is now
  /// rejected rather than accepted.
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

    // F6: uncorrelated failure is rejected, so a late error cannot poison the
    // active execution.
    if (queryToken == null && executionSequence == null) {
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

  /// Records a planned query as never submitted (Task 1869, EXPERIMENTAL).
  ///
  /// Only valid from idle. Creates no execution handle: there is nothing to
  /// correlate because nothing ran. The resulting [QueryStatus.notAttempted]
  /// state is indeterminate and fail-closed.
  void skip(QueryIntent intent) {
    if (_isDisposed) {
      throw StateError('Cannot skip query after disposal');
    }
    queryTransitionTable.validateTransition(_state.status, QueryTrigger.skip);
    _state = QueryState.notAttempted(intent: intent);
    _activeExecution = null;
    _notify();
  }

  /// Declines the execution identified by [execution] with an optional
  /// [reason] (Task 1869, EXPERIMENTAL).
  ///
  /// Returns `false` and leaves state untouched when [execution] is stale.
  /// The resulting [QueryStatus.abstained] state carries the reason, never
  /// a result, and never counts as success.
  bool abstainExecution(QueryExecution<T> execution, {String? reason}) {
    if (_isDisposed) {
      throw StateError('Cannot abstain query after disposal');
    }
    if (!identical(execution, _activeExecution)) {
      // Stale execution: a late decline must not rewrite the newer one.
      return false;
    }

    final activeIntent = _state.intent;
    if (activeIntent == null) {
      throw StateError('Cannot abstain query: no active intent found');
    }

    queryTransitionTable.validateTransition(
      _state.status,
      QueryTrigger.abstain,
    );

    _state = QueryState.abstained(intent: activeIntent, reason: reason);
    _notify();
    return true;
  }

  /// Marks the execution identified by [execution] as indeterminable with
  /// an optional [detail] note (Task 1869, EXPERIMENTAL).
  ///
  /// Returns `false` and leaves state untouched when [execution] is stale.
  /// The resulting [QueryStatus.unknown] state never counts as success,
  /// verified, or enabled.
  bool markUnknownExecution(QueryExecution<T> execution, {String? detail}) {
    if (_isDisposed) {
      throw StateError('Cannot mark query unknown after disposal');
    }
    if (!identical(execution, _activeExecution)) {
      // Stale execution: a late unknown must not rewrite the newer one.
      return false;
    }

    final activeIntent = _state.intent;
    if (activeIntent == null) {
      throw StateError('Cannot mark query unknown: no active intent found');
    }

    queryTransitionTable.validateTransition(
      _state.status,
      QueryTrigger.markUnknown,
    );

    _state = QueryState.unknown(intent: activeIntent, detail: detail);
    _notify();
    return true;
  }

  /// Marks the current query abstained with an optional [reason].
  ///
  /// **Prefer [abstainExecution].** Like [complete] and [fail], an
  /// uncorrelated call is **rejected** (`false`) instead of committing.
  bool abstain([String? queryToken, int? executionSequence, String? reason]) {
    if (_isDisposed) {
      throw StateError('Cannot abstain query after disposal');
    }
    if (_state.status != QueryStatus.running) {
      queryTransitionTable.validateTransition(
        _state.status,
        QueryTrigger.abstain,
      );
    }

    final activeIntent = _state.intent;
    if (activeIntent == null) {
      throw StateError('Cannot abstain query: no active intent found');
    }

    if (queryToken != null && activeIntent.queryToken != null) {
      if (queryToken != activeIntent.queryToken) {
        return false;
      }
    }

    if (executionSequence != null && executionSequence != _executionSequence) {
      return false;
    }

    // F6 parity: uncorrelated abstention is rejected, so a late decline
    // cannot rewrite the active execution.
    if (queryToken == null && executionSequence == null) {
      return false;
    }

    queryTransitionTable.validateTransition(
      _state.status,
      QueryTrigger.abstain,
    );

    _state = QueryState.abstained(intent: activeIntent, reason: reason);
    _notify();
    return true;
  }

  /// Marks the current query outcome as indeterminable with an optional
  /// [detail] note.
  ///
  /// **Prefer [markUnknownExecution].** Like [complete] and [fail], an
  /// uncorrelated call is **rejected** (`false`) instead of committing.
  bool markUnknown([
    String? queryToken,
    int? executionSequence,
    String? detail,
  ]) {
    if (_isDisposed) {
      throw StateError('Cannot mark query unknown after disposal');
    }
    if (_state.status != QueryStatus.running) {
      queryTransitionTable.validateTransition(
        _state.status,
        QueryTrigger.markUnknown,
      );
    }

    final activeIntent = _state.intent;
    if (activeIntent == null) {
      throw StateError('Cannot mark query unknown: no active intent found');
    }

    if (queryToken != null && activeIntent.queryToken != null) {
      if (queryToken != activeIntent.queryToken) {
        return false;
      }
    }

    if (executionSequence != null && executionSequence != _executionSequence) {
      return false;
    }

    // F6 parity: uncorrelated unknown is rejected, so a late
    // indeterminacy cannot rewrite the active execution.
    if (queryToken == null && executionSequence == null) {
      return false;
    }

    queryTransitionTable.validateTransition(
      _state.status,
      QueryTrigger.markUnknown,
    );

    _state = QueryState.unknown(intent: activeIntent, detail: detail);
    _notify();
    return true;
  }

  /// Cancels the currently running query.
  void cancel([String? queryToken]) {
    if (_isDisposed) {
      throw StateError('Cannot cancel query after disposal');
    }
    _cancelActive(queryToken: queryToken);
  }

  /// Shared cancellation transition used by [cancelExecution] and [cancel].
  bool _cancelActive({String? queryToken}) {
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
        return false;
      }
    }

    queryTransitionTable.validateTransition(_state.status, QueryTrigger.cancel);

    _state = QueryState.cancelled(intent: activeIntent);
    _notify();
    return true;
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
    // No execution may commit after a reset: a late result for the pre-reset
    // execution must not resurrect a completed query.
    _activeExecution = null;
    _notify();
  }

  /// Disposes this controller and clears all listeners.
  void dispose() {
    _isDisposed = true;
    _listeners.clear();
  }
}
