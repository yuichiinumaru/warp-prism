# Task 1705 (warp-prism-prism-dialog-modal-molecule)

**Status**: Doing
**Priority**: P0
**Epic**: EPIC-17
**Created**: 2026-07-24
**Assigned**: builders

### Objective

Create `PrismDialog` / `PrismModal` — the missing modal dialog molecule for `warp_prism_ui`. Replaces ad-hoc `showDialog` with an obsidian-glass styled modal that has a scrim, ESC/barrier dismiss, focus trap, and slot-based content.

### Where

| File/Path | Action | Notes |
|-----------|--------|-------|
| `packages/warp_prism_ui/lib/src/molecules/dialog/ds_dialog.dart` | Create | `DSDialog` widget + `showPrismDialog()` helper |
| `packages/warp_prism_ui/lib/src/molecules/dialog/dialog.dart` | Create | Barrel export for dialog molecule |
| `packages/warp_prism_ui/lib/src/molecules/molecules.dart` | Modify | Export new molecule barrel |
| `packages/warp_prism_ui/lib/warp_prism_ui.dart` | Modify | Export via prism_aliases.dart |
| `packages/warp_prism_ui/lib/src/prism_aliases.dart` | Modify | `typedef PrismDialog = DSDialog;` |
| `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart` | Modify | Gallery entry |
| `packages/warp_prism_ui/test/molecules/dialog/ds_dialog_test.dart` | Create | Widget tests |
| `docs/changelog/20260725-120500-1705-prism-dialog-modal-molecule.md` | Create | Local changelog entry |

### Subtasks

- [x] **Prior Inspection**: read `lib/src/atoms/ds_glass_panel.dart` (modal variant), `lib/src/molecules/ds_state_surface.dart`, `lib/src/atoms/ds_interactive_surface.dart` (keyboard contract), `lib/src/atoms/ds_glow_border.dart`, `lib/src/tokens/ds_motion.dart`.
- [x] Design `DSDialog` API:
  ```dart
  class DSDialog extends StatelessWidget {
    final String? title;
    final Widget? content;          // can be any widget (form, message, list, etc.)
    final List<DSDialogAction> actions;  // usually [cancel, confirm]
    final bool dismissible;          // ESC + barrier tap closes
    final DSDialogSize size;         // small, medium, large, fullscreen
  }

  class DSDialogAction {
    final String label;
    final VoidCallback? onPressed;
    final DSButtonVariant variant;   // primary, secondary, danger, ghost
  }

  Future<T?> showPrismDialog<T>({
    required BuildContext context,
    required WidgetBuilder builder,  // returns DSDialog
  });
  ```
- [x] Modal container: `DSGlassPanel.modal()` (existing variant), 360px default width, max-width per `DSDialogSize`, `DSRadii.modal` (16px) border radius. Center-aligned in the viewport.
- [x] Scrim: full-screen black with 0.7 opacity overlay. Click on scrim closes the dialog (if `dismissible: true`).
- [x] Title bar: if `title != null`, render `DSText.headingSmall(title)` at the top, separated by a 1px `DSColors.borderSubtle` line.
- [x] Content slot: any `Widget` — usually a `DSText.bodyMedium` for confirmations, or a form for editing, or a list for selection. Scrollable if overflows.
- [x] Actions bar: at the bottom, right-aligned row of `DSButton` (from Task 1700). Separated from content by 1px divider. Spacing: `DSSpacing.sm` between buttons.
- [x] Focus trap: use `FocusScope` + `Focus` with `autofocus: true`. Trap focus inside the dialog.
- [x] Keyboard: ESC closes (if `dismissible: true`). Enter triggers the primary action.
- [x] Animation: fade in scrim + scale up modal (0.95 → 1.0) with `DSMotion.normal` (200ms). Reverse on close.
- [x] Gallery entry: confirmation dialog, form dialog (with DSTextField + DSButton actions), large info dialog, fullscreen.
- [x] Public alias: `typedef PrismDialog = DSDialog; typedef PrismDialogAction = DSDialogAction; typedef PrismDialogSize = DSDialogSize;` in `prism_aliases.dart`.
- [x] Widget tests:
  - Renders title, content, and actions
  - Scrim tap closes dialog (when dismissible)
  - ESC closes dialog
  - Enter triggers primary action
  - Focus trapped inside dialog
  - Action onPressed fires
  - Dialog returns result via Navigator.pop
- [x] `dart analyze lib/src/molecules/dialog/ test/molecules/dialog/` passes
- [x] `flutter test test/molecules/dialog/ --concurrency=1 --no-pub` passes

### Exit Conditions

- [x] `packages/warp_prism_ui/lib/src/molecules/dialog/ds_dialog.dart` exists
- [x] `DSDialog` supports title, content, actions, dismissible, size
- [x] `showPrismDialog()` helper available
- [x] `PrismDialog` exported via aliases + barrel
- [x] Gallery entry present
- [x] Widget tests pass (7/7 PASS)
- [x] `dart analyze` passes (0 errors)
- [x] `flutter test test/molecules/dialog/ --concurrency=1 --no-pub` passes
- [x] Entry in warp-prism `docs/changelog/` added

### Completion Evidence

- Files modified:
  - `packages/warp_prism_ui/lib/src/molecules/dialog/ds_dialog.dart` (created)
  - `packages/warp_prism_ui/lib/src/molecules/dialog/dialog.dart` (created)
  - `packages/warp_prism_ui/lib/src/molecules/molecules.dart` (modified)
  - `packages/warp_prism_ui/lib/src/prism_aliases.dart` (modified)
  - `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart` (modified)
  - `packages/warp_prism_ui/test/molecules/dialog/ds_dialog_test.dart` (created)
  - `docs/changelog/20260725-120500-1705-prism-dialog-modal-molecule.md` (created)
- Tests that pass:
  - `cd packages/warp_prism_ui && flutter test test/molecules/dialog/ --concurrency=1 --no-pub` (7/7 PASS)
- Lint result:
  - `cd packages/warp_prism_ui && dart analyze lib/src/molecules/dialog/ test/molecules/dialog/` (0 issues)
  - `cd packages/warp_prism_ui && dart analyze` (0 errors)
- Changelog ref: `docs/changelog/20260725-120500-1705-prism-dialog-modal-molecule.md`

### Notes

**Origin**: Migrated from `cybernetics-core-frontend/docs/tasks/01-open/0023-frontend-prism-dialog-modal-gap-widget.md` (archived).

**Spec sources**:
- Report 03 §2.8 (DSGlassPanel.modal — modal styling)
- Report 05 §1 + §2 (TRUE GAP, complex build — focus trap + animation + scrim)

**Blocks frontend tasks**: 0036 (provider form for confirmations and edit modals).

**Anti-Hallucination Guardrail**: Do NOT use Flutter's `AlertDialog` / `SimpleDialog`. Compose custom modal with `DSGlassPanel.modal()` + focus trap + animation. Use `DSButton` (from Task 1700) for actions, not Material's `TextButton`.
