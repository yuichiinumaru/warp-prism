---
date: 20260709-000000
timestamp: 20260709-000000
project: warp-prism
agent: builders
task: "1207"
description: "Add explicit review-packet-template path to promotion-state-model"
is_rebuild_safe: true
---

# Task 1207: Review Packet Generator — Template Path Pointer

## Summary

Remediated Task 1207 after independent re-review rejection (score 86/100).
The promotion state model required review packets generically but did not name
the canonical template path, so the task exit condition and validation greps
could not prove discoverability of `docs/tasks/review-packet-template.md`.

## Changes

- **`.agents/rules/promotion-state-model.md`** — Rule 5 now points builders to
  `docs/tasks/review-packet-template.md` and
  `.agents/workflows/generate-review-packet.md`. Reference list includes both.
- **`docs/governance/promotion-state-model.md`** — Rule 5 and §7 References
  aligned with the same explicit template path.
- **`docs/tasks/02-doing/1207-warp-prism-review-packet-generator.md`** —
  Strengthened Validation Commands to exact-path greps; appended 2026-07-09
  path-to-100 evidence and review ledger entry.

## Verification

- `test -f docs/tasks/review-packet-template.md && echo TEMPLATE_EXISTS: OK` →
  `TEMPLATE_EXISTS: OK`
- `grep -n 'docs/tasks/review-packet-template.md' .agents/rules/promotion-state-model.md` →
  matches at lines 51 and 86
- `grep -n 'docs/tasks/review-packet-template.md' docs/governance/promotion-state-model.md` →
  matches at lines 306 and 322
- `test ! -e docs/tasks/03-review/1207-warp-prism-review-packet-generator.md` →
  `NO_COLLISION: OK`
