# Review Report: Task 0311 — Markdown Frontmatter Parser Fixtures — 2026-07-09

## Review Lineage

- **Current task**: Task 0311 (`warp-prism-markdown-frontmatter-parser-fixtures`); live path at review start: `docs/tasks/03-review/0311-warp-prism-markdown-frontmatter-parser-fixtures.md`
- **Previous reports read**:
  - `docs/reports/build-gate-review/0311-review.md` — 100/100 (SDK-blocked; stale)
  - `docs/reports/review-wave-3/0311-review.md` — **58/100** `REJECTED_TO_DOING` (upstream 0310, fixtures never loaded, lossy YAML, package gates, changelog)
- **Related reports considered**:
  - Task 0310 this wave — models contract **95/100** held (upstream stable enough for parser review)
  - `docs/reports/review-wave-2026-07-09/task-1403-parser-projection-independent-rereview.md` — **58/100** for phantom **130/130** corpus frontmatter; Task 0311 does **not** claim full-corpus remediation, but production corpus residual remains relevant for integration confidence
- **Review mode**: `re-review` (independent)

## Score And Verdict

- **Score**: `78/100`
- **Verdict**: `REJECTED_TO_DOING`
- **Lane recommendation**: `return-to-doing`

## Delta Summary

### Resolved Since Previous Review (2026-06-17 @ 58/100)

- `RESOLVED`: Focused parser gates execute. `dart analyze --format=machine lib/data/parsers test/data/parsers` → EXIT 0 (info-only lints). `flutter test test/data/parsers/workspace_markdown_parser_test.dart` → **All tests passed** (live **45** tests, not claimed 51). Full `test/data/parsers/` → **74/74 PASS**.
- `RESOLVED`: Changelog present: `docs/changelog/2026-07-09-task-0311-markdown-frontmatter-parser-fixtures-live-validation.md`.
- `RESOLVED` (partial): On-disk production corpus is exercised by History fixture ledger group (changelog + lane presence + id resolution).
- `RESOLVED` (dependency): Task 0310 model contract is now independently strong (95); no longer a hard upstream package-gate blocker for reviewing parser code quality.

### Persistent Findings

- `PERSISTENT` / High: Representative fixtures under `test/fixtures/mock_workspace/` (5 happy-path + 3 malformed) are **still not loaded** by the suite. Happy-path and malformed cases use **inline** markdown strings; `rg` finds **zero** `test/fixtures/mock_workspace` path references and no `File.read*` of those fixture files.
- `PERSISTENT` / High: Hand-rolled YAML subset in `frontmatter_parser.dart` remains lossy (skips non-matching lines, no nested maps/multiline scalars; inline lists split on commas inside quotes). Package already depends on `yaml` (`pubspec.yaml`) and legacy `workspace_parser.dart` imports `package:yaml`.

### Regressions

- `REGRESSION` / Medium (Proof Reality): Completion Evidence / subtask claims “fixture-file-backed” wiring and “51/51 PASS”. Live: fixtures unused for claimed families; test count is **45**.

### New Findings

- `NEW` / Low: Analyzer infos on production parser (`prefer_const_literals` ×4 in `workspace_markdown_parser.dart`) and test lint infos; not errors/warnings.
- `NEW` / Note: Unclosed malformed fixture content is correctly unclosed (4 lines, no closing `---`). Inline unclosed tests also cover the error path — fixture file remains dead weight until wired.

### Evidence Gaps / External Blockers

- `EVIDENCE_GAP`: No regression asserting `test/fixtures/mock_workspace/**` content is the parse input.
- Full mock corpus remains **91/130** with frontmatter (39 nested skill files missing). Task 0311 does not require 130/130, but repository/parser consumers will still drop skill-local workflows without FM (see Task 0312). Do **not** treat 0311 as proving corpus completeness.

## Findings

| ID | Class | Severity | Status | Summary | First seen | Evidence |
| --- | --- | --- | --- | --- | --- | --- |
| F1 | PERSISTENT | High | Open | Claimed fixtures never read from disk | wave-3 | No `test/fixtures/mock_workspace` usage in test file; inline literals only |
| F2 | PERSISTENT | High | Open | Lossy hand-rolled YAML vs available `yaml` package | wave-3 | `frontmatter_parser.dart` docs + `_parseYaml`; `pubspec.yaml` has `yaml: ^3.1.2` |
| F3 | RESOLVED | High | Closed | Package gates fail | wave-3 | Live analyze EXIT 0; 45 tests PASS; full parsers 74/74 |
| F4 | RESOLVED | Medium | Closed | Missing changelog | wave-3 | `docs/changelog/2026-07-09-task-0311-…` |
| F5 | REGRESSION | Medium | Open | False fixture-file-backed / 51-test claim | builder 2026-07-09 | Live 45 tests; fixtures unused |
| F6 | SUPERSEDED | High | Closed as dependency gate | Upstream 0310 rejected | wave-3 | 0310 this wave 95 held |

## Exit Condition Verification

| Exit condition | Status | Live evidence |
| --- | --- | --- |
| Frontmatter-aware parsers under `lib/data/parsers/` targeting backbone | PASS | `frontmatter_parser.dart`, `workspace_markdown_parser.dart` |
| Legacy YAML-only path isolated | PASS | `parsers.dart` barrel documents legacy vs canonical |
| `dart analyze … parsers` without errors/warnings | PASS | EXIT 0; info-only |
| `flutter test …/workspace_markdown_parser_test.dart` 0 failures | PASS | All passed (45 tests) |
| Changelog | PASS | present |
| Subtask “fixture-file-backed” | **FAIL** | fixtures on disk unused by primary suite |

## Axiom Compliance

| Axiom | Status | Notes |
| --- | --- | --- |
| Analyzer Integrity | PARTIAL | EXIT 0; 4 prod infos + test infos |
| Lifecycle Safety | PASS | Stateless parsers |
| Dependency Direction | PASS | Parsers → models only |
| UI Accessibility | N/A | |
| Proof Reality | FAIL | Fixture-file-backed + 51/51 claims false |
| Release Security | PASS | |

## Evidence Reviewed

- Task file + Completion Evidence
- `lib/data/parsers/{frontmatter_parser,workspace_markdown_parser,parsers}.dart`
- `test/data/parsers/workspace_markdown_parser_test.dart` (+ projection suite)
- Fixture tree under `test/fixtures/mock_workspace/`
- Live corpus scan (cross-check only)

### Commands run

| Command | Cwd | Result |
| --- | --- | --- |
| `dart analyze --format=machine lib/data/parsers test/data/parsers` | `apps/observatory` | EXIT 0; INFO lints only |
| `flutter test --concurrency=1 --no-pub test/data/parsers/workspace_markdown_parser_test.dart` | `apps/observatory` | All passed (45) |
| `flutter test --concurrency=1 --no-pub test/data/parsers/` | `apps/observatory` | 74/74 PASS |
| Fixture usage `rg` + `find test/fixtures/mock_workspace` | `apps/observatory` | 8 fixture files present; **0** test loads |
| Corpus scan | `apps/observatory` | TOTAL=130 WITH_FM=91 WITHOUT=39 |

## Path To 100

1. Wire happy-path + malformed tests to **read** `test/fixtures/mock_workspace/**` via `File.readAsStringSync` (or equivalent). Corrupt/remove a fixture and prove the suite fails for the right reason.
2. Prefer `package:yaml` for frontmatter decoding, or document a hard schema with explicit rejection tests for nested maps / quoted-comma lists / multiline scalars that currently silently degrade.
3. Correct Completion Evidence: real test counts; remove false “fixture-file-backed” wording until true.
4. Optionally clear const-literal infos if claiming zero-info analyze.
5. Re-run scoped analyze + `workspace_markdown_parser_test` + full `test/data/parsers/`.

## Task Ledger Patch Suggestion

```markdown
## Review Ledger

### Latest Review
- **Date**: 2026-07-09
- **Reviewer profile**: `reviewers`
- **Score**: `78/100`
- **Verdict**: `REJECTED_TO_DOING`
- **Full report**: `docs/reports/review-wave-2026-07-09/task-0311-markdown-frontmatter-parser-independent-rereview.md`
- **Lane outcome**: returned to `02-doing`

#### Current Open Blockers
- Fixtures under test/fixtures not loaded by suite (claimed wired).
- Hand-rolled YAML subset remains lossy while yaml package is available.
- Proof Reality: 51-test / fixture-file-backed claims false (live 45).

#### Path-to-100 Summary
- File-backed fixture tests; harden YAML; fix evidence; re-run gates.

### Previous Reports
- `2026-06-17` — `58/100` — `docs/reports/review-wave-3/0311-review.md`
- `2026-06-13` — `100/100` — `docs/reports/build-gate-review/0311-review.md` (superseded)
```
