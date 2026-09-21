---
date: 20260710-011830
timestamp: 20260710-011830
agent: builders
task: "1030"
description: "Changelog: Task 1030 — No-op action removal for state surfaces"
is_rebuild_safe: true
---

# Changelog: Task 1030 — No-op action removal for state surfaces

> **Date**: 2026-07-09
> **Task**: 1030
> **Type**: fix | state-coherence
> **Status**: Ready for re-review (lane remains `02-doing` per executor instruction)
> **Author**: gt-flutter-engineer

## Summary

Removed fabricated no-op action callbacks from Map state hosts so Retry/Clear
only paint when a real callback is provided. Aligns Map hosts with
`PrismStateSurface` null-action contract (package already hides the button).

## Files modified

| File | Action |
|------|--------|
| `apps/observatory/lib/features/map/widgets/map_state_panel.dart` | Remove `onAction ?? () {}`; gate actionLabel on real callback |
| `apps/observatory/lib/features/map/widgets/map_no_results_state.dart` | Remove `onClearFilters ?? () {}`; hide Clear when null |
| `apps/observatory/test/features/map/map_surface_states_test.dart` | null action → no Retry; real action → invokes |
| `apps/observatory/test/features/map/map_catalog_panel_test.dart` | null Clear filters proof |

## Validation

- `flutter test test/features/map/map_surface_states_test.dart` — pass
- `flutter test test/features/map/map_catalog_panel_test.dart` — pass
- `packages/warp_prism_ui flutter test test/state_surface_test.dart` — **35** tests pass
