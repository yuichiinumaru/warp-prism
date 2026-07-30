# Review Report: Task 0313 — Graph Normalization And Edge Inference — 2026-06-17

## Review Lineage

- **Current task**: Task 0313 (`warp-prism-graph-normalization-edge-inference`), reviewed at `docs/tasks/03-review/0313-warp-prism-graph-normalization-edge-inference.md`.
- **Previous reports read**: `docs/reports/build-gate-review/0313-review.md` — claimed 100/100 while focused analyzer/test gates were blocked.
- **Related reports considered**:
  - `docs/reports/review-wave-3/0310-review.md` — upstream Task 0310 rejected.
  - `docs/reports/review-wave-3/0311-review.md` — upstream Task 0311 rejected.
  - `docs/reports/review-wave-3/0312-review.md` — upstream Task 0312 rejected.
- **Review mode**: dependency triage plus scoped graph-service review.

## Score And Verdict

- **Score**: `60/100`
- **Verdict**: `REJECTED_TO_DOING`
- **Lane recommendation**: `return-to-doing`

## Delta Summary

### Resolved Since Previous Review

- `RESOLVED`: A Task 0313 changelog entry exists at `docs/changelog/20260607-215829-0313-2026-06-07-task-0313-graph-normalization-edge-inference-repair-bot.md`.
- `RESOLVED`: Runtime consumers exist for `WorkspaceGraphBuilder`/`WorkspaceGraphResult` in provider and feature layers.

### Persistent Findings

- `PERSISTENT`: Focused analyzer and graph tests still do not execute; fresh commands fail during package resolution.

### Regressions

- None established because tests did not execute.

### New Findings

- `NEW`: Strict upstream Tasks 0310, 0311, and 0312 are rejected. Task 0313 cannot be approved while its model/parser/repository inputs are not stable.
- `NEW`: Tests miss malformed ID normalization cases. `inferAgentUsage` blindly prefixes `skill:`/`workflow:` even if callers pass canonical IDs; the test passes `skills: ['skill:code-gen']` but asserts only edge count/kind, not the resulting `targetId`, so it would accept `skill:skill:code-gen`.
- `NEW`: `inferPathContainment` ignores its `skillDirectoryPattern` parameter and will return a containment edge for any path matching `/skills/<name>/workflows/`, even when the caller asked about a different skill.

### Evidence Gaps / External Blockers

- `EVIDENCE_GAP`: No passing focused analyzer/test evidence exists for graph services.

## Findings

| ID | Class | Severity | Status | Summary | First seen | Evidence |
| --- | --- | --- | --- | --- | --- | --- |
| F1 | NEW | High | Open | Upstream model/parser/repository chain is rejected | 2026-06-17 | task line 9; reports for Tasks 0310, 0311, 0312 under `docs/reports/review-wave-3/` |
| F2 | PERSISTENT | High | Open | Focused analyzer/test gates do not execute | 2026-06-13 | task lines 48-49; fresh commands fail on nested repository-local Pub cache workspace discovery |
| F3 | NEW | Medium | Open | ID normalization can produce double-prefixed graph targets and tests do not catch it | 2026-06-17 | `apps/observatory/lib/data/services/edge_inference_service.dart:235-260`; `apps/observatory/test/data/services/workspace_graph_builder_test.dart:265-273` |
| F4 | NEW | Low | Open | Path containment helper ignores caller-supplied skill pattern | 2026-06-17 | `apps/observatory/lib/data/services/edge_inference_service.dart:272-289` |

## Evidence Reviewed

- Full task, previous report, upstream review reports, prompt/research/EPIC-03, graph builder, edge inference service, graph result, services barrel, and graph tests.
- Runtime wiring proof: present. `workspace_providers.dart` and `workspace_snapshot_provider.dart` instantiate `WorkspaceGraphBuilder`; metrics/diagnostics and selection controllers consume `WorkspaceGraphResult` and graph edge helpers.
- Commands run from `apps/observatory`:
  - `HOME=<repo>/tmp/home PUB_CACHE=<repo>/tmp/pub-cache flutter analyze lib/data/services lib/data/repositories test/data/services` — exit 1 before analysis.
  - `HOME=<repo>/tmp/home PUB_CACHE=<repo>/tmp/pub-cache flutter test test/data/services/workspace_graph_builder_test.dart` — exit 1 before tests.
  - Content search for graph wiring — found provider and feature consumers.
  - Changelog searches — found Task 0313 changelog entry.
- Commands not run: broader suite, because focused package resolution fails first.

## Stale-Evidence Notes

The previous report accepted manual syntax review and unrelated suite counts while the actual graph-service gates were blocked. Current review confirms runtime wiring exists, but upstream rejection and unrun focused gates still block approval.

## Path To 100

1. Resolve Tasks 0310, 0311, and 0312 first; then re-run graph review against stable upstream contracts.
2. Normalize edge target IDs consistently: accept either raw names or canonical IDs without double-prefixing, and add tests that assert exact target IDs.
3. Either use `skillDirectoryPattern` in `inferPathContainment` or remove the parameter and document that it infers from path only.
4. Repair package resolution/cache discovery, then run focused analyzer and graph tests successfully.

## Dependency Effect

Task 0313 is rejected due direct upstream dependency failures. Tasks 0314/0315 and later Map/Operate/History/Governance work must not treat this graph layer as approved until the full 0310→0313 chain is repaired and re-reviewed.

## Task Ledger Patch Suggestion

Record 60/100, `REJECTED_TO_DOING`, this report, upstream dependency failures, exact edge-normalization test gaps, focused command failures, and path to 100. Set Review State to `Package Gate Failed` and route to `02-doing/`.
