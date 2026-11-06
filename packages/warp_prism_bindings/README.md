# Warp Prism Bindings (`warp_prism_bindings`)

> **Role**: Thin projection layer connecting UI presentation (`warp_prism_ui`), interaction semantics (`warp_prism_interaction`), and runtime contracts (`warp_prism_runtime`).
> **Lifecycle**: EXPERIMENTAL (see `.project/architecture/layer-contracts.md`).

---

## 1. Executive Summary

`warp_prism_bindings` is the convergence layer of Warp Prism. It projects backend-agnostic runtime contracts into reactive view-models and controllers consumable by UI organisms without:
- Leaking stream or runtime internals into pure presentation widgets.
- Polluting runtime contracts with presentation, layout coordinates (`position: Offset`), or scroll state.
- Introducing backend orchestration, disk IO, native FFI, or domain-specific types.

---

## 2. Layer Contract & Dependency Law

Per `.project/architecture/layer-contracts.md`:

| Rule | Enforcement |
|---|---|
| **MAY depend on** | `warp_prism_ui`, `warp_prism_interaction`, `warp_prism_runtime`, Flutter state wrappers |
| **MUST NOT be imported by** | `warp_prism_ui`, `warp_prism_interaction`, `warp_prism_runtime` |
| **MUST NOT import** | `warp_prism_adapter_frb` or direct FRB / native bindings |
| **MUST NOT own** | Backend orchestration, persistence, networking, physics engines, or domain types |

---

## 3. Core Bindings

1. **`EventStreamBinding<T>`** (`lib/src/event_stream_binding/`):
   - Subscribes to `EventStream<T>` and manages subscription lifecycle (cancellation on `dispose()`).
   - Buffers retained events for `ExecutionConsole` / `LogViewer` view models.
   - Handles errors, paused states, and stream completions cleanly.

2. **`GraphSourceBinding<TNodePayload, TEdgePayload>`** (`lib/src/graph_source_binding/`):
   - Subscribes to `GraphSource<TNodePayload, TEdgePayload>` updates.
   - Owns and manages layout coordinates (`position: Offset`) using deterministic layout strategies (grid/circle).
   - Projects pure semantic graph snapshots and updates into renderable `GraphModel` / `GraphNode` / `GraphEdge` models.

3. **`AsyncCommandBinding<TParam, TResult>`** (`lib/src/async_command_binding/`):
   - Bridges UI triggers and IDS intents (`InputIntent`, `QueryIntent`) to runtime `AsyncCommand<TParam, TResult>`.
   - Tracks execution lifecycle states (`idle`, `running`, `succeeded`, `failed`, `cancelled`).
   - Exposes reactive status notifiers and cancellation triggers.
