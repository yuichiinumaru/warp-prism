# Build-Gate Review: Task 1309 — State Vocabulary Surface Reconciliation — 2026-06-17

## Review Lineage

- **Current task**: Task 1309 (`docs/tasks/03-review/1309-warp-prism-state-vocabulary-surface-reconciliation.md` at review time).
- **Previous reports read**: `docs/reports/build-gate-review/1309-review.md` — prior scoped 100/100 approval.
- **Related dependencies checked**: Task 1303 live path is `docs/tasks/02-doing/1303-warp-prism-component-contract-reconciliation.md` after 2026-06-17 rejection.
- **Review mode**: independent live re-review.

## Score And Verdict

- **Score**: `78/100`
- **Verdict**: `REJECTED_TO_DOING`
- **Lane recommendation**: return to `02-doing`.

## Delta Summary

### Resolved / Safe

- Source inspection confirms Task 1309's scoped semantics and touch-target changes are present in `DSStateSurface` and `state_surface_test.dart`.

### Evidence Gaps / New Findings

- `EVIDENCE_GAP`: Fresh targeted Flutter test proof could not run because current workspace resolution is contaminated by nested in-repo pub-cache artifacts.
- `NEW`: Direct dependency Task 1303 is rejected and in `02-doing`.

## Findings

| ID | Class | Severity | Status | Summary | Evidence |
| --- | --- | --- | --- | --- | --- |
| F1 | EVIDENCE_GAP | High | Open | Fresh validation for the primary exit condition is unavailable. | Live command from `packages/warp_prism_ui`: `flutter test test/state_surface_test.dart` failed before running tests with `../../apps/observatory/tmp/pub-cache/hosted/pub.dev/flutter_lints-4.0.0/pubspec.yaml is included in the workspace ... but does not have resolution: workspace`. |
| F2 | NEW | High | Open | Required dependency Task 1303 is not satisfied. | Task 1309 declares `Depends on: 1303` at `docs/tasks/03-review/1309-warp-prism-state-vocabulary-surface-reconciliation.md:10`; live Task 1303 is `docs/tasks/02-doing/1303-warp-prism-component-contract-reconciliation.md:3-4` with `Review State: Builder Done` after rejection. The 2026-06-17 Task 1303 report documents blocked targeted tests and analyzer warnings. |
| F3 | EXTERNAL_BLOCKER | Medium | Open | Boundary harness remains red in the package test surface. | Independent live boundary run returned `5/6 PASS`, failing public-barrel DS leakage at `packages/warp_prism_ui/lib/warp_prism_ui.dart:27`. This is not caused by Task 1309's scoped state-surface code, but it invalidates package-wide green claims until classified/isolated. |

## Evidence Reviewed

- Task file: `docs/tasks/03-review/1309-warp-prism-state-vocabulary-surface-reconciliation.md`.
- Source/test files: `packages/warp_prism_ui/lib/src/molecules/ds_state_surface.dart`, `packages/warp_prism_ui/lib/src/tokens/ds_operational_state.dart`, `packages/warp_prism_ui/test/state_surface_test.dart`, `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart`.
- Dependency report: `docs/reports/build-gate-review/1303-review-wave0-triage.md`.

## Commands Run

```bash
HOME="$PWD/tmp/home" PUB_CACHE="$PWD/tmp/pub-cache" TMPDIR="$PWD/tmp" flutter test test/state_surface_test.dart
# Failed to update packages.
# ../../apps/observatory/tmp/pub-cache/hosted/pub.dev/flutter_lints-4.0.0/pubspec.yaml is included in the workspace ... but does not have resolution: workspace.

HOME="$PWD/tmp/home" PUB_CACHE="$PWD/tmp/pub-cache" TMPDIR="$PWD/tmp" dart packages/warp_prism_ui/test/boundaries/boundary_test.dart --repo-root .
# Checks: 5/6 PASS; public-barrel DS leakage FAIL.
```

## Path To 100

1. Repair or isolate the repository-local workspace contamination under `apps/observatory/tmp/pub-cache` without moving/caching outside the repo.
2. Re-run `flutter test test/state_surface_test.dart` from `packages/warp_prism_ui` and capture exact pass count.
3. Reconcile the Task 1303 dependency: either wait for Task 1303 to return to `Ready For Review`, or document why the rejected component-contract task is not a live dependency for this state-surface review.
4. Re-run scoped analyzer/format/full package tests as applicable after workspace resolution is restored.
5. Keep existing semantic-label and 48x48 touch-target regression guards intact.

## Task Ledger Patch Suggestion

Applied to the task file during reconciliation.
