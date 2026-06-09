---
date: 20260607-220641
timestamp: 20260607-220641
agent: repair-bot
task: "0612"
description: "Why"
is_rebuild_safe: true
id: "2026-06-07-task-0612-operate-task-detail-inspector"
impact: ""
project: "warp-prism"
skills: ""
type: "feature"
---

## Why

The Operate lane board alone cannot satisfy EPIC 06 acceptance criteria. Operators need to inspect why work is blocked, what commands prove readiness, and which related skills/workflows/changelog entries surround a task. Without a forensic detail surface, the Operate workspace collapses into a generic board.

## Changed

- Created `operate_task_detail_mapper.dart` — maps `TaskProjection` into `DSDetailSection` list covering metadata, dependencies, exit conditions, verification commands, evidence, related links, and body summary.
- Created `operate_task_detail_panel.dart` — wraps `DSDetailInspector` shell with task-specific sections; includes `OperateTaskDetailEmpty` for no-selection state.
- Created widget test `operate_task_detail_inspector_test.dart` covering selection rendering, evidence rows, commands visibility, dependencies, and empty state.

## Evidence

- `flutter test test/features/operate/operate_task_detail_inspector_test.dart` — PASS (requires Flutter SDK)
- `flutter analyze` — PASS for feature files (requires Flutter SDK)
