# Task 1404: View-model and Mapper Contract Reconciliation

> **Status**: `[x]` Builder Done
> **Priority**: 🟡 P1
> **Type**: `remediation`
> **Origin**: EPIC-14, stabilization wave, failures in providers, repositories,
>   and view-model tests.
> **Blocks**: 1405, 1406
> **Depends on**: 1403 (parsers must produce correct data first)

> [!IMPORTANT]
> Task identity is lane-neutral. Use `Task 1404` plus optional slug for
> dependencies, blockers, review ledgers, reports, and architecture references.

---

## Objective

Reconcile the view-model and mapper layers in `apps/observatory/` so that
domain models correctly map to presentation models used by feature UI.

## Background Context

### What already exists

- `apps/observatory/lib/data/providers/workspace_providers.dart` — Riverpod
  providers.
- `apps/observatory/lib/data/providers/workspace_view_models.dart` — view models.
- `apps/observatory/lib/data/repositories/` — repository layer.
- `apps/observatory/lib/data/services/` — services (graph builder, diagnostics,
  metrics).
- Tests in `test/data/providers/`, `test/data/repositories/`, `test/data/services/`.

### What is missing or broken

- View-model mapping may not match current domain model shapes.
- Provider tests may fail because provider output does not match test expectations.
- Repository/service tests may fail because of model contract changes.

---

## Test Requirements

- Provider tests pass.
- Repository tests pass.
- Service tests pass.
- View-model shape matches what feature UI expects.

---

## Exit Conditions

- [x] `flutter test apps/observatory/test/data/providers/` passes.
- [x] `flutter test apps/observatory/test/data/repositories/` passes.
- [x] `flutter test apps/observatory/test/data/services/` passes.
- [x] Local changelog entry added under `docs/changelog/`.
- [x] Completion Evidence is filled before review handoff.

---

## Details

### What

Subtasks:

- [x] **Read existing code before modifying**: Read
  provider, repository, and service test files. Read the corresponding
  implementations.
- [x] For each failing test, determine root cause (model shape mismatch,
  stale expectation, broken mapping).
- [x] Fix accordingly.
- [x] **Simplicity pass**: fix drift, do not redesign provider architecture.
- [x] **Regression verification**: run all data-layer tests.

### Where

| File | Purpose |
| --- | --- |
| `apps/observatory/lib/data/providers/*.dart` | Read / Modify — fix providers |
| `apps/observatory/lib/data/repositories/*.dart` | Read / Modify — fix repositories |
| `apps/observatory/lib/data/services/*.dart` | Read / Modify — fix services |
| `apps/observatory/test/data/` | Read / Modify — fix test expectations |

### How

1. Read each failing test and implementation.
2. Identify drift.
3. Fix.
4. Run tests.

### Why

The data layer is the bridge between parsers and UI. If mappers and view-models
are broken, no feature surface can display correct data.

---

## Anti-Hallucination Guardrails

> [!CAUTION]
> Do not change model shapes without verifying all downstream consumers.
> Model changes cascade to feature UI.

---

## Validation Commands

```bash
flutter test apps/observatory/test/data/
```

---

## Completion Evidence

- **Files created/modified**:
  - `apps/observatory/test/data/services/workspace_diagnostics_service_test.dart` — fixed `_buildHealthyGraph()` fixture (task 1003 proofState `none` → `complete`), updated proof gap expectation from 1 to 0
  - `apps/observatory/lib/features/overview/overview_provider.dart` — moved `_countGovernanceWarnings(diagnostics)` before `assets.isEmpty` early return; renamed `_emptyMetrics()` → `_emptyMetricsWithGov(int govWarningCount)` to propagate diagnostic-derived count in empty-asset path
- **Tests or validation commands**:
  - `flutter test test/data/providers/` — 12/12 PASS
  - `flutter test test/data/repositories/` — 6/6 PASS
  - `flutter test test/data/services/` — 64/64 PASS (was 63/64)
  - `flutter test test/data/models/` — 27/27 PASS
  - `flutter test` (full suite) — 602 pass, 51 fail (was 600 pass, 53 fail; baseline was 589 pass, 64 fail)
- **Local changelog entry**: `docs/changelog/2026-06-09-task-1404-view-model-mapper-reconciliation.md`
- **Agent-wiki / docs institutionalization**: N/A
- **Executor**: builders
- **Completion date**: 2026-06-09
