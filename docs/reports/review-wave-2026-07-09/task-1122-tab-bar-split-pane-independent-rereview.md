# Review Report: Task 1122 — Tab Bar And Split Pane — 2026-07-09

## Review Lineage

- **Current task**: Task 1122 (`1122-warp-prism-tab-bar-and-split-pane`); live path: `docs/tasks/03-review/1122-warp-prism-tab-bar-and-split-pane.md`
- **Previous reports read**:
  - `docs/reports/build-gate-review/1122-review.md` — 100/100
  - Promote ledger — 100
  - `.agents/profiles/reviewers/review-260617231309-task-1122-1205-1207-1208-independent-review.md` (historical wave note if present)
- **Related reports considered**: none material
- **Review mode**: `re-review` independent
- **Reviewer profile**: `reviewers`

## Score And Verdict

- **Score**: `91/100`
- **Verdict**: `HELD_IN_REVIEW_PATH_TO_100`
- **Lane recommendation**: `hold-in-review` (S ≥ 90; **do not** move to `04-completed/`)

`DSTabController` / `DSTabBar` / `DSTabView` / `DSSplitPane` deliver solid lifecycle (listener add/remove, scroll controller dispose, focus node dispose). **34/34** tests pass; split pane proves drag + min/max. Residual: test file claims scroll-overflow coverage but **no overflow test exists**; multiple `withOpacity` deprecations on tab bar/split divider.

## Delta Summary

### Resolved / Prior

- Core APIs and tests green live; promote score mostly justified.

### New Findings

- `NEW` / Moderate: Scroll overflow / fade-arrow behavior implemented but **untested** despite task Test Requirements and test file header claim.
- `NEW` / Low: `withOpacity` deprecated member use on tab chrome and divider (INFO).

## Six Axiom Compliance

| # | Axiom | Status | Evidence |
| --- | --- | --- | --- |
| 1 | Analyzer Integrity | **PASS** (soft) | 0 ERROR/WARNING; 13 INFO lib-ish |
| 2 | Lifecycle Safety | **PASS** | TabBar scroll controller + focus; TabView listener remove; SplitPane focus dispose |
| 3 | Dependency Direction | **PASS** | organisms + tokens |
| 4 | UI Accessibility | **PASS** (task) | tab focus/close semantics; divider semantic label |
| 5 | Proof Reality | **PARTIAL** | 34/34; scroll overflow unproven |
| 6 | Release Security | **PASS** | No secrets |

## Findings

| ID | Class | Severity | Status | Summary | First seen | Evidence |
| --- | --- | --- | --- | --- | --- | --- |
| F1 | NEW | Moderate | Open | Scroll overflow not covered by any test (header claims it) | this report | `tab_bar_test.dart` only mentions overflow in comment L7; 0 scroll tests |
| F2 | NEW | Low | Open | Deprecated `withOpacity` on tab/split surfaces | this report | `ds_tab_bar.dart`, `ds_split_pane.dart` INFO |

## Exit Conditions (live)

| # | Condition | Met? | Live proof |
| --- | --- | --- | --- |
| 1 | tab_bar/ + split_pane/ | **YES** | present |
| 2 | closeable/scrollable/badged | **YES** (impl) | code; badges tested |
| 3 | Split drag min/max horiz/vert | **YES** | split tests +11 |
| 4 | 34 tests | **YES** | +23 +11 |
| 5 | Scroll overflow proven | **NO** | F1 |

## Evidence Reviewed

- `tab_bar/*`, `split_pane/*`, both test files, build-gate report

## Commands Run

```text
dart analyze --format=machine lib/src/organisms/tab_bar/ \
  lib/src/organisms/split_pane/ \
  test/organisms/tab_bar_test.dart test/organisms/split_pane_test.dart
# → 14 INFO

flutter test --concurrency=1 --no-pub \
  test/organisms/tab_bar_test.dart test/organisms/split_pane_test.dart
# → +34
```

## Path To 100

1. Add overflow test: many tabs → scroll arrows / maxScrollExtent > 0; optional fade indicators.
2. Migrate `withOpacity` → `withValues(alpha: …)`.
3. Re-run scoped analyze/tests.

## Task Ledger Patch Suggestion

```markdown
### 2026-07-09 independent re-review (reviewers)
- Report: `docs/reports/review-wave-2026-07-09/task-1122-tab-bar-split-pane-independent-rereview.md`
- Score: **91/100** — `HELD_IN_REVIEW_PATH_TO_100`
- Lane: remain `03-review/`
- Residual: F1 scroll overflow test gap
```
