# Review Report: Task 0311 — Markdown Frontmatter Parser Fixtures — 2026-06-17

## Review Lineage

- **Current task**: Task 0311 (`warp-prism-markdown-frontmatter-parser-fixtures`), reviewed at `docs/tasks/03-review/0311-warp-prism-markdown-frontmatter-parser-fixtures.md`.
- **Previous reports read**: `docs/reports/build-gate-review/0311-review.md` — claimed 100/100 while analyzer, tests, and changelog were blocked/deferred.
- **Related reports considered**: `docs/reports/review-wave-3/0310-review.md` — upstream Task 0310 rejected at 72/100.
- **Review mode**: dependency triage plus scoped code/test review.

## Score And Verdict

- **Score**: `58/100`
- **Verdict**: `REJECTED_TO_DOING`
- **Lane recommendation**: `return-to-doing`

## Delta Summary

### Resolved Since Previous Review

- None proven.

### Persistent Findings

- `PERSISTENT`: Analyzer and focused parser tests remain unexecuted; fresh commands fail during package resolution.
- `PERSISTENT`: Required changelog evidence remains absent.

### Regressions

- None established because tests did not execute.

### New Findings

- `NEW`: Strict dependency Task 0310 is rejected and in `Package Gate Failed`, so Task 0311 cannot be approved against a stable upstream model contract.
- `NEW`: The parser fixture files listed as proof are never loaded by the test suite; all behavioral inputs are duplicated inline. Fixture corruption/removal therefore would not fail the claimed fixture tests.
- `NEW`: The custom YAML subset silently accepts malformed YAML and loses valid YAML semantics (for example nested mappings/multiline scalars and quoted list values containing commas), despite the product contract requiring valid YAML frontmatter and the package already depending on `yaml`.

### Evidence Gaps / External Blockers

- `EVIDENCE_GAP`: The test suite does not prove the real fixture files or the production mock corpus parse.

## Findings

| ID | Class | Severity | Status | Summary | First seen | Evidence |
| --- | --- | --- | --- | --- | --- | --- |
| F1 | NEW | High | Open | Upstream backbone contract is not review-approved | 2026-06-17 | Task 0311 dependency at task line 9; `docs/reports/review-wave-3/0310-review.md` |
| F2 | NEW | High | Open | “Fixture” tests never read fixture files | 2026-06-17 | `apps/observatory/test/data/parsers/workspace_markdown_parser_test.dart:23-849`; only `test/fixtures` occurrences are a synthetic error-path string at lines 594-599 |
| F3 | NEW | High | Open | Hand-rolled parser silently degrades valid/malformed YAML | 2026-06-17 | `apps/observatory/lib/data/parsers/frontmatter_parser.dart:7-14,144-175,178-220`; `apps/observatory/pubspec.yaml:18` already provides `yaml` |
| F4 | PERSISTENT | High | Open | Focused analyzer/test gates do not execute | 2026-06-13 | task lines 49-50; fresh commands fail on nested repository-local Pub cache workspace discovery |
| F5 | PERSISTENT | Medium | Open | Required changelog entry absent | 2026-06-13 | task line 51; no Task 0311 changelog filename/content match |

## Evidence Reviewed

- Full task, previous report, Task 0310 report, prompt/draft, EPIC-02, and all task Where source/test paths.
- All eight claimed fixture paths were inventoried.
- Runtime wiring proof: the canonical parser is used by repository/data-layer code through `WorkspaceMarkdownParser`; however, upstream and package proof remain red.
- Commands run from `apps/observatory`:
  - `HOME=<repo>/tmp/home PUB_CACHE=<repo>/tmp/pub-cache flutter analyze lib/data/parsers test/data/parsers` — exit 1 before analysis.
  - `HOME=<repo>/tmp/home PUB_CACHE=<repo>/tmp/pub-cache flutter test test/data/parsers/workspace_markdown_parser_test.dart` — exit 1 before tests.
  - Fixture-consumption content search — no fixture reads.
  - Changelog filename/content searches — no result.
- Commands not run: broader suite, because package resolution fails before the focused gate.

## Stale-Evidence Notes

Flutter is installed now; the old SDK-unavailable explanation is stale. The previous 100/100 report also treated test presence and unrelated package counts as proof of parser behavior, which is not reproducible.

## Path To 100

1. Resolve Task 0310 and re-confirm the parser’s target contract.
2. Replace the lossy YAML subset with the existing `yaml` package or enforce a deliberately documented schema with explicit rejection of unsupported/malformed constructs.
3. Make tests load every claimed fixture from disk and add representative production-corpus files; prove malformed fixture failures for the intended reason.
4. Repair repository-local Pub cache/workspace discovery, then run focused analyzer and parser tests successfully.
5. Add governed Task 0311 changelog evidence and update completion claims.

## Dependency Effect

Task 0312 depends on Task 0311 and Task 0310. Task 0313 depends on the same chain. Neither can be approved while F1–F4 remain open.

## Task Ledger Patch Suggestion

Record 58/100, `REJECTED_TO_DOING`, this report, upstream rejection, fixture non-consumption, YAML correctness risk, failed package proof, and missing changelog. Set Review State to `Package Gate Failed` and route to `02-doing/`.
