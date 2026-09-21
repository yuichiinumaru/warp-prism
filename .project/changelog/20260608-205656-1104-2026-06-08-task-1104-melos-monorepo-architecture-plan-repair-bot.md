---
date: 20260608-205656
timestamp: 20260608-205656
project: "warp-prism"
agent: repair-bot
task: "1104"
description: "Warp Prism Melos monorepo architecture plan established"
is_rebuild_safe: true
id: "2026-06-08-task-1104-melos-monorepo-architecture-plan"
impact: ""
skills: ""
type: "architecture"
---

# Warp Prism Melos monorepo architecture plan established

Created the architecture decision record for restructuring Warp Prism as a
Flutter Melos monorepo with reusable `packages/warp_prism_ui`, catalog app
`apps/catalog`, Observatory app `apps/observatory`, and future CyberCore pilot
`apps/cybercore`.

## Why

Warp Prism needs reusable ADS components and multiple frontend consumers
without version drift. Without a documented architecture plan, builders risk
either premature coupling (ADS stuck inside one app) or premature
fragmentation (ADS in a separate repo before governance is ready). A Melos
monorepo with path dependencies gives immediate update visibility, cross-app
CI, and a clean future extraction path.

## Changed

- `docs/architecture/warp-prism-melos-monorepo-architecture.md`: Full
  architecture decision record covering:
  - Three options evaluated (single root, separate repos, Melos monorepo).
  - Decision: Melos monorepo with path dependencies (no pub.dev, no Git deps).
  - Target monorepo structure with `packages/`, `apps/`, `melos.yaml`.
  - Package boundary decisions (what goes into `warp_prism_ui` vs apps).
  - Path dependency policy.
  - CI/test strategy per package/app with Melos script definitions.
  - Migration sequence (5 phases, step-by-step for Task 1107).
  - Risk analysis (high/medium/low risks with mitigations).
  - Widgetbook vs custom catalog decision (custom catalog for MVP).
  - Task 1103 reconciliation (already superseded, no action needed).
  - ADS upgrade flow to consumers.
  - Complete file ownership table after migration.

## Evidence

- Architecture file exists: `test -f docs/architecture/warp-prism-melos-monorepo-architecture.md` passes.
- Architecture file is substantial: 661 lines.
- Design system dependency isolation verified via `rg` analysis:
  `lib/design_system/` has zero imports from `lib/data/`, and `lib/data/`
  has zero imports from `lib/design_system/`.
- Task 1103 already has a supersession note (added 2026-06-08) — no
  additional updates needed.
