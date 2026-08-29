# Task 1705 Review Packet — PrismDialog / PrismModal Molecule

> **Reviewer**: reviewers  
> **Date**: 2026-08-23  
> **Verdict**: **NOT SCORED — batch stopped on Task 1704 format-gate failure**  
> **Score**: **Withheld** (no invented score)  
> **Lane routing**: no routing decision made.

## Review lineage

No durable independent reviewer report was found. Task-local text records a prior builder review/re-review claim; that claim was not promoted to an independent score here.

## Evidence captured before the stop

```text
dart analyze lib/src/molecules/dialog/ test/molecules/dialog/
No issues found!

flutter test test/molecules/dialog/ --concurrency=1 --no-pub
00:10 +8: All tests passed!
```

Shared wave evidence captured before the stop:

```text
flutter test test/gallery/ --concurrency=1 --no-pub
01:34 +22: All tests passed!

dart run melos run test-boundaries
Checks: 7/7 PASS
```

The mandatory non-mutating format probe was then run across all four NOVA batch surfaces and shared touched files. It failed before any Task 1705 score could be issued:

```text
dart format --output=none --set-exit-if-changed [1704–1707 files + shared touched files]
Changed ... 10 files
Formatted 19 files (10 changed)
```

Per the user stop-on-failure instruction, no remediation or follow-up validation was performed after this red gate.

## Contract observations captured before stop

- `DSDialog` is implemented in `lib/src/molecules/dialog/ds_dialog.dart` and exported by `dialog.dart` and `molecules.dart`.
- `PrismDialog`, `PrismDialogAction`, `PrismDialogSize`, and `showPrismDialog` are exposed through `prism_aliases.dart`.
- `showGeneralDialog` uses a 0.7 scrim and `DSMotion.normal`; the modal uses fade + scale 0.95→1.0.
- `FocusScopeNode` and `FocusNode` are owned and disposed; post-frame autofocus is guarded by `mounted`.
- `DSButton` and `DSInteractiveSurface` provide 48dp target/focus/keyboard behavior.
- 8 dialog tests passed, including title/content/actions, result return, close icon, Escape, Enter, focus loop, and alias.

## Evidence gaps / potential contract drift (not scored)

### Barrier dismissal is not independently proven and may not honor `DSDialog.dismissible`

`DSDialog.dismissible` gates `_handleDismiss`, but `DSDialog.show` separately defaults `barrierDismissible: true`. A route opened with the helper can therefore dismiss on barrier tap even when the built `DSDialog` has `dismissible: false`, unless callers manually pass `barrierDismissible: false`. The task contract states `dismissible` controls “ESC + barrier tap closes.” The existing tests cover close icon and Escape but do not tap the scrim or exercise `dismissible: false`.

This requires a fresh focused test and contract decision after the format gate is repaired; it is not converted to a numeric finding because the batch was stopped before scoring.

### Golden claim is not independently grounded

The task does not provide a dialog-specific golden suite or baseline in the reviewed test tree. Its internal review says widget-property/interaction proof is sufficient, but the completion wording should not imply golden proof unless the governing golden policy explicitly defers it.

## Required closeout after batch restart

1. Repair only the reported format drift.
2. Add focused barrier-tap tests for `dismissible: true` and `dismissible: false`, or document a route-level API decision.
3. Re-run dialog analyzer, tests, gallery, boundary harness, and non-mutating format probe.
4. Issue an independent numeric score only after the mandatory gate is green.
