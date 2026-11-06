import 'package:meta/meta.dart';
import 'package:warp_prism_runtime/warp_prism_runtime.dart';

import 'fake_async_command.dart';

/// In-memory fake executor for deterministic concurrent-job testing.
///
/// Mints one [FakeAsyncCommand] per [submit], so every execution runs in
/// isolation with distinct per-execution identity. Exposes [createdCommands]
/// so tests can assert one command instance per execution and inspect
/// per-execution params.
///
/// The [handler] (or [initialResult]) is shared across executions: it receives
/// each execution's own param and its own [CancellationToken], mirroring
/// production executors that mint one command per job.
///
/// Lifecycle: EXPERIMENTAL (see `.project/architecture/layer-contracts.md`).
@experimental
class FakeAsyncJobExecutor<TParam, TResult>
    extends AsyncJobExecutor<TParam, TResult> {
  /// Commands minted so far, one per [submit], in submit order.
  final List<FakeAsyncCommand<TParam, TResult>> _created;

  /// Creates a [FakeAsyncJobExecutor] with an optional shared [handler].
  factory FakeAsyncJobExecutor({
    Future<TResult> Function(TParam param, CancellationToken? token)? handler,
    TResult? initialResult,
  }) {
    final created = <FakeAsyncCommand<TParam, TResult>>[];
    return FakeAsyncJobExecutor<TParam, TResult>._internal(
      created: created,
      commandFactory: () {
        final command = FakeAsyncCommand<TParam, TResult>(
          handler: handler,
          initialResult: initialResult,
        );
        created.add(command);
        return command;
      },
    );
  }

  FakeAsyncJobExecutor._internal({
    required this._created,
    required super.commandFactory,
  });

  /// Command instances minted so far, one per [submit], in submit order.
  List<FakeAsyncCommand<TParam, TResult>> get createdCommands =>
      List.unmodifiable(_created);
}
