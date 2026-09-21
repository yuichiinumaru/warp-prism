# Drain Review: Task 0512 — Map Graph Modes And Adapters — 2026-07-17

## Review Lineage

- **Current task**: Task 0512; prior independent: `docs/reports/review-wave-2026-07-09/task-0512-map-graph-modes-adapters-independent-rereview.md` — **96/100**
- **Review mode**: independent drain re-review
- **No git / no tasklist**

## Score And Verdict

- **Prior score**: `96/100`
- **New score**: `91/100`
- **Verdict**: `ACCEPTED_PATH_TO_100`
- **Lane**: `docs/tasks/04-completed/` (S≥90; path-to-100 residual documented)

## Delta Summary

### Resolved / Reconfirmed

- Mode projection pure adapter: containment / operational / evidence edge-kind sets (`map_graph_mode.dart`).
- Graph panel: Wrap chips, FocusableActionDetector + Semantics, ≥48×48, empty-edge selector retained.
- Task-scoped analyze clean; full map suite **105/105**.
- Changelogs 2026-06-30 + 2026-07-09 path-to-100 present.

### Persistent Findings

- **PERSISTENT / Low**: Format dirt on `test/features/map/map_graph_panel_test.dart` (FORMAT_EXIT=1).

### New Findings

- **NEW / Moderate**: Production Map builds graph edges solely from `state.catalogAssets.expand((a) => a.edges)` (`map_workspace_page.dart:312–318`). It does **not** consume `WorkspaceGraphBuilder` / `workspaceGraphAsyncProvider` inferred edges (containment, routing, proof linkage, etc.). Modes still filter frontmatter edges correctly, but operational/evidence/containment graphs can be **under-connected** relative to the EPIC-03 graph backbone that Governance already uses. Dual-path residual vs Task 0313 inference.
- **NEW / Low**: Mode projection unit tests do not assert parity against `WorkspaceGraphBuilder.build(assets).edges` for the mock corpus.

### Regressions

- None on adapter purity or chip a11y.

## Findings

| ID | Class | Severity | Status | Summary |
| --- | --- | --- | --- | --- |
| F1 | PERSISTENT | Low | Open | Format dirt on panel test |
| F2 | NEW | Moderate | Open | Production graph skips WorkspaceGraphBuilder inferred edges |

## Exit Conditions

| # | Condition | Met? |
| --- | --- | --- |
| 1–3 | Projection adapters + mode switch + pure canvas consumer | YES |
| 4 | Unit/widget mode + zero-edge | YES |
| 5–7 | analyze / map tests / changelog | YES (105 live) |

## Axiom Compliance

| Axiom | Status | Notes |
| --- | --- | --- |
| Analyzer Integrity | PASS | map scope 0 |
| Lifecycle Safety | PASS | 0 panel controllers |
| Dependency Direction | PASS | projection over models → Prism canvas |
| UI Accessibility | PASS | mode chips Semantics + 48×48 |
| Proof Reality | PASS | suite green; production edge-source gap residual |
| Release Security | PASS | |

## Commands Run

```text
flutter test --concurrency=1 --no-pub test/features/map/  → +105
flutter analyze --no-pub lib/features/map/ test/features/map/ → No issues found
dart format --output=none --set-exit-if-changed test/features/map/map_graph_panel_test.dart → FORMAT_EXIT=1
```

## Path To 100

1. Wire Map graph edges from `workspaceGraphAsyncProvider` (or run `WorkspaceGraphBuilder` once at shell) so modes see inferred + frontmatter edges.
2. Regression test: mock corpus graph edge count in Map projection ≥ builder edge count for at least one mode, or explicit documented subset contract.
3. `dart format` `map_graph_panel_test.dart`.

## Lane Action

- Move → `docs/tasks/04-completed/`.
