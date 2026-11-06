# warp_prism_runtime

Pure Dart backend-agnostic runtime contracts for Warp Prism.

## Scope

`warp_prism_runtime` defines the canonical UI↔runtime interfaces and semantic data models connecting Flutter user interfaces and native/remote service backends:

- **`EventStream`** (`lib/src/event_stream/`): Reactive append-only event stream contract with deterministic FIFO ordering, backpressure policy declarations, completion signaling, and error propagation.
- **`HealthSource`** (`lib/src/health_source/`): Point-in-time `HealthSnapshot` queries and reactive `watch()` state streams for monitoring provider and subsystem dimensions with freshness metadata.
- **`GraphSource`** (`lib/src/graph_source/`): Pure semantic topological graph models (`GraphNode`, `GraphEdge`, `GraphSnapshot`) and incremental topological update streams (`GraphUpdate`).
- **`AsyncCommand`** (`lib/src/async_command/`): Structured asynchronous request/response execution lifecycle (`idle`, `running`, `succeeded`, `failed`, `cancelled`), sealed error types, and cooperative cancellation tokens.

## Presentation-Purge Law (Task 1818 Requirements Floor)

This package strictly enforces the **Presentation-Purge Law** established in `.project/architecture/runtime-consumer-audit.md` and `.project/architecture/layer-contracts.md`:

1. **EventStream**: Zero auto-scroll, follow-tail, viewport tracking, pause-on-scroll, or UI filter states (owned by widget/IDS).
2. **HealthSource**: Zero polling intervals, retry policies, refresh-on-focus mechanics (owned by composition/app), or interactive cell selection / tap callbacks (`onCellSelected` is owned by `warp_prism_ui` / `warp_prism_interaction`).
3. **GraphSource**: Zero spatial coordinates (`position: Offset`), layout bounds, physics flags, pan/zoom scale, or selection state (owned by UI/bindings).
4. **AsyncCommand**: Zero automatic retry loops, exponential backoff, or progress UI logic (owned by composition/app).
5. **Purity**: Pure Dart with zero `package:flutter` or `dart:ui` imports.

## Lifecycle Status

All public contracts and data models in this package are currently tagged **`EXPERIMENTAL`** per `.project/architecture/layer-contracts.md` §9.

## Implementation & Downstream Usage

- In-memory test doubles and reusable contract compliance test suites live in `packages/warp_prism_testkit/`.
- Production Flutter Rust Bridge (FRB) implementation will be delivered by `packages/warp_prism_adapter_frb/` (Task 1823/1824).
- Flutter UI widgets consume these contracts through `packages/warp_prism_bindings/` (Task 1820).
