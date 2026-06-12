# 2026-06-09 — Task 1304: Gallery Compile Boundary Cleanup

**Agent**: builders
**Task**: 1304
**Type**: remediation

## Summary

Fixed compilation and test failures in the Design System Gallery, unblocking
all package-level test gates for `warp_prism_ui`.

## Findings

- **Zero compilation errors** in `design_system_gallery_sections.dart` — the
  ~200 errors mentioned in the task brief were already resolved by Task 1303
  (component contract reconciliation).
- **One rendering overflow**: `_SplitPaneDemo` trailing `Column` overflowed by
  24px when constrained to small heights (e.g. 240px SizedBox in tests).
- **Seven test failures**: all caused by the gallery page using a lazy
  `ListView` — off-screen sections (Atoms, Molecules, Organisms, Templates,
  footer) were not built until scrolled into view, causing `find.text()` to
  fail.

## Changes

### `design_system_gallery_sections.dart`
- Replaced `_SplitPaneDemo` trailing `Column` with `ListView(shrinkWrap: true,
  physics: NeverScrollableScrollPhysics())` to prevent overflow in constrained
  layouts.

### `design_system_gallery_test.dart`
- Added `_findByScrolling` helper using `tester.fling` to scroll the lazy
  `ListView` before asserting off-screen content.
- Updated all full-page tests to use the helper for sections below the fold.
- Changed standalone `buildOrganismsSection` test to use
  `SingleChildScrollView` instead of `ListView` to avoid overflow in the
  fixed-height split pane demo.

## Validation

- `flutter analyze lib/src/gallery/` → 0 errors, 0 warnings (311 info-level
  lint suggestions only)
- `flutter test test/gallery/design_system_gallery_test.dart` → 13/13 passed
