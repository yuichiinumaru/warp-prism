# Warp Prism — Control Surface Component Inventory

> **Task**: 1102 — Warp Prism Control Surface Inventory
> **Date**: 2026-06-08
> **Status**: Active
> **Evidence**: Direct inspection of `lib/design_system/`, `lib/features/`, `lib/data/models/`, and `assets/mock_workspace/`

---

## 1. Design System Components (lib/design_system/)

### 1.1 Tokens

| Token Layer | Class | File | Lines | Purpose | Reusability |
|------------|-------|------|-------|---------|-------------|
| Colors | `DSColors` | `tokens/ds_colors.dart` | 180 | Obsidian backgrounds, energy accents (cyan/violet/gold), status, governance, text, border, lane, asset-kind colors. Includes `forAssetKind()`, `forLane()`, `forCanonicity()` lookup methods. | Universal — all surfaces |
| Typography | `DSTypography` | `tokens/ds_typography.dart` | 186 | 18-style type scale (display/heading/body/label/code/numeric). JetBrainsMono (mono) + Inter (sans). | Universal |
| Spacing | `DSSpacing` | `tokens/ds_spacing.dart` | 72 | Base scale (xxs→massive) + semantic spacing (insets, gaps, layout dimensions, sidebar/topbar/inspector sizes). | Universal |
| Radii | `DSRadii` | `tokens/ds_radii.dart` | 47 | Base radii (none→full) + semantic radii (card, button, chip, input, panel, modal). | Universal |
| Shadows | `DSShadows` | `tokens/ds_shadows.dart` | 144 | Elevation presets (1-4) + energy glow effects (cyan/violet/gold/success/error/warning). | Universal |
| Motion | `DSMotion` | `tokens/ds_motion.dart` | 62 | Durations (instant→slowest) + curves (standard/enter/exit/emphasized/spring) + semantic animations (hover/focus/page/panel/stagger). | Universal |
| Semantics | `DSSemantics` | `tokens/ds_semantics.dart` | 150 | Pre-composed semantic text styles: status (success/warning/error/info), governance (canonical/local/generated/appendOnly), asset kind, lane, proof state. | Universal |
| Breakpoints | `DSBreakpoints` | `tokens/ds_breakpoints.dart` | ~30 | Responsive breakpoint constants (narrow/sidebarCollapse/masterDetailSideBySide/timelineDetail). | Universal |

### 1.2 Atoms

| Component | Class(es) | File | Operational States | Data Dependencies | Reusability |
|-----------|-----------|------|--------------------|-------------------|-------------|
| **Text** | `DSText`, `DSTextVariant` | `atoms/ds_text.dart` | 18 variant states (display/heading/body/label/code/numeric × large/medium/small) | `DSTypography`, `DSColors` | MVP — every surface |
| **Icon** | `DSIcon`, `DSIconSize`, `DSIcons` | `atoms/ds_icon.dart` | 5 size states (tiny/small/medium/large/xlarge). Icon constants for navigation, asset kinds, status, actions, governance, lanes. | `DSColors` | MVP — every surface |
| **Badge** | `DSBadge`, `DSBadgeSize`, `DSBadgeVariant` | `atoms/ds_badge.dart` | Variants: filled/outlined/dot. Semantic constructors: count/success/warning/error/info. | `DSColors` | MVP — dashboards, cards, lane headers |
| **Chip** | `DSChip`, `DSChipSize` | `atoms/ds_chip.dart` | Interactive (selected/unselected/enabled/disabled), keyboard focusable. Factory constructors: `assetKind`, `lane`, `governance`, `removable`. | `DSColors`, `DSIcons` | MVP — filters, tags, lanes |
| **Status Dot** | `DSStatusDot` | `atoms/ds_status_dot.dart` | 5 semantic constructors: success/warning/error/info/neutral. Optional animated pulsing glow. | `DSColors` | MVP — task cards, health indicators |
| **Divider** | `DSDivider`, `DSGlowDivider` | `atoms/ds_divider.dart` | Variants: subtle/default/strong. Glow variant for energy accent separation. | `DSColors` | MVP — layouts |
| **Glass Panel** | `DSGlassPanel`, `DSGlassPanelSimple` | `atoms/ds_glass_panel.dart` | Variants: subtle/elevated/modal. Simple variant without blur for performance. | `DSColors`, `DSShadows` | MVP — story panels, metric tiles, modals |
| **Glow Border** | `DSGlowBorder` | `atoms/ds_glow_border.dart` | Animated energy glow border with color override. | `DSColors` | Defer — decorative |

### 1.3 Molecules

| Component | Class(es) | File | Operational States | Data Dependencies | Reusability |
|-----------|-----------|------|--------------------|-------------------|-------------|
| **Search Bar** | `DSSearchBar` | `molecules/ds_search_bar.dart` | Focused/unfocused, value present/empty, filter toggle | String value, filter state | MVP — topbar, catalog, overview |
| **Filter Chip Group** | `DSFilterChipGroup`, `DSFilterOption` | `molecules/ds_filter_chip_group.dart` | Horizontal scrollable group, multi-select, empty state | List of filter options, selected set | MVP — Map/Operate/History filters |
| **Asset Card** | `DSAssetCard` | `molecules/ds_asset_card.dart` | Normal/selected, kind-colored, description present/absent, tags present/absent, edge count | name, kind, description, canonicality, tags, edgeCount | MVP — Map catalog, search results |
| **Task Card** | `DSTaskCard` | `molecules/ds_task_card.dart` | Normal/selected/focused, proof state color (complete/partial/missing/none), priority badge (P0/P1/P2), review score color, keyboard-interactive | id, title, lane, priority, owner, proofState, reviewScore, linkedSkills, dependencyCount | MVP — Operate lane board |
| **Metric Tile** | `DSMetricTile`, `DSMetricTileCompact` | `molecules/ds_metric_tile.dart` | Trend state (up/down/flat) with color coding, optional subtitle, tap target | label, value, icon, color, trend | MVP — Overview dashboard, governance |
| **Provenance Pill** | `DSProvenancePill`, `DSProvenanceSize` | `molecules/ds_provenance_pill.dart` | 6 canonicality states: parentCanonical/childLocal/generated/appendOnly/archive/mock. 3 sizes. Tooltip with explanation. | canonicality string | MVP — governance, asset cards |
| **Evidence Row** | `DSEvidenceRow`, `DSEvidenceIndicator`, `DSEvidenceState` | `molecules/ds_evidence_row.dart` | 4 evidence states: verified/partial/missing/pending. Compact indicator variant. | label, value, state | MVP — task detail, governance |
| **Timeline Marker** | `DSTimelineMarker` | `molecules/ds_timeline_marker.dart` | Normal/selected, type-colored (feature/fix/refactor/docs/chore), first/last in timeline, project/task badges | date, title, type, project, taskId, impacts | MVP — History timeline |
| **State Surface** | `DSStateSurface`, `DSStateType` | `molecules/ds_state_surface.dart` | 3 states: **empty** (inbox icon), **loading** (spinner), **error** (error icon + retry). Compact mode. | stateType, icon, title, subtitle, actionLabel | MVP — all empty/loading/error states. **CRITICAL: needs expansion to 14+ operational states (see operational-state-vocabulary.md)** |

### 1.4 Organisms

| Component | Class(es) | File | Operational States | Data Dependencies | Reusability |
|-----------|-----------|------|--------------------|-------------------|-------------|
| **Shell** | `DSShell`, `DSShellResponsive` | `organisms/ds_shell.dart` | 4 responsive states: wide (side-by side), medium (overlay drawer + scrim), narrow (collapsed sidebar), very narrow (no sidebar). Inspector open/close. | sidebar, topbar, content, inspector widgets | MVP — app root |
| **Sidebar** | `DSSidebar`, `DSSidebarItem` | `organisms/ds_sidebar.dart` | Expanded/collapsed, selected/unselected items, keyboard-navigable (arrow/Enter/Space), hover/focus visual states, badge counts. | items list, selectedId | MVP — app shell |
| **Topbar** | `DSTopbar`, `DSTopbarAction` | `organisms/ds_topbar.dart` | Title or breadcrumb mode, search bar collapse at narrow widths, action buttons with keyboard focus/activation, badge counts. | title, breadcrumbs, searchBar, actions | MVP — app shell |
| **Lane Board** | `DSLaneBoard`, `DSLane`, `DSLaneTask` | `organisms/ds_lane_board.dart` | 5-lane kanban layout, horizontal scroll, empty lane state (uses DSStateSurface.empty), responsive lane width (280-320px). | lanes list with tasks | MVP — Operate surface |
| **Timeline** | `DSTimeline`, `DSTimelineEntry`, `DSTimelineGrouped`, `DSTimelineGroup` | `organisms/ds_timeline.dart` | Flat or grouped mode, empty state, selected entry, filter bar integration. | entries list, selectedId, filterBar | MVP — History surface |
| **Detail Inspector** | `DSDetailInspector`, `DSDetailSection`, `DSPropertyRow`, `DSLinkRow` | `organisms/ds_detail_inspector.dart` | Kind-colored header, closeable, sections with counts, keyboard-navigable link rows, property/value pairs. | title, kind, sections list | MVP — Asset Detail, Map inspector |
| **Story Panel** | `DSStoryPanel`, `DSStoryInsight`, `DSStoryNarrativeInsight`, `InsightRiskLevel`, `DSStoryCardQuick` | `organisms/ds_story_panel.dart` | 5 risk levels (none/low/medium/high/critical), empty insights state, evidence/connection metadata on narrative insights. Quick card variant for dashboards. | title, insights list | MVP — Overview, Governance storytelling |
| **Graph Canvas** | `DSGraphCanvas`, `GraphNode`, `GraphEdge` | `organisms/ds_graph_canvas.dart` | Empty state, force-directed layout, node hover/select/drag, edge highlighting, pan/zoom, animated physics. | nodes list, edges list | MVP — Map graph. **NOTE: needs layout algorithm expansion per ADS gap analysis** |

### 1.5 Templates

| Template | Class(es) | File | Responsive States | Data Dependencies | Reusability |
|----------|-----------|------|--------------------|-------------------|-------------|
| **Master Detail** | `MasterDetailTemplate` | `templates/master_detail_template.dart` | 3 breakpoint states: ≥1200px side-by-side, 800-1199px overlay drawer + scrim, <800px full-screen detail with back arrow. Filter chip integration. | sidebarItems, masterContent, detailContent, filters | MVP — Map, Operate, Governance |
| **Canvas** | `CanvasTemplate` | `templates/master_detail_template.dart` | Full-bleed canvas with overlay panel (inspector) and floating controls. | sidebarItems, canvas, overlayPanel | MVP — Map graph view |
| **Timeline** | `TimelineTemplate` | `templates/master_detail_template.dart` | ≥1000px side-by-side timeline+detail, <1000px timeline only. Filter chip integration. | sidebarItems, entries, detailPanel | MVP — History surface |

### 1.6 Gallery

| Component | Class | File | Purpose |
|-----------|-------|------|---------|
| Gallery Page | `DSGalleryPage` | `gallery/design_system_gallery_page.dart` | Mandatory gallery route demonstrating all tokens/components/states |
| Gallery Sections | `DSGallerySections` | `gallery/design_system_gallery_sections.dart` | Section generators for color tokens, typography, status semantics, badges, chips, cards, panels, task cards, asset cards, timeline items, graph nodes, empty/loading/error states |

---

## 2. Feature-Level Widgets (lib/features/)

### 2.1 Overview Feature (`lib/features/overview/`)

| Widget/Class | File | Purpose | Data Dependencies |
|-------------|------|---------|-------------------|
| `OverviewPage` | `overview_page.dart` | Top-level dashboard page — aggregates metric tiles, story panels, lane summary | `OverviewProvider` |
| `OverviewProvider` | `overview_provider.dart` | Computes derived metrics from `WorkspaceSnapshot` | `WorkspaceSnapshot` |
| `OverviewMetrics` | `overview_metrics.dart` | Aggregated counts (agents, skills, workflows, tasks, changelog), blocked tasks, review queue, governance warnings, lane breakdown | `WorkspaceSnapshot` |
| `OverviewStoryInsight` | `overview_metrics.dart` | Narrative insight for current story panel (severity: `OverviewInsightSeverity`) | — |

### 2.2 Map Feature (`lib/features/map/`)

| Widget/Class | File | Purpose | Data Dependencies |
|-------------|------|---------|-------------------|
| `MapWorkspacePage` | `map_workspace_page.dart` | Top-level Map surface page with tabs (Agents, Skills, Workflows, Graph) | `MapWorkspaceProvider` |
| `MapWorkspaceProvider` | `map_workspace_provider.dart` | State management for Map: search, filter, selection, catalog/graph projection | `WorkspaceSnapshot` |
| `MapWorkspaceState` | `map_workspace_state.dart` | State model: subview (catalog/graph), search query, filters, selected asset | — |
| `MapSubview` (enum) | `map_workspace_state.dart` | catalog vs graph mode | — |
| `MapCatalogPanel` | `widgets/map_catalog_panel.dart` | Catalog view with tab-based asset listing (agents/skills/workflows) | `MapCatalogTab` enum |
| `MapAssetCardGrid` | `widgets/map_asset_card_grid.dart` | Grid of `DSAssetCard` for catalog view | filtered assets list |
| `MapGraphPanel` | `widgets/map_graph_panel.dart` | Graph mode with `DSGraphCanvas` and mode selector | `MapGraphProjection` |
| `MapInspectorPanel` | `widgets/map_inspector_panel.dart` | Right-side detail inspector for selected asset | `MapSelectionController` |
| `MapStatePanel` | `widgets/map_state_panel.dart` | State overlay for loading/empty/error (`MapSurfaceState` enum) | — |
| `MapNoResultsState` | `widgets/map_no_results_state.dart` | Empty search results state | — |
| `MapSearchBar` | (uses `DSSearchBar`) | Search input | — |
| `MapFilterChips` | (uses `DSFilterChipGroup`) | Kind/status filter chips | — |
| `MapSelectionController` | `map_selection_controller.dart` | Manages selected asset + inspector sections/rows | — |
| `MapGraphProjection` | `graph/map_graph_projection.dart` | Converts `WorkspaceSnapshot` to `GraphNode`/`GraphEdge` lists | `WorkspaceSnapshot` |
| `MapGraphMode` (enum) | `graph/map_graph_mode.dart` | containment / operational / evidence | — |

### 2.3 Operate Feature (`lib/features/operate/`)

| Widget/Class | File | Purpose | Data Dependencies |
|-------------|------|---------|-------------------|
| `OperateWorkspaceView` | `operate_workspace_view.dart` | Top-level Operate surface: filter bar, search, count bar, lane board, story panel | `OperateWorkspaceViewModel` |
| `OperateWorkspaceViewModel` | `operate_workspace_view_model.dart` | State: board state, lane states, filter options, search query | `WorkspaceSnapshot` |
| `OperateBoardState` | `operate_workspace_view_model.dart` | Aggregated lane counts, filtered tasks, story diagnostics | — |
| `OperateTaskDetailPanel` | `operate_task_detail_panel.dart` | Right-side task detail for selected task in lane board | `TaskProjection` |
| `TaskProjection` | `task_projection.dart` | Normalized task view model from `WorkspaceAsset` frontmatter | `WorkspaceAsset` |
| `TaskLaneProjection` | `task_projection.dart` | Lane + task projections for the board | — |
| `OperateFilters` | `operate_filters.dart` | Filter state for lane, owner, priority, proof state | — |
| `OperateStoryDiagnostics` | `operate_storytelling.dart` | Computes blocker clusters, lane mismatches, narrative insights | `WorkspaceSnapshot` |
| `StoryRiskLevel` (enum) | `operate_storytelling.dart` | none/low/medium/high/critical | — |
| `OperateInsight` | `operate_storytelling.dart` | Story insight with risk level for operate narrative | — |
| `OperateTaskDetailMapper` | `operate_task_detail_mapper.dart` | Maps `TaskProjection` → `DSDetailInspector` sections | — |

### 2.4 History Feature (`lib/features/history/`)

| Widget/Class | File | Purpose | Data Dependencies |
|-------------|------|---------|-------------------|
| `HistoryWorkspacePage` | `presentation/history_page.dart` | Top-level History surface: mode selector (timeline/story/impact), filters, content | `HistoryController` |
| `HistoryController` | `presentation/history_controller.dart` | State: view mode, filter category, project story groups, impact path nodes | `WorkspaceSnapshot` |
| `HistoryViewMode` (enum) | `presentation/history_view_mode.dart` | timeline / story / impact | — |
| `HistoryFilterCategory` (enum) | `presentation/history_controller.dart` | project / type / skill / task | — |
| `HistoryState` | `presentation/history_controller.dart` | State model: entries, groups, impact paths, selected filters | — |
| `HistoryStoryView` | `presentation/widgets/history_story_view.dart` | Grouped story cards by project/milestone | `ProjectStoryGroup` |
| `HistoryImpactView` | `presentation/widgets/history_impact_view.dart` | Impact path visualization: changelog → task → skill/workflow | `ImpactPathNode` |

### 2.5 Governance Feature (`lib/features/governance/`)

| Widget/Class | File | Purpose | Data Dependencies |
|-------------|------|---------|-------------------|
| `GovernanceOverviewPage` | `presentation/governance_overview_page.dart` | Diagnostic panels: orphan workflows, no-trigger skills, missing verification, canonicality summary, fan-in hotspots, review pressure | `WorkspaceSnapshot` |
| `GovernanceIssueFilters` | `widgets/governance_issue_filters.dart` | Filter state for diagnostic severity/category | `GovernanceFilterState` |
| `GovernanceIssueGroup` | `widgets/governance_issue_group.dart` | Grouped issue rows with severity badges | `GovernanceIssueGroupData` |
| `GovernanceStorySummary` | `widgets/governance_story_summary.dart` | Risk story panel with severity badges (`GovernanceStorySeverity`) | `GovernanceRiskStory` |
| `GovernanceBoundaryLegend` | `widgets/governance_boundary_legend.dart` | Canonicality legend (parent/child/generated/archive/mock) + read-only banner | `CanonicalityClass` |
| `ReviewPressurePanel` | `widgets/review_pressure_panel.dart` | Review queue pressure indicator by lane with severity badges | `ReviewPressureSummary` |
| `FanInHotspotsPanel` | `widgets/fan_in_hotspots_panel.dart` | High fan-in skill hotspots with severity badges | `FanInHotspot` |
| `GovernanceDrilldownController` | `widgets/governance_drilldown_controller.dart` | Drills from diagnostic → affected asset | `GovernanceDrilldownTarget` |
| `CanonicalityBoundarySummary` | `presentation/governance_overview_page.dart` | Count of assets by canonicality class | `WorkspaceSnapshot` |

### 2.6 Asset Detail Feature (`lib/features/asset_detail/`)

| Widget/Class | File | Purpose | Data Dependencies |
|-------------|------|---------|-------------------|
| `AssetDetailView` | `presentation/asset_detail_view.dart` | Router: dispatches to kind-specific detail views. Handles loading/error/empty. | `AssetDetailResult` |
| `AssetDetailConsumer` | `presentation/asset_detail_consumer.dart` | Riverpod consumer that resolves asset by ID | asset ID |
| `AssetDetailController` | `application/asset_detail_controller.dart` | Fetches asset + related assets from `WorkspaceSnapshot` | `WorkspaceSnapshot` |
| `AssetDetailDescriptor` | `domain/asset_detail_descriptor.dart` | Descriptor: sections, properties, links — used by all detail views | — |
| `AgentDetailView` | `presentation/agent_detail_view.dart` | Agent-specific detail: role, model, skills, workflows, task involvement | `WorkspaceAsset` |
| `SkillDetailView` | `presentation/skill_detail_view.dart` | Skill-specific detail: triggers, subskills, workflows, scripts, references, links | `WorkspaceAsset` |
| `WorkflowDetailView` | `presentation/workflow_detail_view.dart` | Workflow-specific detail: kind, skills, agents, triggers | `WorkspaceAsset` |
| `TaskDetailView` | `presentation/task_detail_view.dart` | Task-specific detail: metadata, lane, dependencies, proof, evidence, related changelog/skills | `WorkspaceAsset` |
| `ChangelogDetailView` | `presentation/changelog_detail_view.dart` | Changelog-specific detail: date, type, project, task, impact, skills, body | `WorkspaceAsset` |
| `GenericAssetDetailView` | `presentation/generic_asset_detail_view.dart` | Fallback detail for unsupported kinds; shows partial-support banner | `WorkspaceAsset` |
| `ResponsiveDetailShell` | `presentation/responsive_detail_shell.dart` | Responsive wrapper for detail views | — |
| `DetailSectionBuilder` | `presentation/detail_section_builder.dart` | Builds `DSDetailSection` list from `AssetDetailDescriptor` | — |
| `AssetDetailMapper` | `application/asset_detail_mapper.dart` | Maps `WorkspaceAsset` → `AssetDetailDescriptor` | — |

### 2.7 Shell Feature (`lib/features/shell/`)

| Widget/Class | File | Purpose | Data Dependencies |
|-------------|------|---------|-------------------|
| `ShellStateHandler` | `shell_state_handler.dart` | Abstract state handler for shell-level routing/navigation state | — |

### 2.8 Workspace Snapshot Feature (`lib/features/workspace_snapshot/`)

| Widget/Class | File | Purpose | Data Dependencies |
|-------------|------|---------|-------------------|
| `WorkspaceSnapshotPage` | `workspace_snapshot_page.dart` | Unified workspace page: topbar, tabs, content sections, metric tiles, lane summary, detail inspector | `WorkspaceSnapshotNotifier` |
| `WorkspaceSnapshotNotifier` | `workspace_snapshot_provider.dart` | Async notifier: loads `WorkspaceSnapshot`, manages search/filter/graph state | `WorkspaceSnapshot` |
| `WorkspaceSearchBar` | `widgets/workspace_search_bar.dart` | Search bar consuming provider state | provider search state |
| `WorkspaceFilterChips` | `widgets/workspace_filter_chips.dart` | Filter chips for kind/lane/provenance | provider filter state |
| `WorkspaceDerivedMetrics` | `widgets/workspace_derived_metrics.dart` | Metric tiles row (agents/skills/workflows/tasks/changelog/edges) | `WorkspaceSnapshot` |
| `WorkspaceDetailInspector` | `widgets/workspace_detail_inspector.dart` | Right-side inspector for selected asset with edge rows | selected asset |
| `WorkspaceGraphPanel` | `widgets/workspace_graph_panel.dart` | Graph mode toggle (containment/operational/evidence) + `DSGraphCanvas` | `GraphProjection` |
| `AgentListPanel` | `widgets/agent_list_panel.dart` | List of agent `DSAssetCard` | agents list |
| `SkillListPanel` | `widgets/skill_list_panel.dart` | List of skill `DSAssetCard` | skills list |
| `WorkflowListPanel` | `widgets/workflow_list_panel.dart` | List of workflow `DSAssetCard` | workflows list |
| `TaskLanePanel` | `widgets/task_lane_panel.dart` | `DSLaneBoard` with lane sections from snapshot | `WorkspaceSnapshot` |
| `ChangelogListPanel` | `widgets/changelog_list_panel.dart` | `DSTimeline` from changelog entries | changelog entries |
| `GraphProjection` | `workspace_snapshot_provider.dart` | Converts snapshot to `GraphNode`/`GraphEdge` | `WorkspaceSnapshot` |
| `GraphNode`, `GraphEdge` | `workspace_snapshot_provider.dart` | Local graph node/edge classes for workspace snapshot | — |

---

## 3. Data Models (lib/data/models/)

| Model | File | Purpose | Key Enums/Classes |
|-------|------|---------|-------------------|
| **Normalized Graph Backbone** | `workspace_graph.dart` | Canonical data contract for all parsers/repositories | `AssetKind` (9 kinds), `EdgeKind` (7 kinds), `Canonicality` (6 values), `WorkspaceAsset`, `WorkspaceEdge` |
| **Task Contracts** | `task_contracts.dart` | Typed task metadata from frontmatter | `TaskLane` (5 lanes), `ProofState` (none/partial/complete/verified), `TaskMetadata` |
| **Changelog Contracts** | `changelog_contracts.dart` | Typed changelog metadata from frontmatter | `ChangelogType` (8 types), `ChangelogMetadata` |
| **Governance Diagnostics** | `governance_diagnostics.dart` | Typed governance diagnostic primitives | `DiagnosticSeverity` (4 levels), `DiagnosticCategory` (9 categories), `GovernanceDiagnostic` |
| **Workspace Snapshot** | `workspace_snapshot.dart` | Aggregate workspace loading result | `WorkspaceSnapshot`, `WorkspaceScanMetadata` |
| **Legacy Models** | `models.dart` | Superseded — retained for backward compat | `Agent`, `Skill`, `Workflow`, `Task`, `ChangelogEntry`, `AssetType`, `AssetEdge` |
| **Data Models Barrel** | `data_models.dart` | Barrel export for all models | — |

---

## 4. Mock Workspace Corpus (assets/mock_workspace/)

### 4.1 Agents (9)

| Agent | File | Skills | Workflows |
|-------|------|--------|-----------|
| architect-orchestrator | `.agents/agents/architect-orchestrator.md` | project-management, harness-architecture, development-methodologies | gt-ganthritor-onboard, architect-orchestration, plan-evidence-to-tasks |
| builder-orchestrator | `.agents/agents/builder-orchestrator.md` | coding-execution-harness, frontend-quality-harness, design-system-harness | builder-orchestration, gt-code-review, gt-verify-task-completion |
| reviewer-orchestrator | `.agents/agents/reviewer-orchestrator.md` | code-quality-harness, project-management, agent-wiki | reviewer-orchestration, gt-code-review, gt-verify-task-completion |
| gt-harness-architect | `.agents/agents/gt-harness-architect.md` | harness-architecture, project-management | gt-harness-architecture, architect-orchestration |
| gt-code-quality-reviewer | `.agents/agents/gt-code-quality-reviewer.md` | code-quality-harness, agent-wiki | gt-code-review, gt-verify-task-completion |
| gt-security-reviewer | `.agents/agents/gt-security-reviewer.md` | code-quality-harness, external-intelligence | gt-code-review, gt-research-orchestration |
| gt-external-intelligence-analyst | `.agents/agents/gt-external-intelligence-analyst.md` | external-intelligence, browser-harness | gt-research-orchestration |
| gt-task-architect | `.agents/agents/gt-task-architect.md` | project-management, harness-architecture, development-methodologies | gt-create-tasks, plan-evidence-to-tasks, audit-tasks |
| gt-wave-orchestrator | `.agents/agents/gt-wave-orchestrator.md` | project-management, harness-architecture, agent-cli-delegation | gt-ganthritor-onboard, builder-orchestration, reviewer-orchestration |

### 4.2 Skills (13)

| Skill Directory | Triggers | Sub-skills |
|----------------|----------|------------|
| harness-architecture/ | create agent, create skill, create workflow, harness governance | create-agent, create-skill, create-workflow, harness-management |
| project-management/ | task management, changelog, handoff, agent memory | tasklist-sync, changelog-engine, manage-changelog, decompose-slices |
| development-methodologies/ | RF8, methodology, decomposition | rf8-methodology |
| code-quality-harness/ | review, audit, proof, verification, security, scoring | code-review, security-review, task-verification |
| coding-execution-harness/ | implement, code, build, develop | code-execution, frontend-execution |
| agent-wiki/ | learnings, decisions, errors, reviews, fixes, audits | — |
| indexing-skills/ | index, regenerate, rebuild | agent-index, skill-index, workflow-index |
| external-intelligence/ | research, analyze external, browser | browser-harness |
| frontend-quality-harness/ | frontend review, UI review, accessibility | frontend-accessibility, design-system-review |
| design-system-harness/ | design system, tokens, components | token-harvesting, component-catalog |
| browser-harness/ | browse, scrape, fetch web | — |
| remediation-harness/ | fix, repair, remediate | — |
| agent-cli-delegation/ | delegate, CLI, spawn | — |

### 4.3 Tasks (22 across 5 lanes)

| Lane | Count | Tasks | Operational States Found |
|------|-------|-------|--------------------------|
| 00-planning | 3 | T001, T002, T003 | status: planning, proof_state: none, priority: high/medium |
| 01-open | 5 | T004, T005, T006, T007, T008 | status: open, proof_state: none, priority: medium/low |
| 02-doing | 5 | T009, T010, T011, T012, T013 | status: doing, proof_state: none/partial, priority: high/medium, review_score: 7.5/8.0 |
| 03-review | 4 | T014, T015, T016, T017 | status: review, proof_state: partial/complete/none, priority: high/medium, review_score: 8.0/8.5/7.0 |
| 04-completed | 5 | T018, T019, T020, T021, T022 | status: completed, proof_state: complete, priority: high/medium, review_score: 9.0-9.5 |

### 4.4 Changelog Entries (28+)

Total: 35 changelog entries under `docs/changelog/`. Types found: feature, fix, refactor, docs, chore. Impacts include: parser, graph-model, agent-corpus, skill-hierarchy, workflow-fixtures, ds-tokens, frontmatter, task-board, changelog-renderer, edge-inference, spacing, sidebar, topbar, metric-tiles, search-integration, manifest, changelog-migration.

---

## 5. Operational State Gaps (Current vs Required)

### 5.1 Current DSStateType (3 states)

Source: `lib/design_system/molecules/ds_state_surface.dart` line 194

```
enum DSStateType { empty, loading, error }
```

This only covers **data-loading states**, not operational states of the workspace entities themselves.

### 5.2 Existing State Scattered Across Components

| Component | States Implemented | Gap |
|-----------|-------------------|-----|
| `DSTaskCard` | proofState: complete/partial/missing/none; priority: P0/P1/P2 | Missing: running, approved, rejected, blocked, stale |
| `DSProvenancePill` | canonicality: parentCanonical/childLocal/generated/appendOnly/archive/mock | Adequate for canonicality |
| `DSEvidenceRow` | evidence: verified/partial/missing/pending | Adequate for evidence |
| `DSSemantics` | proof: complete/partial/missing/pending | Incomplete — see vocabulary |
| `DSStatusDot` | success/warning/error/info/neutral | Missing: degraded, disabled, running |
| Mock tasks | status: planning/open/doing/review/completed; proof_state: none/partial/complete | Missing: healthy, degraded, disabled, pending, running, approved, rejected, redacted, exposed, stale, unverified, promoted, archived |

### 5.3 Required Expansion

See `docs/design/operational-state-vocabulary.md` for the comprehensive 14+ state vocabulary that addresses these gaps.

---

## 6. Component Classification: MVP / Defer / Discard / Needs Research

### MVP (Required for first working prototype)

All tokens (8), all atoms (8), all molecules (9), all organisms (8), all templates (3), gallery, and the following features: Shell, Overview, Map (catalog + graph), Operate (lane board), History (timeline), Governance (diagnostics), Asset Detail (all kind variants), Workspace Snapshot.

### Defer (After Melos migration, per EPIC-11 Wave 2-3)

| Component | Reason | Task |
|-----------|--------|------|
| Data Table | Critical gap — not yet implemented | Task 1112 |
| Command Palette | Critical gap — not yet implemented | Task 1113 |
| Log/Event Viewer | Critical gap — not yet implemented | Task 1114 |
| Loading Skeleton | Important gap — only spinner exists | Task 1115 |
| Error Boundary | Important gap — not yet implemented | Task 1115 |
| Notification Toast | Important gap — not yet implemented | Task 1116 |
| Drag-and-Drop Task Board | Important gap — lane board has no DnD | Task 1120 |
| Health Dashboard Components | Partial — DSStatusDot + DSMetricTile exist but no compound health cards | Task 1119 |

### Needs Research

| Item | Question | Evidence |
|------|----------|----------|
| Graph layout algorithms | Current DSGraphCanvas only has force-directed. Need hierarchical/tree, layered DAG, radial. What is the best Flutter graph layout library? | `docs/reports/ads-gap-analysis-20260608.md` GAP-I1 |
| Inter font | Not declared in pubspec.yaml. Should we add Inter or use system sans-serif? | `docs/reports/warp-prism-ds-inventory.md` §9.2 |
| ThemeExtension bridge | DS tokens are static constants; no Theme.of(context) integration. Is ThemeExtension needed? | `docs/reports/warp-prism-ds-inventory.md` §9.2 |

---

## 7. Source Evidence

| Source | Relevance |
|--------|-----------|
| `lib/design_system/` (38 files) | Direct DS component inspection |
| `lib/features/` (62 files) | Feature-level widget inspection |
| `lib/data/models/` (7 files) | Data model and enum inspection |
| `assets/mock_workspace/` | Mock corpus counts and frontmatter patterns |
| `docs/reports/warp-prism-ds-inventory.md` | Prior DS inventory (Task 0014) |
| `docs/reports/ads-gap-analysis-20260608.md` | ADS gap analysis — 8 present, 6 partial, 6 missing |
| `docs/reports/cybercore-domain-ui-mapping-20260608.md` | CyberCore entity → component → screen mapping |
| `docs/prompt.txt` | Original product contract (784 lines) |
| `docs/design/charter.md` | Project charter (Task 1101) |
| `docs/tasks/00-planning/EPIC-00` through `EPIC-11` | All 12 EPIC planning artifacts |
