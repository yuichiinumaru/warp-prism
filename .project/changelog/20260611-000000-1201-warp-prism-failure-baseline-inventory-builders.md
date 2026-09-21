---
date: 20260611-000000
timestamp: 20260611-000000
project: warp-prism
agent: builders
task: "1201"
description: "Created Warp Prism failure baseline inventory for all current package/app test failures."
is_rebuild_safe: true
---

# Task 1201: Warp Prism Failure Baseline Inventory

## Summary

Created `docs/reports/warp-prism-failure-baseline-inventory.md` after rerunning the four required package/app test commands. Current counts are:

- `warp_prism_ui`: 854 pass / 0 fail
- `observatory`: 641 pass / 12 fail
- `catalog`: 10 pass / 0 fail
- `cybercore`: 12 pass / 0 fail

## Changes

- Added the unified failure inventory report under `docs/reports/`.
- Listed all 12 current Observatory failures with file, test name, taxonomy class, chain position, affected area, and evidence snippets.
- Marked UI, catalog, and cybercore as zero-failure package/app sections.
- Mapped every failure to `.agents/rules/promotion-state-model.md` taxonomy without using unclassified `pre-existing` as a bypass.

## Verification

- `flutter test packages/warp_prism_ui/` → `00:46 +854: All tests passed!`
- `flutter test apps/observatory/` → `00:40 +641 -12: Some tests failed.`
- `flutter test apps/catalog/` → `00:48 +10: All tests passed!`
- `flutter test apps/cybercore/` → `00:03 +12: All tests passed!`
- Parsed unique `[E]` failures from the Observatory log: 12, matching the report table.
