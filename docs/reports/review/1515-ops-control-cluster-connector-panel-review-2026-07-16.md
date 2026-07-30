# Independent Review — Task 1515 PrismOpsControlCluster + PrismConnectorPanel

- **Reviewer lane**: reviewers
- **Date**: 2026-07-16
- **Task file reviewed**: `docs/tasks/03-review/1515-warp-prism-ops-control-cluster-connector-panel.md`
- **Implementation surface**: `packages/warp_prism_ui/lib/src/organisms/ops_control_cluster/` + `packages/warp_prism_ui/lib/src/organisms/connector_panel/`
- **Verdict**: **REJECT — route to `02-doing`**
- **Score**: **89/100**

## Axiom Compliance

| Axiom | Status | Evidence |
| --- | --- | --- |
| 1. Analyzer Integrity | PARTIAL | Task-scoped `dart analyze lib/src/organisms/ops_control_cluster/ lib/src/organisms/connector_panel/ test/organisms/ops_control_cluster/ test/organisms/connector_panel/` returned `No issues found!`; package-wide `dart analyze lib test` returned **141 info issues**. |
| 2. Lifecycle Safety | PASS | Task surface creates **1** `FocusNode` per launcher (`ds_ops_control_cluster.dart:338`), disposed at `ds_ops_control_cluster.dart:343`. Connector panel creates **0** controllers/subscriptions/timers. Ops cluster is `StatelessWidget`; internal `_OpsLauncherButton` manages `FocusNode` lifecycle correctly with dispose. |
| 3. Dependency Direction | PASS | Imports only Flutter services/material plus local ADS atoms/tokens. Boundary harness printed **7/7 PASS**. No Shodan/SCM/radio domain one-off or MapLibre/network dependency confirmed. |
| 4. UI Accessibility | FAIL | Interactive definitions: ops launcher cluster 5 (`GestureDetector`+`Focus` in each launcher button), connector panel 2 (`IconButton` refresh, `IconButton` minimize). Explicit semantic wrappers: 5 for ops cluster (region + per-launcher button), 3 for connector panel (region + refresh + minimize). Touch-target failures: ops launcher minSize is **40dp** dense / **48dp** normal at `ds_ops_control_cluster.dart:353` (borderline pass for normal mode, fail for dense). Connector panel refresh/minimize controls constrained at **40x40** (`ds_connector_panel.dart:282` and `ds_connector_panel.dart:309`), slightly below 48dp. |
| 5. Proof Reality | PASS | Live combined EPIC-15 test run passed **47/47**; this task contributes **19** tests (9 ops_control_cluster + 10 connector_panel) covering: render, callbacks, disabled, semantics, keyboard, vertical direction, model copyWith, controlled/uncontrolled minimize, refresh, show/hide controls, subtitle/trailing. |
| 6. Release Security | PASS | No secrets, no `print()`/`debugPrint()`, no live API/network; fixture launchers/payload explicitly documented. |

## Live Commands Run

```bash
cd packages/warp_prism_ui && dart analyze lib test
# 141 info issues found.

cd packages/warp_prism_ui && dart analyze lib/src/organisms/ops_control_cluster/ lib/src/organisms/connector_panel/ test/organisms/ops_control_cluster/ test/organisms/connector_panel/
# No issues found!

cd packages/warp_prism_ui && flutter test test/organisms/map_canvas_stage/ test/organisms/entity_relation_card/ test/organisms/floating_analytics_hud/ test/organisms/ops_control_cluster/ test/organisms/connector_panel/ --concurrency=1 --no-pub
# 47/47 All tests passed; ops_control_cluster contributes 9 tests, connector_panel contributes 10 tests.

cd packages/warp_prism_ui && flutter test test/boundaries/ --concurrency=1 --no-pub
# Boundary harness: 7/7 PASS, 0 FAIL, 0 violations.
```

## Findings

### MODERATE — Connector panel interactive controls are 40x40, below 48dp requirement

- `packages/warp_prism_ui/lib/src/organisms/connector_panel/ds_connector_panel.dart:277-283` (refresh `IconButton` with `BoxConstraints(minWidth: 40, minHeight: 40)`)
- `packages/warp_prism_ui/lib/src/organisms/connector_panel/ds_connector_panel.dart:302-310` (minimize `IconButton` with `BoxConstraints(minWidth: 40, minHeight: 40)`)
- `packages/warp_prism_ui/lib/src/organisms/connector_panel/ds_connector_panel.dart:281-283` and `:308-310` also use `padding: EdgeInsets.zero` and `visualDensity: VisualDensity.compact`.

These are interactive controls: refresh fires a callback, minimize toggles visibility. Both fail 48dp minimum.

**Change recommendation**: set `BoxConstraints(minWidth: 48, minHeight: 48)` on both `IconButton` controls. Compact visual icon size at 18 is fine; the hit box must be at least 48dp.

### LOW — Ops launcher dense mode 40dp is also below 48dp

- `packages/warp_prism_ui/lib/src/organisms/ops_control_cluster/ds_ops_control_cluster.dart:353` sets the launcher `minSize` to `40.0` in dense mode. Standard mode at `48.0` passes.

**Change recommendation**: raise dense mode launcher `BoxConstraints` to `(minWidth: 48, minHeight: 48)` or remove dense mode until a future dense-touch-target task authorizes the smaller constraint with documented justification.

### SAFE — Disposable FocusNode lifecycle is architecturally sound

- `_OpsLauncherButtonState` at `ds_ops_control_cluster.dart:330-345` declares `late final FocusNode _focusNode;` initialized in `initState` with a debug label, and disposed in `dispose()`. This is correct and complete.

## Path to 100

1. Raise connector panel refresh and minimize `IconButton` constraints to `BoxConstraints(minWidth: 48, minHeight: 48)`.
2. Raise ops launcher dense mode constraints to 48dp or delete dense mode.
3. Add widget tests in both `connector_panel_test.dart` and `ops_control_cluster_test.dart` that verify render box width and height `>= 48.0` for each interactive control.
4. Re-run:
   - `dart analyze lib/src/organisms/ops_control_cluster/ lib/src/organisms/connector_panel/ test/organisms/ops_control_cluster/ test/organisms/connector_panel/`
   - `flutter test test/organisms/ops_control_cluster/ test/organisms/connector_panel/ --concurrency=1 --no-pub`
   - `flutter test test/boundaries/ --concurrency=1 --no-pub`
5. Ensure dense mode remains accessible or is documented as an exception with justification.