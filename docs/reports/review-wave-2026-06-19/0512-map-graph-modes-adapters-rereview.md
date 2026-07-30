# Review Report: Task 0512 — Map graph modes and projection adapters — 2026-06-19

## Review Lineage

- **Current task**: Task 0512 (`0512-warp-prism-map-graph-modes-and-adapters`); live path resolved by filesystem search at `docs/tasks/03-review/0512-warp-prism-map-graph-modes-and-adapters.md` before routing.
- **Previous reports read**:
  - `docs/reports/build-gate-review/0512-review.md` — claimed `100/100`, now invalidated by analyzer output, failing Map tests, and missing widget test evidence.
- **Related reports considered**:
  - `docs/reports/build-gate-review/0510-review.md` — Graph subview route host.
  - `docs/reports/build-gate-review/0511-review.md`, `0513-review.md`, `0514-review.md` — graph selection/state interactions.
- **Review mode**: re-review / independent parent-reviewer gate.

## Score And Verdict

- **Score**: `78/100`
- **Verdict**: `REJECTED_TO_DOING`
- **Lane recommendation**: `return-to-doing`

## Axiom Compliance

| # | Axiom | Status | Evidence |
| --- | --- | --- | --- |
| 1 | Analyzer Integrity | **FAIL** | `flutter analyze lib/features/map test/features/map` reports **45 issues**. Graph files have unused imports and deprecated `withOpacity` infos at `map_graph_projection.dart:11`, `map_graph_panel.dart:9,164,169`. |
| 2 | Lifecycle Safety | **PASS** | Graph projection and `MapGraphPanel` create **0** controllers/subscriptions/timers/listeners; **0** disposals required. |
| 3 | Dependency Direction | **PASS** | Projection is a pure adapter over `WorkspaceAsset`/`WorkspaceEdge`; no parser or presentation-to-data inversion found in `map_graph_projection.dart:57-97`. |
| 4 | UI Accessibility | **PARTIAL** | Graph mode selector has **5 runtime Semantics nodes**: selector, count, and 3 mode chips (`map_graph_panel.dart:88-90,120-123,151-155`). Mode chips are still `GestureDetector`-based and no keyboard action/focus handler is visible. |
| 5 | Proof Reality | **FAIL** | `flutter test test/features/map` is **95 total / 4 failed**. Three failures are graph toolbar overflow at `map_graph_panel.dart:101`. Task asked for `map_graph_panel_test.dart`, but no such test file exists. |
| 6 | Release Security | **PASS** | No secrets, endpoints, signing changes, release logging, or write behavior in reviewed graph files. |

## Delta Summary

### Resolved Since Previous Review

- `RESOLVED`: Graph mode enum and edge rules exist at `apps/observatory/lib/features/map/graph/map_graph_mode.dart:11-39`.
- `RESOLVED`: Projection derives edges from provided normalized edges rather than local widget arrays at `apps/observatory/lib/features/map/graph/map_graph_projection.dart:57-97`.

### Persistent Findings

- `PERSISTENT`: Task 0512 changelog evidence remains pending at `docs/tasks/03-review/0512-warp-prism-map-graph-modes-and-adapters.md:126-127`; no Task 0512 changelog was found among `docs/changelog/*051*.md`.

### Regressions

- `REGRESSION`: Prior 100/100 score is not reproducible under live SDK gates.

### New Findings

- `NEW`: Graph toolbar overflows in widget tests at 800px, making the Graph subview non-responsive at the tested desktop width.
- `NEW`: Completion evidence claims graph panel work, but the task's required `map_graph_panel_test.dart` does not exist; only `map_graph_projection_test.dart` exists.
- `NEW`: Production graph projection is fed by empty route-local state unless tests inject assets.

### Evidence Gaps / External Blockers

- `EVIDENCE_GAP`: No passing Graph panel widget test exists.
- `EXTERNAL_BLOCKER`: None. Flutter and Dart are installed.

## Findings

| ID | Class | Severity | Status | Summary | First seen | Evidence |
| --- | --- | --- | --- | --- | --- | --- |
| F1 | NEW | High | Open | Graph mode selector overflows by 12 pixels and fails tests. | 2026-06-19 | `flutter test test/features/map` failures: `RenderFlex overflowed by 12 pixels`; source `apps/observatory/lib/features/map/widgets/map_graph_panel.dart:101`. |
| F2 | REGRESSION | High | Open | Analyzer gate fails for graph/Map scope. | 2026-06-19 | `flutter analyze lib/features/map test/features/map` → `45 issues found`; graph examples at `map_graph_projection.dart:11`, `map_graph_panel.dart:9,164,169`. |
| F3 | EVIDENCE_GAP | Moderate | Open | Required graph panel widget test is absent. | Task contract / 2026-06-19 | Task Where requires `test/features/map/map_graph_panel_test.dart` at `docs/tasks/03-review/0512-warp-prism-map-graph-modes-and-adapters.md:86-88`; live glob found only `map_graph_projection_test.dart` for graph. |
| F4 | NEW | Moderate | Open | Mode chips are not proven keyboard-focusable despite semantic labels. | 2026-06-19 | Runtime chips generated from `MapGraphMode.values` at `map_graph_panel.dart:107-115`; each is a `GestureDetector` at `:151-177` with no `FocusableActionDetector`/keyboard action. |
| F5 | PERSISTENT | Moderate | Open | Changelog evidence is missing. | 2026-06-13 / 2026-06-19 | `docs/tasks/03-review/0512-warp-prism-map-graph-modes-and-adapters.md:126-127`. |

## Exact Evidence

- Edge mode rules: containment = `{contains, routesTo}`, operational = `{uses, dependsOn, routesTo}`, evidence = `{proves, changedBy, references}` at `map_graph_mode.dart:30-39`.
- Projection uses filtered normalized edges: `map_graph_projection.dart:62-89`.
- Graph panel toolbar row: `map_graph_panel.dart:101-129`; this is the overflowing `Row` named in the failing test output.
- Lifecycle exact count for Task 0512-owned graph files: **0** controllers/subscriptions/timers/listeners created; **0** disposals required.
- Runtime graph mode controls: **3** mode chips, **3** chip `GestureDetector`s, **5** Semantics widgets at runtime.

## Runtime Wiring Proof

1. `apps/observatory/lib/app/router.dart:52-59` registers `/map`.
2. `apps/observatory/lib/app/pages/map_page.dart:14-16` builds `MapWorkspacePage`.
3. `apps/observatory/lib/features/map/map_workspace_page.dart:157` routes the Graph tab to `_buildGraphTab`.
4. `_buildGraphTab` collects `state.catalogAssets.expand((a) => a.edges)` at `map_workspace_page.dart:300`, calls `projectGraph` at `:303-307`, then builds `MapGraphPanel` at `:309-316`.
5. In production, `MapWorkspacePage` receives no repository-loaded assets and initializes `MapWorkspaceProvider` from null `initialState` at `map_workspace_page.dart:72`; therefore runtime graph wiring exists but defaults to empty data.

## Commands

- `flutter --version` — Flutter `3.44.1`, Dart `3.12.1` installed.
- `HOME="$PWD/../../tmp/home" PUB_CACHE="$PWD/../../tmp/pub-cache" flutter analyze` — failed, `378 issues found`.
- `HOME="$PWD/../../tmp/home" PUB_CACHE="$PWD/../../tmp/pub-cache" flutter analyze lib/features/map test/features/map` — failed, `45 issues found`.
- `HOME="$PWD/../../tmp/home" PUB_CACHE="$PWD/../../tmp/pub-cache" flutter test test/features/map` — failed, `95 total / 4 failed`.

## Stale-Evidence Notes

- Previous report's Flutter SDK blocker is stale.
- Previous report says test suite covers graph mode switching, but there is no live `map_graph_panel_test.dart` file.
- The projection unit tests exist, but the widget behavior fails under live layout.

## Path To 100

1. Fix `MapGraphPanel._ModeSelector` so the toolbar cannot overflow at 800px: wrap mode chips/counts, use a horizontal scroll area, or collapse counts on narrower widths.
2. Add `test/features/map/map_graph_panel_test.dart` covering mode switching, active mode semantics, responsive/no-overflow layout, and no-eligible-edges UI.
3. Wire Graph tab data to repository-backed normalized graph assets via the production Map state path.
4. Replace `GestureDetector` mode chips with keyboard-focusable semantic controls or add `FocusableActionDetector`/shortcuts/actions.
5. Clear graph/Map analyzer issues and add Task 0512 changelog proof.

## Task Ledger Patch Suggestion

```markdown
### 2026-06-19 — reviewers independent re-review
**Score**: 78/100 — REJECTED_TO_DOING
**Verdict**: Return to `02-doing` for graph toolbar overflow, missing graph panel widget proof, analyzer cleanup, production data wiring, and changelog evidence.
**Report**: `docs/reports/review-wave-2026-06-19/0512-map-graph-modes-adapters-rereview.md`
**Commands**: `flutter analyze` → 378 issues; `flutter analyze lib/features/map test/features/map` → 45 issues; `flutter test test/features/map` → 95 total / 4 failed.
**Open blockers**: graph `RenderFlex` overflow at `map_graph_panel.dart:101`, absent `map_graph_panel_test.dart`, empty production data path, missing Task 0512 changelog.
**Path to 100**: responsive graph toolbar, widget tests for graph panel/mode switching, repository-fed graph state, keyboard-focusable mode controls, analyzer clean, changelog proof.
```
