# Task 1707 Reconciliation Review — PrismAccordion / PrismCollapsible

> **Reviewer**: reviewers  
> **Date**: 2026-08-23  
> **Verdict**: **REJECT — score 87/100**  
> **Lane routing**: must move to `docs/tasks/02-doing/` (collision-safe destination required).

## Lineage

- Previous report: `docs/reports/review/1707-prism-accordion-collapsible-independent-review-2026-08-23.md` — withheld due to batch stop.
- Task-local builder ledger claimed 91/100 then 100/100; those claims are superseded for acceptance by this independent reconciliation score.
- Previously captured analyzer/test/gallery/boundary checks are not repeated.

## Format drift ownership

`lib/src/molecules/accordion/ds_accordion.dart` and `test/molecules/accordion/ds_accordion_test.dart` are Task 1707-owned. The non-mutating formatter snapshot proposes 10 and 18 hunks respectively. The implementation/test drift is task-owned, not unrelated pre-existing drift.

## Effective 48dp header audit

The header content itself uses:

```dart
BoxConstraints(minHeight: 32)
```

at `ds_accordion.dart:332-334`, but it is wrapped by `DSInteractiveSurface`, whose interactive `ConstrainedBox` enforces `minWidth: 48, minHeight: 48`. Thus the effective tappable header target is at least 48dp even though the inner content constraint is 32px. This is acceptable for target-size compliance, but the task explicitly specifies a 48px section-header height and no direct rendered-size test exists.

## Gallery variant audit

The gallery’s accordion sample includes:

- one default-open section;
- two ordinary sections;
- one disabled section;
- one null-content empty section.

It does **not** independently demonstrate or assert a two-open multi-expand variant in the inspected gallery block. The widget tests prove multi-expand behavior, but that is not gallery registration proof. The task completion claim therefore overstates gallery variant coverage.

## Other contract observations

- Prism aliases are present.
- Controlled/uncontrolled expansion is implemented.
- Callback sets, empty fallback, dividers, glass wrapping, rotation and size animation have broad test coverage.
- Semantics includes expanded/disabled/button state.
- Lifecycle is state-only; no owned controllers requiring disposal.

## Score

| Dimension | Result |
| --- | ---: |
| Local implementation | 91 |
| Runtime/gallery enforcement | 84 |
| **Overall** | **87** |

### Score rationale

The implementation is robust and test-rich. Acceptance is held below 90 by task-owned format drift, missing direct effective-header-size proof, and incomplete gallery demonstration of the requested multi-expand-two-open variant. No critical lifecycle issue was found.

## Required path to 100

1. Add a rendered header-size assertion proving ≥48dp.
2. Add a gallery multi-expand demo with two sections initially open and a gallery assertion for it.
3. Format Task 1707 source/test through the authorized builder path.
4. Re-run the non-mutating format probe and re-review.
