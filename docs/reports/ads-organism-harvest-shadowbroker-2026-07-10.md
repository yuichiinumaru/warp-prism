# ADS Organism Harvest — ShadowBroker — 2026-07-10

> **Analyst role**: design-system harvest (gt-external-intelligence-analyst / design-system-migrate mindset)  
> **Scope**: FRONTEND organisms only — composite product surfaces  
> **Source (read-only)**: `/home/sephiroth/working/ganthritor/hyperion/references/bigbodycobain-shadowbroker/`  
> **Local ADS baseline**: `packages/warp_prism_ui/lib/src/organisms/`  
> **Do not copy code** — reimplement patterns deliberately in Flutter Prism ADS  
> **Product filter**: Warp Prism desktop-first, ultradark glass, **read-only** ASW Observatory + CyberCore ops UI

---

## Source map

### Stack

| Layer | Evidence |
| --- | --- |
| **SPA framework** | Next.js 16 + React 19 (`frontend/package.json` deps: `next@^16.2.7`, `react@^19.2.7`) |
| **Map** | MapLibre GL + `react-map-gl` (`maplibre-gl@^4.7.1`, `react-map-gl@^8.1.0`) — primary surface is geospatial HUD, not page-router app shell |
| **Motion** | Framer Motion (`framer-motion@^12.38.0`) for panel slide/minimize/overlay |
| **Terminal** | xterm.js in mesh agent shell (`@xterm/xterm`, `@xterm/addon-fit` — `MeshChat/AgentShellPanel.tsx`) |
| **Styling** | Tailwind CSS 4 + CSS variables / `data-theme` dark-default (`frontend/README.md`, `globals.css`) |
| **Icons** | lucide-react |
| **Desktop host** | Tauri skeleton under `desktop-shell/` (native control routing, tray, updater bridge) — **not a separate UI component tree**; web UI is the product surface |
| **API shape** | Browser hits relative `/api/*`; Next catch-all proxies to backend (`frontend/src/app/api/[...path]/route.ts`) |

### Frontend folder layout (product UI)

```text
frontend/src/
├── app/
│   ├── page.tsx              # Dashboard root composition (THE app shell)
│   ├── layout.tsx
│   ├── LocateBar.tsx         # Bottom coord/place search strip (page-local)
│   ├── SentinelInfoModal.tsx
│   └── globals.css
├── components/               # ~110 UI modules (primary harvest surface)
│   ├── map/                  # layers, workers, icons, popups, pin detail
│   ├── MaplibreViewer/       # fullscreen CCTV modal + typed popups
│   ├── MeshChat/             # mesh chat + agent shell + infonet flyout
│   ├── InfonetTerminal/      # full-screen sovereign terminal shell modules
│   └── ui/                   # ConfirmDialog, consent dialogs (molecules)
├── hooks/                    # data polling, watchlist, time machine, etc.
├── lib/                      # API clients, desktop bridge, mesh helpers
├── mesh/                     # mesh identity/crypto (logic, not organisms)
└── types/
desktop-shell/src/            # Tauri/native bridge only — skip as ADS organisms
```

### Composition model (proven)

ShadowBroker is a **single full-viewport map workspace** composed as HUD layers, not a multi-route CRUD app:

1. **Full-bleed map canvas** (`MaplibreViewer`) as content stage  
2. **Left HUD stack** (layers → mesh → shodan → recon/scm → AI intel)  
3. **Right HUD stack** (ops controls → find/locate → timeline → filters → intel/news/dossier)  
4. **Chrome strips**: brand header, bottom ticker, bottom coordinate/health bar, scale bar, watchlist, floating GT HUD  
5. **Fullscreen overlays**: Settings, Infonet Terminal, keyboard shortcuts, SAR AOI editor, region imagery, CCTV  
6. **Error isolation**: per-panel `ErrorBoundary` wrappers around heavy stacks  

Evidence: `frontend/src/app/page.tsx` imports and mounts the above (lines ~9–66 composition imports; ~551–910 HUD layout).

### Visual language (transferable aesthetic cues)

- Ultradark glass: `bg-[#0a0a0a]/90`, `backdrop-blur-sm`, cyan/amber borders  
- Mono tactical typography, tracking-widest section titles  
- Corner ticks / CRT vignette / “REC” clock chrome (`WorldviewRightPanel.tsx`)  
- Minimize/expand collapsible panel chrome is a repeated organism pattern  
- Risk color ramp: cyan → yellow → orange → red (toasts, timeline scrubber, GT)

These align with Warp Prism’s obsidian glass + restrained hacker accents (`AGENTS.md` product constraints) — **pattern transfer only**, re-token to `DSColors` / `DSGlassPanel`.

---

## Existing WP organism overlap

Local organisms (`packages/warp_prism_ui/lib/src/organisms/` + barrel `organisms.dart`):

| WP organism | Path | ShadowBroker conceptual peer | Overlap note |
| --- | --- | --- | --- |
| `DSShell` / `DSShellResponsive` | `ds_shell.dart` | `page.tsx` Dashboard root | WP is sidebar+topbar+content+inspector; SB is map-centric dual-HUD. **Different layout template**, not a 1:1 replace |
| `DSSidebar` | `ds_sidebar.dart` | Left HUD toggle stack | Partial — SB left is multi-panel stack, not nav list |
| `DSTopbar` | `ds_topbar.dart` | Brand header + `TopRightControls` | Partial — SB splits brand vs ops controls |
| `DSDetailInspector` | `ds_detail_inspector.dart` | `NewsFeed` entity modes, map popups, `ReconResults` | Strong conceptual match; SB adds type-specific dossier bodies |
| `DSStoryPanel` | `ds_story_panel.dart` | Region/GT narrative blocks in `NewsFeed` | Partial narrative/insight overlap |
| `DSTimeline` / `DSTimelineGrouped` | `ds_timeline.dart` | `TimelinePanel` + `TimelineScrubber` | **Different**: WP event list vs SB time-machine scrubber + playback |
| `DSGraphCanvas` + `graph/*` | `ds_graph_canvas.dart`, `graph/` | `EntityGraphPanel` | Graph canvas exists; SB has **entity-expand floating panel** + type-colored list/links (not full force layout in panel) |
| `DSLaneBoard` | `ds_lane_board.dart` | — | No SB peer (task board is WP-native) |
| `DSStatusGrid` | `ds_status_grid.dart` | Feed health strip in bottom bar; Infonet threat strip | Partial health grid semantics |
| `DSCommandPalette` | `command_palette/` | `FindLocateBar` + keyboard overlay (not full palette) | WP is richer; SB is map-entity search |
| `DSLogViewer` | `log_viewer/` | `LiveActivityLog`, mesh activity streams | Strong peer for activity log organism |
| `DSDataTable` | `data_table/` | Settings/usage tables, markets lists | Partial |
| `DSTabBar` / `DSTabView` | `tab_bar/` | MeshChat tabs, Recon tabs, Markets tabs, Settings tabs | Already covered as primitive; SB shows multi-tab **panel** compositions |
| `DSSplitPane` | `split_pane/` | Infonet multi-pane dashboard | Partial |
| `DSVirtualScroll` | `virtual_scroll/` | Long entity/result lists | Infrastructure already present |
| `DSCodeBlock` / `DSMarkdownRenderer` | code/markdown | Agent shell output, intel text | Partial |
| `DSErrorBoundary` / `DSFallbackView` | same | `ErrorBoundary.tsx` | Already covered |
| Templates: `MasterDetailTemplate` | `templates/master_detail_template.dart` | — | WP map/operate/history use master-detail; SB is **HUD-over-map template** |

### Already covered (do not re-harvest as new organisms)

- App shell chrome primitives (sidebar/topbar/inspector frame)  
- Graph canvas infrastructure  
- Log viewer + filter bar  
- Command palette (prefer WP over SB’s thinner search)  
- Toast molecule (`DSToast` / `DSToastManager`) — SB `AlertToast` is a **risk-scored geo-toast variant**, not a new toast system  
- Error boundary / fallback  
- Tab bar, data table, virtual scroll, code/markdown blocks  
- Timeline **list** organism (event story) — keep; time-machine is a **new** scrubber organism  

### Explicit gaps (WP lacks named product organisms)

1. Map-centric multi-HUD workspace layout  
2. Layer control tree with freshness + consent gates  
3. Entity/intel dossier that switches body by selection type  
4. Find-and-locate multi-corpus search over live entities  
5. Time-machine / density scrubber with playback  
6. Floating minimizable analytics HUD  
7. Watchlist dock  
8. Bottom status ticker / metrics marquee  
9. Map legend catalog  
10. Ops control launcher cluster (mesh/terminal/update/node)  
11. Multi-tab OSINT recon workbench + polymorphic result dossiers  
12. Terminal/sovereign multi-module workspace (ops console metaphor)  
13. Agent shell (xterm-style) as panel organism  
14. Keyboard shortcuts cheatsheet overlay  
15. Coordinate/location status bar with feed health dots  
16. Display/tactical chrome strip (REC clock, clear-UI mode)  

---

## Candidate organisms (ranked)

Priority legend: **P0** ship-soon high leverage · **P1** strong CyberCore/Observatory fit · **P2** aesthetic/ops polish or domain-specific.

---

### 1. `PrismMapHudWorkspace` (Map-centric dual-HUD shell)

| Field | Detail |
| --- | --- |
| **Score** | **GOLD** |
| **Source** | `frontend/src/app/page.tsx` (full composition); secondary chrome in left/right panel modules |
| **Purpose** | Full-viewport stage with collapsible left/right HUD columns, vertical edge toggle tabs, optional bottom ticker, global UI hide/restore (“tactical mode”), panel open-state persistence |
| **Composition sketch** | `stage` (map/canvas slot) + `leftHud: Widget[]` + `rightHud: Widget[]` + `topChrome` + `bottomChrome` + `floating: Widget[]` + `overlays` + edge toggle atoms + `uiVisible` gate |
| **States** | `leftOpen` / `rightOpen` / `tickerOpen` / `uiVisible`; secondary boot “prioritizing feeds” skeleton; fullscreen overlay suppresses bottom chrome |
| **CyberCore / Observatory fit** | Observatory **Map** workspace today uses master-detail; CyberCore ops benefit from multi-panel HUD over graph/map/log stages. Pattern = **workspace template**, not a page. |
| **Priority** | **P0** |
| **Notes** | Distinct from `DSShell` (nav-first). Implement as template under `templates/` *or* organism that consumes existing `DSSplitPane`/`DSGlassPanel`. Persist panel state like SB localStorage keys `sb_left_open` / `sb_right_open`. |

---

### 2. `PrismLayerControlPanel` (Data layers tree + freshness)

| Field | Detail |
| --- | --- |
| **Score** | **GOLD** |
| **Source** | `frontend/src/components/WorldviewLeftPanel.tsx` (`FRESHNESS_MAP`, toggle-all, category groups, GIBS/Sentinel subcontrols, consent modals) |
| **Purpose** | Hierarchical layer enable/disable for multi-feed surfaces with live counts, relative freshness (“12s ago”), master toggle, theme/HUD chrome hooks, gated layers requiring consent |
| **Composition sketch** | Collapsible section groups → layer rows (icon, label, count badge, freshness, toggle) → optional nested controls (opacity/date/preset) → footer actions (settings, legend, SAR editor) |
| **States** | minimized/expanded; per-layer on/off; pending consent; loading scan messages; tile-loading indicator; lean-profile warnings |
| **CyberCore / Observatory fit** | Map catalog filters; CyberCore provider/capability enablement; feed health governance. Read-only projection of “what is active on stage.” |
| **Priority** | **P0** |
| **Notes** | Do not port SB domain layers (flights/ships). Harvest **tree + freshness + consent gate** pattern. WP has filter chips molecule — this is the **organism** wrapping grouped toggles + counts. |

---

### 3. `PrismEntityIntelPanel` (Selection-driven multi-body dossier)

| Field | Detail |
| --- | --- |
| **Score** | **GOLD** |
| **Source** | `frontend/src/components/NewsFeed.tsx` (`NewsFeedInner` — news list **and** entity-specific bodies: flight trail, ship, shodan host, region dossier, GT risk, FIMI, AI summary) |
| **Purpose** | Right-rail (or inspector) that switches from feed list to rich dossier when selection exists; cross-links expand entity graph; article click flies map |
| **Composition sketch** | Header (title + minimize) + body switch on `selectedEntity.type` + expandable list items + optional summary CTA + empty/loading surfaces |
| **States** | minimized; list vs dossier mode; loading trail/host/dossier; expand indexes; AI summary open/loading; consent for correlated markets |
| **CyberCore / Observatory fit** | Universal asset detail; provider host detail; audit/event detail; region risk. Elevates `DSDetailInspector` from static sections to **type-registry of dossier modules**. |
| **Priority** | **P0** |
| **Notes** | Prefer composition: `DSDetailInspector` shell + pluggable `PrismDossierBody` registry rather than one mega-widget. SB’s NewsFeed is overloaded (~2k lines) — **anti-pattern to copy structure**, harvest the mode switch. |

---

### 4. `PrismEntityLocateSearch` (Find/locate multi-corpus bar)

| Field | Detail |
| --- | --- |
| **Score** | **GOLD** |
| **Source** | `frontend/src/components/FindLocateBar.tsx`; page-local `app/LocateBar.tsx` for coord/place |
| **Purpose** | Search live entity index (typed categories, color-coded) → select flies stage + optional filter injection; separate coord/geocode bar |
| **Composition sketch** | Search field + results dropdown (category chip, label, sublabel) + clear; optional filter-on-select |
| **States** | open/closed dropdown; empty query; no results; outside-click dismiss |
| **CyberCore / Observatory fit** | Map workspace entity find; CyberCore capability/provider/route search; complements `DSCommandPalette` for **spatial/entity** vs **command** intents |
| **Priority** | **P0** |
| **Notes** | Do not collapse into command palette only — keep map/entity locate as dedicated organism. |

---

### 5. `PrismTimeMachineScrubber` (Density histogram + playback)

| Field | Detail |
| --- | --- |
| **Score** | **GOLD** |
| **Source** | `frontend/src/components/TimelineScrubber.tsx` + `TimelinePanel.tsx` + hooks `useTimeMachine` |
| **Purpose** | 24h activity density bar with risk coloring; snapshot bins; enter/exit snapshot mode; play/pause/step/speed presets; config presets (paranoid/active/casual/minimal) |
| **Composition sketch** | Canvas/custom painted density bar + hover tooltip + transport controls (skip back/play/forward/live) + clock label + settings drawer for capture presets |
| **States** | live vs snapshot; scrubbing; enabled/disabled feature; hover index; busy snapshot |
| **CyberCore / Observatory fit** | History workspace; execution envelope waterfall scrub; audit replay; changelog “as-of” projection. High value for **read-only time travel** UX. |
| **Priority** | **P0** |
| **Notes** | Distinct from `DSTimeline` event list. Pair: list = narrative; scrubber = temporal control surface. |

---

### 6. `PrismFloatingAnalyticsHud` (Draggable minimizable multi-section HUD)

| Field | Detail |
| --- | --- |
| **Score** | **SILVER** |
| **Source** | `frontend/src/components/GtAnalyticsHud.tsx` (+ embedded `GtBacktestPanel`, `GtTopAlertsStrip`); pattern also in `EntityGraphPanel` floating card |
| **Purpose** | Fixed/draggable glass card over stage; drag handle; minimize to title strip; hosts stacked analytics subpanels; layer-gated visibility |
| **Composition sketch** | Positioned shell + grip header + minimize + scroll body slots |
| **States** | position; dragging; minimized; hidden when feature layer off |
| **CyberCore / Observatory fit** | Overlay metrics on Map/Graph without stealing inspector; circuit-breaker / risk / cost widgets |
| **Priority** | **P1** |
| **Notes** | Harvest **shell**, not GT domain math. Persist position like `useFloatingPanel('sb-gt-analytics-hud-v1')`. |

---

### 7. `PrismOpsControlCluster` (Top-right operational launchers)

| Field | Detail |
| --- | --- |
| **Score** | **SILVER** |
| **Source** | `frontend/src/components/TopRightControls.tsx` |
| **Purpose** | Dense ops cluster: version/update status machine, secure terminal launcher, node/swarm activate flow, DM badge, settings entry, portal modals for multi-step activation |
| **Composition sketch** | Icon/button row + status badges + multi-step modal workflows (prompt → terms → activating phases → done/timeout) |
| **States** | update: idle/checking/available/…; node: prompt/terms/activating/disable; busy/error; dmCount |
| **CyberCore / Observatory fit** | Provider health actions (read-only status + deep-link); environment switchers; “open console” for agent shell; deployment update banner in desktop packaging |
| **Priority** | **P1** |
| **Notes** | Strip write/admin mutation for WP read-only contract — keep **status + navigate** affordances. |

---

### 8. `PrismWatchlistDock`

| Field | Detail |
| --- | --- |
| **Score** | **SILVER** |
| **Source** | `frontend/src/components/WatchlistWidget.tsx` + `hooks/useWatchlist` |
| **Purpose** | Compact pinned-entity list near stage; expand/collapse; fly-to; clear/remove; type-colored glyphs |
| **Composition sketch** | Collapsed badge/count → expanded list rows (type icon, name, remove) |
| **States** | empty (hidden); collapsed; expanded; item actions |
| **CyberCore / Observatory fit** | Pin assets across Map/Operate; star tasks/agents for quick re-focus without full search |
| **Priority** | **P1** |
| **Notes** | Read-only pin set is governance-safe if local-only fixture state. |

---

### 9. `PrismStatusTicker` (Bottom marquee / feed strip)

| Field | Detail |
| --- | --- |
| **Score** | **SILVER** |
| **Source** | `frontend/src/components/GlobalTicker.tsx` |
| **Purpose** | Full-width bottom marquee of live metric chips; seamless loop; optional source-degraded banner overlay |
| **Composition sketch** | Track of `ticker items` (label, value, delta, severity) + infinite scroll motion + warn ribbon |
| **States** | empty (null); streaming; degraded source banner |
| **CyberCore / Observatory fit** | Cost/RPM/error-rate ticker; governance stale-count marquee; market not required |
| **Priority** | **P1** |
| **Notes** | Domain-agnostic item model. Respect reduced-motion accessibility (WP `DSMotion`). |

---

### 10. `PrismCoordinateStatusBar` (Stage status chrome)

| Field | Detail |
| --- | --- |
| **Score** | **SILVER** |
| **Source** | `frontend/src/app/page.tsx` bottom center bar (~811–909): coordinates, reverse-geocode label, style preset, solar/env metric, feed health dots |
| **Purpose** | Centered glass status strip under stage showing pointer context + multi-feed health micro-status |
| **Composition sketch** | Segmented mono metrics + dividers + click cycles style; health = label + status-dot + count |
| **States** | hidden under fullscreen overlays; hover coords vs zero; feed statuses |
| **CyberCore / Observatory fit** | Map workspace; graph zoom/selection status; multi-provider health microstrip |
| **Priority** | **P1** |
| **Notes** | Composes existing `DSStatusDot` atoms + metric text. |

---

### 11. `PrismMapLegend` (Categorized icon catalog)

| Field | Detail |
| --- | --- |
| **Score** | **SILVER** |
| **Source** | `frontend/src/components/MapLegend.tsx` |
| **Purpose** | Modal/panel of categorized legend entries (icon + label) for dense multi-layer maps |
| **Composition sketch** | Categories → icon rows; collapsible sections; close |
| **States** | open/closed; multi-category scroll |
| **CyberCore / Observatory fit** | Graph node/edge kind legend; task lane color legend; asset kind key |
| **Priority** | **P1** |
| **Notes** | Generic data model: `LegendCategory { name, items: { icon, label, color? } }`. |

---

### 12. `PrismFilterWorkbench` (Filter panel + advanced modal)

| Field | Detail |
| --- | --- |
| **Score** | **SILVER** |
| **Source** | `frontend/src/components/FilterPanel.tsx` + `AdvancedFilterModal.tsx` |
| **Purpose** | Collapsible filter control surface deriving option sets from live data; launches typed advanced multi-field modals |
| **Composition sketch** | Category filter buttons + active filter chips + modal with multi-select fields |
| **States** | minimized; open modal id; activeFilters map |
| **CyberCore / Observatory fit** | Map catalog filters; audit log advanced filters; governance stale/orphan filters |
| **Priority** | **P1** |
| **Notes** | Builds on `DSFilterChipGroup`; organism = panel chrome + advanced modal flow. |

---

### 13. `PrismOsintWorkbench` (Tabbed lookup + polymorphic dossiers)

| Field | Detail |
| --- | --- |
| **Score** | **SILVER** |
| **Source** | `frontend/src/components/ReconPanel.tsx` + `ReconResults.tsx` (`DossierShell`, per-type dossiers: IP, DNS, WHOIS, certs, threats, BGP, sanctions, CVE, MAC, GitHub, leaks, sweep) |
| **Purpose** | Operator workbench: tool tabs → query → loading/error → type-specific result dossier |
| **Composition sketch** | Header + tab rail + query field + run → `DossierShell` sections/rows |
| **States** | minimized; active tab; loading; error; results null/present |
| **CyberCore / Observatory fit** | **Strong CyberCore**: tool catalog invoke (read-only results), provider probe, policy dry-run results, MCP tool response inspector. Observatory: external evidence panels. |
| **Priority** | **P1** |
| **Notes** | Harvest **dossier registry pattern** from `ReconResults` (`DossierRow`, `SectionLabel`). Skip mutation sweep semantics if product stays read-only — show fixture results. |

---

### 14. `PrismEntityRelationCard` (Floating entity graph expand)

| Field | Detail |
| --- | --- |
| **Score** | **SILVER** |
| **Source** | `frontend/src/components/EntityGraphPanel.tsx` |
| **Purpose** | Selection-gated floating card: load expand API → nodes/links list with type colors; minimize/close; eligibility gate |
| **Composition sketch** | Header Network icon + entity id strip + loading/error + node list + link list (not full canvas) |
| **States** | null if ineligible; loading; error; minimized; populated |
| **CyberCore / Observatory fit** | Soft complement to `GraphCanvas`: quick expand without leaving inspector; ASW dependency fan-in preview |
| **Priority** | **P1** |
| **Notes** | Prefer deep-link into full `GraphCanvas` for complex graphs; this is **preview organism**. |

---

### 15. `PrismTerminalWorkspace` (Sovereign multi-module console)

| Field | Detail |
| --- | --- |
| **Score** | **SILVER** (ops) / **BRONZE** if only Observatory |
| **Source** | `frontend/src/components/InfonetTerminal/` — especially `index.tsx`, `InfonetShell.tsx`, `TerminalDashboard.tsx`, `LiveActivityLog.tsx`, `IdentityHUD.tsx`, Gate/Market/Messages views |
| **Purpose** | Fullscreen console window: title bar, section nav (HELP/AI/BALLOT/…), dashboard with threat banner, live activity log, modular views, identity domain HUD |
| **Composition sketch** | Modal shell (95vw×90vh) + nav rail + view switcher + dashboard header metrics + `LiveActivityLog` |
| **States** | open/closed; active module; threat level; session begin/end |
| **CyberCore / Observatory fit** | CyberCore **ops console** metaphor for agent/mesh/control-plane; Observatory can use subdued “workspace terminal” for log+query. |
| **Priority** | **P1** (CyberCore) · **P2** (pure Observatory) |
| **Notes** | Strip mesh crypto/persona write paths. Harvest **windowed multi-module console** + activity log composition. |

---

### 16. `PrismAgentShellPanel` (Embedded terminal panel)

| Field | Detail |
| --- | --- |
| **Score** | **SILVER** |
| **Source** | `frontend/src/components/MeshChat/AgentShellPanel.tsx` (xterm + fit addon, intro ack, cwd persistence, expand flyout) |
| **Purpose** | Docked/expandable agent CLI surface with intro gate and size modes |
| **Composition sketch** | Intro acknowledgment surface → xterm host → expand/collapse flyout dimensions |
| **States** | active/inactive; expanded; intro pending/acked; connection lifecycle |
| **CyberCore / Observatory fit** | Agent execution console; read-only transcript mode for Observatory |
| **Priority** | **P1** CyberCore · **P2** Observatory (read-only transcript variant first) |
| **Notes** | Flutter: prefer custom `DSCodeBlock` stream or `xterm`-equivalent package later; start with **transcript organism**. |

---

### 17. `PrismMeshCommsPanel` (Multi-tab secure chat / peer ops UI)

| Field | Detail |
| --- | --- |
| **Score** | **BRONZE** for Observatory · **SILVER** for CyberCore mesh products |
| **Source** | `frontend/src/components/MeshChat/index.tsx` + `useMeshChatController.ts` + flyouts |
| **Purpose** | Multi-tab messaging (infonet/meshtastic/DMs), trust badges, compose, expand flyouts for shell/infonet |
| **Composition sketch** | Tab bar + message list + compose + trust/rep badges + secondary flyout panels |
| **States** | expanded; busy; tab; compat consent prompts; unread counts |
| **CyberCore / Observatory fit** | Only if Ganthritor ships mesh/operator chat. ASW Observatory has **no** messaging product requirement today. |
| **Priority** | **P2** (document only unless mesh UI lands) |
| **Notes** | Do not pull crypto. Pattern of **tabbed comms + trust badge row** is reusable for A2A agent channels. |

---

### 18. `PrismDisplayConfigChrome` (Tactical display / REC strip)

| Field | Detail |
| --- | --- |
| **Score** | **BRONZE** |
| **Source** | `frontend/src/components/WorldviewRightPanel.tsx` |
| **Purpose** | Compact display config: bloom/sharpen/HUD layout, REC timestamp chrome, clear-UI tactical mode |
| **Composition sketch** | Minimize header + effect toggles + sliders + destructive clear-UI button; optional REC clock badge |
| **States** | minimized; effects map; uiVisible parent |
| **CyberCore / Observatory fit** | Visual polish / demo mode; optional graph glow toggles |
| **Priority** | **P2** |
| **Notes** | Aesthetic harvest for glass/tactical feel; low functional urgency. |

---

### 19. `PrismKeyboardCheatsheet`

| Field | Detail |
| --- | --- |
| **Score** | **BRONZE** (easy win) |
| **Source** | `frontend/src/components/KeyboardShortcutsOverlay.tsx` |
| **Purpose** | Modal list of key → action rows with kbd chips |
| **Composition sketch** | Backdrop + glass card + key/description rows |
| **States** | open/closed |
| **CyberCore / Observatory fit** | Desktop-first power user UX; pairs with `DSCommandPalette` |
| **Priority** | **P2** (small, ship with shell) |
| **Notes** | Nearly free; WP lacks a dedicated organism (palette is different). |

---

### 20. `PrismRiskAlertToastStack` (Geo-aware risk toasts)

| Field | Detail |
| --- | --- |
| **Score** | **BRONZE** (variant of existing toast) |
| **Source** | `frontend/src/components/AlertToast.tsx` + `useAlertToasts` |
| **Purpose** | Severity-colored toasts with risk label, progress auto-dismiss, pause-on-hover, click-to-fly |
| **Composition sketch** | Stacked toast cards; left accent; progress bar; fly action |
| **States** | enter/exit; paused; risk tier |
| **CyberCore / Observatory fit** | Ops incident alerts; governance threshold breaches |
| **Priority** | **P2** |
| **Notes** | Extend `DSToast` molecule rather than new organism if possible; elevates to organism only if stack+geo action is first-class. |

---

### 21. `PrismMapCanvasStage` (MapLibre-class multi-layer stage)

| Field | Detail |
| --- | --- |
| **Score** | **SILVER** (architecture) — **IRON** as copy-paste |
| **Source** | `frontend/src/components/MaplibreViewer.tsx` + `components/map/**` (workers, layers, icons, popups) |
| **Purpose** | High-density multi-layer map with clustering, selection, popups, measurement, pin placement, SAR AOI, style light/dark |
| **Composition sketch** | Map engine adapter + layer registry + popup factory + selection bus + workers for GeoJSON |
| **States** | style; selection; measure mode; pin mode; tile loading; flyTo |
| **CyberCore / Observatory fit** | Observatory Map workspace; geo assets if any. CyberCore graphs may stay non-geo. |
| **Priority** | **P1** as **adapter organism contract**, not MapLibre port |
| **Notes** | Flutter uses different map engine (`flutter_map` / Mapbox / etc.). Harvest **layer registry + selection + popup factory** contracts only. |

---

### 22. `PrismSettingsCockpit` (Massive multi-tab settings)

| Field | Detail |
| --- | --- |
| **Score** | **IRON** for ADS organism harvest (product-specific megaform) |
| **Source** | `frontend/src/components/SettingsPanel.tsx` (~2.7k+ lines, multi-tab) |
| **Purpose** | Runtime config: feeds, API keys, wormhole, SAR, usage meters, privacy migration |
| **Composition sketch** | Modal + tabs + forms + meters |
| **States** | many domain-specific |
| **CyberCore / Observatory fit** | CyberCore settings screens exist as pages; not a reusable ADS organism beyond **tabbed settings shell** |
| **Priority** | **P2** — harvest only “tabbed modal shell + usage meter section” as generic pattern |
| **Notes** | Skip bulk of domain settings. |

---

### 23. `PrismSupplyRiskPanel` / `PrismShodanStyleQueryPanel` / markets / radio

| Field | Detail |
| --- | --- |
| **Score** | **IRON / BRONZE** domain-specific |
| **Sources** | `ScmPanel.tsx`, `ShodanPanel.tsx`, `MarketsPanel.tsx`, `PredictionsPanel.tsx`, `RadioInterceptPanel.tsx`, `AIIntelPanel.tsx` |
| **Purpose** | Domain panels: SCM risk list, Shodan query+style presets, markets tabs, radio eavesdrop, AI pin layers |
| **Fit** | Weak for ASW Observatory; optional CyberCore “connector probe” panels |
| **Priority** | **P2** document patterns only |
| **Notes** | Transfer **minimizable connector panel chrome** shared across these, not each domain. Consider one generic `PrismConnectorPanel` (header, badge, refresh, minimize, body slot). |

---

### 24. `PrismScaleMeasureBar`

| Field | Detail |
| --- | --- |
| **Score** | **BRONZE** |
| **Source** | `frontend/src/components/ScaleBar.tsx` |
| **Purpose** | Map scale + measure mode toggle/clear |
| **Fit** | Map workspace only |
| **Priority** | **P2** |

---

### 25. `PrismRegionImageryLightbox`

| Field | Detail |
| --- | --- |
| **Score** | **BRONZE** |
| **Source** | `MaplibreViewer/popups/RegionDossierPanel.tsx`; CCTV `CctvFullscreenModal.tsx` |
| **Purpose** | Fullscreen media/image review with multi-scene nav |
| **Fit** | Evidence/media review for intel or SAR product |
| **Priority** | **P2** |

---

## Anti-patterns / skip

| Item | Why skip / constrain |
| --- | --- |
| **Copy MaplibreViewer monolith** | Thousands of lines of aviation/maritime icon maps + workers; not ADS-portable; engine-specific |
| **NewsFeed mega-component** | Dual-duty list+dossier+wiki+emissions violates organism single responsibility; harvest mode-switch only |
| **SettingsPanel god object** | Product config dump, not design-system organism |
| **Mesh crypto / wormhole / DM mutation UIs** | Outside WP read-only contract; security-sensitive; not Observatory |
| **Prediction markets / stock ticker domain** | Domain product, not ASW/CyberCore core |
| **Live radio eavesdrop / Shodan live queries** | External write-ish ops & API key UX; if needed, abstract as connector panel with fixtures |
| **desktop-shell native code** | No React/Flutter UI organisms; bridge/policy only |
| **POTUS ICAO client filters etc.** | Domain hardcodes |
| **CSS CRT / vignette gimmicks as requirements** | Optional aesthetic; keep optional theme polish |
| **Direct code transplant** | Reimplement with `DSColors`, `DSGlassPanel`, `DSTypography`, Flutter a11y focus order (`DSShell` pattern) |

---

## Molecule/atom derivation hints (deferred)

One line each — not inventorying as harvest targets:

1. **Minimizable panel chrome** — repeated header (title + plus/minus + optional badge) across almost every SB panel.  
2. **Feed health micro-dot** — `feed-dot-{status}` + mono count (bottom bar).  
3. **Risk color ramp helper** — shared by toast, scrubber, alerts (`getRiskColor`).  
4. **Freshness relative-time label** — `relativeTime` in `WorldviewLeftPanel`.  
5. **Type-colored category chip** in locate results / watchlist.  
6. **Vertical edge toggle tab** — writing-mode vertical “LAYERS” / “INTEL” buttons.  
7. **DossierRow / SectionLabel** — recon result primitives (`ReconResults.tsx`).  
8. **Trust / rep badge** — `MeshChat/RepBadge.tsx` for peer trust display.  
9. **Usage meter bar** — settings `UsageMeter` for quota visualization.  
10. **Consent confirm dialogs** — `ConfirmDialog`, KiwiSDR / LiveUAMap opt-in gates.  
11. **kbd chip** — keyboard overlay key glyph.  
12. **Drag grip header** — floating HUD reposition affordance.  
13. **Alert count pill** — SCM critical badge pattern.  
14. **Ticker item** (symbol + price + delta arrows).  
15. **Identity domain row** — visibility-scoped domain list (`IdentityHUD`).  
16. **Advanced filter field multi-select** — modal field config.  
17. **Playback transport icon row** — time machine controls.  
18. **Map popup shell** — shared chrome for entity popups under `MaplibreViewer/popups/`.  

---

## Existing WP vs new (summary table)

| Already covered (WP) | New organism candidates (from SB) |
| --- | --- |
| `DSShell`, sidebar, topbar | `PrismMapHudWorkspace` |
| `DSDetailInspector`, story panel | `PrismEntityIntelPanel` (type registry) |
| `DSGraphCanvas` suite | `PrismEntityRelationCard` (preview) |
| `DSTimeline` event list | `PrismTimeMachineScrubber` |
| `DSCommandPalette` | `PrismEntityLocateSearch` |
| `DSLogViewer` | (reuse for LiveActivityLog body) |
| `DSStatusGrid` / health cards | `PrismCoordinateStatusBar`, ticker, layer freshness |
| `DSToast` | Risk toast variant only |
| `DSFilterChipGroup` | `PrismFilterWorkbench` + `PrismLayerControlPanel` |
| `DSTabBar` | Osint workbench / terminal modules (composition) |
| `MasterDetailTemplate` | Map HUD template (new layout family) |
| Lane board, data table | No SB peers of equal priority |

---

## Top 10 recommendations

1. **Add `PrismMapHudWorkspace` (P0)** — dual collapsible HUD columns over a stage slot; vertical edge toggles; UI hide/restore; panel persistence. Primary layout harvest from `page.tsx`.  
2. **Add `PrismLayerControlPanel` (P0)** — grouped layer toggles with counts, freshness, master toggle, consent gate hooks; domain-agnostic model for Map catalog + CyberCore feed flags. Source: `WorldviewLeftPanel.tsx`.  
3. **Elevate selection intel: `PrismEntityIntelPanel` (P0)** — pluggable dossier registry on top of `DSDetailInspector`; learn mode-switch from `NewsFeed.tsx` without the megafile.  
4. **Add `PrismEntityLocateSearch` (P0)** — multi-corpus typed locate results + fly/select; keep separate from command palette. Source: `FindLocateBar.tsx`.  
5. **Add `PrismTimeMachineScrubber` (P0)** — density histogram + playback transport; pair with existing `DSTimeline` for History workspace. Sources: `TimelineScrubber.tsx`, `TimelinePanel.tsx`.  
6. **Add `PrismFloatingAnalyticsHud` (P1)** — draggable minimizable overlay shell for metrics/alerts; domain-free slots. Source: `GtAnalyticsHud.tsx`.  
7. **Add `PrismOsintWorkbench` + dossier shell (P1)** — tabbed query workbench and polymorphic result bodies for CyberCore tool/MCP inspect. Sources: `ReconPanel.tsx`, `ReconResults.tsx`.  
8. **Add stage chrome pack (P1)** — `PrismCoordinateStatusBar`, `PrismWatchlistDock`, `PrismStatusTicker`, `PrismMapLegend` as small composable organisms for Map workspace polish.  
9. **Define `PrismMapCanvasStage` contract (P1)** — layer registry, selection bus, popup factory — **without** porting MapLibre/SB icons; Flutter engine-agnostic.  
10. **CyberCore ops track (P1–P2)** — `PrismOpsControlCluster`, `PrismTerminalWorkspace`, `PrismAgentShellPanel` (start with read-only transcript); defer full mesh chat (`MeshChat`) until product requires it.

### Immediate task candidates (for Warp Prism task system)

| Suggested task | Outcome |
| --- | --- |
| ADS: Map HUD workspace template | `PrismMapHudWorkspace` + gallery demo over mock stage |
| ADS: Layer control organism | Data model + minimize + freshness + gallery |
| ADS: Entity dossier registry | Extend inspector with type → body widgets |
| ADS: Locate search organism | Fixture entity index + results dropdown |
| ADS: Time machine scrubber | CustomPaint density + transport controls + fixture snapshots |
| ADS: Floating HUD shell | Drag + minimize + persistence demo |
| ADS: Recon/dossier workbench | Tab rail + `DossierShell` molecules |

---

## Evidence map (high-confidence claims)

| Claim | Evidence | Confidence |
| --- | --- | --- |
| Frontend is Next.js 16 + React 19 + MapLibre + Framer Motion | `frontend/package.json` | Proven |
| Single dashboard page composes dual HUD + map | `frontend/src/app/page.tsx` | Proven |
| Left stack: layers, mesh, shodan, recon, scm, AI intel | `page.tsx` ~588–688 | Proven |
| Right stack: ops controls, find, timeline, filters, news | `page.tsx` ~731–808 | Proven |
| NewsFeed is multi-mode entity/intel surface | `NewsFeed.tsx` `NewsFeedInner` + region dossier blocks | Proven |
| Time machine has live/snapshot playback | `TimelinePanel.tsx`, `TimelineScrubber.tsx` | Proven |
| Floating GT HUD is draggable/minimizable composite | `GtAnalyticsHud.tsx` | Proven |
| desktop-shell is native bridge, not UI organism tree | `desktop-shell/README.md` | Proven |
| WP organisms list as of harvest | `organisms.dart` + inventory report | Proven |
| WP product is read-only observatory | `warp-prism/AGENTS.md` §5 | Proven |

## What was not found

- No multi-route Next app router product pages beyond the dashboard root (SPA-as-map).  
- No shared Atomic Design naming (atoms/molecules/organisms) in ShadowBroker — harvest is **retroactive taxonomy**.  
- No Flutter UI in ShadowBroker frontend.  
- No first-class “command palette” organism (search is entity locate).  
- No Kanban/lane board peer.  
- No Storybook / design-system package — components are product-coupled.  

---

## Harvest scoring rollup

| Score | Count | Items (abbrev) |
| --- | --- | --- |
| **GOLD** | 5 | MapHudWorkspace, LayerControl, EntityIntel, LocateSearch, TimeMachineScrubber |
| **SILVER** | 10 | FloatingHud, OpsCluster, Watchlist, Ticker, CoordBar, Legend, FilterWorkbench, OsintWorkbench, EntityRelationCard, MapStage contract (+ Terminal/Agent for CyberCore) |
| **BRONZE** | 6 | DisplayConfig, KeyboardCheatsheet, RiskToast, ScaleBar, ImageryLightbox, MeshComms (obs) |
| **IRON** | 3+ | Settings god panel domain dump; domain panels (SCM/Shodan/markets/radio) as product; MapLibre monolith copy |

---

*End of report. Source tree was not modified. Patterns only — reimplement under Warp Prism ADS tokens and read-only product contract.*
