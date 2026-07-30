# Review Report: Task 0712 — History Workspace Timeline Route — 2026-06-18

## Review Lineage

- **Current task**: Task 0712 (`0712-warp-prism-history-workspace-timeline-route`); reviewed at `docs/tasks/03-review/0712-warp-prism-history-workspace-timeline-route.md`.
- **Previous reports read**:
  - `docs/reports/build-gate-review/0712-review.md` — 100/100 Approved with stale skipped-SDK proof.
  - `docs/reports/build-gate-review/0711-review.md` — dependency approval now superseded.
  - `docs/reports/review-wave-3/0711-review.md` — current dependency review, 74/100 rejected.
  - `docs/reports/review-wave-3/0710-review.md` — upstream History corpus dependency rejected.
- **Related reports considered**:
  - `docs/reports/build-gate-review/1406-review.md` — later History/Operate flow remediation context.
- **Review mode**: re-review / final-gate.

## Score And Verdict

- **Score**: `64/100`
- **Verdict**: `REJECTED_TO_DOING`
- **Lane recommendation**: `return-to-doing`

## Delta Summary

### Resolved Since Previous Review

- `RESOLVED`: The focused History page widget test is runnable and passes: 15/15 tests.
- `RESOLVED`: Flutter SDK is available; prior skipped-SDK evidence is stale.

### Persistent Findings

- `PERSISTENT`: Task 0712 depends on Task 0711, which is currently rejected; the upstream 0710 dependency is also rejected.

### Regressions

- None identified.

### New Findings

- `NEW`: The production `/history` route instantiates `HistoryWorkspacePage` with no state/provider/repository, so it renders an empty History surface rather than the mock corpus timeline.
- `NEW`: `HistoryWorkspacePage` consumes `HistoryState` built from `ChangelogMetadata` directly, not the Task 0711 `HistoryRepository`/`HistoryTimeline` read model; this violates the “uses Task 0711 read model” exit condition.
- `NEW`: Focused analyzer on task-owned files reports task-owned issues.

### Evidence Gaps / External Blockers

- `EVIDENCE_GAP`: The passing widget test uses injected test state and does not prove router-to-repository-to-timeline wiring.
- `EXTERNAL_BLOCKER`: None for focused proof.

## Findings

| ID | Class | Severity | Status | Summary | First seen | Evidence |
| --- | --- | --- | --- | --- | --- | --- |
| F1 | PERSISTENT | High | Open | Required dependencies Task 0711 and Task 0710 are rejected. | Current review | `docs/reports/review-wave-3/0711-review.md`; `docs/reports/review-wave-3/0710-review.md`; Task 0712 depends on Task 0711 at `docs/tasks/03-review/0712-warp-prism-history-workspace-timeline-route.md:9`. |
| F2 | NEW | High | Open | `/history` route does not load or inject the mock History read model. | Current review | `apps/observatory/lib/app/router.dart:73-76` builds `const HistoryWorkspacePage()`; `apps/observatory/lib/features/history/presentation/history_page.dart:43-46` falls back to `const HistoryState()` when no initial state is provided. |
| F3 | NEW | High | Open | Page does not consume Task 0711 `HistoryRepository`/`HistoryTimeline`. | Current review | `apps/observatory/lib/features/history/presentation/history_page.dart:16-19` imports changelog contracts/controller, not `history_repository.dart`; `apps/observatory/lib/features/history/presentation/history_controller.dart:65-123` filters `List<ChangelogMetadata>` directly. |
| F4 | NEW | Medium | Open | Focused analyzer is not clean. | Current review | Analyzer reports unused imports at `history_controller.dart:10` and `history_page.dart:14`, deprecations at `history_page.dart:388`, `:393`, and test const-literal issues. |
| F5 | EVIDENCE_GAP | Medium | Open | Widget proof is injection-only and does not validate route/provider/repository wiring. | Current review | Passing command covers `apps/observatory/test/features/history/history_page_test.dart`, but router wiring at `apps/observatory/lib/app/router.dart:73-76` is untested by this focused file. |

## Evidence Reviewed

- Task files: Task 0712 and dependencies Task 0711 / Task 0710.
- Source/test files: `apps/observatory/lib/features/history/presentation/history_page.dart`, `history_controller.dart`, `history_view_mode.dart`, `apps/observatory/lib/app/router.dart`, `apps/observatory/lib/app/app.dart`, `apps/observatory/lib/data/repositories/history_repository.dart`, `apps/observatory/test/features/history/history_page_test.dart`.
- Runtime wiring proof: route registration exists, but data wiring is missing. `/history` reaches `HistoryWorkspacePage`, yet default construction produces empty `HistoryState`; no canonical repository/provider path is called.
- Commands run:
  - `HOME="$PWD/tmp/home" PUB_CACHE="$PWD/tmp/pub-cache" TMPDIR="$PWD/tmp" flutter test --no-pub apps/observatory/test/features/history/history_page_test.dart` — PASS, 15 tests.
  - `HOME="$PWD/tmp/home" PUB_CACHE="$PWD/tmp/pub-cache" TMPDIR="$PWD/tmp" flutter analyze --no-pub apps/observatory/lib/features/history/presentation/history_controller.dart apps/observatory/lib/features/history/presentation/history_page.dart apps/observatory/lib/app/router.dart apps/observatory/test/features/history/history_page_test.dart` — 12 issues.
  - Dependency supporting: `flutter test --no-pub apps/observatory/test/data/history/history_repository_test.dart` — PASS, 21 tests; but Task 0711 remains rejected for contract/wiring gaps.
- Commands not run: full app suite; focused dependency and wiring findings already block approval.
- Stale-evidence note: task evidence says SDK validation was skipped; current focused Flutter tests run.

## Path To 100

1. Resolve Task 0711 and Task 0710 blockers first, or re-scope Task 0712 with accurate dependency truth.
2. Wire `/history` to a provider/controller that loads the canonical mock corpus through the workspace/history repository and supplies a populated read model to the page.
3. Refactor `HistoryState`/page to consume the Task 0711 `HistoryTimeline`/facets contract, or document and test an adapter from `HistoryTimeline` to page state.
4. Add a route/provider integration test that navigates to `/history` and proves real corpus entries render without injecting hand-built page state.
5. Clean or classify focused analyzer issues and refresh task evidence with current command output.

## Task Ledger Patch Suggestion

Add a latest-review entry for 2026-06-18 with score 64/100, verdict `REJECTED_TO_DOING`, this report path, current open blockers F1-F5, and prior `docs/reports/build-gate-review/0712-review.md`, `docs/reports/review-wave-3/0711-review.md`, and `docs/reports/review-wave-3/0710-review.md` as lineage.
