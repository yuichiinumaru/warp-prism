# Review Report: Task 0312 — Read-Only Mock Workspace Repository — 2026-07-09

## Review Lineage

- **Current task**: Task 0312 (`warp-prism-read-only-mock-workspace-repository`); live path at review start: `docs/tasks/03-review/0312-warp-prism-read-only-mock-workspace-repository.md`
- **Previous reports read**:
  - `docs/reports/build-gate-review/0312-review.md` — 100/100 (SDK-blocked; stale)
  - `docs/reports/review-wave-3/0312-review.md` — **46/100** `REJECTED_TO_DOING` (dual repository, silent partial parse success, systemTemp, package gates, upstream)
- **Related reports considered**:
  - Task 0311 this wave — parser fixture residual
  - Task 1403 this wave — corpus frontmatter 91/130; skill-local workflows without FM hit repository scan
  - Task 0315 Completion Evidence — claims dual `MockWorkspaceRepository` removed from providers
- **Review mode**: `re-review` (independent)

## Score And Verdict

- **Score**: `84/100`
- **Verdict**: `REJECTED_TO_DOING`
- **Lane recommendation**: `return-to-doing`

## Delta Summary

### Resolved Since Previous Review (2026-06-17 @ 46/100)

- `RESOLVED`: Focused gates execute. Repository tests **6/6 PASS**. (Scoped analyze over repositories+parsers reports **4 info** issues in `workspace_markdown_parser.dart`, not errors.)
- `RESOLVED` / Critical: Production providers now use canonical `MockWorkspaceRepository` from `lib/data/repositories/` (`workspace_providers.dart` imports and constructs it; no local source-bridge class).
- `RESOLVED` (dependency partial): Upstream model/parser code exists and unit-tests green; 0311 still has proof gaps but repository can be reviewed on its own contract.

### Persistent Findings

- `PERSISTENT` / High: Parser failures remain **success + `metadata.parseErrors`**, not `WorkspaceLoadState.error`. Task text requires deterministic **error** states for parser failures; tests codify partial success (`handles malformed files gracefully`). Real corpus: repository scan of **104** files → **13** skill-local workflows lack frontmatter and become silent parseErrors while overall load still succeeds.
- `PERSISTENT` / Medium: Tests still use `Directory.systemTemp` for empty/malformed/type fixtures (Warp Prism environment rule preference for repo-local `tmp/` or checked-in fixtures).

### Regressions

- None vs wave-3 code defects that remain open (they never closed). Wiring fix is real progress, not a regression.

### New Findings

- `NEW` / Medium: Builder Completion Evidence “analyze → No issues found” is inaccurate for the declared command set that includes `lib/data/parsers` (live: 4 info). Errors/warnings absent; wording still overstated.
- `NEW` / Low: Success test soft-skips when mock corpus path missing (`return` without fail) — weak under alternate cwd.

### Evidence Gaps / External Blockers

- `EVIDENCE_GAP`: No assertion that `parseErrors` equals expected count for the **real** corpus (would catch the 13 missing skill-local workflow frontmatter cases).
- Cross-task: full tree **39** files lack FM; repository filter (`sub-skills` requires `SKILL.md`; no `references/` scan) hides 26 of those from load — does not repair corpus.

## Findings

| ID | Class | Severity | Status | Summary | First seen | Evidence |
| --- | --- | --- | --- | --- | --- | --- |
| F1 | RESOLVED | Critical | Closed | Provider uses separate MockWorkspaceRepository | wave-3 | `workspace_providers.dart` uses `../repositories/mock_workspace_repository.dart` |
| F2 | PERSISTENT | High | Open | Parser failures → partial success not error | wave-3 | `mock_workspace_repository.dart:170-174`; test expects success + parseErrors |
| F3 | PERSISTENT | Medium | Open | `Directory.systemTemp` in tests | wave-3 | test lines 100, 145, 183 |
| F4 | RESOLVED | High | Closed | Package gates fail | wave-3 | 6/6 tests PASS live |
| F5 | NEW | Medium | Open | 13 real skill-local workflows scan as parseErrors silently | this review | REPO_SCANNED=104 WITH_FM=91 WITHOUT=13 (workflows under skills/*/workflows) |
| F6 | NEW | Low | Open | Analyze “No issues” claim vs 4 infos | this review | flutter analyze repositories+parsers |

## Exit Condition Verification

| Exit condition | Status | Live evidence |
| --- | --- | --- |
| Read-only repository interface + mock impl | PASS | `workspace_repository.dart`, `mock_workspace_repository.dart` |
| Typed workspace snapshot aggregate | PASS | `WorkspaceSnapshot` + `WorkspaceLoadState` |
| Scoped analyze without errors | PASS | 0 error/warning; 4 info in parsers |
| Repository tests 0 failures | PASS | 6/6 |
| Changelog | PASS | `docs/changelog/20260607-214824-0312-…` |
| Test requirement: deterministic error for parser failures | **FAIL / DRIFT** | Success + parseErrors |

## Axiom Compliance

| Axiom | Status | Notes |
| --- | --- | --- |
| Analyzer Integrity | PARTIAL | No errors; infos + overstated evidence |
| Lifecycle Safety | PASS | Read-only IO; no controllers |
| Dependency Direction | PASS | Repo → parsers → models |
| UI Accessibility | N/A | |
| Proof Reality | PARTIAL | Wiring fixed; parse-failure contract drift + systemTemp remain |
| Release Security | PASS | Read-only; no writes |

## Evidence Reviewed

- `mock_workspace_repository.dart`, `workspace_load_state.dart`, `workspace_snapshot.dart`
- `test/data/repositories/mock_workspace_repository_test.dart`
- `workspace_providers.dart` wiring
- Live corpus scan filtered to repository discovery rules

### Commands run

| Command | Cwd | Result |
| --- | --- | --- |
| `flutter analyze lib/data/repositories lib/data/parsers test/data/repositories` | `apps/observatory` | 4 info (parser) |
| `flutter test --concurrency=1 --no-pub test/data/repositories/mock_workspace_repository_test.dart` | `apps/observatory` | 6/6 PASS |
| Python repo-scan frontmatter | `apps/observatory` | 104 scanned; 13 without FM (skill-local workflows) |

## Path To 100

1. Decide parse-failure contract and implement **one** of:
   - **Strict**: if `parseErrors > 0` and no assets, or if `parseErrors` exceeds threshold / any error in required trees → `WorkspaceLoadState.error` with message listing paths; **or**
   - **Partial-success**: keep success+parseErrors but **update task contract/tests** to require surfacing error paths in metadata and assert real-corpus `parseErrors` expectation (currently 13 until corpus fixed).
2. Prefer fixing the 13 skill-local workflow frontmatter files (aligns with Task 1403) so load is clean.
3. Move temp fixtures to repo-local `tmp/` or `test/fixtures/` (no `Directory.systemTemp`).
4. Fail hard if real mock corpus is missing in the success test (no silent skip).
5. Re-run scoped analyze + repository suite; fix evidence wording.

## Task Ledger Patch Suggestion

```markdown
## Review Ledger

### Latest Review
- **Date**: 2026-07-09
- **Reviewer profile**: `reviewers`
- **Score**: `84/100`
- **Verdict**: `REJECTED_TO_DOING`
- **Full report**: `docs/reports/review-wave-2026-07-09/task-0312-mock-workspace-repository-independent-rereview.md`
- **Lane outcome**: returned to `02-doing`

#### Current Open Blockers
- Parse-failure contract drift (success+parseErrors vs task error requirement).
- 13 skill-local workflows without frontmatter → silent parseErrors on real corpus.
- systemTemp fixtures remain.

#### Path-to-100 Summary
- Lock error vs partial-success contract; fix or assert corpus parseErrors; repo-local temps; re-prove gates.

### Previous Reports
- `2026-06-17` — `46/100` — `docs/reports/review-wave-3/0312-review.md`
- `2026-06-13` — `100/100` — `docs/reports/build-gate-review/0312-review.md` (superseded)
```
