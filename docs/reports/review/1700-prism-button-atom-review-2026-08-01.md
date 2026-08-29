# Independent Adversarial Review — Task 1700 PrismButton Atom

- **Reviewer**: reviewers
- **Date**: 2026-08-01
- **Task**: `docs/tasks/03-review/1700-warp-prism-prism-button-atom.md`
- **Report**: this file
- **Score**: **84/100**
- **Verdict**: **REJECT — route to `02-doing`**

## Scope and Evidence

Live implementation inspected:
- `packages/warp_prism_ui/lib/src/atoms/button/ds_button.dart`
- `packages/warp_prism_ui/lib/src/atoms/button/button.dart`
- `packages/warp_prism_ui/lib/src/atoms/atoms.dart`
- `packages/warp_prism_ui/lib/src/prism_aliases.dart`
- `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart`
- `packages/warp_prism_ui/test/atoms/button/ds_button_test.dart`

Current public aliases are present: `PrismButton`, `PrismButtonVariant`, and `PrismButtonSize`. The implementation composes `DSInteractiveSurface` and does not use Flutter `ElevatedButton`, `TextButton`, or `OutlinedButton` as its base. `DSInteractiveSurface` supplies Enter/Space activation, focus-ring behavior, and a 48×48 minimum for interactive surfaces.

## Live Commands

```text
dart format --output=none --set-exit-if-changed \
  lib/src/atoms/button lib/src/atoms/text_field lib/src/molecules/select \
  lib/src/atoms/checkbox test/atoms/button test/atoms/text_field \
  test/molecules/select test/atoms/checkbox
→ formatter reported 8 changed files (non-mutating check requested; no golden/update flag used).

dart analyze lib/src/atoms/button test/atoms/button
→ No issues found!

flutter test test/atoms/button/ --concurrency=1 --no-pub
→ Runtime failure. 9 non-golden tests passed; all 7 golden tests failed.
→ Failures: button_primary, button_secondary, button_outline, button_ghost,
  button_danger, button_disabled, button_loading.
→ Pixel diffs ranged from 99.55% to 100.00% (up to 479,999 pixels).
```

The review stopped at this runtime failure as required. Boundary and gallery commands were **not** run after the failure; no boundary pass is claimed.

## Axiom Compliance

| Axiom | Status | Evidence |
|---|---|---|
| Analyzer integrity | PASS | Task-scoped analyzer returned no issues. |
| Lifecycle safety | PASS | Button accepts an optional external `FocusNode`; it does not allocate a controller or subscription. `DSInteractiveSurface` owns no externally visible lifecycle resource. |
| Dependency direction | UNVERIFIED | Source imports are directionally appropriate, but the boundary harness was not run because the runtime failure gate stopped validation. |
| 48dp semantics | PASS (unit proof) | `DSInteractiveSurface` enforces `minWidth/minHeight: 48` for interactive buttons, and the test checks both dimensions. |
| Focus/keyboard | PASS (unit proof) | Enter and Space tests pass; focus-ring test passes. |
| Gallery/tests | FAIL | Gallery source contains `_ButtonDemo`; scoped widget suite has 7 failing golden assertions. |
| Release safety | PASS | No network, key, persistence, or debug output path found in the inspected module. |

## Findings

### F-A1 — Required golden suite is red (HIGH)

All seven golden assertions fail with near-total image diffs. This directly violates the task's golden-test exit condition and invalidates the completion evidence claiming all seven goldens pass.

The test references `../../goldens/button_*.png` from `test/atoms/button/ds_button_test.dart`, which resolves to `test/goldens/`. The task evidence instead says goldens were generated under `test/atoms/button/goldens/`; the live failure is consistent with stale, misplaced, or mismatched baselines. This must be reconciled rather than bypassed with `--update-goldens` during review.

### F-A2 — Formatter check reports changed files (LOW)

The requested non-mutating format check reported eight files as changed. No formatting remediation was authorized in this review; the builder must rerun the exact check after resolving the golden failure and confirm a clean result.

## Path to 100

1. Reconcile golden test paths and committed baseline images; rerun `flutter test test/atoms/button/ --concurrency=1 --no-pub` without updating goldens.
2. Add/retain explicit semantic assertions for disabled/loading states and confirm the 48×48 render box in the public alias path.
3. Run boundary and gallery tests only after the scoped suite is green.
4. Rerun the non-mutating formatter check and task-scoped analyzer.
5. Return the task to review only with fresh, command-captured evidence.
