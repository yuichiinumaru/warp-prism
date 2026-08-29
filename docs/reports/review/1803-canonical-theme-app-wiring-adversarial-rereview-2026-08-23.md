# NOVA Adversarial Review — Task 1803

- **Task**: 1803 — Canonical ThemeData and App Host Wiring
- **Review mode**: independent adversarial re-review / accepted-100 reconciliation
- **Review date**: 2026-08-23
- **Previous report**: `docs/reports/review/1803-canonical-theme-app-wiring-independent-review-2026-08-23.md` (100/100, ACCEPTED_100)
- **Score**: **NOT SCORED**
- **Verdict**: **BLOCKED_RUNTIME_FAILURE**
- **Lane action**: remains in `docs/tasks/03-review/`; no score-based move is permitted while the production app suite is red

## Blocking runtime failure

The accepted Completion Evidence claims Observatory `810/810` tests pass. A fresh full `flutter test` run reached 810 passing tests and then failed:

- File: `apps/observatory/test/widget_test.dart:12`
- Test: `Observatory app bootstrap smoke test`
- Failure: `pumpAndSettle timed out`
- Result: **810 passed, 1 failed**

A focused rerun of the same test reproduces the timeout. This is a live production-host/runtime gate failure, so no score is invented.

## Independently green evidence

- `PrismTheme.dark()` exists and is publicly exposed as `PrismTheme = DSTheme`.
- Catalog root uses `PrismTheme.dark()`.
- Observatory root uses `PrismTheme.dark()`.
- CyberCore applies `PrismCyberCoreTealSkin.omniRoute().applyToTheme(PrismTheme.dark())`.
- Package token/theme tests: **48/48 PASS**.
- Catalog analyzer: PASS; catalog full tests **10/10 PASS**.
- CyberCore analyzer: PASS; CyberCore full tests **16/16 PASS**.
- Observatory analyzer: 124 infos, 0 errors.
- Observatory focused bootstrap suite: **3/3 PASS**.
- Boundary harness: **7/7 PASS**.

## Format-probe disposition

The earlier invalid repository-root format probe reported `apps/observatory/test/app/app_bootstrap_test.dart` as changed. Inspection shows the file is formatter-sensitive. A non-mutating copied-file check also reports formatting drift. This review does not mutate or “fix” it; the path is shared with typography/theme work and must be handled by a separately authorized narrow cleanup.

## Path to 100

1. Diagnose/fix or explicitly disposition the `pumpAndSettle` timeout in `apps/observatory/test/widget_test.dart`.
2. Re-run the complete Observatory suite and obtain a fresh zero-failure result.
3. Reconcile Completion Evidence from `810/810` to the actual current test count/result.
4. Re-run the public-barrel and app wiring checks after runtime recovery.
