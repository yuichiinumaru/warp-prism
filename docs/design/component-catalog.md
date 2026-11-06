# Warp Prism — Current Component Catalog

> **Status:** Active discovery catalog, checked against the live `warp_prism_ui` package on 2026-10-15.
> **Scope:** Reusable Flutter UI widgets owned by the ADS package. This is an inventory, not a promotion verdict: presence here does not by itself mean a component is stable or suitable for every consumer.

This document is the canonical human-readable index of the current shared component set. The code remains the factual authority for existence, signatures, and exports. The package's public barrel and `prism_aliases.dart` determine which `Prism*` names consumers can import; `DS*` names are implementation names, not consumer API. The Catalog/gallery is the visual discovery surface, not a second independent component list.

## How to read this catalog

- Lists name widget/component surfaces, not every supporting enum, model, controller, fixture, or token.
- Classification follows the package's current `src/atoms/`, `src/molecules/`, and `src/organisms/` ownership. It is not a claim that every component fits every atomic-design taxonomy equally well.
- Component names use the public `Prism*` spelling where defined. For names whose status is unclear, consult the package barrel rather than assuming a public export.
- `PrismScaleMeasureBar` is explicitly classified by its source documentation as a molecule despite its gallery placement in an optional-polish section.
- Template/layout surfaces are listed separately where the source explicitly defines them; gallery demo cases are not counted as product components.

## Atoms

Source barrel: [`atoms.dart`](../../packages/warp_prism_ui/lib/src/atoms/atoms.dart)

| Component | Source family |
|---|---|
| `PrismText` | Text |
| `PrismIcon` | Icon |
| `PrismBadge` | Badge |
| `PrismChip` | Chip |
| `PrismStatusDot` | Operational status indicator |
| `PrismDivider` | Divider |
| `PrismGlowDivider` | Decorative divider |
| `PrismGlassPanel` | Glass surface |
| `PrismGlassPanelSimple` | Simple glass surface variant |
| `PrismGlowBorder` | Decorative border |
| `PrismSparkline` | Compact data visualization |
| `PrismButton` | Button |
| `PrismCheckbox` | Checkbox |
| `PrismSwitch` / `PrismToggle` | Switch/toggle (same underlying implementation) |
| `PrismTextField` | Text input |

## Molecules

Source barrel: [`molecules.dart`](../../packages/warp_prism_ui/lib/src/molecules/molecules.dart)

| Component | Source family |
|---|---|
| `PrismInteractiveSurface` | Shared focus/interaction surface |
| `PrismSearchBar` | Search |
| `PrismFilterChipGroup` | Filter controls |
| `PrismAssetCard` | Asset summary card |
| `PrismMetricTile` | Metric display |
| `PrismProvenancePill` | Provenance/canonicity marker |
| `PrismTaskCard` | Task summary card |
| `PrismEvidenceRow` | Evidence display |
| `PrismTimelineMarker` | Timeline marker |
| `PrismStateSurface` | Empty/loading/error and related states |
| `PrismUptimeBar` | Uptime display |
| `PrismHealthCard` | Health summary |
| `PrismToast` / `PrismToastManager` | Toast notification and manager |
| `PrismShimmer` | Loading shimmer |
| `PrismSkeletonTextLine` | Text skeleton |
| `PrismSkeletonCard` | Card skeleton |
| `PrismSkeletonTableRows` | Table-row skeleton |
| `PrismDraggableCard` | Draggable card |
| `PrismDropTarget` | Drag/drop target |
| `PrismAccordion` | Expand/collapse group |
| `PrismDialog` | Dialog |
| `PrismSelect` | Selection control |
| `PrismColorField` | Color input |
| `PrismScaleMeasureBar` | Compact map-scale chrome |

## Organisms

Source barrel: [`organisms.dart`](../../packages/warp_prism_ui/lib/src/organisms/organisms.dart)

### Shells, navigation, and content structure

`PrismShell`, `PrismSidebar`, `PrismTopbar`, `PrismPageShell`, `PrismBreadcrumbs`, `PrismTree`, `PrismTabBar`, `PrismSplitPane`, `PrismLaneBoard`, `PrismDetailInspector`, `PrismStoryPanel`, `PrismFallbackView`, `PrismErrorBoundary`.

### Data, status, and operational views

`PrismTimeline`, `PrismGraphCanvas`, `PrismDataTable`, `PrismVirtualList`, `PrismVirtualGrid`, `PrismStatusGrid`, `PrismLogViewer`, `PrismCodeBlock`, `PrismMarkdownRenderer`, `PrismCommandPalette`.

### Map, workspace, and operator surfaces

`PrismMapHudWorkspace`, `PrismToolStripSlideout`, `PrismLayerControlPanel`, `PrismFilterWorkbench`, `PrismMapCanvasStage`, `PrismEntityLocateSearch`, `PrismEntityIntelPanel`, `PrismEntityRelationCard`, `PrismWatchlistDock`, `PrismCoordinateStatusBar`, `PrismMapLegend`, `PrismTimeMachineScrubber`, `PrismStatusTicker`, `PrismFloatingAnalyticsHud`, `PrismOpsControlCluster`, `PrismConnectorPanel`, `PrismViewPresets`, `PrismWorkspaceShareCard`, `PrismOsintWorkbench`, `PrismAiAnalystPanel`, `PrismTerminalWorkspace`, `PrismAgentShellPanel`, `PrismKeyboardCheatsheet`, `PrismMediaDetailOverlay`, `PrismThemeEditor`.

### Agent, workflow, and integration-facing displays

`PrismAgentTranscript`, `PrismToolCallCard`, `PrismMessageStatusHistory`, `PrismArtifactWorkbench`, `PrismProviderHealthMatrix`, `PrismMcpCapabilityInspector`, `PrismTimingWaterfall`, `PrismTrafficInspector`, `PrismExecutionConsole`, `PrismWorkflowCanvasStage`.

## Templates and gallery-only sections

- The package contains `MasterDetailTemplate` under `src/templates/`; consult [`templates.dart`](../../packages/warp_prism_ui/lib/src/templates/templates.dart) for its current export surface. Other template names shown in old policy examples or gallery prose are not included here unless present in the live package barrel.
- The gallery also has sections for tokens, operational-state examples, accessibility/focus, toasts, virtual scrolling, health dashboard, and templates. A gallery section or demo helper is not automatically a separately owned component.
- Browse the gallery registry at [`design_system_gallery_registry.dart`](../../packages/warp_prism_ui/lib/src/gallery/design_system_gallery_registry.dart); the Catalog host is `apps/catalog`.

## Canonical sources and maintenance

- Current implementation and layer ownership: `packages/warp_prism_ui/lib/src/{atoms,molecules,organisms,templates}/`.
- Consumer-facing API: `packages/warp_prism_ui/lib/warp_prism_ui.dart` and `packages/warp_prism_ui/lib/src/prism_aliases.dart`.
- Gallery section registration and visual examples: `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_registry.dart` and `design_system_gallery_sections.dart`.
- Layer law and promotion criteria: [Layer Contracts](../../.project/architecture/layer-contracts.md) and [Token, Theme, Catalog, and Component Promotion Policy](token-theme-catalog-policy.md).

When a component is added, removed, reclassified, or promoted, update this inventory in the same change and check its implementation barrel, public alias/export status, and gallery registration. Do not infer `STABLE` status from listing it here.
