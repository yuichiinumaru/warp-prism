# Build-Gate Review: 1401 — Observatory Failure Baseline Inventory

**Date**: 2026-06-12
**Reviewer**: gt-build-review workflow
**Task file**: `docs/tasks/02-doing/1401-warp-prism-observatory-failure-baseline-inventory.md`

## Score: 78/100 — Good, rejected for proof drift

Task 1401 is a governance/inventory task. It created the requested inventory report and changelog, but the artifact cannot be promoted because its advertised baseline is stale against the current repository context: the task and report still claim **64** Observatory failures, while the current canonical baseline and fresh review diagnostics show **12** Observatory failures. The 12 failures are pre-existing external blockers, not Task 1401 implementation defects; the Task 1401 defect is Proof Reality drift in the governance evidence.

## Diagnostics

Commands were run from `apps/observatory/` with `TMPDIR`, `PUB_CACHE`, and `XDG_CACHE_HOME` pointed inside `warp-prism/tmp/`.

| Command | Result | Details |
|---------|--------|---------|
| `flutter analyze lib/` | FAIL | **264 issues found**. This violates Analyzer Integrity for the app gate, but the issues are in app source outside this docs-only task. First observed classes include unused `package:warp_prism_ui/warp_prism_ui.dart` imports, `prefer_const_constructors`, `prefer_const_literals_to_create_immutables`, `deprecated_member_use`, and `curly_braces_in_flow_control_structures`. |
| `dart format --output=none --set-exit-if-changed lib/ test/` | PASS | `Formatted 142 files (0 changed) in 0.68 seconds.` |
| `flutter test` | FAIL — EXTERNAL_BLOCKER | Fresh run ended at `+641 -12: Some tests failed.` This matches the current 12-failure Observatory blocker, not Task 1401's stale 64-failure claim. |
| `flutter test --coverage` | FAIL — EXTERNAL_BLOCKER | Fresh run also ended at `+641 -12: Some tests failed.` Coverage cannot be accepted as a green gate while tests fail. |

## Axiom Compliance

| # | Axiom | Status | Evidence |
|---|-------|--------|----------|
| 1 | Analyzer Integrity | PARTIAL / EXTERNAL_BLOCKER | `flutter analyze lib/` currently reports **264 issues**. Task 1401 did not modify Dart source, but the package gate is not green. |
| 2 | Lifecycle Safety | PASS | Task 1401 changed documentation only. Controllers/subscriptions/timers/listeners created: **0**. Required disposals: **0**. Missing disposals: **0**. |
| 3 | Dependency Direction | PASS | Task 1401 changed no Dart imports, no package dependencies, and no layer boundaries. |
| 4 | UI Accessibility | PASS | Interactive widgets introduced/modified: **0**. Semantics widgets required for task changes: **0**. Missing semantic labels in task changes: **0**. |
| 5 | Proof Reality | FAIL | `docs/reports/observatory-failure-baseline.md:5-8` and `docs/tasks/02-doing/1401-warp-prism-observatory-failure-baseline-inventory.md:127-130` claim **653 tests, 589 pass, 64 fail**. Current canonical baseline records **641 pass, 12 fail** at `docs/reports/warp-prism-failure-baseline-inventory.md:13-21`, and fresh review diagnostics also observed **12** failures. |
| 6 | Release Security | PASS | Task 1401 changed no release config, secrets, endpoints, signing, obfuscation, or release debug-output paths. |

## gt-build-review Flutter Checks

| # | Axiom | Status | Evidence |
|---|-------|--------|----------|
| 1 | Widget Lifecycle | SAFE | Widgets/controllers created by task: **0**; disposals required: **0**. |
| 2 | Provider Scoping | SAFE | Riverpod providers introduced/modified by task: **0**. AsyncValue renderers introduced/modified: **0**. |
| 3 | Const Constructors | SAFE | Dart widgets introduced/modified by task: **0**. App analyzer has const-info debt, but not from this task. |
| 4 | Semantic Labels | SAFE | Interactive widgets introduced/modified by task: **0**; missing task-scoped semantic labels: **0**. |
| 5 | Type Safety | SAFE | Dart lines introduced by task: **0**. Dynamic casts / force unwraps introduced by task: **0**. |

## Warp Prism Checks

| Check | Status | Evidence |
|-------|--------|----------|
| Read-only contract | PASS | Inventory states no tests/code were modified at `docs/reports/observatory-failure-baseline.md:9` and `docs/reports/observatory-failure-baseline.md:411`. |
| DS*/Prism* boundary | N/A | Task 1401 did not change app/package imports. |
| Mock workspace fixtures | N/A | Task 1401 did not mutate fixtures. |
| Melos package boundary | N/A | Task 1401 did not touch package/app import topology. |
| Operational state vocabulary | N/A | Task 1401 did not change operational-state UI. |
| Design token usage | N/A | Task 1401 did not change UI code. |
| Gallery coverage | N/A | Task 1401 added no DS components. |
| Test coverage | PARTIAL | The task is an inventory task and does not add code tests. Current app coverage gate fails because the app has **12** pre-existing test failures. |

## Exit Conditions

| # | Condition | Met? | Evidence |
|---|-----------|------|----------|
| 1 | Observatory-specific failure inventory exists at `docs/reports/observatory-failure-baseline.md` with per-failure detail. | PARTIAL | File exists and contains per-failure sections at `docs/reports/observatory-failure-baseline.md:48-337`, but it is stale against the current **12**-failure baseline. |
| 2 | Each failure has file, test name, taxonomy class, chain position, and root cause hypothesis. | PARTIAL | The historical 64-row artifact includes those fields, but it does not reconcile to current **12** failures. |
| 3 | Local changelog entry added under `docs/changelog/`. | PASS | `docs/changelog/2026-06-09-task-1401-observatory-failure-baseline.md:1-32`. |
| 4 | Completion Evidence is filled before review handoff. | PASS | `docs/tasks/02-doing/1401-warp-prism-observatory-failure-baseline-inventory.md:125-134`. |

## Findings

### Critical

None in Task 1401's changed scope. The current Observatory test failures are classified as external/pre-existing blockers, not as defects introduced by this governance task.

### High

- [HIGH] Proof baseline is stale/contradictory — `docs/reports/observatory-failure-baseline.md:5-8` and `docs/tasks/02-doing/1401-warp-prism-observatory-failure-baseline-inventory.md:127-130` claim `653 tests, 589 pass, 64 fail`, while the current canonical baseline records `641 pass, 12 fail` at `docs/reports/warp-prism-failure-baseline-inventory.md:13-21` and fresh review diagnostics observed `+641 -12`. **Recommendation**: revise the report header and task completion evidence to mark the 64 rows as a historical 2026-06-09 snapshot or replace the report with a current 12-failure inventory.

- [HIGH] Feature-area arithmetic does not reconcile — `docs/reports/observatory-failure-baseline.md:17-28` advertises **64** failures, but the listed feature-area counts sum to **61** (`24 + 8 + 6 + 7 + 6 + 4 + 3 + 1 + 2`). **Recommendation**: correct the table so the exact row count equals the advertised total, or add a separate shared/cross-cutting bucket with an explicit count of **3**.

### Medium

- [MEDIUM] Chain-position rollup omits inventory rows — `docs/reports/observatory-failure-baseline.md:364-380` accounts for **51** failures (`11 + 26 + 3 + 11`), leaving **13** of the claimed 64 failures outside the top-down/bottom-up/model/mixed rollup. **Recommendation**: add exact chain-position buckets until the rollup remainder is **0**.

- [MEDIUM] Raw proof is not reproducible from the report — `docs/reports/observatory-failure-baseline.md:405-411` claims 64 unique `[E]` entries but links no raw log path or durable extraction block. **Recommendation**: include the exact command, final output line, and an extraction table/excerpt proving the row count.

### Low

- [LOW] Predecessor report reference is ambiguous — `docs/reports/observatory-failure-baseline.md:11` points to `docs/reports/warp-prism-test-failure-baseline.md`, while the current canonical Task 1201 inventory is `docs/reports/warp-prism-failure-baseline-inventory.md`. **Recommendation**: add a Previous Reports section that distinguishes the historical 64-failure report from the current 12-failure canonical baseline.

## External Blockers

- [EXTERNAL_BLOCKER] `flutter analyze lib/` in `apps/observatory/` currently reports **264** analyzer issues outside the Task 1401 docs-only change scope.
- [EXTERNAL_BLOCKER] `flutter test` and `flutter test --coverage` in `apps/observatory/` currently fail with **12** pre-existing test failures (`+641 -12`). These failures block a green app gate but do not prove Task 1401 modified runtime behavior.

## Patches Applied

None. Score is below 90, so gt-build-review forbids reviewer remediation and lane movement.

## Verdict

REJECTED → stays in `docs/tasks/02-doing/`.

## Path to 100

1. Update `docs/reports/observatory-failure-baseline.md:3-12` to state whether the 64-failure inventory is historical or current.
2. If historical, add a current-baseline reconciliation section listing the **12** current Observatory failures from `docs/reports/warp-prism-failure-baseline-inventory.md:87-102` and mark the historical 64 rows as superseded evidence.
3. Fix `docs/reports/observatory-failure-baseline.md:17-28` so feature-area counts sum exactly to the advertised total with remainder **0**.
4. Fix `docs/reports/observatory-failure-baseline.md:364-380` so chain-position counts cover every row with remainder **0**.
5. Add durable proof in the report: exact command, final output line, extraction method, and exact row-count reconciliation.
6. Update `docs/tasks/02-doing/1401-warp-prism-observatory-failure-baseline-inventory.md:127-130` so Completion Evidence distinguishes the historical 64-failure run from current **12**-failure diagnostics.
7. Re-run `flutter analyze lib/`, `dart format --output=none --set-exit-if-changed lib/ test/`, `flutter test`, and `flutter test --coverage` from `apps/observatory/`; document analyzer/test failures as external blockers only when their file/test identity is outside Task 1401.
