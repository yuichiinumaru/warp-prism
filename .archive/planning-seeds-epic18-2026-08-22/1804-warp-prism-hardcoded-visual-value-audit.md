# Task 1804 — Hardcoded Visual-Value and Structural-Color Audit

> **Planning Status**: Proposed — executable after Task 1801 token contract approval
> **Priority**: P1
> **Type**: audit/remediation
> **Parent**: EPIC-18
> **Depends on**: Task 1801
> **Blocks**: Task 1805

## Objective

Find and reconcile component-level colors that bypass the visual token contract. Preserve
meaningful fixture/data colors, but remove arbitrary structural backgrounds, borders,
accent fills, and ambient glows.

## Audit Command Shape

```bash
rg -n "Color\\(0x|Colors\\.(green|teal|cyan|blue|pink|orange|purple)|backgroundColor:|BoxShadow" \
  packages/warp_prism_ui/lib apps/catalog/lib apps/observatory/lib apps/cybercore/lib
```

Each match must be classified as:

1. approved semantic token;
2. status/data visualization mapping;
3. transparent/overlay implementation detail;
4. fixture-only color;
5. structural violation requiring remediation.

## Acceptance Criteria

- [ ] Audit report lists every reviewed structural-color finding with file and line.
- [ ] Structural violations are replaced by approved semantic tokens.
- [ ] Fixture/data category colors remain only when documented and distinguishable.
- [ ] No component introduces blue/teal/green as an unapproved structural fill.
- [ ] No persistent ambient blue glow or scanline decoration is added.
- [ ] Scoped tests and analyzer pass after remediation.
- [ ] Report identifies intentionally retained raw values and why they are safe.
