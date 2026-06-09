---
id: T006
title: "Parse YAML workspace manifest"
status: open
priority: high
owner: builder-orchestrator
created: "2026-05-20"
updated: "2026-05-28"
skills:
  - coding-execution-harness
workflows:
  - builder-orchestration
  - gt-create-tasks
depends_on:
  - T003
proof_state: none
review_score: n/a
---

# Parse YAML Workspace Manifest

## Goal
Implement a parser that reads assets/mock_workspace/manifest.yaml and produces a typed WorkspaceManifest model with counts, required assets, and lane definitions.

## Scope
- Parse manifest.yaml using the yaml package
- Validate counts match actual file inventory
- Surface mismatches as structured diagnostics

## Exit Conditions
- [ ] WorkspaceManifest.fromYaml(String) returns typed model
- [ ] Count validation detects mismatches between manifest and filesystem
- [ ] Unit tests cover valid and invalid manifest inputs

## Verification Commands
```bash
flutter test test/data/manifest_parser_test.dart
```

## Completion Evidence
*Not yet completed — task is in open lane.*
