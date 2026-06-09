---
id: 7521
title: Build ASW Observatory mock parser
status: 02-doing
priority: P1
owner: builder-orchestrator
created: 2026-06-01
updated: 2026-06-05
skills:
  - project-management
  - harness-architecture
  - code-quality-harness
workflows:
  - builder-orchestration
  - gt-verify-task-completion
depends_on:
  - 7518
proof_state: partial
review_score: null
---

# Task 7521 — Build ASW Observatory mock parser

## Goal

Implement the mock parsing layer for agent, skill, workflow, task, and changelog assets.

## Scope

- Frontmatter YAML decoder
- Asset-specific parsers
- Edge inference from frontmatter links
- Parser test fixtures

## Exit Conditions

- [ ] All five asset types parse correctly
- [ ] Malformed frontmatter produces typed errors
- [ ] Parser tests pass with 0 failures

## Verification Commands

```bash
flutter test test/data/parsers/
```

## Completion Evidence

Partial — frontmatter parser created, asset parsers in progress.
