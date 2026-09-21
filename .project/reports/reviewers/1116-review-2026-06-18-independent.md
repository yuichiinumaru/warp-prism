# Review Report: Task 1116 — Notification Toast System — 2026-06-18

## Review Lineage

- **Current task**: Task 1116 (`warp-prism-notification-toast-system`), reviewed from `docs/tasks/03-review/1116-warp-prism-notification-toast-system.md`.
- **Previous reports read**:
  - `docs/reports/build-gate-review/1116-review.md` — prior 100/100 approval.
- **Related reports considered**:
  - `docs/reports/build-gate-review/1105-review-2026-06-17-independent.md` — Task 1105 rejected at 68/100.
  - `docs/reports/build-gate-review/1107-review-2026-06-17-independent.md` — Task 1107 rejected at 24/100.
- **Review mode**: independent re-review / live Flutter gate.

## Score And Verdict

- **Score**: `82/100`
- **Verdict**: `REJECTED_TO_DOING`
- **Lane recommendation**: `return-to-doing`

## Axiom Compliance

| Axiom | Status | Evidence |
| --- | --- | --- |
| Analyzer Integrity | PASS | `flutter analyze --no-pub lib/src/molecules/ds_toast.dart lib/src/molecules/ds_toast_manager.dart test/molecules/ds_toast_test.dart` → `No issues found!`. |
| Lifecycle Safety | PARTIAL | 1 `Timer` allocation at `ds_toast_manager.dart:218`; timers are canceled in replace/max-visible/dismiss/clear/dispose paths, but the callback captures a stale list index and can mutate the wrong entry after stack changes. |
| Dependency Direction | PARTIAL | DS package layering is local-only, but declared prerequisites Task 1105 and Task 1107 are both rejected/in `02-doing`. |
| UI Accessibility | PASS | `DSToast` has 3 Semantics wrappers (`ds_toast.dart:52,144,175`) for the live region, action, and dismiss controls; the dismiss control is explicitly 48x48 (`ds_toast.dart:178-180`). Interactive controls in Task 1116 source: 1 `TextButton`, 1 `IconButton`. |
| Proof Reality | PARTIAL | 39 scoped tests pass, but the manager action path never calls an entry-level action callback because the entry has no callback field. |
| Release Security | PASS | No secrets, endpoints, logging, permissions, or release configuration changed. |

## Delta Summary

### Resolved Since Previous Review

- `RESOLVED`: Scoped Task 1116 analyzer and test proof is now reproducible live with `--no-pub`: 0 analyzer issues and 39/39 tests passing.

### Persistent Findings

- None from the previous report; it listed no findings.

### Regressions

- `REGRESSION`: Prior approval relied on upstream Task 1105/1107 being acceptable; both are now rejected and in remediation.

### New Findings

- `NEW`: The entry/manager action contract is incomplete.
- `NEW`: Auto-dismiss timer callback captures a stale list index.

### Evidence Gaps / External Blockers

- `EXTERNAL_BLOCKER`: Task 1105 and Task 1107 prerequisites are not approved.

## Findings

| ID | Class | Severity | Status | Summary | Evidence |
| --- | --- | --- | --- | --- | --- |
| F1 | EXTERNAL_BLOCKER | High | Open | Task 1116 depends on rejected upstreams Task 1105 and Task 1107, so it cannot be promoted as governed ADS work. | Task dependency: `docs/tasks/03-review/1116-warp-prism-notification-toast-system.md:9`; Task 1105 live state `docs/tasks/02-doing/1105-warp-prism-token-theme-catalog-policy.md:3-4,151`; Task 1107 live state `docs/tasks/02-doing/1107-warp-prism-melos-monorepo-migration.md:3-4,176`. |
| F2 | NEW | Moderate | Open | `DSToastEntry` does not contain the task-required `onAction?` callback, and `DSToastManager` dismisses action toasts without invoking entry-owned action behavior. | Required by task `docs/tasks/03-review/1116-warp-prism-notification-toast-system.md:45,58,87`; entry fields omit callback at `packages/warp_prism_ui/lib/src/molecules/ds_toast.dart:249-283`; manager action only dismisses at `packages/warp_prism_ui/lib/src/molecules/ds_toast_manager.dart:342-345`. |
| F3 | NEW | Moderate | Open | Timer callback captures `idx` at timer creation and later writes `_entries[idx].paused`; if an earlier toast is removed before a hovered later toast's timer fires, that index can be stale. | Index captured at `packages/warp_prism_ui/lib/src/molecules/ds_toast_manager.dart:214-218`; stale index write at `packages/warp_prism_ui/lib/src/molecules/ds_toast_manager.dart:221-225`. |

## Evidence Reviewed

- Task file: `docs/tasks/03-review/1116-warp-prism-notification-toast-system.md`.
- Source/test files: `ds_toast.dart`, `ds_toast_manager.dart`, `molecules.dart`, `ds_toast_test.dart`, gallery toast section.
- Runtime wiring proof: exported through `packages/warp_prism_ui/lib/src/molecules/molecules.dart:13-14` and registered in gallery registry at `design_system_gallery_registry.dart:97-102`.
- Lifecycle counts: 1 `Timer` allocation; 0 controllers; 0 stream subscriptions; 1 `dispose()` method in `DSToastManagerState`; 2 interactive controls in `DSToast` source; 3 Semantics wrappers in `DSToast`.
- Commands run:
  - `flutter analyze --no-pub lib/src/molecules/ds_toast.dart lib/src/molecules/ds_toast_manager.dart test/molecules/ds_toast_test.dart` — PASS, 0 issues.
  - `flutter test --no-pub test/molecules/ds_toast_test.dart` — PASS, 39/39.
- Commands not run and why: full Melos commands are blocked by rejected Task 1107 workspace defects; this review used scoped package commands with `--no-pub` to avoid the known workspace pub-cache failure.

## Path To 100

1. Resolve and re-approve Task 1105 and Task 1107, then refresh Task 1116's dependency evidence.
2. Add action behavior to `DSToastEntry`, e.g. `VoidCallback? onAction` and `bool dismissOnAction`, and update `DSToastManager._buildAnimatedToast` to invoke `entry.onAction?.call()` before optional dismissal.
3. Fix timer lifecycle by re-looking up the managed entry by `entry.id` inside the timer callback before reading/writing paused state; add a regression test where toast A is dismissed while hovered toast B waits for auto-dismiss.
4. Re-run the scoped analyzer/test commands above and the package-level gate after Task 1107's workspace is repaired.

## Task Ledger Patch Suggestion

Add a latest-review entry with score `82/100`, verdict `REJECTED_TO_DOING`, this report path, F1-F3, and the path-to-100 above. Preserve `docs/reports/build-gate-review/1116-review.md` as previous-report lineage.
