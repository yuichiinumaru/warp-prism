# Review Report: Task 0411 — Shell Navigation And Responsive Frame — 2026-07-09

## Review Lineage

- **Current task**: Task 0411 (`warp-prism-shell-navigation-and-responsive-frame`); live path: `docs/tasks/03-review/0411-warp-prism-shell-navigation-and-responsive-frame.md`
- **Previous reports read**:
  - `docs/reports/build-gate-review/0411-review.md` — claimed `100/100`, SDK blocked (stale)
  - `docs/reports/review-wave-2026-06-19/0411-shell-navigation-responsive-frame-independent-review.md` — `72/100` REJECTED (fake shell reimplementation in tests, upstream default route, analyzer)
- **Related reports considered**: Task 0410 re-review this wave (default route + shell ownership)
- **Review mode**: `re-review` / independent live verification

## Score And Verdict

- **Score**: `93/100`
- **Verdict**: `HELD_IN_REVIEW_PATH_TO_100`
- **Lane recommendation**: `hold-in-review`

## Delta Summary

### Resolved Since Previous Review

- `RESOLVED`: Responsive suite mounts **production** `AppShell` via real `StatefulShellRoute.indexedStack` (`test/app/shell_responsive_layout_test.dart:18–48`, header comment lines 1–9).
- `RESOLVED`: Wide (1400), medium (900), narrow (400) behaviors proven: PrismShellResponsive vs BottomNavigationBar; no permanent inspector on compact.
- `RESOLVED`: Route-driven Map branch selection test (`initialLocation: '/map'`).
- `RESOLVED`: Live `flutter test` responsive + smoke = **14/14** within broader green shell suite.

### Persistent Findings

- None material for the 0411 contract after AppShell harness rewrite.

### Regressions

- None.

### New Findings

- `NEW` / Low: Shell still sets `showInspector: false` always (`app_shell.dart:126–128`). Ownership is explicit (good); no live inspector region proof on wide layouts (deferred to feature surfaces / later epics — acceptable for 0411 wording “preserve space / ownership”).
- `NEW` / Low: Compact shell uses Material `BottomNavigationBar` rather than a Prism organism (still credible fallback; labels from `AppShell.navItems`).

### Evidence Gaps / External Blockers

- `EVIDENCE_GAP`: Harness still uses stub branch pages (`Center(child: Text(path))`), not production feature pages — intentional OOM isolation; shell chrome is still production.
- `EXTERNAL_BLOCKER`: None.

## Findings

| ID | Class | Severity | Status | Summary | First seen | Evidence |
| --- | --- | --- | --- | --- | --- | --- |
| F1 | RESOLVED | Moderate | Closed | Tests reimplemented layout instead of AppShell | 2026-06-19 | production AppShell now mounted |
| F2 | RESOLVED | High | Closed | Upstream default route blocked shell proof | 2026-06-19 | `initialLocation: '/overview'` |
| F3 | NEW | Low | Open | Inspector pane never shown on wide shell | this review | `app_shell.dart:126–128` |
| F4 | NEW | Low | Open | Compact nav is Material BottomNavigationBar | this review | `app_shell.dart:168–178` |

## Exit Condition Verification

| Exit condition | Status | Live evidence |
| --- | --- | --- |
| Shared routed shell used by router | PASS | `router.dart` → `AppShell` |
| Left-rail nav on desktop | PASS | wide/medium tests + `PrismSidebar` |
| Small-layout fallback | PASS | narrow → `BottomNavigationBar` |
| Inspector ownership explicit | PASS | `showInspector: false` documented |
| Responsive widget tests | PASS | 11 layout + 3 smoke |
| format / analyze / changelog | PASS | live green; changelog `2026-07-09-task-0411-...` |

## Axiom Compliance

| Axiom | Status | Notes |
| --- | --- | --- |
| Analyzer Integrity | PASS | App shell sources/tests clean |
| Lifecycle Safety | PASS | **0** controllers created in `app_shell.dart`; **0** disposals |
| Dependency Direction | PASS | go_router + warp_prism_ui only |
| UI Accessibility | PARTIAL | 5 labeled bottom-nav items; sidebar relies on PrismSidebar semantics |
| Proof Reality | PASS | Production AppShell exercised at 3 breakpoints + route branch |
| Release Security | PASS | |

## Evidence Reviewed

- `lib/app/app_shell.dart`, `lib/app/router.dart`
- `test/app/shell_responsive_layout_test.dart`, `test/app/app_shell_smoke_test.dart`
- DS shell organism `showInspector` gate in `packages/warp_prism_ui/lib/src/organisms/ds_shell.dart`

### Commands run

| Command | Result |
| --- | --- |
| `flutter test test/app/shell_responsive_layout_test.dart test/app/app_shell_smoke_test.dart` (in batch) | **14 passed** |
| Scoped format | PASS |
| Scoped analyze (app surfaces) | PASS (no app_shell issues) |

## Path To 100

1. Optional: one wide-layout test that sets `showInspector: true` path once feature surfaces request inspector (or a shell API for inspector content injection).
2. Optional: Semantics/touch-target assertion on bottom nav items (≥48dp).
3. Keep regression guard: responsive tests must continue to mount production `AppShell`, not a layout reimplementation.

## Task Ledger Patch Suggestion

See task file `Review Ledger`.
