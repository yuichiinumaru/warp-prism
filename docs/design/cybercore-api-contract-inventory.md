# CyberCore API Data Contract Inventory

> **Task**: 1109
> **Date**: 2026-06-08
> **Status**: Active
> **Scope**: 5 MVP Routes defined in Task 1108

## 1. Overview and Assumptions

This inventory defines the read-only DTO and read-model contracts required to power the 5 first-wave CyberCore Flutter frontend routes. 

### Auth & Config Assumptions
- **Auth**: The first-wave Flutter MVP operates without live auth endpoints. Authentication infrastructure is deferred until Feature 1302 completes.
- **Config/Env**: The MVP runs in a local environment relying strictly on fixed mock fixtures. No base URLs or live API endpoints are required or permitted yet.
- **Mutation Boundaries**: All routes are strictly **read-only**. Any state changes (e.g., updating a policy, creating a provider) are out of scope. Mutation calls are explicitly deferred to Wave 2 or later, following the introduction of safety gates.

### Operational State Integration
Loading, error, empty, and degraded state behaviors map directly to the 15-state operational vocabulary defined in `docs/design/operational-state-vocabulary.md`.

---

## 2. API Contract & DTO Inventory

### 2.1 Route 1: Dashboard (`/dashboard`)
Provides an aggregated summary of workspace metrics, system health, and recent events.

- **DTO**: `DashboardSummaryDto`
- **Fields**:
  - `agentMetrics` (Object, non-null): `{ total: int, healthy: int, degraded: int }`
  - `skillMetrics` (Object, non-null): `{ total: int, withTriggers: int, noTriggers: int }`
  - `workflowMetrics` (Object, non-null): `{ total: int, active: int, orphaned: int }`
  - `executionMetrics` (Object, non-null): `{ planning: int, open: int, doing: int, review: int, completed: int }`
  - `recentActivity` (Object, non-null): `{ total: int, lastWeek: int, types: Map<String, int> }`
- **State Contracts**:
  - **Loading**: `DSStateType.loading` with `DSMetricTile` skeletons.
  - **Empty**: `DSStateType.empty` with placeholder zero-metrics.
  - **Error/Degraded**: Metric panels map to `error` or `degraded` operational states if partial data load fails.
- **Data Source**: Aggregated from `assets/mock_workspace/`.

### 2.2 Route 2: Registry (`/registry`)
Lists available capabilities (Skills), providers (Agents), and routing graphs (Workflows).

- **DTOs**: 
  - `RegistryAgentDto`
    - Fields: `id` (String), `name` (String), `model` (String, nullable), `mode` (String), `description` (String), `skills` (List<String>), `workflows` (List<String>), `operationalState` (String)
  - `RegistrySkillDto`
    - Fields: `id` (String), `name` (String), `triggers` (List<String>), `subSkills` (List<String>), `canonicality` (String)
  - `RegistryWorkflowDto`
    - Fields: `id` (String), `name` (String), `kind` (String), `skills` (List<String>), `agents` (List<String>), `triggers` (List<String>)
- **State Contracts**:
  - **Loading**: Canvas/list shows skeleton loader.
  - **Empty**: "No capabilities found" message.
  - **Error/Degraded**: Unverified entities show `unverified` status dot; stale entities show `stale` warning icon.

### 2.3 Route 3: Task Board (`/tasks`)
Provides an execution view mapped to lane progression.

- **DTO**: `TaskExecutionDto`
- **Fields**:
  - `id` (String)
  - `title` (String)
  - `lane` (String, e.g. "01-open")
  - `priority` (String, nullable)
  - `owner` (String, nullable)
  - `proofState` (String)
  - `reviewScore` (double, nullable)
  - `dependsOn` (List<String>)
  - `operationalState` (String)
- **State Contracts**:
  - **Loading**: Lane skeletons.
  - **Empty**: Empty lanes show "Drop tasks here" equivalent (read-only).
  - **Error/Degraded**: Tasks lacking proof show `exposed` or `degraded`.

### 2.4 Route 4: Audit Trail (`/audit`)
Displays a timeline of system activity and provenance changes.

- **DTO**: `AuditEventDto`
- **Fields**:
  - `id` (String)
  - `date` (String, ISO-8601)
  - `project` (String)
  - `task` (String)
  - `type` (String)
  - `impact` (String)
  - `skills` (List<String>)
  - `body` (String, nullable)
- **State Contracts**:
  - **Loading**: Timeline marker skeletons.
  - **Empty**: "No events recorded" placeholder.
  - **Error/Degraded**: Parsing failure results in `error` marker payload.

### 2.5 Route 5: Governance (`/governance`)
Compliance, diagnostics, and risk classification.

- **DTO**: `GovernanceDiagnosticsDto`
- **Fields**:
  - `orphanWorkflows` (List<String>)
  - `noTriggerSkills` (List<String>)
  - `unverifiedTasks` (List<Object>): `{ taskId: String, title: String, priority: String }`
  - `canonicalityBoundary` (Map<String, int>)
  - `fanInHotspots` (List<Object>): `{ skillName: String, referenceCount: int }`
- **State Contracts**:
  - **Loading**: Metric panel skeletons.
  - **Empty**: "All systems compliant" empty state.
  - **Error/Degraded**: Metrics exceeding threshold shift to `error` or `degraded` operational states visually.

---

## 3. Mutation Boundary Declaration

All definitions above are inherently read-only.
- **POST/PUT/DELETE/PATCH** actions (e.g., approving a plugin, advancing a workflow) will mock an operation via an on-screen toast, but no local state mutation will persist.
- Real API write operations require Feature 1302 and an explicit safety gateway task in Wave 2.