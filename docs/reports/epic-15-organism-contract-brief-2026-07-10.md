# EPIC-15 Organism Inventory + Public Contract Brief

> **Status**: Locked inventory for Task 1500  
> **Date**: 2026-07-10  
> **Epic**: `docs/tasks/00-planning/EPIC-15-warp-prism-ads-organism-expansion-from-reference-harvest.md`  
> **Authority**: freezes O-ID ↔ Task 15NN ↔ `Prism*` ↔ wave for builders of Tasks 1501–1523  
> **Governance only** — no Flutter widgets land in this brief

---

## 1. Purpose

Builders implement EPIC-15 organisms **without re-litigating harvest scope**. This brief freezes:

1. Skip list and already-covered organisms (do not re-implement).
2. Full O-01–O-28 mapping to Task / public name / wave / deferred status.
3. Public API contract (barrel, alias, gallery, tests, changelog).
4. Wave dependency graph A→H plus cross-cutting 1519→1520→1521.
5. Soft vs hard dependency notes so parallel waves can fan out.

**Downstream rule**: if a builder disagrees with a name, wave, or skip, open a governance amendment — do not silently fork scope inside a feature task.

---

## 2. Source evidence (mandatory read)

| Artifact | Path |
| --- | --- |
| Epic | `docs/tasks/00-planning/EPIC-15-warp-prism-ads-organism-expansion-from-reference-harvest.md` |
| Unified harvest | `docs/reports/ads-organism-harvest-unified-2026-07-10.md` |
| ShadowBroker harvest | `docs/reports/ads-organism-harvest-shadowbroker-2026-07-10.md` |
| Osiris harvest | `docs/reports/ads-organism-harvest-osiris-2026-07-10.md` |
| Task architect review | `docs/reports/epic-15-task-architect-review-2026-07-10.md` |
| EPIC-13 public contract | `docs/tasks/00-planning/EPIC-13-warp-prism-ads-public-contract-and-catalog-hardening.md` |
| Organisms barrel | `packages/warp_prism_ui/lib/src/organisms/organisms.dart` |
| Public aliases | `packages/warp_prism_ui/lib/src/prism_aliases.dart` |
| Gallery registry | `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_registry.dart` |

Reference frontends (read-only, do not copy files):

| Reference | Path |
| --- | --- |
| ShadowBroker | `ganthritor/hyperion/references/bigbodycobain-shadowbroker/` |
| Osiris | `ganthritor/hyperion/references/simplifaisoul-osiris/` |

---

## 3. Skip list (frozen — do not implement)

These items are **out of scope** for Tasks 1500–1523 and for every EPIC-15 organism task. Do not re-implement, re-port, or “just for gallery”:

| Skip | Rationale |
| --- | --- |
| MapLibre / MapLibre GL / `react-map-gl` | Engine port forbidden; stage is a slot/contract only |
| `react-force-graph` / force-graph JS engines | Use existing `DSGraphCanvas` / typed `graph/` composition |
| Mesh crypto, DM mutation, localStorage API keys | Not product; Warp Prism is fixture/read-only |
| Live CoinGecko / USGS / markets promo tickers | Non-product; no live keys |
| Token/markets promo panels (`TokenPanel` etc.) | Explicit harvest IRON skip |
| Megafile structural copies | ShadowBroker `NewsFeed` ~2k LOC, Osiris `OsintPanel` ~1k — harvest **mode contracts**, not structure |
| Domain one-off panels as separate organisms | Shodan / SCM / radio → prefer `PrismConnectorPanel` chrome |
| Observatory product route rewrites | ADS-first; Map route integration is a later optional task |
| Replacing `DSShell` wholesale | HUD workspace is an **additional** layout class, not a shell replacement |
| Live CyberCore Go API | Fixture-first until backend tasks authorize otherwise |
| Full mesh chat / encryption product | Deferred (O-23 outside promotion set) |
| Widgetbook migration | Custom catalog remains intentional MVP |

**Binary acceptance**: any PR that introduces MapLibre packages, live network keys for AI/OSINT, or Observatory route rewrites as organism exit fails review.

---

## 4. Already covered — do not re-task as new organisms

These exist under `packages/warp_prism_ui/lib/src/organisms/` (and related molecules). New EPIC-15 organisms **compose** them; they do **not** fork or re-create them:

| Existing | Path / note |
| --- | --- |
| `DSShell` / `DSShellResponsive` → `PrismShell` | `ds_shell.dart` — nav-first app chrome |
| `DSSidebar` → `PrismSidebar` | `ds_sidebar.dart` |
| `DSTopbar` → `PrismTopbar` | `ds_topbar.dart` |
| `DSDetailInspector` → `PrismDetailInspector` | `ds_detail_inspector.dart` — compose for dossiers |
| `DSGraphCanvas` + `graph/*` → `PrismGraphCanvas` | Graph infrastructure; relation card hosts it |
| `DSTimeline` → `PrismTimeline` | Event **list** — not the time-machine scrubber |
| `DSLaneBoard` → `PrismLaneBoard` | Task board |
| `DSLogViewer` → `PrismLogViewer` | `log_viewer/` |
| `DSCommandPalette` → `PrismCommandPalette` | Commands ≠ entity locate |
| `DSDataTable` → `PrismDataTable` | `data_table/` |
| `DSTabBar` / `DSTabView` → `PrismTabBar` / `PrismTabView` | Tab chrome primitives |
| `DSSplitPane` → `PrismSplitPane` | Split layout |
| `DSVirtualScroll` / list/grid | Virtualization infrastructure |
| `DSStatusGrid` → `PrismStatusGrid` | Health card grid |
| Toast system | `DSToast` / `DSToastManager` — O-28 is a **variant**, not a second stack |
| Error boundary / fallback | `DSErrorBoundary` / `DSFallbackView` |
| Code / markdown blocks | `DSCodeBlock` / `DSMarkdownRenderer` |
| `DSStoryPanel` → `PrismStoryPanel` | Narrative insights |

**Barrel snapshot (pre-EPIC-15):** `organisms.dart` exports shell, sidebar, topbar, lane board, timeline, detail inspector, story panel, graph canvas, code/markdown, fallback, error boundary, status grid, graph package, log viewer, command palette, tab bar, split pane, data table, virtual scroll. **No** map-HUD / tool-strip / layer-panel / osint workbench exports yet — confirmed gap vs harvest.

---

## 5. Architect resolutions (frozen)

| Topic | Decision |
| --- | --- |
| **Naming** | Public `Prism*`; internal `DS*` + `typedef PrismX = DSX` in `prism_aliases.dart` matching existing ADS pattern (unless EPIC-13 remediation already requires Prism-native classes). |
| **Gallery** | Each organism task registers a **minimal** gallery case on land. Task **1519** audits completeness, section IDs, catalog ordering. |
| **Product routes** | ADS-first. Observatory Map route integration is **out of scope** for organism exit. |
| **O-23 mesh** | Explicitly **not** tasked in 1500–1523; remains P2 backlog outside this promotion set. |
| **Stage chrome pack** | O-11 / O-12 / O-13 delivered as **Task 1509** multi-organism pack (three public names). |
| **O-25 display chrome** | **Not tasked** in 1500–1523 (Task 1522 may skip REC/display strip unless trivial). |
| **Composition rule** | Organisms first; molecules/atoms derive later from proven reuse — not reverse-invented in isolation. |

---

## 6. Master O-ID ↔ Task ↔ Prism* table

Priority: **P0** = consensus next; **P1** = second wave; **P2** = polish / optional.

### 6.1 Promoted organisms (O-01–O-22, O-24–O-28)

| O-ID | Public `Prism*` name(s) | Task | Wave | Pri | Action | Origin (ShadowBroker) | Origin (Osiris) | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| O-01 | `PrismMapHudWorkspace` | **1501** | A | P0 | NEW | `frontend/src/app/page.tsx` dual-HUD | `src/app/page.tsx` canvas HUD | Stage + left/right/bottom HUD; not `DSShell` clone |
| O-02 | `PrismToolStripSlideout` | **1502** | A | P0 | NEW | Right HUD stack | Exclusive right tool strip (~L932–1002) | Exclusive open; icon strip + body |
| O-03 | `PrismLayerControlPanel` | **1503** | B | P0 | NEW | `WorldviewLeftPanel.tsx` | `LayerPanel.tsx` | Groups, counts, freshness, master toggle |
| O-14 | `PrismFilterWorkbench` | **1504** | B | P1 | NEW | Filter panel + advanced modal | Layer/filter patterns | Beyond chip group alone |
| O-04 | `PrismEntityIntelPanel` | **1505** | C | P0 | NEW | `NewsFeed.tsx` multi-body | Region dossier / intel panels | Pluggable dossier registry |
| O-05 | `PrismEntityLocateSearch` | **1506** | C | P0 | NEW | `FindLocateBar.tsx` | `SearchBar.tsx` | Multi-corpus locate ≠ command palette |
| O-06 | `PrismTimeMachineScrubber` | **1507** | D | P0 | NEW | `TimelineScrubber` + `TimelinePanel` | (weaker peer) | Density + playback; pairs with `DSTimeline` |
| O-07 | `PrismStatusTicker` | **1508** | D | P0 | NEW | Bottom ticker | `GlobalStatusBar.tsx` | Marquee / rotating status strip |
| O-11 | `PrismWatchlistDock` | **1509** | D | P1 | NEW | Watchlist dock | — | Stage chrome pack (1/3) |
| O-12 | `PrismCoordinateStatusBar` | **1509** | D | P1 | NEW | Bottom coord/feed-health bar | Coord HUD | Stage chrome pack (2/3) |
| O-13 | `PrismMapLegend` | **1509** | D | P1 | NEW | Map legend catalog | — | Stage chrome pack (3/3) |
| O-08 | `PrismOsintWorkbench` | **1510** | E | P0 | NEW | `ReconPanel` / `ReconResults` | `OsintPanel.tsx` | Tab registry, query, history, map handoff callback |
| O-15 | `PrismAiAnalystPanel` | **1511** | E | P1 | NEW | AI intel panels | `AiAnalyst` / `AiOverview` | **Fixture-first**; no live keys |
| O-17 | `PrismMapCanvasStage` | **1512** | F | P1 | NEW (contract) | `MaplibreViewer` composition | `OsirisMap.tsx` composition | **Contract only**: layer registry, selection bus, popup factory |
| O-10 | `PrismEntityRelationCard` | **1513** | F | P1 | NEW | Entity relation expand card | `EntityGraphPanel.tsx` | Compose `DSGraphCanvas`; hard-deps 1512 |
| O-09 | `PrismFloatingAnalyticsHud` | **1514** | G | P1 | NEW | `GtAnalyticsHud.tsx` | — | Draggable minimizable multi-section |
| O-16 | `PrismOpsControlCluster` | **1515** | G | P1 | NEW | Top-right ops launchers | Top C2 metrics/actions | Pack with connector |
| O-20 | `PrismConnectorPanel` | **1515** | G | P1 | NEW | Shared panel chrome | Shared glass panel recipe | Generic; not domain clones |
| O-18 | `PrismViewPresets` | **1516** | G | P1 | NEW | — | `ViewPresets.tsx` | Named camera/layer preset grid |
| O-19 | `PrismWorkspaceShareCard` | **1516** | G | P1 | NEW | — | `SharePanel.tsx` | Read-only shareable view-state summary |
| O-21 | `PrismTerminalWorkspace` | **1517** | H | P1–P2 | NEW | `InfonetTerminal/*` | — | Multi-pane fixture console shell |
| O-22 | `PrismAgentShellPanel` | **1518** | H | P1–P2 | NEW | `MeshChat/AgentShellPanel.tsx` | — | Start **read-only transcript**; hard-deps 1517 |
| O-24 | `PrismKeyboardCheatsheet` | **1522** | I | P2 | NEW (optional) | Keyboard overlay | `KeyboardShortcuts.tsx` | Optional polish pack |
| O-26 | `PrismScaleMeasureBar` | **1522** | I | P2 | NEW (optional) | Scale bar | `ScaleBar.tsx` | Organism or molecule — classify at impl |
| O-28 | `PrismRiskAlertToastVariant` (proposed; optional — no required typedef until 1522 ships) | **1522** | I | P2 | VARIANT (optional) | Geo-aware risk toasts | — | Extends existing toast system; not a new stack |
| O-27 | `PrismMediaDetailOverlay` | **1523** | I | P2 | NEW (optional) | CCTV / region imagery | `CameraViewer.tsx` | Optional; no HLS engine port |

### 6.2 Deferred / not tasked

| O-ID | Proposed name | Status | Reason |
| --- | --- | --- | --- |
| **O-23** | `PrismMeshCommsPanel` | **DEFERRED — outside 1500–1523** | Multi-tab peer/comms UI; P2 until product needs; mesh crypto also skipped |
| **O-25** | `PrismDisplayConfigChrome` | **NOT TASKED** | Tactical display / REC strip aesthetic; 1522 explicitly may skip |

### 6.3 Cross-cutting tasks (no O-ID)

| Task | Name | Wave | Type | Hard depends |
| --- | --- | --- | --- | --- |
| **1500** | Inventory + organism contract brief (this document) | — | governance | — |
| **1519** | Gallery + catalog registration audit | cross | feature | 1501–1513 (A–F); G–H soft |
| **1520** | Goldens + boundary alias audit | cross | testing | 1519 |
| **1521** | EPIC-15 acceptance audit | close | verification | 1520 |

---

## 7. Task 1501–1523 inventory lock (open-lane verification)

Verified on 2026-07-10 under `docs/tasks/01-open/` (23 files) + Task 1500 in `02-doing/`.

| Task | File (slug) | Public deliverable(s) | Wave |
| --- | --- | --- | --- |
| 1501 | `1501-warp-prism-map-hud-workspace-organism.md` | `PrismMapHudWorkspace` | A |
| 1502 | `1502-warp-prism-tool-strip-slideout-organism.md` | `PrismToolStripSlideout` | A |
| 1503 | `1503-warp-prism-layer-control-panel-organism.md` | `PrismLayerControlPanel` | B |
| 1504 | `1504-warp-prism-filter-workbench-organism.md` | `PrismFilterWorkbench` | B |
| 1505 | `1505-warp-prism-entity-intel-panel-organism.md` | `PrismEntityIntelPanel` | C |
| 1506 | `1506-warp-prism-entity-locate-search-organism.md` | `PrismEntityLocateSearch` | C |
| 1507 | `1507-warp-prism-time-machine-scrubber-organism.md` | `PrismTimeMachineScrubber` | D |
| 1508 | `1508-warp-prism-status-ticker-organism.md` | `PrismStatusTicker` | D |
| 1509 | `1509-warp-prism-stage-chrome-pack-organisms.md` | Watchlist + CoordBar + Legend | D |
| 1510 | `1510-warp-prism-osint-workbench-organism.md` | `PrismOsintWorkbench` | E |
| 1511 | `1511-warp-prism-ai-analyst-panel-fixture-organism.md` | `PrismAiAnalystPanel` | E |
| 1512 | `1512-warp-prism-map-canvas-stage-contract.md` | `PrismMapCanvasStage` | F |
| 1513 | `1513-warp-prism-entity-relation-card-organism.md` | `PrismEntityRelationCard` | F |
| 1514 | `1514-warp-prism-floating-analytics-hud-organism.md` | `PrismFloatingAnalyticsHud` | G |
| 1515 | `1515-warp-prism-ops-control-cluster-connector-panel.md` | OpsCluster + ConnectorPanel | G |
| 1516 | `1516-warp-prism-view-presets-workspace-share-card.md` | ViewPresets + ShareCard | G |
| 1517 | `1517-warp-prism-terminal-workspace-fixture-shell.md` | `PrismTerminalWorkspace` | H |
| 1518 | `1518-warp-prism-agent-shell-panel-read-only-transcript.md` | `PrismAgentShellPanel` | H |
| 1519 | `1519-warp-prism-epic-15-gallery-catalog-registration.md` | Gallery matrix completeness | cross |
| 1520 | `1520-warp-prism-epic-15-goldens-boundary-alias-audit.md` | Goldens + alias audit | cross |
| 1521 | `1521-warp-prism-epic-15-acceptance-audit.md` | Epic acceptance | close |
| 1522 | `1522-warp-prism-optional-keyboard-scale-risk-toast.md` | O-24 + O-26 + O-28 | I |
| 1523 | `1523-warp-prism-optional-media-detail-overlay.md` | `PrismMediaDetailOverlay` | I |

**Numbering**: continuous **1500–1523**, no gaps. Reserved band per epic was 1500–1529; unused 1524–1529 remain free for architect splits only.

**Public name count (promoted non-optional)**: 22 public `Prism*` organisms across 1501–1518 (1509/1515/1516 multi-name packs counted as 3+2+2). Optional Wave I adds up to 3 more public names plus one toast variant (1522×2 + 1523×1 + O-28 variant-only).

---

## 8. Soft dependency notes (fan-out)

Hard dependency on Task 1500 for all feature tasks. Soft edges to **Task 1501** allow waves B/D/F/G to start without waiting for full HUD workspace:

| Task | Soft depends | Rule for builders |
| --- | --- | --- |
| **1503** Layer panel | 1501 | Prefer left-rail composition demo in HUD when 1501 landed; **MUST** ship stand-alone gallery host if 1501 incomplete |
| **1509** Stage chrome pack | 1501 | Prefer bottom/edge placement demos; each of 3 organisms **MUST** gallery-demo stand-alone |
| **1512** Map canvas stage contract | 1501 | Prefer stage-inside-HUD demo; **contract types/API** ship without HUD host |
| **1514** Floating analytics HUD | 1501 | Prefer overlay host; **MUST** demo over plain `Stack`/`SizedBox` stage if 1501 incomplete |
| **1516** View presets + share card | 1501 | Prefer “apply preset to workspace” demos; cards **MUST** stand alone |

### Hard edges (do not soften)

| Edge | Why |
| --- | --- |
| **1513 → 1512** | Relation card consumes stage selection / graph composition contract |
| **1518 → 1517** | Agent shell sits in terminal workspace family |
| **1519 → 1501–1513** | Gallery audit hard-requires A–F; G–H/I soft/deferred matrix |
| **1520 → 1519** | Goldens after registration coherence |
| **1521 → 1520** | Acceptance after goldens + boundaries |

---

## 9. Wave dependency graph

```text
1500 (inventory lock)
  │
  ├─► Wave A: 1501 ∥ 1502
  │     soft ──► 1503, 1509, 1512, 1514, 1516 (composition demos only)
  │
  ├─► Wave B: 1503 ∥ 1504
  ├─► Wave C: 1505 ∥ 1506
  ├─► Wave D: 1507 ∥ 1508 ∥ 1509
  ├─► Wave E: 1510 ∥ 1511
  ├─► Wave F: 1512 ──hard──► 1513
  ├─► Wave G: 1514 ∥ 1515 ∥ 1516
  ├─► Wave H: 1517 ──hard──► 1518
  │
  ├─► Cross: 1519 (hard A–F = 1501–1513; soft G–H + I)
  │            │
  │            └─► 1520 (min goldens A–F)
  │                   │
  │                   └─► 1521 (acceptance audit)
  │
  └─► Wave I optional: 1522 ∥ 1523
         (register in 1519 only if landed; never blocks 1519/1520 min path)

O-23 MeshComms ──► NOT IN GRAPH (deferred backlog)
O-25 DisplayConfig ──► NOT IN GRAPH (not tasked)
```

**Recommended start order** (architect review): 1500 → A (1501∥1502) → B → C → D→E→F→G→H → 1519→1520→1521; optional I anytime after 1500.

---

## 10. Public contract checklist (every organism task)

Builders MUST satisfy all items before claiming organism exit:

### 10.1 Naming + package surface

| # | Requirement |
| --- | --- |
| C1 | Internal class `DS…` under `packages/warp_prism_ui/lib/src/organisms/<snake>/` (or co-located pack dir). |
| C2 | Public alias `typedef Prism… = DS…` in `lib/src/prism_aliases.dart` with dartdoc. |
| C3 | Export implementation from `lib/src/organisms/organisms.dart` barrel. |
| C4 | Ensure public package entry `package:warp_prism_ui/warp_prism_ui.dart` re-exports alias (via existing alias/barrel chain — no `src/` consumer imports). |
| C5 | Consumers (gallery cases, catalog, apps) use **only** `Prism*` names. |

### 10.2 Gallery registration (minimal per organism; full audit = 1519)

| # | Requirement |
| --- | --- |
| G1 | At least one gallery case with fixture data (no MapLibre, no live keys). |
| G2 | Prefer extending existing `organisms` section or adding a **family** subsection rather than exploding top-level nav (1519 normalizes). |
| G3 | Stable section / case IDs (kebab-case). Suggested scheme below. |
| G4 | Case shows default state; optional empty/loading if cheap. |

**Suggested gallery section ID scheme (for 1519):**

| Family | Suggested registry `id` | Organisms |
| --- | --- | --- |
| HUD layout | `epic15-hud` | MapHudWorkspace, ToolStripSlideout |
| Layers / filters | `epic15-layers-filters` | LayerControlPanel, FilterWorkbench |
| Intel / locate | `epic15-intel` | EntityIntelPanel, EntityLocateSearch |
| Time / status / chrome | `epic15-stage-chrome` | TimeMachineScrubber, StatusTicker, Watchlist, CoordBar, Legend |
| CyberCore recon / AI | `epic15-cybercore-recon` | OsintWorkbench, AiAnalystPanel |
| Stage / relations | `epic15-stage-relations` | MapCanvasStage, EntityRelationCard |
| Ops pack | `epic15-ops` | FloatingAnalyticsHud, OpsControlCluster, ConnectorPanel, ViewPresets, WorkspaceShareCard |
| Terminal | `epic15-terminal` | TerminalWorkspace, AgentShellPanel |
| Optional polish | `epic15-optional` | Keyboard, ScaleBar, Risk toast variant, Media overlay |

> Implementers may land cases under existing `id: 'organisms'` temporarily; Task **1519** owns final section list and ordering.

### 10.3 Test path scheme

| Kind | Path pattern |
| --- | --- |
| Unit / widget | `packages/warp_prism_ui/test/organisms/<snake_name>_test.dart` |
| Gallery smoke | `packages/warp_prism_ui/test/gallery/` (extend if pattern exists) |
| Goldens (1520) | `packages/warp_prism_ui/test/goldens/epic15_<family>_test.dart` + PNG baselines |
| Boundaries | existing harness; `melos run test-boundaries` → **6/6 PASS** after alias/barrel touch |

### 10.4 Validation commands (organism tasks)

```bash
# From packages/warp_prism_ui (or monorepo root with path filter)
dart analyze lib/src/organisms lib/src/prism_aliases.dart lib/src/gallery
flutter test test/organisms/<relevant>_test.dart
# After barrel/alias changes:
melos run test-boundaries   # expect 6/6 PASS
```

### 10.5 Changelog

| # | Requirement |
| --- | --- |
| L1 | Local note under `docs/changelog/` per completed task (Warp Prism-only). |
| L2 | Do **not** edit root `CHANGELOG.md` / tasklist-sync from builder role unless parent policy changes. |

### 10.6 Binary product rules

| # | Requirement |
| --- | --- |
| P1 | Fixture/mock data only for OSINT/AI/terminal until backend tasks authorize live adapters. |
| P2 | No MapLibre / force-graph / xterm engine ports. |
| P3 | No Observatory product route rewrite required for organism exit. |
| P4 | Read-only mock-observatory semantics preserved (`AGENTS.md`). |

---

## 11. Gallery + golden expectations (Tasks 1519 / 1520)

### 11.1 Task 1519 — registration completeness

| Expectation | Detail |
| --- | --- |
| Hard matrix | All public names from Tasks **1501–1513** (waves A–F) registered and navigable |
| Soft matrix | 1514–1518 (G–H) registered **if already delivered**; else mark `deferred` in matrix |
| Optional | 1522–1523 register only if completed; never block 1519 |
| Output | Written organism → section id → builder method matrix in Completion Evidence or `docs/reports/` |
| Catalog | Update `apps/catalog/` if it mirrors sections; else document package-gallery-only |
| Boundaries | No new `package:warp_prism_ui/src/...` consumer imports |

### 11.2 Task 1520 — golden families (minimum)

Per epic acceptance + task 1520:

| # | Golden family | Preferred public name | State |
| --- | --- | --- | --- |
| 1 | HUD workspace | `PrismMapHudWorkspace` | default |
| 2 | Intel | `PrismEntityIntelPanel` **or** `PrismOsintWorkbench` | default |
| 3 | CyberCore workbench | `PrismOsintWorkbench` **or** `PrismAiAnalystPanel` / terminal shell | default |

- Minimum **3** golden tests + committed PNGs under `test/goldens/`.
- Waves G–I goldens optional same-pass if organisms already landed.
- Fixed surface sizes; deterministic fixtures; no network/MapLibre.
- Alias audit table: every new `Prism*` → implementation type → barrel export proof.
- `melos run test-boundaries` → **6/6 PASS**.

### 11.3 Task 1521 — acceptance checklist pointers

- P0 organisms O-01–O-08 exist with public `Prism*` names.
- Waves A–F delivered or explicitly deferred with written reason.
- Gallery + catalog + goldens + boundaries green.
- Skip list honored.
- No unauthorized Observatory route rewrites.

---

## 12. False-gap notes (do not re-implement)

| Claimed gap | Reality |
| --- | --- |
| “Need a second app shell” | Use `PrismMapHudWorkspace` over stage; keep `DSShell` for Observatory routes |
| “Locate is just command palette” | **False** — `PrismEntityLocateSearch` is multi-corpus / spatial locate |
| “Time machine is DSTimeline” | **False** — scrubber + density + playback is new; list remains `DSTimeline` |
| “Need MapLibre for stage contract” | **False** — `PrismMapCanvasStage` is selection/layer/popup **contract** |
| “Need new toast stack for risk” | **False** — O-28 is a **variant** of existing toast system |
| “OSINT mega-widget clone” | **False** — harvest mode registry; compose tabs + inspector + connector chrome |
| “Port xterm for agent shell” | **False** — start read-only transcript fixture panel |

---

## 13. Composition-not-fork rules

1. Prefer slots + registries (dossier body registry, tool tab registry, layer group model) over god-objects.
2. Compose `DSGlassPanel`, status atoms, filter chips, `DSDetailInspector`, `DSGraphCanvas`, tab bar, toast, error boundary.
3. Extract molecules only after **proven** reuse across ≥2 organisms (post-wave, not in first land).
4. Domain connectors (Shodan-like) stay as fixture content inside `PrismConnectorPanel`, not separate organisms.

---

## 14. Validation (this governance task)

```bash
test -f docs/tasks/00-planning/EPIC-15-warp-prism-ads-organism-expansion-from-reference-harvest.md
test -f docs/reports/ads-organism-harvest-unified-2026-07-10.md
test -f docs/reports/epic-15-organism-contract-brief-2026-07-10.md
ls packages/warp_prism_ui/lib/src/organisms/
ls docs/tasks/01-open/15*.md | wc -l   # expect 23 (1501–1523)
```

Flutter tooling is **not** required for Task 1500 exit.

---

## 15. Change control

| Event | Action |
| --- | --- |
| Rename public `Prism*` | Amend this brief + task header; update aliases in same PR as rename |
| Split/merge tasks in 1500–1529 | Keep wave order A→H; update this mapping table |
| Promote O-23 | New task outside current set (or 1524+); do not absorb into 1518 |
| Soften a hard edge | Architect review only; never by silent builder choice |

---

*Task 1500 lock — 2026-07-10. Builders: implement against this table; do not re-harvest scope.*
