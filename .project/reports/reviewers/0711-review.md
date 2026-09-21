# Review Report: Task 0711 — History Parser And Filter Index — 2026-06-18

## Review Lineage

- **Current task**: Task 0711 (`0711-warp-prism-history-parser-and-filter-index`); reviewed at `docs/tasks/03-review/0711-warp-prism-history-parser-and-filter-index.md`.
- **Previous reports read**:
  - `docs/reports/build-gate-review/0711-review.md` — 100/100 Approved with skipped SDK proof.
  - `docs/reports/build-gate-review/0710-review.md` — dependency approval now superseded.
  - `docs/reports/review-wave-3/0710-review.md` — current dependency review, 82/100 rejected.
- **Related reports considered**:
  - `docs/reports/build-gate-review/1403-review.md` — later parser reconciliation evidence: task projection/parser tests pass with broader app blockers.
- **Review mode**: re-review / final-gate.

## Score And Verdict

- **Score**: `74/100`
- **Verdict**: `REJECTED_TO_DOING`
- **Lane recommendation**: `return-to-doing`

## Delta Summary

### Resolved Since Previous Review

- `RESOLVED`: The focused History repository test is runnable in the live environment and passes: 21/21 tests.
- `RESOLVED`: Flutter SDK is available; the old SDK blocker is stale.

### Persistent Findings

- `PERSISTENT`: Task 0711 depends on Task 0710, which has live data but is currently rejected to doing with unresolved governance/evidence defects.
- `PERSISTENT`: Task file still has unchecked exit conditions/subtasks and missing changelog evidence despite `Ready For Review` state.

### Regressions

- None identified.

### New Findings

- `NEW`: The History read model exposes a `workflows` facet but always returns `const {}`; the contract requires skill/workflow filter facets/edges.
- `NEW`: The implementation does not actually load the mock changelog corpus itself; `HistoryRepository.buildTimeline` only transforms a caller-provided list of assets, while Task 0711’s exit condition requires a repository/service layer that loads the corpus and delivers timeline/groups.
- `NEW`: Focused analyzer on task-owned files reports issues, so the analyze exit claim is not clean.

### Evidence Gaps / External Blockers

- `EVIDENCE_GAP`: Completion Evidence claims 18 tests and skipped SDK validation; fresh proof is 21 tests passing plus 5 focused analyzer issues.
- `EXTERNAL_BLOCKER`: None for focused proof.

## Findings

| ID | Class | Severity | Status | Summary | First seen | Evidence |
| --- | --- | --- | --- | --- | --- | --- |
| F1 | PERSISTENT | High | Open | Required dependency Task 0710 remains rejected/in doing. | Current dependency review | `docs/tasks/02-doing/0710-warp-prism-history-fixture-ledger-corpus.md:128-140`; `docs/reports/review-wave-3/0710-review.md:13-17`. |
| F2 | NEW | High | Open | Workflow facet contract is not implemented. | Current review | `apps/observatory/lib/data/repositories/history_repository.dart:100-104` defines workflows facet; `:323-330` hard-codes `workflows: const {}`. |
| F3 | NEW | Medium | Open | Repository/read-model layer does not load the corpus; it only transforms injected assets. | Current review | `apps/observatory/lib/data/repositories/history_repository.dart:237-245` takes `List<WorkspaceAsset> changelogAssets`; no load method or corpus integration in this repository. |
| F4 | PERSISTENT | Medium | Open | Task state/evidence is stale and internally contradictory. | Task/current | `docs/tasks/03-review/0711-warp-prism-history-parser-and-filter-index.md:44-52`, `:61-67`, `:111-113`. |
| F5 | NEW | Low | Open | Focused analyzer is not clean. | Current review | Analyzer on `history_repository.dart` and `history_repository_test.dart` reports 5 info-level issues, including `history_repository_test.dart:1` dangling library doc comment. |

## Evidence Reviewed

- Task files: Task 0711 and dependency Task 0710.
- Source/test files: `apps/observatory/lib/data/repositories/history_repository.dart`, `repositories.dart`, `apps/observatory/lib/data/parsers/workspace_parser.dart`, `workspace_markdown_parser.dart`, `apps/observatory/lib/data/models/models.dart`, `changelog_contracts.dart`, `apps/observatory/test/data/history/history_repository_test.dart`.
- Runtime/non-runtime rationale: Task 0711 is data-layer/read-model work. Fresh proof exercises `HistoryRepository.buildTimeline` directly, but no production load path from bundled corpus into this read model is proven by the task-owned test.
- Commands run:
  - `HOME="$PWD/tmp/home" PUB_CACHE="$PWD/tmp/pub-cache" TMPDIR="$PWD/tmp" flutter test --no-pub apps/observatory/test/data/history/history_repository_test.dart` — PASS, 21 tests.
  - `HOME="$PWD/tmp/home" PUB_CACHE="$PWD/tmp/pub-cache" TMPDIR="$PWD/tmp" flutter analyze --no-pub apps/observatory/lib/data/repositories/history_repository.dart apps/observatory/test/data/history/history_repository_test.dart` — 5 info-level issues.
- Commands not run: full app suite; dependency Task 0710 and focused analyzer state already block promotion.
- Stale-evidence note: build-gate evidence claimed SDK unavailable and 18 tests; both are stale.

## Path To 100

1. Resolve Task 0710’s current open review blockers or explicitly re-scope Task 0711 to a dependency-safe subset with current dependency truth.
2. Implement workflow facets/edges, either by parsing workflows directly from changelog metadata or by resolving linked task/workflow graph edges, and add tests that assert non-empty workflow facets when fixture data contains workflows.
3. Add or wire a repository/service method that loads the mock changelog corpus through the canonical workspace repository path and returns `HistoryTimeline`/story groups, then test that load path.
4. Update task checkboxes and Completion Evidence to current commands/counts; remove the stale SDK blocker and add or explicitly waive the changelog entry.
5. Clean or accurately classify focused analyzer issues.

## Task Ledger Patch Suggestion

Add a latest-review entry for 2026-06-18 with score 74/100, verdict `REJECTED_TO_DOING`, this report path, current open blockers F1-F5, and prior `docs/reports/build-gate-review/0711-review.md` plus `docs/reports/review-wave-3/0710-review.md` as lineage.
