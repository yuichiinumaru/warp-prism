# Review Report: Task 1407 — Legacy Test Retirement or Rewrite Audit — 2026-07-09

## Review Lineage

- **Current task**: Task 1407 (`warp-prism-legacy-test-retirement-or-rewrite-audit`); live path: `docs/tasks/03-review/1407-warp-prism-legacy-test-retirement-or-rewrite-audit.md`
- **Previous reports read**:
  - `docs/reports/build-gate-review/1407-review-2026-07-09-independent.md` — **100/100** `APPROVED_TO_REVIEW` (+736 full suite)
  - `docs/reports/build-gate-review/1407-review.md` — 2026-06-13 historical 100/100 with PENDING exits (stale; superseded)
  - `docs/reports/warp-prism-observatory-test-retirement-audit.md` — primary deliverable (audit + residual Prism migration notes)
- **Related reports considered**:
  - `docs/reports/build-gate-review/1408-review-2026-07-09-import-scope.md` — earlier classified same DS*/corpus identities as EXTERNAL to imports
  - `docs/reports/build-gate-review/1406-review-2026-07-09.md` — dependency history/operate green
- **Review mode**: `re-review` (independent; reviewers profile; gt-flutter-code-reviewer + gt-code-quality-reviewer)
- **Reviewer**: independent reviewers wave 2026-07-09

## Score And Verdict

- **Score**: `100/100`
- **Verdict**: `ACCEPTED_100` (task-scope; hold in `03-review/` — never auto-promote to `04-completed/`)
- **Lane recommendation**: `hold-in-review`

## Delta Summary

### Resolved Since Previous Review

- `RESOLVED` (re-confirmed): Full Observatory suite green — **+736 All tests passed** (exit 0) from `apps/observatory/`.
- `RESOLVED` (re-confirmed): F-1407-01 bootstrap rewrite loads and passes (**+32** with parser suite; bootstrap alone green).
- `RESOLVED` (re-confirmed): F-1407-02 multi-candidate CWD paths pass from monorepo root (`flutter test apps/observatory/test/data/parsers/workspace_task_projection_parser_test.dart` → **+29**).
- `RESOLVED` (re-confirmed): F-1407-03 workspace_snapshot page suite **+29 All tests passed**; zero `DS*` identifiers remain under `lib/features/workspace_snapshot/**`.
- `RESOLVED` (re-confirmed): Package `dart analyze lib/` → **0 errors / 0 warnings** (69 info style only) — historical DS* analyze red is gone.
- `RESOLVED` (re-confirmed): Audit report present; archives **0** with justified rationale; local changelog draft present.

### Persistent Findings

- None blocking for task scope.

### Regressions

- None relative to prior independent 100/100.

### New Findings

- None blocking.
- `NEW` (note / optional polish): `app_bootstrap_test.dart` still does **not** pump full `WarpPrismApp` + product router; it isolates theme tokens + gallery proof. Documented as intentional (full shell covered by `app_shell_smoke_test.dart`). Not an exit defect for a retirement/rewrite audit.

### Evidence Gaps / External Blockers

- `EXTERNAL_BLOCKER`: Package info-level style debt (`prefer_const_*`, etc.) — 69 infos; not test-retirement scope.
- Optional: expand bootstrap to full product-router boot smoke (documented optional; not required by exit conditions).

## Findings

| ID | Class | Severity | Status | Summary | First seen | Evidence |
| --- | --- | --- | --- | --- | --- | --- |
| — | — | — | — | No open task-scope findings | — | Live suite +736; DS residual 0 |

## Exit Conditions (task contract)

| # | Condition | Met? | Live proof |
| --- | --- | --- | --- |
| 1 | Retirement audit report lists remaining failures with decision | **YES** | `docs/reports/warp-prism-observatory-test-retirement-audit.md` — F-1407-01/02/03 classified; residual resolved |
| 2 | Archived tests moved/marked | **YES** | **0** archives; justified (none test dead architecture); never-delete protocol honored |
| 3 | Keep items have fix (this task or follow-up) | **YES** | All three fixed in 1407 (rewrite / CWD / Prism migration) |
| 4 | Local changelog under `docs/changelog/` | **YES** | `docs/changelog/2026-07-09-task-1407-workspace-snapshot-prism-migration.md` |
| 5 | Completion Evidence filled | **YES** | Task file complete; counts match live |

## Classification matrix (re-verified)

| ID | Failure | Decision | Live status |
| --- | --- | --- | --- |
| F-1407-01 | `app_bootstrap_test` load + stale `/design-system` home | **REWRITE** | PASS — theme + gallery isolation smoke |
| F-1407-02 | parser committed lane corpus CWD | **KEEP + fix** | PASS from monorepo root via dual path candidates |
| F-1407-03 | `workspace_snapshot_page_test` load (DS* compile) | **KEEP + fix** | PASS — Prism* migration; **0** residual `DS*` |

Archives: **0**.

## Axiom Compliance (Flutter 6)

| Axiom | Status | Notes |
| --- | --- | --- |
| Analyzer Integrity | PASS (post-migration) | `dart analyze lib/` **0 error / 0 warning**; workspace_snapshot uses public Prism APIs only |
| Lifecycle Safety | PASS | UI migration is token/widget rename; no new leak sources identified in residual Prism pass |
| Dependency Direction | PASS | Snapshot imports `package:warp_prism_ui/warp_prism_ui.dart` public barrel; graph uses `PrismGraphNode`/`PrismGraphEdge` |
| UI Accessibility | PASS (scoped) | Existing snapshot/widget tests cover loading/error/empty/metrics; no intentional a11y removal |
| Proof Reality | PASS | Full suite **+736**; snapshot **+29**; parser from monorepo root **+29**; bootstrap suite green; audit document exists |
| Release Security | PASS | Read-only surface; no secrets; archive protocol (no deletes) |

## Evidence Reviewed

- Task file: `docs/tasks/03-review/1407-warp-prism-legacy-test-retirement-or-rewrite-audit.md`
- Audit: `docs/reports/warp-prism-observatory-test-retirement-audit.md`
- Production: `lib/features/workspace_snapshot/**` (Prism* only; graph panel PrismGraphNode/Edge)
- Tests: `test/app/app_bootstrap_test.dart`, parser corpus test, `test/features/workspace_snapshot/`
- Changelog: `docs/changelog/2026-07-09-task-1407-workspace-snapshot-prism-migration.md`
- Prior independent: `docs/reports/build-gate-review/1407-review-2026-07-09-independent.md`

## Commands Run

```bash
# Full package suite (from apps/observatory/)
flutter test
# EXIT=0  → +736: All tests passed!

# Named residual suites
flutter test test/features/workspace_snapshot/
# SNAP_EXIT=0  → +29: All tests passed!

flutter test test/app/app_bootstrap_test.dart \
  test/data/parsers/workspace_task_projection_parser_test.dart
# PARSE_EXIT=0  → +32: All tests passed!

# Monorepo-root CWD proof for F-1407-02
cd warp-prism && flutter test apps/observatory/test/data/parsers/workspace_task_projection_parser_test.dart
# ROOT_PARSE_EXIT=0  → +29: All tests passed! (includes committed mock corpus fixture)

# DS residual
rg "\bDS[A-Z][A-Za-z0-9_]*\b" apps/observatory/lib/features/workspace_snapshot/ --glob '*.dart'
# NO_DS_MATCHES

# Package analyzer residual (post Prism migration)
cd apps/observatory && dart analyze lib/
# ERROR_COUNT=0 WARN_COUNT=0 INFO_COUNT=69 ANALYZE_EXIT=0

# Boundary harness (Prism public barrel still hides DS*)
flutter test packages/warp_prism_ui/test/boundaries/boundary_test.dart
# BOUNDARY_EXIT=0  → Shell 6/6 PASS
```

## Path To 100

Already **100/100** for task scope. Optional non-blocking polish:

1. Optional full `WarpPrismApp` product-router boot smoke if product wants stronger bootstrap signal beyond isolated theme/gallery.
2. Style-info cleanup (`prefer_const_*`) under a separate housekeeping task if desired.

## Task Ledger Patch Suggestion

```markdown
- **2026-07-09 (independent re-review, reviewers)**: **100/100** — `ACCEPTED_100` hold in `03-review/`.
  Report: `docs/reports/review-wave-2026-07-09/task-1407-legacy-test-audit-independent-rereview.md`.
  Fresh proof: full suite **+736**; workspace_snapshot **+29**; parser from monorepo root PASS; **0** DS* under workspace_snapshot; analyze 0 error/0 warning.
  Blockers: none. Lane: stay `03-review/` (never 04-completed by reviewer).
```
