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
| Border color   | `DSColors.accentCyan.withOpacity(0.5)`       |
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

This is implemented via `Focus.onKeyEvent` + `KeyDownEvent` checks in each
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

- **Asset cards**: `DSAssetCard` does not yet have explicit `Semantics` wrapping
  or `Focus`/`onKeyEvent`.  It relies on `GestureDetector` only.  This is an
  acceptable gap for v0.1.0 since cards are demonstrated read-only in the gallery
  but will need focus support when interactive in product screens.
- **Search bar icons**: The clear and filter `_IconButton` sub-widgets use
  `InkWell` which provides Material ripple but not explicit `Semantics`.  When
  product screens add real search, these should get `Semantics(label:)` and
  `Tooltip`.

---

## 8. Testing

- **Contrast tests**: `test/design_system/accessibility_focus_contrast_test.dart`
  — WCAG ratio calculations on all text/background pairs
- **Focus & semantics tests**: `test/design_system/accessibility/design_system_accessibility_test.dart`
  — Widget tests verifying Semantics tree and keyboard baseline

---

## 9. Gallery Demonstration

The **Accessibility & Focus States** section in the Design System Gallery
(`lib/design_system/gallery/design_system_gallery_sections.dart`) provides
a live visual proof of:

- Focus ring pattern description
- Focusable chips with keyboard activation
- Filter chip group with selection states
- Sidebar navigation with focusable items
- Topbar action buttons with focus states
- Semantic status colors
- Contrast rules summary
