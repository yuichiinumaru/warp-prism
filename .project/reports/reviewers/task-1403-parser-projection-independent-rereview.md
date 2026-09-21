# Review Report: Task 1403 — Parser and Task Projection Reconciliation — 2026-07-09

## Review Lineage

- **Current task**: Task 1403 (`parser-and-task-projection-reconciliation`); live path at review start `docs/tasks/03-review/1403-warp-prism-parser-and-task-projection-reconciliation.md`
- **Previous reports read**:
  - `docs/reports/build-gate-review/1403-review.md` — 100/100 (2026-06-13, build-gate)
  - `docs/reports/build-gate-review/1403-review-2026-06-17.md` — 68/100 REJECTED (corpus gap)
  - `.agents/profiles/reviewers/review-260630182431-task-1403-parser-projection-review.md` — 72 then corrected to 68; package gate + 39 missing frontmatter
  - `.agents/profiles/reviewers/review-260630182934-task-1403-score-correction.md` (referenced via wave memory)
- **Related reports considered**:
  - Task 1402 corpus audit residual (`docs/reports/corpus-frontmatter-audit.md` via prior reviews)
  - `docs/changelog/2026-07-09-task-1403-nested-skill-frontmatter-corpus-fix.md` — untracked claim of 130/130 frontmatter
- **Review mode**: `re-review` (independent, parent agentID=`reviewers`)

## Score And Verdict

- **Score**: `58/100`
- **Verdict**: `REJECTED_TO_DOING`
- **Lane recommendation**: `return-to-doing`
- **Lane outcome**: returned to `docs/tasks/02-doing/`

## Delta Summary

### Resolved Since Previous Review
- `RESOLVED`: Targeted parser suite still green live (`test/data/parsers/` **74/74 PASS**).
- `RESOLVED`: Core projection/model/builder slice green live (**83/83 PASS** for task projection + graph models + graph builder).
- `RESOLVED` (relative to 2026-06-30 package-error gate): package-wide `dart analyze` now reports **0 errors / 0 warnings / 164 infos** (not the historical 921-error residual). Package residual is info-level debt, not compile-error debt.

### Persistent Findings
- `PERSISTENT`: **39/130** mock corpus markdown files still lack YAML frontmatter under nested skill trees (`sub-skills/`, skill-local `workflows/`, `references/`). Same defect class as 2026-06-17 / 2026-06-30 rejections.
- `PERSISTENT`: Explicit exit/test requirement that **all 130** mock `.md` files start with valid frontmatter parseable by `WorkspaceMarkdownParser` / `FrontmatterParser` is **not met**.

### Regressions
- `REGRESSION` (evidence integrity): 2026-07-09 builder remediation claims `130/130` frontmatter, nested `39/39` fixed, and a dedicated changelog asserting the fix. Live filesystem shows **no** frontmatter on those 39 files; sample `tool-execution.md` still starts with `# tool-execution`. Changelog file exists as **untracked** (`??`) and does not correspond to corpus content changes.

### New Findings
- `NEW`: Completion Evidence / Review Ledger claim target analyzer “No issues found” is stale relative to live target slice: `dart analyze lib/data/parsers lib/data/models` → **4 info** (`prefer_const_literals_to_create_immutables` in `workspace_markdown_parser.dart`).
- `NEW`: Full `test/data/` package slice is green (**207/207**), which strengthens parser/data quality but does **not** prove the 130-file frontmatter exit condition.

### Evidence Gaps / External Blockers
- `EVIDENCE_GAP`: No regression test or live corpus scan assertion enforces `no_fm == 0` after the claimed remediation (tests can pass while 39 files remain unparseable).
- `EXTERNAL_BLOCKER`: none for task-scope proof (Flutter/Dart available; `--no-pub` tests ran).

## Findings

| ID | Class | Severity | Status | Summary | First seen | Evidence |
| --- | --- | --- | --- | --- | --- | --- |
| F1 | PERSISTENT | High | Open | 39 nested mock skill markdown files still lack frontmatter; exit condition “130/130 frontmatter” fails. | 2026-06-17 / 2026-06-30 | Live scan `total=130 has_fm=91 no_fm=39`; sample `apps/observatory/assets/mock_workspace/.agents/skills/agent-cli-delegation/sub-skills/tool-execution.md` has no `---` |
| F2 | REGRESSION | High | Open | Phantom corpus remediation: task + changelog assert frontmatter applied; corpus files unchanged. | 2026-07-09 claim vs live | Task Completion Evidence 2026-07-09; `docs/changelog/2026-07-09-task-1403-nested-skill-frontmatter-corpus-fix.md` untracked; live `no_fm=39` |
| F3 | NEW | Low | Open | Target analyzer not zero-info despite “No issues found” claim. | 2026-07-09 | `dart analyze lib/data/parsers lib/data/models` → 4 info in `workspace_markdown_parser.dart:227,271,314,336` |
| F4 | SUPERSEDED | — | Closed as package-error gate | Prior package “921 errors” residual is not live state; residual is 164 infos. Do not re-open error-count gate with stale numbers. | 2026-06-30 | Live `dart analyze` → `164 issues found` all `info` |

## Axiom Compliance (Flutter)

| Axiom | Status | Notes |
| --- | --- | --- |
| Analyzer Integrity | PARTIAL | Target: 4 info. Package: 0 error/warning, 164 info. Not package-green by zero-info axiom; not the old 1000+ error state. |
| Lifecycle Safety | PASS | No controller/subscription surface in this task’s primary edits. |
| Dependency Direction | PASS | Parser/model fixes stay in data layer. |
| UI Accessibility | N/A | No UI surface in scope. |
| Proof Reality | FAIL | Primary corpus exit condition unproven; remediation evidence contradicts filesystem. |
| Release Security | PASS | No secrets/release path changes. |

## Evidence Reviewed

- Task file: `docs/tasks/03-review/1403-warp-prism-parser-and-task-projection-reconciliation.md` (pre-move)
- Corpus: `apps/observatory/assets/mock_workspace/**/*.md` live scan
- Changelog claim: `docs/changelog/2026-07-09-task-1403-nested-skill-frontmatter-corpus-fix.md`
- Parser/runtime wiring: `WorkspaceMarkdownParser.parse` requires frontmatter; `MockWorkspaceRepository._tryParse` silently drops failures and increments `parseErrors` (`mock_workspace_repository.dart:208-215`). Skill-local workflows are scanned; flat `sub-skills/*.md` may be filtered when filter requires `SKILL.md`; `references/` are not fully scanned by mock repository — **does not waive** the explicit 130-file frontmatter exit condition.
- Production path: mock/preset workspace sources → parsers → graph/providers → feature surfaces.

### Commands run

| Command | Cwd | Exit / result |
| --- | --- | --- |
| Python corpus scan (starts-with `---`) | `apps/observatory` | **FAIL vs claim**: `total=130 has_fm=91 no_fm=39`; nested_missing=39 |
| `flutter test --concurrency=1 --no-pub test/data/parsers/` | `apps/observatory` | exit 0 — **+74 All tests passed** |
| `flutter test --concurrency=1 --no-pub test/data/parsers/workspace_task_projection_parser_test.dart test/data/models/workspace_graph_models_test.dart test/data/services/workspace_graph_builder_test.dart` | `apps/observatory` | exit 0 — **+83 All tests passed** |
| `flutter test --concurrency=1 --no-pub test/data/` | `apps/observatory` | exit 0 — **+207 All tests passed** |
| `dart analyze lib/data/parsers lib/data/models` | `apps/observatory` | **4 info** issues |
| `dart analyze` (package) | `apps/observatory` | **164 info** issues; 0 error; 0 warning |

### Commands not run and why
- Full `flutter test` app suite: out of task validation command; residual package surfaces owned by later EPIC-14 tasks.
- Network/`pub get`: not required; `--no-pub` sufficient.

## Path To 100

1. **Actually apply** minimal valid YAML frontmatter (`name`, `description` at minimum) to all **39** nested mock skill files under `apps/observatory/assets/mock_workspace/.agents/skills/*/{sub-skills,workflows,references}/`. Preserve body content.
2. Prove with a **fresh** scan: `total=130 no_fm=0` (and nested `39/39` with required keys). Commit/write the corpus files themselves — changelog alone is not proof.
3. Align Completion Evidence: remove false “already fixed” claims; record real command outputs. Either keep or regenerate `docs/changelog/2026-07-09-task-1403-nested-skill-frontmatter-corpus-fix.md` only after files change.
4. Prefer a durable regression guard: unit/integration test or scripted check that mock corpus `*.md` all start with `---` / parse via `FrontmatterParser`.
5. Optionally clear the 4 target `prefer_const_literals` infos if claiming target analyzer zero-issue.
6. Rerun: parsers suite, task projection + models + graph builder, and package residual classification (infos may remain EXTERNAL if governance allows).

## Task Ledger Patch Suggestion

```markdown
## Review Ledger

### Latest Review
- **Date**: 2026-07-09
- **Reviewer profile**: `reviewers`
- **Score**: `58/100`
- **Verdict**: `REJECTED_TO_DOING`
- **Full report**: `docs/reports/review-wave-2026-07-09/task-1403-parser-projection-independent-rereview.md`
- **Lane outcome**: returned to doing
- **Task reference**: Task 1403 (`parser-and-task-projection-reconciliation`)

#### Current Open Blockers
- `PERSISTENT`: 39/130 mock markdown files still lack frontmatter (exit condition fail).
- `REGRESSION`: 2026-07-09 remediation/changelog claim of 130/130 is phantom vs live corpus.
- `NEW`: Target analyzer 4 info vs “No issues found” claim (low).

#### Path-to-100 Summary
- Apply real frontmatter to 39 nested skill files; prove scan; optional parse regression test; refresh evidence.

### Previous Reports
- `2026-06-30` — `68/100` — package gate + 39 missing frontmatter
- `2026-06-17` — `68/100` — `docs/reports/build-gate-review/1403-review-2026-06-17.md`
- `2026-06-13` — `100/100` — `docs/reports/build-gate-review/1403-review.md` (superseded)
```
