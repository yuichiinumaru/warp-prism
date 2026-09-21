# Review Report: Task 0813 — Governance Drill-Down And Storytelling — 2026-07-09

## Review Lineage

- **Current task**: Task 0813 (`0813-warp-prism-governance-drilldown-storytelling`); live path at review start: `docs/tasks/03-review/0813-warp-prism-governance-drilldown-storytelling.md`
- **Previous reports read**:
  - `docs/reports/review-wave-2026-06-19/0813-governance-drilldown-storytelling-review.md` — **48/100** `REJECTED_TO_DOING`
  - `docs/reports/build-gate-review/0813-review.md` — historical 100
- **Related reports considered**:
  - Tasks 0810–0812 prior/current wave (composition inputs)
  - EPIC 09 `/assets/:assetId` now mounts real `AssetDetailView` (0901/0902)
- **Review mode**: `re-review` / independent reviewers-wave 2026-07-09
- **Reviewer profile**: `reviewers` (gt-flutter-code-reviewer + gt-code-quality-reviewer)

## Score And Verdict

- **Score**: `82/100` — Good
- **Verdict**: `REJECTED_TO_DOING`
- **Lane recommendation**: `return-to-doing` (S < 90)

Composition quality is high: risk stories derive from live diagnostics, issue/hotspot rows expose drill-down targets, default handler calls `context.go`, unresolved IDs snackbar without crash, story links have Semantics. Focused **36/36** and full governance **94/94** pass. **Production `/governance` still instantiates empty `GovernanceOverviewPage()`** so stories/drilldowns never appear for users. Navigation tests still use callbacks rather than proving GoRouter landing on `/assets/:id`. Asset IDs are not URL-encoded in `detailRoute`.

## Delta Summary

### Resolved Since Previous Review

- `RESOLVED` (F1 partial): `GovernanceStorySummary`, issue groups, fan-in, and default drilldown are composed in `GovernanceOverviewPage._buildContent`.
- `RESOLVED` (F2 partial): Default `_defaultDrilldown` calls `context.go(target.routePath)` for navigable targets; unresolved → snackbar.
- `RESOLVED` (F4): Story drilldown uses `Semantics(button: true, label: ...)` + `InkWell`.
- `RESOLVED`: Changelog `docs/changelog/20260709-160956-0813-governance-drilldown-storytelling.md`.
- `RESOLVED`: Focused + suite tests green (36 + 94).

### Persistent Findings

- `PERSISTENT` (shared 0810): Production route still null-summary empty state.
- `PERSISTENT` (F3 debt): `AssetSelectionController.detailRoute` interpolates raw IDs without `Uri.encodeComponent`.

### Regressions

- None in test suite.

### New Findings

- `NEW` / Medium: Drilldown tests assert callback targets, not full GoRouter navigation from `/governance` → `/assets/:assetId`.
- `NEW` / Low: Analyzer infos remain in governance feature (prefer_const) — non-failing.

### Evidence Gaps / External Blockers

- `EVIDENCE_GAP`: No production provider maps `DiagnosticsReport` / `GovernanceViewModel` → `CanonicalityBoundarySummary`.
- EPIC 09 detail route is no longer a placeholder (positive external delta).

## Six Axiom Compliance

| # | Axiom | Status | Evidence |
| --- | --- | --- | --- |
| 1 | Analyzer Integrity | **PASS** (scoped) | 0 errors/warnings; style infos only |
| 2 | Lifecycle Safety | **PASS** | Stateless controller/widgets |
| 3 | Dependency Direction | **PASS** | Presentation → diagnostics models + selection helper |
| 4 | UI Accessibility | **PASS** (improved) | Story links semantic; issue/hotspot rows use onDrilldown hooks |
| 5 | Proof Reality | **PARTIAL** | Rich unit/widget coverage; production data + real router path unproven |
| 6 | Release Security | **PASS** | Read-only; snackbar fallback only |

## Findings

| ID | Class | Severity | Status | Summary | First seen | Evidence |
| --- | --- | --- | --- | --- | --- | --- |
| F1 | RESOLVED | Critical | Closed (composition) | Story/drilldown not in overview code | 2026-06-19 | `governance_overview_page.dart:105-163` |
| F1b | PERSISTENT | Serious | Open | Live route never supplies summary → empty UX | 2026-06-19 / 2026-07-09 | `router.dart:83-84` |
| F2 | RESOLVED | Critical | Closed (default handler) | No production `context.go` | 2026-06-19 | `_defaultDrilldown` → `context.go` |
| F2b | EVIDENCE_GAP | Medium | Open | Tests do not exercise GoRouter from Governance | 2026-07-09 | drilldown tests use callbacks |
| F3 | PERSISTENT | Debt | Open | No URL encoding for colon/special asset IDs | 2026-06-19 | `asset_selection_controller.dart:171` |
| F4 | RESOLVED | Moderate | Closed | GestureDetector without semantics | 2026-06-19 | `governance_story_summary.dart` Semantics+InkWell |
| F5 | SUPERSEDED | Critical | Closed | EPIC 09 placeholder detail page | 2026-06-19 | `AssetDetailPage` now mapper-backed |

## Exit Conditions (live)

| # | Condition | Met? | Live proof |
| --- | --- | --- | --- |
| 1 | Findings/hotspots expose drill-down via stable IDs | **YES** (code+tests) | controller + row hooks + composition tests |
| 2 | Risk story panel from real diagnostics | **YES** (when summary) | `deriveGovernanceRiskStories` + PrismStoryPanel |
| 3 | Tests: success, unresolved, story fixtures | **YES** | 36/36 |
| 4 | analyze governance feature | **YES** | 0 errors/warnings |
| 5 | Focused drilldown tests | **YES** | 36/36 |
| 6 | Sibling governance suite | **YES** | 94/94 |
| 7 | Changelog | **YES** | 20260709-160956 |

Product-level “not a dead-end dashboard” is **not** met on live `/governance` until summary injection lands.

## Evidence Reviewed

- Task 0813 + builder self-score 100
- `governance_drilldown_controller.dart`, `governance_story_summary.dart`
- `governance_issue_group.dart`, `fan_in_hotspots_panel.dart`
- `governance_overview_page.dart`, `router.dart`, `asset_selection_controller.dart`
- `governance_drilldown_storytelling_test.dart` + full governance suite run

## Commands Run

```text
# apps/observatory
dart analyze lib/features/governance
# → 11 infos only. EXIT 0

flutter test --concurrency=1 --no-pub \
  test/features/governance/governance_drilldown_storytelling_test.dart
# → +36 All tests passed!

flutter test --concurrency=1 --no-pub test/features/governance/
# → +94 All tests passed!
```

Flutter 3.44.1 / Dart 3.12.1.

## Path To 100

1. Make `GovernanceOverviewPage` a Consumer (or shell wrapper) that builds `CanonicalityBoundarySummary` from workspace diagnostics providers — empty route must not be permanent.
2. Add GoRouter widget test: open `/governance` with fixture graph → tap story/issue → expect `/assets/<id>` (and unresolved snackbar path).
3. Encode asset IDs in `detailRoute` / path params consistently.
4. Clear residual prefer_const infos in touched governance files.

## Task Ledger Patch Suggestion

```markdown
### 2026-07-09 independent re-review (reviewers)
- Report: `docs/reports/review-wave-2026-07-09/task-0813-governance-drilldown-storytelling-independent-rereview.md`
- Score: **82/100** — `REJECTED_TO_DOING`
- Lane: move `03-review/` → `02-doing/`
- Top blocker: production `/governance` still null summary; no real GoRouter drill-down proof
```
