# Review Report: Task 0313 — Graph Normalization And Edge Inference — 2026-07-09

## Review Lineage

- **Current task**: Task 0313 (`warp-prism-graph-normalization-edge-inference`); live path at review start: `docs/tasks/03-review/0313-warp-prism-graph-normalization-edge-inference.md`
- **Previous reports read**:
  - `docs/reports/build-gate-review/0313-review.md` — 100/100 (SDK-blocked; stale)
  - `docs/reports/review-wave-3/0313-review.md` — **60/100** `REJECTED_TO_DOING` (upstream rejections, package gates, double-prefix IDs, skillDirectoryPattern ignored)
- **Related reports considered**:
  - Tasks 0310–0312 this wave (models strong; parser/repo residual)
  - Task 1403 parser/projection wave (corpus FM residual does not waive graph unit correctness)
- **Review mode**: `re-review` (independent)

## Score And Verdict

- **Score**: `88/100`
- **Verdict**: `REJECTED_TO_DOING`
- **Lane recommendation**: `return-to-doing`

## Delta Summary

### Resolved Since Previous Review (2026-06-17 @ 60/100)

- `RESOLVED`: Focused gates execute. `flutter test test/data/services/workspace_graph_builder_test.dart` → **+27 All tests passed**.
- `RESOLVED`: Runtime consumers exist (`workspace_providers.dart` builds graph via `WorkspaceGraphBuilder`).
- `RESOLVED` (partial upstream): Model backbone independent score 95; repository dual-impl wiring fixed (still residual parse contract on 0312).

### Persistent Findings

- `PERSISTENT` / Medium–High: ID normalization can double-prefix. `inferAgentUsage` / related helpers always emit `skill:$name` / `workflow:$name`. Test `inferAgentUsage creates uses edges` passes `skills: ['skill:code-gen']` and asserts **only** count/kind — would accept `skill:skill:code-gen`.
- `PERSISTENT` / Low: `inferPathContainment` still ignores `skillDirectoryPattern` and matches any `/skills/<name>/workflows/` path; parameter is dead API surface.

### Regressions

- None.

### New Findings

- `NEW` / Low: Scoped analyze over services+repositories+tests reports multiple **info** lints (const literals, dangling library doc) — not errors; Completion Evidence “No issues found” is slightly soft if infos count as issues.
- `NEW` / Note: Parser-level edge builders use the same unconditional prefix pattern (`workspace_markdown_parser.dart`), so double-prefix is a **shared** ID convention bug across 0311/0313, not only the inference service.

### Evidence Gaps / External Blockers

- `EVIDENCE_GAP`: No test asserts exact `targetId` when inputs already carry kind prefixes.
- Mock corpus 91/130 FM residual reduces live edge completeness for skill-local workflows (parse drop) — integration debt tracked primarily under 0312/1403.

## Findings

| ID | Class | Severity | Status | Summary | First seen | Evidence |
| --- | --- | --- | --- | --- | --- | --- |
| F1 | RESOLVED | High | Closed | Package gates fail | wave-3 | 27/27 PASS live |
| F2 | PERSISTENT | Medium | Open | Double-prefixed target IDs; tests miss exact IDs | wave-3 | `edge_inference_service.dart` prefixing; test L265-272 |
| F3 | PERSISTENT | Low | Open | `skillDirectoryPattern` unused | wave-3 | `inferPathContainment` L272-288 |
| F4 | SUPERSEDED | High | Closed as pure dep gate | Upstream 0310–0312 fully rejected | wave-3 | Partial recovery this wave; residual 0311/0312 not auto-fail graph unit logic |
| F5 | NEW | Low | Open | Info-level analyze noise vs “No issues found” | this review | analyze 17 infos across services tests |

## Exit Condition Verification

| Exit condition | Status | Live evidence |
| --- | --- | --- |
| Graph normalization + edge inference under services | PASS | `workspace_graph_builder.dart`, `edge_inference_service.dart`, `workspace_graph.dart` (result type) |
| One canonical graph result type | PASS | `WorkspaceGraphResult` |
| Scoped analyze without errors | PASS | infos only |
| Graph builder tests 0 failures | PASS | 27/27 |
| Changelog | PASS | `docs/changelog/20260607-215829-0313-…` |
| Exact ID normalization correctness | **PARTIAL FAIL** | double-prefix hazard |

## Axiom Compliance

| Axiom | Status | Notes |
| --- | --- | --- |
| Analyzer Integrity | PARTIAL | No errors; infos |
| Lifecycle Safety | PASS | Pure services |
| Dependency Direction | PASS | Services consume models/snapshot |
| UI Accessibility | N/A | |
| Proof Reality | PARTIAL | Gates green; ID normalization under-tested |
| Release Security | PASS | |

## Evidence Reviewed

- `edge_inference_service.dart`, `workspace_graph_builder.dart`, service `workspace_graph.dart`
- `test/data/services/workspace_graph_builder_test.dart`
- Parser edge builders for shared prefix pattern
- Provider graph wiring

### Commands run

| Command | Cwd | Result |
| --- | --- | --- |
| `flutter analyze lib/data/services lib/data/repositories test/data/services` | `apps/observatory` | 17 info issues |
| `flutter test --concurrency=1 --no-pub test/data/services/workspace_graph_builder_test.dart` | `apps/observatory` | +27 All tests passed |

## Path To 100

1. Add `_normalizeId(kindPrefix, raw)` that strips an existing prefix before re-applying; apply across inference helpers and parser edge builders for consistency.
2. Assert exact `targetId` values in tests for bare names **and** already-prefixed inputs (`skill:code-gen` → `skill:code-gen`, never `skill:skill:code-gen`).
3. Either honor `skillDirectoryPattern` (return null when path skill ≠ pattern) or remove the parameter and document path-only inference.
4. Re-run graph suite + scoped analyze; correct “No issues found” wording if infos remain.

## Task Ledger Patch Suggestion

```markdown
## Review Ledger

### Latest Review
- **Date**: 2026-07-09
- **Reviewer profile**: `reviewers`
- **Score**: `88/100`
- **Verdict**: `REJECTED_TO_DOING`
- **Full report**: `docs/reports/review-wave-2026-07-09/task-0313-graph-normalization-independent-rereview.md`
- **Lane outcome**: returned to `02-doing`

#### Current Open Blockers
- Double-prefix edge target IDs under-tested.
- skillDirectoryPattern dead parameter.

#### Path-to-100 Summary
- Normalize IDs; exact targetId tests; fix or drop unused param; re-prove.

### Previous Reports
- `2026-06-17` — `60/100` — `docs/reports/review-wave-3/0313-review.md`
- `2026-06-13` — `100/100` — `docs/reports/build-gate-review/0313-review.md` (superseded)
```
