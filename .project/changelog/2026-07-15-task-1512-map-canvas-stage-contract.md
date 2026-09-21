---
date: 20260715-120000
timestamp: 20260715-120000
project: warp-prism
agent: gt-flutter-engineer
task: "1512"
description: "PrismMapCanvasStage contract organism — layer registry, selection bus, popup factory, placeholder renderer (O-17)"
is_rebuild_safe: true
---

# Task 1512: PrismMapCanvasStage Selection/Layer Contract

## Summary

Implemented **PrismMapCanvasStage** (`DSMapCanvasStage`) — engine-agnostic map/stage
contract organism with layer registry, selection bus, popup factory slot, and a
non-MapLibre placeholder stage renderer. EPIC-15 O-17 / Wave F. Explicitly
forbids MapLibre/react-map-gl port.

Public `Prism*` aliases; organisms barrel export; gallery case with interactive
fixture demo; comprehensive widget + controller tests.

## Changes

- Created `packages/warp_prism_ui/lib/src/organisms/map_canvas_stage/`
  - `map_stage_contracts.dart` — `DSMapStageLayerEntry`, `DSMapStageFeature`,
    `DSMapStageSelectionEvent`, `DSMapStageSelectionKind`, `DSMapStagePopupBuilder`,
    `DSMapStageSelectionListener` (immutable contract types)
  - `ds_map_canvas_stage.dart` — `DSMapCanvasStageController` (layer registry:
    add/remove/toggle/set; selection bus: select/clear/listeners), `DSMapCanvasStage`
    widget (placeholder grid + markers + popup overlay + status strip),
    `DSMapCanvasStageFixtures` (default layers + features)
  - `map_canvas_stage.dart` — barrel export
- Exported barrel from `organisms.dart` (append-only line 56)
- Aliased in `prism_aliases.dart`:
  - `PrismMapCanvasStage`, `PrismMapCanvasStageController`,
    `PrismMapStageLayerEntry`, `PrismMapStageFeature`,
    `PrismMapStageSelectionEvent`, `PrismMapStageSelectionKind`,
    `PrismMapStagePopupBuilder`, `PrismMapStageSelectionListener`,
    `PrismMapCanvasStageFixtures`
- Gallery (organisms section): interactive `_MapCanvasStageDemo` with
  layer toggle + selection + popup showcase + policy banner
- Widget tests under `test/organisms/map_canvas_stage/` (11 tests)

## Non-goals honored

- No MapLibre / react-map-gl / force-graph JS port (placeholder only)
- No Observatory product route rewrite (ADS-first)
- Molecules kept in-organism (markers, popup, status strip)
- No live geocoder / tile service / webview
- Reads-only: no backend mutation paths

## Verification

```bash
cd packages/warp_prism_ui
dart analyze lib/src/organisms/map_canvas_stage/ test/organisms/map_canvas_stage/
# No issues found (exit 0)

flutter test test/organisms/map_canvas_stage/ --concurrency=1 --no-pub
# 11/11 PASS

flutter test test/boundaries/boundary_test.dart --no-pub
# Boundary harness: 6/6 PASS, 0 FAIL, 0 violation(s)
```
