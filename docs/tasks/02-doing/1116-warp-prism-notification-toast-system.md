# Task 1116: Warp Prism Notification Toast System

> **Status**: `[/]` In Progress
> **Review State**: Package Gate Failed — implementation complete; pre-existing gallery compilation errors block full package gate
> **Priority**: 🟡 P1
> **Type**: `feature` | `design-system`
> **Origin**: EPIC-11 gap analysis (IMPORTANT GAP-I3)
> **Blocks**: CyberCore mutation screens (future), any screen requiring user feedback
> **Depends on**: Task 1105, Task 1107
>
> **⛔ Hard gate**: Component promotion requires Task 1102 output. No component
> may be promoted to `packages/warp_prism_ui` without a real CyberCore surface
> mapping from the control surface inventory. This prevents ADS from becoming
> generic/ornamental.

> [!IMPORTANT]
> Task identity is lane-neutral. Use `Task 1116` plus optional slug for
> dependencies, blockers, review ledgers, reports, and architecture references.

---

## Objective

Implement a reusable notification/toast system (`DSToast`, `DSToastManager`, `DSToastSeverity`) for the `warp_prism_ui` design system package with severity coloring (info/success/warning/error), stacking behavior, auto-dismiss with configurable duration, optional action buttons, and a Riverpod integration contract that keeps toast dispatch in a StateNotifier while the toast rendering lives in the DS widget layer. The ADS gap analysis reports a `state-notifier-owns-snackbar` rule but NO reusable widget exists — every screen would need to build ad-hoc snackbar/toast logic.

## Background Context

### What already exists

- The gap analysis report at `docs/reports/ads-gap-analysis-20260608.md` references a `state-notifier-owns-snackbar` rule — the principle that a Riverpod StateNotifier should own dispatching notification events, not the UI widget directly.
- `DSStateSurface` handles empty/loading/error page-level states but has no inline notification or toast capability.
- `DSColors.statusError`, `DSColors.statusHealthy` (assumed from status dot), and accent colors provide the severity color palette.
- `DSMotion` provides animation durations for enter/exit transitions.
- `DSGlassPanel` provides glass-panel container styling with blur and border.
- `DSSpacing`, `DSRadii`, `DSTypography` tokens are available.
- Flutter's `ScaffoldMessenger` and `SnackBar` are framework primitives but lack severity coloring, stacking, and the DS glass aesthetic.
- No `DSToast`, `DSNotification`, `DSToastOverlay`, or `DSToastSeverity` exists anywhere in the codebase.

### What is missing or broken

- No reusable toast/notification widget in `warp_prism_ui`.
- No severity enum with corresponding color/icon mapping.
- No overlay-based stacking manager for multiple simultaneous toasts.
- No auto-dismiss timer with configurable duration per toast.
- No action button support (e.g., "Undo", "View details").
- No Riverpod provider contract documenting how a StateNotifier dispatches toasts.
- No catalog cases for toast variants.

---

## Test Requirements

- `DSToastSeverity` MUST define at least 4 values: `info`, `success`, `warning`, `error`.
- Each severity MUST map to a distinct color from `DSColors` and a distinct icon.
- `DSToast` MUST render a glass-panel styled container with severity left-border accent, icon, title, optional message, and optional action button.
- `DSToastManager` MUST support stacking — multiple toasts render vertically from bottom with gap spacing.
- Auto-dismiss MUST fire after a configurable `duration` (default 4 seconds), with pause-on-hover support.
- Action button MUST trigger a callback and optionally dismiss the toast.
- The Riverpod contract MUST define: a `ToastNotifier` that holds a list of toast entries and provides `show()`/`dismiss()` methods; a `toastListProvider` that the widget layer watches.
- Widget tests MUST cover: render each severity, auto-dismiss fires, action button callback, stacking renders multiple toasts.

---

## Exit Conditions

- [x] `packages/warp_prism_ui/lib/src/molecules/ds_toast.dart` exists with `DSToast`, `DSToastSeverity`, `DSToastEntry` types.
- [x] `packages/warp_prism_ui/lib/src/molecules/ds_toast_manager.dart` exists with overlay-based stacking manager.
- [x] `packages/warp_prism_ui/lib/src/molecules/molecules.dart` exports toast widgets.
- [x] Gallery section added in `design_system_gallery_sections.dart` for info toast, success toast, warning toast, error toast, toast with action button, long message toast, and stacked toasts (3 simultaneous).
- [x] Riverpod integration contract documented inline in `ds_toast_manager.dart` — `ToastNotifier` / `toastListProvider` pattern.
- [x] `packages/warp_prism_ui/test/molecules/ds_toast_test.dart` created with full coverage (severity enum, entry data class, widget rendering, manager stacking, auto-dismiss, clear).
- [x] `flutter analyze` on new files passes (0 errors, 0 warnings).
- [ ] `flutter test` on new tests — BLOCKED by pre-existing compilation errors in `design_system_gallery_sections.dart` (unimplemented types from other tasks: DSErrorBoundary, DSLogViewer, DSDataTable, DSCommandPalette). Zero new errors from Task 1116.
- [x] Local changelog entry added under `docs/changelog/`.
- [x] Completion Evidence is filled before review handoff.

---

## Details

### What

Subtasks:

- [x] **Read existing code before modifying**: read `lib/design_system/molecules/ds_state_surface.dart`, `lib/design_system/atoms/ds_glass_panel.dart`, `lib/design_system/tokens/ds_colors.dart`, `lib/design_system/tokens/ds_motion.dart`, `lib/design_system/molecules/molecules.dart`, `apps/catalog/` structure, and `docs/reports/ads-gap-analysis-20260608.md` (GAP-I3 section).
- [x] Define `DSToastSeverity` enum with `info`, `success`, `warning`, `error` values, each mapping to a `DSColors` color and an `IconData`.
- [x] Define `DSToastEntry` data class with `id` (String/UUID), `severity`, `title`, `message?`, `actionLabel?`, `onAction?`, `duration`, `createdAt`.
- [x] Implement `DSToast` widget: glass-panel styled container with severity left-border accent (4px colored bar), severity icon, title (bold), message (secondary text), optional action button (`TextButton`), close/dismiss icon.
- [x] Implement `DSToastManager` as an `OverlayEntry`-based manager: maintains a list of `DSToastEntry`, renders stacked `DSToast` widgets from bottom-right with `AnimatedSlide`/`AnimatedOpacity` slide-in/fade-out transitions, handles auto-dismiss via `Timer`, supports pause-on-hover via `MouseRegion`.
- [x] Implement `DSToastManager.show()` static/instance method for imperative toast dispatch from anywhere in the widget tree.
- [x] Define Riverpod integration contract: document `ToastNotifier extends StateNotifier<List<DSToastEntry>>` with `show(entry)` and `dismiss(id)` methods; `toastListProvider` as `StateNotifierProvider`; widget layer watches provider and renders through `DSToastManager`. This is a contract/specification — the actual Riverpod dependency is documented but lives in the app layer, not in the DS package.
- [x] Add gallery cases in `design_system_gallery_sections.dart` for: each severity variant, toast with action button, toast with long message, stacked toasts (3 simultaneous), auto-dismiss demonstration.
- [x] Write widget tests for `DSToast` (renders severity variants, action callback fires), `DSToastManager` (stacking, auto-dismiss timer, pause-on-hover).
- [x] **Simplicity pass**: avoid over-engineering — the toast is a positioned overlay with a timer. No queue system, no priority levels, no persistence.
- [ ] **Regression verification**: run `melos run analyze` and `melos run test`. *Blocked by pre-existing compilation errors in `design_system_gallery_sections.dart` referencing unimplemented types (DSErrorBoundary, DSLogViewer, DSDataTable, DSCommandPalette). Zero new errors from Task 1116 files.*

### Where

| File | Purpose |
| --- | --- |
| `packages/warp_prism_ui/lib/src/molecules/ds_state_surface.dart` | Read — current state rendering pattern for consistency. |
| `packages/warp_prism_ui/lib/src/atoms/ds_glass_panel.dart` | Read — glass panel styling for toast container. |
| `packages/warp_prism_ui/lib/src/tokens/ds_colors.dart` | Read — severity color mapping. |
| `packages/warp_prism_ui/lib/src/tokens/ds_motion.dart` | Read — animation durations for enter/exit. |
| `packages/warp_prism_ui/lib/src/tokens/tokens.dart` | Read — all tokens barrel. |
| `packages/warp_prism_ui/lib/src/molecules/molecules.dart` | Modify — add toast exports. |
| `packages/warp_prism_ui/lib/src/molecules/ds_toast.dart` | Create — toast widget and severity enum. |
| `packages/warp_prism_ui/lib/src/molecules/ds_toast_manager.dart` | Create — overlay stacking manager. |
| `packages/warp_prism_ui/test/molecules/ds_toast_test.dart` | Create — toast widget tests. |
| `apps/catalog/` | Modify — add catalog gallery cases. |
| `docs/reports/ads-gap-analysis-20260608.md` | Read — GAP-I3 context. |

### How

1. Read all files listed in the Where table before writing any code.
2. Define `DSToastSeverity` enum with color/icon mapping from `DSColors` and `DSIcons`.
3. Define `DSToastEntry` as an immutable data class.
4. Implement `DSToast` as a `StatelessWidget` — pure rendering, no timers.
5. Implement `DSToastManager` as a `StatefulWidget` that manages an `OverlayEntry`, handles the entry list, auto-dismiss timers, pause-on-hover, and stacking layout.
6. Export from `molecules.dart`.
7. Add catalog cases.
8. Write widget tests.
9. Run `melos run analyze` and `melos run test`.
10. Add changelog entry.

### Why

Without a reusable toast system, every CyberCore screen that performs mutations (future task updates, configuration changes, server actions) would build ad-hoc snackbar logic that drifts from the ADS aesthetic and fails to implement severity coloring, stacking, or the Riverpod dispatch contract. The toast system is the primary user feedback mechanism for operational actions.

---

## Anti-Hallucination Guardrails

> [!CAUTION]
> Do not mark this task complete without running `melos run analyze` and
> `melos run test` and filling Completion Evidence.

> [!IMPORTANT]
> Preserve Warp Prism read-only mock-observatory semantics. The toast system
> is a display widget — it does not trigger backend mutations. Riverpod
> integration is a documented contract, not a live implementation.

> [!IMPORTANT]
> All colors MUST come from `DSColors`. All radii from `DSRadii`. All
> spacing from `DSSpacing`. No hardcoded color or spacing values.

---

## Validation Commands

```bash
cd packages/warp_prism_ui && flutter analyze
cd packages/warp_prism_ui && flutter test
melos run analyze
melos run test
```

If Flutter tooling is unavailable in the execution environment, record the exact
tooling failure and do not claim those checks passed.

---

## Completion Evidence

- **Files created/modified**:
  - CREATED: `packages/warp_prism_ui/lib/src/molecules/ds_toast.dart` (DSToast, DSToastSeverity, DSToastEntry)
  - CREATED: `packages/warp_prism_ui/lib/src/molecules/ds_toast_manager.dart` (DSToastManager, DSToastManagerState)
  - MODIFIED: `packages/warp_prism_ui/lib/src/molecules/molecules.dart` (added toast exports)
  - MODIFIED: `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_page.dart` (added toast section)
  - MODIFIED: `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart` (added buildToastsSection)
  - CREATED: `packages/warp_prism_ui/test/molecules/ds_toast_test.dart` (27 test cases)
  - CREATED: `docs/changelog/2026-06-08-task-1116-notification-toast-system.md`
- **Tests or validation commands**:
  - `flutter analyze lib/src/molecules/ds_toast.dart lib/src/molecules/ds_toast_manager.dart` — PASS (0 issues)
  - `flutter analyze lib/src/molecules/molecules.dart lib/src/gallery/design_system_gallery_page.dart test/molecules/ds_toast_test.dart` — PASS (0 errors, 0 warnings; only pre-existing info-level lints)
  - `flutter test test/molecules/ds_toast_test.dart` — BLOCKED (pre-existing compilation errors in `design_system_gallery_sections.dart` referencing unimplemented types from other tasks: DSErrorBoundary, DSLogViewer, DSDataTable, DSCommandPalette, DSDraggableCard, etc.)
  - `flutter analyze` (full package) — 682 issues total, all pre-existing; zero new errors or warnings from Task 1116 files
- **Local changelog entry**: `docs/changelog/2026-06-08-task-1116-notification-toast-system.md`
- **Agent-wiki / docs institutionalization**: N/A (no durable operational knowledge created beyond the DS contract)
- **Executor**: builders (omniroute/builder)
- **Completion date**: 2026-06-08
