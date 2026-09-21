# Drain Review: Task 1309 — State Vocabulary Surface Reconciliation — 2026-07-17

## Review Lineage

- **Current task**: Task 1309 (`1309-warp-prism-state-vocabulary-surface-reconciliation`)
- **Previous reports read**:
  - `docs/reports/review-wave-2026-07-09/task-1309-state-vocabulary-independent-rereview.md` — **92/100**
  - `docs/reports/build-gate-review/1309-review.md` — historical scoped 100/100
  - `docs/reports/build-gate-review/1309-review-2026-06-17-independent.md` — **78/100**
- **Review mode**: independent drain re-review
- **Policy**: S≥90 → `04-completed/`; S<90 → `02-doing/`; no git / no tasklist

## Score And Verdict

- **Prior score (draft)**: `92/100`
- **New score**: `92/100`
- **Verdict**: `ACCEPTED_WITH_PATH_TO_100`
- **Lane recommendation**: `docs/tasks/04-completed/`
- **Lane outcome**: moved to `docs/tasks/04-completed/`

## Delta Summary

### Resolved

- Live suite **35/35 PASS** — all 7 `DSStateType` constructors render + semantics coverage intact.
- Implementation still enforces `minimumSize: Size(48, 48)` on action button (`ds_state_surface.dart:339`).

### Persistent

- **F1 PERSISTENT**: no widget-test regression guard measuring action button ≥48×48 (`getSize` / `>= 48` assertions absent; `state_surface_test.dart` ends ~354 lines).

### Regressions

- None relative to 2026-07-09.

### New Findings

- None beyond prior F1 residual.

## Findings

| ID | Class | Severity | Status | Summary | Evidence |
| --- | --- | --- | --- | --- | --- |
| F1 | PERSISTENT | Moderate | Open | Touch-target size assertion missing | `rg getSize\|48\.0 test/state_surface_test.dart` → empty; impl has `minimumSize` |
| F2 | PRIOR Low | Low | Open residual | Changelog may still advertise historical 38-count | Optional hygiene |

## Exit Condition Verification

| Exit condition | Status | Live evidence |
| --- | --- | --- |
| `state_surface_test` zero failures | **PASS** | **+35 All tests passed** |
| All 7 states tested | **PASS** | empty/loading/error/disabled/stale/degraded/excluded widgets |
| Semantics labels match enum | **PASS** | semantic label cases in suite |
| Gallery covers 7 states | **PASS** | prior + code structure unchanged |
| Changelog + CE | **PASS** | present |

## Path To 100

1. Add widget test: pump `DSStateSurface.error`/`stale` with `onAction`, `tester.getSize(find.byType(OutlinedButton))`, assert `width >= 48 && height >= 48`.
2. Align changelog targeted-test count with live **35**.

## Lane Action

- Move → `docs/tasks/04-completed/` (S≥90; residual is path-to-100 polish only)
