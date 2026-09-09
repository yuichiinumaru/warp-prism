# PLAN — 03-Review Lane Drain (36 parked tasks)

> **⚠️ Evidence note (2026-08-31 source-reality review)**: Task 1805's exit conditions reference desktop `integration_test` captures — **harness now verified to exist** (`apps/catalog/integration_test/visual_acceptance_capture_test.dart`, `apps/observatory/integration_test/observatory_visual_capture_test.dart`, typography smoke). The audit-era "unverified harness" risk is retired; reviewer must still confirm the captures are current and PASS.

> **Planning Status**: Drain plan; blocks new task promotions until wave 1 completes.
> **Origin**: 2026-08-29 audit — lane at 36 tasks while architects planned EPIC-19+; pyramid-debt risk.
> **Reality check (verified 2026-08-29):** EPIC-18 execution already happened in builder sessions: 1800 completed; 1801–1809 in `03-review` (incl. builder-added 1809 Taldarim/Talon themes, P3, scheduled after 1805 gate). `01-open` empty, `02-doing` empty, `04-completed` = 132.

---

## 1. Why drain first

- 36 parked review tasks = review-attention starvation for anything new.
- EPIC-19 charter says visual behavior is parented by EPIC-18 until closure — but EPIC-18's own gate (1805 human screenshot approval) is **inside the parked queue**.
- New promotions (EPIC-20+ stories → tasks) must not enter a 36-deep queue.

## 2. Triage (3 buckets, by review cost)

| Wave | Bucket | Tasks | Why first |
|---|---|---|---|
| **W1 — EPIC-18 finale** (blocking) | Visual-reset chain | **1805** (gate — HUMAN sign-off pending), then 1801, 1802, 1803, 1804, 1806, 1807, 1808 | 1805 unblocks goldens + bakes final palette; everything else in the chain is downstream evidence of the same visual work |
| **W2 — EPIC-17 form primitives** | Atoms/molecules 1700–1707 | 1700, 1701, 1702, 1703, 1704, 1705, 1706, 1707 | homogeneous batch; same component pattern; 1806's reconciliation already routes their visual clauses |
| **W3 — legacy EPIC-15/16 + stragglers** | Organisms + audits | 1504–1517 (13 tasks), 1616, 1617, 1106, 1302, 1401 | oldest debt; lowest urgency; pure review closeout |

## 3. Sequence

```
W1.1  1805 human screenshot gate          ← USER involvement required (single approval act)
W1.2  1801→1808 batch review (same-logic family, reviewer processes as one wave)
      1809 stays parked (P3, deliberately after-gate; move with W2)
W2    1700–1707 batch review (EPIC-17 closeout; fold in 1806's visual reconciliation matrix)
W3    1504–1517 + 1616/1617 + 1106/1302/1401 closeout
```

**Promotion freeze rule:** no new task promotion into `01-open` until W1.2 completes. Planning artifacts (EPIC-19+ files) are NOT tasks — they stay in `00-planning` untouched by this freeze.

## 4. Who does what

- **1805 gate**: USER signs off the screenshot (contract doc + Task 1800's approved target). Orchestrator prepares the comparison packet; cannot self-approve.
- **W1.2–W3**: reviewer subagent waves (`gt-reviewers-*`), batched per family; orchestrator reconciles cross-task findings centrally.
- **Golden regeneration**: only after 1805 approval, once (per 1800 interim freeze policy).

## 5. Exit conditions

- [ ] W1.1: 1805 human sign-off recorded in task file + contract doc
- [ ] W1.2: 1801–1808 each `Review Approved` → `04-completed`
- [ ] W2: 1700–1707 (+1809) approved → `04-completed`
- [ ] W3: remaining 17 tasks approved → `04-completed`
- [ ] Lane `03-review` count ≤ 0 (or every remaining item has an explicit block reason)
- [ ] Drain report written to `docs/reports/` with per-wave verdicts
