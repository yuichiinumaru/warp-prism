import 'dart:async';
import 'package:meta/meta.dart';
import 'graph_source_models.dart';

/// Backend-agnostic semantic graph observation contract.
///
/// Exposes on-demand [GraphSnapshot] queries and reactive [watchUpdates] streams
/// for incremental node and edge topological modifications.
///
/// **PURGE LAW**: This contract contains strictly zero layout offsets
/// (`position: Offset`), physics engines, drag states, or pan/zoom scales.
///
/// Lifecycle: EXPERIMENTAL (see `.project/architecture/layer-contracts.md`).
@experimental
abstract interface class GraphSource<TNodePayload, TEdgePayload> {
  /// Evaluates and returns the current complete [GraphSnapshot].
  Future<GraphSnapshot<TNodePayload, TEdgePayload>> getSnapshot();

  /// Reactive stream of incremental and whole-graph topological updates.
  Stream<GraphUpdate<TNodePayload, TEdgePayload>> watchUpdates();

  /// Whether this graph source has been closed.
  bool get isClosed;

  /// Closes this graph source and terminates any active update streams.
  Future<void> close();
}
