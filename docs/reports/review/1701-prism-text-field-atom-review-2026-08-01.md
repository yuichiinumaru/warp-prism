# Independent Adversarial Review — Task 1701 PrismTextField Atom

- **Reviewer**: reviewers
- **Date**: 2026-08-01
- **Task**: `docs/tasks/03-review/1701-warp-prism-prism-text-field-atom.md`
- **Report**: this file
- **Score**: **85/100**
- **Verdict**: **REJECT — route to `02-doing`**

## Scope and Evidence

Live implementation inspected:
- `packages/warp_prism_ui/lib/src/atoms/text_field/ds_text_field.dart`
- `packages/warp_prism_ui/lib/src/atoms/text_field/text_field.dart`
- `packages/warp_prism_ui/lib/src/atoms/atoms.dart`
- `packages/warp_prism_ui/lib/src/prism_aliases.dart`
- `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart`
- `packages/warp_prism_ui/test/atoms/text_field/ds_text_field_test.dart`

`PrismTextField = DSTextField` is present and the atom is exported through the atoms barrel. The source owns an internal `TextEditingController` and `FocusNode` when callers do not provide them, while leaving caller-owned resources undisposed. Interactive suffixes use a 48×48 `SizedBox` and are semantically labeled.

## Live Commands

```text
dart format --output=none --set-exit-if-changed \
  lib/src/atoms/button lib/src/atoms/text_field lib/src/molecules/select \
  lib/src/atoms/checkbox test/atoms/button test/atoms/text_field \
  test/molecules/select test/atoms/checkbox
→ formatter reported 8 changed files (non-mutating check requested; no golden/update flag used).

dart analyze lib/src/atoms/text_field test/atoms/text_field
→ No issues found!

flutter test test/atoms/text_field/ --concurrency=1 --no-pub
→ Runtime failure. 15 non-golden tests passed; all 3 golden tests failed.
→ Failures: text_field_default, text_field_error, text_field_disabled.
→ Pixel diffs ranged from 99.08% to 99.76% (up to 478,830 pixels).
```

The review stopped at this runtime failure as required. Boundary and gallery commands were **not** run after the failure; no boundary pass is claimed.

## Axiom Compliance

| Axiom | Status | Evidence |
|---|---|---|
| Analyzer integrity | PASS | Task-scoped analyzer returned no issues. |
| Lifecycle safety | PASS | Internal controller/focus resources are disposed; external resources are not disposed. Focus listeners are removed during widget updates/disposal. |
| Dependency direction | UNVERIFIED | Local imports are appropriate, but boundary harness was not run after the runtime gate. |
| 48dp semantics | PARTIAL | Interactive suffix has an explicit 48×48 box. The main text field is a native editable control with a 48dp minimum-height container, but no dedicated whole-field 48×48 semantics regression is present. |
| Focus/keyboard | PARTIAL | Focus acquisition and text submission tests pass. No explicit keyboard activation/semantic test exists for the interactive suffix action. |
| Controller lifecycle | PASS with residual risk | Internal resources are paired; external resource ownership is respected. |
| Gallery/tests | FAIL | Gallery source includes default/focus/error/disabled/multiline/password examples, but all three required golden assertions fail. |
| Release safety | PASS | No network, key, persistence, or debug output path found. |

## Findings

### F-A1 — Required golden suite is red (HIGH)

All three golden assertions fail with near-total diffs. The task's completion evidence claims these goldens pass, but the live suite disproves that claim. The builder must reconcile baseline image location/content before any promotion.

The test references `../../goldens/text_field_*.png` from `test/atoms/text_field/ds_text_field_test.dart`, resolving to `test/goldens/`, while the task evidence describes generated goldens in a task-local area. Do not solve this by silently updating goldens; establish the intended committed baseline path and rerun without update flags.

### F-A2 — Interactive suffix lacks a keyboard-focus proof (MODERATE)

`_InteractiveSuffixIcon` exposes `Semantics(button: true)` and an `InkWell`, but no explicit `FocusNode`/`FocusableActionDetector` or keyboard activation test. The task mandates focus/keyboard behavior as part of the atom review. A screen-reader semantic action may work, but keyboard-tab/Enter behavior is not proven by the current suite.

### F-A3 — Formatter check reports changed files (LOW)

The requested non-mutating format check reported eight files as changed. The builder must establish a clean formatter result after remediation.

## Path to 100

1. Reconcile and pass all three text-field goldens without `--update-goldens` in review evidence.
2. Add a 48×48 render-box and semantics test for the main field and suffix action.
3. Give interactive suffix actions deterministic keyboard focus/Enter activation, or document and test the intended semantics-only contract.
4. Run boundaries and gallery tests only after scoped tests pass.
5. Rerun the formatter check and analyzer with clean output, then provide fresh evidence.
