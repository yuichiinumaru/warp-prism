---
date: 20260711-180000
timestamp: 20260711-180000
project: warp-prism
agent: gt-flutter-engineer
task: "1509"
description: "Add stage chrome pack: WatchlistDock, CoordinateStatusBar, MapLegend"
is_rebuild_safe: true
---

# Task 1509: Stage Chrome Pack Organisms

## Summary

Implemented three stage-chrome organisms for EPIC-15 O-11 / O-12 / O-13:

1. `PrismWatchlistDock` — pinned-entity dock (expand/collapse, select, unpin)
2. `PrismCoordinateStatusBar` — read-only lat/lon + feed-health strip
3. `PrismMapLegend` — categorized legend with optional visibility toggles

Fixture-first ADS delivery: gallery demos + widget tests only. No MapLibre,
no Observatory route rewrite, no live geocoder/feeds.

## Changes

- Created `packages/warp_prism_ui/lib/src/organisms/watchlist_dock/`
  - `ds_watchlist_dock.dart` — `DSWatchlistDock`, `DSWatchlistItem`, fixtures
  - `watchlist_dock.dart` — barrel
- Created `packages/warp_prism_ui/lib/src/organisms/coordinate_status_bar/`
  - `ds_coordinate_status_bar.dart` — `DSCoordinateStatusBar`, feed health models
  - `coordinate_status_bar.dart` — barrel
- Created `packages/warp_prism_ui/lib/src/organisms/map_legend/`
  - `ds_map_legend.dart` — `DSMapLegend`, categories/items, fixtures
  - `map_legend.dart` — barrel
- Appended exports to `organisms.dart`
- Appended `Prism*` aliases in `prism_aliases.dart` (models + fixtures)
- Gallery: combined `_StageChromePackDemo` under Organisms section
- Widget tests for all three organisms (≥1 interactive a11y proof each)

## Verification

```bash
cd packages/warp_prism_ui
dart analyze lib/src/organisms/watchlist_dock \
  lib/src/organisms/coordinate_status_bar \
  lib/src/organisms/map_legend \
  lib/src/organisms/organisms.dart \
  lib/src/prism_aliases.dart \
  lib/src/gallery/design_system_gallery_sections.dart \
  test/organisms/watchlist_dock \
  test/organisms/coordinate_status_bar \
  test/organisms/map_legend
# → No issues found

flutter test test/organisms/watchlist_dock/ \
  test/organisms/coordinate_status_bar/ \
  test/organisms/map_legend/
# → All tests passed (20)

dart run test/boundaries/boundary_test.dart
# → Boundary harness: 6/6 PASS
```
