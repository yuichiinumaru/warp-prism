# Review Report: Task 1116 — Notification Toast System — 2026-06-19

## Review Lineage

- **Current task**: Task 1116 (`warp-prism-notification-toast-system`); live path before routing was `docs/tasks/03-review/1116-warp-prism-notification-toast-system.md`.
- **Previous reports read**:
  - `docs/reports/build-gate-review/1116-review.md` — 2026-06-13 prior 100/100 approval.
  - `docs/reports/build-gate-review/1116-review-2026-06-18-independent.md` — 2026-06-18 independent rejection, 82/100.
- **Related reports/tasks considered**:
  - Task 1105 live path `docs/tasks/02-doing/1105-warp-prism-token-theme-catalog-policy.md` — still `Status: Doing`, `Review State: Doing`.
  - Task 1107 live path `docs/tasks/02-doing/1107-warp-prism-melos-monorepo-migration.md` — still `Status: Doing`, `Review State: Doing`.
- **Review mode**: re-review / lineage verification / lane-state reconciliation.

## Score And Verdict

- **Score**: `82/100`
- **Verdict**: `REJECTED_TO_DOING`
- **Lane recommendation**: `return-to-doing`
- **Remediation applied after 2026-06-18?** No. The persistent code findings and upstream blockers remain live.

## Axiom Compliance

| Axiom | Status | Evidence |
| --- | --- | --- |
| Analyzer Integrity | PASS | `flutter analyze --no-pub lib/src/molecules/ds_toast.dart lib/src/molecules/ds_toast_manager.dart test/molecules/ds_toast_test.dart` returned `No issues found!`. |
| Lifecycle Safety | PARTIAL | Exact count: 1 `Timer` allocation at `packages/warp_prism_ui/lib/src/molecules/ds_toast_manager.dart:218`; 0 controllers; 0 stream subscriptions; 1 `dispose()` method at `ds_toast_manager.dart:127-131`. Timer cancellation paths exist, but the callback still writes `_entries[idx].paused` from a captured stale index at `ds_toast_manager.dart:214-225`. |
| Dependency Direction | PARTIAL | Task 1116 depends on Task 1105 and Task 1107 at `docs/tasks/03-review/1116-warp-prism-notification-toast-system.md:9`; both prerequisites remain in `02-doing` with `Review State: Doing` at `1105...md:3-4` and `1107...md:3-4`. |
| UI Accessibility | PASS | Exact count in Task 1116 toast source: 2 interactive controls (`TextButton` at `ds_toast.dart:147`, `IconButton` at `ds_toast.dart:181`) and 3 `Semantics` wrappers (`ds_toast.dart:52`, `ds_toast.dart:144`, `ds_toast.dart:175`). Dismiss target is 48x48 at `ds_toast.dart:178-180`. |
| Proof Reality | PARTIAL | `flutter test --no-pub test/molecules/ds_toast_test.dart` passed 39/39, but the tests still do not prove entry-owned manager action callback behavior because `DSToastEntry` has no `onAction` field at `ds_toast.dart:249-307`. |
| Release Security | PASS | No secrets, endpoints, logging, permissions, or release build configuration changed in Task 1116 files. |

## Delta Summary

### Resolved Since Previous Review

- `RESOLVED`: No code findings from the 2026-06-18 rejection were resolved.
- `RESOLVED`: Scoped analyzer/test proof remains reproducible: analyzer 0 issues and tests 39/39 pass.

### Persistent Findings

- `PERSISTENT`: Task 1105 and Task 1107 prerequisites remain unapproved and in `02-doing`.
- `PERSISTENT`: `DSToastEntry` still has no entry-owned `onAction` callback or dismiss policy.
- `PERSISTENT`: Auto-dismiss timer callback still captures a stale list index.

### Regressions

- None beyond the 2026-06-18 regression already recorded from prior false approval.

### New Findings

- `NEW`: Lane-state defect verified. The task file was physically in `03-review` while its header said `Status: Doing` and `Review State: Doing` at `docs/tasks/03-review/1116-warp-prism-notification-toast-system.md:3-4`. This is resolved by this review's routing move back to `02-doing`.

### Evidence Gaps / External Blockers

- `EXTERNAL_BLOCKER`: Full package/Melos gates remain unsafe as promotion proof while Task 1107's workspace migration is rejected.

## Findings

| ID | Class | Severity | Status | Summary | First seen | Evidence |
| --- | --- | --- | --- | --- | --- | --- |
| F1 | PERSISTENT | High | Open | Task 1116 depends on rejected/unapproved Task 1105 and Task 1107, so it cannot be promoted as governed ADS work. | 2026-06-18 report | Dependency at `docs/tasks/03-review/1116-warp-prism-notification-toast-system.md:9`; live upstream states at `docs/tasks/02-doing/1105-warp-prism-token-theme-catalog-policy.md:3-4` and `docs/tasks/02-doing/1107-warp-prism-melos-monorepo-migration.md:3-4`. |
| F2 | PERSISTENT | Moderate | Open | Manager action contract remains incomplete: `DSToastEntry` still has `actionLabel` only, no `VoidCallback? onAction` and no `dismissOnAction` policy. | 2026-06-18 report | Requirement at task lines `45,58,87`; entry fields at `packages/warp_prism_ui/lib/src/molecules/ds_toast.dart:249-307`; manager action only dismisses at `ds_toast_manager.dart:342-345`. |
| F3 | PERSISTENT | Moderate | Open | Timer callback still captures `idx` before the timer fires and writes `_entries[idx].paused` later, so removing an earlier toast can make the callback target the wrong entry. | 2026-06-18 report | `idx` captured at `packages/warp_prism_ui/lib/src/molecules/ds_toast_manager.dart:214`; stale write at `ds_toast_manager.dart:218-225`. |
| F4 | NEW | Moderate | Resolved by routing | Task was in the review lane while explicitly marked `Doing`, violating lane-state rules for `03-review`. | 2026-06-19 re-review | Header at `docs/tasks/03-review/1116-warp-prism-notification-toast-system.md:3-4`; lane rules at `docs/governance/promotion-state-model.md:182-188`. |

## Evidence Reviewed

- Task file: `docs/tasks/03-review/1116-warp-prism-notification-toast-system.md`.
- Previous reports: `docs/reports/build-gate-review/1116-review.md`, `docs/reports/build-gate-review/1116-review-2026-06-18-independent.md`.
- Source/test files: `packages/warp_prism_ui/lib/src/molecules/ds_toast.dart`, `packages/warp_prism_ui/lib/src/molecules/ds_toast_manager.dart`, `packages/warp_prism_ui/test/molecules/ds_toast_test.dart`.
- Runtime wiring proof: `DSToastManager` builds `DSToast` at `ds_toast_manager.dart:338-346`; action path only dismisses.
- Counts: 1 timer allocation; 0 controllers; 0 stream subscriptions; 1 dispose method; 2 interactive controls; 3 Semantics wrappers.
- Commands run:
  - `flutter analyze --no-pub lib/src/molecules/ds_toast.dart lib/src/molecules/ds_toast_manager.dart test/molecules/ds_toast_test.dart` — PASS, 0 issues.
  - `flutter test --no-pub test/molecules/ds_toast_test.dart` — PASS, 39/39.
- Commands not run and why: full Melos gates not run because this review verified the scoped component remediation question and Task 1107 is still a rejected workspace prerequisite.

## Path To 100

1. Resolve and re-approve Task 1105 and Task 1107, then update Task 1116 dependency evidence.
2. Add `VoidCallback? onAction` and `bool dismissOnAction` to `DSToastEntry`; update `copyWith`; update `DSToastManager._buildAnimatedToast` to call `entry.onAction?.call()` before optional dismissal.
3. Fix `_startTimer` by re-looking up the managed entry by `entry.id` inside the timer callback before reading or writing paused state.
4. Add a regression test where toast A is dismissed while hovered toast B waits for auto-dismiss; the test must prove toast B remains/removes according to B's own timer state, not A's former index.
5. Re-run scoped analyzer/tests and the package-level gate after Task 1107 is repaired.

## Task Ledger Patch Suggestion

- Latest review entry should record 2026-06-19 score `82/100`, verdict `REJECTED_TO_DOING`, this report path, persistent F1-F3, lane-state F4 resolved by routing, and lane outcome `returned to doing`.
