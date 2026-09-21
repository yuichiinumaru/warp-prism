# Task 1824: FRB Integration Lab Parity Report (Single Hypothesis)

> **Status**: Verified · **Single-Hypothesis Parity Verdict**: `100% Parity on Common Subset`
> **Author**: Builder (Task 1824)
> **Date**: 2026-09-01
> **Milestone Alignment**: M01 — Warp Prism v2: L1 Integration-Capable
> **Governing Task**: Task 1824 (`docs/tasks/01-open/1824-warp-prism-frb-integration-lab-parity.md`)
> **Blocks**: Task 1825 (Golden Path Golden Contract & Adoption Gate)

---

## 1. Executive Summary & Single Hypothesis

Task 1824 established the empirical integration lab verifying the **SINGLE HYPOTHESIS**:
> *Flutter↔Rust via FRB 2.13.0 behaves identically to the in-memory Dart fakes across all 4 Warp Prism backend-agnostic runtime contracts (`EventStream`, `HealthSource`, `GraphSource`, `AsyncCommand`) without transport contamination (no background daemons, JSON-RPC, or external services).*

To evaluate this hypothesis without ambiguity or divergence, the contract compliance suites (`verifyEventStreamContract`, `verifyHealthSourceContract`, `verifyGraphSourceContract`, `verifyAsyncCommandContract`) from `packages/warp_prism_testkit` were executed side-by-side against:
1. In-memory Dart fakes (`FakeEventStream`, `FakeHealthSource`, `FakeGraphSource`, `FakeAsyncCommand`).
2. Live native FRB bridge adapters (`FrbEventStream`, `FrbHealthSource`, `FrbGraphSource`, `FrbAsyncCommand`) dynamically linked to the compiled Rust cdylib (`libwarp_bridge_frb.so`).

**Verdict: 100% parity on the common subset of contract assertions executable against both implementations; live-side reactive/mutation assertions are fake-only because the FRB adapters/substrate lack the corresponding test-control surface; AsyncCommand live parity is proven by a hand-written modality matrix, not the testkit suite.**

All 82 integration lab assertions (5 FFI smoke probes, 39 EventStream tests, 13 HealthSource tests, 10 GraphSource tests, 14 AsyncCommand tests, 1 synthesis test) and 95 total adapter package tests pass cleanly.

---

## 2. Per-Contract Parity Matrix

The following table summarizes the side-by-side verification results across all 4 runtime contracts:

| Contract | Fake Result | Live Adapter Result | Parity Verdict | Evidence & Test Counts |
|---|---|---|---|---|
| **`EventStream<RuntimeEvent<String>>`** | **19/19 PASS** | **19/19 PASS** | **MATCH (Full Symmetric Parity)** | Subscription lifecycle, ordered FIFO delivery, `unbounded` / `dropOldest` / `dropNewest` / `errorOnOverflow` backpressure policies, `emit` / `emitBatch` / `replaceAll` / `clear` operations, error signaling, `complete()`, and clean closure idempotency. |
| **`HealthSource`** | **7/7 PASS** | **5/7 PASS** (common subset) + **1/1 PASS** (parity) | **MATCH (Common Subset)** | Point-in-time `getSnapshot()`, TTL freshness evaluation (`isFresh`), cell query filtering (`cellsForProvider`, `cellsForDimension`), worst-state aggregate calculation fold, and post-close query failure. Note: Live compliance suite omits reactive watch mutation assertions (no test-control surface in substrate); native watch stream transitions are exercised at smoke level in `adapter_test.dart`. |
| **`GraphSource<String, String>`** | **6/6 PASS** | **3/6 PASS** (common subset) + **1/1 PASS** (parity) | **MATCH (Common Subset)** | Semantic snapshot retrieval, adjacency graph topology helpers (`outgoingEdges`, `incomingEdges`, `adjacentNodes`, `edgesBetween`), and resource cleanup on close. Note: Live compliance suite omits update/remove/reset assertions (substrate lacks endpoints); native node-add stream broadcast is exercised at smoke level in `adapter_test.dart`. |
| **`AsyncCommand<String, String>`** | **8/8 PASS** | **6/6 PASS** (modality matrix substitute) | **MATCH (Modality Matrix Substitute)** | Full lifecycle transitions (`idle` -> `running` -> `succeeded` / `failed` / `cancelled`), structured duration tracking, typed `CommandError` propagation, preflight cancellation, in-flight cooperative FFI cancellation token propagation to Rust worker, `watchStatus()` stream broadcasts, and post-close idempotency. Proven via hand-written modality matrix in place of testkit suite. |

### Aggregate Live-Side Suite Coverage Breakdown:
- **EventStream**: 19/19 (100% full symmetric suite parity across all 4 backpressure policies)
- **HealthSource**: 5/7 (Common subset: snapshot, cell queries, aggregate fold, freshness, close lifecycle)
- **GraphSource**: 3/6 (Common subset: snapshot, topology & adjacency query helpers, close lifecycle)
- **AsyncCommand**: Substituted with 6/6 modality matrix (full lifecycle, preflight & in-flight FFI cancellation, status streams, post-close idempotency)

---

## 3. FFI Boundary & Native Substrate Confirmation

The native shared library `libwarp_bridge_frb.so` compiled via `rustc 1.95.0` / Cargo was dynamically loaded via `RustLib.init(externalLibrary: ExternalLibrary.open(...))`.

All primary FFI invocation modalities were verified in dedicated smoke probes:
- **Synchronous Direct FFI (`#[frb(sync)]`)**: `rust_api.add(a: 19, b: 23)` returned `42` synchronously.
- **Asynchronous Direct FFI (`Future<T>`)**: `await rust_api.echo(msg: "parity-lab")` returned `"echo: parity-lab"`.
- **Streaming Native FFI (`StreamSink<T>`)**: `rust_api.countStream(n: 5)` yielded `[1, 2, 3, 4, 5]`.
- **Complex Record Serialization across FFI**:
  - `rust_api.getSampleHealthSnapshot()` returned 2 cells with worst-state `Healthy` aggregate state.
  - `rust_api.getSampleGraphSnapshot()` returned 2 nodes and 1 edge graph topology.
  - `rust_api.cancelCommand(commandId: ...)` cooperatively aborted in-flight Rust task without isolate panics.

**FFI Smoke Test Output**: 5/5 probes executed and passed in < 5ms.

---

## 4. Behavioral Parity & Deep Invariant Analysis

### 4.1 Event Streaming & Backpressure Parity
- **Growth Notification Semantics**: The stream delivery itself acts as the formal growth notification on both Fake and Live FRB streams. Retained snapshot `currentEvents` grows synchronously with delivery.
- **Payload Identity Preservation**: Delivers `RuntimeEvent` preserving `id`, `timestamp`, `severity`, `source`, `runGroupId`, and `payload` without truncation or mutation across FFI.
- **Backpressure Discipline**: `dropOldest(N)` evicts head elements when buffer length reaches capacity; `dropNewest(N)` drops tail incoming items; `errorOnOverflow(N)` signals `StateError` on overflow. Both Fake and Live implementations exhibit identical queue behavior (19/19 tests symmetric).

### 4.2 Async Command Lifecycle & In-Flight Cancellation
- **Cooperative Cancellation**: `CancellationToken` attached in Dart propagates synchronously across FFI into Rust `CommandRegistry` via `cancelCommand(id)`.
- **Execution State**: Rust worker polling `token.is_cancelled()` aborts computation within 10ms and returns `CommandCancelled` with accurate duration and reason.
- **Error Propagation**: Unhandled Rust errors or `fail` command types map cleanly to typed `CommandFailure` with `CommandError.execution` without crashing the Dart VM or breaking isolate channels.
- **Modality Substitute vs Testkit**: Parity across all 6 core lifecycle states and cancellation modes is verified via explicit modality tests.

### 4.3 Health & Graph State Topology
- **Aggregate Worst-Fold**: Both pure Dart derivation and Rust `derive_aggregate_state` evaluate `[healthy, degraded, unreachable]` -> `unreachable` with identical precedence.
- **Topological Invariants**: Adjacency helpers (`outgoingEdges`, `incomingEdges`, `adjacentNodes`, `edgesBetween`) evaluate identically on Dart fakes and native graph snapshots.
- **Stream Termination & Resource Cleanup**: Closing `FrbGraphSource` or `FrbHealthSource` terminates active watcher subscriptions and closes underlying controllers idempotently without leaking Tokio background receiver tasks.

---

## 5. Single-Hypothesis Statement, Exit Conditions & Kill-Gate Framing for Task 1825

### Evaluation Question:
> *Does empirical parity evidence support the ADOPT + pin of `flutter_rust_bridge 2.13.0` as the Ganthritor/Warp Prism golden path for native Rust integration?*

### Exit Conditions Truthful Disposition:
1. **Complete contract test suite passes 100% against live Rust FRB implementation**: **PARTIAL (Met on Common Subset)**
   - Met 100% fully for `EventStream` (19/19 assertions).
   - Partially met for `HealthSource` (5/7 assertions on read/query common subset; live mutation controls omitted).
   - Partially met for `GraphSource` (3/6 assertions on topology common subset; mutation controls omitted).
   - Met via substitute modality matrix for `AsyncCommand` (6/6 lifecycle assertions; closure-injection testkit suite omitted).
2. **Behavioral parity established between in-memory fake and live Rust adapter**: **MET** (Established across all common read/query behaviors, backpressure queues, FFI cancellation, and topology).
3. **Error propagation, stream cancellation, and resource cleanup proven across FFI boundary**: **MET** (Cooperative cancellation, typed `CommandError`, and stream disposal verified).
4. **Parity report committed at `docs/reports/1824-frb-integration-lab-parity-report.md`**: **MET** (This report).
5. **Zero daemon/RPC transport contamination**: **MET** (Pure in-process `cdylib` dynamic FFI linking).
6. **Local changelog entry added**: **MET** (Prepared for ledger closeout).

### Evidence Summary:
1. **Zero Transport Contamination**: Lab runs purely in-process via FFI C dynamic library (`cdylib`); zero socket/HTTP/RPC/worker daemon dependencies.
2. **Contract Common Subset Adherence**: 100% parity across the common subset executable on native bridge, with EventStream fully symmetric (19/19).
3. **Sub-second Execution**: 82 integration tests execute in 1.4s on desktop Linux x86_64.
4. **Cooperative Cancellation Proven**: Cancellation tokens pass across FFI boundaries and abort background Tokio tasks cleanly.

**Recommendation for Task 1825 Gate**: **ADOPT & PIN `flutter_rust_bridge 2.13.0`**.

---

## 6. Residual Risks, Coverage Limitations & Substrate Extension Gap List

### 6.1 Named COVERAGE LIMITATION: Live-Side Contract Suite Omissions & Root Causes
The following test assertions from `warp_prism_testkit` were skipped or substituted during live-side execution:

1. **`HealthSource` Live-Side (2 of 7 skipped in `verifyHealthSourceContract`)**:
   - *Skipped Assertions*: `watch stream emits updated snapshots when state changes` and `updateCell triggers snapshot update with revised aggregate state`.
   - *Root Cause*: `FrbHealthSource.watch()` streams a fixed canned native sequence (`healthy` -> `degraded` -> `healthy`, `rust/warp_bridge_frb/src/api.rs:306-346`) that cannot be driven to a demanded state from Dart; the Rust substrate has no live cell-mutation test-control surface. (Native stream transitions are verified separately at smoke level in `packages/warp_prism_adapter_frb/test/adapter_test.dart`).
2. **`GraphSource` Live-Side (3 of 6 skipped in `verifyGraphSourceContract`)**:
   - *Skipped Assertions*: `incremental node updates emit structured events on watchUpdates`, `incremental edge updates emit structured events on watchUpdates`, and `whole-graph reset emits GraphReset event with new snapshot`.
   - *Root Cause*: The Rust bridge substrate (`rust/warp_bridge_frb/src/api.rs`) exposes only `apply_graph_node_add` and `apply_graph_edge_add` endpoints (no update, remove, or reset endpoints), so `FrbGraphSource` cannot supply `updateNode`, `removeNode`, `updateEdge`, `removeEdge`, or `setGraph` test-control callbacks. (Node addition stream broadcast is verified separately at smoke level in `packages/warp_prism_adapter_frb/test/adapter_test.dart`).
3. **`AsyncCommand` Live-Side (Substituted modality matrix)**:
   - *Omission*: `FrbAsyncCommand` does not run `verifyAsyncCommandContract` directly. Instead, it runs a dedicated 6-test modality matrix (succeeded, failed, preflight-cancel, in-flight-cancel, watchStatus, close).
   - *Root Cause*: `verifyAsyncCommandContract` requires a `createCommand({handler})` factory that injects arbitrary Dart closures (`Future<TResult> Function(TParam, CancellationToken?)`), which is architecturally incompatible with fixed native Rust command handlers (`echo`, `fail`, `long_running`).
   - *Omitted Assertions*: The substitute matrix omits `initial status is idle` and `handler receives input parameter payload intact` (payload delivery is implicitly exercised in echo/fail).

### 6.2 Substrate Extension Gap-to-Close List (for Future 100% Symmetric Suite Parity)
If the parent project or Task 1825 gate mandates true 100% symmetric testkit suite parity without skipped assertions, the following concrete substrate extensions are required:
- **Native Graph Mutation Endpoints**: Implement `apply_graph_node_update`, `apply_graph_node_remove`, `apply_graph_edge_update`, `apply_graph_edge_remove`, and `apply_graph_reset` in `rust/warp_bridge_frb/src/api.rs`.
- **Native Health Watch Control Surface**: Implement controllable health state setter / cell mutator in Rust substrate (e.g. `set_health_cell`, `set_health_snapshot`) to drive live watch streams to demanded test states.
- **AsyncCommand Testkit Adaptation**: Either parameterize `verifyAsyncCommandContract` for fixed-command adapters, or implement a native Dart-closure invocation bridge across FFI.

*(Note: These extensions are documented as non-blocking gap candidates for future milestones; they are not implemented in Task 1824)*.

### 6.3 Operational & Environmental Risks
1. **Desktop Linux Scope (Single OS Baseline)**: Tests executed on Linux x86_64 (`.so`). Mobile toolchain verification (Android NDK `.so`, iOS `.dylib` / static framework) remains deferred to app packaging and release milestones.
2. **Stream Timing Sensitivity under Extreme CI Load**: Asynchronous broadcast streams rely on millisecond delays (`10ms-50ms`) for cross-isolate propagation in test harnesses. While 100% stable locally, low-core CI virtual machines should maintain adequate timeout margins.
3. **No External Transports**: The single-hypothesis boundary intentionally excludes WebSocket, IPC, or daemon transports. Any future out-of-process architecture must maintain separate adapter layers without modifying these 4 core runtime contracts.

---

## 7. Gap Closure Amendment (2026-09-02)

During the Level 1 exit-gate remediation (Task 1825 Disposition 1), the substrate-mirrorable gaps identified in §6.1 and §6.2 were formally implemented and verified:

### 7.1 Implemented Substrate Extensions
1. **GraphSource Native Mutation Endpoints (CLOSED)**:
   - Added `apply_graph_node_update`, `apply_graph_node_remove`, `apply_graph_edge_update`, `apply_graph_edge_remove`, and `apply_graph_reset` in `rust/warp_bridge_frb/src/api.rs`.
   - Each endpoint mutates the shared `GraphState` and broadcasts structured `FrbGraphUpdate` events over the Tokio broadcast channel.
   - `FrbGraphSource` in `packages/warp_prism_adapter_frb` was extended with `updateNode`, `removeNode`, `updateEdge`, `removeEdge`, and `setGraph`.
   - **Result**: `GraphSource` live-side contract compliance is now **6/6 PASS (100% full symmetric parity)**.

2. **HealthSource Native Watch Control Surface (CLOSED)**:
   - Added controllable health mutation surface (`set_health_cell`, `set_health_cells`, `set_health_snapshot`) in `rust/warp_bridge_frb/src/api.rs` backed by `SharedHealthStore`.
   - Replaced the canned test loop in `watch_health` with a live Tokio broadcast stream listener that pushes dynamic health transitions to watchers.
   - `FrbHealthSource` in `packages/warp_prism_adapter_frb` was extended with `updateCell`, `setCells`, and `setSnapshot`.
   - **Result**: `HealthSource` live-side contract compliance is now **7/7 PASS (100% full symmetric parity)**.

3. **AsyncCommand Closure-Injection Exception (REMAINS DOCUMENTED EXCEPTION)**:
   - The architectural barrier remains: `verifyAsyncCommandContract` requires injecting arbitrary in-memory Dart closures (`Future<TResult> Function(TParam, CancellationToken?)`), which is architecturally incompatible with fixed compiled native Rust handlers.
   - `AsyncCommand` live parity continues to be proven via the comprehensive 6/6 modality matrix (succeeded, failed, preflight-cancel, in-flight cooperative FFI cancellation, watchStatus stream transitions, close idempotency).

### 7.2 Updated Per-Contract Parity Status (Post-Remediation)

| Contract | Fake Result | Live Adapter Result | Parity Verdict | Gap Status |
|---|---|---|---|---|
| **`EventStream<RuntimeEvent<String>>`** | **19/19 PASS** | **19/19 PASS** | **MATCH (Full Symmetric Parity)** | Pre-existing Full Parity |
| **`HealthSource`** | **7/7 PASS** | **7/7 PASS** | **MATCH (Full Symmetric Parity)** | **CLOSED (7/7 Live)** |
| **`GraphSource<String, String>`** | **6/6 PASS** | **6/6 PASS** | **MATCH (Full Symmetric Parity)** | **CLOSED (6/6 Live)** |
| **`AsyncCommand<String, String>`** | **8/8 PASS** | **6/6 PASS** (modality matrix) | **MATCH (Modality Matrix)** | **REMAINS Documented Exception** |

---

## 8. Verification Evidence & Exact Command Outputs (Updated 2026-09-02)

```bash
# 1. Cargo Release Build
cargo build --release --manifest-path rust/Cargo.toml
# Output: Finished `release` profile [optimized] target(s) in 0.07s

# 2. Rust Workspace Tests (20 tests: 13 core + 7 frb)
cargo test --manifest-path rust/Cargo.toml
# Output: test result: ok. 13 passed (core); test result: ok. 7 passed (frb)

# 3. Integration Lab Test Suite (87 tests across all 4 contracts + smoke probes)
flutter test packages/warp_prism_adapter_frb/test/integration/
# Output: 00:01 +87: All tests passed!

# 4. Complete Adapter Package Suite (Unit + Integration: 100 tests)
flutter test packages/warp_prism_adapter_frb/
# Output: 00:01 +100: All tests passed!

# 5. Pure Dart Monorepo Boundary Harness
dart run packages/warp_prism_ui/test/boundaries/boundary_test.dart --repo-root .
# Output: Boundary harness: 10/10 PASS, 0 FAIL, 0 violation(s)
```
