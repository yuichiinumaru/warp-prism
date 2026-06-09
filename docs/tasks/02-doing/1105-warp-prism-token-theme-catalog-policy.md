# Task 1105: Warp Prism Token Theme Catalog Policy

> **Status**: `[x]` Done — awaiting review
> **Priority**: 🔴 P0
> **Type**: `architecture` | `design-system`
> **Origin**: Task 1100 candidate Task 1104 plus user requirement for reusable ADS with Storybook/Widgetbook-style catalog.
> **Blocks**: Task 1106, Task 1107, Task 1111
> **Depends on**: Task 1104

> [!IMPORTANT]
> Task identity is lane-neutral. Use `Task 1105` plus optional slug for dependencies, blockers, review ledgers, reports, and architecture references.

---

## Objective

Define the token, ThemeExtension, catalog, golden-test, semantics-test, and component-promotion policy for `warp_prism_ui`. This task turns the existing in-app Design System Gallery into a reusable ADS governance contract so components can be promoted only when they have catalog cases, state matrices, tests, and accessibility evidence.

## Background Context

### What already exists

- Tasks 0014–0018 created/normalized design tokens, atoms/molecules/organisms/templates, gallery route, and accessibility focus baseline in the current root app.
- Task 1100 requires a Storybook/Widgetbook-style catalog and no component promotion without catalog case, widget test, semantics coverage, and CyberCore mapping.
- Task 1104 should define the monorepo architecture and `packages/warp_prism_ui` / `apps/catalog` boundaries.

### What is missing or broken

- No reusable package-level component promotion policy exists.
- No catalog policy defines whether Widgetbook is immediate, deferred, or replaced by a custom catalog MVP.
- No golden/semantics baseline policy exists for `warp_prism_ui` as a package.
- Existing gallery proof is useful but app-local; it does not yet define a reusable package contract.

---

## Test Requirements

- The policy MUST define token categories, ThemeExtension ownership, naming conventions, component layers, and state matrix requirements.
- The policy MUST decide Widgetbook vs custom catalog MVP and document why.
- The policy MUST define what counts as a catalog case/story for tokens, atoms, molecules, organisms, and templates.
- The policy MUST define golden-test and semantics-test gates per component layer.
- The policy MUST define a promotion checklist for new reusable components discovered while building new frontends.
- No broad Flutter code migration may happen in this task.

---

## Exit Conditions

- [x] `docs/design/token-theme-catalog-policy.md` exists.
- [x] The policy includes a Widgetbook/custom catalog decision. (§5.1 + §11)
- [x] The policy includes component promotion gates: catalog case, state matrix, widget test, semantics test, and consumer mapping. (§4)
- [x] The policy defines how ADS bugs discovered in apps become ADS upgrade tasks. (§10)
- [x] The policy includes a Public API Naming Boundary section defining DS* (internal/legacy) vs Prism* (exported public API). (§2.4)
- [x] Existing DS gallery tasks 0014–0018 are cited as current evidence. (§12 + §5.4)
- [x] Local changelog entry added under `docs/changelog/`.
- [x] Completion Evidence is filled before review handoff.

---

## Details

### What

Subtasks:

- [x] **Read existing code before modifying**: read Tasks 0014, 0017 (token contract + gallery evidence), Task 1104 output (Melos architecture), current `lib/design_system/tokens/` (8 files), `lib/design_system/gallery/` (2 files), `test/design_system/` structure, `docs/design/charter.md`, `docs/design/naming.md`, `docs/design/operational-state-vocabulary.md`, `docs/design/component-inventory.md`.
- [x] Inventory current token/component proof and map it to package-level promotion gates. (§2.2 token inventory, §4.2 gate matrix)
- [x] Decide Widgetbook immediate/deferred/custom catalog MVP. (§5.1 + §11: custom catalog MVP, Widgetbook deferred with revisit criteria)
- [x] Define golden-test, semantics-test, and widget-test requirements per component layer. (§6 golden, §7 semantics, §9 widget)
- [x] Define Public API Naming Boundary: `DS*` = internal/legacy implementation layer, `Prism*` = exported public ADS API. Documented in §2.4 with consumer import boundary rule.
- [x] Define ADS upgrade loop for bugs or new components discovered by consumer apps. (§10)
- [x] **Simplicity pass**: kept policy implementable — golden tests use flutter_test, catalog uses existing gallery, no external dependencies added.
- [x] **Regression verification**: `test -f docs/design/token-theme-catalog-policy.md` PASS. Changelog entry created.

### Where

| File | Purpose |
| --- | --- |
| `docs/tasks/02-doing/0014-warp-prism-ds-token-contract-and-inventory.md` | Read — current token evidence. |
| `docs/tasks/02-doing/0017-warp-prism-design-system-gallery-route-bootstrap.md` | Read — current gallery evidence. |
| `lib/design_system/` | Read — current ADS implementation. |
| `test/design_system/` | Read — current ADS tests. |
| `docs/architecture/warp-prism-melos-monorepo-architecture.md` | Read — monorepo boundary decision from Task 1104. |
| `docs/design/token-theme-catalog-policy.md` | Create — reusable ADS policy. |
| `docs/changelog/` | Create local changelog note. |

### How

1. Start from current DS/gallery reality.
2. Translate current proof into package-level gates.
3. Keep Widgetbook optional until the tooling check proves it is low-friction.
4. Make every reusable component promotion reviewable and testable.

### Why

Without a promotion policy, reusable components will drift into whichever app needed them first. This creates retrabalho, hidden breakage, and weak ADS reuse. A catalog/golden/semantics policy makes the ADS a governed product, not a pile of widgets.

---

## Anti-Hallucination Guardrails

> [!CAUTION]
> Do not claim Widgetbook is required or rejected without evidence. Document the decision and revisit criteria.

> [!IMPORTANT]
> Keep `warp_prism_ui` app-agnostic: no CyberCore route/API logic belongs in reusable components.

---

## Validation Commands

```bash
test -f docs/design/token-theme-catalog-policy.md
bash ../.agents/skills/project-management/sub-skills/manage-changelog/scripts/rebuild.sh validate
```

---

## Completion Evidence

- **Files created/modified**:
  - CREATED: `docs/design/token-theme-catalog-policy.md` (655 lines) — reusable ADS governance contract
  - CREATED: `docs/changelog/2026-06-08-task-1105-token-theme-catalog-policy.md` — local changelog entry
- **Tests or validation commands**:
  - `test -f docs/design/token-theme-catalog-policy.md` → PASS
- **Local changelog entry**: `docs/changelog/2026-06-08-task-1105-token-theme-catalog-policy.md`
- **Policy sections delivered**:
  1. Token categories (primitive/semantic/component) and naming conventions (§2)
  2. ThemeExtension ownership rules — deferred for MVP, documented future checklist (§3)
  3. Component promotion gates with per-layer gate matrix and promotion checklist template (§4)
  4. Catalog policy — custom catalog MVP, Widgetbook deferred with revisit criteria (§5 + §11)
  5. Golden test policy — required per layer, conventions, maintenance rules (§6)
  6. Semantics test policy — WCAG AA requirements, per-layer checklist (§7)
  7. State matrix requirements — 15-state vocabulary integration, composition rules (§8)
  8. Gallery-to-catalog evolution path (§5.5)
  9. DS* vs Prism* public API naming boundary (§2.4)
  10. ADS upgrade loop for consumer-discovered bugs (§10)
  11. Quick reference checklists for new components, bug fixes, catalog cases (§13)
- **Source evidence cited**: Task 1101 (charter/naming), Task 1102 (inventory + state vocabulary), Task 1104 (Melos architecture), Tasks 0014/0017/0018 (token contract + gallery + accessibility baseline), direct file inspection of 8 token files, 2 gallery files, test directory structure
- **Agent executor**: gt-architect (builders agent profile)
- **Date**: 2026-06-08
