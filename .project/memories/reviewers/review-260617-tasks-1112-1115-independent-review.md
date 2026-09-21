# Review: Tasks 1112-1115 independent review

Date: 2026-06-17
Reviewer profile: reviewers

Reviewed sequentially:

- Task 1112 — Data Table Component: 48/100, REJECTED_TO_DOING. Report: `docs/reports/build-gate-review/1112-review-2026-06-17.md`. Returned to `docs/tasks/02-doing/`.
- Task 1113 — Command Palette: 46/100, REJECTED_TO_DOING. Report: `docs/reports/build-gate-review/1113-review-2026-06-17.md`. Returned to `docs/tasks/02-doing/`.
- Task 1114 — Log Viewer Component: 50/100, REJECTED_TO_DOING. Report: `docs/reports/build-gate-review/1114-review-2026-06-17.md`. Returned to `docs/tasks/02-doing/`.
- Task 1115 — Loading Skeleton And Error Boundary: 42/100, REJECTED_TO_DOING. Report: `docs/reports/build-gate-review/1115-review-2026-06-17.md`. Returned to `docs/tasks/02-doing/`.

Common live blocker: `dart run melos run analyze`, `flutter analyze lib`, and targeted `flutter test` commands fail before package analysis because `apps/observatory/tmp/pub-cache/hosted/pub.dev/flutter_lints-4.0.0/pubspec.yaml` is inside the workspace glob and lacks `resolution: workspace`.

Common dependency blocker: all four tasks depend on Tasks 1105 and 1107 and include a hard gate requiring Task 1102 output. Task 1102 is rejected to doing at 44/100; Task 1104 is rejected to doing at 82/100; Task 1105/1107 are not final-approved and are downstream of the rejected 1104/1102 chain.

Material findings:

- 1112: table accessibility gaps and filtering API evidence gap.
- 1113: async mounted-safety issue in command palette route completion; semantic/focus/touch-target gaps.
- 1114: log viewer semantics/touch-target gaps, unproven 10K performance, absolute timestamp flag defect.
- 1115: unsafe global `FlutterError.onError` override/restore logic in `DSErrorBoundary`, multi-boundary race risk, shimmer reduced-motion/semantics gap.

Path-to-100 priority:

1. Clean the in-repo pub cache/workspace resolution blocker.
2. Repair and approve upstream Tasks 1102, 1104, 1105, and 1107 or amend downstream hard gates.
3. Fix task-specific lifecycle/accessibility/API/performance defects listed in the four reports.
4. Rerun fresh analyzer/test/coverage proof before returning to review.
