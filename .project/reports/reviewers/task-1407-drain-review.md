# Drain Review: Task 1407 — Legacy Test Retirement or Rewrite Audit — 2026-07-17

## Review Lineage

- **Previous reports**: `review-wave-2026-07-09/task-1407-legacy-test-audit-independent-rereview.md` (**100/100**)
- **Deliverable**: `docs/reports/warp-prism-observatory-test-retirement-audit.md`
- **Review mode**: drain re-review; no git

## Score And Verdict

- **Prior**: `100/100` → **New**: `99/100`
- **Verdict**: `ACCEPTED_WITH_PATH_TO_100`
- **Lane**: `04-completed/`

## Delta / Live Proof

| Exit | Status | Evidence |
| --- | --- | --- |
| Audit report exists | **PASS** | `docs/reports/warp-prism-observatory-test-retirement-audit.md` |
| Classifications applied | **PASS** | keep+fix / rewrite decisions documented; 0 archives required |
| Remaining suite green | **PASS** | Live full suite **+778 All tests passed** (improved vs report +736) |
| Changelog + CE | **PASS** | present |

### Residual (non-blocking)

- Audit executive summary still freezes **+736**; live is **+778**. Method and classifications remain valid; count currency is path-to-100 polish only (−1).

### Spot checks

- `app_bootstrap_test.dart` **+3 PASS**
- History/operate residual surfaces green (supports retirement audit premise)

## Path To 100

1. Optional: append “2026-07-17 re-proof +778 / 0 fail” footnote to audit §0 without rewriting historical narrative.

## Lane Action

- Move → `docs/tasks/04-completed/`
