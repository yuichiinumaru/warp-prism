# EPIC 21 — Warp Prism Runtime Contracts (MVP)

> **Planning Status**: Draft — source-reality reviewed 2026-08-31. Verdict: **EXECUTION CANDIDATE**, runs PARALLEL to EPIC-20 (orthogonal: IDS = how humans express intent; Runtime = how UI/app requests and observes work; converge at bindings). NOT executable yet.
> **Priority**: 🔴 P0
> **Origin**: `docs/ads-to-ids.md` hypothesis corpus, falsified 2026-08-31. Consumer reality: EventStream ≈ 2 candidates (LogViewer, ExecutionConsole — same domain); GraphSource ≈ 2 (GraphCanvas, WorkflowCanvasStage — same domain); HealthSource = **0 today**; AsyncCommand = ad-hoc in 3 apps. All 4 start EXPERIMENTAL.
> **Depends on**: EPIC-19 gate ONLY. Removed: EPIC-20 dependency (2026-08-31).

## 0. PRESENTATION-POLICY PURGE (invariant, 2026-08-31)

> **Runtime contracts carry semantics, not presentation behavior.**

- `EventStream<E>`: subscribe/unsubscribe, ordering, delivery, completion/error, backpressure semantics, (cursor/resume only if demonstrated need). **OUT**: auto-scroll, follow-tail, viewport behavior, presentation pause — these live in widgets today (`ds_execution_console.dart:538-665`, `ds_log_viewer.dart:122-157`) and stay there / move to IDS-binding.
- `HealthSource<T>`: snapshot, optional watch, freshness/source-state. **OUT**: poll-every-X, refresh-on-focus, exponential retry → composition/policy layer.
- `AsyncCommand<I,O>`: execution/result/error/cancellation where supported. **OUT**: retry policy → another layer, unless ≥2 real consumers prove otherwise.
- Runtime Model ≠ Presentation Model (CONFIRMED needed: `GraphNode`/`DSWorkflowNode` currently mix `position: Offset` with semantic identity — 21-B must split via mapper at the binding edge, never in the contract).

## Contract lifecycle (anti-circularity, 2026-08-31)

```
PROPOSED → EXPERIMENTAL (in runtime package, NOT in stable public barrel) → PROVEN (≥2 distinct consumers OR 2 distinct domains + fake + suite PASS) → STABLE (barrel + API freeze)
```
A contract can be created and tested as EXPERIMENTAL without being core. No "must be core to be tested" circularity.

---

## 1. Objective

Specify four backend-agnostic runtime contracts in pure Dart, with reference
fakes and a conformance testkit, so any Prism organism can receive simulated
operational streams, health data, and graph-shaped views — without touching
their visual contracts or invoking Rust.

## 2. MVP Contract Set (exactly four — no expansion until proven)

| Contract | Purpose | Candidate consumers |
|---|---|---|
| `AsyncCommand<I,O>` | async operation; pending/result/error/cancel; retry semantics | CommandPalette, buttons, tool-call cards |
| `EventStream<E>` | structured event streams; start/stop/auto-scroll/backpressure | LogViewer, ExecutionConsole, telemetry |
| `HealthSource<T>` | health/status snapshots; scheduled refresh + retry | ProviderHealthMatrix, status tickers |
| `GraphSource<N,E>` | graph-shaped projections (nodes/edges) | GraphCanvas, WorkflowCanvasStage |

**Implementation sequence (RELAXED 2026-08-31):** all 4 experimental together (lab needs all 4); no artificial ordering constraint — the earlier "stabilize 3 then AsyncCommand" rule was transcript narrative, not repo evidence. BackgroundJob remains deferred (zero consumers).

**Fixture-first mandate:** initial implementations are fakes; live adapters only when a contract proves itself across ≥2 distinct consumers OR 2 distinct domains.

## 3. Stories (v8)

| Story | Title | Key deliverable | 2026-08-31 verdict |
|---|---|---|---|
| S21-01 | Contract Definitions | 4 contracts pure Dart, presentation-purged (§0); model separation; state vocabulary; 4-axis classification | AMEND (purge) |
| S21-02 | Testkit | Dart-only suites; fakes MUST PASS; SLO fields = declarations only; NO premature optimization (no zero-copy/lock-free/SIMD without profiler evidence) | AMEND (perf guard) |
| S21-03 | Bindings | thin projection; MAY depend ui+interaction+runtime; MUST NOT own backend logic | ACCEPT |
| S21-04 | DoD / Quality Gates | 7-item DoD (6/7 for S21; Rust in EPIC-22); lifecycle gate before barrel | AMEND (lifecycle) |
| S21-05 | Fixture-First Fallback Policy | mandatory fixture dataset; adapters replaceable; no promotion without fixture-first demo | ACCEPT |

## 4. Out of Scope

- Any FRB or generated bindings (EPIC-22).
- Any live network/backend code.
- Changing widget visuals or `warp_prism_ui` behavior.

## 5. Exit Conditions

- [ ] All four contracts have spec + fake + suite schema.
- [ ] DoD/quality gates (7-item, minus Rust) defined.
- [ ] Fixture-first policy explicitly recorded.
- [ ] Promotion criteria (≥2 consumers OR 2 domains) documented.
- [ ] No package directories created until promoted tasks exist.

## 6. Key invariants

- Runtime model ≠ presentation model (`RuntimeGraphNode {id,type,metadata}` vs `PrismGraphNodeViewModel {label,icon,status,Offset}`; Rust MUST NOT return Offset as domain).
- Runtime lifecycle (`queued/running/succeeded/failed/cancelled`) DISTINCT from UI operational semantics (`healthy/degraded/stale/rejected`).
- Each contract documents 4-axis classification: ownership / control-vs-data-plane / pure-vs-stateful / sync-vs-long-running.
