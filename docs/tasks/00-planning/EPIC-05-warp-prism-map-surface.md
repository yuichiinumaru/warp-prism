# EPIC 05 — Warp-Prism Map Surface

> **Planning Status**: Active Epic
> **Executable?**: No — planning artifact only.
> **Promotion Gate**: Promote after graph backbone and DS graph/catalog primitives are available.

## Goal

Build the Harness Map view that answers what exists and how assets relate across agents, skills, workflows, tasks, and changelog entries.

## Source Evidence

- `prompt.txt` requires Map tabs for Agents, Skills, Workflows, and Graph.
- `prompt.txt` requires graph modes: containment, operational, and evidence.
- `research.md` identifies the Harness Map as the differentiator for making Lobe Gateway skill structure legible.

## Scope

- Catalog tabs with search/filter.
- Asset cards showing kind, canonicality/status, triggers, and relationships.
- Graph visualization modes.
- Selection-to-inspector behavior.
- Map-specific empty/loading/error states.

## Out of Scope

- Editing assets.
- Real filesystem mutation or index regeneration.
- Full universal detail page if EPIC 09 has not landed yet.

## Candidate Stories

- Map catalog tabs.
- Search/filter/chip interaction.
- Containment graph.
- Operational graph.
- Evidence graph.
- Selection/inspector integration.

## Dependencies

- EPIC 01 for DS graph/catalog organisms.
- EPIC 03 for graph data.
- EPIC 04 for shell route/layout.

## Acceptance Criteria for Epic Completion

- Users can browse agents, skills, workflows, and graph views.
- Graph modes use real normalized edges, not manually hardcoded lists.
- Selecting a node/card updates an inspector or navigable detail route.
- Map makes hierarchy and cross-references more legible than a folder list.
