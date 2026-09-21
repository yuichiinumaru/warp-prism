# Review Report: Task 1120 — Drag And Drop Task Board — 2026-06-18

## Review Lineage

- **Current task**: Task 1120 (`warp-prism-drag-and-drop-task-board`), reviewed from `docs/tasks/03-review/1120-warp-prism-drag-and-drop-task-board.md`.
- **Previous reports read**:
  - `docs/reports/build-gate-review/1120-review.md` — prior 100/100 approval.
- **Related reports considered**:
  - `docs/reports/build-gate-review/1105-review-2026-06-17-independent.md` — Task 1105 rejected at 68/100.
  - `docs/reports/build-gate-review/1107-review-2026-06-17-independent.md` — Task 1107 rejected at 24/100.
- **Review mode**: independent re-review / live Flutter gate.

## Score And Verdict

- **Score**: `58/100`
- **Verdict**: `REJECTED_TO_DOING`
- **Lane recommendation**: `return-to-doing`

## Axiom Compliance

| Axiom | Status | Evidence |
| --- | --- | --- |
| Analyzer Integrity | FAIL | Scoped analyze reports exactly 21 issues: 2 warnings and 19 info-level issues. |
| Lifecycle Safety | PASS | Task 1120 source creates 0 timers, 0 controllers, 0 stream subscriptions, and 0 listeners; no `dispose()` required. |
| Dependency Direction | PARTIAL | Component layering is local, but Task 1120 depends on rejected Task 1105 and Task 1107. |
| UI Accessibility | PARTIAL | Existing `DSTaskCard` semantics remain, but the drag wrapper adds no semantic drag instructions and there is no keyboard-accessible move/reorder path. |
| Proof Reality | FAIL | 17/17 tests pass, but the tests do not prove actual drag start feedback, same-lane reorder callback, cross-lane move callback, hover highlight, or insertion-index behavior. |
| Release Security | PASS | No secrets, endpoints, logging, permissions, or release configuration changed. |

## Delta Summary

### Resolved Since Previous Review

- `RESOLVED`: Focused drag-drop test file is reproducible live: 17/17 pass.

### Persistent Findings

- None from the previous report; it listed no findings.

### Regressions

- `REGRESSION`: Prior analyzer pass claim is false against live scoped files.
- `REGRESSION`: Prior proof accepted tests that do not actually exercise the required drag/drop callbacks.

### New Findings

- `NEW`: `DSDropTarget` does not implement the required `DragTarget.onMove` insertion-index behavior.
- `NEW`: Keyboard accessibility is not provided for reorder/move operations.

### Evidence Gaps / External Blockers

- `EXTERNAL_BLOCKER`: Task 1105 and Task 1107 prerequisites are rejected.

## Findings

| ID | Class | Severity | Status | Summary | Evidence |
| --- | --- | --- | --- | --- | --- |
| F1 | EXTERNAL_BLOCKER | High | Open | Task 1120 depends on rejected upstreams Task 1105 and Task 1107, so it cannot be promoted as governed ADS work. | Task dependency: `docs/tasks/03-review/1120-warp-prism-drag-and-drop-task-board.md:9`; Task 1105 state `docs/tasks/02-doing/1105-warp-prism-token-theme-catalog-policy.md:3-4,151`; Task 1107 state `docs/tasks/02-doing/1107-warp-prism-melos-monorepo-migration.md:3-4,176`. |
| F2 | REGRESSION | High | Open | Scoped analyzer integrity fails with exactly 21 issues: 2 warnings (`unused_local_variable`) and 19 info-level issues. | Fresh command output; representative evidence: deprecated `withOpacity` at `packages/warp_prism_ui/lib/src/molecules/ds_draggable_card.dart:105`, `packages/warp_prism_ui/lib/src/molecules/ds_drop_target.dart:78-108`, `packages/warp_prism_ui/lib/src/organisms/ds_lane_board.dart:202-204`; unused callback variables at `packages/warp_prism_ui/test/molecules/ds_drag_drop_test.dart:249,262`. |
| F3 | EVIDENCE_GAP | Critical | Open | The focused tests are largely structural and do not prove the required drag/drop behavior. The long-press test has no post-drag assertion, and reorder/move tests only verify the callbacks can be passed, not that drops invoke them. | Task requirements: `docs/tasks/03-review/1120-warp-prism-drag-and-drop-task-board.md:53-58`; vacuous long-press test at `packages/warp_prism_ui/test/molecules/ds_drag_drop_test.dart:119-132`; non-asserting callback tests at `ds_drag_drop_test.dart:248-271`. |
| F4 | NEW | High | Open | Required insertion-index tracking on pointer move is not implemented. `DSDropTarget` computes `_insertionIndex` only in `onWillAcceptWithDetails`; there is no `onMove` handler, so the indicator does not follow the cursor as required. | Task requirement: `docs/tasks/03-review/1120-warp-prism-drag-and-drop-task-board.md:89`; implementation only at `packages/warp_prism_ui/lib/src/molecules/ds_drop_target.dart:55-75`; no `onMove` in `ds_drop_target.dart:54-119`. |
| F5 | NEW | Moderate | Open | Keyboard accessibility is preserved only for tap on `DSTaskCard`; there is no keyboard-accessible reorder/move action or semantic drag instruction for assistive technologies. | Task requirement: `docs/tasks/03-review/1120-warp-prism-drag-and-drop-task-board.md:57`; drag wrapper at `packages/warp_prism_ui/lib/src/molecules/ds_draggable_card.dart:84-119`; board semantics at `packages/warp_prism_ui/lib/src/organisms/ds_lane_board.dart:36-38,97-99,193-195`. |

## Evidence Reviewed

- Task file: `docs/tasks/03-review/1120-warp-prism-drag-and-drop-task-board.md`.
- Source/test files: `ds_draggable_card.dart`, `ds_drop_target.dart`, `ds_lane_board.dart`, `ds_task_card.dart`, `molecules.dart`, gallery drag-drop section, `ds_drag_drop_test.dart`.
- Runtime wiring proof: `DSLaneBoard` wraps tasks with `DSDraggableCard` at `ds_lane_board.dart:156-172` and wraps lane content with `DSDropTarget` at `ds_lane_board.dart:108-176`; exports added at `molecules.dart:19-20`.
- Lifecycle/accessibility counts: 0 disposables required; 1 actual `LongPressDraggable` instance (`ds_draggable_card.dart:84`); 1 actual `DragTarget<DSDragPayload>` instance (`ds_drop_target.dart:54`); 3 Semantics widgets in Task 1120 source (`ds_lane_board.dart:36,97,193`) plus existing `DSTaskCard` semantics outside this task.
- Commands run:
  - `flutter analyze --no-pub lib/src/molecules/ds_draggable_card.dart lib/src/molecules/ds_drop_target.dart lib/src/organisms/ds_lane_board.dart test/molecules/ds_drag_drop_test.dart` — FAIL, 21 issues (2 warnings, 19 info).
  - `flutter test --no-pub test/molecules/ds_drag_drop_test.dart` — PASS, 17/17.
- Commands not run and why: full Melos commands are blocked by rejected Task 1107 workspace defects; this review used scoped package commands with `--no-pub`.

## Path To 100

1. Resolve and re-approve Task 1105 and Task 1107, then refresh Task 1120 dependency evidence.
2. Fix all 21 scoped analyzer issues; analyzer must be 0 errors, 0 warnings, 0 info.
3. Replace vacuous drag tests with real behavior tests: long-press must assert ghost/feedback rendering, same-lane drop must invoke `onReorder` with expected indices, cross-lane drop must invoke `onMove`, empty lane drop must be exercised, and hover must assert highlight/insertion indicator state.
4. Implement `DragTarget.onMove` in `DSDropTarget` and recalculate `_insertionIndex` on every pointer move; add tests for index 0, middle, and end positions.
5. Add a keyboard-accessible move/reorder path or explicitly split that requirement into a blocking follow-up before promotion; include semantics instructions for draggable task cards.

## Task Ledger Patch Suggestion

Add a latest-review entry with score `58/100`, verdict `REJECTED_TO_DOING`, this report path, F1-F5, and the path-to-100 above. Preserve `docs/reports/build-gate-review/1120-review.md` as previous-report lineage.
