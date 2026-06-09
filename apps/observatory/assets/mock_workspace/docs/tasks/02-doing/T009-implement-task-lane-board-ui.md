---
id: T009
title: "Implement task lane board UI"
status: doing
priority: high
owner: builder-orchestrator
created: "2026-06-01"
updated: "2026-06-05"
skills:
  - coding-execution-harness
  - frontend-quality-harness
  - design-system-harness
workflows:
  - builder-orchestration
  - gt-code-review
depends_on:
  - T003
  - T006
proof_state: partial
review_score: 7.5
---

# Implement Task Lane Board UI

## Goal
Build the five-lane task board surface using DSLaneBoard, rendering tasks from the mock corpus grouped by lane with drag-and-drop status transitions.

## Scope
- DSLaneBoard organism with 5 swim lanes
- Task cards using DSTaskCard molecules
- Drag-and-drop between lanes updates task status
- Filter by owner, priority, and skill

## Exit Conditions
- [ ] All 5 lanes render with correct task counts
- [ ] DSTaskCard displays title, priority, owner, and review_score
- [ ] Drag from one lane to another fires status change callback
- [ ] Filter controls reduce visible tasks without full reload

## Verification Commands
```bash
flutter test test/features/operate/lane_board_test.dart
```

## Completion Evidence
*Partial — DSLaneBoard organism exists at lib/design_system/organisms/ds_lane_board.dart; feature integration with mock data pending Task T006.*
