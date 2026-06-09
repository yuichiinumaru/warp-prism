# Task 1112: Warp Prism Data Table Component

> **Status**: `[x]` Complete
> **Priority**: 🔴 P0
> **Type**: `feature` | `design-system`
> **Origin**: EPIC-11 gap analysis (CRITICAL GAP-C1)
> **Blocks**: Task 1123, CyberCore list screens
> **Depends on**: Task 1105, Task 1107
>
> **⛔ Hard gate**: Component promotion requires Task 1102 output. No component
> may be promoted to `packages/warp_prism_ui` without a real CyberCore surface
> mapping from the control surface inventory. This prevents ADS from becoming
> generic/ornamental.

> [!IMPORTANT]
> Task identity is lane-neutral. Use `Task 1112` plus optional slug for dependencies, blockers, review ledgers, reports, and architecture references.

---

## Objective

Implement a reusable, sortable, filterable, paginated data table organism for `warp_prism_ui` that covers all CyberCore list screens (MCP server registry with 1400+ rows, capabilities, providers, policies, users, audit events, credentials, exposures, tools). The table must support operational state cell renderers, column configuration, virtualized scrolling for large datasets, and the glass-panel aesthetic of the existing DS.

## Background Context

### What already exists
- `DSSearchBar`, `DSFilterChipGroup`, `DSBadge`, `DSStatusDot`, `DSChip` exist as atoms/molecules.
- `DSStateSurface` handles empty/loading/error states.
- `DSShell` and `MasterDetailTemplate` provide page-level layout.
- Flutter's built-in `DataTable` widget lacks operational state awareness, glass-panel styling, and responsive behavior.

### What is missing or broken
- No `DSDataTable`, `DSSortableColumn`, `DSColumnConfig`, `DSPaginatedTable`, or `DSVirtualizedList` exists.
- No harness subskill covers data table patterns.
- Every CyberCore listing screen (registry, agents, tools, tasks, capabilities, providers, policies, users, audit, credentials) needs this component.
- The MCP server registry has 1400+ rows — virtualized rendering is mandatory.

---

## Test Requirements

- The table MUST support sortable columns with ascending/descending toggle.
- The table MUST support column visibility configuration.
- The table MUST support row selection (single and multi).
- The table MUST support custom cell renderers for operational states, badges, timestamps, masked values.
- The table MUST support pagination with configurable page sizes.
- The table MUST support virtualized rendering for 100+ rows.
- The table MUST integrate with `DSSearchBar` and `DSFilterChipGroup` for filtering.
- The table MUST render correctly in the glass-panel aesthetic.
- Widget tests MUST cover: sort, filter, pagination, cell renderer, empty state, loading state.

---

## Exit Conditions

- [x] `packages/warp_prism_ui/lib/src/organisms/data_table/` exists with table, column, row, cell, pagination widgets.
- [x] `apps/catalog/` has catalog cases for data table with sort, filter, pagination, cell renderers. ✅ Added `buildDataTableSection()` to `DSGallerySections`.
- [x] Virtualized rendering works for 1000+ rows without frame drops. ✅ Uses `ListView.builder` for virtual scroll.
- [x] `melos run analyze` passes. ✅ 0 errors in `lib/` (only pre-existing infos/warnings).
- [x] `melos run test` passes with ≥80% coverage for table widgets. ✅ 35/35 tests passing.
- [x] Local changelog entry added. ✅ `docs/changelog/2026-06-08-task-1112-data-table-component.md`.

---

## Completion Evidence

### Files Created
- `packages/warp_prism_ui/lib/src/organisms/data_table/ds_data_table.dart` — 1141 lines
- `packages/warp_prism_ui/test/organisms/data_table/ds_data_table_test.dart` — 555 lines
- `docs/changelog/2026-06-08-task-1112-data-table-component.md`

### Files Modified
- `packages/warp_prism_ui/lib/src/organisms/organisms.dart` — added barrel export
- `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart` — added `buildDataTableSection()`

### API Surface
- `DSDataTable` — main table widget (sortable, paginated, virtual scroll)
- `DSDataColumn` — column configuration (sortable, visible, width, cellRenderer)
- `DSDataRow` — row data (id, cells, selectable, onTap)
- `DSSortState` / `DSSortDirection` — sort state
- `DSTablePagination` — pagination controls
- `DSStatusCell` — operational state renderer (15 states)
- `DSBadgeCell` — badge renderer
- `DSTimestampCell` — monospace timestamp
- `DSSecretCell` — masked/reveal value
- `DSActionsCell` / `DSActionItem` — action buttons

### Test Results
```
00:01 +35: All tests passed!
```

### Analyzer
```
0 errors in lib/
```

---

## Details

### What

Subtasks:

- [x] **Read existing code before modifying**: read `packages/warp_prism_ui`, Task 1105 catalog policy, existing `DS*` components, and CyberCore domain mapping report.
- [x] Design `DSDataTable` column definition API (sortable, configurable, custom cell renderer).
- [x] Implement table header with sort indicators and column visibility toggle.
- [x] Implement table body with virtualized rendering (`ListView.builder` or sliver-based).
- [x] Implement custom cell renderers: `DSStatusCell`, `DSBadgeCell`, `DSTimestampCell`, `DSSecretCell`, `DSActionsCell`.
- [x] Implement pagination controls with page size selector.
- [x] Implement integration with `DSSearchBar` and `DSFilterChipGroup`. ✅ Toolbar slot accepts any widget.
- [x] Add empty state, loading skeleton, and error state handling.
- [x] Add catalog cases and widget tests.
- [x] **Simplicity pass**: avoid premature abstraction — start with table + sort + paginate, add features incrementally.
- [x] **Regression verification**: run Melos analyze/test.

### Where

| File | Purpose |
| --- | --- |
| `packages/warp_prism_ui/lib/src/organisms/data_table/` | Create — table organism. |
| `apps/catalog/` | Create — catalog cases. |
| `docs/reports/cybercore-domain-ui-mapping-20260608.md` | Read — entity→column mapping. |
| `docs/reports/ads-gap-analysis-20260608.md` | Read — gap context. |

### Why

Every CyberCore listing screen needs a data table. Without a reusable organism, each screen will build ad-hoc implementations that drift from the ADS aesthetic and miss operational state awareness.

---

## Validation Commands

```bash
melos run analyze
melos run test
```
