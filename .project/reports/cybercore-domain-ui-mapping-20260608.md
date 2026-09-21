# CyberCore Domain → Frontend UI Mapping

> **Date**: 2026-06-08
> **Author**: architects (subagent)
> **Source**: `~/working/go/docs/features/` (35 files, ~1,336 features)
> **Purpose**: Map backend domain entities to Flutter frontend components, screens, and ADS patterns

---

## Core Domain Entities (40+)

### Entity → UI Component Mapping

| Entity | Key Attributes | States/Lifecycle | UI Components Needed |
|--------|---------------|-----------------|---------------------|
| **Capability** | name, kind, version, provider, status | draft→active→deprecated→removed | List table, detail page, status badge, kind icon |
| **CapabilitySet** | name, capabilities[] | same as Capability | List with member counts, multi-select picker |
| **Provider** | name, kind, URL, auth, health | healthy/degraded/down | Health card, connectivity test wizard, health dashboard |
| **Exposure** | name, kind, target, auth, policies | draft→active→deprecated→removed | List with kind badges, kind-specific config forms |
| **RouteGraph** | DAG of route nodes, version | draft→active→deprecated→removed | **Visual DAG editor**, DOT export, simulation |
| **RouteNode** | type (Primary/Fallback/LoadBalance/Hedge/Retry/Condition/Transform) | N/A | Node card with type icon, config panel |
| **Policy** | rules[], subject/resource bindings, priority | draft→active→archived | **DSL editor with syntax highlighting**, dry run |
| **Credential** | provider, encrypted payload, rotation | active→rotating→expired→revoked | Masked list, grant mapping, rotation schedule |
| **CredentialGrant** | credential↔capability, scope | active→revoked | Scope selector, usage tracking |
| **CredentialLease** | subject, acquired, expires | active→released/expired | Lease table with expiry warnings |
| **ExecutionEnvelope** | full request pipeline metadata | stored/immutable | **Timeline/waterfall view**, cost breakdown |
| **User** | email, role (admin/operator/viewer) | active→suspended→deleted | CRUD table, role selector, session management |
| **Session** | user, token hash, IP, expires | active→expired→revoked | Session list with revoke action |
| **APIKeyRecord** | prefix, scopes, rate limit | active→expired→revoked | Create (show once), list (prefix only), scope picker |
| **AuditEvent** | timestamp, subject, action, resource, decision | append-only | **Searchable paginated table**, time/subject filters |
| **MCPServer** | connection info, transport, health | registered→active→unavailable | Health card, tool catalog, sync trigger |
| **MCPTool** | name, schema, namespace, server origin | healthy/degraded/unavailable | Tool browser with risk badges |
| **Plugin** | manifest, kind, capabilities, status | registered→approved→enabled→disabled→removed | **Approval workflow**, manifest viewer |
| **WebhookEndpoint** | URL, event subscriptions, retry | active→paused→disabled | Delivery history, test delivery |
| **Hook** | trigger point, conditions, actions | enabled/disabled | Trigger+condition+action builder |
| **WorkflowDefinition** | steps[], triggers, YAML source | created→running→completed/failed/cancelled | **DAG editor**, YAML/visual editor |
| **Memory** | subject, key, content, embedding, tags | active→decayed→expired | Semantic search, lifecycle badges |
| **AgentProfile** | agent card, owner, visibility | N/A | Agent card viewer |
| **CircuitBreaker** | state per provider, thresholds | closed→open→half-open | **State diagram grid**, history timeline |
| **RateLimit** | per-subject, sliding window | transient (Redis) | Progress bars with reset timers |
| **Quota** | token/cost limits, daily/monthly | resets periodically | Gauge, budget allocation panel |

### 11 State Machines Needing Visual Representation

1. Capability/Exposure lifecycle: draft→active→deprecated→removed
2. Circuit breaker: closed→open→half-open→probe
3. Plugin lifecycle: registered→approved→enabled→disabled→removed
4. Policy lifecycle: draft→active→archived
5. Route graph lifecycle: draft→active→deprecated→removed
6. Credential lifecycle: active→rotating→expired/revoked
7. Session lifecycle: active→expired/revoked
8. Task lifecycle (A2A): submitted→working→completed/failed/cancelled
9. Workflow execution: created→running→completed/failed/cancelled
10. Memory lifecycle: active→decayed→expired
11. Tool risk classification: low→medium→high→critical

---

## Screen Candidates by CyberCore IA Section

### 1. Dashboard
- System health overview, active requests, recent events, quick stats
- Components: `PrismHealthDashboard`, `PrismMetricCard`, `PrismEventStream`

### 2. Providers & Routing
- Providers CRUD, RouteGraphs visual editor, Circuit breaker dashboard
- Components: `PrismDataTable`, `PrismDAGEditor`, `PrismCircuitBreakerGrid`

### 3. Interfaces
- Exposures CRUD, MCP surface config, OpenAPI spec viewer, A2A agent cards
- Components: `PrismDataTable`, `PrismDetailPage`, `PrismBadge`

### 4. Context Pipeline
- Compression config, Cache management, Thinking budget, Vision bridge
- Components: `PrismCompressionMonitor`, `PrismCacheInspector`

### 5. Harness
- Policies CRUD, DSL editor, Guardrails, Tool calling policy
- Components: `PrismPolicyEditor`, `PrismRiskDashboard`

### 6. MCPs
- MCP Server CRUD, Tool catalog, Catalog sync, Health monitoring
- Components: `PrismDataTable`, `PrismHealthCard`, tool browser

### 7. Tools
- Tool catalog, Risk classification, Tool quality rubric
- Components: `PrismToolRiskRow`, `PrismRiskDashboard`

### 8. Security & Ops
- Users, Sessions, API Keys, Credentials, Grants, Audit log
- Components: `PrismDataTable`, `PrismCredentialVault`, `PrismSecretMask`

### 9. Help
- Docs/glossary, Runbooks, API docs

### 10. Settings
- Config overview, Trust mode, Feature flags, Import/Export, Bootstrap wizard
- Components: `PrismWizardPage`, config forms

### Additional Screens (Not in 10-Section IA)

| Screen | Feature Source | Notes |
|--------|---------------|-------|
| Memory Management | 1800-1829 | Memories CRUD, vector search, lifecycle |
| Agent Profiles / A2A | 2210-2229 | Agent cards, skills registry, task management |
| Webhooks | 1900-1924 | Endpoint CRUD, delivery history |
| Hooks System | 2310-2319 | Hook CRUD by trigger point |
| Workflow Engine | 2300-2309 | Workflow def CRUD, DAG editor, execution history |
| Playground | 106-013 | Prompt testing with compare mode (4 columns) |
| Plugins Marketplace | 1200-1284 | Plugin discovery, approval, health |
| Batch Processing | 1450-1459 | Batch job status, results |

---

## ADS Component Recommendations

### Atoms (Primitives)

| Component | States |
|-----------|--------|
| **PrismBadge** | active, deprecated, removed, draft, healthy, degraded, down, open, closed, half-open |
| **PrismChip** | selected, unselected, disabled |
| **PrismLifecycleIndicator** | Position on lifecycle rail |
| **PrismRiskBadge** | low (green), medium (yellow), high (orange), critical (red) |
| **PrismHealthDot** | healthy (green pulse), unhealthy (red pulse), unknown (gray) |
| **PrismSecretMask** | masked (•••••), revealed (text) |
| **PrismTokenCounter** | Number + unit (tokens/$/ms) |
| **PrismProgressBar** | Fill %, color threshold, reset timer |
| **PrismCircuitStateIcon** | closed (green), open (red), half-open (yellow) |
| **PrismSkeleton** | text, card, table row, graph variants |
| **PrismEmptyState** | Icon + message + CTA |
| **PrismErrorState** | Error icon + message + retry |
| **PrismDegradedBanner** | Banner with cause + fallback info |

### Molecules (Composed)

| Component | Composition |
|-----------|------------|
| **PrismStatusRow** | HealthDot + Name + Badge + Actions |
| **PrismMetricCard** | Label + Value + Trend sparkline + Unit |
| **PrismFormField** | Label + Input + Validation + Help text |
| **PrismSearchBar** | Text input + filter chips + clear |
| **PrismQuotaGauge** | Gauge + percentage + threshold markers |
| **PrismTimestamp** | Relative + absolute time with hover tooltip |
| **PrismSecretField** | Input + Generate + Copy + Show/Hide |
| **PrismScopeSelector** | Checkbox tree of scopes |
| **PrismPolicyRuleCard** | Subject + Resource + Action + Conditions |
| **PrismRouteNodeCard** | Type icon + Label + Config summary + Connection points |
| **PrismProviderHealthCard** | Name + Status + Latency p50/p99 + Error rate + Circuit state |
| **PrismAuditEventRow** | Timestamp + Subject + Action + Resource + Decision badge |

### Organisms (Complex)

| Component | Data Requirements |
|-----------|------------------|
| **PrismDataTable** | Sortable, filterable, paginated, column config |
| **PrismDAGEditor** | Nodes[], edges[], drag-drop, zoom, config panel |
| **PrismTimeline** | Span tree with timing, color by phase |
| **PrismEventStream** | SSE source, type filters, pause/resume, auto-scroll |
| **PrismHealthDashboard** | Health cards grid, overall status |
| **PrismUsageChart** | Time-series, time range selector, drill-down |
| **PrismPolicyEditor** | DSL text, syntax validation, test evaluation |
| **PrismCredentialVault** | Credential list (masked) + Grants + Rotation |
| **PrismCircuitBreakerGrid** | Per-provider state with history sparklines |
| **PrismRiskDashboard** | Distribution chart + alert list + family breakdown |
| **PrismSimulationPanel** | Old vs New comparison |
| **PrismPluginApproval** | Manifest viewer + Security checklist + Approve/Reject |
| **PrismCompressionMonitor** | Before/after tokens + savings % |
| **PrismCacheInspector** | L1/L2 hit rates + invalidation controls |
| **PrismMemoryBrowser** | Semantic search + lifecycle + relevance scores |
| **PrismDependencyGraph** | Entity relationships visualization |

### Page Templates

| Template | Layout | Usage |
|----------|--------|-------|
| **PrismListPage** | Sidebar filters + Data table + Bulk actions | Users, Capabilities, Providers, etc. |
| **PrismDetailPage** | Header + Status + Tabs + Related entities | Provider detail, Capability detail, etc. |
| **PrismDashboardPage** | Card grid + Time range + Auto-refresh | System/Usage/Security dashboards |
| **PrismFormPage** | Stepper/sections + Validation + Preview | Create/edit any entity |
| **PrismStreamPage** | Filter bar + Streaming list + Pause/Resume | Live events, Audit stream |
| **PrismGraphPage** | Toolbar + Canvas + Property panel + Minimap | Route graph editor, Workflow editor |
| **PrismComparePage** | Split view + Diff + Metric deltas | Route simulation, Config diff |
| **PrismWizardPage** | Step indicator + Form + Review + Confirm | Bootstrap, Plugin registration |

---

## Coverage vs Warp Prism Areas

| Warp Prism Area | CyberCore Entities | Feature Series |
|----------------|-------------------|---------------|
| **Map** (agent/skill/workflow/task graphs) | RouteGraphs, WorkflowDefs, DependencyGraph, CapabilitySets, AgentCards | 600-609, 2300-2309, 2200-2229 |
| **Operate** (task board/execution) | ExecutionPlans, ExecutionResults, ExecutionEnvelopes, CredentialLeases, Hooks | 152-154, 840-849, 430-439, 2310-2329 |
| **History** (changelog/timeline) | AuditEvents, ExecutionEnvelope history, PolicyHistory, WebhookDeliveries | 830-839, 840-849, 533, 1917 |
| **Governance** (stale/orphan/canonicality) | Policies, ToolRiskLevels, Capability lifecycle, Plugin lifecycle, Credential expiry | 500-545, 2400-2424, 303, 1203 |
