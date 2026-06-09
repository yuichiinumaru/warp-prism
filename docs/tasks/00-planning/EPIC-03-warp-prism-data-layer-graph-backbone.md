# EPIC 03 — Warp-Prism Data Layer and Graph Backbone

> **Planning Status**: Active Epic
> **Executable?**: No — planning artifact only.
> **Promotion Gate**: Promote tasks after current model/parser files are audited against the prompt contract.

## Goal

Implement the normalized read-only data backbone that turns mock workspace files into graphable assets and edges powering all product screens.

## Source Evidence

- `prompt.txt` requires `AssetKind`, `EdgeKind`, `Canonicality`, `WorkspaceAsset`, and `WorkspaceEdge`-style model concepts.
- `research.md` recommends one normalized graph shared by harness map and execution ledger.
- `draft.md` reports current models are more generic and omit key kinds/canonicality fields.

## Scope

- Domain models for assets, edges, task lane metadata, changelog metadata, and governance diagnostics.
- Markdown frontmatter parser.
- Repositories/services that load mock assets read-only.
- Graph normalization and relationship inference.
- Loading/error/empty state contracts for UI providers.

## Out of Scope

- UI layout/polish beyond data contracts.
- Direct edits to mock files at runtime.
- Real repository scanning outside the bundled mock workspace.

## Candidate Stories

- Backbone model contract audit.
- Markdown/frontmatter parsing fixtures.
- Mock workspace repository.
- Graph normalization and edge inference.
- Derived metrics and diagnostics service.
- Provider/view-model contracts for feature screens.

## Dependencies

- EPIC 02 should define stable mock files.
- EPIC 04 and feature epics depend on this backbone.

## Acceptance Criteria for Epic Completion

- App can load assets and edges from markdown corpus through repositories/services.
- Graph model includes required asset/edge/canonicality concepts.
- Parser tests cover representative agents, skills, workflows, tasks, and changelog entries.
- Screens consume repositories/view models rather than parsing files inside widgets.
