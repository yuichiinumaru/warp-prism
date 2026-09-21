---
date: 20260701-180236
timestamp: 20260701-180236
agent: builders
task: "1305"
description: "2026-06-09 — Task 1305: Catalog Contract Expansion"
is_rebuild_safe: true
---

# 2026-06-09 — Task 1305: Catalog Contract Expansion

**Agent**: builders
**Task**: 1305
**Type**: feature

## Summary

Transformed the catalog app's widget test from a smoke-only check into a
real ADS proof surface verifying section rendering, uniqueness, state
matrices, and responsive layout.

## Changes

### `apps/catalog/test/widget_test.dart`
- Expanded from 1 smoke test to 9 contract tests.
- **Section rendering**: verifies all gallery sections render using `dsGallerySectionTitles` from the public registry.
- **Duplicate ID check**: asserts section IDs in `dsGallerySectionIds` are unique.
- **High Text Scale check**: asserts using `TextScaler.linear(2.0)` causes zero overflow exceptions.
- **State matrix tests** (4 tests, one per atomic design layer):
  - Atom: `PrismBadge` renders and shows text for default, loading, empty, error, disabled states.
  - Molecule: `PrismStateSurface` proves visibility of empty, loading, error, disabled, and degraded bounds.
  - Organism: `PrismDataTable` asserts visible UI for loading, empty, error, and degraded states.
  - Template: `PrismShellResponsive` renders correctly with its contents in degraded template state.
- **Responsive layout tests**: compact width (<800) vs expanded width (>=1200) layout geometry assertions using `PrismShellResponsive` sidebars.
- Replaced all private `src/` DS* widget usages with public `Prism*` barrel exports (`PrismBadge`, `PrismStateSurface`, `PrismSidebar`, etc.).

### `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart`
- Fixed a layout overflow in `_DemoListTile` by wrapping `DSText.labelMedium` in `Expanded`.

## Validation

- `flutter analyze apps/catalog/` → 0 issues
- `dart format --output=none --set-exit-if-changed apps/catalog/test/widget_test.dart` → Passed (0 changes)
- `flutter test apps/catalog/test/widget_test.dart` → 9/9 passed

## 2026-07-01 Reviewer Finalization

- Builder-side reviewer scored Task 1305 at 100/100 after live filesystem inspection.
- Hardened `apps/catalog/test/widget_test.dart` high-text-scale proof so `FlutterError.onError` is restored in `finally` and unexpected Flutter errors fail the test.
- Registered responsive viewport cleanup before viewport mutation.
- Final scoped validation from `apps/catalog`:
  - `flutter test --concurrency=1 --no-pub test/widget_test.dart` → 9/9 passed.
  - `dart analyze --format=machine test/widget_test.dart` → 0 machine issues.
  - `dart format --output=none --set-exit-if-changed test/widget_test.dart` → passed after one real `dart format test/widget_test.dart` write.
- Moved task file to `docs/tasks/03-review/1305-warp-prism-catalog-contract-expansion.md`.
