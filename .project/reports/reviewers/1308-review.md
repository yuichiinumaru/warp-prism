# Review Report: Task 1308 — Toast Async Lifecycle Stabilization — 2026-06-13

## Review Lineage

- **Current task**: Task 1308 (`toast-async-lifecycle-stabilization`); live path: `docs/tasks/03-review/1308-warp-prism-toast-async-lifecycle-stabilization.md`
- **Previous reports read**:
  - `docs/reports/build-gate-review/1308-review.md` — 63/100, rejected Round 1.
  - `docs/reports/build-gate-review/1308-review-round2.md` — 57/100, rejected Round 2.
  - `docs/reports/build-gate-review/1308-review-round3.md` — 100/100 after reviewer docs patches, approved to review lane.
- **Related reports considered**: none beyond the three Task 1308 reports above.
- **Governance read**: `AGENTS.md`, `.agents/rules/definition-of-done.md`, `.agents/rules/project-boundaries.md`, `.agents/rules/task-governance.md`, `.agents/skills/code-quality-harness/SKILL.md`, `.agents/skills/flutter-harness/SKILL.md`, `.agents/skills/code-quality-harness/workflows/review-report-lineage.md`.
- **Review mode**: final-gate independent review.

## Score And Verdict

- **Score**: `94/100`
- **Verdict**: `APPROVED_WITH_PATCHES`
- **Lane recommendation**: `accept-completed` for Task 1308 scope, with the patch suggestions below tracked as follow-up quality hardening.

Task-owned implementation and required verification commands pass. The score is not 100 because the package-level analyzer remains red outside task scope and because one lifecycle-adjacent feature advertised by the toast manager, pause-on-hover, still lacks a regression test.

## Delta Summary

### Resolved Since Previous Review

- `RESOLVED`: Round 1 accessibility blocker is fixed. `ExcludeSemantics` is now scoped to decorative icon/text only (`packages/warp_prism_ui/lib/src/molecules/ds_toast.dart:89`, `:112`), while action and dismiss controls have explicit semantics (`:144-168`, `:175-192`).
- `RESOLVED`: Round 1 dismiss touch target blocker is fixed. Dismiss target is exactly `48x48` through `kMinInteractiveDimension` (`packages/warp_prism_ui/lib/src/molecules/ds_toast.dart:178-181`) and tested at `packages/warp_prism_ui/test/molecules/ds_toast_test.dart:550-579`.
- `RESOLVED`: Round 1 delayed overlay rebuild blocker is fixed. `dismiss()` marks the overlay dirty at dismiss start and after delayed removal for non-empty stacks (`packages/warp_prism_ui/lib/src/molecules/ds_toast_manager.dart:179-190`).
- `RESOLVED`: Round 2 semantics duplication regression is fixed. The action label text is wrapped in `ExcludeSemantics` (`packages/warp_prism_ui/lib/src/molecules/ds_toast.dart:159-166`), and `find.bySemanticsLabel('Undo')` is asserted as a single widget (`packages/warp_prism_ui/test/molecules/ds_toast_test.dart:345-363`).
- `RESOLVED`: Completion Evidence now reports the current `38/38` toast test count and task-scoped analyzer evidence (`docs/tasks/03-review/1308-warp-prism-toast-async-lifecycle-stabilization.md:145-151`).

### Persistent Findings

- `PERSISTENT` / `EXTERNAL_BLOCKER`: Package-wide `flutter analyze lib/` is still red outside Task 1308 scope. Current reviewer run reports `450 issues found`, not the previous Round 3 count of `467`. Task-scoped analyzer is clean.

### Regressions

- None found in task-owned toast source or tests.

### New Findings

- `NEW`: Pause-on-hover is implemented and documented by `DSToastManager`, but `ds_toast_test.dart` has no hover gesture regression test. This does not invalidate the required Task 1308 commands, but it prevents a structural 100 for async lifecycle proof.

### Evidence Gaps / External Blockers

- `EVIDENCE_GAP`: No widget test currently proves hover pauses an auto-dismiss timer and restarts it on exit.
- `EXTERNAL_BLOCKER`: Package analyzer is non-green outside the modified toast files.

## Axiom Compliance

| # | Axiom | Status | Evidence |
| --- | --- | --- | --- |
| 1 | Analyzer Integrity | PARTIAL | Required task-scoped command passes: `flutter analyze lib/src/molecules/ds_toast.dart lib/src/molecules/ds_toast_manager.dart` → `No issues found!`. Package-wide `flutter analyze lib/` fails with `450 issues found`; example warning: `lib/src/organisms/split_pane/ds_split_pane.dart:223:15`. |
| 2 | Lifecycle Safety | PASS | Exact counts in task files: `TextEditingController` 0, `ScrollController` 0, `AnimationController` 0, `StreamSubscription` 0. `Timer(` creation 1 (`ds_toast_manager.dart:218`). Timer cancel sites 6 (`:147`, `:155`, `:175`, `:217`, `:238`, `:269`). `dispose()` calls `_removeOverlay()` and `_cancelAllTimers()` (`:127-130`). `Future.delayed` callback is guarded by `mounted` (`:181-183`); timer callback is guarded by `mounted` (`:218-220`). Overlay creation/insert/remove/dispose counts are 1/1/1/1 (`:257-263`). |
| 3 | Dependency Direction | PASS | `ds_toast.dart` imports Flutter, tokens, and atoms only (`:1-3`). `ds_toast_manager.dart` imports `dart:async`, Flutter, tokens, and sibling `ds_toast.dart` only (`:1-4`). No app/data/domain inversion introduced. |
| 4 | UI Accessibility | PASS | Explicit toast `Semantics` widgets: 3 (`ds_toast.dart:52`, `:144`, `:175`). Interactive widgets in `DSToast`: 2 (`TextButton` at `:147`, `IconButton` at `:181`); both are wrapped in explicit `Semantics`. Dismiss touch target is 48x48 (`:178-181`) and tested (`ds_toast_test.dart:550-579`). No color-only information: severity label is included in live-region semantics (`ds_toast.dart:56`). |
| 5 | Proof Reality | PARTIAL | Required toast test passes 38/38 in three reviewer runs. Test timing uses `WidgetTester.pump`, not real sleeps: test file has 31 `tester.pump(...)` calls and 0 `sleep(`, 0 `Future.delayed`, 0 `pumpAndSettle` matches. Remaining proof gap: pause-on-hover behavior has 0 test matches beyond the file header comment (`ds_toast_test.dart:5`). |
| 6 | Release Security | PASS | No hardcoded secrets, API keys, `print()`, or `debugPrint()` in `ds_toast.dart` or `ds_toast_manager.dart`. Task code is UI-only and adds no network/persistence surface. |

## Findings

| ID | Class | Severity | Status | Summary | First seen | Evidence |
| --- | --- | --- | --- | --- | --- | --- |
| F1 | EXTERNAL_BLOCKER / PERSISTENT | Moderate | Open outside task scope | Package-level analyzer remains non-green with `450 issues found`; task-scoped analyzer is clean. | Round 1, count updated in this review | `analysis_options.yaml:1-7`; `lib/src/organisms/split_pane/ds_split_pane.dart:223:15`; command `flutter analyze lib/` |
| F2 | NEW / EVIDENCE_GAP | Low | Open | Pause-on-hover async lifecycle behavior lacks a widget regression test. | This review | `ds_toast_manager.dart:14`, `:231-253`; `ds_toast_test.dart:5`; grep found 0 hover gesture tests |
| F3 | RESOLVED | High | Closed | Semantics duplication regression no longer reproduces; action text is excluded from semantics under an explicit action button semantics wrapper. | Round 2 | `ds_toast.dart:144-166`; `ds_toast_test.dart:345-363`; `flutter test test/molecules/ds_toast_test.dart` → 38/38 pass |
| F4 | RESOLVED | High | Closed | Overlay/timer lifecycle cleanup is adequate for task scope. | Round 1 | `ds_toast_manager.dart:127-130`, `:175-190`, `:257-269`; two-toast regression at `ds_toast_test.dart:608-635` |
| F5 | RESOLVED | Medium | Closed | Tests are deterministic for required toast paths and use fake widget time only. | Round 1 | `ds_toast_test.dart:423-426`, `:450-452`, `:601-603`, `:627-630`; no `sleep`, no test `Future.delayed`, no `pumpAndSettle` |

### Finding Details And Recommendations

#### F1 — Package analyzer remains red outside task scope

- **Classification**: `EXTERNAL_BLOCKER / PERSISTENT`
- **Severity**: Moderate for Task 1308; high for the package quality gate.
- **Evidence**: Required task-scoped analyzer passes, but reviewer-owned package sanity command `flutter analyze lib/` reports `450 issues found`. The current count differs from Round 3's `467`, so any future package-level evidence must be regenerated before claiming exact counts.
- **Recommendation**: Keep Task 1308 approval scoped to toast files, then open/route a separate package analyzer remediation task. The next package-level task must either clear all `flutter analyze lib/` findings or publish a fresh exact count/breakdown from the current toolchain.

#### F2 — Pause-on-hover lifecycle lacks regression proof

- **Classification**: `NEW / EVIDENCE_GAP`
- **Severity**: Low.
- **Evidence**: `DSToastManager` advertises pause-on-hover (`packages/warp_prism_ui/lib/src/molecules/ds_toast_manager.dart:14`) and implements it in `_onHoverChanged` (`:231-253`). The test file only mentions pause-on-hover in a header comment (`packages/warp_prism_ui/test/molecules/ds_toast_test.dart:5`) and contains no `MouseRegion`, `createGesture`, `addPointer`, `moveTo`, or hover-specific assertions.
- **Recommendation**: Add one widget test that shows a toast with `duration: const Duration(seconds: 1)`, moves a mouse pointer over the toast, pumps longer than one second, asserts the toast remains, moves the pointer away, pumps the duration plus `DSMotion.slow`, and asserts the toast is removed.

## Evidence Reviewed

- **Task file**: `docs/tasks/03-review/1308-warp-prism-toast-async-lifecycle-stabilization.md`
- **Source/test files from the Where table**:
  - `packages/warp_prism_ui/lib/src/molecules/ds_toast.dart`
  - `packages/warp_prism_ui/lib/src/molecules/ds_toast_manager.dart`
  - `packages/warp_prism_ui/test/molecules/ds_toast_test.dart`
  - `AGENTS.md`
  - `.gitignore`
- **Completion evidence read**: `docs/tasks/03-review/1308-warp-prism-toast-async-lifecycle-stabilization.md:129-155`
- **Changelog read**: `docs/changelog/2026-06-09-toast-async-lifecycle-stabilization.md`
- **Previous reports read**: all three reports listed in Review Lineage.
- **Runtime wiring proof**: `DSToastManager` inserts a single `OverlayEntry` via `Overlay.of(context).insert(_overlayEntry!)` (`ds_toast_manager.dart:255-259`), rebuilds it with `markNeedsBuild()` on show/dismiss/hover (`:161`, `:180`, `:189`, `:252`), and removes/disposes it in `_removeOverlay()` (`:261-264`).

## Commands Run

All required commands were run from `packages/warp_prism_ui/`.

| Command | Result |
| --- | --- |
| `flutter analyze lib/src/molecules/ds_toast.dart lib/src/molecules/ds_toast_manager.dart` | PASS — `No issues found!` |
| `flutter test test/molecules/ds_toast_test.dart` | PASS — `+38: All tests passed!` |
| `flutter test test/molecules/ds_toast_test.dart` (run 2) | PASS — `+38: All tests passed!` |
| `flutter test test/molecules/ds_toast_test.dart` (run 3) | PASS — `+38: All tests passed!` |
| `dart format --set-exit-if-changed lib/src/molecules/ds_toast.dart lib/src/molecules/ds_toast_manager.dart test/molecules/ds_toast_test.dart` | PASS — `Formatted 3 files (0 changed) in 0.04 seconds.` |
| `flutter analyze lib/` | FAIL outside task scope — `450 issues found`; task-owned toast files remain clean. |
| `rg -n "Future\.delayed\|sleep\(\|Timer\(\|fakeAsync\|pumpAndSettle" test/molecules/ds_toast_test.dart` | PASS for real-wait audit — no matches for real sleeps, test `Future.delayed`, `Timer(`, `fakeAsync`, or `pumpAndSettle`. |

## Path To 100

1. **Add pause-on-hover regression coverage** in `packages/warp_prism_ui/test/molecules/ds_toast_test.dart` for `_onHoverChanged` (`ds_toast_manager.dart:231-253`): hover over a timed toast, pump beyond its duration, assert it remains; exit hover, pump its duration plus `DSMotion.slow`, assert it disappears.
2. **Regenerate package analyzer evidence** with the current toolchain. Either clear all `flutter analyze lib/` findings or update the external-blocker classification from `450 issues found` with an exact current breakdown and tracking task.
3. **Optional hardening**: add an action-button size assertion alongside the existing dismiss size test (`ds_toast_test.dart:550-579`) to prove both interactive controls meet the 48x48 dp touch-target axiom under the current Flutter button defaults.

## Task Ledger Patch Suggestion

```markdown
### 2026-06-13 — independent reviewer (review-wave-1)
**Score**: 94/100 — Elite
**Verdict**: APPROVED_WITH_PATCHES → accept Task 1308 scope; track follow-up hardening
**Report**: `docs/reports/review-wave-1/1308-review.md`
**Diagnostics**: `flutter analyze lib/src/molecules/ds_toast.dart lib/src/molecules/ds_toast_manager.dart` PASS (`No issues found!`) | `flutter test test/molecules/ds_toast_test.dart` PASS (`38/38`) ×3 | `dart format --set-exit-if-changed lib/src/molecules/ds_toast.dart lib/src/molecules/ds_toast_manager.dart test/molecules/ds_toast_test.dart` PASS (`0 changed`) | package sanity `flutter analyze lib/` FAIL outside task scope (`450 issues found`)
**Current Open Items**:
- `EXTERNAL_BLOCKER`: package-wide analyzer remains red outside Task 1308 scope; current count is 450, so prior 467-count evidence is stale.
- `EVIDENCE_GAP`: pause-on-hover timer lifecycle has implementation but no hover gesture regression test.
**Path-to-100 Summary**:
- Add hover pause/resume widget test for timed toasts.
- Refresh or clear package-wide analyzer classification.
- Optionally add action-button 48x48 size proof.
**Previous Reports**:
- `2026-06-11` — `63/100` — `docs/reports/build-gate-review/1308-review.md`
- `2026-06-11` — `57/100` — `docs/reports/build-gate-review/1308-review-round2.md`
- `2026-06-11` — `100/100` — `docs/reports/build-gate-review/1308-review-round3.md`
```
