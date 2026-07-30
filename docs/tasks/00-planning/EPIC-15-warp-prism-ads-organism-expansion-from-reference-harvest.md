# EPIC 15 — Warp Prism ADS Organism Expansion (Reference Harvest)

> **Planning Status**: Active Epic  
> **Executable?**: No — planning artifact only. Executable work lives as `Task 15NN` under task lanes.  
> **Promotion Gate**: Promote tasks when EPIC-13 public contract is stable enough for new organisms (barrel, gallery, goldens, boundaries green).  
> **Origin**: User direction 2026-07-10 — increment Atomic Design System while CyberCore Go backend is developed; harvest organisms only from Hyperion reference frontends.  
> **Depends on**: EPIC-01 (ADS foundation), EPIC-13 (public contract / Prism\* barrel), Task 1105 (token/catalog policy). Soft-depends EPIC-05 (Map surface) for product integration, not for pure ADS organism delivery.  
> **Related**: EPIC-11 (CyberCore frontend pilot — fixture-first consumers of new ops organisms).

---

## Goal

Expand `packages/warp_prism_ui` with a new generation of **organism-level** composites harvested from:

| Reference | Path (read-only) |
| --- | --- |
| **ShadowBroker** | `ganthritor/hyperion/references/bigbodycobain-shadowbroker/` (frontend + desktop-shell bridge only) |
| **Osiris** | `ganthritor/hyperion/references/simplifaisoul-osiris/` (Next.js SPA UI) |

**Constraint**: organisms first. Molecules and atoms are **derived later** from organism contracts — not reverse-invented in isolation.

**Product posture**:

- Desktop-first, ultradark obsidian glass, restrained accents (existing ADS tokens).
- Reimplement patterns in Flutter/Dart Prism API — **do not port** MapLibre, react-map-gl, force-graph JS, or reference source files.
- Prefer **fixture/mock data** so CyberCore Go backend can land later without blocking ADS.
- Observatory keeps `DSShell` / route shell; new **map-first HUD workspace** is an additional layout class, not a replacement for all app chrome.

---

## Source Evidence

| Artifact | Path |
| --- | --- |
| Unified harvest | `docs/reports/ads-organism-harvest-unified-2026-07-10.md` |
| ShadowBroker harvest | `docs/reports/ads-organism-harvest-shadowbroker-2026-07-10.md` |
| Osiris harvest | `docs/reports/ads-organism-harvest-osiris-2026-07-10.md` |
| Existing organisms | `packages/warp_prism_ui/lib/src/organisms/` |
| Public barrel / aliases | `packages/warp_prism_ui/lib/warp_prism_ui.dart`, `lib/src/prism_aliases.dart` |
| Gallery / catalog | `lib/src/gallery/`, `apps/catalog/` |

### Shared reference pattern (both frontends)

1. Full-bleed **canvas/stage** (map)  
2. Floating glass **HUD** (left rail, right tool strip, bottom chrome)  
3. **Exclusive** tool slideouts (one open → others close)  
4. **Selection → dossier** body switch by entity type  
5. Live **status strips** (ticker, coords, feed health)

### Already covered (do not re-task as new organisms)

`DSShell`, `DSSidebar`, `DSTopbar`, `DSDetailInspector`, `DSGraphCanvas`, `DSTimeline` (event list), `DSLaneBoard`, `DSLogViewer`, `DSCommandPalette`, `DSDataTable`, `DSTabBar`/`DSTabView`, `DSSplitPane`, `DSVirtualScroll`, `DSStatusGrid`, toast system, error boundary / fallback, code/markdown blocks.

Compose new organisms **using** these where possible.

### Explicit skips (out of scope for this epic)

- Porting MapLibre / MapLibre GL / react-map-gl / `react-force-graph`  
- Mesh crypto, DM mutation, localStorage API keys  
- Token/markets promo panels, CoinGecko/USGS live tickers as product  
- Copying megafile structure (e.g. ShadowBroker `NewsFeed` ~2k LOC, Osiris `OsintPanel` ~1k LOC)  
- Domain one-off panels (Shodan/SCM/radio) as separate organisms — prefer generic connector chrome  
- Observatory product route rewrites (optional integration tasks later; not required for ADS delivery)

---

## Idea Catalog (all organisms + origin)

Priority: **P0** = consensus next; **P1** = second wave; **P2** = polish / CyberCore-optional.

### P0 — Core HUD + intel

| ID | Proposed Prism organism | Origin (ShadowBroker) | Origin (Osiris) | Fit | Notes |
| --- | --- | --- | --- | --- | --- |
| O-01 | `PrismMapHudWorkspace` | `frontend/src/app/page.tsx` dual-HUD composition | `src/app/page.tsx` canvas HUD | Observatory Map + CyberCore ops | Stage slot + left/right/bottom HUD regions; UI hide/restore; not a `DSShell` clone |
| O-02 | `PrismToolStripSlideout` | Right HUD stack | Exclusive right tool strip (~L932–1002) | Both | Exclusive open; icon strip + slideout body |
| O-03 | `PrismLayerControlPanel` | `WorldviewLeftPanel.tsx` | `LayerPanel.tsx` | Map / feed flags | Groups, counts, freshness, master toggle, consent hooks |
| O-04 | `PrismEntityIntelPanel` | `NewsFeed.tsx` selection-driven multi-body | Region dossier / intel panels | Map + detail | **Pluggable dossier registry** on inspector pattern; no mega-widget |
| O-05 | `PrismEntityLocateSearch` | `FindLocateBar.tsx` | `SearchBar.tsx` | Map | Multi-corpus locate ≠ `DSCommandPalette` |
| O-06 | `PrismTimeMachineScrubber` | `TimelineScrubber.tsx` + `TimelinePanel.tsx` | (weaker peer) | History + Map | Density histogram + playback; pairs with existing `DSTimeline` list |
| O-07 | `PrismStatusTicker` | Bottom ticker | `GlobalStatusBar.tsx` | Shell polish | Marquee / rotating status strip |
| O-08 | `PrismOsintWorkbench` | `ReconPanel.tsx` / `ReconResults.tsx` | `OsintPanel.tsx` | **CyberCore** | Tab registry, query, history, structured results, map handoff callback |

### P1 — Stage chrome, analytics, ops

| ID | Proposed Prism organism | Origin (ShadowBroker) | Origin (Osiris) | Fit | Notes |
| --- | --- | --- | --- | --- | --- |
| O-09 | `PrismFloatingAnalyticsHud` | `GtAnalyticsHud.tsx` | — | Map/CyberCore | Draggable minimizable multi-section overlay |
| O-10 | `PrismEntityRelationCard` | Entity relation expand card | `EntityGraphPanel.tsx` expand graph | Map + graph | Preview graph + legend + footer; compose `DSGraphCanvas` |
| O-11 | `PrismWatchlistDock` | Watchlist dock | — | Map | Pinned entities dock |
| O-12 | `PrismCoordinateStatusBar` | Bottom coord/feed-health bar | Coord HUD | Map stage chrome | Read-only stage status |
| O-13 | `PrismMapLegend` | Map legend catalog | — | Map | Categorized icon/legend list |
| O-14 | `PrismFilterWorkbench` | Filter panel + advanced modal | Layer/filter patterns | Map/Operate | Beyond chip group alone |
| O-15 | `PrismAiAnalystPanel` | AI intel panels (SB) | `AiAnalyst.tsx` / `AiOverview.tsx` | CyberCore | **Fixture-first** chat/intel turns; no live keys |
| O-16 | `PrismOpsControlCluster` | Top-right ops launchers | Top C2 metrics/header actions | CyberCore | Cluster of operational launchers |
| O-17 | `PrismMapCanvasStage` (contract) | `MaplibreViewer` composition | `OsirisMap.tsx` composition | Both | **Contract only**: layer registry, selection bus, popup factory — no engine port |
| O-18 | `PrismViewPresets` | — | `ViewPresets.tsx` | Map | Named camera/layer preset grid |
| O-19 | `PrismWorkspaceShareCard` | — | `SharePanel.tsx` | Map | Read-only shareable view-state summary (no auth product) |
| O-20 | `PrismConnectorPanel` | Shared minimizable panel chrome across domain panels | Shared glass panel recipe | Generic | Header, badge, refresh, minimize, body slot — **not** domain clones |

### P1–P2 — CyberCore ops shells

| ID | Proposed Prism organism | Origin (ShadowBroker) | Origin (Osiris) | Fit | Notes |
| --- | --- | --- | --- | --- | --- |
| O-21 | `PrismTerminalWorkspace` | `InfonetTerminal/*` multi-module console | — | CyberCore | Multi-pane sovereign console shell |
| O-22 | `PrismAgentShellPanel` | `MeshChat/AgentShellPanel.tsx` (xterm) | — | CyberCore | Start **read-only transcript** variant; full terminal later |
| O-23 | `PrismMeshCommsPanel` | `MeshChat/*` | — | Deferred | Multi-tab peer/comms UI; **P2** until product needs it |
| O-24 | `PrismKeyboardCheatsheet` | Keyboard overlay | `KeyboardShortcuts.tsx` | UX polish | Overlay cheatsheet organism |
| O-25 | `PrismDisplayConfigChrome` | Tactical display / REC strip | Theme toggle patterns | P2 aesthetic | Optional display chrome |
| O-26 | `PrismScaleMeasureBar` | Scale bar | `ScaleBar.tsx` | Map chrome | Small organism or molecule — classify at task time |
| O-27 | `PrismMediaDetailOverlay` | CCTV / region imagery lightbox | `CameraViewer.tsx` | P2 | Media/stream detail overlay |
| O-28 | `PrismRiskAlertToastVariant` | Geo-aware risk toasts | — | P2 | **Variant** of existing toast system, not new toast stack |

---

## Execution Waves (task packaging)

Waves are delivery order for builders. Each wave produces **organisms + gallery registration + tests**; molecule/atom extraction is a follow-up task per wave or deferred epic.

| Wave | Theme | Organisms (IDs) | Primary consumers |
| --- | --- | --- | --- |
| **A** | HUD layout primitives | O-01, O-02 | ADS gallery; later Map |
| **B** | Layers + filters | O-03, O-14 | Map / catalog |
| **C** | Selection intel + locate | O-04, O-05 | Map / asset detail patterns |
| **D** | Time + status + stage chrome | O-06, O-07, O-11, O-12, O-13 | History + Map polish |
| **E** | CyberCore recon + AI fixtures | O-08, O-15 | CyberCore pilot fixtures |
| **F** | Stage contract + relations | O-17, O-10 | Map graph coupling |
| **G** | Ops chrome pack | O-09, O-16, O-18, O-19, O-20 | CyberCore + Map polish |
| **H** | Terminal / agent (fixture) | O-21, O-22 | CyberCore only |
| **I** | Deferred / optional | O-23–O-28 | As product asks |

### Cross-cutting tasks (every epic needs)

| Theme | Purpose |
| --- | --- |
| Harvest lock + inventory | Point tasks at report paths; freeze skip list |
| Gallery + catalog registration | Each organism appears in design system gallery + catalog section |
| Prism alias + barrel export | Public `Prism*` names; boundary harness 6/6 |
| Goldens (default state) | At least one golden per new organism family when stable |
| Epic acceptance audit | Package green, boundaries, gallery, no DS\* leak |

---

## Candidate Tasks (IDs reserved 1500–1525)

| Task | Name | Wave | Type | Depends |
| --- | --- | --- | --- | --- |
| 1500 | Epic 15 inventory + organism contract brief | — | governance | — |
| 1501 | `PrismMapHudWorkspace` organism | A | feature | 1500 |
| 1502 | `PrismToolStripSlideout` organism | A | feature | 1500 |
| 1503 | `PrismLayerControlPanel` organism | B | feature | 1500 (soft: 1501) |
| 1504 | `PrismFilterWorkbench` organism | B | feature | 1500 |
| 1505 | `PrismEntityIntelPanel` organism | C | feature | 1500 |
| 1506 | `PrismEntityLocateSearch` organism | C | feature | 1500 |
| 1507 | `PrismTimeMachineScrubber` organism | D | feature | 1500 |
| 1508 | `PrismStatusTicker` organism | D | feature | 1500 |
| 1509 | Stage chrome pack (watchlist, coord bar, legend) | D | feature | 1500 (soft: 1501) |
| 1510 | `PrismOsintWorkbench` organism | E | feature | 1500 |
| 1511 | `PrismAiAnalystPanel` fixture-first organism | E | feature | 1500 |
| 1512 | `PrismMapCanvasStage` selection/layer contract | F | feature | 1500 (soft: 1501) |
| 1513 | `PrismEntityRelationCard` organism | F | feature | 1500, 1512 |
| 1514 | `PrismFloatingAnalyticsHud` organism | G | feature | 1500 (soft: 1501) |
| 1515 | `PrismOpsControlCluster` + `PrismConnectorPanel` | G | feature | 1500 |
| 1516 | `PrismViewPresets` + `PrismWorkspaceShareCard` | G | feature | 1500 (soft: 1501) |
| 1517 | `PrismTerminalWorkspace` (fixture shell) | H | feature | 1500 |
| 1518 | `PrismAgentShellPanel` read-only transcript | H | feature | 1517 |
| 1519 | Gallery + catalog registration (hard: A–F) | cross | feature | 1501–1513 hard; 1514–1518 soft |
| 1520 | EPIC-15 goldens + boundary alias audit | cross | testing | 1519 (min goldens A–F) |
| 1521 | EPIC-15 acceptance audit | close | verification | 1520 |
| 1522 | Optional: keyboard cheatsheet + scale bar + risk toast variant | I | feature | 1500 |
| 1523 | Optional: media detail overlay | I | feature | 1500 |

> **Numbering note**: Task architect may refine names/slugs and split/merge **within 1500–1529** if atomicity requires it, but must keep epic origin `EPIC-15` and preserve wave ordering A→H for dependencies.

---

## Acceptance Criteria for Epic Completion

- [ ] All P0 organisms (O-01–O-08) exist under `packages/warp_prism_ui` with `Prism*` public names.  
- [ ] Waves A–F delivered or explicitly deferred with written reason.  
- [ ] Gallery + catalog register new organisms; no `src/` consumer imports.  
- [ ] `melos run test-boundaries` → **6/6 PASS**.  
- [ ] Scoped `flutter test` for new organism suites green.  
- [ ] At least default-state goldens for HUD workspace + one intel + one cybercore workbench.  
- [ ] Harvest skip list honored (no MapLibre port, no mesh crypto, no megafile copies).  
- [ ] Local changelog notes for each completed task.  
- [ ] No task promotes implementation into Observatory product routes unless a separate integration task exists (ADS-first).

---

## Non-Goals

- Replacing Observatory `DSShell` navigation model wholesale.  
- Live CyberCore Go API integration (fixtures only until backend tasks say otherwise).  
- Full mesh chat / encryption product.  
- Widgetbook migration (custom catalog is the intentional MVP proof surface — see Visibility below).  
- Observatory teal rebrand from OmniRoute visual-reference (see EPIC-16 optional CyberCore skin only).

---

## Visibility surface (how to show ADS to someone)

| Surface | Path | Status |
| --- | --- | --- |
| **Custom catalog app** (Storybook-class MVP) | `apps/catalog/` → `DesignSystemGalleryPage` | **Mounted and runnable** |
| Gallery implementation | `packages/warp_prism_ui/lib/src/gallery/` | Registry + sections (tokens→templates) |
| Observatory route | `/design-system` | Also hosts gallery for in-app demo |
| Widgetbook | — | **Deferred** by `docs/design/token-theme-catalog-policy.md` |

**Show a stakeholder today** (after `dart pub get` + `dart run melos bootstrap`):

```bash
cd apps/catalog && flutter run
# or, inside Observatory after flutter run:
# navigate to /design-system
```

Policy: gallery cases are required when landing organisms (Task 1519). README historically under-documented catalog `flutter run` — EPIC-16 Task 1601 hardens showability.

---

## Follow-on epic (do not absorb into 15xx scope)

Net-new harvests (OmniRoute PageShell/Tree, agent transcript, provider health matrix, MCP inspector, etc.) live under:

**`docs/tasks/00-planning/EPIC-16-warp-prism-ads-cybercore-ops-and-agent-transcript-organisms.md`**

Keep EPIC-15 focused on Map HUD / intel / stage chrome from ShadowBroker+Osiris.

---

## References (mandatory reading for task architects & builders)

1. `docs/reports/ads-organism-harvest-unified-2026-07-10.md`  
2. `docs/reports/ads-organism-harvest-shadowbroker-2026-07-10.md`  
3. `docs/reports/ads-organism-harvest-osiris-2026-07-10.md`  
4. `docs/tasks/00-planning/EPIC-01-warp-prism-atomic-design-system.md`  
5. `docs/tasks/00-planning/EPIC-13-warp-prism-ads-public-contract-and-catalog-hardening.md`  
6. `packages/warp_prism_ui/lib/src/organisms/organisms.dart`  
7. `docs/tasks/000-template.md`  
8. `AGENTS.md` product constraints (read-only, mock fixtures, no SQLite)

---

*Created 2026-07-10 from independent reference harvests. Planning only — not an executable task.*
