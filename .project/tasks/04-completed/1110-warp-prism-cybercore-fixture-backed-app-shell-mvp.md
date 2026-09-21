# Task 1110: Warp Prism CyberCore Fixture Backed App Shell MVP

> **Review State**: **Held in review** — residual F2–F4 closed (2026-07-10); ready for re-score; remain `03-review/`
> **Priority**: 🟡 P1
> **Type**: `feature`
> **Origin**: EPIC-11 and CyberCore frontend implementation path.
> **Blocks**: Task 1111
> **Depends on**: Task 1106, Task 1107, Task 1108, Task 1109
> **ready_for_reviewer**: **yes** (promoted)
> **Lane**: `docs/tasks/03-review/`

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

- [x] `apps/cybercore/pubspec.yaml` exists and depends on `warp_prism_ui` via path.
- [x] `apps/cybercore/lib/main.dart` exists.
- [x] `apps/cybercore/lib/app/` contains app root and router shell for MVP routes.
- [x] Fixed fixture data matching Task 1109 schema exists under `apps/cybercore/assets/cybercore_fixtures/` (note: not `assets/fixtures/` path as originally drafted).
- [x] `apps/cybercore/test/` contains widget tests for startup, route navigation, fixture rendering, and one non-happy state.
- [x] `melos run analyze` — monorepo residual OK; **scoped** `cd apps/cybercore && flutter analyze` → **No issues found** (2026-07-09 path-to-100).
- [x] `melos run test` — monorepo residual OK; **scoped** `cd apps/cybercore && flutter test` → **12/12 PASS** (2026-07-09 path-to-100).
- [x] Local changelog entry added under `docs/changelog/` (`2026-06-08-task-1110-cybercore-app-shell-mvp.md` + `2026-07-09-task-1110-pilot-route-realign-path-to-100.md`).
- [x] Completion Evidence is filled before review handoff.

---

## Details

### What

Subtasks:

- [x] **Read existing code before modifying**: read Task 1107 monorepo structure, Task 1108 route matrix, Task 1109 fixture schema, Task 1106 reusable components, and `packages/warp_prism_ui` public API.
- [x] Create or refine `apps/cybercore` app manifest and entrypoint.
- [x] Implement app root/router shell for selected MVP routes (Task 1108 pilots A/B/C).
- [x] Add fixed fixtures matching pilot DTOs under `assets/cybercore_fixtures/`.
- [x] Render pilot routes using `warp_prism_ui` components.
- [x] Add widget tests for startup, navigation, fixture rendering, and non-happy state.
- [x] **Simplicity pass**: keep first CyberCore app shell minimal and fixture-backed.
- [x] **Regression verification**: scoped `flutter analyze` / `flutter test` on `apps/cybercore`.

### Where

| File | Purpose |
| --- | --- |
| `docs/design/cybercore-scope-route-parity.md` | Read — MVP route list (live path). |
| `docs/design/cybercore-pilot-surface-matrix.md` | Read — pilot surface matrix (live path). |
| `docs/design/cybercore-fixture-schema.md` | Read — fixture schema from Task 1109. |
| `packages/warp_prism_ui/lib/` | Read — ADS public API. |
| `apps/cybercore/pubspec.yaml` | Create — app manifest. |
| `apps/cybercore/lib/main.dart` | Create — app entrypoint. |
| `apps/cybercore/lib/app/` | Create — app root/router shell. |
| `apps/cybercore/assets/cybercore_fixtures/` | Create — fixed fixture data (pilot domain JSON). |
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
- **Local changelog entry**: `docs/changelog/2026-06-08-task-1110-cybercore-app-shell-mvp.md`

### Evidence refresh — 2026-07-09 (gt-flutter-engineer evidence batch)

| Check | Result |
| --- | --- |
| `apps/cybercore/pubspec.yaml` + path dep `warp_prism_ui` | **PASS** |
| `lib/main.dart`, `lib/app/{router,cybercore_shell}.dart` | **PASS** |
| Fixtures | `assets/cybercore_fixtures/*.json` (7 files) |
| `flutter analyze` (cybercore app) | **No issues found** |
| `flutter test` (cybercore app) | **12/12 PASS** |
| Upstream 1102 hard gate | Satisfied at evidence level (Ready For Review + inventory docs) |
| Monorepo `melos run analyze` | Residual red (external packages) |
| **ready_for_reviewer** | **yes** (scoped app green) |
| Lane | **left in `02-doing/`** |

### Independent review — 2026-07-09 (gt-code-quality-reviewer wave)

| Field | Value |
| --- | --- |
| **Score** | **82** |
| **Lane** | stay `docs/tasks/02-doing/` |
| **ready_for_reviewer** | **no** |
| **Re-verified** | `cd apps/cybercore && flutter analyze` → No issues; `flutter test` → **12/12 PASS**. |

#### Blocker (contract)
Task 1108 (post-1102 refresh) selects pilots **A/B/C**: `/providers`, `/mcp-servers` (+ inspector), `/live-logs`.  
Implemented shell routes are Observatory-proxy: `/dashboard`, `/registry`, `/tasks`, `/audit`, `/governance` — explicitly labeled **not live CC routes** in `docs/design/cybercore-scope-route-parity.md` §2.4.  
Test requirement: *implement only the routes selected by Task 1108 for MVP/pilot* → **not met**.

#### Path-to-100
1. Realign `apps/cybercore` router + feature pages to pilot paths `/providers`, `/mcp-servers`, `/mcp-inspector` (optional), `/live-logs` **or** get an explicit ADR/amend from product that Observatory-proxy shell is accepted as a non-pilot ADS smoke shell (update 1108 + this task exits).
2. Keep fixture-backed + read-only; refresh fixtures against Task 1109 pilot DTOs for those routes.
3. Re-run scoped `flutter test` / `flutter analyze` on `apps/cybercore`.
4. Mark What-subtasks complete once done; monorepo melos residual alone does **not** block if scoped green.

### Path-to-100 applied — 2026-07-09 (gt-flutter-engineer)

| Field | Value |
| --- | --- |
| **ready_for_reviewer** | **yes** |
| **Lane** | **left in `docs/tasks/02-doing/`** |
| **Scoped analyze** | `cd apps/cybercore && flutter analyze` → **No issues found** |
| **Scoped test** | `cd apps/cybercore && flutter test` → **12/12 PASS** |
| **Changelog** | `docs/changelog/2026-07-09-task-1110-pilot-route-realign-path-to-100.md` |
| **Archive** | Observatory-proxy shell → `.archive/task-1110-observatory-proxy-shell-20260709/` |

#### Routes after realignment

| Path | Pilot | Feature |
| --- | --- | --- |
| `/` | redirect | → `/providers` |
| `/providers` | A | Connections list (`PrismDataTable`, `PrismStoryPanel`) |
| `/providers/new` | A nested | Read-only create form (save disabled) |
| `/providers/:id` | A nested | Connection detail |
| `/mcp-servers` | B | Installed MCP servers list |
| `/mcp-servers/:uuid` | B nested | Server detail |
| `/mcp-inspector` | B | Fixture inspector (no live STDIO) |
| `/live-logs` | C | `PrismLogViewer` + redaction fixtures |

Primary nav (shell): **Providers · MCP Servers · MCP Inspector · Live Logs**.  
Removed as primary nav: `/dashboard`, `/registry`, `/tasks`, `/audit`, `/governance`.

#### Fixtures after

- `assets/cybercore_fixtures/providers.json`
- `assets/cybercore_fixtures/mcp_servers.json`
- `assets/cybercore_fixtures/mcp_inspector.json`
- `assets/cybercore_fixtures/live_logs.json`

#### Files created/modified (path-to-100)

- `apps/cybercore/lib/app/router.dart` — `createAppRouter()` pilot branches
- `apps/cybercore/lib/app/cybercore_shell.dart` — pilot nav items + Material content wrap
- `apps/cybercore/lib/main.dart` — per-instance router
- `apps/cybercore/lib/features/providers/*` — list/new/detail
- `apps/cybercore/lib/features/mcp_servers/*` — list/detail
- `apps/cybercore/lib/features/mcp_inspector/mcp_inspector_page.dart`
- `apps/cybercore/lib/features/live_logs/live_logs_page.dart`
- `apps/cybercore/lib/data/fixtures/*` — pilot DTOs + loader
- `apps/cybercore/test/widget_test.dart`, `test/fixtures/fixture_models_test.dart`

#### Contract check vs review blocker

Reviewer required Task 1108 pilots A/B/C — **met**. Shell no longer uses Observatory-proxy paths as primary nav.

### Independent re-review — 2026-07-09 (gt-code-quality-reviewer)

| Field | Value |
| --- | --- |
| **Score** | **100** |
| **Verdict** | **APPROVED / PROMOTED** |
| **Lane** | `docs/tasks/02-doing/` → `docs/tasks/03-review/` |
| **Path-to-100** | none |
| **Report** | `docs/reports/build-gate-review/1110-review-2026-07-09-path-to-100-rereview.md` |

#### Re-verified gates

| Command | Result |
| --- | --- |
| `cd apps/cybercore && flutter analyze` | **No issues found** |
| `cd apps/cybercore && flutter test` | **12/12 PASS** |
| `dart format --output=none --set-exit-if-changed lib test` | **PASS** (reviewer applied format on 9 files first) |

#### Routes verified (Task 1108 pilots A/B/C)

| Path | Pilot | Status |
| --- | --- | --- |
| `/` → `/providers` | redirect | **PASS** (`router.dart`) |
| `/providers` | A | **PASS** |
| `/providers/new` | A nested | **PASS** (save disabled) |
| `/providers/:id` | A nested | **PASS** |
| `/mcp-servers` | B | **PASS** |
| `/mcp-servers/:uuid` | B nested | **PASS** |
| `/mcp-inspector` | B | **PASS** (no live STDIO) |
| `/live-logs` | C | **PASS** |

Primary nav: **Providers · MCP Servers · MCP Inspector · Live Logs**.  
Observatory-proxy paths (`/dashboard`, `/registry`, `/tasks`, `/audit`, `/governance`) absent from router primary branches and nav (only historical comment).  
Fixtures: `providers.json`, `mcp_servers.json`, `mcp_inspector.json`, `live_logs.json`.  
ADS: path dep `warp_prism_ui`; zero `DS*` widgets under `lib/`; fixture-backed read-only.

#### Prior blocker closure

Score-82 route-contract drift is **closed**. No Critical/High/Medium findings remain.

### 2026-07-09 independent re-review (reviewers)

| Field | Value |
| --- | --- |
| **Score** | **96/100** — `HELD_IN_REVIEW_PATH_TO_100` |
| **Lane** | remain `docs/tasks/03-review/` (**not** `04-completed/`) |
| **ready_for_reviewer** | **yes** |
| **Report** | `docs/reports/review-wave-2026-07-09/task-1110-cybercore-fixture-backed-app-shell-mvp-independent-rereview.md` |
| **Live gates** | `flutter analyze` No issues; `flutter test` **12/12 PASS**; DS* in lib = 0; Prism* ~181 |
| **Blockers** | none High/Medium |
| **Residual path-to-100** | ~~Where path~~; ~~Pilot B widget tests~~; ~~empty-state test~~ — **CLOSED 2026-07-10** (see residual closure below) |

### 2026-07-10 residual closure (gt-flutter-engineer)

| Field | Value |
| --- | --- |
| **Residual batch** | Where path + Pilot B tests (+ Pilot A empty) |
| **Lane** | remain `docs/tasks/03-review/` (no promote to `04-completed/`) |
| **ready_for_reviewer** | **yes** |

#### Closed residuals

| ID | Residual | Fix |
| --- | --- | --- |
| F2 | Where table `assets/fixtures/` vs live path | Where table → `apps/cybercore/assets/cybercore_fixtures/` |
| F3 | Thin Pilot B widget coverage | `McpServersPage(loader:)` injection + success/empty/error widget tests |
| F4 | Pilot A empty not proven | Providers empty-state widget test |

#### Live gates

| Command | Result |
| --- | --- |
| `cd apps/cybercore && flutter analyze` | **No issues found** |
| `cd apps/cybercore && flutter test --concurrency=1 --no-pub` | **16/16 PASS** (was 12) |
| `dart format --output=none --set-exit-if-changed lib test` | **PASS** |

#### Files touched

- `docs/tasks/03-review/1110-…md` (Where path + residual ledger)
- `apps/cybercore/lib/features/mcp_servers/mcp_servers_page.dart` (optional `loader`)
- `apps/cybercore/test/widget_test.dart` (Pilot A empty + Pilot B success/empty/error)
- `docs/changelog/2026-07-10-task-1110-residual-where-path-pilot-b-tests.md`


### 2026-07-18 path-to-100 batch4 (builders)
- Live proof currency: `cd apps/cybercore && flutter test` → **16/16 PASS** (supersedes historical **12/12** CE paragraphs).
- Runtime fixtures remain pilot-only under `apps/cybercore/assets/cybercore_fixtures/` (providers, mcp_servers, mcp_inspector, live_logs). Older CE blocks that list Observatory/ASW fixture filenames are **historical narrative only**.
- Where dead `cybercore-route-parity-matrix.md` corrected to live design paths.
- Report notes: `docs/reports/path-to-100-wave-2026-07-17/batch4-notes.md`
- Lane: left in `03-review/` (no self-promote)

---

### 2026-07-18 — independent path-to-100 re-review (reviewers, batch R4)
- **Score**: `98/100`
- **Verdict**: `ACCEPTED_PATH_TO_100` → **Promoted** to `docs/tasks/04-completed/`
- **Full report**: `docs/reports/review-wave-2026-07-18/task-1110-path100-rereview.md`
- **path100_applied**: yes — re-verified batch4 CE/Where currency; no code residual open
- **Live exits**: cybercore analyze clean; flutter test 16/16; routes A/B/C; DS*=0; Prism* live
- **Top residual**: Historical CE paragraphs still list Observatory fixture names (superseded by pilot fixtures)
- **Lane outcome**: `03-review/` → `04-completed/`
- **No git / no tasklist**
