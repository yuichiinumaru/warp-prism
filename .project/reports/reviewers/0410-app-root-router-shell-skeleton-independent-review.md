# Review Report: Task 0410 — App Root Router Shell Skeleton — 2026-06-19

## Review Lineage

- **Current task**: Task 0410 (`0410-warp-prism-app-root-router-shell-skeleton`); live path reviewed at `docs/tasks/03-review/0410-warp-prism-app-root-router-shell-skeleton.md` before lane routing.
- **Previous reports read**:
  - `docs/reports/build-gate-review/0410-review.md` — claimed `100/100`, approved with Flutter SDK unavailable.
  - `docs/reports/review-wave-3/0011-review.md` via Task 0011 ledger — `68/100`, rejected; relevant because Task 0410 depends on the bootstrap route contract.
- **Related reports considered**:
  - `docs/reports/build-gate-review/0411-review.md`, `0412-review.md`, `0413-review.md` — downstream shell/overview reports share the same router/runtime path.
  - `docs/reports/warp-prism-task-gap-overlap-audit.md` — establishes Task 0410 consumes Task 0011 and must not own a competing bootstrap.
- **Review mode**: re-review / independent runtime-wiring audit.

## Score And Verdict

- **Score**: `68/100`
- **Verdict**: `REJECTED_TO_DOING`
- **Lane recommendation**: `return-to-doing`

## Axiom Compliance

| Axiom | Status | Evidence |
| --- | --- | --- |
| Analyzer Integrity | FAIL | Flutter SDK is present. `flutter analyze lib/app lib/features/overview lib/features/shell test/app/app_shell_smoke_test.dart test/app/shell_responsive_layout_test.dart test/app/deep_link_fallback_test.dart test/features/overview test/features/shell` returned `29 issues found`; full `flutter analyze` returned `378 issues found`. Task-owned examples include `apps/observatory/lib/features/overview/overview_page.dart:12`, `overview_provider.dart:13`, `shell_state_handler.dart:18`, and `test/app/shell_responsive_layout_test.dart:16`. |
| Lifecycle Safety | PASS | Task 0410 runtime files create `0` `TextEditingController`, `0` `ScrollController`, `0` `AnimationController`, `0` `StreamSubscription`, `0` `Timer`, `0` direct listeners, and require `0` task-owned disposals. |
| Dependency Direction | PARTIAL | Router imports app pages and feature pages from the app layer (`apps/observatory/lib/app/router.dart:1-11`), but Task 0410 depends on Task 0011 and Task 0011 remains rejected in `docs/tasks/02-doing/0011-warp-prism-bootstrap-main-router-shell.md:139-152`. |
| UI Accessibility | PARTIAL | Task-owned interactive widgets: `1` `BottomNavigationBar` in `apps/observatory/lib/app/app_shell.dart:166`, `2` `IconButton`s in `apps/observatory/lib/app/pages/asset_detail_page.dart:56` and `:77`. Both IconButtons have tooltips; the bottom nav relies on labels from `AppShell.navItems` (`app_shell.dart:22-44`). No new task-owned raw `Semantics` wrappers exist in app files. |
| Proof Reality | FAIL | Previous report says Flutter SDK unavailable (`docs/reports/build-gate-review/0410-review.md:15-17`), but `/home/sephiroth/flutter/bin/flutter` and `/home/sephiroth/flutter/bin/dart` exist. Smoke tests pass only after manually navigating to `/overview`; the production router starts at `/design-system` (`apps/observatory/lib/app/router.dart:35-36`) while Task 0410 claims `/` redirects to `/overview` and default shell landing (`docs/tasks/03-review/0410...md:40-42`, `:134-135`). |
| Release Security | PASS | Reviewed Task 0410 files add no endpoints, secrets, signing config, release flags, `print()`, or `debugPrint()` calls. |

## Delta Summary

### Resolved Since Previous Review

- `RESOLVED`: Flutter/Dart SDK availability is no longer blocked; commands can run with in-repo `HOME`, `PUB_CACHE`, and `TMPDIR`.
- `RESOLVED`: Targeted smoke and shell/overview/fallback tests execute: `48/48` targeted tests passed.

### Persistent Findings

- `PERSISTENT`: Task 0011 prerequisite remains rejected; Task 0410 cannot be final-approved while its bootstrap dependency is still in `02-doing` with open route/evidence blockers.
- `PERSISTENT`: The live startup path does not land on the product shell; `appRouter.initialLocation` is `/design-system`, not `/overview`.

### Regressions

- `REGRESSION`: None proven against a previously accepted live state. The earlier `100/100` report was based on unavailable analyzer/test tooling, not passing runtime evidence.

### New Findings

- `NEW`: Task-scoped analyzer is not clean; `29` scoped analyzer issues include task-owned unused imports and const/deprecation lints.

### Evidence Gaps / External Blockers

- `EVIDENCE_GAP`: Task 0410 still lacks a test that proves the production default app startup renders the Overview shell without manually calling `appRouter.go('/overview')`.
- `EXTERNAL_BLOCKER`: None. Flutter SDK is available in this environment.

## Findings

| ID | Class | Severity | Status | Summary | First seen | Evidence |
| --- | --- | --- | --- | --- | --- | --- |
| F1 | PERSISTENT | High | Open | Bootstrap dependency Task 0011 is rejected, so Task 0410's route skeleton sits on an unapproved foundation. | 2026-06-17 Task 0011 report | `docs/tasks/02-doing/0011-warp-prism-bootstrap-main-router-shell.md:139-152` |
| F2 | PERSISTENT | High | Open | Production app startup is `/design-system`, while Task 0410 requires product shell default/Overview route proof. | 2026-06-17 Task 0011 report | `apps/observatory/lib/app/router.dart:35-36`; `apps/observatory/test/app/app_shell_smoke_test.dart:15-18` |
| F3 | NEW | Moderate | Open | Analyzer integrity is false: task-scoped analyze returns `29` issues; full package analyze returns `378`. | 2026-06-19 | `apps/observatory/lib/features/overview/overview_page.dart:12`; `apps/observatory/lib/features/shell/shell_state_handler.dart:18` |
| F4 | EVIDENCE_GAP | Moderate | Open | Previous report's SDK-unavailable proof is stale; current task evidence still says Flutter SDK not installed. | 2026-06-19 | `docs/tasks/03-review/0410-warp-prism-app-root-router-shell-skeleton.md:134-135`; `docs/reports/build-gate-review/0410-review.md:15-17` |

## Evidence Reviewed

- **Task file**: `docs/tasks/03-review/0410-warp-prism-app-root-router-shell-skeleton.md`.
- **Source/test files**: `apps/observatory/lib/main.dart`, `app/app.dart`, `app/router.dart`, `app/app_shell.dart`, `app/pages/asset_detail_page.dart`, `test/app/app_shell_smoke_test.dart`, `test/app/shell_responsive_layout_test.dart`, and downstream shell/overview/fallback files needed for compile reachability.
- **Runtime wiring proof**: `main()` calls `runApp(const ProviderScope(child: WarpPrismApp()))` (`apps/observatory/lib/main.dart:5-6`); `WarpPrismApp` uses `MaterialApp.router(routerConfig: appRouter)` (`app/app.dart:14-19`); `appRouter` wraps `/overview`, `/map`, `/operate`, `/history`, and `/governance` in `StatefulShellRoute.indexedStack` using `AppShell` (`app/router.dart:35-89`). The same proof also exposes the blocker: production initial location is `/design-system` (`app/router.dart:35-36`), outside `AppShell`.
- **Commands run**:
  - `git status --short && command -v flutter || true && command -v dart || true` — Flutter and Dart found; many pre-existing/unrelated worktree changes present.
  - `dart format --set-exit-if-changed lib/app lib/features/overview lib/features/shell test/app/app_shell_smoke_test.dart test/app/shell_responsive_layout_test.dart test/features/overview test/features/shell test/app/deep_link_fallback_test.dart` — PASS, `22 files (0 changed)`.
  - `flutter analyze lib/app lib/features/overview lib/features/shell test/app/app_shell_smoke_test.dart test/app/shell_responsive_layout_test.dart test/app/deep_link_fallback_test.dart test/features/overview test/features/shell` — FAIL, `29 issues found`.
  - `flutter analyze` — FAIL, `378 issues found`.
  - `flutter test test/app/app_shell_smoke_test.dart test/app/shell_responsive_layout_test.dart test/features/overview/overview_provider_test.dart test/features/overview/overview_page_test.dart test/features/shell/shell_state_handler_test.dart test/app/deep_link_fallback_test.dart` — PASS, `48/48`.
- **Commands not run and why**: `dart pub outdated` was not run because the review did not have permission to make network/package-registry calls; package versions were read from `pubspec.yaml` instead.

## Stale-Evidence Notes

- Completion evidence and previous build-gate report cite `lib/...` paths and Flutter SDK absence. Current monorepo paths are `apps/observatory/lib/...`, and the SDK is available. Lane-neutral stale path references alone are not scored down; false current validation claims are scored down.

## Path To 100

1. Resolve Task 0011 first or explicitly supersede its rejected default-route contract.
2. Decide the production initial route. If Task 0410 owns product shell startup, change `appRouter.initialLocation` to `/overview` or add a documented exception and update Task 0410.
3. Rewrite `test/app/app_shell_smoke_test.dart` so the default startup assertion does **not** call `appRouter.go('/overview')` before checking the shell.
4. Fix task-scoped analyzer issues in `apps/observatory/lib/app`, `features/overview`, `features/shell`, and the focused tests; then run clean scoped and package analyzer gates.
5. Replace stale Flutter-SDK-blocked completion evidence with the actual command outputs.

## Lane-Neutral References

Task identity is Task 0410. Historical lane strings in old evidence are not blockers by themselves; this rejection is based on current runtime/default-route proof and analyzer/proof reality failures.

## Task Ledger Patch Suggestion

```markdown
### Latest Review

- **Date**: 2026-06-19
- **Reviewer profile**: `reviewers`
- **Score**: `68/100`
- **Verdict**: `REJECTED_TO_DOING`
- **Full report**: `docs/reports/review-wave-2026-06-19/0410-app-root-router-shell-skeleton-independent-review.md`
- **Lane outcome**: returned to doing
- **Task reference**: Task 0410 (`0410-warp-prism-app-root-router-shell-skeleton`)

#### Current Open Blockers

- `PERSISTENT`: Task 0011 bootstrap prerequisite remains rejected.
- `PERSISTENT`: production startup uses `/design-system`, while Task 0410 requires default product shell/Overview proof.
- `NEW`: scoped analyzer fails with `29` issues; full package analyzer fails with `378` issues.
- `EVIDENCE_GAP`: smoke test manually navigates to `/overview` instead of proving default startup.

#### Path-to-100 Summary

- Resolve Task 0011, reconcile initial route, remove manual navigation from smoke proof, and rerun clean analyzer/test gates with current `apps/observatory/` paths.
```
