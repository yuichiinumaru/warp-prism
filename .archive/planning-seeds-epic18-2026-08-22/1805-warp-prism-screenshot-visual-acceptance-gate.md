# Task 1805 — Screenshot Visual Acceptance Gate and Golden Policy

> **Planning Status**: Proposed — executable after Task 1803 and Task 1804
> **Priority**: P0
> **Type**: visual QA/governance
> **Parent**: EPIC-18
> **Depends on**: Tasks 1803, 1804
> **Blocks**: Task 1806 and visual task promotion

## Objective

Make visual correctness a real release gate rather than inferring it from analyzer/tests
or updating goldens until snapshots become green.

## Canonical Evidence

Capture deterministic screenshots for:

- `apps/catalog` gallery home and representative sections;
- Observatory shell/dashboard;
- CyberCore shell with its explicit product skin;
- typography specimen and token swatches;
- at least one dense organism and one form primitive.

The canonical target screenshot must be approved by the product/user owner before golden
files are refreshed.

## Review Checklist

- background is black obsidian, not blue;
- surfaces are neutral near-black with restrained elevation;
- blue is controlled to action/focus/highlight roles;
- semantic green/amber/red remain meaningful;
- no excessive teal/green/rainbow chrome;
- no persistent high-intensity blue ambient glow;
- UI typography is readable and non-mono where appropriate;
- JetBrains Mono appears only in technical roles;
- contrast and focus states remain accessible;
- layout/density match approved reference intent;
- Catalog and app hosts render the same theme contract.

## Acceptance Criteria

- [ ] Screenshot capture command and environment are documented and reproducible.
- [ ] Human-approved target artifact is linked.
- [ ] Reviewer report contains before/after comparison and explicit pass/fail per checklist.
- [ ] Goldens are refreshed only after approval.
- [ ] Golden tests pass after refresh.
- [ ] A visual mismatch cannot be waived merely because unit tests pass.
- [ ] Rejected visual output remains available for diagnosis; it is not overwritten.
