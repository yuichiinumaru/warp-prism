# EPIC 01 — Warp-Prism Atomic Design System

> **Planning Status**: Active Epic
> **Executable?**: No — planning artifact only.
> **Promotion Gate**: Promote tasks after the design-system file inventory and API mismatch evidence are collected.

## Goal

Complete the mandatory Flutter Atomic Design System before product screens, preserving the ultradark obsidian glass visual direction without hardcoding screen-level styling.

## Source Evidence

- `prompt.txt` makes the Atomic Design System a non-negotiable execution rule.
- `prompt.txt` specifies tokens, atoms, molecules, organisms, templates, and a Design System Gallery route.
- `draft.md` reports that some tokens/components exist but have inconsistent APIs and naming.

## Scope

- Tokens: color, typography, spacing, radii, shadows, motion, semantics.
- Atoms: text, icon, badge, chip, divider, status dot, glow border, glass panel.
- Molecules: search/filter, asset card, metric tile, provenance pill, evidence row, timeline marker.
- Organisms: shell, sidebar, topbar, graph canvas, lane board, timeline, detail inspector, story panel.
- Templates and Design System Gallery.

## Out of Scope

- Feature-specific business logic.
- Parsing real/mock workspace data inside widgets.
- Excessive blur/glass effects that violate performance guidance.

## Candidate Stories

- Token contract and ThemeExtension semantics.
- Atom and molecule inventory/normalization.
- Organism API alignment with templates.
- Design System Gallery page and route.
- Accessibility/focus state baseline for components.

## Dependencies

- Depends on EPIC 00 for compile/analyze baseline.

## Acceptance Criteria for Epic Completion

- Gallery demonstrates required tokens/components/states.
- Feature screens can compose DS primitives without local hardcoded visual styling.
- Component names/APIs are consistent enough for analyzer and widget tests.
- Accessibility/readability constraints are explicit in promoted tasks.
