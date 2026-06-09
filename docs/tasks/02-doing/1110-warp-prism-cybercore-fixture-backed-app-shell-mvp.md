# Task 1110: Warp Prism CyberCore Fixture Backed App Shell MVP

> **Status**: `[ ]` Open
> **Priority**: 🟡 P1
> **Type**: `feature`
> **Origin**: EPIC-11 and CyberCore frontend implementation path.
> **Blocks**: Task 1111
> **Depends on**: Task 1106, Task 1107, Task 1108, Task 1109

> [!IMPORTANT]
> Task identity is lane-neutral. Use `Task 1110` plus optional slug for dependencies, blockers, review ledgers, reports, and architecture references.

---

## Objective

Create the first fixture-backed `apps/cybercore` Flutter app shell inside the Warp Prism Melos monorepo. The shell must consume `packages/warp_prism_ui`, implement the route skeleton selected by Task 1108, load fixed fixtures defined by Task 1109, and remain read-only until later mutation tasks are explicitly approved.

## Background Context

### What already exists

- Task 1107 should create the Melos monorepo with `apps/cybercore` target path.
- Task 1108 should define the first-wave CyberCore route list and scope.
- Task 1109 should define API/read-model fixture schemas.
- Task 1106 should promote reusable operational components into `packages/warp_prism_ui`.

### What is missing or broken

- No `apps/cybercore` app exists yet.
- No fixture-backed CyberCore route shell exists.
- No tests prove a CyberCore app can consume the ADS package.
- No monorepo gate proves ADS changes keep CyberCore shell compiling.

---

## Test Requirements

- The CyberCore app MUST consume `warp_prism_ui` via path dependency.
- The app MUST implement only the routes selected by Task 1108 for MVP/pilot.
- The app MUST load fixed fixtures, not live backend data.
- The app MUST show loading, empty, error/degraded, and success states for at least one pilot route.
- The app MUST remain read-only and expose no mutation action that calls a backend.
- Widget tests MUST prove shell startup, route navigation, fixture rendering, and at least one non-happy state.

---

## Exit Conditions

- [ ] `apps/cybercore/pubspec.yaml` exists and depends on `warp_prism_ui` via path.
- [ ] `apps/cybercore/lib/main.dart` exists.
- [ ] `apps/cybercore/lib/app/` contains app root and router shell for MVP routes.
- [ ] `apps/cybercore/assets/fixtures/` contains fixed fixture data matching Task 1109 schema.
- [ ] `apps/cybercore/test/` contains widget tests for startup, route navigation, fixture rendering, and one non-happy state.
- [ ] `melos run analyze` passes.
- [ ] `melos run test` passes.
- [ ] Local changelog entry added under `docs/changelog/`.
- [ ] Completion Evidence is filled before review handoff.

---

## Details

### What

Subtasks:

- [ ] **Read existing code before modifying**: read Task 1107 monorepo structure, Task 1108 route matrix, Task 1109 fixture schema, Task 1106 reusable components, and `packages/warp_prism_ui` public API.
- [ ] Create or refine `apps/cybercore` app manifest and entrypoint.
- [ ] Implement app root/router shell for selected MVP routes.
- [ ] Add fixed fixtures matching Task 1109 schema.
- [ ] Render at least one pilot route using `warp_prism_ui` components.
- [ ] Add widget tests for startup, navigation, fixture rendering, and non-happy state.
- [ ] **Simplicity pass**: keep first CyberCore app shell minimal and fixture-backed.
- [ ] **Regression verification**: run Melos analyze/test gates.

### Where

| File | Purpose |
| --- | --- |
| `docs/design/cybercore-route-parity-matrix.md` | Read — MVP route list. |
| `docs/design/cybercore-fixture-schema.md` | Read — fixture schema from Task 1109. |
| `packages/warp_prism_ui/lib/` | Read — ADS public API. |
| `apps/cybercore/pubspec.yaml` | Create — app manifest. |
| `apps/cybercore/lib/main.dart` | Create — app entrypoint. |
| `apps/cybercore/lib/app/` | Create — app root/router shell. |
| `apps/cybercore/assets/fixtures/` | Create — fixed fixture data. |
| `apps/cybercore/test/` | Create — widget tests. |
| `docs/changelog/` | Create local changelog note. |

### How

1. Use Task 1108/1109 outputs as implementation contract.
2. Keep the app fixture-backed and read-only.
3. Consume the ADS package rather than copying components.
4. Validate with monorepo-wide gates.

### Why

A CyberCore frontend plan becomes real only when an app shell can consume the shared ADS and render source-backed fixtures. This MVP proves the monorepo architecture prevents drift between ADS and frontend consumers.

---

## Anti-Hallucination Guardrails

> [!CAUTION]
> Do not call live Cybernetics Core backend APIs in this task.

> [!CAUTION]
> Do not implement routes outside the Task 1108 MVP/pilot scope.

---

## Validation Commands

```bash
melos bootstrap
melos run analyze
melos run test
```

---

## Completion Evidence

- **Files created/modified**:
  - `apps/cybercore/pubspec.yaml` — Added go_router, intl, collection deps + asset declarations
  - `apps/cybercore/lib/main.dart` — MaterialApp.router with GoRouter integration
  - `apps/cybercore/lib/app/router.dart` — GoRouter config with 5 StatefulShellBranch routes
  - `apps/cybercore/lib/app/cybercore_shell.dart` — App shell with DSSidebar, DSTopbar, DSShellResponsive
  - `apps/cybercore/lib/data/fixtures/fixtures.dart` — Barrel export for all fixture models
  - `apps/cybercore/lib/data/fixtures/dashboard_summary.dart` — DashboardSummary DTO
  - `apps/cybercore/lib/data/fixtures/registry_agent.dart` — RegistryAgent DTO
  - `apps/cybercore/lib/data/fixtures/registry_skill.dart` — RegistrySkill DTO
  - `apps/cybercore/lib/data/fixtures/registry_workflow.dart` — RegistryWorkflow DTO
  - `apps/cybercore/lib/data/fixtures/task_execution.dart` — TaskExecution DTO
  - `apps/cybercore/lib/data/fixtures/audit_event.dart` — AuditEvent DTO
  - `apps/cybercore/lib/data/fixtures/governance_diagnostics.dart` — GovernanceDiagnostics DTO
  - `apps/cybercore/lib/data/fixtures/fixture_loader.dart` — FixtureLoader from bundled JSON assets
  - `apps/cybercore/lib/features/dashboard/dashboard_page.dart` — Dashboard route with DSMetricTile, DSStatusGrid, DSStoryPanel
  - `apps/cybercore/lib/features/registry/registry_page.dart` — Registry route with DSDataTable + TabBar
  - `apps/cybercore/lib/features/tasks/tasks_page.dart` — Tasks route with DSLaneBoard + DSTaskCard
  - `apps/cybercore/lib/features/audit/audit_page.dart` — Audit route with DSTimeline + DSFilterChipGroup
  - `apps/cybercore/lib/features/governance/governance_page.dart` — Governance route with DSStoryPanel + DSDataTable
  - `apps/cybercore/assets/cybercore_fixtures/dashboard_summary.json` — Dashboard fixture
  - `apps/cybercore/assets/cybercore_fixtures/registry_agents.json` — 9 agents fixture
  - `apps/cybercore/assets/cybercore_fixtures/registry_skills.json` — 13 skills fixture
  - `apps/cybercore/assets/cybercore_fixtures/registry_workflows.json` — 11 workflows fixture
  - `apps/cybercore/assets/cybercore_fixtures/task_board.json` — 22 tasks fixture
  - `apps/cybercore/assets/cybercore_fixtures/audit_trail.json` — 20 audit events fixture
  - `apps/cybercore/assets/cybercore_fixtures/governance_diagnostics.json` — Governance diagnostics fixture
  - `apps/cybercore/test/widget_test.dart` — Updated widget tests (app shell + loading state)
  - `apps/cybercore/test/fixtures/fixture_models_test.dart` — 10 fixture model parsing tests
- **Tests or validation commands**:
  - `flutter analyze` → No issues found (0 warnings, 0 errors)
  - `flutter test` → 12/12 passed (2 widget tests + 10 fixture model tests)
- **Local changelog entry**: Pending
