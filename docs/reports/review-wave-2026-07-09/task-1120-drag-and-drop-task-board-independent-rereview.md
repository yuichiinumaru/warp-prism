# Review Report: Task 1120 — Drag And Drop Task Board — 2026-07-09

## Review Lineage

- **Current task**: Task 1120 (`1120-warp-prism-drag-and-drop-task-board`); live path at review start: `docs/tasks/03-review/1120-warp-prism-drag-and-drop-task-board.md`
- **Previous reports read**:
  - `docs/reports/build-gate-review/1120-review.md` — historical 100
  - `docs/reports/build-gate-review/1120-review-2026-06-18-independent.md` — 58/100
  - `docs/reports/review-wave-2026-06-19/1120-drag-and-drop-task-board-rereview-2026-06-19.md` — 58/100
  - Promote ledger — 100 (17 tests “pass”)
- **Related reports considered**: none additional
- **Review mode**: `re-review` independent — **DnD safety + proof reality emphasized**
- **Reviewer profile**: `reviewers`

## Score And Verdict

- **Score**: `68/100`
- **Verdict**: `REJECTED_TO_DOING`
- **Lane recommendation**: `return-to-doing`

Scaffolding is present (`DSDraggableCard`, `DSDropTarget`, lane board wiring, payload/event types). **17/17** tests pass but remain **behaviorally vacuous** for core requirements: long-press test ends with **zero assertions** on ghost/feedback; `onReorder`/`onMove` tests only mount the board with callbacks and never drop. **`DragTarget.onMove` is still absent**, so insertion index does not track pointer motion. Promote-100 treated suite green as product green — **false**.

## Delta Summary

### Resolved Since Previous Review (2026-06-19 @ 58)

- `RESOLVED` (partial): Scoped analyzer no longer reports WARNINGs (now 5 INFO only — withOpacity, prefer_const).
- `SUPERSEDED`: Upstream 1105/1107 doing hard-block.

### Persistent Findings

- `PERSISTENT` / Critical: Vacuous DnD tests (no real reorder/move proof).
- `PERSISTENT` / High: No `onMove` insertion-index tracking during hover.
- `PERSISTENT` / Moderate: No keyboard reorder/move path; no semantic drag instructions.

### Regressions

- Governance: false 100 promotion without fixing F3/F4.

## Six Axiom Compliance

| # | Axiom | Status | Evidence |
| --- | --- | --- | --- |
| 1 | Analyzer Integrity | **PASS** (soft) | 5 INFO; 0 ERROR/WARNING |
| 2 | Lifecycle Safety | **PASS** | No timers/controllers in DnD molecules |
| 3 | Dependency Direction | **PASS** | Built-in LongPressDraggable/DragTarget only |
| 4 | UI Accessibility | **FAIL** (task req) | Tap preserved; no keyboard DnD; no drag semantics |
| 5 | Proof Reality | **FAIL** | 17/17 vacuous for reorder/move/highlight/insertion |
| 6 | Release Security | **PASS** | No secrets |

## Findings

| ID | Class | Severity | Status | Summary | First seen | Evidence |
| --- | --- | --- | --- | --- | --- | --- |
| F1 | PERSISTENT | Critical | Open | Tests do not prove drop→onReorder/onMove or ghost assert | 2026-06-18 | `ds_drag_drop_test.dart:96-131,246-257` |
| F2 | PERSISTENT | High | Open | No `DragTarget.onMove`; insertion index only set in `onWillAcceptWithDetails` | 2026-06-18 | `ds_drop_target.dart:54-75` — no onMove |
| F3 | PERSISTENT | Moderate | Open | Keyboard reorder/move + drag instructions missing | 2026-06-18 | `ds_draggable_card.dart` LongPress only |
| F4 | RESOLVED | — | Closed | Analyzer 2 warnings | 2026-06-19 | now INFO-only |

## Exit Conditions (live)

| # | Condition | Met? | Live proof |
| --- | --- | --- | --- |
| 1 | DSDraggableCard / DSDropTarget exist | **YES** | sources |
| 2 | Board uses them + onReorder/onMove API | **YES** | wiring present |
| 3 | Visual feedback (ghost/highlight/insertion) | **PARTIAL** | UI code present; insertion not continuous; unproven |
| 4 | ≥8 widget tests covering DnD scenarios | **NO** (quality) | 17 compile/smoke, not scenario proof |
| 5 | Analyze | **YES** soft | 0 err/warn |

## Evidence Reviewed

- `ds_draggable_card.dart`, `ds_drop_target.dart`, `ds_lane_board.dart`, `ds_drag_drop_test.dart`
- Prior 58/100 reports

## Commands Run

```text
dart analyze --format=machine lib/src/molecules/ds_draggable_card.dart \
  lib/src/molecules/ds_drop_target.dart lib/src/organisms/ds_lane_board.dart \
  test/molecules/ds_drag_drop_test.dart
# → 5 INFO

flutter test --concurrency=1 --no-pub test/molecules/ds_drag_drop_test.dart
# → +17 (combined wave)
```

## Path To 100

1. Implement `DragTarget.onMove` recalculating `_insertionIndex` from pointer Y every move; tests for index 0 / mid / end.
2. Replace vacuous tests with real gesture sequences that assert `onReorder`/`onMove` payloads and highlight/ghost finders.
3. Add keyboard move/reorder actions **or** explicit deferred a11y task + semantic drag labels for this task’s bar.
4. Replace `withOpacity` deprecations; re-run gates.

## Task Ledger Patch Suggestion

```markdown
### 2026-07-09 independent re-review (reviewers)
- Report: `docs/reports/review-wave-2026-07-09/task-1120-drag-and-drop-task-board-independent-rereview.md`
- Score: **68/100** — `REJECTED_TO_DOING`
- Lane: return `02-doing/`
- Top blocker: F1 vacuous DnD tests + F2 missing onMove
```
