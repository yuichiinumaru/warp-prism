---
date: 20260630-100000
timestamp: 20260630-100000
agent: builders
task: "0610"
description: "Task 0610 - Operate Task Projection Contract"
is_rebuild_safe: true
---

# Task 0610 - Operate Task Projection Contract

**Date**: 2026-06-30
**Task**: 0610-operate-task-projection-contract
**Type**: feature

## Summary

Defined the Operate-specific read model that converts markdown task files
from the five canonical lanes into a single projection contract. The parser
extracts lane, owner, proof state, review score, dependencies, blockers,
validation commands, and evidence summary without relying on the legacy `queue.md`.

## Changes

### Created/Modified
- `apps/observatory/lib/data/models/task_projection.dart` — Models for TaskProjection, ExitCondition, TaskLaneProjection, and OperateProjection, including dependency and blocker fields.
- `apps/observatory/lib/data/parsers/workspace_task_projection_parser.dart` — Parser implementation for extracting fields and metadata from markdown files.
- `apps/observatory/lib/data/parsers/parsers.dart` — Barrel export.
- `apps/observatory/test/data/parsers/workspace_task_projection_parser_test.dart` — Parser tests.

## Verification

- `flutter analyze --no-pub apps/observatory/lib/features/operate apps/observatory/test/features/operate apps/observatory/lib/data apps/observatory/test/data` — PASS
- `flutter test --concurrency=1 --no-pub apps/observatory/test/data/parsers/workspace_task_projection_parser_test.dart` — PASS (24/24 test cases passing)
- `flutter test --concurrency=1 --no-pub apps/observatory/test/features/operate/operate_board_surface_test.dart` — PASS (34/34 test cases passing after blocker-field compatibility patch)
