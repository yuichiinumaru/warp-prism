# Task 1821 — Runtime Contracts Promotion-Gate Evidence Pack

> **Status**: Evidence report — auditable input to Task 1825 (L1 exit gate)
> **Author**: Builder, Task 1821 · **Date**: 2026-09-01
> **Milestone Alignment**: M01 — Warp Prism v2: L1 Integration-Capable (capability 21-D)
> **Depends on**: Task 1819 (contracts + testkit), Task 1820 (bindings proof), Task 1823 (FRB substrate)
> **Blocks**: Task 1825 (Integration Readiness / L1 Exit Gate)
> **Scope note**: This report classifies lifecycle status and audits evidence. It does **not** promote anything to STABLE, does not modify any package, and does not change any `@experimental` annotation. Final promotion authority belongs to the Task 1825 gate owner.

---

## 1. Executive Verdict

Promotion rule under audit (`docs/architecture/layer-contracts-v2.md` §3.2:59-60): **PROVEN = validated by at least two distinct consumer applications or domains with stable semantics.** STABLE is explicitly out of scope for this pack.

| Contract | Code status today | In-stack consuming domains | Live app consumers of the contract | Verdict |
|---|---|:---:|:---:|---|
| **EventStream** | EXPERIMENTAL (`warp_prism_runtime.dart:10`, 47× `@experimental`) | 3 (testkit fake, bindings, FRB adapter) | **0** | **HOLD at EXPERIMENTAL** — needs-more-evidence |
| **HealthSource** | EXPERIMENTAL (`health_source_contract.dart:13-14`) | 2 (testkit fake, FRB adapter — **no binding exists**) | **0** | **HOLD at EXPERIMENTAL** — weakest evidence set |
| **GraphSource** | EXPERIMENTAL (`graph_source_contract.dart:13-14`) | 3 (testkit fake, bindings, FRB adapter) | **0** | **HOLD at EXPERIMENTAL** — needs-more-evidence |
| **AsyncCommand** | EXPERIMENTAL (`async_command_contract.dart:15-16`) | 3 (testkit fake, bindings, FRB adapter) | **0** | **HOLD at EXPERIMENTAL** — strongest PROVEN candidate post-1824 |

**Core honest finding**: `grep -rn "EventStream|HealthSource|GraphSource|AsyncCommand" apps/*/lib` → **0 hits**; `grep -rln "warp_prism_runtime" apps/` → **0 files**. The consumer counts in `docs/architecture/runtime-consumer-audit.md` §1 (e.g. "1 live app consumer" for EventStream/GraphSource, "2 real async apps" for AsyncCommand) measure **pattern-recurrence pressure** — organisms fed fixture lists (cybercore `/live-logs` feeds `PrismLogViewer` a static fixture list, audit §1.1) and apps' ad-hoc state idioms (Riverpod `AsyncValue`, local `_data/_loading/_error` triples, audit §1.4) — **not consumption of these contracts**. No consumer application consumes any runtime contract today. This distinction drives every verdict below.

---

## 2. Seven-Item Definition of Done Audit

### Item 1 — Interface definitions backend-agnostic & presentation-purged: **PASS (all 4)**

Source scan of `packages/warp_prism_runtime/lib/` (17 files, all read):

- **Imports**: only `dart:async` and `package:meta` (e.g. `event_stream_contract.dart:1-3`, `health_source_contract.dart:1-3`, `graph_source_contract.dart:1-3`, `async_command_contract.dart:1-3`). `grep -rc "package:flutter" …/lib/` → **0 files**; `dart:ui` → **0 hits**. Runtime deps = `meta: ^1.15.0` only (`pubspec.yaml`).
- **Purge-law doc contracts**: each contract carries an explicit purge statement — EventStream (`event_stream_contract.dart:50-51`), HealthSource (`health_source_contract.dart:10-12`), GraphSource (`graph_source_contract.dart:10-12`), AsyncCommand (`async_command_contract.dart:12-14`).
- **Token-level scan**: `Offset|Widget|BuildContext` appears only **twice**, both in purge-law doc comments (`graph_source_models.dart:26`, `graph_source_contract.dart:11`); the comment-stripping code-scan in `bindings/test/boundary_isolation_test.dart:80-96` confirms zero code-level occurrences. `Timer.periodic` → **0**; `autoScroll|followTail` → **0** (also enforced by `runtime/test/purity_test.dart:66-102`).
- **Model-ownership rule** (`layer-contracts-v2.md` §4.3): `GraphNode` fields are id/kind/label/status/payload/metadata only (`graph_source_models.dart:31-58`); `HealthCell` carries identity + state + latency, no geometry (`health_source_models.dart:29-64`); `RuntimeEvent` carries provenance, no viewport flags (`event_stream_models.dart:105-136`).

### Item 2 — Contract compliance suite exists in testkit: **PASS (4 suites, 40 suite tests)**

Files exist and were read in full; test counts by reading each suite:

| Suite | File | Tests (as written) | Conditional branches |
|---|---|:---:|---|
| EventStream | `warp_prism_testkit/lib/src/contract_tests/event_stream_contract_test.dart:16` | 19 | 1 (`emitError`) |
| AsyncCommand | `…/async_command_contract_test.dart:14` | 8 | 0 |
| HealthSource | `…/health_source_contract_test.dart:13` | 7 | 2 (`emitSnapshot`, `updateCell`) |
| GraphSource | `…/graph_source_contract_test.dart:13` | 6 | 3 (node ops, edge ops, `setGraph`) |

All conditional branches are **active** for the fake runs (fakes provide every mutation/emission hook), giving 40 exercised suite tests + 12 fake-behavior tests + 1 purity test = **53** — reconciles exactly with the Item 3 run.

### Item 3 — In-memory reference fake passes 100%: **PASS (53/53)**

Re-ran `cd packages/warp_prism_testkit && dart test .` → `+53: All tests passed!`. Per-file recount: `fake_event_stream_test.dart` **26** (19 suite + 7 fake-specific), `fake_async_command_test.dart` **11** (8 + 3), `fake_health_source_test.dart` **8** (7 + 1), `fake_graph_source_test.dart` **7** (6 + 1), `purity_test.dart` **1**. The fakes are genuinely exercised *through* the suites — each fake test file invokes `verify*Contract` with the fake as the implementation (e.g. `fake_event_stream_test.dart:7-26` wires `FakeEventStream<RuntimeEvent<String>>` into `verifyEventStreamContract`).

### Item 4 — ≥1 UI binding demonstrates practical consumption: **PASS at pack level; per-contract gap for HealthSource**

`warp_prism_bindings` contains 3 bindings that consume the runtime contracts as **typed constructor dependencies**, driven by testkit fakes in their tests (Task 1820 recorded 33 binding tests PASS; file recount = 11 + 9 + 11 + 2):

- `EventStreamBinding<T>` holds `final EventStream<T> source` (`event_stream_binding.dart:26`), subscribes via `source.subscribe` (:68-74), propagates error (:85-93) and completion (:95-99), enforces retained capacity (:101-105), disposes (:233-243). 11 tests in `event_stream_binding_test.dart` all drive it with `FakeEventStream` (e.g. :10, :28, :96, :119).
- `GraphSourceBinding` holds `final GraphSource<…> source` (`graph_source_binding.dart:24`), fetches snapshot + subscribes `watchUpdates` (:52-77), and correctly keeps `Offset` positions **binding-side** (`_positions: Map<String, Offset>` :32) per the Model Ownership Rule. 11 tests + 2 boundary-isolation tests.
- `AsyncCommandBinding<TParam, TResult>` holds `final AsyncCommand<TParam, TResult> command` (`async_command_binding.dart:25`), executes via `command.execute` (:73-126), cancels via token (:153-156), disposes (:202-212). 9 tests.

**Honest gap**: there is **no HealthSourceBinding** — `grep -rn "HealthSource" packages/warp_prism_bindings/lib/` → **0 hits**. HealthSource's only consumption paths today are the testkit fake and the FRB adapter. Item 4 is satisfied "at least one UI binding" for the pack, but HealthSource fails it per-contract.

### Item 5 — Error, cancellation, stream-lifecycle invariants verified: **PASS with named gaps**

Verified by reading the suites; specific test names per contract:

- **EventStream** — error: `stream error emission triggers onError callback` (:339); completion: `stream completion triggers onDone callback and sets isClosed` (:309); lifecycle: `cancelling subscription stops event delivery and releases resources` (:247), `pausing subscription suspends delivery until resumed` (:267), `stream close terminates active subscriptions, watch stream, and updates isClosed` (:517), `post-close operations fail deterministically and close is idempotent` (:547); error-on-overflow: `backpressure errorOnOverflow strategy signals error on overflow` (:444).
- **AsyncCommand** — error: `failed execution returns CommandFailure with typed CommandError` (:50); cancellation: `pre-cancelled token returns CommandCancelled and updates status` (:68), `in-flight cooperative cancellation while running returns CommandCancelled and updates status` (:98); lifecycle: `watchStatus stream emits lifecycle state transitions` (:149), `command close terminates status stream, updates isClosed, and post-close execute throws` (:187).
- **HealthSource** — lifecycle: `watch stream emits updated snapshots when state changes` (:150), `updateCell triggers snapshot update with revised aggregate state` (:180), `source close terminates watch stream, updates isClosed, and post-close queries fail` (:206); freshness: `HealthSnapshot freshness evaluation checks expiration TTL` (:40).
- **GraphSource** — lifecycle: `incremental node updates emit structured events on watchUpdates` (:112), `incremental edge updates emit structured events on watchUpdates` (:150), `whole-graph reset emits GraphReset event with new snapshot` (:185), `source close terminates watchUpdates stream, updates isClosed, and post-close queries fail` (:212).

**Named coverage gaps (specific, for §5)**: (a) HealthSource suite has **no watch-error propagation test** (no `onError` path; `FakeHealthSource` exposes no error-emission helper); (b) GraphSource suite has **no `watchUpdates` error test** and no invalid-topology semantics (dangling edge) at suite level — edge-cascade deletion is fake-specific (`fake_graph_source_test.dart:41-85`); (c) EventStream suite never exercises `pause([Future<void>? resumeSignal])` with a signal nor the `cancelOnError` flag; (d) AsyncCommand suite pins no re-entrant `execute` semantics at contract level (re-execute-cancels-active lives only in the binding, `async_command_binding.dart:81-83`) and `CommandTimeoutError` is constructed by no suite test.

### Item 6 — Boundary harness: zero Flutter/UI imports + zero domain leakage: **PASS**

Re-ran `dart run packages/warp_prism_ui/test/boundaries/boundary_test.dart --repo-root .` → **10/10 PASS, 0 FAIL, 0 violations**, including harness check 10 `warp_prism_runtime contains no Flutter imports` (`boundary_test.dart:136-138`, regex-scans import lines for `dart:ui|package:flutter`, :552-564) — the activation of layer-law Check 12. Complementary scans: `grep -rc "package:flutter" packages/warp_prism_runtime/lib/` → **0**; domain-token scan `grep -rcE "Ganthritor|OmniRoute|Cersei|CyberCore"` across `runtime/lib`, `testkit/lib`, `adapter_frb/lib`, `bindings/lib` → **0 matching files in all four**. Note: layer-law Checks 13-17 (interaction purity, bindings/adapter import direction, **core domain leakage**, FRB direct-import) remain PHASED and are not yet harness-enforced (`layer-contracts-v2.md` §5.1:112-118); the grep evidence above stands in for Check-16-style assurance in this report. Runtime's own `test/purity_test.dart` (2 tests) and testkit's `test/purity_test.dart` (1 test) additionally enforce purity at package level.

### Item 7 — Lifecycle status and promotion rationale documented: **PASS — this report is the deliverable**

Per-contract classification with objective rationale follows in §3. No annotation changes were made (the task's `Where` table permits annotation adjustment "if justified"; the honest evidence below justifies **holding** EXPERIMENTAL, so no change is warranted — see §4 for the one annotation gap found in `warp_prism_adapter_frb`).

---

## 3. Per-Contract Lifecycle Classification

### 3.1 EventStream — **HOLD at EXPERIMENTAL** (needs-more-evidence)

- **Evidence held**: 3 distinct in-stack implementation/consumption domains all green — in-memory fake (26 tests incl. full 19-test suite), UI-projection binding (`EventStreamBinding` + 11 tests), native-Rust adapter (`FrbEventStream implements MutableEventStream<RuntimeEvent<String>>`, `frb_event_stream.dart:34`, backpressure parity logic :76-100; 2 adapter tests). Documented design decisions (delivery-is-growth-notification, payload-owned identity) are encoded in the suite's `Growth notification & identity dispositions` group (`event_stream_contract_test.dart:42-224`). Recurrence pressure: 2 candidate organisms, 1 app pattern domain (audit §1.1).
- **Why not PROVEN**: (a) zero consumer applications consume the contract (grep evidence §1); the audit's own closing rule-check found all four contracts single-or-zero-consumer as of Task 1818 (`runtime-consumer-audit.md:103`), and no app adoption has occurred since; (b) the FRB adapter has passed only its 2 adapter-specific tests, not the 19-test suite — full-suite parity is precisely Task 1824's outstanding work; (c) testkit, bindings, and adapter are the Warp Prism delivery stack itself — counting them as "distinct consumer applications or domains" under §3.2 is a governance interpretation that the 1825 gate owner, not this evidence pack, should rule on (the IDS precedent, `docs/reports/1817-ids-kernel-promotion-review.md:154-158`, counted operational app domains).
- **Unblocking conditions**: 1824 full-suite parity (fake vs Rust adapter) **and** either ≥1 real consumer app adopting the contract, or an explicit 1825 ruling that in-stack architectural domains (testing / UI-projection / native-bridge) satisfy §3.2.

### 3.2 HealthSource — **HOLD at EXPERIMENTAL** (weakest evidence set)

- **Evidence held**: testkit fake + 7-test suite green (8 tests total); native adapter (`FrbHealthSource implements HealthSource`, `frb_health_source.dart:6`, native snapshot + watch :19-47; 2 adapter tests). Semantic model complete (worst-state fold `health_source_models.dart:179-198`, freshness TTL :151-157).
- **Why not PROVEN**: (a) 0 live consumers — the audit found ProviderHealthMatrix stateless with "no live health endpoints, API keys, or polling" (`runtime-consumer-audit.md` §1.3) and `Timer.periodic` in `apps/*/lib` = 0 (§5); (b) **no UI binding exists** (§2 Item 4 gap) — the presentation-consumption path that Items 4/7 assume for the other three contracts is absent here; (c) watch() semantics have only ever been exercised against a fake and a sample-emitting Rust fixture, never a real health surface. The OmniRoute provider-management pilot is the recorded future candidate.
- **Unblocking conditions**: a real health surface consumer (OmniRoute pilot or equivalent) plus a binding, or an explicit de-scope decision. Promotion on current evidence would be aspiration, not the rule.

### 3.3 GraphSource — **HOLD at EXPERIMENTAL** (needs-more-evidence)

- **Evidence held**: 3 in-stack domains green — fake (7 tests incl. 6-test suite), binding (`GraphSourceBinding` + 11 tests + 2 boundary-isolation tests proving `Offset` stays binding-side), adapter (`FrbGraphSource implements GraphSource<String, String>`, `frb_graph_source.dart:6`; 2 adapter tests incl. native `NodeAdded` broadcast). Semantic/layout split matches the Model Ownership Rule and the audit's observatory evidence (§1.2: `WorkspaceAsset`/`WorkspaceEdge` are already Offset-free in the app — but project into `PrismGraphNode`, **not** into this contract).
- **Why not PROVEN**: same shape as EventStream — 0 app-level contract consumers (observatory's map/workspace panels consume `PrismGraphCanvas` via product-local projections, a usage the Bypass-is-a-Feature clause `layer-contracts-v2.md` §4.2 explicitly permits, but bypass ≠ validation); adapter full-suite parity pends 1824; suite coverage gaps (§2 Item 5b).
- **Unblocking conditions**: same as EventStream (1824 + real app adoption, or governance ruling on in-stack domains).

### 3.4 AsyncCommand — **HOLD at EXPERIMENTAL**, flagged **strongest PROVEN candidate post-1824**

- **Evidence held**: 3 in-stack domains green with the deepest cross-domain cancellation proof — fake (11 tests incl. 8-test suite), binding (9 tests incl. re-execute-cancels-active), adapter (4 tests incl. **in-flight cooperative cancellation across FFI**: preflight check `frb_async_command.dart:41-49`, native `cancelCommand` listener :55-61, test at `adapter_test.dart:95-114`). Recurrence pressure is the strongest of the four: 2 real apps today run async loads in 2 distinct idioms (observatory Riverpod `AsyncValue` ~6 provider families; cybercore 6 pages × duplicated `_loadData` boilerplate — audit §1.4, §4), which is exactly the duplication this contract would eliminate.
- **Why not PROVEN today**: both real apps still use their ad-hoc idioms — neither consumes `AsyncCommand` (grep §1). The audit's command-state census also records **zero cancellation consumers today** (§4) — the contract's richest capability has no app-level demand signal yet, which the audit itself resolved as "expose at most a hook" (1819 disposition).
- **Unblocking conditions**: 1824 parity + first real consumer app (observatory or cybercore migration would be the natural first adoption). On the in-stack-domain reading it would already qualify; this pack still recommends holding pending the 1825 ruling for consistency across all four contracts.

---

## 4. Cross-Cutting Layer-Law Compliance Evidence

| Check | Result | Evidence |
|---|:---:|---|
| Boundary harness (10 checks) | **10/10 PASS** | §6 verbatim output; incl. `warp_prism_runtime contains no Flutter imports` |
| Runtime purity (flutter/dart:ui + presentation tokens) | **PASS** | `runtime/test/purity_test.dart` 2/2; greps 0/0 (§6) |
| Testkit purity (flutter/dart:ui) | **PASS** | `testkit/test/purity_test.dart` 1/1 within the 53/53 run |
| Domain leakage (runtime, testkit, adapter, bindings lib) | **0 files** | grep §6 (Check 16 remains PHASED in harness — `layer-contracts-v2.md:117`) |
| Annotation density — `@experimental` counts | runtime **47** / testkit **8** / bindings **11** / **adapter_frb 0** | §6 per-file list |
| Pure-Dart dependency proof | **PASS** | runtime deps = `meta` only; testkit deps = `meta`, `test`, `warp_prism_runtime` (pubspecs) |

**Annotation-completeness gap (honest finding)**: `warp_prism_adapter_frb/lib/src/*.dart` carries **zero** `@experimental` annotations on its public classes (`FrbEventStream`, `FrbAsyncCommand`, `FrbHealthSource`, `FrbGraphSource`, adapter init) and zero `Lifecycle:` doc tags, unlike runtime (47), testkit (8), and bindings (11). Layer law §3.2:56 ("All public APIs and contract interfaces must carry an explicit lifecycle annotation") is therefore unmet in that package. This pack's anti-goals forbid modifying packages, so this is recorded as a follow-up for the 1825 gate or a remediation task — not fixed here.

---

## 5. Risks, Open Questions, and Coverage Gaps

1. **Zero app-level adoption is the pack's central risk.** All four contracts are validated only inside the Warp Prism stack (testkit/bindings/adapter). Until a consumer application adopts one contract, every "distinct domain" argument is intra-stack. The audit's consumer counts must not be read as contract-consumer counts (§1 core finding).
2. **1824 parity is the sole native proof outstanding.** The 40-test contract suite has never run against `FrbEventStream`/`FrbAsyncCommand`/`FrbHealthSource`/`FrbGraphSource`; adapter evidence today is its own 10 contract tests (+3 FFI smoke = 13 total, `adapter_test.dart:39-265`), recorded PASS by Task 1823. Backpressure strategies, watch-error paths, and close-idempotency are unproven across FFI.
3. **HealthSource is the thin spot**: no binding, no watch-error suite test, no real health surface, no polling consumer anywhere (audit §5). It should not ride into PROVEN on the coattails of the other three.
4. **Named suite thinness** (from §2 Item 5): EventStream `pause(resumeSignal)`/`cancelOnError` untested; AsyncCommand re-entrant execute + `CommandTimeoutError` untested at contract level; GraphSource `watchUpdates` error propagation + invalid-topology semantics untested; HealthSource watch-error untested (no fake helper exists).
5. **Adapter annotation gap** (§4) — 1825's check 12 ("all experimental APIs tagged with explicit lifecycle state") will fail on `warp_prism_adapter_frb` unless remediated first.
6. **Open governance question for 1825**: do the three in-stack architectural domains (deterministic-testing / UI-projection / native-bridge) satisfy §3.2's "two distinct … domains"? This pack takes the conservative reading (they do not, being one delivery stack) but records the question explicitly so the gate owner rules on it rather than inheriting ambiguity.

---

## 6. Validation Command Outputs (verbatim, run 2026-09-01)

```text
$ cd packages/warp_prism_testkit && dart test . 2>&1 | tail -1
00:00 +53: All tests passed!
  per-file: fake_event_stream 26 · fake_async_command 11 · fake_health_source 8 · fake_graph_source 7 · purity 1

$ dart run packages/warp_prism_ui/test/boundaries/boundary_test.dart --repo-root .
Boundary Test Harness (pure Dart)
Checks: 10/10 PASS
[PASS] CyberCore contains zero DS* references
[PASS] Consumer apps do not import warp_prism_ui src/ paths
[PASS] warp_prism_ui does not import Riverpod or GoRouter
[PASS] warp_prism_ui does not import app-specific packages
[PASS] warp_prism_ui does not import forbidden persistence or IO packages
[PASS] All public DS declarations have Prism aliases
[PASS] Public barrel hides DS* names from consumers
[PASS] PrismTokenRegistry mutators called only by theme_editor organism
[PASS] Repository root contains no fix_/tmp_/patch_/append_/snippet_/test_ scratch files
[PASS] warp_prism_runtime contains no Flutter imports
Boundary harness: 10/10 PASS, 0 FAIL, 0 violation(s)

$ grep -rc "package:flutter" packages/warp_prism_runtime/lib/ | grep -v ":0" | wc -l
0

$ grep -rcE "Ganthritor|OmniRoute|Cersei|CyberCore" packages/warp_prism_runtime/lib/ packages/warp_prism_testkit/lib/ | grep -v ":0" | wc -l
0   (adapter_frb/lib: 0 · bindings/lib: 0 — supplementary)

$ grep -c "@experimental" packages/warp_prism_runtime/lib/ -r
  event_stream: 4+5+2 · health_source: 3+1+1 · graph_source: 13+1+1 · async_command: 13+1+1
  = 47 total (13 annotated files; export-only barrels 0)

$ wc -l docs/reports/1821-runtime-contracts-promotion-evidence.md
186

$ grep -cE "PROVEN|EXPERIMENTAL|HOLD|RECOMMEND" docs/reports/1821-runtime-contracts-promotion-evidence.md
16
```

## 7. Sources Read (evidence basis)

**Task/law/audit (4)**: `docs/tasks/01-open/1821-…md`; `docs/architecture/layer-contracts-v2.md`; `docs/architecture/runtime-consumer-audit.md`; `docs/reports/1817-ids-kernel-promotion-review.md` (domain-counting precedent); `docs/tasks/01-open/1824-…md` (parity scope).
**Runtime lib (17)**: barrel + 4 contracts + 4 models + 4 SLOs + 4 module barrels, plus `test/purity_test.dart`.
**Testkit (11)**: barrel, 4 suites, 4 fakes, 2 barrels, plus 5 test files (`fake_*_test.dart`, `purity_test.dart`).
**Bindings (10)**: barrel, 3 bindings + 2 view models + layout strategy + module barrels, 4 test files (incl. `boundary_isolation_test.dart`).
**Adapter (7)**: barrel, `adapter_init`, 4 `frb_*.dart`, `adapter_test.dart` (full read, 267 lines).
**Harness**: `packages/warp_prism_ui/test/boundaries/boundary_test.dart` (checks list + runtime check impl).
