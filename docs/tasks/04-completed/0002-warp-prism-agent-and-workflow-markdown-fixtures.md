# Task 0002: Warp Prism Agent And Workflow Markdown Fixtures

> **Review State**: `ACCEPTED_100` — S=100/100 (2026-07-18); see `docs/reports/review-wave-2026-07-18/task-0002-path100-rereview.md`
> **Priority**: 🔴 P0
> **Type**: `feature`
> **Origin**: EPIC 02 — Warp Prism Mock Workspace Corpus
> **Blocks**: Task 0004, Task 0005, Task 0006
> **Depends on**: Task 0001

> [!IMPORTANT]
> Task identity is lane-neutral. Use `Task 0002` plus optional slug for dependencies,
> blockers, review ledgers, reports, and architecture references. Lanes such as
> `02-doing` and `03-review` are mutable status, not identity. If a live file path
> is needed, resolve it from `docs/tasks/tasklist.md` or search under `docs/tasks/`.

---

## Objective

Create the markdown-frontmatter mock agent set and global workflow set required by the prompt under `apps/observatory/assets/mock_workspace/.agents/`, replacing the current underspecified YAML corpus with graphable `.md` assets that future parsers can ingest directly.

## Background Context

### O que já existe:
- `warp-prism/mock_workspace/.agents/orchestrator/agent.yaml` and sibling files provide a legacy structure with 5 agents.
- `warp-prism/mock_workspace/.agents/workflows/` contains only 3 YAML workflows in nested directories.
- `warp-prism/docs/prompt.txt` requires 9 specific mock agents and 11 specific global workflows with YAML frontmatter in markdown files.
- `warp-prism/assets/mock_workspace/manifest.yaml` from Task 0001 is the authoritative list and count source for this wave.

### O que está faltando / quebrado:
- The current mock agent files are `.yaml`, not `.md` with frontmatter and markdown body.
- The required agent names from the prompt do not exist yet.
- The required workflow names from the prompt do not exist yet.
- The current files do not clearly model relationships to skills, workflows, tasks, and changelog evidence.

---

## Test Requirements

- DEVE criar exatamente 9 arquivos de agentes markdown exigidos pelo prompt em `apps/observatory/assets/mock_workspace/.agents/agents/`.
- DEVE criar exatamente 11 arquivos de workflows globais markdown exigidos pelo prompt em `apps/observatory/assets/mock_workspace/.agents/workflows/`.
- DEVE garantir que cada agente tenha frontmatter valido com `name`, `model`, `description`, `skills`, e `workflows`.
- DEVE garantir que cada workflow tenha frontmatter valido com `name`, `description`, `uses_skills`, e `kind`.
- DEVE garantir que os corpos markdown contem relacoes legiveis para skills, tasks, governanca ou prova operacional.

---

## Exit Conditions (GDD/TDD)

- [x] Os 9 agentes obrigatorios existem como `.md` em `apps/observatory/assets/mock_workspace/.agents/agents/`.
- [x] Os 11 workflows obrigatorios existem como `.md` em `apps/observatory/assets/mock_workspace/.agents/workflows/`.
- [x] Cada arquivo criado possui delimitadores de frontmatter `---` e um corpo markdown nao vazio.
- [x] Os agentes referenciam skills e workflows que existem no manifesto aprovado em Task 0001.
- [x] Comando de validacao principal do componente passa sem erros: `python3 tool/validate_mock_workspace.py --project-root apps/observatory`.
- [x] Testes relevantes passam com 0 falhas: PyYAML required-key/body/reference checks reported in `docs/reports/review-wave-2/0001-0003-fixture-contract-review.md`.
- [x] Entrada de changelog adicionada via engine em `docs/changelog/` — N/A; fixture-only corpus task, accepted by reviewer ledger.

---

## Details

### What

Subtasks:
- [x] **Ler codigo existente**: `warp-prism/docs/prompt.txt`, `warp-prism/assets/mock_workspace/manifest.yaml`, `warp-prism/mock_workspace/.agents/orchestrator/agent.yaml`, `warp-prism/mock_workspace/.agents/planner/agent.yaml`, `warp-prism/mock_workspace/.agents/reviewer/agent.yaml`, `warp-prism/mock_workspace/.agents/workflows/code-implementation/workflow.yaml`, `warp-prism/lib/data/parsers/workspace_parser.dart`
- [x] Criar os 9 agentes obrigatorios como markdown com frontmatter e secoes de corpo que descrevem papel, gatilhos, dependencias e surfaces relacionadas.
- [x] Criar os 11 workflows globais como markdown com frontmatter e secoes de corpo que descrevem passos, skills usadas e artefatos produzidos.
- [x] Conectar agentes e workflows por referencias cruzadas consistentes com o manifesto e com o corpus de skills da Task 0003.
- [x] Verificar que nomes, paths e contagens batem exatamente com o prompt, sem aliases improvisados.
- [x] **Refactoring pass**: Review implementation for simplicity. If you wrote 200 lines that could be 50, rewrite them.
- [x] **Documentation update**: If you discovered any durable operational notes, record them with `agent-wiki`; if you discovered collective project knowledge, institutionalize it under `docs/`
- [x] **Verificacao de regressao**: `python3 tool/validate_mock_workspace.py --project-root apps/observatory` and PyYAML required-key/reference checks pass per `docs/reports/review-wave-2/0001-0003-fixture-contract-review.md`.

### Where

| Arquivo | Proposito |
|---------|-----------|
| `warp-prism/docs/prompt.txt` | Ler - lista obrigatoria de agentes e workflows |
| `apps/observatory/assets/mock_workspace/manifest.yaml` | Ler - contagens e nomes aprovados |
| `mock_workspace/.agents/orchestrator/agent.yaml` | Ler - referencia do corpus legado |
| `mock_workspace/.agents/planner/agent.yaml` | Ler - referencia do corpus legado |
| `mock_workspace/.agents/reviewer/agent.yaml` | Ler - referencia do corpus legado |
| `mock_workspace/.agents/workflows/code-implementation/workflow.yaml` | Ler - referencia do workflow legado |
| `lib/data/parsers/workspace_parser.dart` | Ler - shape historico de parsing antes da migracao monorepo |
| `apps/observatory/assets/mock_workspace/.agents/agents/*.md` | Criar - corpus de agentes markdown-frontmatter |
| `apps/observatory/assets/mock_workspace/.agents/workflows/*.md` | Criar - corpus de workflows globais markdown-frontmatter |

### How

1. Use Task 0001's manifest as the source of truth for filenames and required counts.
2. Promote the prompt's required agent and workflow names directly instead of renaming them to match the legacy corpus.
3. Keep frontmatter compact but sufficient for graph relationships, especially `skills`, `workflows`, and `uses_skills`.
4. Write bodies that future UI screens can render as realistic detail content instead of placeholder one-liners.

### Why

The app's harness visibility screens depend on agent and workflow assets being real markdown files, not inferred objects. If this slice stays in YAML or remains underspecified, the parser wave and graph views will have no trustworthy source corpus to operate on.

---

## ⛔ Anti-Hallucination Guardrails

> [!CAUTION]
> DO NOT reuse the old generic agent names (`orchestrator`, `planner`, `coder`) as substitutes for the prompt's required filenames.

> [!IMPORTANT]
> Every created agent and workflow must be traceable back to Task 0001's manifest and the exact required names in `prompt.txt`.

---

## 📋 Completion Evidence (preenchido pelo agente executor)

- **Arquivos criados/modificados**:
  - assets/mock_workspace/.agents/agents/architect-orchestrator.md
  - assets/mock_workspace/.agents/agents/builder-orchestrator.md
  - assets/mock_workspace/.agents/agents/reviewer-orchestrator.md
  - assets/mock_workspace/.agents/agents/gt-harness-architect.md
  - assets/mock_workspace/.agents/agents/gt-code-quality-reviewer.md
  - assets/mock_workspace/.agents/agents/gt-security-reviewer.md
  - assets/mock_workspace/.agents/agents/gt-external-intelligence-analyst.md
  - assets/mock_workspace/.agents/agents/gt-task-architect.md
  - assets/mock_workspace/.agents/agents/gt-wave-orchestrator.md
  - assets/mock_workspace/.agents/workflows/gt-ganthritor-onboard.md
  - assets/mock_workspace/.agents/workflows/architect-orchestration.md
  - assets/mock_workspace/.agents/workflows/builder-orchestration.md
  - assets/mock_workspace/.agents/workflows/reviewer-orchestration.md
  - assets/mock_workspace/.agents/workflows/gt-create-tasks.md
  - assets/mock_workspace/.agents/workflows/plan-evidence-to-tasks.md
  - assets/mock_workspace/.agents/workflows/audit-tasks.md
  - assets/mock_workspace/.agents/workflows/gt-harness-architecture.md
  - assets/mock_workspace/.agents/workflows/gt-code-review.md
  - assets/mock_workspace/.agents/workflows/gt-verify-task-completion.md
  - assets/mock_workspace/.agents/workflows/gt-research-orchestration.md
- **Testes que verificam o trabalho**: rg frontmatter validation, file count check
- **Resultado dos comandos de validacao**: PASS — 9 agents, 11 workflows, all frontmatter fields present
- **Entrada no CHANGELOG**: N/A (Task 0002 scope is fixture creation only; changelog corpus is separate task)
- **Agent-wiki / docs institucionalizacao**: N/A
- **Agente executor**: Hermes Agent (subagent)
- **Data de conclusao**: 2026-06-07

---


- **Live corpus root (path-to-100 2026-07-18)**: `apps/observatory/assets/mock_workspace/` (historical `assets/mock_workspace/` paths in older evidence are monorepo-stale)
## 📋 Review Ledger

| Date | Reviewer | Score | Verdict | Notes |
|------|----------|-------|---------|-------|
| 2026-06-13 | gt-build-review workflow | 100/100 | APPROVED | All exit conditions met. 9 agents and 11 workflows created with valid frontmatter. External blockers (Flutter SDK) documented. Review report: `docs/reports/build-gate-review/0002-review.md` |
| 2026-06-14 | reviewers | 95/100 | PASS WITH NOTES | Independent live check found 9 agents and 11 global workflows in `apps/observatory/assets/mock_workspace/.agents/`; required frontmatter keys and non-empty bodies passed; agent/workflow references resolve to manifest skills/workflows. Note: task prose/evidence still uses historical `assets/mock_workspace/...` paths while live app corpus is under `apps/observatory/assets/mock_workspace/...`; inherited from Task 0001 contract drift, not blocking this fixture slice. Commands: `rg --files ...agents ...workflows`; PyYAML frontmatter/reference checks; `python3 tool/validate_mock_workspace.py --project-root apps/observatory`. |


### Path-to-100 Closeout — 2026-07-18 (builders)

- **Residual fixed**: Monorepo evidence paths refreshed; live validator + agent/workflow counts re-proved under `apps/observatory/assets/mock_workspace/`.
- **Commands**:
  - `python3 tool/validate_mock_workspace.py --project-root apps/observatory` → EXIT 0
  - agents=9, workflows=11 under app-local corpus
- **Remaining**: None for fixture exits.
- **Lane**: remain in `docs/tasks/03-review/` (reviewers promote)


### Review Ledger — 2026-07-18 path100 independent re-review (BATCH R1)

| Date | Reviewer | Score | Verdict | Notes |
| --- | --- | --- | --- | --- |
| 2026-07-18 | reviewers (BATCH R1 independent) | 100/100 | ACCEPTED_100 | Live re-validation + path-to-100 residuals closed. Report: `docs/reports/review-wave-2026-07-18/task-0002-path100-rereview.md` |

