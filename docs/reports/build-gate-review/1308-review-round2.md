# Build-Gate Review: 1308 — Toast Async Lifecycle Stabilization (Round 2)

**Date**: 2026-06-11
**Reviewer**: gt-build-review workflow
**Task file**: `docs/tasks/02-doing/1308-warp-prism-toast-async-lifecycle-stabilization.md`
**Previous Report**: `docs/reports/build-gate-review/1308-review.md` (Round 1, 63/100)

## Score: 57/100 — Debt

## Verdict

**REJECTED → stays in `docs/tasks/02-doing/`.**

Reason: the builder's Round 1 fixes introduced a semantics duplication regression that causes 1 test failure (`exposes action and dismiss semantics` at `ds_toast_test.dart:358`). The first exit condition (`ds_toast_test.dart passes with zero failures`) is violated. Completion Evidence was not refreshed and still claims 33/33 despite the suite now containing 38 tests (37 pass, 1 fail). The package analyzer remains at 467 issues with no formal pre-existing classification.

## Previous Report Delta

### RESOLVED (from Round 1)

| Finding | Round 1 Status | Resolution |
|---------|---------------|------------|
| Global `ExcludeSemantics` hid interactive controls | HIGH | `ExcludeSemantics` now scoped to decorative icon (`ds_toast.dart:89`) and text content (`ds_toast.dart:112`) only; action (`ds_toast.dart:144`) and dismiss (`ds_toast.dart:173`) have explicit `Semantics` wrappers. |
| Dismiss button 32x32 touch target | MEDIUM | Now `kMinInteractiveDimension` (48x48) via `SizedBox` at `ds_toast.dart:176-178`. |
| `markNeedsBuild()` missing after delayed dismiss for non-empty stacks | MEDIUM | Added at `ds_toast_manager.dart:189`. |
| Missing action-button interaction tests | MEDIUM | Added: `action button fires onAction callback` at `ds_toast_test.dart:525-545`, `manager action tap dismisses toast` at `ds_toast_test.dart:578-603`. |
| Missing two-toast regression test | MEDIUM | Added: `two toasts - dismiss one leaves other visible` at `ds_toast_test.dart:605-632`. |
| Protected-file drift (AGENTS.md/.gitignore changed) | MEDIUM | Reverted. `AGENTS.md` and `.gitignore` show no diff from HEAD. Task `Where` table updated to "Read / Document — protected-file drift reverted." |
| `fakeAsync` exit condition unmet | HIGH | Task contract amended: exit condition #2 now reads "`WidgetTester.pump(...)` fake test time" at `docs/tasks/02-doing/1308-...:53`. Test Requirements section also amended at line 46. Contract change is legitimate governance. |

### PERSISTENT (from Round 1)

| Finding | Round 1 Status | Round 2 Status | Notes |
|---------|---------------|----------------|-------|
| Package analyzer 467 issues | HIGH | HIGH | Unchanged. No formal pre-existing classification evidence provided. |

### NEW (Round 2 only)

| Finding | Severity | Details |
|---------|----------|---------|
| Semantics duplication regression | CRITICAL | New test `exposes action and dismiss semantics` fails at `ds_toast_test.dart:358` — `find.bySemanticsLabel('Undo')` returns 2 widgets instead of 1. |
| Stale Completion Evidence | MEDIUM | Still claims "33/33 PASS" but suite is now 38 tests (37 pass, 1 fail). |
| Stale changelog | LOW | Changelog at lines 43-44 still lists AGENTS.md/.gitignore changes that were reverted. |

## Diagnostics

| Command | Result | Details |
|---------|--------|---------|
| `flutter analyze lib/` | FAIL | `467 issues found`; 1 warning (`unused_local_variable` at `lib/src/organisms/split_pane/ds_split_pane.dart:223:15`), 466 info-level lint issues. All pre-existing; 0 issues in task-scoped toast files. |
| `dart analyze lib/src/molecules/ds_toast.dart lib/src/molecules/ds_toast_manager.dart` | PASS | `No issues found!` |
| `dart format --set-exit-if-changed lib/ test/` | PASS | `Formatted 122 files (0 changed) in 0.56 seconds.` |
| `flutter test test/molecules/ds_toast_test.dart` (run 1) | FAIL | `+37 -1: Some tests failed.` — `exposes action and dismiss semantics` fails at line 358. |
| `flutter test test/molecules/ds_toast_test.dart` (run 2) | FAIL | Same failure, deterministic. |

## Six-Axiom Compliance

| # | Axiom | Status | Evidence |
|---|-------|--------|----------|
| 1 | Analyzer Integrity | FAIL | `flutter analyze lib/` reports `467 issues found`. Task-scoped files are clean (`dart analyze` on `ds_toast.dart` + `ds_toast_manager.dart` = `No issues found`), but package-level axiom is not green. No pre-existing classification evidence. |
| 2 | Lifecycle Safety | PASS | Timer creation: 1 site (`ds_toast_manager.dart:218`). Timer cancel: 6 sites (`147`, `155`, `175`, `217`, `238`, `269`). `_cancelAllTimers()` at `267-270` iterates all entries. `dispose()` at `127-131` calls `_removeOverlay()` then `_cancelAllTimers()`. Overlay creation: 1 site (`257`). Overlay remove: `262`. Overlay dispose: `263`. `mounted` guard at `141`, `182`, `219`. `markNeedsBuild()` called at `161`, `180`, `189`, `252`. No lifecycle leaks in task-scoped code. |
| 3 | Dependency Direction | PASS | `ds_toast.dart:1-3` imports Flutter, tokens, atoms. `ds_toast_manager.dart:1-4` imports `dart:async`, Flutter, tokens, `ds_toast.dart`. No app-layer or reverse imports. |
| 4 | UI Accessibility | PARTIAL | Outer `Semantics(liveRegion: true, label: ...)` at `ds_toast.dart:52-56`. Icon excluded at `89`. Text excluded at `112`. Action `Semantics(label: actionLabel, button: true)` at `144-146`. Dismiss `Semantics(label: 'Dismiss notification', button: true)` at `173-175`. Touch target 48x48 at `176-178`. **Issue**: action `Semantics` wrapper creates a duplicate node alongside `TextButton`'s implicit text semantics, causing test failure. |
| 5 | Proof Reality | FAIL | Exit condition #1 violated: `ds_toast_test.dart` has 1 failure. Completion Evidence claims "33/33 PASS" but suite has 38 tests with 37 pass/1 fail. |
| 6 | Release Security | PASS | No secrets, API keys, `print()`, or `debugPrint()` in task-scoped files. |

## Build-Gate Axiom Compliance

| # | Axiom | Status | Evidence |
|---|-------|--------|----------|
| 1 | Widget Lifecycle | PASS | 0 `AnimationController`, 0 `ScrollController`, 0 `TextEditingController`, 0 `StreamSubscription`. 1 `Timer` creation (`ds_toast_manager.dart:218`), 6 cancel sites, `_cancelAllTimers()` in `dispose()`. 1 `OverlayEntry` creation (`257`), removed+disposed in `_removeOverlay()` (`262-264`), called from `dispose()` (`128`). |
| 2 | Provider Scoping | PASS | No Riverpod providers in modified files. |
| 3 | Const Constructors | FAIL | Package-level: 467 analyzer issues include `prefer_const_constructors`. Task-scoped files: `dart analyze` reports 0 issues. |
| 4 | Semantic Labels | PARTIAL | 2 interactive widgets (`TextButton` at `ds_toast.dart:147`, `IconButton` at `179`). Both have explicit `Semantics` wrappers (`144-146`, `173-175`). Dismiss has tooltip at `187`. **Issue**: action button `Semantics(label: 'Undo')` duplicates with `TextButton`'s implicit child text semantics, creating 2 nodes with same label. |
| 5 | Type Safety | PASS | No `dynamic`, unchecked `as`, or `!` force-unwraps introduced. `DSToastManager.of` uses `assert`+`!` at `100-101`, guarded pattern. |

## Warp Prism Checks

| Check | Status | Evidence |
|-------|--------|----------|
| Read-only contract | PASS | UI-only changes; no API, persistence, or mutation endpoints. |
| DS*/Prism* boundary | PASS | Package-internal `DS*` names; no app imports. |
| Mock workspace fixtures | N/A | Toast does not consume fixture data. |
| Melos package boundary | PASS | No cross-package imports from `apps/`. |
| Operational state vocabulary | N/A | Toast severity is notification severity, not operational state. |
| Design token usage | PASS | Colors from `DSColors`, spacing from `DSSpacing`, radii from `DSRadii`, typography from `DSTypography`. Touch target uses `kMinInteractiveDimension`. |
| Gallery coverage | N/A | No new component introduced. |
| Test coverage | PARTIAL | 38 tests covering severity, render, dismiss, auto-dismiss, clear, maxVisible, replacement, action callback, touch target, two-toast regression, semantics. 1 test fails (semantics duplication). |

## Exit Conditions

| # | Condition | Met? | Evidence |
|---|-----------|------|----------|
| 1 | `ds_toast_test.dart` passes with zero failures. | FAIL | `flutter test test/molecules/ds_toast_test.dart` → `+37 -1: Some tests failed.` Failing: `exposes action and dismiss semantics` at line 358. |
| 2 | Toast lifecycle timing is deterministic through `WidgetTester.pump(...)`. | PASS | Auto-dismiss test uses `tester.pump(const Duration(seconds: 1))` at `ds_toast_test.dart:447`. No real sleeps. |
| 3 | No test depends on real wall-clock time. | PASS | All timing via `tester.pump(...)`. |
| 4 | Toast state is properly reset between tests. | PASS | Each test pumps a fresh `DSToastManager` + `_ManagerTestHelper` with unique `GlobalKey`. |
| 5 | Local changelog entry added. | PASS | `docs/changelog/2026-06-09-toast-async-lifecycle-stabilization.md` exists. |
| 6 | Completion Evidence is filled. | FAIL | Evidence section exists but is stale: claims "33/33 PASS" at `docs/tasks/02-doing/1308-...:143-145`; actual suite has 38 tests, 1 fails. |

## Findings

### Critical

- [CRITICAL] **Semantics duplication regression** — The action button's explicit `Semantics(label: entry.actionLabel, button: true)` at `ds_toast.dart:144-146` wraps a `TextButton` whose child `Text(entry.actionLabel!)` at `ds_toast.dart:159-163` also contributes a semantics label. `find.bySemanticsLabel('Undo')` at `ds_toast_test.dart:358` finds 2 widgets: the explicit `Semantics` wrapper and the `TextButton`'s implicit child text node. Test fails deterministically on every run. — `packages/warp_prism_ui/lib/src/molecules/ds_toast.dart:144-163`, `packages/warp_prism_ui/test/molecules/ds_toast_test.dart:358`

### High

- [HIGH] **Package analyzer still red at 467 issues** (PERSISTENT from Round 1) — `flutter analyze lib/` reports `467 issues found`. Includes 1 warning (`unused_local_variable` at `ds_split_pane.dart:223:15`) and 466 info-level lint violations (`prefer_const_constructors`, `deprecated_member_use`, etc.). All are in non-task files. No formal pre-existing classification evidence has been provided. — `flutter analyze lib/` output

### Medium

- [MEDIUM] **Stale Completion Evidence** — Task file at lines 143-145 claims "PASS (33/33)" across 3 runs. Actual suite now has 38 tests (5 new tests added: semantics assertion, action/dismiss semantics exposure, action callback, touch target, two-toast regression, manager action dismissal). The result is 37 pass / 1 fail. Evidence was not updated after fixes. — `docs/tasks/02-doing/1308-...:143-145`

### Low

- [LOW] **Stale changelog** — `docs/changelog/2026-06-09-toast-async-lifecycle-stabilization.md:43-44` still lists `AGENTS.md (added workspace file creation rule)` and `.gitignore (added tmp/)` as modified files, but those changes were reverted per the protected-file drift cleanup. — `docs/changelog/2026-06-09-toast-async-lifecycle-stabilization.md:43-44`

## Patches Applied

None. Score is below 90; workflow forbids reviewer patches.

## Path to 100

1. **Fix the semantics duplication** (CRITICAL, blocks exit condition #1):
   - Option A: Wrap the `TextButton`'s child `Text(entry.actionLabel!)` at `ds_toast.dart:159` in `ExcludeSemantics`, so only the outer `Semantics(label: entry.actionLabel, button: true)` at line 144 contributes to the tree.
   - Option B: Remove the explicit `Semantics` wrapper at lines 144-146 and instead set `semanticsLabel` on the `TextButton`, or rely on `TextButton`'s implicit text semantics.
   - Verify: `flutter test test/molecules/ds_toast_test.dart` must pass 38/38.

2. **Update Completion Evidence** (MEDIUM):
   - Re-run `flutter test test/molecules/ds_toast_test.dart` three times after fix #1.
   - Update lines 143-145 to reflect the actual test count (38/38 after fix) and dates.
   - Update line 146 with current `dart analyze` results on both toast files.

3. **Update changelog** (LOW):
   - Remove lines 43-44 (`AGENTS.md` / `.gitignore`) from `docs/changelog/2026-06-09-toast-async-lifecycle-stabilization.md` or note they were reverted.

4. **Classify or resolve package analyzer failures** (HIGH, pre-existing):
   - Either clear 467 issues (large effort, outside Task 1308 scope), OR
   - Provide a formal pre-existing classification document (e.g., a separate governance task or `docs/reports/` artifact) proving all 467 issues predate Task 1308 and are tracked for separate remediation.

5. **Re-run full diagnostics**:
   - `flutter test test/molecules/ds_toast_test.dart` × 3 (determinism proof)
   - `dart analyze lib/src/molecules/ds_toast.dart lib/src/molecules/ds_toast_manager.dart`
   - `dart format --set-exit-if-changed lib/ test/`
