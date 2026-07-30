# Review Report: Task 1117 — Graph Visualization Refactor — path-to-100 independent re-review — 2026-07-10

## Review Lineage

- **Current task**: Task 1117 (`1117-warp-prism-graph-visualization-refactor`); live path: `docs/tasks/03-review/1117-warp-prism-graph-visualization-refactor.md`
- **Previous reports read**:
  - `docs/reports/review-wave-2026-07-09/task-1117-graph-visualization-refactor-independent-rereview.md` — **88/100** `REJECTED_TO_DOING` (layoutEngine dead wiring + nodeSpacing inert)
  - `docs/reports/review-wave-2026-07-10/epic11-path-to-100-rereview.md` — builder/orchestrator **100** promote (cheap suite only) — **suspect until re-proved**
  - `docs/reports/build-gate-review/1117-review-2026-06-18-independent.md` — 66/100
  - `docs/reports/review-wave-2026-06-19/1117-graph-visualization-refactor-rereview-2026-06-19.md` — 66/100
  - `docs/reports/build-gate-review/1117-review.md` — historical false-100
- **Related reports considered**: Task 0512 map graph modes (consumer of canvas API)
- **Review mode**: `path-to-100` independent re-review
- **Reviewer profile**: `reviewers` (gt-flutter-code-reviewer + gt-code-quality-reviewer)
- **Policy**: never `04-completed/`; S≥90 stay `03-review`; S&lt;90 → `02-doing`; no git / no tasklist rebuild

## Score And Verdict

- **Score**: `97/100`
- **Verdict**: `HELD_IN_REVIEW_PATH_TO_100`
- **Lane recommendation**: `hold-in-review` (remains `docs/tasks/03-review/`)
- **Builder/epic11 claim of 100**: **not rubber-stamped** — prior top blockers are **closed** with live proof, but residual ledger/test debt and deferred node a11y keep perfect-100 open.

## Delta Summary

### Resolved Since Previous Independent Review (2026-07-09 @ 88)

- `RESOLVED` / High: **F1** `GraphCanvas.layoutEngine` is live — `_resolveLayoutEngine()` → `widget.layoutEngine ?? const ForceDirectedLayout()`; one-shot `layout()` on init; continuous physics only when engine is `ForceDirectedLayout`; engine/model change reseeds in `didUpdateWidget` (`graph_canvas.dart:141–229`).
- `RESOLVED` / Moderate: **F2** `DSGraphCanvas.nodeSpacing` forwarded into `ForceDirectedLayout(config: ForceDirectedConfig(nodeSpacing: …))` (`ds_graph_canvas.dart:180–183`).
- `RESOLVED` / Proof: injection suite group `layoutEngine + nodeSpacing wiring` in `backward_compat_test.dart` — spy engine positions + ForceDirected config + default 150.
- `RESOLVED` / Analyzer (prod): scoped **lib** analyze on graph sources → **0** issues.

### Persistent Findings

- `PERSISTENT` / Low (deferred 1117d): **F3** zero `Semantics` / keyboard node selection in `graph/` sources — accepted residual for refactor-only scope; still blocks axiom-perfect 100 if counted in-task.
- `PERSISTENT` / Low (governance): historical **Details → What** subtasks remain unchecked `[ ]` while Exit Conditions are `[x]` — DoD hygiene debt; not a product regression.

### Regressions

- None vs 2026-07-09 green suite; count improved **45 → 51**.

### New Findings

- `NEW` / Low: scoped **test** analyze still emits **INFO** (dangling library docs, prefer_const) — non-blocking, prevents analyzer-axiom perfect score if tests are in gate.

### Evidence Gaps / External Blockers

- `EXTERNAL_BLOCKER`: package-wide `melos run analyze/test` residual not re-run (scoped gate only; consistent with wave policy).

## Six Axiom Compliance

| # | Axiom | Status | Evidence |
| --- | --- | --- | --- |
| 1 | Analyzer Integrity | **PASS** (soft) | Prod graph lib: **0** issues. Tests: INFO-only. 0 ERROR/WARNING. |
| 2 | Lifecycle Safety | **PASS** | 1 `AnimationController` create + matching `dispose()` (`graph_canvas.dart:151–154, 233–235`). |
| 3 | Dependency Direction | **PASS** | graph under organisms; model uses `dart:ui` Offset only. |
| 4 | UI Accessibility | **PARTIAL** | deferred node Semantics (1117d); not required by checked exit conditions. |
| 5 | Proof Reality | **PASS** | Live **+51** graph tests including injection spy; layout &lt;100ms test present. |
| 6 | Release Security | **PASS** | No secrets / debug leak paths in scope. |

## Findings

| ID | Class | Severity | Status | Summary | First seen | Evidence |
| --- | --- | --- | --- | --- | --- | --- |
| F1 | RESOLVED | High | Closed | layoutEngine dead wiring | 2026-06-18 | `graph_canvas.dart:141–229`; spy test live |
| F2 | RESOLVED | Moderate | Closed | nodeSpacing not forwarded | 2026-06-18 | `ds_graph_canvas.dart:180–183`; forward test |
| F3 | PERSISTENT | Low | Open (deferred) | No node Semantics/keyboard | 2026-06-18 | 0 `Semantics` under `lib/.../graph/` |
| F4 | PERSISTENT | Low | Open | Historical subtasks still `[ ]` | this re-review | task Details §What L89–100 |
| F5 | NEW | Low | Open | Test-only analyze INFO | this re-review | 22 INFO on graph tests (prefer_const / dangling docs) |

## Exit Conditions (live)

| # | Condition | Met? | Live proof |
| --- | --- | --- | --- |
| 1 | graph_model / layout / painter / canvas split | **YES** | `lib/src/organisms/graph/*` |
| 2 | Organisms export | **YES** | `organisms.dart` + `graph/graph.dart` |
| 3 | Unit tests model/layout/painter | **YES** | +51 suite |
| 4 | Composable layout injection | **YES** | F1 closed + spy |
| 5 | Backward-compat API + nodeSpacing | **YES** | F2 closed |
| 6 | Gallery / changelog | **YES** | gallery + `docs/changelog/2026-07-10-task-1117-layout-engine-wiring-path-to-100.md` |

## Evidence Reviewed

- Task file Review Ledger + path-to-100 builder notes
- `graph_canvas.dart`, `ds_graph_canvas.dart`, `force_directed_layout.dart`, `backward_compat_test.dart`
- Prior 88 reject + epic11 100 claim

## Commands Run (this session)

```text
cd packages/warp_prism_ui

dart analyze --format=machine lib/src/organisms/graph/ lib/src/organisms/ds_graph_canvas.dart
# → 0 lines (prod)

dart analyze --format=machine lib/src/organisms/graph/ lib/src/organisms/ds_graph_canvas.dart test/organisms/graph/
# → 22 INFO, 0 ERROR/WARNING

flutter test --concurrency=1 --no-pub test/organisms/graph/
# → +51 All tests passed!
# log: tmp/path-to-100-independent-rereview-2026-07-10/1117.txt
```

## Path To 100

1. Reconcile historical Details subtasks: mark completed work `[x]` or strike as superseded narrative — clear DoD checkbox debt.
2. Clear test-scoped INFO (dangling library docs → `library;` / prefer_const in graph tests) so scoped analyze is 0 across lib+test.
3. Either (a) land minimal node `Semantics` labels for selected/hovered nodes **or** (b) keep explicit 1117d ownership with a single residual line that axiom-4 is out of scope for 1117 closeout — then claim 100 only after (1)+(2).
4. Re-run scoped analyze + `flutter test test/organisms/graph/`.

## Task Ledger Patch Suggestion

```markdown
### Independent path-to-100 re-review — 2026-07-10 (reviewers / extreme rigor)
- Report: `docs/reports/review-wave-2026-07-10/task-1117-path-to-100-independent-rereview.md`
- Score: **97/100** — `HELD_IN_REVIEW_PATH_TO_100`
- Lane: **stay** `docs/tasks/03-review/` (S≥90; never 04-completed)
- Prior 88 blockers F1/F2: **RESOLVED** (live +51; layoutEngine + nodeSpacing)
- Open residual: F3 deferred a11y; F4 unchecked historical subtasks; F5 test INFO
- Regression guards: re-open if layoutEngine becomes hardcoded again or nodeSpacing inert
```
