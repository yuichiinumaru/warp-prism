# Review Report: Task 1117 — Graph Visualization Refactor — 2026-06-19

## Review Lineage

- **Current task**: Task 1117 (`warp-prism-graph-visualization-refactor`); live path before routing was `docs/tasks/03-review/1117-warp-prism-graph-visualization-refactor.md`.
- **Previous reports read**:
  - `docs/reports/build-gate-review/1117-review.md` — 2026-06-13 prior 100/100 approval.
  - `docs/reports/build-gate-review/1117-review-2026-06-18-independent.md` — 2026-06-18 independent rejection, 66/100.
- **Related reports/tasks considered**:
  - Task 1105 live path `docs/tasks/02-doing/1105-warp-prism-token-theme-catalog-policy.md` — still `Status: Doing`, `Review State: Doing`.
  - Task 1107 live path `docs/tasks/02-doing/1107-warp-prism-melos-monorepo-migration.md` — still `Status: Doing`, `Review State: Doing`.
  - Task 0512 live path `docs/tasks/03-review/0512-warp-prism-map-graph-modes-and-adapters.md` — still has unchecked exit conditions and stale validation at lines `48-57` and `126-127`.
- **Review mode**: re-review / lineage verification / lane-state reconciliation.

## Score And Verdict

- **Score**: `66/100`
- **Verdict**: `REJECTED_TO_DOING`
- **Lane recommendation**: `return-to-doing`
- **Remediation applied after 2026-06-18?** No. The same analyzer, architecture, accessibility, and dependency blockers remain live.

## Axiom Compliance

| Axiom | Status | Evidence |
| --- | --- | --- |
| Analyzer Integrity | FAIL | `flutter analyze --no-pub lib/src/organisms/graph lib/src/organisms/ds_graph_canvas.dart test/organisms/graph` reported exactly 18 issues: 2 warnings and 16 info-level issues. |
| Lifecycle Safety | PASS | Exact count: 1 `AnimationController` allocation at `packages/warp_prism_ui/lib/src/organisms/graph/graph_canvas.dart:139-142`; 1 listener attached via `addListener(_updatePhysics)` at line `142`; 1 disposal at lines `188-190`; 0 timers; 0 stream subscriptions. |
| Dependency Direction | PARTIAL | Task depends on Task 1105, Task 1107, and Task 0512 at `docs/tasks/03-review/1117-warp-prism-graph-visualization-refactor.md:9`; none is promoted/approved as a clean prerequisite. |
| UI Accessibility | FAIL | Exact count in Task 1117 graph source: 2 `GestureDetector` instances (`graph_canvas.dart:203`, `graph_canvas.dart:250`) and 0 `Semantics` widgets in `packages/warp_prism_ui/lib/src/organisms/graph/*.dart`; there is no Focus/Shortcuts/Actions keyboard activation path for nodes. |
| Proof Reality | PARTIAL | Tests exist, but current live `flutter test --no-pub test/organisms/graph` did not produce a passing test count in this environment; it timed out after Flutter tester subprocesses SIGTERM'd during finalization. Prior 2026-06-18 scoped test proof was 45/45, but analyzer and wiring defects remain. |
| Release Security | PASS | No secrets, endpoints, logging, permissions, or release build configuration changed in Task 1117 files. |

## Delta Summary

### Resolved Since Previous Review

- `RESOLVED`: No 2026-06-18 code findings were resolved.

### Persistent Findings

- `PERSISTENT`: Upstream prerequisites Task 1105, Task 1107, and Task 0512 are still not cleanly approved.
- `PERSISTENT`: Scoped analyzer still reports exactly 18 issues.
- `PERSISTENT`: `GraphCanvas.layoutEngine` is still declared but not used; `DSGraphCanvas.nodeSpacing` is still accepted but not forwarded.
- `PERSISTENT`: Interactive graph nodes remain non-semantic and mouse/touch-only.

### Regressions

- None beyond the 2026-06-18 regression already recorded from prior false analyzer proof.

### New Findings

- `NEW`: Lane-state defect verified. The task file was physically in `03-review` while its header said `Status: Doing` and `Review State: Doing` at `docs/tasks/03-review/1117-warp-prism-graph-visualization-refactor.md:3-4`. This is resolved by this review's routing move back to `02-doing`.

### Evidence Gaps / External Blockers

- `EVIDENCE_GAP`: Live graph test command did not complete in this environment; it produced Flutter tester SIGTERM/finalization errors and no test count. This does not erase the analyzer and implementation blockers.

## Findings

| ID | Class | Severity | Status | Summary | First seen | Evidence |
| --- | --- | --- | --- | --- | --- | --- |
| F1 | PERSISTENT | High | Open | Task 1117 depends on upstreams that are not approved or not clean: Task 1105, Task 1107, and Task 0512. | 2026-06-18 report | Dependency at `docs/tasks/03-review/1117-warp-prism-graph-visualization-refactor.md:9`; Task 1105 state `docs/tasks/02-doing/1105...md:3-4`; Task 1107 state `docs/tasks/02-doing/1107...md:3-4`; Task 0512 unchecked exits at `docs/tasks/03-review/0512...md:48-57`. |
| F2 | PERSISTENT | High | Open | Scoped analyzer integrity still fails with exactly 18 issues: 2 warnings and 16 info-level issues. | 2026-06-18 report | Current command output; representative live lines: `graph_canvas.dart:136`, `graph_canvas.dart:276-290`, `graph_painter.dart:118-119`, `backward_compat_test.dart:59-60`. |
| F3 | PERSISTENT | High | Open | The layout abstraction is still dead wiring: `GraphCanvas.layoutEngine` is never used and `DSGraphCanvas.nodeSpacing` is never forwarded. | 2026-06-18 report | `layoutEngine` declared at `packages/warp_prism_ui/lib/src/organisms/graph/graph_canvas.dart:71-72`; `_forceLayout = ForceDirectedLayout()` hardcoded at `graph_canvas.dart:136`; `_initializePositions()` ignores `layoutEngine` at `graph_canvas.dart:149-162`; `nodeSpacing` declared at `packages/warp_prism_ui/lib/src/organisms/ds_graph_canvas.dart:115,125` and omitted from delegate call at `ds_graph_canvas.dart:177-198`. |
| F4 | PERSISTENT | Moderate | Open | Graph interactivity remains inaccessible: nodes and pan/zoom are exposed only through mouse/touch gestures. | 2026-06-18 report | 2 `GestureDetector` instances at `graph_canvas.dart:203` and `graph_canvas.dart:250`; 0 `Semantics` widgets in `packages/warp_prism_ui/lib/src/organisms/graph/*.dart`; no `Focus`, `Shortcuts`, or `Actions` in `graph_canvas.dart:203-317`. |
| F5 | NEW | Moderate | Resolved by routing | Task was in the review lane while explicitly marked `Doing`, violating lane-state rules for `03-review`. | 2026-06-19 re-review | Header at `docs/tasks/03-review/1117-warp-prism-graph-visualization-refactor.md:3-4`; lane rules at `docs/governance/promotion-state-model.md:182-188`. |
| F6 | EVIDENCE_GAP | Moderate | Open | Live graph test command did not complete; current review cannot claim a live 45/45 pass. | 2026-06-19 re-review | `flutter test --no-pub test/organisms/graph` timed out after Flutter tester SIGTERM/finalization errors; retry with `TMPDIR=/home/sephiroth/working/ganthritor/warp-prism/tmp` had the same class of error. |

## Evidence Reviewed

- Task file: `docs/tasks/03-review/1117-warp-prism-graph-visualization-refactor.md`.
- Previous reports: `docs/reports/build-gate-review/1117-review.md`, `docs/reports/build-gate-review/1117-review-2026-06-18-independent.md`.
- Source/test files: `packages/warp_prism_ui/lib/src/organisms/graph/graph_canvas.dart`, `force_directed_layout.dart`, `graph_painter.dart`, `graph_model.dart`, `graph_layout_engine.dart`, `packages/warp_prism_ui/lib/src/organisms/ds_graph_canvas.dart`, `packages/warp_prism_ui/test/organisms/graph/backward_compat_test.dart`.
- Runtime wiring proof: `DSGraphCanvas` delegates to `graph.GraphCanvas` at `ds_graph_canvas.dart:177-198`, but does not pass a layout engine or `nodeSpacing`.
- Counts: 1 controller; 1 controller listener; 1 controller disposal; 0 timers; 0 stream subscriptions; 2 GestureDetectors; 0 Semantics widgets in graph source.
- Commands run:
  - `flutter analyze --no-pub lib/src/organisms/graph lib/src/organisms/ds_graph_canvas.dart test/organisms/graph` — FAIL, 18 issues.
  - `flutter test --no-pub test/organisms/graph` — BLOCKED/TIMEOUT, no tests ran, Flutter tester SIGTERM/finalization errors.
  - `TMPDIR=/home/sephiroth/working/ganthritor/warp-prism/tmp flutter test --no-pub test/organisms/graph` — BLOCKED/TIMEOUT, same class of Flutter tester finalization error using in-repo temp.
- Commands not run and why: full Melos gates not run because scoped analyzer already fails and Task 1107 remains a rejected workspace prerequisite.

## Path To 100

1. Resolve and re-approve Task 1105, Task 1107, and Task 0512, then update Task 1117 dependency evidence.
2. Fix all 18 scoped analyzer issues; analyzer must return 0 errors, 0 warnings, and 0 info-level issues.
3. Wire `GraphCanvas.layoutEngine`: initialize `_positions` from `widget.layoutEngine?.layout(...)` when supplied, and add a widget test proving a custom engine controls node positions.
4. Forward `DSGraphCanvas.nodeSpacing` by constructing `ForceDirectedLayout(config: ForceDirectedConfig(nodeSpacing: widget.nodeSpacing))` or equivalent, and add a regression test proving the parameter changes layout behavior.
5. Add Semantics, Focus, Shortcuts, and Actions around graph nodes so keyboard users can select/activate nodes; add tests for semantic labels and Enter/Space activation.
6. Re-run scoped analyzer/tests and capture a clean test count after the Flutter tester finalization issue is resolved.

## Task Ledger Patch Suggestion

- Latest review entry should record 2026-06-19 score `66/100`, verdict `REJECTED_TO_DOING`, this report path, persistent F1-F4, evidence gap F6, lane-state F5 resolved by routing, and lane outcome `returned to doing`.
