# Build-Gate Review: 1205 — Boundary Test Harness

**Date**: 2026-06-11
**Reviewer**: gt-build-review workflow
**Task file**: docs/tasks/02-doing/1205-warp-prism-boundary-test-harness.md

## Score: 72/100 — Good

## Diagnostics

| Command | Result | Details |
|---------|--------|---------|
| `flutter analyze lib/` | FAIL | `packages/warp_prism_ui`: 467 analyzer issues, including one warning at `lib/src/organisms/split_pane/ds_split_pane.dart:223:15` and many lint/deprecation infos. These are package-wide pre-existing issues, not caused by the boundary harness, but the gate is red. |
| `dart format --set-exit-if-changed lib/ test/` | PASS | `Formatted 122 files (0 changed) in 1.18 seconds.` |
| `flutter test test/boundaries/boundary_test.dart` | PASS | Boundary harness itself passed: 4 tests, all passed. |
| `melos run test-boundaries` | FAIL | `/usr/bin/bash: line 1: melos: command not found`. The literal task command is unavailable because `melos` is not on PATH. |
| `dart run melos run test-boundaries` | FAIL | Starts Melos but the script body invokes `melos exec ...`, which again fails with `/bin/sh: line 1: melos: command not found`. |
| `flutter test` | PASS | Full `warp_prism_ui` suite passed: `+854: All tests passed!` |
| `flutter test --coverage` | PASS | Full `warp_prism_ui` suite passed under coverage: `+854: All tests passed!`; coverage artifact generated in package coverage output. |

## Axiom Compliance

| # | Axiom | Status | Evidence |
|---|-------|--------|----------|
| 1 | Widget Lifecycle | N/A | Boundary harness contains no widgets/controllers/subscriptions; only filesystem scan helpers and `test(...)` blocks in `packages/warp_prism_ui/test/boundaries/boundary_test.dart:22-170`. |
| 2 | Provider Scoping | N/A | No Riverpod provider usage in `packages/warp_prism_ui/test/boundaries/boundary_test.dart:12-170`. |
| 3 | Const Constructors | N/A | Harness has no widget constructor tree; package-wide analyzer still reports unrelated `prefer_const_*` issues outside this task. |
| 4 | Semantic Labels | N/A | Harness has no interactive UI; boundary tests are filesystem checks. |
| 5 | Type Safety | ✅ | No `dynamic`, unchecked casts, or force unwraps in `packages/warp_prism_ui/test/boundaries/boundary_test.dart:22-52`; nullable parameter `Directory? root` is handled by `root ?? _repoRoot` at line 36. |

## Warp Prism Checks

| Check | Status | Evidence |
|-------|--------|----------|
| Read-only contract | ✅ | Test harness reads files only via `Directory.listSync` and `File.readAsLinesSync`; no writes or runtime mutation in `packages/warp_prism_ui/test/boundaries/boundary_test.dart:22-52`. |
| DS*/Prism* boundary | ✅ | CyberCore DS* regression check implemented at `packages/warp_prism_ui/test/boundaries/boundary_test.dart:57-82`; direct test run passed. |
| Mock workspace fixtures | N/A | This task does not touch product data/fixtures. |
| Melos package boundary | ✅ | `warp_prism_ui` dependency policy remains Flutter SDK only at `packages/warp_prism_ui/pubspec.yaml:10-17`; boundary tests check no app-specific imports at `boundary_test.dart:143-168`. |
| Operational state vocabulary | N/A | This task does not introduce operational-state widgets. |
| Design token usage | N/A | This task does not introduce UI styling. |
| Gallery coverage | N/A | This task adds a test harness, not a DS component. |
| Test coverage | ✅/⚠️ | Direct boundary harness has four tests for the four required checks at `boundary_test.dart:57-168`, but the required Melos entrypoint is broken. |

## Exit Conditions

| # | Condition | Met? | Evidence |
|---|-----------|------|----------|
| 1 | A Dart test exists at `packages/warp_prism_ui/test/boundaries/boundary_test.dart` that checks all 4 boundary rules. | ✅ | File exists and checks DS* in CyberCore, consumer `src/` imports, Riverpod/GoRouter imports, and app-specific imports at `boundary_test.dart:57-168`. |
| 2 | `melos run test-boundaries` executes the harness and reports pass/fail. | ❌ | Literal command failed: `/usr/bin/bash: line 1: melos: command not found`; `dart run melos run test-boundaries` also failed because script body calls `melos exec ...`. Script definition at `pubspec.yaml:54-56`. |
| 3 | The harness currently passes all 4 checks. | ✅ | Direct `flutter test test/boundaries/boundary_test.dart` passed `+4: All tests passed!`. |
| 4 | Local changelog entry added under `docs/changelog/`. | ✅ | `docs/changelog/20260609-220000-1205-boundary-test-harness-builders.md` exists and documents verification at lines 23-27. |
| 5 | Completion Evidence is filled before review handoff. | ✅ | Completion Evidence exists at `docs/tasks/02-doing/1205-warp-prism-boundary-test-harness.md:130-143`. |

## Findings

### Critical

- None.

### High

- [HIGH] Required boundary test entrypoint is not runnable in this environment. The task requires `melos run test-boundaries` to execute the harness, but `melos` is not on PATH, and even `dart run melos run test-boundaries` fails because the script body recursively invokes `melos exec ...` instead of a command that is robust when Melos is only available through `dart run`. Evidence: `pubspec.yaml:54-56`; command output `/bin/sh: line 1: melos: command not found`.
- [HIGH] Explicit no-Flutter-SDK requirement is not satisfied. The task says boundary tests must be deterministic, grep-based, and require no Flutter SDK (`docs/tasks/02-doing/1205-warp-prism-boundary-test-harness.md:43-48`), but the harness imports `package:flutter_test/flutter_test.dart` and the Melos script runs `flutter test` (`boundary_test.dart:14`; `pubspec.yaml:54-56`). This makes the harness Flutter-SDK-dependent.

### Medium

- [MEDIUM] Package analyzer gate is red. `flutter analyze lib/` reports 467 issues in `packages/warp_prism_ui`, including a warning at `lib/src/organisms/split_pane/ds_split_pane.dart:223:15`. These appear outside the task's changed file, but the build-gate workflow requires diagnostics to be recorded and scored.
- [MEDIUM] Task status metadata is stale/mismatched for review handoff: status is `[~] Doing` and Review State says `Open — unstarted task; lane mismatch` even though completion evidence claims builder completion (`docs/tasks/02-doing/1205-warp-prism-boundary-test-harness.md:3-4`, `130-143`).

### Low

- [LOW] Validation command in the task body is stale: it lists `dart tool/test_boundaries.dart` (`docs/tasks/02-doing/1205-warp-prism-boundary-test-harness.md:121-126`), but no such task-owned script is listed in the Where table and the implemented route is a Flutter test plus Melos script.

## Patches Applied

- None. Score is below 90, so gt-build-review rules prohibit reviewer patching.

## Verdict

REJECTED → stays in `docs/tasks/02-doing/`.

## Path to 100

1. Make the boundary harness satisfy the no-Flutter-SDK contract: either move the filesystem checks to a pure Dart test/CLI that uses `package:test` or a `dart run` script, or update the task contract only through proper governance if Flutter SDK dependency is intentionally accepted.
2. Fix `test-boundaries` so the required entrypoint works from a clean environment where Melos is only available as a dev dependency. Avoid a script body that depends on a globally installed `melos` binary.
3. Re-run and record: `melos run test-boundaries` (or the newly canonical pure-Dart command), `dart format --set-exit-if-changed lib/ test/`, direct boundary harness command, and applicable package analyzer/test gates.
4. Reconcile task metadata with promotion governance: set Review State/Status to the correct ready-for-review state only after gates pass, and update the stale validation command.
5. Classify package-wide analyzer failures as pre-existing only with a linked baseline/policy, or fix them before claiming a green package gate.
