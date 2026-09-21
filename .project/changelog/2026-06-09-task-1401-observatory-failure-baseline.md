---
date: 20260630-013232
timestamp: 20260630-013232
agent: builders
task: "1401"
description: "Task 1401 — Observatory Failure Baseline Inventory"
is_rebuild_safe: true
---

# Task 1401 — Observatory Failure Baseline Inventory

> **Date**: 2026-06-09
> **Project**: warp-prism
> **Task**: 1401
> **Type**: governance

## What Changed

Created `docs/reports/observatory-failure-baseline.md` — a detailed inventory of
all 64 Observatory test failures with per-failure root cause hypotheses, chain
position classification, and EPIC-14 task mapping.

## Key Findings

- **64 failures** across 14 test files, confirmed fresh run
- **Root cause clusters**: view-mismatch (26), mapper contract drift (11),
  projection contract drift (12), model contract drift (3), widget not
  implemented (8)
- **Highest-impact single fix**: `TaskLaneParsing.fromStatus` is a pass-through
  to `fromDirectoryPrefix` — fixing this would resolve 8 parser tests + cascade
  fixes
- **Largest group**: asset_detail (24 failures) — driven by `AssetKind.name`
  NoSuchMethodError and missing view implementations
- **Effort estimates**: Parsers (S), Asset Detail (L), Map (M), Governance (M),
  History (M)

## Evidence

- Fresh `flutter test apps/observatory/`: 653 tests, 589 pass, 64 fail
- All 14 test files and 6 key implementation files read before classification
- No tests or implementation files were modified (inventory only)
