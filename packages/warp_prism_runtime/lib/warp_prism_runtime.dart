/// Warp Prism Runtime Contracts.
///
/// Provides backend-agnostic UI↔runtime contracts strictly purged of
/// presentation and polling policies:
/// - [EventStream]: Reactive, append-only ordered event stream.
/// - [HealthSource]: Point-in-time snapshot and watch state observation.
/// - [GraphSource]: Pure semantic topological graph models and update streams.
/// - [AsyncCommand]: Structured asynchronous request/response execution lifecycle.
///
/// Lifecycle: EXPERIMENTAL (see `docs/architecture/layer-contracts-v2.md`).
library warp_prism_runtime;

export 'src/async_command/async_command.dart';
export 'src/event_stream/event_stream.dart';
export 'src/graph_source/graph_source.dart';
export 'src/health_source/health_source.dart';
