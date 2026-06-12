# Task 1405: Detail Variant and Responsive Shell Reconciliation

> **Date**: 2026-06-09
> **Type**: remediation
> **EPIC**: 14 (stabilization wave)

## Summary

Fixed 24 asset_detail test failures across 4 test files by resolving type
errors, test assertion drift, viewport clipping, and responsive layout
wrapper issues.

## Root Causes Fixed

1. **`AssetKind.name` NoSuchMethodError** (9 failures): `GenericAssetDetailView._buildSubtitle` accepted `dynamic asset` instead of `WorkspaceAsset`, causing runtime dispatch to fail on `AssetKind.name`. Fixed by typing the parameter correctly.

2. **Duplicate-text assertions** (3 failures): Section titles ("Tools", "Evidence", "Incoming Links") and property labels rendered identical text, causing `findsOneWidget` to fail with `findsWidgets`. Fixed assertions to use `findsWidgets` where section title and property label collide.

3. **Link label vs target ID mismatch** (1 failure): Test expected `find.text('task:0902')` but the link renders its label `'0902'`, not the target ID. Fixed assertion.

4. **ListView viewport clipping** (4 failures): `DSDetailInspector` uses `ListView.builder` which only builds visible items. With the default 800x600 test surface and a `Scaffold` wrapper, sections beyond ~600px were never built. Fixed by adding `tester.view.physicalSize` to tests that assert off-screen sections.

5. **Responsive wrapper Scaffold collision** (5 failures): Test wrapper used `Scaffold(body: ...)` which introduced a second Scaffold in narrow-mode tests. Fixed by using `MediaQuery` override for width perception and updating assertions to account for the wrapper Scaffold.

6. **Mapper missing raw frontmatter keys** (2 failures): `asset_detail_mapper` didn't include raw frontmatter keys (like `version`, `priority`, `lane`) as descriptor properties. Added metadata section and task frontmatter fallbacks.

## Files Changed

- `lib/features/asset_detail/presentation/generic_asset_detail_view.dart`
- `lib/features/asset_detail/application/asset_detail_mapper.dart`
- `test/features/asset_detail/extended_detail_variants_test.dart`
- `test/features/asset_detail/skill_task_detail_widgets_test.dart`
- `test/features/asset_detail/responsive_detail_integration_test.dart`
- `test/features/asset_detail/asset_detail_descriptor_test.dart`

## Verification

```bash
flutter test test/features/asset_detail/
# 92 passed, 0 failed
```

```bash
dart analyze lib/features/asset_detail/ test/features/asset_detail/
# 0 warnings, info-only style suggestions
```
