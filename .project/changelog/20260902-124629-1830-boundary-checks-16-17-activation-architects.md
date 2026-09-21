---
date: 20260902-124629
timestamp: 20260902-124629
project: "unspecified"
agent: "architects"
task: "1830"
description: "Activated the last two PHASED boundary checks, mechanizing the 1825 Part 7 conditional exception policy: check 16 (core packages contain no domain types — scans the 5 v2 semantic packages with word-boundary regex; sanctioned teal-skin stays ui-local per documented policy) + check 17 (FRB generated files not imported directly by widgets — scans apps+packages excluding adapter; import-only regex avoids false-positive on the legal adapter barrel). Boundary harness 13->15/15; layer-contracts-v2 5.1 rows 16/17 -> ENFORCED NOW. Dry-runs found 0 violations (no check weakening needed). Bundled review PASS 98/100."
is_rebuild_safe: true
---

# Task 1830: boundary-checks-16-17-activation

## Summary

Activated the last two PHASED boundary checks, mechanizing the 1825 Part 7 conditional exception policy: check 16 (core packages contain no domain types — scans the 5 v2 semantic packages with word-boundary regex; sanctioned teal-skin stays ui-local per documented policy) + check 17 (FRB generated files not imported directly by widgets — scans apps+packages excluding adapter; import-only regex avoids false-positive on the legal adapter barrel). Boundary harness 13->15/15; layer-contracts-v2 5.1 rows 16/17 -> ENFORCED NOW. Dry-runs found 0 violations (no check weakening needed). Bundled review PASS 98/100.

## Changes

- Documented task completion details.

## Verification

- [x] boundary 15/15 PASS 0 FAIL; dart analyze boundary_test clean; layer-contracts grep ENFORCED NOW rows updated
