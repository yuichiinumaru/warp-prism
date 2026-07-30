# Drain Review: Task 1401 — Observatory Failure Baseline Inventory — 2026-07-17

## Review Lineage

- **Current task**: Task 1401 (`1401-warp-prism-observatory-failure-baseline-inventory`)
- **Previous reports read**:
  - `docs/reports/review-wave-2026-07-10/task-1401-path-to-100-independent-rereview.md` — **98/100**
  - `docs/reports/review-wave-2026-07-09/task-1401-failure-baseline-independent-rereview.md` — **38/100**
  - Deliverable: `docs/reports/observatory-failure-baseline.md`
- **Review mode**: independent drain re-review (extreme proof-reality)
- **Policy**: S≥90 → `04-completed/`; S<90 → `02-doing/`; no git / no tasklist

## Score And Verdict

- **Prior score (draft)**: `98/100`
- **New score**: `86/100`
- **Verdict**: `REJECTED_TO_DOING`
- **Lane recommendation**: `docs/tasks/02-doing/`
- **Lane outcome**: moved to `docs/tasks/02-doing/`

## Delta Summary

### Resolved (product, not inventory currency)

- Prior residual suite `history_story_modes_test` selection-sync cases now **PASS** (31/31 in isolation; full package **+778** green).
- Full Observatory suite **0 non-success** this wave.

### Persistent / NEW (inventory)

- **REGRESSION / Proof Reality**: Inventory “current baseline” still claims **1 non-success suite / 2 errors** (`history_story_modes_test` F01). Live residual is **0**. Primary current residual table is **stale falsehood**.
- Analyzer INFO magnitude still drifts (report **164** vs prior live **155**; this wave full analyze still INFO-only / exit 0).
- Suite pass totals advanced (**+736** historical audit → live **+778**).

### Regressions

- Inventory currency regressed relative to 2026-07-10 “residual honesty holds” claim — residual no longer exists.

## Findings

| ID | Class | Severity | Status | Summary | Evidence |
| --- | --- | --- | --- | --- | --- |
| F1 | REGRESSION | High | Open | Current residual claim false (0 live failures) | `flutter test history_story_modes_test` → +31; full suite +778 |
| F2 | PERSISTENT | Low | Open | Analyzer INFO count currency | Report 164 vs live ~155 INFO class |
| F3 | NEW | Low | Open | Green totals drift (+736/+816 claims vs +778 live) | Full suite tail `+778 All tests passed` |

## Exit Condition Verification

| Exit condition | Status | Live evidence |
| --- | --- | --- |
| Inventory report exists | **PASS** | `docs/reports/observatory-failure-baseline.md` |
| Each failure has taxonomy fields | **PARTIAL** | Historical rows OK; **current** residual row is wrong |
| Live re-run matches inventory residual | **FAIL** | Claimed 2 errors; live **0** |
| Deterministic method documented | **PASS** | JSON recipe still valid |
| Changelog + CE | **PASS** | present (stale counts) |

## Live Snapshot

| Metric | Inventory claim (current) | Live 2026-07-17 |
| --- | --- | --- |
| Suites | 40 | **40** |
| Non-success suites | 1 | **0** |
| Residual tests | 2 errors | **0** |
| Full suite | ~816 green historical | **+778 All tests passed** |
| Analyzer class | INFO-only | **155 issues, 0 error/warning** |

### Commands run

```text
find apps/observatory/test -name '*_test.dart' | wc -l   # 40
flutter test --concurrency=1 --no-pub test/features/history/history_story_modes_test.dart  # +31
flutter analyze --no-pub   # 155 issues (info)
flutter test --concurrency=2 --no-pub   # +778 All tests passed!
```

## Path To 100

1. Re-run full JSON inventory method; rewrite current-baseline section to **0 non-success**.
2. Move F01 to historical “remediated residual” with date stamp.
3. Refresh analyzer INFO count and suite totals; keep historical 64/12 sections labeled historical only.
4. Update Completion Evidence + changelog with exact live counts.

## Score Math (start 100)

| Item | Delta |
| --- | --- |
| Stale residual claim (Proof Reality) | −12 |
| Totals/analyzer micro-drift | −2 |
| **Total** | **86** |

## Lane Action

- Move → `docs/tasks/02-doing/` (S<90)
