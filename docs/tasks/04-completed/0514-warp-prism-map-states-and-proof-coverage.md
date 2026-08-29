# Task 0514: Map empty/loading/error states and proof coverage

> **Review State**: Independent drain **97/100** — `ACCEPTED_PATH_TO_100` → `04-completed/` (2026-07-17)
> **Priority**: 🟢 P2
> **Type**: `feature`
> **Origin**: `EPIC-05-warp-prism-map-surface.md` scope item for map-specific empty/loading/error states
> **Blocks**: None
> **Depends on**: Task 0511 (`0511-warp-prism-map-catalog-tabs-and-filters`), Task 0512 (`0512-warp-prism-map-graph-modes-and-adapters`), Task 0513 (`0513-warp-prism-map-selection-and-inspector`)

> [!IMPORTANT]
> Task identity is lane-neutral. Use `Task 0514` plus optional slug for dependencies,
> blockers, review ledgers, reports, and architecture references. Lanes such as
> `02-doing` and `03-review` are mutable status, not identity. If a live file path
> is needed, resolve it from `docs/tasks/tasklist.md` or search under `docs/tasks/`.

---

## Objective

Harden the Map surface with explicit loading, empty, error, and no-selection states plus focused widget coverage so the feature remains demoable and diagnostically clear before broader polish work begins. Completion means the Map route no longer relies on blank containers or silent failures when repositories are loading, when a tab has no eligible assets, when a filter removes everything, when graph projection fails, or when no asset is selected for inspection.

## Background Context

### O que já existe:
- `warp-prism/docs/prompt.txt` explicitly includes Map-specific empty/loading/error states in epic scope.
- `warp-prism/docs/research.md` argues that the product should be a storytelling console that constantly answers what exists, what matters, and why, which requires explicit state communication rather than silent blanks.
- Tasks 0002, 0003, and 0004 are expected to provide the main catalog, graph, and inspector flows of the Map surface.
- The design system already includes reusable visual primitives that can be used to express state panels without ad hoc screen styling.

### O que está faltando / quebrado:
- No current feature-level state surface distinguishes shell loading from no-results, graph-no-edges, repository error, or no-selection inspector cases.
- The current codebase has no focused proof package for Map behavior; without it, future polish work can accidentally erase edge-state clarity.
- `draft.md` already signals compile and API fragility in the codebase, increasing the risk that silent state regressions slip through if not tested explicitly.
- Epic 10 should handle final polish, but EPIC 05 still needs a trustworthy baseline of visible state contracts before more surfaces accumulate on top.

---

## Test Requirements

- DEVE mostrar estado de loading explícito quando a surface Map ainda não recebeu dados.
- DEVE distinguir “nenhum resultado por filtro/query” de “repositório vazio/sem assets elegíveis”.
- DEVE mostrar estado de erro explícito para falha de carregamento/projeção com mensagem ou affordance de retry/diagnóstico.
- DEVE mostrar estado de “nenhum asset selecionado” no inspector quando aplicável.
- DEVE ter pelo menos um teste happy-path e pelo menos três edge cases cobrindo loading, empty/no-results, error, ou no-selection.

---

## Exit Conditions (GDD/TDD)

- [x] A surface Map tem estados explícitos para loading, empty, no-results, error e no-selection conforme aplicável.
- [x] Catálogo, grafo e inspector usam estados distintos e legíveis em vez de containers vazios ou fallbacks silenciosos.
- [x] Existe uma suíte de testes da feature Map cobrindo pelo menos um happy path e múltiplos edge cases de estado.
- [x] `flutter analyze` passa sem erros (scoped `lib/features/map/` + `test/features/map/`, exit 0)
- [x] `flutter test test/features/map/` passa com 0 falhas (103 tests)
- [x] Entrada de changelog adicionada via engine em `docs/changelog/`

---

## Details

### What

Subtasks:
- [x] **Ler código existente**: monorepo paths under `apps/observatory/lib/features/map/` (task Where table used legacy root-relative `lib/features/map/` paths)
- [x] Definir e implementar estados explícitos da feature para loading, empty, no-results, error e no-selection.
- [x] Aplicar esses estados em catálogo, grafo e inspector com copy e affordances coerentes com a surface Map.
- [x] Criar/expandir testes da feature cobrindo estados principais e edge cases obrigatórios.
- [x] **Refactoring pass**: Inspector no-selection now reuses `MapStatePanel`/`MapSurfaceState.noSelection` (no duplicate private empty widget).
- [x] **Documentation update**: Builder continuity + changelog verification note; monorepo path correction recorded.
- [x] **Verificação de regressão**: `flutter analyze lib/features/map/ test/features/map/` exit 0; `flutter test test/features/map/` 103 passed.

### Where

| Arquivo | Propósito |
|---------|-----------|
| `apps/observatory/lib/features/map/map_workspace_page.dart` | Orquestração dos estados da surface |
| `apps/observatory/lib/features/map/map_workspace_state.dart` | Modelagem dos estados explícitos |
| `apps/observatory/lib/features/map/map_workspace_provider.dart` | Derivar erros, loading e vazios de forma tipada |
| `apps/observatory/lib/features/map/widgets/map_catalog_panel.dart` | empty/no-results/loading no catálogo |
| `apps/observatory/lib/features/map/widgets/map_graph_panel.dart` | loading/no-edges/error no grafo |
| `apps/observatory/lib/features/map/widgets/map_inspector_panel.dart` | no-selection via MapStatePanel |
| `apps/observatory/lib/features/map/widgets/map_state_panel.dart` | Componente reutilizável MapSurfaceState → PrismStateSurface |
| `apps/observatory/test/features/map/map_surface_states_test.dart` | Prova dos estados obrigatórios |
| `apps/observatory/test/features/map/` | Suite completa Map (103 tests) |

### How

1. Modelar estados da feature explicitamente no provider/state, evitando `null` ambíguo para significar loading, vazio e erro ao mesmo tempo.
2. Reusar o design system (`PrismStateSurface`, `PrismDetailInspector`, etc.) com copy específica da surface Map.
3. Concentrar a prova em testes de widget da feature.
4. Surface pronta para polish EPIC 10, já confiável para demos e revisões intermediárias.

### Why

Mesmo uma boa surface de catálogo e grafo falha como ferramenta de observabilidade se os estados degradados forem silenciosos. Esta task transforma a EPIC 05 em algo verificável e demonstrável.

---

## ⛔ Anti-Hallucination Guardrails

> [!CAUTION]
> DO NOT tratar qualquer `null` ou lista vazia como “good enough” sem copy/estado explícito. Blanks silenciosos não contam como UX implementada nem como proof-complete.

> [!IMPORTANT]
> Read EVERY file in `Where` before writing, and keep each degraded state semantically distinct in code and tests so later polish cannot collapse them back into one generic placeholder.

---

## 📋 Completion Evidence (preenchido pelo agente executor)

> **OBRIGATÓRIO ao fechar a task.** O agente deve preencher esta seção ANTES de mover para `completed/`.
> Sem evidência = task NÃO pode ser movida.

- **Arquivos criados/modificados** (session 2026-07-09 builder re-validation):
  - `apps/observatory/lib/features/map/widgets/map_state_panel.dart` — `MapSurfaceState` enum + `MapStatePanel` via `PrismStateSurface`
  - `apps/observatory/lib/features/map/map_workspace_page.dart` — catalog/graph loading, error, empty, no-results
  - `apps/observatory/lib/features/map/widgets/map_graph_panel.dart` — graphNoEdges via MapStatePanel
  - `apps/observatory/lib/features/map/widgets/map_inspector_panel.dart` — no-selection uses MapStatePanel (removed private duplicate)
  - `apps/observatory/test/features/map/map_surface_states_test.dart` — happy path + loading/empty/no-results/error/no-selection/graph-no-edges
  - `docs/changelog/20260709-125628-0514-map-states-proof-live-validation.md`
- **Testes que verificam o trabalho**:
  - `map_surface_states_test.dart` — loading, empty corpus, empty family, no-results (query/filter/combined), error+retry, no-selection, graph-no-edges
  - Full suite `test/features/map/` — **108** tests green (path-to-100 wave 2026-07-18)
- **Resultado dos comandos de validação** (2026-07-18 path-to-100 builders):
  - `cd apps/observatory && flutter analyze lib/features/map` → **No issues found**
  - `cd apps/observatory && flutter test test/features/map/` → **All tests passed! (108)**
- **Entrada no CHANGELOG**:
  - prior: `docs/changelog/20260607-220705-0000-2026-06-07-task-0514-map-states-proof-coverage-repair-bot.md`
  - prior: `docs/changelog/20260709-125628-0514-map-states-proof-live-validation.md`
  - this wave: `docs/changelog/2026-07-18-path-to-100-batch2-0410-0810.md`
- **Agent-wiki / docs institucionalização**: builders continuity handoff for Task 0514
- **Agente executor**: PATH-TO-100 builder (parent agentID=builders)
- **Data de conclusão**: 2026-07-18 (path-to-100 residual close)
- **Self-score**: 100/100 (states distinct incl. emptyFamily, Prism* API, tests green, analyze clean)
- **Blockers**: None

## Review Ledger

### 2026-07-09 — independent re-review (reviewers)
**Score**: 98/100 — HELD_IN_REVIEW_PATH_TO_100
**Verdict**: Task-scope accept (S≥90). Stay in `03-review/` (never 04-completed by reviewer).
**Report**: `docs/reports/review-wave-2026-07-09/task-0514-map-states-proof-independent-rereview.md`
**Fresh proof**: states suite **19/19**; map suite **104/104**; 6 distinct `MapSurfaceState` values; catalog/graph/inspector explicit states; scoped analyze clean.
**Blockers**: none. Note: claim count 103 understates live 104.
**Lane action**: stay `docs/tasks/03-review/`.

### 2026-07-17 — Independent drain re-review (reviewers / Batch 3)

- **Score**: `97/100`
- **Verdict**: `ACCEPTED_PATH_TO_100`
- **Lane**: `docs/tasks/04-completed/`
- **Report**: `docs/reports/review-wave-2026-07-17/task-0514-drain-review.md`
- **Note**: States suite solid; prior Retry no-op RESOLVED. Residual: empty-family enum optional; test count claim drift.

### 2026-07-18 — Path-to-100 residual close (builders)

- Applied `MapSurfaceState.emptyFamily` + catalog orchestration when family empty but corpus non-empty.
- Completion Evidence test count refreshed to **108** live map suite.
- Lane: remain `docs/tasks/03-review/` (no 04-completed move).


### 2026-07-18 — Path-to-100 independent re-review (reviewers / BATCH R2)
- **Score**: 99/100 — ACCEPTED_COMPLETE
- **Report**: `docs/reports/review-wave-2026-07-18/task-0514-path100-rereview.md`
- **path100_applied**: yes; residual path-to-100 list empty
- **Lane**: promoted to `docs/tasks/04-completed/`
- **Top finding**: State vocabulary complete; suite +109
