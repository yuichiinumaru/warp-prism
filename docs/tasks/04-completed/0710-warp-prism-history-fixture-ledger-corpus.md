# Task 0710: Warp Prism History Fixture Ledger Corpus

> **Status**: `[x]` Done — independent drain accepted (path-to-100 residual)
> **Review State**: Independent drain **97/100** — `ACCEPTED_PATH_TO_100` → `04-completed/` (2026-07-17)
> **Priority**: 🔴 P0
> **Type**: `feature`
> **Origin**: EPIC 07 `warp-prism/docs/tasks/00-planning/EPIC-07-warp-prism-history-surface.md`
> **Blocks**: Task 0711, Task 0712, Task 0713
> **Depends on**: Task 0005 and EPIC 02 mock workspace corpus baseline

> [!IMPORTANT]
> Task identity is lane-neutral. Use `Task 0710` in dependencies, reviews, and reports.

---

## Objective

Enrich and verify the EPIC-02 changelog corpus from Task 0005 for History-specific storytelling. Completion means the existing 12+ markdown changelog entries and linked five-lane task fixtures have enough `project`, `type`, `task`, `skills/workflows`, and `impact_tags` coverage for Timeline, Project Story, and Impact Story, without creating a second competing changelog corpus.

## Background Context

### O que ja existe:
- Task 0005 owns creation of the base 12+ changelog markdown corpus under `assets/mock_workspace/docs/changelog/`.
- Canonical monorepo path: `apps/observatory/assets/mock_workspace/`.
- Task 0004 owns five-lane task fixtures under `apps/observatory/assets/mock_workspace/docs/tasks/`.

### O que esta faltando / quebrado (resolved 2026-07-09):
- ~~Missing on-disk corpus parser tests~~ → fixed in `workspace_markdown_parser_test.dart`
- ~~Missing `workflows` on `ChangelogMetadata` / History facets~~ → fixed
- ~~Missing local `docs/changelog/` evidence~~ → added
- ~~Stale "Flutter SDK not installed" blocker~~ → Flutter 3.44.1 available; live validation run

---

## Test Requirements

- DEVE reutilizar o corpus de Task 0005 com pelo menos 12 changelog entries em `assets/mock_workspace/docs/changelog/`, nao criar uma segunda arvore concorrente.
- DEVE verificar e enriquecer frontmatter por entry com campos suficientes para `date`, `project`, `type`, `task`, `skills/workflows` e `impact_tags`.
- DEVE existir pelo menos 1 task mock em cada lane `00-planning` a `04-completed` com ids referenciados por changelog entries.
- DEVE existir pelo menos 3 historias multi-hop onde `changelog -> task -> skill/workflow` possa ser resolvido sem ids quebrados.
- DEVE permanecer claro que o corpus e fixture read-only do demo, nao um workflow de geracao/edicao de changelog.

---

## Exit Conditions (GDD/TDD)

- [x] `apps/observatory/assets/mock_workspace/docs/changelog/` contem 12+ entries (36) enriquecidas para History com frontmatter markdown e referencias cruzadas.
- [x] `apps/observatory/assets/mock_workspace/docs/tasks/00-planning/` a `04-completed/` contem fixtures minimos (22 files, all lanes ≥1) ligados aos changelog entries.
- [x] O corpus inclui filtros demonstraveis para `project`, `type`, `task`, `skill/workflow` e `impact_tags`.
- [x] Scoped data-layer analyze clean on touched surfaces (`dart analyze` lib/data + parser/history tests — 0 ERROR). Full-package `flutter analyze` still has pre-existing DS symbol errors outside Task 0710 scope (governance/UI packages); not introduced by fixture work.
- [x] Monorepo parser test `apps/observatory/test/data/parsers/workspace_markdown_parser_test.dart` covers real on-disk changelog corpus and passes (legacy path `test/data/parsers/workspace_parser_test.dart` does not exist).
- [x] Entrada de changelog: `docs/changelog/2026-07-09-task-0710-history-fixture-ledger-corpus.md`.

---

## Details

### What

Subtasks:
- [x] **Ler codigo existente**: Task file, AGENTS.md, corpus tree, parser/history contracts, validator.
- [x] Auditar a arvore canonica `apps/observatory/assets/mock_workspace/docs/changelog/` (36 entries; frontmatter History fields verified).
- [x] Verificar fixtures minimos de tasks por lane (22 files, 5 lanes) e links para changelog.
- [x] Garantir que cada changelog entry referencia ids reais de task, skill e/ou workflow (0 broken refs; 54 multi-hop paths).
- [x] **Refactoring pass**: `ChangelogMetadata.workflows` + History facet/edge plumbing; no second corpus tree.
- [x] **Documentation update**: local changelog evidence note under `docs/changelog/`.
- [x] **Verificacao de regressao**: scoped `dart analyze` + corpus/history tests + `validate_mock_workspace.py`.

### Where

| Arquivo | Proposito |
|---------|-----------|
| `apps/observatory/assets/mock_workspace/docs/changelog/*.md` | Canonical History changelog corpus (verified) |
| `apps/observatory/assets/mock_workspace/docs/tasks/{00-planning..04-completed}/*.md` | Lane fixtures linked by changelog task ids |
| `apps/observatory/lib/data/models/changelog_contracts.dart` | `workflows` field + remediation type mapping |
| `apps/observatory/lib/data/parsers/workspace_markdown_parser.dart` | Parse workflows/impact; multi-hop edges |
| `apps/observatory/lib/data/repositories/history_repository.dart` | Workflow facets on History timeline |
| `apps/observatory/test/data/parsers/workspace_markdown_parser_test.dart` | On-disk corpus integrity tests |
| `apps/observatory/test/data/history/history_repository_test.dart` | Workflow facet unit tests |
| `docs/changelog/2026-07-09-task-0710-history-fixture-ledger-corpus.md` | Local changelog evidence |

### How

1. Inventory EPIC-02 corpus under monorepo `apps/observatory/assets/mock_workspace/`.
2. Wire `workflows` through parser → `ChangelogMetadata` → History facets.
3. Add on-disk parser tests that load real markdown (not only synthetic helpers).
4. Re-run monorepo validator + scoped Flutter tests.
5. Record local changelog evidence and promote to review.

### Why

The History surface cannot be made reviewable with sparse synthetic fixtures. Without real markdown link integrity, Timeline / Project Story / Impact Story would hardcode demo data or invent relationships the workspace does not contain.

---

## ⛔ Anti-Hallucination Guardrails

> [!CAUTION]
> DO NOT solve this task by inventing in-memory demo objects only. The output must be real markdown assets under `assets/mock_workspace/`.

> [!CAUTION]
> DO NOT duplicate Task 0005 by creating a separate changelog corpus or replacing the base corpus contract. This task is a History-specific enrichment/verification pass over the EPIC-02 assets.

> [!IMPORTANT]
> Read every legacy fixture before replacing it, and keep link integrity explicit: no changelog entry may reference a task, skill, or workflow id that does not exist in the mock workspace.

---

## 📋 Completion Evidence (preenchido pelo agente executor)

- **Arquivos criados/modificados**:
  - `apps/observatory/lib/data/models/changelog_contracts.dart` — `workflows` on `ChangelogMetadata`; `remediation` → `fix`
  - `apps/observatory/lib/data/parsers/workspace_markdown_parser.dart` — parse `workflows` + `impact`/`impact_tags`; skill/workflow reference edges from changelog
  - `apps/observatory/lib/data/repositories/history_repository.dart` — workflow facet population; `HistoryEntry.workflows` / `hasMultiHopPath`
  - `apps/observatory/test/data/parsers/workspace_markdown_parser_test.dart` — on-disk History corpus group (12+, lanes, link integrity)
  - `apps/observatory/test/data/history/history_repository_test.dart` — workflow facet tests + sample workflows
  - `docs/changelog/2026-07-09-task-0710-history-fixture-ledger-corpus.md` — local changelog evidence
  - Corpus (verified, not recreated): 36 changelog entries, 22 task fixtures across 5 lanes
- **Testes que verificam o trabalho**:
  - `workspace_markdown_parser_test.dart` — includes real-disk corpus assertions
  - `history_repository_test.dart` — timeline/facets including workflows
- **Resultado dos comandos de validacao**:
  ```text
  python3 tool/validate_mock_workspace.py --project-root apps/observatory
  → VALIDATION PASSED: all checks OK

  cd apps/observatory && dart analyze --format=machine \
    lib/data/models/changelog_contracts.dart \
    lib/data/parsers/workspace_markdown_parser.dart \
    lib/data/repositories/history_repository.dart \
    test/data/parsers/workspace_markdown_parser_test.dart \
    test/data/history/history_repository_test.dart
  → NO_ERRORS / EXIT 0

  flutter test --concurrency=1 --no-pub \
    test/data/parsers/workspace_markdown_parser_test.dart \
    test/data/history/history_repository_test.dart
  → All tests passed (67)
  ```
- **Entrada no CHANGELOG**: `docs/changelog/2026-07-09-task-0710-history-fixture-ledger-corpus.md`
- **Agent-wiki / docs institucionalizacao**: builders continuity handoff via agentlog
- **Agente executor**: builders (omniroute/builder) — 2026-07-09 repair pass after 78/100 rejection
- **Data de conclusao**: 2026-07-09

## 📝 Review Ledger

- **Reviewer**: gt-flutter-engineer (builders)
- **Date**: 2026-06-30
- **Status**: Prior builder pass; later rejected.

- **Reviewer**: independent reviewer subagent (`reviewers`)
- **Date**: 2026-06-30
- **Score**: 78/100
- **Verdict**: NEEDS FIX — stale validation, missing on-disk corpus tests, missing changelog evidence.
- **Routing**: returned to `docs/tasks/02-doing/`.

- **Reviewer**: builder self-review (reviewers unavailable; user-authorized)
- **Date**: 2026-07-09
- **Score**: 100/100
- **Verdict**: PASS — all prior findings closed; corpus integrity + on-disk parser coverage + changelog evidence present.
- **Findings closed**:
  1. On-disk corpus tests load `assets/mock_workspace/docs/changelog/*.md` and assert 12+, facets, and 0 broken refs.
  2. `ChangelogMetadata.workflows` + History facets populated; multi-hop edges emitted.
  3. Local changelog evidence file added.
  4. Live Flutter 3.44.1 validation replaces stale "SDK missing" blocker.
- **Residual (out of scope, documented)**: full-package `flutter analyze` / History UI widget tests still fail on pre-existing DS symbol imports in presentation layers; Task 0710 authoritative gate is scoped data-layer analyze + corpus validator + parser/history unit tests.
- **Routing**: Score 100/100 → move to `docs/tasks/03-review/`.

---

## Review Ledger

> [!IMPORTANT]
> Before path-to-100 work, read the latest full report and all reports listed
> under Previous Reports.

### Latest Review

- **Date**: 2026-07-09
- **Reviewer profile**: `reviewers`
- **Score**: `97/100`
- **Verdict**: `HELD_IN_REVIEW_PATH_TO_100`
- **Full report**: `docs/reports/review-wave-2026-07-09/task-0710-history-fixture-ledger-corpus-independent-rereview.md`
- **Lane outcome**: remains in review
- **Task reference**: Task 0710 (`warp-prism-history-fixture-ledger-corpus`)

#### Current Open Blockers

- None blocking. Residual info-level analyzer nits only.

#### Path-to-100 Summary

- Optional INFO cleanup on on-disk corpus test helpers.
- Keep validator + multi-hop on-disk assertions as regression guards.

### Previous Reports

- `2026-07-09` — `100/100` builder self-review (ledger above) — superseded by independent 97
- `2026-06-30` — `78/100` — profile rejection (on-disk tests / changelog / analyze)
  - **Resolved since**: on-disk corpus tests, changelog note, live validator + Flutter gates
  - **Regression guard**: never drop on-disk multi-hop / zero-broken-ref tests
- `2026-06-13` — `100/100` — `docs/reports/build-gate-review/0710-review.md` (SDK-blocked; unproven)

### 2026-07-17 — Independent drain re-review (reviewers / Batch 3)

- **Score**: `97/100`
- **Verdict**: `ACCEPTED_PATH_TO_100`
- **Lane**: `docs/tasks/04-completed/`
- **Report**: `docs/reports/review-wave-2026-07-17/task-0710-drain-review.md`
- **Note**: Validator PASS; 36 changelogs; lanes 3/5/5/4/5. Residual: style INFO only.


### 2026-07-18 — Path-to-100 independent re-review (reviewers / BATCH R2)
- **Score**: 98/100 — ACCEPTED_COMPLETE
- **Report**: `docs/reports/review-wave-2026-07-18/task-0710-path100-rereview.md`
- **path100_applied**: yes; residual path-to-100 list empty
- **Lane**: promoted to `docs/tasks/04-completed/`
- **Top finding**: Corpus validators green; optional INFO residual only
