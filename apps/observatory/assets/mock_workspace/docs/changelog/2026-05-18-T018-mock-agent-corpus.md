---
id: 2026-05-18-T018-mock-agent-corpus
date: 2026-05-18
project: warp-prism
task: T018
type: feature
skills:
  - harness-architecture
  - agent-wiki
workflows:
  - gt-ganthritor-onboard
  - gt-harness-architecture
impact:
  - agents
  - mock-data
  - corpus
---

# Mock Agent Corpus Created

Created all 9 required agent .md files with YAML frontmatter under the mock workspace agents directory.

## Why

The workspace graph and observatory UI need a realistic agent corpus to render the agent network. Without fixture agents, the Map and Overview surfaces would be empty.

## Changed

- 9 agent files created: architect-orchestrator, builder-orchestrator, reviewer-orchestrator, gt-harness-architect, gt-code-quality-reviewer, gt-security-reviewer, gt-external-intelligence-analyst, gt-task-architect, gt-wave-orchestrator
- Each agent has frontmatter with name, description, skills, workflows, and tags
- Cross-references to skills and workflows validated against existing fixture files

## Evidence

- ls produces 9 agent files
- All frontmatter validates via WorkspaceMarkdownParser
- Task T018 marked complete with review_score 9.5
