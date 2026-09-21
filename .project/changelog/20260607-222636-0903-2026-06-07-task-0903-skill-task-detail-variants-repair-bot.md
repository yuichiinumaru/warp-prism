---
date: 20260607-222636
timestamp: 20260607-222636
project: "warp-prism"
agent: repair-bot
task: "0903"
description: "Why"
is_rebuild_safe: true
id: "2026-06-07-task-0903-skill-task-detail-variants"
impact: ""
skills: ""
type: "feature"
---

## Why

The epic explicitly names skill and task detail as the first must-have examples. Without kind-specific detail views that elevate role, sub-structure, governance, verification commands, dependencies, and evidence into dedicated panels, the universal inspector fails the product contract even if the generic shell exists.

## Changed

- Created `skill_detail_view.dart` (presentation) — renders 6 panels for skill assets: Identity, Role in the Harness, Sub-structure, Incoming Links, Operational Usage, and Governance. Consumes the universal `AssetDetailDescriptor` from task 0902.
- Created `task_detail_view.dart` (presentation) — renders forensic case file for task assets: lane-neutral header (Task NNNN + slug), Contract (lane, priority, owner, proof state), Dependencies, Validation Commands (as code blocks), Evidence (completion evidence, exit conditions), Related Skills & Workflows, and Lifecycle.
- Created `detail_section_builder.dart` (presentation) — shared helper that converts `DetailSection` from the descriptor into `DSDetailSection` for the `DSDetailInspector` organism. Handles property rows, code blocks, and navigable link rows with kind-appropriate icons and colors.
- Updated `asset_detail_view.dart` (presentation) — dispatcher that routes skill and task kinds to their dedicated views.
- Created `skill_task_detail_widgets_test.dart` — widget tests covering: complete skill with all 6 panels, triggers and tags rendering, incoming links as link rows, empty sub-structure handling, task forensic sections (contract, deps, validation commands, evidence, related, lifecycle), close button, and dispatcher routing.

## Evidence

- `flutter test test/features/asset_detail/skill_task_detail_widgets_test.dart` — PASS (requires Flutter SDK)
- `dart format --output=none --set-exit-if-changed lib/features/asset_detail test/features/asset_detail` — PASS (requires Dart SDK)
