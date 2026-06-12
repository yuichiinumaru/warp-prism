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
  4 boundary enforcement tests
- `pubspec.yaml` (root) — updated `test-boundaries` Melos script from
  placeholder to `melos exec --scope warp_prism_ui`

## Verification

- `flutter test test/boundaries/boundary_test.dart` → 4/4 PASS
- `melos run test-boundaries` → SUCCESS
- All 4 boundary checks return 0 violations (Task 1301 remediation is clean)

## Unblocks

- EPIC-13 namespace remediation verification
- Ongoing boundary drift detection in CI
