# Task 1205: Boundary Test Harness — Builder Done

> **Date**: 2026-06-09
> **Task**: 1205
> **Status**: Builder Done (in 02-doing, awaiting review)

## What happened

Created the boundary test harness at
`packages/warp_prism_ui/test/boundaries/boundary_test.dart`. Four grep-based
tests enforce architectural invariants:

1. Zero `DS[A-Z]` references in `apps/cybercore/lib/` (Prism* regression gate)
2. Zero `src/` imports from consumer apps (barrel-only access)
3. Zero Riverpod/GoRouter imports in `warp_prism_ui` (framework-agnostic ADS)
4. Zero app-specific imports in `warp_prism_ui` (no circular deps)

Updated the Melos `test-boundaries` script from placeholder to functional:
`melos exec --scope warp_prism_ui -- flutter test test/boundaries/boundary_test.dart`

## Current state

All 4 checks pass with 0 violations. Task 1301 remediation is fully clean.
The harness is designed to catch any future drift.

## Notes for reviewers

- The task file specified `tool/test_boundaries.dart` but the user requested
  `packages/warp_prism_ui/test/boundaries/boundary_test.dart` as a Flutter
  test (not a standalone script). This aligns with the Melos test pipeline.
- `Directory.current.parent.parent` resolves the repo root because `flutter test`
  runs from the package directory (`packages/warp_prism_ui/`).
- The original task expected 1 FAIL (DS* in CyberCore) but Task 1301 already
  completed that migration, so all 4 pass.
