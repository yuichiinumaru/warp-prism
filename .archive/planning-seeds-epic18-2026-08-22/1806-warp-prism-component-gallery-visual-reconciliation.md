# Task 1806 — Component and Gallery Visual Reconciliation

> **Planning Status**: Proposed — executable after Task 1805 approval
> **Priority**: P1
> **Type**: component visual remediation
> **Parent**: EPIC-18
> **Depends on**: Task 1805
> **Scope**: Existing components only; no new feature expansion

## Objective

Reconcile existing Warp Prism components and gallery sections with the approved
black-obsidian visual contract after shared tokens, typography, and app themes are stable.
Preserve behavior and accessibility while removing visual drift.

## Review Families

- EPIC-15 organisms: HUD, map, OSINT, stage chrome, panels;
- EPIC-16 organisms: page shell, tree, transcript, artifacts, provider health;
- EPIC-17 atoms/molecules: buttons, text fields, selects, checkboxes, switches, dialogs,
  breadcrumbs, accordions;
- legacy shell, sidebar, gallery framing, panels, cards, and status surfaces.

## Per-Component Checks

- structural backgrounds/surfaces use tokens;
- borders/glows use semantic tokens;
- primary blue is not used as a structural fill;
- teal is not required outside an explicit CyberCore skin;
- status colors retain their meaning;
- typography role is correct;
- focus/hover/disabled states remain accessible;
- no raw value was introduced to compensate for a bad global theme.

## Acceptance Criteria

- [ ] Every reviewed component family has a visual reconciliation matrix.
- [ ] Catalog screenshot passes Task 1805 checklist.
- [ ] Existing behavior/accessibility tests remain green.
- [ ] New or changed goldens link to the approved screenshot evidence.
- [ ] No broad find/replace changed semantic status colors incorrectly.
- [ ] Reviewer scores each component family individually and records residual debt.
