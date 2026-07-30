# Review Report: Task 1120 — Drag And Drop Task Board — path-to-100 independent re-review — 2026-07-10

## Review Lineage

- **Current task**: Task 1120 (`1120-warp-prism-drag-and-drop-task-board`); live path: `docs/tasks/03-review/1120-warp-prism-drag-and-drop-task-board.md`
- **Previous reports read**:
  - `docs/reports/review-wave-2026-07-09/task-1120-drag-and-drop-task-board-independent-rereview.md` — **68/100** `REJECTED_TO_DOING` (vacuous tests + no `DragTarget.onMove`)
  - `docs/reports/review-wave-2026-07-10/epic11-path-to-100-rereview.md` — **100** promote claim — re-verified deeply
  - `docs/reports/build-gate-review/1120-review-2026-06-18-independent.md` — 58/100
  - `docs/reports/review-wave-2026-06-19/1120-drag-and-drop-task-board-rereview-2026-06-19.md` — 58/100
- **Related reports considered**: none additional
- **Review mode**: `path-to-100` independent re-review — **DnD safety + proof reality emphasized**
- **Reviewer profile**: `reviewers` (gt-flutter-code-reviewer + gt-code-quality-reviewer)
- **Policy**: never `04-completed/`; S≥90 stay `03-review`; S&lt;90 → `02-doing`; no git

## Score And Verdict

- **Score**: `96/100`
- **Verdict**: `HELD_IN_REVIEW_PATH_TO_100`
- **Lane recommendation**: `hold-in-review` (remains `docs/tasks/03-review/`)
- **Builder/epic11 claim of 100**: **rejected as perfect score** — prior Critical/High blockers **are closed** with non-vacuous live proof (+24), but production lib still carries **3 INFO** (`prefer_const_*`) and same-lane reorder assertion remains range-soft. Not a return-to-doing.

## Delta Summary

### Resolved Since Previous Independent Review (2026-07-09 @ 68)

- `RESOLVED` / Critical: **F1** Tests are behavioral:
  - long-press asserts ghost + feedback keys (`ds-drag-ghost-*`, `ds-drag-feedback-*`)
  - cross-lane drop asserts full `onMove` payload
  - same-lane drop asserts `onReorder` with `newIndex > 0`
  - empty lane drop → `onMove` into review
  - hover surface idle→hover keys
- `RESOLVED` / High: **F2** `DragTarget.onMove` continuously recalculates insertion index; mid-card probe for feedback top-left offset (`ds_drop_target.dart:75–78, 150–167`); test proves index **0 then 2** with insertion keys.
- `RESOLVED` / Moderate: **F3** Keyboard Alt+Up/Down reorder + Alt+Left/Right move; semantic drag hints; board wires keyboard into callbacks.

### Persistent Findings

- None of the prior Critical/High items remain open.

### Regressions

- None. Suite **17 → 24** with real gesture/keyboard cases.

### New Findings

- `NEW` / Low: Production lib analyze still **3 INFO** on `ds_lane_board.dart` (`prefer_const_declarations` L44–45, `prefer_const_constructors` L150). Blocks analyzer-axiom perfect 100.
- `NEW` / Low: Same-lane reorder test allows `newIndex` range `1..2` rather than a single expected slot — still non-vacuous, not exact mid-list proof.

### Evidence Gaps / External Blockers

- `EXTERNAL_BLOCKER`: full melos residual out of scoped gate.

## Six Axiom Compliance

| # | Axiom | Status | Evidence |
| --- | --- | --- | --- |
| 1 | Analyzer Integrity | **PASS** (soft) | 0 ERROR/WARNING; **3 INFO** in production `ds_lane_board.dart` |
| 2 | Lifecycle Safety | **PASS** | No timers/controllers in DnD molecules; board FocusNodes test-owned |
| 3 | Dependency Direction | **PASS** | Built-in LongPressDraggable/DragTarget only |
| 4 | UI Accessibility | **PASS** (task) | Semantics labels/hints; keyboard reorder/move paths |
| 5 | Proof Reality | **PASS** | +24 non-vacuous: ghost, onMove, onReorder, insertion 0→2, keyboard |
| 6 | Release Security | **PASS** | No secrets |

## Findings

| ID | Class | Severity | Status | Summary | First seen | Evidence |
| --- | --- | --- | --- | --- | --- | --- |
| F1 | RESOLVED | Critical | Closed | Vacuous DnD tests | 2026-06-18 | `ds_drag_drop_test.dart` real gestures |
| F2 | RESOLVED | High | Closed | No DragTarget.onMove | 2026-06-18 | `ds_drop_target.dart:76–78` + insertion test |
| F3 | RESOLVED | Moderate | Closed | Keyboard + drag semantics | 2026-06-18 | Alt+Arrow tests + Semantics hints |
| F4 | NEW | Low | Open | 3 prefer_const INFO in lane board | this re-review | `ds_lane_board.dart:44,45,150` |
| F5 | NEW | Low | Open | Same-lane newIndex range-soft | this re-review | reorder test expects `>0` and `≤2` |

## Exit Conditions (live)

| # | Condition | Met? | Live proof |
| --- | --- | --- | --- |
| 1 | DSDraggableCard / DSDropTarget | **YES** | sources |
| 2 | Board onReorder/onMove API | **YES** | wired + tested |
| 3 | Visual feedback (ghost/highlight/insertion) | **YES** | keys + continuous onMove |
| 4 | ≥8 widget tests covering DnD scenarios | **YES** | **+24** scenario proof |
| 5 | Analyze | **YES** soft | 0 err/warn; 3 INFO prod |

## Evidence Reviewed

- `ds_draggable_card.dart`, `ds_drop_target.dart`, `ds_lane_board.dart`
- Full `ds_drag_drop_test.dart` (841 lines) — not mount-only smoke
- Prior 68 reject report

## Commands Run (this session)

```text
cd packages/warp_prism_ui

dart analyze --format=machine \
  lib/src/molecules/ds_draggable_card.dart \
  lib/src/molecules/ds_drop_target.dart \
  lib/src/organisms/ds_lane_board.dart
# → 3 INFO (prefer_const_*), 0 ERROR/WARNING

flutter test --concurrency=1 --no-pub test/molecules/ds_drag_drop_test.dart
# → +24 All tests passed!
# log: tmp/path-to-100-independent-rereview-2026-07-10/1120.txt
```

## Path To 100

1. Fix three production INFO in `ds_lane_board.dart` (`const` finals / constructors) so scoped **lib** analyze is 0.
2. Optional: tighten same-lane reorder test to exact expected `newIndex` for a controlled itemHeight geometry (or document why range is the correct assertion).
3. Re-run analyze + DnD suite; claim 100 when (1) lands.

## Task Ledger Patch Suggestion

```markdown
### Independent path-to-100 re-review — 2026-07-10 (reviewers / extreme rigor)
- Report: `docs/reports/review-wave-2026-07-10/task-1120-path-to-100-independent-rereview.md`
- Score: **96/100** — `HELD_IN_REVIEW_PATH_TO_100`
- Lane: **stay** `docs/tasks/03-review/`
- Prior 68 blockers F1–F3: **RESOLVED** (live +24 non-vacuous; onMove insertion 0→2; keyboard)
- Open residual: F4 3 prefer_const INFO in ds_lane_board; F5 soft newIndex range
- Regression guards: re-open if tests regress to mount-only or onMove removed
```
