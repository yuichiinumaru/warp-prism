# EPIC 17 — Warp Prism ADS: Form Primitives Gap

> **Planning Status**: Active Epic  
> **Executable?**: No — planning artifact only. Executable work lives as `Task 17NN` under task lanes.  
> **Promotion Gate**: After EPIC-16 gallery/catalog capacity is verified. Can start P0 tasks in parallel with EPIC-16 closeout since they are different layers (form primitives vs. organisms).  
> **Origin**: 2026-07-24 — Deep gap audit (`cybernetics-core-frontend/docs/reports/05-deep-gap-audit-frontend-vs-ads.md`) revealed that `warp_prism_ui` has zero form interaction primitives despite being a comprehensive ADS with 9 atoms, 21 molecules, and 44+ organisms.
> **Depends on**: EPIC-01 (ADS foundation), EPIC-13 (Prism barrel / public contract). Soft-depends EPIC-16 (gallery registration capacity).  
> **Related**: `cybernetics-core-frontend/docs/tasks/00-planning/EPICS-OVERVIEW.md` — EPIC-003 (Gap Widgets) was originally scoped in the frontend but has been **migrated here** per the fundamental rule: "NÃO CRIAMOS componentes no frontend; tudo via ADS Warp-Prism."

---

## Goal

Fill the **form interaction primitive** gap in `warp_prism_ui`. The ADS currently has comprehensive data-display organisms (DataTable, LogViewer, StatusGrid, Timeline, LaneBoard, GraphCanvas, CommandPalette, etc.) but **zero form input widgets**. A CyberNetics Core admin frontend requires buttons, text fields, selects, checkboxes, toggles, dialogs, breadcrumbs, and accordions to function.

All components must follow the existing Warp-Prism visual language:
- Ultradark obsidian glass aesthetic (`DSColors.obsidian*` background, `DSGlassPanel` surfaces)
- `DSGlowBorder`/`DSGlowDivider` for interactive focus emphasis
- `DSInteractiveSurface` keyboard/focus contract (48×48 target, Enter/Space activation, focus ring)
- `DSCyberCoreTealSkin` accent (`#00FFCC`) for active/checked states
- `DSTypography` + `DSSpacing` + `DSRadii` tokens for consistency
- Dark-only (no light theme variant needed at this stage)

**Constraint**: form primitives first, composable into molecules. These are the foundation that blocks the CyberCore frontend's EPIC-005 (Providers CRUD forms) and EPIC-006 (Settings forms, accordion, breadcrumbs).

---

## Source Evidence

| Artifact | Path |
| --- | --- |
| Deep gap audit | `cybernetics-core-frontend/docs/reports/05-deep-gap-audit-frontend-vs-ads.md` (356 lines) |
| Atoms/molecules inventory | `cybernetics-core-frontend/docs/reports/03-warp-prism-atoms-molecules-inventory.md` (1553 lines) |
| Organisms/tokens inventory | `cybernetics-core-frontend/docs/reports/04-warp-prism-organisms-tokens-inventory.md` (960 lines) |
| OmniRoute-2 collapsible patterns | `cybernetics-core-frontend/docs/reports/02-omniroute2-collapsible-menu-patterns.md` (452 lines) |
| OmniRoute-2 sidebar/topbar IA | `cybernetics-core-frontend/docs/reports/01-omniroute2-sidebar-topbar-ia-analysis.md` (872 lines) |
| Public barrel / aliases | `packages/warp_prism_ui/lib/warp_prism_ui.dart`, `lib/src/prism_aliases.dart` |
| Gallery / catalog | `lib/src/gallery/`, `apps/catalog/` |
| Frontend EPIC-003 (migrated) | `cybernetics-core-frontend/docs/tasks/01-open/0018-0024` (spec source for P0 tasks) |

### Confirmed missing (grep evidence from gap audit)

```
grep -n "PrismButton\|DSTextField\|PrismSelect\|PrismDropdown\|PrismCheckbox\|PrismSwitch\|PrismDialog\|PrismModal" prism_aliases.dart
→ No matches (confirming gaps)

grep -n "PrismBreadcrumbs\|DSBreadcrumbs" prism_aliases.dart
→ No matches (confirming gap)

grep -n "PrismAccordion\|PrismCollapsible\|PrismExpandPanel" prism_aliases.dart
→ No matches (confirming gap)
```

### Confirmed EXISTS (not a gap)

| Component | Location | Alias |
| --- | --- | --- |
| `PrismMarkdownRenderer` | `lib/src/organisms/markdown_renderer/ds_markdown_renderer.dart` | `typedef PrismMarkdownRenderer = DSMarkdownRenderer` — **exists, no gap** |
| `PrismDataTable` | `lib/src/organisms/data_table/` | exists |
| `PrismLogViewer` | `lib/src/organisms/log_viewer/` | exists |
| `PrismCommandPalette` | `lib/src/organisms/command_palette/` | exists |
| `PrismTabBar` | `lib/src/organisms/tab_bar/` | exists |
| `PrismStatusGrid` | `lib/src/organisms/status_grid/` | exists |

---

## Scope

### In scope
- 8 P0 form primitives (blocks frontend EPIC-005/006)
- 5 P1 interaction primitives (needed for later frontend phases)
- 4 P2 latent primitives (not immediately blocking, catalog for future)
- Gallery registration for all new components
- Public barrel export updates
- Widget tests (golden + interaction)

### Out of scope
- Light theme support (dark-only for now)
- `flutter_markdown` dependency (PrismMarkdownRenderer already exists)
- Porting React/shadcn patterns literally (translate to Flutter/Dart idioms)
- Rebranding or restyling existing organisms

---

## Candidate Executable Tasks

### Wave 1: P0 — Critical (blocks frontend EPIC-005 and EPIC-006)

| Task | Component | Layer | Spec Source | Blocks |
| --- | --- | --- | --- | --- |
| 1700 | `PrismButton` | Atom | Report 03 §3.1 (DSInteractiveSurface), Report 05 §1 (gap confirmed), Frontend Task 0018 | Frontend 0036, 0044 |
| 1701 | `PrismTextField` | Atom | Report 03 §3.2 (DSSearchBar embeds text input), Report 05 §1, Frontend Task 0019 | Frontend 0036 |
| 1702 | `PrismSelect` / `PrismDropdown` | Molecule | Report 05 §1, Frontend Task 0020 | Frontend 0036, 0044 |
| 1703 | `PrismCheckbox` | Atom | Report 05 §1, Frontend Task 0021 | Frontend 0044 |
| 1704 | `PrismSwitch` / `PrismToggle` | Atom | Report 05 §1, Frontend Task 0022 | Frontend 0044 |
| 1705 | `PrismDialog` / `PrismModal` | Molecule | Report 03 §2.8 (DSGlassPanel.modal), Report 05 §1, Frontend Task 0023 | Frontend 0036 |
| 1706 | `PrismBreadcrumbs` | Organism | Report 01 §6 (breadcrumbs), Report 05 §2 (gap confirmed), Frontend Task 0047 | Frontend 0047 |
| 1707 | `PrismAccordion` / `PrismCollapsible` | Molecule | Report 02 (25 collapsible patterns), Report 05 §2, Frontend Tasks 0043, 0044 | Frontend 0043, 0044 |

### Wave 2: P1 — Important (needed for later frontend phases)

| Task | Component | Layer | Spec Source |
| --- | --- | --- | --- |
| 1708 | `PrismTooltip` | Atom | hover/focus tooltip with glass panel, delay, position |
| 1709 | `PrismPopover` | Molecule | popover with anchor, glass panel content, dismiss |
| 1710 | `PrismContextMenu` | Molecule | right-click context menu |
| 1711 | `PrismBottomSheet` | Organism | slide-up sheet for mobile actions |
| 1712 | Gallery registration for all P0+P1 | — | catalog page entries in `lib/src/gallery/` |

### Wave 3: P2 — Latent (not immediately blocking)

| Task | Component | Layer | Spec Source |
| --- | --- | --- | --- |
| 1713 | `PrismSlider` | Atom | range slider with cyan accent |
| 1714 | `PrismRadioGroup` | Atom | radio button group |
| 1715 | `PrismDatePicker` | Molecule | date picker with glass calendar |
| 1716 | `PrismMultiSelect` | Molecule | multi-select with chip display |

### Warehouse

| Task | Description |
| --- | --- |
| 1717 | Widget tests for all gap components (golden + interaction) |
| 1718 | Public barrel export update (`warp_prism_ui.dart` + `prism_aliases.dart`) |

---

## Dependency Chain (critical path to unblock frontend)

```
EPIC-17 Wave 1 (1700-1707) ──┐
                              ├──→ Frontend EPIC-005 Task 0036 (provider create/edit form)
                              │    needs: PrismButton(1700), PrismTextField(1701),
                              │           PrismSelect(1702), PrismDialog(1705)
                              │
                              ├──→ Frontend EPIC-006 Task 0044 (settings forms)
                              │    needs: PrismButton(1700), PrismTextField(1701),
                              │           PrismSelect(1702), PrismCheckbox(1703),
                              │           PrismSwitch(1704), PrismAccordion(1707)
                              │
                              ├──→ Frontend EPIC-006 Task 0043 (operations endpoint)
                              │    needs: PrismAccordion(1707)
                              │
                              ├──→ Frontend EPIC-006 Task 0047 (breadcrumbs)
                              │    needs: PrismBreadcrumbs(1706)
                              │
                              └──→ Frontend Task 0018-0024 (EPIC-003)
                                   MIGRATED — these frontend tasks are now
                                   DEPRECATED in favor of EPIC-17 tasks 1700-1707
```

---

## Guardrails

> [!CAUTION]
> **Do not** create components in the CyberCore frontend `lib/shared/`. The fundamental rule: all components must exist in the ADS first. Frontend EPIC-003 tasks (0018-0024) are **DEPRECATED** — they are replaced by EPIC-17 tasks (1700-1707).

> [!CAUTION]
> **Do not** add `flutter_markdown` as a dependency. `PrismMarkdownRenderer` already exists at `lib/src/organisms/markdown_renderer/`. Confirmed via `prism_aliases.dart` line 1221.

> **Confirm** `DSTabBar` supports a `variant="subnav"` style for settings tabs. If not, add a style variant rather than a new component.

> **Confirm** existing `DSGlassPanel` variants (subtle/elevated/modal) before building `PrismDialog` — `modal()` constructor may already provide most of what's needed.
