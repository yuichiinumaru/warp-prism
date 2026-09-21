# Task 1100: Warp Prism Operational Atomic Design System Epic

> **Priority**: 🔴 P0
> **Type**: `planning` | `design-system` | `flutter` | `architecture`
> **Origin**: User request to create Warp Prism as new Ganthritor child project for Flutter atomic design system with Storybook/Widgetbook-style catalog
> **Blocks**: Warp Prism scaffold, Cybernetics Core frontend redesign, shared operational UI grammar
> **Depends on**: N/A (parent references removed — warp-prism local namespace)

---

## Objective

Plan Warp Prism as the canonical Ganthritor-family operational atomic design system: a Flutter child project under `warp-prism/` with a reusable UI package, catalog app, golden/widget/semantics tests, and evidence-backed components for Cybernetics Core first.

## Background Context

### O que já existe:
- `warp-prism/` exists and is empty.
- Task 8210 defines the required control-surface inventory gate.
- Task 8220 defines a prior `Voidframe` Flutter ADS kernel idea.
- Task 8230 defines a Cybernetics Core pilot concept.
- Task 8240 defines Ivisa/Tamagui archaeology as reference-only.
- Completed Task 0583 and Task 0590 document and implement Cybernetics Core's current admin design-system baseline.

### O que está faltando / quebrado:
- The active project name `Warp Prism` is not represented in task planning.
- The prior `Voidframe` package/app names are stale.
- There is no child-project scaffold, local documentation structure, or catalog policy.
- There is no explicit Storybook/Widgetbook-equivalent validation plan.

---

## RF8 Plan

1. **Goal**: build a testable operational UI grammar, not merely a pretty Flutter app.
2. **Domain**: tokens, atoms, molecules, operational components, evidence components, product dialects.
3. **Feature**: charter, inventory, scaffold, tokens, atoms, operational components, catalog, CyberCore pilot, expansion gate.
4. **Representation**: `warp-prism/docs/design/`, package docs, catalog app, state matrices.
5. **Specs**: token specs, component API specs, operational state enums, catalog/golden policies.
6. **Behaviour**: default, disabled, loading, error, degraded, redacted, exposed, narrow, long text, high text scale, reduced motion.
7. **Test**: `dart format`, `flutter analyze`, `flutter test`, golden tests, semantics tests, catalog smoke.
8. **Eval**: no component promoted without catalog case, widget test, semantics coverage, and a real CyberCore mapping.

## Proposed Story Breakdown

- WP-S1: Naming and charter convergence.
- WP-S2: Cybernetics Core control-surface inventory.
- WP-S3: Melos monorepo architecture and Flutter tooling scaffold.
- WP-S4: Token, ThemeExtension, catalog, golden, and semantics policy.
- WP-S5: Atomic and operational component MVP.
- WP-S6: Catalog and accessibility discipline.
- WP-S7: CyberCore frontend scope, route parity, and API contract inventory.
- WP-S8: CyberCore fixture-backed app shell and pilot mirror.
- WP-S9: Ivisa/reference archaeology translation.
- WP-S10: Expansion gate for Ganthritor, Khala, Hyperion, and future frontend apps.

## Candidate Open Tasks

- Task 1101: Warp Prism charter and naming convergence.
- Task 1102: Warp Prism control-surface inventory.
- Task 1103: Warp Prism Flutter tooling and scaffold.
- Task 1104: Warp Prism Melos monorepo architecture plan.
- Task 1105: Warp Prism token/theme/catalog policy.
- Task 1106: Warp Prism operational component MVP.
- Task 1107: Warp Prism Melos monorepo migration.
- Task 1108: Warp Prism CyberCore frontend scope and route parity matrix.
- Task 1109: Warp Prism CyberCore API/data contract inventory.
- Task 1110: Warp Prism CyberCore fixture-backed app shell MVP.
- Task 1111: Warp Prism CyberCore pilot mirror and expansion gate.

## Guardrails

> [!CAUTION]
> Do not copy TSX/Tamagui/Ivisa implementation code into Flutter. Harvest component stories, variants, and state matrices only.

> [!CAUTION]
> Do not migrate Cybernetics Core to Flutter as part of the ADS scaffold. The first proof is catalog and pilot mirror evidence.

> [!IMPORTANT]
> `Voidframe` is historical naming. New package and app names should use `warp_prism_ui`, `warp_prism_catalog`, and public `Prism*` components.

## Validation / Promotion Criteria

- The epic has successor tasks in `01-open` with ≥50 lines and exact validation commands.
- `warp-prism/` remains untouched until a scaffold task verifies Flutter/Dart availability.
- Catalog policy defines whether Widgetbook is used immediately or a simple catalog app satisfies MVP.
- Accessibility and performance guardrails are explicit before glass/blur/motion work.
