---
date: 20260710-204936
timestamp: 20260710-204936
project: warp-prism
agent: gt-flutter-engineer
task: "1601"
description: "Catalog/gallery showability smoke + section TOC + demo one-pager"
is_rebuild_safe: true
---

# Task 1601: Catalog / Gallery Showability Verify + Polish

## Summary

Verified ADS catalog/gallery smoke (analyze + tests), added a registry-driven
**Section index** TOC on `DesignSystemGalleryPage` for jump discovery, and
published a 60-second demo one-pager under `docs/demo/`. No Widgetbook; no
registry ID changes; no rebrand.

## Changes

- `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_page.dart` —
  Stateful gallery with section keys + TOC chips (`gallery-toc-<id>`).
- `packages/warp_prism_ui/test/gallery/design_system_gallery_test.dart` —
  TOC presence + per-section TOC chip coverage; Tokens `findsWidgets`.
- `docs/demo/catalog-showability-2026-07-10.md` — 60-second show script.
- Task 1601 Completion Evidence filled (lane remains `02-doing/`).

## Verification

```bash
cd apps/catalog && dart analyze
# EXIT 0 — No issues found

cd packages/warp_prism_ui && dart analyze lib/src/gallery test/gallery
# EXIT 0 — No issues found

cd packages/warp_prism_ui && flutter test test/gallery/
# All tests passed

cd apps/catalog && flutter test
# All tests passed
```

README catalog run path unchanged and still accurate:

```bash
cd apps/catalog && flutter run
```

## Author

gt-flutter-engineer
