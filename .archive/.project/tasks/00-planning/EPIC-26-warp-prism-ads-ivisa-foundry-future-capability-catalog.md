# EPIC 26 — Warp Prism ADS: Ivisa Foundry Capability Harvest (Future Flutter Catalog)

> **Planning Status**: Active Planning Epic  
> **Executable?**: No — planning artifact only. Executable work lives as `Task 19NN` under task lanes when promoted.  
> **Promotion Gate**: Promote tasks into `01-open/` based on priority waves when gallery capacity and dependencies allow.  
> **Origin**: User direction 2026-09-16 — comprehensive capability extraction from `references/secondary-yuichiinumaru-ivisa-tamagui` (170+ components across atoms, molecules, organisms, and foundry infrastructure).  
> **Depends on**: EPIC-01 (ADS foundation), EPIC-13 (public `Prism*` barrel / aliases), EPIC-17 (form primitives baseline), EPIC-18 (Black Obsidian visual contract).  
> **Related**: EPIC-15 (HUD / Map organisms), EPIC-16 (CyberCore ops & transcript organisms), EPIC-23 (Connected Catalog Component Contract Registry).

---

## 1. Goal & Architectural Posture

This epic catalogs all reusable capabilities, interaction idioms, and operational primitives identified in the `secondary-yuichiinumaru-ivisa-tamagui` donor repository that do **not** currently exist in `packages/warp_prism_ui`.

### Core Directive
- **Zero TSX Porting**: Do not copy React, Tamagui, React Native Web, or Storybook code.
- **Pure Flutter Reimplementation**: Every capability is rewritten from scratch in idiomatic Flutter/Dart using Warp Prism's **Black Obsidian Glass** visual language (`#0A0E17` background, frosted glass cards, `#00D4FF` cyan interactive accents, semantic status colors).
- **Ontological Focus**: Components are classified into five functional operator families:
  1. **OBSERVE**: Telemetry, metrics, passive status, and data visualization.
  2. **INSPECT**: Deep artifact inspection, diffs, audits, and discrepancy analysis.
  3. **NAVIGATE**: Spatial manipulation, relations, hierarchies, and step progression.
  4. **COMMAND**: Active execution, contextual menus, overlays, and task transitions.
  5. **AGENT**: AI agent supervision, token monitoring, tool execution, and Human-in-the-Loop (HITL) governance.
- **Evidence-Driven UI & State Matrices**: Every component contract must satisfy the 4 universal operational states:
  - `Loading`: Skeleton / spinner representation.
  - `Empty`: Dedicated icon + contextual message + optional CTA.
  - `Error`: Inline semantic alert / warning banner with retry affordance.
  - `Data / Active`: Normal rendered interaction surface.

---

## 2. Source Evidence Baseline

The catalog was compiled from a 10-slice parallel investigation of `references/secondary-yuichiinumaru-ivisa-tamagui/ivisa-tamagui/`:

| Slice | Focus Area | Key Donor Paths |
|---|---|---|
| **F1** | Atoms & Tokens | `packages/ui/src/atoms/` (`Alert`, `AspectRatio`, `Avatar`, `Badge`, `Button`, `Checkbox`, `Dot`, `Dropzone`, `Input`, `Kbd`, `Label`, `Meter`, `Progress`, `Skeleton`, `StatusLight`, `Toggle`, `Typography`, `Coachmark`) |
| **F2** | Molecules (Form Grammar) | `packages/ui/src/molecules/` (`Field/`, `InputGroup/`, `OTPInput/`, `StarRating/`, `Select/`, `RadioGroup/`, `ToggleGroup/`, `Calendar/`, `DatePicker/`, `ComboButton/`, `ButtonGroup/`) |
| **F3** | Molecules (Overlay/Menu Grammar) | `packages/ui/src/molecules/` (`Dialog/`, `AlertDialog/`, `Sheet/`, `Drawer/`, `Popover/`, `HoverCard/`, `Tooltip/`, `ContextMenu/`, `DropdownMenu/`, `Menubar/`, `Toast/`, `Sonner/`, `ComponentErrorBoundary/`) |
| **F4** | Molecules (Layout Grammar) | `packages/ui/src/molecules/` (`Accordion/`, `Card/`, `Table/`, `Tabs/`, `Resizable/`, `Stepper/`, `Pagination/`, `Breadcrumb/`, `Empty/`, `Item/`, `MetricCard/`, `AvatarGroup/`, `BadgeCounter/`) |
| **F5** | Organisms (Data Visualization) | `packages/ui/src/organisms/` (`DataTable/`, `FilterBar/`, `KPIGrid/`, `DecompositionTree/` + 22 chart organisms: `AreaChart`, `BarChart`, `BoxPlotChart`, `BulletChart`, `ChordDiagram`, `ComboChart`, `FunnelChart`, `GaugeChart`, `HeatmapChart`, `LineChart`, `MarimekkoChart`, `ParallelCoordinates`, `PieChart`, `PolarChart`, `RadarChart`, `RankingChart`, `RidgelinePlot`, `SankeyDiagram`, `ScatterChart`, `SunburstChart`, `TreemapChart`, `WaterfallChart`) |
| **F6** | Organisms (Shell & Ops Workbench) | `packages/ui/src/organisms/` (`DashboardShell/`, `DashboardLayout/`, `Sidebar/`, `Navbar/`, `OpsActivityLogWorkbench/`, `NotificationFeed/`, `TaskBoard/`, `Scheduler/`, `ThemeCustomizer/`, `A11yToolbar/`) |
| **F7** | Organisms (Agentic Systems) | `packages/ui/src/organisms/` (`ChatPanel/`, `ChatWidget/`, `AgentAnimationPanel/`, `AgentAnimationModal/`, `TokenUsageMeter`, `ToolCallRenderer`, `AgentTodoList`) |
| **F8** | Organisms (Graph, Time & Stage) | `packages/ui/src/organisms/` (`NetworkGraph/`, `GraphCanvasControls/`, `WorkflowBuilderCanvas/`, `Timeline/`, `TimelineAudit/`, `Command/`, `Carousel/`) |
| **F9** | Organisms (Media, Form & Comparison) | `packages/ui/src/organisms/` (`DiffViewer/`, `PDFPreview/`, `ImageAnnotator/`, `SignaturePad/`, `MediaGrid/`, `Video/`, `ScannerView/`, `RichText/`, `Form/`, `SchemaForm/`, `WizardForm/`, `FileUpload/`, `Autocomplete/`, `CodeBlock/`, `AnimatedSegmentedControl/`) |
| **F10** | Foundry Infrastructure | `packages/ui/component-registry.json`, `packages/mcp-server/`, `scripts/generate-registry.js`, test utilities |

---

## 3. Already Covered (Do Not Re-Task)

The following components from the donor repository already have mature, verified equivalents in `packages/warp_prism_ui` and MUST NOT be re-tasked:

| Donor Component | Warp Prism Equivalent | Notes |
|---|---|---|
| `StatusLight` / `Dot` | `DSStatusDot` | 15 operational states already supported |
| `Empty` | `DSStateSurface.empty` | Full state surface available |
| `Resizable` | `DSSplitPane` | Horizontal and vertical splitting with ratios |
| `TaskBoard` | `DSLaneBoard` | Lane-based board for tasks/items |
| `DashboardShell` / `DashboardLayout` | `DSShell` + `DSPageShell` | App chrome and content page shell separated |
| `PageHeader` | `DSPageShell` | Page title, subtitle, breadcrumbs, actions |
| `ThemeCustomizer` | `PrismThemeEditor` | Live token override and bake-back tool |
| `Command` | `DSCommandPalette` | Fuzzy-search action and navigation palette |
| `CodeBlock` | `DSCodeBlock` | Syntax highlighted with copy affordance |
| `LocationStatus` | `DSCoordinateStatusBar` | Stage coordinates and feed status bar |
| `DataTable` | `DSDataTable` | Virtualized, sortable, filterable table |
| `FilterBar` | `DSFilterWorkbench` | Multi-section filter drawer with apply/clear |
| `KPIGrid` | `DSMetricTile` / `DSFloatingAnalyticsHud` | Key performance indicator cards |
| `NetworkGraph` | `DSGraphCanvas` (`graph/` layers) | Force-directed graph canvas with typed model |
| `WorkflowBuilderCanvas` | `DSWorkflowCanvasStage` | DAG workflow stage with node and edge kinds |
| `Tabs` | `DSTabBar` + `DSTabView` | Standard tabbed navigation |
| `Accordion` | `PrismAccordion` | Collapsible section panels (EPIC-17) |
| `Breadcrumb` | `PrismBreadcrumbs` | Hierarchical navigation trail (EPIC-17) |
| `Button` / `Input` / `Checkbox` / `Switch` | `PrismButton`, `PrismTextField`, `PrismCheckbox`, `PrismSwitch` | Form primitives baseline (EPIC-17) |
| `Select` / `Dialog` | `PrismSelect`, `PrismDialog` | Dropdown selector and modal dialog |

---

## 4. Explicit Skips (Out of ADS Scope)

The following donor items are product features or platform-coupled experiments and are excluded from the design system:
- **`AuthScreen`**: Application-level feature flow; belongs to consumer app, not ADS.
- **`CookieBanner`**: Web compliance artifact; not applicable to desktop/native operational systems.
- **`ScannerView`**: Hardware camera integration mock; platform concern.
- **`Video`**: Native media playback engine; media app concern.
- **`NativeSelect`**: Web-only HTML select element; obsolete in Flutter.
- **`MonthsPicker`**: Trivial wrapper around select; consumer concern.

---

## 5. The Candidate Capability Catalog (Tasks 1901–1980)

Tasks are organized into 7 sequential execution waves.

### Wave C1 — Overlays, Menus & Action Grammar (COMMAND / INSPECT)
Priority: 🔴 **P0** (Structural gap in interaction vocabulary)

| Task ID | Component Name | Layer | Family | Donor Reference | Capability / Interaction Intent |
|---|---|---|---|---|---|
| **Task 1901** | `PrismPopover` | Molecule | COMMAND | `molecules/Popover/` | Base anchored non-modal overlay with collision detection, arrow positioning, and loading/error/disabled state propagation. Unlocks dropdown menus and hover cards. |
| **Task 1902** | `PrismContextMenu` | Molecule | COMMAND | `molecules/ContextMenu/` | Desktop right-click and mobile long-press contextual action menu supporting keyboard shortcuts (`Kbd`), nested submenus, separators, and title labels. |
| **Task 1903** | `PrismDropdownMenu` | Molecule | COMMAND | `molecules/DropdownMenu/` | Anchored menu trigger supporting grouped single-select radio items (`PrismRadioItem`) and multi-select checkbox items (`PrismCheckboxItem`). |
| **Task 1904** | `PrismMenubar` | Molecule | COMMAND | `molecules/Menubar/` | Desktop horizontal application menu bar with keyboard traversal (Alt/arrow keys), nested menu cascades, and right-aligned status slot (`rightSlot`). |
| **Task 1905** | `PrismTooltip` & `PrismHoverCard` | Molecule | INSPECT | `molecules/Tooltip/`, `HoverCard/` | Non-modal hovering detail inspector with customizable delay timers, interactive action slot, and obsidian glass styling. |
| **Task 1906** | `PrismSheet` & `PrismDrawer` | Molecule | COMMAND | `molecules/Sheet/`, `Drawer/` | Bottom and side sliding sheet with drag-to-dismiss handle bar, full/half snap points, and touch responsive adaptation. |
| **Task 1907** | `PrismAlertDialog` | Molecule | COMMAND | `molecules/AlertDialog/` | High-level destructive confirmation modal with explicit loading spinner on the confirm button, destructive theme accents, and cancel key traps. |
| **Task 1908** | `PrismSonner` | Molecule | COMMAND | `molecules/Sonner/` | Queue-driven toast notification stack with progress indicators, multi-action callbacks, promise/future state progression, and pause-on-hover. |
| **Task 1909** | `PrismNotificationCard` | Molecule | OBSERVE | `molecules/NotificationCard/` | In-feed persistent operational card with severity badge, timestamp, dismiss action, and expandable payload inspection. |

---

### Wave C2 — Form & Input Grammar Orchestration (COMMAND / INPUT)
Priority: 🟡 **P1** (Completes form ergonomics beyond raw text fields)

| Task ID | Component Name | Layer | Family | Donor Reference | Capability / Interaction Intent |
|---|---|---|---|---|---|
| **Task 1910** | `PrismField` | Molecule | COMMAND | `molecules/Field/` | Unified form orchestration molecule binding Label, Control, Validation State, Helper text, Error text, and Skeleton loading state into one atomic contract. |
| **Task 1911** | `PrismOTPInput` | Molecule | COMMAND | `molecules/OTPInput/` | Multi-cell verification code input with automatic focus advance, backspace retreat, paste sanitization, and character masking. |
| **Task 1912** | `PrismRadioGroup` | Molecule | COMMAND | `molecules/RadioGroup/` | Accessible exclusive option selection group with horizontal/vertical orientation, loading skeletons, and error messaging. |
| **Task 1913** | `PrismToggleGroup` | Molecule | COMMAND | `molecules/ToggleGroup/` | Mutually exclusive or multi-select toolbar button group with shared disabled/loading/error context. |
| **Task 1914** | `PrismStarRating` | Molecule | COMMAND | `molecules/StarRating/` | Fractional / integer rating primitive with hover preview, read-only display mode, and customizable icon glyphs. |
| **Task 1915** | `PrismCalendar` & `PrismDatePicker` | Molecule | COMMAND | `molecules/Calendar/`, `DatePicker/` | Month grid calendar molecule and popover date picker with single-date, range-select, disabled bounds, and dark obsidian styling. |
| **Task 1916** | `PrismComboButton` | Molecule | COMMAND | `molecules/ComboButton/` | Split primary action button with attached contextual popover menu for secondary options. |
| **Task 1917** | `PrismInputGroup` & `PrismButtonGroup` | Molecule | COMMAND | `molecules/InputGroup/`, `ButtonGroup/` | Visual and focus-fused grouping container for input fields, search icons, and action buttons. |
| **Task 1918** | `PrismKbd` | Atom | COMMAND | `atoms/Kbd/` | Semantic keyboard shortcut display atom with modifiers (Cmd, Ctrl, Alt, Shift), size variants, and key cap elevation. |
| **Task 1919** | `PrismMeter` | Atom | OBSERVE | `atoms/Meter/` | 4-tier threshold bar/radial meter with semantic color transitions (`positive`, `notice`, `negative`, `info`) based on defined warning/critical values. |
| **Task 1920** | `PrismDropzone` & `PrismFileUpload` | Organism | COMMAND | `atoms/Dropzone/`, `organisms/FileUpload/` | File upload dropzone molecule with drag-and-drop hover feedback, file type constraints, progress tracking, and thumbnail previews. |
| **Task 1921** | `PrismAutocomplete` | Molecule | COMMAND | `organisms/Autocomplete/` | Searchable combobox input with debounced suggestions filter, keyboard selection (ArrowDown/Up, Enter, Esc), and empty state fallback. |
| **Task 1922** | `PrismCheckbox` Indeterminate Extension | Atom | COMMAND | `atoms/Checkbox/` | Support for mixed/tri-state checkbox representation with minus glyph and hierarchical parent selection. |

---

### Wave C3 — Data Exploration & Visualization Encyclopedia (OBSERVE)
Priority: 🟡 **P1** (Essential for observability, telemetries, and ops metrics)

| Task ID | Component Name | Layer | Family | Donor Reference | Capability / Interaction Intent |
|---|---|---|---|---|---|
| **Task 1930** | `PrismChartCore` | Organism | OBSERVE | `molecules/ChartContainer/` | Foundational engine-agnostic chart container providing obsidian glass frame, headers, footer slots, hover crosshair, shared tooltip, and uniform 4-state matrix. |
| **Task 1931** | `PrismBulletChart` | Organism | OBSERVE | `organisms/BulletChart/` | Performance-versus-target bar organism showing current value, target marker, and qualitative performance bands (critical for SLO / rate-limit / quota monitoring). |
| **Task 1932** | `PrismGaugeChart` | Organism | OBSERVE | `organisms/GaugeChart/` | Radial / semicircle progress gauge with threshold color transitions and central metric readout for saturation / health monitoring. |
| **Task 1933** | `PrismSankeyDiagram` | Organism | OBSERVE | `organisms/SankeyDiagram/` | Directed acyclic flow diagram organism with node columns, weighted ribbon links, and throughput volume inspection for network / routing analysis. |
| **Task 1934** | `PrismDecompositionTree` | Organism | OBSERVE | `organisms/DecompositionTree/` | Interactive hierarchical drill-down tree organism allowing operators to decompose aggregate metrics or error counts down root cause branches. |
| **Task 1935** | `PrismRankingChart` | Organism | OBSERVE | `organisms/RankingChart/` | Animated rank-ordered proportional bar chart for comparing top providers, agents, or error categories. |
| **Task 1936** | `PrismWaterfallChart` | Organism | OBSERVE | `organisms/WaterfallChart/` | Cumulative value change waterfall chart tracking sequential positive/negative contributors (distinct from `PrismTimingWaterfall` which tracks duration spans). |
| **Task 1937** | `PrismHeatmapChart` | Organism | OBSERVE | `organisms/HeatmapChart/` | 2D categorical density matrix with cell intensity coloring and hover tooltips for activity / latency distribution. |
| **Task 1938** | `PrismAreaChart`, `PrismLineChart`, `PrismBarChart` | Organism | OBSERVE | `organisms/AreaChart/`, `LineChart/`, `BarChart/` | Core cartesian timeseries and categorical charts with multi-series overlay and hover crosshairs. |
| **Task 1939** | `PrismPieChart` & `PrismDonutChart` | Organism | OBSERVE | `organisms/PieChart/` | Part-to-whole categorical distribution charts with slice highlights and center-metric slot. |
| **Task 1940** | `PrismFunnelChart` | Organism | OBSERVE | `organisms/FunnelChart/` | Multi-stage conversion and pipeline drop-off visualization with centered proportional stages. |
| **Task 1941** | `PrismStatisticalChartPack` | Organism | OBSERVE | `organisms/BoxPlotChart/`, `RidgelinePlot/`, `ParallelCoordinates/` | `PrismBoxPlotChart` (5-number summary), `PrismRidgelinePlot` (stacked density ridges), and `PrismParallelCoordinates` (multivariate normalized lines). |
| **Task 1942** | `PrismSpecialtyChartPack` | Organism | OBSERVE | `organisms/ChordDiagram/`, `SunburstChart/`, `TreemapChart/`, `MarimekkoChart/`, `PolarChart/`, `ScatterChart/` | `PrismChordDiagram` (relational circular matrix), `PrismSunburstChart` (multi-tier radial partition), `PrismTreemapChart` (nested squarified tiles), and `PrismMarimekkoChart` (variable-width/height market map). |
| **Task 1943** | `PrismComboChart` | Organism | OBSERVE | `organisms/ComboChart/` | Multi-axis composable chart container blending lines, bars, and scatter points on a shared viewport. |

---

### Wave C4 — Agentic UI & Supervision Language (AGENT)
Priority: 🔴 **P0** (High strategic leverage for Ganthritor and CyberCore agent interfaces)

| Task ID | Component Name | Layer | Family | Donor Reference | Capability / Interaction Intent |
|---|---|---|---|---|---|
| **Task 1950** | `PrismTokenUsageMeter` | Molecule | AGENT | `organisms/ChatPanel/TokenUsageMeter.tsx` | Context window saturation organism showing input tokens, output tokens, cached tokens, and total context ceiling with semantic threshold warnings. |
| **Task 1951** | `PrismToolCallCard` HITL Extension | Organism | AGENT | `organisms/ChatPanel/ToolCallRenderer.tsx` | Human-in-the-Loop interactive execution gate adding approve, reject, and JSON parameter edit workflows to `PrismToolCallCard`. |
| **Task 1952** | `PrismAgentTodoList` | Organism | AGENT | `organisms/ChatPanel/AgentTodoList.tsx` | Agent goal and step execution tracker showing active, pending, completed, and cancelled subtasks with dynamic progress calculation. |
| **Task 1953** | `PrismAgentStatusPanel` & `PrismAgentAnimationModal` | Organism | AGENT | `organisms/AgentAnimationPanel/`, `AgentAnimationModal/` | Live agent lifecycle dashboard (`idle`, `working`, `error`, `success`) with timestamped event stream and animated state badge. |

---

### Wave C5 — Inspection, Comparison & Workbenches (INSPECT / NAVIGATE)
Priority: 🟡 **P1** (Code review, governance audits, and dynamic forms)

| Task ID | Component Name | Layer | Family | Donor Reference | Capability / Interaction Intent |
|---|---|---|---|---|---|
| **Task 1960** | `PrismDiffViewer` | Organism | INSPECT | `organisms/DiffViewer/` | Side-by-side or unified line diff organism with additions, deletions, word-level changes, and syntax highlighting built on `DSCodeBlock`. |
| **Task 1961** | `PrismTimelineAudit` | Organism | INSPECT | `organisms/TimelineAudit/` | Compliance and security audit timeline with operator attribution, severity filtering, and payload delta inspection (distinct from `DSTimeline` changelog). |
| **Task 1962** | `PrismSchemaForm` | Organism | COMMAND | `organisms/SchemaForm/` | Declarative JSON schema-driven form generator rendering typed fields, validation rules, and sections directly from data models. |
| **Task 1963** | `PrismWizardForm` | Organism | COMMAND | `organisms/WizardForm/` | Multi-step wizard form container with per-step validation gates, state persistence across navigation, and integrated step progress. |
| **Task 1964** | `PrismStepper` | Molecule | NAVIGATE | `molecules/Stepper/` | Standalone horizontal and vertical step progression molecule with valid/invalid/active state indicators. |
| **Task 1965** | `PrismPagination` | Molecule | NAVIGATE | `molecules/Pagination/` | Standalone pagination control molecule with page jump, items-per-page selector, and boundary ellipsis. |
| **Task 1966** | `PrismAvatarGroup` & `PrismBadgeCounter` | Molecule | OBSERVE | `molecules/AvatarGroup/`, `molecules/BadgeCounter/` | Stacked avatar collection with overflow counter and notification badge pill. |
| **Task 1967** | `PrismMediaGrid` | Organism | INSPECT | `organisms/MediaGrid/` | Selectable media asset gallery with grid/list mode toggle, multi-selection bar, and bulk action triggers. |
| **Task 1968** | `PrismImageAnnotator` & `PrismSignaturePad` | Organism | INSPECT | `organisms/ImageAnnotator/`, `SignaturePad/` | Freehand drawing and vector stroke annotation canvas overlay for marking inspection artifacts. |
| **Task 1969** | `PrismPDFPreview` | Organism | INSPECT | `organisms/PDFPreview/` | Multi-page PDF document inspection organism with zoom, page thumbnails, and navigation toolbar. |

---

### Wave C6 — Operational Shell & Accessibility Controls (OBSERVE / COMMAND)
Priority: 🟢 **P2** (Operational ergonomics and accessibility controls)

| Task ID | Component Name | Layer | Family | Donor Reference | Capability / Interaction Intent |
|---|---|---|---|---|---|
| **Task 1970** | `PrismScheduler` | Organism | COMMAND | `organisms/Scheduler/` | Calendar / time-grid operational task and maintenance scheduler with conflict detection and time-slot booking. |
| **Task 1971** | `PrismNotificationFeed` | Organism | OBSERVE | `organisms/NotificationFeed/` | Grouped notification drawer / center categorized by channel, system, and severity with read/unread tracking. |
| **Task 1972** | `PrismA11yToolbar` | Organism | COMMAND | `organisms/A11yToolbar/` | Live accessibility adjustment widget for high contrast toggles, font scaling, focus ring enhancement, and reduced motion. |
| **Task 1973** | `PrismGraphCanvasControls` | Molecule | NAVIGATE | `organisms/GraphCanvasControls/` | Floating tool overlay for `DSGraphCanvas` offering zoom-to-fit, physics freeze/thaw, search filter, and layout mode toggles. |
| **Task 1974** | `PrismCarousel` | Molecule | NAVIGATE | `organisms/Carousel/` | Touch and arrow navigated content carousel with page indicators and auto-advance controls. |
| **Task 1975** | `PrismRichTextEditor` | Organism | COMMAND | `organisms/RichText/` | Formatted text editor with markdown / HTML output, formatting toolbar, and sanitized preview. |

---

### Wave C7 — Component Foundry & Machine-Readable Registry (INFRA / HARNESS)
Priority: 🟡 **P1** (Direct alignment with EPIC-23 and AI agent integration)

| Task ID | Component Name | Layer | Family | Donor Reference | Capability / Interaction Intent |
|---|---|---|---|---|---|
| **Task 1980** | `Warp Prism Component Foundry Registry` | Infra | HARNESS | `component-registry.json`, `packages/mcp-server/` | Machine-readable `prism-component-registry.json` exporter and agent-discovery query tool enabling AI coding assistants to discover, inspect props, and instantiate Warp Prism components without hallucination. |

---

## 6. Implementation & Promotion Rules

1. **Promotion Order**:
   - **Phase 1 (Agentic & Overlays)**: Wave C1 (Overlays/Menus) + Wave C4 (Agentic Supervision) have highest immediate value for Ganthritor and CyberCore.
   - **Phase 2 (Forms & Core Viz)**: Wave C2 (Form Orchestration) + Wave C3 (Foundational Charts: Bullet, Gauge, Sankey, DecompositionTree).
   - **Phase 3 (Workbenches & Specialty Viz)**: Wave C5 (DiffViewer, SchemaForm, Wizard) + Wave C3 (Specialty charts).
   - **Phase 4 (Shells & Polish)**: Wave C6 (Scheduler, NotificationFeed, A11yToolbar).
   - **Transversal**: Wave C7 (Foundry Registry) executes in coordination with EPIC-23.
2. **Naming & Barrels**: Every component must export internal `DS*` and public `Prism*` typedef in `prism_aliases.dart`, re-exported via `packages/warp_prism_ui/lib/warp_prism_ui.dart`.
3. **Gallery Registration**: Every promoted task must register its demo section in `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_registry.dart`.
4. **Testing Gates**: Each component must include unit tests, widget tests with all 4 operational states, and semantics/a11y verification.
