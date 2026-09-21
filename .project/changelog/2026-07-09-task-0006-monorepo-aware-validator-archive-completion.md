---
date: 20260709-031500
timestamp: 20260709-031500
project: warp-prism
agent: builders
task: "0006"
description: "Path-to-100 monorepo-aware validator default and residual legacy archive completion"
is_rebuild_safe: true
---

# Task 0006: Mock Corpus Validation — Monorepo-Aware Archive Completion

## Summary

Remediated Task 0006 after review-wave-2 score 62/100. The active mock corpus
already lived under `apps/observatory/assets/mock_workspace/` and validated with
`--project-root apps/observatory`, but the default validator command failed from
repo root and the residual live `mock_workspace/` tree still sat beside the
collision-checked archive. This pass makes the validator monorepo-aware by
default, finishes the residual archive move without deletion, and refreshes
task evidence for independent review.

## Changes

- **tool/validate_mock_workspace.py** — default project root now resolves to
  `apps/observatory` when that package's `assets/mock_workspace/manifest.yaml`
  exists; explicit `--project-root` remains supported.
- **mock_workspace/** (root residual legacy tree) — moved to
  `.archive/mock_workspace-residual-source-20260709/` after proving it was
  byte-identical to the existing `.archive/mock_workspace/` destination
  (18 files, `diff -rq` empty). No `rm` used.
- **docs/tasks/02-doing → 03-review Task 0006** — path-to-100 evidence refresh
  for monorepo layout, archive absence/presence proofs, and corrected primary
  validation command.

## Verification

- [x] `python3 tool/validate_mock_workspace.py` → `VALIDATION PASSED: all checks OK` (defaults to apps/observatory)
- [x] `python3 tool/validate_mock_workspace.py --project-root apps/observatory` → `VALIDATION PASSED: all checks OK`
- [x] Live corpus counts: agents=9 skills=13 workflows=11 tasks=22 changelog=36 lanes=5
- [x] `test ! -e mock_workspace` → `SOURCE_REMOVED: OK`
- [x] `test -d .archive/mock_workspace` → archive present with 18 files
- [x] Residual source preserved under `.archive/mock_workspace-residual-source-20260709/` (18 files)
- [x] `apps/observatory/assets/mock_workspace/manifest.yaml` archive_destination=`.archive/mock_workspace/`
- [x] `apps/observatory/pubspec.yaml` asset declarations align with disk (validator pubspec check PASS)
