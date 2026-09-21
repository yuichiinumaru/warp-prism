---
type: review
date: 2026-06-17
title: task-1126-readme-monorepo-alignment-wave-0-review
profile: reviewers
---

# Task 1126 README Monorepo Alignment — Wave 0 Review

- Score: 68/100.
- Verdict: REJECT / NEEDS FIX.
- Routed from `docs/tasks/03-review/` to `docs/tasks/02-doing/`.
- Key findings:
  - README documents global `melos`, but command is unavailable; root uses a Melos dev dependency.
  - `dart pub get` and `dart run melos run analyze` fail because workspace globs include nested `apps/observatory/tmp/pub-cache` package metadata.
  - README documents nonexistent `PrismTokens.*`; live aliases are `PrismColors`, `PrismTypography`, and `PrismSpacing`.
  - README points to nonexistent root `assets/mock_workspace/`; corpus lives at `apps/observatory/assets/mock_workspace/`.
  - Changelog validation failure is live but task evidence does not satisfy pre-existing-failure policy requirements.
- Full report: `docs/reports/build-gate-review/1126-review.md`.
