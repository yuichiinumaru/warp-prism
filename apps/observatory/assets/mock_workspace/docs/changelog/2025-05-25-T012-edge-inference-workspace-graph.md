---
id: 2025-05-25-T012-edge-inference-workspace-graph
date: 2025-05-25
project: asw-observatory
task: T012
type: feature
impact:
  - graph-model
  - edge-inference
  - workspace-graph
skills:
  - harness-architecture
  - coding-execution-harness
workflows:
  - gt-harness-architecture
  - builder-orchestration
---

# Edge inference for workspace graph

## Why

The workspace graph has 7 edge kinds (`contains`, `routesTo`, `dependsOn`, `references`, `changedBy`, `proves`, `uses`) but edges were only defined explicitly in frontmatter. Many edges are implicit: a skill `contains` its sub-skills, a task `dependsOn` other tasks listed in its frontmatter, and a changelog entry `changedBy` its referenced task.

## Changed

- Implemented edge inference rules that derive implicit edges from frontmatter data.
- Added `inferEdges()` to the graph model that produces `contains` edges for skill->sub-skill, `dependsOn` for task->task, and `changedBy` for changelog->task.
- Verified inferred edges match the explicit edge definitions in the mock corpus.
- Added edge count validation against the manifest.

## Evidence

- `assets/mock_workspace/docs/tasks/02-doing/T012-implement-edge-inference-workspace-graph.md` defines the inference rules.
- `lib/data/models/workspace_graph.dart` is the target model.
