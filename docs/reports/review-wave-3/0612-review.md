# Review Report: Task 0612 — Operate Task Detail Inspector — 2026-06-18

## Review Lineage

- **Current task**: Task 0612 (`0612-warp-prism-operate-task-detail-inspector`); reviewed at `docs/tasks/03-review/0612-warp-prism-operate-task-detail-inspector.md`.
- **Previous reports read**:
  - `docs/reports/build-gate-review/0612-review.md` — 100/100 Approved.
  - `docs/reports/build-gate-review/0610-review.md` — dependency approval with stale SDK blocker.
  - `docs/reports/build-gate-review/0611-review.md` — dependency approval with stale SDK blocker.
- **Related reports considered**:
  - `docs/reports/build-gate-review/1406-review.md` — later feature-flow remediation noted this same focused test as pending verification.
  - `docs/reports/warp-prism-failure-baseline-inventory.md` — records the same two task-detail inspector failures as pre-existing at the suite level.
- **Review mode**: re-review / final-gate.

## Score And Verdict

- **Score**: `58/100`
- **Verdict**: `REJECTED_TO_DOING`
- **Lane recommendation**: `return-to-doing`

## Delta Summary

### Resolved Since Previous Review

- `RESOLVED`: Flutter SDK is available in the current repo environment; the old “Flutter SDK not installed” blocker is stale.

### Persistent Findings

- `PERSISTENT`: The focused task-detail inspector test fails on the live tree with the same two failures documented in later failure-baseline evidence.

### Regressions

- None identified against the current live tree; this is stale completion evidence plus incomplete wiring rather than a newly introduced regression in this review.

### New Findings

- `NEW`: The Operate board selection never renders `OperateTaskDetailPanel`; selection only updates `selectedTaskId` in the board.
- `NEW`: The app’s `/operate` route still builds the placeholder `OperatePage`, so the task-detail inspector is not reachable from the production route.
- `NEW`: Focused analyzer on task-owned files reports task-owned warnings/issues, including unused imports in the new mapper/panel/view files.

### Evidence Gaps / External Blockers

- `EVIDENCE_GAP`: Task evidence claims skipped SDK validation and 11 tests; fresh validation now runs and fails `apps/observatory/test/features/operate/operate_task_detail_inspector_test.dart` at 11 total tests with 2 failures.
- `EXTERNAL_BLOCKER`: None for the focused proof. Flutter 3.44.1 / Dart 3.12.1 are installed.

## Findings

| ID | Class | Severity | Status | Summary | First seen | Evidence |
| --- | --- | --- | --- | --- | --- | --- |
| F1 | PERSISTENT | High | Open | Required focused widget test fails. | Later baseline / current review | `apps/observatory/test/features/operate/operate_task_detail_inspector_test.dart:126-168`; command output below: `+11 -2` |
| F2 | NEW | High | Open | Board selection does not show the inspector panel. | Current review | `apps/observatory/lib/features/operate/operate_workspace_view.dart:131-135` wires only `DSLaneBoard(selectedTaskId, onTaskTap)`; grep found no `OperateTaskDetailPanel`/`OperateTaskDetailEmpty` use outside their own file/tests. |
| F3 | NEW | High | Open | Production `/operate` route is still a placeholder, so the inspector is not reachable from the app shell. | Current review | `apps/observatory/lib/app/pages/operate_page.dart:4-24`; `apps/observatory/lib/app/router.dart:64-67` routes `/operate` to `OperatePage`. |
| F4 | NEW | Medium | Open | Task-owned analyzer issues remain. | Current review | Focused `flutter analyze --no-pub` reports unused imports at `operate_task_detail_mapper.dart:10`, `operate_task_detail_panel.dart:9`, `operate_workspace_view.dart:12`, plus task-owned lint issues. |

## Evidence Reviewed

- Task files: Task 0612 plus dependencies Task 0610 and Task 0611.
- Source/test files: `apps/observatory/lib/features/operate/operate_task_detail_mapper.dart`, `operate_task_detail_panel.dart`, `operate_workspace_view.dart`, `operate_workspace_view_model.dart`, `operate_storytelling.dart`, `task_projection.dart`, `operate_filters.dart`, `apps/observatory/lib/app/pages/operate_page.dart`, `apps/observatory/lib/app/router.dart`, `apps/observatory/test/features/operate/operate_task_detail_inspector_test.dart`, `operate_board_surface_test.dart`, `operate_storytelling_test.dart`, relevant DS files under `packages/warp_prism_ui/lib/src/`.
- Runtime wiring proof: not proven. The created panel is helper/widget code only; production routing still reaches placeholder `OperatePage`, and `OperateWorkspaceView` itself does not render the detail panel.
- Commands run:
  - `HOME="$PWD/tmp/home" PUB_CACHE="$PWD/tmp/pub-cache" TMPDIR="$PWD/tmp" flutter --version` — Flutter 3.44.1 / Dart 3.12.1.
  - `HOME="$PWD/tmp/home" PUB_CACHE="$PWD/tmp/pub-cache" TMPDIR="$PWD/tmp" flutter test --no-pub apps/observatory/test/features/operate/operate_task_detail_inspector_test.dart` — FAIL, `+11 -2`.
  - `HOME="$PWD/tmp/home" PUB_CACHE="$PWD/tmp/pub-cache" TMPDIR="$PWD/tmp" flutter analyze --no-pub apps/observatory/lib/features/operate/operate_task_detail_mapper.dart apps/observatory/lib/features/operate/operate_task_detail_panel.dart apps/observatory/lib/features/operate/operate_workspace_view.dart apps/observatory/lib/features/operate/operate_workspace_view_model.dart apps/observatory/lib/features/operate/operate_storytelling.dart apps/observatory/test/features/operate/operate_task_detail_inspector_test.dart apps/observatory/test/features/operate/operate_storytelling_test.dart` — 39 issues.
  - Supporting: `flutter test --no-pub apps/observatory/test/features/operate/operate_board_surface_test.dart` — PASS, 33 tests; `flutter test --no-pub apps/observatory/test/features/operate/operate_storytelling_test.dart` — PASS, 12 tests.
- Commands not run: full app test/analyze suite; working tree contains broad concurrent changes and focused task-owned gates already fail.
- Stale-evidence note: the old build-gate report treated skipped SDK commands as an external blocker and still approved 100/100. That proof is obsolete.

## Path To 100

1. Wire `OperateWorkspaceView` so selecting a lane card renders `OperateTaskDetailPanel` for the selected `TaskProjection`, with `OperateTaskDetailEmpty` when nothing is selected.
2. Replace the `/operate` placeholder with the real Operate surface or explicitly document a different production composition path and test it.
3. Fix `operate_task_detail_inspector_test.dart` failures without weakening assertions: disambiguate the duplicate “Exit Conditions” text and make the close-button tap hit a visible/interactive target.
4. Remove task-owned analyzer warnings/issues in the mapper/panel/view surfaces.
5. Refresh Completion Evidence with current Flutter/Dart versions, exact focused test/analyze output, and remove the stale SDK blocker.

## Task Ledger Patch Suggestion

Add a latest-review entry for 2026-06-18 with score 58/100, verdict `REJECTED_TO_DOING`, this report path, current open blockers F1-F4, and prior `docs/reports/build-gate-review/0612-review.md` as lineage.
