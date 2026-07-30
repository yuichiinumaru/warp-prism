# Review Report: Task 0413 — Shell States And Deep Link Fallbacks — 2026-06-19

## Review Lineage

- **Current task**: Task 0413 (`0413-warp-prism-shell-states-and-deep-link-fallbacks`); live path reviewed at `docs/tasks/03-review/0413-warp-prism-shell-states-and-deep-link-fallbacks.md` before lane routing.
- **Previous reports read**:
  - `docs/reports/build-gate-review/0413-review.md` — claimed `100/100`, approved with Flutter SDK unavailable.
  - `docs/reports/review-wave-2026-06-19/0410-app-root-router-shell-skeleton-independent-review.md` — upstream router rejection.
  - `docs/reports/review-wave-2026-06-19/0411-shell-navigation-responsive-frame-independent-review.md` — upstream shell rejection.
  - `docs/reports/review-wave-2026-06-19/0412-overview-dashboard-derived-metrics-independent-review.md` — upstream Overview provider wiring rejection.
- **Related reports considered**:
  - `docs/reports/build-gate-review/0410-review.md`, `0411-review.md`, `0412-review.md` — shared shell/runtime path.
  - `docs/reports/warp-prism-task-gap-overlap-audit.md` — shell states are shared fallback infrastructure for later feature surfaces.
- **Review mode**: re-review / independent runtime-wiring audit.

## Score And Verdict

- **Score**: `70/100`
- **Verdict**: `REJECTED_TO_DOING`
- **Lane recommendation**: `return-to-doing`

## Axiom Compliance

| Axiom | Status | Evidence |
| --- | --- | --- |
| Analyzer Integrity | FAIL | Scoped analyzer returned `29 issues found`; Task 0413-owned examples include unused import in `apps/observatory/lib/features/shell/shell_state_handler.dart:18`, const/deprecated issues at `shell_state_handler.dart:133`, `:135`, `:137`, `:155`, `:172`, `:185`, `:201`, `:202`. Full package analyze returned `378 issues found`. |
| Lifecycle Safety | PASS | `ShellStateHandler` is static/stateless and creates `0` controllers, `0` subscriptions, `0` timers, `0` listeners, requiring `0` disposals. `AssetDetailPage` is stateless. |
| Dependency Direction | PASS | Shell state handler depends on Flutter + UI package only (`shell_state_handler.dart:17-19`). App asset detail page imports shell handler through presentation/app layer (`asset_detail_page.dart:10-13`); no data/presentation inversion found in Task 0413 files. |
| UI Accessibility | PARTIAL | Task-owned interactive widgets: `2` `OutlinedButton.icon` in unresolved fallback (`shell_state_handler.dart:165`, `:179`) and `2` `IconButton`s in asset detail app bars (`asset_detail_page.dart:56`, `:77`). Buttons have visible text or tooltips. Explicit `Semantics` in Task 0413 files: `0`; behavior relies on Material/DSStateSurface defaults. |
| Proof Reality | FAIL | Tests prove the widget builder when directly invoked, but router deep-link resolution treats any non-empty/non-`unknown` ID as resolved (`asset_detail_page.dart:39-45`), so real missing assets like `/assets/agent:nonexistent` render the detail placeholder instead of fallback. |
| Release Security | PASS | Reviewed Task 0413 files add no endpoints, secrets, signing config, release flags, `print()`, or `debugPrint()` calls. |

## Delta Summary

### Resolved Since Previous Review

- `RESOLVED`: Targeted shell-state and deep-link fallback tests execute and pass as part of `48/48` targeted test run.
- `RESOLVED`: Reusable loading/empty/error/unresolved fallback builder exists in `ShellStateHandler`.

### Persistent Findings

- `PERSISTENT`: Upstream Tasks 0410, 0411, and 0412 remain rejected; shell fallback can be helper-tested but cannot be accepted as fully integrated EPIC-04 behavior yet.
- `PERSISTENT`: Previous report's SDK-unavailable validation is stale.

### Regressions

- `REGRESSION`: None proven against a previously clean runtime state.

### New Findings

- `NEW`: Real unresolved asset IDs are not resolved against workspace data. Any non-empty asset ID defaults to `resolved = true`, producing a false-positive detail page.
- `NEW`: Analyzer integrity fails on shell-state task files.

### Evidence Gaps / External Blockers

- `EVIDENCE_GAP`: No router test verifies `/assets/<missing-real-id>` against repository/provider lookup.
- `EXTERNAL_BLOCKER`: None.

## Findings

| ID | Class | Severity | Status | Summary | First seen | Evidence |
| --- | --- | --- | --- | --- | --- | --- |
| F1 | NEW | High | Open | Asset-detail fallback is not data-backed. Non-empty missing IDs are considered resolved and render placeholder detail. | 2026-06-19 | `apps/observatory/lib/app/pages/asset_detail_page.dart:24-45`; `apps/observatory/test/app/deep_link_fallback_test.dart:53-64` |
| F2 | PERSISTENT | High | Open | Upstream Task 0410/0411/0412 route/shell/overview blockers remain open. | 2026-06-19 | `docs/reports/review-wave-2026-06-19/0410-app-root-router-shell-skeleton-independent-review.md`; `0411...md`; `0412...md` |
| F3 | NEW | Moderate | Open | Analyzer fails in task-owned shell-state files. | 2026-06-19 | `apps/observatory/lib/features/shell/shell_state_handler.dart:18`; `:172` |
| F4 | EVIDENCE_GAP | Moderate | Open | Loading/empty/error builders are helper-tested, but not wired to a real provider `AsyncValue` load/error state in routed product pages. | 2026-06-19 | `apps/observatory/lib/app/pages/overview_page.dart:45-63`; `apps/observatory/test/features/shell/shell_state_handler_test.dart:23-247` |

## Evidence Reviewed

- **Task file**: `docs/tasks/03-review/0413-warp-prism-shell-states-and-deep-link-fallbacks.md`.
- **Source/test files**: `apps/observatory/lib/features/shell/shell_state_handler.dart`, `features/shell/shell.dart`, `app/pages/asset_detail_page.dart`, `app/router.dart`, `test/features/shell/shell_state_handler_test.dart`, `test/app/deep_link_fallback_test.dart`, and upstream overview shell file.
- **Runtime wiring proof**: Canonical route `/assets/:assetId` builds `AssetDetailPage(assetId: assetId)` (`apps/observatory/lib/app/router.dart:97-102`). `AssetDetailPage` calls `ShellStateHandler.buildUnresolvedAssetFallback()` only when `assetId.isEmpty`, `assetId == 'unknown'`, or constructor `resolved == false` (`asset_detail_page.dart:37-65`). There is no repository lookup in the route or page. Therefore helper code is runtime-reachable only for empty/unknown or manually injected `resolved: false`, not for real missing asset deep links.
- **Commands run**:
  - `dart format --set-exit-if-changed lib/app lib/features/overview lib/features/shell test/app/app_shell_smoke_test.dart test/app/shell_responsive_layout_test.dart test/features/overview test/features/shell test/app/deep_link_fallback_test.dart` — PASS, `22 files (0 changed)`.
  - `flutter analyze lib/app lib/features/overview lib/features/shell test/app/app_shell_smoke_test.dart test/app/shell_responsive_layout_test.dart test/app/deep_link_fallback_test.dart test/features/overview test/features/shell` — FAIL, `29 issues found`.
  - `flutter analyze` — FAIL, `378 issues found`.
  - `flutter test test/app/app_shell_smoke_test.dart test/app/shell_responsive_layout_test.dart test/features/overview/overview_provider_test.dart test/features/overview/overview_page_test.dart test/features/shell/shell_state_handler_test.dart test/app/deep_link_fallback_test.dart` — PASS, `48/48`.
- **Commands not run and why**: `dart pub outdated` not run because package-registry network access was not requested.

## Stale-Evidence Notes

- Completion evidence and previous review claim Flutter SDK was absent. Current environment has Flutter and Dart; the stale blocker is superseded by actual analyzer/test results.

## Path To 100

1. Wire asset detail fallback to the real normalized workspace repository/provider: resolve `assetId` before rendering detail, and render fallback for any missing ID, not only `unknown`.
2. Add a router-level test for `/assets/agent:does-not-exist` using the real route and provider override; assert fallback renders.
3. Wire loading/error/empty state handling through real provider load states (for example `AsyncValue` or current `WorkspaceLoadState`) instead of demo-only direct builder tests.
4. Fix analyzer issues in `shell_state_handler.dart` and focused tests; replace `.withOpacity()` with `.withValues()` or approved compatibility helper.
5. Resolve upstream Tasks 0410-0412 and rerun clean scoped/full analyzer and targeted tests.

## Lane-Neutral References

Task identity is Task 0413. Old lane-specific paths and root-level `lib/...` claims are not blockers by themselves; live router/provider falsehoods and analyzer failures are blockers.

## Task Ledger Patch Suggestion

```markdown
### Latest Review

- **Date**: 2026-06-19
- **Reviewer profile**: `reviewers`
- **Score**: `70/100`
- **Verdict**: `REJECTED_TO_DOING`
- **Full report**: `docs/reports/review-wave-2026-06-19/0413-shell-states-deep-link-fallbacks-independent-review.md`
- **Lane outcome**: returned to doing
- **Task reference**: Task 0413 (`0413-warp-prism-shell-states-and-deep-link-fallbacks`)

#### Current Open Blockers

- `NEW`: real missing asset IDs are not data-resolved; any non-empty ID renders detail placeholder unless `resolved: false` is injected by tests.
- `PERSISTENT`: upstream Tasks 0410-0412 remain rejected.
- `NEW`: scoped analyzer fails with `29` issues; full package analyzer fails with `378`.
- `EVIDENCE_GAP`: shell state builders are helper-tested but not provider-load-state integrated.

#### Path-to-100 Summary

- Resolve asset IDs through the real repository/provider, add router-level missing-ID tests, integrate state builders with provider load/error/empty states, clear analyzer issues, and rerun validation after upstream fixes.
```
