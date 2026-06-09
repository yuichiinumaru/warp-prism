---
id: T014
title: "Review returned: sidebar navigation fix"
status: review
priority: high
owner: reviewer-orchestrator
created: "2026-05-28"
updated: "2026-06-05"
skills:
  - code-quality-harness
  - frontend-quality-harness
workflows:
  - reviewer-orchestration
  - gt-code-review
depends_on:
  - T009
proof_state: partial
review_score: 8.0
---

# Review Returned: Sidebar Navigation Fix

## Goal
Fix the sidebar navigation issue where onItemTap callback was not firing when expanded: false due to a gesture detector conflict with the collapse animation.

## Scope
- Debug gesture detector layering in DSSidebar
- Fix the tap target sizing in collapsed mode
- Add widget test for collapsed sidebar tap behavior

## Exit Conditions
- [ ] onItemTap fires correctly in both expanded and collapsed modes
- [ ] Widget test covers both states
- [ ] No visual regression in sidebar animation

## Verification Commands
```bash
flutter test test/design_system/ds_sidebar_test.dart
```

## Completion Evidence
*Fix submitted; under review by reviewer-orchestrator. Previous review returned this task due to missing collapsed-mode test coverage.*
