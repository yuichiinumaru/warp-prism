# Review Report: Task 1030 — Empty/Loading/Error State Coherence — 2026-07-09

## Review Lineage

- **Current task**: Task 1030 (`1030-warp-prism-empty-loading-error-state-coherence`); live path at review start `docs/tasks/03-review/1030-warp-prism-empty-loading-error-state-coherence.md`
- **Previous reports read**:
  - `docs/reports/review-wave-2026-06-17/task-1030-review.md` — **84/100** `REJECTED_TO_DOING`
  - `docs/reports/build-gate-review/1030-review.md` — **100/100** historical (SDK-blocked; superseded)
- **Related reports considered**:
  - Task 1000 independent re-review (this wave)
  - Package `state_surface_test.dart` + Observatory feature state wiring
- **Review mode**: `re-review` (independent; Flutter + code-quality)
- **Reviewer profile**: `reviewers`

## Score And Verdict

- **Score**: `89/100`
- **Verdict**: `REJECTED_TO_DOING`
- **Lane recommendation**: `return-to-doing`
- **Human-facing verdict**: NEEDS FIX

## Delta Summary

### Resolved Since Previous Review (2026-06-17 @ 84/100)

- `RESOLVED` (High): History loading no longer uses a raw `CircularProgressIndicator`. Live `history_page.dart` uses `PrismStateSurface.loading` / `.error` / `.empty` (`:96`, `:105`, `:266`).
- `RESOLVED` (High): Shared surface is strong: seven-state `DSStateSurface` / `PrismStateSurface` with semantics; **29** package tests green (task text still says 26 — count drift).
- `RESOLVED` (Medium): Broad production adoption — **32** `PrismStateSurface.(empty|loading|error)` constructor uses under `apps/observatory/lib` across Map, Operate, History, shell, governance, asset detail, workspace snapshot.
- `RESOLVED` (Medium): SDK/validation unblocked; scoped analyze **No issues found** on state surface + tests; changelog present as `docs/changelog/20260607-211745-1030-…-repair-bot.md`.
- `RESOLVED` (partial): Graph empty state lives on `graph/graph_canvas.dart` via `DSStateSurface.empty` (ownership moved from claimed `ds_graph_canvas` host — legitimate design evolution).

### Persistent Findings

- `PERSISTENT` (High): Map still fabricates a **no-op Retry** when `onAction` is null:
  ```dart
  // map_state_panel.dart:148-152
  // ... provide a no-op so the Retry affordance remains visible ...
  onAction: onAction ?? () {},
  ```
  This directly contradicts the shared surface contract test *and* anti-hallucination of actionable states. Production `map_workspace_page` currently passes real `clearError` handlers, so the defect is latent in the panel API but still ships false affordance capability (also `map_no_results_state.dart:66` `onClearFilters ?? () {}`).
- `PERSISTENT` (Medium): No task-scoped integration proof that **parser/repository failures** surface contextual error + real retry end-to-end (package unit/widget only).

### Regressions

- None relative to shared component quality.

### New Findings

- `NEW` (Low): Completion Evidence test count **26/26** is stale vs live **29** tests in `state_surface_test.dart`.

### Evidence Gaps / External Blockers

- `EVIDENCE_GAP`: Parser → provider → Map/Operate/History error surface integration test still absent.

## Findings

| ID | Class | Severity | Status | Summary | First seen | Evidence |
| --- | --- | --- | --- | --- | --- | --- |
| F1 | RESOLVED | High | Closed | History bypasses shared loading surface | 2026-06-17 | `history_page.dart:96` `PrismStateSurface.loading` |
| F2 | PERSISTENT | High | Open | Map error installs no-op Retry | 2026-06-17 | `map_state_panel.dart:144-152`; `map_no_results_state.dart:66` |
| F3 | PERSISTENT | Medium | Open | Parser/runtime failure integration unproven | prior | No observatory integration suite for parse-fail → error surface |
| F4 | RESOLVED | Medium | Closed | SDK/changelog false | 2026-06-17 | Live green + changelog present |
| F5 | NEW | Low | Open | Evidence claims 26 tests; live 29 | this review | `rg test(|testWidgets(` → 29 |

## Exit Condition Verification

| Exit | Status | Live evidence |
| --- | --- | --- |
| Shared state rendering component | PASS | `ds_state_surface.dart` + Prism alias |
| Connected to real board/inspector/story hosts | PASS | lane board, timeline, story panel, graph canvas, data table, + Observatory |
| Regression for loading/empty/error | PASS | 29 package tests; action-null hides button in **package** surface |
| Scoped analyze | PASS | No issues found |
| Changelog | PASS | repair-bot engine file |

Exits that pass at package level are insufficient while F2 remains an intentional product-host violation of the same contract.

## Axiom Compliance

| Axiom | Status | Notes |
| --- | --- | --- |
| Analyzer Integrity | PASS (scoped) | Clean on surface |
| Lifecycle Safety | PASS | Stateless surface |
| Dependency Direction | PASS | |
| UI Accessibility | FAIL (partial) | No-op Retry announces actionable control without action |
| Proof Reality | PARTIAL | Component proven; host no-op + parser chain not |
| Release Security | PASS | |

## Evidence Reviewed

- `packages/warp_prism_ui/lib/src/molecules/ds_state_surface.dart`
- Host organisms: lane board, timeline, story panel, graph canvas, data table, log viewer, status grid
- Observatory: history_page, map_state_panel, map_workspace_page, operate_workspace_view, shell_state_handler, workspace_snapshot_page
- Prior independent findings F1–F4

## Commands And Results (fresh, this re-review)

```text
cd packages/warp_prism_ui
flutter test --no-pub test/state_surface_test.dart
→ All tests passed! (+29)
  includes: action button not rendered when onAction is null

flutter analyze --no-pub \
  lib/src/molecules/ds_state_surface.dart \
  test/state_surface_test.dart
→ No issues found!

# production wiring sample
rg -n 'PrismStateSurface\.(empty|loading|error)' apps/observatory/lib
→ 32 constructor uses across features

# residual defect still live
map_state_panel.dart:152 → onAction: onAction ?? () {},
map_no_results_state.dart:66 → onClearFilters ?? () {},
```

## Path To 100

1. **Required**: Remove no-op fallbacks in `MapStatePanel` / `map_no_results_state`. Only pass `actionLabel`+`onAction` when a real callback exists; rely on `PrismStateSurface` null-action behavior (already tested).
2. Add at least one integration/widget test: error panel with null `onAction` must **not** show Retry; with non-null callback, Retry invokes it.
3. Optional but contract-aligned: one parser/repository failure path test through Map or shell error surface.
4. Refresh Completion Evidence test counts (29) and monorepo host paths.

## Task Ledger Patch Suggestion

```markdown
### Latest Review
- **Date**: 2026-07-09
- **Reviewer profile**: `reviewers`
- **Score**: `89/100`
- **Verdict**: `REJECTED_TO_DOING`
- **Full report**: `docs/reports/review-wave-2026-07-09/task-1030-state-coherence-independent-rereview.md`
- **Lane outcome**: returned to `02-doing`
- **Open blockers**: F2 no-op Retry; F3 parser integration proof
```
