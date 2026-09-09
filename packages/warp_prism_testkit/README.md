# warp_prism_testkit

In-memory test doubles (fakes) and reusable contract compliance verification test suites for Warp Prism runtime contracts.

## Scope

`warp_prism_testkit` provides deterministic verification infrastructure for all `warp_prism_runtime` interfaces:

- **In-Memory Fakes** (`lib/src/fakes/`):
  - `FakeEventStream<T>`: Programmatic emitter with append-only FIFO ordering, backpressure buffer enforcement, subscription tracking, and completion/error signaling.
  - `FakeHealthSource`: Point-in-time snapshot and reactive watch state manager with cell manipulation and simulated degradation.
  - `FakeGraphSource<TNode, TEdge>`: Mutable in-memory topological graph with incremental `GraphUpdate` event broadcasting.
  - `FakeAsyncCommand<TParam, TResult>`: Deterministic execution simulator with custom handlers, simulated delays, and cooperative cancellation tokens.
- **Contract Compliance Suites** (`lib/src/contract_tests/`):
  - `verifyEventStreamContract`: Verifies subscription lifecycle, resource cleanup, deterministic ordering, and backpressure policies.
  - `verifyHealthSourceContract`: Verifies snapshot querying, freshness metadata, cell filtering, and aggregate worst-state calculations.
  - `verifyGraphSourceContract`: Verifies snapshot retrieval, structural adjacency queries, incremental update stream notifications, and graph resets.
  - `verifyAsyncCommandContract`: Verifies execution lifecycle transitions (`idle` -> `running` -> `succeeded` / `failed` / `cancelled`), error handling, and cancellation propagation.

## Presentation-Purge Law

In compliance with the architecture floor defined in `docs/architecture/runtime-consumer-audit.md` and `docs/architecture/layer-contracts-v2.md`, this package contains strictly zero Flutter UI dependencies, no presentation coordinate models (`Offset`), and no UI polling/retry policies.

## Lifecycle Status

All fakes and contract test suites in this package are currently tagged **`EXPERIMENTAL`** per `docs/architecture/layer-contracts-v2.md` §3.2.

## Downstream Usage in Task 1824

In addition to verifying the in-memory fake implementations, the contract compliance suites in this package are designed to be implementation-agnostic. In Task 1824, these same suites will be executed against `packages/warp_prism_adapter_frb/` to guarantee 100% behavioral parity between in-memory test doubles and live Flutter Rust Bridge native adapters.
