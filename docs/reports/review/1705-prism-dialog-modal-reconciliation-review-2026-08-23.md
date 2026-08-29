# Task 1705 Reconciliation Review — PrismDialog / PrismModal

> **Reviewer**: reviewers  
> **Date**: 2026-08-23  
> **Verdict**: **REJECT — score 84/100**  
> **Lane routing**: must move to `docs/tasks/02-doing/` (collision-safe destination required).

## Lineage

- Previous report: `docs/reports/review/1705-prism-dialog-modal-independent-review-2026-08-23.md` — withheld due to batch stop.
- This reconciliation does not repeat prior analyzer/test/gallery/boundary checks.

## Format drift ownership

`lib/src/molecules/dialog/ds_dialog.dart` and `test/molecules/dialog/ds_dialog_test.dart` are Task 1705-owned files. The non-mutating formatter snapshot proposes 9 and 8 hunks respectively. This drift is task-owned, not pre-existing unrelated drift. The shared gallery and aliases also remain part of the batch drift surface.

## Barrier dismissal targeted audit

`DSDialog.show` delegates to `showGeneralDialog` with:

```dart
barrierDismissible: barrierDismissible,
```

while `DSDialog.dismissible` only gates `_handleDismiss`, which is used by the close icon and Escape. The widget’s `dismissible` value is not automatically connected to the route barrier parameter. Therefore:

- `DSDialog(dismissible: true)` is barrier-dismissible only when the helper is called with its default `barrierDismissible: true`.
- `DSDialog(dismissible: false)` can still be shown through `showPrismDialog` with the helper’s default `barrierDismissible: true`, so a scrim tap can pop the route despite the widget flag.
- The existing 8/8 tests cover close icon, Escape, Enter, result, focus, and aliases, but do not prove scrim behavior or the false case.

This is a real contract mismatch, not merely an evidence omission.

## Other contract observations

- Public aliases and top-level helper are present.
- Focus scope/node are disposed.
- Escape/Enter handling and fade/scale animation are implemented.
- Actions use `DSButton`, inheriting 48dp interactive targets.
- Gallery includes small, medium, large, and fullscreen triggers.
- No dialog-specific golden test/baseline was found; task does not make a specific golden claim in its completion evidence.

## Score

| Dimension | Result |
| --- | ---: |
| Local implementation | 86 |
| Runtime/public enforcement | 82 |
| **Overall** | **84** |

### Score rationale

Strong local implementation and prior behavioral coverage, but barrier dismissal is not fail-closed relative to `DSDialog.dismissible`. The missing true/false scrim proof compounds the semantic mismatch. Task-owned format drift remains unresolved.

## Required path to 100

1. Make the route barrier behavior derive from the same dismissible contract, or explicitly separate/document route barrier policy.
2. Add tests for scrim dismissal true and false.
3. Format Task 1705 files through the authorized builder path and coordinate shared surfaces.
4. Re-run the non-mutating format probe and re-review.
