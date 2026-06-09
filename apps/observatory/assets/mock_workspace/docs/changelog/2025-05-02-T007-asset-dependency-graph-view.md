---
id: 2025-05-02-T007-asset-dependency-graph-view
date: 2025-05-02
project: asw-observatory
task: T007
type: feature
impact:
  - harness-map
  - graph-model
  - dependency-chain
skills:
  - design-system-harness
  - harness-architecture
---

# Asset dependency graph view implemented

## Why

The Map workspace needs a visual dependency graph showing how agents, skills, workflows, and tasks connect through `contains`, `routesTo`, `dependsOn`, `references`, `changedBy`, `proves`, and `uses` edges. Without this view, operators cannot trace impact paths or understand workspace topology.

## Changed

- Implemented `DSGraphCanvas` with force-directed layout using the `graphview` package.
- Added node rendering per `AssetKind` with `DSColors.forAssetKind()` color coding.
- Implemented edge rendering with distinct styles per `EdgeKind`.
- Added node selection that opens the detail inspector for the selected asset.

## Evidence

- `assets/mock_workspace/docs/tasks/01-open/T007-build-asset-dependency-graph-view.md` defines the graph contract.
- `lib/design_system/organisms/ds_graph_canvas.dart` is the target organism.
