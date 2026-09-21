# Review Report: Task 0410 — App Root Router Shell Skeleton — 2026-07-09

## Review Lineage

- **Current task**: Task 0410 (`warp-prism-app-root-router-shell-skeleton`); live path: `docs/tasks/03-review/0410-warp-prism-app-root-router-shell-skeleton.md`
- **Previous reports read**:
  - `docs/reports/build-gate-review/0410-review.md` — claimed `100/100` with Flutter SDK unavailable (stale)
  - `docs/reports/review-wave-2026-06-19/0410-app-root-router-shell-skeleton-independent-review.md` — `68/100` REJECTED (default route `/design-system`, analyzer noise, smoke not production-default)
- **Related reports considered**:
  - Tasks 0411–0413 share `appRouter` / `AppShell` runtime path
  - Task 0011 bootstrap dependency (still lane-neutral; monorepo app root under `apps/observatory`)
- **Review mode**: `re-review` / independent live Flutter verification (builders claimed 100/100)

## Score And Verdict

- **Score**: `91/100`
- **Verdict**: `HELD_IN_REVIEW_PATH_TO_100`
- **Lane recommendation**: `hold-in-review` (S ≥ 90; never auto-complete to `04-completed`)

## Delta Summary

### Resolved Since Previous Review

- `RESOLVED`: Production `appRouter.initialLocation` is `/overview` (`apps/observatory/lib/app/router.dart:35`), not `/design-system`.
- `RESOLVED`: Product shell branches for Overview / Map / Operate / History / Governance via `StatefulShellRoute.indexedStack` + `AppShell` (`router.dart:37–87`).
- `RESOLVED`: Asset detail contract: `/assets/:assetId` + legacy `/asset/:id` redirect (`router.dart:96–110`).
- `RESOLVED`: Live scoped gates green (format / analyze `lib/app`+`test/app` clean of errors; shell smoke + responsive tests pass).
- `RESOLVED`: Shell/app surfaces use public Prism* API only (`rg '\bDS[A-Z]' lib/app test/app` → no matches).

### Persistent Findings

- `PERSISTENT` / Low–Moderate: Shell smoke still uses a **parallel** bootstrap `GoRouter`, not production `appRouter` / `WarpPrismApp` (`test/app/app_shell_smoke_test.dart:13–41`). Proves `AppShell` + default `/overview` shape, not the full production route table.

### Regressions

- None vs 2026-06-19 independent review.

### New Findings

- `NEW` / Low: Builder self-score `100/100` overstates proof completeness (production router still not pumped in tests; residual feature DS* still documented out-of-scope).

### Evidence Gaps / External Blockers

- `EVIDENCE_GAP`: No widget test imports `package:warp_prism_observatory/app/router.dart` / `appRouter` and asserts default landing without a hand-built router.
- `EXTERNAL_BLOCKER`: None. Flutter 3.44.1 / Dart 3.12.1 available.

## Findings

| ID | Class | Severity | Status | Summary | First seen | Evidence |
| --- | --- | --- | --- | --- | --- | --- |
| F1 | RESOLVED | High | Closed | `initialLocation` was `/design-system` | 2026-06-19 | now `/overview` at `router.dart:35` |
| F2 | RESOLVED | High | Closed | Analyzer / SDK blocked or dirty on shell scope | 2026-06-19 | live `flutter analyze lib/app test/app` — no issues on pure app shell set |
| F3 | PERSISTENT | Moderate | Open | Smoke harness ≠ production `appRouter` | 2026-06-19 F4 | `app_shell_smoke_test.dart:13–41`; no `appRouter` import under `test/` |
| F4 | NEW | Low | Open | Self-score 100 ignores F3 | this review | task Completion Evidence self-score 100/100 |

## Exit Condition Verification

| Exit condition | Status | Live evidence |
| --- | --- | --- |
| `main.dart` / `app.dart` / `router.dart` exist | PASS | ProviderScope → WarpPrismApp → MaterialApp.router(appRouter) |
| Route contract Overview/Map/Operate/History/Governance/Asset Detail | PASS | `router.dart` branches + `/assets/:assetId` |
| Placeholder / feature shells with stable titles | PASS | pages under `lib/app/pages/` + feature shells |
| Smoke test proves shell + default route | PASS with note | parallel router, not production `appRouter` |
| format / analyze / tests | PASS | see Commands |
| Changelog | PASS | `docs/changelog/20260709-124814-0410-app-root-router-shell-skeleton-verified-builders.md` |

## Axiom Compliance

| Axiom | Status | Notes |
| --- | --- | --- |
| Analyzer Integrity | PASS | Scoped `lib/app` + `test/app` clean in joint shell/overview run; pure app paths free of issues |
| Lifecycle Safety | PASS | Task shell files create **0** controllers/subscriptions/timers; **0** disposals required |
| Dependency Direction | PASS | App layer owns router; features imported as pages only |
| UI Accessibility | PARTIAL | Nav labels present; full a11y owned by Prism organisms / later tasks |
| Proof Reality | PARTIAL | Live tests pass; production `appRouter` still unpumped |
| Release Security | PASS | No secrets / release mutation |

## Evidence Reviewed

- Source: `lib/main.dart`, `lib/app/app.dart`, `lib/app/router.dart`, `lib/app/app_shell.dart`, pages under `lib/app/pages/`
- Tests: `test/app/app_shell_smoke_test.dart`, `test/app/shell_responsive_layout_test.dart`, `test/app/app_bootstrap_test.dart`
- Runtime chain: `main` → `ProviderScope` → `WarpPrismApp` → `appRouter` → `AppShell` for five product branches

### Commands run

| Command | Cwd | Result |
| --- | --- | --- |
| `dart format --set-exit-if-changed lib/app test/app ...` | `apps/observatory` | PASS (0 changed on re-run) |
| `flutter analyze lib/app test/app lib/features/overview lib/features/shell test/features/overview test/features/shell` | `apps/observatory` | 3 **info** only (overview_provider/tests — out of pure 0410 files) |
| `flutter test test/app/app_shell_smoke_test.dart test/app/shell_responsive_layout_test.dart ...` (shell suite) | `apps/observatory` | smoke **3/3** + responsive **11/11** included in **54/54** broader shell/overview batch |

## Path To 100

1. Add one OOM-safe test that mounts production `appRouter` (or a thin extract of its product branches + same `initialLocation`) under `ProviderScope` + `MaterialApp.router` and asserts Overview shell without `_buildBootstrapRouter`.
2. Optionally assert `/` → `/overview` redirect on production router.
3. Keep residual feature DS* migration out of this task’s claim surface; do not re-claim full-app bootstrap until features compile under Prism*.

## Task Ledger Patch Suggestion

See task file `Review Ledger` updated by this review wave.
