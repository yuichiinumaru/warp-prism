---
id: T004
title: "Implement workspace snapshot export"
status: open
priority: medium
owner: builder-orchestrator
created: "2026-05-22"
updated: "2026-05-25"
skills:
  - coding-execution-harness
  - agent-cli-delegation
workflows:
  - builder-orchestration
depends_on:
  - T003
proof_state: none
review_score: n/a
---

# Implement Workspace Snapshot Export

## Goal
Build a command that exports the current mock workspace corpus as a JSON snapshot for offline analysis and comparison across runs.

## Scope
- Read all assets from assets/mock_workspace/
- Serialize frontmatter and body to a single JSON file
- Include asset counts, edge list, and validation status

## Exit Conditions
- [ ] dart run tool/export_snapshot.dart produces workspace_snapshot.json
- [ ] Snapshot includes all 9 agents, 13 skills, 11 workflows, 20+ tasks
- [ ] Edge list covers all 7 edge kinds from the contract

## Verification Commands
```bash
dart run tool/export_snapshot.dart && jq '.agents | length' workspace_snapshot.json
```

## Completion Evidence
*Not yet completed — task is in open lane.*
