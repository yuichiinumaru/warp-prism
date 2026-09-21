---
date: 20260709-180000
timestamp: 20260709-180000
agent: builders
task: "0610"
description: "Task 0610 path-to-100 — Operate task projection contract completion"
is_rebuild_safe: true
---

# Task 0610 Path-to-100 — Operate Task Projection Contract

**Date**: 2026-07-09
**Task**: 0610-operate-task-projection-contract
**Type**: fix / contract completion

## Summary

Closed the 82/100 review debt for Task 0610. The Operate projection now exposes
slug, status label, type, structured evidence rows, and named markdown sections;
lane inference is directory-segment based; section extraction tolerates governed
heading suffixes/emoji; parser tests load one committed fixture per lane.

## Changes

### Modified
- `apps/observatory/lib/data/models/task_projection.dart` — canonical projection with `slug`, `statusLabel`, `type`, `sections`, `completionEvidenceRows`, `EvidenceRow`, `MarkdownSection`.
- `apps/observatory/lib/data/parsers/workspace_task_projection_parser.dart` — path-wins lane inference, tolerant headings, verification-section-only commands, evidence rows, sections.
- `apps/observatory/lib/features/operate/task_projection.dart` — re-export of data-layer model (no duplicate type).
- `apps/observatory/lib/data/models/data_models.dart` — barrel export for `task_projection.dart`.
- `apps/observatory/lib/features/operate/operate_task_detail_mapper.dart` — Prism* API + new metadata/evidence fields.
- `apps/observatory/lib/features/operate/operate_task_detail_panel.dart` — Prism* API.
- `apps/observatory/test/data/parsers/workspace_task_projection_parser_test.dart` — path-to-100 coverage (29 tests).

## Verification

- `flutter test --concurrency=1 --no-pub test/data/parsers/workspace_task_projection_parser_test.dart` — PASS (29/29)
- `flutter test --concurrency=1 --no-pub test/features/operate/operate_task_detail_inspector_test.dart` — PASS (13/13)
- `flutter test --concurrency=1 --no-pub test/features/operate/operate_board_surface_test.dart --plain-name OperateWorkspaceViewModel` — PASS (24/24)
- `flutter analyze --no-pub lib/data/models/task_projection.dart lib/data/parsers/workspace_task_projection_parser.dart lib/features/operate/task_projection.dart lib/data/models/data_models.dart` — No issues found
- `dart format --output=none --set-exit-if-changed` on scoped files — PASS after format

## Known non-blockers

- `OperateWorkspaceView integration` widget tests still report layout overflow / missing semantic labels in the board filter chrome (pre-existing UI surface debt outside the parser contract).
- Full-package `flutter analyze` still has unrelated package-level noise outside Task 0610 scope.
