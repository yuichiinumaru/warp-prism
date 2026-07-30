# Task 1101: Warp Prism Charter And Naming Convergence

> **Status**: `[x]` Promoted
> **Review State**: Promoted
> **Priority**: 🔴 P0
> **Type**: `governance`
> **Origin**: Task 1100 Warp Prism epic
> **Blocks**: Task 1102, Task 1103, Task 1104, Task 1105, Task 1106
> **Depends on**: Task 1100
> **Evidence**: local EPIC planning under `docs/tasks/00-planning/`

---

## Objective

Create the first Warp Prism documentation set that establishes project identity, supersedes the old `Voidframe` codename, defines RF8 scope, and gives future Flutter/design-system implementers an explicit child-project charter before any package scaffold is written.

## Background Context

### O que já existe:
- `warp-prism/` now contains an existing Flutter app, design-system implementation, local task tree, and ASW Observatory planning wave.
- Task 8210 remains useful as historical control-surface inventory evidence but uses historical `Voidframe` naming.
- Task 8220 and Task 8230 have been annotated as superseded by Warp Prism.
- Cybernetics Core has existing admin design-system evidence from completed Task 0583 and Task 0590.
- `docs/tasks/00-planning/1100-warp-prism-operational-atomic-design-system-epic.md` and `EPIC-11-warp-prism-cybercore-frontend.md` define the current ADS + CyberCore frontend planning direction.

### O que está faltando / quebrado:
- No `warp-prism/docs/` structure exists.
- No document defines `Warp Prism`, `warp_prism_ui`, `warp_prism_catalog`, or public `Prism*` naming.
- Future implementers could accidentally create `voidframe_ui` or migrate Cybernetics Core prematurely.

---

## Test Requirements

- The charter MUST define Warp Prism as a child project, not a generic folder.
- The naming document MUST mark `Voidframe` as historical and forbid new `voidframe_*` package names.
- The RF8 plan MUST separate catalog/spec work from Cybernetics Core migration work.
- The docs MUST cite existing source tasks and reports as evidence.
- The docs MUST include explicit non-goals for Tamagui code porting, Hyperion-first work, and full CC Flutter migration.

---

## Exit Conditions (GDD/TDD)

- [x] `warp-prism/docs/design/charter.md` exists and defines purpose, scope, non-goals, and first proof target.
- [x] `warp-prism/docs/design/naming.md` exists and defines project/package/component naming.
- [x] `warp-prism/docs/design/rf8-plan.md` exists and covers Goal through Eval stages.
- [x] The documents cite Task 8210, Task 8220, Task 8230, Task 8240, Task 0583, and Task 0590.
- [x] `test -f warp-prism/docs/design/charter.md && test -f warp-prism/docs/design/naming.md && test -f warp-prism/docs/design/rf8-plan.md` passes.
- [x] `python3 ../.agents/skills/indexing-skills/scripts/index_rebuild.py ../.agents --validate` passes from the Warp Prism root. Fresh 2026-06-19 validation passed all 10 planned index surfaces with non-fatal metadata warnings.
- [x] `bash ../.agents/skills/project-management/sub-skills/manage-changelog/scripts/rebuild.sh validate` passes. Fresh 2026-06-19 validation: 0 issues, 83 entries. The prior external blocker (Task 1410) on `2026-06-09-1405-detail-variant-responsive-shell-reconciliation.md` has been resolved (frontmatter delimiter restored).
- [x] Changelog entry is added through the changelog engine.

---

## Details

### What

Subtasks:
- [x] **Ler o código existente antes de modificar**: read `warp-prism/`, Task 1100, local EPIC planning, and existing `docs/` structure before writing.
- [x] Create `warp-prism/docs/design/` only after confirming it does not already exist.
- [x] Write the Warp Prism charter with child-project ownership, product purpose, first proof target, and non-goals.
- [x] Write naming policy for `warp_prism_ui`, `warp_prism_catalog`, and `Prism*` public components.
- [x] Write RF8 plan that separates inventory, scaffold, tokens, components, catalog, pilot, and eval.
- [x] **Refactoring pass**: remove duplicated wording and ensure the docs are concise enough to guide future tasks.
- [x] **Documentation update**: if durable lessons are discovered, record them with `agent-wiki` or docs as applicable.
- [x] **Verificação de regressão**: run the validation commands and capture results.

### Where

| Arquivo | Propósito |
|---------|-----------|
| `warp-prism/` | Read current child-project root before creating subdirectories. |
| `warp-prism/docs/design/charter.md` | Create child-project charter. |
| `warp-prism/docs/design/naming.md` | Create naming/supersession policy. |
| `warp-prism/docs/design/rf8-plan.md` | Create RF8 plan. |
| `docs/tasks/00-planning/1100-warp-prism-operational-atomic-design-system-epic.md` | Read local epic. |
| `docs/tasks/00-planning/EPIC-00-*.md` through `EPIC-10-*.md` | Read existing local EPIC planning. |
| `docs/prompt.txt` | Read product contract. |
| `docs/research.md` | Read research context. |

### How

1. Inspect all source planning before writing.
2. Create only documentation, not Flutter code.
3. Treat `Voidframe` as provenance, not active naming.
4. Make future task boundaries explicit so scaffold and component work can be delegated safely.

### Why

Warp Prism will become a durable child project. Naming and charter drift at the start would cause duplicate packages, false migrations, and design-system sprawl.

---

## ⛔ Anti-Hallucination Guardrails

> [!CAUTION]
> Do not create Flutter packages, `pubspec.yaml`, or catalog app files in this task.

> [!CAUTION]
> Do not rename or delete historical Voidframe planning files.

> [!IMPORTANT]
> The output is documentation under `warp-prism/docs/design/`, not implementation.

---

## 📋 Completion Evidence (preenchido pelo agente executor)

- **Arquivos criados/modificados**: `docs/design/charter.md` (updated: compile claims → workspace registration), `docs/design/naming.md` (updated: live monorepo topology, token API standalone typedefs), `docs/design/rf8-plan.md` (updated: Melos implemented, compile claims → workspace registration), `docs/changelog/20260608-205031-1101-2026-06-08-task-1101-charter-naming-convergence-repair-bot.md`
- **Testes que verificam o trabalho**: `test -f docs/design/charter.md && test -f docs/design/naming.md && test -f docs/design/rf8-plan.md` — ALL THREE FILES EXIST
- **Resultado dos comandos de validação** (2026-06-19):
  - File existence: PASS
  - Citation/stale-reference check: PASS (6/6 historical tasks cited; 0 `PrismTokens.` usages in Task 1101 docs; 0 wrong catalog paths)
  - Index validation: PASS (10/10 planned surfaces, non-fatal metadata warnings only)
  - Changelog validation: PASS (0 issues, 83 entries — prior Task 1410 external blocker resolved)
  - Fresh analyzer evidence: `warp_prism_ui` 590 issues, catalog 1, observatory 378, CyberCore 0 (969 total) — docs now accurately reflect workspace registration state, not compile cleanliness
- **Entrada no CHANGELOG**: `docs/changelog/20260608-205031-1101-2026-06-08-task-1101-charter-naming-convergence-repair-bot.md` created (engine-generated filename with timestamp/agent suffix).
- **Agent-wiki / docs institucionalização**: Design docs created under `docs/design/`. No durable operational lessons discovered requiring agent-wiki profile update — this was a pure documentation task.
- **Agente executor**: builders
- **Data de conclusão**: 2026-06-19

---

## Review Ledger

> [!IMPORTANT]
> Before path-to-100 work, read the latest full report and all reports listed
> under Previous Reports. Preserve the file-existence and docs-only regression
> guards while correcting current public API and monorepo topology claims.

### Latest Review

- **Date**: 2026-06-19
- **Reviewer profile**: `reviewers`
- **Score**: `100/100`
- **Verdict**: `ACCEPTED_100`
- **Full report**: `docs/reports/build-gate-review/1101-review-2026-06-19.md`
- **Lane outcome**: accepted/completed
- **Task reference**: Task 1101 (`warp-prism-charter-and-naming-convergence`)

#### Current Open Blockers

- None.

#### Final Verification Summary

- Prior F1-F6 are `RESOLVED` with regression guards preserved.
- Task 1410 external changelog blocker is `RESOLVED`; fresh validation returns `Changelog valid: issues=0 entries=83`.
- File-existence, citation/stale-reference, index validation, and changelog validation checks all pass.
- Task 1101 is approved and promoted to `04-completed/`.

### Previous Latest Review

- `2026-06-18` — `84/100` — `docs/reports/build-gate-review/1101-review-2026-06-18.md`
  - **Resolved since**: F5 residual planned-Melos wording, F6 unsupported compile claims, and Task 1410 external blocker.
  - **Regression guard**: keep docs aligned to workspace registration state until analyzer cleanup is separately proven.

### Remediation Applied (2026-06-18)

The following fixes were applied to address the 2026-06-17 review findings:

| Finding | Fix Applied |
|---------|-------------|
| F1: `PrismTokens.*` fabricated API in `naming.md` | Replaced with actual exported aliases: `PrismColors`, `PrismTypography`, `PrismSpacing`, `PrismBreakpoints`, `PrismRadii`, `PrismShadows`, `PrismMotion`, `PrismSemantics` as standalone typedefs. Updated legacy DS-prefix mapping table accordingly. Added note clarifying `PrismTokens` was a conceptual placeholder. |
| F2: Charter/RF8 topology stale (catalog at `packages/warp_prism_catalog`, packages "planned") | Updated `charter.md` §5.3 and `rf8-plan.md` §2.4 to reflect live monorepo: `packages/warp_prism_ui` (implemented), `apps/catalog` (implemented), `apps/observatory` (implemented), `apps/cybercore` (implemented). Removed "planned/conceptual" language. |
| F3: Changelog evidence pointed to nonexistent filename | Updated completion evidence to reference actual engine-generated file: `docs/changelog/20260608-205031-1101-2026-06-08-task-1101-charter-naming-convergence-repair-bot.md` |
| F4: Changelog validation checkbox claimed pass | Changed exit condition from `[x]` to `[ ]` with explicit blocker documentation: unrelated failure in `1302-public-barrel-audit.md` (missing `timestamp`). |

### Additional Remediation (2026-06-18 — Post-Review Action)

| Finding | Fix Applied |
|---------|-------------|
| F1/F2 residual: `naming.md` §3 package table still showed "Planned" status and wrong catalog path | Updated §3 package table: all four packages now show "Implemented" status with correct locations (`packages/warp_prism_ui`, `apps/catalog`, `apps/observatory`, `apps/cybercore`). Added "Location" column. Updated §4.1 token table header and note to clarify standalone typedef exports vs `PrismTokens` namespace. |

### Additional Remediation (2026-06-19 — Post-Review Action)

| Finding | Fix Applied |
|---------|-------------|
| F5 (NEW 2026-06-18): `rf8-plan.md:289` Melos monorepo described as planned | Changed "Melos monorepo (planned) | Task 1104 will formalize" to "Melos monorepo (implemented) | Task 1104 formalized the workspace; stabilization remains ongoing." |
| F6 (NEW 2026-06-18): `charter.md:160-162` and `rf8-plan.md:124` unconditional compile claims | `charter.md`: "All four packages/apps exist and compile" → "All four packages/apps exist and are registered in the workspace." `rf8-plan.md`: "ADS package and all three apps are implemented and compile" → "ADS package and all three apps are implemented and registered in the Melos workspace." |

### Previous Reports

- `2026-06-17` — `72/100` — `docs/reports/build-gate-review/1101-review-2026-06-17.md`
  - **Resolved since**: nonexistent `PrismTokens.*` API, wrong package paths/status table, nonexistent changelog evidence path, and falsely checked changelog gate.
  - **Regression guard**: keep public names aligned with the live barrel and package topology aligned with the five pubspecs.
- `2026-06-13` — `100/100` — `docs/reports/build-gate-review/1101-review.md`
  - **Carried forward**: all three design docs and a changelog entry exist; no Flutter code was created by Task 1101.
  - **Regression guard**: preserve child-project identity, Voidframe supersession, RF8 stage coverage, and CyberCore non-migration boundaries. All guardrails respected.
