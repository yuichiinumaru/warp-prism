# Build-Gate Review: 1308 — Toast Async Lifecycle Stabilization

**Date**: 2026-06-11
**Reviewer**: gt-build-review workflow
**Task file**: `docs/tasks/02-doing/1308-warp-prism-toast-async-lifecycle-stabilization.md`

## Score: 63/100 — Debt

## Verdict

**REJECTED → stays in `docs/tasks/02-doing/`.**

Reason: the toast tests now pass, but the implementation does not satisfy the task's explicit deterministic-timing contract, the package analyzer gate is red, and the accessibility/lifecycle review found concrete regressions in the modified toast surface.

## Diagnostics

| Command | Result | Details |
|---------|--------|---------|
| `flutter analyze lib/` | FAIL | `467 issues found`; includes `warning • unused_local_variable • lib/src/organisms/split_pane/ds_split_pane.dart:223:15` plus analyzer info-level lint violations. Axiom 1 requires zero warnings and zero info-level issues. |
| `dart format --set-exit-if-changed lib/ test/` | PASS | `Formatted 122 files (0 changed) in 0.80 seconds.` |
| `flutter test test/molecules/ds_toast_test.dart` | PASS | `+33: All tests passed!` |
| `flutter test` | PASS after sequential rerun | Initial concurrent run crashed the Flutter tool with `PathNotFoundException` in `build/unit_test_assets/NativeAssetsManifest.json`; sequential rerun passed: `+849: All tests passed!`. |
| `flutter test --coverage` | PASS | Full package suite passed: `+849: All tests passed!`; generated `packages/warp_prism_ui/coverage/lcov.info`. |
| Coverage | 81.87% | Computed from `lcov.info`: `LH=4711`, `LF=5754`. |
| `dart pub outdated` | INFO | Direct outdated constraints: `fl_chart 0.68.0`, `flutter_riverpod 2.6.1`, `go_router 14.8.1`, `intl 0.19.0`, `flutter_lints 4.0.0`, `melos 7.8.1`. |

## Six-Axiom Compliance

| # | Axiom | Status | Evidence |
|---|-------|--------|----------|
| 1 | Analyzer Integrity | FAIL | `flutter analyze lib/` reports exactly `467 issues found`; `analysis_options.yaml:5-7` enables `prefer_const_constructors`, `prefer_const_declarations`, and `avoid_print` without suppressions, but package code still violates analyzer rules. |
| 2 | Lifecycle Safety | PARTIAL | `DSToastManagerState.dispose()` removes overlay and cancels timers at `packages/warp_prism_ui/lib/src/molecules/ds_toast_manager.dart:127-130`; timers are created at line `215`. However delayed removal after `dismiss()` mutates `_entries` without marking the overlay entry dirty at lines `181-189`, leaving stale overlay widgets possible when dismissing one toast from a multi-toast stack. |
| 3 | Dependency Direction | PASS | Modified toast files import Flutter, tokens, atoms, and the sibling toast renderer only: `ds_toast.dart:1-3`, `ds_toast_manager.dart:1-4`. No app-layer imports or reverse dependencies were introduced. |
| 4 | UI Accessibility | FAIL | `DSToast` has exactly 2 interactive widgets (`TextButton` at `ds_toast.dart:141`, `IconButton` at `ds_toast.dart:172`); both are descendants of the global `ExcludeSemantics` at `ds_toast.dart:55`, so their semantics are excluded. The dismiss target is explicitly `32x32` at `ds_toast.dart:170-171`, below the 48x48 dp minimum. |
| 5 | Proof Reality | FAIL | The task claims `Tests use fakeAsync or Timer mocks` at `docs/tasks/02-doing/1308-warp-prism-toast-async-lifecycle-stabilization.md:53`, but `ds_toast_test.dart` contains 0 `fakeAsync` references and 0 Timer mocks; timing is driven by `WidgetTester.pump(...)` at lines `427-429`. |
| 6 | Release Security | PASS | No secrets, API keys, network calls, `print()`, or `debugPrint()` were added in `ds_toast.dart` or `ds_toast_manager.dart`; imports are local/Flutter-only at `ds_toast.dart:1-3` and `ds_toast_manager.dart:1-4`. |

## Build-Gate Axiom Compliance

| # | Axiom | Status | Evidence |
|---|-------|--------|----------|
| 1 | Widget Lifecycle | PARTIAL | Counts: 0 `AnimationController`, 0 `ScrollController`, 0 `TextEditingController`, 0 `StreamSubscription`, 1 `Timer` creation (`ds_toast_manager.dart:215`), 6 explicit timer-cancel sites (`147`, `155`, `175`, `214`, `235`, `266`), 1 overlay creation (`254`), 1 overlay remove (`259`), 1 overlay dispose (`260`). Missing dirty mark after delayed removal at `181-189` is still an overlay lifecycle correctness gap. |
| 2 | Provider Scoping | PASS | No Riverpod providers or `ref.watch` / `ref.read` are used in the modified files. |
| 3 | Const Constructors | FAIL | Package analyzer reports `prefer_const_constructors` and `prefer_const_literals_to_create_immutables` info issues across `lib/`; modified task files are formatted, but the package-level axiom is not green. |
| 4 | Semantic Labels | FAIL | Counts: 2 interactive widgets in `DSToast`; 1 outer live-region `Semantics` (`ds_toast.dart:52-54`), 1 dismiss `Semantics` (`166-168`) that is under `ExcludeSemantics` (`55`), and 0 accessible semantics for the optional action `TextButton` at `141-159`. |
| 5 | Type Safety | PASS | No `dynamic`, unchecked `as`, or nullable force-unwraps were introduced in the modified toast files. `DSToastManager.of` retains an asserted `state!` at `ds_toast_manager.dart:99-101`, guarded by the preceding assert. |

## Warp Prism Checks

| Check | Status | Evidence |
|-------|--------|----------|
| Read-only contract | PASS | Toast changes are UI-only; no API, persistence, or mutation endpoint was added (`ds_toast_manager.dart:1-4`). |
| DS*/Prism* boundary | PASS | The package-internal component correctly uses `DS*` names under `packages/warp_prism_ui/lib/src/`; no app imports were introduced. |
| Mock workspace fixtures | N/A | Toast component does not consume workspace fixture data. |
| Melos package boundary | PASS | `packages/warp_prism_ui/` files do not import from `apps/`; imports are Flutter/package-local at `ds_toast.dart:1-3` and `ds_toast_manager.dart:1-4`. |
| Operational state vocabulary | N/A | Toast severity is notification severity, not ASW operational state; no operational-state booleans/strings were introduced. |
| Design token usage | PARTIAL | Colors, spacing, radii, typography use DS tokens (`ds_toast.dart:60-63`, `90-109`, `117-126`); touch-target sizing uses `DSSpacing.iconButtonSizeCompact = 32`, which violates the 48 dp accessibility minimum (`ds_spacing.dart:71`, `ds_toast.dart:170-171`). |
| Gallery coverage | N/A | This task modifies an existing toast component and did not introduce a new DS component. |
| Test coverage | PARTIAL | `ds_toast_test.dart` has 33 passing tests and covers severity, render, dismiss, auto-dismiss, clear, maxVisible, and replacement. It does not cover action callback execution or multi-toast delayed removal after dismiss. |

## Exit Conditions

| # | Condition | Met? | Evidence |
|---|-----------|------|----------|
| 1 | `ds_toast_test.dart` passes with zero failures. | PASS | `flutter test test/molecules/ds_toast_test.dart` returned `+33: All tests passed!`. |
| 2 | Tests use `fakeAsync` or `Timer` mocks for deterministic timing. | FAIL | `packages/warp_prism_ui/test/molecules/ds_toast_test.dart` contains exactly 0 `fakeAsync` references and 0 Timer mocks; auto-dismiss uses `tester.pump(const Duration(seconds: 1))` at line `427`. |
| 3 | No test depends on real wall-clock time. | PASS | The auto-dismiss test advances Flutter test time through `tester.pump(...)` at `ds_toast_test.dart:427-429`, not `Future.delayed` in the test body or real sleeps. |
| 4 | Toast state is properly reset between tests. | PASS | Each manager test pumps a fresh `DSToastManager` with a new `_ManagerTestHelper` key at `ds_toast_test.dart:388-390`, `413-415`, `436-438`, `462-464`, and `481-483`; no global manager state exists in `ds_toast_manager.dart:118-124`. |
| 5 | Local changelog entry added under `docs/changelog/`. | PASS | `docs/changelog/2026-06-09-toast-async-lifecycle-stabilization.md` exists and documents Task 1308. |
| 6 | Completion Evidence is filled before review handoff. | PASS | Completion Evidence is filled at `docs/tasks/02-doing/1308-warp-prism-toast-async-lifecycle-stabilization.md:125-147`. |

## Findings

### Critical

- None.

### High

- [HIGH] Package analyzer gate is red with exactly `467 issues found`; Axiom 1 requires zero warnings and zero info-level issues. The gate output includes at least one warning, `unused_local_variable` at `packages/warp_prism_ui/lib/src/organisms/split_pane/ds_split_pane.dart:223:15`, plus many info-level lint failures. Recommendation: clear the package analyzer baseline or formally classify pre-existing analyzer failures per the promotion-state model before claiming Ready For Review. — `flutter analyze lib/`, `analysis_options.yaml:5-7`

- [HIGH] Interactive toast controls are semantically excluded. `DSToast` has exactly 2 interactive widgets: optional `TextButton` at `packages/warp_prism_ui/lib/src/molecules/ds_toast.dart:141` and optional `IconButton` at line `172`. Both live below `ExcludeSemantics` at line `55`, so the action and dismiss controls are not exposed as interactive semantics. Recommendation: do not wrap the entire toast subtree in `ExcludeSemantics`; instead use `Semantics(container: true, liveRegion: true, label: ...)` for the announcement and `ExcludeSemantics` only around decorative icon/text pieces that must not duplicate the announcement. Keep separate semantics for action and dismiss controls. — `packages/warp_prism_ui/lib/src/molecules/ds_toast.dart:52-180`

- [HIGH] The explicit exit condition requiring `fakeAsync` or Timer mocks is unmet. The task marks it complete at `docs/tasks/02-doing/1308-warp-prism-toast-async-lifecycle-stabilization.md:53`, but the test file contains 0 `fakeAsync` references and 0 Timer mocks; auto-dismiss is tested by `tester.pump(const Duration(seconds: 1))` at `packages/warp_prism_ui/test/molecules/ds_toast_test.dart:427`. Recommendation: either wrap timer behavior in a testable clock/timer abstraction and assert with a Timer fake, or update the task contract through governance if `WidgetTester` fake time is accepted as the deterministic mechanism. — `packages/warp_prism_ui/test/molecules/ds_toast_test.dart:411-431`

### Medium

- [MEDIUM] Dismissing one toast from a multi-toast stack can leave stale overlay content because the delayed removal mutates `_entries` without marking the `OverlayEntry` dirty. The implementation marks the overlay dirty at dismiss start (`ds_toast_manager.dart:180`), then later removes the entry inside `Future.delayed` (`181-189`) but does not call `_overlayEntry?.markNeedsBuild()` after removal unless the stack becomes empty and `_removeOverlay()` runs. Recommendation: after the delayed `setState`, call `_overlayEntry?.markNeedsBuild()` when still mounted, and add a regression test that shows two toasts, dismisses one, advances `DSMotion.slow`, and asserts the dismissed toast is gone while the other remains. — `packages/warp_prism_ui/lib/src/molecules/ds_toast_manager.dart:181-189`

- [MEDIUM] The dismiss button violates the 48x48 dp minimum touch target. The button is constrained to exactly `32x32` via `DSSpacing.iconButtonSizeCompact` at `packages/warp_prism_ui/lib/src/molecules/ds_toast.dart:170-171`; the token is defined as `32` at `packages/warp_prism_ui/lib/src/tokens/ds_spacing.dart:71`. Recommendation: use at least `kMinInteractiveDimension` or `DSSpacing.iconButtonSize` only if raised to 48, while preserving visual compactness with internal padding. — `packages/warp_prism_ui/lib/src/molecules/ds_toast.dart:170-171`

- [MEDIUM] The optional action button has no dedicated interaction test. Tests verify the action label renders at `ds_toast_test.dart:229-247`, but no test taps the action and proves `onAction` fires or manager default action dismissal works. Recommendation: add a `DSToast` test that taps the `TextButton` and asserts the callback fires, plus a manager test proving action tap dismisses the corresponding toast. — `packages/warp_prism_ui/test/molecules/ds_toast_test.dart:229-247`, `packages/warp_prism_ui/lib/src/molecules/ds_toast_manager.dart:339-342`

- [MEDIUM] Protected governance files were modified outside the task `Where` table. `AGENTS.md` is explicitly protected (`AGENTS.md:72-80`), but Completion Evidence lists changes to `AGENTS.md` and `.gitignore` (`docs/tasks/02-doing/1308-warp-prism-toast-async-lifecycle-stabilization.md:135-137`) even though the task `Where` table only names toast files (`84-86`). The content is directionally compliant with workspace boundaries (`AGENTS.md:84-93`, `.gitignore:34-35`), but there is no task-local approval trail for changing a protected project contract. Recommendation: split those governance changes into their own governance task or append explicit approval/justification evidence to Task 1308 before review. — `AGENTS.md:72-93`, `.gitignore:34-35`

### Low

- [LOW] The changelog claims fake/timing stabilization broadly but does not disclose that no `fakeAsync` or Timer mock was added. Recommendation: update `docs/changelog/2026-06-09-toast-async-lifecycle-stabilization.md` to state the actual deterministic mechanism (`WidgetTester.pump` fake test time) or add the required fake timer proof first. — `docs/changelog/2026-06-09-toast-async-lifecycle-stabilization.md:46-51`

## Patches Applied

None. Score is below 90, so the workflow forbids reviewer patches.

## Path to 100

1. Clear or formally classify the `flutter analyze lib/` failure. For a true approval path, get package analysis to `0 issues found`; at minimum, use the promotion-state pre-existing-failure policy to prove all non-task analyzer issues are unrelated and tracked.
2. Fix toast semantics by removing the global `ExcludeSemantics` from around interactive children. Preserve a single live-region announcement for severity/title while exposing separate accessible action and dismiss controls.
3. Raise the dismiss touch target from `32x32` to at least `48x48` dp and add a widget test that measures the close button target size.
4. Satisfy the timing exit condition exactly: add `fakeAsync` / Timer-fake proof, or amend the task contract through governance to accept `WidgetTester.pump` fake test time as the deterministic timing mechanism.
5. Patch `DSToastManager.dismiss()` so the delayed removal marks the overlay dirty for non-empty stacks, then add a two-toast regression test proving one dismissed toast is fully removed while the remaining toast stays visible.
6. Add action-button interaction tests for direct `DSToast.onAction` and manager default action dismissal.
7. Resolve the protected-file scope drift: either move the `AGENTS.md` / `.gitignore` edits to a separate governance task or add explicit approval evidence and a `Where` table amendment for Task 1308.
8. Re-run, sequentially, from `packages/warp_prism_ui`: `flutter analyze lib/`, `dart format --set-exit-if-changed lib/ test/`, `flutter test test/molecules/ds_toast_test.dart` three times, `flutter test`, and `flutter test --coverage`.
