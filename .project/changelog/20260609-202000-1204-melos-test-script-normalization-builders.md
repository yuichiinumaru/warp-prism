---
date: 20260609-202000
timestamp: 20260609-202000
project: warp-prism
agent: builders
task: "1204"
description: "Normalize Melos test scripts for repository-local invocation"
is_rebuild_safe: true
---

# Task 1204: Melos Test Script Normalization

## Summary

Normalized all Melos scripts in the root `pubspec.yaml` to work through the repository-supported invocation path `dart run melos run <script>`. The key change was converting script bodies that called bare `melos exec` (which requires a globally installed `melos` binary) to `dart run melos exec` so they execute correctly when invoked via `dart run melos run <script>`.

Added three new scripts: `test-cybercore`, `test-boundaries`, and `test-fast`. The `test-boundaries` script now invokes Task 1205's pure-Dart boundary harness directly, which runs without any Flutter SDK dependency. The `test-fast` script runs `test-ui` and `test-cybercore` as a quick local gate.

Updated the pure-Dart boundary harness at `packages/warp_prism_ui/test/boundaries/boundary_test.dart` to be compatible with Flutter test discovery while preserving its CLI entrypoint.

## Changes

- **Added** `test-cybercore`: runs tests scoped to `warp_prism_cybercore` (12 tests pass).
- **Added** `test-boundaries`: runs Task 1205's pure-Dart boundary harness (4/4 checks pass).
- **Added** `test-fast`: runs `test-ui` and `test-cybercore` as a quick local gate.
- **Normalized** `analyze`, `format`, `test`, `test-ui`, `test-observatory`, `test-catalog`, `test-cybercore`, `test-fast`, `validate`: changed from `melos exec`/`melos run` to `dart run melos exec`/`dart run melos run` for repository-local invocation.
- **Updated** `test-boundaries`: changed from `melos exec --scope warp_prism_ui -- flutter test` to direct pure-Dart harness invocation `dart run packages/warp_prism_ui/test/boundaries/boundary_test.dart --repo-root .`.
- **Fixed** boundary harness: made it compatible with Flutter test discovery by removing `flutter_test` import and accepting optional `args` parameter in `main()`.

## Verification

| Script | Result | Notes |
| --- | --- | --- |
| `dart run melos run test-cybercore` | ✅ SUCCESS | 12 tests pass |
| `dart run melos run test-boundaries` | ✅ SUCCESS | 4/4 boundary checks pass |
| `dart run melos run test-fast` | ✅ SUCCESS | test-ui + test-cybercore |
| `dart run melos run test-catalog` | ✅ SUCCESS | 10 tests pass |
| `dart run melos run test-ui` | ✅ SUCCESS | 850+ tests pass |
| `dart analyze packages/warp_prism_ui/test/boundaries/boundary_test.dart` | ✅ PASS | No issues found |
| `dart format --set-exit-if-changed packages/warp_prism_ui/test/boundaries/boundary_test.dart` | ✅ PASS | 0 changed |

## 2026-06-11 Path-to-100 Refresh

- Fixed script bodies to use `dart run melos exec`/`dart run melos run` instead of bare `melos` commands, resolving the "melos: command not found" failures.
- Updated `test-fast` from `melos exec --scope warp_prism_ui,warp_prism_cybercore -- flutter test` to `dart run melos run test-ui && dart run melos run test-cybercore` to avoid the boundary test harness loading issue under `flutter test`.
- Made boundary harness compatible with Flutter test discovery while preserving its pure-Dart CLI capability.
- Updated Completion Evidence to honestly state that existing scripts were normalized for repository-local invocation (not left unchanged).
- Reconciled `test-boundaries` evidence with Task 1205's current pure-Dart harness reality.
