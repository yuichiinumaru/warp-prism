# Build-Gate Review: Task 1401 — Observatory Failure Baseline Inventory — 2026-06-17

## Review Lineage

- **Current task**: Task 1401 (`docs/tasks/03-review/1401-warp-prism-observatory-failure-baseline-inventory.md` at review time).
- **Previous reports read**:
  - `docs/reports/build-gate-review/1401-review.md`
  - `docs/reports/build-gate-review/1401-review-round2.md`
  - `docs/reports/build-gate-review/1401-review-round3.md`
- **Related dependencies checked**: Task 1201 is in `03-review` with a 2026-06-17 `PASS WITH NOTES`; Task 1202 is in `02-doing` after rejection.
- **Review mode**: independent live re-review.

## Score And Verdict

- **Score**: `70/100`
- **Verdict**: `REJECTED_TO_DOING`
- **Lane recommendation**: return to `02-doing`.

## Delta Summary

### Persistent / New Findings

- `NEW`: Required dependency Task 1202 is currently rejected and in `02-doing`.
- `EVIDENCE_GAP`: Fresh Observatory test validation is blocked by current workspace contamination.
- `PERSISTENT`: The 64-failure inventory remains a historical 2026-06-09 snapshot while current Task 1201 evidence describes a later 12-failure baseline/pass-with-notes state.

## Findings

| ID | Class | Severity | Status | Summary | Evidence |
| --- | --- | --- | --- | --- | --- |
| F1 | NEW | High | Open | Required dependency Task 1202 is not satisfied. | Task 1401 declares `Depends on: 1201, 1202` at `docs/tasks/03-review/1401-warp-prism-observatory-failure-baseline-inventory.md:9`; live Task 1202 is `docs/tasks/02-doing/1202-warp-prism-promotion-state-model-definition.md:3-4` with `Review State: Doing` after rejection in `docs/reports/build-gate-review/1202-review-2026-06-17.md`. |
| F2 | EVIDENCE_GAP | High | Open | The requested live validation cannot confirm the 64-failure baseline. | Live command `flutter test apps/observatory/` failed before running tests with `apps/observatory/tmp/pub-cache/hosted/pub.dev/flutter_lints-4.0.0/pubspec.yaml is included in the workspace ... but does not have resolution: workspace`. |
| F3 | PERSISTENT | Medium | Open | The report still presents 64 failures as the active baseline without reconciling later Task 1201 evidence. | `docs/reports/observatory-failure-baseline.md:3-8` records a 2026-06-09 run with `64` failures; Task 1201's live file records a later `apps/observatory/` baseline of `+641 -12` at `docs/tasks/03-review/1201-warp-prism-test-failure-baseline-inventory.md:140-149`, and its 2026-06-17 review says fresh reruns are blocked pending cache cleanup. |

## Evidence Reviewed

- Task file: `docs/tasks/03-review/1401-warp-prism-observatory-failure-baseline-inventory.md`.
- Inventory report: `docs/reports/observatory-failure-baseline.md`.
- Dependency task/report: `docs/tasks/03-review/1201-warp-prism-test-failure-baseline-inventory.md`, `docs/reports/build-gate-review/1201-review-2026-06-17.md`, `docs/tasks/02-doing/1202-warp-prism-promotion-state-model-definition.md`, `docs/reports/build-gate-review/1202-review-2026-06-17.md`.

## Commands Run

```bash
HOME="$PWD/tmp/home" PUB_CACHE="$PWD/tmp/pub-cache" TMPDIR="$PWD/tmp" flutter test apps/observatory/
# Failed to update packages.
# apps/observatory/tmp/pub-cache/hosted/pub.dev/flutter_lints-4.0.0/pubspec.yaml is included in the workspace from ./pubspec.yaml, but does not have resolution: workspace.
```

## Path To 100

1. Repair or isolate the nested repo-local pub-cache workspace contamination under `apps/observatory/tmp/pub-cache`.
2. Rerun `flutter test apps/observatory/` and capture current failure count.
3. Reconcile `docs/reports/observatory-failure-baseline.md` with the current baseline: either mark the 64-failure inventory explicitly historical/superseded or update/create a current Observatory baseline.
4. Wait for Task 1202 to reach an acceptable review state, or explicitly narrow why the rejected promotion-state governance dependency is not gating Task 1401.
5. Refresh Task 1401 Completion Evidence and changelog to distinguish historical 64-failure evidence from current live validation.

## Task Ledger Patch Suggestion

Applied to the task file during reconciliation.
