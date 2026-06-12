# Warp Prism — Stabilization Strategy Report

> **Date**: 2026-06-09
> **Author**: architects (architect-orchestrator)
> **Scope**: Planning intervention — no code changes.
> **Status**: Active strategy document.

---

## 1. Executive Summary

The Warp Prism project has completed a massive builder wave: the Melos monorepo
is operational, the ADS package (`warp_prism_ui`) has 83 Dart files across all
atomic design layers, the Observatory app has full feature coverage, the CyberCore
pilot exists with fixtures and 5 routes, and the catalog app renders the ADS
gallery. The codebase totals ~53,000 lines of Dart.

**The problem is not lack of code. The problem is lack of promotion confidence.**

- 95 test failures are accepted as "pre-existing" (31 in UI package, 64 in Observatory).
- 79 tasks sit in `02-doing/` with no formal distinction between "builder done" and
  "ready for promotion."
- The test suite detects failures well but does not govern promotion.
- The `DS*` vs `Prism*` namespace split is unresolved.
- The catalog test is near-irrelevant (1 smoke test).
- No golden tests, no boundary tests, no review packets exist.

This report defines the stabilization strategy: **stop expanding product; start
governing promotion.**

---

## 2. Strategy: Three-Phase Stabilization

### Phase 1 — Governance Foundation (EPIC-12)

**Goal**: Make the project know, deterministically, when something is ready for
promotion.

| Deliverable | Task | What It Fixes |
|-------------|------|---------------|
| Failure baseline inventory | 1201 | Maps all 95 failures with taxonomy. |
| Promotion state model | 1202 | Replaces `[x] Done` with explicit states. |
| Gate matrix | 1203 | Defines which gates each task type must pass. |
| Melos script normalization | 1204 | Adds `test-cybercore`, `test-boundaries`, `test-fast`. |
| Boundary test harness | 1205 | Automates package purity enforcement. |
| Pre-existing failure policy | 1206 | Makes "pre-existing" auditable, not a bypass. |
| Review packet generator | 1207 | Economizes reviewer quota. |

**Phase 1 does not fix any code.** It creates the governance layer that makes
subsequent fixes trustworthy.

**Estimated effort**: 5-8 builder sessions + 1-2 reviewer sessions.

### Phase 2 — ADS Contract Stabilization (EPIC-13)

**Goal**: Make `warp_prism_ui` pass its own package gate with zero failures.

| Deliverable | Task | What It Fixes |
|-------------|------|---------------|
| Prism namespace remediation | 1301 | CyberCore uses only `Prism*` names. |
| Public barrel audit | 1302 | Definitive export manifest. |
| Component contract reconciliation | 1303 | Fixes 8+ contract test failures. |
| Gallery compile cleanup | 1304 | Fixes ~200 compilation errors in gallery. |
| Catalog contract expansion | 1305 | Catalog becomes a real proof surface. |
| Golden baseline MVP | 1306 | 5 golden baselines for canonical components. |
| Accessibility reconciliation | 1307 | Fixes accessibility test failures. |
| Toast async stabilization | 1308 | Fixes 7 timing/async test failures. |
| State vocabulary reconciliation | 1309 | Fixes state surface test failures. |

**Phase 2 is the highest-value phase.** It turns the ADS from "components that
compile" into "a contract that can be trusted."

**Estimated effort**: 8-12 builder sessions + 2-3 reviewer sessions.

### Phase 3 — Observatory Reconciliation (EPIC-14)

**Goal**: Make the Observatory test suite green.

| Deliverable | Task | What It Fixes |
|-------------|------|---------------|
| Observatory failure inventory | 1401 | Maps all 64 failures by chain position. |
| Corpus/frontmatter audit | 1402 | Determines if corpus or parser is wrong. |
| Parser reconciliation | 1403 | Fixes parser/projection failures. |
| View-model reconciliation | 1404 | Fixes provider/repository/service failures. |
| Detail variant reconciliation | 1405 | Fixes detail view failures. |
| History/operate reconciliation | 1406 | Fixes feature flow failures. |
| Test retirement audit | 1407 | Archives tests for dead architecture. |
| Import cleanup | 1408 | Fixes fragile relative imports. |

**Phase 3 depends on Phase 2** because Observatory imports from `warp_prism_ui`.

**Estimated effort**: 8-12 builder sessions + 2-3 reviewer sessions.

---

## 3. Dependency Chain

```
Phase 1 (EPIC-12): 1201 → 1202 → 1203 → 1204 → 1205
                         ↓        ↓
                        1208     1206, 1207

Phase 1.5 (quick wins): 1126 (README alignment)

Phase 2 (EPIC-13): 1301 → 1302 → 1303 → 1304 → 1305 → 1306
              1307 (parallel after 1303)
              1308 (parallel, isolated)
              1309 (parallel after 1303)

Phase 3 (EPIC-14): 1401 → 1402 → 1403 → 1404 → 1405 → 1406 → 1407
                                                       1408 (parallel)
```

Phases can overlap: Phase 2 can start once 1201-1203 are done. Phase 3 can
start once Phase 2 is mostly done (ADS package stable).

---

## 4. What This Strategy Does NOT Do

- Does not create new product features.
- Does not expand CyberCore beyond namespace migration.
- Does not add live API or runtime mutation.
- Does not touch OmniRoute.
- Does not add new ADS components.
- Does not restructure the Melos monorepo.

---

## 5. Success Criteria

The stabilization wave is complete when:

| Criterion | Gate |
|-----------|------|
| `flutter test packages/warp_prism_ui/` | 0 failures |
| `flutter test apps/observatory/` | 0 failures (or classified residual) |
| `flutter test apps/catalog/` | Proves all sections render, not just smoke |
| `flutter test apps/cybercore/` | 0 failures |
| `dart tool/test_boundaries.dart` | All checks pass |
| `rg "DS[A-Z]" apps/cybercore/lib` | 0 matches |
| Golden tests exist | At least 5 baselines pass |
| Promotion state model is active | Tasks use new status markers |
| Review packets are produced | At least 5 tasks have packets |

---

## 6. Risk Analysis

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| Flutter SDK unavailable in execution environment | Known | Critical | Document tooling gaps. Do not claim tests pass without running them. |
| Scope creep into feature work | Medium | High | This strategy is explicitly "no new features." Builders must resist the urge to improve components while fixing contracts. |
| Pre-existing failures turn out to be real regressions | Medium | Medium | The failure inventory (1201) will surface these. Classify honestly. |
| Toast/test flakiness persists after fix | Low | High | Task 1308 requires running tests 3 times to verify determinism. |
| Phase 3 takes longer than estimated | Medium | Low | Observatory is less critical than ADS. Phase 3 can be deprioritized if Phases 1-2 complete. |

---

## 7. Recommended Execution Order

1. **1201** — Failure Baseline Inventory (the map)
2. **1202** — Promotion State Model (the rules)
3. **1208** — Existing Task Lane Reconciliation (the backlog triage)
4. **1126** — README Monorepo Reality Alignment (the quick win)
5. **1301** — Prism Namespace Remediation (the blocker)
6. **1205** — Boundary Test Harness (the guardrail)
7. **1304** — Gallery Compile Cleanup (the unblocker)
8. **1303** — Component Contract Reconciliation (the fix)
9. **1308** — Toast Async Stabilization (the flaky fix)
10. **1309** — State Vocabulary Reconciliation (the state fix)
11. **1206** — Pre-existing Failure Policy (the policy)
12. Everything else in dependency order.

---

## 8. Task Inventory Summary

| Epic | Tasks | Priority | Phase |
|------|-------|----------|-------|
| EPIC-12 | 1201-1208 (8 tasks) | P0-P1 | Governance Foundation |
| EPIC-13 | 1301-1309 (9 tasks) | P0-P1 | ADS Stabilization |
| EPIC-14 | 1401-1408 (8 tasks) | P0-P1 | Observatory Reconciliation |
| Quick win | 1126 (1 task) | P1 | README alignment |
| **Total** | **26 tasks** | | |

All tasks are in `docs/tasks/01-open/`. None are in `02-doing/`. The promotion
state model (Task 1202) will define when they move lanes.
