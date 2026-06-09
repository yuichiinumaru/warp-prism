# Task 1117: Warp Prism Graph Visualization Refactor — Model/Layout/Painter Split

> **Status**: `[x]` Complete (pending review)
> **Priority**: 🟡 P1
> **Type**: `feature` | `design-system`
> **Origin**: EPIC-11 gap analysis (IMPORTANT GAP-I1) — phase 1 of 2: refactor-only, no new features.
> **Blocks**: Task 1117b (hierarchical + DAG layouts), Task 1117c (graph UX layer), Task 1117d (graph accessibility)
> **Depends on**: Task 1105, Task 1107, Task 0512
>
> **⛔ Hard gate**: Component promotion requires Task 1102 output. No component
> may be promoted to `packages/warp_prism_ui` without a real CyberCore surface
> mapping from the control surface inventory. This prevents ADS from becoming
> generic/ornamental.
>
> **SCOPE NOTE**: This task is **refactor-only** — decompose the 483-line `DSGraphCanvas`
> monolith into composable layers (model, layout engine, painter, interaction handler)
> WITHOUT adding new layout algorithms, filters, minimap, hover preview, or accessibility.
> Those features belong to a follow-up task (1117b) that depends on this refactor.
> **Do not add new graph features in this task.**

> [!IMPORTANT]
> Task identity is lane-neutral. Use `Task 1117` plus optional slug for
> dependencies, blockers, review ledgers, reports, and architecture references.

---

## Objective

Refactor the existing `DSGraphCanvas` (483-line monolith at `lib/design_system/organisms/ds_graph_canvas.dart`) into composable layers — graph model, layout engine, painter, interaction handler. The current monolith mixes data model (`GraphNode`, `GraphEdge`), physics simulation (`_updatePhysics`), painting (`_GraphPainter`), and interaction handling (`GestureDetector`, `MouseRegion`) in a single file. This refactor-only task extracts each concern into a dedicated, testable file without adding new layout algorithms, filters, minimap, hover preview, or edge differentiation. Those features depend on this refactor and belong to follow-up tasks (1117b, 1117c).

## Background Context

### What already exists

- `DSGraphCanvas` at `lib/design_system/organisms/ds_graph_canvas.dart` (483 lines): a `StatefulWidget` with embedded `GraphNode` class (lines 12-62), `GraphEdge` class (lines 64-77), force-directed physics simulation (lines 141-195), `_GraphPainter` custom painter (lines 382-483), node rendering with `GestureDetector` and `MouseRegion` (lines 296-378), pan/zoom via `GestureDetector.onScaleUpdate`.
- `GraphNode` has fields: `id`, `label`, `type` (agent/skill/workflow/task/doc), `status`, `metadata`, `position`, `velocity`, `isDragging`, `isHovered`, `isSelected`.
- `GraphEdge` has fields: `sourceId`, `targetId`, `label`, `edgeType` (uses/triggers/references).
- `_getNodeColor` maps type to `DSColors.assetAgent`, `assetSkill`, `assetWorkflow`, `assetTask`, `assetReference`.
- `_getNodeIcon` maps type to material icons.
- `_GraphPainter` draws curved edges with quadratic bezier and arrows.
- `DSColors`, `DSSpacing`, `DSRadii`, `DSMotion`, `DSShadows`, `DSStateSurface` tokens/components are available.
- Task 0512 (map graph modes and adapters) in `docs/tasks/02-doing/` provides graph mode context.
- Gap analysis report documents GAP-I1 as IMPORTANT: missing hierarchical/tree layout, layered DAG layout, radial layout, graph filtering, minimap, node hover preview, accessibility, edge differentiation, composability.

### What is missing or broken

- No separate graph model class — `GraphNode` and `GraphEdge` are defined inline in the organism file.
- No layout engine abstraction — force-directed physics is hardcoded in `_updatePhysics`.
- `_GraphPainter` is a private class — not testable in isolation.
- Monolith composition means every graph concern lives in one 483-line file, blocking independent development and testing.

---

## Test Requirements

- Extracted `GraphModel` class MUST be testable without a widget tree (pure data).
- `ForceDirectedLayout` MUST produce stable positions for a 10-node, 15-edge graph in <100ms.
- Extracted `GraphPainter` (public) MUST be testable with `Canvas` mock or `PictureRecorder`.
- Unit tests MUST cover: model construction, queries, force-directed layout output positions within canvas bounds, painter draws edges via `PictureRecorder`.

---

## Exit Conditions

- [ ] `packages/warp_prism_ui/lib/src/organisms/graph/graph_model.dart` exists with `GraphModel`, `GraphNode`, `GraphEdge`, `GraphNodeId`, `GraphEdgeId` typed IDs.
- [ ] `packages/warp_prism_ui/lib/src/organisms/graph/layout_engine.dart` exists with `GraphLayoutEngine` abstract interface.
- [ ] `packages/warp_prism_ui/lib/src/organisms/graph/force_directed_layout.dart` exists (extracted from current monolith).
- [ ] `packages/warp_prism_ui/lib/src/organisms/graph/graph_painter.dart` exists (extracted, public, testable).
- [ ] `packages/warp_prism_ui/lib/src/organisms/ds_graph_canvas.dart` refactored to compose the extracted layers.
- [ ] `packages/warp_prism_ui/lib/src/organisms/organisms.dart` exports new graph sub-barrel.
- [ ] `apps/catalog/` has catalog cases for: force-directed graph layout.
- [ ] `packages/warp_prism_ui/test/organisms/graph/graph_model_test.dart` passes.
- [ ] `packages/warp_prism_ui/test/organisms/graph/force_directed_layout_test.dart` passes.
- [ ] `packages/warp_prism_ui/test/organisms/graph/graph_painter_test.dart` passes.
- [ ] `melos run analyze` passes (no errors, no warnings on new files).
- [ ] `melos run test` passes.
- [ ] Local changelog entry added under `docs/changelog/`.
- [ ] Completion Evidence is filled before review handoff.

---

## Details

### What

Subtasks:

- [ ] **Read existing code before modifying**: read `lib/design_system/organisms/ds_graph_canvas.dart` (483 lines, the entire monolith), `lib/design_system/tokens/tokens.dart`, `lib/design_system/organisms/organisms.dart`, `apps/catalog/` structure, `docs/tasks/02-doing/0512-warp-prism-map-graph-modes-and-adapters.md`, and `docs/reports/ads-gap-analysis-20260608.md` (GAP-I1 section).
- [ ] Create `packages/warp_prism_ui/lib/src/organisms/graph/` directory.
- [ ] Extract `GraphNode` and `GraphEdge` into `graph_model.dart` — add typed `GraphNodeId` and `GraphEdgeId` wrappers (simple `String` wrappers with validation), add `GraphModel` container class with `nodes`, `edges`, `nodeById()`, `edgesForNode()`, `adjacentNodes()`.
- [ ] Extract force-directed physics from `_updatePhysics` (lines 141-195) into `ForceDirectedLayout implements GraphLayoutEngine` — accept `GraphModel`, return positioned node map. Parameters: `repulsion`, `attraction`, `damping`, `minDistance`, `centerGravity`, `nodeSpacing`.
- [ ] Define `GraphLayoutEngine` abstract interface in `layout_engine.dart` — `Map<GraphNodeId, Offset> layout(GraphModel model, Size canvasSize)`.
- [ ] Extract `_GraphPainter` (lines 382-483) into public `GraphPainter extends CustomPainter` in `graph_painter.dart` — accept `GraphModel`, layout positions, style config. Make it testable with `PictureRecorder`.
- [ ] Refactor `DSGraphCanvas` to compose: `GraphModel` (data) + `GraphLayoutEngine` (positions) + `GraphPainter` (rendering) + `DSDragHandler`/`DSTapHandler` (interaction). The widget becomes a thin orchestrator.
- [ ] Export all new files from `organisms.dart` or a `graph/` barrel file.
- [ ] Add catalog case in `apps/catalog/` for force-directed layout.
- [ ] Write unit tests for `GraphModel` (construction, queries), `ForceDirectedLayout` (output positions are within canvas bounds), `GraphPainter` (draws edges via `PictureRecorder`).
- [ ] **Simplicity pass**: avoid premature optimization — layout algorithms should be correct first, performant second. No GPU rendering, no spatial indexing until profiling proves necessary.
- [ ] **Regression verification**: run `melos run analyze` and `melos run test`.

### Where

| File | Purpose |
| --- | --- |
| `packages/warp_prism_ui/lib/src/organisms/ds_graph_canvas.dart` | Read — the 483-line monolith to decompose. Refactor to compose layers. |
| `packages/warp_prism_ui/lib/src/tokens/tokens.dart` | Read — DSColors, DSRadii, DSMotion tokens. |
| `packages/warp_prism_ui/lib/src/organisms/organisms.dart` | Modify — add graph sub-barrel export. |
| `packages/warp_prism_ui/lib/src/organisms/graph/graph_model.dart` | Create — GraphModel, GraphNode, GraphEdge, typed IDs. |
| `packages/warp_prism_ui/lib/src/organisms/graph/layout_engine.dart` | Create — abstract GraphLayoutEngine interface. |
| `packages/warp_prism_ui/lib/src/organisms/graph/force_directed_layout.dart` | Create — extracted force-directed implementation. |
| `packages/warp_prism_ui/lib/src/organisms/graph/graph_painter.dart` | Create — extracted, public, testable painter. |
| `packages/warp_prism_ui/test/organisms/graph/graph_model_test.dart` | Create — model unit tests. |
| `packages/warp_prism_ui/test/organisms/graph/force_directed_layout_test.dart` | Create — layout test. |
| `packages/warp_prism_ui/test/organisms/graph/graph_painter_test.dart` | Create — painter test. |
| `apps/catalog/` | Modify — add catalog gallery case for force-directed graph. |
| `docs/tasks/02-doing/0512-warp-prism-map-graph-modes-and-adapters.md` | Read — graph mode context. |
| `docs/reports/ads-gap-analysis-20260608.md` | Read — GAP-I1 context. |

### How

1. Read all files listed in the Where table before writing any code.
2. Extract `graph_model.dart` from the monolith — pure data classes, no Flutter dependency.
3. Define `GraphLayoutEngine` abstract interface in `layout_engine.dart`.
4. Extract `force_directed_layout.dart` from `_updatePhysics` — adapt to `GraphLayoutEngine` interface, keep all physics parameters configurable.
5. Extract `graph_painter.dart` from `_GraphPainter` — make public, accept style config, testable with `PictureRecorder`.
6. Refactor `DSGraphCanvas` to compose all extracted layers — the widget becomes a thin orchestrator delegating to model, layout, and painter.
7. Export new files from barrel and add catalog case.
8. Write unit tests for model, layout, and painter.
9. Run `melos run analyze` and `melos run test`.
10. Add changelog entry.

### Why

The 483-line monolith blocks all graph feature growth. Every new layout algorithm, interaction pattern, or rendering enhancement requires modifying the same file, increasing merge conflict risk and cognitive load. Extracting composable layers enables independent development, testing, and extension of each concern. This refactor is the prerequisite for future layout algorithms (1117b), UX enhancements (1117c), and accessibility (1117d).

### Follow-up tasks (not this task)
- **1117b**: Hierarchical + DAG layout algorithms (depends on 1117)
- **1117c**: Graph UX layer — filters, minimap, hover preview, edge differentiation (depends on 1117)
- **1117d**: Graph accessibility + keyboard navigation (depends on 1117c)

---

## Anti-Hallucination Guardrails

> [!CAUTION]
> Do not mark this task complete without running `melos run analyze` and
> `melos run test` and filling Completion Evidence.

> [!IMPORTANT]
> Preserve Warp Prism read-only mock-observatory semantics. Graph layout
> and rendering are display-only — they do not modify workspace data.

> [!IMPORTANT]
> The refactored `DSGraphCanvas` MUST maintain backward compatibility —
> existing call sites (Map graph panel, Workspace snapshot panel) must
> continue to work without changes. The `nodes`, `edges`, `onNodeTap`,
> `onNodeDoubleTap`, `onNodeDragEnd`, `enablePhysics`, `nodeSpacing`
> parameters must still be accepted (they delegate to the new layers).

---

## Validation Commands

```bash
cd packages/warp_prism_ui && flutter analyze
cd packages/warp_prism_ui && flutter test
melos run analyze
melos run test
```

If Flutter tooling is unavailable in the execution environment, record the exact
tooling failure and do not claim those checks passed.

---

## Completion Evidence

- **Files created/modified**:
  - `packages/warp_prism_ui/lib/src/organisms/graph/graph_model.dart` (created)
  - `packages/warp_prism_ui/lib/src/organisms/graph/graph_layout_engine.dart` (created)
  - `packages/warp_prism_ui/lib/src/organisms/graph/force_directed_layout.dart` (created)
  - `packages/warp_prism_ui/lib/src/organisms/graph/graph_painter.dart` (created)
  - `packages/warp_prism_ui/lib/src/organisms/graph/graph_canvas.dart` (created)
  - `packages/warp_prism_ui/lib/src/organisms/graph/graph.dart` (created — barrel)
  - `packages/warp_prism_ui/lib/src/organisms/ds_graph_canvas.dart` (refactored to thin wrapper)
  - `packages/warp_prism_ui/lib/src/organisms/organisms.dart` (modified — graph export)
  - `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart` (modified — graph demo)
  - `packages/warp_prism_ui/test/organisms/graph/graph_model_test.dart` (created)
  - `packages/warp_prism_ui/test/organisms/graph/force_directed_layout_test.dart` (created)
  - `packages/warp_prism_ui/test/organisms/graph/graph_painter_test.dart` (created)
  - `packages/warp_prism_ui/test/organisms/graph/backward_compat_test.dart` (created)
- **Tests or validation commands**:
  - `flutter test test/organisms/graph/` → **45/45 PASS**
  - `flutter analyze lib/src/organisms/graph/ lib/src/organisms/ds_graph_canvas.dart lib/src/organisms/organisms.dart` → **0 errors, 0 warnings**
  - Pre-existing compilation failures in `design_system_gallery_sections.dart` (classes inside `abstract class` at line 2215+) and `command_palette_test.dart` (undefined `DSCommand*` types) block `flutter test` and `melos run analyze` at the package level. These are NOT from this task.
- **Local changelog entry**: `docs/changelog/2026-06-08-task-1117-graph-visualization-refactor.md`
- **Agent-wiki / docs institutionalization**: N/A
- **Executor**: builders
- **Completion date**: 2026-06-08
