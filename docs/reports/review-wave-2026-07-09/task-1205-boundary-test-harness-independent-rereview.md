# Review Report: Task 1205 — Boundary Test Harness — 2026-07-09

## Review Lineage

- **Current task**: Task 1205 (`warp-prism-boundary-test-harness`); live path at review start `docs/tasks/03-review/1205-warp-prism-boundary-test-harness.md`
- **Previous reports read**:
  - `docs/reports/build-gate-review/1205-review.md` — build-gate / path-to-100 lineage
  - Task-embedded independent reviews (2026-06-11, 2026-06-30 ×2, 2026-07-09 builder proof packet)
- **Related reports considered**:
  - Task 1204 Melos `test-boundaries` wiring
  - Task 1126 README residual table (claims 6/6 boundary harness)
- **Review mode**: `re-review`
- **Reviewer profile**: `reviewers` (gt-code-quality-reviewer primary)

## Score And Verdict

- **Score**: `86/100`
- **Verdict**: `REJECTED_TO_DOING`
- **Lane recommendation**: `return-to-doing`
- **Human-facing verdict**: NEEDS FIX

## Delta Summary

### Resolved Since Previous Review
- `RESOLVED`: Pure-Dart / no-Flutter-SDK harness requirement. Live file uses `dart:io` CLI only; no `flutter_test`.
- `RESOLVED`: Repository-local Melos entrypoint. `pubspec.yaml` `test-boundaries` body is `dart run packages/warp_prism_ui/test/boundaries/boundary_test.dart --repo-root .`; `dart run melos run test-boundaries` PASS.
- `RESOLVED`: Stale root `lib/ test/` format command removed from active validation set (task-scoped path only).
- `RESOLVED`: Original 4 architectural checks still implemented and green.

### Persistent Findings
- `PERSISTENT` (MEDIUM → elevated by false precision): Completion Evidence continues to assert exact package-wide analyzer counts as “live” external-blocker truth. Independent live re-run no longer matches those counts (see F1).

### Regressions
- None functional. Harness still passes.

### New Findings
- `NEW` (HIGH for evidence integrity): 2026-07-09 proof packet claims package-wide `880` diagnostics (`468 ERROR, 7 WARNING, 405 INFO`) and boundary result `4/4 PASS`. Independent live re-run: package analyze **exit 0**, **158 INFO only**, **0 ERROR / 0 WARNING**, **0** diags in boundary file; harness **`6/6 PASS`**.
- `NEW` (MEDIUM): Task contract / exit conditions / changelog still describe “4 checks” while implementation and README residual table correctly reflect **6** checks (alias completeness + public barrel hide).

### Evidence Gaps / External Blockers
- `SUPERSEDED`: Prior EXTERNAL_BLOCKER package-red narrative is **not** currently true for `dart analyze packages/warp_prism_ui` (exit 0). Treat package-red as historical unless a fresh red baseline is recaptured.
- `EVIDENCE_GAP`: Dependency-outdated note remains non-task; not rescored as blocker.

## Findings

| ID | Class | Severity | Status | Summary | First seen | Evidence |
| --- | --- | --- | --- | --- | --- | --- |
| F1 | NEW / PERSISTENT class | High | Open | Stale/false-precision package analyzer “live” counts after path-to-100 | 2026-06-30 (count drift class); acute 2026-07-09 | Task header/Completion Evidence claim 880/468 ERROR; live `dart analyze packages/warp_prism_ui --format machine` → 158 INFO, exit 0 |
| F2 | NEW | Medium | Open | Check-count contract/evidence still say 4; live harness is 6 | 2026-07-09 independent | `boundary_test.dart:95-120` six `BoundaryCheck`s; stdout `Checks: 6/6 PASS`; task exit conditions still “4 checks” |
| F3 | RESOLVED | High | Closed | Flutter SDK / global melos requirement | 2026-06-11 | pure Dart + `dart run melos` |

### F1 detail

Task 1205 was rejected repeatedly for analyzer-count drift, then remediated on 2026-07-09 with a proof packet asserting exact live counts and EXTERNAL_BLOCKER classification. Independent re-run on the same calendar day (later tree state) shows the package gate is **green for errors/warnings**:

```text
dart analyze packages/warp_prism_ui --format machine
→ analyze_exit:0
→ total 158 diagnostics, all INFO
→ lib ERROR=0 WARNING=0 INFO=75
→ test ERROR=0 WARNING=0 INFO=83
→ boundary_test.dart diagnostics: 0
```

Carrying a 468-ERROR EXTERNAL_BLOCKER claim as current truth is **phantom evidence**, even if earlier in the day it was true. Path-to-100 for an evidence task requires a fresh count or an honest “superseded by later remediation” note—not frozen false precision.

### F2 detail

Original task required 4 rules; code now enforces 6 (superset). That is good product behavior, but exit conditions, Completion Evidence, and `docs/changelog/20260609-220000-1205-…` / `20260709-030039-1205-…` still say `4/4`, while README residual baseline already says `6/6`. Contract/evidence must be reconciled.

## Evidence Reviewed

- Task file + full Review Ledger history
- `packages/warp_prism_ui/test/boundaries/boundary_test.dart`
- Root `pubspec.yaml` `test-boundaries` script
- Changelogs `20260609-220000-1205-…`, `20260709-030039-1205-…`
- Commands run (independent 2026-07-09):

| Command | Exit | Result |
| --- | ---: | --- |
| `dart run packages/warp_prism_ui/test/boundaries/boundary_test.dart --repo-root .` | 0 | `6/6 PASS, 0 FAIL, 0 violation(s)` |
| `dart run melos run test-boundaries` | 0 | `6/6 PASS` |
| `dart analyze packages/warp_prism_ui/test/boundaries/boundary_test.dart` | 0 | No issues |
| `dart format --output=none --set-exit-if-changed packages/warp_prism_ui/test/boundaries/boundary_test.dart` | 0 | 0 changed |
| `dart analyze packages/warp_prism_ui --format machine` | 0 | 158 INFO; 0 ERROR; 0 WARNING; 0 in boundary file |

- Implementation quality notes: harness remains deterministic filesystem grep; fail-closed missing-dir handling present; no lifecycle/resources; sabotage-lite not required for pure CLI.

## Path To 100

1. Re-run package analyzer and rewrite header + Completion Evidence + changelogs with **fresh** totals; drop or reclassify the 880/468 ERROR EXTERNAL_BLOCKER claim (prefer SUPERSEDED if still green).
2. Update task Test Requirements / Exit Conditions / evidence from “4 checks / 4/4” to **6 checks / 6/6**, naming the two EPIC-13 checks (Prism alias completeness; public barrel hides DS*).
3. Keep task-scoped format/analyze commands; do not reintroduce root `lib/ test/`.
4. Resubmit in `Ready For Review` with exact stdout block matching the refreshed counts.

## Task Ledger Patch Suggestion

```markdown
### Latest Review
- **Date**: 2026-07-09
- **Reviewer profile**: `reviewers`
- **Score**: `86/100`
- **Verdict**: `REJECTED_TO_DOING`
- **Full report**: `docs/reports/review-wave-2026-07-09/task-1205-boundary-test-harness-independent-rereview.md`
- **Lane outcome**: returned to doing
- **Open blockers**: F1 stale analyzer counts; F2 4-vs-6 check contract drift
```
