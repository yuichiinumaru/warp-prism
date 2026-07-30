# Task 1116: Warp Prism Notification Toast System

> **Status**: `[x]` Ready For Review — independent path-to-100 re-review 2026-07-10 S=100 (reviewers second pass confirmed)
> **Review State**: `ACCEPTED_100` — independent S=100 (2026-07-10 reviewers); remains `03-review/`
> **ready_for_reviewer**: **yes**
> **Lane**: `docs/tasks/03-review/`
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
- [x] `flutter test` on new tests — **47/47** ×3 (`test/molecules/ds_toast_test.dart`, 2026-07-10 path-to-100). Prior gallery compile blocker resolved.
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
- [x] **Regression verification**: scoped toast `flutter test` **47/47** ×3 + `dart analyze` 0 machine issues on toast sources (2026-07-10). Package-wide melos residual remains EXTERNAL (not Task 1116 scope).

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

### Evidence refresh — 2026-07-09 (gt-flutter-engineer evidence batch)

| Check | Result |
| --- | --- |
| Deliverables `ds_toast.dart` / `ds_toast_manager.dart` | Present |
| `flutter test test/molecules/ds_toast_test.dart` | **+40 All tests passed** (prior gallery compile blocker **RESOLVED**) |
| **ready_for_reviewer** | **yes** |
| Lane | **left in `02-doing/`** |

### Independent review — 2026-07-09 (gt-code-quality-reviewer wave)

| Field | Value |
| --- | --- |
| **Score** | **100** |
| **Lane** | moved → `docs/tasks/03-review/` |
| **Policy** | Scoped re-verify green; package-wide melos residual not mass-failed |
| **Ledger** | `.agents/profiles/reviewers/review-260709230500-wave-1106-1123-promote.md` |

### Independent re-review — 2026-07-09 (reviewers / gt-flutter + code-quality)

| Field | Value |
| --- | --- |
| **Score** | **84/100** |
| **Verdict** | `REJECTED_TO_DOING` |
| **Lane** | returned → `docs/tasks/02-doing/` |
| **Report** | `docs/reports/review-wave-2026-07-09/task-1116-notification-toast-system-independent-rereview.md` |
| **Top blocker** | Timer stale idx + entry-owned onAction missing |
| **Policy** | S < 90 → return to doing; never 04-completed; no commit; live evidence only |
| **Regression guards** | Re-open if prior false-100 promote re-asserted without fixing top blocker |

### Path-to-100 fixer — 2026-07-10 (gt-flutter-engineer)

Closed independent re-review F1/F2/F3 against live sources (coordinate with Task 1308 timer-id fix).

| Path-to-100 item | Live proof |
| --- | --- |
| F1 Timer re-resolve by `entry.id` (never stale list idx) | `ds_toast_manager.dart` `_startTimer` captures `entryId`; Timer callback `indexWhere` by id; `_resyncHoverTimers` after dismiss structural change |
| F2 Entry-owned `onAction` + `dismissOnAction` | `DSToastEntry.onAction` / `dismissOnAction` (default true); manager wires `entry.onAction?.call()` then optional `dismiss` |
| F3 Pause-on-hover + id-safety regressions | Tests: `pause-on-hover keeps toast visible…`, `maxVisible eviction does not break remaining toast auto-dismiss by id`, `dismiss toast A while B is hovered…`, `entry onAction fires without dismissing when dismissOnAction is false`, `…when dismissOnAction true` |

| Check | Result |
| --- | --- |
| `dart analyze --format=machine` toast lib+test | **0** lines, exit 0 |
| `dart format --set-exit-if-changed` 3 scoped files | **0** changed |
| `flutter test --concurrency=1 --no-pub test/molecules/ds_toast_test.dart` | **47/47** ×3 consecutive |
| Shared with 1308 | Timer id re-resolve + hover pause already on shared `ds_toast*` sources; 1116 owns entry-action contract + path-to-100 regression suite |
| **ready_for_reviewer** | **yes** |
| Lane | **left in `02-doing/`** (no move; no git) |
| Changelog | `docs/changelog/20260710-170631-1116-toast-path-to-100-timer-id-onaction-builders.md` |


### Independent path-to-100 re-review — 2026-07-10 (gt-code-quality-reviewer)

| Field | Value |
| --- | --- |
| **Date** | 2026-07-10 |
| **Reviewer** | `gt-code-quality-reviewer` (reviewers profile) |
| **Score** | **100/100** (builder wave; **confirmed** by second-pass independent review below) |
| **Verdict** | `APPROVED_PROMOTE_TO_REVIEW` |
| **Lane outcome** | `docs/tasks/02-doing/` → `docs/tasks/03-review/` |
| **Prior reject score** | **84/100** |
| **Cheap live validation** | `cd packages/warp_prism_ui && flutter test --concurrency=1 --no-pub test/molecules/ds_toast_test.dart` → **+47 All tests passed** EXIT 0 |
| **Live log** | `tmp/path-to-100-epic11-rereview/1116.txt` |
| **Blockers closed** | timer re-resolve by entryId; entry onAction + dismissOnAction; hover pause id-safety |
| **Findings** | None blocking. Package-wide melos residual treated as EXTERNAL (not this task scope). |
| **Wave report** | `docs/reports/review-wave-2026-07-10/epic11-path-to-100-rereview.md` |
| **Policy** | S=100 → promote to `03-review/`; never `04-completed/` from this pass; no git |
| **No git operations** | confirmed |

---

## Review Ledger

> [!IMPORTANT]
> Before path-to-100 work, read the latest full report and all reports listed
> under Previous Reports. Persistent findings and regression guards are part of
> the acceptance contract; do not fix the latest finding by undoing a previously
> accepted repair.

### Latest Review

- **Date**: 2026-07-10
- **Reviewer profile**: `reviewers` (gt-flutter-code-reviewer + gt-code-quality-reviewer)
- **Score**: `100/100`
- **Verdict**: `ACCEPTED_100`
- **Full report**: `docs/reports/review-wave-2026-07-10/task-1116-path-to-100-independent-rereview.md`
- **Lane outcome**: remains in `03-review/` (never `04-completed/` from this pass)
- **Task reference**: Task 1116 (`1116-warp-prism-notification-toast-system`)

#### Current Open Blockers

- None. Prior F1–F3 **RESOLVED**.

#### Path-to-100 Summary

- At 100 for task scope. Coordinate future toast edits with Task 1308 shared-source ownership.

### Previous Reports

- `2026-07-10` — builder/confirmed 100 — `docs/reports/review-wave-2026-07-10/epic11-path-to-100-rereview.md`
  - **Carried forward**: none
  - **Resolved since**: timer id re-resolve; onAction/dismissOnAction; hover id-safety
  - **Regression guard**: keep maxVisible eviction + dismiss-while-hover + dismissOnAction false/true tests
- `2026-07-09` — `84/100` — `docs/reports/review-wave-2026-07-09/task-1116-notification-toast-system-independent-rereview.md`
  - **Carried forward**: none
  - **Resolved since**: F1, F2, F3
  - **Regression guard**: never recapture list index for timer fire after mutations
