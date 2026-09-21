---
date: 20260718-045520
timestamp: 20260718-045520
project: warp-prism
agent: gt-flutter-engineer
task: "1616"
description: "Optional CyberCore teal ThemeExtension skin (OmniRoute #00FFCC) without Observatory rebrand"
is_rebuild_safe: true
---

# Task 1616: Optional CyberCore Teal ThemeExtension Skin

## Summary

Landed an **opt-in** CyberCore teal `ThemeExtension` (`PrismCyberCoreTealSkin` /
`DSCyberCoreTealSkin`) with OmniRoute core accent `#00FFCC`. Observatory static
defaults (`DSColors.accentCyan` / `PrismColors.accentCyan` = `#00D4FF`) are
**unchanged**. CyberCore pilot app installs the skin via `applyToTheme`.

## Changes

- **Created** `packages/warp_prism_ui/lib/src/tokens/ds_cybercore_teal_skin.dart`
  — ThemeExtension with `coreTeal` / muted / dim, `of`/`maybeOf`, `applyToTheme`,
  and teal glow helper.
- **Modified** `packages/warp_prism_ui/lib/src/tokens/tokens.dart` — export skin.
- **Modified** `packages/warp_prism_ui/lib/src/prism_aliases.dart` — public
  `typedef PrismCyberCoreTealSkin = DSCyberCoreTealSkin` + non-rebrand note on
  `PrismColors`.
- **Created** `packages/warp_prism_ui/test/tokens/ds_cybercore_teal_skin_test.dart`
  — proves cyan default, teal extension, Theme resolution, non-mutation.
- **Modified** `apps/cybercore/lib/main.dart` — opt-in sample wrap.
- **Created** `docs/design/cybercore-teal-theme-extension-skin.md` — usage docs
  (soft inventory assumption from live tokens + OmniRoute harvest).

## Verification

```text
dart analyze lib/src/tokens/ds_cybercore_teal_skin.dart \
  lib/src/tokens/tokens.dart lib/src/tokens/ds_colors.dart \
  lib/src/prism_aliases.dart test/tokens/ds_cybercore_teal_skin_test.dart
→ No issues found

flutter test test/tokens/ds_cybercore_teal_skin_test.dart \
  test/tokens/ds_token_contract_test.dart
→ All tests passed (52)

rg -n "00D4FF|accentCyan" lib/src/tokens/ds_colors.dart
→ accentCyan = Color(0xFF00D4FF) unchanged

dart run packages/warp_prism_ui/test/boundaries/boundary_test.dart --repo-root .
→ 7/7 PASS

dart analyze apps/cybercore/lib/main.dart
→ No issues found
```
