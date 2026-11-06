# EPIC 02 — Warp-Prism Mock Workspace Corpus

> **Planning Status**: Active Epic
> **Executable?**: No — planning artifact only.
> **Promotion Gate**: Promote tasks after verifying current mock files and exact asset declarations in `pubspec.yaml`.

## Goal

Create the realistic markdown/frontmatter mock Agent System Workspace required by the prompt, under `assets/mock_workspace/`, so the app can parse real files rather than hardcoded placeholder data.

## Source Evidence

- `prompt.txt` requires mocked `.agents/` and `docs/` files as real `.md` files with valid YAML frontmatter.
- `prompt.txt` specifies minimum counts: 9 agents, 13 super-skills, 11 workflows, 20 tasks across 5 lanes, 12 changelog entries.
- `draft.md` reports current mocks are `.yaml`-style and located under `mock_workspace/`, while `pubspec.yaml` expects `assets/mock_workspace/`.

## Scope

- Agents with skills/workflows frontmatter.
- Skills with `SKILL.md`, sub-skills, workflows, references, and scripts.
- Global workflows with frontmatter.
- Task corpus in five lanes with metadata and body sections.
- Changelog corpus with frontmatter and change-story body.
- Asset declaration alignment in Flutter config when promoted.

## Out of Scope

- Real Ganthritor data ingestion.
- Runtime write-back to files.
- Mutation tools for task/changelog management.

## Candidate Stories

- Mock corpus inventory and relocation plan.
- Agent/workflow markdown fixtures.
- Skill hierarchy markdown fixtures.
- Task lane fixture set.
- Changelog fixture set.
- Fixture validity checks for YAML frontmatter.

## Dependencies

- EPIC 00 for basic asset loading confidence.
- EPIC 03 consumes this corpus, so ordering must keep fixture contracts stable.

## Acceptance Criteria for Epic Completion

- Required mock file counts exist in `assets/mock_workspace/`.
- Files use `.md` with valid YAML frontmatter and markdown body.
- Corpus demonstrates graph relationships called out in the prompt.
- Parser tasks can treat the corpus as source evidence rather than inventing data.
