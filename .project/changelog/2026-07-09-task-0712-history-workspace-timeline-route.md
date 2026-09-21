---
date: 20260709-161012
timestamp: 20260709-161012
project: "warp-prism"
agent: builders
task: "0712"
description: "History workspace timeline route wired to Task 0711 read model with Prism* UI"
is_rebuild_safe: true
id: "2026-07-09-task-0712-history-workspace-timeline-route"
impact: "history,timeline,route,filters"
skills: "flutter-harness,coding-execution-harness"
type: "feature"
---

## Why

Task 0712 claimed a History workspace but still rendered an empty page at `/history` (no provider wiring) and used pre-Prism DS* tokens with ChangelogMetadata fixtures instead of the Task 0711 `HistoryTimeline`/`HistoryEntry` read model.

## Changed

- Replaced placeholder `HistoryPage` with `HistoryPageShell` that watches `historyTimelineAsyncProvider` and maps `HistoryTimeline` → `HistoryState`.
- Router `/history` branch now hosts `HistoryPageShell` (parity with Map/Operate shells).
- `HistoryState` consumes `HistoryEntry` (nullable dates, impactTags, resolved skills/workflows, malformed flags).
- History UI migrated to Prism* public API (`PrismTimeline`, `PrismDetailInspector`, `PrismFilterChipGroup`, `PrismStateSurface`, tokens).
- Widget tests cover timeline, filters, empty/loading/error, selection detail, shell forced states, story/impact modes.

## Evidence

- Scoped analyze: `dart analyze lib/features/history lib/app/pages/history_page.dart lib/app/router.dart test/features/history` → 0 errors (info-only prefer_const).
- Scoped tests: `flutter test test/features/history/history_page_test.dart test/features/history/history_story_modes_test.dart` → **46 passed**.
