# Warp Prism Design System — Accessibility Baseline

> Task 0018 — Established 2026-06-07

## Purpose

This document defines the minimum accessibility and keyboard-focus baseline
for the Warp Prism design system.  All feature screens built on top of the
DS must inherit these rules — do not retrofit accessibility in page code.

---

## 1. Focus Ring

Every interactive DS component uses a **consistent focus indicator**:

| Property       | Value                                        |
|----------------|----------------------------------------------|
| Border width   | `2px`                                        |
| Border color   | `DSColors.accentCyan.withValues(alpha: 0.5)`       |
| Trigger        | Keyboard focus (Tab / Shift+Tab)             |
| Animation      | `DSMotion.fast` on border width/color change |

Components with this baseline:
- `DSChip` (all interactive variants)
- `DSFilterChipGroup` → `_FilterChip`
- `DSSidebar` → `_SidebarItemWidget`
- `DSTopbarAction`
- `DSSearchBar` (TextField border changes on focus)

---

## 2. Keyboard Activation

All tappable interactive components respond to:

- **Enter** — activates the component
- **Space** — activates the component

This is implemented via `FocusableActionDetector` / keyboard activation callbacks in each
interactive widget.  Tab order follows the widget tree order.

---

## 3. Semantic Labels

| Component           | Semantics Property | Value                          |
|---------------------|--------------------|--------------------------------|
| `DSChip`            | `label`            | Chip label text                |
| `DSChip`            | `button`           | `true` when interactive        |
| `DSChip`            | `selected`         | Current selection state        |
| `DSFilterChipGroup` | `label`            | `"Filter options"`             |
| `_FilterChip`       | `label`            | Option label                   |
| `_FilterChip`       | `button`           | `true`                         |
| `DSSidebar`         | `label`            | `"Navigation sidebar"`         |
| `_SidebarItemWidget`| `label`            | Item label text                |
| `_SidebarItemWidget`| `hint`             | `"Currently selected"` or `"Double-tap to navigate"` |
| `DSTopbar`          | `label`            | `"Top navigation bar"`         |
| `DSTopbarAction`    | `label`            | Tooltip text or `"Action button"` |
| `DSTopbarAction`    | `button`           | `true`                         |
| `_Breadcrumbs`      | `label`            | `"Breadcrumb navigation: ..."` |

---

## 4. Contrast Rules

All text/background pairs must meet WCAG AA minimum:

| Pair                         | Ratio Required | Level  |
|------------------------------|----------------|--------|
| `textPrimary` on `obsidianDeep`  | ≥ 7.0:1      | AAA    |
| `textSecondary` on `obsidianDeep`| ≥ 4.5:1      | AA     |
| `textTertiary` on `obsidianDeep` | ≥ 4.5:1      | AA     |
| `textTertiary` on `obsidianBase` | ≥ 4.5:1      | AA     |
| Status colors on `obsidianDeep`  | ≥ 3.0:1      | AA lg  |

Verified by: `test/design_system/accessibility_focus_contrast_test.dart`

---

## 5. Status Colors

Semantic status colors are distinct and meet WCAG AA large text minimum:

| Token            | Usage                    |
|------------------|--------------------------|
| `statusSuccess`  | Completed, healthy       |
| `statusWarning`  | Attention needed         |
| `statusError`    | Failure, blocked         |
| `statusInfo`     | Neutral information      |

---

## 6. Disabled State

Disabled components:
- Use `DSColors.textDisabled` for text and icons
- Do **not** respond to `onTap` or keyboard activation
- Do **not** receive keyboard focus (when `enabled: false`)

---

## 7. Known Limitations

- **Gallery density**: The Accessibility section uses a tall sidebar demo
  (`height: 800`) for focus walkthroughs; product shells should prefer
  viewport-sized sidebars via `DSShell`.
- **Deprecated Color channels in contrast tests**:
  `test/accessibility_focus_contrast_test.dart` still uses `Color.red/green/blue`
  channel getters (info-level deprecation). Behavior is correct; migrate to
  `Color.r/g/b` when refreshing that suite.
- **Non-interactive molecules**: Surfaces without `onTap` intentionally omit
  button/focus claims via `DSInteractiveSurface` (`onTap == null`).

Resolved since Task 0018 closeout / Task 1307 reconciliation:
- `DSAssetCard` uses `DSInteractiveSurface` (semantics label, focus ring,
  Enter/Space, 48×48 target when interactive).
- `DSSearchBar` clear/filter controls expose `Clear search query` and
  `Open search filters` semantics labels.

---

## 8. Testing

Package-root paths (monorepo package `packages/warp_prism_ui`):

- **Contrast tests**: `test/accessibility_focus_contrast_test.dart`
  — WCAG ratio calculations on all text/background pairs
- **Focus & semantics tests**: `test/accessibility/design_system_accessibility_test.dart`
  — Widget tests verifying Semantics tree, 48×48 hit regions, shell Tab order,
  Shift+Tab reverse order, and Enter/Space activation

Validation commands (from `packages/warp_prism_ui`):

```bash
dart analyze lib/src/molecules/ds_interactive_surface.dart \
  lib/src/molecules/ds_asset_card.dart \
  lib/src/molecules/ds_filter_chip_group.dart \
  lib/src/molecules/ds_search_bar.dart \
  lib/src/atoms/ds_chip.dart \
  lib/src/organisms/ds_sidebar.dart \
  lib/src/organisms/ds_topbar.dart \
  lib/src/organisms/ds_shell.dart \
  lib/src/gallery/design_system_gallery_sections.dart \
  lib/src/gallery/design_system_gallery_registry.dart \
  test/accessibility/design_system_accessibility_test.dart

flutter test test/accessibility/design_system_accessibility_test.dart \
  test/accessibility_focus_contrast_test.dart
```

---

## 9. Gallery Demonstration

The **Accessibility & Focus States** section in the Design System Gallery
(`packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart`,
registered in `design_system_gallery_registry.dart`) provides a live visual proof of:

- Focus ring pattern description
- Focusable chips with keyboard activation
- Filter chip group with selection states
- Sidebar navigation with focusable items
- Topbar action buttons with focus states
- Semantic status colors
- Contrast rules summary
