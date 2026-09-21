---
date: 20260907-190853
timestamp: 20260907-190853
project: "warp-prism-ui"
agent: "builder-engineer"
task: "1837"
description: "Tagged all 74 golden tests: 13 library-level @Tags(['golden']) on test/goldens/ files plus 3 group-level tags: 'golden' on embedded golden groups in ds_checkbox_test, ds_button_test, and ds_text_field_test (group-level so non-golden unit tests in those files keep running under exclusion). Executed in two rounds: round 2 was a parent scope repair after the builder's guardrail correctly reported 4 embedded checkbox goldens outside the original Where table, and a sweep found 2 more embedded groups. Independent review 2026-09-07: 95/100 APPROVED_PATH100, zero regressions; one count-recording correction (60 ran / 1 passed / 59 failed; surface total 74) applied during promotion."
is_rebuild_safe: true
---

# Task 1837: Golden Suite Tagging — --exclude-tags=golden Effective (promoted)

## Summary

flutter test test/ --no-pub --exclude-tags=golden now exits 0 (+1692 all passed) — the documented full-suite validation command is finally usable on this branch; goldens still run without exclusion (60 dir tests: 59 expected frozen-drift failures + 1 drift-invariant pass; 14 embedded); Task 1800/1805 golden freeze intact (0 baselines touched); boundary harness 15/15.

## Changes

- Documented task completion details.

## Verification

- [x] Independent review: docs/reports/reviewers/1837-golden-suite-tagging-review-loop.md (95/100 APPROVED_PATH100, zero REGRESSION findings; primary gate re-run +1692 exit 0)
