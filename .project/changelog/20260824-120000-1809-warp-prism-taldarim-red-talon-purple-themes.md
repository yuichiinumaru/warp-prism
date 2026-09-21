---
date: 20260824-120000
timestamp: 20260824-120000
project: "warp-prism"
agent: "builder-engineer"
task: "1809"
description: "Added opt-in Taldarim Red and Talon Purple accent themes via ThemeExtension skins and static DSTheme factories. Reuses Black Obsidian background mapping (#030506 family)."
is_rebuild_safe: true
---

# Task 1809: Warp Prism Taldarim Red and Talon Purple Accent Themes

## Summary

Added two new opt-in accent themes — **Taldarim Red** (`#E51A4C` crimson energy ladder) and **Talon Purple** (`#9911E5` violet/crimson-purple energy ladder) — as `ThemeExtension` skins (`DSTaldarimRedSkin`, `DSTalonPurpleSkin`) and static factories (`DSTheme.taldarimRed()`, `DSTheme.talonPurple()`, aliased publicly as `PrismTheme.taldarimRed()` and `PrismTheme.talonPurple()`).

Both themes strictly honor Rule Zero: backgrounds stay in the `#030506` black obsidian family, static `DSColors` defaults remain unmodified (Khalai Blue default action accent `#2F81FF`), and existing Protoss brand labels (Khalai Blue, Nerazim Green/Teal, Purifier Gold) are documented alongside the new brand labels.

## Changes

- Created `packages/warp_prism_ui/lib/src/tokens/ds_taldarim_red_skin.dart` with `DSTaldarimRedSkin` ThemeExtension.
- Created `packages/warp_prism_ui/lib/src/tokens/ds_talon_purple_skin.dart` with `DSTalonPurpleSkin` ThemeExtension.
- Added `DSTheme.taldarimRed()` and `DSTheme.talonPurple()` static factories in `packages/warp_prism_ui/lib/src/theme/ds_theme.dart`.
- Re-exported `DSTaldarimRedSkin` and `DSTalonPurpleSkin` in `packages/warp_prism_ui/lib/src/tokens/tokens.dart`.
- Exported public aliases `PrismTaldarimRedSkin` and `PrismTalonPurpleSkin` in `packages/warp_prism_ui/lib/src/prism_aliases.dart`.
- Updated `docs/design/public-barrel-audit.md` symbol inventory lock from 294 to 296 Prism symbols.
- Added unit tests in `packages/warp_prism_ui/test/tokens/ds_taldarim_red_skin_test.dart` and `ds_talon_purple_skin_test.dart`.
- Added factory & Rule Zero regression tests in `packages/warp_prism_ui/test/theme/prism_theme_test.dart`.
- Updated `apps/catalog/lib/main.dart` with `CatalogThemeVariant` enum for live preview of all 4 accent themes (Khalai Blue, Taldarim Red, Talon Purple, CyberCore Teal).

## Verification

- `cd packages/warp_prism_ui && flutter analyze --no-fatal-infos` (PASS: 0 errors)
- `cd packages/warp_prism_ui && flutter test test/theme test/tokens` (PASS: 172/172 tests green)
- `cd packages/warp_prism_ui && flutter test test/boundaries` (PASS: 7/7 boundary harness green)
- `cd apps/catalog && flutter analyze` (PASS: 0 issues)
- `dart run tool/verify_public_barrel_audit.dart` (PASS: 296/296 symbols locked)
- Golden freeze intact: existing goldens untouched, zero new PNG goldens created.
