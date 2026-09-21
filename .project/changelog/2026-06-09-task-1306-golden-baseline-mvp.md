---
date: 20260709-213249
timestamp: 20260709-213249
agent: builders
task: "1306"
description: "Task 1306 — Golden Baseline MVP"
is_rebuild_safe: true
---

# Task 1306 — Golden Baseline MVP

> **Date**: 2026-06-09 (updated 2026-07-09 re-review)
> **Executor**: builders / gt-flutter-engineer
> **Type**: testing

## Summary

Created the first golden baseline snapshot tests for the Warp Prism design
system. Seven golden test files cover the five required canonical ADS surfaces
plus extra non-MVP state matrices, producing 53 PNG golden files that protect
visual regression for the obsidian glass aesthetic.

## What changed

### New files

| File | Purpose |
|------|---------|
| `packages/warp_prism_ui/test/goldens/ds_text_golden_test.dart` | 1 canonical DSText default golden |
| `packages/warp_prism_ui/test/goldens/ds_glass_panel_golden_test.dart` | 8 glass panel tests (simple/blur/stacked) + 1 non-golden unit check |
| `packages/warp_prism_ui/test/goldens/ds_metric_tile_golden_test.dart` | 11 metric tile tests (default, health, trend, subtitle, compact) |
| `packages/warp_prism_ui/test/goldens/ds_shell_golden_test.dart` | 1 canonical DSShell default golden (fixed 1024×768) |
| `packages/warp_prism_ui/test/goldens/ds_data_table_golden_test.dart` | 1 canonical DSDataTable default golden |
| `packages/warp_prism_ui/test/goldens/ds_status_dot_golden_test.dart` | Extra — 20 status-dot state matrix goldens |
| `packages/warp_prism_ui/test/goldens/ds_badge_golden_test.dart` | Extra — 12 badge state/variant goldens |
| `packages/warp_prism_ui/test/goldens/goldens/*.png` | 53 generated golden baseline PNG files |

### Product fix (2026-07-09)

| File | Purpose |
|------|---------|
| `packages/warp_prism_ui/lib/src/molecules/ds_interactive_surface.dart` | Default `alignment` is now null so decorated surfaces shrink-wrap; restores compact metric-tile goldens without PNG regeneration |

### Test counts

- **Total golden suite tests**: 54 (53 `matchesGoldenFile` baselines + 1 glass-panel unit check)
- **Golden PNG files**: 53
- **Required canonical baselines (5/5)**:
  1. `goldens/text_default.png` — DSText.bodyMedium
  2. `goldens/glass_panel_simple_default.png` — DSGlassPanelSimple
  3. `goldens/metric_tile_default.png` — DSMetricTile
  4. `goldens/shell_default.png` — DSShell
  5. `goldens/data_table_default.png` — DSDataTable

### Design decisions

- Animated dots (running, exposed) are pumped at a single deterministic frame
  (`Duration(milliseconds: 500)`) rather than settling, to avoid flaky animation
  timing in goldens.
- All tests render on `DSColors.obsidianBase` with `ThemeData.dark()` for
  consistent obsidian glass appearance.
- DSGlassPanel (blur-based) tests are included but may need `skip` on CI
  environments with inconsistent BackdropFilter rendering — documented in test
  file headers.
- Intentional visual redesigns regenerate PNGs; accidental layout regressions
  (e.g. compact-tile expansion) are fixed in product code without golden regen.
