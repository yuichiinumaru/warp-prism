---
date: 20260608-213315
timestamp: 20260608-213315
agent: repair-bot
task: "1043"
description: "Changelog — Task 1112: Data Table Component"
is_rebuild_safe: true
---

# Changelog — Task 1112: Data Table Component

> **Date**: 2026-06-08
> **Task**: 1112 — Warp Prism Data Table Component
> **Type**: feature · design-system

## Summary

Implemented `DSDataTable`, a reusable sortable, paginated, virtualized data
table organism for `warp_prism_ui`. Covers all CyberCore list screens (MCP
server registry, capabilities, providers, policies, users, audit events,
credentials, exposures, tools).

## Files Created

| File | Purpose |
|------|---------|
| `packages/warp_prism_ui/lib/src/organisms/data_table/ds_data_table.dart` | Main table organism with column config, row data, sort, pagination, cell renderers, virtual scroll. |
| `packages/warp_prism_ui/test/organisms/data_table/ds_data_table_test.dart` | 35 widget tests covering sort, filter, pagination, cell renderers, empty/loading/error states, selection, barrel exports. |

## Files Modified

| File | Change |
|------|--------|
| `packages/warp_prism_ui/lib/src/organisms/organisms.dart` | Added `export 'data_table/ds_data_table.dart'` to barrel. |
| `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart` | Added `buildDataTableSection()` catalog entry. |

## API Surface

### Core Widgets
- `DSDataTable` — main table organism (sortable, paginated, virtual scroll)
- `DSTablePagination` — pagination controls with page size selector

### Configuration
- `DSDataColumn` — column definition (id, label, sortable, visible, width, cellRenderer)
- `DSDataRow` — row data (id, cells map, selectable, selected, onTap)
- `DSSortState` / `DSSortDirection` — sort state management

### Cell Renderers
- `DSStatusCell` — operational state dot + label (uses canonical `DSOperationalState`)
- `DSBadgeCell` — count badge
- `DSTimestampCell` — monospace timestamp
- `DSSecretCell` — masked/reveal value
- `DSActionsCell` / `DSActionItem` — action icon buttons

### Reuses (not created)
- `DSOperationalState` — 15-state enum from `tokens/ds_operational_state.dart`
- `DSOperationalStateUI` — color/icon/label extension from same
- `DSStateSurface` — empty/loading/error state surface
- `DSGlassPanelSimple` — glass panel styling
- `DSStatusDot`, `DSBadge`, `DSText`, `DSIcon` — existing atoms

## Test Results

- 35 tests passing (data table specific)
- 0 new errors introduced
- All pre-existing tests unaffected
