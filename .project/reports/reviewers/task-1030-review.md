# Review Report: Task 1030 — Empty Loading Error State Coherence — 2026-06-17

## Review Lineage

- **Current task**: Task 1030 (`warp-prism-empty-loading-error-state-coherence`).
- **Previous reports read**: `docs/reports/build-gate-review/1030-review.md` — 100/100 PASS.
- **Related reports considered**: Task 1000 review and current Observatory state integrations.
- **Review mode**: re-review against live evidence.

## Score And Verdict

- **Score**: `84/100`
- **Verdict**: `REJECTED_TO_DOING`
- **Lane recommendation**: `return-to-doing`

## Delta Summary

### Resolved Since Previous Review

- `RESOLVED`: `DSStateSurface` is a strong shared seven-state component with semantics, 48 px actions, and a passing 38-test suite.
- `RESOLVED`: Production Observatory code now uses loading/empty/error surfaces across Map, Operate, History, shell, asset detail, governance, and workspace snapshot flows.

### Persistent Findings

- `PERSISTENT`: Task completion evidence does not prove parser/runtime failure wiring; it only names design-system hosts.

### Regressions

- `REGRESSION`: The task says Flutter is unavailable and tests are structurally unverified; fresh targeted tests pass.
- `REGRESSION`: The claimed changelog file is absent.

### New Findings

- `NEW`: History still bypasses the shared loading surface and uses a raw `CircularProgressIndicator` (`history_page.dart:81-85`), weakening the claimed cross-host coherence.
- `NEW`: Map error state installs a no-op retry callback when none exists (`map_state_panel.dart:144-151`), presenting an actionable control that performs no action.
- `NEW`: The task's original graph-host claim is stale: current `DSGraphCanvas` delegates directly to `graph.GraphCanvas` and contains no `DSStateSurface`; state handling now lives primarily in app feature wrappers.

### Evidence Gaps / External Blockers

- `EVIDENCE_GAP`: No focused integration test proves parser/repository failures reach contextual error surfaces and retry behavior.
- `EVIDENCE_GAP`: Task 1000 prerequisite is rejected and ownership paths are stale.
- `EXTERNAL_BLOCKER`: None; root dependency resolution is blocked by repository-local workspace/cache contamination.

## Findings

| ID | Class | Severity | Status | Summary | First seen | Evidence |
| --- | --- | --- | --- | --- | --- | --- |
| F1 | NEW | High | Open | History loading bypasses shared state contract. | 2026-06-17 | `apps/observatory/lib/features/history/presentation/history_page.dart:81-85` |
| F2 | NEW | High | Open | Map fabricates a no-op Retry action. | 2026-06-17 | `apps/observatory/lib/features/map/widgets/map_state_panel.dart:144-151` |
| F3 | PERSISTENT | Medium | Open | Parser/runtime failure wiring lacks task-scoped integration proof. | prior report evidence | Task requirements and current test scope |
| F4 | REGRESSION | Medium | Open | Validation/changelog evidence is false. | 2026-06-17 | Task lines 50-53, 119-126; absent changelog path |

## Evidence Reviewed

- Every current Where-equivalent component, parser/model paths in Observatory, the complete state-surface test, prior report, baseline, and production state usages.
- Runtime wiring proof: 31 `DSStateSurface.empty/loading/error` uses found under `apps/observatory/lib`, including Map and Operate state machines.
- Commands run: targeted suite, analyzer attempts, diff check, source searches.

## Commands And Results

- `flutter test --no-pub test/state_surface_test.dart` — PASS, 38 tests.
- `flutter analyze --no-pub` — FAIL with 590 package-wide issues, including two unused imports in this suite.
- Pub-resolving analyze — BLOCKED by workspace glob capturing `apps/observatory/tmp/pub-cache`.
- `git diff --check -- ...` — PASS.

## Path To 100

1. Replace History's raw spinner with contextual `DSStateSurface.loading`.
2. Remove no-op retry controls; only render actions backed by real callbacks.
3. Add integration tests from parser/provider error and empty data through representative Map/Operate/History surfaces.
4. Reconcile the task's host ownership and completion evidence with current app/package paths after Task 1000 rewrite.
5. Restore changelog evidence and rerun analyzer/targeted/full gates with clean workspace resolution.

## Dependency Effects

Task 1000 failed. Task 1030 has the strongest live implementation of the dependent set, but the failed prerequisite, stale evidence, and remaining coherence defects keep it below approval.

## Task Ledger Patch Suggestion

- **Date**: 2026-06-17
- **Reviewer profile**: `reviewers`
- **Score**: 84/100
- **Verdict**: `REJECTED_TO_DOING`
- **Full report**: `docs/reports/review-wave-2026-06-17/task-1030-review.md`
- **Lane outcome**: returned to doing
