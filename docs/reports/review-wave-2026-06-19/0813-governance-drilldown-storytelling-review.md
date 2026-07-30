# Review Report: Task 0813 — Governance Drill-Down And Storytelling — 2026-06-19

## Review Lineage

- **Current task**: Task 0813 (`0813-warp-prism-governance-drilldown-storytelling`); live path resolved from filesystem search under `docs/tasks/`.
- **Previous reports read**:
  - `docs/reports/build-gate-review/0813-review.md` — claimed `100/100`, approved.
- **Related reports considered**:
  - `docs/reports/build-gate-review/0810-review.md`, `0811-review.md`, `0812-review.md` — upstream Governance widgets must be composed for drilldown/storytelling to be runtime-useful.
  - Task 0314 ledger in `docs/tasks/02-doing/0314-warp-prism-derived-metrics-governance-diagnostics.md` — current dependency rejected to doing at `52/100`.
  - EPIC 09 planning file `docs/tasks/00-planning/EPIC-09-warp-prism-universal-asset-detail.md` — detail route should degrade gracefully for unknown assets.
- **Review mode**: `re-review`.

## Score And Verdict

- **Score**: `48/100`
- **Verdict**: `REJECTED_TO_DOING`
- **Lane recommendation**: `return-to-doing`

## Axiom Compliance

| Axiom | Status | Evidence |
| --- | --- | --- |
| Analyzer Integrity | FAIL | `flutter analyze --no-pub` found **378 issues**, including Task 0813 test lint issues at `governance_drilldown_storytelling_test.dart:430` and `:441`. |
| Lifecycle Safety | PASS | Task 0813 production files create **0** controllers/subscriptions/timers/listeners and contain **0** `dispose()` methods. `governance_drilldown_controller.dart` is functional/stateless. |
| Dependency Direction | PARTIAL | Presentation code imports data diagnostics and fan-in presentation model (`governance_story_summary.dart:12-14`). No cycle found, but it bypasses route-level asset detail/controller integration. |
| UI Accessibility | FAIL | Task 0813 production interactive widgets: **1** `GestureDetector` drilldown link (`governance_story_summary.dart:362-390`). Task 0813 production `Semantics` widgets: **0**. No 48x48 dp minimum is enforced. |
| Proof Reality | FAIL | Focused governance suite failed (**80** run, **79** pass, **1** fail). Task 0813 tests pass in that run, but they only validate callback targets, not real GoRouter navigation from `/governance`. Runtime route does not render story/drilldown widgets. |
| Release Security | PASS | No release config, secrets, permissions, `print`, or `debugPrint` in Task 0813 production files. |

## Delta Summary

### Resolved Since Previous Review
- `RESOLVED`: Flutter SDK is available locally for this review.

### Persistent Findings
- `PERSISTENT`: Analyzer gate is not clean.

### Regressions
- `REGRESSION`: Previous report accepted drill-down completion, but live route/page does not use `GovernanceStorySummary` or `GovernanceDrilldownTarget`; drill-down is test-only callback plumbing.

### New Findings
- `NEW`: Drilldown controller builds `/assets/$assetId` strings but no production caller invokes `context.go(target.routePath)`, no URL encoding is applied for IDs containing `:`, `/`, spaces, or `#`, and no resolver checks whether the ID exists.
- `NEW`: Story summary is not runtime-wired into `/governance` and therefore cannot provide required high-level risk storytelling.
- `NEW`: The interactive drilldown link has no semantic label/minimum tap target.

### Evidence Gaps / External Blockers
- `EVIDENCE_GAP`: Task 0813 depends on Tasks 0810-0812 and EPIC 09. Tasks 0810-0812 fail this review wave, and the current `AssetDetailPage` itself says it is a placeholder “To be replaced by the real Asset Detail screen in EPIC-09” at line 7.

## Findings

| ID | Class | Severity | Status | Summary | First seen | Evidence |
| --- | --- | --- | --- | --- | --- | --- |
| F1 | REGRESSION | CRITICAL | Open | Drill-down/story widgets are not wired into the production Governance route. `/governance` renders `GovernanceOverviewPage`; that page never imports/renders `GovernanceStorySummary` or uses drilldown targets. | 2026-06-19 | `apps/observatory/lib/app/router.dart:83-84`; `apps/observatory/lib/features/governance/presentation/governance_overview_page.dart:12`, `:78-100`; grep found `deriveGovernanceRiskStories` only in declaration/tests |
| F2 | NEW | CRITICAL | Open | Drilldown controller is not a navigation controller. It returns string targets only; no production code calls `context.go(target.routePath)`, and the tests only capture callback data. | 2026-06-19 | `apps/observatory/lib/features/governance/presentation/widgets/governance_drilldown_controller.dart:53-89`; `apps/observatory/test/features/governance/governance_drilldown_storytelling_test.dart:340-369` |
| F3 | NEW | MODERATE | Open | Asset IDs are interpolated into route paths without URL encoding. Stable IDs currently include colons (`task:0612`, `skill:hub-skill`); future IDs with `/`, whitespace, `?`, or `#` will break or misroute. | 2026-06-19 | `apps/observatory/lib/features/governance/presentation/widgets/governance_drilldown_controller.dart:61`, `:71`, `:86`; `apps/observatory/lib/features/governance/presentation/widgets/governance_story_summary.dart:366` |
| F4 | NEW | MODERATE | Open | Interactive story drilldown link is inaccessible: **1** GestureDetector, **0** Semantics widgets, no 48x48 dp hit target. | 2026-06-19 | `apps/observatory/lib/features/governance/presentation/widgets/governance_story_summary.dart:362-390` |
| F5 | EVIDENCE_GAP | CRITICAL | Open | Upstream dependencies are not approved: Tasks 0810-0812 are rejected in this wave, and Task 0314 is back in `02-doing` at `52/100`. EPIC 09 detail page is currently a placeholder. | 2026-06-19 | `docs/tasks/03-review/0813-warp-prism-governance-drilldown-storytelling.md:9`; `docs/tasks/02-doing/0314-warp-prism-derived-metrics-governance-diagnostics.md:132-147`; `apps/observatory/lib/app/pages/asset_detail_page.dart:7`, `:44-45`, `:93-102` |
| F6 | PERSISTENT | MODERATE | Open | Analyzer integrity is not satisfied: **378** issues. | 2026-06-13 | command output: `flutter analyze --no-pub` |

## Evidence Reviewed

- Task file: `docs/tasks/03-review/0813-warp-prism-governance-drilldown-storytelling.md`.
- Previous report: `docs/reports/build-gate-review/0813-review.md`.
- Source/test files: `governance_drilldown_controller.dart`, `governance_story_summary.dart`, `governance_drilldown_storytelling_test.dart`, `router.dart`, `asset_detail_page.dart`, `governance_overview_page.dart`, `fan_in_hotspots_panel.dart`, `governance_diagnostics.dart`.
- Runtime wiring proof: `/governance` route constructs `const GovernanceOverviewPage()` at `router.dart:83-84`. The Governance page never imports/renders Task 0813 widgets. `/assets/:assetId` route exists at `router.dart:97-102` and renders `AssetDetailPage`, but Task 0813 does not navigate to it from production UI. `AssetDetailPage` contains an honest placeholder/fallback, but not a full EPIC 09 detail implementation.
- Interactive/accessibility count: **1** Task 0813 production tap target (`GestureDetector`), **0** `Semantics` widgets in Task 0813 production files.
- Commands run:
  - `flutter --version` — PASS.
  - `dart --version` — PASS.
  - `flutter analyze --no-pub && flutter test --no-pub ...governance...` — FAIL at analyzer, **378** issues.
  - `flutter test --no-pub test/features/governance/governance_boundaries_overview_test.dart test/features/governance/governance_issue_panels_test.dart test/features/governance/governance_analytics_panels_test.dart test/features/governance/governance_drilldown_storytelling_test.dart` — FAIL, **80 tests run**, **79 passed**, **1 failed** in Task 0812.
- Commands not run and why: full package `flutter test` not run because focused governance suite already failed.

## Path To 100

1. Do not attempt Task 0813 acceptance until Tasks 0810-0812 and Task 0314 are back to `>=90/100`; this task composes their outputs.
2. Wire `GovernanceStorySummary` into the production `GovernanceOverviewPage` using service-backed diagnostics/boundary counts/hotspots.
3. Convert `GovernanceDrilldownTarget` into real navigation from the production widget: inject `ValueChanged<GovernanceDrilldownTarget>` from the page/router layer and call `context.go(target.routePath)` or update inspector state. Add a GoRouter test that taps a Governance story and lands on `/assets/<encoded-id>` or the honest fallback.
4. URL-encode asset IDs (`Uri.encodeComponent`) and decode in the asset route, or use query/state if colon/slash IDs must remain opaque.
5. Replace GestureDetector drilldown text with an accessible `TextButton`/`InkWell` plus `Semantics(button: true, label: 'Open asset detail for ...')` and 48x48 dp minimum.
6. Clear analyzer issues and rerun the focused governance tests after Task 0812’s failing test is fixed.

## Task Ledger Patch Suggestion

```markdown
---

## Review Ledger

> [!IMPORTANT]
> Before path-to-100 work, read the latest full report and all reports listed
> under Previous Reports. Persistent findings and regression guards are part of
> the acceptance contract; do not fix the latest finding by undoing a previously
> accepted repair.

### Latest Review

- **Date**: 2026-06-19
- **Reviewer profile**: `reviewers`
- **Score**: `48/100`
- **Verdict**: `REJECTED_TO_DOING`
- **Full report**: `docs/reports/review-wave-2026-06-19/0813-governance-drilldown-storytelling-review.md`
- **Lane outcome**: `returned to doing`
- **Task reference**: Task 0813 (`0813-warp-prism-governance-drilldown-storytelling`)

#### Current Open Blockers

- `REGRESSION`: Story/drilldown widgets are not rendered by `/governance`.
- `NEW`: Drilldown controller returns string targets only; no production navigation/inspector update exists.
- `NEW`: asset IDs are interpolated into routes without URL encoding.
- `NEW`: story drilldown tap target lacks Semantics and 48x48 dp guarantee.
- `EVIDENCE_GAP`: upstream Tasks 0810-0812 and Task 0314 are not approved; EPIC 09 detail route is still placeholder-level.

#### Path-to-100 Summary

- Fix/approve upstream Governance diagnostics and panels first.
- Runtime-wire story summary and real GoRouter/inspector navigation.
- Add encoded route navigation tests plus accessibility fixes.

### Previous Reports

- `2026-06-13` — `100/100` — `docs/reports/build-gate-review/0813-review.md`
  - **Carried forward**: analyzer evidence gap.
  - **Resolved since**: Flutter SDK is available locally.
  - **Regression guard**: callback-only drilldown tests do not prove production route navigation.
```
