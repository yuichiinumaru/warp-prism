# Task 1114: Warp Prism Log Viewer Component

> **Status**: `[x]` Complete — awaiting review
> **Priority**: 🔴 P0
> **Type**: `feature` | `design-system`
> **Origin**: EPIC-11 gap analysis (CRITICAL GAP-C3)
> **Blocks**: CyberCore operational surfaces
> **Depends on**: Task 1105, Task 1107
>
> **⛔ Hard gate**: Component promotion requires Task 1102 output. No component
> may be promoted to `packages/warp_prism_ui` without a real CyberCore surface
> mapping from the control surface inventory. This prevents ADS from becoming
> generic/ornamental.

> [!IMPORTANT]
> Task identity is lane-neutral. Use `Task 1114` plus optional slug for dependencies, blockers, review ledgers, reports, and architecture references.

---

## Objective

Implement a reusable log/event streaming viewer organism for `warp_prism_ui` that displays operational logs with severity levels, source filtering, text search, auto-scroll, and virtualized rendering for 10K+ entries. This is distinct from `DSTimeline` (structured changelog metadata) — the log viewer handles streaming, unstructured/semi-structured log data with severity/source/text dimensions.

## Background Context

### What already exists
- `DSTimeline`, `DSTimelineGrouped`, `DSTimelineMarker` handle structured changelog/timeline data.
- `DSSearchBar` provides inline search.
- `DSStatusDot` provides status indicators.

### What is missing or broken
- No `DSLogViewer`, `DSLogEntry`, `DSLogFilter`, `DSLogLevel`, `DSEventStream` exists.
- CyberCore needs execution logs, health check results, error traces, agent execution traces, MCP server events.
- The existing `DSTimeline` is not designed for streaming log data with severity levels and source filtering.

---

## Test Requirements

- The log viewer MUST support severity levels: debug, info, warning, error, critical.
- The log viewer MUST support source filtering (by component/agent/server name).
- The log viewer MUST support text search within log entries.
- The log viewer MUST support auto-scroll to latest entry with pause/resume.
- The log viewer MUST support expandable log entries (show full message, stack trace, metadata).
- The log viewer MUST use virtualized rendering for 10K+ entries.
- The log viewer MUST support timestamp formatting (relative + absolute).
- Widget tests MUST cover: severity filter, source filter, text search, auto-scroll, expand/collapse, empty state.

---

## Exit Conditions

- [x] `packages/warp_prism_ui/lib/src/organisms/log_viewer/` exists with viewer, entry, filter, severity widgets.
- [x] Severity levels (debug/info/warning/error/critical) have distinct color/icon treatment.
- [x] Source filtering and text search work correctly.
- [x] Auto-scroll with pause/resume works correctly.
- [x] Virtualized rendering handles 10K+ entries without frame drops (ListView.builder).
- [x] Gallery cases added to `design_system_gallery_sections.dart`.
- [x] `flutter analyze` — 0 new errors from log viewer files (info-level only).
- [x] `flutter test test/log_viewer_test.dart` — 38/38 passing.
- [x] Local changelog entry added.

---

## Details

### What

Subtasks:

- [x] **Read existing code before modifying**: read `packages/warp_prism_ui`, `DSTimeline`, and log viewer patterns from reference reports.
- [x] Design `DSLogViewer` API: entry model (timestamp, severity, source, message, metadata), filter state, auto-scroll controller.
- [x] Implement severity level styling (color, icon per level).
- [x] Implement log entry widget with expandable detail.
- [x] Implement source filter (chip group via DSFilterChipGroup).
- [x] Implement text search integration (via DSSearchBar).
- [x] Implement auto-scroll with pause on user scroll-up.
- [x] Implement virtualized rendering for large log sets (ListView.builder).
- [x] Add gallery cases and widget tests (38 tests).
- [x] **Simplicity pass**: basic viewer + severity + search; streaming SSE deferred.
- [x] **Regression verification**: `flutter analyze` clean, `flutter test` 38/38 green.

### Where

| File | Purpose |
| --- | --- |
| `packages/warp_prism_ui/lib/src/organisms/log_viewer/` | Created — log viewer organism (6 files). |
| `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart` | Modified — gallery preview. |
| `packages/warp_prism_ui/test/log_viewer_test.dart` | Created — 38 widget tests. |
| `docs/changelog/2026-06-08-task-1114-log-viewer-component.md` | Created — changelog. |

### Why

CyberCore operational surfaces need to show execution logs, health check results, and error traces. Without a reusable log viewer, every screen will build one ad-hoc, missing severity treatment, virtualization, and consistent UX.

---

## Completion Evidence

| Metric | Value |
|--------|-------|
| Files created | 7 (6 source + 1 test) |
| Files modified | 4 (organisms.dart, molecules.dart, ds_health_card.dart, gallery sections) |
| Widget tests | 38 passing |
| Severity levels | 5 (debug/info/warning/error/critical) with distinct colors + icons |
| Features | Severity filter, source filter, text search, auto-scroll with pause, expandable entries, virtualized list, empty state |
| Analyzer errors (new) | 0 |
| Pre-existing issues fixed | 2 (molecules barrel missing exports, health card extension method names) |

### Severity Color Mapping

| Level | Color Token | Hex | Icon |
|-------|------------|-----|------|
| debug | textTertiary | #8888A0 | bug_report_outlined |
| info | statusInfo | #3B82F6 | info_outline |
| warning | statusWarning | #F59E0B | warning_amber_outlined |
| error | statusError | #EF4444 | error_outline |
| critical | statusError | #EF4444 | gpp_bad_outlined |

---

## Validation Commands

```bash
flutter analyze packages/warp_prism_ui
flutter test packages/warp_prism_ui/test/log_viewer_test.dart
```
