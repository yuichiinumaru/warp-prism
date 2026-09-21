---
date: 20260709-061500
timestamp: 20260709-061500
project: warp-prism
agent: builders
task: "0004"
description: "Task-lane markdown corpus path-to-100 evidence refresh and monorepo validation"
is_rebuild_safe: true
type: evidence-refresh
impact: "mock-workspace, task-corpus, operate-surface, docs/tasks/0004"
skills: "project-management, harness-architecture"
---

# Task 0004: Warp Prism Task Lane Markdown Corpus

## Summary

Refreshed Task 0004 after Wave-2 rejection (86/100). Live mock task corpus under
`apps/observatory/assets/mock_workspace/docs/tasks/` was re-verified as complete
(22 files, 5 lanes, full frontmatter/body contract, resolved owner/skill/workflow
and dependency references). Task evidence paths were migrated off the obsolete
root `assets/mock_workspace/` location, monorepo-aware validation was re-run, and
local changelog evidence was added so the task can re-enter `03-review/`.

## Changes

- Confirmed live corpus at `apps/observatory/assets/mock_workspace/docs/tasks/`:
  - `00-planning/`: 3
  - `01-open/`: 5
  - `02-doing/`: 5
  - `03-review/`: 4
  - `04-completed/`: 5
  - Total: 22 task markdown files
- Confirmed required frontmatter on all 22 files:
  `id`, `title`, `status`, `priority`, `owner`, `created`, `updated`, `skills`,
  `workflows`, `depends_on`, `proof_state`, `review_score`
- Confirmed required body sections on all 22 files:
  Goal, Scope, Exit Conditions, Verification Commands, Completion Evidence
- Confirmed owner/skill/workflow references resolve against mock agents/skills/workflows
- Confirmed all `depends_on` IDs exist inside the mock corpus (T001–T022)
- Updated Task 0004 evidence/Where paths to monorepo-aware
  `apps/observatory/assets/mock_workspace/...`
- Recorded current validator stdout for
  `python3 tool/validate_mock_workspace.py --project-root apps/observatory`
- Added this local changelog entry for the previously unchecked exit condition

## Verification

```text
$ find apps/observatory/assets/mock_workspace/docs/tasks -name '*.md' | wc -l
22

$ for d in 00-planning 01-open 02-doing 03-review 04-completed; do
    echo -n "$d: "; find apps/observatory/assets/mock_workspace/docs/tasks/$d -name '*.md' | wc -l
  done
00-planning: 3
01-open: 5
02-doing: 5
03-review: 4
04-completed: 5

$ python3 tool/validate_mock_workspace.py --project-root apps/observatory
VALIDATION PASSED: all checks OK
EXIT:0

$ python3 schema/cross-ref audit (inline)
frontmatter_ok=22/22 sections_ok=22/22
RESOLVE_OK True
bad_owners []
bad_skills []
bad_wfs []
bad_deps []
```

Note: bare `python3 tool/validate_mock_workspace.py` (no `--project-root`) still
fails against the obsolete root path; the governed monorepo command is the
authoritative verification surface for this packet.
