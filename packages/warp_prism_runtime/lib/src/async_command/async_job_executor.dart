import 'package:meta/meta.dart';

import 'async_command_contract.dart';
import 'async_command_models.dart';

/// Factory producing one [AsyncCommand] instance per execution.
///
/// The executor calls the factory once per [AsyncJobExecutor.submit], so each
/// concurrent execution owns a dedicated command instance and never disturbs
/// the single-flight state of a sibling execution.
///
/// Lifecycle: EXPERIMENTAL (see `.project/architecture/layer-contracts.md`).
@experimental
typedef AsyncCommandFactory<TParam, TResult> =
    AsyncCommand<TParam, TResult> Function();

/// Per-execution handle returned by [AsyncJobExecutor.submit].
///
/// Carries the stable per-execution identity ([executionId]) plus the live
/// terminal result and cooperative cancellation for exactly one execution.
/// Handles are independent: cancelling or awaiting one handle never observes
/// or mutates another execution.
///
/// Lifecycle: EXPERIMENTAL (see `.project/architecture/layer-contracts.md`).
@experimental
class JobExecutionHandle<TResult> {
  /// Internal cancellation signal owned by this execution.
  final CancellationToken _token;

  /// Terminal result future for this execution.
  final Future<CommandResult<TResult>> _result;

  /// Stable per-execution identity, unique within the owning executor.
  ///
  /// Monotonic (`job-1`, `job-2`, ...) so concurrent executions always carry
  /// distinct identity even when their params, timing, and outcomes match.
  final String executionId;

  /// Whether this execution has reached a terminal result.
  bool _isCompleted = false;

  /// Creates a [JobExecutionHandle] for [executionId].
  ///
  /// Created by [AsyncJobExecutor.submit]; do not construct directly.
  JobExecutionHandle({
    required this.executionId,
    required this._token,
    required this._result,
  }) {
    _result.then((_) {
      _isCompleted = true;
    });
  }

  /// Terminal result of this execution.
  ///
  /// Resolves to [CommandSuccess], [CommandFailure], or [CommandCancelled].
  /// A cancelled execution reports [CommandCancelled.reason] as its
  /// cancellation disclosure; a refused execution reports the refusal text in
  /// [CommandFailure.error] — see `describePathRefusal` for the verbatim
  /// refusal contract.
  Future<CommandResult<TResult>> get result => _result;

  /// Whether this execution has reached a terminal result.
  bool get isCompleted => _isCompleted;

  /// Whether cancellation has been requested for this execution.
  bool get isCancellationRequested => _token.isCancelled;

  /// Requests cooperative cancellation of this execution only.
  ///
  /// Sibling executions submitted through the same executor are unaffected.
  void cancel([String? reason]) => _token.cancel(reason);
}

/// Concurrent-job execution concept over existing [AsyncCommand] contracts.
///
/// A single [AsyncCommand] instance is single-flight, cancel-and-replace: one
/// logical command, one authoritative execution (see [AsyncCommand]). Genuine
/// concurrent-job workloads — generation queues, export renders — need the
/// opposite: many simultaneous executions, each with its own identity, state,
/// and cancellation. [AsyncJobExecutor] is that concept. It mints one
/// [AsyncCommand] instance per [submit] via [commandFactory], so every
/// execution runs in isolation and the single-flight contract is never
/// weakened.
///
/// Per-execution identity: each [submit] returns a [JobExecutionHandle] with a
/// monotonic [JobExecutionHandle.executionId] unique within this executor.
/// Concurrent executions with identical params still carry distinct identity.
///
/// Cancellation/refusal disclosure: [JobExecutionHandle.cancel] signals only
/// its own execution; the terminal [CommandCancelled.reason] preserves the
/// caller-visible disclosure. Refusals surface as [CommandFailure] whose
/// message carries the verbatim `path refused [` contract — resolved with
/// `describePathRefusal`, never by guessing message text.
///
/// **PURGE LAW**: This concept contains strictly zero re-invocation loops,
/// delay loops, auto-invocation timers, or progress UI logic.
///
/// Lifecycle: EXPERIMENTAL (see `.project/architecture/layer-contracts.md`).
@experimental
class AsyncJobExecutor<TParam, TResult> {
  /// Factory minting one command instance per execution.
  final AsyncCommandFactory<TParam, TResult> commandFactory;

  /// Monotonic per-execution identity counter.
  int _sequence = 0;

  /// Handles for executions that have not reached a terminal result.
  final Map<String, JobExecutionHandle<TResult>> _active = {};

  /// Whether this executor has been closed.
  bool _isClosed = false;

  /// Creates an [AsyncJobExecutor] over [commandFactory].
  AsyncJobExecutor({required this.commandFactory});

  /// Whether this executor has been closed.
  bool get isClosed => _isClosed;

  /// Number of executions that have not reached a terminal result.
  int get activeCount => _active.length;

  /// Execution ids that have not reached a terminal result, in submit order.
  List<String> get activeExecutionIds => List.unmodifiable(_active.keys);

  /// Submits [param] as a new concurrent execution with fresh identity.
  ///
  /// Each call mints a new [JobExecutionHandle.executionId] and a dedicated
  /// command instance, so overlapping executions never cancel or overwrite
  /// each other — unlike [AsyncCommand.execute], which cancels-and-replaces.
  /// Throws [StateError] when this executor [isClosed].
  JobExecutionHandle<TResult> submit(
    TParam param, {
    CancellationToken? cancellationToken,
  }) {
    if (_isClosed) {
      throw StateError('Cannot submit to a closed AsyncJobExecutor.');
    }
    final token = cancellationToken ?? CancellationToken();
    final executionId = 'job-${++_sequence}';
    final command = commandFactory();
    final handle = JobExecutionHandle<TResult>(
      executionId: executionId,
      token: token,
      result: command.execute(param, cancellationToken: token),
    );
    _active[executionId] = handle;
    handle.result.then((_) {
      _active.remove(executionId);
    });
    return handle;
  }

  /// Requests cancellation of every active execution.
  ///
  /// Each execution keeps its own disclosure: its terminal
  /// [CommandCancelled.reason] carries [reason].
  Future<void> cancelAll([String? reason]) async {
    final handles = List<JobExecutionHandle<TResult>>.from(_active.values);
    for (final handle in handles) {
      handle.cancel(reason);
    }
    await Future.wait(handles.map((handle) => handle.result));
  }

  /// Cancels active executions and releases executor bookkeeping.
  ///
  /// Idempotent. Underlying per-execution command instances are owned by the
  /// factory caller; closing the executor does not close them.
  Future<void> close() async {
    if (_isClosed) return;
    _isClosed = true;
    await cancelAll('Executor closed');
    _active.clear();
  }
}
