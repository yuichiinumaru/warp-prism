---
id: T010
title: "Build frontmatter parser pipeline"
status: doing
priority: high
owner: gt-harness-architect
created: "2026-06-01"
updated: "2026-06-06"
skills:
  - coding-execution-harness
  - harness-architecture
workflows:
  - gt-harness-architecture
  - builder-orchestration
depends_on:
  - T003
proof_state: partial
review_score: 6.0
---

# Build Frontmatter Parser Pipeline

## Goal
Implement the unified parseFrontmatter(String content) function and the typed parsers for agents, skills, workflows, tasks, and changelogs as specified in contract section 9.3.

## Scope
- parseFrontmatter() splits on --- delimiters
- parseAgent(), parseSkill(), parseWorkflow(), parseTask(), parseChangelog() each use frontmatter extraction
- Return typed model objects matching contract section 9.4

## Exit Conditions
- [ ] parseFrontmatter() correctly handles files with and without frontmatter
- [ ] All 5 typed parsers pass round-trip tests against mock corpus files
- [ ] Graph normalizer produces valid WorkspaceEdge list from cross-references

## Verification Commands
```bash
flutter test test/data/frontmatter_parser_test.dart
```

## Completion Evidence
*Partial — parseFrontmatter() implemented in lib/data/parsers/frontmatter_parser.dart; typed parsers for agent and skill complete; workflow, task, changelog parsers in progress.*
