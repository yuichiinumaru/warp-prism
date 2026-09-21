# Review Report: Task 0510 — Map Workspace Scaffold — 2026-07-09

## Review Lineage

- **Current task**: Task 0510 (`warp-prism-map-workspace-scaffold`); live path: `docs/tasks/03-review/0510-warp-prism-map-workspace-scaffold.md`
- **Previous reports read**:
  - `docs/reports/build-gate-review/0510-review.md` — claimed `100/100`, SDK blocked
  - `docs/reports/review-wave-2026-06-19/0510-map-workspace-scaffold-rereview.md` — `78/100` REJECTED (45 analyzer issues, 4 failing tests, empty production data path, missing changelog)
- **Related reports considered**: Task 0511 catalog; Tasks 0410/0411 route shell
- **Review mode**: `re-review` / independent live verification

## Score And Verdict

- **Score**: `90/100`
- **Verdict**: `HELD_IN_REVIEW_PATH_TO_100`
- **Lane recommendation**: `hold-in-review`

## Delta Summary

### Resolved Since Previous Review

- `RESOLVED`: Live `flutter analyze lib/features/map lib/app/pages/map_page.dart test/features/map` → **No issues found**.
- `RESOLVED`: Live `flutter test test/features/map/` → **104/104 PASS** (builder claimed 103; live is 104).
- `RESOLVED`: Production `/map` hydrates from `workspaceSnapshotAsyncProvider` via `MapPageShell` (`map_page.dart:17–36`) → `MapWorkspacePage(initialState: …)`.
- `RESOLVED`: Four tabs Agents/Skills/Workflows/Graph via `PrismTabBar` + `IndexedStack` (`map_workspace_page.dart:48–74,187–199`).
- `RESOLVED`: Changelog `docs/changelog/2026-07-09-task-0510-map-workspace-scaffold.md`.
- `RESOLVED`: Lifecycle: `PrismTabController` listener removed + disposed; `MapWorkspaceProvider` StreamController closed (`map_workspace_page.dart:113–117`; `map_workspace_provider.dart:143–145`). **Created: 2 disposables; disposed: 2.**

### Persistent Findings

- None of the 2026-06-19 High findings remain open.

### Regressions

- None.

### New Findings

- `NEW` / Moderate: `MapWorkspaceState.operator ==` ignores `activeFilters`, `activeGraphMode`, `additionalState`, and catalog **identity** (only `catalogAssets.length`) (`map_workspace_state.dart:218–228`). `MapPageShell` rebuilds pass `initialState` into `didUpdateWidget` → `syncState` only when `!=`. Same-length catalog reloads can skip sync; equality is intentionally incomplete vs field set.
- `NEW` / Low: Map error `Retry` calls `_provider.clearError()` only — does not `invalidate` workspace snapshot (`map_workspace_page.dart:225–231`).
- `NEW` / Low: Builder test count under-claim (103 vs live 104).

### Evidence Gaps / External Blockers

- `EVIDENCE_GAP`: No single widget test that pumps `MapPageShell` under `ProviderScope` with overridden snapshot provider (route-level integration). Scaffold unit/widget suite covers page with injected state.
- `EXTERNAL_BLOCKER`: None.

## Findings

| ID | Class | Severity | Status | Summary | First seen | Evidence |
| --- | --- | --- | --- | --- | --- | --- |
| F1 | RESOLVED | High | Closed | Analyzer 45 issues / tests failing | 2026-06-19 | analyze clean; 104/104 |
| F2 | RESOLVED | High | Closed | Production Map empty / no repo path | 2026-06-19 | `map_page.dart:17–36` |
| F3 | RESOLVED | Moderate | Closed | Changelog missing | 2026-06-19 | changelog 2026-07-09 |
| F4 | NEW | Moderate | Open | Incomplete `MapWorkspaceState` equality | this review | `map_workspace_state.dart:218–228` |
| F5 | NEW | Low | Open | Error retry does not reload workspace | this review | `map_workspace_page.dart:230` |

## Exit Condition Verification

| Exit condition | Status | Live evidence |
| --- | --- | --- |
| `lib/features/map/` module page/state/provider | PASS | present |
| Route opens Map in shell | PASS | router → MapPageShell → MapWorkspacePage |
| Four tabs | PASS | page + tests |
| Widget tests route + non-happy path | PASS | workspace_page + surface_states suites |
| analyze / test / changelog | PASS | clean / 104 / present |

## Axiom Compliance

| Axiom | Status | Notes |
| --- | --- | --- |
| Analyzer Integrity | PASS | Map scope 0 issues |
| Lifecycle Safety | PASS | 2 create / 2 dispose exact |
| Dependency Direction | PASS | feature → data models/providers; no markdown in page |
| UI Accessibility | PARTIAL | Tabs labeled; catalog a11y residual owned with 0511 |
| Proof Reality | PASS | 104/104 live |
| Release Security | PASS | |

## Evidence Reviewed

- `map_workspace_page.dart`, `map_workspace_provider.dart`, `map_workspace_state.dart`
- `lib/app/pages/map_page.dart`, `lib/app/router.dart` `/map` branch
- Full `test/features/map/` suite

### Commands run

| Command | Result |
| --- | --- |
| `flutter analyze lib/features/map lib/app/pages/map_page.dart test/features/map` | **No issues found** |
| `flutter test --concurrency=1 --no-pub test/features/map/` | **+104 All tests passed** |

## Path To 100

1. Fix `MapWorkspaceState.==` / `hashCode` to include `activeFilters`, `activeGraphMode`, and catalog identity (e.g. `listEquals` / id set), matching fields that affect UI.
2. Map error Retry should invalidate `workspaceSnapshotAsyncProvider` (or accept reload callback from `MapPageShell`).
3. Add one `MapPageShell` + provider-override widget test for loading → data → empty.
4. Align Completion Evidence test count to 104.

## Task Ledger Patch Suggestion

See task file `Review Ledger`.
