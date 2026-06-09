---
id: 2026-06-05-T012-edge-inference-workspace-graph
date: 2026-06-05
project: warp-prism
task: T012
type: feature
skills:
  - harness-architecture
  - coding-execution-harness
workflows:
  - gt-harness-architecture
  - builder-orchestration
impact:
  - graph
  - edge-inference
  - workspace-model
---

# Edge Inference for Workspace Graph

Implemented automatic edge inference from frontmatter fields: skills -> uses, sub_skills -> contains, depends_on -> dependsOn, task -> changedBy, uses_skills -> dependsOn.

## Why

The workspace graph needs edges to render relationships between assets. Manual edge declaration would be error-prone and redundant since edges are already implied by frontmatter fields like skills, depends_on, and sub_skills.

## Changed

- WorkspaceMarkdownParser infers edges from frontmatter automatically
- 7 edge kinds implemented: uses, contains, dependsOn, changedBy, references, triggers, governs
- Edge targets resolve to typed asset IDs (skill:name, task:id, workflow:name)
- Parser tests verify edge inference for all asset kinds

## Evidence

- Task T012 in doing lane
- workspace_markdown_parser_test.dart has edge inference test group
- All 7 edge kinds covered by at least one test case
