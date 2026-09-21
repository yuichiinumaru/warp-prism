---
date: 20260710-012201
timestamp: 20260710-012201
agent: builders
task: "0311"
description: "Tasks 0311 / 0312 / 0313 — Path-to-100 Parser, Repository, Graph (2026-07-09)"
is_rebuild_safe: true
---

# Tasks 0311 / 0312 / 0313 — Path-to-100 Parser, Repository, Graph (2026-07-09)

> **Date**: 2026-07-09
> **Executor**: gt-flutter-engineer
> **Scope**: `apps/observatory/lib/data/parsers|repositories|services|models`, tests, mock corpus skill-local workflows
> **Lane**: remain in `docs/tasks/02-doing/` (ready for independent re-review)

## Summary

Closed independent re-review path-to-100 blockers for the EPIC 03 data-layer trio:

1. **0311** — File-backed fixtures + `package:yaml` frontmatter decoding
2. **0312** — Locked error vs partial-success load contract; repo-local temps; clean corpus scan
3. **0313** — `normalizeAssetId` (no double-prefix); honor `skillDirectoryPattern`

## Changes

### Task 0311 — Markdown frontmatter parser fixtures

- Replaced hand-rolled YAML subset with `package:yaml` in `frontmatter_parser.dart`
- Wired `test/fixtures/mock_workspace/**` via `File.readAsStringSync` (5 happy + 3 malformed)
- Added nested-map / quoted-comma / invalid-YAML contract tests
- Quoted colon-bearing `description` on `development-methodologies/SKILL.md` so strict YAML succeeds

### Task 0312 — Read-only mock workspace repository

- Documented load contract:
  - **error**: missing root; exception; **or** all scanned files fail parse
  - **empty**: root exists, zero files scanned
  - **success** (partial OK): ≥1 asset; `parseErrors` + `parseErrorPaths` when some fail
- Added `WorkspaceScanMetadata.parseErrorPaths`
- Repository tests use `tmp/test_fixtures/` (no `Directory.systemTemp`); hard-fail if corpus missing
- Added frontmatter to 13 skill-local `skills/*/workflows/*.md` files

### Task 0313 — Graph normalization / edge inference

- Added `normalizeAssetId` on backbone model; applied in edge inference + parser edge builders
- `inferPathContainment` returns null when path skill ≠ `skillDirectoryPattern`
- Exact `targetId` assertions for bare / prefixed / double-prefixed inputs

## Validation (cwd `apps/observatory`)

| Command | Result |
| --- | --- |
| `dart analyze --format=machine lib/data/parsers test/data/parsers` | EXIT 0 — no ERROR/WARNING |
| `flutter test --concurrency=1 --no-pub test/data/parsers/workspace_markdown_parser_test.dart` | **56/56 PASS** |
| `flutter test --concurrency=1 --no-pub test/data/parsers/` | **85/85 PASS** |
| `flutter test --concurrency=1 --no-pub test/data/repositories/mock_workspace_repository_test.dart` | **7/7 PASS** |
| `flutter test --concurrency=1 --no-pub test/data/services/workspace_graph_builder_test.dart` | **30/30 PASS** |
| Combined three suites | **93/93 PASS** |

Scoped `flutter analyze` reports **info** lints only (prefer_const_literals / dangling library docs); zero errors/warnings.

## Author

gt-flutter-engineer
