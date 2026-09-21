---
date: 20260607-214824
timestamp: 20260607-214824
agent: repair-bot
task: "0312"
description: "Task 0312 — Read-Only Mock Workspace Repository"
is_rebuild_safe: true
scope: "data-layer, repository"
type: "feature"
---

# Task 0312 — Read-Only Mock Workspace Repository

## What changed
- Created `lib/data/repositories/workspace_repository.dart` — abstract `WorkspaceRepository` interface with `load()` returning `WorkspaceLoadState`
- Created `lib/data/repositories/workspace_load_state.dart` — typed load state model with `success`, `empty`, `error`, and `loading` statuses
- Created `lib/data/repositories/mock_workspace_repository.dart` — read-only implementation that loads from `assets/mock_workspace/` using `dart:io` and `WorkspaceMarkdownParser`
- Created `lib/data/repositories/repositories.dart` — barrel export for repository layer
- Created `test/data/repositories/mock_workspace_repository_test.dart` — tests for success loading, non-existent path error, empty directory, malformed file handling, and backbone type usage

## Why
The repository layer is the boundary between mocked files and app logic. Without it, graph services and UI providers will either duplicate asset-loading logic or parse files directly in presentation code. The mock implementation validates the repository contract against the existing corpus before EPIC-04 UI integration.
