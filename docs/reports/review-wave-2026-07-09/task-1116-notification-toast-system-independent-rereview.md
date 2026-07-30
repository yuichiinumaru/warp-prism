# Review Report: Task 1116 — Notification Toast System — 2026-07-09

## Review Lineage

- **Current task**: Task 1116 (`1116-warp-prism-notification-toast-system`); live path at review start: `docs/tasks/03-review/1116-warp-prism-notification-toast-system.md`
- **Previous reports read**:
  - `docs/reports/build-gate-review/1116-review.md` — historical 100/100
  - `docs/reports/build-gate-review/1116-review-2026-06-18-independent.md` — 82/100 reject
  - `docs/reports/review-wave-2026-06-19/1116-notification-toast-system-rereview-2026-06-19.md` — 82/100 reject
  - `.agents/profiles/reviewers/review-260709230500-wave-1106-1123-promote.md` — promote score 100 (scoped tests only)
- **Related reports considered**:
  - `docs/reports/review-wave-2026-07-09/task-1308-toast-lifecycle-independent-rereview.md` — 87/100; shares timer stale-index finding on same sources
- **Review mode**: `re-review` (independent; gt-flutter-code-reviewer + gt-code-quality-reviewer)
- **Reviewer profile**: `reviewers`

## Score And Verdict

- **Score**: `84/100`
- **Verdict**: `REJECTED_TO_DOING`
- **Lane recommendation**: `return-to-doing`

Deliverables exist and scoped tests are **40/40** green with **0** machine analyzer diagnostics on toast sources+tests. The 2026-07-09 promote-to-100 over-scored: core lifecycle and action-contract defects from 2026-06-18/06-19 remain live (stale timer index; entry-owned `onAction` missing; manager action path only dismisses). Overlaps Task 1308 residual F1.

## Delta Summary

### Resolved Since Previous Review (2026-06-19 @ 82)

- `RESOLVED` / SUPERSEDED: Upstream Task 1105 and Task 1107 no longer sit in `02-doing` as open blockers (both currently in `03-review` with independent 100 claims). Dependency-gate F1 from June is **SUPERSEDED** for this wave.
- `RESOLVED` / EVIDENCE: Live toast suite executes (prior gallery compile blocker gone).
- `RESOLVED` (from 1308 lineage overlap): Mounted guards on `dismiss`/`clear`/`_onHoverChanged`; live-region label includes message; 48×48 targets (shared toast sources).

### Persistent Findings

- `PERSISTENT`: Timer pause path still writes `_entries[idx].paused` using index captured when the timer was scheduled (`ds_toast_manager.dart` `_startTimer`).
- `PERSISTENT`: `DSToastEntry` still has `actionLabel` only — no entry-owned `VoidCallback? onAction` / `dismissOnAction`; manager hardcodes dismiss-on-action.

### Regressions

- None relative to June remediation baseline; prior false 100 promotion is the governance regression, not a code regression.

### New Findings

- `NEW` / Low: Pause-on-hover remains undocumented by tests (header claims it; suite has 0 hover-pause cases) — also noted on Task 1308.

### Evidence Gaps / External Blockers

- Package-wide INFO debt outside toast files is **EXTERNAL** / non-blocking for this task's scoped gate.

## Six Axiom Compliance

| # | Axiom | Status | Evidence |
| --- | --- | --- | --- |
| 1 | Analyzer Integrity | **PASS** (scoped) | `dart analyze --format=machine` toast lib+test → **0** lines |
| 2 | Lifecycle Safety | **PARTIAL** | Overlay + Timer cancel paths exist; **stale idx** on timer hover branch remains |
| 3 | Dependency Direction | **PASS** | Molecules/tokens only; Riverpod is docs contract |
| 4 | UI Accessibility | **PASS** (task scope) | Live region + action/dismiss semantics |
| 5 | Proof Reality | **PARTIAL** | 40/40 pass; does not prove pause-on-hover or entry-owned action |
| 6 | Release Security | **PASS** | No secrets |

## Findings

| ID | Class | Severity | Status | Summary | First seen | Evidence |
| --- | --- | --- | --- | --- | --- | --- |
| F1 | PERSISTENT | Moderate | Open | Timer callback captures list `idx`; after `maxVisible` front-removal / earlier dismiss, `_entries[idx].paused = true` can target wrong entry or range-error | 2026-06-18 | `ds_toast_manager.dart` `_startTimer` ~215-229; `maxVisible` removeAt(0) ~154-157 |
| F2 | PERSISTENT | Moderate | Open | Action contract incomplete: entry has no `onAction`/`dismissOnAction`; manager only `dismiss(entry.id)` | 2026-06-18 | `ds_toast.dart` `DSToastEntry` ~264-321; manager `onAction` ~348-351 |
| F3 | NEW | Low | Open | Pause-on-hover unproven by tests | this report / 1308 | `ds_toast_test.dart` header claims pause; 0 hover tests |
| F4 | SUPERSEDED | — | Closed | Upstream 1105/1107 doing-lane deps | 2026-06-19 | both now `03-review` |

## Exit Conditions (live)

| # | Condition | Met? | Live proof |
| --- | --- | --- | --- |
| 1 | `ds_toast.dart` / manager / exports | **YES** | files present |
| 2 | Gallery toast section | **YES** | gallery sections |
| 3 | Riverpod contract documented | **YES** | manager docs |
| 4 | Tests full coverage claim | **PARTIAL** | 40/40 run; action/timer edge incomplete |
| 5 | Scoped analyze clean | **YES** | 0 diagnostics |
| 6 | Changelog | **YES** | present |

## Evidence Reviewed

- Task 1116 + prior 06-18/06-19 reports + promote ledger + Task 1308 re-review
- `packages/warp_prism_ui/lib/src/molecules/ds_toast.dart`, `ds_toast_manager.dart`
- `packages/warp_prism_ui/test/molecules/ds_toast_test.dart`

## Commands Run

```text
# packages/warp_prism_ui
dart analyze --format=machine lib/src/molecules/ds_toast.dart \
  lib/src/molecules/ds_toast_manager.dart test/molecules/ds_toast_test.dart
# → 0 lines  EXIT 0

flutter test --concurrency=1 --no-pub test/molecules/ds_toast_test.dart
# → part of combined wave suite: toast +40 included in +253 All tests passed
```

Flutter 3.44.x / Dart 3.12.x environment.

## Path To 100

1. Fix `_startTimer` / hover path to resolve managed entry by `entry.id` on every timer/hover mutation (never reuse captured `idx` after await/timer fire).
2. Add `VoidCallback? onAction` and `bool dismissOnAction` to `DSToastEntry`; wire manager to call entry callback then optional dismiss.
3. Add regression tests: (a) dismiss toast A while B is paused-by-hover; B still auto-dismisses on its own timer; (b) entry `onAction` fires without always dismissing when `dismissOnAction: false`.
4. Re-run scoped analyze + toast suite.

## Task Ledger Patch Suggestion

```markdown
### 2026-07-09 independent re-review (reviewers)
- Report: `docs/reports/review-wave-2026-07-09/task-1116-notification-toast-system-independent-rereview.md`
- Score: **84/100** — `REJECTED_TO_DOING`
- Lane: return `02-doing/`
- Top blocker: F1 timer stale index + F2 entry-owned onAction
```
