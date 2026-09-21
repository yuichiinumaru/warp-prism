# Review Report: Task 0905 — Responsive Detail Shell Integration — 2026-07-09

## Review Lineage

- **Current task**: Task 0905 (`0905-warp-prism-responsive-detail-shell-integration`); live path at review start: `docs/tasks/03-review/0905-warp-prism-responsive-detail-shell-integration.md`
- **Previous reports read**:
  - `docs/reports/review-wave-2026-06-19/0905-responsive-detail-shell-integration-rereview.md` — **54/100** `REJECTED_TO_DOING`
  - `docs/reports/build-gate-review/0905-review.md` — historical 100
- **Related reports considered**:
  - Tasks 0901–0904 (route + variants now production-capable)
- **Review mode**: `re-review` / independent reviewers-wave 2026-07-09
- **Reviewer profile**: `reviewers` (gt-flutter-code-reviewer + gt-code-quality-reviewer)

## Score And Verdict

- **Score**: `84/100` — Good
- **Verdict**: `REJECTED_TO_DOING`
- **Lane recommendation**: `return-to-doing` (S < 90)

Responsive shell mechanics are solid and tested (**25/25**): wide split, medium overlay, narrow full-screen + back semantics. `AssetDetailConsumer` now wires **Map and Operate**. History uses `ResponsiveDetailShell` ×3. Canonical deep-link `/assets/:assetId` renders real universal detail (outside shell — documented focused inspection). Remaining gaps vs task How/intent: Map/History/Operate still inject **surface-local inspectors** (`MapInspectorPanel`, History `_buildDetailPanel`, `OperateTaskDetailPanel`) rather than shared `AssetDetailView`; medium scrim is unlabeled `GestureDetector`; no production route×breakpoint integration tests; Governance uses full-page `context.go` only (acceptable alternate, but not the shared shell contract).

## Delta Summary

### Resolved Since Previous Review

- `RESOLVED` (partial F1): Operate now uses `AssetDetailConsumer` (was 0 usages).
- `RESOLVED` (partial F1): Map continues `AssetDetailConsumer`; History continues `ResponsiveDetailShell`.
- `RESOLVED` (F3 partial): `/assets/:assetId` no longer placeholder — mounts universal detail page (not responsive shell modes).
- `RESOLVED`: Lifecycle still safe (`AnimationController` disposed).
- `RESOLVED`: Shell tests still **25/25**.
- `RESOLVED`: Changelog evidence exists (prior note).

### Persistent Findings

- `PERSISTENT` (F2): Shared shell does not render universal `AssetDetailView` on Map/History; local inspectors remain.
- `PERSISTENT` (F4): Medium overlay scrim still unlabeled `GestureDetector` (narrow back has Semantics).
- `PERSISTENT` (F6): Responsive tests use generic placeholders, not production Map/Operate/History/router flows.

### Regressions

- None.

### New Findings

- `NEW` / Medium: Operate uses shared shell but `OperateTaskDetailPanel` content path — open/close contract met; universal descriptor path not used.
- `NEW` / Low: Scoped analyze shows prefer_const infos in operate workspace (not errors).
- `NEW` / Low: Governance consumer remains route-only drill-down (not `AssetDetailConsumer`) — consistent with focused asset route, incomplete vs “all four surfaces identical shell”.

### Evidence Gaps / External Blockers

- `EVIDENCE_GAP`: No widget test that pumps Map/Operate/History production pages across wide/medium/narrow and asserts shell mode + close/back.
- Task 0903 was mid-flight earlier; variants exist now — not a blocker for shell validation.

## Six Axiom Compliance

| # | Axiom | Status | Evidence |
| --- | --- | --- | --- |
| 1 | Analyzer Integrity | **PASS** (errors) | infos only in operate/map scope |
| 2 | Lifecycle Safety | **PASS** | overlay controller disposed |
| 3 | Dependency Direction | **PASS** | shell presentation layering ok |
| 4 | UI Accessibility | **PARTIAL** | narrow back Semantics; medium scrim unlabeled |
| 5 | Proof Reality | **PARTIAL** | 25/25 shell mechanics; consumer product content not universal |
| 6 | Release Security | **PASS** | Read-only |

## Findings

| ID | Class | Severity | Status | Summary | First seen | Evidence |
| --- | --- | --- | --- | --- | --- | --- |
| F1 | RESOLVED | Critical | Closed (Operate) | Operate lacked shared consumer | 2026-06-19 | `operate_workspace_view.dart:64` AssetDetailConsumer |
| F1b | PERSISTENT | Medium | Open | Map/History/Operate detail *content* still local | 2026-06-19 / 2026-07-09 | MapInspectorPanel; History `_buildDetailPanel`; OperateTaskDetailPanel |
| F2 | PERSISTENT | Serious | Open | Shared shell not injecting universal AssetDetailView | 2026-06-19 | detailBuilder callbacks return surface panels |
| F3 | RESOLVED | Critical | Closed (placeholder) | Deep-link placeholder page | 2026-06-19 | AssetDetailPage + AssetDetailView |
| F3b | NEW | Debt | Open | Deep-link outside responsive breakpoints | 2026-07-09 | router places asset route outside shell |
| F4 | PERSISTENT | Medium | Open | Unlabeled medium scrim | 2026-06-19 | `responsive_detail_shell.dart:138-150` |
| F5 | RESOLVED | Moderate | Closed (errors) | 44 analyzer issues | 2026-06-19 | infos only now |
| F6 | PERSISTENT | Medium | Open | Tests lack production consumer proof | 2026-06-19 | responsive_detail_integration_test placeholders |

## Exit Conditions (live)

| # | Condition | Met? | Live proof |
| --- | --- | --- | --- |
| 1 | Shell supports split/overlay/full-screen | **YES** | ResponsiveDetailShell + 25 tests |
| 2 | Consumers open/close via shared contract | **PARTIAL** | Map/Operate/History use shell; content still local; Governance route-only |
| 3 | Widget tests breakpoints + open/close/back | **YES** (shell-only) | 25/25 |
| 4–6 | format/analyze/test | **YES** (errors free) | 25/25; infos remain |
| 7 | Changelog | **YES** | existing repair-bot note |

Task How #3 (“Inject the shared detail view … instead of recreating screen-local inspectors”) is **not** fully met.

## Evidence Reviewed

- `responsive_detail_shell.dart`, `asset_detail_consumer.dart`
- `map_workspace_page.dart`, `operate_workspace_view.dart`, `history_page.dart`
- `governance_overview_page.dart` drilldown path
- `router.dart`, `asset_detail_page.dart`
- `master_detail_template.dart` / `ds_shell.dart` (prior contract alignment)
- `responsive_detail_integration_test.dart`

## Commands Run

```text
# apps/observatory
flutter analyze --no-pub \
  lib/features/asset_detail/presentation/responsive_detail_shell.dart \
  lib/features/asset_detail/presentation/asset_detail_consumer.dart \
  lib/features/map/map_workspace_page.dart \
  lib/features/operate/operate_workspace_view.dart \
  test/features/asset_detail/responsive_detail_integration_test.dart
# → infos only (prefer_const), 0 errors

flutter test --concurrency=1 --no-pub \
  test/features/asset_detail/responsive_detail_integration_test.dart
# → +25 All tests passed!
```

Flutter 3.44.1 / Dart 3.12.1.

## Path To 100

1. Drive Map/History (and ideally Operate) `detailBuilder` through descriptor provider → `AssetDetailView` (keep surface chrome only if necessary).
2. Add Semantics/button role + label on medium scrim dismiss.
3. Add integration tests pumping production Map/Operate/History pages at 1200/1000/600 widths for open/close/back.
4. Document deep-link full-page vs in-shell breakpoints as intentional contract (or unify).
5. Clear prefer_const infos in operate scope.

## Task Ledger Patch Suggestion

```markdown
### 2026-07-09 independent re-review (reviewers)
- Report: `docs/reports/review-wave-2026-07-09/task-0905-responsive-detail-shell-integration-independent-rereview.md`
- Score: **84/100** — `REJECTED_TO_DOING`
- Lane: move `03-review/` → `02-doing/`
- Top blocker: shared shell still hosts surface-local inspectors, not universal AssetDetailView
```
