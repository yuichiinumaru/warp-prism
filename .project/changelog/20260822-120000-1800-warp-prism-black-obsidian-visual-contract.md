---
date: 20260822-120000
timestamp: 20260822-120000
project: "warp-prism"
agent: "builders"
task: "1800"
description: "Created black obsidian visual contract (docs/design/black-obsidian-visual-contract.md) freezing Rule Zero, provisional palette hexes, font role separation, forbidden-pattern checklist, supersession map, and interim golden-freeze policy."
is_rebuild_safe: true
---

# Task 1800: warp-prism-black-obsidian-visual-contract

## Summary

Created the authoritative Black Obsidian Visual Contract (`docs/design/black-obsidian-visual-contract.md`) to freeze product identity: black obsidian (#030506) background, bounded blue accent ladder (#2F81FF provisional), font role separation (Rajdhani UI / JetBrains Mono technical), forbidden-pattern checklist, supersession map for Task 1105 / Task 1616 / EPIC-17, and interim golden freeze policy between 1801 and 1805.

## Changes

- Created `docs/design/black-obsidian-visual-contract.md` containing Rule Zero verbatim, product owner rationale, provisional palette table, typography role table, binary forbidden checklist, can/cannot composition examples, supersession map, and interim golden freeze policy.
- Annotated `docs/tasks/00-planning/EPIC-17-warp-prism-ads-form-primitives-gap.md` with supersession pointer for active/checked states.
- Annotated `docs/tasks/00-planning/EPIC-18-warp-prism-black-obsidian-visual-direction-reset.md` closing Task 1800 contract deliverable.

## Verification

- `test -f docs/design/black-obsidian-visual-contract.md && grep -q "screenshot" docs/design/black-obsidian-visual-contract.md` -> PASS
- `dart analyze packages/warp_prism_ui apps/catalog apps/observatory` -> PASS (0 errors)
