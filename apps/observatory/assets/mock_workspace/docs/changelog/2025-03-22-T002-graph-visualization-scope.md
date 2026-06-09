---
id: 2025-03-22-T002-graph-visualization-scope
date: 2025-03-22
project: asw-observatory
task: T002
type: feature
impact:
  - harness-map
  - graph-model
  - visualization
skills:
  - harness-architecture
  - design-system-harness
---

# Graph visualization scope defined

## Why

The Map workspace needs a force-directed graph to show how agents, skills, workflows, and tasks connect. Without a scope document, graph rendering would be over-engineered or under-specified.

## Changed

- Defined three graph modes: force-directed, hierarchical, and dependency-chain.
- Specified node styling per `AssetKind` using `DSColors.forAssetKind()`.
- Planned edge rendering for all 7 `EdgeKind` values with distinct visual treatments.
- Reserved `DSGraphCanvas` as the organism host for graph rendering.

## Evidence

- `assets/mock_workspace/docs/tasks/00-planning/T002-plan-graph-visualization-scope.md` contains the visualization contract.
- `lib/design_system/organisms/ds_graph_canvas.dart` is the target organism.
