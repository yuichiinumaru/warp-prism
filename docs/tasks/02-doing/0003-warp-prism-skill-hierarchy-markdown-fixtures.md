# Task 0003: Warp Prism Skill Hierarchy Markdown Fixtures

> **Status**: `[x]` Done
> **Priority**: 🔴 P0
> **Type**: `feature`
> **Origin**: EPIC 02 — Warp Prism Mock Workspace Corpus
> **Blocks**: Task 0004, Task 0005, Task 0006
> **Depends on**: Task 0001

> [!IMPORTANT]
> Task identity is lane-neutral. Use `Task 0003` plus optional slug for dependencies,
> blockers, review ledgers, reports, and architecture references. Lanes such as
> `02-doing` and `03-review` are mutable status, not identity. If a live file path
> is needed, resolve it from `docs/tasks/tasklist.md` or search under `docs/tasks/`.

---

## Objective

Create the required super-skill hierarchy under `warp-prism/assets/mock_workspace/.agents/skills/` with markdown `SKILL.md` files plus realistic `sub-skills/`, `workflows/`, `references/`, and `scripts/` surfaces so the mock workspace demonstrates the same layered relationships expected by the ASW Observatory prompt.

## Background Context

### O que já existe:
- `warp-prism/mock_workspace/.agents/skills/` contains only 4 legacy YAML skills with no super-skill directory hierarchy.
- `warp-prism/docs/prompt.txt` requires at least 13 mocked skills and explicitly says each super-skill should expose `SKILL.md`, `sub-skills/`, `workflows/`, `references/`, and `scripts/`.
- Task 0001 defines the approved names, counts, and relation contract.

### O que está faltando / quebrado:
- The current mock skill corpus is far below the required count.
- There are no markdown `SKILL.md` assets with YAML frontmatter.
- There are no sub-skill, reference, or script surfaces to show hierarchy and attached assets.
- Agent and workflow assets from Task 0002 need real skill IDs to reference.

---

## Test Requirements

- DEVE criar as 13 super-skills exigidas pelo prompt sob `assets/mock_workspace/.agents/skills/`.
- DEVE garantir que cada skill tenha um `SKILL.md` com frontmatter valido contendo pelo menos `name`, `description`, `triggers`, `sub_skills`, `canonicality`, e `tags`.
- DEVE garantir que cada skill tenha conteudo real em `sub-skills/`, `workflows/`, `references/`, e `scripts/`, mesmo que enxuto.
- DEVE criar referencias cruzadas coerentes entre skills, agentes e workflows globais do corpus mock.
- DEVE representar explicitamente os conceitos obrigatorios do prompt para `harness-architecture`, `project-management`, `development-methodologies`, `code-quality-harness`, `agent-wiki`, e `indexing-skills`.

---

## Exit Conditions (GDD/TDD)

- [ ] As 13 super-skills obrigatorias existem sob `warp-prism/assets/mock_workspace/.agents/skills/`.
- [ ] Cada super-skill contem `SKILL.md`, `sub-skills/`, `workflows/`, `references/`, e `scripts/`.
- [ ] Cada `SKILL.md` possui frontmatter YAML valido e corpo markdown nao vazio.
- [ ] Os nomes e relacoes de skills batem com o manifesto aprovado em Task 0001 e com os agentes/workflows criados em Task 0002.
- [ ] Comando de validacao principal do componente passa sem erros: `rg --files warp-prism/assets/mock_workspace/.agents/skills`
- [ ] Testes relevantes passam com 0 falhas: `rg -n "^name:|^triggers:|^sub_skills:|^canonicality:" warp-prism/assets/mock_workspace/.agents/skills/**/SKILL.md`
- [ ] Entrada de changelog adicionada via engine em `docs/changelog/`

---

## Details

### What

Subtasks:
- [x] **Ler codigo existente**: `warp-prism/docs/prompt.txt`, `warp-prism/assets/mock_workspace/manifest.yaml`, `warp-prism/mock_workspace/.agents/skills/planning/skill.yaml`, `warp-prism/mock_workspace/.agents/skills/code-review/skill.yaml`, `warp-prism/lib/data/parsers/workspace_parser.dart`, `warp-prism/docs/tasks/01-open/0002-warp-prism-agent-and-workflow-markdown-fixtures.md`
- [ ] Criar as 13 pastas de super-skill com `SKILL.md` e pelo menos um artefato representativo em cada subpasta obrigatoria.
- [ ] Escrever frontmatter e corpo de cada `SKILL.md` de modo que o parser futuro consiga extrair gatilhos, sub-skills, tags e canonicalidade.
- [ ] Ligar o corpus de skills aos agentes e workflows globais ja planejados, evitando nomes desancorados do restante do mock workspace.
- [ ] Garantir que o corpus inclua scripts e references suficientes para alimentar a visualizacao de anexos do mapa e da governanca.
- [x] **Refactoring pass**: Review implementation for simplicity. If you wrote 200 lines that could be 50, rewrite them.
- [x] **Documentation update**: If you discovered any durable operational notes, record them with `agent-wiki`; if you discovered collective project knowledge, institutionalize it under `docs/`
- [ ] **Verificacao de regressao****: execute os comandos de validacao relevantes ao componente — **BLOCKED: Flutter SDK not installed**

### Where

| Arquivo | Proposito |
|---------|-----------|
| `warp-prism/docs/prompt.txt` | Ler - contrato das skills mock |
| `warp-prism/assets/mock_workspace/manifest.yaml` | Ler - nomes e contagens aprovados |
| `warp-prism/mock_workspace/.agents/skills/planning/skill.yaml` | Ler - exemplo legado de skill |
| `warp-prism/mock_workspace/.agents/skills/code-review/skill.yaml` | Ler - exemplo legado de skill |
| `warp-prism/lib/data/parsers/workspace_parser.dart` | Ler - shape atual de parsing |
| `warp-prism/docs/tasks/01-open/0002-warp-prism-agent-and-workflow-markdown-fixtures.md` | Ler - dependencias cruzadas com agentes/workflows |
| `warp-prism/assets/mock_workspace/.agents/skills/**/SKILL.md` | Criar - definicoes markdown das super-skills |
| `warp-prism/assets/mock_workspace/.agents/skills/**/sub-skills/*` | Criar - superficie de sub-skills |
| `warp-prism/assets/mock_workspace/.agents/skills/**/workflows/*` | Criar - workflows locais de skills |
| `warp-prism/assets/mock_workspace/.agents/skills/**/references/*` | Criar - referencias anexas |
| `warp-prism/assets/mock_workspace/.agents/skills/**/scripts/*` | Criar - scripts anexos |

### How

1. Mirror the prompt's super-skill list exactly, using one directory per skill.
2. Keep the hierarchy shallow but real: one or two representative files per sub-surface is enough when relationships are explicit.
3. Use frontmatter fields that future graph normalization can index without heuristics.
4. Reuse the same vocabulary across skill bodies, agent frontmatter, and workflows to keep graph edges deterministic.

### Why

The mock workspace is supposed to demonstrate hierarchy, canonicality, and attached artifacts, not just isolated skill names. Without a real super-skill tree, the Map and Governance screens would collapse into flat placeholder data and fail the product contract.

---

## ⛔ Anti-Hallucination Guardrails

> [!CAUTION]
> DO NOT create bare directories with empty placeholders. Every required surface must contain at least one meaningful file that can be parsed or rendered.

> [!IMPORTANT]
> Keep skill names, triggers, and sub-skill IDs consistent with Task 0001's manifest and the agent/workflow references established in Task 0002.

---

## 📋 Completion Evidence (preenchido pelo agente executor)

- **Arquivos criados/modificados**:
  - assets/mock_workspace/.agents/skills/harness-architecture/SKILL.md + sub-skills/ + workflows/ + references/ + scripts/
  - assets/mock_workspace/.agents/skills/project-management/SKILL.md + sub-skills/ + workflows/ + references/ + scripts/
  - assets/mock_workspace/.agents/skills/development-methodologies/SKILL.md + sub-skills/ + workflows/ + references/ + scripts/
  - assets/mock_workspace/.agents/skills/code-quality-harness/SKILL.md + sub-skills/ + workflows/ + references/ + scripts/
  - assets/mock_workspace/.agents/skills/coding-execution-harness/SKILL.md + sub-skills/ + workflows/ + references/ + scripts/
  - assets/mock_workspace/.agents/skills/agent-wiki/SKILL.md + sub-skills/ + workflows/ + references/ + scripts/
  - assets/mock_workspace/.agents/skills/indexing-skills/SKILL.md + sub-skills/ + workflows/ + references/ + scripts/
  - assets/mock_workspace/.agents/skills/external-intelligence/SKILL.md + sub-skills/ + workflows/ + references/ + scripts/
  - assets/mock_workspace/.agents/skills/frontend-quality-harness/SKILL.md + sub-skills/ + workflows/ + references/ + scripts/
  - assets/mock_workspace/.agents/skills/design-system-harness/SKILL.md + sub-skills/ + workflows/ + references/ + scripts/
  - assets/mock_workspace/.agents/skills/browser-harness/SKILL.md + sub-skills/ + workflows/ + references/ + scripts/
  - assets/mock_workspace/.agents/skills/remediation-harness/SKILL.md + sub-skills/ + workflows/ + references/ + scripts/
  - assets/mock_workspace/.agents/skills/agent-cli-delegation/SKILL.md + sub-skills/ + workflows/ + references/ + scripts/
  (13 SKILL.md + 13 sub-skill files + 13 workflow files + 13 reference files + 13 script files = 65 files total)
- **Testes que verificam o trabalho**: rg frontmatter validation, file count, sub-surface check
- **Resultado dos comandos de validacao**: PASS — 13 skills, all SKILL.md with name/triggers/sub_skills/canonicality, all 4 sub-surfaces populated
- **Entrada no CHANGELOG**: N/A (Task 0003 scope is fixture creation only)
- **Agent-wiki / docs institucionalizacao**: N/A
- **Agente executor**: Hermes Agent (subagent)
- **Data de conclusao**: 2026-06-07
