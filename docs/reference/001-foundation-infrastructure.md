# Feature Catalog: Foundation & Infrastructure

> **Series**: 100
> **EPICs**: EPIC-100, EPIC-110, EPIC-120, EPIC-150, EPIC-160, EPIC-170, EPIC-180, EPIC-190, EPIC-195, EPIC-1A0, EPIC-1B0, EPIC-1C0, EPIC-1D0
> **Tasks**: 0001-0095
> **Total Features**: 95

## Features

### Project Bootstrap (101-109)

| # | Name | Description | Priority |
|---|------|-------------|----------|
| 101 | Go Module Init | Initialize `go.mod` with module path `github.com/cybernetics-core/cybercore`, set Go version, create root `.gitignore` | P0 |
| 102 | Binary: cybercore-api | Create `cmd/cybercore-api/main.go` — thin entry point that loads config, builds app, starts HTTP server | P0 |
| 103 | Binary: cybercore-worker | Create `cmd/cybercore-worker/main.go` — background processing entry point for outbox, catalog sync, health probes | P0 |
| 104 | Binary: cybercore-runner | Create `cmd/cybercore-runner/main.go` — sandboxed MCP STDIO execution entry point, separate trust boundary | P0 |
| 105 | Binary: cybercore-migrate | Create `cmd/cybercore-migrate/main.go` — database migration runner entry point | P0 |
| 106 | Binary: cybercore-cli | Create `cmd/cybercore-cli/main.go` — operational CLI entry point for diagnostics, key gen, config export | P1 |
| 107 | Version Embedding | Embed build version, commit hash, and build time via `-ldflags` at compile time; expose via `/version` endpoint and CLI `--version` | P1 |
| 108 | Makefile | Create `Makefile` with targets: `build`, `test`, `lint`, `migrate`, `docker-build`, `docker-up`, `clean`, `generate` | P1 |
| 109 | Project Directory Scaffold | Create all `internal/` subdirectories matching the canonical project structure from AGENTS.md | P0 |

### Configuration (110-119)

| # | Name | Description | Priority |
|---|------|-------------|----------|
| 110 | Config Loading | Implement `internal/config/` package with environment variable loading, struct tags, and validation | P0 |
| 111 | Server Config | Define `ServerConfig` struct: listen address, port, read/write timeouts, max header bytes, TLS cert/key paths | P0 |
| 112 | Database Config | Define `DatabaseConfig` struct: DSN, pool min/max connections, connection lifetime, statement cache, SSL mode | P0 |
| 113 | Redis Config | Define `RedisConfig` struct: address, password, DB number, pool size, dial/read/write timeouts, TLS config | P0 |
| 114 | Log Config | Define `LogConfig` struct: level, format (json/text), output (stdout/file), caller info, sampling rate | P0 |
| 115 | YAML Override | Support optional YAML config file that overrides environment variables; file path set via `CONFIG_FILE` env var | P1 |
| 116 | Redacted String Type | Implement `RedactedString` type that masks value in `String()`, `MarshalJSON()`, and `MarshalText()` — never leaks secrets in logs or API responses | P0 |
| 117 | Trust Mode | Define `TrustMode` enum (`strict`, `permissive`, `development`) controlling security behavior: strict = fail-closed, development = relaxed validation | P0 |
| 118 | Fail-Fast Validation | Config validation at startup: required fields, port ranges, URL formats, enum values — fail immediately with clear error messages | P0 |
| 119 | Feature Flags | Implement feature flag system: static flags from config, per-flag enable/disable, used to gate incomplete features behind flags | P1 |

### Domain Types (120-144)

| # | Name | Description | Priority |
|---|------|-------------|----------|
| 120 | Capability Type | Define `Capability` domain type with ID, name, kind, version, provider, metadata, status, timestamps | P0 |
| 121 | Capability Kind: LLM Model | Define `KindLLMModel` — represents a language model capability (e.g., GPT-4, Claude 3) | P0 |
| 122 | Capability Kind: MCP Tool | Define `KindMCPTool` — represents an MCP-exposed tool capability | P0 |
| 123 | Capability Kind: Search API | Define `KindSearchAPI` — represents a search provider capability (Brave, DuckDuckGo) | P0 |
| 124 | Capability Kind: Embedding | Define `KindEmbedding` — represents an embedding model capability | P1 |
| 125 | Capability Kind: Reranker | Define `KindReranker` — represents a reranking model capability | P2 |
| 126 | Capability Kind: Image Gen | Define `KindImageGen` — represents an image generation capability | P2 |
| 127 | Capability Kind: Audio | Define `KindAudio` — represents an audio/speech capability (TTS, STT) | P2 |
| 128 | Capability Kind: Code Exec | Define `KindCodeExec` — represents a code execution sandbox capability | P2 |
| 129 | Capability Kind: Workflow | Define `KindWorkflow` — represents a composite workflow capability | P2 |
| 12A | Capability Kind: Custom | Define `KindCustom` — represents a user-defined or plugin-provided capability | P2 |
| 12B | Capability Kind: Gateway | Define `KindGateway` — represents a gateway/proxy capability for external API routing | P2 |
| 130 | CapabilitySet Type | Define `CapabilitySet` — named group of capabilities with metadata, used for exposure and policy binding | P0 |
| 131 | Exposure Type | Define `Exposure` domain type with ID, name, kind, target (CapabilitySet or RouteGraph), surface config, auth requirements, policy bindings | P0 |
| 132 | Exposure Kind: HTTP Path | Define `ExposureKindHTTPPath` — exposes capabilities through an HTTP REST endpoint | P0 |
| 133 | Exposure Kind: MCP Surface | Define `ExposureKindMCPSurface` — exposes capabilities through MCP protocol (tools, resources, prompts) | P0 |
| 134 | Exposure Kind: OpenAPI Tool | Define `ExposureKindOpenAPITool` — exposes capabilities as OpenAPI-described tool endpoints | P1 |
| 135 | Exposure Kind: A2A Surface | Define `ExposureKindA2ASurface` — exposes capabilities through Agent-to-Agent protocol | P2 |
| 136 | Exposure Kind: WebSocket | Define `ExposureKindWebSocket` — exposes capabilities through WebSocket streaming | P2 |
| 137 | Exposure Kind: gRPC | Define `ExposureKindGRPC` — exposes capabilities through gRPC protocol | P2 |
| 138 | Workload Type | Define `Workload` domain type representing an incoming request classified for routing | P0 |
| 139 | Workload Kind: Chat Completion | Define `WorkloadKindChatCompletion` — standard chat completion request | P0 |
| 13A | Workload Kind: Completion | Define `WorkloadKindCompletion` — legacy text completion request | P1 |
| 13B | Workload Kind: Embedding | Define `WorkloadKindEmbedding` — embedding generation request | P1 |
| 13C | Workload Kind: Image Gen | Define `WorkloadKindImageGen` — image generation request | P2 |
| 13D | Workload Kind: Audio | Define `WorkloadKindAudio` — audio processing request | P2 |
| 13E | Workload Kind: Tool Call | Define `WorkloadKindToolCall` — MCP or function tool invocation request | P0 |
| 13F | Workload Kind: Search | Define `WorkloadKindSearch` — search query request | P1 |
| 140 | RouteGraph Type | Define `RouteGraph` domain type — DAG of route nodes defining decision, fallback, and load-balance paths | P0 |
| 141 | Route Node: Primary | Define `RouteNodePrimary` — selects primary capability candidate | P0 |
| 142 | Route Node: Fallback | Define `RouteNodeFallback` — ordered fallback chain on failure | P0 |
| 143 | Route Node: LoadBalance | Define `RouteNodeLoadBalance` — distributes across capabilities (weighted round-robin, least-connections) | P0 |
| 144 | Route Node: Hedge | Define `RouteNodeHedge` — parallel speculative execution, return fastest success | P1 |
| 145 | Route Node: Retry | Define `RouteNodeRetry` — retry with backoff on transient failure | P0 |
| 146 | Route Node: Condition | Define `RouteNodeCondition` — conditional branching based on workload attributes or policy | P1 |
| 147 | Route Node: Transform | Define `RouteNodeTransform` — transforms request/response between capabilities | P2 |
| 148 | Policy Type | Define `Policy` domain type with ID, name, rules, subject bindings, resource bindings, version, status | P0 |
| 149 | Policy Decision: Allow | Define `DecisionAllow` — explicitly grants access to a capability or exposure | P0 |
| 14A | Policy Decision: Deny | Define `DecisionDeny` — explicitly denies access with reason | P0 |
| 14B | Policy Decision: RateLimit | Define `DecisionRateLimit` — allows access subject to rate/quota constraints | P0 |
| 14C | Policy Decision: Audit | Define `DecisionAudit` — allows access but flags for detailed audit logging | P1 |
| 14D | Policy Decision: Warn | Define `DecisionWarn` — allows access but emits warning (e.g., approaching quota) | P1 |
| 150 | Credential Type | Define `Credential` domain type with ID, name, provider, encrypted payload, rotation config, status, timestamps | P0 |
| 151 | Credential Grant Type | Define `CredentialGrant` — maps a credential to specific capabilities with scope restrictions | P0 |
| 152 | Execution Plan Type | Define `ExecutionPlan` — compiled route graph output: ordered list of execution steps, credential leases needed, policies to enforce | P0 |
| 153 | Execution Result Type | Define `ExecutionResult` — outcome of executing a plan: response, latency, tokens, cost, fallback path taken, errors | P0 |
| 154 | Execution Envelope Type | Define `ExecutionEnvelope` — complete audit record: request metadata, caller, policy version, capabilities used, credential lease IDs, timing, cost | P0 |
| 155 | Endpoint Descriptor Type | Define `EndpointDescriptor` — compiled descriptor cached in Redis: resolved capabilities, policies, credentials, routing config for a specific exposure | P0 |
| 156 | Plugin Manifest Type | Define `PluginManifest` — versioned manifest: ID, kind, capabilities, required secrets, egress requirements, permissions, limits, config schema | P1 |
| 157 | Runtime Category Policy Type | Define `RuntimeCategoryPolicy` — per-category fail-open/fail-closed configuration for Redis coordination plane | P0 |
| 158 | Subject Type | Define `Subject` domain type — authenticated identity making a request: user, API key, service, anonymous | P0 |
| 159 | Audit Event Type | Define `AuditEvent` domain type — structured event for observability: timestamp, subject, action, resource, decision, metadata | P0 |
| 15A | Identity Types | Define identity domain types: `User`, `Session`, `APIKeyRecord` (hash-only, prefix, scopes, expiry), `OAuthToken` | P0 |
| 15B | Sentinel Errors | Define package-level sentinel errors: `ErrNotFound`, `ErrConflict`, `ErrUnauthorized`, `ErrForbidden`, `ErrRateLimited`, `ErrQuotaExceeded`, `ErrCircuitOpen`, `ErrTimeout`, `ErrValidation` | P0 |
| 15C | Search Result Type | Define `SearchResult` domain type — unified search result from any search provider: title, URL, snippet, source, score | P1 |
| 15D | Guardrail Type | Define `Guardrail` domain type — safety check configuration: content filters, PII detection, injection detection, custom rules | P1 |

### Kernel Interfaces (160-168)

| # | Name | Description | Priority |
|---|------|-------------|----------|
| 160 | Descriptor Store Interface | Define `DescriptorStore` interface — `Get`, `Put`, `Delete`, `List` for compiled endpoint descriptors | P0 |
| 161 | Identity Service Interface | Define `IdentityService` interface — `Authenticate`, `GetUser`, `ValidateAPIKey`, `CreateSession`, `RevokeSession` | P0 |
| 162 | Policy Engine Interface | Define `PolicyEngine` interface — `Authorize(ctx, AuthorizationRequest) (AuthorizationDecision, error)` | P0 |
| 163 | Limit Manager Interface | Define `LimitManager` interface — `CheckRate`, `CheckQuota`, `CheckConcurrency`, `CheckBudget`, `Record` | P0 |
| 164 | Planner Interface | Define `Planner` interface — `Plan(ctx, PlanningRequest) (ExecutionPlan, error)` | P0 |
| 165 | Credential Broker Interface | Define `CredentialBroker` interface — `Acquire(ctx, LeaseRequest) (*CredentialLease, error)`, `Release(ctx, leaseID)` | P0 |
| 166 | Executor Interface | Define `Executor` interface — `Execute(ctx, *ExecutionPlan) (*ExecutionResult, error)`, `Stream(ctx, *ExecutionPlan) (<-chan StreamEvent, error)` | P0 |
| 167 | Audit Sink Interface | Define `AuditSink` interface — `Emit(ctx, AuditEvent) error`, supports async batching | P0 |
| 168 | Guardrail Evaluator Interface | Define `GuardrailEvaluator` interface — `Evaluate(ctx, GuardrailRequest) (GuardrailDecision, error)` for content safety checks | P1 |

### PostgreSQL (170-175)

| # | Name | Description | Priority |
|---|------|-------------|----------|
| 170 | Connection Pool | Configure `pgxpool` with connection limits, lifetime, health checks, SSL mode from `DatabaseConfig` | P0 |
| 171 | Transaction Helper | Implement `WithTx(ctx, pool, fn)` helper — acquires connection, begins transaction, executes function, commits or rolls back | P0 |
| 172 | Health Check | Implement PostgreSQL health check: `SELECT 1` with timeout for readiness probes | P0 |
| 173 | Migration Runner | Implement forward-only migration runner: reads `migrations/postgres/*.sql`, tracks applied in `schema_migrations` table, runs in order | P0 |
| 174 | Migration: 0001_init | Create initial migration: `schema_migrations` table, `pgcrypto` extension, `updated_at` trigger function | P0 |
| 175 | pgcrypto Extension | Enable `pgcrypto` extension in init migration for `gen_random_uuid()` and cryptographic functions | P0 |

### Redis (180-188)

| # | Name | Description | Priority |
|---|------|-------------|----------|
| 180 | Redis Client | Configure `go-redis` client with pool size, timeouts, TLS, retry config from `RedisConfig` | P0 |
| 181 | Cache Interface | Define `Cache` interface — `Get`, `Set`, `Delete`, `Exists`, `SetNX`, `Expire` with typed serialization | P0 |
| 182 | Redis Health Check | Implement Redis health check: `PING` with timeout for readiness probes | P0 |
| 183 | Coordination Plane: 9 Categories | Define Redis coordination categories: rate-limits, quotas, semaphores, circuit-breakers, idempotency, locks, leases, descriptors, sessions | P0 |
| 184 | Soft Category (Rate Limits) | Implement fail-open behavior for rate limit category — if Redis unavailable, allow requests with degraded tracking | P0 |
| 185 | Safety Category (Circuit Breakers) | Implement fail-closed behavior for circuit breaker category — if Redis unavailable, trip circuits to protect backends | P0 |
| 186 | Runtime Category (Configurable) | Implement configurable fail-open/fail-closed per category via `RuntimeCategoryPolicy` | P0 |
| 187 | Key Namespacing | Implement Redis key namespacing: `cc:{category}:{entity}:{key}` pattern to prevent collisions and enable selective flush | P0 |
| 188 | Lua Script Atomicity | Implement Lua script loading and execution for atomic multi-step Redis operations (rate limiting, quota checks, lease acquisition) | P0 |

### Composition Root & Lifecycle (190-195)

| # | Name | Description | Priority |
|---|------|-------------|----------|
| 190 | App Struct | Implement `internal/app/app.go` — composition root that wires all dependencies, holds references, provides `Run()` and `Shutdown()` | P0 |
| 191 | Graceful Shutdown | Implement graceful shutdown: stop accepting new requests, drain in-flight, close connections, flush buffers, release resources | P0 |
| 192 | Signal Handling | Handle `SIGINT`, `SIGTERM` signals to trigger graceful shutdown sequence | P0 |
| 193 | Errgroup Orchestration | Use `errgroup` to manage concurrent goroutines (HTTP server, workers, health probes) with coordinated cancellation | P0 |
| 194 | Worker Shutdown Ordering | Implement ordered shutdown: stop HTTP server first, then workers, then flush audit, then close DB/Redis pools | P0 |
| 195 | Lease Release on Shutdown | Release all active credential leases and coordination locks during shutdown sequence | P1 |

### HTTP Server & Health (196-199)

| # | Name | Description | Priority |
|---|------|-------------|----------|
| 196 | HTTP Server | Implement HTTP server with graceful shutdown, timeouts, TLS support, middleware chain, router setup | P0 |
| 197 | Health: /healthz | Implement liveness probe endpoint — returns 200 if process is alive | P0 |
| 198 | Health: /readyz | Implement readiness probe endpoint — checks PostgreSQL and Redis connectivity, returns 503 if not ready | P0 |
| 199 | Connection Draining | Implement connection draining: stop accepting new connections, wait for in-flight requests with configurable timeout | P0 |

### Docker (19A-19F)

| # | Name | Description | Priority |
|---|------|-------------|----------|
| 19A | Docker Compose: Dev | Create `deploy/compose/docker-compose.dev.yml` with PostgreSQL, Redis, API server, worker, hot-reload volumes | P0 |
| 19B | Dockerfile: API | Create multi-stage `Dockerfile` for `cybercore-api`: build stage (Go), runtime stage (distroless/alpine) | P0 |
| 19C | Dockerfile: Migrate | Create `Dockerfile` for `cybercore-migrate`: lightweight image with migration binary and SQL files | P0 |
| 19D | Env Example | Create `.env.example` with all configuration variables, documented defaults, and security warnings | P0 |
| 19E | Docker Compose: Prod | Create `deploy/compose/docker-compose.prod.yml` with production settings: resource limits, restart policies, health checks, secrets | P1 |
| 19F | Production Dockerfiles | Create production Dockerfiles for `cybercore-worker`, `cybercore-runner`, `cybercore-cli` with minimal attack surface | P1 |

### CI (1A0-1A4)

| # | Name | Description | Priority |
|---|------|-------------|----------|
| 1A0 | GitHub Actions Workflow | Create `.github/workflows/ci.yml`: checkout, setup Go, cache, lint, test, build all binaries | P0 |
| 1A1 | golangci-lint Config | Create `.golangci.yml` with enabled linters: `govet`, `errcheck`, `staticcheck`, `gosec`, `ineffassign`, `unused`, `misspell` | P0 |
| 1A2 | Race Detection | Enable `-race` flag in CI test runs to detect data races | P0 |
| 1A3 | Testcontainers in CI | Configure CI to run integration tests with testcontainers (PostgreSQL, Redis) using Docker-in-Docker or service containers | P1 |
| 1A4 | Migration Safety Check | CI step that runs all migrations against empty database, verifies schema matches expected state | P1 |

### Outbox & Events (1B0-1B5)

| # | Name | Description | Priority |
|---|------|-------------|----------|
| 1B0 | Event Type Registry | Define `EventType` enum: `ExposureChanged`, `PolicyChanged`, `CredentialRotated`, `RouteGraphChanged`, `CapabilityRegistered`, `CapabilityRemoved` | P0 |
| 1B1 | Outbox Writer | Implement outbox writer: within same Postgres transaction as domain change, insert event row with type, payload, status, correlation ID | P0 |
| 1B2 | Outbox Reader Worker | Implement outbox reader: poll `outbox` table for unprocessed events, process in order, mark as processed, handle retries | P0 |
| 1B3 | Event Repository | Implement `EventRepository` — CRUD for outbox events, query by status/type, cleanup of old processed events | P0 |
| 1B4 | Event Bus Skeleton | Define `EventBus` interface — `Publish(ctx, Event)`, `Subscribe(eventType, handler)` for in-process event distribution | P0 |
| 1B5 | Event Bus Fan-Out | Implement fan-out: outbox reader publishes to event bus, multiple subscribers receive events (descriptor compiler, cache invalidator, audit logger) | P1 |

### SSRF & Network Security (1C0-1C8)

| # | Name | Description | Priority |
|---|------|-------------|----------|
| 1C0 | SSRF Guard | Implement SSRF guard: validates outbound URLs against allowlists, blocks private IP ranges (RFC 1918, link-local, loopback) | P0 |
| 1C1 | DNS Resolver Guard | Implement DNS resolution guard: resolve hostname before connecting, verify resolved IP is not in blocked ranges, prevent DNS rebinding | P0 |
| 1C2 | Egress Policy | Define `EgressPolicy` — per-capability/plugin allowlist of permitted outbound hosts, ports, and protocols | P0 |
| 1C3 | Header Sanitizer | Implement HTTP header sanitizer for outbound requests: strip internal headers, prevent header injection, limit header size | P0 |
| 1C4 | Input Size Limits | Implement request body size limits: configurable per endpoint, reject oversized payloads before parsing | P0 |
| 1C5 | Scheme Allowlist | Implement URL scheme allowlist: only `https` in production, `http` + `https` in development; block `file://`, `ftp://`, `gopher://` | P0 |
| 1C6 | DNS Rebinding Protection | Implement DNS rebinding protection: pin resolved IP for connection lifetime, detect IP changes between resolution and connection | P0 |
| 1C7 | Certificate Pinning | Implement optional TLS certificate pinning for critical provider connections (configurable per provider) | P2 |
| 1C8 | SSRF Bypass Test Suite | Comprehensive test suite for SSRF bypass attempts: URL encoding, IPv6 mapping, DNS rebinding, redirect chains, decimal IP encoding | P0 |

### RF8 Domain Contract Freeze (1D0-1D9)

| # | Name | Description | Priority |
|---|------|-------------|----------|
| 1D0 | Threat Model: Trust Modes | Document threat model for each trust mode (strict/permissive/development): what is allowed, what is blocked, what is logged | P0 |
| 1D1 | Trust Mode Schema | Define JSON Schema for trust mode configuration: validation rules per mode, security controls, degradation behavior | P1 |
| 1D2 | Trust Mode Fixtures | Create test fixtures for each trust mode: config examples, expected behavior assertions, edge cases | P1 |
| 1D3 | Source of Truth Map | Document which system (Postgres, Redis, config file) is source of truth for each domain entity and configuration | P0 |
| 1D4 | Feature Parity Matrix | Create matrix mapping original OmniRoute/MetaMCP features to Cybernetics Core equivalents with status (done, planned, dropped, modified) | P1 |
| 1D5 | Domain JSON Schemas | Generate JSON Schemas for all domain types: Capability, Exposure, Policy, Credential, RouteGraph, ExecutionEnvelope, PluginManifest | P0 |
| 1D6 | Golden Fixtures | Create golden test fixtures for all domain types with known-good serialization/deserialization, used in regression tests | P0 |
| 1D7 | Kernel Interface Contract | Document behavioral contracts for each kernel interface: preconditions, postconditions, error semantics, concurrency guarantees | P0 |
| 1D8 | Coordination Plane Contract | Document Redis coordination plane contract: key formats, TTLs, Lua script semantics, fail-open/fail-closed behavior per category | P0 |
| 1D9 | Plugin Manifest Contract | Document plugin manifest contract: required fields, version compatibility, capability declarations, security requirements, validation rules | P1 |
