/// Warp Prism Bindings — Thin Projection Layer.
///
/// Connects UI presentation (`warp_prism_ui`), interaction semantics
/// (`warp_prism_interaction`), and runtime contracts (`warp_prism_runtime`).
///
/// Provides:
/// - [EventStreamBinding]: Reactive view-model projection of runtime [EventStream]
///   for [PrismExecutionConsole] and [PrismLogViewer].
/// - [GraphSourceBinding]: Pure semantic [GraphSource] topological mapping to
///   [PrismGraphCanvas] with binding-owned layout state ([Offset]).
/// - [AsyncCommandBinding]: UI and IDS intent trigger convergence with [AsyncCommand].
/// - [HealthSourceBinding]: Reactive view-model projection of runtime [HealthSource]
///   for [PrismProviderHealthMatrix] surfaces.
///
/// Lifecycle: EXPERIMENTAL (see `.project/architecture/layer-contracts.md`).
library warp_prism_bindings;

export 'src/async_command_binding/async_command_binding.dart';
export 'src/async_command_binding/async_command_view_model.dart';
export 'src/event_stream_binding/event_stream_binding.dart';
export 'src/event_stream_binding/event_stream_view_model.dart';
export 'src/graph_source_binding/graph_layout_strategy.dart';
export 'src/graph_source_binding/graph_source_binding.dart';
export 'src/graph_source_binding/graph_view_model.dart';
export 'src/health_source_binding/health_source_binding.dart';
export 'src/health_source_binding/health_source_view_model.dart';
