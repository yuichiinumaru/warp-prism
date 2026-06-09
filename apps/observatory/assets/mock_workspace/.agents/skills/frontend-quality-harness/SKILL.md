---
name: frontend-quality-harness
description: Design system compliance, UI component quality, accessibility verification, and frontend-specific quality gates.
triggers:
  - design system check
  - component review
  - accessibility audit
  - ui quality gate
  - visual regression
sub_skills:
  - component-quality
  - accessibility-check
  - design-token-compliance
  - visual-consistency
canonicality: parentCanonical
tags:
  - frontend
  - ui
  - design-system
  - accessibility
---

# frontend-quality-harness

## Purpose

Ensures frontend code meets design system standards, accessibility requirements, and component quality gates. Validates that UI components compose tokens, atoms, molecules, and organisms correctly.

## Quality Gates

1. **Token compliance**: Uses design tokens, not hardcoded values
2. **Atomic composition**: Composes from atoms/molecules/organisms
3. **Accessibility**: Keyboard navigation, contrast, focus states
4. **Visual consistency**: Matches design system patterns

## When To Use

- Reviewing frontend code changes
- Validating design system component additions
- Running accessibility audits
- Checking visual consistency across screens

## Sub-Skills

- `component-quality`: Component structure and composition checks
- `accessibility-check`: WCAG compliance and keyboard navigation
- `design-token-compliance`: Token usage validation
- `visual-consistency`: Cross-component visual alignment
