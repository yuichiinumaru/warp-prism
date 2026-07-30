# Review Report: Task 0011 — Bootstrap Main Router Shell — 2026-06-17

## Review Lineage

- **Current task**: Task 0011 (`0011-warp-prism-bootstrap-main-router-shell`); reviewed at `docs/tasks/03-review/0011-warp-prism-bootstrap-main-router-shell.md` before routing.
- **Previous reports read**: `docs/reports/build-gate-review/0011-review.md` — prior 100/100 approval.
- **Related reports considered**: `docs/reports/review-wave-3/0010-review.md` and the Task 0010 executor/prior-review reports.
- **Review mode**: dependency triage and re-review.

## Score And Verdict

- **Score**: `68/100`
- **Verdict**: `REJECTED_TO_DOING`
- **Lane recommendation**: `return-to-doing`

## Delta Summary

### Resolved Since Previous Review

- `RESOLVED`: The bootstrap has survived the later monorepo migration under `apps/observatory/`; production wiring from `main()` through `WarpPrismApp`, `MaterialApp.router`, `appRouter`, and `AppShell` exists.
- `RESOLVED`: The focused shell smoke test passes 3/3 with the current Flutter SDK.

### Persistent Findings

- `PERSISTENT`: The prior 100/100 review approved the task while analyzer/test exits and changelog were explicitly blocked or pending.
- `PERSISTENT`: No Task 0011 changelog artifact was found.

### Regressions

- None attributed to Task 0011. Current broad Observatory failures involve later feature surfaces and are not sufficient evidence that this bootstrap slice regressed.

### New Findings

- `NEW`: Task 0010, the declared prerequisite, was rejected at 58/100. Task 0011 therefore cannot be finalized on the claim that it consumes a trustworthy Task 0010 baseline.
- `NEW`: Current task paths and completion evidence still describe the pre-monorepo root application, while the live production surface is `apps/observatory/`.
- `NEW`: The task promises a minimal initial `/overview` bootstrap, but the current router's `initialLocation` is `/design-system`; the focused test works around this by manually navigating to `/overview`.

### Evidence Gaps / External Blockers

- `EVIDENCE_GAP`: A clean current package analyzer gate was not established. The no-network analyzer traversed repository-local cached package sources under `tmp/pub-cache` and reported 55,953 diagnostics, so it is invalid as task-owned analyzer proof.
- `EXTERNAL_BLOCKER`: none. Flutter 3.44.1 is installed.

## Findings

| ID | Class | Severity | Status | Summary | First seen | Evidence |
| --- | --- | --- | --- | --- | --- | --- |
| F1 | NEW | High | Open | Failed prerequisite Task 0010 invalidates finalization based on its baseline. | 2026-06-17 | `docs/tasks/03-review/0011-warp-prism-bootstrap-main-router-shell.md:9`, `docs/reports/review-wave-3/0010-review.md` |
| F2 | PERSISTENT | Medium | Open | Analyzer/test/changelog exits were incomplete, yet the prior review awarded 100/100 and declared all exits met. | prior review | `docs/tasks/03-review/0011-warp-prism-bootstrap-main-router-shell.md:44-53`, `docs/reports/build-gate-review/0011-review.md:49-92` |
| F3 | NEW | Medium | Open | The implemented startup route no longer matches the task's claimed `/overview` initial route; the smoke test masks this by navigating after startup. | 2026-06-17 | `apps/observatory/lib/app/router.dart:35-37`, `apps/observatory/test/app/app_shell_smoke_test.dart:15-18` |
| F4 | PERSISTENT | Medium | Open | Required changelog evidence remains absent. | executor task | `docs/tasks/03-review/0011-warp-prism-bootstrap-main-router-shell.md:52`, `docs/tasks/03-review/0011-warp-prism-bootstrap-main-router-shell.md:125` |
| F5 | EVIDENCE_GAP | Low | Open | Task and `Where` paths are obsolete after monorepo migration and do not identify the current owning package. | 2026-06-17 | `README.md:12-43`, `apps/observatory/pubspec.yaml:1-17` |

## Evidence Reviewed

- Full Task 0011 and all `Where` entries. Old root `lib/` entries are absent; current migrated counterparts under `apps/observatory/` were read, including all claimed pages and the shell smoke test.
- Runtime wiring proof: `apps/observatory/lib/main.dart:5-7` → `WarpPrismApp` in `apps/observatory/lib/app/app.dart:9-19` → `appRouter` in `apps/observatory/lib/app/router.dart:35-160` → `AppShell` in `apps/observatory/lib/app/app_shell.dart:16-128`.
- Current design-system public API and Observatory compatibility boundary were inspected.
- Commands:
  - Focused `flutter test --no-pub test/app/app_shell_smoke_test.dart` — exit 0; 3 tests passed.
  - Full `flutter test --no-pub` in `apps/observatory` — exit 1; 646 passed / 7 failed. Failures are in later Map/Operate/Governance feature tests, not the focused bootstrap test.
  - `flutter analyze --no-pub` in `apps/observatory` — exit 1 with 55,953 diagnostics because repository-local `tmp/pub-cache` was included; invalid as clean task analyzer proof.
- Commands not run: package fetching/network was prohibited.

## Stale-Evidence Notes

The root app was legitimately migrated to `apps/observatory/`; old lane and source paths are historical drift, not by themselves a functional failure. The blocking issues are the rejected prerequisite, unresolved current initial-route contract, missing changelog, and lack of clean analyzer evidence.

## Dependency Effect

Task 0011 is not finalizable while Task 0010 remains rejected. The live bootstrap is usable and its focused smoke proof passes, but Task 0011 must reconcile its prerequisite and current monorepo contract before re-review.

## Path To 100

1. Resolve Task 0010 and update Task 0011 to cite the corrected baseline.
2. Reconcile the intended startup route: restore `/overview` as initial location or update the task contract and add a test that asserts the actual startup surface without manual navigation.
3. Update all `Where` and completion-evidence paths to `apps/observatory/` and record migration lineage.
4. Produce clean package analyzer evidence that excludes repository-local caches/generated temp trees, rerun the focused bootstrap test, and classify unrelated broad-suite failures.
5. Add or link a real Task 0011 changelog entry.

## Task Ledger Patch Suggestion

- Date: 2026-06-17
- Reviewer profile: `reviewers`
- Score: `68/100`
- Verdict: `REJECTED_TO_DOING`
- Full report: `docs/reports/review-wave-3/0011-review.md`
- Lane outcome: returned to doing
- Open blockers: failed Task 0010 prerequisite, initial-route mismatch, missing changelog, stale paths, and clean analyzer evidence gap.
