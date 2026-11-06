import 'package:meta/meta.dart';
import '../state_machine/interaction_state.dart';
import 'query_intent.dart';
import 'query_result_reference.dart';

/// Execution phases of a query interaction lifecycle.
///
/// Lifecycle: PROVEN (see `.project/architecture/layer-contracts.md`).
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

  /// Query outcome cannot yet be determined (Task 1869, EXPERIMENTAL).
  ///
  /// Fail-closed: never counts as success, verified, or enabled.
  unknown,

  /// Query was deliberately declined instead of executed (Task 1869,
  /// EXPERIMENTAL). Carries a reason, never a result.
  abstained,

  /// Query was planned but never submitted (Task 1869, EXPERIMENTAL).
  notAttempted,
}

/// Triggers that transition a query between execution states.
///
/// Lifecycle: PROVEN (see `.project/architecture/layer-contracts.md`).
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

  /// Record a planned query as never submitted (Task 1869, EXPERIMENTAL).
  skip,

  /// Deliberately decline the running query with a reason (Task 1869,
  /// EXPERIMENTAL). Never produces a result.
  abstain,

  /// Mark the running query outcome as indeterminable (Task 1869,
  /// EXPERIMENTAL). Never counts as success or verified.
  markUnknown,
}

/// Canonical transition table for query lifecycles.
///
/// Lifecycle: PROVEN (see `.project/architecture/layer-contracts.md`).
const queryTransitionTable =
    InteractionTransitionTable<QueryStatus, QueryTrigger>(
      allowedTriggers: {
        QueryStatus.idle: {QueryTrigger.submit, QueryTrigger.skip},
        QueryStatus.running: {
          QueryTrigger.complete,
          QueryTrigger.fail,
          QueryTrigger.cancel,
          QueryTrigger.submit,
          QueryTrigger.abstain,
          QueryTrigger.markUnknown,
        },
        QueryStatus.complete: {QueryTrigger.submit, QueryTrigger.reset},
        QueryStatus.error: {QueryTrigger.submit, QueryTrigger.reset},
        QueryStatus.cancelled: {QueryTrigger.submit, QueryTrigger.reset},
        // Indeterminate states hold no outcome: they may be retried or
        // cleared, never committed forward into success or failure.
        QueryStatus.unknown: {QueryTrigger.submit, QueryTrigger.reset},
        QueryStatus.abstained: {QueryTrigger.submit, QueryTrigger.reset},
        QueryStatus.notAttempted: {QueryTrigger.submit, QueryTrigger.reset},
      },
      targetStates: {
        (QueryStatus.idle, QueryTrigger.submit): QueryStatus.running,
        (QueryStatus.idle, QueryTrigger.skip): QueryStatus.notAttempted,
        (QueryStatus.running, QueryTrigger.complete): QueryStatus.complete,
        (QueryStatus.running, QueryTrigger.fail): QueryStatus.error,
        (QueryStatus.running, QueryTrigger.cancel): QueryStatus.cancelled,
        (QueryStatus.running, QueryTrigger.submit): QueryStatus.running,
        (QueryStatus.running, QueryTrigger.abstain): QueryStatus.abstained,
        (QueryStatus.running, QueryTrigger.markUnknown): QueryStatus.unknown,
        (QueryStatus.complete, QueryTrigger.submit): QueryStatus.running,
        (QueryStatus.complete, QueryTrigger.reset): QueryStatus.idle,
        (QueryStatus.error, QueryTrigger.submit): QueryStatus.running,
        (QueryStatus.error, QueryTrigger.reset): QueryStatus.idle,
        (QueryStatus.cancelled, QueryTrigger.submit): QueryStatus.running,
        (QueryStatus.cancelled, QueryTrigger.reset): QueryStatus.idle,
        (QueryStatus.unknown, QueryTrigger.submit): QueryStatus.running,
        (QueryStatus.unknown, QueryTrigger.reset): QueryStatus.idle,
        (QueryStatus.abstained, QueryTrigger.submit): QueryStatus.running,
        (QueryStatus.abstained, QueryTrigger.reset): QueryStatus.idle,
        (QueryStatus.notAttempted, QueryTrigger.submit): QueryStatus.running,
        (QueryStatus.notAttempted, QueryTrigger.reset): QueryStatus.idle,
      },
    );

/// Immutable snapshot of query execution state.
///
/// Lifecycle: PROVEN (see `.project/architecture/layer-contracts.md`).
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

  /// Why the outcome was marked indeterminable, when status is
  /// [QueryStatus.unknown]. Never a result, never proof.
  final String? detail;

  /// Why the query was declined, when status is [QueryStatus.abstained].
  /// Never a result, never proof.
  final String? reason;

  const QueryState.idle()
    : status = QueryStatus.idle,
      intent = null,
      result = null,
      error = null,
      stackTrace = null,
      detail = null,
      reason = null;

  const QueryState.running(QueryIntent this.intent)
    : status = QueryStatus.running,
      result = null,
      error = null,
      stackTrace = null,
      detail = null,
      reason = null;

  const QueryState.complete({
    required QueryIntent this.intent,
    required QueryResultReference<T> this.result,
  }) : status = QueryStatus.complete,
       error = null,
       stackTrace = null,
       detail = null,
       reason = null;

  const QueryState.error({
    required QueryIntent this.intent,
    required this.error,
    this.stackTrace,
  }) : status = QueryStatus.error,
       result = null,
       detail = null,
       reason = null;

  const QueryState.cancelled({required QueryIntent this.intent})
    : status = QueryStatus.cancelled,
      result = null,
      error = null,
      stackTrace = null,
      detail = null,
      reason = null;

  /// Indeterminate outcome: the query ran (or was observed) but its result
  /// cannot be determined. Fail-closed: never success, never verified.
  const QueryState.unknown({required QueryIntent this.intent, this.detail})
    : status = QueryStatus.unknown,
      result = null,
      error = null,
      stackTrace = null,
      reason = null;

  /// Deliberately declined query. Carries a reason, never a result.
  const QueryState.abstained({required QueryIntent this.intent, this.reason})
    : status = QueryStatus.abstained,
      result = null,
      error = null,
      stackTrace = null,
      detail = null;

  /// Planned but never submitted. Reachable via `skip` from idle.
  const QueryState.notAttempted({required QueryIntent this.intent})
    : status = QueryStatus.notAttempted,
      result = null,
      error = null,
      stackTrace = null,
      detail = null,
      reason = null;

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

  /// True if the query outcome is indeterminable (Task 1869).
  bool get isUnknown => status == QueryStatus.unknown;

  /// True if the query was deliberately declined (Task 1869).
  bool get isAbstained => status == QueryStatus.abstained;

  /// True if the query was planned but never submitted (Task 1869).
  bool get isNotAttempted => status == QueryStatus.notAttempted;

  /// True when the query withholds determination: unknown, abstained, or
  /// notAttempted (Task 1869).
  ///
  /// Fail-closed: an indeterminate state is never success ([isComplete]),
  /// never verified (no [result]), and never enabled ([isRunning]).
  bool get isIndeterminate =>
      status == QueryStatus.unknown ||
      status == QueryStatus.abstained ||
      status == QueryStatus.notAttempted;

  /// True when the query reached a terminal, reportable position:
  /// success, failure, cancellation, or a recorded abstention.
  /// [QueryStatus.unknown] and [QueryStatus.notAttempted] are not settled.
  bool get isSettled =>
      status == QueryStatus.complete ||
      status == QueryStatus.error ||
      status == QueryStatus.cancelled ||
      status == QueryStatus.abstained;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! QueryState<T>) return false;
    return other.status == status &&
        other.intent == intent &&
        other.result == result &&
        other.error == error &&
        other.detail == detail &&
        other.reason == reason;
  }

  @override
  int get hashCode =>
      Object.hash(status, intent, result, error, detail, reason);

  @override
  String toString() =>
      'QueryState<$T>(status: $status, intent: $intent, result: $result, error: $error)';
}
