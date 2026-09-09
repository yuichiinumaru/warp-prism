# Task 1820: Bindings Proof (IDS ∥ Runtime Convergence)

> **Priority**: 🔴 P0 · **Type**: `feature`
> **Origin**: EPIC-21 (S21-03 + S21-04) · Source-Reality Review 2026-09-01
> **Blocks**: Task 1821, Task 1824
> **Depends on**: Task 1815 (IDS Candidate Kernel), Task 1819 (Experimental Runtime Contracts)

## Milestone Alignment

- **Target milestone**: M01 — Warp Prism v2: L1 Integration-Capable (`docs/milestones.md`)
- **Capability / Gate advanced**: 21-C bindings proof (the IDS ∥ Runtime convergence point of the DAG)
- **Strategic why**: L1 must prove ui + interaction + runtime compose through a thin projection layer; this is where layout state stays out of runtime contracts.
- **Consequence if absent**: 1824 has no Dart-side projection to compare against the Rust bridge; convergence of IDS and Runtime stays unproven.

## Objective

Create `packages/warp_prism_bindings/` as the thin projection layer that connects UI presentation (`warp_prism_ui`), interaction semantics (`warp_prism_interaction`), and runtime contracts (`warp_prism_runtime`). Implement interactive bindings for at least 2 real component patterns (e.g. `ExecutionConsole` + `EventStream`, `GraphCanvas` + `GraphSource`), proving convergence and complete separation of concerns without domain leakage or backend implementation ownership.

## Background Context

### What already exists

- `packages/warp_prism_ui/` — ADS visual components.
- `packages/warp_prism_interaction/` — IDS kernel (from Task 1815).
- `packages/warp_prism_runtime/` — runtime contracts (from Task 1819).
- `packages/warp_prism_testkit/` — fakes and contract test suites (from Task 1819).
- `docs/architecture/layer-contracts-v2.md` — layer laws defining bindings rules (bindings MAY import ui+interaction+runtime, MUST NOT own backend logic or domain types, MUST NOT be imported by ui).

### What is missing or broken

- No bindings package exists (`packages/warp_prism_bindings/` is greenfield).
- UI components lack thin projection adapters to bind runtime streams/commands to reactive UI state without hardcoding backend APIs.

## Subtasks

- [x] **Read before modifying**: `docs/architecture/layer-contracts-v2.md`, `packages/warp_prism_interaction/lib/`, `packages/warp_prism_runtime/lib/`, `packages/warp_prism_ui/lib/src/organisms/execution_console/`, `packages/warp_prism_ui/lib/src/organisms/graph_canvas/`.
- [x] **Create `packages/warp_prism_bindings/`**: initialize Flutter package depending on `warp_prism_ui`, `warp_prism_interaction`, and `warp_prism_runtime`.
- [x] **Implement `EventStreamBinding`**: projects `EventStream` events into `ExecutionConsole` / `LogViewer` view models, managing stream subscription lifecycle, cancellation on dispose, and UI buffering without leaking stream internals to widget.
- [x] **Implement `GraphSourceBinding`**: maps semantic `GraphSource` models (nodes, edges) into `GraphCanvas` renderable models, maintaining layout state (`position: Offset`) in the binding layer without polluting the runtime contract.
- [x] **Implement `AsyncCommandBinding`**: binds user UI triggers (e.g. `PrismButton`) via IDS command intent to runtime `AsyncCommand`, tracking execution status and exposing loading/error states.
- [x] **Write integration tests**: verify bindings in `packages/warp_prism_bindings/test/` using in-memory fakes from `warp_prism_testkit`.
- [x] **Add boundary harness checks**: verify `warp_prism_bindings` is not imported by `warp_prism_ui` (check 14).
- [x] **Simplify pass**: remove unnecessary complexity.
- [x] **Regression verification**: run validation commands below.

## Validation Commands

```bash
flutter analyze packages/warp_prism_bindings
flutter test packages/warp_prism_bindings
dart run packages/warp_prism_ui/test/boundaries/boundary_test.dart --repo-root .
```

## Where

| File | Purpose |
|---|---|
| `packages/warp_prism_bindings/` | Create — UI↔Interaction↔Runtime bindings package |
| `packages/warp_prism_bindings/lib/src/event_stream_binding/` | EventStream binding implementation & view-models |
| `packages/warp_prism_bindings/lib/src/graph_source_binding/` | GraphSource binding implementation, view-models & layout strategies |
| `packages/warp_prism_bindings/lib/src/async_command_binding/` | AsyncCommand binding implementation & view-models |
| `packages/warp_prism_bindings/test/` | Integration tests with fakes |

## Exit Conditions

- [x] `packages/warp_prism_bindings/` created with clean dependency direction.
- [x] At least 2 real binding projections implemented and verified with tests (EventStreamBinding, GraphSourceBinding, AsyncCommandBinding).
- [x] Layout state (`Offset`) and presentation policies strictly kept in bindings/UI, not runtime.
- [x] 100% test pass rate using `warp_prism_testkit` fakes (29/29 tests PASS).
- [x] Boundary checks pass (no reverse import from `warp_prism_ui`, 10/10 boundary harness PASS).
- [x] Local changelog entry added (proposed in handoff packet).

## Completion Evidence

- **Files created**: packages/warp_prism_bindings/ (14 files: pubspec, analysis_options, README, barrel, 3 binding modules with sub-barrels + layout strategies, 4 test files). ZERO modifications outside this package (the adapter pubspec modification was a Task 1823 change, not this task's).
- **Tests or validation commands**:
  - `flutter analyze packages/warp_prism_bindings`: PASS (0 errors, 0 warnings)
  - `flutter test packages/warp_prism_bindings`: PASS (33/33 passed: 11 event_stream + 11 graph_source + 9 async_command + 2 boundary_isolation)
  - `dart run packages/warp_prism_ui/test/boundaries/boundary_test.dart --repo-root .`: PASS (10/10 passed)
  - `grep -rn "warp_prism_bindings" packages/warp_prism_ui/lib/ apps/*/lib/ | wc -l`: 0
  - `grep -rnE "Ganthritor|OmniRoute|Cersei|CyberCore" packages/warp_prism_bindings/lib/ | wc -l`: 0
- **Convergence proof**: AsyncCommandBinding.executeWithIntent (InputIntent) + executeWithQueryIntent (QueryIntent) bridge IDS intents to runtime AsyncCommand — verified via FakeAsyncCommand. EventStreamBinding + GraphSourceBinding project runtime contracts into view-models with layout state (Offset) owned strictly in bindings layer (structural source-scan assertions confirm runtime models contain no layout/Flutter).
- **Local changelog entry**: pending parent publication
- **Executor**: gt-builders-engineer-flutter (builder + remediation, 2026-09-01)
- **Completion date**: 2026-09-01
- **Review trail**: independent review FAIL (boundary_isolation not structural; GraphViewModel == shallow; toLogEntries nondeterministic DateTime.now(); claim of out-of-scope adapter pubspec modification) → remediated (source-scan assertions, identity semantics, deterministic sentinel, ledger claim removed) → focal re-review PASS (33/33 tests; structural isolation; deterministic fallback; followState optional advisory; out-of-scope claim removed).
