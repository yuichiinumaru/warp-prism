---
date: 20260709-031434
timestamp: 20260709-031434
project: "warp-prism"
agent: "builders"
task: "0006"
description: "Made validate_mock_workspace.py monorepo-aware by defaulting to apps/observatory, completed residual live mock_workspace/ archive move into .archive/ without deletion, and refreshed Task 0006 path-to-100 evidence after review-wave-2 return."
is_rebuild_safe: true
---

# Task 0006: Mock corpus validation monorepo-aware archive completion

## Summary

Task 0006 path-to-100: monorepo-aware validator default + residual legacy archive move + evidence refresh.

## Changes

- Documented task completion details.

## Verification

- [x] python3 tool/validate_mock_workspace.py → VALIDATION PASSED
- [x] python3 tool/validate_mock_workspace.py --project-root apps/observatory → VALIDATION PASSED
- [x] test ! -e mock_workspace && test -d .archive/mock_workspace → LIVE gone / archive present (18 files)
- [x] apps/observatory/assets/mock_workspace/manifest.yaml archive_destination=.archive/mock_workspace/
