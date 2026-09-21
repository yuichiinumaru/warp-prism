# ADS Organism Harvest — Osiris — 2026-07-10

> **Analyst role**: design-system harvest (gt-external-intelligence-analyst / design-system-migrate)
> **Filter**: ORGANISMS only (composite shells, boards, tables, timelines, inspectors, chat/intel panels, navigation frames, multi-panel workspaces)
> **Source (read-only)**: `/home/sephiroth/working/ganthritor/hyperion/references/simplifaisoul-osiris/`
> **Local ADS baseline**: `packages/warp_prism_ui/lib/src/organisms/`
> **Product lens**: Warp Prism desktop-first dark glass (Observatory + CyberCore pilot UI); read-only fixtures preferred; no code transplant from Osiris

---

## Source map

### Stack

| Layer | Evidence |
| --- | --- |
| Framework | Next.js **16.2.6** + React **19.2.4** (`package.json` L15–24) |
| Styling | Tailwind CSS **v4** + large design-token CSS in `src/app/globals.css` (void/obsidian, gold/cyan HUD, glass panels, gotham risk tags) |
| Map | MapLibre GL **5.x** + `react-map-gl` (`OsirisMap.tsx`, `package.json` L21–27) |
| Graph | `react-force-graph-2d` (`EntityGraphPanel.tsx` L5–12) |
| Motion | `framer-motion` throughout panels |
| Icons | `lucide-react` |
| Media | `hls.js` in `CameraViewer.tsx` |
| AI | Gemini via `/api/ai/*` (`AiAnalyst.tsx`, `AiOverview.tsx`) |
| Tests | Vitest (`package.json` L10–12) |

### Routes / app shape

| Path | Role |
| --- | --- |
| `src/app/layout.tsx` | Root chrome; wraps app in named `ErrorBoundary` |
| `src/app/page.tsx` | **Single-route SPA dashboard** (~1.3k lines) — map canvas + all HUD composition state |
| `src/app/api/**` | Backend/proxy surface only (not harvested as UI) |
| `src/app/globals.css` | Design system tokens + organism chrome classes (`.glass-panel`, `.hud-text`, `.gotham-tag*`, `.btn-tactical`, ticker, mobile-nav) |

**Proven fact**: there is no multi-page app router taxonomy for UI. Composition is one full-viewport workspace orchestrated by `Dashboard` in `page.tsx`.

### Component taxonomy (frontend only)

| Bucket | Files under `src/components/` |
| --- | --- |
| **Workspace / shell** | `page.tsx` (composition root), `LayerPanel.tsx`, `KeyboardShortcuts.tsx`, `ErrorBoundary.tsx`, `ScaleBar.tsx` |
| **Spatial canvas** | `OsirisMap.tsx` (~1600 lines MapLibre organism) |
| **Intel / feed panels** | `IntelFeed.tsx`, `LiveAlerts.tsx`, `MarketsPanel.tsx`, `ScmPanel.tsx`, `GlobalStatusBar.tsx` |
| **Investigation tools** | `OsintPanel.tsx` (~1.1k lines multi-tab recon workbench), `EntityGraphPanel.tsx`, `SearchBar.tsx`, `ViewPresets.tsx`, `SharePanel.tsx` |
| **Media / detail** | `CameraViewer.tsx`, live-feed modal (inline in `page.tsx` ~L1004–1091), region dossier (inline `page.tsx` ~L1199–1231) |
| **AI surfaces** | `AiAnalyst.tsx`, `AiOverview.tsx` |
| **Promo / non-product** | `TokenPanel.tsx` ($OSIRIS chart modal) |

### Shell composition pattern (proven)

Desktop composition in `page.tsx`:

1. Full-bleed map (`OsirisMap`) as sole content canvas
2. Left **icon layer rail** (`LayerPanel` when `showLayers && !isMobile`, ~L928)
3. Right **vertical tool strip** with exclusive slideouts (OSINT / Markets / Alerts / Entity Graph / Search) (~L932–1002)
4. Top brand header + C2 status metrics (~L858–905)
5. Bottom map projection/style controls + scale (~L783–856), coord HUD (~L1177–1195), live ticker (`GlobalStatusBar` ~L1268)
6. Overlays: splash, region dossier, camera viewer, entity graph drawer, live feed modal, keyboard help
7. Mobile: bottom nav + spring drawer multiplexing the same panels (~L1102–1174)

Mutual-exclusion rule is explicit: opening one right-strip panel closes others (`setShowIntel` / `setShowMarkets` / `setShowAlerts` / `setShowEntityGraph` toggles at L935–990).

### Visual system notes (organism chrome, not atoms)

From `globals.css` `:root` (L9–69) and theme variant `body.theme-ghost` (L84–118):

- Void backgrounds `#04040A` / `#06060C`, gold `#D4AF37`, cyan `#00E5FF`
- Risk vocabulary via `.gotham-tag--critical|high|medium|low|info`
- Panel recipe: translucent `rgba` panel + blur + gold-tinted border (`.glass-panel` ~L152+)
- Dual theme: `core` (gold/cyan) vs `ghost` (violet) toggled from LayerPanel footer

Aligns well with Warp Prism “ultradark obsidian glass + restrained hacker/protoss accents” — harvest **composition**, re-skin with `DSColors` / `DSGlassPanel`.

---

## Existing WP organism overlap

Baseline inventory from `packages/warp_prism_ui/lib/src/organisms/organisms.dart` and directory listing:

| WP organism | Path | Role |
| --- | --- | --- |
| `DSShell` / `DSShellResponsive` | `ds_shell.dart` | App chrome: sidebar + topbar + content + inspector; responsive drawer/full-screen detail |
| `DSSidebar` | `ds_sidebar.dart` | Workspace-area navigation list |
| `DSTopbar` | `ds_topbar.dart` | Search, breadcrumbs, actions |
| `DSDetailInspector` | `ds_detail_inspector.dart` | Sectioned asset detail side panel |
| `DSStoryPanel` | `ds_story_panel.dart` | Narrative insight stack |
| `DSTimeline` | `ds_timeline.dart` | Chronological changelog list |
| `DSGraphCanvas` + `graph/*` | `ds_graph_canvas.dart`, `graph/` | Force-directed graph canvas + typed model/layout/painter |
| `DSLaneBoard` | `ds_lane_board.dart` | Kanban/task lanes |
| `DSStatusGrid` | `ds_status_grid.dart` | Health-card grid for services |
| `DSLogViewer` | `log_viewer/` | Severity-filtered streaming log |
| `DSCommandPalette` | `command_palette/` | Cmd+K fuzzy command surface |
| `DSDataTable` | `data_table/` | Operational table |
| `DSTabBar` / `DSTabView` | `tab_bar/` | Tab chrome |
| `DSSplitPane` | `split_pane/` | Resizable multi-pane |
| `DSVirtualList` / `DSVirtualGrid` | `virtual_scroll/` | Large-list performance |
| `DSCodeBlock` | `code_block/` | Code surface |
| `DSMarkdownRenderer` | `markdown_renderer/` | Markdown body |
| `DSErrorBoundary` / `DSFallbackView` | `ds_error_boundary.dart`, `ds_fallback_view.dart` | Panel isolation + fallback |

**Supporting molecules already present** (context for gap claims): `DSSearchBar`, `DSGlassPanel`, `DSFilterChipGroup`, `DSMetricTile`, `DSHealthCard`, `DSToast*`, skeletons, etc. under `lib/src/molecules/`.

### Overlap matrix (Osiris organism → WP)

| Osiris candidate | Closest WP | Gap nature |
| --- | --- | --- |
| App shell (`page.tsx`) | `DSShell` | **Different topology**: WP is sidebar/topbar/content; Osiris is map-first floating HUD |
| Layer rail | `DSSidebar` | Rail is **icon column + hover flyout toggles + live counts**, not route nav |
| Right tool strip + slideouts | `DSShell.inspector` + `DSSplitPane` | Missing **exclusive multi-tool strip** with transient slideouts |
| Entity graph panel | `DSGraphCanvas` + `DSDetailInspector` | Missing **expand-on-demand** merge graph + graph-linked property footer + type legend as one organism |
| Intel / live alerts | `DSTimeline` / `DSLogViewer` / `DSStoryPanel` | Missing **multi-source risk feed** with filter chips + locate-to-canvas + maximize |
| Osint multi-tool | `DSTabView` + `DSDetailInspector` | Missing **tool-suite workbench** (tab registry, query, history, structured result, map handoff) |
| AI analyst chat | None | **No chat/intel conversation organism** |
| Status ticker | `DSTopbar` / status atoms | Missing **marquee live strip** organism |
| View presets | Command palette / custom | Missing **preset jump grid** organism |
| Share view state | None | Missing **workspace share URL** organism |
| Region dossier | `DSDetailInspector` / `DSStoryPanel` | Pattern exists as inspector; missing **spatial context card** overlay |
| Camera / stream viewer | None | Missing **media detail overlay** organism |
| Markets / SCM risk panels | `DSStatusGrid` + `DSMetricTile` | Partial metric grid; missing **sectioned risk command** composite |
| Keyboard help overlay | `DSCommandPalette` | Overlap — palette supersedes for WP |
| Error boundary | `DSErrorBoundary` | Already covered |
| Token / promo modal | — | Out of product scope |

**Negative evidence (searched, not found in Osiris UI)**:

- No kanban / lane board
- No data table organism
- No log severity stream viewer (feeds are news/alert lists)
- No command palette (only single-key shortcuts + SearchBar)
- No split-pane resizer (panels are fixed widths / maximize-to-viewport)
- No virtualized 10k list abstraction (slice + max-height scroll only)
- No multi-route app shell (single `page.tsx`)

---

## Candidate organisms (ranked)

Scoring: **GOLD** high impact / low integration risk / clear destination · **SILVER** valuable but needs design work · **BRONZE** interesting, defer · **IRON** skip (with reason).

### Ranked table

| Rank | Score | Organism (conceptual name) | Primary source | Local destination | Effort | Risk |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | **GOLD** | **Map/Canvas Workspace HUD Shell** | `src/app/page.tsx` composition (~L762–1273) | New: `ds_canvas_workspace_shell.dart` or template `CanvasHudTemplate`; CyberCore map pilot + Observatory map epic | L | Med — topology differs from `DSShell` |
| 2 | **GOLD** | **Exclusive Tool-Strip Slideout Frame** | `page.tsx` right strip (~L932–1002) | New: `ds_tool_strip.dart` + `ds_slideout_host.dart` | M | Low — pure layout/state, domain-agnostic |
| 3 | **GOLD** | **Layer Rail + Flyout Toggles** | `LayerPanel.tsx` desktop (~L216–341), groups (~L20–108) | New: `ds_layer_rail.dart` for Map/CyberCore layers; Observatory filter groups | M | Low |
| 4 | **GOLD** | **Expandable Entity Intel Graph Panel** | `EntityGraphPanel.tsx` (full file) | Extend `graph/` + compose with `DSDetailInspector` footer → `ds_entity_graph_workbench.dart` | L | Med — graph API design |
| 5 | **GOLD** | **Multi-Source Live Alerts Feed** | `LiveAlerts.tsx` | New: `ds_alert_feed.dart` (severity/ops events) | M | Low |
| 6 | **GOLD** | **Multi-Tool Recon / Lookup Workbench** | `OsintPanel.tsx` tabs L16–35 + query/result/history | New: `ds_tool_workbench.dart` for CyberCore MCP/tools | L | Med — tool registry contract |
| 7 | **GOLD** | **AI Analyst Chat Panel** | `AiAnalyst.tsx` (~L365–end UI) | New: `ds_intel_chat_panel.dart` (fixture-first, no live Gemini required) | M | Med — streaming/markdown XSS patterns must be WP-safe |
| 8 | **SILVER** | **SIGINT / Risk-Scored Intel List** | `IntelFeed.tsx` | `ds_intel_feed.dart` or specialization of alert feed | S | Low |
| 9 | **SILVER** | **One-Click Panel AI Overview Card** | `AiOverview.tsx` | Molecule-ish but used as panel section → `ds_ai_overview_card` in organisms if stateful | S | Low |
| 10 | **SILVER** | **Region / Context Dossier Card** | `page.tsx` ~L1199–1231 | Overlay mode for `DSDetailInspector` / `DSStoryPanel` | S | Low |
| 11 | **SILVER** | **Global Status Ticker** | `GlobalStatusBar.tsx` | `ds_status_ticker.dart` under top/bottom chrome | S | Low — a11y for marquee |
| 12 | **SILVER** | **View / Workspace Presets Grid** | `ViewPresets.tsx` | `ds_view_presets.dart` (region or workspace snapshots) | S | Low |
| 13 | **SILVER** | **Share Workspace State Panel** | `SharePanel.tsx` | `ds_share_workspace_panel.dart` (encode layers/view/selection) | S | Low |
| 14 | **SILVER** | **Sectioned Markets / Metrics Command Panel** | `MarketsPanel.tsx` | Compose `DSMetricTile` + `DSTabBar` → `ds_metrics_command_panel.dart` | M | Low |
| 15 | **SILVER** | **Multi-Bucket Risk Command Panel** | `ScmPanel.tsx` | Governance/risk rollup for Observatory | M | Low |
| 16 | **SILVER** | **Media / Stream Detail Overlay** | `CameraViewer.tsx` + live feed modal in `page.tsx` | `ds_media_detail_overlay.dart` | M | Med — platform media stack differs (no HLS copy) |
| 17 | **SILVER** | **Map Control Strip (mode toggles + scale)** | `page.tsx` ~L783–856 + `ScaleBar.tsx` | Canvas chrome companion for map pilot | S | Low |
| 18 | **SILVER** | **Mobile Bottom Nav + Panel Drawer** | `page.tsx` ~L1102–1174 | Extension of `DSShellResponsive` mobile story | M | Med — WP is desktop-first |
| 19 | **BRONZE** | **Boot / Splash Sequence** | `page.tsx` splash ~L690–758 | Demo polish only | S | Low |
| 20 | **BRONZE** | **Keyboard Shortcuts Help Modal** | `KeyboardShortcuts.tsx` | Prefer extending `DSCommandPalette` help | S | Low |
| 21 | **BRONZE** | **Search-Locate with Type-Aware Zoom** | `SearchBar.tsx` | Enhance `DSSearchBar` / command palette (mostly molecule) | S | Low |
| 22 | **IRON** | **Token / promo chart modal** | `TokenPanel.tsx` | No product fit | — | — |
| 23 | **IRON** | **OsirisMap MapLibre implementation** | `OsirisMap.tsx` | Domain GEOINT globe; do **not** port MapLibre code. Harvest **layer/entity interaction contracts** only into Flutter map pilot separately | XL | High |
| 24 | **IRON** | **ErrorBoundary** | `ErrorBoundary.tsx` | Already have `DSErrorBoundary` | — | — |

### Detailed candidate dossiers (organisms only)

#### 1. Map/Canvas Workspace HUD Shell — GOLD

**What it is**: Full-viewport content canvas with pointer-events-none HUD layers that re-enable on interactive children; z-index stacking for panels vs overlays; desktop vs mobile panel hosts.

**Evidence**: `page.tsx` map wrapper L762–780; absolute HUD regions L783–1002, L1177–1273; vignette/scanline chrome L1248–1262.

**Why WP**: Observatory Map workspace and CyberCore spatial/ops pilot need a shell that is **not** forced into sidebar-first `DSShell`. A `CanvasHudTemplate` can host Flutter map (or graph canvas) with dockable glass panels.

**Composition notes**:
- Canvas (content)
- Left rail slot, right strip slot, top brand/status, bottom telemetry
- Overlay stack (modal, inspector drawer, toast)
- Keyboard chord layer

**Do not copy**: Osiris-specific branding SVG, Ko-fi links, splash mythology copy.

#### 2. Exclusive Tool-Strip Slideout Frame — GOLD

**What it is**: Vertical pill of icon buttons mid-right; each opens a fixed-width slideout; only one active.

**Evidence**: `page.tsx` L933–1002 (`group` + `AnimatePresence` + mutual exclusion setters).

**WP API sketch**:
```dart
DSToolStrip(
  items: [DSToolStripItem(id: 'recon', icon: ..., panel: ...)],
  activeId: active,
  onActiveChanged: ...,
  side: AxisDirection.right,
)
```

#### 3. Layer Rail + Flyout Toggles — GOLD

**What it is**: 48px left column of group icons; hover opens glass flyout with toggles + live entity counts; group icon glow when any child active; optional theme switcher footer.

**Evidence**: `LayerPanel.tsx` `LAYER_GROUPS` L20–108; desktop rail L216–341; `getCount` L146–160; ghost theme toggle L319–339.

**WP mapping**: Map layer visibility, governance filter groups, CyberCore capability layers — **not** primary app navigation (`DSSidebar` remains for routes).

#### 4. Expandable Entity Intel Graph Panel — GOLD

**What it is**: Right-edge full-height glass drawer: header, root label, force graph, selected-node property grid, expand-target action, type color legend; width expand 480px ↔ 60vw; progressive graph merge on node click.

**Evidence**: `EntityGraphPanel.tsx` types L16–30; `mergeGraph` L63–80; `expandEntity` L82–99; paint selection brackets L121–172; layout L193–352.

**WP mapping**:
- Reuse `graph/` typed model + layout
- Add **progressive expand** + **selected node detail footer** as first-class composition (today `DSDetailInspector` is separate)
- Type palette → `DSColors.forAssetKind` / operational state colors

**Proven UI details worth transplanting as design**:
- Target-lock corner brackets on selection (not only scale/pulse)
- Edge label midpoints at low opacity
- Empty “awaiting target” typewriter state
- Node/link counts in subheader

#### 5. Multi-Source Live Alerts Feed — GOLD

**What it is**: Collapsible/maximizable glass panel; filter tabs (`all`/`news`/`quakes`/`feeds`); unified alert model with severity; locate-on-map; optional watch-feed handoff; count badges.

**Evidence**: `LiveAlerts.tsx` props L12–16; severity map L18–24; filter L29 + L100–103; maximize portal pattern L118–145+.

**WP mapping**: Operate/governance live events, MCP health alerts, task pressure, cyber events — **one organism** with pluggable sources, not three separate panels.

#### 6. Multi-Tool Recon / Lookup Workbench — GOLD

**What it is**: Horizontal tab registry of tools (port scan, DNS, WHOIS, certs, threats, …); shared query field; loading/error; structured `ResultRow` rendering; recent history; fullscreen mode; callbacks for map visualization (`onSweepVisualize`, `onScanGeolocate`).

**Evidence**: `OsintPanel.tsx` `TABS` L16–35; state L39–53; `runLookup` L111+; `ResultRow` L273–283; history L244.

**WP mapping (CyberCore)**: MCP tool invoker UI, provider probe console, policy dry-run workbench — **registry-driven tabs + result body + history rail**. Do not hardcode Shodan/Nmap.

#### 7. AI Analyst Chat Panel — GOLD

**What it is**: FAB → floating glass chat; injects live dashboard context into API; message list with role chrome; briefing action; settings for user-supplied key; markdown-lite render; mobile backdrop.

**Evidence**: `AiAnalyst.tsx` `buildContext` L114–164; FAB L365–393; panel L415–428; briefing L285–334; `renderMarkdown` L166–184 (HTML escape then light markup).

**WP mapping**: Fixture-backed “workspace analyst” for Observatory storytelling / CyberCore triage. Prefer existing `DSMarkdownRenderer` over custom HTML. Keep offline/fixture mode first (WP read-only product constraint).

#### 8–15. SILVER set (brief)

| Item | Transferable composition idea |
| --- | --- |
| IntelFeed | Risk badge + source chip + relative time + pin-to-map row; critical “machine assessment” callout |
| AiOverview | Panel-section one-shot summary with regenerate; always-useful fallback generator pattern (backend) |
| Region dossier | Centered glass card from spatial selection; loading “COMPILING INTEL…” |
| Status ticker | Fixed-height LIVE label + CSS marquee + hover detail tooltip |
| View presets | 2-col grid of named camera targets; “hot” accent for priority regions |
| Share panel | Encode lat/lon/zoom/layers → clipboard URL; keyboard `S` |
| Markets panel | Section tabs + ticker rows + banner severity + embed AI overview |
| SCM risk | Multi-section risk rollup with green “all clear” empty states |

#### 16–18. Media + mobile — SILVER (constrained)

- **CameraViewer**: HUD header with Zulu clock + CAM-ID, multi-transport body, locate/retry/fullscreen — harvest as media overlay skeleton only.
- **Mobile nav drawer**: Spring sheet above bottom tab bar multiplexing panels — useful if WP ever ships narrow breakpoints; secondary to desktop.

---

## Anti-patterns / skip

| Item | Why IRON / skip | Source |
| --- | --- | --- |
| **TokenPanel / $OSIRIS chart** | Promo/token modal; no Observatory/CyberCore fit | `TokenPanel.tsx` |
| **Porting MapLibre/OsirisMap** | Different platform stack; 1600-line domain GEOINT blob; copy would violate “pattern not code” and Flutter map strategy | `OsirisMap.tsx` |
| **Hardcoded live YouTube news list** | Content/product coupling, not reusable ADS | `LiveAlerts.tsx` `BUILTIN_FEEDS` L32–62 |
| **Direct client calls to CoinGecko/USGS from UI** | Bypass WP data/fixture/backend contracts; CORS/ops liability | `GlobalStatusBar.tsx` L51–85 |
| **localStorage API keys in chat UI** | Security anti-pattern for Ganthritor | `AiAnalyst.tsx` L203–208, L346–358 |
| **dangerouslySetInnerHTML markdown** | XSS risk; WP should use `DSMarkdownRenderer` | `AiAnalyst.tsx` L166–184 usage later in file |
| **Monolithic page.tsx state god-object** | ~20+ useState fields, dataRef versioning — do **not** replicate; split shell/tool/map controllers | `page.tsx` L87–118 |
| **ToggleSwitch with empty onClick in flyout** | Accessibility footgun (click on row vs switch) | `LayerPanel.tsx` L295 |
| **Duplicate mobile support blocks** | Copy-paste drift (two similar mobile top status blocks) | `page.tsx` ~L907–923 vs L1093–1100 |
| **CRT/scanline/vignette everywhere** | Fun for Osiris brand; WP already has restrained glass — use sparingly | `page.tsx` L1248–1250 |
| **Emoji as primary iconography in presets** | Prefer Lucide-equivalent `DSIcon` | `ViewPresets.tsx` L10–23 |
| **ErrorBoundary only** | Already implemented better in WP | `ErrorBoundary.tsx` vs `ds_error_boundary.dart` |

---

## Molecule/atom derivation hints (deferred)

Not harvested as organisms; useful when implementing the GOLD set:

| Hint | From | WP landing (later) |
| --- | --- | --- |
| Spring toggle switch | `LayerPanel.tsx` `ToggleSwitch` L111–138 | Atom: `DSToggle` if missing |
| Gotham risk tags | `globals.css` `.gotham-tag--*` | Extend `DSBadge` severity variants |
| HUD label / value pair | `.hud-label` / `.hud-value` usage in mobile stats | Molecule: `DSHudMetric` |
| Live pulse dot | `animate-osiris-pulse` next to headers | Already near `DSStatusDot` |
| Result row (label 90px + mono value) | `OsintPanel.tsx` `ResultRow` | Molecule: `DSKeyValueRow` (may overlap `DSPropertyRow`) |
| Maximize / collapse panel chrome | LiveAlerts / Markets headers | Molecule: `DSPanelChrome` (title, badge, pulse, max, chevron) |
| Tactical full-width button | `.btn-tactical` + EntityGraph expand | Atom/button variant |
| Corner frame / scanline accents | EntityGraphPanel inline styles L208–235 | Token/motion only — optional |
| Type-aware geocode zoom | `SearchBar.tsx` `getZoomForType` | Utility, not widget |
| Scale bar from zoom/lat | `ScaleBar.tsx` | Molecule for map chrome |

---

## Top 10 recommendations

1. **Author `CanvasHudTemplate` / `DSCanvasWorkspaceShell` (GOLD #1)**  
   Separate from `DSShell`. Slots: canvas, leftRail, rightStrip, topStatus, bottomTelemetry, overlays. Primary destination: Map workspace + CyberCore pilot. Evidence model: `page.tsx` composition.

2. **Ship `DSToolStrip` + exclusive slideout host (GOLD #2)**  
   Domain-agnostic. Wire OSINT-like tools, markets, alerts, graph, search without bloating `DSShell.inspector` (which is selection-detail oriented).

3. **Ship `DSLayerRail` (GOLD #3)**  
   Data-driven `LayerGroup { id, label, icon, layers: [{id,label,count?}] }`. Hover/focus flyouts for desktop; stacked list for narrow. Use for map layers first; reuse for filter taxonomies.

4. **Compose `DSEntityGraphWorkbench` from `graph/` + inspector footer (GOLD #4)**  
   Add progressive expand, type legend, selection brackets, node/link counts. Do not rewrite force layout — extend existing graph package. Align node types with ASW asset kinds.

5. **Ship `DSAlertFeed` multi-source organism (GOLD #5)**  
   Unified model: `{id, type, title, severity, source, time, lat?, lng?, actions[]}`. Filters + maximize + empty “awaiting…” state. Prefer virtualization via `DSVirtualList` for high volume (Osiris does not — improve on it).

6. **Ship `DSToolWorkbench` for CyberCore (GOLD #6)**  
   Tab registry + query + history + result body + optional “visualize on canvas” callback. Fixture tools only until Go backend exists. Steal Osiris information architecture, not endpoints.

7. **Ship fixture-first `DSIntelChatPanel` (GOLD #7)**  
   FAB/dockable chat; inject workspace snapshot as context; briefing button; use `DSMarkdownRenderer`. No client-side API key storage. Optional later: parent AI proxy.

8. **Standardize collapsible/maximizable `DSPanelChrome` (enables SILVER #8–15)**  
   Shared header pattern from LiveAlerts/Markets/IntelFeed: icon, HUD title, count tags, live pulse, maximize, collapse. Reduces one-off panel code.

9. **Add lightweight workspace memory organisms (SILVER #12–13)**  
   `DSViewPresets` (named camera/workspace snapshots) + `DSShareWorkspacePanel` (encode selection/layers/view to URL or clipboard). Complements existing preset/snapshot tasks without Osiris social share clutter.

10. **Explicitly do not port MapLibre, TokenPanel, or client-side third-party tickers (IRON)**  
    Harvest only interaction contracts (layer keys, entity click → graph target, scan geolocate → flyTo). Keep data behind WP fixtures / future Go APIs. Maintain ADS purity: reimplement under `warp_prism_ui` tokens.

### Suggested implementation order (task-shaped)

| Wave | Organisms | Why first |
| --- | --- | --- |
| A | ToolStrip, LayerRail, PanelChrome | Layout primitives; unblocks all panels |
| B | CanvasHudTemplate | Host for map/graph pilots |
| C | AlertFeed, IntelFeed specialization | High user value, moderate complexity |
| D | EntityGraphWorkbench | Builds on existing graph maturity |
| E | ToolWorkbench, IntelChat | CyberCore-facing; needs contracts/fixtures |
| F | Ticker, Presets, Share, Dossier, Media | Polish / secondary |

### Confidence notes

| Claim | Confidence | Basis |
| --- | --- | --- |
| Single-route map-first shell | **High** | Only `src/app/page.tsx` UI route; components are panels |
| Organism list is complete for `src/components/` | **High** | Full directory listing + export inventory |
| WP organism inventory | **High** | `organisms.dart` + tree walk 2026-07-10 |
| Transfer scores | **Medium–High** | Product fit inferred from WP ADS + AGENTS.md Observatory constraints |
| Backend/API patterns | **Out of scope** | Intentionally not scored (frontend harvest only) |

### Files inspected (read-only)

**Osiris**: `package.json`, `src/app/layout.tsx`, `src/app/page.tsx`, `src/app/globals.css` (partial), `src/components/{AiAnalyst,AiOverview,CameraViewer,EntityGraphPanel,ErrorBoundary,GlobalStatusBar,IntelFeed,KeyboardShortcuts,LayerPanel,LiveAlerts,MarketsPanel,OsintPanel,OsirisMap,ScaleBar,ScmPanel,SearchBar,SharePanel,TokenPanel,ViewPresets}.tsx`

**Warp Prism**: `packages/warp_prism_ui/lib/src/organisms/**`, `organisms.dart`, `ds_shell.dart`, `ds_detail_inspector.dart`, sample headers for story/timeline/command palette; prior `docs/reports/ads-gap-analysis-20260608.md` (historical — many “MISSING” items there are now present; this harvest supersedes for Osiris-specific organism gaps only).

---

*End of harvest. No files outside this report were modified. Osiris reference left untouched.*
