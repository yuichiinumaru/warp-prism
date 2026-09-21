---
date: 20260709-154808
timestamp: 20260709-154808
agent: builders
task: "0315"
description: "Task 0315 — Provider Load-State / View-Model Contracts (2026-07-09)"
is_rebuild_safe: true
---

# Task 0315 — Provider Load-State / View-Model Contracts (2026-07-09)

> **Date**: 2026-07-09
> **Executor**: builders
> **Scope**: `apps/observatory/lib/data/providers/`, `apps/observatory/test/data/providers/`

## Summary

Revalidated Task 0315 after Flutter SDK became available. Provider/view-model
contracts remain presentation-neutral and screen-ready. Fixed the production
provider path so it uses the **canonical** `MockWorkspaceRepository` from the
repository layer (removed the local `PresetLocalWorkspaceSource` bridge
duplicate that earlier 0312 reviews flagged as non-blocking).

## Changes

### Provider wiring — canonical repository

**File**: `apps/observatory/lib/data/providers/workspace_providers.dart`

- Import and construct `MockWorkspaceRepository` from
  `lib/data/repositories/mock_workspace_repository.dart`.
- Default `ASW_WORKSPACE_ROOT` to `assets/mock_workspace` (bundled corpus).
- Graph provider fails closed on `WorkspaceLoadStatus.error` (throws
  `StateError`) so UI consumers see `AsyncValue.error` instead of a silent
  empty graph.

### Provider tests — success / empty / error transitions

**File**: `apps/observatory/test/data/providers/workspace_providers_test.dart`

- Keep pure view-model contract tests (overview/map/operate/history/governance).
- Add repository-override tests for populated success, empty corpus, and
  repository error → graph fail-closed behavior.
- Suite size: **15** tests.

## Validation

| Command (cwd: `apps/observatory`) | Result |
| --- | --- |
| `dart analyze lib/data/providers/ test/data/providers/` | No issues found! |
| `flutter test test/data/providers/workspace_providers_test.dart` | **15/15 PASS** |

## Honesty boundary

Package-wide residual `DS*` compile failures in `warp_prism_ui` organism tests
remain **external** to Task 0315 and are not claimed fixed.
