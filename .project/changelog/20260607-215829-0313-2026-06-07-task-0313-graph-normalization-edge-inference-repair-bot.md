---
date: 20260607-215829
timestamp: 20260607-215829
project: "warp-prism"
agent: repair-bot
task: "0313"
description: "Why"
is_rebuild_safe: true
id: "task-0313-graph-normalization-edge-inference"
impact: ""
skills: ""
type: "feature"
---

## Why

The app requires one normalized graph shared by Map, Operate, History, and
Governance surfaces. Without a centralized graph builder and edge inference
service, each screen would rebuild relationships independently, leading to
drift and inconsistent truth models.

## Changed

- Created `WorkspaceGraphResult` — the canonical graph return type with
  asset index, edge list, kind grouping, and lookup/query helpers.
- Created `EdgeInferenceService` — pure, stateless edge inference rules
  covering containment, routing, dependency, reference, changed-by, proves,
  and usage relationships.
- Created `WorkspaceGraphBuilder` — single graph build pipeline that takes
  a flat list of `WorkspaceAsset` and returns a normalized `WorkspaceGraphResult`
  with deduplicated typed edges.
- Created barrel export `services.dart` for the data services layer.
- Added comprehensive tests proving graph normalization, edge inference,
  deduplication, and the changelog→task linkage chain.

## Evidence

- `lib/data/services/workspace_graph.dart` — canonical result type
- `lib/data/services/edge_inference_service.dart` — inference rules
- `lib/data/services/workspace_graph_builder.dart` — build pipeline
- `test/data/services/workspace_graph_builder_test.dart` — test suite
