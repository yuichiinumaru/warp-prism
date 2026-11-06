# Nerazim Teal ThemeExtension Skin (Optional)

> **Status**: Live (opt-in)  
> **Task**: 1616 (created) · 1839 (brand normalization)  
> **Date**: 2026-07-18 (created) · 2026-09-27 (renamed)  
> **Authority**: EPIC-16 optional wave + OmniRoute harvest (`docs/reports/ads-harvest-omniroute-visual-reference-2026-07-10.md`)

> **Task 1839**: this document was renamed from its previous filename and the
> brand vocabulary normalized to **Nerazim Teal**. Only identifiers, labels, and
> prose changed — no hex value, no theme behavior, and no visual change.
> Historical references elsewhere that still cite the old filename or old
> identifiers are prior-work record and are intentionally not rewritten; the
> pre-rename filename is recorded in the archived copy of this document rather
> than reproduced here, so that live documentation carries no stale brand token.

## Purpose

Provide a **mono-teal opt-in** accent skin (OmniRoute `#00FFCC`) under the
canonical **Nerazim Teal** brand name, without rebranding Observatory defaults
(`PrismColors.accentCyan` / `DSColors.accentCyan` = `#00D4FF` sky cyan
multi-accent stack).

This is **not** a second design system. It is a small `ThemeExtension` for product
apps that want OmniRoute DNA.

## Soft inventory assumption (Task 1600)

Task 1600 froze organism inventory and an explicit skip of Observatory teal
rebrand; it did **not** publish a full second skin palette. Live tokens and
harvest remain the source of truth:

| Role | Source | Hex |
| --- | --- | --- |
| Observatory primary energy (default) | `DSColors.accentCyan` | `#00D4FF` |
| OmniRoute / Nerazim Teal core teal | harvest `coreCyan` / skin `coreTeal` | `#00FFCC` |
| Skin muted / dim | structured ladder (cyan pattern, teal-shifted) | `#00B894` / `#007A66` |

## Public API

| Surface | Name |
| --- | --- |
| Internal | `DSNerazimTealSkin` (`packages/warp_prism_ui/lib/src/tokens/ds_nerazim_teal_skin.dart`) |
| Public alias | `PrismNerazimTealSkin` via `package:warp_prism_ui/warp_prism_ui.dart` |
| Factory | `const PrismNerazimTealSkin.nerazimTeal()` |
| Install helper | `skin.applyToTheme(ThemeData base, {remapColorScheme})` |
| Resolve | `PrismNerazimTealSkin.of(context)` / `maybeOf(context)` |

## Opt-in

```dart
import 'package:flutter/material.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

class MonoTealApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = const PrismNerazimTealSkin.nerazimTeal().applyToTheme(
      ThemeData.dark().copyWith(
        scaffoldBackgroundColor: PrismColors.obsidianDeep,
        colorScheme: const ColorScheme.dark(
          primary: PrismColors.accentCyan, // remapped to teal by applyToTheme
          surface: PrismColors.obsidianBase,
        ),
      ),
    );

    return MaterialApp(
      theme: theme,
      home: const Placeholder(),
    );
  }
}

// In a widget tree under that theme:
// final teal = PrismNerazimTealSkin.of(context).accent; // #00FFCC
```

Sample consumer: `apps/cybercore/lib/main.dart`.

## Observatory (must not require the skin)

```dart
// Default path — no ThemeExtension.
theme: ThemeData.dark().copyWith(
  scaffoldBackgroundColor: PrismColors.obsidianDeep,
  colorScheme: const ColorScheme.dark(
    primary: PrismColors.accentCyan, // #00D4FF
  ),
);

// Static tokens always remain sky cyan regardless of any consumer skin:
// PrismColors.accentCyan == Color(0xFF00D4FF)
```

Observatory widgets that read `PrismColors.accentCyan` continue to use sky cyan.
Only widgets that **explicitly** read `PrismNerazimTealSkin` (or Material
`ColorScheme.primary` after the skin's `applyToTheme`) see teal.

## Non-goals

- Do **not** change global `DSColors.accentCyan` to `#00FFCC`.
- Do **not** force Orbitron / Rajdhani / scanlines.
- Do **not** require the extension for ADS goldens or Observatory routes.
- Do **not** treat this as a full `PrismThemeColors` migration (still future per
  `docs/design/token-theme-catalog-policy.md` §3).

## Related

- Policy: `docs/design/token-theme-catalog-policy.md` §3 ThemeExtension ownership
- Harvest: `docs/reports/ads-harvest-omniroute-visual-reference-2026-07-10.md`
- Tokens: `packages/warp_prism_ui/lib/src/tokens/ds_colors.dart`
- Tests: `packages/warp_prism_ui/test/tokens/ds_nerazim_teal_skin_test.dart`
