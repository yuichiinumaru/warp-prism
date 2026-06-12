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

Created `.agents/rules/pre-existing-failure-policy.md` as the short
builder-facing source rule and kept `docs/governance/pre-existing-failure-policy.md`
as the canonical governance policy. Updated
`.agents/rules/promotion-state-model.md` and `docs/governance/promotion-state-model.md`
to reference both surfaces, and reconciled Task 1206 to use the actual baseline
path `docs/reports/warp-prism-test-failure-baseline.md`.

## Changes

- **Created**: `.agents/rules/pre-existing-failure-policy.md` — short builder-facing source rule with teeth: unrelated pre-existing failures do not block, related pre-existing failures block unless explicitly justified by the reviewer, and caused regressions always block.
- **Created**: `docs/governance/pre-existing-failure-policy.md` — full canonical policy with classification decision tree, promotion rules, evidence requirements, reviewer checklist, anti-gaming rules, and current baseline reference (64 Observatory pre-existing failures, 24 UI wave4-regressions).
- **Modified**: `.agents/rules/promotion-state-model.md` — added references to the builder source rule and canonical policy in Rule 2, Failure Taxonomy table, and Reference section.
- **Modified**: `docs/governance/promotion-state-model.md` — added matching canonical references to the builder source rule and canonical policy.
- **Modified**: `docs/tasks/02-doing/1206-warp-prism-pre-existing-failure-classification-policy.md` — reconciled Where table, validation commands, status metadata, and completion evidence; no lane move performed.

## Verification

- `cat .agents/rules/pre-existing-failure-policy.md` → PASS; builder source rule exists and is readable.
- `grep -n "pre-existing" .agents/rules/promotion-state-model.md` → PASS; Rule 2, Failure Taxonomy row, and Reference section reference the source rule and canonical policy.
- `grep -n "pre-existing" docs/governance/promotion-state-model.md` → PASS; canonical governance reference is aligned with the builder source rule.
- `test -f .agents/rules/pre-existing-failure-policy.md` → PASS (exit 0; no stdout).
- `test -f docs/governance/pre-existing-failure-policy.md` → PASS (exit 0; no stdout).
- `test -f docs/reports/warp-prism-test-failure-baseline.md` → PASS (exit 0; no stdout).
- `dart format --set-exit-if-changed docs/governance/pre-existing-failure-policy.md .agents/rules/pre-existing-failure-policy.md .agents/rules/promotion-state-model.md` → N/A applicability probe because all three inputs are Markdown; exact tool output recorded in Task 1206 completion evidence.
