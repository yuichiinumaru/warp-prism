---
id: T012
title: "Implement edge inference for workspace graph"
status: doing
priority: high
owner: gt-task-architect
created: "2026-06-03"
updated: "2026-06-07"
skills:
  - coding-execution-harness
  - harness-architecture
workflows:
  - gt-harness-architecture
  - gt-verify-task-completion
depends_on:
  - T010
  - T007
proof_state: partial
review_score: 7.0
---

# Implement Edge Inference for Workspace Graph

## Goal
Build the graph normalizer that infers WorkspaceEdge objects from cross-references in parsed frontmatter, covering all 7 edge kinds: contains, routesTo, dependsOn, references, changedBy, proves, uses.

## Scope
- Scan agent frontmatter for skills/workflows references to produce uses edges
- Scan task frontmatter for depends_on/skills/workflows to produce dependsOn/uses edges
- Scan workflow frontmatter for uses_skills to produce uses edges
- Scan changelog frontmatter for task to produce changedBy edges
- Output normalized edge list for DSGraphCanvas

## Exit Conditions
- [ ] All 7 edge kinds are produced by the normalizer
- [ ] Edge list is deterministic (same input produces same output)
- [ ] Normalizer handles missing references gracefully (no crash, log warning)

## Verification Commands
```bash
flutter test test/data/graph_normalizer_test.dart
```

## Completion Evidence
*Partial — edge inference for agent-to-skill and agent-to-workflow edges implemented; task and changelog edge inference in progress.*
