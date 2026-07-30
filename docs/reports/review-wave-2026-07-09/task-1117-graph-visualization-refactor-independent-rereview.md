# Review Report: Task 1117 — Graph Visualization Refactor — 2026-07-09

## Review Lineage

- **Current task**: Task 1117 (`1117-warp-prism-graph-visualization-refactor`); live path at review start: `docs/tasks/03-review/1117-warp-prism-graph-visualization-refactor.md`
- **Previous reports read**:
  - `docs/reports/build-gate-review/1117-review.md` — historical 100
  - `docs/reports/build-gate-review/1117-review-2026-06-18-independent.md` — 66/100
  - `docs/reports/review-wave-2026-06-19/1117-graph-visualization-refactor-rereview-2026-06-19.md` — 66/100
  - Promote ledger `review-260709230500-wave-1106-1123-promote.md` — 100 (scoped tests only)
- **Related reports considered**: Task 0512 (map graph modes) as consumer of canvas API
- **Review mode**: `re-review` independent
- **Reviewer profile**: `reviewers` (gt-flutter-code-reviewer + gt-code-quality-reviewer)

## Score And Verdict

- **Score**: `88/100`
- **Verdict**: `REJECTED_TO_DOING`
- **Lane recommendation**: `return-to-doing`

Model/layout/painter split is real and **45/45** graph tests pass live. Analyzer is **INFO-only** (16 infos; 0 ERROR/WARNING). Promote-100 ignored **dead wiring**: `GraphCanvas.layoutEngine` is never used (`ForceDirectedLayout()` hardcoded); `DSGraphCanvas.nodeSpacing` accepted but not forwarded. That violates the composable-layer contract that is this task’s entire objective.

## Delta Summary

### Resolved Since Previous Review (2026-06-19 @ 66)

- `RESOLVED`: Live graph suite **45/45** (prior SIGTERM evidence gap closed).
- `RESOLVED`: Analyzer warnings cleared — only INFO remain (deprecated withOpacity, prefer_const, dangling library docs).
- `SUPERSEDED`: Upstream 1105/1107 “still doing” dependency hard-block from June.

### Persistent Findings

- `PERSISTENT`: `layoutEngine` parameter is dead; physics always uses private `_forceLayout = ForceDirectedLayout()`.
- `PERSISTENT`: `nodeSpacing` on thin `DSGraphCanvas` wrapper not passed into `graph.GraphCanvas`.
- `PERSISTENT` / deferred: Node a11y (0 Semantics in graph/) — acceptable residual for refactor-only; owned by 1117d, still noted.

### Regressions

- None in test greenness.

### New Findings

- None High beyond persistent dead wiring.

## Six Axiom Compliance

| # | Axiom | Status | Evidence |
| --- | --- | --- | --- |
| 1 | Analyzer Integrity | **PASS** (scoped, soft) | 0 ERROR/WARNING; 16 INFO |
| 2 | Lifecycle Safety | **PASS** | 1 `AnimationController` create/dispose; listener tied to controller |
| 3 | Dependency Direction | **PASS** | graph/ under organisms; pure model uses dart:ui Offset only |
| 4 | UI Accessibility | **PARTIAL** | deferred to 1117d; 0 Semantics in graph sources |
| 5 | Proof Reality | **PASS** | +45 graph tests; layout <100ms test present |
| 6 | Release Security | **PASS** | No secrets |

## Findings

| ID | Class | Severity | Status | Summary | First seen | Evidence |
| --- | --- | --- | --- | --- | --- | --- |
| F1 | PERSISTENT | High | Open | `layoutEngine` never applied — always `ForceDirectedLayout()` | 2026-06-18 | `graph_canvas.dart:72,95,111,136` |
| F2 | PERSISTENT | Moderate | Open | `DSGraphCanvas.nodeSpacing` not forwarded | 2026-06-18 | `ds_graph_canvas.dart:115,125` vs delegate `177+` |
| F3 | PERSISTENT | Low | Open (deferred 1117d) | No Semantics/keyboard on nodes | 2026-06-18 | graph/ sources |
| F4 | RESOLVED | — | Closed | Graph tests not runnable | 2026-06-19 | live +45 |

## Exit Conditions (live)

| # | Condition | Met? | Live proof |
| --- | --- | --- | --- |
| 1 | graph_model / layout / painter / canvas split | **YES** | `lib/src/organisms/graph/*` |
| 2 | Organisms export | **YES** | barrel |
| 3 | Unit tests model/layout/painter | **YES** | +45 |
| 4 | Composable layout injection | **NO** | F1 dead wiring |
| 5 | Backward-compat API surface | **PARTIAL** | wrapper exists; nodeSpacing inert |
| 6 | Changelog | **YES** | present |

## Evidence Reviewed

- Graph package sources + `ds_graph_canvas.dart` + `test/organisms/graph/`
- Prior independent rejections + promote ledger

## Commands Run

```text
dart analyze --format=machine lib/src/organisms/graph/ \
  lib/src/organisms/ds_graph_canvas.dart test/organisms/graph/
# → 16 INFO, 0 ERROR/WARNING

flutter test --concurrency=1 --no-pub test/organisms/graph/
# → +45 All tests passed (in combined wave +253)
```

## Path To 100

1. Wire `widget.layoutEngine ?? ForceDirectedLayout()` for one-shot layout and continuous simulation (or document and type-narrow if only ForceDirected supports `simulateStep`).
2. Forward `nodeSpacing` into layout parameters / force layout constructor.
3. Clear scoped INFO (withOpacity → withValues; const; library directives).
4. Re-run analyze + graph tests.

## Task Ledger Patch Suggestion

```markdown
### 2026-07-09 independent re-review (reviewers)
- Report: `docs/reports/review-wave-2026-07-09/task-1117-graph-visualization-refactor-independent-rereview.md`
- Score: **88/100** — `REJECTED_TO_DOING`
- Lane: return `02-doing/`
- Top blocker: F1 layoutEngine dead wiring
```
