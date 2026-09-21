---
type: review
title: cascade-review-tasks-0017-0020
date: 2026-06-17
---

# Cascade Review: Tasks 0017-0020

Reviewed sequentially under parent agentID `reviewers`.

Outcomes:

- Task 0017 — `58/100`, `REJECTED_TO_DOING`, moved to `docs/tasks/02-doing/0017-warp-prism-design-system-gallery-route-bootstrap.md`.
- Task 0018 — `55/100`, `REJECTED_TO_DOING`, moved to `docs/tasks/02-doing/0018-warp-prism-ds-accessibility-focus-baseline.md`.
- Task 0019 — `64/100`, `REJECTED_TO_DOING`, moved to `docs/tasks/02-doing/0019-warp-prism-preset-workspace-snapshot-starter.md`.
- Task 0020 — `52/100`, `REJECTED_TO_DOING`, moved to `docs/tasks/02-doing/0020-warp-prism-enhanced-workspace-snapshot-search-detail-graph.md`.

Reports:

- `docs/reports/review-wave-cascade/0017-review.md`
- `docs/reports/review-wave-cascade/0018-review.md`
- `docs/reports/review-wave-cascade/0019-review.md`
- `docs/reports/review-wave-cascade/0020-review.md`

Fresh commands run:

- `packages/warp_prism_ui`: `flutter analyze --no-pub lib/src/gallery test/gallery test/accessibility` — failed, `333 issues found`.
- `packages/warp_prism_ui`: `flutter test --no-pub test/gallery/design_system_gallery_test.dart test/accessibility/design_system_accessibility_test.dart` — passed, `33 passed`.
- `apps/observatory`: `flutter analyze --no-pub lib/features/workspace_snapshot lib/data/sources/preset_local_workspace_source.dart lib/data/models/workspace_snapshot.dart test/features/workspace_snapshot test/data/sources/preset_local_workspace_source_test.dart` — failed, `42 issues found`.
- `apps/observatory`: `flutter test --no-pub test/data/sources/preset_local_workspace_source_test.dart test/features/workspace_snapshot/workspace_snapshot_enhanced_test.dart` — passed, `34 passed`.

Primary recurring blockers:

- Prerequisite cascade: 0017 is blocked by rejected 0011/0016; 0018 by 0017; 0019 by 0011/0017; 0020 by 0019.
- Stale pre-monorepo evidence paths.
- Blocked/missing-SDK validation was previously treated as approval proof.
- Task 0020 claims debounced search, but `debouncedSearchQueryProvider` passes through immediately.
