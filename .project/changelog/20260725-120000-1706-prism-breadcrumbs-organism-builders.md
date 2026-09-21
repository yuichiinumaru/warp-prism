---
date: 20260725-120000
timestamp: 20260725-120000
project: warp-prism
agent: builders
task: "1706"
description: "Implement PrismBreadcrumbs organism with separators, active highlight, click callbacks, auto-derive, and truncation"
is_rebuild_safe: true
---

# Task 1706: PrismBreadcrumbs Organism Implementation

## Summary

Implemented `DSBreadcrumbs` / `PrismBreadcrumbs` organism in `warp_prism_ui` for hierarchical navigation path display, supporting custom separators, active item state, click callbacks, middle-item truncation via PopupMenuButton, optional route auto-derivation, and gallery demonstrations.

## Changes

- Created `packages/warp_prism_ui/lib/src/organisms/breadcrumbs/ds_breadcrumbs.dart` (`DSBreadcrumbs` widget + `DSBreadcrumbItem` model).
- Created barrel file `packages/warp_prism_ui/lib/src/organisms/breadcrumbs/breadcrumbs.dart`.
- Re-exported barrel from `packages/warp_prism_ui/lib/src/organisms/organisms.dart`.
- Registered `typedef PrismBreadcrumbs = DSBreadcrumbs;` and `typedef PrismBreadcrumbItem = DSBreadcrumbItem;` in `packages/warp_prism_ui/lib/src/prism_aliases.dart`.
- Added interactive gallery demonstration in `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart`.
- Added comprehensive unit and widget tests in `packages/warp_prism_ui/test/organisms/breadcrumbs/ds_breadcrumbs_test.dart`.

## Verification

- `cd packages/warp_prism_ui && dart analyze lib/src/organisms/breadcrumbs/ test/organisms/breadcrumbs/`: 0 issues found.
- `cd packages/warp_prism_ui && flutter test test/organisms/breadcrumbs/ --concurrency=1 --no-pub`: All 9 tests passed.
