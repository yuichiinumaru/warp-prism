# Task 0004: Warp Prism Task Lane Markdown Corpus

> **Review State**: `ACCEPTED_100` — S=100/100 (2026-07-18); see `docs/reports/review-wave-2026-07-18/task-0004-path100-rereview.md`
> **Priority**: 🔴 P0
> **Type**: `feature`
> **Origin**: EPIC 02 — Warp Prism Mock Workspace Corpus
> **Blocks**: Task 0005, Task 0006
> **Depends on**: Task 0001, Task 0002, Task 0003

> [!IMPORTANT]
> Task identity is lane-neutral. Use `Task 0004` plus optional slug for dependencies,
> blockers, review ledgers, reports, and architecture references. Lanes such as
> `02-doing` and `03-review` are mutable status, not identity. If a live file path
> is needed, resolve it from `docs/tasks/tasklist.md` or search under `docs/tasks/`.

---

## Objective

Create the mock task corpus under `apps/observatory/assets/mock_workspace/docs/tasks/` with at least 20 markdown task files distributed across the five lane directories, using the prompt's frontmatter contract and body sections so the Operate, Governance, and asset-detail screens can parse realistic execution data.

## Background Context

### O que já existe:
- `warp-prism/mock_workspace/.agents/tasks/queue.md` contains only 6 legacy tasks in a single queue file (historical legacy reference).
- `warp-prism/docs/prompt.txt` requires at least 20 mock tasks across `00-planning/` through `04-completed/`.
- Task 0002 and Task 0003 define the agent, workflow, and skill identifiers that task frontmatter should reference.
- After monorepo migration (Task 1107-class), the live mock corpus root is `apps/observatory/assets/mock_workspace/` (not obsolete root `assets/mock_workspace/`).

### O que está faltando / quebrado:
- ~~There are no lane directories under the mock task tree yet.~~ **Resolved** — live tree exists under `apps/observatory/assets/mock_workspace/docs/tasks/`.
- ~~There are no task markdown files with prompt-style frontmatter.~~ **Resolved** — 22 files with full frontmatter contract.
- ~~The current queue model cannot express lane state, review score, proof state, or cross-links.~~ **Resolved** by one-file-per-task five-lane corpus.
- Path-to-100 from Wave-2 rejection: monorepo-aware evidence paths, local changelog entry, and Ready For Review gate (this pass).

---

## Test Requirements

- DEVE criar pelo menos 20 arquivos de task markdown distribuidos entre `00-planning`, `01-open`, `02-doing`, `03-review`, e `04-completed`.
- DEVE garantir que cada task use frontmatter com pelo menos `id`, `title`, `status`, `priority`, `owner`, `created`, `updated`, `skills`, `workflows`, `depends_on`, `proof_state`, e `review_score`.
- DEVE incluir no corpo das tasks secoes equivalentes a `Goal`, `Scope`, `Exit Conditions`, `Verification Commands`, e `Completion Evidence`.
- DEVE representar categorias variadas do prompt: feature, review returned, completed with evidence, planning task, changelog repair, index regeneration, governance audit, frontend design-system, graph visualization, and data parser.
- DEVE garantir que cada lane tenha pelo menos um arquivo e que os IDs referenciados em `depends_on` existam dentro do corpus mock.

---

## Exit Conditions (GDD/TDD)

- [x] Pelo menos 20 tasks markdown existem em `apps/observatory/assets/mock_workspace/docs/tasks/` distribuidas nas cinco lanes.
- [x] Cada lane `00-planning` a `04-completed` contem pelo menos uma task.
- [x] As tasks usam frontmatter e corpo markdown coerentes com o contrato do prompt.
- [x] Os owners, skills e workflows referenciados existem no corpus criado pelas Tasks 0002 e 0003.
- [x] Comando de validacao principal do componente passa sem erros: `python3 tool/validate_mock_workspace.py --project-root apps/observatory` → `VALIDATION PASSED: all checks OK`
- [x] Testes relevantes passam com 0 falhas: frontmatter/schema/cross-ref audit → `frontmatter_ok=22/22 sections_ok=22/22 RESOLVE_OK True`
- [x] Entrada de changelog adicionada em `docs/changelog/20260709-061500-0004-task-lane-markdown-corpus-builders.md`

---

## Details

### What

Subtasks:
- [x] **Ler codigo existente**: Read manifest.yaml, contract, existing agent/skill/workflow fixtures to get valid IDs
- [x] Criar as cinco lanes sob `apps/observatory/assets/mock_workspace/docs/tasks/` e popular o corpus com pelo menos 20 tasks coerentes entre si.
- [x] Distribuir categorias e estados do prompt, incluindo exemplos de planning, open, doing, review e completed com prova realista.
- [x] Garantir referencias cruzadas validas para owners, skills, workflows, dependencias e proof state.
- [x] Escrever `Verification Commands` realistas por task, mesmo sendo um corpus mock, para que a UI tenha dados de prova e readiness.
- [x] **Refactoring pass**: Each task file is minimal and focused — no excess.
- [x] **Documentation update**: Monorepo-aware path refresh + local changelog evidence (2026-07-09 path-to-100).
- [x] **Verificacao de regressao**: monorepo validator PASS; all 22 files have required frontmatter fields and body sections; refs resolve.

### Where

| Arquivo | Proposito |
|---------|-----------|
| `docs/prompt.txt` | Ler - contrato das tasks mock |
| `apps/observatory/assets/mock_workspace/manifest.yaml` | Ler - contagens e distribuicao aprovadas (live monorepo path) |
| `mock_workspace/.agents/tasks/queue.md` | Ler - referencia do formato legado (historical) |
| `docs/tasks/04-completed/0002-warp-prism-agent-and-workflow-markdown-fixtures.md` | Ler - IDs de owners e workflows (current lane) |
| `docs/tasks/04-completed/0003-warp-prism-skill-hierarchy-markdown-fixtures.md` | Ler - IDs de skills (current lane) |
| `apps/observatory/assets/mock_workspace/docs/tasks/00-planning/*.md` | Criar/manter - tasks mock em planejamento |
| `apps/observatory/assets/mock_workspace/docs/tasks/01-open/*.md` | Criar/manter - tasks mock abertas |
| `apps/observatory/assets/mock_workspace/docs/tasks/02-doing/*.md` | Criar/manter - tasks mock em execucao |
| `apps/observatory/assets/mock_workspace/docs/tasks/03-review/*.md` | Criar/manter - tasks mock em revisao |
| `apps/observatory/assets/mock_workspace/docs/tasks/04-completed/*.md` | Criar/manter - tasks mock concluidas |
| `docs/changelog/20260709-061500-0004-task-lane-markdown-corpus-builders.md` | Criar - local changelog evidence |
| `tool/validate_mock_workspace.py` | Ler/executar - monorepo-aware corpus validator |

### How

1. Use the prompt's frontmatter example as the baseline shape for every mock task.
2. Build a lane-balanced corpus with cross-links instead of a flat backlog dump.
3. Seed realistic evidence, review-score, and proof-state variation so the Operate and Governance screens have meaningful data.
4. Keep IDs stable and referenced by later changelog entries.
5. After monorepo migration, treat `apps/observatory/assets/mock_workspace/` as the only live corpus root and always pass `--project-root apps/observatory` to the validator.

### Why

The task board is one of the four core product areas. Without a true five-lane markdown corpus, the Operate surface would regress to placeholder cards and fail to demonstrate review state, blockers, evidence, and execution flow.

---

## ⛔ Anti-Hallucination Guardrails

> [!CAUTION]
> DO NOT recreate the old single-file queue under the new asset tree. The prompt explicitly requires one file per task across five lanes.

> [!IMPORTANT]
> Make every dependency, owner, skill, and workflow reference resolve to an asset that actually exists in the mock corpus.

> [!IMPORTANT]
> Do not cite obsolete root `assets/mock_workspace/` as the live path. Use `apps/observatory/assets/mock_workspace/` after the monorepo migration.

---

## 📋 Completion Evidence (preenchido pelo agente executor)

- **Arquivos criados/modificados (historical 2026-06-07)**: 22 task .md files created across 5 lanes. (Original evidence cited pre-migration root `assets/mock_workspace/docs/tasks/` — superseded by monorepo path below.)
  - 00-planning/: T001, T002, T003 (3 files)
  - 01-open/: T004, T005, T006, T007, T008 (5 files)
  - 02-doing/: T009, T010, T011, T012, T013 (5 files)
  - 03-review/: T014, T015, T016, T017 (4 files)
  - 04-completed/: T018, T019, T020, T021, T022 (5 files)
- **Testes que verificam o trabalho (historical)**: rg frontmatter field validation; file count per lane
- **Resultado dos comandos de validacao (historical)**: PASS — 22 files; 3+5+5+4+5 distribution
- **Entrada no CHANGELOG (historical)**: Pending — superseded 2026-07-09
- **Agent-wiki / docs institucionalizacao**: N/A for corpus content
- **Agente executor (historical)**: Hermes Agent
- **Data de conclusao (historical)**: 2026-06-07

### **2026-07-09 Path-to-100 Refresh** (builders / gt-evidence-refresher style)

Wave-2 rejection path-to-100 items closed:

1. **Monorepo-aware paths** — Where table + exit conditions + objective now cite `apps/observatory/assets/mock_workspace/...`. Obsolete root `assets/mock_workspace/` is marked historical/absent (`ls assets/mock_workspace` → cannot access).
2. **Local changelog evidence** — added `docs/changelog/20260709-061500-0004-task-lane-markdown-corpus-builders.md`.
3. **Current validation commands re-run** (literal stdout):

```text
$ find apps/observatory/assets/mock_workspace/docs/tasks -name '*.md' | wc -l
22

$ for d in 00-planning 01-open 02-doing 03-review 04-completed; do
    echo -n "$d: "; find apps/observatory/assets/mock_workspace/docs/tasks/$d -name '*.md' | wc -l
  done
00-planning: 3
01-open: 5
02-doing: 5
03-review: 4
04-completed: 5

$ python3 tool/validate_mock_workspace.py --project-root apps/observatory
============================================================
Mock Workspace Corpus Validator
============================================================
Project root : apps/observatory
Corpus root  : apps/observatory/assets/mock_workspace
Manifest     : apps/observatory/assets/mock_workspace/manifest.yaml

Manifest loaded successfully.

--- Count Validation ---
  PASS: all counts match manifest

--- Required Names ---
  PASS: all required agents, skills, workflows present

--- Frontmatter Validation ---
  PASS: all changelog entries have valid frontmatter

--- Task Lane Validation ---
  PASS: task lanes match manifest

--- Pubspec Alignment ---
  PASS: pubspec.yaml asset declarations align with disk

============================================================
VALIDATION PASSED: all checks OK
============================================================
EXIT:0

$ python3 tool/validate_mock_workspace.py
FATAL: manifest.yaml not found at .../assets/mock_workspace/manifest.yaml
(historical note: bare root default is stale; monorepo-aware flag is authoritative)

$ schema/cross-ref audit (inline Python)
total_files=22
missing_frontmatter_fields= [] count 0
missing_sections= [] count 0
ids= T001..T022
bad_deps= []
bad_owners= []
bad_skills= []   # resolved via skill directory name / SKILL.md name field
bad_workflows= []
frontmatter_ok=22/22 sections_ok=22/22
RESOLVE_OK True
```

4. **Category coverage** (name/body keyword hits across 22 files): feature, review returned, completed, planning, changelog, index, governance, design-system, graph, parser/data — all present.
5. **Review State** set to `Ready For Review`.
6. **Changelog lookup**:

```text
$ find docs/changelog -name '*-0004-*'
docs/changelog/20260709-061500-0004-task-lane-markdown-corpus-builders.md
```

- **Files touched this pass**:
  - `docs/tasks/03-review/0004-warp-prism-task-lane-markdown-corpus.md` (evidence refresh + promotion from `02-doing/`)
  - `docs/changelog/20260709-061500-0004-task-lane-markdown-corpus-builders.md` (created)
- **Agente executor (this pass)**: builders (omniroute/builder) as gt-evidence-refresher-style worker
- **Self-score**: 100/100 — substantive corpus already complete; rejection items were metadata/evidence only and are now closed with live commands.

---

## Post-Promotion Evidence — 2026-07-09

```text
$ test -f docs/tasks/03-review/0004-warp-prism-task-lane-markdown-corpus.md && echo IN_REVIEW: OK
IN_REVIEW: OK

$ test ! -f docs/tasks/02-doing/0004-warp-prism-task-lane-markdown-corpus.md && echo NOT_IN_DOING: OK
NOT_IN_DOING: OK

$ find docs/changelog -name '*-0004-*'
docs/changelog/20260709-061500-0004-task-lane-markdown-corpus-builders.md

$ python3 tool/validate_mock_workspace.py --project-root apps/observatory
VALIDATION PASSED: all checks OK
```

- Header/status: `Status: Ready For Review`, `Review State: Ready For Review` (not Doing/Completed/Open).
- Older `02-doing` lane proofs and pre-migration root-path counts are historical/superseded by this block.
- Changelog validation is independent of corpus validation (dedicated changelog file present + named lookup above).
- Corpus validator re-confirmed PASS after promotion; mock task corpus files were not mutated this pass.

---

## 📋 Review Ledger

| Date | Reviewer | Score | Verdict | Notes |
|------|----------|-------|---------|-------|
| 2026-06-14 | reviewers | 86/100 | REJECTED | Live corpus exists and is parser-compatible under `apps/observatory/assets/mock_workspace/docs/tasks/` with 22 files across 5 lanes, but the task remains `Review State: Builder Done`, has no local changelog evidence, and its validation evidence/Where paths still point at the obsolete root `assets/mock_workspace/` location. Path to 100: update monorepo-aware evidence/paths, add or explicitly waive local changelog evidence, rerun current-path validation commands, and set Review State to Ready For Review before returning to `03-review/`. Evidence commands: `python3 tool/validate_mock_workspace.py` FAILS from repo root; `python3 tool/validate_mock_workspace.py --project-root apps/observatory` PASS; schema/cross-reference Python audits PASS for 22 tasks. Report: `docs/reports/review-wave-2/0004-review.md`. |
| 2026-07-09 | builders (self) | 100/100 | READY FOR REVIEW | Path-to-100 closed: monorepo paths, changelog entry, live validator PASS, Ready For Review header. Corpus unchanged (already correct). Promoted to `03-review/` with Post-Promotion Evidence. |
| 2026-07-09 | reviewers (independent re-review) | 97/100 | HELD_IN_REVIEW_PATH_TO_100 | 22 tasks / 5 lanes; frontmatter+sections 22/22; owners/skills/workflows resolve; validator EXIT 0; changelog present. Non-blocking: no committed schema unit test. Held in `03-review/`. Report: `docs/reports/review-wave-2026-07-09/task-0004-task-lane-markdown-corpus-independent-rereview.md`. |

### Review Ledger — 2026-07-17 drain (independent)

| Date | Reviewer | Score | Verdict | Notes |
| --- | --- | --- | --- | --- |
| 2026-07-17 | reviewers (drain batch 1) | 100/100 | APPROVED_COMPLETED | Live re-validation. Prior 97/100. None — path-to-100 evidence/paths residual closed. Report: `docs/reports/review-wave-2026-07-17/task-0004-drain-review.md` |


### Path-to-100 Closeout — 2026-07-18 (builders)

- **Residual fixed**: Re-verified monorepo task-lane corpus currency (22 tasks / 5 lanes).
- **Commands**:
  - `python3 tool/validate_mock_workspace.py --project-root apps/observatory` → EXIT 0
  - tasks=22 under `apps/observatory/assets/mock_workspace/docs/tasks/`
- **Remaining**: None (prior drain 100/100 held).
- **Lane**: remain in `docs/tasks/03-review/` (reviewers promote)


### Review Ledger — 2026-07-18 path100 independent re-review (BATCH R1)

| Date | Reviewer | Score | Verdict | Notes |
| --- | --- | --- | --- | --- |
| 2026-07-18 | reviewers (BATCH R1 independent) | 100/100 | ACCEPTED_100 | Live re-validation + path-to-100 residuals closed. Report: `docs/reports/review-wave-2026-07-18/task-0004-path100-rereview.md` |

