# Feature Catalog: Capability Registry & Exposures

> **Series**: 300
> **EPICs**: EPIC-300, EPIC-310, EPIC-320, EPIC-330, EPIC-340, EPIC-350, EPIC-360
> **Tasks**: 0146-0180
> **Total Features**: 35

## Features

### Capability Model & CRUD (300-309)

| # | Name | Description | Priority |
|---|------|-------------|----------|
| 300 | Capability Repository | Implement `CapabilityRepository` — Create, GetByID, GetByName, Update, Delete, List with PostgreSQL; support filtering by kind, provider, status | P0 |
| 301 | Capability Validation | Validate capability on create/update: required fields, kind-specific validation, unique name constraint, metadata schema | P0 |
| 302 | Capability CRUD Use Cases | Implement `RegisterCapability`, `UpdateCapability`, `DeregisterCapability`, `GetCapability`, `ListCapabilities` use cases | P0 |
| 303 | Capability Status Lifecycle | Implement capability status transitions: `draft` → `active` → `deprecated` → `removed`; validate transitions | P0 |
| 304 | Capability Versioning | Support capability versioning: version field, query specific version, list versions, deprecation of old versions | P1 |
| 305 | Capability Metadata Schema | Define per-kind metadata schemas: LLM models (context window, pricing), MCP tools (input/output schema), search APIs (regions) | P0 |
| 306 | CapabilitySet CRUD | Implement `CapabilitySet` CRUD: create named set, add/remove capabilities, list sets, validate membership | P0 |
| 307 | CapabilitySet Validation | Validate capability set: no duplicate capabilities, all capabilities exist and are active, kind compatibility checks | P0 |
| 308 | Capability Search | Implement capability search: full-text search on name/description, filter by kind/provider/status, paginated results | P1 |
| 309 | Capability Import/Export | Support bulk import/export of capabilities as JSON: for migration, backup, and cross-environment promotion | P2 |

### Provider Registry (310-319)

| # | Name | Description | Priority |
|---|------|-------------|----------|
| 310 | Provider Domain Model | Define `Provider` entity: ID, name, kind (LLM, search, MCP, custom), base URL, auth config, status, health, metadata | P0 |
| 311 | Provider Repository | Implement `ProviderRepository` — Create, GetByID, GetByName, Update, Delete, List with PostgreSQL | P0 |
| 312 | Provider CRUD Use Cases | Implement `RegisterProvider`, `UpdateProvider`, `DeregisterProvider`, `ListProviders` use cases | P0 |
| 313 | Provider Health Tracking | Track provider health: last check time, status (healthy/degraded/down), error count, response latency p50/p99 | P0 |
| 314 | Provider Health Probe Worker | Background worker that periodically probes provider health endpoints; updates status in database and Redis | P0 |
| 315 | Provider Credential Linking | Link providers to credentials: each provider has associated credential grants for authentication | P0 |
| 316 | Provider Capability Discovery | Auto-discover capabilities from provider API (e.g., OpenAI `/v1/models` endpoint) and register as capabilities | P1 |
| 317 | Provider Rate Limit Awareness | Track provider-specific rate limits: headers (`X-RateLimit-*`), back-off on 429, per-provider quotas | P0 |
| 318 | Provider Priority & Weight | Assign priority and weight to providers for load balancing across providers offering same capability | P0 |
| 319 | Provider Tags & Groups | Tag providers with metadata (region, cost-tier, compliance); group for routing decisions | P1 |

### Model Catalog (320-324)

| # | Name | Description | Priority |
|---|------|-------------|----------|
| 320 | Model Catalog Repository | Implement `ModelCatalogRepository` — store and query LLM model metadata: context window, pricing, capabilities, modalities | P0 |
| 321 | Model Catalog Sync Worker | Background worker that syncs model catalogs from providers: fetch available models, update metadata, detect new/removed models | P1 |
| 322 | Model Alias System | Support model aliases: `gpt-4` → `gpt-4-0125-preview`, `claude-3` → `claude-3-sonnet-20240229`; configurable per environment | P0 |
| 323 | Model Pricing Tracking | Track per-model pricing: input/output token costs, per-request costs; used for budget enforcement and cost reporting | P1 |
| 324 | Model Capability Matrix | Track model capabilities: function calling, vision, JSON mode, streaming, system prompts; used by planner for compatibility | P0 |

### Tool Catalog (325-329)

| # | Name | Description | Priority |
|---|------|-------------|----------|
| 325 | Tool Catalog Repository | Implement `ToolCatalogRepository` — store MCP tool metadata: name, description, input/output schema, provider, namespace | P0 |
| 326 | Tool Namespace Mapping | Map MCP server tools into namespaced tool names: `server_name.tool_name` to prevent collisions across servers | P0 |
| 327 | Tool Schema Validation | Validate tool input/output schemas on registration: JSON Schema compliance, required fields, type checking | P0 |
| 328 | Tool Discovery Endpoint | Expose tool discovery endpoint: list available tools with schemas, filterable by namespace/capability set | P0 |
| 329 | Tool Status Tracking | Track tool availability: healthy/degraded/unavailable based on underlying MCP server status | P0 |

### Exposure System (330-344)

| # | Name | Description | Priority |
|---|------|-------------|----------|
| 330 | Exposure Repository | Implement `ExposureRepository` — Create, GetByID, GetByPath, Update, Delete, List with PostgreSQL | P0 |
| 331 | Exposure CRUD Use Cases | Implement `CreateExposure`, `UpdateExposure`, `DeleteExposure`, `ListExposures` use cases | P0 |
| 332 | Exposure Validation | Validate exposure on create/update: target exists, kind-specific config valid, auth requirements set, policy bound | P0 |
| 333 | Exposure Public Guard | Require `explicit_public=true` flag and emit warning event for public exposures (deny-by-default) | P0 |
| 334 | Exposure Auth Requirements | Define per-exposure auth requirements: API key required, session required, specific scopes, IP restrictions | P0 |
| 335 | Exposure Policy Binding | Bind one or more policies to an exposure; all policies evaluated on access (AND semantics by default) | P0 |
| 336 | Exposure Rate Limiting | Per-exposure rate limit configuration: requests/minute, tokens/day, concurrent; independent of per-key limits | P0 |
| 337 | Exposure Monitoring | Track per-exposure metrics: request count, error rate, latency p50/p99, token usage, cost | P1 |
| 338 | Exposure Versioning | Support exposure versioning: `/v1/...`, `/v2/...`; route to different capability sets per version | P2 |
| 339 | Exposure Status Lifecycle | Implement exposure status transitions: `draft` → `active` → `deprecated` → `removed`; emit events on transition | P0 |
| 340 | HTTP Path Exposure Config | Configure HTTP path exposures: path prefix, methods, request/response transforms, CORS overrides | P0 |
| 341 | MCP Surface Exposure Config | Configure MCP surface exposures: tool filter, resource filter, prompt filter, namespace prefix | P0 |
| 342 | OpenAPI Exposure Config | Configure OpenAPI exposures: generated spec, operation IDs, security schemes, tag mapping | P1 |
| 343 | A2A Surface Exposure Config | Configure A2A surface exposures: agent card, skill declarations, protocol version | P2 |
| 344 | Exposure Dependency Graph | Track exposure dependencies: which capabilities, credentials, policies, route graphs are required; validate on changes | P1 |

### Descriptor Compilation (350-354)

| # | Name | Description | Priority |
|---|------|-------------|----------|
| 350 | Descriptor Compiler | Implement descriptor compiler: resolve exposure → capabilities, policies, credentials, routing into single `EndpointDescriptor` | P0 |
| 351 | Descriptor Caching | Cache compiled descriptors in Redis with versioned keys; invalidate on any dependency change via outbox events | P0 |
| 352 | Descriptor Local Cache | Implement local in-memory cache (LRU) for hot descriptors with TTL and Redis-based invalidation | P0 |
| 353 | Descriptor Compilation Worker | Background worker that recompiles descriptors when outbox events indicate dependency changes | P0 |
| 354 | Descriptor Version Tracking | Track descriptor version: increment on recompilation, include in execution envelope for audit correlation | P0 |

### Capability Discovery Lifecycle (360-364)

| # | Name | Description | Priority |
|---|------|-------------|----------|
| 360 | Admin Capability Endpoints | Implement admin REST endpoints: CRUD for capabilities, capability sets, providers, exposures | P0 |
| 361 | Admin Provider Endpoints | Implement admin REST endpoints for provider management: register, update, health status, capability discovery trigger | P0 |
| 362 | Admin Exposure Endpoints | Implement admin REST endpoints for exposure management: create, update, activate, deprecate, delete | P0 |
| 363 | Admin Descriptor Endpoints | Implement admin endpoints for descriptor inspection: view compiled descriptor, trigger recompilation, view version history | P1 |
| 364 | Capability Change Notifications | Emit outbox events on capability/provider/exposure changes; trigger descriptor recompilation and cache invalidation | P0 |
