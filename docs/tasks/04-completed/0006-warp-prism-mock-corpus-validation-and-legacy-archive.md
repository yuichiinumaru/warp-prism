# Task 0006: Warp Prism Mock Corpus Validation And Legacy Archive

> **Status**: `[x]` Completed — independent path100 re-review 2026-07-18 S=100/100
> **Review State**: `ACCEPTED_100` — S=100/100 (2026-07-18); see `docs/reports/review-wave-2026-07-18/task-0006-path100-rereview.md`
> **Priority**: 🔴 P0
> **Type**: `verification`
> **Origin**: EPIC 02 — Warp Prism Mock Workspace Corpus
> **Blocks**: EPIC 03 parser and graph-backbone execution wave
> **Depends on**: Task 0001, Task 0002, Task 0003, Task 0004, Task 0005

> [!IMPORTANT]
> Task identity is lane-neutral. Use `Task 0006` plus optional slug for dependencies,
> blockers, review ledgers, reports, and architecture references. Lanes such as
> `02-doing` and `03-review` are mutable status, not identity. If a live file path
> is needed, resolve it from `docs/tasks/tasklist.md` or search under `docs/tasks/`.

---

## Objective

Finalize EPIC 02 by validating that the new markdown corpus under
`apps/observatory/assets/mock_workspace/` satisfies the approved manifest,
aligns with `apps/observatory/pubspec.yaml`, and safely archives the legacy
root `mock_workspace/` tree into `.archive/` without deletion.

## Background Context

### O que já existe:
- Melos monorepo places the live Flutter app under `apps/observatory/`.
- `apps/observatory/pubspec.yaml` points Flutter asset loading at
  `assets/mock_workspace/` relative to that package.
- Tasks 0001 through 0005 define the manifest, agents/workflows, skills, task
  lanes, and changelog corpus required by EPIC 02.
- The historical YAML-first corpus originally lived at repo-root
  `mock_workspace/` and cannot be deleted.

### O que estava faltando / quebrado (historical, pre path-to-100):
- No monorepo-aware default validator command from repo root.
- Residual live root `mock_workspace/` still sat beside `.archive/mock_workspace/`.
- Task evidence still cited pre-monorepo root paths and a blocked Flutter SDK.

---

## Test Requirements

- DEVE criar um verificador reproduzivel do corpus mock, preferencialmente em
  `tool/validate_mock_workspace.py` (or Dart equivalent), consumindo
  `apps/observatory/assets/mock_workspace/manifest.yaml`.
- DEVE validar contagens minimas, nomes obrigatorios, presenca de frontmatter e
  distribuicao de lanes do corpus completo.
- DEVE verificar que `apps/observatory/pubspec.yaml` continua alinhado com os
  diretorios finais realmente usados.
- DEVE mover o corpus legado para um destino unico sob `.archive/` depois de
  verificar que o destino nao colide com conteudo existente.
- DEVE produzir evidencia suficiente para desbloquear a onda de parser e graph
  backbone do EPIC 03.

---

## Exit Conditions (GDD/TDD)

- [x] Existe um validador do corpus mock versionado no repositorio e apontado
  para `apps/observatory/assets/mock_workspace/manifest.yaml`.
- [x] O validador confirma as contagens e listas obrigatorias definidas em Task 0001.
- [x] `apps/observatory/pubspec.yaml` continua coerente com a arvore final de
  `apps/observatory/assets/mock_workspace/`.
- [x] O corpus legado `mock_workspace/` foi arquivado sob `.archive/` sem uso de
  `rm` e sem colisao de destino (no residual live root remains).
- [x] Comando de validacao principal do componente passa sem erros:
  `python3 tool/validate_mock_workspace.py`
- [x] Testes relevantes do validador passam com 0 falhas:
  `python3 tool/validate_mock_workspace.py` (5 groups; Flutter SDK now available
  but primary gate for this task is the Python corpus validator).
- [x] Entrada de changelog adicionada em `docs/changelog/`

---

## Details

### What

Subtasks:
- [x] **Ler codigo existente**: `apps/observatory/assets/mock_workspace/manifest.yaml`,
  `apps/observatory/pubspec.yaml`, Tasks 0001–0005, legacy `mock_workspace/`,
  prior review reports for Task 0006.
- [x] Implementar o validador automatizado do corpus consumindo o manifesto
  aprovado em Task 0001 (`tool/validate_mock_workspace.py`).
- [x] Rodar o validador contra a arvore final e corrigir qualquer mismatch de
  contagem, nome ou frontmatter.
- [x] Verificar os paths finais declarados em `apps/observatory/pubspec.yaml`
  depois que o corpus completo existir.
- [x] Arquivar o corpus legado para `.archive/` com verificacao previa do
  diretorio alvo e registrar o destino final na evidencia.
- [x] **Refactoring pass**: monorepo-aware default project-root resolver (short,
  explicit, no soft re-inference of the contract).
- [x] **Documentation update**: path-to-100 evidence + builders agent-wiki note.
- [x] **Verificacao de regressao**: re-run primary validator from repo root and
  with explicit `--project-root apps/observatory`; prove residual live root
  absence and archive presence.

### Where

| Arquivo | Proposito |
|---------|-----------|
| `apps/observatory/assets/mock_workspace/manifest.yaml` | Ler - contrato estruturado do corpus |
| `apps/observatory/pubspec.yaml` | Ler - confirmar alinhamento dos assets |
| `docs/tasks/**/0001-warp-prism-mock-workspace-contract-baseline.md` | Ler - criterios aprovados |
| `docs/tasks/**/0002-warp-prism-agent-and-workflow-markdown-fixtures.md` | Ler - escopo de agentes/workflows |
| `docs/tasks/**/0003-warp-prism-skill-hierarchy-markdown-fixtures.md` | Ler - escopo de skills |
| `docs/tasks/**/0004-warp-prism-task-lane-markdown-corpus.md` | Ler - escopo de tasks mock |
| `docs/tasks/**/0005-warp-prism-changelog-markdown-corpus.md` | Ler - escopo de changelog mock |
| `mock_workspace/` (historical residual root) | Arquivar - corpus legado a preservar |
| `tool/validate_mock_workspace.py` | Criar/Modificar - validador monorepo-aware |
| `.archive/mock_workspace/` | Destino canonico do corpus legado (18 files) |
| `.archive/mock_workspace-residual-source-20260709/` | Residual live-root move target (18 files, no deletion) |
| `docs/changelog/2026-07-09-task-0006-monorepo-aware-validator-archive-completion.md` | Changelog path-to-100 entry |

### How

1. Implement one validator that reads the manifest and walks the final asset tree.
2. Default the validator project root to the monorepo app package when that
   package owns the live corpus.
3. Use the validator to prove exact counts, required names, and frontmatter presence.
4. Recheck `apps/observatory/pubspec.yaml` against the resulting tree.
5. Archive residual live root legacy corpus only after confirming destination
   is free / identical-to-archive and documented.

### Why

EPIC 02 is only valuable if later parser work can trust the corpus as stable
source evidence. A final validation and archive task prevents silent drift, keeps
the old data recoverable, and gives EPIC 03 a deterministic handoff point.

---

## ⛔ Anti-Hallucination Guardrails

> [!CAUTION]
> DO NOT delete the legacy mock corpus or overwrite an existing archive destination.
> Archive moves must be collision-checked first. Residual live roots must be
> moved into `.archive/`, never `rm`'d.

> [!IMPORTANT]
> The validator must prove the corpus contract from Task 0001, not re-infer a
> softer contract from whatever files happen to exist. After Melos migration the
> live corpus path is `apps/observatory/assets/mock_workspace/`.

---

## 📋 Completion Evidence (preenchido pelo agente executor)

- **Arquivos criados/modificados** (historical 2026-06-07 + 2026-07-09 path-to-100):
  - `tool/validate_mock_workspace.py` — automated corpus validator (Python 3);
    2026-07-09: monorepo-aware default project-root resolver
  - `apps/observatory/assets/mock_workspace/manifest.yaml` — live corpus contract
    (counts: agents 9, skills 13, workflows 11, tasks 22, changelog 36, lanes 5;
    `archive_destination: .archive/mock_workspace/`)
  - `.archive/mock_workspace/` — archived legacy corpus (18 files)
  - `.archive/mock_workspace-residual-source-20260709/` — residual live-root tree
    moved 2026-07-09 after proving identity with the archive (18 files)
  - `docs/changelog/20260607-000000-0006-2026-06-07-task-0006-mock-corpus-validation-archive-repair-bot.md` —
    historical entry (pre monorepo path-to-100)
  - `docs/changelog/2026-07-09-task-0006-monorepo-aware-validator-archive-completion.md` —
    path-to-100 entry
- **Testes que verificam o trabalho**: `tool/validate_mock_workspace.py`
  (5 validation groups: counts, required names, frontmatter, task lanes,
  pubspec alignment)
- **Resultado dos comandos de validacao** (2026-07-09 live re-run):
  - `python3 tool/validate_mock_workspace.py` → exit 0,
    `VALIDATION PASSED: all checks OK`, project root resolves to
    `.../apps/observatory`
  - `python3 tool/validate_mock_workspace.py --project-root apps/observatory` →
    exit 0, same PASS
  - Live corpus: agents=9 skills=13 workflows=11 tasks=22 changelog=36
    lanes=`00-planning,01-open,02-doing,03-review,04-completed` (144 files / 130 md)
- **Entrada no CHANGELOG**:
  `docs/changelog/2026-07-09-task-0006-monorepo-aware-validator-archive-completion.md`
  (supersedes path-only claims of the historical 2026-06-07 entry)
- **Agent-wiki / docs institucionalizacao**: builders continuity/fix note for
  Task 0006 path-to-100
- **Agente executor**: hermes-agent (initial); omniroute/builder path-to-100 2026-07-09
- **Data de conclusao**: 2026-06-07 (initial); path-to-100 refresh 2026-07-09

### Historical review ledger

| Date | Reviewer | Score | Verdict | Note |
|------|----------|------:|---------|------|
| 2026-06-13 | build-gate | 100/100 | APPROVED (stale) | Pre monorepo residual-root discovery; Flutter SDK external blocker noted. |
| 2026-06-14 | reviewers (wave 2) | 62/100 | REJECTED → `02-doing` | Default validator failed from root; residual live `mock_workspace/` still present; monorepo path drift. |
| 2026-07-09 | builders (omniroute/builder) | 100/100 | READY FOR REVIEW | Monorepo-aware default + residual archive move + evidence refresh. |
| 2026-07-09 | reviewers (independent re-review) | 95/100 | HELD_IN_REVIEW_PATH_TO_100 | Bare validator EXIT 0 (monorepo-aware); residual root `mock_workspace/` gone; archive under `.archive/`; exits met. Shared note: 0001 archive string inconsistency not a 0006 exit fail. Held in `03-review/`. Report: `docs/reports/review-wave-2026-07-09/task-0006-mock-corpus-validation-archive-independent-rereview.md`. |

### 2026-07-09 Path-to-100 Refresh

Review-wave-2 path to 100 items closed:

1. **Monorepo-aware primary command** — `tool/validate_mock_workspace.py` now
   defaults to `apps/observatory` when
   `apps/observatory/assets/mock_workspace/manifest.yaml` exists.
2. **Residual live root archive** — after `diff -rq mock_workspace
   .archive/mock_workspace` returned empty identity, residual root was moved
   with `mv mock_workspace .archive/mock_workspace-residual-source-20260709`
   (no `rm`). Live root absence proven.
3. **Manifest archive policy** — already corrected by Task 0001 path-to-100 to
   `.archive/mock_workspace/`; reconfirmed live.
4. **Evidence paths** — completion evidence rewritten to monorepo-live paths and
   exact command stdout.

Live commands (exact):

```text
$ python3 tool/validate_mock_workspace.py
Project root : .../apps/observatory
Corpus root  : .../apps/observatory/assets/mock_workspace
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
VALIDATION PASSED: all checks OK
→ EXIT:0

$ test ! -e mock_workspace && echo SOURCE_REMOVED:OK
→ SOURCE_REMOVED:OK

$ test -d .archive/mock_workspace && find .archive/mock_workspace -type f | wc -l
→ 18

$ test -d .archive/mock_workspace-residual-source-20260709 && find .archive/mock_workspace-residual-source-20260709 -type f | wc -l
→ 18

$ rg -n "archive_destination:" apps/observatory/assets/mock_workspace/manifest.yaml
→ 74:archive_destination: .archive/mock_workspace/
```

Note on changelog engine: parent `changelog_engine.py` defaults to `.changelog/`
and a naive `build` from an empty/partial staging dir rewrote root
`CHANGELOG.md` to a single-entry file. That accidental rewrite was immediately
restored from git (`git checkout -- CHANGELOG.md CHANGELOG-FULL.md`), the
misrouted `.changelog/` staging dir was archived under
`.archive/changelog-engine-misroute-20260709/`, and the durable path-to-100
entry was written under the live child ledger `docs/changelog/`. Reviewers
should treat `docs/changelog/` as the Warp Prism entry surface for this task.

## Post-Promotion Evidence — 2026-07-09

- `test -f docs/tasks/03-review/0006-warp-prism-mock-corpus-validation-and-legacy-archive.md && echo IN_REVIEW:OK`
- `test ! -f docs/tasks/02-doing/0006-warp-prism-mock-corpus-validation-and-legacy-archive.md && echo NOT_IN_DOING:OK`
- Review State: Ready For Review (not Doing / Completed / Open)
- Primary validator re-run after evidence write still exits 0
- Changelog validation independent of tasklist: live entry present at
  `docs/changelog/2026-07-09-task-0006-monorepo-aware-validator-archive-completion.md`
- Older 02-doing / pre-monorepo path claims above are historical/superseded

> **STATUS**: Ready for independent review. Evidence refreshed 2026-07-09.

## Review Ledger

### Review Ledger — 2026-07-17 drain (independent)

| Date | Reviewer | Score | Verdict | Notes |
| --- | --- | --- | --- | --- |
| 2026-07-17 | reviewers (drain batch 1) | 100/100 | APPROVED_COMPLETED | Live re-validation. Prior 95/100. None — monorepo validator + archive completion holds. Report: `docs/reports/review-wave-2026-07-17/task-0006-drain-review.md` |


### Path-to-100 Closeout — 2026-07-18 (builders)

- **Residual fixed**: Re-proved monorepo-aware validator + residual live root absent + archive present.
- **Commands**:
  - `python3 tool/validate_mock_workspace.py --project-root apps/observatory` → EXIT 0
  - `test ! -d mock_workspace` → OK
  - archive `.archive/mock_workspace*` present
- **Remaining**: None (prior drain 100/100 held).
- **Lane**: remain in `docs/tasks/03-review/` (reviewers promote)


### Review Ledger — 2026-07-18 path100 independent re-review (BATCH R1)

| Date | Reviewer | Score | Verdict | Notes |
| --- | --- | --- | --- | --- |
| 2026-07-18 | reviewers (BATCH R1 independent) | 100/100 | ACCEPTED_100 | Live re-validation + path-to-100 residuals closed. Report: `docs/reports/review-wave-2026-07-18/task-0006-path100-rereview.md` |

