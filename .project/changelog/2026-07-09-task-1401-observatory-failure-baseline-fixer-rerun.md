---
date: 20260710-014242
timestamp: 20260710-014242
agent: builders
task: "1401"
description: "Task 1401 — Observatory Failure Baseline Fixer Re-run"
is_rebuild_safe: true
---

# Task 1401 — Observatory Failure Baseline Fixer Re-run

> **Date**: 2026-07-09
> **Project**: warp-prism
> **Task**: 1401
> **Type**: governance / inventory
> **Author**: builders (fixer)

## Why

Independent re-review rejected Task 1401 (S=38/100): inventory claimed 12
non-success suites / 472 green / 1042 analyzer issues while live package was
info-only and nearly green.

## What Changed

Rewrote `docs/reports/observatory-failure-baseline.md` from a **new** per-suite
JSON inventory over all `apps/observatory/test/**/*_test.dart` files.

## Live Baseline (this re-run)

- Suites found: **40** (includes `governance_page_shell_test`,
  `overview_shell_test`, `workspace_snapshot_page_test`)
- Fully green suites: **39**
- Non-success suites: **1** — `history_story_modes_test` (2 runtime errors)
- Green `testDone` successes: **816**
- Non-success `testDone`: **2** (`error`)
- Analyzer: **164 info / 0 error / 0 warning** (exit 0)
- DS\* compile flood: **obsolete** (not the live dominant class)
- Historical 653/589/64 and mid-wave 12-compile tables: labeled historical only

## Evidence paths

- Report: `docs/reports/observatory-failure-baseline.md`
- Summary TSV: `tmp/1401-suite-summary.tsv`
- Analyze log: `tmp/1401-analyze.out`
- Task ledger remains in `docs/tasks/02-doing/` per fixer instructions

## Notes

- Independent re-review's +736 / 39/39 green snapshot is recorded as a prior
  claim; this document uses **this run's** measured counts only.
- No production/test code modified under Task 1401 (inventory-only).
- No git/jj operations.
