# Wave 0 Review: Task 1306 — Golden Baseline MVP

**Date**: 2026-06-17
**Reviewer profile**: `reviewers`
**Task file reviewed**: `docs/tasks/03-review/1306-warp-prism-golden-baseline-mvp.md`
**Score**: 54/100 — Debt
**Verdict**: REJECTED → return to `02-doing`

## Findings

- **HIGH — Required golden-suite command fails on live filesystem**: `flutter test --no-pub test/goldens/` finishes `42 passed, 11 failed`. Every failure is in the retained `ds_badge_golden_test.dart` extras, with pixel diffs ranging from 10–29,927 pixels (`0.00%`–`6.23%`). The task explicitly requires the whole `test/goldens/` directory to pass, so the exit condition is unmet and the previous `54/54 PASS` evidence is stale.
- **HIGH — Cross-lane dependency is rejected/not Review Approved**: Task 1306 declares `Depends on: 1304 (gallery compiles)`. Live Task 1304 is in `docs/tasks/02-doing/` with `Review State: Package Gate Failed` and latest Wave 1 score `62/100` / rejected. Task 1306 cannot be independently approved under the orchestration contract while that declared dependency remains rejected.
- **MEDIUM — Dependency-state metadata is overstated**: Task 1306 header says `Review Approved`, while its prerequisite Task 1304 is back in doing and its own required suite currently fails. This is non-reproducible promotion evidence, not an approvable state.

## Commands Run

From `packages/warp_prism_ui/` with `TMPDIR`, `HOME`, and `PUB_CACHE` constrained inside the repo:

| Command | Result |
| --- | --- |
| `flutter analyze --no-pub test/goldens/` | PASS — no issues |
| `dart format --output=none --set-exit-if-changed test/goldens/` | PASS — 7 files, 0 changed |
| `flutter test --no-pub test/goldens/` | FAIL — 42 passed, 11 failed; all failures in badge golden comparisons |
| `flutter test --no-pub test/goldens/ds_text_golden_test.dart test/goldens/ds_glass_panel_golden_test.dart test/goldens/ds_metric_tile_golden_test.dart test/goldens/ds_shell_golden_test.dart test/goldens/ds_data_table_golden_test.dart` | PASS — canonical MVP subset 22/22 |

The full-suite failure generated comparator artifacts under `packages/warp_prism_ui/test/goldens/failures/`; they were left intact as diagnostic evidence.

## Path to 100

1. Resolve and independently approve Task 1304 first, or revise the task dependency contract through governance if gallery compilation is genuinely unnecessary for golden baseline approval.
2. Determine whether the 11 badge diffs are intended visual changes or regressions. Do not blindly update snapshots: inspect the generated master/test/diff images, fix production regression if unintended, or explicitly approve and regenerate badge baselines if intended.
3. Re-run `flutter analyze --no-pub test/goldens/`, format check, and the exact full `flutter test --no-pub test/goldens/` gate until all 54 tests pass.
4. Replace stale `Review Approved`/54-pass evidence with fresh command output.

## Routing

Task moved back to `docs/tasks/02-doing/1306-warp-prism-golden-baseline-mvp.md` after ledger annotation.
