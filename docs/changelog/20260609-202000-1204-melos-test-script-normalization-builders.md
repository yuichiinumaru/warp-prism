---
date: 20260609-202000
timestamp: 20260609-202000
project: warp-prism
agent: builders
task: "1204"
description: "Normalize Melos test scripts — add test-cybercore, test-boundaries, test-fast"
is_rebuild_safe: true
---

# Task 1204: Melos Test Script Normalization

## Summary

Added three missing Melos scripts to the root `pubspec.yaml` and fixed the
scoped test script pattern across all `test-*` scripts. The previous pattern
(`run: flutter test` + `packageFilters: scope:`) did not change the working
directory into the target package, causing all scoped test scripts to fail with
"Test directory not found." Fixed by using `melos exec --scope <package> -- flutter test`.

## Changes

- **Added** `test-cybercore`: runs tests scoped to `warp_prism_cybercore` (12 tests pass).
- **Added** `test-boundaries`: placeholder script that checks for
  `test/boundaries/boundary_test.dart` and skips gracefully if absent (depends on
  Task 1205).
- **Added** `test-fast`: runs tests for `warp_prism_ui` and `warp_prism_cybercore` via
  `melos exec --scope` (quick local validation gate).
- **Fixed** `test-ui`, `test-observatory`, `test-catalog`: changed from broken
  `run: flutter test` + `packageFilters` pattern to working
  `melos exec --scope <pkg> -- flutter test` pattern.
- **Untouched**: `analyze`, `format`, `test`, `validate`.

## Verification

| Script | Result | Notes |
| --- | --- | --- |
| `melos run test-cybercore` | ✅ SUCCESS | 12 tests pass |
| `melos run test-boundaries` | ✅ SUCCESS | Skips with message (Task 1205 pending) |
| `melos run test-fast` | ✅ Runs correctly | Pre-existing UI test failures (31) |
| `melos run test-ui` | ✅ Runs correctly | Pre-existing UI test failures (31) |
| `melos run test-observatory` | ✅ Runs correctly | Pre-existing observatory failures (64) |
| `melos run test-catalog` | ✅ SUCCESS | 1 test passes |
| `melos run analyze` | ⚠️ Pre-existing issue | Interactive prompt in non-TTY (not caused by this change) |

## Pre-existing Issue Noted

The `analyze` script (`melos exec -- flutter analyze` + `packageFilters: dirExists: lib`)
triggers an interactive package-selection prompt in non-interactive terminals. This is a
pre-existing issue unrelated to this task. A separate fix (e.g., `--no-select` or explicit
`--scope` list) is recommended as a follow-up.
