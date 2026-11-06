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
/// ## Concurrency model: SINGLE-FLIGHT, CANCEL-AND-REPLACE (F1)
///
/// **One command instance represents one logical command, and at most one
/// execution of it is ever authoritative.** The instance exposes a single
/// [status] and a single [watchStatus] stream; that surface is only truthful
/// under single-flight. Concurrent in-flight executions would make both
/// ambiguous — there is no correct answer to "what is this command's status?"
/// when two runs disagree, and a shared stream would interleave them.
///
/// The one rule for re-entrant [execute] while an execution is active:
///
/// > **The active execution is cancelled and replaced.** The new call becomes
/// > the sole authoritative execution; the superseded execution is signalled
/// > for cooperative cancellation and may still return its own terminal result
/// > to *its own* caller, but it no longer owns the instance's presentation
/// > state.
///
/// Consequences every implementation must honour:
///
/// - [status] and [watchStatus] reflect the **authoritative** (most recently
///   started) execution only.
/// - A superseded execution's late completion must **not** overwrite the
///   authoritative execution's terminal status.
/// - Overlapping A/B is therefore a *defined* state, not an error: A is
///   cancelled-and-replaced by B, B is authoritative.
///
/// **Why not reject?** No consumer requires rejection. `AsyncCommandBinding`
/// — the only consumer of this contract in the repository — documents and
/// implements cancel-and-replace ("Re-executed with new input"), so rejection
/// would force it to surface an error for behaviour it already relies upon.
/// **Why not multi-flight?** No consumer requires it either: there is no
/// production construction site for [AsyncCommandBinding] and the only two
/// [AsyncCommand] implementations are the testkit fake and the FRB adapter.
/// Multi-flight existed solely as an encoded test expectation.
///
/// Genuine concurrent-job workloads are a **different concept** and must be
/// modelled by a separate abstraction with per-execution identity and state
/// (e.g. a command *executor* returning a per-execution handle), never by
/// weakening this contract.
///
/// **PURGE LAW**: This contract contains strictly zero re-invocation loops,
/// exponential delay loops, auto-invocation timers, or progress UI logic.
///
/// Lifecycle: EXPERIMENTAL (see `.project/architecture/layer-contracts.md`).
@experimental
abstract interface class AsyncCommand<TParam, TResult> {
  /// Lifecycle status of the **authoritative** (most recently started) execution.
  ///
  /// Under the single-flight model this is never ambiguous. See the class-level
  /// concurrency contract.
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
