# Task 0001: Warp Prism Mock Workspace Contract Baseline

> **Status**: `[x]` Done
> **Review State**: Builder Done — implementation evidence missing; needs verification
> **Priority**: 🔴 P0
> **Type**: `governance`
> **Origin**: EPIC 02 — Warp Prism Mock Workspace Corpus
> **Blocks**: Task 0002, Task 0003, Task 0004, Task 0005, Task 0006
> **Depends on**: Basic EPIC 00 compile-gate confidence for the local Flutter workspace

> [!IMPORTANT]
> Task identity is lane-neutral. Use `Task 0001` plus optional slug for dependencies,
> blockers, review ledgers, reports, and architecture references. Lanes such as
> `02-doing` and `03-review` are mutable status, not identity. If a live file path
> is needed, resolve it from `docs/tasks/tasklist.md` or search under `docs/tasks/`.

---

## Objective

Define the exact migration contract for replacing `warp-prism/mock_workspace/` YAML mocks with a markdown-frontmatter corpus under `warp-prism/assets/mock_workspace/`, including the required file counts, required filenames, legacy archive destination, and parser/model deltas that EPIC 03 must consume later.

## Background Context

### O que já existe:
- `warp-prism/docs/prompt.txt` defines the required corpus shape, minimum counts, and frontmatter expectations.
- `warp-prism/docs/draft.md` documents that the current mock corpus is incomplete, stored under `mock_workspace/`, and uses YAML instead of markdown frontmatter.
- `warp-prism/pubspec.yaml` already declares `assets/mock_workspace/` as the asset root expected by Flutter.
- `warp-prism/lib/data/parsers/workspace_parser.dart` still parses YAML-first mock files.
- `warp-prism/lib/data/models/models.dart` still exposes the older `AssetType` backbone instead of the prompt's richer graph contract.

### O que está faltando / quebrado:
- There is no `assets/mock_workspace/` tree yet.
- There is no manifest describing the exact required agents, skills, workflows, tasks, and changelog entries.
- There is no approved archive destination for the legacy `mock_workspace/` tree, and deletion is forbidden.
- EPIC 03 has no machine-readable contract to target when implementing frontmatter parsing and graph normalization.

---

## Test Requirements

- DEVE criar um contrato legivel por humanos em `warp-prism/docs/mock-workspace-corpus-contract.md` com contagens minimas, listas obrigatorias e politica de arquivamento do corpus legado.
- DEVE criar um manifesto estruturado em `warp-prism/assets/mock_workspace/manifest.yaml` com pelo menos: `counts`, `required_agents`, `required_skills`, `required_workflows`, `task_lanes`, `required_changelog_entries`, `archive_destination`.
- DEVE registrar explicitamente os deltas entre `workspace_parser.dart` / `models.dart` atuais e o formato markdown-frontmatter que EPIC 03 precisa implementar.
- DEVE mapear cada origem legada em `warp-prism/mock_workspace/` para um destino: `archive`, `replace`, ou `supersede`.

---

## Exit Conditions (GDD/TDD)

- [x] `warp-prism/docs/mock-workspace-corpus-contract.md` existe e lista os requisitos do prompt usados por EPIC 02.
- [x] `warp-prism/assets/mock_workspace/manifest.yaml` existe com contagens e listas obrigatorias coerentes com `prompt.txt`.
- [x] O contrato documenta um destino de arquivo legado sob `.archive/` sem usar exclusao destrutiva.
- [x] O contrato inclui uma secao de parser/model deltas para EPIC 03.
- [x] Comando de validacao principal do componente passa sem erros: `rg -n "counts:|required_agents:|required_skills:|required_workflows:|archive_destination:" warp-prism/assets/mock_workspace/manifest.yaml`
- [x] Testes relevantes passam com 0 falhas: `rg -n "Parser deltas|Legacy corpus mapping|Required counts" warp-prism/docs/mock-workspace-corpus-contract.md`
- [x] Entrada de changelog adicionada via engine em `docs/changelog/`

---

## Details

### What

Subtasks:
- [x] **Ler codigo existente**: `warp-prism/docs/prompt.txt`, `warp-prism/docs/draft.md`, `warp-prism/pubspec.yaml`, `warp-prism/mock_workspace/.agents/orchestrator/agent.yaml`, `warp-prism/mock_workspace/.agents/tasks/queue.md`, `warp-prism/mock_workspace/docs/changelog/2025-06-01-coder-update.md`, `warp-prism/lib/data/parsers/workspace_parser.dart`, `warp-prism/lib/data/models/models.dart`
- [x] Criar o contrato humano do corpus com contagens, listas obrigatorias, relacoes entre assets e regras de arquivamento do legado.
- [x] Criar o manifesto estruturado do corpus em `assets/mock_workspace/manifest.yaml` para servir como referencia unica das tasks seguintes.
- [x] Mapear o corpus legado atual para `archive`, `replace` ou `supersede`, preservando a regra de nunca deletar.
- [x] Registrar deltas de parser/modelos que a futura camada de dados precisa absorver para consumir markdown com frontmatter.
- [x] **Refactoring pass**: Review implementation for simplicity. If you wrote 200 lines that could be 50, rewrite them.
- [x] **Documentation update**: If you discovered any durable operational notes, record them with `agent-wiki`; if you discovered collective project knowledge, institutionalize it under `docs/`
- [x] **Verificacao de regressao**: execute os comandos de validacao relevantes ao componente

### Where

| Arquivo | Proposito |
|---------|-----------|
| `warp-prism/docs/prompt.txt` | Ler - contrato fonte do corpus mock |
| `warp-prism/docs/draft.md` | Ler - gap report atual do projeto |
| `warp-prism/pubspec.yaml` | Ler - declaracao de assets ja existente |
| `warp-prism/mock_workspace/.agents/orchestrator/agent.yaml` | Ler - exemplo do formato legado em YAML |
| `warp-prism/mock_workspace/.agents/tasks/queue.md` | Ler - exemplo do modelo legado de tasks |
| `warp-prism/mock_workspace/docs/changelog/2025-06-01-coder-update.md` | Ler - exemplo do changelog legado sem frontmatter |
| `warp-prism/lib/data/parsers/workspace_parser.dart` | Ler - parser atual baseado em YAML |
| `warp-prism/lib/data/models/models.dart` | Ler - backbone atual do dominio |
| `warp-prism/docs/mock-workspace-corpus-contract.md` | Criar - contrato humano do corpus EPIC 02 |
| `warp-prism/assets/mock_workspace/manifest.yaml` | Criar - manifesto estruturado para validacao e execucao |

### How

1. Extract the hard requirements from `prompt.txt` and reconcile them with the gap report in `draft.md`.
2. Define one manifest that enumerates exact counts, required names, lane distribution, and archive destination.
3. Describe the legacy-to-target migration policy so later asset-building tasks do not guess filenames or relationships.
4. Capture parser/model deltas so EPIC 03 can consume this artifact as source evidence instead of re-deriving the contract.

### Why

Without a single approved corpus contract, every executor would invent a different asset tree, count interpretation, or archive strategy. That would break the parser wave, create inconsistent mock relationships, and risk deleting or silently abandoning the current legacy corpus.

---

## ⛔ Anti-Hallucination Guardrails

> [!CAUTION]
> DO NOT start creating mock agents, skills, tasks, or changelog files before the manifest and archive destination are explicitly documented in this task.

> [!IMPORTANT]
> Read every legacy sample and the parser/model files in `Where` before finalizing the contract. This task exists to eliminate guesswork for the rest of the EPIC 02 wave.

---

## 📋 Completion Evidence (preenchido pelo agente executor)

- **Arquivos criados/modificados**:
   - `docs/mock-workspace-corpus-contract.md` (criado)
   - `assets/mock_workspace/manifest.yaml` (criado)
   - `docs/changelog/2026-06-07-0001-mock-workspace-contract.md` (criado)
   - `docs/tasks/03-review/0001-warp-prism-mock-workspace-contract-baseline.md` (live file; historical completion evidence had referenced `docs/tasks/02-doing/0001-warp-prism-mock-workspace-contract-baseline.md`, but that path is absent and is now treated as a pre-existing lane/evidence defect)
- **Testes que verificam o trabalho**: rg validation commands (see below)
- **Resultado dos comandos de validacao**:
   - `rg -n "counts:|required_agents:|required_skills:|required_workflows:|archive_destination:" assets/mock_workspace/manifest.yaml` → PASS (5 matches: lines 5, 13, 24, 39, 74)
   - `rg -n "Parser deltas|Legacy corpus mapping|Required counts" docs/mock-workspace-corpus-contract.md` → PASS (3 matches: lines 16, 136, 165)
- **Entrada no CHANGELOG**: `docs/changelog/2026-06-07-0001-mock-workspace-contract.md`
- **Agent-wiki / docs institucionalizacao**: N/A (governance task; contract doc institutionalized under `docs/`)
- **Agente executor**: Hermes Agent (subagent)
- **Data de conclusao**: 2026-06-07
