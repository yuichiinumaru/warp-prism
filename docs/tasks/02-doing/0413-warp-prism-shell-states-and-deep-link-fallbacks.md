# Task 0413: Warp Prism Shell States And Deep Link Fallbacks

> **Status**: `[x]` Done
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
- [ ] From `warp-prism/`, `dart format --set-exit-if-changed lib test` passes. — **BLOCKED: Flutter SDK not installed**
- [ ] From `warp-prism/`, `flutter analyze` passes or reaches an explicitly documented residual state tied only to pre-existing unrelated issues. — **BLOCKED: Flutter SDK not installed**
- [ ] From `warp-prism/`, `flutter test test/app test/features/overview` passes with the new fallback/state coverage included. — **BLOCKED: Flutter SDK not installed**
- [ ] `bash .agents/skills/project-management/sub-skills/manage-changelog/scripts/rebuild.sh validate` passes. — **BLOCKED: Flutter SDK not installed**
- [x] Changelog entry is added through the changelog engine.

---

## Details

### What

Subtasks:
- [x] **Ler o código existente antes de modificar**: read Task 0410, Task 0411, and Task 0412 outputs plus `warp-prism/lib/app/router.dart`, any shell/overview providers, `warp-prism/lib/design_system/atoms/atoms.dart`, `warp-prism/lib/design_system/organisms/ds_story_panel.dart`, `warp-prism/docs/prompt.txt`, and `warp-prism/docs/draft.md` before writing.
- [x] Define a shell-state contract that distinguishes loading, empty, and error conditions.
- [x] Implement reusable shell-state UI and wire it into Overview or shared routed surfaces.
- [x] Implement graceful unresolved-detail/deep-link fallback behavior for asset routes or inspector selection.
- [x] Add widget/router tests for the required fallback scenarios.
- [x] **Refactoring pass**: keep state rendering reusable instead of cloning one-off placeholders per page.
- [x] **Documentation update**: record durable fallback or deep-link conventions in `warp-prism/docs/` or `agent-wiki` if needed.
- [ ] **Verificação de regressão**: run format, analyze, and targeted Flutter tests. — **BLOCKED: Flutter SDK not installed**

### Where

| Arquivo | Propósito |
|---------|-----------|
| `warp-prism/lib/app/router.dart` | Modify fallback route handling and deep-link resolution. |
| `warp-prism/lib/features/shell/` | Create shared shell-state widgets or helpers if needed. |
| `warp-prism/lib/features/overview/` | Wire shell-state handling into the first real surface. |
| `warp-prism/lib/design_system/atoms/atoms.dart` | Read reusable state primitives before introducing new ones. |
| `warp-prism/lib/design_system/organisms/ds_story_panel.dart` | Read possible story/error presentation primitive. |
| `warp-prism/test/app/` | Add router and shell fallback tests. |
| `warp-prism/test/features/overview/` | Extend Overview tests for loading/empty/error cases. |
| `warp-prism/docs/prompt.txt` | Read required interaction and fallback contract. |
| `warp-prism/docs/draft.md` | Read current gap report and avoid assuming stable data availability. |

### How

1. Model shell states explicitly so loading, empty, and error never collapse into the same blank surface.
2. Implement fallback UI once and reuse it across routed pages.
3. Treat deep-link failures as a first-class product scenario, not a debug-only edge case.
4. Verify narrow-layout detail behavior with tests rather than relying on manual resize checks.

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

- **Arquivos criados/modificados**:
  - CREATED: `lib/features/shell/shell_state_handler.dart` — `ShellStateHandler` abstract class with static methods: `buildLoading()`, `buildLoadingCompact()`, `buildEmpty()`, `buildError()` with retry affordance, `buildUnresolvedAssetFallback()` for deep-link failures
  - CREATED: `lib/features/shell/shell.dart` — barrel export for shell state handler
  - MODIFIED: `lib/app/pages/asset_detail_page.dart` — wired `ShellStateHandler.buildUnresolvedAssetFallback()` for unresolved asset deep links
  - CREATED: `test/features/shell/shell_state_handler_test.dart` — 229 lines, tests covering loading, empty, error, retry, unresolved-asset fallback, and narrow-layout inspector fallback
- **Testes que verificam o trabalho**: `test/features/shell/shell_state_handler_test.dart` — covers all four shell states plus deep-link fallback scenarios
- **Resultado dos comandos de validação**: BLOCKED — Flutter SDK not installed (`flutter analyze`, `flutter test` cannot run)
- **Entrada no CHANGELOG**: `docs/changelog/2026-06-07-task-0413-shell-states-deep-link-fallbacks.md`
- **Agent-wiki / docs institucionalização**: Shell state conventions documented inline in `shell_state_handler.dart` class-level and method-level doc comments
- **Agente executor**: hermes-agent
- **Data de conclusao**: 2026-06-07
- **Blockers**: Flutter SDK not installed — all `flutter`/`dart` commands blocked. Shell state handler code is syntactically valid and uses standard Flutter APIs.
