# Review Report: Task 0411 — Shell Navigation And Responsive Frame — 2026-06-19

## Review Lineage

- **Current task**: Task 0411 (`0411-warp-prism-shell-navigation-and-responsive-frame`); live path reviewed at `docs/tasks/03-review/0411-warp-prism-shell-navigation-and-responsive-frame.md` before lane routing.
- **Previous reports read**:
  - `docs/reports/build-gate-review/0411-review.md` — claimed `100/100`, approved with Flutter SDK unavailable.
  - `docs/reports/review-wave-2026-06-19/0410-app-root-router-shell-skeleton-independent-review.md` — current upstream rejection affecting shell startup proof.
  - `docs/reports/review-wave-3/0011-review.md` via Task 0011 ledger — `68/100`, rejected bootstrap prerequisite.
- **Related reports considered**:
  - `docs/reports/build-gate-review/0410-review.md`, `0412-review.md`, `0413-review.md` — shared router/shell/overview path.
  - `docs/reports/warp-prism-task-gap-overlap-audit.md` — establishes Task 0411 consumes Task 0410 and design-system API coherence.
- **Review mode**: re-review / independent runtime-wiring audit.

## Score And Verdict

- **Score**: `72/100`
- **Verdict**: `REJECTED_TO_DOING`
- **Lane recommendation**: `return-to-doing`

## Axiom Compliance

| Axiom | Status | Evidence |
| --- | --- | --- |
| Analyzer Integrity | FAIL | Flutter SDK is available. Scoped analyzer returned `29 issues found`; full package analyzer returned `378 issues found`. Task-owned examples: `apps/observatory/test/app/shell_responsive_layout_test.dart:16`, `apps/observatory/lib/features/overview/overview_page.dart:12`, `apps/observatory/lib/features/shell/shell_state_handler.dart:18`. |
| Lifecycle Safety | PASS | Task-owned `apps/observatory/lib/app/app_shell.dart` creates `0` controllers, `0` subscriptions, `0` timers, and `0` listeners. It requires `0` disposals. Design-system `DSSidebar`/`DSTopbarAction` own FocusNodes and dispose them in their package files, but Task 0411 did not create those lifecycle objects directly. |
| Dependency Direction | PARTIAL | App shell imports `go_router` and design-system compatibility only (`apps/observatory/lib/app/app_shell.dart:1-3`). However, it depends on rejected upstream Task 0410/0011 route startup state. |
| UI Accessibility | PARTIAL | Task-owned interactive widgets: `1` `BottomNavigationBar` (`apps/observatory/lib/app/app_shell.dart:166`) with `5` labeled items derived from `AppShell.navItems` (`app_shell.dart:22-44`). The wide shell uses `DSSidebar`, whose package implementation has `1` sidebar `Semantics` wrapper and per-item semantics (`packages/warp_prism_ui/lib/src/organisms/ds_sidebar.dart:30-33`, `:208-214`). No task-owned touch-target measurement test exists. |
| Proof Reality | FAIL | The responsive test does not instantiate the production `AppShell`; it uses `_FakeNavigationShell` and reimplements the branch logic (`apps/observatory/test/app/shell_responsive_layout_test.dart:34-111`). The smoke test manually navigates to `/overview` because production initial location is `/design-system` (`app_shell_smoke_test.dart:15-18`; `app/router.dart:35-36`). |
| Release Security | PASS | Reviewed Task 0411 files add no secrets, endpoints, release config, `print()`, or `debugPrint()` calls. |

## Delta Summary

### Resolved Since Previous Review

- `RESOLVED`: Flutter/Dart SDK is available; targeted tests can run.
- `RESOLVED`: Targeted tests including shell responsive tests pass: `48/48` across reviewed shell/overview/fallback set.

### Persistent Findings

- `PERSISTENT`: Upstream Task 0410/0011 startup-route blockers remain open, so Task 0411 shell cannot be accepted as product-runtime-default proof.

### Regressions

- `REGRESSION`: None proven. The earlier `100/100` approval relied on manual review under a now-stale SDK-unavailable premise.

### New Findings

- `NEW`: Responsive test coverage is weaker than claimed because `_FakeNavigationShell` reimplements shell layout rather than pumping production `AppShell` with real `StatefulShellRoute`.
- `NEW`: Analyzer integrity fails on the task-scoped file set.

### Evidence Gaps / External Blockers

- `EVIDENCE_GAP`: No direct production `AppShell` narrow-layout test proves the actual router shell uses bottom navigation under `<600px`.
- `EXTERNAL_BLOCKER`: None.

## Findings

| ID | Class | Severity | Status | Summary | First seen | Evidence |
| --- | --- | --- | --- | --- | --- | --- |
| F1 | PERSISTENT | High | Open | Task 0411 depends on Task 0410 and Task 0410 is rejected for default startup and analyzer proof. | 2026-06-19 Task 0410 review | `docs/reports/review-wave-2026-06-19/0410-app-root-router-shell-skeleton-independent-review.md` |
| F2 | NEW | Moderate | Open | Responsive test reimplements layout instead of testing production `AppShell`; false confidence for narrow runtime wiring. | 2026-06-19 | `apps/observatory/test/app/shell_responsive_layout_test.dart:34-111` |
| F3 | NEW | Moderate | Open | Analyzer returns `29` scoped issues and `378` full package issues. | 2026-06-19 | `apps/observatory/test/app/shell_responsive_layout_test.dart:16` |
| F4 | EVIDENCE_GAP | Moderate | Open | Previous report and task evidence still say Flutter SDK unavailable despite current executable SDK. | 2026-06-19 | `docs/tasks/03-review/0411-warp-prism-shell-navigation-and-responsive-frame.md:126-131`; `docs/reports/build-gate-review/0411-review.md:15-17` |

## Evidence Reviewed

- **Task file**: `docs/tasks/03-review/0411-warp-prism-shell-navigation-and-responsive-frame.md`.
- **Source/test files**: `apps/observatory/lib/app/router.dart`, `app/app_shell.dart`, `test/app/app_shell_smoke_test.dart`, `test/app/shell_responsive_layout_test.dart`, `packages/warp_prism_ui/lib/src/organisms/ds_shell.dart`, `ds_sidebar.dart`, `ds_topbar.dart`, `ds_detail_inspector.dart`.
- **Runtime wiring proof**: Production route path is `main()` → `WarpPrismApp` → `MaterialApp.router(appRouter)` (`main.dart:5-6`, `app.dart:14-19`). Product branches `/overview`, `/map`, `/operate`, `/history`, and `/governance` are wrapped by `StatefulShellRoute.indexedStack` builder returning `AppShell` (`app/router.dart:38-41`). `AppShell` switches to `_CompactShell` and `BottomNavigationBar` below `DSBreakpoints.narrow` (`app_shell.dart:95-111`, `:166-176`). The runtime path is real, but default startup still bypasses it via `/design-system`.
- **Commands run**:
  - `dart format --set-exit-if-changed lib/app lib/features/overview lib/features/shell test/app/app_shell_smoke_test.dart test/app/shell_responsive_layout_test.dart test/features/overview test/features/shell test/app/deep_link_fallback_test.dart` — PASS, `22 files (0 changed)`.
  - `flutter analyze lib/app lib/features/overview lib/features/shell test/app/app_shell_smoke_test.dart test/app/shell_responsive_layout_test.dart test/app/deep_link_fallback_test.dart test/features/overview test/features/shell` — FAIL, `29 issues found`.
  - `flutter analyze` — FAIL, `378 issues found`.
  - `flutter test test/app/app_shell_smoke_test.dart test/app/shell_responsive_layout_test.dart test/features/overview/overview_provider_test.dart test/features/overview/overview_page_test.dart test/features/shell/shell_state_handler_test.dart test/app/deep_link_fallback_test.dart` — PASS, `48/48`.
- **Commands not run and why**: `dart pub outdated` not run because outbound package-registry access was not authorized.

## Stale-Evidence Notes

- Historical `lib/...` paths are stale after monorepo migration; current app code is under `apps/observatory/lib/...`. This lane/path drift alone is not scored down. The score is reduced for analyzer/proof/runtime mismatches.

## Path To 100

1. Land Task 0410/0011 route-startup fixes first.
2. Replace `_FakeNavigationShell` layout reimplementation with a test that pumps `WarpPrismApp` or a real `GoRouter`/`StatefulShellRoute` and verifies production compact `BottomNavigationBar` at `<600px`.
3. Fix analyzer issues in task-scoped shell test/app files and rerun clean scoped + full package analyzer.
4. Update task evidence to remove stale SDK-unavailable claims and cite real command outputs.
5. Add a touch-target/semantics assertion for the `5` bottom navigation items or document that `BottomNavigationBar` provides the Material minimum.

## Lane-Neutral References

Task identity is Task 0411. Historical references to `lib/...` or old lanes are not blockers by themselves; current-state falsehoods and missing runtime proof are blockers.

## Task Ledger Patch Suggestion

```markdown
### Latest Review

- **Date**: 2026-06-19
- **Reviewer profile**: `reviewers`
- **Score**: `72/100`
- **Verdict**: `REJECTED_TO_DOING`
- **Full report**: `docs/reports/review-wave-2026-06-19/0411-shell-navigation-responsive-frame-independent-review.md`
- **Lane outcome**: returned to doing
- **Task reference**: Task 0411 (`0411-warp-prism-shell-navigation-and-responsive-frame`)

#### Current Open Blockers

- `PERSISTENT`: upstream Task 0410/0011 default-startup proof remains rejected.
- `NEW`: responsive test reimplements shell logic instead of testing production `AppShell`.
- `NEW`: scoped analyzer fails with `29` issues; full package analyzer fails with `378`.

#### Path-to-100 Summary

- Fix upstream route startup, test real `AppShell` narrow/wide behavior, clear analyzer issues, and refresh validation evidence.
```
