# Task 1819: Experimental Runtime Contracts + Fakes/Testkit

> **Priority**: 🔴 P0 · **Type**: `feature`
> **Origin**: EPIC-21 (S21-01 + S21-02 + S21-05) · Source-Reality Review 2026-09-01
> **Blocks**: Task 1820, Task 1823
> **Depends on**: Task 1818 (Runtime Consumer Audit)

## Milestone Alignment

- **Target milestone**: M01 — Warp Prism v2: L1 Integration-Capable (`docs/milestones.md`)
- **Capability / Gate advanced**: 21-B experimental runtime contracts + fakes/testkit (the backend-agnostic contract layer of L1)
- **Strategic why**: L1's runtime-contract layer is what the FRB golden path (1822–1824) and bindings (1820) build against; the testkit is what 1824's parity suite executes.
- **Consequence if absent**: no backend-agnostic contract surface exists; FRB work would bind to presentation-coupled models (the exact v1 failure mode).

## Objective

Create `packages/warp_prism_runtime/` and `packages/warp_prism_testkit/`. Implement the 4 core backend-agnostic runtime contracts (`EventStream`, `HealthSource`, `GraphSource`, `AsyncCommand`) strictly purged of presentation policy (no auto-scroll, follow-tail, polling intervals, or UI retry), accompanied by in-memory fake adapters, contract verification testkit, and declared SLO metrics without speculative low-level optimization.

## Background Context

### What already exists

- `docs/architecture/runtime-consumer-audit.md` (from Task 1818) defining presentation-purged contract requirements.
- `docs/architecture/layer-contracts-v2.md` enforcing runtime package purity (pure Dart, zero Flutter UI dependencies, zero domain types).
- Fixture-first culture across existing apps.

### What is missing or broken

- No runtime contracts package exists (`packages/warp_prism_runtime/` is greenfield).
- No testkit package exists (`packages/warp_prism_testkit/` is greenfield).
- Existing components lack contract test harnesses to verify behavioral parity between fakes and live adapters.

## Subtasks

- [ ] **Read before modifying**: `docs/architecture/runtime-consumer-audit.md`, `docs/architecture/layer-contracts-v2.md`, `packages/warp_prism_ui/test/boundaries/boundary_test.dart`.
- [ ] **Create `packages/warp_prism_runtime/`**: initialize pure Dart package (no `package:flutter` or Flutter imports).
- [ ] **Implement `EventStream` contract**: subscription, stream lifecycle, event ordering, delivery, completion, error signaling, backpressure semantics (NO auto-scroll, follow-tail, or viewport presentation logic).
- [ ] **Implement `HealthSource` contract**: snapshot, watch, freshness metadata, source state (NO polling timers or retry policies).
- [ ] **Implement `GraphSource` contract**: semantic graph nodes, edges, update streams (pure semantic models, NO layout `Offset` or canvas coordinates).
- [ ] **Implement `AsyncCommand` contract**: execution lifecycle, parameter payload, typed result, error handling, cancellation support if applicable (NO generic exponential retry).
- [ ] **Create `packages/warp_prism_testkit/`**: implement in-memory fake adapters for all 4 contracts + reusable contract compliance test suite.
- [ ] **Declare SLO metrics**: define benchmark declarations (event throughput, latency expectations) as contract declarations (no premature SIMD/lock-free optimizations).
- [ ] **Lifecycle tagging**: all contracts tagged EXPERIMENTAL (not in stable public barrel).
- [ ] **Add boundary harness check**: verify `warp_prism_runtime` contains zero Flutter imports (check 12).
- [ ] **Simplify pass**: remove unnecessary complexity.
- [ ] **Regression verification**: run validation commands below.

## Validation Commands

```bash
flutter analyze packages/warp_prism_runtime packages/warp_prism_testkit
flutter test packages/warp_prism_runtime packages/warp_prism_testkit
dart run packages/warp_prism_ui/test/boundaries/boundary_test.dart --repo-root .
```

## Where

| File | Purpose |
|---|---|
| `packages/warp_prism_runtime/` | Create — backend-agnostic runtime contracts package |
| `packages/warp_prism_runtime/lib/src/event_stream/` | EventStream contract |
| `packages/warp_prism_runtime/lib/src/health_source/` | HealthSource contract |
| `packages/warp_prism_runtime/lib/src/graph_source/` | GraphSource contract |
| `packages/warp_prism_runtime/lib/src/async_command/` | AsyncCommand contract |
| `packages/warp_prism_testkit/` | Create — testkit and fake implementations |
| `packages/warp_prism_testkit/lib/src/fakes/` | In-memory fake adapters |
| `packages/warp_prism_testkit/lib/src/contract_tests/` | Reusable contract compliance test suites |

## Exit Conditions

- [ ] `packages/warp_prism_runtime/` created and verified pure Dart (zero Flutter imports).
- [ ] All 4 contracts implemented without embedded presentation or polling policies.
- [ ] `packages/warp_prism_testkit/` created with working in-memory fakes and contract test suites.
- [ ] Contract compliance tests pass 100% against all 4 fake implementations.
- [ ] All contracts tagged EXPERIMENTAL.
- [ ] Boundary harness checks pass.
- [ ] Local changelog entry added.

## Completion Evidence

- **Files created**: packages/warp_prism_runtime/ (21 files: 4 contract modules + models + SLO declarations, barrel, README, purity test; 43/43+new publics @experimental) + packages/warp_prism_testkit/ (fakes ×4 + implementation-agnostic contract suites ×4 + tests; 8/8+new publics @experimental). Both workspace-registered (melos list confirms).
- **Contract surface**: EventStream<T> (+ MutableEventStream/EventStreamSink producer: emit/emitBatch/replaceAll/clear/emitError/complete; backpressure policy as data; Growth Notification Decision: delivery IS notification; Stable Identity Decision: payload-owned via RuntimeEvent); HealthSource (snapshot/watch/freshness TTL/source state; NO polling); GraphSource<TNodePayload,TEdgePayload> (semantic nodes/edges, sealed updates incl. EdgeUpdated, open typedef kinds); AsyncCommand<TParam,TResult> (lifecycle, sealed errors, cooperative CancellationToken; NO retry).
- **Purge law verification**: grep auto-scroll/followTail/Timer.periodic/retry/refresh-on-focus in runtime lib/ = **0**; flutter/dart:ui in runtime+testkit lib/ = **0**; domain leakage = **0**; graph models zero layout fields.
- **Tests or validation commands**: warp_prism_runtime dart analyze clean + 2 purity tests pass; warp_prism_testkit analyze clean + **53 tests pass** (4 contract suites: 14+7+6+8 suite tests + fake-specific + purity; backpressure behavioral ×4 strategies, in-flight cancellation, onDone/isClosed/post-close across all 4, EdgeUpdated, growth/identity dispositions); boundary harness **10/10 PASS** (check 12 runtime purity added).
- **Requirement dispositions recorded**: docs/architecture/runtime-consumer-audit.md §6.1 — HealthSource.onCellSelected → composition-owned per purge law; EventStream identity/growth → payload/delivery-owned.
- **Local changelog entry**: pending parent publication
- **Executor**: gt-builders-engineer-flutter (builder + 2 remediations, 2026-09-01)
- **Completion date**: 2026-09-01
- **Review trail**: independent review FAIL (8 findings: append surface, backpressure, in-flight cancel, cleanup, complete() state, onCellSelected, check 12, EdgeUpdated) → remediation 1 (F1-F8: producer contracts, behavioral backpressure, in-flight cancel, termination assertions, fake fix, audit §6.1 disposition, check 12, EdgeUpdated test) → review FAIL (F1 partial: identity/growth not decided) → remediation 2 (documented payload-identity + delivery-notification decisions + 6 assertive tests) → all findings closed. Final review basis: F2-F8 PASS + F1 closed via documented architectural decision per reviewer's stated acceptable path.
