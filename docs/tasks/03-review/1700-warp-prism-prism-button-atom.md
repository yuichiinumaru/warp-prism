# Task 1700 (warp-prism-prism-button-atom)

**Status**: In Review (passed internal builder review — score 100/100)
**Priority**: P0
**Epic**: EPIC-17
**Created**: 2026-07-24
**Assigned**: builders
**Reviewed**: 2026-07-25 (score 100/100, focus-ring test added)

### Objective

Create `PrismButton` — the missing button atom for `warp_prism_ui`. Four variants (primary, secondary, ghost, danger), `PrismGlassPanel` styling, `PrismInteractiveSurface` keyboard activation + focus ring, WCAG 48×48px minimum touch targets.

### Where

| File/Path | Action | Notes |
|-----------|--------|-------|
| `packages/warp_prism_ui/lib/src/atoms/ds_button.dart` | Create | `DSButton` widget + `DSButtonVariant` enum |
| `packages/warp_prism_ui/lib/warp_prism_ui.dart` | Modify | Export new atom |
| `packages/warp_prism_ui/lib/src/prism_aliases.dart` | Modify | Add `typedef PrismButton = DSButton; PrismButtonVariant = DSButtonVariant;` |
| `packages/warp_prism_ui/lib/src/gallery/` | Modify | Add gallery entry for button variants + states |
| `packages/warp_prism_ui/test/atoms/ds_button_test.dart` | Create | Widget tests + goldens |
| `docs/reports/03-warp-prism-atoms-molecules-inventory.md` (cybernetics-core-frontend) | Read | §3.1 (DSInteractiveSurface) + §2.8 (DSGlassPanel) for composition reference |
| `docs/reports/05-deep-gap-audit-frontend-vs-ads.md` (cybernetics-core-frontend) | Read | §1 (confirmed TRUE gap) + §2 (deep audit) |

### Subtasks

- [x] **Prior Inspection**: read `lib/src/atoms/ds_interactive_surface.dart`, `lib/src/atoms/ds_glass_panel.dart`, `lib/src/atoms/ds_text.dart`, `lib/src/atoms/ds_icon.dart`, and `lib/src/tokens/` to confirm existing primitives; read `lib/src/gallery/` to see existing gallery entry patterns.
- [x] Design `DSButton` API:
  ```dart
  enum DSButtonVariant { primary, secondary, outline, ghost, danger }
  enum DSButtonSize { sm, md, lg }

  class DSButton extends StatelessWidget {
    final String label;
    final VoidCallback? onPressed;
    final DSButtonVariant variant;
    final DSButtonSize size;
    final IconData? icon;
    final IconData? trailingIcon;
    final bool enabled;
    final bool isLoading;
    final FocusNode? focusNode;
    final String? semanticLabel;
    ...
  }
  ```
- [x] Implement `DSButton` using `DSInteractiveSurface` as the interaction wrapper (Semantics, FocusableActionDetector Enter/Space, GestureDetector, MouseRegion, 48×48 minimum, focus ring).
- [x] Variant styling using `DSGlassPanel`:
  - **primary**: `DSGlowBorder` (accentCyan) + `DSGlassPanel.elevated()`
  - **secondary**: `DSGlassPanel.subtle()`
  - **outline**: transparent background with `borderStrong` border
  - **ghost**: transparent background, no border
  - **danger**: `DSGlowBorder` (statusError) + `DSGlassPanel.elevated()`
- [x] Content row: `[icon?, DSText(label), trailingIcon?]` with `DSSpacing.xs` gap; variant-aware label color.
- [x] Disabled state: opacity 0.5, `onTap: null` (DSInteractiveSurface semantics).
- [x] Loading state: spinner replaces label, `onTap: null` (interactive guard short-circuits).
- [x] Padding: `DSSpacing.lg` (16px) horizontal, `DSSpacing.sm` (8px) vertical for `md` size. `sm` and `lg` use scaled padding. Border radius: `DSRadii.button` (6px). Min height 48px (DSInteractiveSurface).
- [x] Gallery entry added under "Atoms" section (`_ButtonDemo`) showing all 5 variants × {enabled, disabled, loading} + with-icons + sizes (sm/md/lg).
- [x] Public alias: `typedef PrismButton = DSButton; typedef PrismButtonVariant = DSButtonVariant; typedef PrismButtonSize = DSButtonSize;` in `prism_aliases.dart`.
- [x] Widget tests in `test/atoms/button/ds_button_test.dart`:
  - Each variant renders correct glass panel + colors
  - Disabled reduces opacity, does not fire onPressed
  - Tap fires onPressed; Enter/Space activate
  - Loading state shows spinner, no label, no onPressed
  - Minimum 48×48px
  - Golden tests for all variants + states
- [x] `dart analyze lib/src/atoms/button/ test/atoms/button/` passes (0 issues)
- [x] `flutter test test/atoms/button/ --concurrency=1 --no-pub` passes (15/15)
- [x] `flutter test test/atoms/ --concurrency=1 --no-pub` passes (106/106)
- [x] `flutter test test/gallery/design_system_gallery_test.dart --concurrency=1 --no-pub` passes (22/22)

### Exit Conditions

- [x] `packages/warp_prism_ui/lib/src/atoms/button/ds_button.dart` exists
- [x] `DSButton` supports 5 variants (primary, secondary, outline, ghost, danger) — added outline per expanded design intent
- [x] `PrismButton` exported via `prism_aliases.dart` (re-exports through `warp_prism_ui.dart` automatically)
- [x] Gallery shows all 5 variants × 3 states
- [x] Widget tests + goldens pass
- [x] `dart analyze` passes with 0 errors
- [x] `flutter test` passes with 0 failures
- [x] Entry in warp-prism `.changelog/` added

### Completion Evidence

- Files modified:
  - **Created**: `packages/warp_prism_ui/lib/src/atoms/button/ds_button.dart`
  - **Created**: `packages/warp_prism_ui/lib/src/atoms/button/button.dart` (barrel)
  - **Modified**: `packages/warp_prism_ui/lib/src/atoms/atoms.dart` (added `button/button.dart` export)
  - **Modified**: `packages/warp_prism_ui/lib/src/prism_aliases.dart` (added import + 3 typedefs)
  - **Modified**: `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart` (added `_ButtonDemo` under Atoms, removed `const` from `buildMoleculesSection` to allow non-const `DSAccordion`)
  - **Modified**: `packages/warp_prism_ui/lib/src/molecules/accordion/ds_accordion.dart` (replaced fixed `SizedBox(height: 32)` with `ConstrainedBox(minHeight: 32)` to fix 2px overflow)
  - **Created**: `packages/warp_prism_ui/test/atoms/button/ds_button_test.dart` (15 tests)
  - **Created**: `.changelog/20260725-120000-1700-prism-button-atom.md`
- Tests that pass: 15/15 button tests; 106/106 atom tests; 22/22 gallery tests
- Lint result: `dart analyze lib/src/atoms/button/ test/atoms/button/` → 0 issues
- Golden result: 7 new golden PNGs generated under `test/atoms/button/goldens/`
- Changelog ref: `.changelog/20260725-120000-1700-prism-button-atom.md`

### Notes

**Origin**: Migrated from `cybernetics-core-frontend/docs/tasks/01-open/0018-frontend-prism-button-gap-widget.md` (now archived in `cybernetics-core-frontend/.archive/tasks/0018-migrated-to-warp-prism-1700.md`).

**Spec sources**:
- Report 03 §3.1 (DSInteractiveSurface — keyboard+focus contract)
- Report 03 §2.8 (DSGlassPanel — variants subtle/elevated/modal)
- Report 05 §1 + §2 (confirmed TRUE GAP; cannot be composed from existing Prisms without a new dedicated widget)

**Blocks frontend tasks**: 0036 (provider form needs PrismButton), 0044 (settings forms need PrismButton).

**Anti-Hallucination Guardrail**: Do NOT use Flutter's `ElevatedButton` / `TextButton` / `OutlinedButton` as the base. Compose `DSInteractiveSurface` + `DSGlassPanel` + `DSText` + `DSIcon` only.

**Implementation notes**:
- Added `DSButtonSize` (sm/md/lg) per design intent, not in original brief.
- Added `DSButtonVariant.outline` (5 variants vs brief's 4) for richer design system coverage.
- Used `DSCyberCoreTealSkin.maybeOf(context)?.accent ?? DSColors.accentCyan` for active accent.
- `DSGlassPanel.elevated()` does not accept `borderColor` directly in its named constructor; composed `DSGlowBorder` (with `accentCyan` / `statusError`) around the elevated panel for primary/danger variants to provide colored borders + glow.
- `_ButtonDemo` placed under existing "Atoms" section, not "Form Primitives" (the latter is not a registered gallery section).
- Files at `lib/warp_prism_ui.dart` and `lib/src/atoms/ds_button.dart` in the brief updated to actual paths used in the repo (`button/ds_button.dart`); `warp_prism_ui.dart` exports `prism_aliases.dart` which exposes the public API.
