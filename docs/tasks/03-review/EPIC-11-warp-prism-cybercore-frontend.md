# EPIC-11 — Warp Prism Cybernetics Core Frontend

> **Planning Status**: Drained — Ready For Review
> **Executable?**: No — planning artifact only.
> **Review State**: Ready For Review — internal builder review 100/100 (2026-07-16); promoted to `03-review/`
> **Origin**: User clarified that Warp Prism must support a reusable operational ADS plus future Cybernetics Core frontend work, not just a mock ASW Observatory.
> **Depends on**: `1100-warp-prism-operational-atomic-design-system-epic.md`, Task 1101, Task 1102, Task 1104.
> **Implementation gate**: Task 1107 (Melos migration must complete before component work begins).

## Goal

Define the governed path from Warp Prism's reusable Flutter operational atomic design system to a Cybernetics Core frontend implementation. The first delivery target is not a destructive migration from the current Next.js frontend; it is an evidence-backed Flutter app/pilot inside the Warp Prism monorepo that can consume `warp_prism_ui`, mirror selected Cybernetics Core admin surfaces with fixed fixtures, and later decide whether to become a replacement, companion, or design-system reference implementation.

## Source Evidence

- `warp-prism/docs/tasks/00-planning/1100-warp-prism-operational-atomic-design-system-epic.md` defines Warp Prism as the ADS and catalog foundation for Cybernetics Core first.
- `warp-prism/docs/tasks/01-open/1102-warp-prism-control-surface-inventory.md` requires Cybernetics Core surface inventory and pilot matrix.
- Parent Cybernetics Core current frontend lives under `cyberneticscore/apps/frontend/` and backend/API under `cyberneticscore/apps/backend/`.
- Parent completed tasks 0583 and 0590 are cited by Task 1100 as current Cybernetics Core design-system evidence.

## Scope

- CyberCore frontend scope decision: mirror, companion app, replacement candidate, or ADS consumer only.
- Route parity matrix for current Cybernetics Core frontend/admin surfaces.
- API/data contract inventory for read-only frontend surfaces.
- Fixture-backed Flutter CyberCore app under `warp-prism/apps/cybercore/` once the Melos scaffold exists.
- Pilot screens that consume `packages/warp_prism_ui` and reuse catalog/state matrices.
- CI/test gate that proves ADS changes do not break CyberCore app consumers.

## Out of Scope

- Replacing the current Cybernetics Core Next.js frontend without a later explicit migration decision.
- Live mutation against Cybernetics Core backend APIs before safety and auth gates are documented.
- Reimplementing all Cybernetics Core routes in the first wave.
- Introducing SQLite or client-side durable runtime state.

## RF8 Framing

| Stage | Decision |
| --- | --- |
| Goal | Provide a path from reusable Flutter ADS to real Cybernetics Core frontend value. |
| Domain | Cybernetics Core admin/control plane surfaces, registry views, health/status, configuration UX, and governance states. |
| Feature | Scope decision, route parity, API contract, fixture-backed app shell, pilot screens, expansion gate. |
| Representation | Monorepo apps/packages, catalog stories, CyberCore pilot fixtures, route/API matrices. |
| Specs | Typed DTOs/read models, route contracts, operational state vocabulary, fixture schemas. |
| Behaviour | Browse registry/status surfaces read-only, inspect details, show loading/error/empty/degraded states. |
| Test | `melos run analyze`, `melos run test`, app-level widget tests, fixture parser tests, catalog smoke. |
| Eval | No CyberCore route promoted without source-route mapping, fixture, widget test, accessibility/semantics check, and ADS consumer compatibility. |

## Candidate Executable Tasks

### Wave 1: Monorepo + Scope (existing)
- Task 1107: Warp Prism Melos monorepo migration.
- Task 1108: CyberCore frontend scope and route parity matrix.
- Task 1109: CyberCore API/data contract inventory.
- Task 1110: CyberCore fixture-backed app shell MVP.

### Wave 2: Critical ADS Components (new, after gap analysis)
- Task 1112: Data table component (sortable, filterable, paginated, virtualized).
- Task 1113: Command palette (Cmd+K global search, fuzzy match, action execution).
- Task 1114: Log/event streaming viewer (severity, source filter, auto-scroll).
- Task 1115: Loading skeleton + error boundary patterns.
- Task 1116: Notification/toast system.
- Task 1117: Graph visualization refactor + enhancement.
- Task 1118: Operational state vocabulary expansion (3→14+ states).

### Wave 3: Operational Quality (new)
- Task 1119: Health dashboard components.
- Task 1120: Drag-and-drop task board.
- Task 1121: Code block + markdown renderer.
- Task 1122: Tab bar + resizable split pane.
- Task 1123: Virtual scroll optimization for 10K+ rows.

> **Source**: Gap analysis reports in `warp-prism/docs/reports/ads-gap-analysis-20260608.md`
> and `warp-prism/docs/reports/cybercore-domain-ui-mapping-20260608.md`.

## Guardrails

> [!CAUTION]
> Do not treat CyberCore pilot work as authorization to remove or rewrite the existing `cyberneticscore/apps/frontend/` implementation.

> [!CAUTION]
> Do not add live backend mutations. First wave is read-only or fixed-fixture unless a later task explicitly opens mutation with auth/safety gates.

> [!IMPORTANT]
> The ADS package (`packages/warp_prism_ui`) must remain app-agnostic. CyberCore-specific state, routes, and API DTOs belong in `apps/cybercore/` or a later CyberCore-specific package, not in the core ADS.

## Reference Evidence (2026-06-08 sweep)

### Backend Domain Corpus
- `warp-prism/docs/reference/cybercore-backend-features/` — 35 files, ~1,336 features from Go backend.
- Maps 40+ domain entities, 11 state machines, 16 admin CRUD entities, ~13 read-only dashboards.
- Source: `~/working/go/docs/features/` (CyberCore Go backend project).

### Flutter Reference Repo Sweep
- `warp-prism/docs/reports/flutter-reference-repo-sweep-20260608.md` — patterns from 37 archived repos.
- Key finding: `dart_agent_core` (published Dart agent framework, v1.0.13) as primary reference for agent UI patterns.
- Key finding: `skill_tree` (custom RenderObject graph widget) for DAG visualization.
- Key finding: `achieve-flutter-architecture` (production fintech) for DataPage lifecycle, EventBus, caching.

### ADS Gap Analysis
- `warp-prism/docs/reports/ads-gap-analysis-20260608.md` — coverage matrix vs operational UI needs.
- 8 PRESENT (40%), 6 PARTIAL (30%), 6 MISSING (30%).
- 3 CRITICAL gaps: data table, command palette, log viewer.
- 6 IMPORTANT gaps: graph maturity, skeleton, toast, error boundary, health dashboard, drag-and-drop.
- Recommended new sub-skill: `operational-ui-patterns`.

### Domain-to-Component Mapping
- `warp-prism/docs/reports/cybercore-domain-ui-mapping-20260608.md` — entity→component→screen mapping.
- 13 atoms, 12 molecules, 16 organisms, 8 page templates recommended for ADS.

## Completion Criteria for Epic

- Scope decision and route parity matrix exist.
- CyberCore app can compile/test inside the Warp Prism monorepo scaffold.
- At least two pilot surfaces are represented with fixed fixtures, catalog cases, widget tests, and semantics checks.
- ADS changes are validated against the catalog, Observatory app, and CyberCore pilot app in one monorepo gate.
- Critical ADS gaps (data table, command palette, log viewer) are resolved or explicitly deferred.
- Operational state vocabulary covers 14+ states across all CyberCore entity lifecycles.

---

## EPIC-11 Planning Closeout — 2026-07-15

> **STATUS**: Planning artifact drained. All executable work promoted out of this file.
> Internal builder review: **100/100 PASS** (2026-07-16). Promoted to `03-review/`.

### Closeout Summary

All EPIC-11 executable tasks have been promoted out of `01-open` and `02-doing`.
This planning artifact is retained in `03-review/` as the governing reference and
closeout record. No further executor action is required.

### Task Placement Evidence (verified 2026-07-15)

| Task | Lane | Title |
| --- | --- | --- |
| 1101 | `04-completed/` | Charter and Naming Convergence |
| 1102 | `03-review/` | Control Surface Inventory |
| 1103 | `03-review/` | Flutter Tooling and Scaffold — **SUPERSEDED** (see note) |
| 1104 | `03-review/` | Melos Monorepo Architecture Plan |
| 1105 | `03-review/` | Token/Theme Catalog Policy |
| 1106 | `03-review/` | Operational Component MVP |
| 1107 | `03-review/` | Melos Monorepo Migration |
| 1108 | `03-review/` | CyberCore Frontend Scope & Route Parity |
| 1109 | `03-review/` | CyberCore API/Data Contract Inventory |
| 1110 | `03-review/` | CyberCore Fixture-Backed App Shell MVP |
| 1111 | `03-review/` | CyberCore Pilot Mirror Expansion Gate |
| 1112 | `03-review/` | Data Table Component |
| 1113 | `03-review/` | Command Palette |
| 1114 | `03-review/` | Log/Event Streaming Viewer |
| 1115 | `03-review/` | Loading Skeleton + Error Boundary |
| 1116 | `03-review/` | Notification/Toast System |
| 1117 | `03-review/` | Graph Visualization Refactor |
| 1118 | `04-completed/` | Operational State Vocabulary Expansion |
| 1119 | `03-review/` | Health Dashboard Components |
| 1120 | `03-review/` | Drag-and-Drop Task Board |
| 1121 | `03-review/` | Code Block + Markdown Renderer |
| 1122 | `03-review/` | Tab Bar + Resizable Split Pane |
| 1123 | `03-review/` | Virtual Scroll Optimization |
| 1126 | `03-review/` | README Monorepo Reality Alignment |

**Totals**: `04-completed`: 2 · `03-review`: 22 · `01-open`/`02-doing` (executable): 0

### Task 1103 Superseded Closure

Task 1103 (Flutter Tooling and Scaffold) is closed as **SUPERSEDED** (terminal state).
All scaffold objectives were fulfilled by:
- **Task 1104** — Melos monorepo architecture plan (approved in `03-review/`)
- **Task 1107** — Melos monorepo migration (approved in `03-review/`)

The old scaffold subtasks are not executed because they conflict with the
approved Melos monorepo layout. No residual work remains from 1103.

### Exit Condition — Planning Artifact Drained

- [x] All EPIC-11 executable tasks (1101–1126) are in `03-review/` or `04-completed/`.
- [x] No EPIC-11 executable tasks remain in `01-open/` or `02-doing/`.
- [x] Task 1103 superseded closure is documented and acknowledged.
- [x] This planning file is promoted to `03-review/` after internal builder review 100/100.

### Internal builder review — 2026-07-16 (`gt-code-quality-reviewer`)

**Score**: 100/100  
**Verdict**: PASS — all closeout claims verified against live filesystem.

**Fresh evidence reviewed**:
- Full EPIC-11 file read; zero executable EPIC-11 tasks in `01-open/` or `02-doing/`.
- Task placement table (1101–1126): 2 in `04-completed/`, 22 in `03-review/`, 0 executable in active lanes.
- Task 1103 superseded closeout in `03-review/` with terminal SUPERSEDED status and live Melos layout evidence.
- Live structure spot-check: `packages/warp_prism_ui/`, `apps/{observatory,catalog,cybercore}/`, root `workspace:`, no root `lib/`/`test/`, no standalone `melos.yaml`.

**Residual risks**: none for this planning closeout. Individual EPIC-11 tasks in `03-review/` still require independent human completion promotion; this epic file only records drained planning status.

### **STATUS**: Ready For Review. Internal builder review 100/100. Promoted to `03-review/`.
Evidence refreshed 2026-07-15; lane promotion 2026-07-16.
