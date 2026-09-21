---
date: 20260709-154702
timestamp: 20260709-154702
agent: builders
task: "0311"
description: "Task 0311 — Markdown Frontmatter Parser Fixtures Live Validation (2026-07-09)"
is_rebuild_safe: true
---

# Task 0311 — Markdown Frontmatter Parser Fixtures Live Validation (2026-07-09)

> **Date**: 2026-07-09
> **Executor**: builders
> **Scope**: `apps/observatory/lib/data/parsers/`, `apps/observatory/test/data/parsers/`, `apps/observatory/test/fixtures/mock_workspace/`

## Summary

Cleared the stale Task 0311 review blocker ("Flutter SDK not installed") with live
scoped validation under `apps/observatory`. Parser implementation was already present;
this pass exercised fixtures on disk, fixed a false "unclosed" malformed fixture, and
eliminated analyzer warnings by wiring real fixture-file-backed tests.

## Changes

### Fixture-file-backed parser tests

**File**: `apps/observatory/test/data/parsers/workspace_markdown_parser_test.dart`

- Added `_readFixture` helper using `dart:io` + existing `_fixture` path helper
- New `Fixture files on disk` group covering agent, skill, workflow, task, changelog
  happy paths and three malformed cases with deterministic `ParseException`s

### Malformed unclosed fixture content

**File**: `apps/observatory/test/fixtures/mock_workspace/malformed/unclosed_frontmatter.md`

Removed the accidental closing `---` so the fixture actually models unclosed frontmatter.

## Validation

| Command (cwd `apps/observatory`) | Result |
| --- | --- |
| `dart analyze --format=machine lib/data/parsers test/data/parsers` | EXIT 0 — no issues |
| `flutter test --concurrency=1 --no-pub test/data/parsers/workspace_markdown_parser_test.dart` | 51/51 PASS |
| `flutter test --concurrency=1 --no-pub test/data/parsers/` | 75/75 PASS |

## Why

Task 0311 exit conditions require analyzer + fixture tests green. Prior completion
evidence claimed Flutter was unavailable; the environment now has Flutter 3.44.1 /
Dart 3.12.1, so live proof replaces the stale blocker.
