# Review Report: Task 1020 — Responsive Shell And Detail Pass — 2026-07-09

## Review Lineage

- **Current task**: Task 1020 (`1020-warp-prism-responsive-shell-detail-pass`); live path `docs/tasks/03-review/1020-warp-prism-responsive-shell-detail-pass.md`
- **Previous reports read**:
  - `docs/reports/review-wave-2026-06-17/task-1020-review.md` — **72/100** `REJECTED_TO_DOING`
  - `docs/reports/build-gate-review/1020-review.md` — **100/100** historical (SDK-blocked; superseded)
- **Related reports considered**:
  - Task 1000 independent re-review (this wave)
  - Observatory `responsive_detail_integration_test.dart` + `shell_responsive_layout_test.dart` (production path proof)
- **Review mode**: `re-review` (independent; Flutter + code-quality)
- **Reviewer profile**: `reviewers`

## Score And Verdict

- **Score**: `92/100`
- **Verdict**: `HELD_IN_REVIEW_PATH_TO_100`
- **Lane recommendation**: `hold-in-review`
- **Human-facing verdict**: PASS WITH NOTES

## Delta Summary

### Resolved Since Previous Review (2026-06-17 @ 72/100)

- `RESOLVED` (Critical for demo path): **Rendered** side-by-side / overlay / full-screen detail transitions are proven on production `ResponsiveDetailShell` — **25/25** green (`apps/observatory/test/features/asset_detail/responsive_detail_integration_test.dart`).
- `RESOLVED` (High): App shell responsive contract proven — **11/11** green (`apps/observatory/test/app/shell_responsive_layout_test.dart`): wide/medium/narrow, bottom nav below 600px, breakpoint edges.
- `RESOLVED` (High): `DSBreakpoints` / `PrismBreakpoints` centralized tokens exist and are consumed by `DSShellResponsive`, Observatory `AppShell`, and detail shell.
- `RESOLVED` (Medium): SDK/validation unblocked; monorepo Where paths honest; changelog present as `docs/changelog/20260607-212124-1020-…-repair-bot.md`.
- `SUPERSEDED` (for product demo): `MasterDetailTemplate` is **not** on Observatory runtime routes (gallery/tests only; Operate comment cites it as broken and bypassed). Residual template debt remains package-level.

### Persistent Findings

- `PERSISTENT` (Medium): Task-scoped `packages/warp_prism_ui/test/responsive_shell_test.dart` still validates **constants only** (13 unit tests; no `pumpWidget` transitions / overflow checks).
- `PERSISTENT` (Medium): `MasterDetailTemplate` still wraps non-responsive `DSShell` + always-expanded sidebar; content-area “full-screen” leaves desktop sidebar chrome (`master_detail_template.dart:110-114,192-219`). Hardcoded overlay widths **400** / canvas **360** bypass tokens (`:178`, `:374`).

### Regressions

- None on production shell/detail path.

### New Findings

- `NEW` (Low): Task Completion Evidence still markets only the constant suite as the responsive regression; monorepo already has stronger observatory proof that should be cited for honesty.

### Evidence Gaps / External Blockers

- None blocking demo-path acceptance. Optional package-template hardening remains path-to-100.

## Findings

| ID | Class | Severity | Status | Summary | First seen | Evidence |
| --- | --- | --- | --- | --- | --- | --- |
| F1 | PERSISTENT (mitigated for product) | Medium | Open | Task-named suite is constants-only | 2026-06-17 | `responsive_shell_test.dart`; mitigation: observatory +25 / +11 widget suites |
| F2 | PERSISTENT / SUPERSEDED product | Medium | Open (package) | MasterDetailTemplate not true full-screen shell | 2026-06-17 | `master_detail_template.dart:110-219`; unused by Observatory features |
| F3 | PERSISTENT | Low–Med | Open | Drawer widths hardcoded 400/360 | 2026-06-17 | Template + also `ResponsiveDetailShell` overlay 400 |
| F4 | RESOLVED | Medium | Closed | SDK/changelog evidence false | 2026-06-17 | Live tests + repair-bot changelog |

## Exit Condition Verification

| Exit | Status | Live evidence |
| --- | --- | --- |
| Shell/sidebar/topbar/template API alignment | PASS | Breakpoints shared; organisms use tokens |
| Breakpoint contract documented | PASS | `DSBreakpoints` + shell/template docs |
| Regression for responsive shell/detail | PASS (with notes) | Package constants + **Observatory rendered** suites |
| Scoped analyze 0 errors | PASS | 7 info only on Where surface |
| Changelog | PASS | repair-bot engine file |

## Axiom Compliance

| Axiom | Status | Notes |
| --- | --- | --- |
| Analyzer Integrity | PASS (scoped) | Infos only |
| Lifecycle Safety | PASS | Overlay controllers in detail shell dispose path (observatory) |
| Dependency Direction | PASS | |
| UI Accessibility | PASS (related) | Full-screen back semantics covered in detail tests |
| Proof Reality | PASS with notes | Real transitions proven off task-named file |
| Release Security | PASS | |

## Evidence Reviewed

- `ds_breakpoints.dart`, `ds_shell.dart` (`DSShellResponsive`), `ds_topbar.dart`, `master_detail_template.dart`
- `apps/observatory/lib/app/app_shell.dart`, `responsive_detail_shell.dart`
- Production search: no feature import of `MasterDetailTemplate` outside gallery/tests
- Prior independent report findings F1–F4

## Commands And Results (fresh, this re-review)

```text
cd packages/warp_prism_ui
flutter test --no-pub test/responsive_shell_test.dart
→ All tests passed! (+13)

flutter analyze --no-pub \
  lib/src/tokens/ds_breakpoints.dart lib/src/tokens/tokens.dart \
  lib/src/organisms/ds_shell.dart lib/src/organisms/ds_topbar.dart \
  lib/src/templates/master_detail_template.dart \
  test/responsive_shell_test.dart
→ 7 info; 0 error; 0 warning

cd apps/observatory
flutter test --no-pub \
  test/features/asset_detail/responsive_detail_integration_test.dart
→ All tests passed! (+25)
  wide split / medium overlay+scrim / narrow full-screen+back / breakpoint edges

flutter test --no-pub test/app/shell_responsive_layout_test.dart
→ All tests passed! (+11)
  wide/medium/narrow, bottom nav <600, sidebar edges at 600/800
```

## Path To 100

1. Extend package `responsive_shell_test.dart` (or templates contract) with width-pumped assertions for `DSShellResponsive` + document MasterDetailTemplate as gallery-only **or** migrate it to `DSShellResponsive` and true full-screen.
2. Tokenize overlay drawer width (replace bare `400` / `360`).
3. Update Completion Evidence to cite Observatory responsive suites as the contract proof for transitions.

## Task Ledger Patch Suggestion

```markdown
### Latest Review
- **Date**: 2026-07-09
- **Reviewer profile**: `reviewers`
- **Score**: `92/100`
- **Verdict**: `HELD_IN_REVIEW_PATH_TO_100`
- **Full report**: `docs/reports/review-wave-2026-07-09/task-1020-responsive-shell-detail-independent-rereview.md`
- **Lane outcome**: remains in `03-review`
```
