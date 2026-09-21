---
date: 20260709-214406
timestamp: 20260709-214406
agent: builders
task: "1406"
description: "Task 1406 — History and Operate Feature Flow Reconciliation"
is_rebuild_safe: true
---

# Task 1406 — History and Operate Feature Flow Reconciliation

> **Date**: 2026-07-09
> **Executor**: gt-flutter-engineer
> **Scope**: `apps/observatory/lib/features/history/`, `apps/observatory/lib/features/operate/`

## Summary

Reconciled History and Operate feature flows after upstream data/view-model
waves (1403–1405). Live scoped tests for both surfaces were already green;
this task removed deep relative import drift and re-validated story modes,
impact paths, and the operate task detail inspector against current contracts.

## Changes

### Package import hygiene (feature surfaces)

Converted deep/relative feature imports to `package:warp_prism_observatory/...`
and kept Prism* public UI API usage:

- History page no longer deep-imports asset_detail via `../../`
- History controller/widgets use package imports for presentation types
- Operate workspace, inspector, mapper, storytelling, and view-model use
  package imports for feature-local modules

### Contract verification (no redesign)

Confirmed current contracts still match tests:

- History: Timeline / Project Story / Impact Story modes, workflow-only
  complete paths, gap indicators, selection sync, skill/workflow filters
- Operate: inspector sections (metadata, deps, exit conditions, commands,
  evidence, related skills/workflows, body), empty state, close callback

## Verification

```bash
cd apps/observatory
flutter test test/features/history/ test/features/operate/
# → 119 passed, 0 failed
```

Named target suites:

- `history_story_modes_test.dart` — PASS
- `operate_task_detail_inspector_test.dart` — PASS
