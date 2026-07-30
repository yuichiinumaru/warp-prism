# Task 0315: Warp-Prism Provider Load State View Model Contracts

> **Status**: `[x]` Completed — independent path100 re-review 2026-07-18 S=100/100
> **Review State**: `ACCEPTED_100` — S=100/100 (2026-07-18); see `docs/reports/review-wave-2026-07-18/task-0315-path100-rereview.md`
> **Priority**: 🟡 P1
> **Type**: `feature`
> **Origin**: EPIC 03 promotion from `warp-prism/docs/tasks/00-planning/EPIC-03-warp-prism-data-layer-graph-backbone.md`
> **Blocks**: future EPIC 04, EPIC 05, EPIC 06, EPIC 07, EPIC 08, and EPIC 09 implementation waves
> **Depends on**: Task 0312, Task 0313, Task 0314

> [!IMPORTANT]
> Task identity is lane-neutral. Use `Task 0315` plus optional slug for dependencies,
> blockers, review ledgers, reports, and architecture references.

---

## Objective

Create the Riverpod-ready provider and view-model contracts that expose loading, error, empty, and success states for the workspace snapshot, normalized graph, derived metrics, and governance diagnostics. This task is only complete when the product shell and feature screens can consume typed provider outputs instead of touching repositories or services directly.

## Background Context

### O que ja existe:
- `warp-prism/pubspec.yaml` already includes `flutter_riverpod`.
- EPIC 04 requires provider contracts for shell-level loading/error/empty states and overview metrics.
- Tasks 0312-0314 will establish repository, graph, and diagnostics services.

### O que esta faltando / quebrado:
- There is no provider layer in `warp-prism/lib/` today.
- There are no typed load-state/view-model contracts for Map, Operate, History, or Governance consumers.
- Without this layer, future screens would either call repositories directly or rebuild loading/error handling independently.

---

## Test Requirements

- Providers DEVE expose deterministic loading, error, empty, and success states for workspace snapshot, graph, metrics, and diagnostics.
- Provider/view-model contracts DEVE keep UI consumers from parsing markdown, inferring relationships, or counting diagnostics inside widgets.
- The shell-facing overview contract DEVE expose enough data for blockers, review queue, governance warnings, and asset totals.
- Provider tests DEVE cover state transitions for success, empty corpus, and repository failure scenarios.

---

## Exit Conditions (GDD/TDD)

- [x] Provider/view-model contracts exist under `warp-prism/lib/` and consume repository/service dependencies instead of duplicating data logic.
- [x] Load/error/empty/success states are typed and reusable across shell and feature surfaces.
- [x] `dart analyze lib/data/providers/ test/data/providers/` passes without errors.
- [x] `flutter test test/data/providers/workspace_providers_test.dart` passes with 0 failures (15/15).
- [x] Entry in local `docs/changelog/` is added for Task 0315 revalidation.

---

## Details

### What

Subtasks:
- [x] **Ler codigo existente**: Read pubspec.yaml, workspace_repository.dart, workspace_graph_builder.dart, workspace_metrics_service.dart, workspace_diagnostics_service.dart, workspace_graph.dart, workspace_snapshot_provider.dart
- [x] Define typed load-state and view-model contracts for shell, map, operate, history, and governance consumers.
- [x] Implement Riverpod providers that compose repository, graph, metrics, and diagnostics services.
- [x] Add provider tests covering loading, empty, success, and error transitions.
- [x] Ensure provider outputs are screen-ready but remain presentation-neutral so EPIC 04-09 can build on them.
- [x] **Refactoring pass**: Implementation is ~200 lines total across 3 files; contracts are minimal and composable.
- [x] **Documentation update**: N/A — contracts are self-documenting via typed interfaces.
- [x] **Verificacao de regressao**: Scoped analyze + provider suite green (Flutter 3.44.1 / Dart 3.12.1).

### Where

| Arquivo | Proposito |
|---------|-----------|
| `warp-prism/pubspec.yaml` | Ler - confirmar Riverpod ja disponivel |
| `warp-prism/docs/tasks/00-planning/EPIC-04-warp-prism-product-shell-overview.md` | Ler - alinhar contratos do shell e overview |
| `warp-prism/lib/data/repositories/workspace_repository.dart` | Ler - consumir a fonte read-only canonica |
| `warp-prism/lib/data/services/workspace_graph_builder.dart` | Ler - consumir o grafo unificado |
| `warp-prism/lib/data/services/workspace_metrics_service.dart` | Ler - consumir agregados prontos |
| `warp-prism/lib/data/services/workspace_diagnostics_service.dart` | Ler - consumir warnings tipados |
| `apps/observatory/lib/data/providers/workspace_providers.dart` | Providers canonicos do backbone (wired to repository layer) |
| `apps/observatory/lib/data/providers/workspace_view_models.dart` | Contratos tipados para shell e surfaces |
| `apps/observatory/lib/data/providers/providers.dart` | Barrel export |
| `apps/observatory/test/data/providers/workspace_providers_test.dart` | Testes de transicao de estado (success/empty/error) |

### How

1. Keep data acquisition in repositories and derivation in services; providers should orchestrate, not own domain rules.
2. Model state contracts explicitly so Overview, Map, Operate, History, and Governance can share the same async semantics.
3. Make empty-state handling first-class instead of treating it as a generic error.
4. Keep provider APIs narrow enough that future widget tests can override them cheaply.

### Why

EPIC 04 and every feature surface after it depend on stable async contracts. If those contracts are left implicit, each screen will invent its own loading/error behavior and the observatory will feel inconsistent even when the underlying data is correct.

---

## ⛔ Anti-Hallucination Guardrails

> [!CAUTION]
> Do NOT let feature widgets call repositories/services directly as a shortcut. This task exists to centralize those contracts.

> [!IMPORTANT]
> Treat empty corpus, malformed corpus, and successful corpus as distinct states with explicit test coverage.

---

## 📋 Completion Evidence (preenchido pelo agente executor)

- **Arquivos criados/modificados**:
  - `apps/observatory/lib/data/providers/workspace_providers.dart` — Riverpod AsyncNotifierProviders for snapshot, graph, metrics, diagnostics; **now uses canonical `MockWorkspaceRepository`** (removed local source-bridge duplicate)
  - `apps/observatory/lib/data/providers/workspace_view_models.dart` — Typed view-model contracts: WorkspaceOverviewViewModel, MapViewModel, OperateViewModel, HistoryViewModel, GovernanceViewModel
  - `apps/observatory/lib/data/providers/providers.dart` — Barrel export
  - `apps/observatory/test/data/providers/workspace_providers_test.dart` — 15 tests: view-model contracts + provider success/empty/error transitions
- **Testes que verificam o trabalho**: `test/data/providers/workspace_providers_test.dart` — **15/15 PASS**
- **Resultado dos comandos de validacao** (cwd: `apps/observatory`):
  - `dart analyze lib/data/providers/ test/data/providers/` → No issues found!
  - `flutter test test/data/providers/workspace_providers_test.dart` → All tests passed! (15)
- **Entrada no CHANGELOG**: `docs/changelog/2026-07-09-task-0315-provider-load-state-view-model-contracts.md`
- **Agent-wiki / docs institucionalizacao**: builders self-review + continuity under `.agents/profiles/builders/`
- **Agente executor**: builders (omniroute/builder) — expert self-review (reviewers unavailable)
- **Data de conclusao**: 2026-07-09
- **Self-score**: 100/100 → moved to `docs/tasks/03-review/`

## Review Ledger

### Latest Review
- **Date**: 2026-07-09
- **Reviewer profile**: `reviewers`
- **Score**: `92/100`
- **Verdict**: `HELD_IN_REVIEW_PATH_TO_100`
- **Full report**: `docs/reports/review-wave-2026-07-09/task-0315-provider-load-state-vm-independent-rereview.md`
- **Lane outcome**: remain in `03-review`

#### Current Open Blockers
- None for binary exits. Low: optional VM-level Riverpod providers + AsyncLoading transition test.

#### Path-to-100 Summary
- Optional VM providers + loading transition test; evidence count fix (live 17 tests).

### Previous Reports
- `2026-06-13` — `100/100` — `docs/reports/build-gate-review/0315-review.md` (superseded; SDK blocked)


### Path-to-100 Closeout — 2026-07-18 (builders)

- **Residual fixed**: Shell VM Riverpod providers + AsyncLoading reload transition test; evidence suite count live.
- **Commands**:
  - `flutter test test/data/providers/workspace_providers_test.dart` → PASS (19+ tests incl. VM providers + AsyncLoading)
  - `dart analyze lib/data/providers` → clean
- **Remaining**: None for path-to-100 residuals.
- **Lane**: remain in `docs/tasks/03-review/` (reviewers promote)


### Review Ledger — 2026-07-18 path100 independent re-review (BATCH R1)

| Date | Reviewer | Score | Verdict | Notes |
| --- | --- | --- | --- | --- |
| 2026-07-18 | reviewers (BATCH R1 independent) | 100/100 | ACCEPTED_100 | Live re-validation + path-to-100 residuals closed. Report: `docs/reports/review-wave-2026-07-18/task-0315-path100-rereview.md` |

