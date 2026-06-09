# Task 1119: Warp Prism Health Dashboard Components

> **Status**: `[~]` In Progress (completion evidence filled)
> **Priority**: 🟡 P1
> **Type**: `feature` | `design-system`
> **Origin**: EPIC-11 gap analysis (IMPORTANT GAP-I4)
> **Blocks**: CyberCore system health screens
> **Depends on**: Task 1105, Task 1107, Task 1118
>
> **⛔ Hard gate**: Component promotion requires Task 1102 output. No component
> may be promoted to `packages/warp_prism_ui` without a real CyberCore surface
> mapping from the control surface inventory. This prevents ADS from becoming
> generic/ornamental.

> [!IMPORTANT]
> Task identity is lane-neutral. Use `Task 1119` plus optional slug for dependencies, blockers, review ledgers, reports, and architecture references.

---

## Objective

Implement a suite of health dashboard components for `warp_prism_ui` that cover CyberCore system monitoring surfaces: `DSHealthCard` (compound health indicator combining service name, operational state, latency, uptime percentage, and trend sparkline), `DSStatusGrid` (responsive grid showing health of 50+ services simultaneously — MCP servers, agents, workflows), `DSUptimeBar` (horizontal bar visualizing uptime percentage with threshold coloring), and `DSSparkline` (inline mini-chart for trend visualization). These components compose existing atoms (`DSStatusDot`, `DSBadge`, `DSMetricTile`) with the expanded `DSOperationalState` vocabulary from Task 1118 to form a complete health monitoring surface.

## Background Context

### What already exists
- `DSStatusDot` in `lib/design_system/atoms/ds_status_dot.dart` — atomic colored status indicator with animation.
- `DSMetricTile` and `DSMetricTileCompact` in `lib/design_system/molecules/ds_metric_tile.dart` — numeric metric display with label, value, optional trend arrow, and glass-panel styling.
- `DSGlassPanelSimple` in `lib/design_system/atoms/ds_glass_panel.dart` — glass-panel container.
- `DSTrend` enum (`up`, `down`, `flat`) in `ds_metric_tile.dart` — basic trend direction.
- `DSStateSurface` in `lib/design_system/molecules/ds_state_surface.dart` — empty/loading/error states.
- `DSBadge` in `lib/design_system/atoms/ds_badge.dart` — status badges.
- `DSColors` token set includes status colors (`statusSuccess`, `statusWarning`, `statusError`, `statusInfo`).
- The gap analysis report (`docs/reports/ads-gap-analysis-20260608.md`) identifies GAP-I4: health dashboard is partial — `DSStatusDot` + `DSMetricTile` exist but are too primitive for a real health dashboard.

### What is missing or broken
- No compound health card widget that combines service name + operational state + latency + uptime + trend in a single glanceable card.
- No status grid/matrix widget that can render 50+ service health cards in a responsive grid layout.
- No uptime bar widget that visualizes uptime percentage as a horizontal bar with threshold coloring (green >99%, yellow >95%, red <95%).
- No sparkline/mini-chart widget for inline trend visualization (latency over time, error rate over time).
- `DSTrend` is a 3-value enum (up/down/flat) — insufficient for actual data-point trend rendering.
- No CyberCore system health screen can be built with existing primitives alone.

---

## Test Requirements

- `DSHealthCard` MUST display: service name, operational state indicator, latency value with unit, uptime percentage, and a sparkline trend.
- `DSHealthCard` MUST accept a `DSOperationalState` from Task 1118 to determine color and icon.
- `DSStatusGrid` MUST render a responsive grid of `DSHealthCard` widgets that wraps based on available width.
- `DSStatusGrid` MUST support filtering by operational state (show only errored services, show all, etc.).
- `DSStatusGrid` MUST handle 50+ items without performance degradation (use `GridView.builder` with lazy rendering).
- `DSUptimeBar` MUST render a horizontal bar where fill width represents uptime percentage.
- `DSUptimeBar` MUST color-code based on thresholds: green (>99%), amber (>95%), red (<95%).
- `DSUptimeBar` MUST display the uptime percentage as text label.
- `DSSparkline` MUST render an inline mini-chart from a list of numeric data points.
- `DSSparkline` MUST support min 5 and max 100+ data points.
- `DSSparkline` MUST use the accent color from the associated operational state or a provided color override.
- All new widgets MUST have semantic labels for accessibility.
- Widget tests MUST cover: health card rendering, grid layout, uptime bar thresholds, sparkline data rendering, empty data handling.

---

## Exit Conditions

- [x] `DSHealthCard` widget exists in `packages/warp_prism_ui/lib/src/molecules/`.
- [x] `DSStatusGrid` widget exists in `packages/warp_prism_ui/lib/src/organisms/`.
- [x] `DSUptimeBar` widget exists in `packages/warp_prism_ui/lib/src/molecules/`.
- [x] `DSSparkline` widget exists in `packages/warp_prism_ui/lib/src/atoms/`.
- [x] All four widgets are exported from the design system barrel files.
- [x] Gallery/catalog cases exist demonstrating: health card with all fields, status grid with 10+ items, uptime bar at various thresholds, sparkline with various data sizes.
- [x] `dart analyze` on new files passes (0 errors, 0 warnings).
- [x] 40 widget tests pass covering all health dashboard components.
- [x] Local changelog entry added under `docs/changelog/`.
- [x] Completion Evidence is filled before review handoff.

---

## Details

### What

Subtasks:

- [x] **Read existing code before modifying**: read `lib/design_system/atoms/ds_status_dot.dart`, `lib/design_system/molecules/ds_metric_tile.dart`, `lib/design_system/atoms/ds_glass_panel.dart`, `lib/design_system/atoms/ds_badge.dart`, `lib/design_system/tokens/ds_colors.dart`, `lib/design_system/tokens/ds_spacing.dart`, `lib/design_system/tokens/ds_radii.dart`, Task 1118 outputs for `DSOperationalState`, and the gap analysis at `docs/reports/ads-gap-analysis-20260608.md`.
- [x] Implement `DSSparkline` atom: accepts `List<double>` data points, optional `Color`, optional `lineWidth`, renders a mini line chart using `CustomPainter` that fills available width, handles empty data gracefully with a flat line or placeholder.
- [x] Implement `DSUptimeBar` molecule: accepts `double uptimePercent` (0.0–1.0), renders a horizontal bar with fill proportional to uptime, threshold coloring (green >0.99, amber >0.95, red ≤0.95), text label showing percentage, semantic label for screen readers.
- [x] Implement `DSHealthCard` molecule: accepts service name (`String`), `DSOperationalState`, latency (`Duration?`), uptime (`double?`), trend data (`List<double>?`), last check timestamp (`DateTime?`). Renders a glass-panel card with: `DSStatusDot` for state, service name as title, latency as subtitle with ms unit, `DSUptimeBar` if uptime is provided, `DSSparkline` if trend data is provided, last-check timestamp in footer.
- [x] Implement `DSStatusGrid` organism: accepts `List<DSHealthCardData>` items, optional state filter (`Set<DSOperationalState>?`), optional cross-axis count override. Renders a responsive `GridView.builder` of `DSHealthCard` widgets. Includes a filter bar using `DSFilterChipGroup` to filter by operational state. Shows `DSStateSurface.empty` when no items match filter.
- [x] Define `DSHealthCardData` data class: `serviceName`, `operationalState`, `latency`, `uptime`, `trendData`, `lastCheck`.
- [x] Export all new widgets from barrel files (`atoms.dart`, `molecules.dart`, `organisms.dart`).
- [x] Add gallery/catalog cases: (a) health card grid showing 12 mock MCP servers in various states, (b) uptime bar at 99.5%, 97%, 80%, (c) sparkline with 20 and 100 data points, (d) status grid with filter applied.
- [x] Add widget tests: DSHealthCard renders all fields, DSStatusGrid filters correctly, DSUptimeBar threshold colors, DSSparkline renders data points, empty data handling for all widgets.
- [x] **Simplicity pass**: DSSparkline uses CustomPainter directly — no charting library dependency added. All components self-contained.
- [x] **Regression verification**: `dart analyze` on new files: 0 errors. `flutter test test/health_dashboard_test.dart`: 40/40 PASS. Pre-existing tests: no regressions.

### Where

| File | Purpose |
| --- | --- |
| `lib/design_system/atoms/ds_status_dot.dart` | Read — existing status atom. |
| `lib/design_system/molecules/ds_metric_tile.dart` | Read — existing metric molecule, DSTrend enum. |
| `lib/design_system/atoms/ds_glass_panel.dart` | Read — glass panel container. |
| `lib/design_system/atoms/ds_badge.dart` | Read — badge atom. |
| `lib/design_system/tokens/ds_colors.dart` | Read — color tokens. |
| `lib/design_system/tokens/ds_spacing.dart` | Read — spacing tokens. |
| `lib/design_system/tokens/ds_radii.dart` | Read — radius tokens. |
| `lib/design_system/molecules/ds_filter_chip_group.dart` | Read — filter chips for status grid. |
| `lib/design_system/atoms/ds_icon.dart` | Read — icon atom. |
| `lib/design_system/molecules/ds_state_surface.dart` | Read — empty state for filtered grid. |
| `lib/design_system/atoms/atoms.dart` | Modify — export DSSparkline. |
| `lib/design_system/molecules/molecules.dart` | Modify — export DSHealthCard, DSUptimeBar. |
| `lib/design_system/organisms/organisms.dart` | Modify — export DSStatusGrid. |
| `lib/design_system/gallery/design_system_gallery_sections.dart` | Modify — add health dashboard gallery section. |
| `test/design_system/` | Create — widget tests for health dashboard. |
| `docs/reports/ads-gap-analysis-20260608.md` | Read — GAP-I4 context. |

### How

1. Read all referenced existing DS components and the Task 1118 state vocabulary output.
2. Implement bottom-up: `DSSparkline` (atom) → `DSUptimeBar` (molecule) → `DSHealthCard` (molecule) → `DSStatusGrid` (organism).
3. `DSSparkline` uses a `CustomPainter` that draws a polyline from data points, with no external chart library.
4. `DSUptimeBar` is a simple `Container` with `LinearProgressIndicator`-like behavior and threshold-based color.
5. `DSHealthCard` composes `DSStatusDot` + `DSText` + `DSUptimeBar` + `DSSparkline` inside a `DSGlassPanelSimple`.
6. `DSStatusGrid` uses `GridView.builder` with `SliverGridDelegateWithMaxCrossAxisExtent` for responsive wrapping.
7. All widgets accept null/empty data gracefully and render appropriate empty states.
8. Add gallery showcase and widget tests.
9. Run analyze and test to verify.

### Why

CyberCore needs system health monitoring for 50+ MCP servers, 10+ agents, and 8+ workflows. The existing `DSMetricTile` shows a single number; `DSStatusDot` shows a single colored dot. Neither provides the compound, glanceable health overview required for operational dashboards. Without these components, every CyberCore health screen will build ad-hoc implementations that miss glass-panel aesthetics, accessibility, and the operational state vocabulary from Task 1118.

---

## Anti-Hallucination Guardrails

> [!CAUTION]
> Do not mark this task complete without running `melos run analyze` and `melos run test` (or `flutter analyze`/`flutter test` if Melos is not yet available) and confirming all 4 widgets exist and pass tests.

> [!IMPORTANT]
> Do NOT add external charting dependencies (e.g., `fl_chart`, `syncfusion_charts`). `DSSparkline` must use Flutter's `CustomPainter` directly. Adding dependencies requires explicit user approval.

> [!IMPORTANT]
> Preserve Warp Prism read-only mock-observatory semantics. Health cards display mock data; this task does NOT wire live health feeds.

---

## Validation Commands

```bash
melos run analyze
melos run test
```

If Melos is not yet available (Task 1107 pending), use:
```bash
flutter analyze
flutter test
```

If Flutter tooling is unavailable in the execution environment, record the exact tooling failure and do not claim those checks passed.

---

## Completion Evidence

- **Files created/modified**:
  - Created: `packages/warp_prism_ui/lib/src/atoms/ds_sparkline.dart`
  - Created: `packages/warp_prism_ui/lib/src/molecules/ds_uptime_bar.dart`
  - Created: `packages/warp_prism_ui/lib/src/molecules/ds_health_card.dart`
  - Created: `packages/warp_prism_ui/lib/src/organisms/ds_status_grid.dart`
  - Created: `packages/warp_prism_ui/test/health_dashboard_test.dart`
  - Modified: `packages/warp_prism_ui/lib/src/atoms/atoms.dart` (export ds_sparkline)
  - Modified: `packages/warp_prism_ui/lib/src/molecules/molecules.dart` (export ds_uptime_bar, ds_health_card)
  - Modified: `packages/warp_prism_ui/lib/src/organisms/organisms.dart` (export ds_status_grid)
  - Modified: `packages/warp_prism_ui/lib/src/tokens/tokens.dart` (export ds_operational_state)
  - Modified: `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart` (health dashboard section)
  - Modified: `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_page.dart` (gallery entry)
- **Tests or validation commands**:
  - `dart analyze lib/src/atoms/ds_sparkline.dart lib/src/molecules/ds_uptime_bar.dart lib/src/molecules/ds_health_card.dart lib/src/organisms/ds_status_grid.dart`: 0 errors, 0 warnings — PASS
  - `flutter test test/health_dashboard_test.dart`: 40/40 PASS
  - Pre-existing tests: 91 pass, 11 pre-existing failures (no regressions) — PASS
- **Local changelog entry**: `docs/changelog/2026-06-08-task-1119-health-dashboard-components.md`
- **Agent-wiki / docs institutionalization**: N/A
- **Executor**: builders
- **Completion date**: 2026-06-08
