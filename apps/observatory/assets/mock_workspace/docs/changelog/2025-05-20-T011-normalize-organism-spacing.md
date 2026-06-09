---
id: 2025-05-20-T011-normalize-organism-spacing
date: 2025-05-20
project: asw-observatory
task: T011
type: remediation
impact:
  - design-system
  - spacing
  - consistency
skills:
  - design-system-harness
  - frontend-quality-harness
---

# Organism spacing normalized to tokens

## Why

Organisms like `DSLaneBoard`, `DSStoryPanel`, and `DSDetailInspector` used hardcoded padding and margin values (16.0, 12.0, 8.0) instead of the `DSSpacing` token class. This made spacing inconsistent and prevented global adjustments.

## Changed

- Audited all 9 organisms for hardcoded spacing values.
- Replaced 47 hardcoded literals with `DSSpacing.xs`, `DSSpacing.sm`, `DSSpacing.md`, `DSSpacing.lg`, `DSSpacing.xl` tokens.
- Added `DSSpacing.sectionGap` and `DSSpacing.cardGap` semantic tokens for common patterns.
- Verified no visual regression by comparing before/after layouts at all three breakpoints.

## Evidence

- `assets/mock_workspace/docs/tasks/02-doing/T011-normalize-ds-organism-spacing-tokens.md` defines the normalization scope.
- `lib/design_system/tokens/ds_spacing.dart` (72 lines) defines the token class.
