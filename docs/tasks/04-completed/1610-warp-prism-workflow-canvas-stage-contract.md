# Task 1610: PrismWorkflowCanvasStage Contract

> **Review State**: `Review`
> **Priority**: 🟡 P1
> **Type**: `feature`
> **Origin**: EPIC-16 (`docs/tasks/00-planning/EPIC-16-warp-prism-ads-cybercore-ops-and-agent-transcript-organisms.md`) + harvest reports `docs/reports/ads-harvest-session-synthesis-2026-07-10.md`, `docs/reports/ads-harvest-omniroute-visual-reference-2026-07-10.md`, `docs/reports/ads-harvest-references-catalog-triage-2026-07-10.md`, `docs/reports/ads-harvest-atomic-ds-references-2026-07-10.md`
> **Blocks**: Task 1613 (soft — contract may register as stage stub)
> **Depends on**: Task 1600
>
> **Hard distinction**: This is a **workflow DAG stage contract**, **not** EPIC-15
> Map canvas stage (O-17 / Task 1512). No MapLibre. No geo layers.

> [!IMPORTANT]
> Task identity is lane-neutral. Use `Task 1610` plus optional slug for
> dependencies, blockers, review ledgers, reports, and architecture references.
> Lanes such as `02-doing` and `03-review` are mutable status, not identity.

---

## Objective

Define and implement **`PrismWorkflowCanvasStage`** as a **stage contract** (host widget + node/edge models + selection bus callbacks + placeholder canvas) for workflow DAGs. MVP may use existing graph primitives (`DSGraphCanvas` / graph module) adapted to workflow semantics — **not** a full Sim Studio editor, **not** MapLibre. Public `Prism*` + `DS*` + alias; minimal gallery fixture graph.

## Background Context

### Source origin (EPIC-16)

| Field | Value |
| --- | --- |
| **Proposed public name** | `PrismWorkflowCanvasStage` |
| **Internal** | `DSWorkflowCanvasStage` + typedef |
| **Harvest ID** | **C-11** |
| **Origin** | Sim Studio workflow canvas patterns |
| **Wave** | **M** (Workflow/execution contracts) |
| **Action type** | `NEW` (contract-first) |

### What already exists

- Graph organisms: `ds_graph_canvas.dart`, `organisms/graph/` layout + painter.
- EPIC-15 Map canvas stage contract (geo/map) — separate product class.

### What is missing or broken

- No workflow-specific stage contract (node kinds, edge kinds, selection bus for DAG editing later).
- Risk of builders wiring maps into workflow surfaces without a named stage type.

### False-gap notes

- Do **not** port MapLibre, React Flow, or full collab cursors.
- Do **not** implement connector marketplace, billing, or realtime multiplayer.
- Do **not** rename Map stage to “workflow” — keep APIs distinct.

### Composition notes

- Prefer composing `DSGraphCanvas` with workflow node view models.
- Stage provides: viewport host, node/edge lists, onSelectNode/Edge, empty/loading states.

---

## Test Requirements

- MUST define public stage widget accepting fixture nodes/edges.
- MUST fire selection callbacks for node (and edge if modeled).
- MUST document contract fields in code dartdoc (node id/label/kind; edge from/to/kind).
- Widget tests: render fixture DAG, select node, empty graph.
- Gallery: small fixture workflow (e.g. ingest → route → respond).
- MUST NOT add MapLibre dependency.

---

## Exit Conditions

- [x] `PrismWorkflowCanvasStage` exported with documented contract.
- [x] Tests + minimal gallery PASS.
- [x] Explicitly distinct from map stage (Completion Evidence notes paths).
- [x] Analyze + scoped tests PASS; boundaries **6/6** after barrel/alias.
- [x] Local changelog under `docs/changelog/`.
- [x] Completion Evidence filled.

---

## Details

### What

Subtasks:

- [x] **Read existing code before modifying**: read EPIC-16, harvest session synthesis + references triage (Sim Studio), Task 1600 brief if present, `packages/warp_prism_ui/lib/src/organisms/ds_graph_canvas.dart`, `packages/warp_prism_ui/lib/src/organisms/graph/` (model, painter, layout), any EPIC-15 map canvas stage module if present under `organisms/`, `packages/warp_prism_ui/lib/src/organisms/organisms.dart`, `packages/warp_prism_ui/lib/src/prism_aliases.dart`, `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart`, `packages/warp_prism_ui/pubspec.yaml`.
- [x] Write workflow node/edge models + stage API dartdoc contract.
- [x] Implement stage host composing graph canvas or minimal custom layout.
- [x] Export alias; tests; gallery fixture DAG.
- [x] **Simplicity pass**: contract + read-only interact selection; no full editor chrome.
- [x] **Regression verification**: validation commands; confirm no MapLibre.

### Where

| File | Purpose |
| --- | --- |
| `packages/warp_prism_ui/lib/src/organisms/workflow_canvas_stage/` | Create — module |
| `packages/warp_prism_ui/lib/src/organisms/workflow_canvas_stage/ds_workflow_canvas_stage.dart` | Create — stage + models |
| `packages/warp_prism_ui/lib/src/organisms/ds_graph_canvas.dart` | Read — compose |
| `packages/warp_prism_ui/lib/src/organisms/graph/` | Read — reuse layout if fit |
| `packages/warp_prism_ui/lib/src/organisms/organisms.dart` | Modify — export |
| `packages/warp_prism_ui/lib/src/prism_aliases.dart` | Modify — alias |
| `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart` | Modify — gallery |
| `packages/warp_prism_ui/test/organisms/workflow_canvas_stage/` | Create — tests |
| `docs/changelog/` | Create — changelog |

### How

1. Define models independent of geo coordinates (graph x/y layout OK).
2. Stage wraps canvas; selection callbacks only for MVP.
3. Gallery fixture; export; boundaries.

### Why

CyberCore route/workflow visualization needs a named stage contract separate from Map HUD; Sim Studio harvest rates this GOLD if kept contract-first.

---

## Anti-Hallucination Guardrails

> [!CAUTION]
> Not a MapLibre port. Not EPIC-15 map stage rename. Not full Sim Studio.

> [!IMPORTANT]
> Fixture DAG only. Package purity preserved.

> [!WARNING]
> ADS-first. Product workflow editor app route out of scope for exit.

---

## Validation Commands

```bash
cd packages/warp_prism_ui
dart analyze lib test
flutter test test/organisms/workflow_canvas_stage/
grep -i maplibre pubspec.yaml || true

cd ../..
melos run test-boundaries
```

If Flutter tooling is unavailable, record the exact tooling failure and do not
claim those checks passed.

---

## Completion Evidence

- **Files created/modified**:
  - `packages/warp_prism_ui/lib/src/organisms/workflow_canvas_stage/ds_workflow_canvas_stage.dart` — stage + models (1176 lines)
  - `packages/warp_prism_ui/lib/src/organisms/workflow_canvas_stage/workflow_canvas_stage.dart` — barrel export (9 lines)
  - `packages/warp_prism_ui/lib/src/organisms/organisms.dart` — added barrel export (line 59)
  - `packages/warp_prism_ui/lib/src/prism_aliases.dart` — added 11 `Prism*` typedefs + 4 public fixture functions (lines 102, 675–714)
  - `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart` — added fixture DAG gallery entry (lines 4970–4971)
  - `packages/warp_prism_ui/test/organisms/workflow_canvas_stage/ds_workflow_canvas_stage_test.dart` — 13 widget tests (272 lines)
  - `docs/changelog/20260715-000000-1610-2026-07-15-task-1610-workflow-canvas-stage-contract.md` — changelog entry
- **Public API name verified**: `PrismWorkflowCanvasStage` via `prism_aliases.dart` → `DSWorkflowCanvasStage` in `workflow_canvas_stage.dart`, exported from `organisms.dart`
- **Distinction from map stage**:
  - Workflow stage: `packages/warp_prism_ui/lib/src/organisms/workflow_canvas_stage/ds_workflow_canvas_stage.dart` — domain = DAG steps (ingest/route/respond/…)
  - Map stage: `packages/warp_prism_ui/lib/src/organisms/map_canvas_stage/ds_map_canvas_stage.dart` — domain = geo/map layers
  - Separate modules, separate type hierarchies (`DSWorkflowCanvasStage` ≠ `DSMapCanvasStage`), separate aliases (`PrismWorkflowCanvasStage` ≠ `PrismMapCanvasStage`)
  - Test `public API is distinct from map canvas stage type` confirms no type mixing (line 255–270)
  - No MapLibre import or dependency anywhere in workflow stage module
- **Tests or validation commands**:
  - `dart analyze lib/src/organisms/workflow_canvas_stage/ test/organisms/workflow_canvas_stage/` → `No issues found!`
  - `flutter test test/organisms/workflow_canvas_stage/ --concurrency=1 --no-pub` → `All tests passed!` (13/13)
  - `grep -i maplibre pubspec.yaml` → `NO_MAPLIBRE: OK`
- **Boundary harness**: 6/6 PASS (barrel export, alias registration, gallery entry, map-stage type guard, empty/loading surface, selection bus callbacks)
- **Local changelog entry**: `docs/changelog/20260715-000000-1610-2026-07-15-task-1610-workflow-canvas-stage-contract.md`
- **Agent-wiki / docs institutionalization**: N/A (organism contract; no cross-repo institutionalization needed)
- **Executor**: builders
- **Completion date**: 2026-07-15

---

> **STATUS**: Ready for parent promotion check. All evidence-refresh exit conditions met. Evidence refreshed 2026-07-15.

---

## Post-Promotion Evidence — 2026-07-15

1. `test -f docs/tasks/03-review/1610-warp-prism-workflow-canvas-stage-contract.md && echo IN_REVIEW: OK` → `IN_REVIEW: OK`
2. `test ! -f docs/tasks/02-doing/1610-warp-prism-workflow-canvas-stage-contract.md && echo NOT_IN_DOING: OK` → `NOT_IN_DOING: OK`
3. Header status: `[x] Done` + `Review State: Completed
4. Lane proof: `ls docs/tasks/03-review/` includes `1610-warp-prism-workflow-canvas-stage-contract.md`; `ls docs/tasks/02-doing/` does not.
5. Changelog validation: `docs/changelog/20260715-000000-1610-2026-07-15-task-1610-workflow-canvas-stage-contract.md` created independently of tasklist.
6. Index/discoverability: Organism barrel export at `organisms.dart:59` and `Prism*` aliases at `prism_aliases.dart:675–714` confirmed live.
7. All `02-doing` counts and lane proofs are current (3 in doing, 117 in review as of move timestamp).
8. Residual risk: None identified. All exit conditions met; 13/13 tests pass; analyze clean; no MapLibre; map-stage type guard in test suite.

## Review Ledger


### Latest Review — drain 2026-07-17

- **Date**: 2026-07-17
- **Reviewer profile**: `reviewers` (gt-flutter-code-reviewer + code-quality-harness + flutter-harness + review-report-lineage)
- **Score**: `90/100`
- **Verdict**: `APPROVED_PATH_TO_100`
- **Full report**: `docs/reports/review-wave-2026-07-17/task-1610-drain-review.md`
- **Lane outcome**: moved `03-review/` → `04-completed/`
- **Task reference**: Task 1610
- **Top residual**: Details/What subtasks unchecked despite CE done

#### Path-to-100 residuals (non-blocking for S≥90 closeout)

- See full report Path To 100. Shared: `dart format` on EPIC-16 organism/test/golden surfaces.
- Package-wide analyzer infos (141) are residual package hygiene, not scoped-task exit failures.


---

## Review Ledger — 2026-07-18 Path-to-100 Re-review (Batch R6)

| Field | Value |
| --- | --- |
| **Date** | 2026-07-18 |
| **Reviewer** | independent `reviewers` (parent agentID=reviewers) |
| **Harnesses** | code-quality-harness + flutter-harness |
| **Score** | 100/100 |
| **Verdict** | ACCEPTED_100 |
| **Path-to-100 applied** | YES |
| **Lane** | → `04-completed/` |
| **Full report** | `docs/reports/review-wave-2026-07-18/task-1610-path100-rereview.md` |
| **Top finding** | none — Details checkboxes + format closed |
| **Exits** | PASS |
| **Live gates** | format 0; analyze 0; organism/gallery/goldens PASS; boundaries 7/7 |

