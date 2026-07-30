# EPIC-15 Gallery + Catalog Registration Matrix

> **Task**: 1519  
> **Date**: 2026-07-16  
> **Package**: `packages/warp_prism_ui`  
> **Catalog host**: `apps/catalog` (thin `DesignSystemGalleryPage` — no parallel section list)

## Purpose

Single verification that every delivered EPIC-15 public organism name (O-01–O-22
families, Tasks 1501–1518) is discoverable in the design-system gallery registry
with coherent family ordering, Prism naming in section titles/subtitles, and
catalog visibility via the package gallery (catalog remains a thin host).

## Registry baseline (preserved)

| Section ID | Title |
| --- | --- |
| `tokens` | Tokens |
| `atoms` | Atoms |
| `molecules` | Molecules |
| `operational-states` | Operational States |
| `organisms` | Organisms |
| `virtual-scroll` | Virtual Scroll |
| `health-dashboard` | Health Dashboard |
| `toasts` | Toasts |
| `accessibility-focus` | Accessibility & Focus States |
| `templates` | Templates |

## EPIC-15 family sections (Task 1519)

Ordered immediately after `organisms` so TOC groups HUD → layers → intel →
stage chrome → recon → stage/relations → ops → terminal before EPIC-16 families.

Section IDs follow `docs/reports/epic-15-organism-contract-brief-2026-07-10.md`
§ gallery scheme.

| Section ID | Title | Builder |
| --- | --- | --- |
| `epic15-hud` | Map HUD Layout | `DSGallerySections.buildEpic15HudSection` / `PrismGallerySections.buildEpic15HudSection` |
| `epic15-layers-filters` | Layers & Filters | `DSGallerySections.buildEpic15LayersFiltersSection` / `PrismGallerySections.buildEpic15LayersFiltersSection` |
| `epic15-intel` | Intel & Locate | `DSGallerySections.buildEpic15IntelSection` / `PrismGallerySections.buildEpic15IntelSection` |
| `epic15-stage-chrome` | Time, Status & Stage Chrome | `DSGallerySections.buildEpic15StageChromeSection` / `PrismGallerySections.buildEpic15StageChromeSection` |
| `epic15-cybercore-recon` | CyberCore Recon & AI | `DSGallerySections.buildEpic15CyberCoreReconSection` / `PrismGallerySections.buildEpic15CyberCoreReconSection` |
| `epic15-stage-relations` | Stage & Relations | `DSGallerySections.buildEpic15StageRelationsSection` / `PrismGallerySections.buildEpic15StageRelationsSection` |
| `epic15-ops` | Ops Pack | `DSGallerySections.buildEpic15OpsSection` / `PrismGallerySections.buildEpic15OpsSection` |
| `epic15-terminal` | Terminal | `DSGallerySections.buildEpic15TerminalSection` / `PrismGallerySections.buildEpic15TerminalSection` |

## EPIC-16 family sections (coexistence — Task 1613)

Unchanged; still registered after EPIC-15:

| Section ID | Title |
| --- | --- |
| `epic16-content-chrome` | Content Chrome |
| `epic16-agent-transcript` | Agent Transcript |
| `epic16-cybercore-ops` | CyberCore Ops |
| `epic16-workflow-execution` | Workflow & Execution |

**Total registry sections**: 22 (10 baseline + 8 EPIC-15 + 4 EPIC-16).

## Organism → section → builder matrix

| O-ID | Public name | Task | Section ID | Gallery builder | Status |
| --- | --- | --- | --- | --- | --- |
| O-01 | `PrismMapHudWorkspace` | 1501 | `epic15-hud` | `buildEpic15HudSection` | **registered** |
| O-02 | `PrismToolStripSlideout` | 1502 | `epic15-hud` | `buildEpic15HudSection` | **registered** |
| O-03 | `PrismLayerControlPanel` | 1503 | `epic15-layers-filters` | `buildEpic15LayersFiltersSection` | **registered** |
| O-24 | `PrismFilterWorkbench` | 1504 | `epic15-layers-filters` | `buildEpic15LayersFiltersSection` | **registered** |
| O-04 | `PrismEntityIntelPanel` | 1505 | `epic15-intel` | `buildEpic15IntelSection` | **registered** |
| O-05 | `PrismEntityLocateSearch` | 1506 | `epic15-intel` | `buildEpic15IntelSection` | **registered** |
| O-06 | `PrismTimeMachineScrubber` | 1507 | `epic15-stage-chrome` | `buildEpic15StageChromeSection` | **registered** |
| O-07 | `PrismStatusTicker` | 1508 | `epic15-stage-chrome` | `buildEpic15StageChromeSection` | **registered** |
| O-11 | `PrismWatchlistDock` | 1509 | `epic15-stage-chrome` | `buildEpic15StageChromeSection` | **registered** |
| O-12 | `PrismCoordinateStatusBar` | 1509 | `epic15-stage-chrome` | `buildEpic15StageChromeSection` | **registered** |
| O-13 | `PrismMapLegend` | 1509 | `epic15-stage-chrome` | `buildEpic15StageChromeSection` | **registered** |
| O-08 | `PrismOsintWorkbench` | 1510 | `epic15-cybercore-recon` | `buildEpic15CyberCoreReconSection` | **registered** |
| O-15 | `PrismAiAnalystPanel` | 1511 | `epic15-cybercore-recon` | `buildEpic15CyberCoreReconSection` | **registered** |
| O-17 | `PrismMapCanvasStage` | 1512 | `epic15-stage-relations` | `buildEpic15StageRelationsSection` | **registered** |
| O-28 | `PrismEntityRelationCard` | 1513 | `epic15-stage-relations` | `buildEpic15StageRelationsSection` | **registered** |
| O-09 | `PrismFloatingAnalyticsHud` | 1514 | `epic15-ops` | `buildEpic15OpsSection` | **registered** (soft 1514 landed) |
| O-16 | `PrismOpsControlCluster` | 1515 | `epic15-ops` | `buildEpic15OpsSection` | **registered** (soft 1515 landed) |
| O-20 | `PrismConnectorPanel` | 1515 | `epic15-ops` | `buildEpic15OpsSection` | **registered** (soft 1515 landed) |
| O-18 | `PrismViewPresets` | 1516 | `epic15-ops` | `buildEpic15OpsSection` | **registered** (soft 1516 landed) |
| O-19 | `PrismWorkspaceShareCard` | 1516 | `epic15-ops` | `buildEpic15OpsSection` | **registered** (soft 1516 landed) |
| O-21 | `PrismTerminalWorkspace` | 1517 | `epic15-terminal` | `buildEpic15TerminalSection` | **registered** (soft 1517 landed) |
| O-22 | `PrismAgentShellPanel` | 1518 | `epic15-terminal` | `buildEpic15TerminalSection` | **registered** (soft 1518 landed) |

### Deferred

| Item | Status | Note |
| --- | --- | --- |
| Wave I optional `1522` keyboard / scale / risk toast | **deferred** | Still `01-open` at registration time — not registered |
| Wave I optional `1523` media detail overlay | **deferred** | Still `01-open` at registration time — not registered |
| Optional `epic15-optional` section | **deferred** | Only when 1522/1523 land |

## Catalog visibility

| Surface | Behavior |
| --- | --- |
| `apps/catalog/lib/main.dart` | Hosts `DesignSystemGalleryPage` only — **no parallel section list** |
| Catalog tests | Consume `dsGallerySectionTitles` / `dsGallerySectionIds` dynamically — auto-picks new family sections |
| Public barrel | Gallery tests + catalog use `package:warp_prism_ui/warp_prism_ui.dart` only |

## Naming

- Section titles/subtitles and demo labels use **Prism\*** public names.
- Builders still construct `DS*` implementation widgets (internal); consumers never import `src/`.
- Organisms mega-section no longer embeds EPIC-15 demos (pointer text only) to avoid duplication and nav noise — same pattern as Task 1613 for EPIC-16.

## Non-goals / coexistence

- EPIC-16 C-01–C-12 remain under `epic16-*` sections only.
- No Widgetbook.
- No Observatory teal rebrand.
- No new organisms implemented in Task 1519 — registration/discoverability only.

## Validation (builder)

See Task 1519 Completion Evidence for live command results.
