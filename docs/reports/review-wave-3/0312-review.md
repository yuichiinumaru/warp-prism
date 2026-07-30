# Review Report: Task 0312 — Read-Only Mock Workspace Repository — 2026-06-17

## Review Lineage

- **Current task**: Task 0312 (`warp-prism-read-only-mock-workspace-repository`), reviewed at `docs/tasks/03-review/0312-warp-prism-read-only-mock-workspace-repository.md`.
- **Previous reports read**: `docs/reports/build-gate-review/0312-review.md` — claimed 100/100 while focused analyzer/test gates were blocked.
- **Related reports considered**:
  - `docs/reports/review-wave-3/0310-review.md` — upstream Task 0310 rejected.
  - `docs/reports/review-wave-3/0311-review.md` — upstream Task 0311 rejected.
- **Review mode**: dependency triage plus scoped repository/runtime-wiring review.

## Score And Verdict

- **Score**: `46/100`
- **Verdict**: `REJECTED_TO_DOING`
- **Lane recommendation**: `return-to-doing`

## Delta Summary

### Resolved Since Previous Review

- `RESOLVED`: A Task 0312 changelog entry exists at `docs/changelog/20260607-214824-0312-2026-06-07-task-0312-read-only-mock-workspace-repository-repair-bot.md`.

### Persistent Findings

- `PERSISTENT`: Focused analyzer and repository tests still do not execute; fresh commands fail during package resolution.

### Regressions

- None established because tests did not execute.

### New Findings

- `NEW`: Strict dependencies Task 0310 and Task 0311 are rejected, so Task 0312 cannot be approved as a stable consumer of their contracts.
- `NEW`: The repository implementation created by this task is not wired into the production provider path. The production provider defines a separate `MockWorkspaceRepository` class inside `workspace_providers.dart` and delegates to `PresetLocalWorkspaceSource`, not `data/repositories/mock_workspace_repository.dart`.
- `NEW`: Repository tests create directories via `Directory.systemTemp`, violating the Warp Prism “no external directories” rule and making the evidence unsuitable for this project.
- `NEW`: The repository silently downgrades parser failures to a “success with parseErrors” snapshot. The task requires deterministic error states for parser failures, not silent partial success.

### Evidence Gaps / External Blockers

- `EVIDENCE_GAP`: No passing focused analyzer/test evidence exists for the repository package surface.

## Findings

| ID | Class | Severity | Status | Summary | First seen | Evidence |
| --- | --- | --- | --- | --- | --- | --- |
| F1 | NEW | Critical | Open | Production provider does not use the reviewed repository implementation | 2026-06-17 | `apps/observatory/lib/data/providers/workspace_providers.dart:43-76` defines a local `MockWorkspaceRepository`; `apps/observatory/lib/data/repositories/mock_workspace_repository.dart:36-217` is not the provider implementation |
| F2 | NEW | High | Open | Upstream contract/parser dependencies are rejected | 2026-06-17 | Task line 9; `docs/reports/review-wave-3/0310-review.md`; `docs/reports/review-wave-3/0311-review.md` |
| F3 | NEW | High | Open | Parser failures are silently treated as partial success | 2026-06-17 | `apps/observatory/lib/data/repositories/mock_workspace_repository.dart:88-93,149-174`; task lines 39-40 require deterministic error states for parser failures |
| F4 | NEW | Medium | Open | Tests use external system temp directories | 2026-06-17 | `apps/observatory/test/data/repositories/mock_workspace_repository_test.dart:98-141,144-180,182-213` uses `Directory.systemTemp.createTemp` |
| F5 | PERSISTENT | High | Open | Focused analyzer/test gates do not execute | 2026-06-13 | task lines 48-49; fresh commands fail on nested repository-local Pub cache workspace discovery |

## Evidence Reviewed

- Full task, previous report, upstream review reports, prompt/draft/pubspec, repository source, model snapshot source, providers, and repository tests.
- Runtime wiring proof: failed. Production `workspaceRepositoryProvider` returns the local provider-layer `MockWorkspaceRepository`, which uses `PresetLocalWorkspaceSource`. The task-owned `lib/data/repositories/mock_workspace_repository.dart` is exported but not the implementation on the app load path.
- Commands run from `apps/observatory`:
  - `HOME=<repo>/tmp/home PUB_CACHE=<repo>/tmp/pub-cache flutter analyze lib/data/repositories lib/data/parsers test/data/repositories` — exit 1 before analysis.
  - `HOME=<repo>/tmp/home PUB_CACHE=<repo>/tmp/pub-cache flutter test test/data/repositories/mock_workspace_repository_test.dart` — exit 1 before tests.
  - Content search for repository wiring — found provider-local implementation.
  - Changelog searches — found Task 0312 changelog entry.
- Commands not run: broader suite, because the focused package gate cannot resolve packages.

## Stale-Evidence Notes

The previous report accepted manual import review and unrelated suite counts despite blocked focused gates. Current evidence shows a real runtime-wiring mismatch, so this is not merely stale environmental evidence.

## Path To 100

1. Resolve Tasks 0310 and 0311 first.
2. Wire the task-owned `data/repositories/mock_workspace_repository.dart` implementation into `workspaceRepositoryProvider`, or remove the unused implementation and make the provider-layer repository the canonical reviewed surface.
3. Decide the parse-failure contract: if malformed corpus is a load error, return `WorkspaceLoadState.error`; if partial success is intentional, update the task contract and expose deterministic warnings with tests.
4. Rewrite tests to create temporary fixtures only under repository-local `tmp/` or checked-in test fixtures, never `Directory.systemTemp` or absolute external paths.
5. Repair package resolution/cache discovery, then run focused analyzer and repository tests successfully.

## Dependency Effect

Task 0313 depends on Task 0312 plus Tasks 0310/0311. It must be rejected/triaged until the model, parser, and repository contracts are approved and runtime-wired.

## Task Ledger Patch Suggestion

Record 46/100, `REJECTED_TO_DOING`, this report, F1–F5, and the path to 100. Set Review State to `Package Gate Failed` or `Consumer Gate Failed` (runtime wiring defect) and route to `02-doing/`.
