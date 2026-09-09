import 'package:meta/meta.dart';
import '../state_machine/interaction_state.dart';
import 'query_intent.dart';
import 'query_result_reference.dart';

/// Execution phases of a query interaction lifecycle.
///
/// Lifecycle: PROVEN (see `docs/architecture/layer-contracts-v2.md`).
enum QueryStatus {
  /// No query is currently active or executing.
  idle,

  /// Query is actively executing asynchronously.
  running,

  /// Query completed successfully with a result set.
  complete,

  /// Query execution failed with an error.
  error,

  /// Query execution was cancelled before completion.
  cancelled,
}

/// Triggers that transition a query between execution states.
///
/// Lifecycle: PROVEN (see `docs/architecture/layer-contracts-v2.md`).
enum QueryTrigger {
  /// Submit / start executing a query.
  submit,

  /// Mark the executing query complete with results.
  complete,

  /// Mark the executing query failed with an error.
  fail,

  /// Cancel the executing query.
  cancel,

  /// Reset the query back to idle.
  reset,
}

/// Canonical transition table for query lifecycles.
///
/// Lifecycle: PROVEN (see `docs/architecture/layer-contracts-v2.md`).
const queryTransitionTable =
    InteractionTransitionTable<QueryStatus, QueryTrigger>(
      allowedTriggers: {
        QueryStatus.idle: {QueryTrigger.submit},
        QueryStatus.running: {
          QueryTrigger.complete,
          QueryTrigger.fail,
          QueryTrigger.cancel,
          QueryTrigger.submit,
        },
        QueryStatus.complete: {QueryTrigger.submit, QueryTrigger.reset},
        QueryStatus.error: {QueryTrigger.submit, QueryTrigger.reset},
        QueryStatus.cancelled: {QueryTrigger.submit, QueryTrigger.reset},
      },
      targetStates: {
        (QueryStatus.idle, QueryTrigger.submit): QueryStatus.running,
        (QueryStatus.running, QueryTrigger.complete): QueryStatus.complete,
        (QueryStatus.running, QueryTrigger.fail): QueryStatus.error,
        (QueryStatus.running, QueryTrigger.cancel): QueryStatus.cancelled,
        (QueryStatus.running, QueryTrigger.submit): QueryStatus.running,
        (QueryStatus.complete, QueryTrigger.submit): QueryStatus.running,
        (QueryStatus.complete, QueryTrigger.reset): QueryStatus.idle,
        (QueryStatus.error, QueryTrigger.submit): QueryStatus.running,
        (QueryStatus.error, QueryTrigger.reset): QueryStatus.idle,
        (QueryStatus.cancelled, QueryTrigger.submit): QueryStatus.running,
        (QueryStatus.cancelled, QueryTrigger.reset): QueryStatus.idle,
      },
    );

/// Immutable snapshot of query execution state.
///
/// Lifecycle: PROVEN (see `docs/architecture/layer-contracts-v2.md`).
@immutable
class QueryState<T extends Object> {
  /// The current execution status of the query.
  final QueryStatus status;

  /// The active query intent, if any.
  final QueryIntent? intent;

  /// The result reference when status is [QueryStatus.complete].
  final QueryResultReference<T>? result;

  /// The error payload when status is [QueryStatus.error].
  final Object? error;

  /// The stack trace associated with [error], if captured.
  final StackTrace? stackTrace;

  const QueryState.idle()
    : status = QueryStatus.idle,
      intent = null,
      result = null,
      error = null,
      stackTrace = null;

  const QueryState.running(QueryIntent this.intent)
    : status = QueryStatus.running,
      result = null,
      error = null,
      stackTrace = null;

  const QueryState.complete({
    required QueryIntent this.intent,
    required QueryResultReference<T> this.result,
  }) : status = QueryStatus.complete,
       error = null,
       stackTrace = null;

  const QueryState.error({
    required QueryIntent this.intent,
    required this.error,
    this.stackTrace,
  }) : status = QueryStatus.error,
       result = null;

  const QueryState.cancelled({required QueryIntent this.intent})
    : status = QueryStatus.cancelled,
      result = null,
      error = null,
      stackTrace = null;

  /// True if query is in idle state.
  bool get isIdle => status == QueryStatus.idle;

  /// True if query is actively executing.
  bool get isRunning => status == QueryStatus.running;

  /// True if query completed successfully.
  bool get isComplete => status == QueryStatus.complete;

  /// True if query encountered an error.
  bool get isError => status == QueryStatus.error;

  /// True if query was cancelled.
  bool get isCancelled => status == QueryStatus.cancelled;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! QueryState<T>) return false;
    return other.status == status &&
        other.intent == intent &&
        other.result == result &&
        other.error == error;
  }

  @override
  int get hashCode => Object.hash(status, intent, result, error);

  @override
  String toString() =>
      'QueryState<$T>(status: $status, intent: $intent, result: $result, error: $error)';
}
