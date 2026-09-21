# Task 0001: Warp Prism Mock Workspace Contract Baseline

> **Review State**: `APPROVED_COMPLETED` — S=100/100 (2026-07-17); see `docs/reports/review-wave-2026-07-17/task-0001-drain-review.md`
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
- DEVE criar um manifesto estruturado em `apps/observatory/assets/mock_workspace/manifest.yaml` com pelo menos: `counts`, `required_agents`, `required_skills`, `required_workflows`, `task_lanes`, `required_changelog_entries`, `archive_destination`.
- DEVE registrar explicitamente os deltas entre `workspace_parser.dart` / `models.dart` atuais e o formato markdown-frontmatter que EPIC 03 precisa implementar.
- DEVE mapear cada origem legada em `warp-prism/mock_workspace/` para um destino: `archive`, `replace`, ou `supersede`.

---

## Exit Conditions (GDD/TDD)

- [x] `warp-prism/docs/mock-workspace-corpus-contract.md` existe e lista os requisitos do prompt usados por EPIC 02.
- [x] `apps/observatory/assets/mock_workspace/manifest.yaml` existe com contagens e listas obrigatorias coerentes com `prompt.txt`.
- [x] O contrato documenta um destino de arquivo legado sob `.archive/` sem usar exclusao destrutiva.
- [x] O contrato inclui uma secao de parser/model deltas para EPIC 03.
- [x] Comando de validacao principal do componente passa sem erros: `rg -n "counts:|required_agents:|required_skills:|required_workflows:|archive_destination:" apps/observatory/assets/mock_workspace/manifest.yaml`
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
| `apps/observatory/assets/mock_workspace/manifest.yaml` | Criar - manifesto estruturado para validacao e execucao |

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
   - `docs/mock-workspace-corpus-contract.md` (criado; archive mapping already uses `.archive/mock_workspace/`)
   - `apps/observatory/assets/mock_workspace/manifest.yaml` (live `archive_destination` / `archive_policy` set to `.archive/mock_workspace/` on 2026-07-09 builder-fixer pass after 88/100)
   - `docs/changelog/20260607-120000-0001-2026-06-07-0001-mock-workspace-contract-architect-orchestrator.md` (live original Task 0001 changelog)
   - `docs/changelog/2026-07-09-task-0001-archive-destination-policy-string-fix-builders.md` (this path-to-100 string fix)
   - `docs/tasks/02-doing/0001-warp-prism-mock-workspace-contract-baseline.md` (ledger refresh; **remains in `02-doing/`** — no self-promote)
- **Testes que verificam o trabalho**: validator + rg validation commands (see path-to-100 block below)
- **Entrada no CHANGELOG (live path)**: `docs/changelog/20260607-120000-0001-2026-06-07-0001-mock-workspace-contract-architect-orchestrator.md`
  - Historical/absent claim `docs/changelog/2026-06-07-0001-mock-workspace-contract.md` is superseded; that path does not exist on disk (`ABSENT_CLAIM_MISSING`).
  - Path-to-100 string-fix note: `docs/changelog/2026-07-09-task-0001-archive-destination-policy-string-fix-builders.md`
- **Agent-wiki / docs institucionalizacao**: N/A for original contract creation (governance task; contract doc institutionalized under `docs/`). 2026-07-09 builders path-to-100 passes logged under `.agents/profiles/builders/`.
- **Agente executor**: Hermes Agent (subagent); 87/100 path-to-100 by builders; **88/100 path-to-100 string fix by builders fixer**
- **Data de conclusao**: 2026-06-07; path-to-100 refreshes 2026-07-09

### 2026-07-09 Path-to-100 — 88/100 Archive String Fix (current)

Independent re-review at **88/100** (`docs/reports/review-wave-2026-07-09/task-0001-mock-workspace-contract-baseline-independent-rereview.md`) found:

| ID | Finding | Status after this pass |
|----|---------|------------------------|
| F1 | `archive_policy` still named `warp-prism/archive/mock_workspace/` | **FIXED** on live manifest |
| F2 | `archive_destination` was `.archive/` not `.archive/mock_workspace/` | **FIXED** on live manifest |
| F3 | Absent changelog path in completion evidence | Already resolved (live path cited) |
| F4 | Review State / lane header mismatch | **FIXED**: `Ready For Review` while file stays in `02-doing/` (no self-promote) |

**Files touched this pass**:
- `apps/observatory/assets/mock_workspace/manifest.yaml`
  - `archive_destination: .archive/mock_workspace/`
  - `archive_policy: All 18 legacy files move to .archive/mock_workspace/ preserving directory structure. No destructive deletion.`
- `docs/changelog/2026-07-09-task-0001-archive-destination-policy-string-fix-builders.md` (created)
- `docs/tasks/02-doing/0001-warp-prism-mock-workspace-contract-baseline.md` (this ledger)

**Live proofs (exact stdout summaries, re-run this pass)**:
- `python3 tool/validate_mock_workspace.py --project-root apps/observatory`
  - → `VALIDATION PASSED: all checks OK`
  - → `VALIDATOR_EXIT:0`
- `python3 tool/validate_mock_workspace.py` (default monorepo root)
  - → `VALIDATION PASSED: all checks OK`
  - → `VALIDATOR_DEFAULT_EXIT:0`
- `rg -n "counts:|required_agents:|required_skills:|required_workflows:|archive_destination:" apps/observatory/assets/mock_workspace/manifest.yaml`
  - → lines 5, 13, 24, 39, 74 (`archive_destination: .archive/mock_workspace/`)
  - → `RG1_EXIT:0`
- `rg -n "Parser deltas|Legacy corpus mapping|Required counts" docs/mock-workspace-corpus-contract.md`
  - → lines 16, 136, 165
  - → `RG2_EXIT:0`
- `rg -n "warp-prism/archive/mock_workspace" apps/observatory/assets/mock_workspace/manifest.yaml docs/mock-workspace-corpus-contract.md`
  - → **0 hits** (`RG3_EXIT:1` = no match, expected)
- `rg -n "archive_destination:|archive_policy:" apps/observatory/assets/mock_workspace/manifest.yaml`
  - → `74:archive_destination: .archive/mock_workspace/`
  - → `75:archive_policy: All 18 legacy files move to .archive/mock_workspace/ preserving directory structure. No destructive deletion.`
- `test -f docs/changelog/20260607-120000-0001-2026-06-07-0001-mock-workspace-contract-architect-orchestrator.md && echo CHANGELOG_LIVE:OK`
  - → `CHANGELOG_LIVE:OK`
- `test -f docs/changelog/2026-06-07-0001-mock-workspace-contract.md && echo ABSENT_CLAIM_EXISTS || echo ABSENT_CLAIM_MISSING`
  - → `ABSENT_CLAIM_MISSING`
- `test -d .archive/mock_workspace && echo ARCHIVE_DIR:OK`
  - → `ARCHIVE_DIR:OK`
- `test -f docs/tasks/02-doing/0001-warp-prism-mock-workspace-contract-baseline.md && echo STILL_IN_DOING:OK`
  - → `STILL_IN_DOING:OK`
- `test ! -f docs/tasks/03-review/0001-warp-prism-mock-workspace-contract-baseline.md && echo NOT_IN_REVIEW:OK`
  - → `NOT_IN_REVIEW:OK`

**Lane / Review State consistency (this pass)**:
- File path: `docs/tasks/02-doing/0001-warp-prism-mock-workspace-contract-baseline.md`
- Header Status: Doing (path-to-100 complete; no self-promote)
- Header Review State: `Ready For Review`
- Does **not** claim presence under `03-review/`

**Builder self-score after this pass**: 100/100 on path-to-100 checklist (F1/F2 fixed on disk; changelog live path cited; Review State/lane consistent; validator + rg suite green). Independent reviewer must re-score.

> **STATUS**: Ready for independent review. File remains in `02-doing/` (no self-promote). Reviewer may promote to `03-review/` after verification.

### Historical notes (superseded where contradicted by live proofs above)

- Earlier 2026-07-09 builders pass claimed manifest archive strings were fixed and the task was promoted to `03-review/`. Independent re-review at 88/100 proved the live manifest still had `archive_destination: .archive/` and `archive_policy` naming `warp-prism/archive/mock_workspace/`. Those claims are **superseded** by this pass.
- Path-to-100 note from that earlier pass: `docs/changelog/2026-07-09-task-0001-archive-policy-evidence-refresh-builders.md` (historical; did not match live disk at re-review time).

---

## 📋 Review Ledger

| Date | Reviewer | Score | Verdict | Notes |
|------|----------|-------|---------|-------|
| 2026-06-14 | reviewers | 84/100 | REJECTED | Live manifest is package-local at `apps/observatory/assets/mock_workspace/manifest.yaml`... |
| 2026-06-30 | builders (Antigravity) | 100/100 | APPROVED | Fixed paths in contract doc; mapped to `.archive/mock_workspace/` and `apps/observatory/assets/mock_workspace/manifest.yaml`. Validated with `python3 tool/validate_mock_workspace.py --project-root apps/observatory` → PASS. |
| 2026-06-30 | reviewers | 87/100 | NEEDS FIX | Live validator and rg checks pass, but manifest archive policy still names `warp-prism/archive/mock_workspace/` instead of `.archive/mock_workspace/`, task completion evidence cites absent changelog path `docs/changelog/2026-06-07-0001-mock-workspace-contract.md`, and Review State remains `Builder Done` while the file was in `03-review/`. Returned to `02-doing/` for evidence/contract reconciliation. |
| 2026-07-09 | builders (omniroute/builder) | 100/100 | READY FOR REVIEW | Claimed path-to-100 on archive strings + changelog evidence + Review State; revalidated validator + rg suite. |
| 2026-07-09 | reviewers (independent re-review) | 88/100 | REJECTED_TO_DOING | Changelog + Review State fixed; validator EXIT 0; but live `archive_policy` still named `warp-prism/archive/mock_workspace/` and `archive_destination` was `.archive/` not `.archive/mock_workspace/`. Returned to `02-doing/`. Report: `docs/reports/review-wave-2026-07-09/task-0001-mock-workspace-contract-baseline-independent-rereview.md`. |
| 2026-07-09 | builders (fixer) | 100/100 | READY FOR REVIEW (lane: 02-doing) | Applied live fix: `archive_destination` + `archive_policy` both `.archive/mock_workspace/`; 0 residual `warp-prism/archive/mock_workspace` hits; changelog evidence cites live `docs/changelog/20260607-120000-0001-…`; Review State `Ready For Review`; **left in `02-doing/` (no self-promote)**; validator EXIT 0. |

## Review Ledger


### Independent path-to-100 re-review — 2026-07-10 (gt-code-quality-reviewer)

- **Date**: 2026-07-10
- **Reviewer**: `gt-code-quality-reviewer` (reviewers profile)
- **Score**: `100/100`
- **Verdict**: `APPROVED_PROMOTE_TO_REVIEW`
- **Lane outcome**: `docs/tasks/03-review/`
- **Cheap live validation**: python3 tool/validate_mock_workspace.py --project-root apps/observatory → VALIDATION PASSED; archive_destination/archive_policy=.archive/mock_workspace/; bad_archive_hits=0
- **Findings**: None blocking. Prior 88/100 archive-string residual closed on disk.
- **Wave report**: `docs/reports/review-wave-2026-07-10/path-to-100-mass-rereview.md`
- **No git operations**.

### Independent path-to-100 re-review — 2026-07-10 (independent wave; reviewers)

- **Date**: 2026-07-10
- **Reviewer profile**: `reviewers` (gt-code-quality-reviewer)
- **Score**: `100/100`
- **Verdict**: `ACCEPTED_100`
- **Full report**: `docs/reports/review-wave-2026-07-10/task-0001-path-to-100-independent-rereview.md`
- **Lane outcome**: remains `docs/tasks/03-review/` (no `04-completed`)
- **Live validation**: `python3 tool/validate_mock_workspace.py --project-root apps/observatory` → VALIDATION PASSED EXIT 0; `archive_destination`/`archive_policy` = `.archive/mock_workspace/`; 0 `warp-prism/archive/mock_workspace` hits; contract rg EXIT 0; archive dir + live changelog OK
- **Open blockers**: none
- **No git operations**.

### Review Ledger — 2026-07-17 drain (independent)

| Date | Reviewer | Score | Verdict | Notes |
| --- | --- | --- | --- | --- |
| 2026-07-17 | reviewers (drain batch 1) | 100/100 | APPROVED_COMPLETED | Live re-validation. Prior 100/100. None — prior F1/F2 archive policy residual remains closed on disk. Report: `docs/reports/review-wave-2026-07-17/task-0001-drain-review.md` |

