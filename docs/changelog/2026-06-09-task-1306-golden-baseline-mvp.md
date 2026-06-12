# Task 1306 — Golden Baseline MVP

> **Date**: 2026-06-09
> **Executor**: builders
> **Type**: testing

## Summary

Created the first golden baseline snapshot tests for the Warp Prism design
system. Four golden test files cover DSStatusDot, DSBadge, DSMetricTile, and
DSGlassPanel/DSGlassPanelSimple, producing 50 PNG golden files that protect
visual regression for the obsidian glass aesthetic.

## What changed

### New files

| File | Purpose |
|------|---------|
| `packages/warp_prism_ui/test/goldens/ds_status_dot_golden_test.dart` | 19 individual state goldens + 1 all-states grid (20 tests) |
| `packages/warp_prism_ui/test/goldens/ds_badge_golden_test.dart` | 10 badge tests: semantic constructors, variants, sizes, count overflow, operational states |
| `packages/warp_prism_ui/test/goldens/ds_metric_tile_golden_test.dart` | 10 metric tile tests: default, health states, trends, subtitle, compact variant |
| `packages/warp_prism_ui/test/goldens/ds_glass_panel_golden_test.dart` | 8 glass panel tests: simple variants, blur variants, stacked layout |
| `packages/warp_prism_ui/test/goldens/goldens/*.png` | 50 generated golden baseline PNG files |

### Test counts

- **Total golden tests**: 51
- **Golden PNG files**: 50
- **Components covered**: DSStatusDot (all 15 operational states), DSBadge
  (semantic/variant/size/operational), DSMetricTile (health/trend/compact),
  DSGlassPanel + DSGlassPanelSimple (subtle/elevated/modal/stacked)

### Design decisions

- Animated dots (running, exposed, error-state) are pumped at a single
  deterministic frame (`Duration(milliseconds: 500)`) rather than settling,
  to avoid flaky animation timing in goldens.
- All tests render on `DSColors.obsidianBase` with `ThemeData.dark()` for
  consistent obsidian glass appearance.
- DSGlassPanel (blur-based) tests are included but may need `skip` on
  CI environments with inconsistent BackdropFilter rendering — documented
  in test file headers.
