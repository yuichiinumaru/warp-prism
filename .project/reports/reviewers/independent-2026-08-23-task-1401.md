# Independent Review — Task 1401 Observatory Failure Baseline Inventory — 2026-08-23

## Review mode

Independent live re-run of the Observatory test corpus, JSON result extraction, analyzer, and suite inventory. The historical 100/100 report was not accepted without current evidence.

## Verdict

- **Score:** 84/100
- **Verdict:** `REJECTED_TO_DOING`
- **Lane recommendation:** move `docs/tasks/03-review/1401-warp-prism-observatory-failure-baseline-inventory.md` to `docs/tasks/02-doing/`

The baseline correctly describes the intended inventory methodology and the package compiles, but the current report's claimed all-green baseline is false: the live bootstrap smoke test times out.

## Findings

### F1 — CRITICAL — current inventory says zero failures, live test has one failure

`flutter test apps/observatory --concurrency=2 --no-pub` reached `+810`, then failed:

```text
The test description was:
Observatory app bootstrap smoke test

pumpAndSettle timed out
apps/observatory/test/widget_test.dart:12
```

A JSON run over `apps/observatory/test` recorded:

- `testDone`: 856
- `success`: 855
- `error`: 1 (test ID 1110, bootstrap smoke test)
- process result: failure

The current inventory at `docs/reports/observatory-failure-baseline.md` states **44 green suites / 0 non-success / +810 / 0 non-success tests** and says diagnostics are fully green. That is stale and cannot remain the current baseline.

### F2 — HIGH — the report's current pass counter is not a complete proof

The `+810` counter appears before the late bootstrap failure and therefore does not establish package success. The inventory must distinguish passed test cases from a failed run and include the failing smoke test in its per-failure table. The current report's “Package result: All tests passed!” and “Non-success tests: 0” are contradicted by the live run.

### F3 — MODERATE — analyzer magnitude is stale relative to this run

`flutter analyze apps/observatory --no-pub` exits 0 but reports **124 issues**, all INFO-level in this run, while the report claims **126 INFO**. The severity class is still INFO-only, but the inventory is required to record current measured evidence, so the count should be refreshed alongside the failure record.

## Passing evidence

- Observatory source compiles; analyzer has no errors/warnings and exits 0.
- Governance feature suite: `+104 All tests passed!`.
- `apps/observatory/lib/features` has 68 Dart files and the source itself is available for classification.
- The report has a suite universe and historical sections, but its current section needs restamping.

## Required fixes before re-review

1. Re-run the scoped Observatory package with a deterministic JSON/saved-log method and record the bootstrap timeout as a current failure (chain position likely view/bootstrap or test/runtime; retain hypothesis wording).
2. Reconcile the `+810` pre-failure counter with the process-level failure; do not claim “All tests passed!” when the run exits nonzero.
3. Refresh the analyzer count to the same-run value (currently 124 INFO) or explicitly explain why a different run is authoritative.
4. Update the suite/outcome table and files-read list; mark the previous zero-residual claim historical only.
5. Re-run the smoke test after remediation before any promotion.

## Axiom summary

| Axiom | Status |
| --- | --- |
| Analyzer integrity | PASS (0 errors/warnings; INFO debt) |
| Lifecycle safety | N/A (inventory-only) |
| Dependency direction | N/A |
| UI accessibility | N/A |
| Proof reality | FAIL — live bootstrap failure contradicts current baseline |
| Release security | PASS |

## Evidence paths

- `docs/reports/observatory-failure-baseline.md:18-31,49-60`
- `apps/observatory/test/widget_test.dart:6-14`
- `apps/observatory/test/features/governance/` (104 passing tests)
- live JSON extraction `/tmp/warp-prism-observatory-test.json` (generated during this review)
