# Review Report: Task 1402 — Corpus and Frontmatter Contract Audit — 2026-07-09

## Review Lineage

- **Current task**: Task 1402 (`1402-warp-prism-corpus-and-frontmatter-contract-audit`); live path at review start: `docs/tasks/03-review/1402-warp-prism-corpus-and-frontmatter-contract-audit.md`
- **Previous reports read**:
  - `docs/reports/build-gate-review/1402-review.md` — 100/100 (historical soft approval)
  - `docs/reports/build-gate-review/1402-review-2026-06-17.md` — 74/100 (contradictory corpus conclusion)
  - Task Review Ledger 2026-06-30 independent — **78/100** (stale `fromStatus` claim, 99/91 arithmetic, category-only nested mismatches)
  - Builder path-to-100 2026-07-09 — self **100/100** (claims live `130/130` frontmatter + per-file rows + fixed `fromStatus`)
- **Related reports considered**:
  - `docs/reports/corpus-frontmatter-audit.md` — primary deliverable
  - Task 1403 live in `docs/tasks/02-doing/` with independent rejection for **phantom corpus remediation** (same 39-file claim)
  - Task 1401 inventory (upstream; also rejected this wave for stale baseline)
- **Review mode**: `re-review` (independent; reviewers profile)

## Score And Verdict

- **Score**: `41/100`
- **Verdict**: `REJECTED_TO_DOING`
- **Lane recommendation**: `return-to-doing`

## Delta Summary

### Resolved Since Previous Review (2026-06-30 @ 78/100)

- `RESOLVED`: Live `TaskLaneParsing.fromStatus()` **does** map bare `planning/open/doing/review/completed` (no longer a pass-through-only bug). Report §3.1 live quote matches `task_contracts.dart:186-200`.
- `RESOLVED` (structure): Report now includes **39** per-file nested mismatch rows (was category-only) and corrects historical 91/39 arithmetic note.
- `RESOLVED` (partial): Schema tables for agents/skills/workflows/tasks/changelog remain useful for the 91 frontmatter-bearing files.

### Persistent Findings

- `PERSISTENT` / High: Nested skill corpus frontmatter defect class is still open on disk (**39** files without YAML frontmatter).

### Regressions

- `REGRESSION` / Critical for Proof Reality: Builder 2026-07-09 “live refresh” claims `WITH_FM=130 WITHOUT=0` and marks all 39 rows as **live present**. Independent live scan: **`TOTAL=130 WITH_FM=91 WITHOUT=39`**. All **39/39** “Actual (live 2026-07-09) = present” cells are **false**.

### New Findings

- `NEW` / High: Task 1402 refresh attributes corpus remediation to Task 1403, but Task 1403 is in `02-doing` with independent rejection documenting the same phantom 130/130 claim. Audit must not assert downstream remediation that is not on the filesystem.
- `NEW` / Medium: Upstream Task 1401 dependency is not a clean ready-for-review inventory (rejected this wave); not a code defect in 1402, but governance chain remains noisy.

### Evidence Gaps / External Blockers

- `EVIDENCE_GAP`: Whether nested files **must** carry frontmatter for production parse paths is still a design question, but the report cannot claim they already have frontmatter when they do not. Either restate live actual as missing or wait for a real Task 1403 corpus write.

## Findings

| ID | Class | Severity | Status | Summary | First seen | Evidence |
| --- | --- | --- | --- | --- | --- | --- |
| F1 | REGRESSION | Critical | Open | Live frontmatter count claim false (130/130 vs 91/130) | builder 2026-07-09 self-score | Live scan `WITH_FM=91 WITHOUT=39`; sample `tool-execution.md` starts with `# tool-execution`, not `---` |
| F2 | REGRESSION | Critical | Open | All 39 per-file “live present” dispositions are wrong | builder 2026-07-09 | Parsed 39 appendix rows; **39** claim `present` while disk lacks frontmatter |
| F3 | RESOLVED | High | Closed | `fromStatus` still pass-through | 2026-06-30 | Live switch maps bare lane words at `task_contracts.dart:186-200` |
| F4 | NEW | High | Open | Report asserts Task 1403 corpus fix that is not on disk / 1403 rejected | this report | `docs/tasks/02-doing/1403-…` Review State documents phantom remediation; nested files still plain markdown |
| F5 | RESOLVED | Medium | Closed | Missing per-file rows for nested mismatches | 2026-06-30 | Rows exist in §3.2 — but live column is false (F2) |
| F6 | PERSISTENT | Medium | Open | Nested files still lack frontmatter (if still required) | 2026-06-17 / 06-30 | 39 nested paths under `sub-skills`/`workflows`/`references` |

## Exit Condition Verification

| Exit condition | Status | Live evidence |
| --- | --- | --- |
| Report exists at `docs/reports/corpus-frontmatter-audit.md` | PASS | File present (~609 lines) |
| Each mismatch specifies file/field/expected/actual/recommendation | **FAIL** | Rows exist, but **actual (live)** is incorrect for 39/39 nested files (F1/F2) |
| Local changelog | FAIL (payload) | `docs/changelog/2026-07-09-task-1402-audit-report-live-refresh.md` claims `WITH_FM=130 WITHOUT=0` — false |
| Completion Evidence filled | FAIL | Claims live 130/130 + nested missing=0 — false against filesystem |

## Axiom Compliance

| Axiom | Status | Notes |
| --- | --- | --- |
| Analyzer Integrity | N/A (audit docs) | No Dart mutation required by task. |
| Lifecycle Safety | N/A | Docs-only. |
| Dependency Direction | N/A | Docs-only. |
| UI Accessibility | N/A | Docs-only. |
| Proof Reality | **FAIL** | Primary audit deliverable misstates live corpus frontmatter state for 39 files and invents a completed 1403 corpus fix. |
| Release Security | PASS | No secrets; audit-only guardrail appears preserved (no corpus mutation under 1402 itself). |

## Live Corpus Scan (this review)

```text
TOTAL=130 WITH_FM=91 WITHOUT=39
NESTED=39 NESTED_MISSING_FM=39 NESTED_NAME_DESC=0
Category counts: agents=9 skills=13 sub=13 skill-workflows=13 references=13
workflows=11 tasks=22 changelog=36  sum=130
Task status vocabulary: planning=3 open=5 doing=5 review=4 completed=5
```

Sample nested file head (`agent-cli-delegation/sub-skills/tool-execution.md`):

```markdown
# tool-execution

Sub-skill of `agent-cli-delegation`. Provides detailed rules and templates for tool-execution operations.
```

No YAML `---` frontmatter.

`fromStatus` live (correct in report §3.1):

```dart
// apps/observatory/lib/data/models/task_contracts.dart:186-200
static TaskLane fromStatus(String status) {
  switch (status.toLowerCase().trim()) {
    case 'planning': return TaskLane.planning;
    case 'open': return TaskLane.open;
    case 'doing': return TaskLane.doing;
    case 'review': return TaskLane.review;
    case 'completed': return TaskLane.completed;
    default: return fromDirectoryPrefix(status);
  }
}
```

## Evidence Reviewed

- Task: `docs/tasks/03-review/1402-warp-prism-corpus-and-frontmatter-contract-audit.md`
- Audit: `docs/reports/corpus-frontmatter-audit.md`
- Changelogs: 2026-06-09 original + 2026-07-09 live-refresh
- Parser/model: `task_contracts.dart`, parsers under `apps/observatory/lib/data/parsers/`
- Corpus: `apps/observatory/assets/mock_workspace/**/*.md` (full frontmatter scan)
- Related: Task 1403 doing-lane rejection notes on phantom frontmatter write
- Runtime wiring: N/A (audit-only verification task)

## Commands Run

```bash
test -f docs/reports/corpus-frontmatter-audit.md && echo PASS
# → PASS

python3 - <<'PY'
# frontmatter presence scan
# → TOTAL=130 WITH_FM=91 WITHOUT=39
# → NESTED=39 NESTED_MISSING_FM=39
# → false live present claims 39 of 39 appendix rows
PY

# Live fromStatus source inspection
# → maps bare status words (resolved)

# Related task lane
ls docs/tasks/*/1403*
# → docs/tasks/02-doing/1403-warp-prism-parser-and-task-projection-reconciliation.md
```

## Path To 100

1. **Re-scan** the mock workspace and replace every false “live present” claim with measured actuals (`91/130` with frontmatter unless files are really fixed).
2. For the 39 nested files, keep historical mismatch rows but set **Actual (live)** to `missing` until Task 1403 (or another authorized corpus task) actually writes frontmatter.
3. Do **not** claim Task 1403 remediated the corpus while 1403 is rejected/doing and disk still shows plain markdown.
4. Keep the correct `fromStatus` live quote (F3) — that part is good.
5. Refresh Completion Evidence + 2026-07-09 changelog so they no longer print `WITH_FM=130 WITHOUT=0`.
6. Optionally note parser tests may still pass without nested frontmatter; separate “required by contract” vs “required by current parser call sites” if recommending corpus-only vs parser-only disposition — but never invent filesystem state.
7. Re-submit for independent review after live numbers match the report tables.

## Task Ledger Patch Suggestion

```markdown
### Latest Review
- Date: 2026-07-09
- Reviewer profile: reviewers
- Score: 41/100
- Verdict: REJECTED_TO_DOING
- Full report: docs/reports/review-wave-2026-07-09/task-1402-corpus-frontmatter-independent-rereview.md
- Lane outcome: returned to doing
- Blockers: F1/F2 phantom 130/130 + 39 false live dispositions; F4 1403 corpus fix not on disk
```
