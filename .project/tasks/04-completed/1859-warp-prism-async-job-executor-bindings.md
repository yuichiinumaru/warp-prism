# Task 1859: AsyncJobExecutor identity plus terminality standard and EventStream/HealthSource bindings

Change only the runtime spine in `warp_prism_runtime` + thin projections in
`warp_prism_bindings`: add the `AsyncJobExecutor` per-execution identity
concept (single-flight `AsyncCommand` untouched), standardise
terminality/refusal disclosure, and bind `EventStream`/`HealthSource`
(bridge-badge → real projection) with same-suite-for-fake-and-adapter proof.
Success is the stated observable behavior, verified by the relevant checks.

## Outcome and boundaries

- **Authorized outcome**: (a) `AsyncJobExecutor` concept with per-execution
  identity for concurrent jobs; `AsyncCommand` single-flight semantics
  byte-identical. (b) Terminality/refusal standard: `isTerminalMediaError`
  shape + verbatim `pathRefusedPrefix` invariant + `AssuranceLoader/Repairer`
  typedef pattern as testkit reference. (c) `EventStream` + `HealthSource`
  bindings proven against the same conformance suite for fake and adapter.
- **Subject**: `packages/warp_prism_runtime` (pure Dart, backend-agnostic) +
  `packages/warp_prism_bindings` (thin projection) + testkit fakes/suites.
- **Constraints**: runtime imports no Flutter/`dart:ui`, no FRB, no adapter,
  no presentation policy (purge law: auto-scroll, follow-tail, poll-every-X,
  retry policy, viewport all OUT). Bindings own no backend logic/storage, no
  FRB imports, never imported directly by UI widgets. `Offset` owned by the
  binding edge only. Needs runtime-architect review independent of ADS lanes.
- **Non-goals**: no new runtime contract (executor is a concept over existing
  contracts); no FRB DTO redesign; no product orchestration/daemon wiring;
  no widget work (banner is Task 1858).

## Context / reliance

- Source evidence: backlog F-11 card (WB-U8: `bridge_adapter.dart:1-33`
  import-boundary only, ~60 `setState` sites, single-flight generation/export;
  TP-U10 parity suite; Macro runtime rows); terminality
  (`media_error_mapper.dart:51-65`) + verbatim prefix invariant.
- MISSION §§4.3–4.4, 6, 7 (control vs data plane); layer-contracts §§1–3, 10.
- MISSION §3.1 + §11.4 govern on any recurrence conflict.

## Where

| Path | Role | Notes |
|---|---|---|
| `packages/warp_prism_runtime/lib/src/async_command/async_command_contract.dart` | Read | Single-flight semantics must not change; read before extension |
| `packages/warp_prism_runtime/lib/src/async_command/` | Extend | Executor concept + terminality/refusal vocabulary |
| `packages/warp_prism_runtime/lib/src/event_stream/` | Bind | Binding target (contract side) |
| `packages/warp_prism_runtime/lib/src/health_source/` | Bind | Binding target (contract side) |
| `packages/warp_prism_bindings/lib/src/` | Extend | `async_command_binding`, `event_stream_binding`, `health_source_binding` thin projections |
| `packages/warp_prism_testkit/lib/src/fakes/` | Extend | Fake executor + fake stream/health sources |
| `packages/warp_prism_testkit/lib/src/contract_tests/` | Extend | Same suite fake and adapter must pass |
| `packages/warp_prism_adapter_frb/lib/` | Proof peer | Adapter side of same-suite proof; DTO mapping only |
| `packages/warp_prism_ui/test/boundaries/boundary_test.dart` | Gate | Layer purity harness |

## Work / responsibility

- [ ] Read async-command contract/models/SLO + binding edge + testkit fake
  conventions before mutation.
- [ ] Specify executor identity model (per-execution id, concurrent-job
  isolation, cancellation/refusal disclosure) without altering `AsyncCommand`.
- [ ] Implement executor + terminality/refusal standard + stream/health
  binding projections with fakes.
- [ ] Write/extend conformance suite: per-execution identity, refusal-prefix
  verbatim, health snapshot, same-suite fake-vs-adapter parity.
- [ ] Run adapter against the same suite (FRB lifecycle proof, M §6 item 6).
- [ ] Run full validation; record results and schedule runtime-architect review.

## Success and verification

- `AsyncCommand` single-flight behavior unchanged (existing suite green).
- New suite asserts: concurrent executions carry distinct identity; refusal
  prefix verbatim; health snapshot deterministic; fake and adapter pass the
  identical suite.
- MISSION §6 gates: items 1 (mandate + macro-review runtime rows), 2–4 (fake
  + conformance + boundary), 6 (same suite real adapter + fake), 7
  (independent + runtime-architect review). Item 5 n/a unless a widget
  consumes the binding (then host proof required).
- Format/analyze/boundary clean; no presentation policy in runtime (purge-law
  scan: no auto-scroll/follow-tail/poll/retry/viewport strings).

**Validation commands**:

```sh
dart format --set-exit-if-changed packages/warp_prism_runtime/lib packages/warp_prism_bindings/lib packages/warp_prism_testkit/lib
dart analyze packages/warp_prism_runtime packages/warp_prism_bindings packages/warp_prism_testkit
flutter test packages/warp_prism_ui/test/boundaries/boundary_test.dart
flutter test packages/warp_prism_testkit
flutter test packages/warp_prism_runtime packages/warp_prism_bindings
```

## Evidence / assessment

- Bind results here: suite outputs (fake + adapter runs), health snapshot
  path, review verdicts. Partial adapter parity is explicit, never assumed.

**Parallelizable with**: Task 1858, Task 1860 — disjoint writesets
(runtime/bindings vs ADS molecules/organisms). Requires independent
runtime-architect review lane.

## Parent verification — 2026-11-01 (builders lane, post-worker return)

- **Worker**: `gtb-engineer-flutter` via User-authorized `opencode run` (`opencode-go/muse-spark-1.3-contributor`), shell `sh_1970e42dd001IPLC3PfDoZqXzi`. Handoff `status: complete` received; full packet in shell output (not copied here).
- **Filesystem check**: new executor + terminality + fakes + contract suites + 2 parity tests present; contract file sha `a737d63f…` matches worker's before/after claim (the `git diff` vs HEAD on that file is pre-existing worktree drift — F1 single-flight doc block + path fix — predating this wave, not a worker mutation); 1876's UI files untouched; boundary additive-only.
- **Parent re-run (fresh, after return)**: `dart format` on 3 lib dirs → 0 changed exit 0; `dart analyze` 4 packages → No issues found; boundary harness → **53/53 PASS exit 0**; executor unit + suite-on-fake → **24 pass**; adapter live-native parity → **14/14**; binding parity → **2/2** (new-scope 40/40, matches worker claim).
- **Not re-run by parent**: full testkit 84 + runtime+bindings 67 (worker-fresh green output accepted as evidence input; re-proof belongs to independent review).
- **Known residuals**: 7 pre-existing lib files whitespace-reformatted by mandated `dart format` (semantic no-op; parent may `git checkout` them — parent-owned VCS decision, explicitly not taken here); bindings lib intentionally proof-only; runtime-architect review still required (assurance routing, recorded — NOT self-granted).
- **Lane**: stays in `02-doing/`; submission move belongs to the authorized actor after independent review. Independent review (MISSION §6 gate 7) still required — NOT self-granted.

## Review Ledger — 2026-11-06 (independent bundled review, BUILDER_CONTEXT)

- **Reviewer**: fresh `gtr-reviewer-flutter` session `ses_e519a6438ffeiur7fRB9no1jas` (independent — did not build). Report: `.project/reports/reviewers/1859-warp-prism-async-job-executor-bindings-review-loop.md` (Entry 1, new file).
- **Verdict**: PASS (88/100 diagnostic). No remediation; two cosmetic non-mandatory notes only.
- **Accepted evidence**: contract byte-identity verified (sha256 prefix match, F1 doc block intact, authoritative-generation guard implements it); format 49 files 0-changed; analyze 0 errors (1 pre-existing 1860-owned info); runtime+bindings 83 (2/2 parity); testkit 130; boundary 81/81; EXPERIMENTAL containment; single-flight preserved; executor purely additive.
- **Lane**: stays in `02-doing/` pending closeout mechanics. No promotion claimed.

## Promotion — 2026-11-06 (parent closeout batch)

- Independent acceptance: PASS 88/100; contract byte-identity verified, runtime+bindings 83, testkit 130, boundary 81/81 (see Review Ledger above for report path).
- Lane: promoted to `04-completed` by parent (orchestrator-karax). No product files changed in promotion.
- Promotion changelog entry: `.project/changelog/20261106-235900-1859-warp-prism-async-job-executor-bindings-promoted-orchestrator-karax.md`. Canonical index/views rebuild pending (changelog tool unreachable this session; no hand-edits to generated surfaces).
