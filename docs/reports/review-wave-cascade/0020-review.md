# Review Report: Task 0020 — Enhanced Workspace Snapshot Search, Detail, Graph — 2026-06-17

## Review Lineage

- **Current task**: Task 0020 (`0020-warp-prism-enhanced-workspace-snapshot-search-detail-graph`); live path initially `docs/tasks/03-review/0020-warp-prism-enhanced-workspace-snapshot-search-detail-graph.md`, routed back to `docs/tasks/02-doing/0020-warp-prism-enhanced-workspace-snapshot-search-detail-graph.md`.
- **Previous reports read**:
  - `docs/reports/build-gate-review/0020-warp-prism-enhanced-workspace-snapshot-search-detail-graph.md` — prior `100/100`, accepted blocked SDK proof.
- **Related reports/tasks considered**:
  - Task 0019 current cascade report: `docs/reports/review-wave-cascade/0019-review.md` — rejected to doing.
- **Review mode**: cascade re-review / prerequisite and live contract check.

## Score And Verdict

- **Score**: `52/100`
- **Verdict**: `REJECTED_TO_DOING`
- **Lane recommendation**: `return-to-doing`

## Delta Summary

### Resolved Since Previous Review
- `RESOLVED`: Targeted enhanced snapshot tests run and pass under live SDK as part of `34 passed`.

### Persistent Findings
- `PERSISTENT`: Prior report treated blocked analyzer/test proof as pass-equivalent.

### Regressions
- `REGRESSION`: Declared prerequisite Task 0019 is now rejected to doing by current cascade review.

### New Findings
- `NEW`: The claimed debounced search is not implemented; the provider passes through immediately.
- `NEW`: Live analyzer proof for the enhanced workspace snapshot surface fails.

### Evidence Gaps / External Blockers
- `EVIDENCE_GAP`: UI behavior for actual card/graph click + deep-link inspector is not fully proven by the passing tests; the current tests mostly exercise model/search/filter/metric functions.

## Findings

| ID | Class | Severity | Status | Summary | Evidence |
| --- | --- | --- | --- | --- | --- |
| F1 | REGRESSION | High | Open | Rejected prerequisite blocks approval. | Task 0020 declares `Depends on: Task 0019` at `docs/tasks/03-review/0020-warp-prism-enhanced-workspace-snapshot-search-detail-graph.md:10`; Task 0019 is rejected in `docs/reports/review-wave-cascade/0019-review.md`. |
| F2 | NEW | Medium | Open | Debounced search exit condition is false. | Task 0020 requires `Global search bar wired to the snapshot data with debounced filtering` at `docs/tasks/03-review/0020-warp-prism-enhanced-workspace-snapshot-search-detail-graph.md:85`; live provider says it passes through directly and debounce is optional at `apps/observatory/lib/features/workspace_snapshot/workspace_snapshot_provider.dart:59-64`. |
| F3 | EVIDENCE_GAP | Medium | Open | Analyzer exit condition is not satisfied on live enhanced snapshot files. | The focused analyzer command in `apps/observatory/` failed with `42 issues found`, including warnings such as `apps/observatory/lib/features/workspace_snapshot/widgets/agent_list_panel.dart:10` unused import and additional diagnostics across workspace snapshot widgets/tests. |

## Evidence Reviewed

- Task files: Task 0020, Task 0019.
- Source/test files: `apps/observatory/lib/data/models/workspace_snapshot.dart`, `apps/observatory/lib/features/workspace_snapshot/workspace_snapshot_page.dart`, `workspace_snapshot_provider.dart`, `widgets/workspace_search_bar.dart`, `widgets/workspace_filter_chips.dart`, `widgets/workspace_graph_panel.dart`, `widgets/workspace_detail_inspector.dart`, `widgets/workspace_derived_metrics.dart`, `test/features/workspace_snapshot/workspace_snapshot_enhanced_test.dart`.
- Runtime wiring proof: `apps/observatory/lib/app/router.dart:122-157` registers deep-link routes for agent, skill, workflow, task, changelog to `WorkspaceSnapshotPage(assetId: ...)`; `workspace_snapshot_page.dart:53-58` posts a callback to select deep-linked assets.
- Commands run:
  - `flutter analyze --no-pub lib/features/workspace_snapshot lib/data/sources/preset_local_workspace_source.dart lib/data/models/workspace_snapshot.dart test/features/workspace_snapshot test/data/sources/preset_local_workspace_source_test.dart` in `apps/observatory/` — failed, `42 issues found`.
  - `flutter test --no-pub test/data/sources/preset_local_workspace_source_test.dart test/features/workspace_snapshot/workspace_snapshot_enhanced_test.dart` in `apps/observatory/` — passed, `34 passed`.

## Path To 100

1. Get Task 0019 approved first.
2. Implement actual debounce behavior (timer/notifier or equivalent) and add a test that proves rapid changes coalesce before filtering.
3. Clear focused analyzer diagnostics for workspace snapshot files/tests.
4. Add/refresh UI-level tests for card click, graph node click, and deep-link inspector opening, not only model-level search/filter/metrics.
5. Re-run exact analyzer and targeted tests; paste fresh output.

## Task Ledger Patch Suggestion

Add/update Task 0020 Review Ledger with this latest report, `52/100`, `REJECTED_TO_DOING`, blockers F1-F3, and the path-to-100 above.
