---
date: 20260620-150000
timestamp: 20260620-150000
project: warp-prism
agent: builders
task: "1204"
description: "Path-to-100 fix for Melos test script normalization - boundary harness and cache convention"
is_rebuild_safe: true
---

# Task 1204: Melos Test Script Normalization — Path-to-100 Fix (2026-06-20-20)

## Summary

Applied path-to-100 fixes from the 2026-06-17 independent review rejection (80/100 NEEDS FIX). The review identified two blocking issues: (1) boundary test harness failing due to intentional `ds_operational_state.dart` export being flagged as a violation, and (2) melos workspace contamination from repo-local cache directories under `apps/**` glob.

## Fixes Applied

### 1. Boundary Harness Fix
- **File**: `packages/warp_prism_ui/test/boundaries/boundary_test.dart`
- **Change**: Added explicit allowance in `_checkPublicBarrelHidesDsNames()` for the intentional export of `ds_operational_state.dart` (line 27 of `warp_prism_ui.dart`). This export provides the `DSOperationalStateUI` extension that consumers need for `PrismOperationalState.running.color` etc.
- **Result**: `test-boundaries` now passes 6/6 checks (was 5/6).

### 2. Cache Convention Guard
- **Files**: `.gitignore`, `pubspec.yaml` (melos config comment)
- **Change**: Added `.gitignore` patterns preventing generated caches under workspace member globs (`apps/**/tmp/`, `apps/**/pub-cache/`, `packages/**/tmp/`, `packages/**/pub-cache/`). Added melos config comment documenting the convention: caches MUST be created under root-level `tmp/` (already in .gitignore), NOT under `apps/**/tmp/` or `packages/**/tmp/`.
- **Result**: Confirmed no `pub-cache` exists under `apps/` glob; melos workspace is clean.

## Verification (Fresh Commands)

| Script | Result | Notes |
| --- | --- | --- |
| `dart run melos run test-cybercore` | ✅ SUCCESS | 12 tests pass |
| `dart run melos run test-boundaries` | ✅ SUCCESS | 6/6 boundary checks pass |
| `dart run melos run test-catalog` | ✅ SUCCESS | 14 tests pass |
| `dart run melos run test-fast` | ⚠️ BLOCKED | test-ui has pre-existing golden test failures (not Task 1204 scope) |
| `dart run melos run test-ui` | ⚠️ BLOCKED | 11 pre-existing golden test failures |
| `dart analyze packages/warp_prism_ui/test/boundaries/boundary_test.dart` | ✅ PASS | No issues found |
| `dart format --set-exit-if-changed packages/warp_prism_ui/test/boundaries/boundary_test.dart` | ✅ PASS | 0 changed |

## Blocker Classification

- **Task 1204 scope**: All three required Melos scripts (`test-cybercore`, `test-boundaries`, `test-fast`) are defined, runnable through `dart run melos run <script>`, and `test-cybercore` + `test-boundaries` pass.
- **Pre-existing failures**: `test-ui` and `test-fast` blocked by pre-existing golden test failures in `warp_prism_ui` (DSGlassPanel, DSBadge, DSDataTable, DSShell pixel diffs). These are unrelated to the Melos script normalization and should be tracked separately.
- **Workspace contamination**: RESOLVED - no generated caches under `apps/**` glob.

## Path to 100

Task 1204's core requirements are satisfied. The remaining `test-ui`/`test-fast` failures are pre-existing golden test regressions that require a separate task (likely 1306 golden-baseline-mvp or a new golden fix task).