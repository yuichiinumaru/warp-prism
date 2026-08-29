# Task 1804: Hardcoded Visual-Value and Structural-Color Audit Report

> **Status**: Complete Baseline Audit, Remediation & Lineage Reconciliation
> **Date**: 2026-08-24 (Reconciled)
> **Executor**: `gt-builders-engineer-flutter`
> **Authority Contract**: `docs/design/black-obsidian-visual-contract.md`
> **Governing Task**: Task 1804 (`docs/tasks/02-doing/1804-warp-prism-hardcoded-visual-value-audit.md`)

---

## Executive Summary

Pursuant to the Black Obsidian Visual Contract (`docs/design/black-obsidian-visual-contract.md`), this audit establishes a verified workspace-wide baseline inventory of raw component-level colors. All candidate structural violations were remediated to approved tokens (`DSColors`), leaving behind a clean baseline and a repeatable high-signal audit command to detect future visual value drift during code review. The baseline inventory below has been reconciled to reflect the live 18 non-token matches across the codebase (including Theme Editor presets and hex parser logic).

---

## 1. High-Signal Repeatable Audit Command

### Command Specification

```bash
rg -n "Color\.(fromARGB|fromRGBO)|Color\(0x|HSLColor" \
  --glob '!**/tokens/**' \
  packages/warp_prism_ui/lib apps/catalog/lib apps/observatory/lib apps/cybercore/lib
```

### Exemption Rules & Classification Buckets

- **Tokens Directory (`packages/warp_prism_ui/lib/src/tokens/`)**: Source of truth for design token definitions (`DSColors`, `DSShadows`, `DSCyberCoreTealSkin`). Exempt by role (Bucket 1).
- **Bucket 2 (Alpha-composite / elevation scrims / Parser logic)**:
  - `Color(0x40000000)` in `ds_keyboard_cheatsheet.dart` line 479 (25% opacity elevation black shadow scrim).
  - `Color.fromARGB` & `Color(0xFF000000 | val)` in `hex_color_parser.dart` lines 24 & 27 (Exempt hex color parser implementation logic).
- **Bucket 4 (Fixture / Data / Theme Editor Presets)**:
  - 15 raw `Color(...)` literals in `prism_theme_editor.dart` lines 311–371 (15 Blue, Teal, Amber preset color swatches for runtime theme customization).

---

## 2. Classified Inventory Baseline (Reconciled Live 18 Matches)

| Index | File Path | Line | Raw Value / Construct | Classification Bucket | Verdict / Action Taken |
|---|---|---|---|---|---|
| 1 | `packages/warp_prism_ui/lib/src/organisms/keyboard_cheatsheet/ds_keyboard_cheatsheet.dart` | 479 | `Color(0x40000000)` | Bucket 2 (Alpha-composite Scrim) | Retained — Legitimate keyboard key elevation shadow scrim |
| 2 | `packages/warp_prism_ui/lib/src/molecules/color_field/hex_color_parser.dart` | 24 | `Color.fromARGB(255, r, g, b)` | Bucket 2 (Hex Parser Logic) | Retained — Legitimate hex parser conversion method |
| 3 | `packages/warp_prism_ui/lib/src/molecules/color_field/hex_color_parser.dart` | 27 | `Color(0xFF000000 \| val)` | Bucket 2 (Hex Parser Logic) | Retained — Legitimate hex parser bitwise conversion |
| 4–8 | `packages/warp_prism_ui/lib/src/organisms/theme_editor/prism_theme_editor.dart` | 311–327 | `Color(0xFF2F81FF)` et al. (5 values) | Bucket 4 (Theme Editor Data Presets) | Retained — Legitimate Blue theme preset color swatches |
| 9–13 | `packages/warp_prism_ui/lib/src/organisms/theme_editor/prism_theme_editor.dart` | 333–349 | `Color(0xFF00FFCC)` et al. (5 values) | Bucket 4 (Theme Editor Data Presets) | Retained — Legitimate Teal theme preset color swatches |
| 14–18 | `packages/warp_prism_ui/lib/src/organisms/theme_editor/prism_theme_editor.dart` | 355–371 | `Color(0xFFFFB800)` et al. (5 values) | Bucket 4 (Theme Editor Data Presets) | Retained — Legitimate Amber theme preset color swatches |
| — | `packages/warp_prism_ui/lib/src/organisms/media_detail_overlay/ds_media_detail_overlay.dart` | 99, 107, 115, 127 | 4 raw `Color(0x...)` literals | Bucket 5 (Structural Violation) | **Remediated** → Migrated to `DSColors.obsidianActive`, `DSColors.glassOverlay`, `DSColors.obsidianHover` |

---

## 3. Remediation Details

### Media Detail Overlay Placeholder Tints Migration

- **Before**: 4 raw `Color(0x...)` literals (`0xFF1A2A32`, `0xFF1E2430`, `0xFF242018`, `0xFF1A2430`) in `DSMediaDetailFixtures`.
- **After**: Migrated to token-derived obsidian surface spectrum constants (`DSColors.obsidianActive`, `DSColors.glassOverlay`, `DSColors.obsidianHover`).
- **Result**: Zero structural raw `Color(0x...)` remaining in `packages/warp_prism_ui/lib/src/organisms/`.

---

## 4. Expected Drift Detection & Review Baseline

Running the audit command across non-token paths yields **EXACTLY 18 findings**:

- 1 keyboard elevation scrim (`ds_keyboard_cheatsheet.dart`)
- 2 hex parser implementation methods (`hex_color_parser.dart`)
- 15 theme editor preset color swatches (`prism_theme_editor.dart`)

Any review diff that increases this count above **18** (outside `tokens/`) or introduces new raw `fromARGB/fromRGBO/HSLColor/Color(0x)` structural constructs indicates an unapproved visual value regression and MUST fail code review.

---

## 5. Verification Evidence

1. **Audit Command**:
   `rg -n "Color\.(fromARGB|fromRGBO)|Color\(0x|HSLColor" --glob '!**/tokens/**' packages/warp_prism_ui/lib apps/catalog/lib apps/observatory/lib apps/cybercore/lib`
   - Output: 18 legitimate classified findings (1 scrim, 2 parser methods, 15 theme editor swatches).
2. **Analyzer Gate**:
   `cd packages/warp_prism_ui && flutter analyze --no-fatal-infos`
   - Output: 0 errors, infos tracked per policy.
3. **Component Suite Tests**:
   `cd packages/warp_prism_ui && flutter test test/organisms/media_detail_overlay/media_detail_overlay_test.dart test/organisms/theme_editor/`
   - Output: 100% PASS.
4. **Boundary Harness**:
   `cd packages/warp_prism_ui && dart test/boundaries/boundary_test.dart`
   - Output: 7/7 PASS (0 violations).
