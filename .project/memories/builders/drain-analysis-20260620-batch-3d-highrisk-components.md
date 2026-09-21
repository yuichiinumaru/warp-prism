# Drain Analysis 2026-06-20 — Batch 3d High-Risk Components

> Source: `gt-mechanical-investigator` task `ses_11c828da1ffeobgNMJTkGwW6rk`.
> Scope: `02-doing/1121`, `1122`, `1123`, `1126`.
> Status: PARTIAL-COMPLETE — subagent read task files, build-gate reports, Wave 1 reports for `1121`/`1123`, and harness upgrade notes. It did not locate/read a 2026-06-17 independent review report for `1122` before step limit.

## Task Matrix

| Task | Priority | Latest Known Score / Verdict | Key Blockers | Recommended Action |
| --- | --- | ---: | --- | --- |
| `1121` Code Block + Markdown Renderer | P2 | 30 REJECTED | `TapGestureRecognizer` lifecycle leak; copy button 24x24 below 48x48; 10 hardcoded constants; tests don't assert copy action/syntax styles; analyzer issues. | `fixer_then_review`, high-risk lifecycle/accessibility. |
| `1122` Tab Bar + Split Pane | P2 | Prior build-gate 100, but current task says returned Doing | Need locate independent review; task mentions tab close crash, split-pane trailing max constraint, live verification blocker. | `fixer_then_review` only after current review findings are read. |
| `1123` Virtual Scroll Optimization | P2 | 49 REJECTED | Benchmark fails to compile; imports non-exported `DS*`; benchmark asserts `<50ms` not 60fps `<16.67ms`; no memory delta; `DSVirtualList` controller lifecycle bug; data-table a11y gaps. | `fixer_then_review`, performance/lifecycle specialist. |
| `1126` README Monorepo Alignment | P1 | 68 NEEDS FIX | Docs use global `melos`; `dart pub get` fails due workspace glob/nested cache; nonexistent `PrismTokens`; wrong corpus path; changelog validation failure unclassified. | `fixer_then_review`, docs + workspace command truth. |

## Where / Domains

| Task | Primary Files / Domains |
| --- | --- |
| `1121` | `packages/warp_prism_ui/lib/src/organisms/code_block/ds_code_block.dart`, `ds_markdown_renderer.dart`, related tests; lifecycle/accessibility/rendering. |
| `1122` | `packages/warp_prism_ui/lib/src/organisms/tab_bar/`, `ds_split_pane.dart`, related tests; tab/split-pane interaction. |
| `1123` | `ds_virtual_scroll.dart`, `test/performance/virtual_scroll_benchmark.dart`, `ds_data_table.dart`; performance/lifecycle/accessibility. |
| `1126` | `README.md`, `pubspec.yaml`, `prism_aliases.dart`; docs/tooling/API reality. |

## Collision Risks

| Risk | Tasks | Notes |
| --- | --- | --- |
| Barrel boundary (`DS*` vs `Prism*`) | `1121`, `1123`, `1126` | Benchmark/docs/tests must use correct public/internal surfaces. |
| Lifecycle/disposal | `1121`, `1123`, maybe `1122` | Recognizer, controller, focus/animation ownership must be audited. |
| Touch target / accessibility | `1121`, `1123` | 48x48 minimum and semantics gaps. |
| Workspace/tooling truth | `1126`, `1107`, `1204`, `1401` | Shared root for validation failures. |

## Suggested Priority

1. `1126` / workspace docs truth can unblock human/builders by correcting commands and path reality, but touches protected README/pubspec; requires task authority and careful serialization.
2. `1121` and `1123` are high-risk correctness bugs; handle separately with `gt-flutter-engineer` and strict review.
3. `1122` needs direct independent-review finding lookup before implementation.
