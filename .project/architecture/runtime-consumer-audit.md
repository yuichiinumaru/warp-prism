# Runtime Consumer & Source Audit — Warp Prism v2

> **Status**: Active audit (evidence input for Task 1819 contract design)
> **Author**: Task 1818 — Runtime Consumer Source Audit
> **Date**: 2026-09-01
> **Depends on**: Task 1811 (`layer-contracts-v2.md`), Task 1812 (`package-topology.md`)
> **Blocks**: Task 1819 (experimental runtime contracts)
> **Method**: full read of the 4 candidate organism families + sweep of `apps/{observatory,cybercore,catalog}/lib`. Every claim carries `file:line` evidence. All 4 contracts start **EXPERIMENTAL** (lifecycle law, layer-contracts-v2 §3.2).

---

## 1. Contract Candidate Inventory

### 1.1 EventStream — 2 organism candidates, 1 live app consumer, 1 domain (event/log viewing)

| Consumer | Evidence | Data flowing through it | Semantics needed |
|---|---|---|---|
| `DSExecutionConsoleController` (alias `PrismExecutionConsoleController`, `prism_aliases.dart:676-677`) | `ds_execution_console.dart:285-406` (`_lines` :286, `appendLine` :364-367, `appendLines` :370-375, `setLines` :348, `clearLines` :378, `clear` :385) | `DSExecutionLine` (:124-197): id, message, level (stdout/stderr/info/warning/error/system :18-36), runGroupId, source, timestampLabel; grouped by `DSExecutionRunGroup` (:200-275) with lifecycle status `DSExecutionRunStatus` (:78-90) | Ordered append-only buffer (oldest→newest, :303), single + batch append, full replace, clear, growth notification via `ChangeNotifier`, stable event identity (`id`), severity channel, group attribution, run-status lifecycle |
| `DSLogViewer` (alias `PrismLogViewer`, `prism_aliases.dart:1130`) | `ds_log_viewer.dart:30` (`entries` full list), growth detect `didUpdateWidget` :150-158; app consumer: `live_logs_page.dart:116-119` (PrismLogViewer, `autoScroll: false`, `showAbsoluteTime: true`) | `DSLogEntry` (`ds_log_entry_model.dart:12-27`): id, timestamp (DateTime), severity (`ds_log_severity.dart:11-26`), source, message, detail (+`hasDetail` :30); cybercore maps `LiveLogEntry` fixtures → `PrismLogEntry` (`live_logs_page.dart:79-88`, severity map :129-140) | Receives a **complete list**, not a stream — new-entry detection is `entries.length > old.length` (:153); severity/source/text filtering is **presentation** (:122-143); expandable detail entries (:63); virtualized rendering for 10K+ entries (doc comment :20) |
| (adjacent, not a candidate) observatory state streams | `StreamController<MapWorkspaceState>.broadcast()` `map_workspace_provider.dart:34` consumed via `StreamBuilder` `map_workspace_page.dart:177`; same pattern `OperateWorkspaceViewModel` `operate_workspace_view_model.dart:38, :53` → `StreamBuilder` `operate_workspace_view.dart:54` | Full state snapshots, not events — every emission replaces the whole board/map state | Distinguishing evidence: Warp Prism's real apps use **state-diff streams** (latest-wins broadcast), while the organisms need **append-only event streams**. EventStream must model append semantics, not state snapshots. |

**Consumer count (updated)**: 2 candidate components — same domain (event/log viewing), refining the prior "EventStream≈2 candidates (same domain)". Sharper still: only **one** candidate has a live app consumer (cybercore `/live-logs`), and that consumer feeds a static fixture list, not a live stream. ExecutionConsole app consumers = **0** (gallery demo `design_system_gallery_sections.dart:3817-3825` + package tests `test/organisms/execution_console/ds_execution_console_test.dart` only).

### 1.2 GraphSource — 2 candidate stages, 1 live app consumer, 1 domain (workspace graphs)

| Consumer | Evidence | Semantic vs layout mixing |
|---|---|---|
| `GraphCanvas` (typed model; `PrismGraphCanvas` = legacy wrapper `ds_graph_canvas.dart:108-130`, alias `prism_aliases.dart:1256`) | `graph_canvas.dart:67-106`; model `graph_model.dart:58-127` — `GraphNode` carries `position: Offset` (:64) **and** includes position in equality/hash (:113-123) | Semantic: id (:59, typed `GraphNodeId` :13-27), label, type, status, metadata, edges (`GraphEdge` :130-173, typed `GraphEdgeId` :32-51), adjacency queries `edgesForNode`/`adjacentNodes` (:193, :200), `GraphModel` lookup (:178-244). Layout: position :64; live pan/zoom/physics is already widget-local (`_positions` :122, `_velocities` :125, `_draggingNodes` :128, `_panOffset` :130, `_scale` :131, physics `AnimationController` :151-158, seed `_initializePositions` :161-191) |
| `DSWorkflowCanvasStage` (alias `PrismWorkflowCanvasStage` `prism_aliases.dart:609`) | `ds_workflow_canvas_stage.dart:554-886`; `DSWorkflowNode` :180-262 — `position: Offset?` (:193-194, "auto-layout when null" :174), equality includes position (:249-261) | Semantic: id :182, label :184, `kind` (`DSWorkflowNodeKind` :20-50, 10 semantic pipeline kinds), status :190, metadata :196; `DSWorkflowEdge` :275-362 with 5 semantic kinds `DSWorkflowEdgeKind` :53-68. Layout: optional position + deterministic DAG auto-layout `DSWorkflowCanvasLayout` (:412-514, preserves explicit positions :489-491, canvas size fit :502-513). **App consumers = 0** (gallery demo :5907 only) |
| Legacy `DSGraphCanvas` wrapper | `ds_graph_canvas.dart:29-79` | Worst mixing: mutable `position` :35, `velocity` :36, `isDragging` :37, `isHovered` :38, `isSelected` :39 all live on the node class itself; converts to typed model per build (:134-160) |

**App consumer (the split point, already working in practice)**: observatory projects `WorkspaceAsset`/`WorkspaceEdge` (semantic, **Offset-free**: `workspace_graph.dart:88-131`, `:197-215`) into `PrismGraphNode` **without position** — `map_graph_projection.dart:99-111`, `workspace_graph_panel.dart:28-47`; the canvas re-seeds positions internally (`graph_canvas.dart:161-191`). Live canvas consumers: `map_graph_panel.dart:54-58` and `workspace_graph_panel.dart:82-89` (with `onNodeTap` → asset selection). Two more projection layers exist (`workspace_snapshot_provider.dart:209-234, :240-314` — local GraphNode/GraphEdge without position), confirming the pattern recurs.

### 1.3 HealthSource — 0 consumers (fixture-only, stateless organism)

`DSProviderHealthMatrix` (alias `PrismProviderHealthMatrix` `prism_aliases.dart:477`) is a `StatelessWidget` (`ds_provider_health_matrix.dart:169`) whose own contract states "No live health endpoints, API keys, or polling in this package" (:168). It consumes immutable `DSProviderHealthCell` (:18-52: id, providerId/Label, dimensionId/Label, `DSOperationalState`, `latency: Duration?`, meta) + provider rollup (`DSProviderHealthProvider.effectiveAggregate` :146-150, worse-state fold :579-601 over the 15-state vocabulary `ds_operational_state.dart:18-70`). Current consumers: gallery fixture (`design_system_gallery_sections.dart:3687-3691`) and one catalog integration test (`visual_acceptance_capture_test.dart:160-169`) — **0 app-runtime consumers**. **Zero polling**: `grep -rn "Timer.periodic" apps/*/lib/` → **0** hits; the only two `Timer.periodic` in the repo are presentation timers (`ds_status_ticker.dart:446` rotation; `ds_time_machine_scrubber.dart:367` playback) — neither is health. CyberCore's `ProviderConnection.testStatus/lastTested/lastError` → `operationalLabel` (`provider_connection.dart:14-20`, `:41-51`) and `McpServer.errorStatus` → `operationalLabel` (`mcp_server.dart:19-20`, `:42-46`) are the natural future projection sources — one-shot fixtures today.

### 1.4 AsyncCommand — ad-hoc ×2 loading apps + 1 sync paradigm (3 paradigms, 2 real)

| App | Representation | Evidence |
|---|---|---|
| Observatory | Riverpod `AsyncValue` + `AsyncNotifier.reload()` | backbone `workspace_providers.dart`: snapshot notifier :62-83 (reload :69-74 = `state=AsyncLoading` → `AsyncValue.guard`), graph :101-123 (rebuild :118-122), metrics :140-148, diagnostics :164-172, history :196-219, view-model FutureProviders :226-261; feature variant `workspace_snapshot_provider.dart:30-52` (reload :40-44); family projection `asset_detail_controller.dart:173-203`; 12+ `.when()` consumers (e.g. `overview_page.dart:72-87`, `workspace_snapshot_page.dart:107-154`, `map_page.dart:26`, `asset_detail_page.dart:116`) |
| CyberCore | Per-page local triple state `_data? / _loading / _error` | 6 pages, same shape: `live_logs_page.dart:16-18`, `providers_page.dart:21-23`, `provider_detail_page.dart:17-19`, `mcp_servers_page.dart:19-21`, `mcp_server_detail_page.dart:17-19`, `mcp_inspector_page.dart:16-18`; `_loadData()` try/catch → `e.toString()` (e.g. `live_logs_page.dart:26-43`) with `mounted` guards |
| Catalog | `ValueNotifier<CatalogThemeVariant>` — **sync theme selection only, zero async commands** | `main.dart:19-20`, consumed via `ValueListenableBuilder` :30-32 + `ListenableBuilder` on `PrismTokenRegistry.instance` :27-29 |

**Refinement of the prior "ad-hoc×3 apps"**: 3 paradigms exist, but only **2 apps run async loads** (observatory ~6 provider families; cybercore 6 pages × identical boilerplate). Catalog's ValueNotifier is a sync preference toggle, not a command consumer — the recurrence pressure for AsyncCommand comes from observatory+cybercore (2 distinct apps, 2 distinct state idioms).

---

## 2. Presentation-Purge Map

| Consumer | Entangled presentation policy | Evidence | Correct home |
|---|---|---|---|
| ExecutionConsole | `autoScroll` prop + `_autoScroll`/`_userScrolledUp`/`_programmaticScroll`, scroll-to-bottom on growth, pause-on-user-scroll (20px threshold), "Latest" resume chip | `ds_execution_console.dart:465, :510, :542-544, :611-614, :627-635, :637-648, :650-662, :664-670, :969-1004` | widget/IDS (per-widget ScrollController mechanics — interaction-inventory §3.1) |
| LogViewer | `autoScroll`, `_expandedIds`, `_searchQuery`, severity/source filter sets, filtered-count label, resume chip | `ds_log_viewer.dart:39-40, :50, :60-68, :84-98, :114-120, :150-158, :221-270`; filter bar `ds_log_filter_bar.dart:41-90` | widget/IDS (Query is IDS-proven per interaction-inventory §2; scroll viewport stays mechanics) |
| GraphCanvas | pan/zoom clamp (0.3–3.0), physics animation loop, drag velocities, hit-test transform | `graph_canvas.dart:130-131, :151-158, :250-255, :269-279` | widget mechanics (never IDS semantic — interaction-inventory §3.3) |
| WorkflowCanvasStage | DAG layout + dual-axis viewport scroll | `ds_workflow_canvas_stage.dart:746-748, :767-769` | widget |
| ProviderHealthMatrix | min cell width, horizontal scroll fallback | `ds_provider_health_matrix.dart:200, :246-257, :285-295` | widget |
| Observatory command surfaces | retry buttons / rescan icons wired to `ref.invalidate`/`reload()` | `overview_page.dart:80, :85`; `workspace_snapshot_page.dart:115-117, :243-244`; cybercore retry buttons `live_logs_page.dart:58-65` et al. | composition/app (retry policy is not command semantics) |

**Explicit purge rules (law for Task 1819)**:

1. **EventStream owns** subscription / ordering / delivery / completion / error / backpressure **ONLY**. Auto-scroll, follow-tail, viewport, pause-on-scroll, filtering, expandedIds → **presentation (widget/IDS)**.
2. **HealthSource owns** snapshot / watch / freshness **ONLY**. Polling intervals, retry, refresh-on-focus → **composition layer**.
3. **AsyncCommand owns** execute / result / error / cancellation **ONLY**. Retry policy → **composition layer**.
4. **GraphSource owns** semantic identity / relations / payload **ONLY**. Position, physics, pan/zoom, selection → **ui/binding**.

These match the runtime-row MUST-NOT law (`layer-contracts-v2.md` §2: "MUST NOT contain presentation policy (e.g. auto-scroll, follow-tail, retry timers)") and the rejected-idea ledger (source-reality review §G: "auto-scroll/follow-tail/viewport in EventStream — REJECTED, never; wrong layer by definition").

---

## 3. Semantic vs Layout Separation for Graph Models

The mixing point is `position: Offset` on otherwise-semantic node classes (`graph_model.dart:64`; `ds_workflow_canvas_stage.dart:193-194`), which makes layout drift alter semantic equality (`graph_model.dart:113-123`; `ds_workflow_canvas_stage.dart:249-261`) — and, in the legacy wrapper, mutating interaction flags (`ds_graph_canvas.dart:35-39`) plus a `copyWith` that drops them (:54-79).

**The split already exists in observatory**: `WorkspaceAsset`/`WorkspaceEdge` are Offset-free semantic models (`workspace_graph.dart:88-131`, `:197-215`), and both projections (`map_graph_projection.dart:99-111`, `workspace_graph_panel.dart:28-47`, `workspace_snapshot_provider.dart:209-234`) strip layout before reaching the canvas; positions are then owned exclusively by `GraphCanvas` internals (`:122`, `:161-191`). `DSWorkflowNode.toGraphNode` (:238-247) is the in-package bridge that re-injects position at the composition boundary — the correct pattern.

**Task 1819 boundary**: `warp_prism_runtime` DTOs own id, kind, label, status, typed directed edges, adjacency, metadata payload; they **MUST NOT carry** `Offset`, velocity, physics flags, or selection state (Model Ownership Rule, layer-contracts-v2 §4.3; package-topology §5). Open mapping decision: three divergent kind vocabularies exist today — `GraphNode.type` strings (`graph_model.dart:61`), `DSWorkflowNodeKind` (:20-50, with `graphType` adapter :117-128), observatory `AssetKind` (`workspace_graph.dart:17-27`, projected via `kind.name` `map_graph_projection.dart:103`) — plus 3 edge vocabularies (`GraphEdge.edgeType`, `DSWorkflowEdgeKind`, `EdgeKind` :32-53).

## 4. Command-State Census Across Apps

| App | Loading | Error | Success | Cancellation | Retry |
|---|---|---|---|---|---|
| Observatory | `AsyncLoading` (`workspace_providers.dart:71`) | `AsyncValue.error` + typed `WorkspaceLoadState.error` with message (`workspace_load_state.dart:12-25`, `:32-106`) | data + **distinct empty status** (:63) | **none** | `ref.invalidate` / `reload()` (`overview_page.dart:80`) |
| CyberCore | `_loading` bool | `_error` String? (`e.toString()`) | nullable data; empty conflated with `data.isEmpty` (e.g. `live_logs_page.dart:69-74`) | **none** (only `mounted` guards `:29-41`) | setState reset + re-call `_loadData()` (`live_logs_page.dart:58-65`; identical in all 6 pages) |
| Catalog | n/a (sync) | n/a | `ValueNotifier` theme value | n/a | n/a |

**Shared AsyncCommand would unify**: a single execute → loading/result/error tri-state, errors carrying a typed message, and a manual re-execute trigger — eliminating cybercore's 6× duplicated `_loadData` boilerplate and matching observatory's AsyncValue shape. **Stays app-local**: Riverpod wiring, GoRouter, fixture loaders, the empty-vs-error distinction (observatory models it in `WorkspaceLoadStatus`; cybercore does not), and retry-presentation (`PrismStateSurface.error` onAction). **Cancellation has zero consumers today** — 1819 should expose at most a hook, not machinery.

## 5. Health Surface Reality

ProviderHealthMatrix is stateless today; a `HealthSource` contract would project **onto the existing cell model unchanged** — provider/dimension identity, `DSOperationalState`, latency, and (new) a freshness timestamp — with the organism continuing to receive an immutable list per build. Nothing in the current surface needs watch semantics: **0 polling consumers exist today** (`Timer.periodic` in `apps/*/lib` = 0). Any watch/stream freshness capability stays EXPERIMENTAL until a real consumer appears; the OmniRoute provider-management pilot is the recorded future candidate (source-reality review §EPIC-OR).

## 6. Consumer Requirements Table (direct input to Task 1819)

| Contract | MUST (evidence-backed) | MUST NOT (presentation, purged) | Open questions |
|---|---|---|---|
| **EventStream** | ordered append (oldest→newest `:303`), single + batch append (:364, :370), full replace/clear (:348, :378, :385), stable event id, severity channel, source attribution, timestamp, group key (runGroupId), growth notification, state-diff (latest-wins, `map_workspace_provider.dart:34`) vs append-only (`ds_execution_console.dart:286`) distinction | auto-scroll, follow-tail, viewport, filters, expandedIds, pause-on-scroll | backpressure (today unbounded `_lines`), completion event, stream-level error vs error-line, cursor/resume (no consumer) |
| **HealthSource** | snapshot of cells (identity + operational state + latency), derived aggregate rollup (:146-150), selection callback (`onCellSelected` :185) | polling interval, retry, refresh-on-focus, any Timer | watch vs snapshot-only, freshness field shape, dimension-axis semantics |
| **GraphSource** | stable node id, node kind, label, status, typed directed edges with kind, adjacency queries (:193, :200), metadata payload | position/Offset, velocity, physics, pan/zoom, selection, hover | incremental updates (today full rebuild per `didUpdateWidget` :209-230), kind vocabulary mapping, edge-id scheme |
| **AsyncCommand** | execute, loading, typed error, result, manual re-execute | retry policy, auto-invoke, progress UI | cancellation hook (0 consumers), empty-as-distinct-result-state |

All four remain single-domain or zero-consumer today — none qualifies as PROVEN (needs ≥2 distinct consumers or domains, layer-contracts-v2 §3.2); experimental lifecycle applies to each.

### 6.1 Requirement Dispositions & Layer Reconciliations

- **`HealthSource.onCellSelected` Disposition**: Reconciled as **COMPOSITION-OWNED / INTERACTION-OWNED** per the Presentation-Purge Law (`layer-contracts-v2.md` §2 and §4.3). While §6 table records `onCellSelected` as an organism-level consumer callback on `DSProviderHealthMatrix` (:185), cell selection, focus states, and interactive gesture handling are strictly prohibited from backend-agnostic runtime contracts in `warp_prism_runtime`. The `HealthSource` contract exposes pure semantic health cells, aggregated states, snapshots, and freshness metadata; selection dispatch is owned by the UI presentation and interaction layers (`warp_prism_ui`, `warp_prism_interaction`, `warp_prism_bindings`).
- **EventStream stable identity → PAYLOAD-OWNED** (`RuntimeEvent.id`; generic `T` unconstrained by design per `layer-contracts-v2.md` §2). `EventStream<T>` remains generic so `T` may be any type without forcing an identity base class constraint (`T extends Identifiable`). When stable event identity, severity channel, timestamp, source, or run-group correlation is needed, consumers use the identity-bearing reference model `RuntimeEvent<T>` (which carries `id`, timestamp, severity, source, and runGroupId).
- **EventStream growth notification → DELIVERY-OWNED** (subscription delivery is the notification; `currentEvents` = retained snapshot per `layer-contracts-v2.md` §2). Stream delivery across `stream` and `subscribe` directly delivers every appended event to active subscribers in FIFO order, acting as the formal growth notification mechanism; `currentEvents` provides the retained snapshot buffer. No separate growth event channel exists because it would duplicate stream delivery.

---

## 7. Validation Evidence (recorded 2026-09-01)

```bash
grep -cE "EventStream|HealthSource|GraphSource|AsyncCommand" docs/architecture/runtime-consumer-audit.md   # 19
grep -cE "[Pp]resentation [Pp]urge|auto-scroll|follow-tail" docs/architecture/runtime-consumer-audit.md     # 4
grep -c "Timer.periodic" docs/architecture/runtime-consumer-audit.md                                       # 4 (0-polling evidence note)
grep -c "\.dart:" docs/architecture/runtime-consumer-audit.md                                               # 25 (file:line citations)
wc -l docs/architecture/runtime-consumer-audit.md                                                          # 141
grep -rn "Timer.periodic" apps/*/lib/ | wc -l                                                              # 0 → 0-polling claim physically confirmed
cd packages/warp_prism_ui && dart run test/boundaries/boundary_test.dart --repo-root ../..                 # see 7.1
```

### 7.1 Boundary harness (read-only confirmation)

`dart run test/boundaries/boundary_test.dart --repo-root ../..` was executed from
`packages/warp_prism_ui` as a read-only confirmation that the audit introduced no
boundary violations (Check 1: CyberCore zero `DS*` refs; Check 2: no `src/` imports in
apps; Checks 3-7 per `layer-contracts-v2.md` §5). Exact output recorded in Task 1818
completion evidence. This task wrote only `docs/architecture/runtime-consumer-audit.md`
— zero source files were modified, so the harness result is unchanged by this task
by construction.

## 8. Sources Read (37 files, read-only)

**warp_prism_ui organisms/tokens (11)**: `ds_execution_console.dart`, `ds_log_viewer.dart`, `ds_log_filter_bar.dart`, `ds_log_entry_model.dart`, `ds_log_severity.dart`, `graph_canvas.dart`, `graph_model.dart`, `ds_graph_canvas.dart` (legacy), `ds_workflow_canvas_stage.dart`, `ds_provider_health_matrix.dart`, `ds_operational_state.dart`.
**Observatory (14)**: `workspace_providers.dart`, `workspace_snapshot_provider.dart`, `workspace_load_state.dart`, `workspace_graph.dart` (model), `workspace_graph.dart` (result), `map_graph_projection.dart`, `map_graph_mode.dart`, `map_graph_panel.dart`, `workspace_graph_panel.dart`, `map_workspace_provider.dart`, `map_workspace_page.dart`, `map_workspace_state.dart`, `operate_workspace_view_model.dart`, `overview_page.dart`, `asset_detail_controller.dart`, `workspace_snapshot_page.dart`.
**CyberCore (10)**: `live_logs_page.dart`, `providers_page.dart`, `provider_detail_page.dart`, `provider_new_page.dart`, `mcp_servers_page.dart`, `mcp_server_detail_page.dart`, `mcp_inspector_page.dart`, `fixture_loader.dart`, `provider_connection.dart`, `mcp_server.dart`, `live_log_entry.dart`.
**Catalog (1)**: `main.dart`.
**Docs/harness (5)**: `layer-contracts-v2.md`, `package-topology.md`, `interaction-inventory.md`, source-reality review 2026-08-31, gallery sections + boundary harness (`boundary_test.dart`).

## 9. Limitations

- CyberCore MCP inspector/servers detail pages were read for census shape only (state triple + retry pattern identical to the 6 audited pages); deep fixture-field mapping beyond `operationalLabel` is out of audit scope.
- The `warp_prism_interaction` package tests present in the working tree during this audit belong to concurrent Task 1815 work; their LSP diagnostics are not evidence about runtime contracts and were not consumed.
- Gallery (`design_system_gallery_sections.dart`) consumer references establish demo/test surfaces only — gallery counts as showcase, not a production consumer domain for PROVEN-lifecycle purposes.
