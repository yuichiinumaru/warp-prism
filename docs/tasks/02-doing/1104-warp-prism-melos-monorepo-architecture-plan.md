# Task 1104: Warp Prism Melos Monorepo Architecture Plan

> **Status**: `[ ]` Open
> **Priority**: 🔴 P0
> **Type**: `architecture` | `governance`
> **Origin**: User clarified ADS reuse/versioning/CI requirements and approved Warp Prism as a parent monorepo with ADS, catalog, and frontend apps as child projects.
> **Blocks**: Task 1103 (superseded), Task 1105, Task 1106, Task 1107, Task 1110
> **Depends on**: Task 1101, Task 1102

> [!IMPORTANT]
> Task identity is lane-neutral. Use `Task 1104` plus optional slug for dependencies, blockers, review ledgers, reports, and architecture references. Lanes such as `02-doing` and `03-review` are mutable status, not identity.

---

## Objective

Create the architecture decision and migration plan for restructuring Warp Prism as a Flutter Melos monorepo with reusable `packages/warp_prism_ui`, Storybook/Widgetbook-like `apps/catalog`, current ASW Observatory app under `apps/observatory`, and future CyberCore frontend under `apps/cybercore`. This task must decide package boundaries, CI/test strategy, path dependency policy, and the migration sequence without moving code yet.

## Background Context

### What already exists

- Warp Prism currently has a single Flutter app structure at the child root with `pubspec.yaml`, `lib/`, `test/`, design-system files, app routes, and workspace snapshot features.
- `docs/tasks/00-planning/1100-warp-prism-operational-atomic-design-system-epic.md` calls for reusable `warp_prism_ui` and `warp_prism_catalog`.
- `docs/tasks/01-open/1103-warp-prism-flutter-tooling-and-scaffold.md` proposes `packages/warp_prism_ui` and `apps/warp_prism_catalog`.
- User clarified that ADS upgrades must be visible to consuming frontends with minimal effort and that new frontend ideas should be able to feed reusable atoms/molecules/organisms back into ADS.

### What is missing or broken

- There is no documented package/app boundary for ADS, catalog, observatory, and CyberCore.
- There is no Melos policy or alternative monorepo decision.
- Existing `1101–1103` stale context still assumes `warp-prism/` is empty.
- Without an architecture plan, a builder could either keep ADS too coupled to one app or split it into a repo too early and create update/versioning friction.

---

## Test Requirements

- The architecture plan MUST compare at least three options: single app root, separate GitHub repos, and Melos monorepo with path dependencies.
- The plan MUST choose one option and justify it against ADS reuse, cross-app CI, versioning, frontend specialization, and future extraction.
- The plan MUST specify package names and paths for ADS, catalog, observatory, and CyberCore app.
- The plan MUST define how ADS changes are validated against all consumers.
- The plan MUST explicitly preserve current Warp Prism work and describe migration sequencing.
- No Flutter code may be moved in this task.

---

## Exit Conditions

- [x] `docs/architecture/warp-prism-melos-monorepo-architecture.md` exists with options, decision, and migration sequence.
- [x] The architecture doc defines `packages/warp_prism_ui`, `apps/catalog`, `apps/observatory`, and `apps/cybercore` boundaries.
- [x] The architecture doc defines CI commands and Melos script names for analyze/test/catalog smoke.
- [x] The architecture doc explains how reusable ADS upgrades flow to apps through path dependencies and monorepo gates.
- [x] Task 1103 is updated or explicitly superseded so it no longer claims the root is empty or creates a conflicting scaffold.
- [x] Local changelog entry added under `docs/changelog/`.
- [x] Completion Evidence is filled before review handoff.

---

## Details

### What

Subtasks:

- [x] **Read existing code before modifying**: read `AGENTS.md`, `pubspec.yaml`, `lib/`, `test/`, `docs/tasks/00-planning/1100-warp-prism-operational-atomic-design-system-epic.md`, Task 1101, Task 1102, Task 1103, and `docs/tasks/00-planning/EPIC-11-warp-prism-cybercore-frontend.md`.
- [x] Inventory current root Flutter app files that would belong to `apps/observatory` vs `packages/warp_prism_ui`. (Full file ownership table in §15 of architecture doc.)
- [x] Compare single-root, separate-repo, and Melos-monorepo options. (§2 of architecture doc.)
- [x] Decide package/app boundaries and path dependency policy. (§5 and §6 of architecture doc.)
- [x] Define Melos bootstrap/analyze/test/catalog commands. (§7 and §8 of architecture doc.)
- [x] Update Task 1103 stale assumptions or mark the conflict explicitly in this task evidence. (Task 1103 already has supersession note; §12 of architecture doc confirms no action needed.)
- [x] **Simplicity pass**: keep the first migration plan minimal; do not require publishing to pub.dev or separate GitHub repos. (Decision: Melos + path deps, no pub.dev, no Git deps.)
- [x] **Regression verification**: run non-Flutter doc existence checks and changelog validation. (Architecture file exists at 661 lines; changelog entry created.)

### Where

| File | Purpose |
| --- | --- |
| `warp-prism/AGENTS.md` | Read — child-project governance and protected-file scope. |
| `warp-prism/pubspec.yaml` | Read — current root app dependency baseline. |
| `warp-prism/lib/` | Read — classify current code by future package/app owner. |
| `warp-prism/test/` | Read — classify tests by future package/app owner. |
| `warp-prism/docs/tasks/01-open/1103-warp-prism-flutter-tooling-and-scaffold.md` | Read/Modify — reconcile stale scaffold assumptions. |
| `warp-prism/docs/architecture/warp-prism-melos-monorepo-architecture.md` | Create — architecture decision and migration plan. |
| `warp-prism/docs/changelog/` | Create local changelog note. |

### How

1. Treat the root app as current evidence, not an empty scaffold.
2. Design the target monorepo shape before moving files.
3. Keep ADS package app-agnostic and put product routes/data into apps.
4. Define the first migration as a separate task so this architecture task remains reviewable.

### Why

Warp Prism needs reusable ADS components and multiple frontend consumers without version drift. A Melos monorepo with path dependencies gives immediate update visibility, cross-app CI, and a clean future extraction path if `warp_prism_ui` later deserves a separate repository or pub.dev package.

---

## Anti-Hallucination Guardrails

> [!CAUTION]
> Do not move code in this task. This task creates the architecture plan and updates stale scaffold assumptions only.

> [!IMPORTANT]
> Preserve current Warp Prism work. The migration plan must route existing root `lib/` and `test/` into the target structure instead of pretending the project is empty.

---

## Validation Commands

```bash
test -f docs/architecture/warp-prism-melos-monorepo-architecture.md
bash ../.agents/skills/project-management/sub-skills/manage-changelog/scripts/rebuild.sh validate
```

---

## Completion Evidence

- **Files created/modified**:
  - `docs/architecture/warp-prism-melos-monorepo-architecture.md` — created (661 lines)
  - `docs/changelog/2026-06-08-task-1104-melos-monorepo-architecture-plan.md` — created
- **Tests or validation commands**:
  - `test -f docs/architecture/warp-prism-melos-monorepo-architecture.md` — passes
  - `wc -l docs/architecture/warp-prism-melos-monorepo-architecture.md` — 661 lines (>100 threshold)
  - Dependency isolation verified via `rg`: design_system has zero data imports, data has zero design_system imports
  - `bash ../.agents/skills/project-management/sub-skills/manage-changelog/scripts/rebuild.sh validate` — fails with pre-existing issue: `2026-06-07-task-0006-mock-corpus-validation-archive.md` is missing YAML frontmatter delimiter (`---`). This file was created before the changelog frontmatter convention was enforced (also noted in Task 1101 changelog evidence). Task 1104's own changelog entry has valid frontmatter.
- **Local changelog entry**: `docs/changelog/2026-06-08-task-1104-melos-monorepo-architecture-plan.md`
- **Task 1103 reconciliation**: Task 1103 already has a supersession note (added 2026-06-08). No additional updates needed. Flutter tooling verification remains valid as prerequisite for Task 1107.
