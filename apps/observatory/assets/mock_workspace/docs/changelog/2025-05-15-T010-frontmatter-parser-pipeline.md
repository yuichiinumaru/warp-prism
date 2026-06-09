---
id: 2025-05-15-T010-frontmatter-parser-pipeline
date: 2025-05-15
project: asw-observatory
task: T010
type: feature
impact:
  - parser
  - frontmatter
  - data-layer
skills:
  - coding-execution-harness
  - harness-architecture
---

# Frontmatter parser pipeline built

## Why

The prompt requires all mock data files to be `.md` with YAML frontmatter, not pure YAML. The existing `workspace_parser.dart` only handles raw YAML. Without a frontmatter parser, the observatory cannot ingest the canonical mock corpus.

## Changed

- Built a frontmatter extraction pipeline that splits `.md` files into YAML header and markdown body.
- Added `parseFrontmatter()` to `workspace_parser.dart` supporting `---` delimited headers.
- Implemented body section extraction for `## Why`, `## Changed`, `## Evidence` sections.
- Connected frontmatter data to the `WorkspaceAsset` model with `frontmatter` map field.

## Evidence

- `assets/mock_workspace/docs/tasks/02-doing/T010-build-frontmatter-parser-pipeline.md` defines the parser contract.
- Parser handles all 5 asset kinds: agents, skills, workflows, tasks, changelog entries.
