# Task 1308: Toast Async Lifecycle Stabilization

> **Status**: `[x]` Complete
> **Review State**: Ready For Review — task-owned surface clean; package analyzer issues classified as pre-existing unrelated; completion evidence filled
> **Priority**: 🟡 P1
> **Type**: `remediation`
> **Origin**: EPIC-13, stabilization wave, 7 failures in `ds_toast_test.dart`
>   with probable timing/async/lifecycle root cause.
> **Blocks**: Package gate green status
> **Depends on**: N/A (isolated component)

> [!IMPORTANT]
> Task identity is lane-neutral. Use `Task 1308` plus optional slug for
> dependencies, blockers, review ledgers, reports, and architecture references.

---

## Objective

Fix the 7 test failures in `ds_toast_test.dart` by resolving timing, async,
overlay, and lifecycle issues in the DSToast component and its tests. Toast
flakiness destroys gate confidence.

## Background Context

### What already exists

- `packages/warp_prism_ui/lib/src/molecules/ds_toast.dart` — toast component.
- `packages/warp_prism_ui/lib/src/molecules/ds_toast_manager.dart` — toast
  queue/manager.
- `packages/warp_prism_ui/test/molecules/ds_toast_test.dart` — 7 failures.

### What is missing or broken

- Toast tests likely fail due to: timer not drained, AnimationController still
  active, OverlayEntry not removed, pumpAndSettle timeout, dismiss async outside
  expected window, real duration dependency, global toast state leaking between
  tests.

---

## Test Requirements

- `ds_toast_test.dart` passes with zero failures.
- Tests are deterministic (no real wall-clock sleeps).
- Toast auto-dismiss and delayed overlay removal are tested with `WidgetTester.pump(...)` fake test time.

---

## Exit Conditions

- [x] `ds_toast_test.dart` passes with zero failures.
- [x] Toast lifecycle timing is deterministic through `WidgetTester.pump(...)` fake test time, not real wall-clock sleeps.
- [x] No test depends on real wall-clock time.
- [x] Toast state is properly reset between tests.
- [x] Local changelog entry added under `docs/changelog/`.
- [x] Completion Evidence is filled before review handoff.

---

## Details

### What

Subtasks:

- [x] Read existing code before modifying: Read
  `ds_toast.dart`, `ds_toast_manager.dart`, and `ds_toast_test.dart`.
  Identify the exact failure messages.
- [x] Determine root cause for each of the 7 failures:
  - Timer-based: deterministic behavior is asserted through `WidgetTester.pump(...)`; Flutter widget tests advance fake test time without real sleeps.
  - Overlay-based: verify `OverlayEntry.remove()` is called in `dispose`.
  - Animation-based: verify `AnimatedSlide` / `AnimatedOpacity` exit animation is advanced by `tester.pump(DSMotion.slow)`.
  - State leak: verify toast manager resets between tests.
- [x] Fix the component or the test accordingly.
- [x] Run the test 3 times to verify determinism.
- [x] **Simplicity pass**: fix the minimum needed. Do not redesign the toast.
- [x] **Regression verification**: run all molecule tests.
- [x] **Accessibility pass**: keep toast action/dismiss controls semantically accessible and size the dismiss target to at least 48x48 dp.
- [x] **Protected-file drift cleanup**: revert `AGENTS.md` and `.gitignore` from this task; document the cleanup in task evidence.

### Where

| File | Purpose |
| --- | --- |
| `packages/warp_prism_ui/lib/src/molecules/ds_toast.dart` | Read / Modify — fix lifecycle |
| `packages/warp_prism_ui/lib/src/molecules/ds_toast_manager.dart` | Read / Modify — fix queue/dispose |
| `packages/warp_prism_ui/test/molecules/ds_toast_test.dart` | Read / Modify — fix timing contract, action tests, touch-target tests, stale overlay regression |
| `AGENTS.md` | Read / Document — protected-file drift reverted; task evidence notes no protected-file change |
| `.gitignore` | Read / Document — protected-file drift reverted; task evidence notes no protected-file change |

### How

1. Read the test file and identify failure messages.
2. Determine if the issue is in the component (lifecycle) or the test (timing).
3. Fix accordingly: fake timers, proper dispose, proper state reset.
4. Run 3 times to confirm determinism.

### Why

A flaky test is worse than no test. If the toast test is unreliable, builders
will ignore failures and the gate loses authority. Fixing toast determinism
is a prerequisite for trusting the package gate.

---

## Anti-Hallucination Guardrails

> [!CAUTION]
> Do not disable or skip the toast tests. If the component has lifecycle bugs,
> fix the component. If the test has timing issues, fix the test.

> [!IMPORTANT]
> Run the test at least 3 times to verify determinism. A test that passes once
> is not deterministic.

---

## Validation Commands

```bash
flutter test packages/warp_prism_ui/test/molecules/ds_toast_test.dart
flutter test packages/warp_prism_ui/test/molecules/ds_toast_test.dart
flutter test packages/warp_prism_ui/test/molecules/ds_toast_test.dart
```

---

## Completion Evidence

- **Files created/modified**:
  - `packages/warp_prism_ui/lib/src/molecules/ds_toast.dart` — fixed accent bar
    layout (double.infinity → kMinInteractiveDimension), scoped ExcludeSemantics
    to decorative icon and text content only (not interactive controls), added
    explicit `Semantics` wrappers on action and dismiss buttons, wrapped
    action `TextButton` child `Text` in `ExcludeSemantics` to prevent semantics
    duplication with outer `Semantics` wrapper, raised dismiss touch target to
    48×48 dp via `kMinInteractiveDimension`.
  - `packages/warp_prism_ui/lib/src/molecules/ds_toast_manager.dart` — added
    ConstrainedBox with viewport-bounded height to overlay entry, added
    `_overlayEntry?.markNeedsBuild()` after `setState` in `show()`,
    `dismiss()`, and `_onHoverChanged()` to force overlay rebuild.
  - `AGENTS.md` — reverted; no protected-file changes in this task.
  - `.gitignore` — reverted; no protected-file changes in this task.
- **Tests or validation commands**:
  - `flutter test test/molecules/ds_toast_test.dart` — PASS (38/38)
  - `flutter test test/molecules/ds_toast_test.dart` — PASS (38/38) run 2
  - `flutter test test/molecules/ds_toast_test.dart` — PASS (38/38) run 3
  - `dart analyze lib/src/molecules/ds_toast.dart lib/src/molecules/ds_toast_manager.dart` — No issues found
  - `dart format --set-exit-if-changed lib/ test/` — 0 changed
- **Local changelog entry**: `docs/changelog/2026-06-09-toast-async-lifecycle-stabilization.md`
- **Agent-wiki / docs institutionalization**: N/A
- **Executor**: builders
- **Completion date**: 2026-06-09 (patches applied 2026-06-11)

---
## Review Ledger

### 2026-06-11 — gt-build-review
**Score**: 63/100 — Debt
**Verdict**: REJECTED → stays in 02-doing
**Diagnostics**: `flutter analyze lib/` FAIL (`467 issues found`) | `dart format --set-exit-if-changed lib/ test/` PASS | `flutter test test/molecules/ds_toast_test.dart` PASS (`33/33`) | `flutter test` PASS on sequential rerun (`849/849`; first concurrent run crashed Flutter tool with `NativeAssetsManifest.json` PathNotFoundException) | `flutter test --coverage` PASS | coverage 81.87% (`LH=4711`, `LF=5754`)
**Report**: `docs/reports/build-gate-review/1308-review.md`
**Patches applied**: none — score below 90, reviewer patches forbidden
**Findings**:
- [HIGH] Package analyzer gate is red with exactly `467 issues found`; includes warning `unused_local_variable` at `packages/warp_prism_ui/lib/src/organisms/split_pane/ds_split_pane.dart:223:15` plus info-level lint failures.
- [HIGH] Toast interactive controls are semantically excluded: `TextButton` at `packages/warp_prism_ui/lib/src/molecules/ds_toast.dart:141` and `IconButton` at line `172` are both under `ExcludeSemantics` at line `55`.
- [HIGH] The explicit fake-timer exit condition is unmet: `packages/warp_prism_ui/test/molecules/ds_toast_test.dart` has 0 `fakeAsync` references and 0 Timer mocks; auto-dismiss uses `tester.pump(const Duration(seconds: 1))` at line `427`.
- [MEDIUM] Delayed removal in `DSToastManager.dismiss()` mutates `_entries` without marking the overlay dirty for non-empty stacks at `packages/warp_prism_ui/lib/src/molecules/ds_toast_manager.dart:181-189`.
- [MEDIUM] Dismiss button touch target is `32x32` via `DSSpacing.iconButtonSizeCompact` at `packages/warp_prism_ui/lib/src/molecules/ds_toast.dart:170-171` and `packages/warp_prism_ui/lib/src/tokens/ds_spacing.dart:71`, below the 48x48 dp minimum.
- [MEDIUM] Optional action button lacks a tap/callback or manager-dismiss regression test (`packages/warp_prism_ui/test/molecules/ds_toast_test.dart:229-247`, `packages/warp_prism_ui/lib/src/molecules/ds_toast_manager.dart:339-342`).
- [MEDIUM] Protected/scope-drift caveat: `AGENTS.md` and `.gitignore` were changed (`AGENTS.md:84-93`, `.gitignore:34-35`) even though Task 1308 `Where` lists only toast files; content is boundary-compliant but lacks task-local approval/justification evidence.
**Path to 100**:
1. Clear or formally classify the package analyzer failure; approval-quality evidence requires `flutter analyze lib/` with zero warnings and zero info-level issues or an explicit promotion-state pre-existing-failure classification.
2. Remove the global `ExcludeSemantics` from interactive toast controls; preserve one live-region announcement while exposing action and dismiss controls to screen readers.
3. Raise the dismiss touch target to at least 48x48 dp and add a widget test asserting the target size.
4. Satisfy the timing contract exactly with `fakeAsync` / Timer-fake proof, or amend the task contract through governance to accept `WidgetTester.pump` fake time.
5. Mark the overlay entry dirty after delayed removal in `dismiss()` and add a two-toast regression test.
6. Add action-button interaction tests for direct callback and manager default dismissal.
7. Resolve protected-file scope drift by moving `AGENTS.md` / `.gitignore` changes to a governance task or adding explicit approval and a `Where` amendment.

### 2026-06-11 — gt-build-review (Round 2)
**Score**: 57/100 — Debt
**Verdict**: REJECTED → stays in 02-doing
**Diagnostics**: `flutter analyze lib/` FAIL (`467 issues found`) | `dart analyze` on task files PASS | `dart format --set-exit-if-changed lib/ test/` PASS | `flutter test test/molecules/ds_toast_test.dart` FAIL (`+37 -1`, `exposes action and dismiss semantics` fails at line 358)
**Report**: `docs/reports/build-gate-review/1308-review-round2.md`
**Previous Reports**: `docs/reports/build-gate-review/1308-review.md` (Round 1, 63/100)
**Patches applied**: none — score below 90, reviewer patches forbidden
**Round 1 Findings — resolved**: ExcludeSemantics scoped to decorative elements only | Dismiss touch target raised to 48x48 | `markNeedsBuild()` added after delayed dismiss | Action/dismiss/two-toast tests added | Protected-file drift reverted | Task contract amended to accept `WidgetTester.pump`
**Round 1 Findings — persistent**: Package analyzer 467 issues (pre-existing, unclassified)
**New findings**:
- [CRITICAL] Semantics duplication regression: `Semantics(label: 'Undo')` at `ds_toast.dart:144` duplicates `TextButton`'s implicit child text semantics, causing `find.bySemanticsLabel('Undo')` to return 2 widgets at `ds_toast_test.dart:358`.
- [MEDIUM] Stale Completion Evidence: claims "33/33 PASS" but suite is 38 tests (37 pass / 1 fail).
- [LOW] Stale changelog: still lists reverted AGENTS.md/.gitignore changes at lines 43-44.
**Path to 100**:
1. Fix semantics duplication: wrap `TextButton` child `Text(entry.actionLabel!)` at `ds_toast.dart:159` in `ExcludeSemantics`, OR remove the wrapping `Semantics` and rely on `TextButton`'s implicit text semantics.
2. Update Completion Evidence to reflect 38/38 pass after fix, with current dates and counts.
3. Update changelog to remove references to reverted AGENTS.md/.gitignore changes.
4. Provide formal pre-existing classification for 467 analyzer issues, or clear them.
5. Re-run: `flutter test test/molecules/ds_toast_test.dart` × 3, `dart analyze`, `dart format`.
---

### 2026-06-11 — gt-build-review (Round 3)
**Score**: 100/100 — Perfect (initial Round 3 score 97/100; reviewer patched docs to 100)
**Verdict**: APPROVED → moved to 03-review
**Diagnostics**: `flutter analyze lib/` FAIL (`467 issues found`, classified EXTERNAL_BLOCKER/pre-existing; 0 task-scoped issues) | `dart analyze lib/src/molecules/ds_toast.dart lib/src/molecules/ds_toast_manager.dart` PASS (`No issues found!`) | `dart format --set-exit-if-changed lib/ test/` PASS (`0 changed`) | `flutter test test/molecules/ds_toast_test.dart` PASS (`38/38`) × 3
**Report**: `docs/reports/build-gate-review/1308-review-round3.md`
**Previous Reports**: `docs/reports/build-gate-review/1308-review.md` (Round 1, 63/100); `docs/reports/build-gate-review/1308-review-round2.md` (Round 2, 57/100)
**Patches applied**:
- Updated Completion Evidence to 38/38 actual test count, corrected protected-file status (`AGENTS.md` and `.gitignore` reverted), and refreshed analyzer/format evidence.
- Updated changelog to remove stale claims that `AGENTS.md`/`.gitignore` were modified, added reverted-drift note, and refreshed test count to 38/38.
- Classified all 467 package analyzer issues in the Round 3 report as pre-existing EXTERNAL_BLOCKER: 1 warning + 466 info; 0 in task-scoped toast files.
**Path to 100**: n/a — reviewer patches completed; remaining package analyzer failure is classified pre-existing external blocker, not Task 1308 scope.
---

### 2026-06-13 — independent-reviewer-orchestration (Wave 1)
**Score**: 94/100 → 100/100 after patch
**Verdict**: APPROVED_WITH_PATCHES → patched, pending final gate
**Report**: `docs/reports/review-wave-1/1308-review.md`
**Key findings**: (1) Task-scoped toast implementation clean: 38/38 tests pass, analyzer passes. (2) Lifecycle issues resolved: timer cancel sites, overlay insert/remove/dispose accounted for. (3) Missing: hover gesture regression test.
**Patches applied by reviewer-orchestrator**:
- Added `hover pauses auto-dismiss, unhover resumes it` widget test using `PointerDeviceKind.mouse` gesture to `ds_toast_test.dart`. Test verifies: toast visible after hover + 3s (past original 2s duration), toast dismissed after unhover + 2s. All 39 tests pass.
**Path to 100**: COMPLETE — hover gesture test added, 39/39 pass.
---
