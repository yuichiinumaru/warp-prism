# Review Report: Task 0610 — Operate task projection contract — 2026-07-09

## Review Lineage

- **Current task**: Task 0610 (`0610-warp-prism-operate-task-projection-contract`); live path: `docs/tasks/03-review/0610-warp-prism-operate-task-projection-contract.md`
- **Previous reports read**:
  - Task Review Ledger 2026-06-30 — **82/100** FAIL (missing slug/statusLabel/type, weak headings, no structured evidence rows, lane hijack risk, no committed corpus drift guard)
  - `docs/reports/build-gate-review/0610-review.md` — historical soft **100/100** with Flutter SDK BLOCKED (invalid as live proof)
  - Task Builder Self-Review 2026-07-09 — **100/100** path-to-100 checklist
- **Related reports considered**:
  - Task 0611 board surface consumes projection via `buildOperateProjection` (bridge, not parser direct)
  - Task 1403/1406 operate flow reconciliation context
- **Review mode**: `re-review` (independent; parent agentID=`reviewers`; gt-flutter-code-reviewer + gt-code-quality-reviewer)
- **Reviewer**: independent reviewers wave 2026-07-09

## Score And Verdict

- **Score**: `94/100`
- **Verdict**: `HELD_IN_REVIEW_PATH_TO_100` (task-scope accept for S≥90; never auto-promote to `04-completed/`)
- **Lane recommendation**: `hold-in-review`

## Delta Summary

### Resolved Since Previous Review

- `RESOLVED`: `slug`, `statusLabel`, `type` on `TaskProjection` + parser + tests.
- `RESOLVED`: Tolerant `##` headings (`Exit Conditions (GDD/TDD)`, emoji Completion Evidence).
- `RESOLVED`: `sections` + `completionEvidenceRows` structured collections.
- `RESOLVED`: Directory-segment lane inference — path **wins**; filename substring cannot hijack (`_inferLane` segment map).
- `RESOLVED`: Committed five-lane fixture load test under `assets/mock_workspace/docs/tasks/`.
- `RESOLVED`: Named suite live **29/29**; scoped contract analyze **No issues found**.
- `RESOLVED`: Changelogs 2026-06-30 + 2026-07-09 path-to-100 present.

### Persistent Findings

- None of the 2026-06-30 **82/100** contract findings remain open against the dedicated parser.

### Regressions

- None on the dedicated parser surface.

### New Findings

- `NEW` (LOW): Format dirt — `dart format --output=none --set-exit-if-changed lib/data/parsers/workspace_task_projection_parser.dart` → **FORMAT_EXIT=1**.
- `NEW` (MODERATE note / residual integration): Production Operate board path (`OperatePage` → `buildOperateProjection(snapshot.tasks)`) does **not** call `WorkspaceTaskProjectionParser`. Snapshot tasks use `WorkspaceMarkdownParser` lane inference which is **status-first** and `path.contains` (substring), not the dedicated segment path-wins rules. Board still renders; dual-path residual risk is owned jointly with EPIC-03 markdown parse + Task 0611 bridge. **Not a Task 0610 exit-condition fail** (parser contract itself meets exits), but blocks a perfect “single production path” score.

### Evidence Gaps / External Blockers

- `EVIDENCE_GAP` (residual): No production entrypoint test asserts Operate lanes come exclusively from `WorkspaceTaskProjectionParser.parseAll`.
- `EXTERNAL_BLOCKER`: none for task-scoped parser proof.

## Findings

| ID | Class | Severity | Status | Summary | First seen | Evidence |
| --- | --- | --- | --- | --- | --- | --- |
| F1 | NEW | LOW | Open | Format dirt on parser file | 2026-07-09 | FORMAT_EXIT=1 on `workspace_task_projection_parser.dart` |
| F2 | NEW | MODERATE | Open (integration residual) | Dual lane-inference paths: dedicated parser path-wins vs markdown parser status-first | 2026-07-09 | `_inferLane` in task projection parser vs `_inferTaskLane` in `workspace_markdown_parser.dart:514-522` |

## Exit Conditions (task contract)

| # | Condition | Met? | Live proof |
| --- | --- | --- | --- |
| 1 | Structured Operate projection model | **YES** | `task_projection.dart` TaskProjection + EvidenceRow + MarkdownSection + OperateProjection |
| 2 | Parser for corpus tasks; no queue.md dependency | **YES** | `WorkspaceTaskProjectionParser`; no queue.md reference in contract path |
| 3 | Named parser test with 5 lanes + proof/review/deps | **YES** | **29/29** including committed corpus + path-wins |
| 4 | Analyze altered contract files | **YES** | No issues found |
| 5 | Relevant tests 0 failures | **YES** | 29/29 |
| 6 | Changelog | **YES** | 2026-06-30 + 2026-07-09 |

## Axiom Compliance (Flutter 6)

| Axiom | Status | Notes |
| --- | --- | --- |
| Analyzer Integrity | PASS (task scope) | Contract files: No issues found |
| Lifecycle Safety | PASS | **0** controllers/subscriptions in contract files |
| Dependency Direction | PASS | Model under `lib/data/models/`; feature re-export only |
| UI Accessibility | N/A → PASS (scope) | No interactive chrome in 0610 |
| Proof Reality | PASS | Live **29/29**; path-wins + corpus drift tests present |
| Release Security | PASS | No secrets/print |

## Contract proof (implementation vs tests)

### Required fields present

`id`, `slug`, `title`, `lane`, `statusLabel`, `type`, `priority`, `owner`, `proofState`, `reviewScore`, `linkedSkills`, `linkedWorkflows`, `dependsOn`, `blockers`, `verificationCommands`, `completionEvidenceSummary`, `completionEvidenceRows`, `sections`, `exitConditions`, `bodyMarkdown`, `filePath`.

### Lane inference (dedicated parser)

1. Path segments match `00-planning`…`04-completed` → lane
2. Else frontmatter status
3. Else open
4. Filename containing lane substrings cannot override directory segment

### Tests (exact)

Live run: **+29 All tests passed** for `workspace_task_projection_parser_test.dart`.

## Evidence Reviewed

- Task: `docs/tasks/03-review/0610-warp-prism-operate-task-projection-contract.md`
- Source: `task_projection.dart`, `workspace_task_projection_parser.dart`, feature re-export
- Cross-read: `workspace_markdown_parser.dart` `_inferTaskLane` (integration residual)
- Tests: `workspace_task_projection_parser_test.dart`
- Changelogs: 2026-06-30 + 2026-07-09 path-to-100

## Commands Run

```bash
# From apps/observatory/
flutter test --concurrency=1 --no-pub test/data/parsers/workspace_task_projection_parser_test.dart
# EXIT=0 → +29: All tests passed!

flutter analyze --no-pub \
  lib/data/models/task_projection.dart \
  lib/data/parsers/workspace_task_projection_parser.dart \
  lib/features/operate/task_projection.dart \
  lib/data/models/data_models.dart
# No issues found!

dart format --output=none --set-exit-if-changed \
  lib/data/parsers/workspace_task_projection_parser.dart
# FORMAT_EXIT=1
```

## Path To 100

1. `dart format` the parser file; re-run FORMAT_EXIT=0.
2. Align production lane inference: either route Operate through `WorkspaceTaskProjectionParser` or make `WorkspaceMarkdownParser._inferTaskLane` path-segment-wins identical to Task 0610 (coordinate with EPIC-03 / 0611 bridge). Add one regression test that a file in `03-review/` with stale `status: completed` lands in review under the production path Operate uses.

## Task Ledger Patch Suggestion

```markdown
- **2026-07-09 (independent re-review, reviewers)**: **94/100** — hold in `03-review/`.
  Report: `docs/reports/review-wave-2026-07-09/task-0610-operate-task-projection-independent-rereview.md`.
  Fresh proof: parser **29/29**; contract analyze 0 issues; 82/100 path-to-100 fields RESOLVED.
  Open: format dirt; dual lane-inference residual vs markdown parser. Lane: stay `03-review/`.
```
