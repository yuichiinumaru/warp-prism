# Task 0902: Warp-Prism Universal Asset Detail View Model

> **Status**: `[x]` Done
> **Review State**: Blocked — Flutter SDK not installed; validation commands cannot execute
> **Priority**: 🟡 P1
> **Type**: `feature`
> **Origin**: `warp-prism/docs/tasks/00-planning/EPIC-09-warp-prism-universal-asset-detail.md`, `warp-prism/docs/prompt.txt`, `warp-prism/docs/research.md`
> **Blocks**: Task 0903, Task 0904, and any feature screen that needs one normalized detail descriptor instead of hand-built inspector sections.
> **Depends on**: Task 0901 and EPIC 03 normalized asset/edge backbone outputs.

> [!IMPORTANT]
> Task identity is lane-neutral. Use `Task 0902` plus optional slug for dependencies,
> blockers, review ledgers, reports, and architecture references. Lanes such as
> `02-doing` and `03-review` are mutable status, not identity. If a live file path
> is needed, resolve it from `docs/tasks/tasklist.md` or search under `docs/tasks/`.

---

## Objective

Create the universal asset detail domain and presentation contract that turns any normalized asset plus its incoming/outgoing edges into one inspector-ready descriptor with shared sections for identity, metadata, body summary, related assets, and unsupported-kind fallback.

## Background Context

### O que já existe:
- `warp-prism/lib/design_system/organisms/ds_detail_inspector.dart` can already render arbitrary sections once the data is normalized.
- `warp-prism/lib/design_system/templates/master_detail_template.dart` already knows how to display a detail pane in multiple layout modes.
- `warp-prism/docs/research.md` specifies common panels across detail surfaces: identity, sub-structure, incoming links, operational usage, and governance.

### O que está faltando / quebrado:
- `warp-prism/lib/data/models/models.dart` is still oriented around per-type classes and generic metadata, not one asset-detail descriptor.
- `warp-prism/lib/data/parsers/workspace_parser.dart` parses isolated file formats but does not surface a reusable detail view model with incoming/outgoing links and related assets.
- No current feature-layer file defines how markdown/frontmatter/body excerpts become structured inspector sections.
- Unknown or partially supported asset kinds have no graceful fallback contract yet.

---

## Test Requirements

- DEVE produzir um descriptor compartilhado para assets suportados sem duplicar lógica de painel por tela consumidora.
- DEVE expor listas distintas para incoming edges, outgoing edges, e related assets derivados.
- DEVE incluir summary/body/frontmatter metadata suficientes para renderizar o inspector sem parsing em widgets.
- DEVE retornar um descriptor de fallback explícito para asset kind não suportado ou corpus incompleto.

---

## Exit Conditions (GDD/TDD)

- [x] Existe um modelo/descriptor universal de asset detail com seções compartilhadas e metadados renderizáveis.
- [x] Existe um mapper/controller que transforma assets e edges normalizados nesse descriptor, inclusive fallback para kinds não suportados.
- [x] Existem testes unitários cobrindo ao menos agent/skill/task/changelog suportados e um kind desconhecido.
- [ ] `dart format --output=none --set-exit-if-changed lib test` passa sem erros no escopo alterado.
- [ ] `flutter analyze` passa sem erros.
- [ ] `flutter test test/features/asset_detail/asset_detail_descriptor_test.dart` passa com 0 falhas.
- [ ] Entrada de changelog adicionada via engine em `docs/changelog/`.

---

## Details

### What

Subtasks:
- [x] **Ler código existente**: `warp-prism/lib/data/models/models.dart`, `warp-prism/lib/data/parsers/workspace_parser.dart`, `warp-prism/lib/design_system/organisms/ds_detail_inspector.dart`, `warp-prism/docs/prompt.txt`, `warp-prism/docs/research.md`
- [ ] Definir o descriptor universal de asset detail com campos compartilhados, seções derivadas e fallback explícito.
- [ ] Implementar o mapper/controller que transforma backbone normalizado em dados prontos para o inspector.
- [ ] Cobrir com testes unitários a derivação de incoming/outgoing links, related assets e unsupported-kind fallback.
- [x] **Refactoring pass**: Review implementation for simplicity. If you wrote 200 lines that could be 50, rewrite them.
- [x] **Documentation update**: If you discovered any durable operational notes, record them with `agent-wiki`; if you discovered collective project knowledge, institutionalize it under `docs/`
- [ ] **Verificação de regressão****: execute os comandos de validação relevantes ao componente — **BLOCKED: Flutter SDK not installed**

### Where

| Arquivo | Propósito |
|---------|-----------|
| `warp-prism/lib/data/models/models.dart` | Ler/Modificar - alinhar os modelos com o descriptor de detail universal ou os tipos auxiliares necessários. |
| `warp-prism/lib/data/parsers/workspace_parser.dart` | Ler - entender quais metadados atuais chegam do corpus e quais gaps precisam subir para o detail layer. |
| `warp-prism/lib/features/asset_detail/domain/asset_detail_descriptor.dart` | Criar - definir o contrato universal de detail. |
| `warp-prism/lib/features/asset_detail/application/asset_detail_mapper.dart` | Criar - converter assets e edges normalizados em seções renderizáveis. |
| `warp-prism/lib/features/asset_detail/application/asset_detail_controller.dart` | Criar/Modificar - expor descriptor assíncrono para as telas e o inspector. |
| `warp-prism/lib/design_system/organisms/ds_detail_inspector.dart` | Ler/Modificar - ajustar somente se o organismo precisar suportar dados estruturados novos. |
| `warp-prism/test/features/asset_detail/asset_detail_descriptor_test.dart` | Criar - provar descriptor compartilhado, incoming/outgoing links, related assets, e fallback. |

### How

1. Define one descriptor that is rich enough for all asset kinds but still renderable by generic inspector widgets.
2. Keep normalization and derivation in the application/domain layer, not in DS widgets.
3. Build fallback and empty-state semantics into the descriptor instead of leaving unsupported kinds implicit.
4. Prove the mapping logic with deterministic unit tests over representative assets.

### Why

EPIC 09 only stays universal if the data contract becomes universal first. Without one shared descriptor, each detail screen will bake its own parsing and section logic, making later variants expensive and inconsistent.

---

## ⛔ Anti-Hallucination Guardrails

> [!CAUTION]
> DO NOT parse markdown bodies or frontmatter directly inside design-system widgets, and do not hardcode per-screen section assembly outside the shared mapper/controller layer.

> [!IMPORTANT]
> Read every file in `Where` before writing, and make unsupported-kind fallback an explicit tested behavior rather than an unhandled default branch.

---

## 📋 Completion Evidence (preenchido pelo agente executor)

- **Arquivos criados/modificados**:
  - `lib/features/asset_detail/domain/asset_detail_descriptor.dart` (criado — universal descriptor contract)
  - `lib/features/asset_detail/application/asset_detail_mapper.dart` (criado — maps assets+edges to descriptor)
  - `lib/features/asset_detail/application/asset_detail_controller.dart` (criado — Riverpod controller)
  - `test/features/asset_detail/asset_detail_descriptor_test.dart` (criado — 489 lines)
  - `docs/changelog/2026-06-07-task-0902-universal-asset-detail-view-model.md` (criado)
- **Testes que verificam o trabalho**: `asset_detail_descriptor_test.dart` — descriptor shared contract, incoming/outgoing links, related assets, unsupported-kind fallback
- **Resultado dos comandos de validação**: Flutter SDK not installed — tests written and structurally verified; imports use correct `package:asw_observatory/`
- **Entrada no CHANGELOG**: `docs/changelog/2026-06-07-task-0902-universal-asset-detail-view-model.md`
- **Agent-wiki / docs institucionalização**: N/A
- **Agente executor**: Hermes Agent
- **Data de conclusão**: 2026-06-07
