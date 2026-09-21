---
type: review
date: 2026-06-17
title: task-0016-wave-0-review
agent: reviewers
---

# Task 0016 Wave 0 Review

- Reviewed `docs/tasks/03-review/0016-warp-prism-ds-organisms-templates-alignment.md` per Wave 0 cross-lane dependency triage.
- Score: `62/100` — Debt.
- Verdict: `REJECTED_TO_DOING`; task moved to `docs/tasks/02-doing/0016-warp-prism-ds-organisms-templates-alignment.md`.
- Report: `docs/reports/review-wave-0/0016-review.md`.
- Main blocker: dependency Task 0015 is still in `02-doing` with latest score `76/100` / rejected; Task 0016 consumes atom/molecule surfaces and cannot be proven independent.
- Live diagnostics: exact Where/test analyzer scope failed with 38 issues; format passed; targeted organism/template tests passed 20/20.
