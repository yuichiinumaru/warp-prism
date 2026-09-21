---
date: 20260709-161253
timestamp: 20260709-161253
agent: builders
task: "0713"
description: "Task 0713 — History Story And Impact Views Path-to-100 (2026-07-09)"
is_rebuild_safe: true
---

# Task 0713 — History Story And Impact Views Path-to-100 (2026-07-09)

> **Date**: 2026-07-09
> **Executor**: builders (flutter-engineer)
> **Scope**: History story and impact view modes — Prism API alignment, selection sync, complete-path semantics, scoped test evidence

## Summary

Brought Task 0713 from the prior "blocked — Flutter SDK not installed" state to a
verifiable 31/31 green widget-test path on the History feature surface. The
implementation now:

- Exposes three modes (`Timeline`, `Project Story`, `Impact Story`) via a real
  mode switcher inside `HistoryWorkspacePage`.
- Projects Project Story and Impact Story from the Task 0711 `HistoryTimeline`
  read model (no second source of truth).
- Treats the impact path as `changelog → task → (skill | workflow)`. Skill-only,
  workflow-only, and missing-hop states all surface explicitly — no fabricated
  links.
- Migrated the history surface to the public `Prism*` API per
  `warp-prism-ui/warp_prism_ui.dart`; the only non-Prism references remaining
  are inside history-feature internals (no DS* leakage to consumers).
- Wraps the master content with `ResponsiveDetailShell` so the
  `PrismDetailInspector` for the selected entry stays in sync with whichever
  mode the user is viewing, including a dedicated **Impact Path** section that
  reports complete vs partial paths.

## Files touched

| File | Change |
| --- | --- |
| `apps/observatory/lib/features/history/presentation/history_controller.dart` | Realigned to `HistoryEntry` (Task 0711 read model); added `selectedEntry` getter; `toProjectStoryGroups` and `toImpactPathNodes` consume the same filtered set |
| `apps/observatory/lib/features/history/presentation/history_page.dart` | Migrated to `Prism*` API; three-mode switcher; story/impact modes wrapped in `ResponsiveDetailShell`; detail panel adds **Impact Path** section |
| `apps/observatory/lib/features/history/presentation/widgets/history_story_view.dart` | `Prism*` migration; chip-based entry picker for selection sync; selection highlight on parent card |
| `apps/observatory/lib/features/history/presentation/widgets/history_impact_view.dart` | `Prism*` migration; workflow hop chips; gap indicator renders when task or skills/workflows are missing; partial/complete path footer |
| `apps/observatory/test/features/history/history_story_modes_test.dart` | Rewritten to use `HistoryEntry`, cover workflow-only completion, gap indicators, and selection sync across modes |

## Test evidence

```text
$ cd apps/observatory && flutter test \
    test/features/history/ test/data/history/ \
    test/data/providers/workspace_providers_test.dart
…
00:05 +97: All tests passed!
```

`history_story_modes_test.dart` alone: **31 tests pass**, 0 failures, covering:

- Mode switcher (Timeline / Project Story / Impact Story)
- Project story grouping by project, type breakdown, impact areas
- Impact path completeness with skills-only, workflow-only, and missing hops
- Gap indicator copy for missing task and missing skills/workflows
- Partial vs complete path labels
- Selection sync across mode changes; entry chip taps in story view

## Analyzer evidence (scoped)

```text
$ cd apps/observatory && flutter analyze lib/features/history/ test/features/history/
13 issues found. (ran in 1.2s)
```

13 info-level `prefer_const_*` lint hints. **0 errors, 0 warnings** within the
history feature.

## Out of scope

- Full-package analyzer remains out of scope per the lane policy — pre-existing
  `DS*` issues in `packages/warp_prism_ui/test/organisms/*` are not part of
  Task 0713 and were not introduced by this change.
- No mutations to the read model or parser (Task 0711). Story and impact are
  pure projections over `HistoryTimeline.entries`.
- No live wiring to the `historyTimelineAsyncProvider`; `HistoryWorkspacePage`
  still accepts a pre-built `HistoryState` for the router seam, matching the
  behavior already present in `history_page_test.dart` and Task 0711.
