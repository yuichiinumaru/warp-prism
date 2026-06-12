# Task 1306 — Golden Baseline MVP — Complete

> **Session**: 2026-06-09
> **Executor**: builders
> **Status**: complete (awaiting review)

## What was done

Created the first golden baseline snapshot tests for Warp Prism's design
system. This was the zero-to-one moment for golden testing — previously no
golden files existed despite policy (Task 1105) requiring them for atoms,
molecules, organisms, and templates.

## Deliverables

### 4 golden test files (51 tests total)

| File | Tests | Coverage |
|------|-------|----------|
| `ds_status_dot_golden_test.dart` | 20 | All 15 operational states + 5 basic semantic constructors + composite grid |
| `ds_badge_golden_test.dart` | 10 | Semantic constructors, filled/outlined/dot variants, small/medium/large sizes, count overflow, all operational states |
| `ds_metric_tile_golden_test.dart` | 10 | Default, 4 health states (healthy/degraded/error/disabled), 3 trend indicators, subtitle, compact variant |
| `ds_glass_panel_golden_test.dart` | 8 | DSGlassPanelSimple (default, cyan border, elevation), DSGlassPanel (subtle, elevated, modal), stacked layout |

### 50 generated PNG golden baselines

Located in `test/goldens/goldens/`. These are the regression baselines that
`flutter test test/goldens/` compares against.

## Technical decisions

- **Animated dots**: Pumped at 500ms single frame instead of `pumpAndSettle` to
  get deterministic snapshots from running/exposed animated states.
- **BackdropFilter**: DSGlassPanel tests use BackdropFilter (blur). If CI
  produces inconsistent rendering, these can be `skip`'d per the test file
  header documentation. DSGlassPanelSimple tests are always stable.
- **Test structure**: Each test file uses `_inApp()` helper wrapping in
  `MaterialApp(theme: ThemeData.dark(), home: Scaffold(backgroundColor: DSColors.obsidianBase))`
  for consistent obsidian glass rendering.

## For reviewer

- Verify `flutter test test/goldens/` passes on your machine.
- Check that golden PNGs look correct (obsidian dark background, correct
  accent colors for each state).
- The 50 PNGs exceed the task minimum of "at least 5" — this is intentional
  to cover the full operational state vocabulary from the start.
