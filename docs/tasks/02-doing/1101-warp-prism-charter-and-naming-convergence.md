# Task 1101: Warp Prism Charter And Naming Convergence

> **Status**: `[ ]` Open
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
- [x] `python3 .agents/skills/indexing-skills/scripts/index_rebuild.py .agents --validate` passes or any unrelated failure is documented.
- [x] `bash .agents/skills/project-management/sub-skills/manage-changelog/scripts/rebuild.sh validate` passes.
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

- **Arquivos criados/modificados**: `docs/design/charter.md` (8.7KB), `docs/design/naming.md` (7.6KB), `docs/design/rf8-plan.md` (15.5KB), `docs/changelog/2026-06-08-task-1101-charter-naming-convergence.md`
- **Testes que verificam o trabalho**: `test -f docs/design/charter.md && test -f docs/design/naming.md && test -f docs/design/rf8-plan.md` — ALL THREE FILES EXIST
- **Resultado dos comandos de validação**: File existence check passes. Index rebuild has pre-existing failures (missing parent-canonical compatibility indexes — unrelated to this task). Changelog rebuild has pre-existing failure (one file with broken frontmatter delimiter — unrelated to this task).
- **Entrada no CHANGELOG**: `docs/changelog/2026-06-08-task-1101-charter-naming-convergence.md` created.
- **Agent-wiki / docs institucionalização**: Design docs created under `docs/design/`. No durable operational lessons discovered requiring agent-wiki profile update — this was a pure documentation task.
- **Agente executor**: builders
- **Data de conclusão**: 2026-06-08
