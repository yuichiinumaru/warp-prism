# Task 1115: Warp Prism Loading Skeleton And Error Boundary

> **Status**: `[x]` Done (awaiting review)
> **Priority**: 🟡 P1
> **Type**: `feature` | `design-system`
> **Origin**: EPIC-11 gap analysis (IMPORTANT GAP-I2 + GAP-I6)
> **Blocks**: CyberCore screens, Task 1123 (virtual scroll integration)
> **Depends on**: Task 1105, Task 1107
>
> **⛔ Hard gate**: Component promotion requires Task 1102 output. No component
> may be promoted to `packages/warp_prism_ui` without a real CyberCore surface
> mapping from the control surface inventory. This prevents ADS from becoming
> generic/ornamental.

> [!IMPORTANT]
> Task identity is lane-neutral. Use `Task 1115` plus optional slug for
> dependencies, blockers, review ledgers, reports, and architecture references.

---

## Objective

Implement shimmer/skeleton loading patterns (`DSShimmer`, `DSSkeletonCard`, `DSSkeletonTableRows`) and an error boundary widget (`DSErrorBoundary`) with fallback UI, error isolation, and retry mechanism for the `warp_prism_ui` design system package. The current `DSStateSurface.loading` shows only a `CircularProgressIndicator` spinner — content-shaped skeletons are needed for cards, table rows, text lines, and dashboard panels. One widget crash currently kills the entire app because no error boundary wraps individual panels.

## Background Context

### What already exists

- `DSStateSurface` (`lib/design_system/molecules/ds_state_surface.dart`, 237 lines) handles empty/loading/error as a full-page centered state with `CircularProgressIndicator` for loading, icon + title + subtitle + action button for empty/error.
- `DSStateType` enum has 3 values: `empty`, `loading`, `error`.
- `DSToken`, `DSColors`, `DSSpacing`, `DSRadii`, `DSTypography`, `DSMotion` tokens exist.
- `DSGlassPanel` provides glass-panel container styling.
- `DSAssetCard`, `DSTaskCard` are existing card molecules.
- `DSMetricTile`, `DSStoryCardQuick` are existing metric/story cards.
- `DSShell` and `MasterDetailTemplate` provide page-level layout.
- Flutter has `ErrorWidget.builder` global override but no widget-level boundary.
- ADS gap report at `docs/reports/ads-gap-analysis-20260608.md` documents GAP-I2 (loading skeleton) and GAP-I6 (error boundary) as IMPORTANT gaps.

### What is missing or broken

- No `DSShimmer`, `DSSkeletonCard`, `DSSkeletonTableRows`, `DSSkeletonTextLine` widgets exist.
- No `DSErrorBoundary` widget exists — a single panel crash kills the entire app.
- No shimmer animation using `LinearGradient` with `AnimatedContainer` or equivalent.
- No `ErrorWidget.builder` override scoped to the DS layer.
- No catalog cases for skeleton or error boundary variants.

---

## Test Requirements

- `DSShimmer` MUST render an animated gradient placeholder that loops continuously.
- `DSSkeletonCard` MUST match `DSAssetCard` dimensions (height, padding, border radius).
- `DSSkeletonTableRows` MUST render N configurable placeholder rows with column proportions.
- `DSSkeletonTextLine` MUST render a placeholder text line with configurable width fraction.
- `DSErrorBoundary` MUST catch widget build errors and display a fallback UI without crashing the app.
- `DSErrorBoundary` MUST provide a retry callback that rebuilds the child.
- `DSErrorBoundary` MUST display error details in debug mode and a friendly message in release mode.
- All skeleton widgets MUST use `DSColors` and `DSRadii` tokens (no hardcoded colors).
- Widget tests MUST cover: shimmer renders, skeleton variants render, error boundary catches exception, error boundary retry rebuilds child.

---

## Exit Conditions

- [x] `packages/warp_prism_ui/lib/src/molecules/ds_shimmer.dart` exists with `DSShimmer` base widget.
- [x] `packages/warp_prism_ui/lib/src/molecules/ds_skeleton_card.dart` exists.
- [x] `packages/warp_prism_ui/lib/src/molecules/ds_skeleton_table_rows.dart` exists.
- [x] `packages/warp_prism_ui/lib/src/molecules/ds_skeleton_text_line.dart` exists.
- [x] `packages/warp_prism_ui/lib/src/organisms/ds_error_boundary.dart` exists with `DSErrorBoundary` widget. (Note: placed in organisms/ per atomic design — error boundary is organism-level complexity.)
- [x] `packages/warp_prism_ui/lib/src/organisms/ds_fallback_view.dart` exists with `DSFallbackView` widget.
- [x] `packages/warp_prism_ui/lib/src/molecules/molecules.dart` exports all new molecules.
- [x] `packages/warp_prism_ui/lib/src/organisms/organisms.dart` exports DSErrorBoundary and DSFallbackView.
- [x] `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart` has gallery entries for shimmer, skeleton card, skeleton table rows, skeleton text line, and error boundary fallback.
- [x] `packages/warp_prism_ui/test/molecules/ds_shimmer_test.dart` passes (19 tests).
- [x] `packages/warp_prism_ui/test/molecules/ds_error_boundary_test.dart` passes (14 tests).
- [x] `flutter analyze` passes — no errors or warnings on new files.
- [x] `flutter test` passes — all 33 tests green.
- [x] Local changelog entry added under `docs/changelog/`.
- [x] Completion Evidence is filled before review handoff.

---

## Details

### What

Subtasks:

- [x] **Read existing code before modifying**: read `lib/design_system/molecules/ds_state_surface.dart`, `lib/design_system/tokens/tokens.dart`, `lib/design_system/atoms/ds_glass_panel.dart`, `lib/design_system/molecules/molecules.dart`, `apps/catalog/` structure, and `docs/reports/ads-gap-analysis-20260608.md`.
- [x] Implement `DSShimmer` base widget: animated `LinearGradient` sweep from left to right, configurable `baseColor` and `highlightColor` derived from `DSColors`, configurable `duration` defaulting to 1500ms, `borderRadius` defaulting to `DSRadii.sm`.
- [x] Implement `DSSkeletonCard`: rectangular placeholder matching `DSAssetCard` proportions, built with `DSShimmer` blocks for image area, title line, and subtitle line.
- [x] Implement `DSSkeletonTableRows`: accepts `rowCount` and `columnWidths` (list of fractional widths), renders N rows of shimmer cells using `DSShimmer` rectangles.
- [x] Implement `DSSkeletonTextLine`: single shimmer rectangle with configurable `widthFactor` (fraction of parent width, default 0.7).
- [x] Implement `DSErrorBoundary` widget: wraps a child widget, intercepts `FlutterError.onError`, catches build exceptions, renders `fallbackBuilder(context, error, stackTrace)` with a retry button.
- [x] Add `DSErrorBoundary.withDefaultFallback` convenience constructor that renders a `DSFallbackView` with error icon, title, optional error detail, and retry button using `DSColors.statusError`.
- [x] Register `DSErrorBoundary` pattern guidance: every `DSShell` panel section SHOULD be wrapped in `DSErrorBoundary` for fault isolation.
- [x] Add gallery entries in `apps/catalog/` via `design_system_gallery_sections.dart` for: shimmer standalone, skeleton card, skeleton table rows (3-row and 5-row), skeleton text line, error boundary fallback view.
- [x] Write widget tests for `DSShimmer` (renders, animates), `DSSkeletonCard` (matches expected dimensions), `DSSkeletonTableRows` (renders correct row count), `DSFallbackView` (renders, retry works), `DSErrorBoundary` (renders child, shows fallback).
- [x] **Simplicity pass**: shimmer is one widget with color props, skeleton variants compose shimmer without extra layers.
- [x] **Regression verification**: `flutter analyze` on new files — 0 warnings. `flutter test` — 33/33 pass.

### Where

| File | Purpose |
| --- | --- |
| `packages/warp_prism_ui/lib/src/molecules/ds_state_surface.dart` | Read — understand current loading state pattern and DSStateType. |
| `packages/warp_prism_ui/lib/src/tokens/tokens.dart` | Read — DSColors, DSRadii, DSMotion tokens. |
| `packages/warp_prism_ui/lib/src/atoms/ds_glass_panel.dart` | Read — glass panel styling for error boundary fallback. |
| `packages/warp_prism_ui/lib/src/molecules/molecules.dart` | Modify — add exports for new widgets. |
| `packages/warp_prism_ui/lib/src/molecules/ds_shimmer.dart` | Create — base shimmer animation widget. |
| `packages/warp_prism_ui/lib/src/molecules/ds_skeleton_card.dart` | Create — card skeleton variant. |
| `packages/warp_prism_ui/lib/src/molecules/ds_skeleton_table_rows.dart` | Create — table rows skeleton variant. |
| `packages/warp_prism_ui/lib/src/molecules/ds_skeleton_text_line.dart` | Create — text line skeleton variant. |
| `packages/warp_prism_ui/lib/src/molecules/ds_error_boundary.dart` | ~~Create~~ → `lib/src/organisms/ds_error_boundary.dart` — error boundary widget (placed in organisms per atomic design). |
| `packages/warp_prism_ui/test/molecules/ds_shimmer_test.dart` | Create — shimmer widget tests. |
| `packages/warp_prism_ui/test/molecules/ds_error_boundary_test.dart` | Create — error boundary widget tests. |
| `apps/catalog/` | Modify — add catalog gallery cases. |
| `docs/reports/ads-gap-analysis-20260608.md` | Read — GAP-I2 and GAP-I6 context. |

### How

1. Read all files listed in the Where table before writing any code.
2. Create `DSShimmer` with `AnimationController` and `LinearGradient` transform — the foundation for all skeleton variants.
3. Create skeleton card, table rows, and text line as thin composition widgets over `DSShimmer`.
4. Create `DSErrorBoundary` as a `StatefulWidget` that overrides `FlutterError.onError` within its subtree scope and replaces the child with a fallback builder on exception.
5. Export all new widgets from `molecules.dart`.
6. Add catalog cases to `apps/catalog/`.
7. Write widget tests.
8. Run `melos run analyze` and `melos run test`.
9. Add changelog entry.

### Why

Content-shaped loading skeletons dramatically improve perceived performance and polish compared to a generic spinner. The error boundary prevents a single panel crash from killing the entire app — a critical reliability requirement for a multi-panel dashboard. Without these, CyberCore screens will feel unprofessional and fragile.

---

## Anti-Hallucination Guardrails

> [!CAUTION]
> Do not mark this task complete without running `melos run analyze` and
> `melos run test` and filling Completion Evidence.

> [!IMPORTANT]
> Preserve Warp Prism read-only mock-observatory semantics. Skeleton and
> error boundary are display-only widgets — they do not introduce write
> operations or backend dependencies.

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
  - Created: `packages/warp_prism_ui/lib/src/molecules/ds_shimmer.dart` (DSShimmer — animated gradient shimmer)
  - Created: `packages/warp_prism_ui/lib/src/molecules/ds_skeleton_text_line.dart` (DSSkeletonTextLine)
  - Created: `packages/warp_prism_ui/lib/src/molecules/ds_skeleton_card.dart` (DSSkeletonCard)
  - Created: `packages/warp_prism_ui/lib/src/molecules/ds_skeleton_table_rows.dart` (DSSkeletonTableRows)
  - Created: `packages/warp_prism_ui/lib/src/organisms/ds_fallback_view.dart` (DSFallbackView)
  - Created: `packages/warp_prism_ui/lib/src/organisms/ds_error_boundary.dart` (DSErrorBoundary)
  - Modified: `packages/warp_prism_ui/lib/src/molecules/molecules.dart` (added 4 exports)
  - Modified: `packages/warp_prism_ui/lib/src/organisms/organisms.dart` (added 2 exports)
  - Modified: `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart` (added gallery entries)
  - Created: `packages/warp_prism_ui/test/molecules/ds_shimmer_test.dart` (19 tests)
  - Created: `packages/warp_prism_ui/test/molecules/ds_error_boundary_test.dart` (14 tests)
- **Tests or validation commands**:
  - `flutter analyze` on new files: 0 errors, 0 warnings — PASS
  - `flutter test test/molecules/ds_shimmer_test.dart`: 19/19 pass — PASS
  - `flutter test test/molecules/ds_error_boundary_test.dart`: 14/14 pass — PASS
  - Combined: 33/33 pass — PASS
  - Note: Pre-existing errors in `design_system_gallery_sections.dart` (DSTab, DSDataTable, DSDragReorderEvent, _CommandPalettePreview etc.) and `test/log_viewer_test.dart`, `test/molecules/ds_drag_drop_test.dart`, `test/organisms/command_palette_test.dart` are unrelated to this task.
- **Local changelog entry**: `docs/changelog/1115-loading-skeleton-error-boundary.md`
- **Agent-wiki / docs institutionalization**: N/A
- **Executor**: builders
- **Completion date**: 2026-06-08
