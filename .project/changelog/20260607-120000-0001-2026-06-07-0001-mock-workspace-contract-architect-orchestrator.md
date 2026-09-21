---
date: 20260607-120000
timestamp: 20260607-120000
project: "warp-prism"
agent: architect-orchestrator
task: "0001"
description: "Mock Workspace Corpus Contract Baseline"
is_rebuild_safe: true
impact: "mock-workspace, corpus-contract, parser-deltas, model-deltas"
skills: "harness-architecture, project-management"
type: "governance"
---

# Mock Workspace Corpus Contract Baseline

Established the migration contract for replacing legacy YAML mocks with markdown-frontmatter corpus.

## Why

Without a single approved corpus contract, every executor would invent a different asset tree, count interpretation, or archive strategy. This task eliminates guesswork for the entire EPIC 02 wave.

## Changed

- Created `docs/mock-workspace-corpus-contract.md` with required counts, agent/skill/workflow/task/changelog lists, legacy archive mapping, and parser/model deltas for EPIC 03.
- Created `assets/mock_workspace/manifest.yaml` as the structured reference manifest.
- Mapped all 18 legacy files under `mock_workspace/` to `archive` destination under `.archive/`.
- Documented 7 parser changes and 10 model changes required for EPIC 03.

## Evidence

- Validation: `rg` commands pass for all required keys in manifest and contract.
- Task file completed with exit condition checkboxes.
