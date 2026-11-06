---
date: 20260928-133500
timestamp: 20260928-133500
project: warp-prism
agent: gt-builders-engineer-flutter
task: "1839"
description: "Theme brand normalization: CyberCore Teal -> Nerazim Teal, Protoss Gold -> Purifier Gold (identifiers + labels only)"
is_rebuild_safe: true
---

# Task 1839: Theme Brand Normalization (Nerazim Teal / Purifier Gold)

## Summary

Normalized the teal skin brand and gold preset label to the canonical vocabulary
mandated by `AGENTS.md` §7.0. **Identifiers, labels, comments, and docs only** —
no hex value, no theme behavior, no visual change. The `AGENTS.md` §7.0
temporary section is now removable by governance once the residual out-of-scope
sites (listed below) are cleared and independent review passes.

## Changes

### Renamed files (originals archived to `.archive/`, reversible)

| Old | New |
| --- | --- |
| `packages/warp_prism_ui/lib/src/tokens/ds_cybercore_teal_skin.dart` | `.../ds_nerazim_teal_skin.dart` |
| `packages/warp_prism_ui/test/tokens/ds_cybercore_teal_skin_test.dart` | `.../ds_nerazim_teal_skin_test.dart` |
| `docs/design/cybercore-teal-theme-extension-skin.md` | `docs/design/nerazim-teal-theme-extension-skin.md` |

### Renamed identifiers

- `DSCyberCoreTealSkin` → `DSNerazimTealSkin`
- `PrismCyberCoreTealSkin` → `PrismNerazimTealSkin`
- factory `.omniRoute()` → `.nerazimTeal()`
  (recorded per task: the `omniRoute` anchor was itself a stale product anchor;
  every call site changes anyway, so it was renamed once.)
- catalog enum `CatalogThemeVariant.cybercoreTeal` → `.nerazimTeal`
- test probe key `'cybercore-teal-accent-probe'` → `'nerazim-teal-accent-probe'`

### Renamed labels / comments / docs

- `'CyberCore Teal (#00FFCC)'` → `'Nerazim Teal (#00FFCC)'` (catalog dropdown)
- `'CyberCore Teal'` → `'Nerazim Teal'` (theme editor preset chip)
- `'Protoss Gold'` → `'Purifier Gold'` (theme editor preset chip)
- `Nerazim Green/Teal` → `Nerazim Teal` (4 docstring sites:
  `prism_aliases.dart` ×2, `ds_taldarim_red_skin.dart`, `ds_talon_purple_skin.dart`)
- barrel export + import paths in `tokens.dart` and `prism_aliases.dart`
- `docs/design/public-barrel-audit.md` alias row
- `docs/design/black-obsidian-visual-contract.md` — 3 live brand-label mentions
  updated; the 2 historical-quote rows in the Supersession Map were deliberately
  left verbatim and annotated with a Task 1839 note (rewriting a verbatim quote
  of a superseded task artifact would falsify the record)

### Explicitly NOT changed (verified)

- **No hex value changed.** Teal `#00FFCC` / `#00B894` / `#007A66` proven
  byte-identical against the archived original. Talon Purple
  (`#9911E5`/`#770CB3`/`#4F0878`), Taldarim Red
  (`#E51A4C`/`#B8103A`/`#7A0A26`), and Khalai Blue (`#2F81FF`) untouched.
- `AGENTS.md`, `MISSION.md`, `README.md`, `pubspec.yaml` — not touched.
- `.archive/`, `.project/tasks/04-completed/`, `.project/tasks/03-review/` —
  not rewritten (0 files modified).
- No golden refresh (Task 1800 freeze respected).

## Verification

| Check | Result |
| --- | --- |
| `dart format --set-exit-if-changed` (my 5 authored/edited files) | **PASS** exit 0 |
| `dart format --set-exit-if-changed lib/ test/` (package-wide) | exit 1 — **pre-existing** baseline drift, 57 files dirty incl. files this task never touched |
| `dart analyze` (warp_prism_ui) | exit 3 — 10 errors, **all in 3 out-of-scope test files**; 0 errors in in-scope files; remaining 212 are pre-existing `info` lints |
| `flutter test test/tokens/ds_nerazim_teal_skin_test.dart` | **PASS** 15/15, exit 0 |
| canonical sibling skin tests (taldarim/talon) | **PASS**, exit 0 |
| `boundary_test.dart --repo-root .` | **PASS** 15/15, exit 0 |
| `apps/cybercore` `flutter analyze` | **PASS** exit 0 |
| `flutter test --no-pub` (warp_prism_ui, full) | exit 1 — 70 failures: 3 compile breaks from out-of-scope files + golden drift documented as expected under the Task 1800/1805 freeze |
| `apps/catalog` `flutter analyze` / `flutter test` | exit 1 / exit 1 — 2 errors, both in out-of-scope `test/host_exercise/catalog_host.dart` |
| `apps/cybercore` `flutter test` | exit 1 — 4 failures, **pre-existing** `PathNotFoundException` in the Task 1838 host-exercise harness; 0 references to any renamed symbol |
| Zero-hit sweep over in-scope live paths | **0 stale hits** |

### Out-of-`Where`-table stale-brand sites (reported, NOT edited — scope discipline)

These break compilation and must be cleared by an authorized follow-up:

- `packages/warp_prism_ui/lib/src/tokens/prism_token_registry.dart` (1 — docstring)
- `packages/warp_prism_ui/test/atoms/switch/ds_switch_test.dart` (1)
- `packages/warp_prism_ui/test/organisms/theme_editor/prism_theme_editor_test.dart` (2 — asserts `find.text('CyberCore Teal')`)
- `packages/warp_prism_ui/test/theme/prism_theme_test.dart` (3)
- `packages/warp_prism_ui/test/theme/theme_role_accent_propagation_test.dart` (11)
- `packages/warp_prism_host_exercise/lib/src/models/theme_matrix.dart` (2)
- `apps/catalog/test/host_exercise/catalog_host.dart` (2)
- `docs/governance/catalog-showability-2026-07-10.md` (1)

**Not edited, by design:** `AGENTS.md` §7.0 (the law must name the variants it
forbids; removed by governance after review), `.project/tasks/01-open/1839-*`
(the task itself), `.project/tasks/03-review/1806-*` (out of bounds),
`docs/design/black-obsidian-visual-contract.md` lines 180–181 (annotated
historical quotes).
