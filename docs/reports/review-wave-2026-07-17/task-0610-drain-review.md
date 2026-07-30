# Drain Review: Task 0610 — Operate Task Projection Contract — 2026-07-17

## Review Lineage

- Prior independent: `docs/reports/review-wave-2026-07-09/task-0610-operate-task-projection-independent-rereview.md` — **94/100**

## Score And Verdict

- **Prior score**: `94/100`
- **New score**: `91/100`
- **Verdict**: `ACCEPTED_PATH_TO_100`
- **Lane**: `docs/tasks/04-completed/`

## Delta Summary

### Reconfirmed

- Full `TaskProjection` contract fields; path-segment-wins `_inferLane`; tolerant headings; structured evidence rows/sections.
- Named parser suite live **29/29** (within combined operate+parser 70 green).
- Contract analyze clean (0 error/warning).
- Changelogs 2026-06-30 + 2026-07-09 path-to-100.

### Persistent Findings

- **PERSISTENT / Low**: Format dirt — `workspace_task_projection_parser.dart` FORMAT_EXIT=1.
- **PERSISTENT / Moderate (integration residual)**: Production Operate still uses `buildOperateProjection` → markdown `TaskMetadata` with **status-first** `_inferTaskLane` (`workspace_markdown_parser.dart:514–522`) / `_laneFromPath` status-first (`operate_projection_builder.dart:100–109`). Dedicated parser path-wins is **not** on the product board path. Dual inference rules remain.

### New Findings

- **NEW / Low**: No production entrypoint test asserts Operate lanes come exclusively from `WorkspaceTaskProjectionParser.parseAll` (EVIDENCE_GAP remains).

## Findings

| ID | Class | Severity | Status | Summary |
| --- | --- | --- | --- | --- |
| F1 | PERSISTENT | Low | Open | Format dirt on parser |
| F2 | PERSISTENT | Moderate | Open | Dual lane-inference paths |

## Exit Conditions

All task-scoped exits PASS (model, parser, 5-lane + corpus tests, analyze, changelog).

## Path To 100

1. `dart format` parser file.
2. Align production: either Operate loads via `WorkspaceTaskProjectionParser` or make markdown `_inferTaskLane` path-segment-wins identical; add regression for `03-review/` + stale `status: completed`.

## Lane Action

- Move → `docs/tasks/04-completed/`.
