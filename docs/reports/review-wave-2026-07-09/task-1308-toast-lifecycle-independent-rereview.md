# Review Report: Task 1308 — Toast Async Lifecycle Stabilization — 2026-07-09

## Review Lineage

- **Current task**: Task 1308 (`1308-warp-prism-toast-async-lifecycle-stabilization`); live path at review start: `docs/tasks/03-review/1308-warp-prism-toast-async-lifecycle-stabilization.md`
- **Previous reports read**:
  - `docs/reports/build-gate-review/1308-review.md` — Round 1, 63/100
  - `docs/reports/build-gate-review/1308-review-round2.md` — Round 2, 57/100
  - `docs/reports/build-gate-review/1308-review-round3.md` — Round 3, 100/100 (later invalidated by compile/import failure)
  - Task Review Ledger entries 2026-06-30 independent (42/100), builder re-review (100/100), independent Round 2 (84/100), builders Round-2 path-to-100 (self 100/100)
- **Related reports considered**:
  - `docs/tasks/04-completed/1308-warp-prism-toast-async-lifecycle-stabilization.md` — **lane collision residue** (stale completed copy; not treated as current authority)
- **Review mode**: `re-review` (independent; reviewers profile)

## Score And Verdict

- **Score**: `87/100`
- **Verdict**: `REJECTED_TO_DOING`
- **Lane recommendation**: `return-to-doing`

## Delta Summary

### Resolved Since Previous Review (2026-06-30 independent Round 2 @ 84/100)

- `RESOLVED`: Outer live-region label includes optional `entry.message` (`ds_toast.dart:54-56`); widget test `live-region semantics include title and message` proves label `Success: Task completed. All proofs verified`.
- `RESOLVED`: Mounted guards at start of `dismiss()`, `clear()`, `_onHoverChanged()` before any `setState` (`ds_toast_manager.dart:172`, `199`, `236`).
- `RESOLVED`: Action `TextButton` enforces `minimumSize: Size(kMinInteractiveDimension, kMinInteractiveDimension)` (`ds_toast.dart:161-164`); test `action button has minimum 48x48 touch target` passes.
- `RESOLVED`: Suite is live-executable (internal molecule/token imports at `ds_toast_test.dart:9-10`); 40/40 ×3 deterministic PASS this wave.
- `RESOLVED`: Task-scoped analyzer + format gates clean (0 machine issues; 0 format changes on 3 scoped files).

### Persistent Findings

- `PERSISTENT` / `EXTERNAL_BLOCKER`: Package-wide `dart analyze lib/` still reports pre-existing info-level lints outside toast files (live count this wave: **75 INFO**, 0 ERROR, 0 WARNING in toast files). Task scope correctly does not clear them; keep classified external.

### Regressions

- None relative to Round-2 path-to-100 claims. Prior Round-2 blockers are fixed.

### New Findings

- `NEW`: Timer callback in `_startTimer` captures a list **index** and later mutates `_entries[idx]` on the pause-on-hover path. Index becomes stale when the entry list is shifted (e.g. `maxVisible` front-removal, earlier dismissals). See F1.
- `NEW`: Pause-on-hover is a documented manager feature with **0** dedicated widget tests; the only timer proof is auto-dismiss via `tester.pump(Duration)`. See F2.
- `NEW` / governance: Dual lane artifact still exists under `docs/tasks/04-completed/1308-...` (stale) while review work lives in `03-review` / will return to `02-doing`. See F3.

### Evidence Gaps / External Blockers

- `EXTERNAL_BLOCKER`: Package-wide analyzer INFO debt (75 issues, non-toast). Not Task 1308 scope.
- `EVIDENCE_GAP`: No sabotage/mutation proof that a broken mounted guard or stale-index fix would fail tests (not required by task contract; residual).

## Findings

| ID | Class | Severity | Status | Summary | First seen | Evidence |
| --- | --- | --- | --- | --- | --- | --- |
| F1 | NEW | Moderate | Open | Timer pause path uses captured `idx` after list mutations can shift/remove entries → wrong `_ManagedToastEntry.paused` or `RangeError` | this report | `ds_toast_manager.dart:218-229` captures `idx`; `maxVisible` removal at `154-157` shifts indices; hover branch writes `_entries[idx].paused` without re-resolving by `entry.id` |
| F2 | NEW | Low | Open | Pause-on-hover contract unproven by tests | this report | Manager docs claim pause-on-hover (`ds_toast_manager.dart:14`); test file header claims it (`ds_toast_test.dart:5`) but suite has **0** tests for hover pause / timer re-queue; only auto-dismiss pump at ~`471` |
| F3 | NEW | Low | Open | Stale `04-completed` sibling of Task 1308 collides with live review lane | this report | `docs/tasks/04-completed/1308-warp-prism-toast-async-lifecycle-stabilization.md` exists alongside live task file; authority is the non-completed lane only |
| F4 | PERSISTENT | External | Open (classified) | Package analyzer not green | Round 1 / Round-2 | `dart analyze lib/` → 75 INFO; 0 issues in toast scoped files |

## Axiom Compliance

| Axiom | Status | Notes |
| --- | --- | --- |
| Analyzer Integrity | PARTIAL | Task-scoped machine analyze: **0** issues. Package `lib/`: **75** INFO, pre-existing EXTERNAL_BLOCKER. |
| Lifecycle Safety | PARTIAL | Overlay: 1 create (`263`), 1 remove+dispose (`268-270`). Timer field: 1; cancel paths at replace/maxVisible/dismiss/hover/dispose. All `setState` public paths now have leading `mounted` guards; delayed dismiss callback guards `mounted` (`184`). **Residual**: timer closure stale `idx` on hover path (F1). Controllers/subscriptions in scope: **0**. |
| Dependency Direction | PASS | Toast sources import tokens/atoms only; package tests import `src/` intentionally. |
| UI Accessibility | PASS (task scope) | Live-region includes title+message; 2 interactive controls with `Semantics(button: true)`; dismiss + action both ≥48×48 with tests. Decorative icon/text under `ExcludeSemantics`. |
| Proof Reality | PASS (scoped) | Live `flutter test` **40/40** ×3 exit 0; analyzer 0; format 0 changed. Builder claims match live counts. |
| Release Security | PASS | No secrets/print in toast sources. |

## Lifecycle Inventory (exact)

| Resource | Create count | Dispose/cancel paths | Notes |
| --- | --- | --- | --- |
| `OverlayEntry` | 1 (`_ensureOverlay` ~263) | 1 (`_removeOverlay` 268-270) | Also cleared on empty dismiss / clear |
| `Timer` | 1 path (`_startTimer` 222) | cancel at 147, 155, 175, 217, 244, 273-276 | Hover path may write via stale idx (F1) |
| `Future.delayed` | 1 (`dismiss` 183) | guarded `if (!mounted) return` at 184 | OK |
| `TextEditingController` / `AnimationController` / `StreamSubscription` | 0 | n/a | AnimatedSlide/Opacity are declarative |

## `setState` inventory (exact)

| Line | Method | Mounted guard |
| --- | --- | --- |
| 143 | `show` | yes (`141`) |
| 181 | `dismiss` (mark removing) | yes (`172`) |
| 185 | delayed remove | yes (`184`) |
| 203 | `clear` | yes (`199`) |
| 238 | `_onHoverChanged` | yes (`236`) |

## Accessibility inventory (exact)

| Control | Widget line | Semantics line | Touch target |
| --- | --- | --- | --- |
| Action | `TextButton` 156 | `Semantics` 153-155 | `minimumSize` 48×48 at 161-164; test `action button has minimum 48x48 touch target` |
| Dismiss | `IconButton` 196 | `Semantics` 190-192 | `SizedBox` 48×48 at 193-195; test `dismiss button has minimum 48x48 touch target` |
| Live region | outer `Semantics` 58-62 | includes message when present | proven by live-region test |

## Evidence Reviewed

- Task file: `docs/tasks/03-review/1308-warp-prism-toast-async-lifecycle-stabilization.md`
- Source: `packages/warp_prism_ui/lib/src/molecules/ds_toast.dart`, `ds_toast_manager.dart`
- Tests: `packages/warp_prism_ui/test/molecules/ds_toast_test.dart`
- Changelog: `docs/changelog/2026-06-09-toast-async-lifecycle-stabilization.md`
- Runtime wiring: N/A (package molecule; not app-route wiring). Manager is a StatefulWidget overlay host; tests construct it directly.

## Commands Run

```bash
# From packages/warp_prism_ui — three consecutive runs
flutter test --concurrency=1 --no-pub test/molecules/ds_toast_test.dart
# EXIT1=0  → +40: All tests passed!
# EXIT2=0  → +40: All tests passed!
# EXIT3=0  → +40: All tests passed!

dart analyze --format=machine \
  test/molecules/ds_toast_test.dart \
  lib/src/molecules/ds_toast.dart \
  lib/src/molecules/ds_toast_manager.dart
# ANALYZE_TOAST_EXIT=0  (0 machine issue lines)

dart format --output=none --set-exit-if-changed \
  test/molecules/ds_toast_test.dart \
  lib/src/molecules/ds_toast.dart \
  lib/src/molecules/ds_toast_manager.dart
# FORMAT_EXIT=0  Formatted 3 files (0 changed)

dart analyze lib/   # package-wide residual
# → 75 issues found (INFO only; 0 toast-file hits)
```

## Path To 100

1. **Fix F1**: In the `Timer` callback, never use captured `idx` after await/async gap. Re-resolve with `_entries.indexWhere((e) => e.entry.id == entry.id)` (or store pause flag on the `_ManagedToastEntry` found by id). Apply the same discipline anywhere the list may shift under a delayed callback.
2. **Fix F2**: Add a widget test that shows a toast with short duration, simulates hover (MouseRegion enter) before duration elapses, pumps past duration, asserts toast still visible, then leave hover and pumps remaining duration to dismiss.
3. **F3 (governance)**: Archive or clearly supersede the stale `04-completed` Task 1308 copy so only one live lane file exists (do not re-promote this task to completed from this review).
4. Re-run: toast suite ×3, scoped analyze, scoped format; refresh Completion Evidence with live counts.
5. Keep package analyzer 75 INFO classified EXTERNAL_BLOCKER (do not expand task scope).

## Task Ledger Patch Suggestion

See compact Review Ledger update applied to the task file. Full report path:

`docs/reports/review-wave-2026-07-09/task-1308-toast-lifecycle-independent-rereview.md`
