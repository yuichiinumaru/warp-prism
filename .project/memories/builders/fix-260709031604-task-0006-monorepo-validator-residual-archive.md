---
type: fix
title: "task-0006-monorepo-validator-residual-archive"
agent: builders
created: 2026-07-09T03:16:04
date: 2026-07-09
---

# task-0006-monorepo-validator-residual-archive

Task 0006 path-to-100 complete.

Scope: warp-prism Task 0006 mock corpus validation + legacy archive.

Changes:
- tool/validate_mock_workspace.py now defaults to apps/observatory when its manifest exists (monorepo-aware).
- Residual live root mock_workspace/ moved to .archive/mock_workspace-residual-source-20260709 after diff-identity with .archive/mock_workspace/ (18 files each). No rm.
- Task evidence refreshed and file promoted 02-doing → 03-review.
- Changelog entry: docs/changelog/2026-07-09-task-0006-monorepo-aware-validator-archive-completion.md

Verification:
- python3 tool/validate_mock_workspace.py → VALIDATION PASSED (exit 0)
- SOURCE_REMOVED:OK, ARCHIVE 18 files present

Gotcha: parent changelog_engine.py defaults to .changelog/ and build from empty staging rewrote root CHANGELOG.md; restored via git checkout and archived misroute under .archive/changelog-engine-misroute-20260709/. Warp Prism durable entries stay under docs/changelog/.
