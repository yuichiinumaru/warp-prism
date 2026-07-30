# Review Report: Task 0901 — Asset Detail Route Contract — 2026-07-09

## Review Lineage

- **Current task**: Task 0901 (`0901-warp-prism-asset-detail-route-contract`); live path: `docs/tasks/03-review/0901-warp-prism-asset-detail-route-contract.md`
- **Previous reports read**:
  - `docs/reports/review-wave-2026-06-19/0901-asset-detail-route-contract-rereview.md` — **58/100** `REJECTED_TO_DOING`
  - `docs/reports/build-gate-review/0901-review.md` — historical 100
- **Related reports considered**:
  - Tasks 0902–0905 (descriptor + variants + shell consumers)
- **Review mode**: `re-review` / independent reviewers-wave 2026-07-09
- **Reviewer profile**: `reviewers` (gt-flutter-code-reviewer + gt-code-quality-reviewer)

## Score And Verdict

- **Score**: `95/100` — Elite
- **Verdict**: `HELD_IN_REVIEW_PATH_TO_100`
- **Lane recommendation**: `hold-in-review` (S ≥ 90; **do not** move to `04-completed/`)

Canonical `/assets/:assetId` + legacy redirect are live. `AssetDetailPage` resolves via graph-backed `assetDetailDescriptorProvider`, mounts `AssetDetailView` when resolved, and shows shell unresolved fallback for empty/unknown/missing graph assets. GoRouter widget tests cover open, unknown, legacy redirect, close/back, and missing-graph degradation. Scoped analyze clean; **33/33** route+deep-link tests pass. Changelog present.

## Delta Summary

### Resolved Since Previous Review

- `RESOLVED` (F1): Route no longer ends in “coming soon” placeholder — renders mapper-backed `AssetDetailView`.
- `RESOLVED` (F2): Unknown / missing graph assets degrade to unresolved fallback (not fake success).
- `RESOLVED` (F3): GoRouter contract tests exist (deep-link open, redirect, close/back, missing asset).
- `RESOLVED` (F4): Changelog `docs/changelog/20260709-160937-0901-asset-detail-route-contract-builders.md`.
- `RESOLVED` (F5): Scoped analyze on route/page/controller/tests — **No issues found**.

### Persistent Findings

- None blocking.

### Regressions

- None.

### New Findings

- `NEW` / Low: Deep-link page resolves via `assetDetailDescriptorProvider` and does **not** call `AssetSelectionController.select` — dual resolution paths (selection controller vs descriptor family) can diverge if surfaces assume selection state is set by the route.
- `NEW` / Low: `detailRoute` does not URL-encode asset IDs containing `:` / reserved characters (shared residual with governance drill-down).

### Evidence Gaps / External Blockers

- None blocking exit conditions.

## Six Axiom Compliance

| # | Axiom | Status | Evidence |
| --- | --- | --- | --- |
| 1 | Analyzer Integrity | **PASS** | Scoped: No issues found |
| 2 | Lifecycle Safety | **PASS** | ConsumerWidget; no local controllers |
| 3 | Dependency Direction | **PASS** | app page → feature controller/view |
| 4 | UI Accessibility | **PASS** (delegated) | Back IconButton + tooltip; fallback via ShellStateHandler |
| 5 | Proof Reality | **PASS** | 33/33 including GoRouter + mapper-backed known agent |
| 6 | Release Security | **PASS** | Read-only deep-link surface |

## Findings

| ID | Class | Severity | Status | Summary | First seen | Evidence |
| --- | --- | --- | --- | --- | --- | --- |
| F1 | RESOLVED | Critical | Closed | Placeholder route / no selection pipeline | 2026-06-19 | `asset_detail_page.dart:44-75` |
| F2 | RESOLVED | Critical | Closed | Unknown IDs fake success | 2026-06-19 | unresolved branch + tests |
| F3 | RESOLVED | Moderate | Closed | No GoRouter widget tests | 2026-06-19 | `asset_detail_route_test.dart` GoRouter group |
| F4 | RESOLVED | Low | Closed | Missing changelog | 2026-06-19 | 20260709-160937 changelog |
| F5 | NEW | Low | Open | Route does not sync `AssetSelectionController` | 2026-07-09 | page watches descriptor only |
| F6 | NEW | Low | Open | Unencoded detail paths | 2026-07-09 | `detailRoute` helper |

## Exit Conditions (live)

| # | Condition | Met? | Live proof |
| --- | --- | --- | --- |
| 1 | Canonical route documented | **YES** | `router.dart` contract comments + path |
| 2 | Selection/resolve controller covers empty/unknown | **YES** | `AssetSelectionController` + descriptor provider |
| 3 | Tests open/restore/close/unknown | **YES** | GoRouter + deep_link suites |
| 4 | format scoped | **YES** (claimed; not re-run format this pass) | prior + clean analyze |
| 5 | analyze scoped | **YES** | No issues |
| 6 | flutter test route + deep-link | **YES** | **33/33** |
| 7 | Changelog | **YES** | 20260709-160937 |

## Evidence Reviewed

- `router.dart`, `asset_detail_page.dart`, `asset_selection_controller.dart`
- `asset_detail_route_test.dart`, `deep_link_fallback_test.dart`
- Task completion evidence + 2026-06-19 re-review

## Commands Run

```text
# apps/observatory
flutter analyze --no-pub \
  lib/app/router.dart lib/app/pages/asset_detail_page.dart \
  lib/app/asset_selection_controller.dart \
  test/app/asset_detail_route_test.dart test/app/deep_link_fallback_test.dart
# → No issues found

flutter test --concurrency=1 --no-pub \
  test/app/asset_detail_route_test.dart test/app/deep_link_fallback_test.dart
# → +33 All tests passed!
```

Flutter 3.44.1 / Dart 3.12.1.

## Path To 100

1. On deep-link open, optionally sync `AssetSelectionController.select(assetId, origin: ...)` so selection and descriptor providers agree.
2. Encode/decode asset path parameters safely for colon-bearing IDs.
3. Optionally assert format gate live in ledger for completeness.

## Task Ledger Patch Suggestion

```markdown
### 2026-07-09 independent re-review (reviewers)
- Report: `docs/reports/review-wave-2026-07-09/task-0901-asset-detail-route-contract-independent-rereview.md`
- Score: **95/100** — `HELD_IN_REVIEW_PATH_TO_100`
- Lane: remain `03-review/`
```
