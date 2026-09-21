---
date: 20260710-190000
timestamp: 20260710-190000
project: warp-prism
agent: gt-flutter-engineer
task: "1501"
description: "Add PrismMapHudWorkspace stage + multi-region HUD organism"
is_rebuild_safe: true
---

# Task 1501: PrismMapHudWorkspace Organism

## Summary

Implemented `DSMapHudWorkspace` with public alias `PrismMapHudWorkspace` —
full-bleed stage slot plus optional left/right/bottom/top glass HUD regions and
hide/restore chrome control. ADS-first (gallery + fixtures only); not a
`DSShell` clone; no MapLibre.

## Changes

- Created `packages/warp_prism_ui/lib/src/organisms/map_hud_workspace/`:
  - `ds_map_hud_workspace.dart` — stage stack, glass HUD wrappers, toggle a11y
  - `map_hud_workspace.dart` — barrel export
- Exported from `organisms.dart`
- Aliased `typedef PrismMapHudWorkspace = DSMapHudWorkspace` in `prism_aliases.dart`
- Minimal gallery case under Organisms section (mock gradient stage)
- Widget tests: regions present, hide/restore, empty slots, a11y labels

## Verification

```bash
cd packages/warp_prism_ui
dart analyze lib/src/organisms/map_hud_workspace lib/src/organisms/organisms.dart \
  lib/src/prism_aliases.dart lib/src/gallery/design_system_gallery_sections.dart \
  test/organisms/map_hud_workspace
# → No issues found

flutter test test/organisms/map_hud_workspace/
# → All tests passed (8)

dart run test/boundaries/boundary_test.dart
# → Boundary harness: 6/6 PASS
```
