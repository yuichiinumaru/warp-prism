# Review Report: Task 0710 — History Fixture Ledger Corpus — 2026-06-17

## Review Lineage

- **Current task**: Task 0710 (`0710-warp-prism-history-fixture-ledger-corpus`); reviewed at `docs/tasks/03-review/0710-warp-prism-history-fixture-ledger-corpus.md`.
- **Previous reports read**:
  - `docs/reports/build-gate-review/0710-review.md` — 100/100 Approved.
  - `docs/reports/review-wave-2/0005-review.md` — Task 0005 live-corpus review, 94/100.
  - `docs/reports/review-wave-2/0004-review.md` — Task 0004 returned to doing, 86/100.
- **Related reports considered**: `docs/reports/warp-prism-task-gap-overlap-audit.md` — establishes Task 0005 ownership and Task 0710 enrichment boundary.
- **Review mode**: re-review / final-gate.

## Score And Verdict

- **Score**: `82/100`
- **Verdict**: `REJECTED_TO_DOING`
- **Lane recommendation**: `return-to-doing`

## Delta Summary

### Resolved Since Previous Review

- `RESOLVED`: The active monorepo corpus is live under `apps/observatory/assets/mock_workspace/`: 36 changelog entries, 22 tasks across all five lanes, 13 skills, and 11 workflows.
- `RESOLVED`: A fresh cross-reference audit found 36 valid changelog-to-task-to-skill/workflow chains and no broken references.
- `RESOLVED`: Focused History tests run successfully with `--no-pub`: 21/21 passed.

### Persistent Findings

- `PERSISTENT`: Task evidence and prior review still describe obsolete root paths (`assets/mock_workspace/...`) instead of the active app-owned asset tree.
- `PERSISTENT`: The task remains marked Ready For Review while exit conditions and core subtasks are unchecked and no task-local changelog evidence exists.

### Regressions

- None identified.

### New Findings

- `NEW`: The claimed dependency baseline is not governance-complete. Task 0005 is live under `04-completed/`, but Task 0004 is in `02-doing/` with `Review State: Builder Done`, and the EPIC-02 validation wave is not fully promoted. The data exists, but completion-state claims must distinguish live corpus sufficiency from dependency promotion.
- `NEW`: Completion Evidence reports 18 test cases; the current focused file runs 21 tests.

### Evidence Gaps / External Blockers

- `EVIDENCE_GAP`: The specified parser test path `test/data/parsers/workspace_parser_test.dart` does not exist in the monorepo. The focused History test is valid supporting proof, but task text must be updated to the actual test surface.
- `EVIDENCE_GAP`: Fresh focused analysis completed with five info-level lint findings, not the claimed clean `flutter analyze` gate.
- `EVIDENCE_GAP`: The corpus uses `impact` consistently; task prose alternates between `impact` and `impact_tags`. The accepted field name must be made explicit.
- `EXTERNAL_BLOCKER`: None. Flutter 3.44.1 and Dart 3.12.1 are installed. Earlier “Flutter SDK not installed” evidence is stale.

## Findings

| ID | Class | Severity | Status | Summary | First seen | Evidence |
| --- | --- | --- | --- | --- | --- | --- |
| F1 | PERSISTENT | High | Open | Ready-for-review state contradicts unchecked exits/subtasks and missing changelog evidence. | Task/current | `docs/tasks/03-review/0710-warp-prism-history-fixture-ledger-corpus.md:46-51`, `:61-66`, `:121` |
| F2 | EVIDENCE_GAP | High | Open | Required validation path is obsolete/nonexistent and the historical SDK blocker is false today. | Current review | `docs/tasks/03-review/0710-warp-prism-history-fixture-ledger-corpus.md:49-50`, `:66`, `:120`; fresh Flutter version/test/analyze commands below |
| F3 | NEW | Medium | Open | Dependency truth is incomplete: Task 0004 remains in doing/Builder Done even though its corpus is live. | Current review | `docs/tasks/02-doing/0004-warp-prism-task-lane-markdown-corpus.md:3-5`, `:129-133` |
| F4 | PERSISTENT | Medium | Open | All task paths/evidence point to pre-monorepo root assets while production pubspec loads app-owned assets. | Prior Task 0004/0005 reviews | `docs/tasks/03-review/0710-warp-prism-history-fixture-ledger-corpus.md:23`, `:36`, `:46-47`, `:72-83`; `apps/observatory/pubspec.yaml:32-42` |
| F5 | NEW | Low | Open | Completion Evidence says 18 tests; fresh run executes 21. | Current review | `docs/tasks/03-review/0710-warp-prism-history-fixture-ledger-corpus.md:117-120`; focused test output |

## Evidence Reviewed

- Task and dependency files: Task 0710, Task 0005, Task 0004, EPIC-02, prompt/research/draft, gap/overlap report.
- Where/source files: root pubspec, app pubspec, five legacy changelogs, legacy queue, active changelog/task fixture trees, History repository and focused tests.
- Runtime wiring/non-runtime rationale: Task 0710 is primarily fixture/read-model work. Production asset wiring is proven by `apps/observatory/pubspec.yaml:32-42`; repository behavior is directly exercised by focused tests. This report does not claim full History UI integration.
- Commands run:
  - `python3 tool/validate_mock_workspace.py --project-root apps/observatory` — PASS, all five validator groups.
  - Fresh Python schema/cross-reference audit — `changelog_count=36`, `task_count=22`, lanes `3/5/5/4/5`, `valid_multihop_chains=36`, `errors=[]`.
  - `HOME="$PWD/tmp/home" PUB_CACHE="$PWD/tmp/pub-cache" flutter test --no-pub apps/observatory/test/data/history/history_repository_test.dart` — PASS, 21 tests.
  - `HOME="$PWD/tmp/home" PUB_CACHE="$PWD/tmp/pub-cache" flutter analyze --no-pub apps/observatory/lib/data/repositories/history_repository.dart apps/observatory/test/data/history/history_repository_test.dart` — completed with 5 info-level issues.
  - `flutter --version`; `dart --version` — Flutter 3.44.1 / Dart 3.12.1 installed.
- Commands not accepted as proof:
  - Initial package-update runs failed because an app-local PUB_CACHE was placed inside the workspace and Dart treated cached packages as workspace members. The subsequent `--no-pub` runs are the valid fresh evidence.
  - Full workspace analyze/test was not run because this review is scoped and the working tree contains extensive unrelated concurrent changes.
- Stale-evidence note: the old build-gate report scored 100 despite skipped mandatory gates and asserted an SDK blocker that no longer exists.

## Path To 100

1. Update Task 0710 to the active `apps/observatory/assets/mock_workspace/...` and `apps/observatory/test/...` paths; name the real focused test.
2. Reconcile `impact` versus `impact_tags` and document whether workflows are direct changelog metadata or resolved through linked tasks.
3. Update Completion Evidence to fresh counts/output (36 changelogs, 22 tasks, 21 focused tests), remove the stale SDK blocker, and record the five info-level analyzer findings or fix them narrowly.
4. Add the required local changelog entry or obtain an explicit task-governance waiver.
5. Check completed subtasks/exits only after fresh proof, and state accurately that Task 0004 remains unpromoted even though its fixture corpus is live.

## Task Ledger Patch Suggestion

Add a latest-review entry for 2026-06-17 with score 82/100, verdict `REJECTED_TO_DOING`, this report path, the five open findings above, and the prior build-gate report as lineage.
