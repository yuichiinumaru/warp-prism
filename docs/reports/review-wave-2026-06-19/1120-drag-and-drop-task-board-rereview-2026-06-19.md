# Review Report: Task 1120 — Drag And Drop Task Board — 2026-06-19

## Review Lineage

- **Current task**: Task 1120 (`warp-prism-drag-and-drop-task-board`); live path before routing was `docs/tasks/03-review/1120-warp-prism-drag-and-drop-task-board.md`.
- **Previous reports read**:
  - `docs/reports/build-gate-review/1120-review.md` — 2026-06-13 prior 100/100 approval.
  - `docs/reports/build-gate-review/1120-review-2026-06-18-independent.md` — 2026-06-18 independent rejection, 58/100.
- **Related reports/tasks considered**:
  - Task 1105 live path `docs/tasks/02-doing/1105-warp-prism-token-theme-catalog-policy.md` — still `Status: Doing`, `Review State: Doing`.
  - Task 1107 live path `docs/tasks/02-doing/1107-warp-prism-melos-monorepo-migration.md` — still `Status: Doing`, `Review State: Doing`.
- **Review mode**: re-review / lineage verification / lane-state reconciliation.

## Score And Verdict

- **Score**: `58/100`
- **Verdict**: `REJECTED_TO_DOING`
- **Lane recommendation**: `return-to-doing`
- **Remediation applied after 2026-06-18?** No. The analyzer, test-reality, insertion-index, keyboard accessibility, and upstream blockers remain live.

## Axiom Compliance

| Axiom | Status | Evidence |
| --- | --- | --- |
| Analyzer Integrity | FAIL | `flutter analyze --no-pub lib/src/molecules/ds_draggable_card.dart lib/src/molecules/ds_drop_target.dart lib/src/organisms/ds_lane_board.dart test/molecules/ds_drag_drop_test.dart` reported exactly 21 issues: 2 warnings and 19 info-level issues. |
| Lifecycle Safety | PASS | Exact count: 0 timers, 0 controllers, 0 stream subscriptions, 0 listeners created by Task 1120 files; no `dispose()` required. |
| Dependency Direction | PARTIAL | Task 1120 depends on Task 1105 and Task 1107 at `docs/tasks/03-review/1120-warp-prism-drag-and-drop-task-board.md:9`; both remain in `02-doing`. |
| UI Accessibility | PARTIAL | Exact count in Task 1120 source: 1 `LongPressDraggable<DSDragPayload>` at `ds_draggable_card.dart:84`, 1 `DragTarget<DSDragPayload>` at `ds_drop_target.dart:54`, 3 `Semantics` wrappers in `ds_lane_board.dart:36,97,193`, and 0 semantic drag instructions or keyboard move/reorder actions in the drag wrapper/board. |
| Proof Reality | FAIL | `flutter test --no-pub test/molecules/ds_drag_drop_test.dart` passed 17/17, but tests remain vacuous for core behavior: no assertion after long-press feedback, no real drop invoking `onReorder`, no real drop invoking `onMove`, no hover highlight assertion, and no insertion-index movement assertion. |
| Release Security | PASS | No secrets, endpoints, logging, permissions, or release build configuration changed in Task 1120 files. |

## Delta Summary

### Resolved Since Previous Review

- `RESOLVED`: Focused drag-drop tests remain reproducible live: 17/17 pass.
- `RESOLVED`: No 2026-06-18 open code/proof findings were resolved.

### Persistent Findings

- `PERSISTENT`: Task 1105 and Task 1107 prerequisites remain unapproved and in `02-doing`.
- `PERSISTENT`: Scoped analyzer still reports exactly 21 issues.
- `PERSISTENT`: Drag/drop tests still do not prove core drag/drop callbacks or visual feedback.
- `PERSISTENT`: DSDropTarget still has no `DragTarget.onMove` handler.
- `PERSISTENT`: No keyboard-accessible reorder/move path or semantic drag instructions exist.

### Regressions

- None beyond the 2026-06-18 regression already recorded from prior false approval.

### New Findings

- `NEW`: Lane-state defect verified. The task file was physically in `03-review` while its header said `Status: Doing` and `Review State: Doing` at `docs/tasks/03-review/1120-warp-prism-drag-and-drop-task-board.md:3-4`. This is resolved by this review's routing move back to `02-doing`.

### Evidence Gaps / External Blockers

- `EXTERNAL_BLOCKER`: Full package/Melos gates remain unsafe as promotion proof while Task 1107's workspace migration is rejected.

## Findings

| ID | Class | Severity | Status | Summary | First seen | Evidence |
| --- | --- | --- | --- | --- | --- | --- |
| F1 | PERSISTENT | High | Open | Task 1120 depends on rejected/unapproved Task 1105 and Task 1107. | 2026-06-18 report | Dependency at `docs/tasks/03-review/1120-warp-prism-drag-and-drop-task-board.md:9`; upstream states at `docs/tasks/02-doing/1105...md:3-4` and `docs/tasks/02-doing/1107...md:3-4`. |
| F2 | PERSISTENT | High | Open | Scoped analyzer integrity still fails with exactly 21 issues: 2 warnings and 19 info-level issues. | 2026-06-18 report | Current command output; representative lines: `packages/warp_prism_ui/lib/src/molecules/ds_draggable_card.dart:105`, `packages/warp_prism_ui/lib/src/molecules/ds_drop_target.dart:78-108`, `packages/warp_prism_ui/lib/src/organisms/ds_lane_board.dart:202-204`, `packages/warp_prism_ui/test/molecules/ds_drag_drop_test.dart:249,262`. |
| F3 | PERSISTENT | Critical | Open | Focused tests remain structurally passing but behaviorally vacuous for required drag/drop behavior. | 2026-06-18 report | Long-press test has no post-drag assertion at `packages/warp_prism_ui/test/molecules/ds_drag_drop_test.dart:119-132`; `onReorder` callback test only checks widget existence at `ds_drag_drop_test.dart:248-259`; `onMove` callback test only checks widget existence at `ds_drag_drop_test.dart:261-271`. |
| F4 | PERSISTENT | High | Open | Required insertion-index tracking on pointer move is still not implemented. | 2026-06-18 report | Task requirement at `docs/tasks/03-review/1120...md:89`; `DSDropTarget` has `onWillAcceptWithDetails` and `onAcceptWithDetails` at `packages/warp_prism_ui/lib/src/molecules/ds_drop_target.dart:55-75`, but no `onMove` in `ds_drop_target.dart:54-119`. |
| F5 | PERSISTENT | Moderate | Open | Keyboard accessibility is not provided for reorder/move operations and draggable task cards lack semantic drag instructions. | 2026-06-18 report | Drag wrapper at `packages/warp_prism_ui/lib/src/molecules/ds_draggable_card.dart:84-119`; board semantics at `packages/warp_prism_ui/lib/src/organisms/ds_lane_board.dart:36-38,97-99,193-195`; no keyboard move/reorder action in `ds_lane_board.dart:1-247`. |
| F6 | NEW | Moderate | Resolved by routing | Task was in the review lane while explicitly marked `Doing`, violating lane-state rules for `03-review`. | 2026-06-19 re-review | Header at `docs/tasks/03-review/1120-warp-prism-drag-and-drop-task-board.md:3-4`; lane rules at `docs/governance/promotion-state-model.md:182-188`. |

## Evidence Reviewed

- Task file: `docs/tasks/03-review/1120-warp-prism-drag-and-drop-task-board.md`.
- Previous reports: `docs/reports/build-gate-review/1120-review.md`, `docs/reports/build-gate-review/1120-review-2026-06-18-independent.md`.
- Source/test files: `packages/warp_prism_ui/lib/src/molecules/ds_draggable_card.dart`, `packages/warp_prism_ui/lib/src/molecules/ds_drop_target.dart`, `packages/warp_prism_ui/lib/src/organisms/ds_lane_board.dart`, `packages/warp_prism_ui/test/molecules/ds_drag_drop_test.dart`.
- Runtime wiring proof: `DSLaneBoard` wraps tasks with `DSDraggableCard` at `ds_lane_board.dart:156-172` and lane content with `DSDropTarget` at `ds_lane_board.dart:108-176`.
- Counts: 0 disposables required; 1 LongPressDraggable; 1 DragTarget; 3 Semantics wrappers in Task 1120 source; 0 keyboard reorder/move actions.
- Commands run:
  - `flutter analyze --no-pub lib/src/molecules/ds_draggable_card.dart lib/src/molecules/ds_drop_target.dart lib/src/organisms/ds_lane_board.dart test/molecules/ds_drag_drop_test.dart` — FAIL, 21 issues.
  - `flutter test --no-pub test/molecules/ds_drag_drop_test.dart` — PASS, 17/17.
- Commands not run and why: full Melos gates not run because scoped analyzer already fails and Task 1107 remains a rejected workspace prerequisite.

## Path To 100

1. Resolve and re-approve Task 1105 and Task 1107, then update Task 1120 dependency evidence.
2. Fix all 21 scoped analyzer issues; analyzer must return 0 errors, 0 warnings, and 0 info-level issues.
3. Replace vacuous tests with real behavior tests: long-press must assert ghost/feedback rendering, same-lane drop must invoke `onReorder` with exact indices, cross-lane drop must invoke `onMove`, empty-lane drop must invoke the expected callback, and hover must assert highlight/insertion indicator state.
4. Implement `DragTarget.onMove` in `DSDropTarget` and recalculate `_insertionIndex` on every pointer move; add tests for index 0, middle, and end positions.
5. Add keyboard-accessible move/reorder actions or split that requirement into a blocking follow-up before promotion; add semantic instructions for draggable cards and tests for keyboard operation.
6. Re-run scoped analyzer/tests and package-level gates after Task 1107 is repaired.

## Task Ledger Patch Suggestion

- Latest review entry should record 2026-06-19 score `58/100`, verdict `REJECTED_TO_DOING`, this report path, persistent F1-F5, lane-state F6 resolved by routing, and lane outcome `returned to doing`.
