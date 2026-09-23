---
name: ui-ux
parent: flutter
description: Build and audit adaptive, accessible, localized, token-driven Flutter UI, design-system components, and visual evidence.
---

# Flutter UI, UX, Accessibility, and Design Systems

Use this route for widgets, layouts, design-system components, visual consistency, adaptive desktop/mobile UI, accessibility, localization, and Figma/design-to-code work.

## UI Axioms

- **Constraints drive layout**: reason from parent constraints; fix overflow at the layout contract, not by hiding symptoms.
- **Token domain×role classifies dynamics**: when theme tokens change at runtime, each dynamic entry declares one physical domain (color, shape, spacing, …) and one primary role from that domain's declared set (color: structural/interactive/semantic/data). Contract and annotation spec: `references/token-role-annotation.spec.yaml` in this subskill; verification matrix: `workflows/ss-atomic-theme-theme-role-verification.md`. Flutter-side role failures route to the theme-propagation path in remediation, not a second theme doctrine here.
- **Atomic boundaries matter**: atoms/molecules/organisms/templates/pages should have clear composition direction and naming conventions.
- **Accessibility is not optional**: keyboard navigation, focus order, semantics labels, contrast, reduced motion, text scaling, and screen-reader affordances are part of the component contract.
- **Localization is part of UI correctness**: user-facing strings should flow through the project’s l10n system, not inline literals.
- **Desktop-first still needs responsive behavior**: pointer, keyboard, large-screen density, resizable windows, and scroll behavior must be intentional.

## Checklist

- [ ] Layout works for compact/medium/expanded or project-defined breakpoints.
- [ ] Components use tokens and theme APIs rather than raw literals.
- [ ] Focus, hover, pressed, disabled, selected, error, and loading states are defined where relevant.
- [ ] Semantics labels/roles make sense for non-text controls and custom canvases.
- [ ] Text scale and high-contrast modes do not break the layout.
- [ ] Motion is subtle and respects reduced-motion requirements for high-risk surfaces.
- [ ] Visual changes have widget/golden/story/gallery evidence when the project supports it.

## Common Anti-Patterns

- Private `_buildX()` helper forests for meaningful UI components.
- Raw colors/sizes sprinkled through screens.
- Icon-only buttons without semantic labels.
- Canvas/graph widgets without keyboard or accessible alternate representation.
- Golden tests that depend on current time, random data, network, or fonts not pinned by the test harness.

## Concrete UI Rules (from reference corpus)

### Widget Extraction
- Extract widgets to **public** classes. No `_buildXxx()` helpers. No private widget classes (`class _Foo extends StatelessWidget`).
- Mark file-internal widgets `@visibleForTesting`.
- `_FooState extends State<Foo>` stays private (Flutter convention — exempt).

### Localization
- Use `AppLocalizations` (gen-l10n) for every user-facing string. Never hardcode UI copy.
- In widgets: `final l10n = context.l10n;` at top of `build`, then use `l10n.someKey`. Never chain `context.l10n.someKey`.
- `*Strings` constants only for non-user-facing IDs.

### Extensions and Utilities
- Primitives → `core/extensions/`. Never inline. DateTime/String/int/double/Duration/Iterable/BuildContext ops in `core/extensions/{type}_extensions.dart`, barrel `extensions.dart`.
- 2+ uses → extension. Domain entities NEVER import `core/extensions/`.

### Adaptive Layout
- 3-step approach: Abstract → Measure → Branch.
- Breakpoints: Compact (<600), Medium (600-840), Expanded (≥840).
- Capability/Policy pattern for platform-specific behavior.

### Reference corpus paths

- `references/building-flutter-apps/references/atomic-design.md` — atomic design hierarchy.
- `references/building-flutter-apps/references/extensions-utilities.md` — extension SSOT patterns.
- `references/building-flutter-apps/references/localization.md` — gen-l10n patterns.
- `references/building-flutter-apps/references/layout-diagnostics.md` — RenderFlex overflow, Expanded/Flexible/Positioned misuse.
- `references/mad-agents-skills/flutter-adaptive-ui/` — adaptive UI with Capability/Policy pattern and responsive navigation.
- `references/mad-agents-skills/flutter-internationalization/assets/app_en.arb` — complete ARB template.
- `references/RobertAlvv-flutter-skills/atomic-design-system-auditor/` — atomic design hierarchy audit.

## Atomic Design-System Governance

Merged from the `frontend-quality` atomic cluster (`atomic-classify-component`,
`atomic-token`, `atomic-theme`, `atomic-accessibility`, `atomic-migrate`,
`design-craft`) on 2026-09-23 and adapted to Flutter per operator authorization.
`frontend-quality` remains the web/TS owner (React/Next, WCAG product audits,
Storybook); this section is the Flutter-side doctrine. When `frontend-quality`
is retired, this section is already the surviving owner — do not re-fork it.

Rejected for this merge (recorded, not silently dropped): `atomic-storybook`
(no Storybook/Widgetbook by project policy — custom catalog instead),
`web-performance-audit` (Core Web Vitals / React / Lighthouse — web-only;
Flutter performance lives in `../performance/`), `frontend-accessibility`
(full web WCAG product audit; Flutter a11y gates live below),
`project-specifics` (project-local findings, not harness doctrine).

### Classify Before Implementing

For any component that might enter the shared design system, classify as
atom, molecule, organism, template, or page, and name props, states, slots,
accessibility requirements, tokens used, and examples. Product-specific or
unproven components stay reference-only — never promoted on aesthetics.

Warp Prism mapping: public surface uses the `Prism*` prefix
(`PrismText` atom, `PrismAssetCard` molecule, `PrismShell` organism);
`DS*`/`Ds*` is internal implementation detail.

### Token Domain × Role Contract

Every dynamic token entry — semantic alias or component token resolved at
runtime (`ThemeExtension` fields, `ThemeData.colorScheme` overrides) — MUST
declare exactly one primary `domain` (physical dimension: color, shape,
spacing, typography, elevation, motion, layout, …) and one primary `role`
from that domain's declared set. The four-role taxonomy
(structural / interactive / semantic / data) is the COLOR-domain role set —
not a universal enum. Other domains define their own evidence-justified sets.

1. One primary domain + one primary role per dynamic entry. Secondary roles
   only with recorded mechanical justification (e.g. a focus-ring color that
   also signals enabled state); unjustified secondaries are coupling debt.
2. Tier ≠ domain ≠ role: tier says what a token IS; domain says what
   dimension it expresses; role says how it is used. Never collapse the axes.
3. `interactive`-role color must not drive layout (width/height/padding/
   constraints); `structural`-role color must not encode state — split the
   token instead of overloading the role.
4. Changes to layout-domain entries (layout, spacing, elevation, shape) or
   `structural` color-role entries require real-host-composition smoke
   evidence before acceptance; goldens alone are insufficient.

Annotation spec: `references/token-role-annotation.spec.yaml`.
Verification matrix: `workflows/ss-atomic-theme-theme-role-verification.md`.

### Theme Architecture (Dark-First)

Define dark-first defaults with explicit light parity: `ThemeData` +
`ThemeExtension` schema, `ThemeMode` switching, system
`MediaQuery.platformBrightness` behavior, persistence of the user choice, and
per-mode a11y checks (contrast, focus visibility). Runtime theme APIs stay
provisional until a design-system prototype accepts them. When theme tokens
or theme APIs change, run the verification-matrix workflow above over
touched entries + direct consumers.

### Design Craft (Polish Heuristics)

Pick a clear visual direction before writing widgets. Preserve the existing
design system when one exists — craft never overrides consistency.
Typography must communicate hierarchy; do not default to generic stacks
unless the surrounding app already does. Use color, spacing, elevation,
texture, and layout rhythm intentionally. Motion must carry meaning: reveal
hierarchy, show causality, preserve spatial continuity — no generic
animation noise; honor `MediaQuery.disableAnimations` on high-risk surfaces.

- Radii should be concentric: nested corners need smaller radii than containers.
- Align optically, not just mathematically; baselines and controls often need
  visual correction.
- Hit targets must be easy to acquire (`SizedBox`/`Padding` around small
  visuals; minimum 48×48 touch target).
- Elevation should model surfaces — prefer subtle layered elevation over one
  harsh shadow.
- Hover/press/focus states must be interruptible and reversible; no animation
  that fights rapid input.
- Empty, loading, error, and success states deserve the same design quality
  as the happy path.

Output standard when reviewing or improving UI:

```text
surface -> issue -> user perception -> concrete change
```

### Harvest Migration

When moving UI assets from donor references (e.g. `references/*` donor repos)
or incumbent implementations into the shared design system: harvest contracts
first (component layer, tokens, themes, props, states, accessibility,
screenshots), then migrate in small slices with rollback and package
boundaries. Reimplementation in idiomatic Flutter/Dart — never a port of the
donor's framework code (no TSX/Tamagui/RNW in the target tree).
