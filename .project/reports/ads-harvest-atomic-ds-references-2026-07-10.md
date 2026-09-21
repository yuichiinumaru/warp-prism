# External Intelligence: Atomic Design System references — structural ADS harvest

**Date**: 2026-07-10  
**Analyst role**: Design-system harvest (read-only)  
**Mission**: Mission B — extract transferable **patterns** from secondary atomic DS references; rank for Warp Prism `warp_prism_ui` (ultradark glass, `Prism*` API, Riverpod-free package).  
**Related**: EPIC-15 (Hyperion HUD organisms), EPIC-01/13 (ADS foundation + public contract), existing analyses under `references/*-analysis.md`.

---

## Executive Summary

- **Verdict**: These three references are **structural / educational ADS packages**, not product-organism sources. Warp Prism already **outranks them** on domain organisms (shell, graph, log viewer, command palette, lane board, virtual scroll, etc.), token depth (obsidian + operational/governance semantics), gallery registry, and package boundary harness. Harvest value is almost entirely **layer taxonomy, theming architecture, component-API discipline, and anti-patterns** — not “copy these widgets.”
- **Best transferable items**:
  1. **Judatop** — explicit **tokens → foundations (semantic) → components** pipeline and a single public barrel.
  2. **Ahmedm guide** — **per-family `ThemeExtension`**, abstract button base + variants, **WidgetState-driven** inputs, **pages-only** state/routing rule, Widgetbook/catalog posture, package folder contract under `lib/src/`.
  3. **Villa** — clean `lib/src/{atoms,molecules,organisms,templates,tokens}` layout, **theme-aware token factory** (`VillaColors(Brightness)`), **consumer-owned controllers** + optional `isLoading` on actions, **example app as layer gallery**.
- **Primary risk**: Treating mobile form/scaffold kits as organism backlog (login forms, `Navigator.pop` templates, bottom-sheet dropdowns) and violating Prism constraints (no app routing/state in `warp_prism_ui`, no Riverpod, no DS\* leak to consumers, no license-unclear copy).

---

## Scope & method

| Source | Path | Artifact type |
| --- | --- | --- |
| **Judatop** (`atomic_design_system`) | `references/secondary-judatop-atomic_design_system/` | Full Flutter package + prior analysis MDs |
| **Ahmedm** | `references/secondary-ahmedm-gh-flutter-design-system-atomic-design/` | README guide only (no `lib/`) + analysis MDs |
| **Villa** | `references/secondary-jorgemvv01-villa_design/` | Flutter package + `/example` gallery app |
| **Prism baseline** | `packages/warp_prism_ui/lib/src/{tokens,atoms,molecules,organisms,templates,gallery}/` | Current ADS |

**Method**: read package trees, barrel files, token/theme/component samples, licenses, and existing `*-analysis.md` / `*-reasoning.md`. Claims below cite concrete lib paths. **Do not port implementation code** — reimplement patterns under `Prism*` / internal `DS*`.

---

## Warp Prism baseline (what we already have)

### Layer contract (already live)

| Layer | Path | Notes |
| --- | --- | --- |
| Tokens | `packages/warp_prism_ui/lib/src/tokens/` | colors, spacing, radii, shadows, motion, breakpoints, typography, operational state, semantics |
| Atoms | `.../atoms/` | glass panel, glow border, status dot, badge, chip, icon, text, sparkline, divider |
| Molecules | `.../molecules/` | search bar, task/asset/health cards, skeletons, toast, filter chips, state surface, … |
| Organisms | `.../organisms/` | shell, sidebar, topbar, graph, timeline, inspector, log viewer, command palette, data table, tabs, split pane, virtual scroll, lane board, code/markdown, error boundary, … |
| Templates | `.../templates/master_detail_template.dart` | responsive master–detail (breakpoints) |
| Gallery | `.../gallery/` | registry-driven sections (`design_system_gallery_registry.dart`) |
| Public API | `.../prism_aliases.dart`, package barrel | `Prism*` typedefs; DS* internal |

### Package posture (must not break)

- **`warp_prism_ui` deps**: Flutter SDK only (`packages/warp_prism_ui/pubspec.yaml`) — same ultralight posture as Judatop.
- **Boundary harness** forbids `package:flutter_riverpod|riverpod|go_router` inside the UI package (`test/boundaries/boundary_test.dart`).
- Visual direction already encoded in tokens (`DSColors.obsidian*`, accents cyan/violet/gold) and `DSGlassPanel` (`atoms/ds_glass_panel.dart`).
- EPIC-15 product organism expansion is sourced from **Hyperion** (ShadowBroker/Osiris), **not** these secondary ADS kits.

**Inference**: Atomic secondary refs validate architecture and fill **API/theme micro-gaps**; they do not replace EPIC-15 HUD work.

---

## Evidence Map

| Claim | Evidence | Confidence |
| --- | --- | --- |
| Judatop is a pure UI kit (tokens → templates), no state/DI | `lib/` tree; analysis MD; all sampled widgets `StatelessWidget` | Proven |
| Judatop barrel exports tokens, foundations, atoms, molecules, organisms, templates | `lib/atomic_design_system.dart` L1–32 | Proven |
| Judatop **does not** export `AdsDropdown` in barrel despite file existing | Barrel omits `organisms/ads_dropdown.dart`; file at `lib/organisms/ads_dropdown.dart` | Proven |
| Judatop foundations remap raw tokens | `lib/foundations/ads_foundations_colors.dart` maps `ADSColors.*` → semantic names | Proven |
| Judatop theme is static light/dark `ThemeData` factories | `lib/foundations/ads_theme.dart` (`lightTheme`, dark variants, input decoration) | Proven |
| Judatop shadow token is a likely bug (red RGBO) | `lib/tokens/ads_shadows.dart` L6–11 `Color.fromRGBO(240, 10, 4, 0.2)` | Proven |
| Judatop spacing is Fibonacci-ish (3,5,8,13,21…) | `lib/tokens/ads_spacing.dart` | Proven |
| Judatop screen template calls `Navigator.pop` + `dart:io` Platform | `lib/templates/ads_screen_template.dart` L1, L55–65 | Proven |
| Judatop MIT | `LICENSE` (Juan García, 2024) | Proven |
| Ahmedm repo has no Flutter source — README guide only | Tree: `LICENSE`, `README.md` only | Proven |
| Ahmedm teaches `ThemeExtension` per component family + aggregator | README steps 12–15 (`AppButtonTheme`, `AppTheme`, `ThemeScope`) | Proven |
| Ahmedm teaches abstract `AppTextButton` + variant subclasses | README ~L304–352 | Proven |
| Ahmedm recommends Widgetbook + widget tests + pages-only state/routing | README sections 3, 9; analysis MD | Proven |
| Ahmedm MIT | `LICENSE` (Ahmed Mostafa, 2026) | Proven |
| Villa has full ADS folders under `lib/src/` + barrel | `lib/villa_design.dart` | Proven |
| Villa colors are theme-aware via `factory VillaColors(Brightness)` | `lib/src/tokens/colors.dart` L7–16 | Proven |
| Villa login form keeps controllers external + `isLoading` | `lib/src/organisms/forms/login_form.dart` | Proven |
| Villa example app is a layer-by-layer gallery | `example/lib/home_page.dart` tokens/atoms/… pages | Proven |
| Villa LICENSE is **placeholder** (“TODO: Add your license here.”) | `LICENSE` | Proven |
| Prism already has glass atom + deep token semantics | `ds_glass_panel.dart`, `ds_colors.dart`, `ds_semantics.dart`, `ds_operational_state.dart` | Proven |
| Prism UI package is Riverpod/router-free by design | `pubspec.yaml`; boundary test import ban | Proven |

---

## Source deep-dives

### 1. Judatop — `secondary-judatop-atomic_design_system` (“maluco” ADS)

#### Folder / layer taxonomy

```text
lib/
  tokens/          # raw: colors, sizes, spacing, typography, shadows
  foundations/     # semantic aliases + ADSTheme ThemeData
  atoms/           # ADSAssetImg, ADSNetworkImg only
  molecules/       # button/*, card, text/*, avatar
  organisms/       # form field, dropdown (+ bottom sheet helper)
  templates/       # AdsScreenTemplate
  atomic_design_system.dart  # public barrel
```

#### Token → foundation contract (steal the *shape*)

| Raw | Path | Role |
| --- | --- | --- |
| `ADSColors` | `lib/tokens/ads_colors.dart` | Primitive palette (primary, bg/text light-dark, status) |
| `ADSSpacing` | `lib/tokens/ads_spacing.dart` | Fibonacci-ish scale |
| `ADSSizes` | `lib/tokens/ads_sizes.dart` | Size scale |
| `ADSTypography` | `lib/tokens/ads_typography.dart` | Font family `Geist` + sizes |
| `ADSShadows` | `lib/tokens/ads_shadows.dart` | Single shadow (broken color) |
| `ADSFoundationsColors` | `lib/foundations/ads_foundations_colors.dart` | Semantic: `primaryColor`, `titleTextLight`, status backgrounds |
| `ADSFoundationSizes` | `lib/foundations/ads_foundation_sizes.dart` | Semantic radii, icon sizes, **percent** paddings |
| `ADSTheme` | `lib/foundations/ads_theme.dart` | Material3 light/dark + component themes |

**Pattern**: components should import **foundations** (semantic), not raw hex tokens. Prism already collapses much of this into `DSColors` + `DSSemantics` + `DSOperationalState`; Judatop’s value is the **named indirection discipline**, not the palette.

#### Component API notes

| Component | Path | API pattern | Prism relevance |
| --- | --- | --- | --- |
| `AdsFilledButton` | `molecules/button/ads_filled_button.dart` | Thin `FilledButton` wrap; optional `buttonStyle`/`textStyle`/`focusNode` | Thin Material wrap = weak ADS atom; prefer theme-driven variants |
| Button family | `molecules/button/*` | filled / outlined / text / icon / round icon | Variant matrix is useful; classification as “molecule” is wrong for bare buttons |
| `AdsCard` | `molecules/card/ads_card.dart` | child + tap/double/long + border/elevation | Weaker than `DSGlassPanel` / cards |
| `AdsFormField` | `organisms/ads_form_field.dart` | label + arbitrary `formField` widget | Trivial composition; molecule-level |
| `AdsDropdown` | `organisms/ads_dropdown.dart` | disabled `TextField` + `showAdsDropdownBottomSheet` | Mobile bottom-sheet; not desktop observatory |
| `AdsScreenTemplate` | `templates/ads_screen_template.dart` | Scaffold + SafeArea + optional scroll + **Navigator.pop** | **Anti-pattern** for package boundary |

#### Anti-patterns (Judatop)

1. **Routing inside package** — `Navigator.pop` in template.
2. **Platform IO in UI kit** — `dart:io` / `Platform.isAndroid` for layout hacks.
3. **Incomplete public surface** — dropdown file not barrel-exported.
4. **Token quality** — red shadow; light-gray `bgGrey` used for “disabled”; title/subtitle/body light map to same token.
5. **Layer misclassification** — images-only atoms; buttons/text fields as molecules; form label as organism.
6. **No tests, no a11y matrix, no catalog app** in-repo.
7. **Style override free-for-all** — every button accepts raw `ButtonStyle`/`TextStyle`, undermining token SSOT.

#### License

MIT (Juan García, 2024) — **OK to study**; still **do not copy** sources into Prism (reimplement patterns only).

---

### 2. Ahmedm — `secondary-ahmedm-gh-flutter-design-system-atomic-design`

#### What it is

A **bilingual (AR/EN) production guide** for Flutter ADS (2026). **No runnable package** in the clone — only `README.md` + MIT `LICENSE`. All “code” is documentation snippets.

#### Patterns worth harvesting (from guide)

| Pattern | Guide locus | Why it matters for Prism |
| --- | --- | --- |
| Semantic token naming (`brand.500` not `buttonColor`) | Tokens section | Aligns with existing Prism governance/status naming; reinforce in reviews |
| `abstract final class` token holders | `AppColors`, `AppSpacing`, `AppRadius`, `AppShadow` | Matches Prism `abstract class DS*` style |
| **Per-component `ThemeExtension`** (`AppButtonTheme`, `AppInputTheme`, …) + aggregator `AppTheme` | Steps 12–14 | Prism mostly uses static tokens + `ThemeData.dark()` in tests/gallery; extensions enable hover/focus/error **without** inline overrides |
| `lerp` / `copyWith` on extensions | Theme section | Smooth theme transitions if multi-mode ever ships |
| **Abstract base + concrete variants** (`AppTextButton` → Primary/Secondary/Outline/Ghost) | Components | Cleaner than Judatop’s six parallel thin wrappers |
| **WidgetState\*** styling on inputs | `AppTextField` snippet | Focus/hover/error/disabled as first-class ADS states (pairs with Task 0018 a11y baseline) |
| **Pages own routing + app state**; DS stays pure UI | Architecture | Matches Prism boundary (no go_router/Riverpod in package) |
| **ThemeScope** as InheritedWidget | Scope section | Useful *idea*; avoid `SharedPreferences` inside UI package (persist in app shell) |
| **Separate assets package** + `packageName:` | Assets section | Good monorepo hygiene if assets grow |
| **Widgetbook** or dedicated catalog | Testing section | Prism already has in-package gallery + `apps/catalog` — treat Widgetbook as optional alternative, not mandate |
| Melos + semantic versioning of DS as product | Best practices | Already aligned with Warp Prism melos work |

#### What to skip from Ahmedm

- Generic e-commerce organisms (`LoginForm`, `ProductList`, `BottomNavBar`) as product targets.
- Full dual light/dark Material brand system as primary Prism goal (obsidian-first is fixed).
- Putting theme **persistence** inside the UI package.
- Claiming “80% time-to-market” marketing stats as engineering requirements.

#### License

MIT — patterns free to reimplement.

---

### 3. Villa — `secondary-jorgemvv01-villa_design` (optional structural skim)

#### Structure

```text
lib/
  villa_design.dart          # barrel
  src/
    tokens/   colors, typography
    atoms/    buttons, avatar, text_fields
    molecules/ search, profile, action_card
    organisms/ headers, forms/login_form
    templates/ page_template, form_template
    pages/    welcome_page          # ⚠ page in package
example/lib/  home_page + layer pages  # gallery-by-layer
```

#### Patterns

| Pattern | Path | Transfer note |
| --- | --- | --- |
| Theme-aware colors via factory | `src/tokens/colors.dart` | Alternative to dual static light/dark maps; Prism is effectively single-theme (obsidian) — factory still good for brightness branches |
| Dartdoc on public widgets | e.g. `elevated_button.dart` | Adopt for every new `Prism*` organism |
| `isLoading` on primary button | `VillaElevatedButton` | Small, high-value atom API |
| External controllers on forms | `VillaLoginForm` | Correct package boundary |
| Example as ADS gallery | `example/lib/home_page.dart` | Validates layer demos; Prism gallery registry is already stronger |
| Search as field + icon molecule | `src/molecules/search/search_bar.dart` | Prism already has `DSSearchBar` |

#### Anti-patterns

1. **`WelcomePage` exported from package** — pages belong in apps, not `warp_prism_ui`.
2. **Hardcoded spacing** (`EdgeInsets` 16/24) instead of spacing tokens.
3. **No radii/shadow/spacing token modules** (only colors + typography).
4. **License file is TODO** — treat as **non-copyable source**; patterns only.
5. Components rebuild `VillaColors`/`VillaTypography` every build without caching/extension.

---

## Cross-reference matrix (refs × Prism)

| Concern | Judatop | Ahmedm (guide) | Villa | Warp Prism today |
| --- | --- | --- | --- | --- |
| Tokens | Raw + foundations | Strong taxonomy | Colors+type only | **Richer** (ops, governance, motion, breakpoints) |
| Theming | Static ThemeData | **ThemeExtension** | Brightness factory | Static tokens + dark ThemeData consumers |
| Atoms | Images only | Full control kit | Buttons/fields | Glass/glow/status domain atoms |
| Organisms | Form/dropdown | Login/header (described) | Header/login | **Operational** shell/graph/logs/… |
| Gallery | None | Widgetbook advised | Example pages | **Registry gallery + catalog app** |
| A11y | Minimal (`focusNode` params) | WidgetState story | Limited | Explicit a11y task baseline (0018) |
| Tests | None | Widget test recipe | Minimal package test | Goldens + boundary harness |
| Package purity | Broken by Navigator/Platform | Documented purity | Page export leak | **Enforced** boundaries |
| Glass / HUD | None | None | None | Glass panel + EPIC-15 HUD plan |

---

## Harvested Items

| Score | Item | Local Destination | Effort | Risk |
| --- | --- | --- | --- | --- |
| **GOLD** | **Package purity rule**: no routing, no platform IO, no app pages, no Riverpod in UI package (negative harvest from Judatop/Villa) | `warp_prism_ui` boundary tests + AGENTS/rules; reject any organism that calls `Navigator`/`go_router` | Low | Low — already mostly enforced |
| **GOLD** | **Pages/apps own state; DS accepts controllers/callbacks** (Villa login + Ahmedm pages rule) | All new `Prism*` organism contracts in EPIC-15+ | Low | Low |
| **GOLD** | **WidgetState / focus-hover-error-disabled matrix** on interactive atoms (Ahmedm `AppTextField` pattern) | Atoms that still wrap Material without state maps; pair with gallery “states” section | Med | Low–med (visual QA) |
| **SILVER** | **Tokens → semantic foundations** explicit layer (Judatop `foundations/`) | Optional `lib/src/foundations/` *or* document that `DSSemantics` + `DSOperationalState` **are** foundations; avoid dual SSOT | Med | Med if duplicated |
| **SILVER** | **Per-family ThemeExtension** for glass/button/input/glow (Ahmedm) | `foundations/` or `theme/` under `warp_prism_ui`; single `PrismTheme` extension aggregating glass blur, border glow, input borders | High | Med — migration from static `DSColors` call sites |
| **SILVER** | **Abstract control base + named variants** (Ahmedm `AppTextButton`) | If/when `PrismButton` / control family is formalized (gallery still mentions button-like surfaces) | Med | Low |
| **SILVER** | **Optional `isLoading` on primary actions** (Villa) | Atom/molecule action surfaces used by Operate boards | Low | Low |
| **SILVER** | **Barrel completeness + export tests** (negative: Judatop dropdown missing) | `warp_prism_ui.dart` / `prism_aliases.dart` + boundary/export tests | Low | Low |
| **BRONZE** | **Layer-ordered example gallery** (Villa example) | Already covered by `design_system_gallery_registry.dart`; use as checklist only | — | — |
| **BRONZE** | **Separate assets package** (Ahmedm) | Future monorepo package if fonts/SVGs grow | Med | Low |
| **BRONZE** | **Widgetbook** (Ahmedm) | Only if catalog app insufficient; avoid dual catalog maintenance | High | Med |
| **IRON** | Port Judatop buttons/cards/text fields/dropdown | N/A | — | Architecture + visual mismatch |
| **IRON** | Port Villa login/welcome/header as product organisms | N/A | — | Mobile app chrome; license unclear |
| **IRON** | Fibonacci spacing scale | N/A | — | Conflicts with Prism 4/8 scale in `ds_spacing.dart` |
| **IRON** | Bottom-sheet select pattern as desktop organism | N/A | — | Wrong interaction model for observatory |
| **IRON** | Theme persistence (`SharedPreferences`) inside UI package | N/A | — | Violates package purity |

### Priority ranking for builders

#### P0 — steal-now (patterns / guardrails, not code dumps)

1. **Codify ADS package purity checklist** from Judatop/Villa failures (Navigator, Platform, pages-in-package) into task templates / boundary harness notes.
2. **State matrix for interactive atoms**: focused / hovered / disabled / error / loading — document in gallery; implement WidgetState styling where Material leaves gaps for glass.
3. **Organism API contract**: data in via typed props/models; behavior out via callbacks; **no** internal navigation.

#### P1 — adapt-later

1. Design **`ThemeExtension` glass/control themes** for true themable glow/blur/border without scattering `DSColors` literals (Ahmedm architecture, Prism palette).
2. Formalize **button/control variant family** with abstract base if multiple control styles proliferate.
3. Optional **`foundations/`** folder rename/docs if token review confusion continues — only after EPIC-13 barrel stability.
4. **`isLoading`** (and busy semantics) on key action molecules used by Operate.

#### P2 / skip

1. Any form-auth, mobile scaffold, or Material bottom-sheet select organism from these refs.
2. Widgetbook introduction before catalog/gallery debt is real.
3. Dual light/dark consumer marketing themes as core ADS work.
4. Copying Judatop `AdsScreenTemplate` — Prism has `DSShell` + `MasterDetailTemplate` + EPIC-15 `PrismMapHudWorkspace`.

---

## Organisms / molecules / atoms worth adapting?

**Short answer: almost none as product organisms.** These kits are generic mobile/web form systems. Prism’s organism gap is **ops/HUD** (EPIC-15), not login headers.

| Candidate from refs | Suggested Prism home | Harmonization |
| --- | --- | --- |
| Button **variant matrix** (Judatop files / Ahmedm abstract base) | Atom: formalize `PrismButton` / control variants if still fragmented | Ultradark glass, glow border, cyan/violet accents; no Material filled default look |
| Label + field composition (`AdsFormField`) | Molecule if filter/settings forms need it | Use spacing tokens; glass field chrome |
| Card shell (`AdsCard` / `VillaActionCard`) | Prefer existing `DSGlassPanel` + asset/task cards | Do not add parallel card stack |
| Search molecule (`VillaSearchBar`) | Already `DSSearchBar` | Skip duplicate |
| Header organism (`VillaHeader`) | Already `DSTopbar` / shell | Skip |
| Screen / page templates | Already shell + master-detail + EPIC-15 HUD workspace | Skip mobile scaffold |
| Dropdown bottom sheet | Desktop combobox / filter workbench later (EPIC-15 O-14) | Different UX |

---

## Anti-patterns, license, architecture mismatch (summary)

| Issue | Source | Prism rule |
| --- | --- | --- |
| `Navigator.pop` / routing in package | Judatop template | **Forbidden** in `warp_prism_ui` |
| `dart:io` Platform layout | Judatop template | Prefer breakpoints / LayoutBuilder; no IO in pure UI if avoidable |
| Pages exported from DS package | Villa `WelcomePage` | Pages live in apps (`observatory`, `catalog`, `cybercore`) |
| Incomplete barrel | Judatop dropdown | Every public `Prism*` must export + test |
| Style override soup | Judatop buttons | Prefer theme/extension + limited style hooks |
| Broken shadow token | Judatop shadows | Token review + goldens catch this class of bug |
| App state / prefs in DS | Ahmedm ThemeScopeWidget prefs | Persist theme mode in **app**, inject via theme |
| Unclear license | Villa `LICENSE` TODO | **No code copy**; patterns only |
| Riverpod/go_router | None in these refs (good) | Keep package free (boundary test) |
| Domain organisms from Hyperion | Out of this mission | EPIC-15 reports — do not conflate |

---

## What Was Not Found

| Search | Result |
| --- | --- |
| Runnable Flutter code in Ahmedm clone | **None** (README-only) |
| Glassmorphism / BackdropFilter / neon glow in any of the three | **None** |
| Desktop observatory organisms (graph, log stream, command palette, lane board) | **None** |
| Accessibility suite (semantics, focus traversal tests) | **None** beyond `focusNode` params / WidgetState docs |
| Golden tests | **None** in Judatop/Villa of significance |
| Responsive breakpoint system | **None** solid (Judatop % MediaQuery only; Prism already has `DSBreakpoints`) |
| Operational / governance status vocabulary | **None** (Prism-unique) |
| Melos monorepo implementation in these clones | Documented only (Ahmedm) |
| Prior analysis files | **Present** for Judatop + Ahmedm (`*-analysis.md`, `*-analysis-reasoning.md`); Villa has no prior analysis MD in `references/` |

---

## Recommended Next Tasks

| # | Task sketch | Priority | Depends |
| --- | --- | --- | --- |
| 1 | **ADS purity checklist** note in task template / EPIC-15 contract brief: no Navigator, no go_router, no Riverpod, no pages, no Platform IO in package | P0 | — |
| 2 | **Interactive state matrix** gallery section expansion (hover/focus/error/disabled/loading) for atoms that lack it | P0–P1 | Gallery registry |
| 3 | Spike: **`PrismTheme` / glass ThemeExtension** design doc (Ahmedm pattern × `DSColors`/`DSShadows`/`DSGlassPanel`) — no big-bang rewrite | P1 | EPIC-13 stable |
| 4 | If controls proliferate: **abstract button/control base + variants** task | P1 | Spike #3 optional |
| 5 | **Do not** open tasks to port Judatop/Villa organisms; keep EPIC-15 on Hyperion harvest for product organisms | P0 governance | EPIC-15 |
| 6 | Optional: document Villa as **IRON for code / BRONZE for example-app gallery** in reference index (license TODO) | P2 | — |

---

## Verdict by reference

| Reference | Overall harvest grade | Steal? |
| --- | --- | --- |
| **Judatop** | **SILVER structural**, IRON widgets | Steal tokens→foundations *idea* + purity anti-patterns; skip component ports |
| **Ahmedm** | **GOLD architecture guide**, IRON “codebase” (none) | Steal ThemeExtension / WidgetState / purity / catalog philosophy; reimplement |
| **Villa** | **BRONZE structure**, IRON license+product fit | Steal controller ownership + `isLoading` + example layering; skip source copy |

**Bottom line for Ganthritor/Warp Prism**: treat these as **ADS methodology validators**. Warp Prism’s next organism value remains **EPIC-15 Hyperion HUD** work; these secondary packages should only spawn **theme/API hygiene** tasks, not a parallel generic component rewrite.

---

## Appendix A — Judatop public barrel inventory

From `lib/atomic_design_system.dart`:

- Tokens: `ads_colors`, `ads_shadows`, `ads_sizes`, `ads_spacing`, `ads_typography`
- Foundations: colors, spacing, typography, sizes, `ads_theme`
- Atoms: `ads_asset_img`, `ads_network_img`
- Molecules: 6 buttons, card, headline/title/subtitle, text field, text form field, avatar
- Organisms: **`ads_form_field` only** (dropdown exists on disk, not exported)
- Templates: `ads_screen_template`

## Appendix B — Prism organism inventory (baseline, do not re-harvest as “new from atomic refs”)

`packages/warp_prism_ui/lib/src/organisms/`: shell, sidebar, topbar, lane board, timeline, detail inspector, story panel, graph canvas (+ graph/), status grid, code block, markdown, fallback, error boundary, log viewer, command palette, tab bar, split pane, data table, virtual scroll.

## Appendix C — Prior local analyses consulted

- `references/secondary-judatop-atomic_design_system-analysis.md`
- `references/secondary-judatop-atomic_design_system-analysis-reasoning.md`
- `references/secondary-ahmedm-gh-flutter-design-system-atomic-design-analysis.md`
- `references/secondary-ahmedm-gh-flutter-design-system-atomic-design-analysis-reasoning.md`
- `docs/tasks/00-planning/EPIC-15-warp-prism-ads-organism-expansion-from-reference-harvest.md` (Hyperion scope boundary)

---

*Report type: External Intelligence / ADS structural harvest. No external source code copied into packages.*
