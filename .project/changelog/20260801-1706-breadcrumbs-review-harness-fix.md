---
date: 20260801-093000
timestamp: 20260801-093000
project: "warp-prism"
agent: "reviewers"
task: "1706"
description: "Fix boundary harness typedef regex to support generic typedefs (PrismSelect<T> = DSSelect<T>) so All public DS declarations have Prism aliases check passes 7/7."
is_rebuild_safe: true
---

# Boundary Harness Regex Fix (generic typedefs)

## Summary

`test/boundaries/boundary_test.dart` failed its "All public DS declarations have Prism aliases" check (6/7 PASS) because the typedef-matching regex `typedef\s+Prism\w+\s*=\s*(DS[A-Z]\w+)\s*;` could not parse generic typedefs. Task 1702 introduced the package's first generic alias (`typedef PrismSelect<T> = DSSelect<T>;`), which broke the previously-green harness.

## Changes

- `packages/warp_prism_ui/test/boundaries/boundary_test.dart` line 237: regex now accepts optional type parameters on both sides:
  `r'typedef\s+Prism\w+(?:<[^>]*>)?\s*=\s*(DS[A-Z]\w+)(?:<[^>]*>)?\s*;'`

## Verification

- `dart run test/boundaries/boundary_test.dart --repo-root .` → 7/7 PASS, 0 FAIL, 0 violations
- `dart analyze test/boundaries/` → 0 issues

## Notes

- Existing aliases `PrismSelect`/`PrismSelectItem`/`PrismSelectOption` were always present and correct; the regex was the defect.
