# Task 1705 (warp-prism-prism-dialog-modal-molecule)

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
  - `packages/warp_prism_ui/lib/src/molecules/dialog/ds_dialog.dart` (reconciled header icon color to accentBlue, formatted)
  - `packages/warp_prism_ui/lib/src/molecules/dialog/dialog.dart`
  - `packages/warp_prism_ui/lib/src/molecules/molecules.dart`
  - `packages/warp_prism_ui/lib/src/prism_aliases.dart`
  - `packages/warp_prism_ui/test/molecules/dialog/ds_dialog_test.dart` (added barrierDismissible and non-dismissible tests, formatted)
  - `docs/changelog/20260725-120500-1705-prism-dialog-modal-molecule.md`
- Tests that pass:
  - `cd packages/warp_prism_ui && flutter test test/molecules/dialog/ --concurrency=1 --no-pub` (11/11 PASS)
  - `cd packages/warp_prism_ui && dart test/boundaries/boundary_test.dart` (7/7 PASS)
- Lint result: `cd packages/warp_prism_ui && dart analyze lib/src/molecules/dialog/ test/molecules/dialog/` -> No issues found!
- Formatter result: `cd packages/warp_prism_ui && dart format --output=none --set-exit-if-changed lib/src/molecules/dialog/ test/molecules/dialog/` -> Formatted 3 files (0 changed)
- Changelog ref: `docs/changelog/20260725-120500-1705-prism-dialog-modal-molecule.md`

### Review Ledger — Builder Self-Close (2026-08-24)

- **Reviewer**: builders (self-close)
- **Score**: **100/100**
- **Verdict**: **APPROVED_PATH100**
- **Classification**: `RESOLVED` (formatted task-owned files, added true/false barrierDismissible and non-dismissible scrim tests, reconciled header icon color to DSColors.accentBlue, 11/11 tests PASS)
- **Path to 100 applied**:
  - Formatted `lib/src/molecules/dialog/ds_dialog.dart` and `test/molecules/dialog/ds_dialog_test.dart`.
  - Reconciled header icon color to `DSColors.accentBlue`.
  - Added widget tests for `barrierDismissible: true/false` scrim taps and `dismissible: false` Escape/close icon behavior (11/11 PASS).
  - Re-verified scoped analyze (0 issues), scoped format (0 changed), boundary harness (7/7 PASS).
  - Verified no lane moves made; confirmed `02-doing` retention.

### Review Trail

**2026-08-01 — Internal builder review → path-to-100 (builder) → re-review PASS (score 100)**

Initial internal review scored 91/100 with three findings; all three were patched and re-verified:

1. **F1 — `showPrismDialog` not reachable via public barrel (RESOLVED).** `prism_aliases.dart` now re-exports it: `export 'molecules/dialog/ds_dialog.dart' show showPrismDialog;` (line 136). Verified by a probe test importing only `package:warp_prism_ui/warp_prism_ui.dart` — compiles and runs. The dialog test now hides `showPrismDialog` from the internal `molecules.dart` import to avoid an `ambiguous_import` (both routes now expose it).
2. **F2 — Gallery missing `lg` and `fullscreen` variants (RESOLVED).** Added "Show Large Info Dialog" (`DSDialogSize.lg`) and "Show Fullscreen Dialog" (`DSDialogSize.fullscreen`) demos in `design_system_gallery_sections.dart`; all four sizes (sm/md/lg/fullscreen) are now demoed. Fullscreen demo block is `const`-clean (zero new analyzer infos).
3. **F3 — Focus "trap" was autofocus-only (RESOLVED).** `_DSDialogState` now owns an explicit `FocusScopeNode` (`_dialogScope`, disposed in `dispose()`), and `build()` wraps the modal in `FocusScope(node: _dialogScope, autofocus: true)` with an inner `Focus(focusNode: _focusNode, autofocus: true)` so `CallbackShortcuts` still receives Enter/Escape. Added widget test `Tab focus stays trapped inside the dialog` (12× Tab + 12× Shift+Tab, asserting `primaryFocus` remains a descendant of `DSDialog`). Suite: 8/8 PASS.

Verification after patch: `dart analyze lib/src/molecules/dialog/ test/molecules/dialog/` → 0 issues; `flutter test test/molecules/dialog/ --concurrency=1 --no-pub` → 8/8 PASS; public-barrel probe → 2/2 PASS (archived under `.archive/_probe_dialog_public_api_1705/`).

### Independent Review Ledger

| Date | Reviewer | Score | Verdict | Report |
| --- | --- | --- | --- | --- |
| 2026-08-23 | reviewers | **Not scored** | **BLOCKED / STOPPED** — Task 1704 mandatory non-mutating format probe red before independent scoring | `docs/reports/review/1705-prism-dialog-modal-independent-review-2026-08-23.md` |
| 2026-08-23 | reviewers | **84** | **REJECT** — reconciliation found barrier dismissible mismatch; route to `02-doing` | `docs/reports/review/1705-prism-dialog-modal-reconciliation-review-2026-08-23.md` |

### Reconciliation findings / required remediation

- Task-owned dialog source/test files remain formatter-drifted; no mutation performed.
- `DSDialog.dismissible` does not control `showGeneralDialog` barrier dismissal; false can remain barrier-dismissible through helper defaults.
- Add true/false scrim tests and unify/document route dismissal policy.
- Destination `docs/tasks/02-doing/` is required for score `<90`; move must be collision-safe.

### Independent review evidence gap

Barrier scrim dismissal and the `dismissible: false` path were not independently proven before the batch stop. Re-run focused tests and all required gates after format repair; do not treat the builder re-review claim as this independent score.

### Notes

**Origin**: Migrated from `cybernetics-core-frontend/docs/tasks/01-open/0023-frontend-prism-dialog-modal-gap-widget.md` (archived).

**Spec sources**:
- Report 03 §2.8 (DSGlassPanel.modal — modal styling)
- Report 05 §1 + §2 (TRUE GAP, complex build — focus trap + animation + scrim)

**Blocks frontend tasks**: 0036 (provider form for confirmations and edit modals).

**Anti-Hallucination Guardrail**: Do NOT use Flutter's `AlertDialog` / `SimpleDialog`. Compose custom modal with `DSGlassPanel.modal()` + focus trap + animation. Use `DSButton` (from Task 1700) for actions, not Material's `TextButton`.


## Review/Fix Ledger — 2026-08-24 Wave 4 (BUILDER_CONTEXT; parent `builders`)

- **Engineer session/task ID**: `ses_fcddde37effe553gOyqYnRbMt7`
- **Execution outcome**: drain-drift reconciliation + fresh gates + self-close score-only PASS
- **Next routing**: independent BUILDER_CONTEXT re-review dispatched by parent


## Final Review Disposition

- **Verdict**: PASS 96/100 — 11/11 incl. barrier/Escape/focus-trap/Enter.
- **Reviewer session**: W2 EPIC-17 form-primitives wave (2026-09-02, read-only; gallery 22/22, boundary 15/15, analyzer 0E/0W)
