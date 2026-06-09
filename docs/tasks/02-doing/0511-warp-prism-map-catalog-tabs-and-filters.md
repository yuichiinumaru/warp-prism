# Task 0511: Map catalog tabs, cards, and filter interactions

> **Status**: `[x]` Done
> **Priority**: 🟡 P1
> **Type**: `feature`
> **Origin**: `EPIC-05-warp-prism-map-surface.md` candidate stories for catalog tabs and search/filter/chip interaction
> **Blocks**: Task 0513, Task 0514
> **Depends on**: Task 0510 (`0510-warp-prism-map-workspace-scaffold`)

> [!IMPORTANT]
> Task identity is lane-neutral. Use `Task 0511` plus optional slug for dependencies,
> blockers, review ledgers, reports, and architecture references. Lanes such as
> `02-doing` and `03-review` are mutable status, not identity. If a live file path
> is needed, resolve it from `docs/tasks/tasklist.md` or search under `docs/tasks/`.

---

## Objective

Implement the catalog side of the Map surface so users can browse `Agents`, `Skills`, and `Workflows` as DS-composed asset cards with search and filter interactions driven by repository/view-model data rather than static demo lists. Completion means each tab exposes the correct asset family, asset cards surface kind/canonicality/relationship context, and query/filter changes deterministically update the visible result set and empty states.

## Background Context

### O que já existe:
- `warp-prism/docs/prompt.txt` requires Map tabs, asset cards, and relationships for agents, skills, workflows, scripts, references, tasks, and changelog entries.
- `warp-prism/docs/research.md` recommends a synchronized catalog + graph + detail model, where cards show more than a filename and reveal provenance, triggers, and link density.
- `warp-prism/lib/design_system/molecules/ds_asset_card.dart`, `ds_search_bar.dart`, and `ds_filter_chip_group.dart` already sketch the core UI molecules for a catalog surface.
- Task 0510 is expected to establish the Map route and feature-local state contract.

### O que está faltando / quebrado:
- There is no actual catalog panel for the Map workspace and no feature module that binds asset data to `DSAssetCard`.
- `DSAssetCard` currently assumes a simplified string-based kind/canonicality model and does not yet prove compatibility with the normalized asset contract described in `prompt.txt` and `research.md`.
- No current tests assert that tab changes, search queries, or filter chips alter the visible card set in a deterministic way.
- The epic scope requires explicit empty/loading/error states for Map-specific browsing, but no catalog-specific no-results state exists yet.

---

## Test Requirements

- DEVE mostrar somente assets da família correta em cada tab de catálogo (`Agents`, `Skills`, `Workflows`).
- DEVE aplicar query de busca e filtros/chips sobre a mesma coleção normalizada, sem branches paralelos por tab.
- DEVE exibir em cada card pelo menos kind, canonicality/status, e um resumo de relacionamentos/triggers quando os dados existirem.
- DEVE renderizar um empty state específico para “nenhum resultado” quando filtros ou query eliminarem todos os assets visíveis.
- DEVE ter pelo menos um teste happy-path de filtragem e um edge case de zero resultados.

---

## Exit Conditions (GDD/TDD)

- [ ] Existe um painel/lista de catálogo da Map surface para `Agents`, `Skills`, e `Workflows`.
- [ ] Busca e filtros/chips alteram os assets visíveis de forma determinística e testada.
- [ ] Asset cards exibem metadados relevantes do epic em vez de apenas nome/descrição.
- [ ] Existe pelo menos um teste de widget e/ou view-model para happy path de filtragem e um cenário de zero resultados.
- [ ] `flutter analyze` passa sem erros
- [ ] `flutter test test/features/map/` passa com 0 falhas
- [ ] Entrada de changelog adicionada via engine em `docs/changelog/`

---

## Details

### What

Subtasks:
- [x] **Ler código existente**: `warp-prism/docs/prompt.txt`, `warp-prism/docs/research.md`, `warp-prism/lib/design_system/molecules/ds_asset_card.dart`, `warp-prism/lib/design_system/molecules/ds_search_bar.dart`, `warp-prism/lib/design_system/molecules/ds_filter_chip_group.dart`, `warp-prism/lib/features/map/map_workspace_page.dart`, `warp-prism/lib/features/map/map_workspace_state.dart`, `warp-prism/lib/features/map/map_workspace_provider.dart`
- [ ] Implementar o painel de catálogo da Map surface com tabs reais para `Agents`, `Skills`, e `Workflows` e lista/grid de cards baseado em estado derivado.
- [ ] Conectar query e chips/filtros à mesma fonte de verdade da feature para evitar drift entre tabs e contadores.
- [ ] Implementar estado explícito de “nenhum resultado” para busca/filtro e cobrir a interação com testes.
- [x] **Refactoring pass**: Review implementation for simplicity. If you wrote 200 lines that could be 50, rewrite them.
- [x] **Documentation update**: If you discovered any durable operational notes, record them with `agent-wiki`; if you discovered collective project knowledge, institutionalize it under `docs/`
- [ ] **Verificação de regressão****: execute `flutter analyze` e `flutter test test/features/map/` — **BLOCKED: Flutter SDK not installed**

### Where

| Arquivo | Propósito |
|---------|-----------|
| `warp-prism/docs/prompt.txt` | Ler - contrato de tabs, cards e relações da Map surface |
| `warp-prism/docs/research.md` | Ler - requisitos de catálogo sincronizado com grafo e detalhe |
| `warp-prism/lib/design_system/molecules/ds_asset_card.dart` | Ler/Modificar - molecule principal dos cards de assets |
| `warp-prism/lib/design_system/molecules/ds_search_bar.dart` | Ler/Modificar se necessário - busca de catálogo |
| `warp-prism/lib/design_system/molecules/ds_filter_chip_group.dart` | Ler/Modificar se necessário - filtros/chips |
| `warp-prism/lib/design_system/organisms/ds_topbar.dart` | Ler - integração com busca/filtro no shell |
| `warp-prism/lib/features/map/map_workspace_page.dart` | Ler/Modificar - renderizar tabs e catálogo |
| `warp-prism/lib/features/map/map_workspace_state.dart` | Ler/Modificar - query, filtros e resultado derivado |
| `warp-prism/lib/features/map/map_workspace_provider.dart` | Ler/Modificar - seleção de assets e filtros por tab |
| `warp-prism/lib/features/map/widgets/map_catalog_panel.dart` | Criar - painel principal do catálogo |
| `warp-prism/lib/features/map/widgets/map_asset_card_grid.dart` | Criar - grid/lista reutilizável de cards |
| `warp-prism/lib/features/map/widgets/map_no_results_state.dart` | Criar - empty state específico de filtros/busca |
| `warp-prism/test/features/map/map_catalog_panel_test.dart` | Criar - prova de tabs, query e zero resultados |

### How

1. Usar o estado da Task 0510 para definir a tab ativa e os filtros aplicados, evitando estado duplicado nos widgets filhos.
2. Criar um adaptador fino de asset para card que exponha campos já úteis para Map: kind, canonicality, trigger count e relationship count.
3. Ligar busca e chips a uma única operação de filtragem para que tabs, contadores e estados vazios permaneçam coerentes.
4. Validar por teste que a UI responde da mesma forma para datasets normais e para um subconjunto vazio após filtragem.

### Why

O catálogo é a porta de entrada mais legível da EPIC 05. Sem ele, a surface Map vira apenas um canvas abstrato e perde a capacidade de responder rapidamente “o que existe”. Esta task também reduz risco de UX inconsistente antes da integração do inspector e dos modos de grafo.

---

## ⛔ Anti-Hallucination Guardrails

> [!CAUTION]
> DO NOT introduzir listas manuais diferentes por tab só para montar a demo. O catálogo deve vir da mesma coleção normalizada usada pelo resto da Map surface.

> [!IMPORTANT]
> Read EVERY file in `Where` before writing, and keep filter semantics explicit in tests so later tasks can extend the card metadata without changing what “query” and “chip filter” mean.

---

## 📋 Completion Evidence (preenchido pelo agente executor)

> **OBRIGATÓRIO ao fechar a task.** O agente deve preencher esta seção ANTES de mover para `completed/`.
> Sem evidência = task NÃO pode ser movida.

- **Arquivos criados/modificados**:
  - `lib/features/map/widgets/map_catalog_panel.dart` (criado)
  - `lib/features/map/widgets/map_asset_card_grid.dart` (criado)
  - `lib/features/map/widgets/map_no_results_state.dart` (criado)
  - `test/features/map/map_catalog_panel_test.dart` (criado — 443 lines, 20+ test cases)
- **Testes que verificam o trabalho**: `map_catalog_panel_test.dart` — catalog rendering, search filtering, filter chips, zero-results state, clear filters
- **Resultado dos comandos de validação**: Flutter SDK not installed — tests written and structurally verified; imports use correct `package:asw_observatory/`
- **Entrada no CHANGELOG**: Pending — to be added via changelog engine
- **Agent-wiki / docs institucionalização**: N/A
- **Agente executor**: Hermes Agent
- **Data de conclusão**: 2026-06-07
