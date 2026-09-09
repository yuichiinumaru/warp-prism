# Task 1814: Interaction Inventory (Evidence-Driven)

> **Priority**: 🔴 P0 · **Type**: `verification`
> **Origin**: EPIC-20 (S20-01 + S20-04) · Source-Reality Review 2026-09-01
> **Blocks**: Task 1815
> **Depends on**: None (root task)

## Milestone Alignment

- **Target milestone**: M01 — Warp Prism v2: L1 Integration-Capable (`docs/milestones.md`)
- **Capability / Gate advanced**: 20-A interaction inventory (the evidence input for the IDS kernel)
- **Strategic why**: the IDS kernel (1815) may only admit recurrence-backed primitives; without this inventory the kernel would encode planning hypotheses instead of source evidence.
- **Consequence if absent**: 1815 has no evidence floor; primitives without ≥2 consumers/domains would enter the kernel by name only.

## Non-Goals

- **Do not**: implement any IDS model, kernel code, or package — this is an inventory/read-only task; implementation belongs to Task 1815.
- **Do not**: modify components or organisms — reading them for evidence is in scope, mutation is not.
- **Do not**: force primitives without recurrence evidence into the kernel; they stay in the candidate ledger.

## Objective

Produce an evidence-driven inventory of interaction patterns across `warp_prism_ui` to determine which primitives (Selection, Inspection, Command-intent, Query, Navigation, Viewport) have recurrence evidence (≥2 distinct consumers OR 2 distinct domains) — the input for the IDS candidate kernel (Task 1815).

## Background Context

### What already exists

- `DSInteractiveSurface` = per-widget mechanics only (focus, keyboard, semantics, cursor, touch target) — no reusable semantic state (`ds_interactive_surface.dart:16-145`).
- Selection state is ad-hoc: >100 `selected` usages, 10+ bespoke callback patterns (`onNodeTap`, `onEdgeSelected`, `onSelectionChanged`, `onCellSelected`, `onEntryTap`, `onSelect`, `onSelected`, `onLocate`, `onSectionToggled`, `onExpandedIndicesChanged`).
- Only `DSWorkflowSelection` is a dedicated selection payload class (`ds_workflow_canvas_stage.dart:370-402`).
- GraphCanvas selection = local `_selectedNodeId` state; LogViewer = `_expandedIds`; ExecutionConsole = `_uncontrolledSelectedId`; DataTable = `_selectedIds`.

### What is missing or broken

- No shared selection/inspection model exists.
- No inventory of which interaction patterns recur across components.
- IDS kernel primitives were hypothesized in planning but not validated against actual code.

## Subtasks

- [ ] **Read before modifying**: `ds_interactive_surface.dart`, `graph_canvas.dart`, `workflow_canvas_stage.dart`, `log_viewer.dart`, `execution_console.dart`, `data_table.dart`, `status_ticker.dart`.
- [ ] **Inventory selection/inspection patterns**: for each component, record: component name, selection state location (local/prop/shared), callback pattern, domain.
- [ ] **Classify recurrence**: which patterns appear in ≥2 distinct consumers OR ≥2 distinct domains?
- [ ] **Counter-examples**: document ≥4 near-miss patterns that belong in Runtime or App domain, not IDS.
- [ ] **Output**: create `docs/architecture/interaction-inventory.md` with evidence table + recurrence verdict per candidate primitive.
- [ ] **Simplify pass**: remove unnecessary complexity.
- [ ] **Regression verification**: run validation commands.

## Validation Commands

```bash
grep -E "Selection|Inspection|Command-intent|Query|Navigation|Viewport" docs/architecture/interaction-inventory.md
flutter analyze packages/warp_prism_ui
```

## Where

| File | Purpose |
|---|---|
| `docs/architecture/interaction-inventory.md` | Create — evidence table + recurrence verdict per candidate primitive |

## Exit Conditions

- [ ] Inventory covers all major organisms/atoms with selection/inspection behavior.
- [ ] Recurrence verdict per primitive: evidence count + domains.
- [ ] Counter-examples documented (≥4 near-misses mapped to correct home).
- [ ] Primitives without recurrence evidence explicitly deferred (not forced into kernel).
- [ ] Local changelog entry added.

## Completion Evidence

- **Files created/modified**: `docs/architecture/interaction-inventory.md` (created: 156 lines, 35 evidence rows — 31 component rows §1 + 4 selection-payload rows §1.1; 6 counter-examples; §7 admission contract). ZERO source files modified (read-only audit).
- **Key evidence**: ~40 files read; sweep covered gallery sections, all task-named organisms + 20 additional components (accordion, select, tree, sidebar, breadcrumbs, timeline, tab_bar, command_palette, entity panels, map_canvas_stage, provider_health_matrix, traffic_inspector, timing_waterfall, osint_workbench, ops_control_cluster, artifact_workbench, view_presets, filter chips, status_grid, terminal_workspace, virtual_scroll, time_machine_scrubber, master_detail) + app consumers (observatory, cybercore, catalog).
- **Per-primitive verdicts**: Selection RECURRENCE_PROVEN (20+ impls, 3 state locations, 4 payload classes, 3 app domains); Inspection RECURRENCE_PROVEN (6 impls, observatory ×5 + gallery); **Query RECURRENCE_PROVEN (6+ impls, cybercore + observatory + gallery — 2+ distinct domains)**; Command-intent DEFERRED (3 divergent shapes, gallery-only, 0 app adoption); Navigation-intent DEFERRED (reduces to Selection + app routing); Viewport-state DEFERRED (3 unrelated mechanics).
- **Source-reality corrections recorded (doc §6)**: DSInteractiveSurface lives in `molecules/` not `atoms/interactive_surface/`; **4** dedicated selection payload classes exist (DSWorkflowSelection, DSMcpCapabilitySelection, DSMapStageSelectionEvent, DSEntitySelection), not 1; ExecutionConsole has controller-owned state; callback-pattern count 20+.
- **Tests or validation commands**: greps → 34 / 3 / 4 / 43 / 156 lines; `dart run test/boundaries/boundary_test.dart` → **8/8 PASS, 0 FAIL** (confirms zero lib/ drift from read-only audit)
- **Local changelog entry**: pending parent publication
- **Executor**: gt-architects-architect-general (builder session, 2026-09-01)
- **Completion date**: 2026-09-01
- **Residual risks**: gallery treated as demo domain (conservative read — gallery-only recurrences deferred); gallery file:line anchors age fastest; `.orig` file observed in lib/ (out-of-scope hygiene item)
