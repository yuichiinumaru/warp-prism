# Public Barrel Audit — `warp_prism_ui`

> **Task**: 1302 (with Task 1807 tooling export lock)  
> **Date**: 2026-09-02 (current live re-audit; 296 Prism symbols, 302 public symbols)  
> **Original audit**: 2026-06-09  
> **Executor**: gt-flutter-engineer (builders)  
> **Source of truth**: `packages/warp_prism_ui/lib/warp_prism_ui.dart`  
> **Alias surface**: `packages/warp_prism_ui/lib/src/prism_aliases.dart`

---

## 1. Live Barrel Structure

The public barrel is intentionally narrow. **DS\* implementation libraries are not
exported.** Consumers receive Prism\* aliases plus intentional gallery entrypoints.

| # | Export path | Role | Hides |
|---|-------------|------|-------|
| 1 | `src/prism_aliases.dart` | Sole Prism\* public API (typedefs + extension) | — |
| 2 | `src/gallery/design_system_gallery_page.dart` | Gallery page | — |
| 3 | `src/gallery/design_system_gallery_registry.dart` | Gallery registry const + helpers | `DSGallerySectionSpec` |
| 4 | `src/gallery/design_system_gallery_sections.dart` | Gallery section builders | `DSGallerySections` |

**Not exported** (internal / `src/` only):

- `src/tokens/tokens.dart`
- `src/atoms/atoms.dart`
- `src/molecules/molecules.dart`
- `src/organisms/organisms.dart`
- `src/templates/templates.dart`
- All other `src/**` implementation files

> Historical note: older audit drafts listed layer sub-barrels as public. That
> structure is obsolete after Prism namespace remediation. This document matches
> the live four-export barrel only.

> **2026-08-24 re-audit (Tasks 1302 / 1803 / 1807 / 1809)**: Live alias inventory is **296** Prism
> symbols (**295** typedef + **1** extension), plus two public Task 1807 tooling classes
> (`PrismTokenRegistry`, `PrismThemeEditor`). Prior freezes (127/129/131, 263, 274, 292, and
> 294) are superseded. The live alias surface is the source of truth; the lock below is
> regenerated and verified via `verify_public_barrel_audit.dart`.

---

## 2. Complete Public Symbol Manifest

### 2.1 Production / Experimental / Gallery — Prism API (`src/prism_aliases.dart`)

**Count: 296 symbols** (295 `typedef` + 1 `extension`).

#### Task 1807 tooling exports (2)

These are intentional public tooling surfaces re-exported by `prism_aliases.dart`; they are classes rather than `Prism*` typedef/extension aliases and are therefore tracked by a separate lock from the alias set-equality check.

| Public symbol | Kind | Source | Status |
|---|---|---|---|
| `PrismTokenRegistry` | class | `tokens/prism_token_registry.dart` | Tooling |
| `PrismThemeEditor` | class | `organisms/theme_editor/prism_theme_editor.dart` | Tooling |

Classification key:

- **Production** — stable consumer API
- **Experimental** — drag-drop surface still evolving; keep exported, do not treat as frozen
- **Gallery** — Prism-named gallery surface (preferred over hidden DSGallery\*)

#### TOKENS — Operational State (16)

| Public symbol | Kind | Target | Status |
|---|---|---|---|
| `PrismOperationalState` | typedef | `DSOperationalState` | Production |
| `PrismOperationalSeverity` | typedef | `DSOperationalSeverity` | Production |
| `PrismOperationalCategory` | typedef | `DSOperationalCategory` | Production |
| `PrismOperationalStateUI` | extension | on `DSOperationalState` | Production |
| `PrismColors` | typedef | `DSColors` | Production |
| `PrismTheme` | typedef | `DSTheme` | Production |
| `PrismNerazimTealSkin` | typedef | `DSNerazimTealSkin` | Production |
| `PrismTaldarimRedSkin` | typedef | `DSTaldarimRedSkin` | Production |
| `PrismTalonPurpleSkin` | typedef | `DSTalonPurpleSkin` | Production |
| `PrismSpacing` | typedef | `DSSpacing` | Production |
| `PrismTypography` | typedef | `DSTypography` | Production |
| `PrismBreakpoints` | typedef | `DSBreakpoints` | Production |
| `PrismRadii` | typedef | `DSRadii` | Production |
| `PrismShadows` | typedef | `DSShadows` | Production |
| `PrismMotion` | typedef | `DSMotion` | Production |
| `PrismSemantics` | typedef | `DSSemantics` | Production |

#### ATOMS (2)

| Public symbol | Kind | Target | Status |
|---|---|---|---|
| `PrismStatusDot` | typedef | `DSStatusDot` | Production |
| `PrismColorField` | typedef | `DSColorField` | Production |

#### MOLECULES (27)

| Public symbol | Kind | Target | Status |
|---|---|---|---|
| `PrismMetricTile` | typedef | `DSMetricTile` | Production |
| `PrismMetricTileCompact` | typedef | `DSMetricTileCompact` | Production |
| `PrismMetricTileHealth` | typedef | `DSMetricTileHealth` | Production |
| `PrismTrend` | typedef | `DSTrend` | Production |
| `PrismInteractiveSurface` | typedef | `DSInteractiveSurface` | Production |
| `PrismStateSurface` | typedef | `DSStateSurface` | Production |
| `PrismStateType` | typedef | `DSStateType` | Production |
| `PrismTaskCard` | typedef | `DSTaskCard` | Production |
| `PrismAssetCard` | typedef | `DSAssetCard` | Production |
| `PrismSearchBar` | typedef | `DSSearchBar` | Production |
| `PrismFilterChipGroup` | typedef | `DSFilterChipGroup` | Production |
| `PrismFilterOption` | typedef | `DSFilterOption` | Production |
| `PrismEvidenceRow` | typedef | `DSEvidenceRow` | Production |
| `PrismEvidenceIndicator` | typedef | `DSEvidenceIndicator` | Production |
| `PrismEvidenceState` | typedef | `DSEvidenceState` | Production |
| `PrismProvenancePill` | typedef | `DSProvenancePill` | Production |
| `PrismProvenanceSize` | typedef | `DSProvenanceSize` | Production |
| `PrismTimelineMarker` | typedef | `DSTimelineMarker` | Production |
| `PrismAccordion` | typedef | `DSAccordion` | Production |
| `PrismAccordionItem` | typedef | `DSAccordionItem` | Production |
| `PrismAccordionSection` | typedef | `DSAccordionSection` | Production |
| `PrismDialog` | typedef | `DSDialog` | Production |
| `PrismDialogAction` | typedef | `DSDialogAction` | Production |
| `PrismDialogSize` | typedef | `DSDialogSize` | Production |
| `PrismSelect` | typedef | `DSSelect` | Production |
| `PrismSelectItem` | typedef | `DSSelectItem` | Production |
| `PrismSelectOption` | typedef | `DSSelectOption` | Production |

#### ORGANISMS (135)

| Public symbol | Kind | Target | Status |
|---|---|---|---|
| `PrismLaneBoard` | typedef | `DSLaneBoard` | Production |
| `PrismLane` | typedef | `DSLane` | Production |
| `PrismLaneTask` | typedef | `DSLaneTask` | Production |
| `PrismPageShell` | typedef | `DSPageShell` | Production |
| `PrismMapHudWorkspace` | typedef | `DSMapHudWorkspace` | Production |
| `PrismToolStripSlideout` | typedef | `DSToolStripSlideout` | Production |
| `PrismToolStripItem` | typedef | `DSToolStripItem` | Production |
| `PrismFilterWorkbench` | typedef | `DSFilterWorkbench` | Production |
| `PrismFilterSection` | typedef | `DSFilterSection` | Production |
| `PrismFilterCriterion` | typedef | `DSFilterCriterion` | Production |
| `PrismFilterCriterionKind` | typedef | `DSFilterCriterionKind` | Production |
| `PrismTree` | typedef | `DSTree` | Production |
| `PrismTreeNode` | typedef | `DSTreeNode` | Production |
| `PrismAgentTranscript` | typedef | `DSAgentTranscript` | Production |
| `PrismAgentMessage` | typedef | `DSAgentMessage` | Production |
| `PrismAgentMessageBlock` | typedef | `DSAgentMessageBlock` | Production |
| `PrismAgentRole` | typedef | `DSAgentRole` | Production |
| `PrismAgentMessageBlockType` | typedef | `DSAgentMessageBlockType` | Production |
| `PrismToolCallCard` | typedef | `DSToolCallCard` | Production |
| `PrismToolCallData` | typedef | `DSToolCallData` | Production |
| `PrismToolCallStatus` | typedef | `DSToolCallStatus` | Production |
| `PrismMessageStatusHistory` | typedef | `DSMessageStatusHistory` | Production |
| `PrismMessageStatusStep` | typedef | `DSMessageStatusStep` | Production |
| `PrismMessageStatusStepState` | typedef | `DSMessageStatusStepState` | Production |
| `PrismProviderHealthMatrix` | typedef | `DSProviderHealthMatrix` | Production |
| `PrismProviderHealthCell` | typedef | `DSProviderHealthCell` | Production |
| `PrismProviderHealthProvider` | typedef | `DSProviderHealthProvider` | Production |
| `PrismMcpCapabilityInspector` | typedef | `DSMcpCapabilityInspector` | Production |
| `PrismMcpCapabilityKind` | typedef | `DSMcpCapabilityKind` | Production |
| `PrismMcpCapabilities` | typedef | `DSMcpCapabilities` | Production |
| `PrismMcpToolItem` | typedef | `DSMcpToolItem` | Production |
| `PrismMcpResourceItem` | typedef | `DSMcpResourceItem` | Production |
| `PrismMcpPromptItem` | typedef | `DSMcpPromptItem` | Production |
| `PrismMcpRootItem` | typedef | `DSMcpRootItem` | Production |
| `PrismMcpPingResult` | typedef | `DSMcpPingResult` | Production |
| `PrismMcpCapabilitySelection` | typedef | `DSMcpCapabilitySelection` | Production |
| `PrismTimingWaterfall` | typedef | `DSTimingWaterfall` | Production |
| `PrismTimingSpan` | typedef | `DSTimingSpan` | Production |
| `PrismTimingWaterfallLayout` | typedef | `DSTimingWaterfallLayout` | Production |
| `PrismTrafficInspector` | typedef | `DSTrafficInspector` | Production |
| `PrismTrafficRequest` | typedef | `DSTrafficRequest` | Production |
| `PrismTrafficDetailTab` | typedef | `DSTrafficDetailTab` | Production |
| `PrismWorkflowCanvasStage` | typedef | `DSWorkflowCanvasStage` | Production |
| `PrismWorkflowNode` | typedef | `DSWorkflowNode` | Production |
| `PrismWorkflowEdge` | typedef | `DSWorkflowEdge` | Production |
| `PrismWorkflowNodeKind` | typedef | `DSWorkflowNodeKind` | Production |
| `PrismWorkflowEdgeKind` | typedef | `DSWorkflowEdgeKind` | Production |
| `PrismWorkflowSelection` | typedef | `DSWorkflowSelection` | Production |
| `PrismWorkflowCanvasLayout` | typedef | `DSWorkflowCanvasLayout` | Production |
| `PrismViewPreset` | typedef | `DSViewPreset` | Production |
| `PrismViewPresets` | typedef | `DSViewPresets` | Production |
| `PrismWorkspaceShareSummary` | typedef | `DSWorkspaceShareSummary` | Production |
| `PrismWorkspaceShareCard` | typedef | `DSWorkspaceShareCard` | Production |
| `PrismExecutionConsole` | typedef | `DSExecutionConsole` | Production |
| `PrismExecutionLine` | typedef | `DSExecutionLine` | Production |
| `PrismExecutionLineLevel` | typedef | `DSExecutionLineLevel` | Production |
| `PrismExecutionRunGroup` | typedef | `DSExecutionRunGroup` | Production |
| `PrismExecutionRunStatus` | typedef | `DSExecutionRunStatus` | Production |
| `PrismExecutionConsoleController` | typedef | `DSExecutionConsoleController` | Production |
| `PrismLayerControlPanel` | typedef | `DSLayerControlPanel` | Production |
| `PrismLayerGroup` | typedef | `DSLayerGroup` | Production |
| `PrismLayerItem` | typedef | `DSLayerItem` | Production |
| `PrismLayerFreshness` | typedef | `DSLayerFreshness` | Production |
| `PrismTimeMachineScrubber` | typedef | `DSTimeMachineScrubber` | Production |
| `PrismTimeDensityBucket` | typedef | `DSTimeDensityBucket` | Production |
| `PrismTimeDensitySeverity` | typedef | `DSTimeDensitySeverity` | Production |
| `PrismEntityIntelPanel` | typedef | `DSEntityIntelPanel` | Production |
| `PrismEntitySelection` | typedef | `DSEntitySelection` | Production |
| `PrismEntityIntelDossier` | typedef | `DSEntityIntelDossier` | Production |
| `PrismEntityIntelBodyBuilder` | typedef | `DSEntityIntelBodyBuilder` | Production |
| `PrismEntityIntelFixtures` | typedef | `DSEntityIntelFixtures` | Production |
| `PrismEntityLocateSearch` | typedef | `DSEntityLocateSearch` | Production |
| `PrismLocateCorpus` | typedef | `DSLocateCorpus` | Production |
| `PrismLocateEntry` | typedef | `DSLocateEntry` | Production |
| `PrismLocateResult` | typedef | `DSLocateResult` | Production |
| `PrismArtifactWorkbench` | typedef | `DSArtifactWorkbench` | Production |
| `PrismArtifact` | typedef | `DSArtifact` | Production |
| `PrismArtifactType` | typedef | `DSArtifactType` | Production |
| `PrismStatusTicker` | typedef | `DSStatusTicker` | Production |
| `PrismStatusTickerItem` | typedef | `DSStatusTickerItem` | Production |
| `PrismStatusTickerMode` | typedef | `DSStatusTickerMode` | Production |
| `PrismStatusTickerController` | typedef | `DSStatusTickerController` | Production |
| `PrismStatusTickerFixtures` | typedef | `DSStatusTickerFixtures` | Production |
| `PrismWatchlistDock` | typedef | `DSWatchlistDock` | Production |
| `PrismWatchlistItem` | typedef | `DSWatchlistItem` | Production |
| `PrismWatchlistFixtures` | typedef | `DSWatchlistFixtures` | Production |
| `PrismCoordinateStatusBar` | typedef | `DSCoordinateStatusBar` | Production |
| `PrismCoordinateFeedHealth` | typedef | `DSCoordinateFeedHealth` | Production |
| `PrismCoordinateFeedStatus` | typedef | `DSCoordinateFeedStatus` | Production |
| `PrismCoordinateStatusFixtures` | typedef | `DSCoordinateStatusFixtures` | Production |
| `PrismMapLegend` | typedef | `DSMapLegend` | Production |
| `PrismMapLegendCategory` | typedef | `DSMapLegendCategory` | Production |
| `PrismMapLegendItem` | typedef | `DSMapLegendItem` | Production |
| `PrismMapLegendFixtures` | typedef | `DSMapLegendFixtures` | Production |
| `PrismOsintWorkbench` | typedef | `DSOsintWorkbench` | Production |
| `PrismOsintTool` | typedef | `DSOsintTool` | Production |
| `PrismOsintResult` | typedef | `DSOsintResult` | Production |
| `PrismOsintResultField` | typedef | `DSOsintResultField` | Production |
| `PrismOsintHistoryEntry` | typedef | `DSOsintHistoryEntry` | Production |
| `PrismOsintMapHandoff` | typedef | `DSOsintMapHandoff` | Production |
| `PrismOsintFixtures` | typedef | `DSOsintFixtures` | Production |
| `PrismOsintFixtureResolver` | typedef | `DSOsintFixtureResolver` | Production |
| `PrismAiAnalystPanel` | typedef | `DSAiAnalystPanel` | Production |
| `PrismAiAnalystTurn` | typedef | `DSAiAnalystTurn` | Production |
| `PrismAiAnalystRole` | typedef | `DSAiAnalystRole` | Production |
| `PrismAiAnalystTurnStatus` | typedef | `DSAiAnalystTurnStatus` | Production |
| `PrismAiAnalystController` | typedef | `DSAiAnalystController` | Production |
| `PrismAiAnalystReplyAdapter` | typedef | `DSAiAnalystReplyAdapter` | Production |
| `PrismFloatingAnalyticsHud` | typedef | `DSFloatingAnalyticsHud` | Production |
| `PrismFloatingAnalyticsSection` | typedef | `DSFloatingAnalyticsSection` | Production |
| `PrismFloatingAnalyticsMetric` | typedef | `DSFloatingAnalyticsMetric` | Production |
| `PrismFloatingAnalyticsHudController` | typedef | `DSFloatingAnalyticsHudController` | Production |
| `PrismFloatingAnalyticsFixtures` | typedef | `DSFloatingAnalyticsFixtures` | Production |
| `PrismOpsControlCluster` | typedef | `DSOpsControlCluster` | Production |
| `PrismOpsLauncher` | typedef | `DSOpsLauncher` | Production |
| `PrismOpsControlClusterFixtures` | typedef | `DSOpsControlClusterFixtures` | Production |
| `PrismConnectorPanel` | typedef | `DSConnectorPanel` | Production |
| `PrismConnectorPanelFixtures` | typedef | `DSConnectorPanelFixtures` | Production |
| `PrismMapCanvasStage` | typedef | `DSMapCanvasStage` | Production |
| `PrismMapCanvasStageController` | typedef | `DSMapCanvasStageController` | Production |
| `PrismMapStageLayerEntry` | typedef | `DSMapStageLayerEntry` | Production |
| `PrismMapStageFeature` | typedef | `DSMapStageFeature` | Production |
| `PrismMapStageSelectionEvent` | typedef | `DSMapStageSelectionEvent` | Production |
| `PrismMapStageSelectionKind` | typedef | `DSMapStageSelectionKind` | Production |
| `PrismMapStagePopupBuilder` | typedef | `DSMapStagePopupBuilder` | Production |
| `PrismMapStageSelectionListener` | typedef | `DSMapStageSelectionListener` | Production |
| `PrismMapCanvasStageFixtures` | typedef | `DSMapCanvasStageFixtures` | Production |
| `PrismTerminalWorkspace` | typedef | `DSTerminalWorkspace` | Production |
| `PrismTerminalPane` | typedef | `DSTerminalPane` | Production |
| `PrismTerminalLayoutMode` | typedef | `DSTerminalLayoutMode` | Production |
| `PrismTerminalWorkspaceController` | typedef | `DSTerminalWorkspaceController` | Production |
| `PrismAgentShellLineType` | typedef | `DSAgentShellLineType` | Production |
| `PrismAgentShellLine` | typedef | `DSAgentShellLine` | Production |
| `PrismAgentShellPanelController` | typedef | `DSAgentShellPanelController` | Production |
| `PrismAgentShellPanel` | typedef | `DSAgentShellPanel` | Production |

#### COMPONENTS — Additional promoted types (42)

| Public symbol | Kind | Target | Status |
|---|---|---|---|
| `PrismBadge` | typedef | `DSBadge` | Production |
| `PrismIcon` | typedef | `DSIcon` | Production |
| `PrismIcons` | typedef | `DSIcons` | Production |
| `PrismText` | typedef | `DSText` | Production |
| `PrismDataTable` | typedef | `DSDataTable` | Production |
| `PrismDataColumn` | typedef | `DSDataColumn` | Production |
| `PrismDataRow` | typedef | `DSDataRow` | Production |
| `PrismStatusCell` | typedef | `DSStatusCell` | Production |
| `PrismStatusGrid` | typedef | `DSStatusGrid` | Production |
| `PrismHealthCardData` | typedef | `DSHealthCardData` | Production |
| `PrismErrorBoundary` | typedef | `DSErrorBoundary` | Production |
| `PrismFallbackView` | typedef | `DSFallbackView` | Production |
| `PrismTimeline` | typedef | `DSTimeline` | Production |
| `PrismTimelineEntry` | typedef | `DSTimelineEntry` | Production |
| `PrismShellResponsive` | typedef | `DSShellResponsive` | Production |
| `PrismSidebar` | typedef | `DSSidebar` | Production |
| `PrismSidebarItem` | typedef | `DSSidebarItem` | Production |
| `PrismTopbar` | typedef | `DSTopbar` | Production |
| `PrismStoryPanel` | typedef | `DSStoryPanel` | Production |
| `PrismStoryInsight` | typedef | `DSStoryInsight` | Production |
| `PrismToast` | typedef | `DSToast` | Production |
| `PrismToastManager` | typedef | `DSToastManager` | Production |
| `PrismSparkline` | typedef | `DSSparkline` | Production |
| `PrismUptimeBar` | typedef | `DSUptimeBar` | Production |
| `PrismHealthCard` | typedef | `DSHealthCard` | Production |
| `PrismShimmer` | typedef | `DSShimmer` | Production |
| `PrismSkeletonCard` | typedef | `DSSkeletonCard` | Production |
| `PrismSkeletonTextLine` | typedef | `DSSkeletonTextLine` | Production |
| `PrismSkeletonTableRows` | typedef | `DSSkeletonTableRows` | Production |
| `PrismVirtualList` | typedef | `DSVirtualList` | Production |
| `PrismVirtualGrid` | typedef | `DSVirtualGrid` | Production |
| `PrismTabBar` | typedef | `DSTabBar` | Production |
| `PrismSplitPane` | typedef | `DSSplitPane` | Production |
| `PrismCodeBlock` | typedef | `DSCodeBlock` | Production |
| `PrismMarkdownRenderer` | typedef | `DSMarkdownRenderer` | Production |
| `PrismCommandPalette` | typedef | `DSCommandPalette` | Production |
| `PrismCommand` | typedef | `DSCommand` | Production |
| `PrismLogViewer` | typedef | `DSLogViewer` | Production |
| `PrismLogEntry` | typedef | `DSLogEntry` | Production |
| `PrismLogSeverity` | typedef | `DSLogSeverity` | Production |
| `PrismLogEntryWidget` | typedef | `DSLogEntryWidget` | Production |
| `PrismLogFilterBar` | typedef | `DSLogFilterBar` | Production |

#### ATOMS — Additional aliases (20)

| Public symbol | Kind | Target | Status |
|---|---|---|---|
| `PrismCheckbox` | typedef | `DSCheckbox` | Production |
| `PrismChip` | typedef | `DSChip` | Production |
| `PrismChipSize` | typedef | `DSChipSize` | Production |
| `PrismDivider` | typedef | `DSDivider` | Production |
| `PrismGlowDivider` | typedef | `DSGlowDivider` | Production |
| `PrismGlassPanel` | typedef | `DSGlassPanel` | Production |
| `PrismGlassPanelSimple` | typedef | `DSGlassPanelSimple` | Production |
| `PrismGlassPanelVariant` | typedef | `DSGlassPanelVariant` | Production |
| `PrismGlowBorder` | typedef | `DSGlowBorder` | Production |
| `PrismBadgeSize` | typedef | `DSBadgeSize` | Production |
| `PrismBadgeVariant` | typedef | `DSBadgeVariant` | Production |
| `PrismIconSize` | typedef | `DSIconSize` | Production |
| `PrismSwitch` | typedef | `DSSwitch` | Production |
| `PrismToggle` | typedef | `DSSwitch` | Production |
| `PrismTextVariant` | typedef | `DSTextVariant` | Production |
| `PrismButton` | typedef | `DSButton` | Production |
| `PrismButtonSize` | typedef | `DSButtonSize` | Production |
| `PrismButtonVariant` | typedef | `DSButtonVariant` | Production |
| `PrismTextField` | typedef | `DSTextField` | Production |
| `PrismBreadcrumbs` | typedef | `DSBreadcrumbs` | Production |
| `PrismBreadcrumbItem` | typedef | `DSBreadcrumbItem` | Production |

#### MOLECULES — Additional aliases (10)

| Public symbol | Kind | Target | Status |
|---|---|---|---|
| `PrismDraggableCard` | typedef | `DSDraggableCard` | Experimental |
| `PrismDragPayload` | typedef | `DSDragPayload` | Experimental |
| `PrismDragMoveEvent` | typedef | `DSDragMoveEvent` | Experimental |
| `PrismDragReorderEvent` | typedef | `DSDragReorderEvent` | Experimental |
| `PrismDragReorderIntent` | typedef | `DSDragReorderIntent` | Experimental |
| `PrismDragMoveLaneIntent` | typedef | `DSDragMoveLaneIntent` | Experimental |
| `PrismDropTarget` | typedef | `DSDropTarget` | Experimental |
| `PrismToastEntry` | typedef | `DSToastEntry` | Production |
| `PrismToastSeverity` | typedef | `DSToastSeverity` | Production |
| `PrismToastManagerState` | typedef | `DSToastManagerState` | Production |

#### ORGANISMS — Additional aliases (19)

| Public symbol | Kind | Target | Status |
|---|---|---|---|
| `PrismDetailInspector` | typedef | `DSDetailInspector` | Production |
| `PrismDetailSection` | typedef | `DSDetailSection` | Production |
| `PrismPropertyRow` | typedef | `DSPropertyRow` | Production |
| `PrismLinkRow` | typedef | `DSLinkRow` | Production |
| `PrismGraphCanvas` | typedef | `DSGraphCanvas` | Production |
| `PrismEntityRelationCard` | typedef | `DSEntityRelationCard` | Production |
| `PrismGraphNode` | typedef | `GraphNode` | Production |
| `PrismGraphEdge` | typedef | `GraphEdge` | Production |
| `PrismShell` | typedef | `DSShell` | Production |
| `PrismTopbarAction` | typedef | `DSTopbarAction` | Production |
| `PrismStoryCardQuick` | typedef | `DSStoryCardQuick` | Production |
| `PrismStoryNarrativeInsight` | typedef | `DSStoryNarrativeInsight` | Production |
| `PrismInsightRiskLevel` | typedef | `InsightRiskLevel` | Production |
| `PrismTimelineGroup` | typedef | `DSTimelineGroup` | Production |
| `PrismTimelineGrouped` | typedef | `DSTimelineGrouped` | Production |
| `PrismTab` | typedef | `DSTab` | Production |
| `PrismTabController` | typedef | `DSTabController` | Production |
| `PrismTabView` | typedef | `DSTabView` | Production |
| `PrismVirtualScrollConfig` | typedef | `DSVirtualScrollConfig` | Production |

#### DATA TABLE — Additional aliases (9)

| Public symbol | Kind | Target | Status |
|---|---|---|---|
| `PrismActionItem` | typedef | `DSActionItem` | Production |
| `PrismActionsCell` | typedef | `DSActionsCell` | Production |
| `PrismBadgeCell` | typedef | `DSBadgeCell` | Production |
| `PrismSecretCell` | typedef | `DSSecretCell` | Production |
| `PrismTimestampCell` | typedef | `DSTimestampCell` | Production |
| `PrismTablePagination` | typedef | `DSTablePagination` | Production |
| `PrismSortState` | typedef | `DSSortState` | Production |
| `PrismSortDirection` | typedef | `DSSortDirection` | Production |
| `PrismCellRenderer` | typedef | `DSCellRenderer` | Production |

#### COMMAND PALETTE — Additional aliases (2)

| Public symbol | Kind | Target | Status |
|---|---|---|---|
| `PrismCommandPaletteShortcut` | typedef | `DSCommandPaletteShortcut` | Production |
| `PrismCommandCategory` | typedef | `DSCommandCategory` | Production |

#### GALLERY — Public Prism* surface (DSGallery* remains internal) (2)

| Public symbol | Kind | Target | Status |
|---|---|---|---|
| `PrismGallerySectionSpec` | typedef | `DSGallerySectionSpec` | Gallery |
| `PrismGallerySections` | typedef | `DSGallerySections` | Gallery |

#### EPIC-15 Wave I optional polish — Tasks 1522 / 1523 (O-24 / O-26 / O-27 / O-28) (11)

| Public symbol | Kind | Target | Status |
|---|---|---|---|
| `PrismKeyboardCheatsheet` | typedef | `DSKeyboardCheatsheet` | Production |
| `PrismKeyboardShortcut` | typedef | `DSKeyboardShortcut` | Production |
| `PrismKeyboardShortcutGroup` | typedef | `DSKeyboardShortcutGroup` | Production |
| `PrismKeyboardCheatsheetFixtures` | typedef | `DSKeyboardCheatsheetFixtures` | Production |
| `PrismScaleMeasureBar` | typedef | `DSScaleMeasureBar` | Production |
| `PrismScaleSegment` | typedef | `DSScaleSegment` | Production |
| `PrismScaleMeasureBarFixtures` | typedef | `DSScaleMeasureBarFixtures` | Production |
| `PrismToastRiskTier` | typedef | `DSToastRiskTier` | Production |
| `PrismMediaDetailOverlay` | typedef | `DSMediaDetailOverlay` | Production |
| `PrismMediaDetailItem` | typedef | `DSMediaDetailItem` | Production |
| `PrismMediaDetailFixtures` | typedef | `DSMediaDetailFixtures` | Production |

### 2.2 Non-Prism gallery entrypoints (4)

Exported via gallery files. `DSGallerySectionSpec` / `DSGallerySections` are **hidden**.

| Public symbol | Kind | File | Status |
|---|---|---|---|
| `DesignSystemGalleryPage` | class | `design_system_gallery_page.dart` | Gallery-only |
| `dsGallerySections` | const | `design_system_gallery_registry.dart` | Gallery-only |
| `dsGallerySectionIds` | getter | `design_system_gallery_registry.dart` | Gallery-only |
| `dsGallerySectionTitles` | getter | `design_system_gallery_registry.dart` | Gallery-only |

---

## 3. Aggregate Counts

| Bucket | Count |
|---|---:|
| Prism API aliases (typedef + extension) | **296** |
| — Production aliases | 287 |
| — Experimental (drag-drop) aliases | 7 |
| — Gallery Prism aliases | 2 |
| Task 1807 tooling classes | **2** |
| Non-Prism gallery entrypoints | **4** |
| **Total public top-level symbols** | **302** |
| DS\* layer barrels re-exported | **0** |
| Public DSGallery\* identifiers | **0** (hidden) |

### 3.1 Source↔audit set equality

```text
  src_set (typedef+extension Prism*) = 296
  audit_set (typedef/extension rows `Prism*`) = 296
  tooling_set (Task 1807 public classes) = 2
  missing = 0
  extra   = 0
```

Regenerate proof:

```bash
rg -c '^typedef Prism' packages/warp_prism_ui/lib/src/prism_aliases.dart
rg -c '^extension Prism' packages/warp_prism_ui/lib/src/prism_aliases.dart
# set-diff table backticks vs source → empty missing/extra

# Automated lock (Task 1302 regression guard — fails on inventory freeze):
dart run packages/warp_prism_ui/tool/verify_public_barrel_audit.dart --repo-root .
```

---

## 4. Classification Notes

- **Experimental drag-drop** (7): `PrismDragMoveEvent`, `PrismDragMoveLaneIntent`, `PrismDragPayload`, `PrismDragReorderEvent`, `PrismDragReorderIntent`, `PrismDraggableCard`, `PrismDropTarget`.
- **Gallery Prism aliases** (2): `PrismGallerySectionSpec`, `PrismGallerySections`.
- **Intent aliases retained** for keyboard DnD boundary harness.
- **`PrismInsightRiskLevel` retained** under organisms/story surface.
- Recent +11 (post-263 freeze): `PrismKeyboardCheatsheet`, `PrismKeyboardCheatsheetFixtures`,
  `PrismKeyboardShortcut`, `PrismKeyboardShortcutGroup`, `PrismMediaDetailFixtures`,
  `PrismMediaDetailItem`, `PrismMediaDetailOverlay`, `PrismScaleMeasureBar`,
  `PrismScaleMeasureBarFixtures`, `PrismScaleSegment`, `PrismToastRiskTier`.
- Historical experimental names `PrismDragHandle` / `PrismDropZone` are **gone**; live
  surface uses `PrismDraggableCard` / `PrismDropTarget` (+ events/intents/payload).

---

## 5. Gallery Separation Recommendation

Gallery is mixed into the public barrel **by design** (design-system documentation
entrypoint). Separation options (not implemented — export-removal guardrail):

1. Keep current four-export barrel; document gallery as gallery-only (this audit).
2. Future optional: `package:warp_prism_ui/gallery.dart` secondary entry for
   gallery-only consumers; production apps import main barrel only.

**Do not remove** gallery exports while Observatory or catalog tests depend on them.

---

## 6. Boundary Enforcement

Task 1205 harness (`packages/warp_prism_ui/test/boundaries/boundary_test.dart`):

- Consumers must import `package:warp_prism_ui/warp_prism_ui.dart` only (no `src/`).
- Public DS declarations must have Prism aliases.
- Public barrel must hide DS\* names from consumers.

---

## 7. Validation Snapshot (2026-09-02 current re-audit)

```text
test -f docs/design/public-barrel-audit.md
rg -c '^typedef Prism' packages/warp_prism_ui/lib/src/prism_aliases.dart  # 295
rg -c '^extension Prism' packages/warp_prism_ui/lib/src/prism_aliases.dart # 1
dart run packages/warp_prism_ui/tool/verify_public_barrel_audit.dart --repo-root .
# src Prism: 296 (295 typedef + 1 extension); audit Prism rows: 296
# audit non-Prism gallery: 4; barrel exports: 4; total public top-level: 302
# Public barrel audit lock: PASS
dart analyze packages/warp_prism_ui/lib/warp_prism_ui.dart \
  packages/warp_prism_ui/lib/src/prism_aliases.dart
# No issues found!
dart run packages/warp_prism_ui/test/boundaries/boundary_test.dart --repo-root .
# Checks: 15/15 PASS, 0 FAIL, 0 violation(s)
flutter test packages/warp_prism_ui/test/boundaries/public_barrel_no_ds_export_test.dart --no-pub
# 3 tests passed
```

---

## 8. Regression Guards

1. Four-export barrel only; no DS layer re-exports.
2. Keep `hide DSGallerySectionSpec` / `hide DSGallerySections`.
3. Boundary harness must stay green (currently 7 checks).
4. Intent aliases + `PrismInsightRiskLevel` must remain listed.
5. **Re-audit when new `typedef Prism*` land** — set equality must stay empty.

