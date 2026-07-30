# Review Report: Task 1117 — Graph Visualization Refactor — 2026-06-18

## Review Lineage

- **Current task**: Task 1117 (`warp-prism-graph-visualization-refactor`), reviewed from `docs/tasks/03-review/1117-warp-prism-graph-visualization-refactor.md`.
- **Previous reports read**:
  - `docs/reports/build-gate-review/1117-review.md` — prior 100/100 approval.
- **Related reports considered**:
  - `docs/reports/build-gate-review/1105-review-2026-06-17-independent.md` — Task 1105 rejected at 68/100.
  - `docs/reports/build-gate-review/1107-review-2026-06-17-independent.md` — Task 1107 rejected at 24/100.
  - `docs/reports/build-gate-review/0512-review.md` — previous graph-mode dependency report; live task still has unchecked exit conditions and stale evidence.
- **Review mode**: independent re-review / live Flutter gate.

## Score And Verdict

- **Score**: `66/100`
- **Verdict**: `REJECTED_TO_DOING`
- **Lane recommendation**: `return-to-doing`

## Axiom Compliance

| Axiom | Status | Evidence |
| --- | --- | --- |
| Analyzer Integrity | FAIL | Scoped analyze reports exactly 18 issues: 2 warnings and 16 info-level issues. |
| Lifecycle Safety | PASS | 1 `AnimationController` created at `graph_canvas.dart:139-142`, 1 listener attached, and the controller is disposed at `graph_canvas.dart:188-190`; 0 timers/subscriptions/controllers elsewhere in Task 1117 graph files. |
| Dependency Direction | PARTIAL | Graph package layering is local, but Task 1117 depends on rejected/not-approved Task 1105, Task 1107, and Task 0512. |
| UI Accessibility | FAIL | Task 1117 graph source has 2 `GestureDetector` instances (`graph_canvas.dart:203,250`) and 0 `Semantics` widgets; interactive nodes have no keyboard activation path. |
| Proof Reality | PARTIAL | 45/45 graph tests pass, but tests do not prove the `layoutEngine` parameter is honored and analyzer claims in the previous report are false today. |
| Release Security | PASS | No secrets, endpoints, logging, permissions, or release configuration changed. |

## Delta Summary

### Resolved Since Previous Review

- `RESOLVED`: Scoped graph tests are reproducible live: 45/45 pass.

### Persistent Findings

- None from the previous report; it listed no findings.

### Regressions

- `REGRESSION`: Prior 0-warning analyzer claim is false against live scoped files.
- `REGRESSION`: The task is now blocked by rejected/not-approved prerequisite chain.

### New Findings

- `NEW`: `GraphCanvas.layoutEngine` is a dead parameter and `DSGraphCanvas.nodeSpacing` is ignored.
- `NEW`: Interactive graph canvas remains non-semantic and mouse/touch-only.

### Evidence Gaps / External Blockers

- `EXTERNAL_BLOCKER`: Task 1105/1107 prerequisites are rejected; Task 0512 is not approved and has stale/unmet exit evidence.

## Findings

| ID | Class | Severity | Status | Summary | Evidence |
| --- | --- | --- | --- | --- | --- |
| F1 | EXTERNAL_BLOCKER | High | Open | Task 1117 depends on upstreams that are not approved, including Task 1105 and Task 1107 returned to `02-doing` and Task 0512 with stale/unmet graph projection evidence. | Task dependency: `docs/tasks/03-review/1117-warp-prism-graph-visualization-refactor.md:9`; Task 1105 state `docs/tasks/02-doing/1105-warp-prism-token-theme-catalog-policy.md:3-4,151`; Task 1107 state `docs/tasks/02-doing/1107-warp-prism-melos-monorepo-migration.md:3-4,176`; Task 0512 unchecked exits/stale validation at `docs/tasks/03-review/0512-warp-prism-map-graph-modes-and-adapters.md:48-57,126-127`. |
| F2 | REGRESSION | High | Open | Scoped analyzer integrity fails with exactly 18 issues: 2 warnings (`unused_local_variable`) and 16 info-level issues (`deprecated_member_use`, `prefer_const_*`, dangling library docs). | Fresh command output; representative lines include `packages/warp_prism_ui/lib/src/organisms/graph/graph_painter.dart:118-119`, `packages/warp_prism_ui/lib/src/organisms/graph/graph_canvas.dart:276-290`, `packages/warp_prism_ui/test/organisms/graph/backward_compat_test.dart:59-60`. |
| F3 | NEW | High | Open | The new layout abstraction is not actually wired: `GraphCanvas.layoutEngine` is declared but never used, and `DSGraphCanvas.nodeSpacing` is accepted but never forwarded into the actual force-directed layout. | Declared at `packages/warp_prism_ui/lib/src/organisms/graph/graph_canvas.dart:71-72`; forced implementation at `graph_canvas.dart:136`; initialization ignores `layoutEngine` at `graph_canvas.dart:149-162`; `DSGraphCanvas.nodeSpacing` declared at `packages/warp_prism_ui/lib/src/organisms/ds_graph_canvas.dart:115,125` but not used in `ds_graph_canvas.dart:177-198`. |
| F4 | NEW | Moderate | Open | Interactive graph nodes and pan/zoom controls are not exposed semantically or via keyboard. This refactor kept graph interactivity mouse/touch-only. | 0 `Semantics` widgets in `packages/warp_prism_ui/lib/src/organisms/graph/*.dart`; outer gesture at `graph_canvas.dart:203-210`; node tap/drag gesture at `graph_canvas.dart:250-269`. |

## Evidence Reviewed

- Task file: `docs/tasks/03-review/1117-warp-prism-graph-visualization-refactor.md`.
- Source/test files: graph model/layout/painter/canvas files, legacy `ds_graph_canvas.dart`, organism barrel, graph tests, gallery graph usage.
- Runtime wiring proof: `DSGraphCanvas` delegates to `graph.GraphCanvas` at `ds_graph_canvas.dart:177-198`; graph sub-barrel exported at `organisms.dart:18-24`.
- Lifecycle counts: 1 `AnimationController`; 1 attached listener; 1 controller disposal; 0 timers; 0 stream subscriptions; 2 `GestureDetector` instances; 0 `Semantics` widgets in graph source.
- Commands run:
  - `flutter analyze --no-pub lib/src/organisms/graph lib/src/organisms/ds_graph_canvas.dart test/organisms/graph` — FAIL, 18 issues (2 warnings, 16 info).
  - `flutter test --no-pub test/organisms/graph` — PASS, 45/45.
- Commands not run and why: full Melos commands are blocked by rejected Task 1107 workspace defects; this review used scoped package commands with `--no-pub`.

## Path To 100

1. Resolve and re-approve Task 1105, Task 1107, and Task 0512, then refresh dependency evidence.
2. Fix all 18 scoped analyzer issues: replace `withOpacity` in graph files with `withValues(alpha: ...)`, add missing `const`, convert or remove dangling library doc comments, and use/remove unused variables in `backward_compat_test.dart`.
3. Honor `GraphCanvas.layoutEngine` and `DSGraphCanvas.nodeSpacing`: initialize positions through the supplied engine and pass `ForceDirectedConfig(nodeSpacing: widget.nodeSpacing)` when the legacy wrapper is used.
4. Add tests proving a custom `GraphLayoutEngine` controls node positions and proving `nodeSpacing` affects force layout configuration.
5. Add Semantics/focus/keyboard wrappers for rendered graph nodes or explicitly scope that remediation into a prerequisite accessibility task before re-review.

## Task Ledger Patch Suggestion

Add a latest-review entry with score `66/100`, verdict `REJECTED_TO_DOING`, this report path, F1-F4, and the path-to-100 above. Preserve `docs/reports/build-gate-review/1117-review.md` as previous-report lineage.
