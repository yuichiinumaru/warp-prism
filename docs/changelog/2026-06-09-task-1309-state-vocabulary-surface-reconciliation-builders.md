# Task 1309: State Vocabulary Surface Reconciliation

> **Date**: 2026-06-09
> **Agent**: builders
> **Type**: remediation

## Summary

Reconciled the 15-state operational vocabulary across all DS component
surfaces, tests, and gallery sections.

## What Changed

### Tests
- `test/state_surface_test.dart`: Added 8 new widget tests covering the
  4 operational DSStateSurface constructors (disabled, stale, degraded,
  excluded) plus a composite test verifying all 7 DSStateType variants
  render distinct titles, and a stale-action integration test. Test count
  grew from 20 to 38.

### Gallery
- `design_system_gallery_sections.dart`: Expanded the Molecules section
  "State Surfaces" showcase from 1 variant (empty) to all 7 DSStateType
  variants (empty, loading, error, disabled, stale, degraded, excluded).
- `design_system_gallery_page.dart`: Removed duplicate
  `buildOperationalStatesSection()` call (was rendered twice).

### Audit (no code changes needed)
All other component surfaces were already reconciled:

| Component | Verdict |
|---|---|
| DSStatusDot | 15 constructors + `operational()` factory |
| DSBadge | `operational()` factory for all 15 states |
| DSMetricTile | 4 health states (healthy/degraded/error/disabled) |
| DSStateSurface | 7 constructors (3 data + 4 operational) |
| DSStatusCell | Accepts any `DSOperationalState` |
| DSHealthCard | Accepts any `DSOperationalState` |
| DSStatusGrid | Filters by any `DSOperationalState` |
| Gallery operational section | All 15 states shown with tiles, dots, badges, behavioral table |

## Validation

```bash
flutter test test/state_surface_test.dart test/tokens/ds_operational_state_test.dart test/molecules/operational_components_test.dart
# 171 tests — All passed!
```
