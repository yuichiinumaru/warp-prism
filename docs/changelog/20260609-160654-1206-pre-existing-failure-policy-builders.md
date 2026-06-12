---
date: 20260609-160654
timestamp: 20260609-160654
project: ganthritor
agent: builders
task: "1206"
description: "Pre-existing failure classification policy created"
is_rebuild_safe: true
---

# Task 1206: Pre-existing Failure Classification Policy

## Summary

Created `docs/governance/pre-existing-failure-policy.md` to formalize how
pre-existing test failures are classified and handled during task promotion.
Updated `.agents/rules/promotion-state-model.md` to reference the new policy.

## Changes

- **Created**: `docs/governance/pre-existing-failure-policy.md` — full policy
  with classification decision tree, promotion rules, evidence requirements,
  reviewer checklist, anti-gaming rules, and current baseline reference
  (64 Observatory pre-existing failures, 24 UI wave4-regressions).
- **Modified**: `.agents/rules/promotion-state-model.md` — added references
  to the pre-existing failure policy in Rule 2, Failure Taxonomy table, and
  Reference section.

## Verification

- `test -f docs/governance/pre-existing-failure-policy.md` → PASS
- `grep "pre-existing" .agents/rules/promotion-state-model.md` → 5 matches
  (Rule 2, taxonomy row, reference link) → PASS
