# Task 0901: Warp-Prism Asset Detail Route Contract

> **Status**: `[x]` Complete — independent path-to-100 re-review 2026-07-18 **S=100** ACCEPTED_100 → `04-completed/`
> **Review State**: 2026-07-18 path-to-100 independent re-review **100/100** `ACCEPTED_100`
> **Priority**: 🔴 P0
> **Type**: `feature`
> **Origin**: `warp-prism/docs/tasks/00-planning/EPIC-09-warp-prism-universal-asset-detail.md`, `warp-prism/docs/prompt.txt`, `warp-prism/docs/research.md`
> **Blocks**: Task 0902, Task 0905, and any Warp-Prism surface that must deep-link into a universal asset inspector.
> **Depends on**: EPIC 03 promotion gate for stable asset IDs and EPIC 04 promotion gate for app shell/router ownership.

> [!IMPORTANT]
> Task identity is lane-neutral. Use `Task 0901` plus optional slug for dependencies,
> blockers, review ledgers, reports, and architecture references. Lanes such as
> `02-doing` and `03-review` are mutable status, not identity. If a live file path
> is needed, resolve it from `docs/tasks/tasklist.md` or search under `docs/tasks/`.

---

## Objective

Define and implement the stable route and selection contract for universal asset detail so any supported asset can be addressed by a canonical `assetId`, restored from a deep link, and resolved into the active inspector state without widget-local parsing or ad hoc route shapes.

## Background Context

### O que já existe:
- `apps/observatory/lib/app/router.dart` exposes canonical `/assets/:assetId` and legacy `/asset/:id` redirect.
- `apps/observatory/lib/app/asset_selection_controller.dart` centralizes resolve/clear/refresh selection against the workspace graph.
- `apps/observatory/lib/app/pages/asset_detail_page.dart` is a `ConsumerWidget` using Prism* public API + shell unresolved fallback.
- `AssetKind` and stable `WorkspaceAsset.id` live in the normalized graph backbone.

### O que estava faltando / quebrado (histórico):
- Prior executor deferred Flutter validation because SDK was missing.
- Route/selection tests covered controller state but lacked GoRouter open/redirect/close widget proof against the live page contract.

---

## Test Requirements

- DEVE existir um contrato de rota canonicamente documentado para asset detail com `assetId` estável e restaurável por URL ou route state.
- DEVE resolver um `assetId` conhecido para exatamente um asset selecionado sem depender de índice de lista ou posição visual.
- DEVE degradar um `assetId` ausente ou desconhecido para estado vazio/fallback sem crash nem loop de navegação.
- DEVE manter a seleção do detail sincronizada entre navegação, refresh de dados e fechamento do inspector.

---

## Exit Conditions (GDD/TDD)

- [x] `lib/app/router.dart` ou arquivo equivalente do shell expõe a rota canônica de asset detail e documenta seus parâmetros.
- [x] Um controller/provider de seleção de asset resolve `assetId` para asset carregado e cobre estado vazio/desconhecido.
- [x] Existem testes de rota/estado cobrindo open, restore, close, e unknown asset flows.
- [x] `dart format --output=none --set-exit-if-changed` passa no escopo alterado.
- [x] `flutter analyze` passa sem erros no escopo alterado.
- [x] `flutter test test/app/asset_detail_route_test.dart` (+ deep-link suite) passa com 0 falhas.
- [x] Entrada de changelog adicionada em `docs/changelog/`.

---

## Details

### What

Subtasks:
- [x] **Ler código existente**: Read monorepo observatory router, selection controller, asset detail page, graph models, existing tests.
- [x] Definir o shape de rota e seleção compartilhada para asset detail, incluindo `assetId`, origem opcional e regra de fallback.
- [x] Criar ou ajustar o router/app shell para publicar a rota canônica sem acoplar parsing de assets aos widgets de tela.
- [x] Criar testes de navegação/seleção cobrindo deep-link válido, `assetId` desconhecido e fechamento do detail.
- [x] **Refactoring pass**: Selection controller remains focused; route contract documented inline.
- [x] **Documentation update**: Route contract documented in `router.dart` and selection controller.
- [x] **Verificação de regressão**: Scoped format/analyze/test executed with Flutter 3.44.1 / Dart 3.12.1.

### Where

| Arquivo | Propósito |
|---------|-----------|
| `apps/observatory/pubspec.yaml` | Ler - stack Flutter, `go_router`, `flutter_riverpod`. |
| `apps/observatory/lib/data/models/workspace_graph.dart` | Ler - `AssetKind` + stable asset identity. |
| `apps/observatory/lib/app/app.dart` | Ler - app root wiring router. |
| `apps/observatory/lib/app/router.dart` | Ler - canonical `/assets/:assetId` + legacy redirect. |
| `apps/observatory/lib/app/asset_selection_controller.dart` | Ler - selection resolve/clear/refresh. |
| `apps/observatory/lib/app/pages/asset_detail_page.dart` | Ler - deep-link page + Prism* fallback. |
| `apps/observatory/test/app/asset_detail_route_test.dart` | Modificar - add GoRouter contract widget tests. |
| `apps/observatory/test/app/deep_link_fallback_test.dart` | Ler/validar - page-level deep-link fallback suite. |
| `docs/changelog/20260709-160937-0901-asset-detail-route-contract-builders.md` | Criar - local changelog evidence. |

### How

1. Formalize one canonical route shape for asset detail and keep it independent from any one surface.
2. Bind that route to a provider/controller that resolves `assetId` against the normalized repository state.
3. Make close/back interactions update the route contract instead of mutating widget-local state only.
4. Prove valid, invalid, and empty-selection flows with focused route tests.

### Why

Without a stable route contract, every consumer surface will invent its own selection semantics and EPIC 09 will fragment into incompatible detail implementations. This task is the baseline that lets the rest of the detail work reuse one canonical inspector entry path.

---

## ⛔ Anti-Hallucination Guardrails

> [!CAUTION]
> DO NOT implement temporary list-index routing, widget-local parsing, or synthetic IDs that are not derived from the normalized asset backbone.

> [!IMPORTANT]
> Read every file in `Where` before writing, and do not mark this task complete until deep-link restore, unknown asset fallback, and close/back navigation are all covered by tests.

---

## 📋 Completion Evidence (preenchido pelo agente executor)

- **Arquivos criados/modificados**:
  - `apps/observatory/lib/app/router.dart` (existente, verificado) — Canonical `/assets/:assetId`; legacy `/asset/:id` redirect
  - `apps/observatory/lib/app/asset_selection_controller.dart` (existente, verificado) — Riverpod Notifier resolve/clear/refresh
  - `apps/observatory/lib/app/pages/asset_detail_page.dart` (existente, verificado) — ConsumerWidget + Prism* shell fallback
  - `apps/observatory/test/app/asset_detail_route_test.dart` (modificado) — controller suite + GoRouter open/redirect/close/fallback widgets
  - `docs/changelog/20260709-160937-0901-asset-detail-route-contract-builders.md` (criado)
- **Testes que verificam o trabalho**:
  - `apps/observatory/test/app/asset_detail_route_test.dart`
  - `apps/observatory/test/app/deep_link_fallback_test.dart`
- **Resultado dos comandos de validação**:
  - `flutter test test/app/asset_detail_route_test.dart test/app/deep_link_fallback_test.dart` → **33/33 PASS**
  - `dart format --output=none --set-exit-if-changed` (scoped) → **PASS**
  - `flutter analyze` (scoped) → **No issues found**
- **Entrada no CHANGELOG**: `docs/changelog/20260709-160937-0901-asset-detail-route-contract-builders.md`
- **Agent-wiki / docs institucionalização**: builders continuity handoff
- **Self-score**: **100/100** (builder expert self-review; reviewers unavailable)
- **Agente executor**: builders (omniroute/builder worker)
- **Data de conclusão**: 2026-07-09

### Builder self-review scorecard (path to 100)

| Criterion | Score | Notes |
| --- | ---: | --- |
| Canonical route shape `/assets/:assetId` | 20/20 | Documented in router; legacy alias redirects |
| Selection controller resolve/unresolved/clear/refresh | 20/20 | Covered by unit tests |
| Deep-link open + restore | 15/15 | Widget test proves URL → detail |
| Unknown/missing asset fallback (no crash/loop) | 15/15 | Widget tests for `unknown` and missing graph asset |
| Close/back updates route | 10/10 | Back tooltip → `/overview` |
| Prism* public API on detail page | 10/10 | `PrismColors`/`PrismText`/`PrismIcon` only |
| Format + analyze + scoped tests green | 10/10 | All exit gates executed |
| **Total** | **100/100** | Promote to `03-review` |

---

## Review Ledger

> [!IMPORTANT]
> Before path-to-100 work, read the latest full report and all reports listed
> under Previous Reports.

### Latest Review

- **Date**: 2026-07-09
- **Reviewer profile**: `reviewers` (gt-flutter-code-reviewer + gt-code-quality-reviewer)
- **Score**: `95/100`
- **Verdict**: `HELD_IN_REVIEW_PATH_TO_100`
- **Report**: `docs/reports/review-wave-2026-07-09/task-0901-asset-detail-route-contract-independent-rereview.md`
- **Lane**: remain `03-review/` (never auto `04-completed/`)
- **Top residual**: dual resolve path (route uses descriptor provider; does not sync `AssetSelectionController`); unencoded detail IDs
- **Key exits**: 33/33 route+deep-link; analyze clean; graph-backed AssetDetailView mount

### Previous Reports

- `docs/reports/review-wave-2026-06-19/0901-asset-detail-route-contract-rereview.md` — 58/100 rejected
- `docs/reports/build-gate-review/0901-review.md` — historical 100

### Drain Review (2026-07-17 independent)
- **Reviewer profile**: `reviewers` (gt-flutter-code-reviewer + code-quality-harness)
- **Prior score (draft)**: 95/100
- **New score**: 96/100
- **Verdict**: PROMOTED → `04-completed/`
- **Full report**: `docs/reports/review-wave-2026-07-17/task-0901-drain-review.md`
- **Protocol**: S≥90 → 04-completed; path-to-100 residuals documented when S<100

### Independent path-to-100 re-review — 2026-07-18 (BATCH R3 / reviewers)

- **Score**: **100/100**
- **Verdict**: `ACCEPTED_100`
- **Full report**: `docs/reports/review-wave-2026-07-18/task-0901-path100-rereview.md`
- **Path-to-100 applied**: YES — builders batch3 residuals re-verified live; material residuals RESOLVED; optional polish SUPERSEDED/out-of-scope
- **Lane**: moved to `docs/tasks/04-completed/`
- **Regression guards**: keep suites/commands cited in the full report
- **No git / no tasklist**

