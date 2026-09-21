# Build-Gate Review: 1204 — Melos Test Script Normalization

**Date**: 2026-06-11
**Reviewer**: reviewer
**Task file**: docs/tasks/02-doing/1204-warp-prism-melos-test-script-normalization.md
**Review mode**: Path-to-100 re-review
**Previous report**: This file, prior score 68/100

## Score: 94/100

## Verdict

ACCEPTED for the task-scoped Melos normalization contract. No lane move was performed.

The prior rejection blockers are resolved: repository-local `dart run melos run <script>` entrypoints now execute without depending on a globally installed `melos`, existing scripts are honestly documented as semantically preserved but normalized, and `test-boundaries` runs the Task 1205 pure-Dart harness.

The remaining deductions are not task regressions: the repository-wide analyzer and full test gate are still red due to pre-existing, unrelated codebase debt outside Task 1204's touched surface.

## Review Lineage

- **Current task**: Task 1204 (`docs/tasks/02-doing/1204-warp-prism-melos-test-script-normalization.md`)
- **Previous reports read**:
  - `docs/reports/build-gate-review/1204-review.md` — prior 68/100 rejection
- **Related evidence read**:
  - `docs/tasks/03-review/1205-warp-prism-boundary-test-harness.md` — pure-Dart boundary harness evidence
  - `docs/governance/pre-existing-failure-policy.md` — pre-existing failure classification policy
  - `docs/reports/warp-prism-test-failure-baseline.md` — baseline inventory for Observatory failures

## Delta Summary

### Resolved Since Previous Review

- `RESOLVED`: Script bodies no longer require global `melos`; nested Melos calls now use repository-local `dart run melos` at `pubspec.yaml:22`, `pubspec.yaml:26`, `pubspec.yaml:30`, `pubspec.yaml:34`, `pubspec.yaml:38`, `pubspec.yaml:42`, `pubspec.yaml:46`, `pubspec.yaml:54`, and `pubspec.yaml:58`.
- `RESOLVED`: `test-boundaries` now invokes the pure-Dart harness directly at `pubspec.yaml:50`; the harness itself uses only `dart:io` at `packages/warp_prism_ui/test/boundaries/boundary_test.dart:1` and exposes a CLI `main` at `packages/warp_prism_ui/test/boundaries/boundary_test.dart:3`.
- `RESOLVED`: The task contract now states existing scripts preserve semantics while being normalized, not that they remain byte-for-byte unchanged (`docs/tasks/02-doing/1204-warp-prism-melos-test-script-normalization.md:50`, `docs/tasks/02-doing/1204-warp-prism-melos-test-script-normalization.md:62`, `docs/tasks/02-doing/1204-warp-prism-melos-test-script-normalization.md:80`).
- `RESOLVED`: Boundary evidence no longer claims a skip; it records 4/4 PASS at `docs/tasks/02-doing/1204-warp-prism-melos-test-script-normalization.md:137`.

### Persistent Findings

- None from the prior report remain open against Task 1204.

### Regressions

- None found.

### New Findings

- `NEW`: Repository-wide analyzer gate is red with 957 info-level issues: 593 in `warp_prism_ui` and 364 in `warp_prism_observatory`. This is a pre-existing, unrelated codebase gate blocker, not a Task 1204 regression.
- `NEW`: Repository-wide `test` gate is red with 12 Observatory failures. These failures are in baseline-owned Observatory areas and unrelated to Task 1204's touched files.

## Axiom Compliance

| Axiom | Status | Evidence |
|-------|--------|----------|
| Analyzer Integrity | PARTIAL | Task-scoped boundary harness analyzes clean: `dart analyze packages/warp_prism_ui/test/boundaries/boundary_test.dart` -> no issues. Repository analyzer remains red: `dart run melos run validate` stops at `analyze` with 593 UI issues and 364 Observatory issues. The active lint rules are not suppressed in `packages/warp_prism_ui/analysis_options.yaml:5` and `apps/observatory/analysis_options.yaml:5`. |
| Lifecycle Safety | PASS | Task-touched lifecycle surface count: 0 `TextEditingController`, 0 `ScrollController`, 0 `AnimationController`, 0 `StreamSubscription`, 0 `Timer`, 0 listener registrations, 0 `dispose()` required, 0 `dispose()` present. Touched files are Melos YAML and a pure-Dart filesystem harness. |
| Dependency Direction | PASS | Boundary harness passes all 4 checks. Checks are defined at `packages/warp_prism_ui/test/boundaries/boundary_test.dart:95`: CyberCore zero `DS*`, no consumer `src/` imports, UI package no Riverpod/GoRouter imports, UI package no app-specific imports. |
| UI Accessibility | PASS | Task-touched UI surface count: 0 interactive widgets, 0 `Semantics` required, 0 `Semantics` present. No UI widget code changed by Task 1204. |
| Proof Reality | PARTIAL | Required task proof passes: `test-cybercore` 12 tests PASS, `test-boundaries` 4/4 PASS, `test-fast` UI 850 + CyberCore 12 tests PASS, `test-catalog` 10 tests PASS. Full `test` and `validate` are red due to pre-existing unrelated Observatory test failures and analyzer lint debt. No coverage claim was made. |
| Release Security | PASS | No release, signing, permissions, endpoint, token, or secret surface changed. Dependency versions are constrained, not `any`: root SDK at `pubspec.yaml:5`, Melos constraint at `pubspec.yaml:12`. |

## Diagnostics

| Command | Result | Exact Count / Details |
|---------|--------|-----------------------|
| `dart run melos run test-cybercore` | PASS | 12 tests passed in `warp_prism_cybercore`; scoped script at `pubspec.yaml:44-46`. |
| `dart run melos run test-boundaries` | PASS | Boundary harness reports 4/4 PASS, 0 FAIL, 0 violations; script at `pubspec.yaml:48-50`. |
| `dart run melos run test-fast` | PASS | Runs `test-ui` then `test-cybercore` via `pubspec.yaml:52-54`; UI 850 tests PASS, CyberCore 12 tests PASS. |
| `dart run melos run test-catalog` | PASS | 10 tests passed in `warp_prism_catalog`; existing script semantics preserved at `pubspec.yaml:40-42`. |
| `dart run melos run format` | PASS | 4 packages formatted, 0 files changed: Catalog 2, CyberCore 19, Observatory 141, UI 122. |
| `dart analyze packages/warp_prism_ui/test/boundaries/boundary_test.dart` | PASS | No issues found. |
| `dart run melos run test` | FAIL | Script executes non-interactively, but `warp_prism_observatory` has 12 failures. Other packages pass: UI 850, Catalog 10, CyberCore 12. |
| `dart run melos run validate` | FAIL | Script executes non-interactively and fails at `analyze`: 593 UI issues + 364 Observatory issues = 957 info-level issues. |
| `dart pub outdated` | PASS with findings | 0 `any` dependencies found; 7 constrained dependencies are older than resolvable versions; Melos current 7.8.1, upgradable 7.8.2. |

## Findings

| ID | Class | Severity | Status | Summary | Evidence |
|----|-------|----------|--------|---------|----------|
| F1 | RESOLVED | HIGH | Closed | Previous global-`melos` dependency was eliminated. Repository-local script invocation now works for new and existing scripts. | `pubspec.yaml:22`, `pubspec.yaml:26`, `pubspec.yaml:30`, `pubspec.yaml:34`, `pubspec.yaml:38`, `pubspec.yaml:42`, `pubspec.yaml:46`, `pubspec.yaml:54`, `pubspec.yaml:58` |
| F2 | RESOLVED | HIGH | Closed | The task no longer falsely claims existing scripts are unchanged; it states semantics are preserved while implementation is normalized. | `docs/tasks/02-doing/1204-warp-prism-melos-test-script-normalization.md:50`, `docs/tasks/02-doing/1204-warp-prism-melos-test-script-normalization.md:62`, `docs/tasks/02-doing/1204-warp-prism-melos-test-script-normalization.md:80` |
| F3 | RESOLVED | MEDIUM | Closed | Boundary script no longer points at stale/Flutter-only behavior; it runs the Task 1205 pure-Dart harness and passes 4/4 checks. | `pubspec.yaml:48`, `pubspec.yaml:50`, `packages/warp_prism_ui/test/boundaries/boundary_test.dart:3`, `packages/warp_prism_ui/test/boundaries/boundary_test.dart:95` |
| F4 | EXTERNAL_BLOCKER | MODERATE | Open outside Task 1204 | Repository analyzer integrity is not globally satisfied: 957 info-level issues remain. This blocks a perfect score but is unrelated to Task 1204 because Task 1204 touched `pubspec.yaml` and the boundary harness, not the linted UI/Observatory implementation files. | `packages/warp_prism_ui/analysis_options.yaml:5`, `apps/observatory/analysis_options.yaml:5`, example Observatory lint surface `apps/observatory/lib/features/operate/operate_workspace_view_model.dart:189` |
| F5 | EXTERNAL_BLOCKER | MODERATE | Open outside Task 1204 | Full monorepo tests execute through the normalized script but fail in Observatory with 12 failures. These are within the baseline's Observatory pre-existing failure areas and Task 1204 did not modify the failing app/test files. | Baseline inventory: `docs/reports/warp-prism-test-failure-baseline.md:83`, feature areas at `docs/reports/warp-prism-test-failure-baseline.md:89`; current example failure stack points at `apps/observatory/test/app/app_shell_smoke_test.dart:20` |
| F6 | NEW | LOW | Open outside Task 1204 | Dependency freshness is not perfect: `dart pub outdated` reports 7 direct/dev dependency constraints older than resolvable versions. This is not a script-normalization defect. | Root Melos constraint at `pubspec.yaml:12`; outdated command output reports Melos 7.8.1 -> 7.8.2 and 7 older constrained dependencies. |

## Pre-existing Failure Classification

| Failure Surface | Count | Classification | Blocks Task 1204? | Evidence |
|-----------------|-------|----------------|-------------------|----------|
| Observatory tests during `dart run melos run test` | 12 current failures | Pre-existing unrelated | No | Baseline records 64 Observatory pre-existing failures at `docs/reports/warp-prism-test-failure-baseline.md:83`; Task 1204 changed `pubspec.yaml` and boundary harness only. |
| Analyzer lint debt during `dart run melos run validate` | 957 info-level issues | Pre-existing unrelated analyzer debt | No for Task 1204; yes for global 100/100 | Current counts: 593 UI + 364 Observatory. Rules are enabled, not suppressed, in `packages/warp_prism_ui/analysis_options.yaml:5` and `apps/observatory/analysis_options.yaml:5`. |

## Patches Applied During Path-to-100 Review

- Updated existing Melos script bodies to use repository-local nested Melos invocation:
  - `analyze`: `pubspec.yaml:22`
  - `format`: `pubspec.yaml:26`
  - `test`: `pubspec.yaml:30`
- Preserved existing scoped script semantics while removing global `melos` dependency:
  - `test-ui`: `pubspec.yaml:34`
  - `test-observatory`: `pubspec.yaml:38`
  - `test-catalog`: `pubspec.yaml:42`
- Confirmed new scripts are repository-local and task-aligned:
  - `test-cybercore`: `pubspec.yaml:46`
  - `test-boundaries`: `pubspec.yaml:50`
  - `test-fast`: `pubspec.yaml:54`
  - `validate`: `pubspec.yaml:58`

## Path To 100

1. Reduce repository analyzer output from 957 issues to 0:
   - Fix 593 UI analyzer issues surfaced by `dart run melos run validate`.
   - Fix 364 Observatory analyzer issues surfaced by `dart run melos run validate`.
   - Start with concrete reported files such as `apps/observatory/lib/features/operate/operate_workspace_view_model.dart:189` for `curly_braces_in_flow_control_structures`.
2. Resolve the 12 current Observatory test failures seen under `dart run melos run test`:
   - `apps/observatory/test/app/app_shell_smoke_test.dart:20` / shell-router context failure.
   - Governance analytics panel lane breakdown expectation.
   - Map/catalog no-results and tab/content expectation failures.
   - Task detail close/exit-condition expectation failures.
3. Re-run `dart run melos run validate` and require full PASS: format PASS, analyze 0 issues, all package tests PASS.
4. Re-run `dart pub outdated` after intentional dependency refresh planning; either upgrade Melos from 7.8.1 to 7.8.2 or document why it remains pinned by the current workspace constraints.
