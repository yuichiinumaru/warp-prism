# Task 1616: Optional CyberCore Teal ThemeExtension Skin

> **Status**: `[x]` Formal review ACCEPTED_100 — lane `03-review`
> **Review State**: `ACCEPTED_100`
> **Priority**: ⚪ P3
> **Type**: `ux-polish`
> **Origin**: EPIC-16 (`docs/tasks/00-planning/EPIC-16-warp-prism-ads-cybercore-ops-and-agent-transcript-organisms.md`) + harvest reports `docs/reports/ads-harvest-session-synthesis-2026-07-10.md`, `docs/reports/ads-harvest-omniroute-visual-reference-2026-07-10.md`, `docs/reports/ads-harvest-references-catalog-triage-2026-07-10.md`, `docs/reports/ads-harvest-atomic-ds-references-2026-07-10.md`
> **Blocks**: N/A
> **Depends on**: Task 1600 (soft)
>
> **OPTIONAL**: Does **not** block Tasks 1613–1615. Explicitly **not** Observatory default
> rebrand. OmniRoute `#00FFCC` teal is CyberCore-only skin candidate.

> [!IMPORTANT]
> Task identity is lane-neutral. Use `Task 1616` plus optional slug for
> dependencies, blockers, review ledgers, reports, and architecture references.
> Lanes such as `02-doing` and `03-review` are mutable status, not identity.

---

## Objective

Optionally introduce a **CyberCore-only teal ThemeExtension skin** (accent around OmniRoute `#00FFCC`) that product apps can opt into **without** changing Observatory default tokens (`DSColors.accentCyan` / `PrismColors` remain sky-cyan multi-accent stack). Document usage; provide minimal gallery or CyberCore app sample if low cost.

## Background Context

### Source origin (EPIC-16)

| Field | Value |
| --- | --- |
| **Wave** | **optional** |
| **Origin** | OmniRoute visual-ref palette + session synthesis “optional later CyberCore teal skin” |
| **Action type** | `OPTIONAL` ThemeExtension |

### What already exists

- WP tokens: `packages/warp_prism_ui/lib/src/tokens/ds_colors.dart` with multi-accent cyan/violet/gold.
- Harvest verdict: **no mandatory retoken** of Observatory.
- Ahmedm harvest notes ThemeExtension families as pattern (not a port mandate).

### What is missing or broken

- No opt-in CyberCore teal skin extension for product monism without global rebrand.
- Risk of builders hardcoding `#00FFCC` into shared Observatory widgets.

### False-gap notes

- Do **not** change global `accentCyan` default to teal.
- Do **not** force Orbitron/Rajdhani/scanlines.
- Do **not** block EPIC acceptance on this task.

---

## Test Requirements

- MUST keep default Observatory/theme path visually using existing WP cyan (prove via test or explicit non-mutation of `DSColors.accentCyan` hex).
- MUST provide a named ThemeExtension (or equivalent scoped skin API) with teal core accent for CyberCore opt-in.
- Widget or unit test: extension resolves teal; default theme without extension remains unchanged.
- Docs: how CyberCore app wraps `Theme` with extension; Observatory must not require it.
- MUST NOT add Widgetbook, MapLibre, Recharts.

---

## Exit Conditions

- [x] ThemeExtension (or documented skin API) landed **or** task explicitly cancelled/deferred with written reason (optional OK).
- [x] Default `DSColors.accentCyan` / Observatory tokens **unchanged** as global default.
- [x] Tests or proof of non-rebrand PASS.
- [x] Minimal docs note under `docs/design/` or `docs/reports/`.
- [x] If barrel exports skin, boundaries **6/6 PASS**.
- [x] Local changelog under `docs/changelog/` if code/docs landed.
- [x] Completion Evidence filled (including “deferred” path if chosen).

---

## Details

### What

Subtasks:

- [x] **Read existing code before modifying**: read EPIC-16 optional task note, harvest OmniRoute color diff section, session synthesis optional skin note, `packages/warp_prism_ui/lib/src/tokens/ds_colors.dart`, `packages/warp_prism_ui/lib/src/tokens/ds_shadows.dart` if glow helpers exist, `packages/warp_prism_ui/lib/src/prism_aliases.dart`, `apps/cybercore/` theme entry if present, `docs/design/token-theme-catalog-policy.md`, Task 1600 brief if present.
- [x] Decide API: `ThemeExtension` in UI package vs CyberCore-app-local extension (prefer UI package only if reusable and clearly opt-in).
- [x] Implement extension + docs; **do not** flip global defaults.
- [x] Add test proving defaults unchanged + extension values.
- [x] Optional: gallery toggle or CyberCore sample wrap.
- [x] **Simplicity pass**: small extension object; no full second design system.
- [x] **Regression verification**: analyze + tests + boundaries if package exports change.

### Where

| File | Purpose |
| --- | --- |
| `packages/warp_prism_ui/lib/src/tokens/ds_colors.dart` | Read — do not rebrand defaults |
| `packages/warp_prism_ui/lib/src/tokens/` | Create optional extension file |
| `packages/warp_prism_ui/lib/src/prism_aliases.dart` | Optional export alias |
| `apps/cybercore/` | Optional consumer sample |
| `docs/design/` or `docs/reports/` | Create — skin usage note |
| `packages/warp_prism_ui/test/tokens/` | Create/Modify — tests |
| `docs/changelog/` | Create — changelog if landed |

### How

1. Add extension with `coreTeal = Color(0xFF00FFCC)` (or documented equivalent).
2. Document opt-in only for CyberCore.
3. Prove Observatory defaults untouched.
4. Export carefully; run boundaries.

### Why

OmniRoute DNA wants mono-teal CyberCore identity; Observatory constitution wants multi-accent glass. ThemeExtension skin separates products without EPIC-wide rebrand risk.

---

## Anti-Hallucination Guardrails

> [!CAUTION]
> Never change Observatory default accent to teal in this task.

> [!IMPORTANT]
> Optional: deferral with reason is a valid completion path.

> [!WARNING]
> Do not block 1613–1615 on this task. No scanlines/Orbitron mandate.

---

## Validation Commands

```bash
cd packages/warp_prism_ui
dart analyze lib test
# Token / extension tests if added:
flutter test test/tokens/
# Prove default cyan not rewritten (adjust if constant name differs):
rg -n "00D4FF|accentCyan" lib/src/tokens/ds_colors.dart

cd ../..
# Only if package public surface changed:
melos run test-boundaries
```

If Flutter tooling is unavailable, record the exact tooling failure and do not
claim those checks passed. Deferral path needs only written reason + changelog note optional.

---

## Completion Evidence

- **Files created/modified**:
  - **Created** `packages/warp_prism_ui/lib/src/tokens/ds_cybercore_teal_skin.dart`
  - **Modified** `packages/warp_prism_ui/lib/src/tokens/tokens.dart` (export)
  - **Modified** `packages/warp_prism_ui/lib/src/prism_aliases.dart` (`PrismCyberCoreTealSkin` + PrismColors non-rebrand note)
  - **Created** `packages/warp_prism_ui/test/tokens/ds_cybercore_teal_skin_test.dart`
  - **Modified** `apps/cybercore/lib/main.dart` (opt-in sample)
  - **Created** `docs/design/cybercore-teal-theme-extension-skin.md`
  - **Created** `docs/changelog/20260718-045520-1616-optional-cybercore-teal-theme-extension-skin-gt-flutter-engineer.md`
  - **Not modified** `packages/warp_prism_ui/lib/src/tokens/ds_colors.dart` (read-only; cyan defaults preserved)
- **Default rebrand avoided**:
  - `DSColors.accentCyan = Color(0xFF00D4FF)` still present (`rg` proof).
  - Tests assert accentCyan ≠ `#00FFCC` and remains `#00D4FF` after `applyToTheme`.
  - Skin is ThemeExtension-only; static token classes never rewritten.
- **Soft inventory assumption (Task 1600)**: Task 1600 locked organism inventory + skip of Observatory teal rebrand; full second skin palette not frozen. Live tokens + OmniRoute harvest (`coreCyan`/`coreTeal` = `#00FFCC`) used for muted/dim ladder structure.
- **API decision**: Reusable opt-in ThemeExtension in UI package (`DSCyberCoreTealSkin` / `PrismCyberCoreTealSkin`) — not a full `PrismThemeColors` migration; CyberCore sample wraps via `applyToTheme`.
- **Tests or validation commands**:
  - `dart analyze` (task-owned: tokens + prism_aliases + cybercore main): **No issues found** PASS
  - `flutter test test/tokens/ds_cybercore_teal_skin_test.dart test/tokens/ds_token_contract_test.dart`: **52 passed** PASS
  - `rg -n "00D4FF|accentCyan" lib/src/tokens/ds_colors.dart`: cyan `#00D4FF` unchanged PASS
  - Note: full-package `dart analyze lib test` may surface concurrent non-1616 organism debt elsewhere; scoped surfaces for this task are clean.
- **Boundary harness**: **7/7 PASS** (harness currently has 7 checks; task text said 6/6 — live harness is 7)
  - Command: `dart run packages/warp_prism_ui/test/boundaries/boundary_test.dart --repo-root .`
- **Local changelog entry**: `docs/changelog/20260718-045520-1616-optional-cybercore-teal-theme-extension-skin-gt-flutter-engineer.md`
- **Agent-wiki / docs institutionalization**: `docs/design/cybercore-teal-theme-extension-skin.md` (usage note; no agent-wiki write required for this optional polish task)
- **Executor**: gt-flutter-engineer (under parent builder-orchestrator)
- **Completion date**: 2026-07-18
- **Lane**: left in `02-doing` per builder compact (no promote / no parent closeout)
- **Pack re-verify (2026-07-18T05:28Z)**:
  - `flutter test test/tokens/ds_cybercore_teal_skin_test.dart --concurrency=1 --no-pub` → **13/13 PASS**
  - `rg -n "00D4FF|accentCyan" lib/src/tokens/ds_colors.dart` → `accentCyan = Color(0xFF00D4FF)` unchanged
  - Boundary harness → **7/7 PASS**
  - Default Observatory accent **not** rebranded to `#00FFCC`

### Changelog Draft

```yaml
task: "1616"
agent: gt-flutter-engineer
project: warp-prism
title: "Optional CyberCore teal ThemeExtension skin"
description: "Opt-in PrismCyberCoreTealSkin (#00FFCC) without changing Observatory DSColors.accentCyan (#00D4FF)"
summary: >
  ThemeExtension skin + Prism alias + CyberCore main sample + design usage note +
  non-rebrand tests. Boundaries 7/7.
verification: >
  dart analyze (scoped tokens/aliases/cybercore main) clean;
  flutter test token skin + contract 52 pass;
  rg accentCyan #00D4FF unchanged;
  boundary harness 7/7 PASS
```

### Entrypoint Chain Proof

- **Claim**: helper/library-only ThemeExtension + optional CyberCore theme wiring
- **Classification**: `helper/library-only` for ADS skin; `runtime-behavior` sample only in `apps/cybercore/lib/main.dart` theme construction
- **Entrypoint (sample)**: `apps/cybercore/lib/main.dart` → `WarpPrismCyberCoreApp.build` → `PrismCyberCoreTealSkin.omniRoute().applyToTheme(...)`
- **Helper**: `DSCyberCoreTealSkin` in `ds_cybercore_teal_skin.dart`
- **Regression test**: `test/tokens/ds_cybercore_teal_skin_test.dart` fails if cyan default rewritten or skin omits `#00FFCC`

---

## Review Ledger

> [!IMPORTANT]
> Before path-to-100 work, read the latest full report and all reports listed
> under Previous Reports. Persistent findings and regression guards are part of
> the acceptance contract; do not fix the latest finding by undoing a previously
> accepted repair.

### Latest Review

- **Date**: 2026-07-18
- **Reviewer profile**: `builders` (gt-flutter-code-reviewer formal parallel)
- **Score**: `100/100`
- **Verdict**: `ACCEPTED_100`
- **Full report**: `docs/reports/review/formal-2026-07-18-task-1616.md`
- **Lane outcome**: moved to `03-review`
- **Task reference**: Task 1616 (`1616-warp-prism-optional-cybercore-teal-theme-extension-skin`)

#### Current Open Blockers

- None.

#### Path-to-100 Summary

- Already at 100 (formal independent re-proof of expert path-to-100).
- Live: **14/14** public-barrel tests; accentCyan `#00D4FF` unchanged; boundary **7/7**.

#### Regression Guards

- **Never** change `DSColors.accentCyan` / `PrismColors.accentCyan` to `#00FFCC`.
- Teal is opt-in ThemeExtension only (`PrismCyberCoreTealSkin.omniRoute().applyToTheme`).
- Observatory must not require the extension.
- Keep of() fail-closed + non-rebrand asserts on public barrel.

### Previous Reports

- `docs/reports/review/expert-2026-07-18-task-1616.md` — expert path-to-100 100/100 (before 93)
