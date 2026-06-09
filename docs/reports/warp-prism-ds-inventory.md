# Warp Prism Design System — Inventory and Mismatch Ledger

> **Generated**: 2026-06-07
> **Task**: 0014 — DS Token Contract and Inventory
> **Source**: Direct inspection of all 38 files in `lib/design_system/`

---

## 1. File Inventory

### 1.1 Tokens (7 files, ~1,050 lines)

| File | Class | Purpose | Lines |
|------|-------|---------|-------|
| `tokens/tokens.dart` | — | Barrel export | 8 |
| `tokens/ds_colors.dart` | `DSColors` | Color tokens — obsidian backgrounds, energy accents, status, governance, text, border, lane, asset | 178 |
| `tokens/ds_typography.dart` | `DSTypography` | Typography scale — display, heading, body, label, code, numeric | 186 |
| `tokens/ds_spacing.dart` | `DSSpacing` | Spacing scale — base (xxs..massive) + semantic (insets, gaps, layout dimensions) | 72 |
| `tokens/ds_radii.dart` | `DSRadii` | Border radii — base (none..full) + semantic (card, button, chip, input, panel, modal) | 47 |
| `tokens/ds_shadows.dart` | `DSShadows` | Shadow presets (elevation1-4) + glow effects (cyan, violet, gold, success, error, warning) | 144 |
| `tokens/ds_motion.dart` | `DSMotion` | Animation durations (instant..slowest) + curves (standard, enter, exit, emphasized, spring) + semantic animations | 62 |
| `tokens/ds_semantics.dart` | `DSSemantics` | Pre-composed semantic styles combining colors + typography (status, governance, asset, lane, proof) | 150 |

### 1.2 Atoms (8 files, ~900 lines)

| File | Class(es) | Purpose |
|------|-----------|---------|
| `atoms/atoms.dart` | — | Barrel export |
| `atoms/ds_text.dart` | `DSText`, `DSTextVariant` | Semantic text component with 18 variants (display, heading, body, label, code, numeric) |
| `atoms/ds_icon.dart` | `DSIcon`, `DSIconSize`, `DSIcons` | Icon component + semantic icon constants (navigation, asset kinds, status, actions, governance, lanes) |
| `atoms/ds_badge.dart` | `DSBadge`, `DSBadgeSize` | Count/status badge |
| `atoms/ds_chip.dart` | `DSChip`, `DSChipSize` | Label chip |
| `atoms/ds_status_dot.dart` | `DSStatusDot` | Status indicator dot with animation |
| `atoms/ds_divider.dart` | `DSDivider` | Horizontal divider with subtle/default/strong variants |
| `atoms/ds_glow_border.dart` | `DSGlowBorder` | Animated glow border effect |
| `atoms/ds_glass_panel.dart` | `DSGlassPanel`, `DSGlassPanelSimple` | Frosted glass effect panel (subtle, elevated, modal variants) + simple variant without blur |

### 1.3 Molecules (8 files, ~900 lines)

| File | Class(es) | Purpose |
|------|-----------|---------|
| `molecules/molecules.dart` | — | Barrel export |
| `molecules/ds_search_bar.dart` | `DSSearchBar` | Search input with filter integration |
| `molecules/ds_filter_chip_group.dart` | `DSFilterChipGroup`, `DSFilterOption` | Horizontal scrollable filter chip group |
| `molecules/ds_asset_card.dart` | `DSAssetCard` | Card for displaying assets (agent, skill, workflow, etc.) |
| `molecules/ds_metric_tile.dart` | `DSMetricTile`, `DSTrend` | Metric display tile with trend indicator |
| `molecules/ds_provenance_pill.dart` | `DSProvenancePill` | Governance provenance indicator |
| `molecules/ds_task_card.dart` | `DSTaskCard` | Task card for lane board display |
| `molecules/ds_evidence_row.dart` | `DSEvidenceRow` | Proof/evidence display row |
| `molecules/ds_timeline_marker.dart` | `DSTimelineMarker` | Timeline entry marker |

### 1.4 Organisms (8 files, ~1,700 lines)

| File | Class(es) | Purpose |
|------|-----------|---------|
| `organisms/organisms.dart` | — | Barrel export |
| `organisms/ds_shell.dart` | `DSShell`, `DSShellResponsive` | Main app shell (sidebar + topbar + content + inspector) |
| `organisms/ds_sidebar.dart` | `DSSidebar`, `DSSidebarItem` | Navigation sidebar with items |
| `organisms/ds_topbar.dart` | `DSTopbar`, `DSTopbarAction` | Top bar with title, breadcrumbs, search, actions |
| `organisms/ds_lane_board.dart` | `DSLaneBoard`, `DSLane`, `DSLaneTask` | Kanban-style task lane board |
| `organisms/ds_timeline.dart` | `DSTimeline`, `DSTimelineEntry`, `DSTimelineGrouped`, `DSTimelineGroup` | Chronological changelog timeline |
| `organisms/ds_detail_inspector.dart` | `DSDetailInspector`, `DSDetailSection`, `DSPropertyRow`, `DSLinkRow` | Asset detail side panel |
| `organisms/ds_story_panel.dart` | `DSStoryPanel`, `DSStoryInsight`, `DSStoryCardQuick` | Data storytelling panel |
| `organisms/ds_graph_canvas.dart` | `DSGraphCanvas`, `GraphNode`, `GraphEdge` | Interactive force-directed graph canvas |

### 1.5 Templates (2 files, ~500 lines)

| File | Class(es) | Purpose |
|------|-----------|---------|
| `templates/templates.dart` | — | Barrel export |
| `templates/master_detail_template.dart` | `MasterDetailTemplate`, `CanvasTemplate`, `TimelineTemplate` | Page-level layout templates |

### 1.6 Top-level Barrel

| File | Purpose |
|------|---------|
| `design_system/design_system.dart` | Root barrel — exports tokens, atoms, molecules, organisms, templates |

---

## 2. Canonical Naming Convention

**Standard**: All design system classes use `DS` prefix (uppercase S).

| Layer | Convention | Examples |
|-------|-----------|----------|
| Tokens | `DS{Domain}` | `DSColors`, `DSTypography`, `DSSpacing`, `DSRadii`, `DSShadows`, `DSMotion`, `DSSemantics` |
| Atoms | `DS{Component}` | `DSText`, `DSIcon`, `DSBadge`, `DSChip`, `DSStatusDot`, `DSDivider`, `DSGlowBorder`, `DSGlassPanel` |
| Molecules | `DS{Component}` | `DSSearchBar`, `DSFilterChipGroup`, `DSAssetCard`, `DSMetricTile`, `DSProvenancePill`, `DSTaskCard`, `DSEvidenceRow`, `DSTimelineMarker` |
| Organisms | `DS{Component}` | `DSShell`, `DSSidebar`, `DSTopbar`, `DSLaneBoard`, `DSTimeline`, `DSDetailInspector`, `DSStoryPanel`, `DSGraphCanvas` |
| Templates | `{Name}Template` | `MasterDetailTemplate`, `CanvasTemplate`, `TimelineTemplate` |
| Enums | `DS{Domain}{Variant}` | `DSTextVariant`, `DSIconSize`, `DSBadgeSize`, `DSChipSize`, `DSTrend` |
| Data classes | `DS{Domain}` | `DSSidebarItem`, `DSTimelineEntry`, `DSLane`, `DSLaneTask`, `DSFilterOption`, etc. |

**Verification**: `grep -r 'Ds[A-Z]' lib/design_system/` returns 0 matches. All 38 files use `DS*` consistently.

---

## 3. Color Token Contract

### 3.1 Obsidian Backgrounds (6 tokens)
| Token | Hex | Usage |
|-------|-----|-------|
| `obsidianDeep` | `#050508` | Root background |
| `obsidianBase` | `#0A0A0F` | Primary surface |
| `obsidianElevated` | `#0F1015` | Cards, panels |
| `obsidianHover` | `#14141C` | Interactive hover |
| `obsidianActive` | `#1A1A24` | Active/selected |
| `glassOverlay` | `#1E1E28` | Glass panel overlay |

### 3.2 Energy Accents (9 tokens)
| Token | Hex | Usage |
|-------|-----|-------|
| `accentCyan` | `#00D4FF` | Primary accent |
| `accentCyanMuted` | `#0099B8` | Muted primary |
| `accentCyanDim` | `#006680` | Dim primary |
| `accentViolet` | `#8B5CF6` | Secondary accent |
| `accentVioletMuted` | `#6B4CD4` | Muted secondary |
| `accentVioletDim` | `#4C3899` | Dim secondary |
| `accentGold` | `#FFB800` | Tertiary accent |
| `accentGoldMuted` | `#CC9400` | Muted tertiary |
| `accentGoldDim` | `#997000` | Dim tertiary |

### 3.3 Semantic Status (12 tokens)
| Token | Hex | Usage |
|-------|-----|-------|
| `statusSuccess` | `#10B981` | Success state |
| `statusSuccessMuted` | `#059669` | Muted success |
| `statusSuccessDim` | `#047857` | Dim success |
| `statusWarning` | `#F59E0B` | Warning state |
| `statusWarningMuted` | `#D97706` | Muted warning |
| `statusWarningDim` | `#B45309` | Dim warning |
| `statusError` | `#EF4444` | Error state |
| `statusErrorMuted` | `#DC2626` | Muted error |
| `statusErrorDim` | `#B91C1C` | Dim error |
| `statusInfo` | `#3B82F6` | Info state |
| `statusInfoMuted` | `#2563EB` | Muted info |
| `statusInfoDim` | `#1D4ED8` | Dim info |

### 3.4 Governance Colors (6 tokens)
| Token | Hex | Usage |
|-------|-----|-------|
| `governanceCanonical` | `#10B981` | Parent canonical |
| `governanceLocal` | `#3B82F6` | Child local |
| `governanceGenerated` | `#8B5CF6` | Generated |
| `governanceAppendOnly` | `#FFB800` | Append-only |
| `governanceArchive` | `#6B7280` | Archive |
| `governanceMock` | `#EC4899` | Mock/test |

### 3.5 Text Colors (5 tokens)
| Token | Hex | Usage |
|-------|-----|-------|
| `textPrimary` | `#F0F0F5` | High emphasis |
| `textSecondary` | `#A0A0B0` | Medium emphasis |
| `textTertiary` | `#606070` | Low emphasis |
| `textDisabled` | `#404050` | Disabled |
| `textInverse` | `#0A0A0F` | Light backgrounds |

### 3.6 Border Colors (4 tokens)
| Token | Hex | Usage |
|-------|-----|-------|
| `borderSubtle` | `#1E1E28` | Barely visible |
| `borderDefault` | `#2A2A38` | Default |
| `borderStrong` | `#3A3A4A` | Emphasis |
| `borderGlow` | `#00D4FF` | Energy glow |

### 3.7 Lane Colors (5 tokens)
| Token | Hex | Lane |
|-------|-----|------|
| `lanePlanning` | `#8B5CF6` | 00-planning |
| `laneOpen` | `#3B82F6` | 01-open |
| `laneDoing` | `#FFB800` | 02-doing |
| `laneReview` | `#EC4899` | 03-review |
| `laneCompleted` | `#10B981` | 04-completed |

### 3.8 Asset Kind Colors (9 tokens)
| Token | Hex | Kind |
|-------|-----|------|
| `assetAgent` | `#00D4FF` | agent |
| `assetSkill` | `#8B5CF6` | skill |
| `assetSubskill` | `#A78BFA` | subskill |
| `assetWorkflow` | `#FFB800` | workflow |
| `assetTask` | `#3B82F6` | task |
| `assetChangelog` | `#10B981` | changelog |
| `assetScript` | `#EC4899` | script |
| `assetReference` | `#6B7280` | reference |
| `assetRule` | `#F97316` | rule |

### 3.9 Utility (3 tokens)
| Token | Value |
|-------|-------|
| `transparent` | `Colors.transparent` |
| `white` | `#FFFFFF` |
| `black` | `#000000` |

### 3.10 Lookup Methods
- `DSColors.forAssetKind(String kind)` → Color for asset type
- `DSColors.forLane(String lane)` → Color for task lane
- `DSColors.forCanonicity(String canonicity)` → Color for governance status

---

## 4. Typography Contract

### 4.1 Font Families
| Token | Value | pubspec Status |
|-------|-------|----------------|
| `fontFamilyMono` | `JetBrainsMono` | ✅ Declared in pubspec.yaml |
| `fontFamilySans` | `Inter` | ⚠️ NOT declared in pubspec.yaml |

### 4.2 Font Weights
| Token | Value |
|-------|-------|
| `weightLight` | `w300` |
| `weightRegular` | `w400` |
| `weightMedium` | `w500` |
| `weightSemibold` | `w600` |
| `weightBold` | `w700` |

### 4.3 Type Scale (18 styles)
| Style | Family | Size | Weight | Usage |
|-------|--------|------|--------|-------|
| `displayLarge` | Sans | 48 | Bold | Hero headings |
| `displayMedium` | Sans | 36 | Bold | Section headings |
| `displaySmall` | Sans | 28 | Semibold | Page titles |
| `headingLarge` | Sans | 24 | Semibold | Large headings |
| `headingMedium` | Sans | 20 | Semibold | Medium headings |
| `headingSmall` | Sans | 16 | Semibold | Small headings |
| `bodyLarge` | Sans | 16 | Regular | Primary content |
| `bodyMedium` | Sans | 14 | Regular | Secondary content |
| `bodySmall` | Sans | 12 | Regular | Captions, metadata |
| `labelLarge` | Sans | 14 | Medium | Buttons, labels |
| `labelMedium` | Sans | 12 | Medium | Chips, tags |
| `labelSmall` | Sans | 10 | Medium | Micro labels |
| `codeLarge` | Mono | 14 | Regular | Code blocks |
| `codeMedium` | Mono | 13 | Regular | Inline code |
| `codeSmall` | Mono | 11 | Regular | Compact code |
| `numericLarge` | Mono | 32 | Bold | Big numbers |
| `numericMedium` | Mono | 24 | Semibold | Medium metrics |
| `numericSmall` | Mono | 14 | Medium | IDs, small metrics |

---

## 5. Spacing Contract

### 5.1 Base Scale
| Token | Value | Usage |
|-------|-------|-------|
| `xxs` | 2px | Micro spacing |
| `xs` | 4px | Tight spacing |
| `sm` | 8px | Compact spacing |
| `md` | 12px | Default tight |
| `lg` | 16px | Default comfortable |
| `xl` | 20px | Comfortable |
| `xxl` | 24px | Spacious |
| `xxxl` | 32px | Section spacing |
| `huge` | 48px | Large section |
| `massive` | 64px | Page section |

### 5.2 Semantic Spacing
| Token | Value | Usage |
|-------|-------|-------|
| `insetCard` | 16px | Card padding |
| `insetCardCompact` | 12px | Compact card padding |
| `gapList` | 8px | List item gap |
| `gapListCompact` | 4px | Compact list gap |
| `gapSection` | 24px | Section gap |
| `sidebarCollapsed` | 64px | Collapsed sidebar width |
| `sidebarExpanded` | 240px | Expanded sidebar width |
| `inspectorWidth` | 360px | Inspector panel width |
| `topbarHeight` | 56px | Top bar height |
| `cardMinHeight` | 80px | Card minimum height |
| `iconButtonSize` | 40px | Icon button size |
| `iconButtonSizeCompact` | 32px | Compact icon button |

---

## 6. Radii Contract

| Token | Value | Usage |
|-------|-------|-------|
| `none` | 0 | Sharp edges |
| `xs` | 2px | Subtle rounding |
| `sm` | 4px | Slight rounding |
| `md` | 6px | Default rounding |
| `lg` | 8px | Comfortable rounding |
| `xl` | 12px | Pronounced rounding |
| `xxl` | 16px | Large rounding |
| `full` | 9999px | Circle/pill |
| `card` | 8px | Cards |
| `button` | 6px | Buttons |
| `chip` | 4px | Chips/badges |
| `input` | 6px | Input fields |
| `panel` | 12px | Panels |
| `modal` | 16px | Modals |

---

## 7. Motion Contract

### 7.1 Durations
| Token | Value | Usage |
|-------|-------|-------|
| `instant` | 0ms | No animation |
| `fast` | 100ms | Micro interactions |
| `normal` | 200ms | Standard interactions |
| `slow` | 300ms | Emphasis |
| `slower` | 400ms | Major transitions |
| `slowest` | 500ms | Dramatic reveals |

### 7.2 Curves
| Token | Flutter Curve | Usage |
|-------|--------------|-------|
| `standard` | `easeInOut` | Most interactions |
| `enter` | `easeOut` | Elements appearing |
| `exit` | `easeIn` | Elements disappearing |
| `emphasized` | `easeInOutCubic` | Dramatic transitions |
| `spring` | `elasticOut` | Playful bounce |
| `linear` | `linear` | Constant speed |

### 7.3 Semantic Animations
| Token | Duration | Curve | Usage |
|-------|----------|-------|-------|
| `hoverDuration` | 150ms | `easeOut` | Hover state |
| `focusDuration` | 100ms | `easeOut` | Focus state |
| `pageDuration` | 300ms | `easeInOutCubic` | Page transition |
| `panelDuration` | 250ms | `easeInOut` | Panel expand/collapse |
| `staggerDelay` | 50ms | — | List item stagger |

---

## 8. Shadows Contract

| Token | Type | Usage |
|-------|------|-------|
| `elevation1` | `List<BoxShadow>` | Subtle lift |
| `elevation2` | `List<BoxShadow>` | Cards, panels |
| `elevation3` | `List<BoxShadow>` | Modals, dropdowns |
| `elevation4` | `List<BoxShadow>` | Floating elements |
| `glowCyan({intensity})` | `List<BoxShadow>` | Cyan energy glow |
| `glowViolet({intensity})` | `List<BoxShadow>` | Violet energy glow |
| `glowGold({intensity})` | `List<BoxShadow>` | Gold energy glow |
| `glowSuccess({intensity})` | `List<BoxShadow>` | Success glow |
| `glowError({intensity})` | `List<BoxShadow>` | Error glow |
| `glowWarning({intensity})` | `List<BoxShadow>` | Warning glow |
| `innerShadow` | `BoxDecoration` | Recessed element |

---

## 9. Mismatch Ledger

### 9.1 Resolved (from draft.md)
All mismatches reported in `docs/draft.md` are **RESOLVED** in the current codebase:

| Claim | Actual | Status |
|-------|--------|--------|
| `DsColors` vs `DSColors` | All `DSColors` | ✅ Resolved |
| `DsShell(... body: ...)` | `DSShell(... content: ...)` | ✅ Resolved |
| `DsSidebar` with `selectedIndex` | `DSSidebar` with `selectedId` | ✅ Resolved |
| `DsTopbar` with wrong params | `DSTopbar` with correct params | ✅ Resolved |
| `ds_graph_canvas` missing colors | All colors exist | ✅ Resolved |

### 9.2 Active Gaps

| Issue | Severity | Location | Description |
|-------|----------|----------|-------------|
| **Inter font not declared** | 🟡 Medium | `pubspec.yaml` + `ds_typography.dart` | `DSTypography.fontFamilySans = 'Inter'` but pubspec only declares `JetBrainsMono`. Inter will fall back to system sans-serif. |
| **No `main.dart` entrypoint** | 🔴 Critical | `lib/main.dart` | Flutter app entrypoint missing — prevents compilation |
| **No `test/` directory** | 🟡 Medium | `test/` | No tests exist; contract test created as part of Task 0014 |
| **No `ThemeData` bridge** | 🟡 Medium | `lib/design_system/` | DS tokens are accessed via static constants; no `ThemeExtension` integration for widgets that need `Theme.of(context)` |

### 9.3 Font Contract Decision

The `DSTypography` class references two font families:
- `JetBrainsMono` — ✅ Declared in pubspec.yaml (Regular, Medium/Bold weights)
- `Inter` — ⚠️ NOT declared in pubspec.yaml

**Resolution options** (to be decided in a future task):
1. Add Inter font to `assets/fonts/` and declare in pubspec.yaml
2. Replace `Inter` with `JetBrainsMono` for sans-serif usage (monospace-first design)
3. Use system sans-serif as fallback (current behavior — implicit)

---

## 10. Barrel Export Verification

All barrel exports resolve without circular dependencies:

```
design_system.dart
  → tokens/tokens.dart (7 token files)
  → atoms/atoms.dart (8 atom files)
  → molecules/molecules.dart (8 molecule files)
  → organisms/organisms.dart (8 organism files)
  → templates/templates.dart (1 template file)
```

No duplicate exports. No ambiguous names. All exports use `DS*` prefix consistently.

---

*Report generated by Task 0014 execution. All findings based on direct source file inspection.*
