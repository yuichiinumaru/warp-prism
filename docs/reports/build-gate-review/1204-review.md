# Build-Gate Review: 1204 — Melos Test Script Normalization

**Date**: 2026-06-11
**Reviewer**: gt-build-review workflow
**Task file**: docs/tasks/02-doing/1204-warp-prism-melos-test-script-normalization.md

## Score: 68/100 — Debt

## Diagnostics

| Command | Result | Details |
|---------|--------|---------|
| `grep -A 3 "test-cybercore" pubspec.yaml && grep -A 3 "test-boundaries" pubspec.yaml && grep -A 3 "test-fast" pubspec.yaml` | PASS | New script blocks are present. |
| `dart run melos list` | PASS | Workspace packages resolve: `warp_prism_catalog`, `warp_prism_cybercore`, `warp_prism_observatory`, `warp_prism_ui`. |
| `melos run test-cybercore` | FAIL | `/usr/bin/bash: line 1: melos: command not found` in this environment. |
| `dart run melos run test-cybercore` | FAIL | Script starts, then inner `melos exec --scope warp_prism_cybercore -- flutter test` fails with `/bin/sh: line 1: melos: command not found`. |
| `dart run melos run test-boundaries` | FAIL | Same inner global-`melos` dependency failure. |
| `dart run melos run test-fast` | FAIL | Same inner global-`melos` dependency failure. |
| `dart run melos run test-catalog` | FAIL | Existing script also fails after normalization because it now uses inner `melos exec`. |
| `dart run melos exec --scope warp_prism_cybercore -- flutter test` | PASS | Underlying CyberCore test command is valid: 12 tests passed. |
| `dart run melos exec --scope warp_prism_ui -- flutter test test/boundaries/boundary_test.dart` | PASS | Underlying boundary harness is valid: 4 tests passed. |
| `dart run melos exec --scope warp_prism_ui,warp_prism_cybercore -- flutter test` | PASS | Underlying fast subset is valid: CyberCore 12 tests and UI 854 tests passed. |
| `flutter analyze` | N/A | Housekeeping/Melos script task; no Dart implementation changed by this task. |
| `dart format` | N/A | Root YAML/config task; no Dart formatting surface changed by this task. |
| `flutter test` | N/A | Replaced by Melos script diagnostics above, which are the task contract. |
| coverage | N/A | No code/test implementation changes requiring coverage. |

## Axiom Compliance

| # | Axiom | Status | Evidence |
|---|-------|--------|----------|
| 1 | Widget Lifecycle | N/A | No widget lifecycle code changed. |
| 2 | Provider Scoping | N/A | No provider/Riverpod code changed. |
| 3 | Const Constructors | N/A | No Dart widget code changed. |
| 4 | Semantic Labels | N/A | No interactive UI changed. |
| 5 | Type Safety | N/A | No Dart code changed by this task. |

## Warp Prism Checks

| Check | Status | Evidence |
|-------|--------|----------|
| Read-only contract | ✅ | Melos config/changelog/task docs only; no runtime mutation or live service dependency added. |
| DS*/Prism* boundary | ✅ | Boundary harness exists and passes when invoked directly: `packages/warp_prism_ui/test/boundaries/boundary_test.dart:55`. |
| Mock workspace fixtures | N/A | No fixture changes. |
| Melos package boundary | ❌ | Script bodies in `pubspec.yaml:40`, `pubspec.yaml:44`, `pubspec.yaml:48`, `pubspec.yaml:52`, `pubspec.yaml:56`, and `pubspec.yaml:60` depend on a globally discoverable `melos` executable when run through repository-local `dart run melos run ...`; those script diagnostics fail. |
| Operational state vocabulary | N/A | No operational-state code changed. |
| Design token usage | N/A | No UI styling code changed. |
| Gallery coverage | N/A | No DS component added. |
| Test coverage | ⚠️ | Underlying direct Melos exec tests pass, but the task's script entrypoints fail in this environment. |

## Exit Conditions

| # | Condition | Met? | Evidence |
|---|-----------|------|----------|
| 1 | Root `pubspec.yaml` contains `test-cybercore`, `test-boundaries`, and `test-fast` scripts. | ✅ | `pubspec.yaml:50`, `pubspec.yaml:54`, `pubspec.yaml:58`. |
| 2 | `melos run test-cybercore` runs tests in `apps/cybercore/` only. | ❌ | `pubspec.yaml:52` defines the intended scope, but both `melos run test-cybercore` and `dart run melos run test-cybercore` failed in this environment before running tests. Direct `dart run melos exec --scope warp_prism_cybercore -- flutter test` proves the underlying scoped command is valid. |
| 3 | `melos run test-boundaries` runs the boundary test harness from Task 1205. | ❌ | `pubspec.yaml:56` points at the harness, and direct exec passes, but `dart run melos run test-boundaries` fails before executing because the script body calls `melos exec`. |
| 4 | `melos run test-fast` runs a fast subset of tests. | ❌ | `pubspec.yaml:60` points at UI + CyberCore, and direct exec passes, but `dart run melos run test-fast` fails before executing because the script body calls `melos exec`. |
| 5 | Existing scripts (`test-ui`, `test-observatory`, `test-catalog`, `validate`) are unchanged. | ❌ | The task itself says existing scripts were fixed/modified at `docs/tasks/02-doing/1204-warp-prism-melos-test-script-normalization.md:125`; changelog confirms changes at `docs/changelog/20260609-202000-1204-melos-test-script-normalization-builders.md:29`. Current `test-catalog` fails through `dart run melos run test-catalog`. |
| 6 | Local changelog entry added under `docs/changelog/`. | ✅ | `docs/changelog/20260609-202000-1204-melos-test-script-normalization-builders.md:1`. |
| 7 | Completion Evidence is filled before review handoff. | ✅ | `docs/tasks/02-doing/1204-warp-prism-melos-test-script-normalization.md:123`. |

## Findings

### Critical
- None.

### High
- [HIGH] Script entrypoints fail under repository-local Melos invocation. The new and modified script bodies call `melos exec` (`pubspec.yaml:40`, `pubspec.yaml:44`, `pubspec.yaml:48`, `pubspec.yaml:52`, `pubspec.yaml:56`, `pubspec.yaml:60`), but `dart run melos run <script>` executes those strings in a shell where `melos` is not on PATH, causing `/bin/sh: line 1: melos: command not found`. This leaves the task's core `melos run test-cybercore`, `test-boundaries`, and `test-fast` exit conditions unverified/failed.
- [HIGH] The implementation violates the explicit no-existing-script-change contract. Exit condition says existing scripts are unchanged at `docs/tasks/02-doing/1204-warp-prism-melos-test-script-normalization.md:55`, and the guardrail says only add new scripts at `docs/tasks/02-doing/1204-warp-prism-melos-test-script-normalization.md:104`; completion evidence/changelog admit existing scripts were changed at `docs/tasks/02-doing/1204-warp-prism-melos-test-script-normalization.md:125` and `docs/changelog/20260609-202000-1204-melos-test-script-normalization-builders.md:29`.

### Medium
- [MEDIUM] Completion evidence is stale/inaccurate for `test-boundaries`: it claims graceful skip while Task 1205 is pending at `docs/tasks/02-doing/1204-warp-prism-melos-test-script-normalization.md:128` and `docs/changelog/20260609-202000-1204-melos-test-script-normalization-builders.md:24`, but `pubspec.yaml:56` now points at an existing harness file and direct execution runs 4 tests from `packages/warp_prism_ui/test/boundaries/boundary_test.dart:55`.

### Low
- None.

## Patches Applied

None. Score is below 90, so gt-build-review routing requires rejection without reviewer patching.

## Verdict

REJECTED → stays in `docs/tasks/02-doing/`.

## Path to 100

1. Make Melos script bodies runnable through the repository-supported invocation path. Either require and document a global `melos` binary explicitly, or change the root scripts to avoid depending on a nested global `melos` command when invoked as `dart run melos run <script>`.
2. Restore or explicitly re-contract the existing-script rule. If `test-ui`, `test-observatory`, and `test-catalog` must change, update the task contract/changelog honestly; otherwise revert those existing scripts and add only the three requested scripts.
3. Re-run and record exact outputs for `melos run test-cybercore`, `melos run test-boundaries`, `melos run test-fast`, and at least one existing script (`test-catalog`) in the supported environment.
4. Update Completion Evidence to match current reality: `test-boundaries` no longer skips because `packages/warp_prism_ui/test/boundaries/boundary_test.dart` exists and passes when directly executed.
