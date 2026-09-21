# Task 0512: Map graph modes and projection adapters

> **Review State**: Independent drain **91/100** — `ACCEPTED_PATH_TO_100` → `04-completed/` (2026-07-17)
> **Priority**: 🟡 P1
> **Type**: `feature`
> **Origin**: `EPIC-05-warp-prism-map-surface.md` candidate stories for containment, operational, and evidence graph modes
> **Blocks**: Task 0513, Task 0514
> **Depends on**: Task 0510 (`0510-warp-prism-map-workspace-scaffold`), `EPIC-03-warp-prism-data-layer-graph-backbone.md`

> [!IMPORTANT]
> Task identity is lane-neutral. Use `Task 0512` plus optional slug for dependencies,
> blockers, review ledgers, reports, and architecture references. Lanes such as
> `02-doing` and `03-review` are mutable status, not identity. If a live file path
> is needed, resolve it from `docs/tasks/tasklist.md` or search under `docs/tasks/`.

---

## Objective

Implement the Graph subview of the Map surface so the same normalized asset corpus can be projected into three explicit graph modes: `containment`, `operational`, and `evidence`. Completion means the Graph tab can switch among those modes, each mode derives nodes and edges from normalized asset relationships instead of hardcoded demo lists, and the projection contract is test-covered independently from the canvas widget.

## Background Context

### O que já existe:
- `warp-prism/docs/prompt.txt` requires three graph modes and a normalized edge model (`contains`, `routesTo`, `dependsOn`, `references`, `changedBy`, `proves`, `uses`).
- `warp-prism/docs/research.md` explicitly identifies graph mode switching as the differentiator of the Harness Map.
- `warp-prism/lib/design_system/organisms/ds_graph_canvas.dart` already provides a graph canvas organism, but it currently uses a simplified string `type` and local `GraphNode`/`GraphEdge` model.
- Task 0510 is expected to provide the Graph subview entrypoint and feature-local state shell.

### O que está faltando / quebrado:
- No projection layer currently maps normalized workspace assets/edges into graph-mode-specific nodes and links.
- `ds_graph_canvas.dart` still reflects an older asset taxonomy (`agent`, `skill`, `workflow`, `task`, `doc`) and references token names that do not exist, so it cannot yet be trusted as the source of projection truth.
- No tests prove that different graph modes are built from the same source asset graph with different edge selection rules.
- The epic acceptance criteria explicitly forbid manually hardcoded relationship lists, but the current codebase has no guardrail enforcing that boundary.

---

## Test Requirements

- DEVE projetar os mesmos assets normalizados em pelo menos três modos de grafo: `containment`, `operational`, e `evidence`.
- DEVE derivar edges por regra de modo a partir do backbone normalizado, não por listas locais manualmente mantidas no widget.
- DEVE expor contagens e/ou labels de nós/arestas que permitam verificar o modo ativo em testes determinísticos.
- DEVE ter pelo menos um teste happy-path cobrindo troca de modo e um edge case com assets sem arestas elegíveis para um modo específico.

---

## Exit Conditions (GDD/TDD)

- [x] Existe uma camada de projeção/adaptação do backbone Map para `containment`, `operational`, e `evidence`.
- [x] O Graph subview alterna entre os três modos sem trocar de fonte de dados.
- [x] `DsGraphCanvas` ou seu adaptador passa a aceitar o modelo necessário para a feature sem depender de listas hardcoded no widget.
- [x] Existe pelo menos um teste de unidade/widget cobrindo troca de modo e um caso sem edges elegíveis.
- [x] `flutter analyze` passa sem erros
- [x] `flutter test test/features/map/` passa com 0 falhas
- [x] Entrada de changelog adicionada via engine em `docs/changelog/`

---

## Details

### What

Subtasks:
- [x] **Ler código existente**: `warp-prism/docs/prompt.txt`, `warp-prism/docs/research.md`, `warp-prism/lib/design_system/organisms/ds_graph_canvas.dart`, `warp-prism/lib/data/models/models.dart`, `warp-prism/lib/data/parsers/workspace_parser.dart`, `warp-prism/lib/features/map/map_workspace_state.dart`, `warp-prism/lib/features/map/map_workspace_provider.dart`
- [x] Definir o contrato de projeção de grafo da feature Map e as regras por modo (`containment`, `operational`, `evidence`).
- [x] Adaptar o Graph subview e o canvas para consumir a projeção em vez de manter taxonomia/edges locais não normalizados.
- [x] Criar testes de projeção e de troca de modo, incluindo um dataset onde um modo retorna zero edges elegíveis.
- [x] **Refactoring pass**: Review implementation for simplicity. If you wrote 200 lines that could be 50, rewrite them.
- [x] **Documentation update**: If you discovered any durable operational notes, record them with `agent-wiki`; if you discovered collective project knowledge, institutionalize it under `docs/`
- [x] **Verificação de regressão**: execute `flutter analyze` e `flutter test test/features/map/`

### Where

| Arquivo | Propósito |
|---------|-----------|
| `warp-prism/docs/prompt.txt` | Ler - contrato do backbone de asset/edge e dos três modos de grafo |
| `warp-prism/docs/research.md` | Ler - rationale do grafo como diferenciador da surface Map |
| `warp-prism/lib/design_system/organisms/ds_graph_canvas.dart` | Ler/Modificar - canvas atual e seus limites de modelo/tokens |
| `warp-prism/lib/data/models/models.dart` | Ler/Modificar se necessário - alinhamento do modelo com projeções de grafo |
| `warp-prism/lib/data/parsers/workspace_parser.dart` | Ler - garantir que a projeção fique acima do parser, não dentro da UI |
| `warp-prism/lib/features/map/map_workspace_state.dart` | Ler/Modificar - armazenar modo de grafo ativo e seleção sincronizada |
| `warp-prism/lib/features/map/map_workspace_provider.dart` | Ler/Modificar - derivar projeções por modo |
| `warp-prism/lib/features/map/graph/map_graph_projection.dart` | Criar - regra central de projeção por modo |
| `warp-prism/lib/features/map/graph/map_graph_mode.dart` | Criar - enum/contrato do modo de grafo |
| `warp-prism/lib/features/map/widgets/map_graph_panel.dart` | Criar - subview Graph da Map surface |
| `warp-prism/test/features/map/map_graph_projection_test.dart` | Criar - prova de projeção por modo |
| `warp-prism/test/features/map/map_graph_panel_test.dart` | Criar - prova de alternância visual/estado do modo ativo |

### How

1. Tratar a projeção de grafo como uma camada derivada do backbone, não como responsabilidade do canvas.
2. Definir regras simples e testáveis para cada modo: containment privilegia hierarquia, operational privilegia rotas/uso, evidence privilegia task/changelog/proof links.
3. Manter o canvas como consumidor de um modelo já projetado, reduzindo o acoplamento entre física/renderização e semântica do workspace.
4. Testar a projeção antes da UI para garantir que o epic continue atendendo ao requisito de “real normalized edges”.

### Why

Sem esta task, o Graph tab corre o risco de virar uma visualização bonita mas semanticamente falsa. O valor da EPIC 05 depende de o grafo explicar relações reais entre assets, e isso só acontece se a projeção for tratada como contrato verificável independente do widget de canvas.

---

## ⛔ Anti-Hallucination Guardrails

> [!CAUTION]
> DO NOT preencher os três modos com arrays locais de demo para “parecer completo”. Se o modo não puder ser derivado do backbone normalizado, a task não está pronta para fechamento.

> [!IMPORTANT]
> Read EVERY file in `Where` before writing, and keep projection rules centralized in a dedicated adapter/service so later tasks can reuse the same graph semantics for inspector and stories.

---

## 📋 Completion Evidence (preenchido pelo agente executor)

> **OBRIGATÓRIO ao fechar a task.** O agente deve preencher esta seção ANTES de mover para `completed/`.
> Sem evidência = task NÃO pode ser movida.

- **Arquivos criados/modificados**:
  - `apps/observatory/lib/features/map/graph/map_graph_mode.dart` — MapGraphMode enum + edgeKindsForMode() + labelForMode()
  - `apps/observatory/lib/features/map/graph/map_graph_projection.dart` — MapGraphProjection + projectGraph() over normalized backbone
  - `apps/observatory/lib/features/map/widgets/map_graph_panel.dart` — MapGraphPanel keeps mode selector when empty; 48×48 chips; ActivateIntent
  - `apps/observatory/lib/features/map/map_workspace_page.dart` — always mounts MapGraphPanel (empty-edge selector retained)
  - `apps/observatory/lib/features/map/map_workspace_state.dart` — activeGraphMode + copyWith
  - `apps/observatory/lib/features/map/map_workspace_provider.dart` — changeGraphMode() / syncState()
  - `apps/observatory/lib/features/map/widgets/map_inspector_panel.dart` — const no-selection surface
  - `apps/observatory/test/features/map/map_graph_projection_test.dart` — 3-mode + empty-edge projection proof
  - `apps/observatory/test/features/map/map_graph_panel_test.dart` — mode switch, overflow, 48×48, empty-edge selector
  - `apps/observatory/test/features/map/map_surface_states_test.dart` / `map_workspace_page_test.dart` — graph empty + selector retained
  - `docs/changelog/2026-06-30-task-0512-map-graph-modes-adapters.md` — original changelog
  - `docs/changelog/2026-07-09-task-0512-map-graph-modes-adapters-path-to-100.md` — path-to-100 + pre-existing classification
- **Testes que verificam o trabalho**:
  - `test/features/map/map_graph_projection_test.dart`
  - `test/features/map/map_graph_panel_test.dart`
  - `test/features/map/` full suite
- **Resultado dos comandos de validação** (2026-07-09, from `apps/observatory/`):
  - `flutter analyze lib/features/map test/features/map lib/app/pages/map_page.dart` → **No issues found**
  - `flutter test test/features/map/` → **104/104 PASS**
  - Package `flutter analyze` → **1073 issues** (no hits under `lib/features/map` / `test/features/map`) — classified below
- **Pre-existing failures**:
  - Classification: **unrelated pre-existing**
  - Affected areas: package-wide legacy `DS*` consumers (`workspace_snapshot`, `governance`, UI organism tests, etc.)
  - Baseline evidence: package analyze 1073; map-path filter → zero hits; task touch set limited to Map feature
  - Regression introduced: **NONE**
- **Entrada no CHANGELOG**:
  - `docs/changelog/2026-07-09-task-0512-map-graph-modes-adapters-path-to-100.md`
- **Agent-wiki / docs institucionalização**: builders continuity handoff under `.agents/profiles/builders/`
- **Agente executor**: builders (omniroute/builder; reviewers unavailable → expert self-review)
- **Data de conclusão**: 2026-07-09
- **Self-score**: **100/100**

## Review Ledger

### 2026-06-19 — reviewers independent re-review
**Score**: 78/100 — REJECTED_TO_DOING
**Verdict**: Return to `02-doing` for graph toolbar overflow, missing graph panel widget proof, analyzer cleanup, production data wiring, and changelog evidence.
**Report**: `docs/reports/review-wave-2026-06-19/0512-map-graph-modes-adapters-rereview.md`

### 2026-06-30 — builders remediation
**Status**: Remediation Complete
**Details**: 
- Fixed mode selector overflow by using `Wrap`
- Added missing `map_graph_panel_test.dart`
- Cleared ALL remaining analyzer issues (36 info-level issues regarding const constructors and missing excludeSemantics) across `lib/features/map` and tests.
- Replaced `GestureDetector` with `FocusableActionDetector` for mode chips and correctly set `excludeSemantics: true` to prevent screen reader redundancy.
- Wired Graph production state through `workspaceSnapshotAsyncProvider`
- Fixed and updated `map_catalog_panel_test.dart`, `map_selection_and_inspector_test.dart`, `map_surface_states_test.dart`, and `map_workspace_page_test.dart` which were broken due to previous builder's refactors of UI aliases, const constructor migrations, and missing explicit callbacks.
- Logged changelog: `docs/changelog/2026-06-30-task-0512-map-graph-modes-adapters.md`

### 2026-06-30 — missing 48x48 touch targets review
**Score**: 88/100 — REJECTED_TO_DOING
**Verdict**: 3 graph mode chips are interactive controls but below 48x48 dp.

### 2026-06-30 — builders remediation round 2
**Status**: Ready for re-review
**Details**:
- Enforced min 48x48 dp touch target for all graph mode chips using Container `BoxConstraints` without breaking the compact layout spacing in `apps/observatory/lib/features/map/widgets/map_graph_panel.dart`.
- Added new test case in `apps/observatory/test/features/map/map_graph_panel_test.dart` to assert that all mode chips report rendered dimensions >= 48x48.
- Analyzed cleanly and verified test completion.

### 2026-06-30 — reviewers independent final re-review
**Score**: 82/100 — REJECTED_TO_DOING
**Verdict**: Graph mode projection and 3/3 48x48 graph chips are proven by scoped tests, but the package-level analyzer gate fails with 1126 issues, so Axiom 1 and the task exit condition `flutter analyze` are not satisfied.
**Findings**:
- CRITICAL: `flutter analyze` from `apps/observatory/` reports 1126 issues; representative failures include undefined DS symbols in `lib/features/workspace_snapshot/widgets/workspace_graph_panel.dart:159`, `lib/features/workspace_snapshot/widgets/workspace_search_bar.dart:27`, and `test/app/shell_responsive_layout_test.dart:93`. This falsifies completion evidence line 130 and exit condition line 54.
- MODERATE: `MapWorkspacePage` suppresses the Graph mode selector whenever the active projection has no eligible edges by returning `MapStatePanel.graphNoEdges` before `MapGraphPanel`, preventing users from switching to another graph mode that might contain edges (`apps/observatory/lib/features/map/map_workspace_page.dart:306-309`).
**Evidence**: `flutter test test/features/map/` passed 103/103; `flutter test test/features/map/map_graph_projection_test.dart test/features/map/map_graph_panel_test.dart` passed 13/13; task-scoped `flutter analyze lib/features/map test/features/map lib/app/pages/map_page.dart` passed; full `flutter analyze` failed.
**Path to 100**: Fix or formally classify the package analyzer failures, then render an empty-edges graph panel/state with the mode selector still available for mode changes.
**Lane action**: Returned to `docs/tasks/02-doing/` per S<90 review contract.

### 2026-07-09 — builders path-to-100 + expert self-review
**Score**: 100/100 — READY_FOR_REVIEW
**Status**: Path-to-100 complete; reviewers unavailable so builder expert self-review applied.
**Details**:
- Confirmed `MapWorkspacePage` always returns `MapGraphPanel` so empty modes retain mode chips (`map_workspace_page.dart` graph tab).
- `MapGraphPanel` shows `MapStatePanel(graphNoEdges)` **under** the mode selector when `projection.isEmpty`.
- Added widget proof: empty-edge projection keeps Containment/Operational/Evidence chips and accepts mode tap.
- Cleared task-scoped analyzer to **0 issues** (const / library hygiene).
- Formally classified package `flutter analyze` (1073 issues, DS* residue outside Map) as **pre-existing unrelated** per `.agents/rules/pre-existing-failure-policy.md` with zero map-path hits.
- Changelog: `docs/changelog/2026-07-09-task-0512-map-graph-modes-adapters-path-to-100.md`
**Lane action**: Moved to `docs/tasks/03-review/` for independent reviewer when available.

### 2026-07-09 — independent re-review (reviewers)
**Score**: 96/100 — HELD_IN_REVIEW_PATH_TO_100
**Verdict**: Task-scope accept (S≥90). Stay in `03-review/` (never 04-completed by reviewer).
**Report**: `docs/reports/review-wave-2026-07-09/task-0512-map-graph-modes-adapters-independent-rereview.md`
**Fresh proof**: map suite **104/104**; graph projection+panel **14/14**; scoped analyze **No issues found**; prior empty-edge / 48×48 / overflow / panel-test blockers **RESOLVED**.
**Open**: format dirt on `test/features/map/map_graph_panel_test.dart` (FORMAT_EXIT=1 only).
**Lane action**: stay `docs/tasks/03-review/`.

### 2026-07-17 — Independent drain re-review (reviewers / Batch 3)

- **Score**: `91/100`
- **Verdict**: `ACCEPTED_PATH_TO_100`
- **Lane**: `docs/tasks/04-completed/`
- **Report**: `docs/reports/review-wave-2026-07-17/task-0512-drain-review.md`
- **Note**: Exits met. Residual: production graph skips WorkspaceGraphBuilder inferred edges; format dirt on panel test.


### 2026-07-18 — Path-to-100 independent re-review (reviewers / BATCH R2)
- **Score**: 98/100 — ACCEPTED_COMPLETE
- **Report**: `docs/reports/review-wave-2026-07-18/task-0512-path100-rereview.md`
- **path100_applied**: yes; residual path-to-100 list empty
- **Lane**: promoted to `docs/tasks/04-completed/`
- **Top finding**: Builder edges wired; brief async graph-loading fallback residual
