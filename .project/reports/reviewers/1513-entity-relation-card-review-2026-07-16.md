# Independent Review — Task 1513 PrismEntityRelationCard Organism

- **Reviewer lane**: reviewers
- **Date**: 2026-07-16
- **Task file reviewed**: `docs/tasks/03-review/1513-warp-prism-entity-relation-card-organism.md`
- **Implementation surface**: `packages/warp_prism_ui/lib/src/organisms/entity_relation_card/`
- **Verdict**: **REJECT — route to `02-doing`**
- **Score**: **88/100**

## Axiom Compliance

| Axiom | Status | Evidence |
| --- | --- | --- |
| 1. Analyzer Integrity | PARTIAL | Task-scoped `dart analyze lib/src/organisms/entity_relation_card/ test/organisms/entity_relation_card/` returned `No issues found!`; package-wide `dart analyze lib test` returned **141 info issues**. |
| 2. Lifecycle Safety | PASS | Task surface creates **0** controllers/subscriptions/timers/listeners requiring disposal. `_DSEntityRelationCardState` stores only `bool _internalCollapsed`; no `dispose()` required. |
| 3. Dependency Direction | PASS | Composes existing `DSGraphCanvas` (`ds_entity_relation_card.dart:231-236`) and imports only Flutter plus local ADS atoms/molecules/tokens. Boundary harness printed **7/7 PASS**. No force-graph JS dependency found. |
| 4. UI Accessibility | FAIL | Interactive definitions: 5 (`IconButton`, `OutlinedButton`, `ElevatedButton`, tappable legend `GestureDetector`, keyboard `FocusableActionDetector`). Explicit semantic wrappers: 5. Touch-target failures: 1 confirmed legend chip (`_LegendItem` padding only `sm/xxs` at `ds_entity_relation_card.dart:429-432`; the `GestureDetector` hit region is chip-sized, not 48dp). |
| 5. Proof Reality | PASS | Live combined EPIC-15 test run passed **47/47**; this task contributes **6** widget tests covering render, empty, collapse/expand, callbacks, keyboard legend activation, and semantics. |
| 6. Release Security | PASS | No secrets, no `print()`/`debugPrint()`, no live API/network/persistence, no force-graph JS port. |

## Live Commands Run

```bash
cd packages/warp_prism_ui && dart analyze lib test
# 141 info issues found (package-wide; includes unrelated pre-existing files).

cd packages/warp_prism_ui && dart analyze lib/src/organisms/entity_relation_card/ test/organisms/entity_relation_card/
# No issues found!

cd packages/warp_prism_ui && flutter test test/organisms/map_canvas_stage/ test/organisms/entity_relation_card/ test/organisms/floating_analytics_hud/ test/organisms/ops_control_cluster/ test/organisms/connector_panel/ --concurrency=1 --no-pub
# 47/47 All tests passed; entity_relation_card contributes 6 tests.

cd packages/warp_prism_ui && flutter test test/boundaries/ --concurrency=1 --no-pub
# Boundary harness: 7/7 PASS, 0 FAIL, 0 violations.
```

## Findings

### MODERATE — Legend filter controls are below 48dp touch target

- `packages/warp_prism_ui/lib/src/organisms/entity_relation_card/ds_entity_relation_card.dart:404-410` makes each legend chip tappable with `GestureDetector`.
- `packages/warp_prism_ui/lib/src/organisms/entity_relation_card/ds_entity_relation_card.dart:429-432` sizes the chip with only horizontal `DSSpacing.sm` and vertical `DSSpacing.xxs` padding around an 8px dot and label. This does not satisfy the 48x48dp interactive target requirement.

**Change recommendation**: wrap the `_LegendItem` returned from `_LegendButton` in `ConstrainedBox(constraints: BoxConstraints(minWidth: 48, minHeight: 48))` and center the visual chip inside the larger hit area, or replace the custom `GestureDetector` with an accessible Material button/chip configured with 48dp minimum constraints.

### LOW — Implementation remains a large organism file

- `packages/warp_prism_ui/lib/src/organisms/entity_relation_card/ds_entity_relation_card.dart` is **458 lines**, above the >200-line mega-widget review threshold.

**Change recommendation**: extract private widgets for header, body, footer actions, and legend item while preserving the public `DSEntityRelationCard`/`PrismEntityRelationCard` constructor.

### SAFE — Internal builder score was not accepted blindly

- Task file claimed internal builder review score 100 at `docs/tasks/03-review/1513-warp-prism-entity-relation-card-organism.md:191-201`. I re-ran live analyzer/tests/boundary checks and rejected the 100 because the legend touch target still violates the UI Accessibility axiom.

## Path to 100

1. Make legend filter hit regions at least 48x48dp while retaining existing semantic label and Enter/Space activation.
2. Add a widget test that measures the tappable legend ancestor size and asserts both width and height are `>= 48.0`.
3. Split the 458-line file into smaller private widgets or helpers under `entity_relation_card/`.
4. Re-run:
   - `dart analyze lib/src/organisms/entity_relation_card/ test/organisms/entity_relation_card/`
   - `flutter test test/organisms/entity_relation_card/ --concurrency=1 --no-pub`
   - `flutter test test/boundaries/ --concurrency=1 --no-pub`
5. Package-wide path to perfect requires resolving or formally scoping the existing package-wide analyzer info baseline.
