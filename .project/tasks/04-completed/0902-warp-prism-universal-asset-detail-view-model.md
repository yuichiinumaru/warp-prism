# Task 0902: Warp-Prism Universal Asset Detail View Model

> **Review State**: 2026-07-18 path-to-100 independent re-review **100/100** `ACCEPTED_100`
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
- [x] `dart format --output=none --set-exit-if-changed` no escopo alterado passa sem erros.
- [x] `flutter analyze` no escopo do view-model/page/core presentation passa sem erros.
- [x] `flutter test test/features/asset_detail/asset_detail_descriptor_test.dart` passa com 0 falhas.
- [x] Entrada de changelog adicionada via engine em `docs/changelog/`.

---

## Details

### What

Subtasks:
- [x] **Ler código existente**: models, parser, inspector, prompt, research, prior re-review path-to-100
- [x] Definir o descriptor universal de asset detail com campos compartilhados, seções derivadas e fallback explícito.
- [x] Implementar o mapper/controller que transforma backbone normalizado em dados prontos para o inspector.
- [x] Cobrir com testes unitários a derivação de incoming/outgoing links, related assets e unsupported-kind fallback.
- [x] Implementar Riverpod providers (`assetDetailDescriptorProvider`, `selectedAssetDetailDescriptorProvider`).
- [x] Wire production `AssetDetailPage` to mapper-produced `AssetDetailView`.
- [x] **Refactoring pass**: Review implementation for simplicity.
- [x] **Documentation update**: changelog + builders continuity/agent-wiki notes
- [x] **Verificação de regressão**: scoped format/analyze/test green

### Where

| Arquivo | Propósito |
|---------|-----------|
| `apps/observatory/lib/data/models/workspace_graph.dart` | Ler - backbone asset/edge contracts. |
| `apps/observatory/lib/features/asset_detail/domain/asset_detail_descriptor.dart` | Criar/Modificar - contrato universal de detail + relatedAssets. |
| `apps/observatory/lib/features/asset_detail/application/asset_detail_mapper.dart` | Criar/Modificar - converter assets/edges em seções renderizáveis. |
| `apps/observatory/lib/features/asset_detail/application/asset_detail_controller.dart` | Criar/Modificar - pure resolvers + Riverpod providers. |
| `apps/observatory/lib/app/pages/asset_detail_page.dart` | Modificar - consumir provider e AssetDetailView. |
| `apps/observatory/test/features/asset_detail/asset_detail_descriptor_test.dart` | Criar/Modificar - descriptor/provider coverage. |
| `apps/observatory/test/app/deep_link_fallback_test.dart` | Modificar - route wiring proof. |

### How

1. Define one descriptor that is rich enough for all asset kinds but still renderable by generic inspector widgets.
2. Keep normalization and derivation in the application/domain layer, not in DS widgets.
3. Build fallback and empty-state semantics into the descriptor instead of leaving unsupported kinds implicit.
4. Expose graph-backed Riverpod providers and wire the canonical route page.
5. Prove the mapping + provider logic with deterministic unit/widget tests.

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
  - `apps/observatory/lib/features/asset_detail/domain/asset_detail_descriptor.dart` — relatedAssets + fallback link retention
  - `apps/observatory/lib/features/asset_detail/application/asset_detail_mapper.dart` — fallback preserves edges
  - `apps/observatory/lib/features/asset_detail/application/asset_detail_controller.dart` — Riverpod family + selection providers
  - `apps/observatory/lib/features/asset_detail/asset_detail.dart` — public barrel exports
  - `apps/observatory/lib/app/pages/asset_detail_page.dart` — production wiring to AssetDetailView
  - `apps/observatory/lib/features/asset_detail/presentation/{asset_detail_view,generic_asset_detail_view,responsive_detail_shell}.dart` — const/deprecation cleanup
  - `apps/observatory/test/features/asset_detail/asset_detail_descriptor_test.dart` — 31 tests
  - `apps/observatory/test/app/deep_link_fallback_test.dart` — mapper-backed route proof
  - `docs/changelog/20260709-130838-0902-universal-asset-detail-view-model-path-to-100-builders.md`
- **Testes que verificam o trabalho**:
  - `asset_detail_descriptor_test.dart` — shared sections, incoming/outgoing, relatedAssets, fallback, providers
  - `deep_link_fallback_test.dart` — `/assets/:id` renders AgentDetailView from mapper output
- **Resultado dos comandos de validação**:
  - `dart format` scoped — PASS
  - `flutter analyze` domain/application/page/core presentation/tests — PASS (0 issues)
  - `flutter test ...asset_detail_descriptor_test.dart ...deep_link_fallback_test.dart` — PASS (38 tests)
- **Entrada no CHANGELOG**: `docs/changelog/20260709-130838-0902-universal-asset-detail-view-model-path-to-100-builders.md`
- **Agent-wiki / docs institucionalização**: builders continuity handoff entry
- **Agente executor**: builders (omniroute/builder)
- **Data de conclusão**: 2026-07-09
- **Self-score**: 100/100

### Path-to-100 resolution vs 2026-06-19 re-review

| Finding | Resolution |
| --- | --- |
| F1 Mapper not consumed by production | `AssetDetailPage` watches `assetDetailDescriptorProvider` and renders `AssetDetailView` |
| F2 No Riverpod controller | Added `assetDetailDescriptorProvider` + `selectedAssetDetailDescriptorProvider` |
| F3 Widget tests hand-build descriptors | Deep-link test now uses mapper-backed provider path for known agent |
| F4 Analyzer issues in asset-detail | Core view-model/page/presentation sources clean (0 issues) |

### Latest Review Notes (builder self-review)

- Descriptor contract complete with relatedAssets derivation.
- Riverpod providers graph-backed and selection-synced.
- Production route no longer shows "coming soon" placeholder.
- Remaining non-core presentation widget test infos (skill/task/extended variants) are EPIC-09 follow-on surfaces, not 0902 view-model blockers.

---

## Review Ledger

> [!IMPORTANT]
> Before path-to-100 work, read the latest full report and all reports listed
> under Previous Reports.

### Latest Review

- **Date**: 2026-07-09
- **Reviewer profile**: `reviewers` (gt-flutter-code-reviewer + gt-code-quality-reviewer)
- **Score**: `96/100`
- **Verdict**: `HELD_IN_REVIEW_PATH_TO_100`
- **Report**: `docs/reports/review-wave-2026-07-09/task-0902-universal-asset-detail-view-model-independent-rereview.md`
- **Lane**: remain `03-review/` (never auto `04-completed/`)
- **Top residual**: cross-task mapper→variant matrix for 0904 kinds still thin (not 0902 exit block)
- **Key exits**: providers live; production page wired; 38 descriptor+deep-link tests; analyze clean

### Previous Reports

- `docs/reports/review-wave-2026-06-19/0902-universal-asset-detail-view-model-rereview.md` — 68/100 rejected
- `docs/reports/build-gate-review/0902-review.md` — historical 100

### Drain Review (2026-07-17 independent)
- **Reviewer profile**: `reviewers` (gt-flutter-code-reviewer + code-quality-harness)
- **Prior score (draft)**: 96/100
- **New score**: 97/100
- **Verdict**: PROMOTED → `04-completed/`
- **Full report**: `docs/reports/review-wave-2026-07-17/task-0902-drain-review.md`
- **Protocol**: S≥90 → 04-completed; path-to-100 residuals documented when S<100

### Independent path-to-100 re-review — 2026-07-18 (BATCH R3 / reviewers)

- **Score**: **100/100**
- **Verdict**: `ACCEPTED_100`
- **Full report**: `docs/reports/review-wave-2026-07-18/task-0902-path100-rereview.md`
- **Path-to-100 applied**: YES — builders batch3 residuals re-verified live; material residuals RESOLVED; optional polish SUPERSEDED/out-of-scope
- **Lane**: moved to `docs/tasks/04-completed/`
- **Regression guards**: keep suites/commands cited in the full report
- **No git / no tasklist**

