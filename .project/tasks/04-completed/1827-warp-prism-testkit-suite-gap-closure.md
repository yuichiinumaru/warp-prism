# Task 1827: Contract Testkit Suite Gap Closure

> **Priority**: 🟡 P1 · **Type**: `verification`
> **Origin**: Task 1821 named gaps + Task 1825 open item
> **Blocks**: none (independent hardening branch)
> **Depends on**: Task 1821 (Promotion Evidence — named gaps list)

## Milestone Alignment

- **Target milestone**: M01 — Warp Prism v2: L1 Integration-Capable (`docs/milestones.md`)
- **Capability / Gate advanced**: contract-suite depth — the parity instrument 1824 used and the pilot will rely on.
- **Strategic why**: 1821 named 4 uncovered contract behaviors; a thin parity suite makes future parity claims vacuous.
- **Consequence if absent**: error paths and edge semantics stay untested at contract level; pilot harvest would rediscover them as bugs.

## Objective

Close the named suite gaps in `packages/warp_prism_testkit/` contract compliance suites: (1) `EventStream pause(resumeSignal)` overload + `cancelOnError` untested; (2) `AsyncCommand` re-entrancy + `CommandTimeoutError` never constructed/tested; (3) `GraphSource watchUpdates` error path untested; (4) `HealthSource` watch-error path untested (add fake mutation helper if needed).

## Scope

- Read the 4 contract suites + their fakes (1824 parity lab depends on these signatures — do NOT break the callback API; extend, don't reshape).
- Add suite tests for each named gap: pause/resume-signal, cancelOnError, re-entrant execute (documented disposition: auto-cancel vs reject), timeout error path, watch error propagation (stream errors surface to subscribers, not swallowed), watchUpdates error path.
- All new tests conditional-compatible with the FRB adapter where applicable (extra callbacks optional so live-side can skip only for genuine substrate limits).
- Do NOT redesign contracts (gaps are coverage gaps, not contract defects — the contracts are green).

## Validation Commands

```bash
cd packages/warp_prism_testkit && dart analyze . && dart test .   # >53 pass
cd ../warp_prism_adapter_frb && flutter test test/integration/   # still 87 pass (suite extended, not broken)
cd ../.. && dart run packages/warp_prism_ui/test/boundaries/boundary_test.dart --repo-root .   # 13/13
```

## Where

| File | Purpose |
|---|---|
| `packages/warp_prism_testkit/lib/src/contract_tests/` | Extend — 4 suites with named-gap tests |
| `packages/warp_prism_testkit/lib/src/fakes/` | Extend — helpers as needed (watch-error injection etc.) |

## Exit Conditions

- [x] All 6 named behaviors covered by suite tests (pause-resumeSignal, cancelOnError, re-entrancy, CommandTimeoutError, health watch-error, graph watchUpdates error).
- [x] Testkit >53 tests pass; adapter integration suite unbroken (87+).
- [x] Boundary harness 13/13 PASS.
- [x] Local changelog entry proposed in packet.

## Completion Evidence

- **Files modified**: 4 contract suites + 2 fakes (emitWatchError/emitUpdateError helpers) + 4 fake test files.
- **Gaps closed**: G1 pause(resumeSignal) auto-resume [covered — contract signature `pause([Future<void>?])` real]; G2 cancelOnError both modes [covered — `subscribe({bool? cancelOnError})` is a genuine contract param, not invented]; G3 re-entrancy [covered — contract permits concurrent executions w/ independent results; auto-cancel = binding-layer policy, honestly tested at that layer]; G4 CommandTimeoutError [covered — construction/equality in suite + typed-error→failed lifecycle in fake test]; G5 health watch-error [covered — fake helper + suite + source stays usable]; G6 graph update-error [covered — snapshot intact after error].
- **Tests**: testkit **65/65** (53→65); adapter integration **95/95** (87→95, suite extended without callback breakage); boundary 13/13 at build time (15/15 after 1830).
- **Local changelog entry**: pending parent publication
- **Executor**: gt-builders-engineer-flutter (2026-09-02)
- **Completion date**: 2026-09-02
- **Review trail**: bundled independent review **PASS 94/100** — G1-G6 verified against real contract signatures; callback API extended not broken (95/95); nuance noted: timeout lifecycle via FakeAsyncCommand-specific test, not fully parameterized in generic suite (non-blocking coverage note).
