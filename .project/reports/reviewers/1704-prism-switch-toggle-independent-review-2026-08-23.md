# Task 1704 Review — PrismSwitch / PrismToggle Atom

> **Reviewer**: reviewers  
> **Date**: 2026-08-23  
> **Verdict**: **BLOCKED — mandatory non-mutating format gate failed**  
> **Score**: **Not scored** (numeric score would be invented while the required gate is red)  
> **Lane routing**: unchanged; no numeric routing decision made.

## Review lineage

Initial independent review. No prior reviewer report was found for Task 1704.

## Live evidence before stop

Scoped analyzer and tests were independently re-run:

```text
dart analyze lib/src/atoms/switch/ test/atoms/switch/
No issues found!

flutter test test/atoms/switch/ --concurrency=1 --no-pub
00:05 +9: All tests passed!
```

The package gallery and boundary harness were also run before the format probe:

```text
flutter test test/gallery/ --concurrency=1 --no-pub
00:01:34 +22: All tests passed!

dart run melos run test-boundaries
Checks: 7/7 PASS
```

The required non-mutating format probe then failed:

```text
dart format --output=none --set-exit-if-changed [Task 1704 files + shared touched files]
Changed lib/src/atoms/switch/ds_switch.dart
Changed lib/src/molecules/dialog/ds_dialog.dart
Changed lib/src/molecules/accordion/ds_accordion.dart
Changed lib/src/organisms/breadcrumbs/ds_breadcrumbs.dart
Changed lib/src/prism_aliases.dart
Changed lib/src/gallery/design_system_gallery_sections.dart
Changed test/atoms/switch/ds_switch_test.dart
Changed test/molecules/dialog/ds_dialog_test.dart
Changed test/molecules/accordion/ds_accordion_test.dart
Changed test/organisms/breadcrumbs/ds_breadcrumbs_test.dart
Formatted 19 files (10 changed)
```

The probe was invoked with `--output=none`; no formatter write was authorized. Per the stop-on-failure instruction, no further commands or repairs were run after this red gate.

## Contract audit observed before stop

- `DSSwitch` is implemented and `PrismSwitch` is present at `lib/src/prism_aliases.dart:1135-1136`.
- `DSSwitch` composes `DSInteractiveSurface`, whose interactive path provides keyboard Enter/Space, focus ring, and a 48x48 minimum target.
- `AnimatedContainer` + `AnimatedAlign` use `DSMotion.normal`.
- 9 scoped switch tests pass, including Space/Enter, disabled behavior, 48x48 size, alias behavior, and skin accent.
- Gallery switch demo is present at `design_system_gallery_sections.dart:337-340` and `6687-6737`.

## Findings

### HIGH — Required `PrismToggle` public contract is absent

- **Evidence**: repository search found no `PrismToggle` or `DSToggle` declaration. The task objective explicitly requires `PrismSwitch / PrismToggle`; the implementation and aliases provide only `DSSwitch` / `PrismSwitch`.
- **Impact**: consumers asking for the documented toggle name cannot compile. This is a public API completeness failure, independent of passing `DSSwitch` tests.
- **Required fix**: add the documented compatibility alias (`typedef PrismToggle = DSSwitch;`, or a clearly documented equivalent) and public-barrel proof test. If `PrismToggle` is intentionally rejected, amend the task contract before accepting it.

### HIGH — Completion claim for goldens is ungrounded

- **Evidence**: Task claims “Widget tests + goldens pass” and `melos run golden` passes, but the task-specific test tree contains only `test/atoms/switch/ds_switch_test.dart` and the redirect; no switch golden test or switch golden PNG was found. The scoped test run produced 9 widget tests, not golden evidence.
- **Impact**: visual acceptance is phantom evidence. Existing repository golden freeze policy also requires honest classification rather than asserting a missing suite passed.
- **Required fix**: either add deterministic switch golden tests/baselines under the approved golden policy, or correct Completion Evidence to say no switch golden was run/deferred and link the governing task.

### BLOCKING EVIDENCE — Non-mutating format gate is red

- **Evidence**: 10 touched/shared Dart files were reported as changed by the format probe. No score can be assigned under this batch’s stop-on-failure instruction.

## Required closeout

1. Resolve the format drift without broad unrelated formatting.
2. Add or explicitly defer `PrismToggle` with a contract decision.
3. Replace phantom golden claim with actual proof or an honest deferred note.
4. Re-run analyzer, switch tests, gallery, boundary harness, and the same non-mutating format probe. Only then can an independent numeric score be assigned.
