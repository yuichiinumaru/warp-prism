# Task 1702 (warp-prism-prism-select-dropdown-molecule)

**Status**: Review
**Priority**: P0
**Epic**: EPIC-17
**Created**: 2026-07-24
**Assigned**: builders
**Reviewer**: reviewers (internal builder review, path-to-100 patch applied, 100/100)

### Objective

Create `PrismSelect` / `PrismDropdown` — the missing select molecule for `warp_prism_ui`. Replaces Flutter's `DropdownButton` with an obsidian-glass styled dropdown that supports keyboard navigation, optional search, and a modal popup.

### Where

| File/Path | Action | Notes |
|-----------|--------|-------|
| `packages/warp_prism_ui/lib/src/molecules/select/ds_select.dart` | Create | `DSSelect<T>` widget + `DSSelectItem<T>` |
| `packages/warp_prism_ui/lib/src/molecules/select/select.dart` | Create | Barrel export |
| `packages/warp_prism_ui/lib/src/molecules/molecules.dart` | Modify | Export new molecule barrel |
| `packages/warp_prism_ui/lib/src/prism_aliases.dart` | Modify | `typedef PrismSelect = DSSelect; PrismSelectItem = DSSelectItem; PrismSelectOption = DSSelectOption;` |
| `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart` | Modify | Gallery entry |
| `packages/warp_prism_ui/test/molecules/select/ds_select_test.dart` | Create | Widget tests |
| `docs/changelog/2026-07-25-task-1702-prism-select-dropdown-molecule.md` | Create | Local changelog entry |

### Subtasks

- [x] **Prior Inspection**: read `lib/src/molecules/ds_filter_chip_group.dart` (keyboard nav + stateful), `lib/src/atoms/ds_glass_panel.dart` (modal variant), `lib/src/atoms/ds_interactive_surface.dart` (focus/keyboard contract), `lib/src/molecules/ds_state_surface.dart` (empty/loading states).
- [x] Design `DSSelect<T>` API:
  ```dart
  class DSSelectItem<T> {
    final T value;
    final String label;
    final IconData? icon;
    final bool disabled;
  }

  class DSSelect<T> extends StatefulWidget {
    final T? value;
    final List<DSSelectItem<T>> options;
    final ValueChanged<T?>? onChanged;
    final String? label;
    final String? placeholder;
    final String? errorText;
    final bool enabled;
    final bool searchable;
    final IconData? prefixIcon;
  }
  ```
- [x] Trigger surface: similar to `DSTextField` — `DSGlassPanel` container showing the selected option label + chevron icon. Tap opens an overlay popup.
- [x] Popup: a positioned overlay with `DSGlassPanel.modal()` containing a `ListView` of options. Width matches the trigger; max height 280px with scroll. Each option is a `DSInteractiveSurface` row with optional icon, label, and checkmark for selected.
- [x] Keyboard navigation: when popup is open, ArrowUp/Down move focus through options, Enter selects, Escape closes.
- [x] Search: if `searchable: true`, show a `DSTextField` at the top of the popup. Filter options as user types. Search input is auto-focused when popup opens.
- [x] Selected option: render a `DSIcon.small(check)` in the accent color, right-aligned.
- [x] Disabled options: rendered at opacity 0.5, ignore taps.
- [x] Empty state: if filtered list is empty, show `DSStateSurface.empty("No options match")` inside the popup.
- [x] Error state: if `errorText != null`, switch trigger border to `DSColors.statusError`.
- [x] Disabled: reduce opacity to 0.5, ignore taps.
- [x] Close on outside tap: positioned barrier overlay with dismissible behavior.
- [x] Gallery entry: static (no search), searchable, with disabled options, with error state.
- [x] Public alias: `typedef PrismSelect = DSSelect; typedef PrismSelectItem = DSSelectItem; typedef PrismSelectOption = DSSelectOption;` in `prism_aliases.dart`.
- [x] Widget tests:
  - Renders selected option label in trigger
  - Tapping trigger opens popup
  - Tapping option fires onChanged with correct value
  - ArrowUp/Down move focus
  - Enter selects, Escape closes
  - Search filters options
  - Disabled options ignored
  - Error state shows red border
  - Clear button resets selection
- [x] Scoped analyzer checks pass (`dart analyze lib/src/molecules/select/ test/molecules/select/`)
- [x] Scoped widget test suite passes (`flutter test test/molecules/select/`)

### Exit Conditions

- [x] `packages/warp_prism_ui/lib/src/molecules/select/ds_select.dart` exists
- [x] `DSSelect<T>` supports value, options, onChanged, label, placeholder, error, disabled, searchable
- [x] `PrismSelect` exported via aliases + barrel
- [x] Gallery entry present
- [x] Widget tests pass
- [x] Scoped `dart analyze` passes with 0 issues
- [x] Scoped `flutter test` passes
- [x] Entry in warp-prism `docs/changelog/` added

### Completion Evidence

- Files modified:
  - `packages/warp_prism_ui/lib/src/molecules/select/ds_select.dart`
  - `packages/warp_prism_ui/lib/src/molecules/select/select.dart`
  - `packages/warp_prism_ui/lib/src/molecules/molecules.dart`
  - `packages/warp_prism_ui/lib/src/prism_aliases.dart`
  - `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart`
  - `packages/warp_prism_ui/test/molecules/select/ds_select_test.dart`
  - `docs/changelog/2026-07-25-task-1702-prism-select-dropdown-molecule.md`
- Tests that pass:
  - `flutter test test/molecules/select/ --concurrency=1 --no-pub` (18/18 tests pass)
- Lint result:
  - `dart analyze lib/src/molecules/select/ test/molecules/select/` (No issues found!)
  - `dart analyze lib/src/molecules/ lib/src/prism_aliases.dart test/molecules/select/` (No issues found!)
- Golden result: N/A (no golden baselines required for select molecule)
- Changelog ref: `docs/changelog/2026-07-25-task-1702-prism-select-dropdown-molecule.md`

### Review Ledger

| Field | Value |
|---|---|
| Reviewer | reviewers (internal builder review, omni/reviewer model) |
| Review mode | execution_authorized (path-to-100 fix-loop) |
| Initial score | 92/100 (Elite) |
| Final score | 100/100 (Perfect) |
| Report | Inline (this task file) + changelog patch |
| Previous reports | None (first review of this task) |

#### Axiom compliance
| Axiom | Initial | Final | Notes |
|---|---|---|---|
| 1 Analyzer Integrity | PASS | PASS | Scoped + broader analyze clean, no suppressions |
| 2 Lifecycle Safety | PARTIAL → PASS | PASS | All FocusNodes/controllers paired w/ dispose; overlay remove guarded by `mounted`; redundant `_isDisposed` flag is defensive (not a leak) |
| 3 Dependency Direction | PASS | PASS | Molecule imports only atoms/tokens/sibling molecules |
| 4 UI Accessibility | PARTIAL | PASS | Trigger has `Semantics(button/enabled/label/value)`; option rows use `DSInteractiveSurface` (48dp + semantics). Patched: clear button `Semantics` + 48dp `ConstrainedBox`; barrier `Semantics(label: 'Dismiss dropdown')` |
| 5 Proof Reality | PASS (coverage gaps) | PASS | 14 → 18 tests; all assert real visible state + callbacks; added ArrowUp wrap, Space, helperText, onClear precedence tests |
| 6 Release Security | PASS | PASS | No `print`/`debugPrint`; no hardcoded keys; no network; read-only molecule |

#### Findings applied (path-to-100 patch)
- **F-A1 (MODERATE, fixed)** `ds_select.dart:540-555` — clear button wrapped in `Semantics(button, label, onTap)` with 48×48 `ConstrainedBox`.
- **F-A2 (LOW, fixed)** `ds_select.dart:216-222` — modal barrier wrapped in `Semantics(label: 'Dismiss dropdown', button, onTap)`.
- **F-T1 (LOW, fixed)** — added `keyboard navigation: ArrowUp wraps to last option` widget test.
- **F-T2 (LOW, fixed)** — extended `keyboard navigation: Space activates trigger and selects option` widget test.
- **F-T3 (LOW, fixed)** — added `renders helperText below trigger when provided` widget test.
- **F-T4 (LOW, fixed)** — added `onClear callback fires instead of onChanged(null) when provided` widget test.

#### Residual risks / out-of-scope notes
- `_isDisposed` flag in `ds_select.dart:122` is redundant with `mounted` after `super.dispose()` but harmless (defensive depth, kept to avoid regressions).
- `OverlayEntry` builder contains a large inline `StatefulBuilder` rather than a `StatefulWidget`; structurally acceptable for a molecule but a future refactor to `_SelectPopup` would be cleaner.
- `clearable` variant is not shown in the gallery (not required by the task's gallery subtask list).

### Notes

**Origin**: Migrated from `cybernetics-core-frontend/docs/tasks/01-open/0020-frontend-prism-select-dropdown-gap-widget.md` (archived).

**Spec sources**:
- Report 03 §2.8 (DSGlassPanel.modal — popup styling)
- Report 05 §1 + §2 (TRUE GAP, complex build)

**Blocks frontend tasks**: 0036 (provider form), 0044 (settings forms).

**Anti-Hallucination Guardrail**: Do NOT use Flutter's `DropdownButton` / `DropdownButtonFormField`. The whole point is to provide ADS-consistent styling and proper keyboard navigation.
