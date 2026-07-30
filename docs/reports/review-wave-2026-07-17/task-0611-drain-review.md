# Drain Review: Task 0611 — Operate Board Surface Filters — 2026-07-17

## Review Lineage

- Prior independent: `docs/reports/review-wave-2026-07-09/task-0611-operate-board-surface-independent-rereview.md` — **93/100**

## Score And Verdict

- **Prior score**: `93/100`
- **New score**: `90/100`
- **Verdict**: `ACCEPTED_PATH_TO_100`
- **Lane**: `docs/tasks/04-completed/`

## Delta Summary

### Reconfirmed

- `/operate` → `OperatePage` → `buildOperateProjection` → `OperateWorkspaceView` (not empty shell).
- Five canonical lanes always; combinable filters; a11y Search/Clear semantics tests.
- Lifecycle 1:1 ViewModel StreamController + TextEditingController dispose.
- Board suite **41/41**; operate format on feature view files was clean previously.
- Retry on Operate **does** invalidate `workspaceSnapshotAsyncProvider` (better than Map).

### Persistent Findings

- **PERSISTENT / Moderate residual**: `taskProjectionFromAsset` is a **shallow** rematerialization — drops `sections`, `completionEvidenceRows`, `exitConditions` (defaults empty). Board does not need them; wording “consume Task 0610 projection” is only partially true.
- **PERSISTENT / Low**: prefer_const_* infos on operate views (~29 info when analyzing operate feature set).

### New Findings

- **NEW / Low**: Production lane source remains status-first via TaskMetadata (inherits 0610 F2); board filter-by-lane can disagree with directory placement for stale status fixtures.
- **NEW / Low**: No repository-backed OperatePage smoke without `forcedProjection`.

## Findings

| ID | Class | Severity | Status | Summary |
| --- | --- | --- | --- | --- |
| F1 | PERSISTENT | Moderate | Open | Shallow bridge vs full parser fields |
| F2 | PERSISTENT | Low | Open | prefer_const infos |
| F3 | NEW | Low | Open | Status-first lane on board path |

## Exit Conditions

All PASS (VM/lanes, filters, 41 tests, analyze 0 error, changelog).

## Path To 100

1. Deepen bridge to full 0610 parser fields (or call parser).
2. Align lane inference path-wins with 0610.
3. Optional const cleanups + repository-backed smoke test.

## Lane Action

- Move → `docs/tasks/04-completed/`.
