---
date: 20260609-220000
timestamp: 20260609-220000
agent: builders
task: "1205"
description: "Task 1205: Boundary Test Harness"
is_rebuild_safe: true
---

# Task 1205: Boundary Test Harness

> **Task**: 1205
> **Agent**: builders
> **Date**: 2026-06-09
> **Type**: testing

## Summary

Created a deterministic, grep-based boundary test harness that enforces
package purity and namespace rules across the Warp Prism monorepo. Four
checks cover: DS* regression in CyberCore, `src/` import leakage from
consumer apps, Riverpod/GoRouter in the ADS package, and app-specific
imports in the ADS package.

## What Changed

- `packages/warp_prism_ui/test/boundaries/boundary_test.dart` — created,
  pure Dart (no Flutter SDK) boundary harness with 4 grep-based checks:
  DS* regression in CyberCore, `src/` import leakage from consumer apps,
  Riverpod/GoRouter in UI package, and app-specific imports in UI package.
- `pubspec.yaml` (root) — updated `test-boundaries` Melos script to invoke
  `dart run packages/warp_prism_ui/test/boundaries/boundary_test.dart --repo-root .`

## Verification

- `dart run packages/warp_prism_ui/test/boundaries/boundary_test.dart --repo-root .` → 4/4 PASS (pure Dart, no Flutter SDK)
- `dart run melos run test-boundaries` → 4/4 PASS (repository-local Melos, no global binary required)
- `dart analyze packages/warp_prism_ui/test/boundaries/boundary_test.dart` → No issues found
- `dart format --output=none --set-exit-if-changed packages/warp_prism_ui/test/boundaries/boundary_test.dart` → 0 changed
- Do **not** use repo-root `dart format ... lib/ test/` — those paths do not exist in this monorepo layout
- Package-wide `dart analyze packages/warp_prism_ui` remains red with pre-existing external-blocker diagnostics and is not claimed clean by Task 1205
- All 4 boundary checks return 0 violations (Task 1301 remediation is clean)

## 2026-07-09 note

Proof-packet remediation after review score 82/100: validation commands and
evidence now use only existing package/task paths. Dependency-constraint
refresh remains a separate non-task follow-up. See
`docs/changelog/20260709-030039-1205-validation-path-proof-packet-builders.md`.

## Unblocks

- EPIC-13 namespace remediation verification
- Ongoing boundary drift detection in CI
