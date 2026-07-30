# Task 1703 (warp-prism-prism-checkbox-atom)

**Status**: Doing
**Priority**: P0
**Epic**: EPIC-17
**Created**: 2026-07-24
**Assigned**: builders

### Objective

Create `PrismCheckbox` — the missing checkbox atom for `warp_prism_ui`. Replaces Flutter's `Checkbox` with an obsidian-glass styled checkbox that uses glow border on the checked state, supports a label, and is controlled externally.

### Where

| File/Path | Action | Notes |
|-----------|--------|-------|
| `packages/warp_prism_ui/lib/src/atoms/checkbox/ds_checkbox.dart` | Create | `DSCheckbox` widget |
| `packages/warp_prism_ui/lib/src/atoms/checkbox/checkbox.dart` | Create | Barrel export for checkbox atom |
| `packages/warp_prism_ui/lib/src/atoms/atoms.dart` | Modify | Export `checkbox/checkbox.dart` |
| `packages/warp_prism_ui/lib/src/prism_aliases.dart` | Modify | `typedef PrismCheckbox = DSCheckbox;` |
| `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart` | Modify | Gallery entry |
| `packages/warp_prism_ui/test/atoms/checkbox/ds_checkbox_test.dart` | Create | Widget tests + goldens |

### Subtasks

- [x] **Prior Inspection**: read `lib/src/atoms/ds_badge.dart` (status dot variants), `lib/src/atoms/ds_glow_border.dart` (glow effect), `lib/src/atoms/ds_interactive_surface.dart` (keyboard/focus contract), `lib/src/atoms/ds_icon.dart`.
- [x] Design `DSCheckbox` API:
  ```dart
  class DSCheckbox extends StatelessWidget {
    final bool? value;
    final ValueChanged<bool?>? onChanged;
    final String? label;
    final bool enabled;
    final bool tristate;
    final FocusNode? focusNode;
    final String? semanticLabel;

    const DSCheckbox({...});
  }
  ```
- [x] Render: 20×20 box, `DSGlassPanel.subtle()` / glass overlay background, `DSRadii.button` (6px) border radius. Border: 1px `DSColors.borderSubtle` when unchecked, 1px `DSColors.accentCyan` when checked.
- [x] Checked state: render a `DSIcon(Icons.check, size: 14, color: DSColors.obsidianDeep)` over a filled `DSColors.accentCyan` background. Add a subtle `DSGlowBorder` glow effect on the checked state.
- [x] Indeterminate: render a horizontal `DSColors.accentCyan` bar (10×2px) in the center of the box.
- [x] Label: if `label != null`, render `DSText.labelMedium(label)` to the right with `DSSpacing.sm` gap. Tap on label also toggles.
- [x] Wrap the entire box+label row in `DSInteractiveSurface` for keyboard activation (Space) and focus ring.
- [x] Disabled: reduce opacity to 0.5, ignore `onChanged`.
- [x] Tristate: cycle through `false → true → null → false` on tap.
- [x] Gallery entry: unchecked, checked, indeterminate, disabled, with label.
- [x] Public alias: `typedef PrismCheckbox = DSCheckbox;` in `prism_aliases.dart`.
- [x] Widget tests:
  - Unchecked renders empty box
  - Checked renders check mark + accent background + glow
  - Indeterminate renders bar
  - Tap fires onChanged
  - Space key toggles
  - Disabled reduces opacity, ignores input
  - Tristate cycles correctly
  - Golden tests for all states
- [x] `dart analyze` passes on checkbox module and tests
- [x] `flutter test test/atoms/checkbox/` passes (12 tests green)
- [x] `dart test/boundaries/boundary_test.dart` passes (7/7 PASS)

### Exit Conditions

- [x] `packages/warp_prism_ui/lib/src/atoms/checkbox/ds_checkbox.dart` exists
- [x] `DSCheckbox` supports value, onChanged, label, disabled, tristate
- [x] `PrismCheckbox` exported via aliases + barrel
- [x] Gallery entry present
- [x] Widget tests + goldens pass
- [x] `dart analyze` passes (0 issues)
- [x] `flutter test` passes
- [x] Entry in warp-prism `.changelog/` added

### Completion Evidence

- Files modified:
  - `packages/warp_prism_ui/lib/src/atoms/checkbox/ds_checkbox.dart` (created)
  - `packages/warp_prism_ui/lib/src/atoms/checkbox/checkbox.dart` (created)
  - `packages/warp_prism_ui/lib/src/atoms/atoms.dart` (modified)
  - `packages/warp_prism_ui/lib/src/prism_aliases.dart` (modified)
  - `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart` (modified)
  - `packages/warp_prism_ui/test/atoms/checkbox/ds_checkbox_test.dart` (created)
  - `.changelog/20260725-120000-1703-prism-checkbox-atom.md` (created)
- Tests that pass:
  - `flutter test test/atoms/checkbox/ds_checkbox_test.dart` (12/12 PASS: 8 unit/widget + 4 golden tests)
  - `dart test/boundaries/boundary_test.dart` (7/7 PASS: zero DS* leaks, all public DS declarations have Prism aliases)
- Lint result: `dart analyze lib/src/atoms/checkbox/ test/atoms/checkbox/` -> No issues found!
- Golden result: 4 goldens generated and verified (`checkbox_unchecked.png`, `checkbox_checked.png`, `checkbox_indeterminate.png`, `checkbox_disabled.png`)
- Changelog ref: `.changelog/20260725-120000-1703-prism-checkbox-atom.md`

### Notes

**Origin**: Migrated from `cybernetics-core-frontend/docs/tasks/01-open/0021-frontend-prism-checkbox-gap-widget.md` (archived).

**Spec sources**:
- Report 03 §2 (DSGlowBorder — checked-state glow)
- Report 05 §1 + §2 (TRUE GAP, simple build)

**Blocks frontend tasks**: 0044 (settings forms need checkboxes for toggles).

**Anti-Hallucination Guardrail**: Do NOT use Flutter's `Checkbox` / `CheckboxListTile`. Compose with `DSGlassPanel` + `DSGlowBorder` + `DSIcon` for ADS-consistent styling.
