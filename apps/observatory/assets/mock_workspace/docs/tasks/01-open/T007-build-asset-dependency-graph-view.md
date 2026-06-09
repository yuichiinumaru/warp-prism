---
id: T007
title: "Build asset dependency graph view"
status: open
priority: medium
owner: architect-orchestrator
created: "2026-05-25"
updated: "2026-05-30"
skills:
  - frontend-quality-harness
  - design-system-harness
workflows:
  - architect-orchestration
depends_on:
  - T002
  - T003
proof_state: none
review_score: n/a
---

# Build Asset Dependency Graph View

## Goal
Implement a graph view that visualizes the workspace asset dependency DAG using the DSGraphCanvas organism, with nodes colored by asset kind and edges by edge kind.

## Scope
- Load parsed workspace data from the frontmatter repository
- Render nodes using DS* design system atoms
- Edge rendering with kind-specific styling
- Selection and hover interaction states

## Exit Conditions
- [ ] Graph renders all assets from the mock corpus
- [ ] At least 3 edge kinds are visually distinguishable
- [ ] Node selection triggers DSDetailInspector update

## Verification Commands
```bash
flutter test test/features/graph/dependency_graph_test.dart
```

## Completion Evidence
*Not yet completed — task is in open lane.*
