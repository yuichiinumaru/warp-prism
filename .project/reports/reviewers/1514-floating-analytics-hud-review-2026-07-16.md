# Independent Review — Task 1514 PrismFloatingAnalyticsHud Organism

- **Reviewer lane**: reviewers
- **Date**: 2026-07-16
- **Task file reviewed**: `docs/tasks/03-review/1514-warp-prism-floating-analytics-hud-organism.md`
- **Implementation surface**: `packages/warp_prism_ui/lib/src/organisms/floating_analytics_hud/`
- **Verdict**: **REJECT — route to `02-doing`**
- **Score**: **82/100**

## Axiom Compliance

| Axiom | Status | Evidence |
| --- | --- | --- |
| 1. Analyzer Integrity | FAIL | Task-scoped `dart analyze lib/src/organisms/floating_analytics_hud/ test/organisms/floating_analytics_hud/` returned **3 info issues** at `ds_floating_analytics_hud.dart:188-190` (`prefer_initializing_formals`). Package-wide `dart analyze lib test` returned **141 info issues**. The task completion evidence acknowledged these info hints but still claimed completion; axiom requires zero info issues. |
| 2. Lifecycle Safety | PASS | Controller/listener count: `DSFloatingAnalyticsHudController` external controller created but not owned by widget; widget adds 1 listener at `ds_floating_analytics_hud.dart:525`, swaps by removing old listener at `532`, and removes current listener in `dispose()` at `551-553`. No owned `TextEditingController`, `ScrollController`, `AnimationController`, `StreamSubscription`, or `Timer`. `mounted` guard exists at `556-558`. |
| 3. Dependency Direction | PASS | Imports only Flutter services/material plus local ADS atoms/molecules/tokens. Boundary harness printed **7/7 PASS**. No MapLibre/network/persistence dependency. |
| 4. UI Accessibility | FAIL | Interactive definitions: 4 (`GestureDetector` drag handle, `GestureDetector` title drag, minimize `IconButton`, close `IconButton`). Explicit semantic wrappers: 4 region/control wrappers, but 2 touch-target failures: drag handle is icon padding only (`ds_floating_analytics_hud.dart:732-745`), and title drag target has no explicit action semantics beyond row text (`750-769`). Minimize/close controls are constrained to **36x36** (`790`, `808`), below 48dp. |
| 5. Proof Reality | PASS | Live combined EPIC-15 test run passed **47/47**; this task contributes **11** tests covering render, minimize/expand, controller, drag, close, a11y labels, alias, and gallery-shaped fixture. |
| 6. Release Security | PASS | No secrets, no `print()`/`debugPrint()`, no live telemetry/network; fixtures documented as mock-only. |

## Live Commands Run

```bash
cd packages/warp_prism_ui && dart analyze lib test
# 141 info issues found.

cd packages/warp_prism_ui && dart analyze lib/src/organisms/floating_analytics_hud/ test/organisms/floating_analytics_hud/
# 3 info issues found: ds_floating_analytics_hud.dart:188, :189, :190 prefer_initializing_formals.

cd packages/warp_prism_ui && flutter test test/organisms/map_canvas_stage/ test/organisms/entity_relation_card/ test/organisms/floating_analytics_hud/ test/organisms/ops_control_cluster/ test/organisms/connector_panel/ --concurrency=1 --no-pub
# 47/47 All tests passed; floating_analytics_hud contributes 11 tests.

cd packages/warp_prism_ui && flutter test test/boundaries/ --concurrency=1 --no-pub
# Boundary harness: 7/7 PASS, 0 FAIL, 0 violations.
```

## Findings

### MODERATE — Task-scoped analyzer has 3 live info issues

- `packages/warp_prism_ui/lib/src/organisms/floating_analytics_hud/ds_floating_analytics_hud.dart:188-190` assigns constructor parameters to fields instead of using initializing formals, triggering `prefer_initializing_formals` 3 times.

**Change recommendation**: change the controller constructor to use initializing formals for `_offset`, `_minimized`, and `_visible`, while preserving defaults:

```dart
DSFloatingAnalyticsHudController({
  Offset offset = Offset.zero,
  bool minimized = false,
  bool visible = true,
})  : _offset = offset,
      _minimized = minimized,
      _visible = visible;
```

should become a lint-compliant private-field initializer pattern accepted by the analyzer, or equivalent field initializing formals if supported by the desired API shape.

### MODERATE — Header controls miss 48dp touch targets

- `packages/warp_prism_ui/lib/src/organisms/floating_analytics_hud/ds_floating_analytics_hud.dart:790` constrains minimize to 36x36.
- `packages/warp_prism_ui/lib/src/organisms/floating_analytics_hud/ds_floating_analytics_hud.dart:808` constrains close to 36x36.
- `packages/warp_prism_ui/lib/src/organisms/floating_analytics_hud/ds_floating_analytics_hud.dart:732-745` makes the drag handle hit target only padded icon-sized, not 48dp.

**Change recommendation**: set header interactive `BoxConstraints(minWidth: 48, minHeight: 48)` for drag handle, minimize, and close. Keep compact visual icon size inside the larger hit area.

### MODERATE — Title drag area is interactive but not semantically actionable

- `packages/warp_prism_ui/lib/src/organisms/floating_analytics_hud/ds_floating_analytics_hud.dart:750-769` wraps the title row in a `GestureDetector` with `onPanUpdate`, but unlike the drag handle it has no explicit semantic label or action hint. A screen reader sees text, not a drag affordance.

**Change recommendation**: either remove title-row drag interaction and leave drag to the labeled handle, or wrap the title drag target in `Semantics(label: 'Drag analytics HUD', ...)` with a 48dp minimum target.

### LOW — Organism file is too large

- `packages/warp_prism_ui/lib/src/organisms/floating_analytics_hud/ds_floating_analytics_hud.dart` is **919 lines**, exceeding the mega-widget threshold by a wide margin.

**Change recommendation**: split models, controller, fixtures, header, section list, and metric rendering into smaller files under `floating_analytics_hud/` while preserving the module barrel.

## Path to 100

1. Fix the 3 task-scoped analyzer info issues at lines 188-190; `dart analyze ...` must return `No issues found!`.
2. Raise drag/minimize/close/title-drag hit targets to 48x48dp or remove unlabeled title drag.
3. Add widget tests asserting minimize/close/drag handle render boxes have width and height `>= 48.0` and that every draggable target has semantic drag affordance.
4. Split the 919-line file into smaller module files.
5. Re-run:
   - `dart analyze lib/src/organisms/floating_analytics_hud/ test/organisms/floating_analytics_hud/`
   - `flutter test test/organisms/floating_analytics_hud/ --concurrency=1 --no-pub`
   - `flutter test test/boundaries/ --concurrency=1 --no-pub`
