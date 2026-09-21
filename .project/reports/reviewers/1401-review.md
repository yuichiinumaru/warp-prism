# Build-Gate Review: 1401 — Observatory Failure Baseline Inventory

**Date**: 2026-06-12
**Reviewer**: gt-build-review workflow
**Task file**: docs/tasks/02-doing/1401-warp-prism-observatory-failure-baseline-inventory.md

## Score: 78/100 — Good, rejected for proof drift

Task 1401 is an inventory-only governance task. It did create the requested report and changelog, and the report contains a 64-row per-failure inventory. It is not review-ready because its core proof is stale/contradictory against the current canonical baseline and because its own summary tables do not reconcile to the advertised 64 failures.

Per user context and current repository evidence, the Observatory has **12 pre-existing test failures**. Those failures are classified here as **EXTERNAL_BLOCKER**, not as Task 1401 implementation defects. The Task 1401 defect is the inventory artifact's proof reality: it still claims a fresh 64-failure baseline and contains unreconciled arithmetic.

## Diagnostics

Commands were run from `apps/observatory/` with `TMPDIR=/home/sephiroth/working/ganthritor/warp-prism/tmp`.

| Command | Result | Details |
|---------|--------|---------|
| `flutter analyze lib/` | FAIL — EXTERNAL_BLOCKER | Analyzer reported **1495 issues**. First blocking class: missing/withheld design-system exports such as `DSDetailSection`, `DSPropertyRow`, `DSText`, `DSColors`, `DSSearchBar`, and `DSBreakpoints` in Observatory code. Example: `apps/observatory/lib/features/workspace_snapshot/widgets/workspace_detail_inspector.dart:41`, `apps/observatory/lib/features/asset_detail/presentation/detail_section_builder.dart:10`, `apps/observatory/lib/features/asset_detail/presentation/responsive_detail_shell.dart:107`. This is outside Task 1401's docs-only scope. |
| `dart format --output=none --set-exit-if-changed lib/ test/` | PASS | `Formatted 141 files (0 changed) in 0.71 seconds.` |
| `flutter test` | FAIL — EXTERNAL_BLOCKER | Compile/load failures prevent a clean suite result. Output reached `+280 -22` before failure summary. First blocking class: missing DS public API symbols (`DSDetailSection`, `DSDetailInspector`, `DSBreakpoints`, `DSColors`, `DSText`) from app/test compilation. This is outside Task 1401's docs-only scope. |
| `flutter test --coverage` | FAIL — EXTERNAL_BLOCKER | Same compile/load failure class as `flutter test`; no trustworthy fresh coverage percentage can be claimed. Existing `apps/observatory/coverage/lcov.info` is stale relative to the failed run. |

## Axiom Compliance — Six-Axiom Harness

| # | Axiom | Status | Evidence |
|---|-------|--------|----------|
| 1 | Analyzer Integrity | PARTIAL / EXTERNAL_BLOCKER | `flutter analyze lib/` fails with **1495 issues**, but failures are in app/source compile boundaries outside this docs-only inventory. Task 1401 must not claim analyzer pass. |
| 2 | Lifecycle Safety | PASS for task scope | Task 1401 introduced/modified documentation only. Controllers/subscriptions/listeners created: **0**. Required disposals: **0**. Missing disposals: **0**. |
| 3 | Dependency Direction | PASS for task scope | No Dart imports or package dependencies changed by this governance inventory. |
| 4 | UI Accessibility | PASS for task scope | Interactive widgets introduced: **0**. Required Semantics/touch-target checks for task changes: **0**. Missing semantic labels in task changes: **0**. |
| 5 | Proof Reality | FAIL | The task/report claims a fresh 64-failure Observatory baseline at `docs/reports/observatory-failure-baseline.md:5-8` and `docs/tasks/02-doing/1401-warp-prism-observatory-failure-baseline-inventory.md:127-130`, while the current canonical baseline report records **12 failures** at `docs/reports/warp-prism-failure-baseline-inventory.md:13-21`. The report also has internal count drift: `docs/reports/observatory-failure-baseline.md:17-28` sums to **61**, not 64. |
| 6 | Release Security | PASS for task scope | No release paths, secrets, endpoints, signing, obfuscation, or debug-output paths changed by this docs-only task. |

## Axiom Compliance — gt-build-review Flutter Checks

| # | Axiom | Status | Evidence |
|---|-------|--------|----------|
| 1 | Widget Lifecycle | SAFE | Documentation-only task. Controllers/subscriptions/listeners created: **0**; disposals required: **0**. |
| 2 | Provider Scoping | SAFE | Providers introduced/modified: **0**. `AsyncValue` UI states introduced/modified: **0**. |
| 3 | Const Constructors | SAFE | Widgets introduced/modified: **0**. |
| 4 | Semantic Labels | SAFE | Interactive widgets introduced/modified: **0**. Semantics required: **0**. |
| 5 | Type Safety | SAFE | Dart code introduced/modified by Task 1401: **0** lines. |

## Warp Prism Checks

| Check | Status | Evidence |
|-------|--------|----------|
| Read-only contract | PASS | Inventory-only report states no tests/code modified at `docs/reports/observatory-failure-baseline.md:9` and `docs/reports/observatory-failure-baseline.md:411`. |
| DS*/Prism* boundary | EXTERNAL_BLOCKER | Current app analyzer/test failures expose missing DS exports, but Task 1401 did not touch DS imports or app code. |
| Mock workspace fixtures | N/A | Task is failure inventory, not fixture mutation. |
| Melos package boundary | N/A | Task did not change packages/apps imports. |
| Operational state vocabulary | N/A | Task did not change stateful UI. |
| Design token usage | N/A | Task did not change UI code. |
| Gallery coverage | N/A | Task did not add DS components. |
| Test coverage | PARTIAL | The task validates by failed test inventory, not by adding tests. Current coverage command cannot complete because of external app compile blockers. |

## Exit Conditions

| # | Condition | Met? | Evidence |
|---|-----------|------|----------|
| 1 | Observatory-specific failure inventory created at `docs/reports/observatory-failure-baseline.md` with per-failure detail. | PARTIAL | File exists and contains per-failure rows at `docs/reports/observatory-failure-baseline.md:48-337`; however it is stale against current 12-failure baseline and has internal count drift. |
| 2 | Each failure has file, test name, taxonomy class, chain position, and root cause hypothesis. | PARTIAL | Per-row sections contain these fields for the 64 historical failures; current canonical 12 failures are not the artifact's baseline. |
| 3 | Local changelog entry added under `docs/changelog/`. | PASS | `docs/changelog/2026-06-09-task-1401-observatory-failure-baseline.md:1-32`. |
| 4 | Completion Evidence is filled before review handoff. | PASS | `docs/tasks/02-doing/1401-warp-prism-observatory-failure-baseline-inventory.md:125-134`. |

## Findings

### Critical

None in Task 1401's changed code scope. The current app compile/test failures are classified as **EXTERNAL_BLOCKER**, not as Task 1401 defects.

### High

- [HIGH] Proof baseline is stale/contradictory: Task 1401 claims `653 tests, 589 pass, 64 fail` as fresh validation at `docs/tasks/02-doing/1401-warp-prism-observatory-failure-baseline-inventory.md:127-130` and `docs/reports/observatory-failure-baseline.md:5-8`, but the current canonical failure inventory records `641 pass, 12 fail` at `docs/reports/warp-prism-failure-baseline-inventory.md:13-21`. **Recommendation**: revise `docs/reports/observatory-failure-baseline.md` to explicitly mark the 64 rows as a historical 2026-06-09 snapshot, add a current-baseline reconciliation section for the 12 pre-existing failures, and update Task 1401 completion evidence to distinguish historical artifact proof from current gate proof.

- [HIGH] Internal count reconciliation is broken: the feature-area summary in `docs/reports/observatory-failure-baseline.md:17-28` advertises **64** total failures, but the listed rows sum to **61** (`24 + 8 + 6 + 7 + 6 + 4 + 3 + 1 + 2`). **Recommendation**: correct the table so every summary bucket sums exactly to 64, or split shared/cross-cutting failures into a separate explicitly counted bucket.

### Medium

- [MEDIUM] Chain-position rollup omits failures: `docs/reports/observatory-failure-baseline.md:364-380` accounts for **51** failures (`11 + 26 + 3 + 11`), leaving **13** of the claimed 64 unclassified in the top-down/bottom-up/model/mixed rollup. **Recommendation**: add exact buckets for governance/history/map/app/overview view failures or add an `unclassified in rollup = 0` reconciliation table that proves all 64 are covered.

- [MEDIUM] Source proof is not reproducible from the artifact: `docs/reports/observatory-failure-baseline.md:405-411` claims a fresh test run and 64 unique `[E]` entries, but no raw log path or extraction output is linked. **Recommendation**: store the raw Observatory test log under `tmp/` during the run if transient, then summarize it in the report; for durable review, include either a committed excerpt in the report or a deterministic command/output block proving the exact 64-row extraction.

### Low

- [LOW] Predecessor naming is ambiguous: `docs/reports/observatory-failure-baseline.md:11` names `docs/reports/warp-prism-test-failure-baseline.md`, while the current Task 1201 canonical inventory is `docs/reports/warp-prism-failure-baseline-inventory.md`. **Recommendation**: add a `Previous Reports` section distinguishing the historical 64-failure baseline from the current 12-failure canonical Task 1201 report.

## External Blockers

- [EXTERNAL_BLOCKER] `flutter analyze lib/` currently fails with **1495 issues** in `apps/observatory/`, dominated by missing DS public API symbols and unresolved design-system names. Example evidence: `apps/observatory/lib/features/workspace_snapshot/widgets/workspace_detail_inspector.dart:41` (`DSDetailSection` undefined), `apps/observatory/lib/features/workspace_snapshot/widgets/workspace_search_bar.dart:27` (`DSSearchBar` undefined), and `apps/observatory/lib/features/asset_detail/presentation/responsive_detail_shell.dart:107` (`DSBreakpoints` undefined). This is outside the Task 1401 docs-only inventory scope.
- [EXTERNAL_BLOCKER] `flutter test` and `flutter test --coverage` cannot complete cleanly because the same compile/load failures occur before a stable failure-count comparison can be produced. The user-provided/current canonical Observatory blocker is **12 pre-existing test failures**, not a Task 1401 regression.

## Patches Applied

None. Score is below 90, so gt-build-review forbids reviewer remediation and lane movement.

## Verdict

REJECTED → stays in `docs/tasks/02-doing/`.

The task has useful inventory content, but the proof artifact cannot be accepted while it contradicts the current canonical 12-failure baseline and fails its own count reconciliation.

## Path to 100

1. Update `docs/reports/observatory-failure-baseline.md` header to state whether the 64 failures are historical snapshot data or current data. If historical, add a new current-baseline section for the 12 pre-existing Observatory failures.
2. Fix the feature-area summary at `docs/reports/observatory-failure-baseline.md:17-28` so exact bucket totals sum to **64** for the historical snapshot, or to **12** for the current snapshot if the report is refreshed.
3. Fix the chain-position rollup at `docs/reports/observatory-failure-baseline.md:364-380` so exact bucket totals cover every inventory row with zero remainder.
4. Add reproducible proof: include the exact test command, final output line, extraction method, and a durable excerpt/table proving row count equals captured failures.
5. Update `docs/tasks/02-doing/1401-warp-prism-observatory-failure-baseline-inventory.md` Completion Evidence to distinguish current external blockers from Task 1401 validation evidence.
6. Re-run from `apps/observatory/`: `flutter analyze lib/`, `dart format --output=none --set-exit-if-changed lib/ test/`, `flutter test`, and `flutter test --coverage`. Mark analyzer/test/coverage failures as external blockers only if their file/test identity is outside Task 1401 and matches the current 12-failure baseline.
