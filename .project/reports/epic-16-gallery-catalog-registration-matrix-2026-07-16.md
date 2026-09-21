# EPIC-16 Gallery + Catalog Registration Matrix

> **Task**: 1613  
> **Date**: 2026-07-16  
> **Package**: `packages/warp_prism_ui`  
> **Catalog host**: `apps/catalog` (thin `DesignSystemGalleryPage` — no parallel section list)

## Purpose

Single verification that every delivered EPIC-16 public organism name (C-01–C-12)
is discoverable in the design-system gallery registry with coherent family
ordering, Prism naming in section titles/subtitles, and catalog visibility via
the package gallery (catalog remains a thin host).

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

## EPIC-16 family sections (Task 1613)

Ordered immediately after `organisms` so TOC groups content chrome → transcript
→ CyberCore ops → workflow/execution before remaining utility sections.

| Section ID | Title | Builder |
| --- | --- | --- |
| `epic16-content-chrome` | Content Chrome | `DSGallerySections.buildContentChromeSection` / `PrismGallerySections.buildContentChromeSection` |
| `epic16-agent-transcript` | Agent Transcript | `DSGallerySections.buildAgentTranscriptSection` / `PrismGallerySections.buildAgentTranscriptSection` |
| `epic16-cybercore-ops` | CyberCore Ops | `DSGallerySections.buildCyberCoreOpsSection` / `PrismGallerySections.buildCyberCoreOpsSection` |
| `epic16-workflow-execution` | Workflow & Execution | `DSGallerySections.buildWorkflowExecutionSection` / `PrismGallerySections.buildWorkflowExecutionSection` |

**Total registry sections**: 14 (10 baseline + 4 EPIC-16 families).

Section IDs follow `docs/reports/epic-16-organism-contract-brief-2026-07-10.md` §10.2.

## Organism → section → builder matrix

| C-ID | Public name | Task | Section ID | Gallery builder | Status |
| --- | --- | --- | --- | --- | --- |
| C-01 | `PrismPageShell` | 1602 | `epic16-content-chrome` | `buildContentChromeSection` | **registered** |
| C-02 | `PrismTree` | 1603 | `epic16-content-chrome` | `buildContentChromeSection` | **registered** |
| C-03 | `PrismAgentTranscript` | 1604 | `epic16-agent-transcript` | `buildAgentTranscriptSection` | **registered** |
| C-04 | `PrismToolCallCard` | 1605 | `epic16-agent-transcript` | `buildAgentTranscriptSection` | **registered** |
| C-05 | `PrismMessageStatusHistory` | 1605 | `epic16-agent-transcript` | `buildAgentTranscriptSection` | **registered** |
| C-06 | `PrismArtifactWorkbench` | 1606 | `epic16-agent-transcript` | `buildAgentTranscriptSection` | **registered** |
| C-07 | `PrismProviderHealthMatrix` | 1607 | `epic16-cybercore-ops` | `buildCyberCoreOpsSection` | **registered** |
| C-08 | `PrismMcpCapabilityInspector` | 1608 | `epic16-cybercore-ops` | `buildCyberCoreOpsSection` | **registered** |
| C-09 | `PrismTimingWaterfall` | 1609 | `epic16-cybercore-ops` | `buildCyberCoreOpsSection` | **registered** |
| C-10 | `PrismTrafficInspector` | 1609 | `epic16-cybercore-ops` | `buildCyberCoreOpsSection` | **registered** |
| C-11 | `PrismWorkflowCanvasStage` | 1610 | `epic16-workflow-execution` | `buildWorkflowExecutionSection` | **registered** (soft 1610 landed) |
| C-12 | `PrismExecutionConsole` | 1611 | `epic16-workflow-execution` | `buildWorkflowExecutionSection` | **registered** (soft 1611 landed) |

### Deferred

| Item | Status | Note |
| --- | --- | --- |
| Optional 1616 skin | **deferred** | Does not block registration (architect resolution) |
| Hygiene 1612 | N/A | No organism gallery requirement |

## Catalog visibility

| Surface | Behavior |
| --- | --- |
| `apps/catalog/lib/main.dart` | Hosts `DesignSystemGalleryPage` only — **no parallel section list** |
| Catalog tests | Consume `dsGallerySectionTitles` / `dsGallerySectionIds` dynamically — auto-picks new family sections |
| Public barrel | Gallery tests + catalog use `package:warp_prism_ui/warp_prism_ui.dart` only |

## Naming

- Section titles/subtitles and demo labels use **Prism\*** public names.
- Builders still construct `DS*` implementation widgets (internal); consumers never import `src/`.
- Organisms mega-section no longer embeds C-01–C-12 demos (pointer text only) to avoid duplication and nav noise.

## Non-goals / coexistence

- EPIC-15 Map HUD / OSINT / terminal organisms remain under `organisms` (and prior registration patterns). Not re-registered as EPIC-16.
- No Widgetbook.
- No Observatory teal rebrand.

## Validation (builder)

See Task 1613 Completion Evidence for live command results.
