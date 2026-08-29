# Task 1104: Warp Prism Melos Monorepo Architecture Plan

> **Review State**: 2026-07-18 path-to-100 independent re-review **100/100** `ACCEPTED_100`
> **Priority**: 🔴 P0
> **Type**: `architecture` | `governance`
> **Origin**: User clarified ADS reuse/versioning/CI requirements and approved Warp Prism as a parent monorepo with ADS, catalog, and frontend apps as child projects.
> **Blocks**: Task 1103 (superseded), Task 1105, Task 1106, Task 1107, Task 1110
> **Depends on**: Task 1101 (`04-completed/`), Task 1102 (`02-doing/` — Builder Done deliverables present; not yet promoted)

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

- **Files created/modified** (historical builder pass 2026-06-08):
  - `docs/architecture/warp-prism-melos-monorepo-architecture.md` — created (661 lines)
  - Local changelog ledger entry (engine-renamed; see path-to-100 refresh for live path)
- **Tests or validation commands** (historical; superseded by 2026-07-09 live re-run below):
  - `test -f docs/architecture/warp-prism-melos-monorepo-architecture.md` — passes
  - `wc -l docs/architecture/warp-prism-melos-monorepo-architecture.md` — 661 lines
  - Historical isolation check on pre-migration `lib/design_system` / `lib/data` paths (those root paths no longer exist after later monorepo migration; architecture plan itself forbade code moves)
  - Changelog validate historically failed on unrelated entries (see live classification below)
- **Local changelog entry** (live path):
  - `docs/changelog/20260608-205656-1104-2026-06-08-task-1104-melos-monorepo-architecture-plan-repair-bot.md`
  - Historical bare name `docs/changelog/2026-06-08-task-1104-melos-monorepo-architecture-plan.md` is **superseded** by the engine-prefixed ledger filename above (`id: "2026-06-08-task-1104-melos-monorepo-architecture-plan"` retained in frontmatter)
- **Task 1103 reconciliation**: Task 1103 already has a supersession note (added 2026-06-08). No additional updates needed. Flutter tooling verification remains valid as prerequisite for Task 1107.
- **Dependency status (live 2026-07-09)**:
  - Task 1101 → `docs/tasks/04-completed/1101-warp-prism-charter-and-naming-convergence.md` (`Status: [x] Promoted`)
  - Task 1102 → `docs/tasks/02-doing/1102-warp-prism-control-surface-inventory.md` (`Status: [x] Done` / `Review State: Builder Done`; deliverables present: `docs/design/component-inventory.md`, `operational-state-vocabulary.md`, `cybercore-pilot-surface-matrix.md`). Related completed snapshot: `docs/tasks/04-completed/1420-warp-prism-cybercore-evidence-snapshot-for-1102.md`. **Note**: dependency 1102 is not yet review-promoted; inventory artifacts required by this architecture task are on disk.

### Path-to-100 Refresh — 2026-07-09 — builders (`gt-evidence-refresher`)

- **Mode**: `worker-dry-run` evidence-only; parent ordered leave lane in `02-doing`; no git/tasklist/changelog-publish/agent-wiki.
- **Why**: 2026-06-17 rejection (82/100) for header/lane inconsistency (`Status: [ ] Open` vs `Review State: Builder Done` while briefly in `03-review/`), stale changelog path in evidence, and undeclared live changelog validator failure class.
- **Header reconciliation**:
  - Was: `Status: [ ] Open` + `Review State: Builder Done — status marker inconsistent with evidence; lane mismatch`
  - Now: `Status: [x] Done` + `Review State: Ready For Review` (lane deliberately remains `02-doing/` until parent promotion)
- **Live lane proof**:
  - `test -f docs/tasks/02-doing/1104-warp-prism-melos-monorepo-architecture-plan.md` → `IN_DOING:OK`
  - `test ! -f docs/tasks/03-review/1104-warp-prism-melos-monorepo-architecture-plan.md` → `NOT_IN_REVIEW:OK`
- **Declared validation re-run (exact)**:
  1. `test -f docs/architecture/warp-prism-melos-monorepo-architecture.md` → `ARCH_OK` (exit 0)
  2. `wc -l docs/architecture/warp-prism-melos-monorepo-architecture.md` → `661 docs/architecture/warp-prism-melos-monorepo-architecture.md`
  3. `test -f docs/changelog/20260608-205656-1104-2026-06-08-task-1104-melos-monorepo-architecture-plan-repair-bot.md` → `CHANGELOG_1104_OK` (exit 0)
  4. Child-local changelog validate:
     ```text
     GANTHRITOR_CHANGELOG_DIR=docs/changelog bash ../.agents/skills/project-management/sub-skills/manage-changelog/scripts/rebuild.sh validate
     → ERROR: Missing 'timestamp' in 1302-public-barrel-audit.md
     → exit=1
     ```
     Note: bare `bash …/rebuild.sh validate` without `GANTHRITOR_CHANGELOG_DIR=docs/changelog` fails earlier with `ERROR: Changelog directory not found: …/warp-prism/.changelog` (wrong default dir for this child). Child-local invocation requires the env override.
  5. Task 1103 supersession still live: `docs/tasks/01-open/1103-…` contains `SUPERSESSION NOTE (2026-06-08)`.
- **Architecture contract spot-check (live)**:
  - Top-level sections present: Options (§2), Decision (§3), Target structure (§4), Package boundaries (§5), Path dependency policy (§6), Melos config/scripts (§7), CI/test strategy (§8), Migration sequence (§9), Task 1103 reconciliation (§12), ADS upgrade flow (§13)
  - Required paths named: `packages/warp_prism_ui`, `apps/catalog`, `apps/observatory`, `apps/cybercore`
  - Melos script names present: `melos bootstrap`, `melos run analyze`, `melos run test`, catalog-scoped scripts
- **Pre-existing failure classification** (`.agents/rules/pre-existing-failure-policy.md` / EPIC-12):

  | Failure | Classification | Evidence |
  |---|---|---|
  | `Missing 'timestamp' in 1302-public-barrel-audit.md` under `GANTHRITOR_CHANGELOG_DIR=docs/changelog … validate` | **Pre-existing (unrelated)** | Failing file is `docs/changelog/1302-public-barrel-audit.md` (Task 1302). Task 1104 touch set is architecture doc + this task ledger + historical 1104 changelog entry. 1104 changelog frontmatter includes `timestamp: 20260608-205656`. Same class of failure already classified on Tasks 1126 / prior 1104 review packet. |
  | Flutter/Dart package gates | **N/A** | Task forbids code moves; docs-only architecture plan. |

- **Exit conditions**: 7/7 remain `[x]` — architecture doc, package paths, CI/Melos scripts, ADS path-dep flow, Task 1103 supersession, local changelog entry, completion evidence.
- **Subtasks**: 8/8 remain `[x]`.
- **Substantive work**: none (evidence-only). Architecture doc unchanged this pass.
- **Review packet link**: `docs/reports/build-gate-review/1104-review.md` (historical rejection packet from 2026-06-17). Parent may commission a fresh post-promotion packet after lane move.
- **Self-score (evidence gate only)**: 100/100 mechanical path-to-100 items addressed; parent owns lane move to `03-review/`.

> **STATUS**: Internal builder review ACCEPTED (100/100) 2026-07-09. Lane is `03-review/`. Awaiting independent review. Report: `docs/reports/build-gate-review/1104-review.md`.

---

## Review Ledger

### 2026-06-17 — independent reviewer subagent (`reviewers`)
**Score**: 82/100 — Good
**Verdict**: REJECTED → moved back to `02-doing`
**Diagnostics**: `test -f docs/architecture/warp-prism-melos-monorepo-architecture.md` PASS | `bash .agents/skills/project-management/sub-skills/manage-changelog/scripts/rebuild.sh validate` FAIL (`ERROR: Missing 'timestamp' in 1302-public-barrel-audit.md`) | Flutter/Dart gates N/A for docs-only architecture task
**Report**: `docs/reports/build-gate-review/1104-review.md`
**Patches applied**: none — score below 90
**Rejection rationale**: task is physically in `03-review/` while header remains `Status: [ ] Open` and `Review State: Builder Done`; local governance allows `03-review/` only for `Ready For Review`. No pre-existing 1104 build-gate review packet was present, and the declared changelog validation gate is not green today.
**Path to 100**: refresh the task header to `Ready For Review`, rerun/document declared validation commands, classify any unrelated changelog validator failure with exact evidence, include dependency status for Tasks 1101/1102, and move back to `03-review/` only after the promotion-state gate is satisfied.

### 2026-07-09 — builders (`gt-evidence-refresher`)
**Mode**: evidence-only path-to-100; lane left in `02-doing` per parent
**Actions**:
1. Header reconciled: `Status: [x] Done` + `Review State: Ready For Review`
2. Declared validation commands re-run with exact stdout captured in Completion Evidence
3. Changelog validator failure classified as pre-existing unrelated (`1302-public-barrel-audit.md` missing `timestamp`)
4. Dependency status recorded: 1101 `04-completed/`; 1102 `02-doing/` Builder Done with inventory deliverables on disk
5. Live changelog path corrected to engine-prefixed ledger filename
6. Pre-promotion STATUS line appended; no lane move, no git/tasklist/changelog-publish/agent-wiki
**Disposition**: Ready for parent promotion check → `03-review/` (parent-owned)

### 2026-07-09 — gt-code-quality-reviewer (internal builder review)
**Score**: 100/100 — Pass
**Verdict**: ACCEPTED → moved `02-doing/` → `03-review/`
**Diagnostics**:
- `test -f docs/architecture/warp-prism-melos-monorepo-architecture.md` → PASS (661 lines)
- Contract checklist (3 options, Melos decision, four package/app paths, Melos scripts, ADS path-dep flow, migration sequence, Task 1103 section) → ALL PASS
- Changelog entry `docs/changelog/20260608-205656-1104-2026-06-08-task-1104-melos-monorepo-architecture-plan-repair-bot.md` → PASS (`timestamp` present)
- Child-local changelog validate → FAIL unrelated pre-existing (`Missing 'timestamp' in 1302-public-barrel-audit.md`)
- Flutter/Dart gates → N/A (docs-only; no code moves)
- Task 1103 supersession note → PASS (live)
**Report**: `docs/reports/build-gate-review/1104-review.md` (refreshed pass packet)
**Patches applied**: none (architecture deliverable unchanged)
**Path to 100**: none
**Disposition**: Lane `docs/tasks/03-review/1104-warp-prism-melos-monorepo-architecture-plan.md`; awaiting independent review

### 2026-07-09 — independent re-review (`reviewers` / gt-code-quality-reviewer)
**Score**: 100/100
**Verdict**: `HELD_IN_REVIEW_PATH_TO_100` — remain `03-review/` (never `04-completed/`)
**Full report**: `docs/reports/review-wave-2026-07-09/task-1104-melos-monorepo-architecture-plan-independent-rereview.md`
**Diagnostics**: architecture 661 lines; 3 options + Melos decision; four paths; Melos scripts; 1103 SUPERSESSION live; changelog path OK; Flutter N/A
**Note**: ADR still mentions standalone `melos.yaml`; live Melos 7 embeds config in root `pubspec.yaml` (Task 1107) — SUPERSEDED packaging detail, not 1104 DoD failure
**Path to 100**: n/a

### 2026-07-17 — drain independent re-review (`reviewers` / gt-code-quality-reviewer)

- **Date**: 2026-07-17
- **Reviewer profile**: `reviewers`
- **Score**: `99/100`
- **Verdict**: `ACCEPTED_PATH_TO_100`
- **Full report**: `docs/reports/review-wave-2026-07-17/task-1104-drain-review.md`
- **Lane outcome**: `docs/tasks/04-completed/`
- **Residuals**: cybercore ownership wording vs 1107 skeleton minor

### Independent path-to-100 re-review — 2026-07-18 (BATCH R3 / reviewers)

- **Score**: **100/100**
- **Verdict**: `ACCEPTED_100`
- **Full report**: `docs/reports/review-wave-2026-07-18/task-1104-path100-rereview.md`
- **Path-to-100 applied**: YES — builders batch3 residuals re-verified live; material residuals RESOLVED; optional polish SUPERSEDED/out-of-scope
- **Lane**: moved to `docs/tasks/04-completed/`
- **Regression guards**: keep suites/commands cited in the full report
- **No git / no tasklist**

