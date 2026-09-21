# Interaction Inventory — warp_prism_ui (Evidence-Driven)

> **Provenance**: Task 1814 · audit date 2026-09-01 · method: full `rg` sweep of
> `packages/warp_prism_ui/lib/` for `selected|onSelect|onTap|onSelection|onExpand|onToggle|`
> `onLocate|onCommand|onQuery|onCell|onSpan|onLauncher`, plus consumer sweep of
> `apps/{observatory,cybercore,catalog}`. Every claim carries `file:line` evidence.
> **Consumer of this doc**: Task 1815 (IDS candidate kernel) — it may admit ONLY
> recurrence-proven primitives (≥2 distinct consumers OR ≥2 distinct domains).

## 1. Evidence Table — Selection / Inspection State Per Component

State location kinds: **local** = private State field; **prop** = controlled widget
property; **controller** = ChangeNotifier owned outside the widget tree.

| Component | Path:line | Selection state (location) | Callback pattern | Domains (apps + gallery demo) |
|---|---|---|---|---|
| GraphCanvas | `organisms/graph/graph_canvas.dart:133` | `GraphNodeId? _selectedNodeId` (local) | `onNodeTap` :78, `onNodeDoubleTap` :81 | observatory (map_graph_panel.dart:28, workspace_graph_panel.dart:86), gallery |
| DSGraphCanvas (legacy wrapper) | `organisms/ds_graph_canvas.dart:111` | delegates (none) | `onNodeTap` :111, :121, :185-188 | same as GraphCanvas |
| WorkflowCanvasStage | `organisms/workflow_canvas_stage/ds_workflow_canvas_stage.dart:562-565` | `selectedNodeId` / `selectedEdgeId` (props) | `onNodeSelected` :568, `onEdgeSelected` :571, `onSelectionChanged` :574, `onSelectionCleared` :577 | gallery (:5907) |
| LogViewer | `organisms/log_viewer/ds_log_viewer.dart:63` | `Set<String> _expandedIds` (local) | `onEntryTap` :34, :307 | cybercore (live_logs_page.dart:116), gallery |
| ExecutionConsole (controller) | `organisms/execution_console/ds_execution_console.dart:288` | `String? _selectedRunGroupId` (controller `DSExecutionConsoleController` :285) | `onRunGroupSelected` :451, internal `onGroupSelected` :1023 | gallery (:3817) |
| ExecutionConsole (uncontrolled view) | `organisms/execution_console/ds_execution_console.dart:541` | `String? _uncontrolledSelectedId` (local) | `_selectGroup` :696 | gallery |
| DataTable | `organisms/data_table/ds_data_table.dart:1021` | `late Set<String> _selectedIds` (local, multi + select-all :1058-1063) | `onSelectionChanged` :946, row `onSelect` :683, :791 | cybercore (providers_page.dart:135, mcp_inspector_page.dart:135), catalog (widget_test.dart:321), gallery |
| StatusTicker | `organisms/status_ticker/ds_status_ticker.dart:275` | none (stateless tap) | `onItemTap` :275 via `_StatusChip.onTap` :698 | gallery (:6259) |
| MapCanvasStage | `organisms/map_canvas_stage/ds_map_canvas_stage_controller.dart:109` | `String? _selectedFeatureId` (controller) + listener bus `addSelectionListener` :301 | `onSelectionChanged` :48 (ds_map_canvas_stage.dart), event :153 | gallery placeholder (:6141) |
| McpCapabilityInspector | `organisms/mcp_capability_inspector/ds_mcp_capability_inspector.dart:498-501` | `selectedKind` / `selectedItemId` (props) + `initialSelection` :504 | `onSelectionChanged` :507, `onCapabilityChanged` :510 | gallery (:3710); cybercore MCP pages use PrismDataTable instead (mcp_inspector_page.dart:135) |
| Timeline | `organisms/ds_timeline.dart:11` | `selectedId` (prop, both variants :92) | `onEntryTap` :12, :59, :93, :160 | observatory (history_page.dart:274, :277, :300, :323; overview_page.dart), gallery |
| Tree | `organisms/tree/ds_tree.dart:45` | `selectedId` (prop) | `onNodeSelected` :48, row `onSelect` :279, `onToggleExpand` :280 | gallery |
| LaneBoard | `organisms/ds_lane_board.dart:19` | none (external) | `onTaskTap` :19, :92 | observatory (operate_workspace_view.dart:174) |
| Sidebar | `organisms/ds_sidebar.dart:13` | `selectedId` (prop) | `onItemTap` :13 | observatory (app_shell.dart:23), cybercore (cybercore_shell.dart:26) |
| MasterDetailTemplate | `templates/master_detail_template.dart:32` | `selectedIndex` (prop; :274) + `selectedEntry` :432 | `onItemTap` :113, :324, :464; `onEntryTap` :487 | gallery (text preview only, :3854 — no live instantiation; observatory deliberately composes primitives instead, operate_workspace_view.dart:5-6) |
| Accordion | `molecules/accordion/ds_accordion.dart:107` | `expandedIndices` (prop) + `_uncontrolledExpanded` :162 (local) | `onSectionToggled` :101, `onExpandedIndicesChanged` :104 | gallery (9 refs) |
| DSSelect | `molecules/select/ds_select.dart:42-49` | value (prop, single) + `_selectedItem` :165 | `onChanged` :49 | gallery (14 refs; :6317) |
| CommandPalette | `organisms/command_palette/ds_command_palette.dart:115` | `int _selectedIndex` :115, `DSCommandCategory? _activeCategory` :116 (local) | `onCommandTap` :306, :563 | gallery |
| EntityLocateSearch | `organisms/entity_locate_search/ds_entity_locate_search.dart:835` | internal `_select(result)` :812 (local) | `onLocate` :362 (payload `DSLocateResult` :218), `onQueryChanged` :365, row `onSelect` :835 | gallery (:5587) |
| TerminalWorkspace | `organisms/terminal_workspace/ds_terminal_workspace.dart:30` | none (command passthrough) | `onCommandSubmitted(paneId, command)` :30, :616 | gallery |
| ProviderHealthMatrix | `organisms/provider_health_matrix/ds_provider_health_matrix.dart:185` | none (cell tap) | `onCellSelect` :185, :400 | catalog (visual_acceptance_capture_test.dart:160), gallery |
| TrafficInspector | `organisms/traffic_inspector/ds_traffic_inspector.dart:652` | none | `onTabSelect` :652, :728 | gallery |
| TimingWaterfall | `organisms/timing_waterfall/ds_timing_waterfall.dart:198` | none | `onSpanSelect` :198 | gallery |
| OsintWorkbench | `organisms/osint_workbench/ds_osint_workbench.dart:554` | none | `onHistorySelect` :554 | gallery |
| OpsControlCluster | `organisms/ops_control_cluster/ds_ops_control_cluster.dart:193` | none | `onLauncherActivate` :193 | gallery |
| Breadcrumbs | `organisms/breadcrumbs/ds_breadcrumbs.dart:59` | none | `onItemTap` :59 (collapsed overflow menu wires it :237-240) | gallery (:6846, :6857) |
| ArtifactWorkbench | `organisms/artifact_workbench/ds_artifact_workbench.dart:262` | `selectedId` (prop) + `_uncontrolledSelectedId` :262 (local) | `onSelectionChanged` :169, tile `onSelect` :476 | gallery |
| ViewPresets | `organisms/view_presets/ds_view_presets.dart:36` | none | `onSelected` :36, :106 | gallery (:6443) |
| FilterChipGroup | `molecules/ds_filter_chip_group.dart:11-12` | `selected` Set (prop) | `onToggle` :12 | gallery |
| DSTabController | `organisms/tab_bar/ds_tab_controller.dart:22` | `int _activeIndex` (controller, ChangeNotifier) | `select(index)` ds_tab_bar.dart:195 | observatory (map_workspace_page.dart) |
| StatusGrid | `organisms/ds_status_grid.dart:71-74` | none | `onFilterToggle` :71, `onItemTap` :74 | gallery |

**Inspection surfaces** (selected-entity detail rendering): `DSDetailInspector`
(`organisms/ds_detail_inspector.dart:10-15`, sections + `onClose` :15), `DSEntityIntelPanel`
(`organisms/entity_intel_panel/ds_entity_intel_panel.dart:20` payload, dossier body builder),
MasterDetailTemplate detail pane (:481-487), McpCapabilityInspector detail (:1044),
ExecutionConsole structured output (:718), ArtifactWorkbench pane (:169-310).

### 1.1 Dedicated selection payload classes (4 — see §5 correction)

| Payload | Path:line | Shape |
|---|---|---|
| `DSWorkflowSelection` | `organisms/workflow_canvas_stage/ds_workflow_canvas_stage.dart:370-403` | `nodeId?`/`edgeId?`, `.cleared/.node/.edge` ctors |
| `DSMcpCapabilitySelection` | `organisms/mcp_capability_inspector/ds_mcp_capability_inspector.dart:435-455` | `kind` + `id` |
| `DSMapStageSelectionEvent` | `organisms/map_canvas_stage/map_stage_contracts.dart:182-235` | `kind` (selected/cleared) + `feature/featureId/layerId` |
| `DSEntitySelection` | `organisms/entity_intel_panel/ds_entity_intel_panel.dart:20-95` | `id/type/title/attributes` dossier descriptor |

## 2. Recurrence Classification (verdict per candidate primitive)

| Primitive | Distinct implementations | Distinct domains served | Verdict |
|---|---|---|---|
| **Selection** | 20+ components; 3 state locations (local field, controlled prop, controller/ChangeNotifier bus); 4 payload classes | observatory, cybercore, catalog, gallery | **RECURRENCE_PROVEN** |
| **Inspection** | 6 (DetailInspector, EntityIntelPanel, MasterDetail detail, McpInspector detail, ExecutionConsole output, ArtifactWorkbench) | observatory (asset_detail views ×5+), gallery | **RECURRENCE_PROVEN** |
| **Query** | 6+ (CommandPalette :123/:190, EntityLocateSearch :365, LogFilterBar :16-19, FilterChipGroup :11-12, SearchBar `ds_search_bar.dart:11`, StatusGrid :71) | cybercore (live_logs→LogViewer→LogFilterBar ds_log_viewer.dart:178), observatory (workspace_search_bar.dart), gallery | **RECURRENCE_PROVEN** |
| **Command-intent** | 3 (CommandPalette `DSCommand.onExecute` :45, TerminalWorkspace :30, OpsControlCluster :193) — three **divergent** shapes (closure-carrying, `(paneId, command)` tuple, launcher activate) | gallery only; zero app adoption (`PrismCommandPalette` obs/cyb/cat = 0) | **DEFERRED** — strongest deferred candidate: 3 divergent implementations signal consolidation pressure, but only 1 consuming domain today |
| **Navigation-intent** | 4 (Breadcrumbs :59, Sidebar :13, MasterDetail :113, DSTabController :22) — but all reduce to item-selection + app-owned routing | observatory, cybercore, gallery | **DEFERRED** — route transition is app/framework-owned (Breadcrumbs couples to `ModalRoute` :83; app GoRouter owns transitions); the recurring in-widget part is Selection (already proven) |
| **Viewport-state** | 3 (GraphCanvas `_panOffset`/`_scale` graph_canvas.dart:130-131, :252-253; TimeMachineScrubber `onPlayheadChanged`/`onRangeChanged` :163-166; VirtualScroll `itemExtent` :19-22) — three **unrelated** concerns: spatial camera, temporal window, virtualization extent | observatory (GraphCanvas camera), gallery (TimeMachine, VirtualScroll) | **DEFERRED** — no shared viewport semantics recur; each is mechanics-local (see §3) |

## 3. Counter-Examples — Not IDS Primitives

1. **Auto-scroll / follow-tail** — looks like "follow the stream" interaction semantics;
   actually per-widget `ScrollController` mechanics: LogViewer `_autoScroll` :64, user-scroll
   detection :90-94, jump :105, :116-116, :153 (ds_log_viewer.dart); AgentTranscript
   `scrollController` :59; TerminalWorkspace `maxScrollExtent` :512. **Correct home**:
   presentation/widget layer inside each streaming organism (or a future presentation-mode
   helper), not IDS semantic state.
2. **Health polling** — looks like a recurring interaction contract; actually explicitly
   excluded from this package: ProviderHealthMatrix doc "No live health endpoints, API keys,
   or polling in this package" (ds_provider_health_matrix.dart:168); fixture latencies only
   (:622-668). **Correct home**: runtime/app composition (product adapters feed health
   data in); UI stays fixture-driven.
3. **Viewport pan/zoom** — looks like a Viewport primitive; actually canvas mechanics:
   GraphCanvas `_panOffset` :130, `_scale` :131, gesture math :252-253, hit-test transform
   :270, drag physics :312; VirtualScroll fixed-extent offset math :19-22, :216-222.
   **Correct home**: GraphCanvas / virtual-scroll internals (widget mechanics), never an
   IDS semantic layer.
4. **Navigation / routing** — Sidebar/Breadcrumbs/MasterDetail `onItemTap` looks like a
   navigation-intent primitive; Breadcrumbs `autoDerive` reads `ModalRoute` (:83), proving
   route knowledge is framework/app-owned. **Correct home**: app GoRouter/Navigator owns
   transitions; the component-side recurrence is Selection (`selectedId`), already covered
   by the Selection primitive.
5. **Keyboard focus / activation mechanics** — Enter/Space activation looks like command
   semantics; actually pure input mechanics: DSInteractiveSurface shortcuts/actions :96-108,
   `_isFocused` :55, `_TreeRow` focus :306 (ds_tree.dart), terminal `_focusedPaneId`
   (ds_terminal_workspace_models.dart:92). **Correct home**: DSInteractiveSurface mechanics
   layer (§4) — the IDS kernel reuses it, never re-implements it.
6. **Command execution closures** — `DSCommand` carrying an embedded `onExecute` callback
   (:45) looks like a command-intent contract; the closure is an app-supplied side effect,
   not a reusable interaction semantic. **Correct home**: app/runtime command dispatch;
   an IDS Command-intent primitive (if ever admitted) must carry an intent **descriptor**,
   not a closure — and today only the gallery consumes it (§2, DEFERRED).

## 4. DSInteractiveSurface — Mechanics-Only, Reuse As Substrate

Confirmed mechanics-only with **zero** semantic interaction state:
`molecules/ds_interactive_surface.dart:16-145` (⚠ task background says
`atoms/interactive_surface/` — path drift; actual home is `molecules/`). It provides and
owns only: semantic `button/enabled/selected` **passthrough flags** (:81-87, input :19, :40),
keyboard focus tracking `_isFocused` :55 + focus ring :130-144, Enter/Space activation
:96-108, click cursor gating :114-117, 48×48 minimum touch target :118-121, tap plumbing
:111-113. It never stores which item is selected — `selected` is a rendered flag supplied
by the caller. **IDS kernel reuse contract**: a kernel selection state owns *which entity
is selected* and feeds two things into `DSInteractiveSurface` — the `selected:` flag for
a11y/rendering and `onTap` for activation routing. The kernel composes it as the mechanics
substrate (focus, keyboard, a11y, cursor, hit target) and must not duplicate or replace it.

## 5. DSWorkflowSelection — Selection Payload Status

`DSWorkflowSelection` (`ds_workflow_canvas_stage.dart:370-403`; task background says
370-402 — off by one) is the only **generic stage-level node/edge** selection payload:
mutually-exclusive `nodeId?`/`edgeId?`, named ctors `.cleared()` :380 / `.node()` :383 /
`.edge()` :386, `isEmpty/hasNode/hasEdge` :389-391, value equality :393-402. It is NOT the
only dedicated selection payload class in the package — §1.1 lists three more
(`DSMcpCapabilitySelection` :435, `DSMapStageSelectionEvent` :182, `DSEntitySelection`
:20). This is direct source evidence that selection payloads already recur in 4 divergent,
non-interoperable shapes — the strongest single argument for a kernel-owned selection model
in Task 1815.

## 6. Source-Reality Corrections to Task 1814 Background

1. `DSInteractiveSurface` path is `molecules/ds_interactive_surface.dart` (not
   `atoms/interactive_surface/`); line range 16-145 confirmed.
2. "Only `DSWorkflowSelection` is a dedicated selection payload class" is stale —
   4 exist (§1.1, §5).
3. "ExecutionConsole = `_uncontrolledSelectedId`" is incomplete — it ALSO has a
   controller-owned `String? _selectedRunGroupId` (:288) inside a `ChangeNotifier`
   (`DSExecutionConsoleController` :285), i.e. a third state-location kind (controller)
   beyond local/prop.
4. "10+ bespoke callback patterns" understates it: the sweep found 20+ distinct callback
   names across selection/tap/toggle intents (`rg` sweep, § header method).

## 7. Input Contract for Task 1815 (IDS Kernel)

The kernel may admit, on current source evidence ONLY: **Selection**, **Inspection**,
**Query** (§2). Selection must model the three observed state locations (local, controlled
prop, external controller) and subsume the 4 divergent payload shapes. Command-intent,
Navigation-intent, and Viewport-state stay in the candidate ledger until a second real
consumer/domain appears — per AGENTS.md §5 (promotion from observed recurrence) they must
NOT enter the kernel by name. Counter-examples in §3 are the rejection tests for future
admission decisions.
