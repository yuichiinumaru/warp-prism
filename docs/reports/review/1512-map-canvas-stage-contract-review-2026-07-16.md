# Independent Review — Task 1512 PrismMapCanvasStage Selection/Layer Contract

- **Reviewer lane**: reviewers
- **Date**: 2026-07-16
- **Task file reviewed**: `docs/tasks/03-review/1512-warp-prism-map-canvas-stage-contract.md`
- **Implementation surface**: `packages/warp_prism_ui/lib/src/organisms/map_canvas_stage/`
- **Verdict**: **REJECT — route to `02-doing`**
- **Score**: **87/100**

## Axiom Compliance

| Axiom | Status | Evidence |
| --- | --- | --- |
| 1. Analyzer Integrity | PARTIAL | Task-scoped `dart analyze lib/src/organisms/map_canvas_stage/ test/organisms/map_canvas_stage/` returned `No issues found!`; package-wide `dart analyze lib test` returned **141 info issues**. No task-local analyzer issue was found, but the package does not satisfy zero-info analyzer integrity. |
| 2. Lifecycle Safety | PASS | `DSMapCanvasStageController.dispose()` clears selection listeners at `ds_map_canvas_stage.dart:351-353`; widget removes controller/listener subscriptions and disposes owned controller at `ds_map_canvas_stage.dart:497-501`. Controller/listener count: 1 owned controller site, 2 listener add sites, 2 matching remove sites, 2 owned dispose paths. No `TextEditingController`, `ScrollController`, `AnimationController`, `StreamSubscription`, or `Timer` in task surface. |
| 3. Dependency Direction | PASS | No Riverpod/GoRouter/app imports in package boundary harness; `flutter test test/boundaries/ --concurrency=1 --no-pub` printed **7/7 PASS**. No MapLibre/react-map-gl/webview engine dependency in `pubspec.yaml` or task module. |
| 4. UI Accessibility | FAIL | Interactive definitions: 4 (`GestureDetector` background, status `InkWell`, marker `InkWell`, popup dismiss `InkWell`). Interactive semantic wrappers: 3 explicit (`Clear selection`, marker labels, popup dismiss); the background clear gesture has no semantics. Touch-target failures: 3 definitions below 48dp (`markerSize` 32/40 at `ds_map_canvas_stage.dart:643`, clear padding at `ds_map_canvas_stage.dart:617-621`, popup dismiss padding at `ds_map_canvas_stage.dart:754-761`). |
| 5. Proof Reality | PASS | Live organism suite passed: `flutter test test/organisms/map_canvas_stage/ ...` contributed **11/47 PASS** in combined EPIC-15 run; boundary harness printed 7/7 PASS. Tests cover layer registry, selection, clear, popup, custom popup, labels, Prism alias. |
| 6. Release Security | PASS | No `print()`/`debugPrint()`, no API key/token handling, no live network, no map engine/webview dependency. Fixture-only placeholder explicitly documented. |

## Live Commands Run

```bash
cd packages/warp_prism_ui && dart analyze lib test
# 141 info issues found (package-wide; includes unrelated pre-existing files).

cd packages/warp_prism_ui && dart analyze lib/src/organisms/map_canvas_stage/ test/organisms/map_canvas_stage/
# No issues found!

cd packages/warp_prism_ui && flutter test test/organisms/map_canvas_stage/ test/organisms/entity_relation_card/ test/organisms/floating_analytics_hud/ test/organisms/ops_control_cluster/ test/organisms/connector_panel/ --concurrency=1 --no-pub
# 47/47 All tests passed; map_canvas_stage contributes 11 tests.

cd packages/warp_prism_ui && flutter test test/boundaries/ --concurrency=1 --no-pub
# Shell boundary harness: 7/7 PASS, 0 FAIL, 0 violations; Flutter wrapper reports no test cases after shell harness output.

cd packages/warp_prism_ui && dart pub outdated
# Outdated direct dependencies reported at workspace resolution level; no `any` constraints in package pubspec.
```

## Findings

### MODERATE — UI accessibility touch targets below 48dp

- `packages/warp_prism_ui/lib/src/organisms/map_canvas_stage/ds_map_canvas_stage.dart:643` sets marker size to `32.0` unselected and `40.0` selected. These markers are interactive map feature controls and fail the required 48x48dp minimum.
- `packages/warp_prism_ui/lib/src/organisms/map_canvas_stage/ds_map_canvas_stage.dart:617-621` wraps the status-strip clear action in a tiny `Padding` instead of a 48dp constrained target.
- `packages/warp_prism_ui/lib/src/organisms/map_canvas_stage/ds_map_canvas_stage.dart:754-761` wraps popup dismiss in `Padding(EdgeInsets.all(DSSpacing.xxs))`, also below 48dp.

**Change recommendation**: wrap each `InkWell` child in `ConstrainedBox(constraints: BoxConstraints(minWidth: 48, minHeight: 48))` or use `IconButton` with 48dp constraints. For markers, keep visual dot size inside a 48dp hit box.

### MODERATE — Background clear gesture is unlabeled interaction

- `packages/warp_prism_ui/lib/src/organisms/map_canvas_stage/ds_map_canvas_stage.dart:543-552` uses a full-stage `GestureDetector` that clears selection on tap, but it has no explicit semantics action/label. This is an interaction, not passive paint.

**Change recommendation**: wrap the background clear target in `Semantics(label: 'Clear map selection', button: true, onTap: _handleBackgroundTap, child: ExcludeSemantics(...))` or otherwise expose the clear action only through the existing labeled status control and make background tap non-semantic.

### LOW — Mega-widget file exceeds reviewable organism size

- `packages/warp_prism_ui/lib/src/organisms/map_canvas_stage/ds_map_canvas_stage.dart` is **854 lines**. The Flutter review protocol flags mega-widgets/files over 200 lines. The contracts/controller/widget/painter can be split without changing public API.

**Change recommendation**: keep `ds_map_canvas_stage.dart` as the public implementation wrapper and extract `_MapStageGridPainter`, fixture marker, popup, and status strip into private part files or package-private widgets under the same module.

## Path to 100

1. Raise all interactive hit regions to 48x48dp: feature markers, clear action, popup dismiss.
2. Add or intentionally suppress semantics for the background clear gesture; if it remains interactive, expose an accessible action label.
3. Split the 854-line implementation into focused private widgets/painter files while preserving `PrismMapCanvasStage` aliases and tests.
4. Re-run:
   - `dart analyze lib/src/organisms/map_canvas_stage/ test/organisms/map_canvas_stage/`
   - `flutter test test/organisms/map_canvas_stage/ --concurrency=1 --no-pub`
   - `flutter test test/boundaries/ --concurrency=1 --no-pub`
5. Package-wide path to perfect requires clearing the existing 141 package analyzer info issues or documenting that this task is gated only on task-scoped analysis.
