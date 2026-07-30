# Task 0413: Warp Prism Shell States And Deep Link Fallbacks

> **Status**: `[x]` Done — held in review (path-to-100)
> **Review State**: Independent re-review **92/100** — `HELD_IN_REVIEW_PATH_TO_100` (2026-07-09)
> **Priority**: 🟡 P1
> **Type**: `feature`
> **Origin**: EPIC-04 Warp Prism Product Shell and Overview
> **Blocks**: EPIC-05 through EPIC-09 feature-surface promotions that rely on shared shell fallback behavior
> **Depends on**: Task 0410, Task 0411, Task 0412

> [!IMPORTANT]
> Task identity is lane-neutral. Use `Task 0413` plus optional slug for dependencies,
> blockers, review ledgers, reports, and architecture references. Lanes such as
> `02-doing` and `03-review` are mutable status, not identity. If a live file path
> is needed, resolve it from `docs/tasks/tasklist.md` or search under `docs/tasks/`.

---

## Objective

Harden the EPIC-04 shell by implementing shell-level loading, error, and empty states plus deep-link and asset-detail fallback behavior, so the product shell remains truthful and navigable when repositories are empty, parsing fails, or an asset-detail route cannot resolve a requested item.

## Background Context

### O que já existe:
- `warp-prism/docs/prompt.txt` explicitly requires empty/loading/error states, route/deep-link support where possible, and inspector/fullscreen detail behavior.
- Task 0410 should introduce the router skeleton, Task 0411 the shared frame, and Task 0412 the first data-driven Overview surface.
- Existing design-system atoms and organisms already provide glass panels, badges, status dots, and story panels that can present shell states consistently.

### O que está faltando / quebrado:
- No current shell-level fallback contract exists for failed parse/load, empty mock workspace, or unresolved asset-detail routes.
- Without this hardening, later feature pages can appear broken or blank even when the correct UX is to explain missing data or invalid deep links.
- EPIC-04 acceptance explicitly includes shell-level state handling, so leaving it implicit would produce a phantom-complete shell.

---

## Test Requirements

- The shell MUST expose a loading state for repository/provider initialization that is distinct from empty data.
- The shell MUST expose an error state for parsing/repository failures with actionable retry or reset affordances.
- The shell MUST expose an empty state when the mock workspace or a routed surface has no data to show.
- Asset-detail or inspector deep links MUST fail gracefully when the requested asset does not exist, with tested fallback behavior.
- The task MUST include widget or router tests covering at least loading, empty, error, and unresolved-detail scenarios.

---

## Exit Conditions (GDD/TDD)

- [x] Shell-level loading, empty, and error state widgets or templates exist and are wired into routed surfaces.
- [x] A retry or refresh affordance exists for recoverable shell/data failures.
- [x] Asset-detail or inspector deep-link fallback behavior is implemented for unresolved asset IDs or unsupported narrow-layout inspector states.
- [x] Widget or router tests cover loading, empty, error, and unresolved-detail scenarios.
- [x] From `apps/observatory/`, scoped `dart format --set-exit-if-changed` passes for shell/overview/deep-link surfaces.
- [x] From `apps/observatory/`, scoped `dart analyze` reports no issues on shell/overview/deep-link surfaces.
- [x] From `apps/observatory/`, scoped Flutter tests pass for shell states, deep-link fallback, and overview wiring.
- [x] Changelog entry is added under `docs/changelog/`.
- [x] Self-score 100/100 with builder expert self-review (independent reviewers unavailable).

---

## Details

### What

Subtasks:
- [x] **Ler o código existente antes de modificar**: read Task 0410, Task 0411, and Task 0412 outputs plus router, shell/overview providers, design-system atoms, story panel, prompt, and draft before writing.
- [x] Define a shell-state contract that distinguishes loading, empty, and error conditions.
- [x] Implement reusable shell-state UI and wire it into Overview or shared routed surfaces.
- [x] Implement graceful unresolved-detail/deep-link fallback behavior for asset routes or inspector selection.
- [x] Add widget/router tests for the required fallback scenarios.
- [x] **Refactoring pass**: keep state rendering reusable instead of cloning one-off placeholders per page; migrate shell/overview fallback UI to public Prism* API.
- [x] **Documentation update**: record durable fallback or deep-link conventions in class docs + changelog + agent-wiki continuity.
- [x] **Verificação de regressão**: run scoped format, analyze, and Flutter tests (Flutter SDK available 2026-07-09).

### Where

| Arquivo | Propósito |
|---------|-----------|
| `apps/observatory/lib/app/router.dart` | Fallback route handling and deep-link resolution. |
| `apps/observatory/lib/features/shell/` | Shared shell-state widgets/helpers. |
| `apps/observatory/lib/features/overview/` | Wire shell-state handling into Overview surface. |
| `apps/observatory/lib/app/pages/asset_detail_page.dart` | Unresolved asset deep-link fallback. |
| `apps/observatory/lib/app/pages/overview_page.dart` | Overview shell wiring to providers/states. |
| `apps/observatory/test/app/` | Router and deep-link fallback tests. |
| `apps/observatory/test/features/shell/` | Shell state handler widget tests. |
| `apps/observatory/test/features/overview/` | Overview loading/empty/error wiring tests. |

### How

1. Model shell states explicitly so loading, empty, and error never collapse into the same blank surface.
2. Implement fallback UI once and reuse it across routed pages via `ShellStateHandler`.
3. Treat deep-link failures as a first-class product scenario, not a debug-only edge case.
4. Prefer public Prism* API (`PrismStateSurface`, `PrismColors`, etc.) over internal DS* names.
5. Verify with scoped tests rather than relying on manual resize checks.

### Why

The observatory is only trustworthy if it explains absence, failure, and unresolved navigation clearly. Shell-level fallback behavior prevents later feature epics from shipping blank panels or dead deep links disguised as “partial implementation.”

---

## ⛔ Anti-Hallucination Guardrails

> [!CAUTION]
> Do not conflate loading, empty, and error into one generic placeholder card.

> [!CAUTION]
> Do not mark deep-link support complete unless unresolved asset IDs are covered by an automated test.

> [!IMPORTANT]
> Keep fallback behavior reusable at the shell level so later feature screens inherit it instead of rebuilding it inconsistently.

---

## 📋 Completion Evidence (preenchido pelo agente executor)

- **Arquivos criados/modificados (2026-07-09 path-to-100)**:
  - `apps/observatory/lib/features/shell/shell_state_handler.dart` — Prism* public API migration; loading/empty/error/unresolved/narrow fallback builders
  - `apps/observatory/lib/features/shell/shell.dart` — barrel export (existing)
  - `apps/observatory/lib/app/pages/asset_detail_page.dart` — unresolved deep-link fallback (existing wiring verified)
  - `apps/observatory/lib/app/pages/overview_page.dart` — OverviewPageShell provider wiring (existing)
  - `apps/observatory/lib/features/overview/overview_page.dart` — migrated DS* → Prism* so shell wiring tests compile against public barrel
  - `apps/observatory/test/features/shell/shell_state_handler_test.dart` — NoSplash harness + full state coverage
  - `apps/observatory/test/app/deep_link_fallback_test.dart` — NoSplash harness for headless InkSparkle safety
- **Testes que verificam o trabalho**:
  - `shell_state_handler_test.dart`: loading, compact loading, empty, empty action, error, retry, unresolved asset, narrow layout
  - `deep_link_fallback_test.dart`: empty/unknown/`resolved:false`/valid asset detail routes
  - `overview_shell_test.dart`: forced metrics/loading/error/zero-metrics structure
  - `overview_page_test.dart` + `overview_provider_test.dart`: overview surface integrity after Prism migration
- **Resultado dos comandos de validação** (from `apps/observatory/`):
  - `dart format --set-exit-if-changed lib/features/shell/ lib/features/overview/overview_page.dart lib/app/pages/asset_detail_page.dart lib/app/pages/overview_page.dart test/features/shell/ test/app/deep_link_fallback_test.dart test/features/overview/` → pass
  - `dart analyze lib/features/shell/shell_state_handler.dart lib/features/overview/overview_page.dart` → **No issues found**
  - `flutter test test/features/shell/shell_state_handler_test.dart test/app/deep_link_fallback_test.dart test/features/overview/ --reporter compact` → **All tests passed! (39)**
- **Entrada no CHANGELOG**: `docs/changelog/2026-07-09-task-0413-shell-states-deep-link-fallbacks-path-to-100.md`
- **Agent-wiki**: builders continuity entry for Task 0413 path-to-100
- **Self-score**: **100/100** (builder expert self-review; independent reviewers unavailable)
  - Contract: loading ≠ empty ≠ error ≠ unresolved deep-link (distinct UI + tests)
  - Retry affordance present on recoverable error path
  - Prism* public API preferred in shell fallback surface
  - Scoped format/analyze/test green; monorepo path is `apps/observatory/` (not repo-root `lib/`)
- **Agente executor**: builders (omniroute/builder)
- **Data de conclusão**: 2026-07-09
- **Blockers**: none (Flutter SDK available; prior “SDK missing” blocker cleared)

---

## Review Ledger

> [!IMPORTANT]
> Before path-to-100 work, read the latest full report and all reports listed
> under Previous Reports.

### Latest Review

- **Date**: 2026-07-09
- **Reviewer profile**: `reviewers`
- **Score**: `92/100`
- **Verdict**: `HELD_IN_REVIEW_PATH_TO_100`
- **Full report**: `docs/reports/review-wave-2026-07-09/task-0413-shell-states-deep-link-fallbacks-independent-rereview.md`
- **Lane outcome**: remains in `03-review`
- **Task reference**: Task 0413 (`warp-prism-shell-states-and-deep-link-fallbacks`)

#### Current Open Blockers

- `NEW` / Low: Overview empty uses zero-metrics dashboard, not `ShellStateHandler.buildEmpty`.
- `NEW` / Low: Deep-link tests pump page widget, not production `/assets/:id` via `appRouter`.

#### Path-to-100 Summary

- Document or wire empty Overview contract vs `buildEmpty`.
- One production-router unresolved asset deep-link test.
- **Regression guard**: loading ≠ empty ≠ error ≠ unresolved remain distinct in tests.

### Previous Reports

- `2026-06-19` — prior independent — `docs/reports/review-wave-2026-06-19/0413-shell-states-deep-link-fallbacks-independent-review.md`
- `2026-06-14` — `100/100` — `docs/reports/build-gate-review/0413-review.md` (superseded; SDK blocked)


### 2026-07-18 — Path-to-100 independent re-review (reviewers / BATCH R2)
- **Score**: 98/100 — ACCEPTED_COMPLETE
- **Report**: `docs/reports/review-wave-2026-07-18/task-0413-path100-rereview.md`
- **path100_applied**: yes; residual path-to-100 list empty
- **Lane**: promoted to `docs/tasks/04-completed/`
- **Top finding**: Empty chrome + production deep-link fallback unified
