# Review Wave 2 — Task 0004

**Date**: 2026-06-14
**Reviewer profile**: reviewers
**Task**: `docs/tasks/02-doing/0004-warp-prism-task-lane-markdown-corpus.md`
**Score**: 86/100 — Rejected and routed to `02-doing/`

## Summary

Task 0004's live task corpus is mostly correct after the monorepo migration: the active fixture tree is under `apps/observatory/assets/mock_workspace/docs/tasks/`, not root `assets/mock_workspace/docs/tasks/`. The corpus contains 22 task markdown files across all five lanes, all required task frontmatter fields, all required task body sections, valid owner/skill/workflow/dependency references, and a realistic category spread.

The task is rejected because its task-file documentation/evidence is not ready for review: the header remains `Review State: Builder Done`, the local changelog exit condition remains unchecked, and the documented validation paths still point to the obsolete root asset tree. The root default validator also fails, proving the recorded command surface is stale.

## Evidence

| Check | Result |
| --- | --- |
| `python3 tool/validate_mock_workspace.py` | FAIL — looks for missing root `assets/mock_workspace/manifest.yaml`. |
| `python3 tool/validate_mock_workspace.py --project-root apps/observatory` | PASS — all five validation groups pass. |
| Corpus count audit | PASS — 22 tasks; lane distribution 3/5/5/4/5. |
| Task schema/body audit | PASS — 0 missing required frontmatter fields or required sections. |
| Task cross-reference audit | PASS — 0 bad owner/skill/workflow/dependency refs. |
| Lane routing | DONE — task file moved to `docs/tasks/02-doing/`. |

## Findings

### High

1. **Review state/lane gate mismatch** — Task is in review flow with `Review State: Builder Done`; lane policy requires tasks in `03-review/` to be `Ready For Review` or later.
2. **Validation evidence path drift** — Task evidence and Where paths cite root `assets/mock_workspace/...`; live corpus is under `apps/observatory/assets/mock_workspace/...` after Task 1107.
3. **Local changelog evidence missing** — Exit condition for changelog entry remains unchecked/pending.

### Medium

1. **Default validator command is stale for this packet** — `python3 tool/validate_mock_workspace.py` fails from repo root while the monorepo-aware command passes.

## Path to 100

- Update Task 0004 evidence/Where paths to `apps/observatory/assets/mock_workspace/...` or explicitly document the monorepo migration path change.
- Add the local changelog evidence, or explicitly mark the fixture-only waiver with reviewer/architect rationale.
- Rerun and record current validation commands against the live corpus path.
- Set `Review State: Ready For Review` before moving back to `docs/tasks/03-review/`.
