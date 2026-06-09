# ADS Gap Analysis — Operational UI Coverage

> **Date**: 2026-06-08
> **Author**: architects (subagent)
> **Scope**: Flutter Harness (10 subskills, 158 rules) + Task Tree (1101-1110) + Existing DS implementation
> **Purpose**: Identify missing patterns for a comprehensive operational dashboard

---

## Coverage Matrix

| Operational UI Pattern | Harness | Task | DS Implementation | Verdict |
|:---|:---|:---|:---|:---|
| Graph visualization | NONE | 0512 (graph modes) | `DSGraphCanvas` (483 lines, force-directed only) | PARTIAL |
| Log/event viewer | NONE | NONE | NONE | **MISSING** |
| Real-time status indicators | NONE | NONE | `DSStatusDot` (animated, 5 states) | PRESENT |
| Health dashboard / metrics | NONE | 0412 (derived metrics) | `DSMetricTile`, `DSStoryCardQuick` | PARTIAL |
| Multi-panel layouts | NONE | 0513 (selection/inspector) | `DSShell`, `MasterDetailTemplate` | PRESENT |
| Data tables | NONE | NONE | NONE | **MISSING** |
| Notification/toast | `state-notifier-owns-snackbar` rule | NONE | NONE | **MISSING** |
| Drag-and-drop | NONE | NONE | Graph node drag only | **MISSING** |
| Code/config editor | NONE | NONE | NONE | **MISSING** |
| Command palette | NONE | NONE | NONE | **MISSING** |
| Breadcrumb navigation | NONE | 0411 (shell nav) | `DSTopbar` has `_Breadcrumbs` | PARTIAL |
| Timeline/changelog viz | NONE | 0710-0713 | `DSTimeline`, `DSTimelineGrouped`, `DSTimelineMarker` | PRESENT |
| Status badges | NONE | NONE | `DSBadge`, `DSStatusDot`, `DSChip` | PRESENT |
| Empty state | NONE | 1030 | `DSStateSurface` (empty/loading/error) | PRESENT |
| Loading skeleton | NONE | 1030 | NONE (only `CircularProgressIndicator`) | **MISSING** |
| Error boundary | NONE | NONE | NONE | **MISSING** |
| Operational state vocab | NONE | 1102 (inventory) | `DSStateType` enum (3 states only) | PARTIAL |
| Data storytelling | NONE | 0813 | `DSStoryPanel`, `DSStoryNarrativeInsight` | PRESENT |
| Filter chips | NONE | 0611 | `DSFilterChipGroup` | PRESENT |
| Search bar | NONE | 0511 | `DSSearchBar` | PRESENT |
| Detail inspector | NONE | 0901-0905 | `DSDetailInspector`, `DSPropertyRow` | PRESENT |
| Sidebar navigation | NONE | 0411 | `DSSidebar` | PRESENT |
| Task/kanban board | NONE | 0610-0612 | `DSLaneBoard`, `DSTaskCard` | PRESENT |

**Summary**: 8 PRESENT (40%), 6 PARTIAL (30%), 6 MISSING (30%)

---

## CRITICAL Gaps (Block CyberCore operational viability)

### GAP-C1: Data Table Component — MISSING
Sortable, filterable, column-configurable, paginated table with operational state cell renderers, virtual scrolling, glass-panel styling. Needed for: MCP server registry (1400+ rows), agents, skills, tasks, capabilities, providers, policies, users, audit events, credentials.

### GAP-C2: Command Palette / Global Search — MISSING
`Cmd+K` keyboard-driven command palette with fuzzy search, category grouping (navigate/run/recent), overlay positioning, action execution. Primary navigation interface for power users.

### GAP-C3: Log/Event Streaming Viewer — MISSING
Severity levels, source filtering, text search, auto-scroll, virtualized rendering for 10K+ entries. Different from `DSTimeline` (structured metadata) — this is streaming log with severity/source/text.

---

## IMPORTANT Gaps (Degrade operational quality)

### GAP-I1: Graph Visualization Maturity — PARTIAL
Current `DSGraphCanvas` is a 483-line monolith. Missing: hierarchical/tree layout, layered DAG layout, radial layout, graph filtering, minimap, node hover preview, accessibility, edge differentiation, composability.

### GAP-I2: Loading Skeleton — MISSING
No shimmer/skeleton placeholder. `DSStateSurface.loading` shows only a spinner. Need content-shaped skeletons for cards, table rows, graph nodes.

### GAP-I3: Notification/Toast System — MISSING
Rule says notifier owns snackbar, but NO reusable snackbar/toast widget exists. Need severity coloring, stacking, auto-dismiss, action buttons, Riverpod integration.

### GAP-I4: Health Dashboard — PARTIAL
`DSStatusDot` + `DSMetricTile` exist. Missing: compound health cards, status grid/matrix, sparkline/trend mini-charts, uptime bars.

### GAP-I5: Operational State Vocabulary — PARTIAL
`DSStateType` has 3 states (empty, loading, error). Need 14+: healthy, degraded, error, disabled, pending, running, approved, rejected, redacted, exposed, stale, unverified, promoted, archived.

### GAP-I6: Error Boundary — MISSING
No `DSErrorBoundary`. One panel crash kills entire app. Need `ErrorWidget.builder` override, fallback UI, isolation, retry mechanism.

### GAP-I7: Drag-and-Drop — MISSING
`DSLaneBoard` has no drag-and-drop. `DSDraggableCard`, `DSDropTarget`, `DSReorderableLane` needed for task board interactivity.

---

## NICE-TO-HAVE Gaps

- **N1**: Code/Config Editor (syntax-highlighted code block, JSON/YAML viewer)
- **N2**: Real Tab Component (closeable, scrollable, badges — not just FilterChipGroup)
- **N3**: Resizable Split Pane (draggable divider, not fixed ratio)
- **N4**: Virtual Scroll (explicit 10K+ row optimization)
- **N5**: Markdown/Content Renderer (agent profiles, skill defs, task descriptions)

---

## Recommended New Tasks

### Wave A: Critical (after 1107 Melos migration)

| # | Task | Depends On | Priority |
|:--|:-----|:-----------|:---------|
| 1112 | Data Table Component | 1105, 1107 | CRITICAL |
| 1113 | Command Palette | 1105, 1107 | CRITICAL |
| 1114 | Log Viewer Component | 1105, 1107 | CRITICAL |

### Wave B: Important

| # | Task | Depends On | Priority |
|:--|:-----|:-----------|:---------|
| 1115 | Loading Skeleton & Error Boundary | 1105, 1107 | IMPORTANT |
| 1116 | Notification Toast System | 1105, 1107 | IMPORTANT |
| 1117 | Graph Visualization Refactor | 1105, 1107, 0512 | IMPORTANT |
| 1118 | Operational State Vocabulary Expansion | 1105, 1102 | IMPORTANT |
| 1119 | Health Dashboard Components | 1105, 1107, 1118 | IMPORTANT |
| 1120 | Drag-and-Drop Task Board | 1105, 1107 | IMPORTANT |

### Wave C: Polish

| # | Task | Depends On | Priority |
|:--|:-----|:-----------|:---------|
| 1121 | Code Block & Markdown Renderer | 1105, 1107 | NICE-TO-HAVE |
| 1122 | Tab Bar & Split Pane | 1105, 1107 | NICE-TO-HAVE |
| 1123 | Virtual Scroll Optimization | 1105, 1107, 1112 | NICE-TO-HAVE |

---

## Recommended Harness Additions

### New Sub-skill: `operational-ui-patterns`

```
operational-ui-patterns:
  - Data tables: sortable, filterable, column-configurable, virtualized
  - Command palettes: global search, fuzzy match, keyboard-driven
  - Log viewers: severity, source, search, streaming, virtualized
  - Loading skeletons: shimmer, content-shaped placeholders
  - Error boundaries: fallback UI, isolation, retry
  - Notification toasts: severity, stacking, auto-dismiss, a11y
  - Health dashboards: status grids, sparklines, uptime bars
  - Drag-and-drop: sortable lists, kanban moves, drop targets
  - Operational state vocabulary: 14+ states, transitions, behavioral contracts
```

### New Rules

| Rule ID | Category | Description |
|:--------|:---------|:-----------|
| `op-table-virtualize` | operational | Tables with 100+ rows must use virtualized rendering |
| `op-error-boundary` | operational | Every dashboard panel must be wrapped in error boundary |
| `op-skeleton-over-spinner` | operational | Prefer skeleton loading over generic spinner for network content |
| `op-state-vocabulary` | operational | Use canonical 14+ operational state enum |
| `op-command-palette` | operational | Desktop apps must provide Cmd+K command palette |
| `op-notification-channel` | operational | Notifications must be dispatched through Riverpod providers |
| `op-graph-layout-choice` | operational | Choose layout algorithm based on data shape |

---

## Priority Ranking

### Tier 1 — Maximum ADS value, execute first after Melos migration
1. **1112 Data Table** — Every CyberCore listing screen needs this
2. **1113 Command Palette** — Defines operational UX feel
3. **1118 Operational State Vocabulary** — Underpins every operational component
4. **1114 Log Viewer** — CyberCore needs execution/event logging

### Tier 2 — Execute in parallel with CyberCore pilot
5. **1115 Skeleton + Error Boundary** — Small effort, high polish
6. **1116 Notification Toast** — System alerts for read-only apps too
7. **1117 Graph Refactor** — 483-line monolith blocks graph feature growth
8. **1119 Health Dashboard** — MCP server health and agent status monitoring
9. **1120 Drag-and-Drop** — Operate workspace interactivity

### Tier 3 — Polish wave
10. **1121 Code Block + Markdown** — Content display
11. **1122 Tab Bar + Split Pane** — Multi-view workspaces
12. **1123 Virtual Scroll** — MCP registry scale (1400+ rows)
