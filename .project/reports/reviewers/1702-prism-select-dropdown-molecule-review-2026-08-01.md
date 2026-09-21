# Independent Adversarial Review — Task 1702 PrismSelect / PrismDropdown Molecule

- **Reviewer**: reviewers
- **Date**: 2026-08-01
- **Task**: `docs/tasks/03-review/1702-warp-prism-prism-select-dropdown-molecule.md`
- **Report**: this file
- **Score**: **93/100**
- **Verdict**: **PASS WITH EVIDENCE GAP — remain in `03-review`**

## Scope and Evidence

Live implementation inspected:
- `packages/warp_prism_ui/lib/src/molecules/select/ds_select.dart`
- `packages/warp_prism_ui/lib/src/molecules/select/select.dart`
- `packages/warp_prism_ui/lib/src/molecules/molecules.dart`
- `packages/warp_prism_ui/lib/src/prism_aliases.dart`
- `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart`
- `packages/warp_prism_ui/test/molecules/select/ds_select_test.dart`

Public aliases `PrismSelect<T>`, `PrismSelectItem<T>`, and `PrismSelectOption<T>` are present. The trigger is 48dp minimum height, clear action is explicitly constrained to 48×48, and option rows compose `DSInteractiveSurface`, which supplies 48dp minimum targets and Enter/Space semantics. Overlay resources (`OverlayEntry`, popup/search focus nodes, search controller) are explicitly removed/disposed.

## Live Commands

```text
dart format --output=none --set-exit-if-changed \
  lib/src/atoms/button lib/src/atoms/text_field lib/src/molecules/select \
  lib/src/atoms/checkbox test/atoms/button test/atoms/text_field \
  test/molecules/select test/atoms/checkbox
→ formatter reported 8 changed files (non-mutating check requested; no golden/update flag used).

dart analyze lib/src/molecules/select test/molecules/select
→ No issues found!

flutter test test/molecules/select/ --concurrency=1 --no-pub
→ 18/18 tests passed.
```

Validation stopped when the parallel EPIC-17 test wave exposed runtime golden failures in other assigned tasks. Boundary and gallery commands were therefore **not run**; this report does not claim boundary or gallery test execution.

## Axiom Compliance

| Axiom | Status | Evidence |
|---|---|---|
| Analyzer integrity | PASS | Task-scoped analyzer returned no issues. |
| Lifecycle safety | PASS | External trigger focus node is not disposed; internal focus node is disposed. Popup entry, popup focus node, search focus node, and search controller are removed/disposed in `_closePopup()` and on widget disposal. |
| Dependency direction | UNVERIFIED | Imports are local atoms/tokens/molecules, but the boundary harness was not run due the runtime-failure stop gate. |
| 48dp semantics | PASS (source + behavioral tests) | Trigger min-height 48; clear action 48×48; option rows use `DSInteractiveSurface`. Explicit semantic labels exist for trigger, options, clear, and barrier. |
| Focus/keyboard | PASS | Escape closes; ArrowUp/ArrowDown skip disabled items and wrap; Enter/Space select; trigger opens on Enter/Space/arrows; searchable mode auto-focuses the search field. |
| Controller/overlay lifecycle | PASS | Overlay and all allocated focus/controller resources have cleanup paths. |
| Gallery/tests | PARTIAL | Gallery source includes static, searchable, error, and disabled examples; scoped suite is green, but gallery runtime test and boundary harness were not run after the stop gate. |
| Release safety | PASS | No network, key, persistence, or debug output path found. |

## Findings

### F-A1 — Boundary and gallery evidence gap (MODERATE)

The scoped select suite is green, but the required boundary and gallery checks were not run because the first parallel EPIC-17 test wave produced runtime failures in Tasks 1700, 1701, and 1703. This task remains in review, but the evidence is not a perfect closeout packet.

### F-A2 — Formatter check reports changed files (LOW)

The requested non-mutating format check reported eight files as changed. The builder should rerun it after the batch is clean and retain exact output.

### F-A3 — Overlay implementation is structurally dense (LOW)

`ds_select.dart` is a 725-line molecule with a large inline `StatefulBuilder` overlay. This is not a correctness blocker at 93, but extracting a `_SelectPopup` stateful widget would make focus/resource ownership easier to audit.

## Path to 100

1. Re-run the package boundary harness and gallery test after the EPIC-17 runtime failures are repaired.
2. Add explicit render-box assertions for trigger and option rows (not only source-level reliance on `DSInteractiveSurface`).
3. Rerun non-mutating format and scoped analyzer/test commands with clean output.
4. Optionally extract the inline popup into a focused widget to reduce lifecycle complexity.
