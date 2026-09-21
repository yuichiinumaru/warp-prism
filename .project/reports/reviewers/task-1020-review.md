# Review Report: Task 1020 — Responsive Shell And Detail Pass — 2026-06-17

## Review Lineage

- **Current task**: Task 1020 (`warp-prism-responsive-shell-detail-pass`).
- **Previous reports read**: `docs/reports/build-gate-review/1020-review.md` — 100/100 PASS.
- **Related reports considered**: Task 1000 review and current Observatory shell/detail implementation.
- **Review mode**: re-review against live evidence.

## Score And Verdict

- **Score**: `72/100`
- **Verdict**: `REJECTED_TO_DOING`
- **Lane recommendation**: `return-to-doing`

## Delta Summary

### Resolved Since Previous Review

- `RESOLVED`: Breakpoint tokens exist, are exported, and are used by the current Observatory `AppShell` and responsive detail shell.
- `RESOLVED`: Current app shell includes a compact bottom-navigation fallback below 600 px.

### Persistent Findings

- `PERSISTENT`: The task-scoped test validates numeric constants only; it does not render side-by-side, overlay, or full-screen detail transitions as the task explicitly requires.

### Regressions

- `REGRESSION`: Completion evidence says Flutter is unavailable; targeted tests now run.
- `REGRESSION`: Claimed changelog file is absent.

### New Findings

- `NEW`: `MasterDetailTemplate` still uses non-responsive `DSShell` with an expanded sidebar and applies breakpoints only inside the remaining content width (`master_detail_template.dart:110-150`). Its `<800` "full-screen" detail therefore remains beside the desktop sidebar, contradicting the documented full-screen contract.
- `NEW`: The medium overlay uses a hard-coded 400 px drawer rather than the centralized inspector width/token (`master_detail_template.dart:174-189`).
- `NEW`: `CanvasTemplate` documents a narrow overlay policy but unconditionally places a 360 px overlay when selected (`master_detail_template.dart:368-387`).

### Evidence Gaps / External Blockers

- `EVIDENCE_GAP`: No task test pumps actual shell/template widgets at representative widths or calls `tester.takeException()` to detect overflow.
- `EVIDENCE_GAP`: Task 1000 prerequisite is rejected and its host map is stale.
- `EXTERNAL_BLOCKER`: None; dependency resolution is blocked by repository-local workspace/cache contamination.

## Findings

| ID | Class | Severity | Status | Summary | First seen | Evidence |
| --- | --- | --- | --- | --- | --- | --- |
| F1 | PERSISTENT | Critical | Open | Required transition/overflow behavior is untested. | prior review evidence | `packages/warp_prism_ui/test/responsive_shell_test.dart:1-126` |
| F2 | NEW | High | Open | Master-detail narrow mode is not full-screen because desktop shell/sidebar remain. | 2026-06-17 | `packages/warp_prism_ui/lib/src/templates/master_detail_template.dart:110-150,192-220` |
| F3 | NEW | Medium | Open | Drawer/overlay widths bypass responsive tokens. | 2026-06-17 | `master_detail_template.dart:174-189,368-387` |
| F4 | REGRESSION | Medium | Open | Validation and changelog evidence are stale/false. | 2026-06-17 | Task lines 50-53, 114, 129-134 |

## Evidence Reviewed

- Every current Where-equivalent source, test, prior report, baseline, and production shell/detail wiring.
- Runtime wiring proof: `apps/observatory/lib/app/app_shell.dart:95-127` uses `DSShellResponsive`; `apps/observatory/lib/features/asset_detail/presentation/responsive_detail_shell.dart:108-112` uses centralized breakpoints.
- Commands run: targeted suite, analyzer attempts, diff check, source searches.

## Commands And Results

- `flutter test --no-pub test/responsive_shell_test.dart` — PASS, 13 constant/token tests.
- `flutter analyze --no-pub` — FAIL with 590 package-wide issues.
- Pub-resolving analyze — BLOCKED by workspace glob capturing `apps/observatory/tmp/pub-cache`.
- `git diff --check -- ...` — PASS.

## Path To 100

1. Replace constant-only tests with widget tests at narrow, medium, and wide widths proving sidebar mode, topbar behavior, side-by-side detail, overlay/scrim dismissal, and full-screen back navigation.
2. Make `MasterDetailTemplate` use responsive shell semantics or remove the persistent desktop sidebar from narrow detail mode.
3. Tokenize/clamp overlay widths and make Canvas overlay adaptive.
4. Add explicit no-overflow assertions at boundary widths and text scaling.
5. Refresh changelog/validation evidence after Task 1000 is rewritten.

## Dependency Effects

Task 1000 failed. Current runtime wiring improves confidence, but it does not rescue the task's unproven template acceptance criteria.

## Task Ledger Patch Suggestion

- **Date**: 2026-06-17
- **Reviewer profile**: `reviewers`
- **Score**: 72/100
- **Verdict**: `REJECTED_TO_DOING`
- **Full report**: `docs/reports/review-wave-2026-06-17/task-1020-review.md`
- **Lane outcome**: returned to doing
