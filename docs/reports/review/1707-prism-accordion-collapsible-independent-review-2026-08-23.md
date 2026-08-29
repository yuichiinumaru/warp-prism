# Task 1707 Review Packet — PrismAccordion / PrismCollapsible Molecule

> **Reviewer**: reviewers  
> **Date**: 2026-08-23  
> **Verdict**: **NOT SCORED — batch stopped on Task 1704 format-gate failure**  
> **Score**: **Withheld** (no invented score)  
> **Lane routing**: no routing decision made.

## Review lineage

The task-local ledger claims an earlier 91/100 builder pass and a later builder re-review at 100/100. Those claims are recorded as prior lineage only; no independent score is substituted here.

## Evidence captured before the stop

```text
dart analyze lib/src/molecules/accordion/ test/molecules/accordion/
No issues found!

flutter test test/molecules/accordion/ --concurrency=1 --no-pub
00:13 +17: All tests passed!
```

Shared wave evidence captured before the stop:

```text
flutter test test/gallery/ --concurrency=1 --no-pub
01:34 +22: All tests passed!

dart run melos run test-boundaries
Checks: 7/7 PASS
```

The mandatory non-mutating format probe then failed across the batch/shared surfaces before an independent 1707 score could be issued:

```text
dart format --output=none --set-exit-if-changed [1704–1707 files + shared touched files]
Changed ... 10 files
Formatted 19 files (10 changed)
```

Per the user stop-on-failure instruction, no commands were run after the red format gate.

## Contract observations captured before stop

- `DSAccordion` and aliases `PrismAccordion`, `PrismAccordionItem`, `PrismAccordionSection` are present.
- Uncontrolled and controlled expansion, default-open, single/multi-expand, disabled, empty content/list fallback, divider and glass options, callback emission, `AnimatedRotation`, and `AnimatedSize` are implemented.
- Headers compose `DSInteractiveSurface`; interactive targets inherit 48x48 constraints and keyboard/focus behavior.
- Region/header semantics is explicit and includes `expanded`, `disabled`, and button state.
- 17 accordion tests passed, including animation destination turns and optional public API surfaces.

## Evidence gaps / potential contract drift (not scored)

### Header visual minimum height is only 32px

`_DSAccordionSectionWidget` adds `BoxConstraints(minHeight: 32)` at `ds_accordion.dart:332-334`. The outer `DSInteractiveSurface` supplies a minimum 48x48 interactive constraint, so the effective tappable target may still be 48dp, but the task explicitly documents a 48px section-header height. Independent review should measure the rendered header and verify that target contract rather than relying only on the shared wrapper.

### Gallery proof should be independently checked for all requested variants

The task requires closed, open, multi-expand with two open, icon, and disabled variants. Gallery tests passed globally, but no task-specific independent assertion was run before the stop.

## Required closeout after batch restart

1. Repair only the reported format drift.
2. Re-run accordion analyzer, tests, gallery, boundary harness, and non-mutating format probe.
3. Add/inspect a rendered-size assertion for accordion header targets and verify gallery variants.
4. Issue an independent numeric score only after the mandatory gate is green.
