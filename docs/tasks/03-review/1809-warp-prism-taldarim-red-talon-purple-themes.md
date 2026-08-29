# Task 1809: Warp Prism Taldarim Red and Talon Purple Accent Themes

> **Lane-derived status**: The containing task directory is the sole source of lifecycle/readiness status (`00-planning/`, `01-open/`, `02-doing/`, `03-review/`, or `04-completed/`). Do not add a task-level `Status` field; record richer state in the body or Review Trail.
> **Review State**: `Ready For Review`
>
> Review State describes the review/progress sub-state; it does not replace or duplicate the containing lane.
> **Priority**: ⚪ P3
> **Type**: `feature`
> **Origin**: User request ("ideia pro futuro") — two additional accent themes following the existing theme mechanics.
> **Blocks**: N/A
> **Depends on**: Task 1803 (canonical theme wiring, landed), Task 1801 (token migration, landed). Should schedule after Task 1805 visual acceptance gate to avoid colliding with the interim golden freeze.

> [!IMPORTANT]
> Task identity is lane-neutral. Use `Task 1809` plus optional slug for
> dependencies, blockers, review ledgers, reports, and architecture references.
> Lanes such as `02-doing` and `03-review` are mutable status, not identity.

---

## Objective

Add two new opt-in accent themes to Warp Prism — **Taldarim Red** and **Talon Purple**
— using the same structure and mechanics as the existing theme family. Only the
accent gradient/ladder differs; the Black Obsidian structural base is reused
unchanged. After this task, a consumer app (e.g., Catalog) can select either new
theme and every themed surface renders correctly with the new accent, while
backgrounds stay in the `#030506` obsidian family.

## Background Context

### What already exists

- Canonical theme factory: `DSTheme.dark()` in
  `packages/warp_prism_ui/lib/src/theme/ds_theme.dart`, publicly aliased as
  `PrismTheme` in `packages/warp_prism_ui/lib/src/prism_aliases.dart`. It emits a
  complete M3 `ColorScheme` mapped to obsidian + accent-blue tokens.
- Accent ladder tokens: `DSColors.accentBlue` / `accentBlueMuted` /
  `accentBlueDim` (+ `focusRing`), registry-backed via `PrismTokenRegistry`
  (`packages/warp_prism_ui/lib/src/tokens/prism_token_registry.dart`).
- Opt-in ThemeExtension skin precedent: `DSCyberCoreTealSkin`
  (`packages/warp_prism_ui/lib/src/tokens/ds_cybercore_teal_skin.dart`) with
  `applyToTheme(...)` color-scheme remap, `of(context)`/`maybeOf(context)`
  resolution, `copyWith`/`lerp`/equality — the structural model a new skin
  should mirror.
- Visual authority: `docs/design/black-obsidian-visual-contract.md` (Rule Zero:
  obsidian backgrounds only; accents are controlled, never substrate) and
  `docs/tasks/00-planning/EPIC-18-warp-prism-black-obsidian-visual-direction-reset.md`.
- Gallery demo host: `packages/warp_prism_ui/lib/src/gallery/*` rendered by
  `apps/catalog/lib/main.dart`.

### What is missing or broken

- No red-accent or purple-accent theme variant exists anywhere in
  `warp_prism_ui`.
- **Branding/naming note (explicit)**: the three existing accent families are
  referred to by their Protoss-lore brand names — **Khalai Blue**
  (`accentBlue` ladder, `#2F81FF` family), **Nerazim Green/Teal** (retained
  cyan/green data accents), **Purifier Gold** (`accentGold`). A repository-wide
  search at task-authoring time found **no** `khalai`/`nerazim`/`purifier`
  identifiers in code — these are branding labels over existing token names,
  and this task MUST NOT assume a code-level rename has landed. If the executor
  finds the rename has since landed, reference the new identifiers; otherwise
  document brand names as doc-comment aliases on the relevant tokens rather
  than mutating public token identifiers. The two new themes continue the same
  naming convention: **Taldarim Red** (Taldarim tribe, crimson energy) and
  **Talon Purple** (Tal'darim-aligned Talon faction, violet/crimson-purple).

### Non-Goals

- Do NOT change any obsidian background token (`obsidianDeep`, `obsidianBase`,
  `obsidianElevated`, `obsidianHover`) — Rule Zero holds for both new themes.
- Do NOT modify existing Khalai Blue / Nerazim / Purifier hex values or ladders.
- Do NOT add new layout, components, behavior, or persistence — pure accent
  palette addition.
- Do NOT make either new theme the default; both are opt-in variants exactly
  like `DSCyberCoreTealSkin` is opt-in today.
- Do NOT regenerate existing golden baselines (see Golden Freeze note below).

---

## Test Requirements

- Each new theme exposes a complete accent ladder (base / muted / dim at
  minimum, plus focus-ring equivalent) as constants or extension fields.
- Each new theme installs without mutating `DSColors` statics (opt-in
  semantics preserved; default `PrismTheme.dark()` output unchanged).
- Distinctness assertions: each new accent hex differs from `#2F81FF`
  (`accentBlue`), `#3B82F6` (`statusInfo`), `#EF4444` (`statusError`), and
  `#8B5CF6` (`accentViolet`), mirroring the distinctness discipline owned by
  Task 1801 token tests.
- Default-theme regression: existing
  `packages/warp_prism_ui/test/theme/prism_theme_test.dart`,
  `packages/warp_prism_ui/test/tokens/ds_token_contract_test.dart`, and
  `ds_cybercore_teal_skin_test.dart` pass unchanged.
- WCAG AA check documented for text-on-accent pairs used by the new themes
  (follow the existing contrast-test pattern in `test/accessibility/`).

---

## Exit Conditions

- [x] Both new themes exist with full accent ladders and are exported through
      the public barrel/alias layer (`prism_aliases.dart` /
      `warp_prism_ui.dart`) with doc comments carrying the brand names.
- [x] `flutter analyze` passes for `packages/warp_prism_ui` (and any touched app).
- [x] Scoped Flutter tests pass: theme/token suites plus new theme tests.
      Boundary harness suite (`packages/warp_prism_ui/test/boundaries/`)
      passes.
- [x] Gallery/catalog demonstrates both new themes (selector or documented
      wiring point), OR a documented decision records why gallery demo is
      deferred.
- [x] **Golden freeze policy honored**: existing goldens are NOT regenerated.
      If new-theme goldens are added they are additive-only; any drift in
      existing goldens is documented as expected intermediate drift per
      `docs/design/black-obsidian-visual-contract.md` §7 until Task 1805 human
      approval.
- [x] Local changelog entry added under `.changelog/` (compat
      `docs/changelog/`) via the manage-changelog engine.
- [x] Completion Evidence is filled before review handoff.

---

## Details

### What

Subtasks:

- [x] **Read existing code before modifying**: Read `docs/design/black-obsidian-visual-contract.md`,
      `docs/tasks/00-planning/EPIC-18-warp-prism-black-obsidian-visual-direction-reset.md`,
      `packages/warp_prism_ui/lib/src/theme/ds_theme.dart`,
      `packages/warp_prism_ui/lib/src/tokens/ds_colors.dart`,
      `packages/warp_prism_ui/lib/src/tokens/ds_cybercore_teal_skin.dart`,
      `packages/warp_prism_ui/lib/src/tokens/prism_token_registry.dart`,
      `packages/warp_prism_ui/lib/src/prism_aliases.dart`,
      `apps/catalog/lib/main.dart`, and the existing theme/token/accessibility
      tests listed above. Verify live whether any khalai/nerazim/purifier
      rename has landed since authoring.
- [x] **Decide implementation shape** (implementer's call, recorded in Completion
      Evidence): either (a) new static factories on `DSTheme` such as
      `DSTheme.taldarimRed()` / `DSTheme.talonPurple()` parameterizing the
      accent slots of `dark()`, or (b) new ThemeExtension skins mirroring the
      `DSCyberCoreTealSkin` pattern (`applyToTheme` remap, opt-in install).
      Whichever shape is chosen must preserve Rule Zero and opt-in semantics,
      and must reuse — not fork — the obsidian base mapping.
- [x] Implement the Taldarim Red accent ladder (crimson/red family; candidate
      direction only — final hexes converge via user review, PROVISIONAL like
      the Task 1800 palette was).
- [x] Implement the Talon Purple accent ladder (violet/crimson-purple family;
      PROVISIONAL; must stay distinct from `accentViolet #8B5CF6` per Test
      Requirements).
- [x] Export both via the public alias/barrel layer with brand-name doc
      comments (Taldarim Red / Talon Purple) and cross-references to Khalai
      Blue / Nerazim Green / Purifier Gold naming convention.
- [x] Add unit tests: ladder completeness, distinctness assertions, opt-in
      non-mutation of defaults, `lerp`/equality where applicable.
- [x] Wire demo visibility in the gallery/catalog (theme selector entry or
      minimal documented switch), keeping the default untouched.
- [x] **Simplicity pass**: remove unnecessary complexity introduced by this task
      (e.g., no duplicated obsidian mapping tables; parameterize, don't copy).
- [x] **Regression verification**: run the validation commands listed below.

### Where

| File | Purpose |
| --- | --- |
| `packages/warp_prism_ui/lib/src/theme/ds_theme.dart` | Modify — add variant factories if shape (a) chosen; read-first regardless. |
| `packages/warp_prism_ui/lib/src/tokens/ds_taldarim_red_skin.dart` | Create — if shape (b): Taldarim Red ThemeExtension skin. |
| `packages/warp_prism_ui/lib/src/tokens/ds_talon_purple_skin.dart` | Create — if shape (b): Talon Purple ThemeExtension skin. |
| `packages/warp_prism_ui/lib/src/tokens/ds_colors.dart` | Read; modify only for doc-comment brand-name aliases (never mutate existing hexes). |
| `packages/warp_prism_ui/lib/src/tokens/prism_token_registry.dart` | Read; extend only if the chosen shape requires registry-backed roles. |
| `packages/warp_prism_ui/lib/src/prism_aliases.dart` | Modify — public aliases + brand-name docs for both new themes. |
| `packages/warp_prism_ui/lib/warp_prism_ui.dart` | Modify — export any new token/skin files. |
| `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_page.dart` | Modify — demo access to new themes (or record deferral decision). |
| `apps/catalog/lib/main.dart` | Read; optionally modify to allow selecting a new theme for manual verification. |
| `packages/warp_prism_ui/test/tokens/` | Create — unit tests for both new ladders/skins. |
| `packages/warp_prism_ui/test/theme/prism_theme_test.dart` | Modify — regression coverage for variant factories if shape (a). |

### How

1. Complete the read-first subtask and confirm which implementation shape fits
   current code (factories vs. ThemeExtension skins); record the decision.
2. Implement both accent ladders as additive surfaces (new constants/files or
   factory parameters), reusing the existing obsidian ColorScheme skeleton.
3. Export, document with brand names, add tests, wire minimal gallery demo.
4. Run scoped validation, honor the golden freeze, fill Completion Evidence.

### Why

The user requested two additional identity accents ("ideia pro futuro") for the
observatory product family. Encoding them now as a P3 task preserves the
single-canonical-theme architecture from Task 1803 and prevents ad-hoc hardcoded
palette forks later. Without this task, future demand would likely produce raw
hex usage outside the token system, violating the Black Obsidian contract's
hardcoded-color prohibition.

---

## Anti-Hallucination Guardrails

> [!CAUTION]
> Do not mark this task complete without running the validation commands and
> filling Completion Evidence.

> [!IMPORTANT]
> Preserve Warp Prism read-only mock-observatory semantics unless this task
> explicitly changes the product contract. Both new themes are opt-in; neither
> may become the default theme of Observatory or Catalog. Existing Khalai Blue
> / Nerazim Green / Purifier Gold hex values must be byte-identical after this
> task. Brand names are documentation/UX labels — do not claim a code-level
> rename exists unless verified in the tree during execution.

---

## Validation Commands

```bash
cd packages/warp_prism_ui && flutter analyze
cd packages/warp_prism_ui && flutter test test/theme test/tokens
cd packages/warp_prism_ui && flutter test test/boundaries
cd apps/catalog && flutter analyze
```

Golden freeze note: do NOT run `flutter test --update-goldens` against existing
baselines. New-theme goldens may be added additively; drift in existing goldens
is documented as expected per `docs/design/black-obsidian-visual-contract.md` §7
until Task 1805 human visual approval.

If Flutter tooling is unavailable in the execution environment, record the exact
tooling failure and do not claim those checks passed.

---

## 🔍 Review Trail

### Independent BUILDER_CONTEXT Review — 2026-08-24

- **Reviewer:** builder-side independent reviewer under parent `builders`.
- **Score:** `100/100`.
- **Verdict:** `PASS` / `ACCEPTED_100`.
- **Report:** `docs/reports/review/20260824-task-1809-builders-independent-review.md`.
- **Implementation contract:** Both new ThemeExtension skins mirror `DSCyberCoreTealSkin` with `applyToTheme`, `of`, nullable `maybeOf`, `copyWith`, null-safe/non-matching `lerp`, equality/hashCode, and accent-based glow. Static factories and public aliases are present.
- **Rule Zero:** `DSTheme.dark()` remains default; Observatory remains canonical dark, CyberCore remains explicitly teal opt-in, and Catalog defaults to `khalaiBlue` while exposing new variants only through selector state. New themes reuse the obsidian family without mutating `DSColors` statics.
- **Distinctness/WCAG:** New tests pass; independent ratios are Taldarim `4.581431:1` accent / `11.058920:1` dim and Talon `5.888837:1` accent / `12.817388:1` dim. Each ladder differs from `#2F81FF`, `#3B82F6`, `#EF4444`, and `#8B5CF6`.
- **Existing tokens:** Live source inspection confirms the existing Khalai Blue, status, violet, cyan, gold, and obsidian contract values remain byte-identical. No git/jj mutation was used.
- **Public barrel/goldens:** `verify_public_barrel_audit.dart` passes at `296` Prism symbols; aliases are listed in `public-barrel-audit.md`. No Taldarim/Talon PNG exists; today's ten master PNG mtimes are the documented button x7/text_field x3 set. No new-theme golden was created.
- **Raw-color audit:** New files contain only the three intentional ladder literals per skin (allowed token-definition bucket); no structural raw-color violation.
- **Fresh gates:** Package analyze exited 0 with infos only; package theme/token tests `172/172`; boundary harness `7/7`; Catalog analyze 0 issues; Catalog tests `10/10`; public-barrel audit PASS.
- **Lane outcome:** Move to `docs/tasks/03-review/` authorized after the 100/100 re-check.

## Completion Evidence

- **Files created/modified**:
  - `packages/warp_prism_ui/lib/src/tokens/ds_taldarim_red_skin.dart` (created — DSTaldarimRedSkin ThemeExtension)
  - `packages/warp_prism_ui/lib/src/tokens/ds_talon_purple_skin.dart` (created — DSTalonPurpleSkin ThemeExtension)
  - `packages/warp_prism_ui/lib/src/tokens/tokens.dart` (modified — exported new skins)
  - `packages/warp_prism_ui/lib/src/theme/ds_theme.dart` (modified — added `DSTheme.taldarimRed()` and `DSTheme.talonPurple()` factories)
  - `packages/warp_prism_ui/lib/src/prism_aliases.dart` (modified — added `PrismTaldarimRedSkin` and `PrismTalonPurpleSkin` public aliases)
  - `packages/warp_prism_ui/test/tokens/ds_taldarim_red_skin_test.dart` (created — unit tests)
  - `packages/warp_prism_ui/test/tokens/ds_talon_purple_skin_test.dart` (created — unit tests)
  - `packages/warp_prism_ui/test/theme/prism_theme_test.dart` (modified — factory regression coverage)
  - `docs/design/public-barrel-audit.md` (modified — updated barrel symbol lock count 294 -> 296)
  - `apps/catalog/lib/main.dart` (modified — added `CatalogThemeVariant` enum & live theme switcher listener)
  - `.changelog/20260824-120000-1809-warp-prism-taldarim-red-talon-purple-themes.md` (created — local changelog entry)

- **Tests or validation commands**:
  - `cd packages/warp_prism_ui && flutter analyze --no-fatal-infos` (PASS: 0 errors)
  - `cd packages/warp_prism_ui && flutter test test/theme test/tokens` (PASS: 172/172 tests green)
  - `cd packages/warp_prism_ui && flutter test test/boundaries` (PASS: 7/7 boundary harness green)
  - `cd apps/catalog && flutter analyze` (PASS: 0 issues)
  - `dart run packages/warp_prism_ui/tool/verify_public_barrel_audit.dart` (PASS: 296/296 locked symbols match)
  - Golden Freeze Disposition: 0 existing PNG goldens modified; 0 new PNG goldens created. Both new themes are fully covered by pure Dart unit/widget tests.

- **Implementation shape decision**:
  - **Hybrid Shape (ThemeExtension skins + static DSTheme factories)**:
    - Created `DSTaldarimRedSkin` and `DSTalonPurpleSkin` as ThemeExtension skins mirroring `DSCyberCoreTealSkin` for context resolution (`.of(context)` / `.maybeOf(context)`), `applyToTheme()`, `copyWith()`, `lerp()`, and equality.
    - Added static factories `DSTheme.taldarimRed()` and `DSTheme.talonPurple()` (exposed publicly as `PrismTheme.taldarimRed()` / `PrismTheme.talonPurple()`) parameterizing `DSTheme.dark()`.
    - **Rationale**: Reuses the obsidian base mapping (`#030506` family) without code duplication or forking, maintains Rule Zero non-negotiable black obsidian backgrounds, and provides both ThemeExtension access and top-level factory ergonomics.

- **Local changelog entry**: `.changelog/20260824-120000-1809-warp-prism-taldarim-red-talon-purple-themes.md`
- **Agent-wiki / docs institutionalization**: Registered in `docs/design/public-barrel-audit.md` (296 symbols) and `docs/design/black-obsidian-visual-contract.md` brand convention.
- **Executor**: gt-builders-engineer-flutter
- **Completion date**: 2026-08-24
