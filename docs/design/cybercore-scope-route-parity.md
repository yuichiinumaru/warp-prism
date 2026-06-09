# CyberCore Frontend Scope & Route Parity Matrix

> **Task**: 1108 — CyberCore Frontend Scope and Route Parity Matrix
> **Date**: 2026-06-08
> **Status**: Active
> **Evidence**: Mock corpus in `assets/mock_workspace/`, CyberCore backend feature catalog in `docs/reference/cybercore-backend-features/`, CyberCore domain mapping in `docs/reports/cybercore-domain-ui-mapping-20260608.md`, ADS component inventory in `docs/design/component-inventory.md`, pilot surface matrix in `docs/design/cybercore-pilot-surface-matrix.md`, operational state vocabulary in `docs/design/operational-state-vocabulary.md`, EPIC-11 in `docs/tasks/00-planning/EPIC-11-warp-prism-cybercore-frontend.md`

---

## 1. Scope Decision

### Decision: Read-Only Mirror (First Wave)

The first CyberCore Flutter app (`apps/cybercore/`) will be a **read-only observatory mirror** — not a migration, not a companion admin app, and not an ADS-only consumer.

| Scope Option | Decision | Rationale |
|-------------|----------|-----------|
| **Read-Only Mirror** | **CHOSEN** | Highest value-per-risk. Demonstrates CyberCore domain surfaces using mock data. Validates ADS components against real entity shapes. No live API dependency. No mutation risk. |
| Migration / Replacement | REJECTED | No evidence that the existing Next.js frontend needs replacement. No auth/session infrastructure in Flutter yet. No OpenAPI client SDK generated yet (blocked by Feature 1300-1304 in `013-frontend-flutter.md`). |
| Companion Admin App | REJECTED | Requires live backend API integration. Backend admin endpoints exist (Features 360-364, 530-539, 606, 934) but all are Go-only with no generated Dart SDK. Auth endpoints are blocked (Feature 1302). |
| ADS Consumer Only | REJECTED | Too thin. Does not demonstrate CyberCore-specific domain shapes. Misses the opportunity to validate ADS components against real entity structures (capabilities, providers, routes, policies). |

### What "Read-Only Mirror" Means

1. **Mock-backed, not live**: All data comes from fixtures modeled after CyberCore entity shapes, not from API calls.
2. **Domain-shaped, not generic**: Screens are organized by CyberCore domain sections (Registry, Execution, Audit, Governance), not by Warp Prism's current section names (Map, Operate, History, Governance).
3. **ADS-validating**: Each route exercises a different combination of ADS atoms/molecules/organisms/templates to prove the design system works for CyberCore domain shapes.
4. **Incremental path**: Later tasks can swap mock fixtures for real API clients route-by-route without rewriting the app shell or navigation.

---

## 2. Route Parity Matrix

### 2.1 CyberCore Backend Route Inventory

Derived from `docs/reference/cybercore-backend-features/` (10 series, ~1,336 features) and the sidebar taxonomy from diegosouza-omniroute (`docs/reference/cybercore-backend-features/101-109`).

| # | CyberCore IA Section | Backend Series | Key Entities | Admin CRUD | State Machines |
|---|---------------------|---------------|--------------|------------|----------------|
| 1 | **Dashboard** | 008 (Observability), 104 (Analytics) | System health, metrics, recent events | Read-only summary | — |
| 2 | **Providers & Routing** | 003 (Capability Registry), 006 (Route Graphs) | Providers, Capabilities, CapabilitySets, RouteGraphs, RouteNodes | CRUD + lifecycle | Capability: draft→active→deprecated→removed, RouteGraph: draft→active→deprecated→removed |
| 3 | **Interfaces / Exposures** | 003 (Exposures), 009 (MCP Surface) | Exposures, MCP surface configs, A2A agent cards | CRUD + lifecycle | Exposure: draft→active→deprecated→removed |
| 4 | **Context Pipeline** | 008 (Limits, Cache), 016 (Compression) | Compression config, cache, thinking budget | Config only | — |
| 5 | **Harness / Policies** | 005 (Policy Engine), 017 (Guardrails) | Policies, PolicyRules, PolicySnapshots, guardrails | CRUD + lifecycle | Policy: draft→active→archived |
| 6 | **MCPs** | 009 (MCP & Sandbox) | MCPServers, MCPTools, MCPTool catalog, catalog sync | CRUD + health | MCPServer: registered→active→unavailable |
| 7 | **Tools** | 009 (Tool Catalog), 024 (MCP Governance) | Tools, tool risk classification, tool quality | Read-only catalog + risk | Tool risk: low→medium→high→critical |
| 8 | **Security & Ops** | 002 (Identity), 004 (Credentials), 105 (Audit) | Users, Sessions, APIKeys, Credentials, CredentialGrants, AuditEvents | CRUD + lifecycle | Credential: active→rotating→expired→revoked, Session: active→expired→revoked |
| 9 | **Execution** | 007 (Execution), 008 (Observability) | ExecutionEnvelopes, ExecutionPlans, ExecutionResults | Read-only inspection | WorkflowExecution: created→running→completed/failed/cancelled |
| 10 | **Plugins** | 012 (Plugin System) | Plugins, manifests, approval workflow | CRUD + approval | Plugin: registered→approved→enabled→disabled→removed |
| 11 | **Agentic** | 107 (Agentic Features), 022 (A2A), 023 (Workflows) | AgentProfiles, Skills, Workflows, Memories, Hooks | CRUD + lifecycle | Memory: active→decayed→expired, Task A2A: submitted→working→completed/failed |
| 12 | **Settings** | 109 (Configuration) | Config, feature flags, trust mode | Config forms | — |

### 2.2 Mock Workspace Entity → CyberCore Domain Mapping

This matrix maps each mock workspace entity type to its CyberCore domain equivalent and identifies which CyberCore IA sections it can prototype.

| Mock Entity | Count | Mock Location | CyberCore Equivalent | CyberCore IA Sections | Mock Coverage |
|------------|-------|--------------|---------------------|----------------------|---------------|
| **Agent** (`.agents/agents/*.md`) | 9 | `assets/mock_workspace/.agents/agents/` | AgentProfile, User (admin/operator/viewer roles) | Agentic, Interfaces, Dashboard | High — each agent has name, model, mode, description, skills[], workflows[] |
| **Skill** (`.agents/skills/*/SKILL.md`) | 13 | `assets/mock_workspace/.agents/skills/` | Capability, CapabilitySet | Providers & Routing, Tools, MCPs | High — each skill has triggers, sub-skills, references, scripts |
| **Workflow** (`.agents/workflows/*.md`) | 11 | `assets/mock_workspace/.agents/workflows/` | WorkflowDefinition, Hook | Harness/Policies, Agentic | Medium — each workflow has kind, skills, agents, triggers |
| **Task** (`docs/tasks/*/*.md`) | 22 | `assets/mock_workspace/docs/tasks/` | Task A2A, WorkflowExecution | Execution, Harness/Policies | Highest — full lifecycle: planning→open→doing→review→completed, proof_state, review_score, priority, owner, depends_on |
| **Changelog Entry** (`docs/changelog/*.md`) | 36 | `assets/mock_workspace/docs/changelog/` | AuditEvent | Security & Ops (Audit) | High — each entry has date, project, task, type, impact, skills |
| **Manifest** (`manifest.yaml`) | 1 | `assets/mock_workspace/manifest.yaml` | System config snapshot | Dashboard, Settings | Medium — aggregate counts, schema definition |

### 2.3 Route Prototype Mapping

Each CyberCore IA section is evaluated against what the mock corpus can demonstrate:

| CyberCore IA Section | Mock Prototyping? | Best Mock Surface | ADS Template | Readiness |
|---------------------|-------------------|-------------------|-------------|-----------|
| **1. Dashboard** | **YES** | All 5 entity types aggregated | DashboardTemplate (metric tiles + story panels) | Ready — `OverviewProvider` + `OverviewMetrics` already exist |
| **2. Providers & Routing** | **YES** | 9 agents + 13 skills + 11 workflows (topology graph) | CanvasTemplate (graph) + MasterDetailTemplate (catalog) | Ready — `MapWorkspacePage` + `DSGraphCanvas` already exist |
| **3. Interfaces / Exposures** | **PARTIAL** | Skills as capability proxies, agents as exposure proxies | MasterDetailTemplate | Needs extension — no exposure-specific fixtures |
| **4. Context Pipeline** | **NO** | No mock data maps to compression/cache/thinking | — | Defer — no mock surface available |
| **5. Harness / Policies** | **PARTIAL** | Task governance diagnostics from mock task frontmatter | MasterDetailTemplate | Partial — `GovernanceOverviewPage` exists but policy-specific fixtures needed |
| **6. MCPs** | **PARTIAL** | Skills with triggers/workflows as MCP tool proxies | MasterDetailTemplate | Needs extension — no MCP server-specific fixtures |
| **7. Tools** | **PARTIAL** | Skills as tool proxies with risk classification | MasterDetailTemplate | Needs extension — no tool risk fixtures |
| **8. Security & Ops** | **YES** | 36 changelog entries as AuditEvent proxies | TimelineTemplate | Ready — `HistoryWorkspacePage` + `DSTimeline` already exist |
| **9. Execution** | **YES** | 22 tasks across 5 lanes (full lifecycle) | MasterDetailTemplate (lane board) | Ready — `OperateWorkspaceView` + `DSLaneBoard` already exist |
| **10. Plugins** | **NO** | No mock data maps to plugin manifests/lifecycle | — | Defer — no mock surface available |
| **11. Agentic** | **YES** | Agents + skills + workflows (full topology) | CanvasTemplate + MasterDetailTemplate | Ready — `MapWorkspacePage` covers agent/skill/workflow graph |
| **12. Settings** | **NO** | No mock config data | — | Defer — no mock surface available |

### 2.4 Cross-Reference: Existing Warp Prism Features → CyberCore Sections

| Existing Warp Prism Feature | Current Section | CyberCore Section(s) | Reusability |
|---------------------------|----------------|---------------------|-------------|
| `lib/features/overview/` | Overview | Dashboard | Direct reuse — `OverviewPage` becomes CyberCore Dashboard |
| `lib/features/map/` | Map | Providers & Routing, Agentic | Direct reuse — `MapWorkspacePage` becomes Registry |
| `lib/features/operate/` | Operate | Execution | Direct reuse — `OperateWorkspaceView` becomes Task Board |
| `lib/features/history/` | History | Security & Ops (Audit) | Direct reuse — `HistoryWorkspacePage` becomes Audit Trail |
| `lib/features/governance/` | Governance | Harness/Policies, Tools | Direct reuse — `GovernanceOverviewPage` becomes Governance |
| `lib/features/asset_detail/` | Asset Detail | All sections (detail drill-down) | Direct reuse — `AssetDetailView` + kind-specific views |
| `lib/features/workspace_snapshot/` | Workspace Snapshot | Dashboard (backend) | Reuse for unified workspace view |
| `lib/features/shell/` | Shell | All sections (app scaffold) | Direct reuse — `DSShell` becomes CyberCore app shell |

---

## 3. MVP Route List

### Selection Criteria

| Criterion | Weight | Application |
|-----------|--------|-------------|
| Mock corpus coverage | High | Route must be demonstrable with existing mock data |
| ADS component exercise | High | Route must exercise ≥3 unique ADS components |
| CyberCore domain mapping | Medium | Route must map to ≥1 CyberCore IA section with entity-level fidelity |
| Operational state coverage | Medium | Route must demonstrate ≥2 operational states |
| Implementation simplicity | Low | Simpler is better for first proof |

### Selected Routes (5)

#### Route 1: Dashboard

| Attribute | Value |
|-----------|-------|
| **Path** | `/dashboard` |
| **CyberCore IA Section** | §1 Dashboard |
| **Mock Source** | All 5 entity types aggregated (9 agents, 13 skills, 11 workflows, 22 tasks, 36 changelogs) |
| **ADS Components** | `DSShell` (organism), `DSTopbar` (organism), `DSMetricTile` (molecule), `DSStoryPanel` (organism), `DSGlassPanel` (atom), `DSBadge` (atom), `DSStatusDot` (atom), `MasterDetailTemplate` |
| **Operational States** | healthy, degraded, stale, pending, running, promoted (6 of 15) |
| **Mock Fixture Shape** | Aggregated workspace metrics (total counts, lane breakdown, proof state distribution, review score summary, governance warnings) |
| **CyberCore Entity Fidelity** | Maps to system health overview, active requests, recent events, quick stats (Feature 1307) |
| **Existing Implementation** | `lib/features/overview/overview_page.dart` + `OverviewProvider` + `OverviewMetrics` |
| **Rationale** | Highest value entry point. Proves metric tiles, story panels, and status components work for CyberCore's primary landing screen. Already implemented in Warp Prism — minimal new work. |

#### Route 2: Registry (Capabilities & Providers)

| Attribute | Value |
|-----------|-------|
| **Path** | `/registry` |
| **CyberCore IA Section** | §2 Providers & Routing, §11 Agentic |
| **Mock Source** | 9 agents (as provider proxies), 13 skills (as capability proxies), 11 workflows (as workflow definition proxies) |
| **ADS Components** | `DSGraphCanvas` (organism), `DSAssetCard` (molecule), `DSDetailInspector` (organism), `DSProvenancePill` (molecule), `DSFilterChipGroup` (molecule), `DSSearchBar` (molecule), `CanvasTemplate`, `MasterDetailTemplate` |
| **Operational States** | healthy, degraded, stale, promoted, unverified, archived (6 of 15) |
| **Mock Fixture Shape** | Agent frontmatter (name, model, mode, description, skills[], workflows[]), skill frontmatter (triggers, sub-skills, references, scripts), workflow frontmatter (kind, skills, agents) |
| **CyberCore Entity Fidelity** | Maps to capability list (Feature 1308), provider list (Feature 1309), route graph visualization (Feature 130D) |
| **Existing Implementation** | `lib/features/map/map_workspace_page.dart` + `MapWorkspaceProvider` + `DSGraphCanvas` |
| **Rationale** | Exercises graph visualization (unique to this route), provenance/canonicality display, and catalog+detail split. Maps directly to the most common admin CRUD pattern in CyberCore. Already implemented in Warp Prism. |

#### Route 3: Task Board (Execution)

| Attribute | Value |
|-----------|-------|
| **Path** | `/tasks` |
| **CyberCore IA Section** | §9 Execution |
| **Mock Source** | 22 tasks across 5 lanes (00-planning→04-completed) with full frontmatter (id, title, status, priority, owner, created, updated, skills[], workflows[], depends_on[], proof_state, review_score) |
| **ADS Components** | `DSLaneBoard` (organism), `DSTaskCard` (molecule), `DSDetailInspector` (organism), `DSEvidenceRow` (molecule), `DSStoryPanel` (organism), `DSFilterChipGroup` (molecule), `DSSearchBar` (molecule), `MasterDetailTemplate` |
| **Operational States** | pending, running, approved, rejected, promoted, archived, unverified, exposed, degraded (9 of 15) |
| **Mock Fixture Shape** | Task frontmatter with lane, priority, proof_state, review_score, depends_on — richest fixture in the corpus |
| **CyberCore Entity Fidelity** | Maps to execution envelope detail (Feature 1315), task A2A lifecycle (submitted→working→completed/failed), workflow execution (created→running→completed/failed) |
| **Existing Implementation** | `lib/features/operate/operate_workspace_view.dart` + `OperateWorkspaceViewModel` + `DSLaneBoard` |
| **Rationale** | Highest operational state coverage (9 of 15). Most ADS components exercised. Strongest CyberCore domain mapping. Best storytelling potential. Already implemented in Warp Prism. |

#### Route 4: Audit Trail (History)

| Attribute | Value |
|-----------|-------|
| **Path** | `/audit` |
| **CyberCore IA Section** | §8 Security & Ops (Audit) |
| **Mock Source** | 36 changelog entries with frontmatter (id, date, project, task, type, impact, skills[]) |
| **ADS Components** | `DSTimeline` (organism), `DSTimelineMarker` (molecule), `DSFilterChipGroup` (molecule), `DSStoryPanel` (organism), `DSDetailInspector` (organism), `TimelineTemplate` |
| **Operational States** | promoted, archived, stale, healthy, unverified (5 of 15) |
| **Mock Fixture Shape** | Changelog entry frontmatter with date, project, task, type (feature/fix/refactor/docs/chore), impact, skills |
| **CyberCore Entity Fidelity** | Maps to audit log viewer (Feature 130F), policy history (Feature 533), webhook delivery history |
| **Existing Implementation** | `lib/features/history/history_page.dart` + `HistoryController` |
| **Rationale** | Exercises timeline template (unique to this route). Demonstrates append-only audit pattern. Already implemented in Warp Prism. Lowest implementation cost. |

#### Route 5: Governance & Compliance

| Attribute | Value |
|-----------|-------|
| **Path** | `/governance` |
| **CyberCore IA Section** | §5 Harness/Policies, §7 Tools |
| **Mock Source** | Task frontmatter (proof_state, review_score, depends_on), skill frontmatter (triggers presence), workflow orphan detection, agent-skill cross-reference |
| **ADS Components** | `DSStoryPanel` (organism), `DSMetricTile` (molecule), `DSBadge` (atom), `DSChip` (molecule), `DSGlassPanel` (atom), `DSDetailInspector` (organism), `DSStatusDot` (atom), `MasterDetailTemplate` |
| **Operational States** | healthy, degraded, stale, exposed, unverified (5 of 15) |
| **Mock Fixture Shape** | Derived diagnostics: orphan workflows (no agent/skill references), skills with no triggers, tasks with missing proof, canonicality boundary summary, fan-in hotspots |
| **CyberCore Entity Fidelity** | Maps to policy compliance dashboard, tool risk classification, circuit breaker dashboard (Feature 1316), plugin health |
| **Existing Implementation** | `lib/features/governance/governance_overview_page.dart` + diagnostic widgets |
| **Rationale** | Proves diagnostic/governance storytelling works for CyberCore compliance patterns. Exercises story panel with risk levels. Already implemented in Warp Prism. |

### Route Summary

| # | Route | Path | CyberCore Section | Mock Entities | ADS Components | States | Status |
|---|-------|------|-------------------|---------------|---------------|--------|--------|
| 1 | Dashboard | `/dashboard` | §1 Dashboard | All 5 types | 8 components | 6 states | Ready |
| 2 | Registry | `/registry` | §2 Providers, §11 Agentic | Agents, Skills, Workflows | 8 components | 6 states | Ready |
| 3 | Task Board | `/tasks` | §9 Execution | Tasks (22) | 8 components | 9 states | Ready |
| 4 | Audit Trail | `/audit` | §8 Security & Ops | Changelog (36) | 6 components | 5 states | Ready |
| 5 | Governance | `/governance` | §5 Policies, §7 Tools | Derived diagnostics | 8 components | 5 states | Ready |

**Total unique ADS components exercised across all 5 routes**: 18 (all templates, all key organisms, all key molecules).
**Total operational states demonstrated across all 5 routes**: 12 of 15 (disabled, redacted, excluded not demonstrated by mock corpus).

---

## 4. Non-Goals

The first CyberCore Flutter app will **NOT**:

| # | Non-Goal | Rationale | When to Revisit |
|---|---------|-----------|-----------------|
| 1 | **Replace the existing Next.js frontend** | No evidence of need. No auth/SDK infrastructure in Flutter. No user request for migration. | Task 1111+ (after Flutter app proves value) |
| 2 | **Connect to live CyberCore backend APIs** | No generated Dart client SDK (blocked by Features 1300-1304). No Flutter auth implementation (blocked by Feature 1302). | Task 1109 (API contract inventory) → Task 1110+ (app shell with generated client) |
| 3 | **Implement write operations** (create, update, delete) | First wave is read-only observatory. Mutation requires auth, safety gates, and error handling infrastructure not yet built. | After auth and safety gates are documented |
| 4 | **Reimplement all CyberCore routes** | 12 IA sections × 40+ domain entities = unbounded scope. 5 routes prove the pattern. | Wave 2-3 tasks per EPIC-11 |
| 5 | **Add live SSE/WebSocket streaming** | No SSE endpoint contract stable (blocked by Feature 1303). Mock fixtures are sufficient for first proof. | After SSE endpoint stability (Feature 1303) |
| 6 | **Introduce SQLite or client-side durable state** | Per AGENTS.md product constraints. Mock fixtures are stateless YAML/markdown. | Only if PostgreSQL/Redis governance is authorized |
| 7 | **Build CyberCore-specific components into `warp_prism_ui`** | Per EPIC-11 guardrail: ADS package remains app-agnostic. CyberCore-specific state, routes, and DTOs belong in `apps/cybercore/`. | Never — this is a permanent boundary |
| 8 | **Add login/auth flows** | No auth infrastructure in Flutter yet. Feature 1306 (Login Screen) is blocked by Feature 1302 (Auth Endpoints Stable). | After auth endpoints are stable |
| 9 | **Support multimodal endpoints** (image gen, audio, video) | Mock corpus has no multimodal entity shapes. Backend support is in GAP catalog (Series 014). | Wave 3+ after core routes are proven |
| 10 | **Add real-time notifications/toasts** | Requires live backend events. Not needed for mock-backed observatory. | After SSE/live event infrastructure exists |

---

## 5. Migration Guardrails

These guardrails prevent accidental full-frontend replacement or scope creep:

### 5.1 Hard Boundaries

| # | Guardrail | Enforcement | Evidence |
|---|----------|-------------|----------|
| 1 | **No code in `cyberneticscore/apps/frontend/` may be modified** | Read-only reference. CyberCore Flutter work lives in `warp-prism/apps/cybercore/` only. | EPIC-11 guardrail: "Do not treat CyberCore pilot work as authorization to remove or rewrite the existing frontend." |
| 2 | **No generated API client until Feature 1300-1304 complete** | Flutter app uses mock fixtures from `warp-prism/assets/`. No HTTP client, no API base URL, no live endpoints. | `docs/reference/cybercore-backend-features/013-frontend-flutter.md` |
| 3 | **No mutation endpoints** | All CyberCore routes are read-only. No create/update/delete actions. No forms that submit to backend. | EPIC-11 guardrail: "First wave is read-only or fixed-fixture unless a later task explicitly opens mutation." |
| 4 | **ADS stays app-agnostic** | CyberCore-specific providers, state, DTOs, and routes live in `apps/cybercore/`, never in `packages/warp_prism_ui/`. | EPIC-11 guardrail |
| 5 | **Melos scaffold first** | CyberCore app cannot be created until Task 1107 (Melos migration) completes. App lives at `apps/cybercore/` inside the Melos workspace. | EPIC-11 dependency |

### 5.2 Incremental Expansion Rules

| # | Rule | Rationale |
|---|------|-----------|
| 1 | **One route at a time** | Each CyberCore route must be individually testable, documented, and reviewable before the next route begins. |
| 2 | **Fixture-first** | Each route must have its mock fixture contract defined before the route implementation begins. |
| 3 | **ADS reuse required** | Each route must use existing ADS components. New components go through ADS gap analysis and Wave 2-3 tasks. |
| 4 | **No CyberCore-specific atoms/molecules** | If a CyberCore route needs a component that doesn't exist in the ADS, it goes through the ADS gap analysis (Tasks 1112-1123). |
| 5 | **Route contract before implementation** | Each route needs: path, mock fixture schema, ADS component list, operational states demonstrated, CyberCore entity mapping. |
| 6 | **CI gate** | `melos run analyze` and `melos run test` must pass for both `packages/warp_prism_ui` and `apps/cybercore` on every change. |

### 5.3 Escalation Triggers

If any of the following occur, stop and create a planning/architecture task before continuing:

| Trigger | Action |
|---------|--------|
| A route needs live API data | Create API contract inventory task (Task 1109) |
| A route needs authentication | Create auth infrastructure task |
| A route needs a new ADS component | Route through ADS gap analysis (Tasks 1112-1123) |
| A route needs write operations | Create mutation safety gate task |
| Scope creep beyond 5 MVP routes | Re-evaluate with user/stakeholder before proceeding |

---

## 6. Fixture Requirements

### 6.1 Per-Route Fixture Specification

Each MVP route requires mock fixtures that map to CyberCore entity shapes. All fixtures derive from the existing mock corpus in `assets/mock_workspace/`.

#### Route 1: Dashboard

| Fixture | Source | Shape | CyberCore Entity |
|---------|--------|-------|-----------------|
| Agent count + health summary | `assets/mock_workspace/.agents/agents/` (9 files) | `{total: 9, healthy: N, degraded: N}` | AgentProfile summary |
| Skill count + trigger coverage | `assets/mock_workspace/.agents/skills/` (13 dirs) | `{total: 13, withTriggers: N, noTriggers: N}` | Capability summary |
| Workflow count + orphan status | `assets/mock_workspace/.agents/workflows/` (11 files) | `{total: 11, orphaned: N, active: N}` | WorkflowDefinition summary |
| Task lane breakdown | `assets/mock_workspace/docs/tasks/` (22 files) | `{planning: 3, open: 5, doing: 5, review: 4, completed: 5}` | WorkflowExecution summary |
| Changelog recent activity | `assets/mock_workspace/docs/changelog/` (36 files) | `{total: 36, lastWeek: N, types: {feature: N, fix: N, ...}}` | AuditEvent summary |
| Governance warnings | Derived from cross-referencing | `{orphanWorkflows: N, noTriggerSkills: N, unverifiedTasks: N}` | Policy compliance summary |

#### Route 2: Registry

| Fixture | Source | Shape | CyberCore Entity |
|---------|--------|-------|-----------------|
| Agent list | `assets/mock_workspace/.agents/agents/*.md` | `[{name, model, mode, description, skills[], workflows[]}]` | AgentProfile list |
| Skill list | `assets/mock_workspace/.agents/skills/*/SKILL.md` | `[{name, triggers[], subSkills[], references[], canonicality}]` | Capability list |
| Workflow list | `assets/mock_workspace/.agents/workflows/*.md` | `[{name, kind, skills[], agents[], triggers[]}]` | WorkflowDefinition list |
| Graph edges | Derived from agent→skill→workflow references | `[{source, target, kind}]` | RouteGraph (DAG) |
| Canonicality | Derived from file location (parent vs child vs generated) | `{parentCanonical: N, childLocal: N, generated: N, mock: N}` | Plugin lifecycle (registered→approved→enabled) |

#### Route 3: Task Board

| Fixture | Source | Shape | CyberCore Entity |
|---------|--------|-------|-----------------|
| Task list with full frontmatter | `assets/mock_workspace/docs/tasks/*/*.md` | `[{id, title, status, priority, owner, created, updated, skills[], workflows[], depends_on[], proof_state, review_score}]` | Task A2A (submitted→working→completed/failed) |
| Lane definitions | `assets/mock_workspace/manifest.yaml` task_lanes | `[{id, description}]` | ExecutionPlan stages |
| Task dependencies | Derived from `depends_on[]` fields | `[{taskId, blockedBy[]}]` | Execution dependency chain |
| Proof/verification state | Derived from `proof_state` field | `{none: N, partial: N, complete: N}` | Verification state |

#### Route 4: Audit Trail

| Fixture | Source | Shape | CyberCore Entity |
|---------|--------|-------|-----------------|
| Changelog entry list | `assets/mock_workspace/docs/changelog/*.md` | `[{id, date, project, task, type, impact, skills[], body}]` | AuditEvent (append-only, timestamped) |
| Impact paths | Derived from task→skill→workflow references | `[{changelogEntry, task, skills[], workflows[]}]` | Audit trail: who did what to which resource |
| Type distribution | Derived from `type` field | `{feature: N, fix: N, refactor: N, docs: N, chore: N}` | AuditEvent classification |

#### Route 5: Governance

| Fixture | Source | Shape | CyberCore Entity |
|---------|--------|-------|-----------------|
| Orphan workflows | Cross-reference: workflows not referenced by any agent or skill | `[{workflowName}]` | Policy violation |
| No-trigger skills | Cross-reference: skills with empty or missing triggers | `[{skillName}]` | Capability health issue |
| Unverified high-priority tasks | Cross-reference: tasks with `proof_state: none` + priority P0/P1 | `[{taskId, title, priority}]` | Exposure risk |
| Canonicality boundary | Cross-reference: agents/skills by location (parent vs child vs mock) | `{parentCanonical: N, childLocal: N, mock: N}` | Trust level distribution |
| Fan-in hotspots | Cross-reference: skills with ≥5 incoming references | `[{skillName, referenceCount}]` | Critical dependency |
| Review pressure | Cross-reference: tasks in review lane vs reviewer capacity | `{reviewQueue: N, avgReviewScore: N}` | Quality gate health |

### 6.2 Fixture File Location

All CyberCore mock fixtures should be organized under:

```
warp-prism/
├── assets/
│   ├── mock_workspace/          # Existing mock corpus (source of truth)
│   │   ├── .agents/
│   │   ├── docs/
│   │   └── manifest.yaml
│   └── cybercore_fixtures/      # NEW: CyberCore-specific derived fixtures
│       ├── dashboard_summary.json
│       ├── registry_agents.json
│       ├── registry_skills.json
│       ├── registry_workflows.json
│       ├── registry_graph_edges.json
│       ├── task_board.json
│       ├── audit_trail.json
│       └── governance_diagnostics.json
```

> **Note**: `cybercore_fixtures/` files are **derived** from `mock_workspace/` — they are precomputed projections of the mock corpus into CyberCore entity shapes. The source of truth remains `mock_workspace/`. When the mock corpus changes, the derived fixtures must be regenerated.

### 6.3 Fixture Contract

Each fixture file must:
1. Be valid JSON with a top-level schema version field.
2. Reference the source mock entity IDs (not invented IDs).
3. Include all fields required by the CyberCore entity shape it prototypes.
4. Be parseable by a Dart model class in `apps/cybercore/lib/data/fixtures/`.
5. Have a corresponding fixture loader test that validates the contract.

---

## 7. Implementation Sequencing

### 7.1 Wave 1 (This Task + Dependencies)

| Task | Deliverable | Depends On |
|------|------------|------------|
| **1107** | Melos monorepo scaffold (`apps/cybercore/` exists) | None |
| **1108** | This document (scope + route parity) | Task 1102, EPIC-11 |
| **1109** | API/data contract inventory for read-only surfaces | This task |
| **1110** | CyberCore fixture-backed app shell MVP | Tasks 1107, 1108, 1109 |

### 7.2 Route Implementation Order

| Order | Route | Rationale |
|-------|-------|-----------|
| 1 | **Dashboard** | Simplest route. Aggregates existing data. Proves app shell. |
| 2 | **Registry** | Exercises graph canvas. Proves catalog+detail split. |
| 3 | **Task Board** | Most operational states. Proves lane board for CyberCore. |
| 4 | **Audit Trail** | Exercises timeline. Proves append-only audit pattern. |
| 5 | **Governance** | Exercises diagnostics. Proves compliance storytelling. |

### 7.3 Per-Route Checklist

Each route implementation must complete:

- [ ] Fixture file exists in `assets/cybercore_fixtures/`
- [ ] Fixture loader test passes
- [ ] Route renders from fixture data (widget test)
- [ ] Route uses only existing ADS components
- [ ] Operational states documented and demonstrated
- [ ] CyberCore entity mapping documented
- [ ] No live API calls or HTTP clients

---

## 8. Risk Assessment

| Risk | Severity | Mitigation |
|------|----------|------------|
| Mock corpus does not cover all CyberCore entity shapes | Medium | Focus on the 5 routes where mock data has highest fidelity. Defer routes that need MCP servers, credentials, or plugin fixtures. |
| Scope creep into live API integration | High | Migration guardrails §5.1 enforce mock-only until Features 1300-1304 complete. |
| CyberCore-specific state leaks into ADS package | Medium | EPIC-11 guardrail: all CyberCore-specific code in `apps/cybercore/`. CI gate enforces. |
| Parent frontend team perceives this as replacement initiative | Low | Scope decision §1 explicitly states: read-only mirror, not migration. Document this in every CyberCore task. |
| Fixture drift from mock corpus | Low | §6.2 states fixtures are derived from `mock_workspace/`. Regeneration script should be created in Task 1110. |

---

## 9. Source Evidence

| Source | Path | Relevance |
|--------|------|-----------|
| EPIC-11 | `docs/tasks/00-planning/EPIC-11-warp-prism-cybercore-frontend.md` | Epic scope, guardrails, wave definitions |
| CyberCore Backend Features | `docs/reference/cybercore-backend-features/` (35 files, ~1,336 features) | Backend entity inventory, sidebar taxonomy, feature priorities |
| Flutter Feature Reference | `docs/reference/cybercore-backend-features/013-frontend-flutter.md` | Blocked features, required prerequisites (1300-1323) |
| Domain-to-UI Mapping | `docs/reports/cybercore-domain-ui-mapping-20260608.md` | 40+ entities → UI component mapping, 11 state machines |
| Component Inventory | `docs/design/component-inventory.md` | Full ADS inventory (38 DS files, 62 feature files, 7 model files) |
| Pilot Surface Matrix | `docs/design/cybercore-pilot-surface-matrix.md` | Candidate A (Task Board, 10 states), Candidate B (Registry, 7 states) |
| Operational State Vocabulary | `docs/design/operational-state-vocabulary.md` | 15 operational states, 11 CyberCore state machines covered |
| Mock Workspace Manifest | `assets/mock_workspace/manifest.yaml` | 9 agents, 13 skills, 11 workflows, 22 tasks, 36 changelogs |
| Mock Workspace Corpus | `assets/mock_workspace/` | Full mock data (agents, skills, workflows, tasks, changelogs) |
| ADS Gap Analysis | `docs/reports/ads-gap-analysis-20260608.md` | 8 present, 6 partial, 6 missing components |
| Warp Prism AGENTS.md | `AGENTS.md` | Product constraints, read-only mandate, mock-first |
