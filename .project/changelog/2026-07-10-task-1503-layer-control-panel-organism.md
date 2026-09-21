---
date: 20260710-210000
timestamp: 20260710-210000
project: warp-prism
agent: gt-flutter-engineer
task: "1503"
description: "Add PrismLayerControlPanel grouped layer toggles organism"
is_rebuild_safe: true
---

# Task 1503: PrismLayerControlPanel Organism

## Summary

Implemented `DSLayerControlPanel` with public alias `PrismLayerControlPanel` —
grouped layer toggles with counts, freshness indicators, master all-on/all-off
toggle, and consent-gate callbacks. Fixture catalog only; ADS-first (gallery +
tests); no MapLibre or live feeds.

## Changes

- Created `packages/warp_prism_ui/lib/src/organisms/layer_control_panel/`:
  - `ds_layer_control_panel.dart` — models (`DSLayerItem`, `DSLayerGroup`,
    `DSLayerFreshness`), panel UI, master toggle, consent hooks, a11y
  - `layer_control_panel.dart` — barrel export
- Exported from `organisms.dart` (append-only; preserved MapHud, ToolStrip,
  PageShell, Tree, AgentTranscript)
- Aliased in `prism_aliases.dart`:
  - `PrismLayerControlPanel`, `PrismLayerGroup`, `PrismLayerItem`,
    `PrismLayerFreshness`
- Minimal gallery case under Organisms (fixture catalog with consent stub)
- Widget tests: toggle, master, empty, disabled, consent, collapse, a11y

## Verification

```bash
cd packages/warp_prism_ui
dart analyze lib/src/organisms/layer_control_panel lib/src/organisms/organisms.dart \
  lib/src/prism_aliases.dart lib/src/gallery/design_system_gallery_sections.dart \
  test/organisms/layer_control_panel
# → No issues found

flutter test test/organisms/layer_control_panel/
# → All tests passed (12)

dart run test/boundaries/boundary_test.dart
# → Boundary harness: 6/6 PASS
```
