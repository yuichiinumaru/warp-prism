# Review Report: Task 0901 — Asset Detail Route Contract — 2026-06-19

## Review Lineage

- **Current task**: Task 0901 (`0901-warp-prism-asset-detail-route-contract`); live path resolved from filesystem at `docs/tasks/03-review/0901-warp-prism-asset-detail-route-contract.md`.
- **Previous reports read**:
  - `docs/reports/build-gate-review/0901-review.md` — previous score `100/100`; now contradicted by live SDK availability and runtime wiring evidence.
- **Related reports considered**:
  - `docs/reports/build-gate-review/0902-review.md` through `0905-review.md` — downstream detail tasks depend on this route/selection contract.
- **Review mode**: `re-review` under reviewer profile `reviewers`.

## Score And Verdict

- **Score**: `58/100`
- **Verdict**: `REJECTED_TO_DOING`
- **Lane recommendation**: `return-to-doing`

## Axiom Compliance

| Axiom | Status | Evidence |
| --- | --- | --- |
| 1. Analyzer Integrity | FAIL | Flutter SDK is installed, but scoped asset-detail analysis reports `44 issues`; full app analysis reports `378 issues`. Previous `EXTERNAL_BLOCKER` claim is false. |
| 2. Lifecycle Safety | PASS | Task 0901 route/selection scope creates `0` disposable controllers/subscriptions/timers. `AssetSelectionController` is a Riverpod `Notifier`; no `dispose()` required. |
| 3. Dependency Direction | PARTIAL | Router is in `app/`, selection controller imports data models/services only; however production route bypasses the selection controller and descriptor pipeline. |
| 4. UI Accessibility | PARTIAL | `AssetDetailPage` has `2` `IconButton`s with tooltips (`lib/app/pages/asset_detail_page.dart:56`, `77`) but `0` explicit `Semantics` wrappers in that page. |
| 5. Proof Reality | FAIL | Claimed route tests do not instantiate `GoRouter`, do not navigate `/assets/:assetId`, do not verify `/asset/:id` redirect, and do not verify close/back route state. |
| 6. Release Security | PASS | No secrets, release signing, permissions, or debug print paths introduced in Task 0901 scope. |

## Delta Summary

### Resolved Since Previous Review
- `RESOLVED`: Flutter/Dart SDK availability is no longer an external blocker; commands can run locally.

### Persistent Findings
- `PERSISTENT`: Task evidence still says changelog is deferred (`docs/tasks/03-review/0901-warp-prism-asset-detail-route-contract.md:55`, `115`), and no `0901` changelog file exists in `docs/changelog/`.

### Regressions
- `REGRESSION`: The previous report accepted route/runtime wiring as complete, but live route wiring is placeholder-only and not connected to the selection controller.

### New Findings
- `NEW`: Canonical `/assets/:assetId` route renders `AssetDetailPage(assetId: assetId)` directly and never calls `assetSelectionControllerProvider`, `AssetSelectionController.select`, or the descriptor resolver (`apps/observatory/lib/app/router.dart:97-102`).
- `NEW`: `AssetDetailPage` treats any non-empty/non-`unknown` ID as resolved and renders “Detail view — coming soon” (`apps/observatory/lib/app/pages/asset_detail_page.dart:39-45`, `83-103`), so unknown IDs such as `agent:nonexistent` do not degrade through real graph resolution.

### Evidence Gaps / External Blockers
- `EVIDENCE_GAP`: No route widget test covers actual open/restore/close/legacy redirect despite the task exit condition requiring these flows.
- `EXTERNAL_BLOCKER`: none; Flutter and Dart SDKs are installed.

## Findings

| ID | Class | Severity | Status | Summary | First seen | Evidence |
| --- | --- | --- | --- | --- | --- | --- |
| F1 | REGRESSION | CRITICAL | Open | Production route does not wire route state into the selection controller or descriptor pipeline. | 2026-06-19 | `apps/observatory/lib/app/router.dart:97-102`; `apps/observatory/lib/app/asset_selection_controller.dart:140-154` |
| F2 | NEW | CRITICAL | Open | Valid-looking unknown asset IDs render a placeholder success detail instead of unresolved fallback from graph resolution. | 2026-06-19 | `apps/observatory/lib/app/pages/asset_detail_page.dart:39-45`, `83-103` |
| F3 | EVIDENCE_GAP | MODERATE | Open | Tests cover controller methods only; they never create `MaterialApp.router`, navigate `/assets/:assetId`, verify `/asset/:id`, or assert back/close URL behavior. | 2026-06-19 | `apps/observatory/test/app/asset_detail_route_test.dart:56-292` |
| F4 | PERSISTENT | LOW | Open | Task 0901 changelog remains missing/deferred. | 2026-06-13 | `docs/tasks/03-review/0901-warp-prism-asset-detail-route-contract.md:55`, `115` |
| F5 | NEW | MODERATE | Open | Analyzer integrity is not clean; scoped asset-detail analysis reports `44` warnings/info. | 2026-06-19 | command output: `flutter analyze lib/app/router.dart ... test/features/asset_detail` |

## Evidence Reviewed

- **Task file**: `docs/tasks/03-review/0901-warp-prism-asset-detail-route-contract.md`.
- **Previous report**: `docs/reports/build-gate-review/0901-review.md`.
- **Source/test files**:
  - `apps/observatory/lib/app/router.dart`
  - `apps/observatory/lib/app/pages/asset_detail_page.dart`
  - `apps/observatory/lib/app/asset_selection_controller.dart`
  - `apps/observatory/test/app/asset_detail_route_test.dart`
  - downstream asset-detail source/tests for wiring context.
- **Runtime wiring proof**: `/assets/:assetId` exists, but it terminates in placeholder `AssetDetailPage`; no production call path reaches `AssetSelectionController.select`, `resolveAssetDetail`, `buildAssetDetailDescriptor`, or `AssetDetailView` from the router.
- **Lifecycle count**: `0` disposable controllers/subscriptions/timers in Task 0901 route/selection scope; `0` missing disposals.
- **Accessibility count**: `2` `IconButton` instances in `AssetDetailPage`; `0` explicit `Semantics` wrappers there; `2` tooltips.
- **Commands run**:
  - `dart --version` — PASS (`Dart SDK version: 3.12.1`).
  - `flutter --version` — PASS (`Flutter 3.44.1`).
  - `HOME=... PUB_CACHE=... dart format --output=none --set-exit-if-changed lib test` — PASS, `142 files (0 changed)`.
  - `HOME=... PUB_CACHE=... flutter analyze` — FAIL, `378 issues found`.
  - `HOME=... PUB_CACHE=... flutter analyze lib/app/router.dart lib/app/pages/asset_detail_page.dart lib/app/asset_selection_controller.dart lib/features/asset_detail test/app/asset_detail_route_test.dart test/features/asset_detail` — FAIL, `44 issues found`.
  - `HOME=... PUB_CACHE=... flutter test test/app/asset_detail_route_test.dart` — PASS, `20` tests.
- **Commands not run and why**: none relevant to Task 0901.

## Path To 100

1. Replace placeholder `AssetDetailPage` routing with a real route-aware page that watches/uses normalized workspace graph state, calls `AssetSelectionController.select(assetId, origin: ...)`, and renders unresolved fallback for every missing ID.
2. Render `AssetDetailView` from an `AssetDetailDescriptor` built by `resolveAssetDetail`/`buildAssetDetailDescriptor`; do not show “coming soon” for known assets.
3. Add route widget tests that instantiate the production router and prove: `/assets/<id>` opens, refresh/deep-link restore resolves, `/asset/:id` redirects to `/assets/:id`, unknown ID shows fallback, close/back returns to recorded origin or documented default.
4. Add the missing Task 0901 changelog entry or update task evidence with the actual generated changelog file.
5. Reduce scoped analyzer issues to `0` warnings and `0` infos for the route/detail files and tests.

## Task Ledger Patch Suggestion

```markdown
| 2026-06-19 | reviewers | 58/100 | REJECTED_TO_DOING | `docs/reports/review-wave-2026-06-19/0901-asset-detail-route-contract-rereview.md` |

### Latest Review Notes
- `REGRESSION/CRITICAL`: `/assets/:assetId` exists but renders placeholder `AssetDetailPage` and does not use `AssetSelectionController` or descriptor resolution.
- `NEW/CRITICAL`: arbitrary unknown IDs render “Detail view — coming soon” instead of graph-backed unresolved fallback.
- `EVIDENCE_GAP`: route tests do not exercise the production router, legacy redirect, deep-link restore, or close/back URL behavior.
- `PERSISTENT/LOW`: Task 0901 changelog evidence is still deferred/missing.
```
