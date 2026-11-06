# Warp Prism — Token, Theme, Catalog, and Component Promotion Policy

> **Status**: Active policy
> **Author**: Task 1105 — Warp Prism Token Theme Catalog Policy
> **Date**: 2026-06-08
> **Depends on**: Task 1101 (charter/naming — **Promoted** `04-completed/`); Task 1104 architecture artifact `.project/architecture/warp-prism-melos-monorepo-architecture.md` (task lane `03-review/` Ready For Review as of 2026-07-09, not yet Promoted); Task 1102 **source docs** `docs/design/operational-state-vocabulary.md` + `docs/design/component-inventory.md` (task still `02-doing/` / blocked on screenshots — not a gate on this policy's API accuracy)
> **Blocks**: Task 1106 (component migration), Task 1107 (Melos migration), Task 1111 (expansion gate)
> **Public API authority**: Live `packages/warp_prism_ui` barrel + `prism_aliases.dart` (per-class `Prism*` typedefs). No `PrismTokens`.

---

## 1. Purpose

This policy turns the existing in-app Design System Gallery into a governed ADS
contract so components in `warp_prism_ui` can be promoted only when they have
catalog evidence, state matrices, tests, and accessibility coverage. It is the
single source of truth for:

- Token layering (primitive → semantic → component)
- Naming conventions (DS* legacy vs Prism* public API)
- ThemeExtension ownership
- Component promotion gates per atomic layer
- Catalog, golden-test, and semantics-test policy
- Operational state matrix requirements
- Gallery-to-catalog evolution path
- ADS upgrade loop when consumer apps discover bugs or missing components

For consumer coverage or external donor inspiration, use the Warp Prism-only
[`wp-component-absorption`](../../.opencode/workflows/wp-component-absorption.md)
workflow (subject to its lifecycle metadata) and
[component adaptation reference](component-adaptation.md). They separate research,
local selection and design from construction; they do not replace this policy's
token/catalog proof or the current mission/layer promotion requirements.

---

## 2. Token Categories and Naming Conventions

### 2.1 Token Layers

| Layer | Purpose | Examples | Package Location |
|-------|---------|----------|------------------|
| **Primitive** | Raw color hex values, pixel scales, duration constants, curve references. No semantic meaning. Used only as building blocks for semantic tokens. | `Color(0xFF00D4FF)`, `48.0`, `Duration(milliseconds: 200)` | `warp_prism_ui/lib/src/tokens/` — constants inside token classes |
| **Semantic** | Named tokens that encode meaning. Reference primitives but add intent. | `DSColors.statusSuccess`, `DSSpacing.gapSection`, `DSMotion.hoverDuration`, `DSSemantics.laneDoing` | `warp_prism_ui/lib/src/tokens/` — exposed on token classes |
| **Component** | Per-component style defaults derived from semantic tokens. Not global constants — these live inside component constructors or static methods. | `DSGlassPanelSimple` border default → `DSColors.borderDefault`, `DSTaskCard` proof-state colors → `DSColors.forAssetKind()` | `warp_prism_ui/lib/src/atoms/`, `molecules/`, etc. |

**Rule**: A new component MUST NOT introduce new primitive or semantic tokens
without a documented justification in the task. If a needed semantic token is
missing, add it to the appropriate token class (`DSColors`, `DSSpacing`, etc.)
before using raw values in the component.

### 2.2 Existing Token Inventory

> **Supersession Note (Task 1800 / Task 1801)**: Default palette sections superseded by the Black Obsidian Visual Contract (`docs/design/black-obsidian-visual-contract.md`). Structural backgrounds are pure black obsidian (`#030506` family), primary action accent is `accentBlue` (`#2F81FF`), and cyan (`#00D4FF`) is retained as a data-category accent.

Evidence from Task 0014 lineage and **live** `packages/warp_prism_ui/lib/src/tokens/`
inspection (line counts refreshed 2026-07-09; treat counts as inventory hints, not
API contracts):

| Token Class | Public Alias | File | Lines | Role |
|-------------|--------------|------|-------|------|
| `DSColors` | `PrismColors` | `tokens/ds_colors.dart` | 254 | Black Obsidian backgrounds (#030506 family), primary action blue ladder (#2F81FF/#1D64D8/#114299), retained data accents (cyan/violet/gold), status, governance, text, border (#121D22), lane, asset-kind colors, **and 15 operational-state semantic aliases**. Lookup methods: `forAssetKind()`, `forLane()`, `forCanonicity()`. |
| `DSTypography` | `PrismTypography` | `tokens/ds_typography.dart` | 186 | 18-style type scale: display/heading/body/label/code/numeric × large/medium/small. JetBrainsMono (mono) + Inter (sans). |
| `DSSpacing` | `PrismSpacing` | `tokens/ds_spacing.dart` | 72 | Base scale (xxs→massive: 2/4/8/12/16/20/24/32/48/64px) + semantic spacing (insets, gaps, layout dimensions). |
| `DSRadii` | `PrismRadii` | `tokens/ds_radii.dart` | 47 | Base radii (none→full: 0/2/4/6/8/12/16/9999) + semantic radii (card/button/chip/input/panel/modal). |
| `DSShadows` | `PrismShadows` | `tokens/ds_shadows.dart` | 116 | Elevation presets + energy glow effects (cyan/violet/gold/success/error/warning) + inner shadow. |
| `DSMotion` | `PrismMotion` | `tokens/ds_motion.dart` | 66 | Durations + curves + semantic animations (hover/focus/page/panel/stagger). |
| `DSSemantics` | `PrismSemantics` | `tokens/ds_semantics.dart` | 167 | Pre-composed semantic text styles: status, governance, asset kind, lane, proof state. Lookup methods: `forAssetKind()`, `forLane()`, `forProofState()`. |
| `DSBreakpoints` | `PrismBreakpoints` | `tokens/ds_breakpoints.dart` | 32 | Responsive breakpoint constants: narrow (600), sidebarCollapse (800), masterDetailSideBySide (1200), timelineDetail (1000). |
| `DSOperationalState` (+ severity/category enums) | `PrismOperationalState` (+ `PrismOperationalSeverity`, `PrismOperationalCategory`) | `tokens/ds_operational_state.dart` | 452 | Canonical 15-state vocabulary; UI metadata via `PrismOperationalStateUI` extension on the enum. |

Also present: `tokens/tokens.dart` (barrel-style re-exports within the tokens folder — implementation detail, not a public `PrismTokens` facade).

### 2.3 Operational State Color Tokens

> **Supersession Note (Task 1800 / Task 1801)**: Primary action accent for interactive controls is `accentBlue` (`#2F81FF`). `statusPromoted` remains `accentCyan` (`#00D4FF`) as a retained data-category accent until Task 1806.

The 15 operational states are defined in `docs/design/operational-state-vocabulary.md`
and implemented live as **semantic aliases on `DSColors` / `PrismColors`** plus
`PrismOperationalState` / `PrismOperationalStateUI`. **No new hex values are needed** —
aliases map to existing palette entries.

| Operational State | Live `PrismColors` alias | Color Source | Hex |
|-------------------|--------------------------|--------------|-----|
| Pending | `statusPending` | `textTertiary` | `#8888A0` |
| Running | `statusRunning` | `accentGold` | `#FFB800` |
| Approved | `statusApproved` | `statusSuccess` | `#10B981` |
| Rejected | `statusRejected` | `statusError` | `#EF4444` |
| Promoted | `statusPromoted` | `accentCyan` | `#00D4FF` |
| Archived | `statusArchived` | `textDisabled` | `#505060` |
| Healthy | `statusHealthy` | `statusSuccess` | `#10B981` |
| Degraded | `statusDegraded` | `statusWarning` | `#F59E0B` |
| Error | `statusOpError` | `statusError` | `#EF4444` |
| Disabled | `statusDisabled` | `textDisabled` | `#505060` |
| Unverified | `statusUnverified` | `textTertiary` | `#8888A0` |
| Exposed | `statusExposed` | `statusError` | `#EF4444` |
| Redacted | `statusRedacted` | `accentViolet` | `#8B5CF6` |
| Stale | `statusStale` | `statusWarning` | `#F59E0B` |
| Excluded | `statusExcluded` | `textDisabled` | `#505060` |

**Policy (already satisfied in live package)**: Components MUST use these semantic
aliases (or `PrismOperationalState.*.color`) rather than hard-coding hex values.
New operational-state colors, if ever needed, MUST be added to `DSColors` as
static const fields and remain reachable via `PrismColors` / the operational-state
extension — never as a nested `PrismTokens` namespace unless that facade is
explicitly implemented and barrel-exported.

### 2.4 Naming Conventions

#### DS* Prefix (Internal / Legacy Layer)

All existing classes use `DS` or `Ds` prefixes (e.g., `DSColors`, `DSText`,
`DSGlassPanelSimple`). These names were created by the v0 generation.

**Policy**: `DS*` names remain as the **internal implementation names** inside
`warp_prism_ui/lib/src/`. They are not deleted or renamed in the initial
migration (Task 1107). They are the canonical names for the pre-Prism codebase.

#### Prism* Prefix (Exported Public API)

All public widgets, atoms, molecules, organisms, templates, and token surfaces
exported by `warp_prism_ui` for consumer apps use the `Prism` prefix
per `docs/design/naming.md` §4.1, **as realized by live typedef aliases**.

**Live public API (authoritative)**: Consumers import
`package:warp_prism_ui/warp_prism_ui.dart`, which exports only
`packages/warp_prism_ui/lib/src/prism_aliases.dart` (plus public gallery
surfaces). Token and type access is **per-class typedefs**, not a nested
`PrismTokens` namespace. There is **no** `PrismTokens` type, class, or export
in the package (verified: `rg PrismTokens packages/warp_prism_ui` → no matches).

| Layer | Public Convention | Live examples (`typedef` → DS*) |
|-------|-------------------|----------------------------------|
| **Tokens** | One `Prism*` typedef per token class | `PrismColors` → `DSColors`, `PrismSpacing` → `DSSpacing`, `PrismTypography` → `DSTypography`, `PrismRadii` → `DSRadii`, `PrismShadows` → `DSShadows`, `PrismMotion` → `DSMotion`, `PrismSemantics` → `DSSemantics`, `PrismBreakpoints` → `DSBreakpoints` |
| **Operational state** | `PrismOperationalState` (+ related enums / UI extension) | `PrismOperationalState` → `DSOperationalState`; `PrismOperationalSeverity`, `PrismOperationalCategory`; `PrismOperationalStateUI` extension |
| **Atoms** | `Prism` + noun | `PrismText`, `PrismBadge`, `PrismStatusDot`, `PrismChip`, `PrismGlassPanel`, … |
| **Molecules** | `Prism` + compound noun | `PrismAssetCard`, `PrismMetricTile`, `PrismTaskCard`, `PrismSearchBar`, … |
| **Organisms** | `Prism` + descriptive noun | `PrismShell`, `PrismSidebar`, `PrismGraphCanvas`, `PrismLaneBoard`, … |
| **Templates** | `Prism` + layout name | Prefer `Prism*` aliases when promoted; internal template types may still be DS-named until alias promotion |
| **Gallery** | `PrismGallery*` + page type | `PrismGallerySections`, `PrismGallerySectionSpec`, `DesignSystemGalleryPage` |
| **Theme extensions** | `PrismTheme` + qualifier (**planned, not live**) | Future: `PrismThemeColors`, `PrismThemeTypography` — **not** present in the barrel today |

**Consumer token access (live pattern)**:

```dart
import 'package:warp_prism_ui/warp_prism_ui.dart';

// Correct — static members on per-class public aliases:
final accent = PrismColors.accentCyan;
final gap = PrismSpacing.gapSection;
final title = PrismTypography.headingMedium;
final r = PrismRadii.card;
final glow = PrismShadows.glowCyan;
final d = PrismMotion.hoverDuration;
final bp = PrismBreakpoints.sidebarCollapse;
final color = PrismOperationalState.running.color; // via PrismOperationalStateUI
```

**Historical / superseded naming (do not document as live API)**:

| Superseded form | Why invalid | Use instead |
|-----------------|-------------|-------------|
| `PrismTokens.colors` / `PrismTokens.typography` / `PrismTokens.spacing` | No `PrismTokens` namespace exists in `warp_prism_ui` | `PrismColors`, `PrismTypography`, `PrismSpacing` |
| Early `docs/design/naming.md` §4.1 “PrismTokens namespace” rows | Pre-implementation target wording; live package uses per-class typedefs (Task 1301+ remediation) | This section + `prism_aliases.dart` |

If a nested `PrismTokens` facade is ever desired, it requires an **explicit
implementation task** that adds the type and barrel export. Policy MUST NOT
document that facade as current until the export exists.

#### The Boundary Rule

```
Consumer app import line:
  import 'package:warp_prism_ui/warp_prism_ui.dart';

What they get (examples — live barrel via prism_aliases.dart):
  PrismColors, PrismSpacing, PrismTypography, PrismRadii, PrismShadows,
  PrismMotion, PrismSemantics, PrismBreakpoints, PrismOperationalState,
  PrismText, PrismBadge, PrismShell, PrismSidebar, PrismGallerySections, ...

What they NEVER see (implementation layer under lib/src/):
  DSText, DSBadge, DSShell, DSColors, DSSemantics, DSGallerySections, ...

What they also NEVER see (nonexistent / not exported):
  PrismTokens, PrismTokens.colors, PrismTokens.typography
```

**Implementation**: The barrel (`packages/warp_prism_ui/lib/warp_prism_ui.dart`)
re-exports `Prism*` aliases from `src/prism_aliases.dart` and intentionally
hides `DS*` gallery implementation names. `DS*` classes remain under `src/` as
implementation detail. Consumer apps import only the barrel. A future lint rule
(not this task) may enforce `Prism*` usage at consumer call sites.

**When to create Prism* aliases**: When a component is promoted to the public
ADS layer (or when remediation tasks expand the alias surface). New public
types MUST add a `typedef PrismX = DSX` (or equivalent) in `prism_aliases.dart`
before claiming promotion.

---

## 3. ThemeExtension Ownership

### 3.1 Current State (Evidence)

The existing token classes (`DSColors`, `DSTypography`, etc.) are **static const
abstract classes**. They are not `ThemeExtension` objects. There is no
`Theme.of(context)` integration — all tokens are accessed via direct static
reference on the **public** aliases or internal DS names (e.g.,
`PrismColors.accentCyan` / `DSColors.accentCyan`).

Live sources:
- Implementation: `packages/warp_prism_ui/lib/src/tokens/ds_colors.dart` —
  `abstract class DSColors`
- Public aliases: `packages/warp_prism_ui/lib/src/prism_aliases.dart` —
  `typedef PrismColors = DSColors` (and siblings listed in §2.4)

### 3.2 ThemeExtension Policy

| Decision | Rationale |
|----------|-----------|
| **Defer ThemeExtension for MVP** | Current static-const approach works, is zero-cost, and matches the live package implementation. Introducing `ThemeExtension` now would require changing every component's token access pattern. |
| **Plan ThemeExtension for PrismThemeColors / PrismThemeTypography** | **Future only** — wrap the two most commonly overridden token groups (colors, typography) into `ThemeExtension<PrismThemeColors>` and `ThemeExtension<PrismThemeTypography>`. These types are **not** in the public barrel today. |
| **Who creates**: A future task creates the extensions inside `warp_prism_ui/lib/src/tokens/` and exports Prism-named surfaces via `prism_aliases.dart` / the barrel. | The extension classes live with the tokens, not with consumers. |
| **Who consumes**: Consumer apps provide the extension via `MaterialApp(theme: ThemeData(extensions: [PrismThemeColors(...)]))`. | Each app can override accent colors, status colors, or typography scale for its domain without forking the ADS. |
| **Default values**: Extensions MUST provide a `defaultPrism()` factory that returns the canonical obsidian-glass palette. | Consumer apps that don't override get the default ADS visual identity. |

### 3.3 ThemeExtension Checklist (Future Task)

When ThemeExtension is implemented, the task MUST:

1. Define `PrismThemeColors extends ThemeExtension<PrismThemeColors>` with all
   color token groups (obsidian, accent, status, governance, text, border, lane,
   asset-kind).
2. Define `PrismThemeTypography extends ThemeExtension<PrismThemeTypography>`
   with the 18-style type scale.
3. Provide `defaultPrism()` factory on each extension returning the current
   hardcoded values.
4. Provide context-aware accessors that read
   `Theme.of(context).extension<PrismThemeColors>()` /
   `Theme.of(context).extension<PrismThemeTypography>()` with fallback to the
   static defaults on `PrismColors` / `PrismTypography` (or documented
   extension helpers). Do **not** invent a `PrismTokens` namespace unless that
   type is explicitly implemented and barrel-exported in the same task.
5. Write widget tests that verify theme override propagation.
6. Update the catalog gallery to demonstrate theme override (light accent
   variant).

---

## 4. Component Promotion Gates

### 4.1 What Is a Promotion Gate?

A promotion gate is a set of concrete, measurable criteria that a component MUST
satisfy before it is exported from `warp_prism_ui` as a public `Prism*` API
surface. No component is promoted without evidence.

### 4.2 Gate Matrix by Atomic Layer

| Gate | Tokens | Atoms | Molecules | Organisms | Templates |
|------|--------|-------|-----------|-----------|-----------|
| **Catalog case** (gallery/story entry) | Required — color swatch, type sample, spacing bar, etc. | Required — each variant/state shown | Required — each variant/state shown | Required — key states shown | Required — responsive states shown |
| **State matrix** | N/A | Required if interactive | Required | Required | Required |
| **Widget test** | Contract test (instantiation, value correctness) | Required — each constructor/variant | Required — each variant, interaction, callback | Required — key interactions, layout | Required — responsive breakpoints |
| **Semantics test** | N/A | Required if interactive (focus traversal, label) | Required — screen reader labels, focus order | Required — keyboard nav, ARIA | Required — landmark structure |
| **Golden test** | Optional (color swatch render) | Required | Required | Required | Required |
| **Operational state coverage** | N/A | N/A | Required if state-aware | Required if state-aware | Required if state-aware |
| **Naming compliance** | DS* internal OK | Prism* alias required | Prism* alias required | Prism* alias required | Prism* alias required |
| **Dependency isolation** | No imports from apps/data | No imports from apps/data | No imports from apps/data | No imports from apps/data | No imports from apps/data |

### 4.3 Promotion Checklist Template

Every component promoted to `warp_prism_ui` public API MUST satisfy this
checklist. The promoting task includes the checklist as a subtask:

```markdown
## Component Promotion Checklist: [ComponentName]

- [ ] **Read existing code**: Component source, related tokens, consumers in apps/ read before modification.
- [ ] **Catalog case exists**: Component is demonstrated in `DesignSystemGalleryPage` / `DSGallerySections` / future catalog app with all meaningful variants and states.
- [ ] **State matrix documented**: All operational states the component supports are listed in the task or in this policy's §6. A table mapping states → visual treatment → behavior.
- [ ] **Widget test passes**: `flutter test` includes tests for the component covering:
  - Default rendering
  - Each named constructor / variant
  - Interactive callbacks (onTap, onChanged, etc.)
  - Edge cases (empty data, long text, disabled state)
- [ ] **Semantics test passes**: If the component is interactive:
  - `SemanticsTester` verifies labels for screen readers
  - Focus traversal order is correct
  - Enter/Space activation works for keyboard users
  - WCAG contrast ratios pass (≥4.5:1 for body text, ≥3:1 for large text/UI)
- [ ] **Golden test baseline captured**: `flutter test --update-goldens` produces baseline. Test file exists under `test/goldens/` or `test/<layer>/goldens/`.
- [ ] **Prism* public alias created**: `Prism[ComponentName]` exists in the barrel export and delegates to the DS* implementation.
- [ ] **Dependency isolation verified**: `rg` confirms zero imports from `lib/data/`, `lib/features/`, `lib/app/`, Riverpod, go_router, or any app-specific domain.
- [ ] **No new primitive tokens without justification**: Any new token added to DSColors/DSSpacing/etc. is documented in the task.
- [ ] **Changelog entry added**: Promotion is recorded in `docs/changelog/`.
```

### 4.4 Promotion Workflow

1. **Builder implements** component inside `warp_prism_ui/lib/src/<layer>/`.
2. **Builder adds catalog case** (gallery section or story).
3. **Builder writes tests** (widget, semantics, golden).
4. **Builder fills promotion checklist** in the task file.
5. **Reviewer verifies** checklist items against evidence.
6. **Reviewer promotes** component to `Prism*` public alias if all gates pass.
7. **Changelog** records the promotion.

If any gate fails, the component stays internal (`DS*` only) and the task is
returned to the builder with a specific failure note.

---

## 5. Catalog Policy

### 5.1 Decision: Custom Catalog App for MVP

| Decision | Rationale |
|----------|-----------|
| **Use custom catalog app** (not Widgetbook) for MVP | The existing `DesignSystemGalleryPage` + `DSGallerySections` already demonstrates all atomic design layers in a scrollable, testable layout. `warp_prism_ui` must remain dependency-free (only `flutter` SDK). Adding Widgetbook introduces external dependencies and code generation. |
| **Widgetbook deferred** | Revisit after the Melos migration is complete (Task 1107) and the expansion gate (Task 1111) proves the custom catalog is insufficient. |

Source evidence: Task 1104 §11.2 selected custom catalog MVP.

### 5.2 Custom Catalog Architecture

```
packages/warp_prism_ui/
├── lib/src/gallery/                    # Gallery pages (live with the ADS package)
│   ├── design_system_gallery_page.dart # Main gallery page — all layers
│   └── design_system_gallery_sections.dart # Section builders

apps/catalog/                           # Catalog app (thin shell)
├── lib/main.dart                       # MaterialApp → renders gallery page
├── pubspec.yaml                        # depends on warp_prism_ui via path:
└── test/                               # Smoke test: app builds, gallery renders
```

### 5.3 Catalog Case Requirements

A **catalog case** is a visual demonstration of a component in the gallery.
Every promoted component MUST have at least one catalog case.

| Layer | What a Catalog Case Shows | Minimum Cases |
|-------|---------------------------|---------------|
| **Tokens** | Color swatches, typography samples, spacing bars, radii shapes, shadow boxes, motion duration labels. | One section per token class (already exists: `buildTokensSection()`). |
| **Atoms** | Each constructor/variant rendered with meaningful data. Interactive atoms show hover/focus states. | One case per atom class (text variants, icon set, badge variants, chip states, status dots, dividers, glass panels). |
| **Molecules** | Each molecule in a representative state. Show edge cases (empty, long text, selected). | One case per molecule class. Task cards show proof states. Provenance pills show all 6 canonicality values. State surfaces show empty/loading/error. |
| **Organisms** | Key organism in a realistic but minimal layout. Sidebar shows navigation items. Lane board shows sample lanes. Timeline shows sample entries. | One case per organism class. Shell shown in collapsed mode. |
| **Templates** | Descriptive preview with responsive breakpoint documentation. | One case per template class. Full rendering deferred to app-level integration. |

### 5.4 Catalog Case Naming Convention

Each catalog case in `DSGallerySections` / `PrismGallerySections` is a static
method. **Live section builders** (refreshed 2026-07-09 from
`design_system_gallery_sections.dart`):

```
buildTokensSection()              → token catalog cases
buildAtomsSection()               → atom catalog cases
buildMoleculesSection()           → molecule catalog cases
buildOperationalStatesSection()   → 15-state vocabulary cases
buildOrganismsSection()           → organism catalog cases
buildDragAndDropSection()         → drag/drop cases
buildAccessibilitySection()       → accessibility catalog cases
buildToastsSection()              → toast cases
buildDataTableSection()           → data table cases
buildVirtualScrollSection()       → virtual scroll cases
buildHealthDashboardSection()     → health dashboard cases
buildTemplatesSection()           → template catalog cases
```

New components are added to the appropriate existing section. If a new category
is needed, a new section builder is added to `DSGallerySections` and a matching
`PrismGallerySections` alias remains available via the public barrel.

### 5.5 Gallery-to-Catalog Evolution

| Phase | What Exists | Where |
|-------|-------------|-------|
| **Historical (pre-Melos)** | Gallery lived under root `lib/design_system/gallery/` | Root app route `/design-system` (obsolete path) |
| **Current (post-package migration)** | `DesignSystemGalleryPage` + `DSGallerySections` / `PrismGallerySections` under `packages/warp_prism_ui/lib/src/gallery/` | `warp_prism_ui` package; consumer apps import via barrel |
| **Catalog app** | Thin shell (`apps/catalog/` or equivalent) imports gallery page from `warp_prism_ui` | Catalog host only — no component ownership |
| **Future expansion** | Catalog host adds search, category navigation, component isolation view, theme toggle | Catalog app `lib/` only |

The gallery pages are **always inside `warp_prism_ui`** (not owned by the catalog
app) so any consumer app can render the gallery as a route for development
validation.

### 5.6 Widgetbook Revisit Criteria

Revisit the Widgetbook decision when ANY of these are true:

1. The custom catalog exceeds 50 catalog cases and navigation becomes painful.
2. Knobs (interactive parameter controls) are needed for testing component
   variants that are hard to demonstrate statically.
3. Device-frame previews are needed (unlikely for desktop-first).
4. Multiple developers need to contribute catalog cases concurrently and the
   static section builder pattern creates merge conflicts.

If any criterion is met, create a planning task to evaluate Widgetbook adoption
in `apps/catalog/` only (never in `warp_prism_ui`).

---

## 6. Golden Test Policy

### 6.1 When Golden Tests Are Required

| Layer | Golden Required | Rationale |
|-------|----------------|-----------|
| **Tokens** | Optional | Tokens are const values; contract tests suffice. Golden tests for color swatch render are optional. |
| **Atoms** | **Required** | Visual regression for atoms is high value, low cost. Each atom has a small, stable visual surface. |
| **Molecules** | **Required** | Molecules compose atoms; golden tests catch layout regressions early. |
| **Organisms** | **Required** | Organisms are complex layouts. Golden tests catch responsive breakpoint regressions. |
| **Templates** | **Required** | Templates compose organisms. Golden tests at each breakpoint threshold. |

### 6.2 Golden Test File Location

```
packages/warp_prism_ui/test/
├── goldens/                     # Top-level golden directory
│   ├── atoms/                   # One file per atom
│   │   ├── prism_text_golden_test.dart
│   │   ├── prism_badge_golden_test.dart
│   │   └── ...
│   ├── molecules/               # One file per molecule
│   │   ├── prism_asset_card_golden_test.dart
│   │   └── ...
│   ├── organisms/               # One file per organism
│   └── templates/               # One file per template
```

Alternative: golden tests may live alongside widget tests in the same directory
structure (e.g., `test/atoms/prism_text_test.dart` includes both widget and
golden tests). Choose one convention and apply consistently.

### 6.3 Golden Test Conventions

> **Interim Golden-Freeze Policy (Task 1800 / Task 1801)**: No golden regeneration during palette migration. Visual golden test failures resulting from token palette migration are recognized as expected intermediate drift until Task 1805 human visual acceptance gate.

1. **Test file naming**: `<component_snake>_golden_test.dart`.
2. **Golden file naming**: `goldens/<layer>/<component>_<variant>_<state>.png`.
3. **Test body**: `await tester.pumpWidget(MaterialApp(home: Scaffold(body: PrismXxx(...)))); await expectLater(find.byType(PrismXxx), matchesGoldenFile(...));`
4. **Update command**: `flutter test --update-goldens` (run in `packages/warp_prism_ui/`).
5. **CI enforcement**: Golden tests MUST pass in CI. If a visual change is intentional, the builder updates the golden in the same PR.
6. **Theme override**: Golden tests use the default obsidian-glass static token
   palette (`PrismColors` / related aliases). Theme-override goldens are
   optional until `PrismTheme*` extensions exist (§3); if added, they live in a
   `goldens/themed/` subdirectory.

### 6.4 Golden Test Maintenance

| Situation | Action |
|-----------|--------|
| Intentional visual change | Update golden in the same PR. Describe change in PR description. |
| Unintentional golden failure | Block PR. Investigate and fix the regression before merging. |
| Platform-specific rendering difference | Use `skip` with platform annotation. Document the platform delta. |
| Golden file too large (>500KB) | Restructure test to render a smaller surface or use `repaintBoundary`. |

---

## 7. Semantics Test Policy

### 7.1 When Semantics Tests Are Required

| Layer | Semantics Required | What to Test |
|-------|--------------------|--------------|
| **Tokens** | N/A | Tokens have no UI surface. |
| **Atoms** | **Required if interactive** | `DSChip` (focus, Enter/Space), `DSIcon` (semantic label if standalone). `DSText`, `DSBadge`, `DSDivider`, `DSGlassPanel` — pass-through semantics, no dedicated test needed unless they carry semantic labels. |
| **Molecules** | **Required** | `DSSearchBar` (label, focus), `DSFilterChipGroup` (group label, individual chip labels, selected state announcement), `DSAssetCard` (card label, kind, description), `DSTaskCard` (task label, lane, priority, proof state), `DSMetricTile` (label + value pair), `DSProvenancePill` (canonicality label), `DSEvidenceRow` (evidence state label). |
| **Organisms** | **Required** | `DSSidebar` (navigation landmark, item labels, selected state, arrow key navigation), `DSTopbar` (toolbar landmark, breadcrumb labels, action button labels), `DSLaneBoard` (lane labels, task count), `DSTimeline` (list landmark, entry labels), `DSDetailInspector` (dialog landmark, close button, section headings), `DSGraphCanvas` (accessible description of graph state). |
| **Templates** | **Required** | Landmark structure (navigation, main, complementary). Responsive breakpoint behavior announced to screen readers. |

### 7.2 Semantics Test File Location

```
packages/warp_prism_ui/test/
├── accessibility/                # Existing directory (from Task 0018)
│   ├── focus_traversal_test.dart
│   ├── contrast_test.dart
│   └── ...
├── atoms/
│   └── ds_chip_semantics_test.dart
├── molecules/
│   └── ds_task_card_semantics_test.dart
└── organisms/
    └── ds_sidebar_semantics_test.dart
```

Semantics tests may be in the same file as widget tests or in a dedicated
`*_semantics_test.dart` file. Choose one convention and apply consistently.

### 7.3 Semantics Test Checklist

For each interactive component, the semantics test MUST verify:

1. **Screen reader label**: `SemanticsTester` finds a `Semantics` node with the
   expected `label` for the component or its interactive children.
2. **Role/trait**: Correct `SemanticsRole` or Flutter semantics trait (button,
   link, text field, etc.).
3. **State announcement**: State changes (selected, expanded, disabled) are
   announced via `Semantics.propertiesChanged` or equivalent.
4. **Focus traversal**: `FocusTraversalGroup` order matches visual order.
   `FocusNode` receives focus when `tester.sendKeyEvent(LogicalKeyboardKey.tab)`
   is pressed.
5. **Keyboard activation**: `Enter` and `Space` trigger `onTap` for interactive
   elements.
6. **Contrast**: Text colors against background meet WCAG AA (≥4.5:1 for body,
   ≥3:1 for large text/UI components). Existing
   `packages/warp_prism_ui/test/accessibility/` provides the baseline.

### 7.4 WCAG Contrast Requirements

| Element | Minimum Ratio | Standard | Verification |
|---------|--------------|----------|--------------|
| Body text (≤24px, non-bold) | 4.5:1 | WCAG AA | `contrast_test.dart` |
| Large text (≥24px or ≥18.67px bold) | 3:1 | WCAG AA | `contrast_test.dart` |
| UI components (borders, icons) | 3:1 | WCAG AA | Manual or future automated |
| Focus indicator | Visible on obsidian background | Project convention | Focus ring: 2px `accentBlue` (#2F81FF) at 50% opacity (superseded per Task 1800 / Task 1801) |

---

## 8. State Matrix Requirements

### 8.1 The 15-State Operational Vocabulary

Every component that represents or displays workspace entity state MUST document
which of the 15 operational states (from `docs/design/operational-state-vocabulary.md`)
it supports.

The 15 states are organized into four categories:

| Category | States |
|----------|--------|
| **Lifecycle** (6) | `pending`, `running`, `approved`, `rejected`, `promoted`, `archived` |
| **Health** (4) | `healthy`, `degraded`, `error`, `disabled` |
| **Verification** (3) | `unverified`, `exposed`, `redacted` |
| **Governance** (2) | `stale`, `excluded` |

### 8.2 State Matrix Template

Each state-aware component MUST include a state matrix in its implementation
file doc comment or in the promoting task. Format:

```markdown
## [ComponentName] State Matrix

| State | Visual Treatment | Icon | Color | Behavior | Screen Reader Label |
|-------|-----------------|------|-------|----------|---------------------|
| pending | Muted border, neutral dot | schedule | textTertiary | No action | "Pending: awaiting start" |
| running | Gold animated dot, gold border | trending_up | accentGold | Pulse animation | "Running: in progress" |
| ... | ... | ... | ... | ... | ... |
```

### 8.3 Which Components Need State Matrices

| Component | States Required | Notes |
|-----------|----------------|-------|
| `DSStatusDot` | All 15 | Already has 5 variants (success/warning/error/info/neutral). Needs expansion per Task 1102 §7.4. |
| `DSTaskCard` | Lifecycle (6) + Health (3) + Verification (3) + Governance (2) = 14 (not `disabled`) | Task is the primary state carrier. Currently has proof state (4 values) and priority (3 values). |
| `DSAssetCard` | Health (4) + Governance (2) = 6 | Asset health and staleness. |
| `DSMetricTile` | Health (4) = 4 | Metric health (healthy/degraded/error/disabled). |
| `DSStateSurface` | Currently 3 (empty/loading/error). Needs expansion to include `disabled`, `stale`, `excluded` | Per Task 1102 §5.1, this is the primary state surface container. |
| `DSLaneBoard` | Implicit from task cards | No direct state — composes task cards. |
| `DSStoryPanel` | Risk levels (5): none/low/medium/high/critical | Maps to health states. |
| `DSProvenancePill` | Canonicality (6): parentCanonical/childLocal/generated/appendOnly/archive/mock | Orthogonal to operational states. Already complete. |
| `DSEvidenceRow` | Verification (3): verified/partial/missing + pending | Already complete for evidence display. |

### 8.4 State Composition Rule

A single entity can carry **multiple state fields simultaneously** (per
Task 1102 §4). The state matrix MUST document which state category applies:

- A task can be `running` (lifecycle) AND `degraded` (health) AND `exposed`
  (verification) AND `stale` (governance) simultaneously.
- Components that display multi-category state MUST show each category's visual
  treatment independently (e.g., a task card shows lane color + health dot +
  proof indicator + stale warning).

---

## 9. Widget Test Policy

### 9.1 Minimum Widget Test Coverage

| Layer | Required Test Cases |
|-------|---------------------|
| **Tokens** | Instantiation test (const values accessible), value range tests (colors are valid, spacing is non-negative, radii are non-negative), barrel export coherence. Source: `packages/warp_prism_ui/test/tokens/ds_token_contract_test.dart` (Task 0014 lineage). |
| **Atoms** | Default render, each named constructor, disabled state, focus behavior (if interactive), callback invocation. |
| **Molecules** | Default render, each variant, empty/long-text edge cases, callback invocation, keyboard interaction (if interactive). |
| **Organisms** | Default render, responsive breakpoint behavior, keyboard navigation (if interactive), empty state handling. |
| **Templates** | Render at each breakpoint, responsive layout transitions, filter integration. |

### 9.2 Test File Location

Tests mirror the source structure under `packages/warp_prism_ui/test/`:

```
test/
├── tokens/          # Token contract tests
├── atoms/           # Atom widget tests
├── molecules/       # Molecule widget tests
├── organisms/       # Organism widget tests
├── templates/       # Template widget tests
├── gallery/         # Gallery render tests
├── accessibility/   # Focus traversal, contrast, semantics
└── goldens/         # Golden image tests
```

### 9.3 Test Naming Convention

```dart
group('PrismText', () {
  testWidgets('renders displayLarge variant', (tester) async { ... });
  testWidgets('applies custom color override', (tester) async { ... });
  testWidgets('renders with default sans font family', (tester) async { ... });
});
```

---

## 10. ADS Upgrade Loop

### 10.1 Problem

Consumer apps (`warp_prism_observatory`, `warp_prism_cybercore`) will discover
bugs in ADS components or need new components that don't exist yet. Without a
governed loop, fixes will be applied locally in the app, creating ADS drift.

### 10.2 Upgrade Loop Policy

| Step | Actor | Action |
|------|-------|--------|
| **Discovery** | App developer | Identifies a bug in `warp_prism_ui` or a missing component. Creates a task in `.project/tasks/00-planning/` describing the issue with reproduction steps and the affected consumer app. |
| **Triage** | Task Architect | Classifies as **bug fix** (existing component broken) or **new component** (missing ADS surface). Assigns to `warp_prism_ui` task range. |
| **Fix/Create** | Builder | Fixes the bug or creates the new component inside `warp_prism_ui`. Applies all promotion gates (catalog case, tests, semantics, state matrix). |
| **Cross-app validation** | CI | `melos run validate` ensures the fix doesn't break other consumers. |
| **Changelog** | Builder | Adds `docs/changelog/` entry documenting the ADS change and which consumer app triggered it. |

### 10.3 Anti-Pattern: Local ADS Hacks

**Prohibited**: A consumer app MUST NOT:

1. Duplicate an ADS component inside its own `lib/` to fix a bug.
2. Monkey-patch or extend an ADS class to add missing features.
3. Import `warp_prism_ui` internal (`src/`) files directly.
4. Skip the promotion checklist for "quick fixes."

**Required**: If a fix is urgent, the app developer applies a **temporary
workaround** (e.g., wrapping the component) and immediately creates a planning
task for the proper ADS fix. The workaround MUST include a `// TODO(Task NNNN):`
comment linking to the ADS upgrade task.

---

## 11. Widgetbook Decision Record

### 11.1 Decision

**Custom catalog app for MVP. Widgetbook deferred.**

### 11.2 Rationale

1. The existing `DesignSystemGalleryPage` + `DSGallerySections` /
   `PrismGallerySections` (Task 0017 lineage; live under
   `packages/warp_prism_ui/lib/src/gallery/`) already demonstrates tokens, atoms,
   molecules, organisms, templates, operational states, and expanded surfaces
   (toasts, data table, virtual scroll, health, drag/drop, accessibility) in a
   functional, testable gallery. Exact component counts grow over time; the
   **promotion gates** in §4 are the stable contract, not a fixed count.
2. `warp_prism_ui` MUST remain dependency-free (only `flutter` SDK). Widgetbook
   introduces `widgetbook` and `widgetbook_annotation` as dependencies plus code
   generation.
3. The custom catalog uses `flutter_test` + golden tests for visual regression,
   which remains sufficient until §5.6 revisit criteria are met.
4. Widgetbook can be introduced in `apps/catalog/` (not in `warp_prism_ui`)
   without restructuring when the revisit criteria (§5.6) are met.

### 11.3 Revisit Criteria

See §5.6 above.

### 11.4 Future Widgetbook Path

If Widgetbook is adopted:

- Add `widgetbook` to `apps/catalog/pubspec.yaml` only.
- Create stories in `apps/catalog/lib/stories/` importing from `warp_prism_ui`.
- The custom gallery page inside `warp_prism_ui` remains as a dependency-free
  fallback.
- No changes to `warp_prism_ui` package structure.

---

## 12. Source Evidence

| Source | Relevance |
|--------|-----------|
| `docs/design/charter.md` (Task 1101) | Project scope, non-goals, first proof target (ADS Gallery). |
| `docs/design/naming.md` (Task 1101) | Prism* prefix policy, DS* legacy classification, Voidframe supersession. |
| `docs/design/operational-state-vocabulary.md` (Task 1102 **source doc**; task lane may lag) | 15 operational states, color/icon/behavioral contracts, state transition diagrams, composite state matrix. Live code: `PrismOperationalState` + `PrismColors.status*`. |
| `docs/design/component-catalog.md` | Current human-readable inventory of shared ADS widgets, reconciled against live source, barrels, aliases, and gallery registration. |
| `docs/design/component-inventory.md` (Task 1102 source doc) | Historical CyberCore control-surface inventory; not the current Warp Prism ADS component catalog. |
| `.project/architecture/warp-prism-melos-monorepo-architecture.md` (Task 1104 artifact; task in `03-review/`) | Melos monorepo decision, package boundaries, path dependency policy, Widgetbook vs custom catalog decision (§11), migration sequence. |
| `packages/warp_prism_ui/lib/src/tokens/` | Live token implementation: `DSColors`, `DSTypography`, `DSSpacing`, `DSRadii`, `DSShadows`, `DSMotion`, `DSSemantics`, `DSBreakpoints`, `DSOperationalState` (historical root `lib/design_system/tokens/` path is obsolete post-Melos). |
| `packages/warp_prism_ui/lib/src/prism_aliases.dart` | Live public `Prism*` typedef surface (token + component aliases). **No `PrismTokens`.** |
| `packages/warp_prism_ui/lib/warp_prism_ui.dart` | Public barrel: exports `prism_aliases.dart` + gallery pages; hides `DS*` gallery implementation names. |
| `packages/warp_prism_ui/lib/src/gallery/` | Live gallery: `DesignSystemGalleryPage`, `DSGallerySections` / `PrismGallerySections`, registry. Proof surface for atomic layers. |
| `packages/warp_prism_ui/test/` | Live package tests: tokens, atoms, molecules, organisms, gallery, accessibility, goldens, boundaries. |
| Task 0014 (completed) | Token contract and inventory — canonical naming, Theme bridge gap identified. |
| Task 0017 (completed) | Gallery route bootstrap — proves the DS gallery exists and renders. |
| Task 0018 (completed) | Accessibility focus baseline — focus rings, keyboard activation, WCAG contrast rules for DSChip, DSFilterChipGroup, DSSidebar, DSTopbarAction, DSSearchBar, DSAssetCard. Source for §7.4 contrast requirements. |
| `.project/tasks/00-planning/1100-...epic.md` | Requires catalog case + widget test + semantics test + CyberCore mapping for promotion. |

---

## 13. Appendix: Quick Reference Checklists

### A. New Component Checklist

- [ ] Component lives in correct `warp_prism_ui/lib/src/<layer>/` directory.
- [ ] Uses only semantic tokens (no raw hex/px values).
- [ ] Documented with doc comment including state matrix (if state-aware).
- [ ] Catalog case added to `DSGallerySections` (or future catalog stories).
- [ ] Widget test covers default render + variants + edge cases.
- [ ] Semantics test covers labels + focus + keyboard activation (if interactive).
- [ ] Golden test baseline captured.
- [ ] Prism* public alias created in barrel export.
- [ ] Zero imports from apps, Riverpod, go_router, or data layer.
- [ ] Changelog entry added.

### B. ADS Bug Fix Checklist

- [ ] Bug reproduced in `warp_prism_ui` test (not just in the consumer app).
- [ ] Fix applied in `warp_prism_ui`, not locally in the consumer app.
- [ ] Existing tests still pass.
- [ ] New regression test added for the bug.
- [ ] Golden updated if visual output changed.
- [ ] `melos run validate` passes (all consumers unbroken).
- [ ] Changelog entry added referencing the consumer app that discovered the bug.

### C. Catalog Case Checklist

- [ ] Component rendered in gallery section with meaningful data.
- [ ] All named constructors / variants demonstrated.
- [ ] Key interactive states shown (hover, focus, selected, disabled).
- [ ] Edge cases shown (empty data, long text) where applicable.
- [ ] Operational states shown (if component is state-aware).
- [ ] Section builds independently via `DSGallerySections.build<X>Section()`.
