# Review Report: Task 0310 — Backbone Model Contract Audit — 2026-07-09

## Review Lineage

- **Current task**: Task 0310 (`warp-prism-backbone-model-contract-audit`); live path at review start: `docs/tasks/03-review/0310-warp-prism-backbone-model-contract-audit.md`
- **Previous reports read**:
  - `docs/reports/build-gate-review/0310-review.md` — 100/100 (SDK-blocked soft approval; stale)
  - `docs/reports/review-wave-3/0310-review.md` — **72/100** `REJECTED_TO_DOING` (package proof fail, missing changelog, unused `_listEquals`)
  - `docs/reports/0310-backbone-model-contract-audit.md` — builder audit artifact
- **Related reports considered**:
  - `docs/reports/review-wave-2026-07-09/task-1403-parser-projection-independent-rereview.md` — corpus frontmatter residual is **not** a Task 0310 exit condition
  - Wave-3 sequential rejections handoff for 0310→0313 chain
- **Review mode**: `re-review` (independent; gt-flutter-code-reviewer + gt-code-quality-reviewer)

## Score And Verdict

- **Score**: `95/100`
- **Verdict**: `HELD_IN_REVIEW_PATH_TO_100`
- **Lane recommendation**: `hold-in-review` (S ≥ 90; never auto-complete to `04-completed`)

## Delta Summary

### Resolved Since Previous Review (2026-06-17 @ 72/100)

- `RESOLVED`: Focused package gates execute live. `flutter analyze lib/data/models test/data/models` → **No issues found**; `flutter test test/data/models/workspace_graph_models_test.dart` → **+27 All tests passed**.
- `RESOLVED`: Required changelog entry present: `docs/changelog/20260709-122047-0310-backbone-model-contract-audit-builders.md`.
- `RESOLVED`: Unused `_listEquals` helper no longer present in `workspace_graph.dart`.
- `RESOLVED`: Flutter SDK available; historical EXTERNAL_BLOCKER is stale.

### Persistent Findings

- `PERSISTENT` / Low: Legacy `models.dart` (`Asset`/`AssetType`/`AssetEdge`) remains on disk for `workspace_parser.dart` compatibility. Ownership is explicit via SUPERSEDED notice and `data_models.dart` barrel preferring the backbone.

### Regressions

- None.

### New Findings

- `NEW` / Low: Builder self-score 100/100 is slightly overstated relative to residual dual-surface debt (legacy models still importable). Does not fail exit conditions.

### Evidence Gaps / External Blockers

- None for Task 0310 binary exits. Live corpus 91/130 frontmatter residual is owned by Tasks 1402/1403, not this model-contract task.

## Findings

| ID | Class | Severity | Status | Summary | First seen | Evidence |
| --- | --- | --- | --- | --- | --- | --- |
| F1 | RESOLVED | High | Closed | Package analyze/test gates fail | wave-3 | Live: No issues found; 27/27 PASS |
| F2 | RESOLVED | Medium | Closed | Missing changelog | wave-3 | `docs/changelog/20260709-122047-0310-…` |
| F3 | RESOLVED | Low | Closed | Unused `_listEquals` | wave-3 | `rg _listEquals lib/data/models` empty |
| F4 | PERSISTENT | Low | Open | Legacy models.dart retained | original design | SUPERSEDED notice + barrel docs; not dual-canonical for new code |
| F5 | NEW | Low | Open | Self-score 100 ignores residual dual-surface | this review | Task Completion Evidence self-score 100/100 |

## Exit Condition Verification

| Exit condition | Status | Live evidence |
| --- | --- | --- |
| Normalized backbone under `lib/data/models/` + barrel | PASS | `workspace_graph.dart`, `task_contracts.dart`, `changelog_contracts.dart`, `governance_diagnostics.dart`, `data_models.dart` |
| Legacy primitives removed or clearly superseded | PASS | SUPERSEDED doc on `models.dart`; barrel excludes legacy export |
| `flutter analyze lib/data/models test/data/models` clean | PASS | No issues found |
| `flutter test …/workspace_graph_models_test.dart` 0 failures | PASS | +27 All tests passed |
| Changelog under `docs/changelog/` | PASS | `20260709-122047-0310-backbone-model-contract-audit-builders.md` |

## Contract Fidelity Notes

- `AssetKind` = 9 (includes subskill/changelog/script/reference/rule)
- `EdgeKind` = 7 (contains, routesTo, dependsOn, references, changedBy, proves, uses)
- `Canonicality` = 6 (expanded beyond prompt’s four labels with archive/mock — documented and tested)
- `TaskLane` / `ProofState` / `TaskMetadata` / `ChangelogMetadata` / `GovernanceDiagnostic` present with parsing helpers (`fromStatus` maps bare lane words)

## Axiom Compliance

| Axiom | Status | Notes |
| --- | --- | --- |
| Analyzer Integrity | PASS | Scoped models surface: No issues found |
| Lifecycle Safety | PASS | Pure data models only |
| Dependency Direction | PASS | Models do not import UI/providers |
| UI Accessibility | N/A | No UI |
| Proof Reality | PASS | Fresh analyze + 27 tests match evidence |
| Release Security | PASS | No secrets/release path |

## Evidence Reviewed

- Task file Completion Evidence + Where table sources
- `apps/observatory/lib/data/models/*`, `test/data/models/workspace_graph_models_test.dart`
- Prior reports listed above

### Commands run

| Command | Cwd | Result |
| --- | --- | --- |
| `flutter analyze lib/data/models test/data/models` | `apps/observatory` | No issues found |
| `flutter test --concurrency=1 --no-pub test/data/models/workspace_graph_models_test.dart` | `apps/observatory` | +27 All tests passed |
| Corpus frontmatter scan (cross-task note) | `apps/observatory` | TOTAL=130 WITH_FM=91 WITHOUT=39 |

## Path To 100

1. Optionally stop exporting/retaining legacy graph types behind a single shim or archive note with zero new imports of `AssetType`/`AssetEdge` outside legacy parser.
2. Record residual dual-surface debt honestly in Completion Evidence (self-score ≤ 97 until legacy retired).
3. Re-run the two scoped gates and keep ledger green.

## Task Ledger Patch Suggestion

```markdown
## Review Ledger

### Latest Review
- **Date**: 2026-07-09
- **Reviewer profile**: `reviewers`
- **Score**: `95/100`
- **Verdict**: `HELD_IN_REVIEW_PATH_TO_100`
- **Full report**: `docs/reports/review-wave-2026-07-09/task-0310-backbone-model-contract-independent-rereview.md`
- **Lane outcome**: remain in `03-review`

#### Current Open Blockers
- None for binary exits. Low residual: legacy `models.dart` SUPERSEDED surface.

#### Path-to-100 Summary
- Optional legacy retirement/honesty on dual-surface; re-run scoped gates.

### Previous Reports
- `2026-06-17` — `72/100` — `docs/reports/review-wave-3/0310-review.md`
- `2026-06-13` — `100/100` — `docs/reports/build-gate-review/0310-review.md` (superseded)
```
