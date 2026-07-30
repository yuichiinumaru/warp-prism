# Review Report: Task 1112 — Data Table Component — 2026-07-09

## Review Lineage

- **Current task**: Task 1112 (`1112-warp-prism-data-table-component`); live path at review start `docs/tasks/03-review/1112-warp-prism-data-table-component.md`
- **Previous reports read**:
  - `docs/reports/build-gate-review/1112-review.md` — historical **100** (build-gate)
  - `docs/reports/build-gate-review/1112-review-2026-06-17.md` — independent **48** (workspace FAIL + a11y + hard gate)
  - `.agents/profiles/reviewers/review-260709230500-wave-1106-1123-promote.md` — wave **100** promote on scoped **+35**
- **Related reports considered**: Task 1102 now **100** in `03-review/` (hard-gate upstream improved)
- **Review mode**: `re-review` (independent; gt-flutter-code-reviewer + gt-code-quality-reviewer)
- **Reviewer profile**: `reviewers`

## Score And Verdict

- **Score**: `84/100`
- **Verdict**: `REJECTED_TO_DOING`
- **Lane recommendation**: `return-to-doing` (S < 90)

Scoped suite is **live green (35/35)** and upstream 1102 hard-gate is no longer a Critical promotion fail. However, **UI Accessibility** axiom still fails on multiple interactive controls, task-required **filter integration** remains a generic toolbar slot without behavioral proof, and **≥80% coverage** remains unproven. Wave-100 promote is **over-scored** relative to DS component rigor.

## Delta Summary

### Resolved Since Previous Review (2026-06-17 @ 48)

- `RESOLVED`: Workspace resolution no longer blocks `flutter test` for data_table.
- `RESOLVED`: Live `flutter test test/organisms/data_table/` → **+35 All tests passed**.
- `RESOLVED` / SUPERSEDED severity: Task 1102 hard gate now **100/100** in `03-review/` (was Critical when 1102 rejected).
- `RESOLVED`: Deliverable + gallery section present; Prism typedefs export `PrismDataTable`.

### Persistent Findings

- `PERSISTENT` / Medium: Interactive a11y gaps on sort headers, secret reveal, actions, compact checkboxes (from 2026-06-17 F1112-3…6) **still present** in source.
- `PERSISTENT` / Medium: Filtering not implemented by table; only optional `toolbar` widget slot — no DSSearchBar/DSFilterChipGroup behavioral integration test.
- `PERSISTENT` / Low: Coverage ≥80% claim still lacks lcov/coverage run evidence.

### Regressions

- None functional vs June source; proof environment improved.

### New Findings

- `NEW` / Low: Scoped analyze reports multiple `prefer_const_*` infos + one `withOpacity` deprecation in `ds_data_table.dart` (Axiom 1 residual, not error).

### Evidence Gaps / External Blockers

- `EVIDENCE_GAP`: No coverage report for table widgets.
- `EVIDENCE_GAP`: No 1000+ row frame-timing proof (ListView.builder present; performance claim soft).

## Six Axiom Compliance

| # | Axiom | Status | Evidence |
| --- | --- | --- | --- |
| 1 | Analyzer Integrity | **PARTIAL** | Scoped analyze: info-only (const/deprecation); 0 errors/warnings |
| 2 | Lifecycle Safety | **PASS** | Table state has no TextEditing/Animation/Scroll controllers requiring dispose in scoped file |
| 3 | Dependency Direction | **PASS** | Organisms → tokens/atoms/molecules/virtual_scroll; Prism aliases public |
| 4 | UI Accessibility | **FAIL** | Sort `GestureDetector` without button semantics/focus; secret reveal icon-only; actions `InkWell` + xs padding; checkbox width 40 compact density |
| 5 | Proof Reality | **PARTIAL** | 35/35 live PASS; filter integration + coverage + 1000-row perf unproven |
| 6 | Release Security | **PASS** | No secrets |

## Findings

| ID | Class | Severity | Status | Summary | First seen | Evidence |
| --- | --- | --- | --- | --- | --- | --- |
| F1 | SUPERSEDED | Critical→n/a | Closed as gate | 1102 hard-gate rejection | 2026-06-17 | 1102 now 03-review 100 |
| F2 | RESOLVED | Critical | Closed | Workspace blocked tests | 2026-06-17 | live +35 PASS |
| F3 | PERSISTENT | Medium | Open | Secret cell reveal not keyboard/48dp button | 2026-06-17 | `ds_data_table.dart` ~GestureDetector reveal |
| F4 | PERSISTENT | Medium | Open | Row actions under 48×48 / weak semantics | 2026-06-17 | `DSActionsCell` InkWell + xs padding |
| F5 | PERSISTENT | Medium | Open | Sort headers pointer-only GestureDetector | 2026-06-17 | `_ColumnHeaderCell` |
| F6 | PERSISTENT | Medium | Open | Selectable checkboxes compact / width 40 | 2026-06-17 | header + row Checkbox |
| F7 | PERSISTENT | Medium | Open | Filter MUST integrate SearchBar/FilterChipGroup — only toolbar slot | 2026-06-17 | API + no filter tests |
| F8 | PERSISTENT | Low | Open | ≥80% coverage unproven | 2026-06-17 | no lcov this wave |
| F9 | NEW | Low | Open | withOpacity deprecation + const infos | this report | scoped analyze |

## Exit Conditions (live)

| # | Condition | Met? | Live proof |
| --- | --- | --- | --- |
| 1 | data_table organism exists | **YES** | `lib/src/organisms/data_table/ds_data_table.dart` |
| 2 | Catalog/gallery cases | **YES** | `buildDataTableSection()` |
| 3 | Virtualized 1000+ without frame drops | **PARTIAL** | `ListView.builder` yes; no perf proof |
| 4 | melos analyze | **PARTIAL** | scoped infos only; package residual external |
| 5 | tests + ≥80% coverage | **PARTIAL** | 35/35 PASS; coverage **no** |
| 6 | Changelog | **YES** | `2026-06-08-task-1112-…` |

## Evidence Reviewed

- Task 1112 + prior 48/100 and wave-100 ledger
- `ds_data_table.dart` interactive sites (secret, actions, sort, checkbox, pagination semantics)
- `test/organisms/data_table/ds_data_table_test.dart` groups (sort, pagination, selection, cells, empty/loading/error, column visibility)
- `prism_aliases.dart` typedefs

## Commands Run

```text
cd packages/warp_prism_ui
flutter test --concurrency=1 --no-pub test/organisms/data_table/
# → +35: All tests passed!  EXIT 0

dart analyze lib/src/organisms/data_table/
# → info-level only (prefer_const_*, deprecated_member_use withOpacity)
```

## Path To 100

1. **A11y (blocking)**: sort headers, secret reveal, actions → `Semantics(button: true)` + focusable + ≥48×48 targets (match toast/a11y pattern from Task 1308).
2. **Filter contract**: either compose documented `toolbar` with SearchBar+FilterChipGroup gallery/test proving integration, or implement first-class filter hooks with tests.
3. **Coverage**: run coverage on data_table sources; attach lcov summary to Completion Evidence (≥80% claim).
4. Clear `withOpacity` → `withValues` and easy const infos on scoped file.
5. Optional: virtual-scroll smoke with 1000 rows (no frame-timing if not budgeted — document honestly).

## Task Ledger Patch Suggestion

```markdown
### 2026-07-09 independent re-review (reviewers)
- Report: `docs/reports/review-wave-2026-07-09/task-1112-data-table-component-independent-rereview.md`
- Score: **84/100** — `REJECTED_TO_DOING`
- Lane: `03-review/` → `02-doing/`
- Blockers: F3–F7 a11y + filter contract; F8 coverage gap
- Commands: data_table tests 35/35 PASS; analyze info-only
```
