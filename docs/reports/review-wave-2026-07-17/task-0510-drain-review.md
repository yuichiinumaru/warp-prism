# Drain Review: Task 0510 — Map Workspace Scaffold — 2026-07-17

## Review Lineage

- **Current task**: Task 0510 (`warp-prism-map-workspace-scaffold`); was `docs/tasks/03-review/`
- **Previous reports (draft)**:
  - `docs/reports/review-wave-2026-07-09/task-0510-map-workspace-scaffold-independent-rereview.md` — **90/100**
  - `docs/reports/review-wave-2026-06-19/0510-map-workspace-scaffold-rereview.md` — 78/100
  - `docs/reports/build-gate-review/0510-review.md` — historical soft 100
- **Review mode**: independent drain re-review (gt-flutter-code-reviewer + code-quality-harness + flutter-harness)
- **No git / no tasklist**

## Score And Verdict

- **Prior score**: `90/100`
- **New score**: `88/100`
- **Verdict**: `REJECTED_TO_DOING`
- **Lane**: `docs/tasks/02-doing/`

## Delta Summary

### Resolved Since Prior Independent Review

- Live map suite still green (**105/105**; prior claimed 104 — suite grew by 1).
- Scoped `flutter analyze lib/features/map test/features/map lib/app/pages/map_page.dart` → **No issues found**.
- Production `/map` still hydrates via `MapPageShell` → `MapWorkspacePage`.
- Lifecycle still 1:1 for `PrismTabController` + provider `StreamController`.

### Persistent Findings

- **PERSISTENT / Moderate**: `MapWorkspaceState.==` / `hashCode` still ignore `activeFilters`, `activeGraphMode`, catalog identity (length only), and `additionalState` (`map_workspace_state.dart:218–238`).
- **PERSISTENT / Low**: Error Retry still calls `_provider.clearError()` only — no `invalidate(workspaceSnapshotAsyncProvider)` (`map_workspace_page.dart:250,303`).

### New Findings

- **NEW / Moderate**: `syncState` is a full replace (`map_workspace_provider.dart:133–135`). `MapPageShell` injects a bare `MapWorkspaceState(catalogAssets: …)` with default filters/selection/mode. When catalog **length** changes, `didUpdateWidget` triggers `syncState` and **wipes** interactive UI state. When length is unchanged but asset *content* changes, incomplete `==` **skips** sync so catalog identity can go stale.
- **NEW / Low**: Format dirt on owned files: `dart format --output=none --set-exit-if-changed` → exit 1 for `map_workspace_page.dart` (and graph panel test file adjacent).
- **NEW / Low**: No widget test pumps `MapPageShell` under `ProviderScope` with overridden snapshot (EVIDENCE_GAP remains).

### Regressions

- None vs green suite; score drop is from unresolved + newly elevated parent-sync risk.

## Findings

| ID | Class | Severity | Status | Summary |
| --- | --- | --- | --- | --- |
| F1 | PERSISTENT | Moderate | Open | Incomplete `MapWorkspaceState` equality |
| F2 | PERSISTENT | Low | Open | Retry clears error without reloading workspace |
| F3 | NEW | Moderate | Open | `syncState` full-replace vs incomplete equality causes wipe/stale catalog races |
| F4 | NEW | Low | Open | Format dirt on `map_workspace_page.dart` |

## Exit Condition Verification

| Exit | Status | Live evidence |
| --- | --- | --- |
| Map module page/state/provider | PASS | `lib/features/map/` present |
| Route opens Map in shell | PASS | router → MapPageShell |
| Four tabs | PASS | PrismTabBar + IndexedStack |
| Widget tests + non-happy path | PASS | suite 105 |
| analyze / test / changelog | PASS | clean / 105 / `2026-07-09-task-0510-…` |

Exits met, but quality axioms (lifecycle data sync correctness) fail path-to-100 bar → hold below 90.

## Axiom Compliance

| Axiom | Status | Notes |
| --- | --- | --- |
| Analyzer Integrity | PASS | 0 issues scoped |
| Lifecycle Safety | PARTIAL | dispose 1:1 OK; parent inject/sync race |
| Dependency Direction | PASS | feature ← data models/providers |
| UI Accessibility | PASS (scoped) | tabs labeled; catalog Clear residual owned by 0511 |
| Proof Reality | PASS | 105/105 live |
| Release Security | PASS | read-only |

## Commands Run

```text
cd apps/observatory
flutter test --concurrency=1 --no-pub test/features/map/
→ +105 All tests passed!

flutter analyze --no-pub lib/features/map/ test/features/map/ lib/app/pages/map_page.dart
→ No issues found!

dart format --output=none --set-exit-if-changed lib/features/map/map_workspace_page.dart
→ FORMAT_EXIT=1
```

## Path To 100

1. Fix `MapWorkspaceState.==` / `hashCode` to include `activeFilters`, `activeGraphMode`, catalog identity (`listEquals` / id set), matching UI-affecting fields.
2. Change `syncState` / `MapPageShell` to merge catalog/error/loading into existing interactive state (preserve filters/selection/mode) rather than full replace.
3. Map error Retry must invalidate `workspaceSnapshotAsyncProvider` (callback from shell) — not only `clearError()`.
4. `dart format` owned map page; add one `MapPageShell` + provider-override widget test (loading → data → empty).
5. Align Completion Evidence test count to **105**.

## Lane Action

- Move task file → `docs/tasks/02-doing/` for path-to-100 remediation.
