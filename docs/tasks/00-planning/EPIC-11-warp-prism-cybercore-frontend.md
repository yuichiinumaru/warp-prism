# EPIC-11 — Warp Prism Cybernetics Core Frontend

> **Planning Status**: Active Epic
> **Executable?**: No — planning artifact only.
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
