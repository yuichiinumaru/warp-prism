# ADS Organism Harvest — Unified (ShadowBroker + Osiris) — 2026-07-10

> **Sources**: read-only frontends under `ganthritor/hyperion/references/`  
> - `bigbodycobain-shadowbroker` → full report: `ads-organism-harvest-shadowbroker-2026-07-10.md`  
> - `simplifaisoul-osiris` → full report: `ads-organism-harvest-osiris-2026-07-10.md`  
> **Filter**: organisms only (molecules/atoms deferred as derivation)  
> **Target**: Warp Prism `packages/warp_prism_ui` Prism ADS, desktop-first ultradark glass

---

## Pattern both references share

Neither is a classic multi-route CRUD shell. Both are:

1. **Full-bleed canvas** (map) as the stage  
2. **Floating glass HUD** panels (left rail / right strip / bottom chrome)  
3. **Exclusive tool slideouts** (opening one closes others)  
4. **Selection → dossier** coupling (entity/region intel bodies swap by type)  
5. **Live status strips** (ticker, coords, feed health)

Warp Prism today is stronger at **sidebar/topbar/inspector shell** (`DSShell`) and **ops boards** (lane board, log viewer, table). The harvest gap is the **map-first / canvas-first multi-HUD workspace** class — valuable for CyberCore ops and a richer Map workspace, without abandoning `DSShell` for Observatory routes.

---

## Consensus P0 organisms (implement next)

| # | Proposed Prism organism | ShadowBroker | Osiris | Why |
| --: | --- | --- | --- | --- |
| 1 | `PrismMapHudWorkspace` | `page.tsx` dual HUD | `page.tsx` canvas HUD | New layout template over stage slot; not a `DSShell` clone |
| 2 | `PrismLayerControlPanel` | `WorldviewLeftPanel` | `LayerPanel` | Grouped toggles, counts, freshness, flyouts |
| 3 | `PrismToolStripSlideout` | right HUD stack | exclusive right tool strip | Multi-tool exclusive slideouts |
| 4 | `PrismEntityIntelPanel` | `NewsFeed` mode switch | region dossier / intel | Pluggable dossier registry on inspector pattern |
| 5 | `PrismEntityLocateSearch` | `FindLocateBar` | `SearchBar` | Multi-corpus locate ≠ command palette |
| 6 | `PrismTimeMachineScrubber` | `TimelineScrubber` + panel | (weaker) | Density histogram + playback; pairs with `DSTimeline` |
| 7 | `PrismStatusTicker` | bottom ticker | `GlobalStatusBar` | Marquee live strip |
| 8 | `PrismOsintWorkbench` | `ReconPanel`/`ReconResults` | `OsintPanel` | Tabbed recon + structured results → CyberCore |

---

## Consensus P1 (second wave)

| Organism | Notes |
| --- | --- |
| `PrismFloatingAnalyticsHud` | Draggable minimizable multi-section overlay (SB GT HUD) |
| `PrismEntityRelationCard` / expand-graph workbench | Graph preview + legend + footer (Osiris `EntityGraphPanel`; SB relation card) |
| `PrismWatchlistDock` | Pinned entities dock |
| `PrismCoordinateStatusBar` | Stage coords + feed health chrome |
| `PrismMapLegend` | Categorized icon catalog |
| `PrismFilterWorkbench` | Advanced filter panel + modal |
| `PrismAiAnalystPanel` | Chat/intel conversation (fixture-first; CyberCore) |
| `PrismOpsControlCluster` | Top-right operational launchers |
| `PrismMapCanvasStage` **contract** | Layer registry, selection bus, popup factory — **not** MapLibre port |
| `PrismViewPresets` / share workspace state | Osiris presets/share (read-only share URL pattern) |
| `PrismTerminalWorkspace` / `PrismAgentShellPanel` | CyberCore ops; start read-only transcript |

---

## Already covered — do not re-harvest as new organisms

`DSShell`, `DSSidebar`, `DSTopbar`, `DSDetailInspector`, `DSGraphCanvas`, `DSTimeline` (list), `DSLaneBoard`, `DSLogViewer`, `DSCommandPalette`, `DSDataTable`, `DSTabBar`, `DSSplitPane`, `DSVirtualScroll`, `DSStatusGrid`, toast system, error boundary.

Upgrade path: **compose** new organisms using these, don’t fork them.

---

## Explicit skips (both sources)

- Porting MapLibre / react-map-gl / force-graph JS engines  
- Mesh crypto / DM mutation / live keys in localStorage  
- Token/markets promo panels, CoinGecko tickers  
- God-object megafiles (`NewsFeed` ~2k lines, `OsintPanel` ~1k) — harvest **mode contracts**, not structure  
- Domain one-offs (Shodan, SCM, radio) as separate organisms → prefer generic `PrismConnectorPanel` chrome  

---

## Suggested build waves (organisms → then derive molecules)

| Wave | Organisms | Derives later (molecules/atoms) |
| --- | --- | --- |
| **A** | `PrismMapHudWorkspace`, `PrismToolStripSlideout` | HUD edge toggle, collapsible glass chrome, exclusive panel controller |
| **B** | `PrismLayerControlPanel`, `PrismFilterWorkbench` | Layer row, freshness pill, master toggle, consent gate chip |
| **C** | `PrismEntityIntelPanel`, `PrismEntityLocateSearch` | Dossier body slot, locate result row, corpus tab |
| **D** | `PrismTimeMachineScrubber`, `PrismStatusTicker`, stage chrome pack | Density histogram, transport controls, marquee item |
| **E** | `PrismOsintWorkbench`, `PrismAiAnalystPanel` (fixtures) | Tool tab registry, query history list, chat bubble/turn |
| **F** | `PrismMapCanvasStage` contract + `PrismEntityRelationCard` | Selection bus types, legend item, expand-graph footer |

---

## Product fit note

- **Observatory**: waves A–D upgrade Map/History/Governance polish without needing Go CyberCore.  
- **CyberCore pilot** (while Go backend grows): waves E–F + terminal/agent shells against **fixtures** first; swap data adapters when Go lands.

---

*Synthesized from independent harvest subagents. Sources not modified.*
