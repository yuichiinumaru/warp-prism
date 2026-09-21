# Drain Review: Task 1122 — Tab Bar And Split Pane — 2026-07-17

## Review Lineage

- **Current task**: Task 1122 (`1122-warp-prism-tab-bar-and-split-pane`); live path at review start: `docs/tasks/03-review/1122-warp-prism-tab-bar-and-split-pane.md`
- **Previous reports treated as draft**:
  - Prior independent score **91/100** (see lineage notes below)
- **Review mode**: drain independent re-review (gt-flutter-code-reviewer + code-quality-harness + flutter-harness + review-report-lineage)
- **Policy (this wave)**: S≥90 → `docs/tasks/04-completed/`; S<90 → `docs/tasks/02-doing/`; no git / no tasklist
- **Dig deeper**: lifecycle, a11y, fake/vacuous tests, live gates

## Score And Verdict

- **Prior score (draft)**: `91/100`
- **New score**: `91/100`
- **Verdict**: `ACCEPTED_PROMOTE_COMPLETED`
- **Lane recommendation**: `promote-to-completed`
- **Lane outcome**: moved to `docs/tasks/04-completed/`
- **Top new finding**: Scroll overflow still untested despite test header claim (Moderate)
- **Blockers**: none

## Executive Summary

Tab controller lifecycle (listeners, scroll controller dispose, focus dispose) and split-pane drag min/max remain solid. Suite **23+11=34**. **Moderate residual remains**: test file header claims scroll overflow coverage but **zero overflow/fade-arrow tests** exist. **13 INFO** including multiple deprecated `withOpacity` on tab chrome and split divider.

## Delta Summary

### Resolved Since Prior Independent Review

- Core APIs/tests still green; split drag proven.

### Persistent Findings

- F1 scroll overflow untested (header claim false).
- F2 withOpacity deprecations + prefer_const INFO (13 total).

### New Findings (this session)

- Reconfirmed F1/F2 still open; no new High findings.

### Regressions

- None observed under scoped live gates.

## Six Axiom Compliance

| # | Axiom | Status | Evidence |
| --- | --- | --- | --- |
| 1 | Analyzer Integrity | **PASS (soft)** | 0 ERROR/WARNING; 13 INFO incl. deprecated withOpacity |
| 2 | Lifecycle Safety | **PASS** | scroll controller + focus dispose; TabView listener remove |
| 3 | Dependency Direction | **PASS** | organisms + tokens |
| 4 | UI Accessibility | **PASS** | tab focus/close semantics; divider label |
| 5 | Proof Reality | **PARTIAL** | 34/34 but overflow unproven |
| 6 | Release Security | **PASS** | no secrets |

## Findings

| ID | Class | Severity | Status | Summary | Evidence |
| --- | --- | --- | --- | --- | --- |
| F1 | PERSISTENT | Moderate | Open | Scroll overflow untested despite header claim | tab_bar_test.dart |
| F2 | PERSISTENT | Low | Open | withOpacity deprecations + prefer_const | tab_bar + split_pane |

## Live Validation (this session)

```text
dart analyze --format=machine lib/src/organisms/tab_bar/ lib/src/organisms/split_pane/  # 13 INFO
flutter test --concurrency=1 --no-pub test/organisms/tab_bar_test.dart test/organisms/split_pane_test.dart  # 34/34
```

## Evidence Reviewed

- tab_bar/*, split_pane/*, tests

## Path To 100

1. Add overflow test: many tabs → maxScrollExtent>0 and/or scroll arrows.
2. Migrate withOpacity → withValues(alpha: …).
3. Re-run scoped analyze/tests.

## Task Ledger Patch Suggestion

```markdown
### 2026-07-17 drain review (reviewers)
- Report: `docs/reports/review-wave-2026-07-17/task-1122-drain-review.md`
- Prior: **91/100** → New: **91/100** — `ACCEPTED_PROMOTE_COMPLETED`
- Lane: `docs/tasks/04-completed/`
- Residual F1 overflow proof gap (Moderate) keeps score <100
```
