# Task 1405: Detail Variant and Responsive Shell Reconciliation — Complete

> **Date**: 2026-06-09
> **Task**: 1405
> **Status**: Complete
> **Tests**: 92 passed, 0 failed

## What Was Done

Fixed all 24 asset_detail test failures across 4 test files in the observatory
app. Six distinct root causes were identified and resolved:

1. **`GenericAssetDetailView._buildSubtitle` type error**: Changed `dynamic
   asset` parameter to `WorkspaceAsset asset` to fix `AssetKind.name`
   NoSuchMethodError (9 failures).

2. **Duplicate-text test assertions**: Section titles and property labels
   rendered identical text (e.g., "Tools" section title + "Tools" property
   label). Changed `findsOneWidget` to `findsWidgets` for colliding texts (3
   failures).

3. **Link label mismatch**: Tests expected target ID (`task:0902`) but links
   render their label (`0902`). Fixed assertion (1 failure).

4. **ListView viewport clipping**: `DSDetailInspector` uses `ListView.builder`
   which only builds visible items. Added `tester.view.physicalSize` for tests
   asserting off-screen sections (4 failures).

5. **Responsive wrapper Scaffold collision**: Test wrapper Scaffold interfered
   with shell's narrow-mode Scaffold. Used `MediaQuery` override for width
   perception; updated assertions to account for wrapper Scaffold (5 failures).

6. **Mapper missing raw frontmatter keys**: Added metadata section to mapper
   for remaining frontmatter keys; added task frontmatter fallbacks for
   priority/lane (2 failures).

## Key Learning

- `MaterialApp(home: SizedBox(width: X))` constrains the SizedBox to the test
  surface (800x600) — the SizedBox doesn't enforce its width if the parent
  constrains it tighter. Use `Scaffold(body: ...)` or `tester.view.physicalSize`
  for wider layouts.

- `ListView.builder` is lazy — items outside the viewport are NOT in the widget
  tree. `find.text()` won't find them. Use `tester.view.physicalSize` to
  increase viewport or `tester.scrollUntilVisible`.

- `Container(width: 1, color: ...)` gets optimized to `ConstrainedBox` +
  `ColoredBox` internally — `find.byType(Container)` won't find it.

## Files Modified

- `lib/features/asset_detail/presentation/generic_asset_detail_view.dart`
- `lib/features/asset_detail/application/asset_detail_mapper.dart`
- `test/features/asset_detail/extended_detail_variants_test.dart`
- `test/features/asset_detail/skill_task_detail_widgets_test.dart`
- `test/features/asset_detail/responsive_detail_integration_test.dart`
- `test/features/asset_detail/asset_detail_descriptor_test.dart`
