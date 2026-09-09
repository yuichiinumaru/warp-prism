import 'dart:async';
import 'package:meta/meta.dart';
import 'async_command_models.dart';

/// Backend-agnostic asynchronous command execution contract.
///
/// Unifies asynchronous request/response and RPC execution lifecycle
/// (`idle` -> `running` -> `succeeded` / `failed` / `cancelled`), supporting
/// typed parameter input, structured results, sealed error hierarchies, and
/// cooperative cancellation.
///
/// **PURGE LAW**: This contract contains strictly zero re-invocation loops,
/// exponential delay loops, auto-invocation timers, or progress UI logic.
///
/// Lifecycle: EXPERIMENTAL (see `docs/architecture/layer-contracts-v2.md`).
@experimental
abstract interface class AsyncCommand<TParam, TResult> {
  /// Current lifecycle execution status.
  AsyncCommandStatus get status;

  /// Executes this command with input [param] and optional cooperative [cancellationToken].
  Future<CommandResult<TResult>> execute(
    TParam param, {
    CancellationToken? cancellationToken,
  });

  /// Reactive stream emitting status updates across lifecycle transitions.
  Stream<AsyncCommandStatus> watchStatus();

  /// Whether this command instance has been closed.
  bool get isClosed;

  /// Closes this command instance and terminates active status watchers.
  Future<void> close();
}
