---
date: 20260709-155859
timestamp: 20260709-155859
agent: builders
task: "0512"
description: "Task 0512 — Map graph modes & adapters path-to-100 (2026-07-09)"
is_rebuild_safe: true
---

# Task 0512 — Map graph modes & adapters path-to-100 (2026-07-09)

> **Date**: 2026-07-09
> **Executor**: builders (self-review; reviewers unavailable)
> **Scope**: `apps/observatory/lib/features/map/`, `apps/observatory/test/features/map/`

## Summary

Closed the 2026-06-30 package-gate rejection path for Task 0512:

1. Empty-edge Graph projections keep the mode selector mounted (already in
   production path; reinforced with a dedicated panel widget test).
2. Task-scoped analyzer is clean (`No issues found`).
3. Package-level analyzer debt is formally classified as **pre-existing
   unrelated** under `.agents/rules/pre-existing-failure-policy.md` (DS*
   symbols outside `lib/features/map`).

## Changes

- `map_graph_panel.dart`: const `BoxDecoration` for mode selector chrome;
  keyboard `ActivateIntent` on mode chips via `FocusableActionDetector`.
- `map_inspector_panel.dart`: const no-selection `ColoredBox`.
- `map_graph_panel_test.dart`: empty-edge projection keeps selector + empty
  guidance and still accepts mode taps.
- `map_surface_states_test.dart` / `map_graph_projection_test.dart`: const /
  library hygiene for scoped analyzer zero.

## Pre-existing failure classification (package analyzer)

| Field | Value |
| --- | --- |
| Classification | **Pre-existing (unrelated)** |
| Package gate | `flutter analyze` from `apps/observatory/` → **1073 issues** (mostly `error • Undefined name 'DS*'` outside Map) |
| Representative areas | `lib/features/workspace_snapshot/`, `lib/features/governance/`, other non-Map surfaces still on legacy `DS*` public names |
| Task file touch set | `lib/features/map/**`, `test/features/map/**` only |
| Map path hits in package analyze | **NONE** |
| Task-scoped analyze | `flutter analyze lib/features/map test/features/map lib/app/pages/map_page.dart` → **No issues found** |
| Regression introduced | **NONE** |
| Baseline / ownership | Prism namespace migration residue; EPIC-13/14 / package-wide DS→Prism cleanup — not Task 0512 graph projection scope |

## Validation

| Command | Result |
| --- | --- |
| `flutter analyze lib/features/map test/features/map lib/app/pages/map_page.dart` | **No issues found** |
| `flutter test test/features/map/map_graph_projection_test.dart test/features/map/map_graph_panel_test.dart` | **PASS** (14 tests; +1 empty-edge selector) |
| `flutter test test/features/map/` | **104/104 PASS** |
| Package `flutter analyze` | 1073 issues — classified unrelated pre-existing (see table) |

## Self-score

**100/100** — both path-to-100 items from 2026-06-30 review addressed:
empty-mode selector retained + package analyzer formally classified.
