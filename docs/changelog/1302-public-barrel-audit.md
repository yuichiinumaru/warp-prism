---
date: 2026-06-09
task: Task 1302
type: governance
scope: warp-prism-ui/barrel
agent: builders
---

# Task 1302: Public Barrel Audit

## Summary

Audited the public barrel of `packages/warp_prism_ui` and produced a definitive
export manifest at `docs/design/public-barrel-audit.md`.

## Findings

- **143 total public symbols** across tokens, atoms, molecules, organisms,
  templates, and gallery layers.
- **64 symbols have Prism* aliases** (45% coverage). Token classes and promoted
  molecules/organisms are well covered. Atoms, supporting enums, and organism
  infrastructure types are mostly unaliased.
- **10 experimental symbols** identified: Wave 4 drag-and-drop
  (`DSDraggableCard`, `DSDropTarget`, event types) and graph composable layers
  (`GraphNodeId`, `GraphEdgeId`, `GraphModel`, `GraphLayoutEngine`, etc.).
- **2 gallery-only symbols** (`DesignSystemGalleryPage`, `DSGallerySections`)
  exported alongside production types.
- **No src/ types leaking** into the public API except the documented
  legacy `GraphNode`/`GraphEdge` collision (graph composable types hidden
  from organisms barrel, legacy types exposed).

## Recommendations

1. Separate gallery exports from production (create `warp_prism_gallery.dart`).
2. Add Prism* aliases for commonly-used production types: `DSChip`, `DSIcons`,
   `DSShell`, `DSDetailInspector`, `DSTopbarAction`.
3. Mark experimental components (`@experimental` or doc comments) until Wave 4
   stabilization is complete.
4. Enforce barrel-only imports via boundary test harness (Task 1205).

## Files Created

- `docs/design/public-barrel-audit.md`

## Verification

- `dart analyze packages/warp_prism_ui/` — PASS (0 errors)
- `test -f docs/design/public-barrel-audit.md` — PASS
