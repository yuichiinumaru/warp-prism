# Changelog: warp-prism

> **Note**: Auto-generated view for project `warp-prism` from `.changelog/` entries.
> **Do NOT edit manually** - use the changelog skill/subcommands.
> **Last rebuilt**: 2026-07-09 06:14:45 UTC

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

---
