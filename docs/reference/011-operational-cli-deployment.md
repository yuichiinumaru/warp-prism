# Feature Catalog: Operational CLI & Deployment

> **Series**: 1100
> **EPICs**: EPIC-1100, EPIC-1110, EPIC-1120, EPIC-1130, EPIC-1140, EPIC-1150, EPIC-1160, EPIC-1170, EPIC-11E0
> **Tasks**: 0481-0545
> **Total Features**: 65

## Features

### SSE Admin Live Events (1100-1109)

| # | Name | Description | Priority |
|---|------|-------------|----------|
| 1100 | Admin SSE Endpoint | Implement `/admin/events` SSE endpoint: stream real-time admin events to connected clients | P1 |
| 1101 | Event Type Filtering | Support event type filtering via query parameter: subscribe to specific event types only | P1 |
| 1102 | Circuit Breaker Events | Stream circuit breaker state changes via SSE: opened, half-opened, closed, with provider/capability context | P1 |
| 1103 | Rate Limit Events | Stream rate limit trigger events via SSE: subject, endpoint, limit details | P1 |
| 1104 | Credential Events | Stream credential events via SSE: rotation, expiry warning, lease acquisition/release | P1 |
| 1105 | Policy Events | Stream policy change events via SSE: created, activated, archived, evaluation anomalies | P1 |
| 1106 | Health Events | Stream health change events via SSE: provider up/down, Redis connectivity, database issues | P1 |
| 1107 | Error Events | Stream error events via SSE: provider errors, execution failures, sandbox violations | P1 |
| 1108 | SSE Authentication | Authenticate SSE connections: require admin session or API key with admin scope | P1 |
| 1109 | SSE Connection Management | Manage SSE connections: limit max concurrent, heartbeat, cleanup on disconnect, backpressure | P1 |

### OpenAPI Spec Generation (1110-1114)

| # | Name | Description | Priority |
|---|------|-------------|----------|
| 1110 | OpenAPI Spec: Admin API | Generate OpenAPI 3.1 spec for admin API: all CRUD endpoints, schemas, auth, error responses | P0 |
| 1111 | OpenAPI Spec: Public API | Generate OpenAPI 3.1 spec for public API: OpenAI-compatible endpoints, MCP endpoints, auth | P0 |
| 1112 | OpenAPI Validation | Validate generated specs: schema consistency, endpoint coverage, example accuracy | P1 |
| 1113 | OpenAPI Serving | Serve OpenAPI specs at `/api/docs/admin` and `/api/docs/public`; Swagger UI or ReDoc integration | P1 |
| 1114 | OpenAPI Code Generation | Generate client SDKs from OpenAPI specs: Go, TypeScript, Python; used for testing and Flutter app | P2 |

### E2E Docker Compose Tests (1120-1129)

| # | Name | Description | Priority |
|---|------|-------------|----------|
| 1120 | E2E Test Framework | Set up E2E test framework: Docker Compose orchestration, test runner, assertion helpers, cleanup | P1 |
| 1121 | E2E: Full Stack Boot | Test full stack boot: API + worker + PostgreSQL + Redis start successfully, health checks pass | P1 |
| 1122 | E2E: User Lifecycle | Test user lifecycle: create user, login, create API key, make API call, revoke key, logout | P1 |
| 1123 | E2E: Chat Completion Flow | Test chat completion: register provider, create capability, create exposure, make chat completion request | P1 |
| 1124 | E2E: Streaming Flow | Test streaming: initiate streaming chat completion, receive SSE events, verify content and usage | P1 |
| 1125 | E2E: Policy Enforcement | Test policy enforcement: create policy, verify allow/deny decisions, test rate limiting | P1 |
| 1126 | E2E: Fallback Flow | Test fallback: configure route graph with primary + fallback, simulate primary failure, verify fallback execution | P1 |
| 1127 | E2E: MCP Tool Execution | Test MCP tool execution: register MCP server, discover tools, execute tool call, verify result | P1 |
| 1128 | E2E: Credential Rotation | Test credential rotation: create credential, use in execution, rotate, verify new credential used | P1 |
| 1129 | E2E: Graceful Shutdown | Test graceful shutdown: start long-running request, signal shutdown, verify request completes, server stops | P1 |

### CLI Tooling (1130-1149)

| # | Name | Description | Priority |
|---|------|-------------|----------|
| 1130 | CLI Framework | Set up CLI framework: `cobra` or `urfave/cli`, root command, global flags (config, output format, verbose) | P1 |
| 1131 | CLI: create-user | `cybercore-cli create-user`: create admin/operator/viewer user with email and password | P1 |
| 1132 | CLI: create-api-key | `cybercore-cli create-api-key`: generate API key for user, display full key ONCE, specify scopes | P1 |
| 1133 | CLI: test-provider | `cybercore-cli test-provider`: test provider connectivity, send test request, display response | P1 |
| 1134 | CLI: test-mcp | `cybercore-cli test-mcp`: test MCP server connectivity, list tools, execute test tool call | P1 |
| 1135 | CLI: inspect-policy | `cybercore-cli inspect-policy`: display compiled policy snapshot, show evaluation tree, test authorization | P1 |
| 1136 | CLI: inspect-descriptor | `cybercore-cli inspect-descriptor`: display compiled endpoint descriptor, show resolved capabilities and policies | P1 |
| 1137 | CLI: export-config | `cybercore-cli export-config`: export full configuration as YAML/JSON (secrets redacted) | P1 |
| 1138 | CLI: import-config | `cybercore-cli import-config`: import configuration from YAML/JSON, validate, apply changes | P1 |
| 1139 | CLI: diagnostics | `cybercore-cli diagnostics`: run system diagnostics including DB connectivity, Redis, provider health, disk space | P1 |
| 113A | CLI: migrate | `cybercore-cli migrate`: run database migrations, show status, rollback support | P1 |
| 113B | CLI: version | `cybercore-cli version`: display version, commit, build time, Go version | P1 |
| 113C | CLI: list-capabilities | `cybercore-cli list-capabilities`: display registered capabilities with status, kind, provider | P1 |
| 113D | CLI: list-exposures | `cybercore-cli list-exposures`: display configured exposures with status, type, target | P1 |
| 113E | CLI: list-providers | `cybercore-cli list-providers`: display registered providers with health status | P1 |
| 113F | CLI: audit-query | `cybercore-cli audit-query`: query audit trail with filters, output as table/JSON | P1 |
| 1140 | CLI: quota-report | `cybercore-cli quota-report`: display quota usage for subject/all subjects | P1 |
| 1141 | CLI: circuit-status | `cybercore-cli circuit-status`: display circuit breaker states for all providers/capabilities | P1 |
| 1142 | CLI: cache-stats | `cybercore-cli cache-stats`: display cache hit rates, sizes, entry counts per cache layer | P1 |
| 1143 | CLI: rotate-credential | `cybercore-cli rotate-credential`: trigger manual credential rotation for specified credential | P1 |
| 1144 | CLI: simulate-route | `cybercore-cli simulate-route`: simulate routing decision for given workload parameters | P2 |
| 1145 | CLI Output Formats | Support CLI output formats: table (default), JSON, YAML; configurable via `--output` flag | P1 |
| 1146 | CLI Autocomplete | Generate shell autocompletion scripts: bash, zsh, fish | P2 |
| 1147 | CLI Config File | Support CLI config file: `~/.cybercore.yaml` with defaults for server URL, API key, output format | P1 |
| 1148 | CLI Error Handling | Consistent CLI error handling: clear error messages, exit codes, suggestion hints | P1 |
| 1149 | CLI Interactive Mode | Optional interactive mode for complex operations: guided prompts for create-user, create-api-key | P2 |

### Deployment, Backup & DR (1150-1159)

| # | Name | Description | Priority |
|---|------|-------------|----------|
| 1150 | Deployment Guide | Document deployment guide: prerequisites, architecture, configuration, security hardening, scaling | P1 |
| 1151 | PostgreSQL Backup Script | Create PostgreSQL backup script: pg_dump with custom format, encrypted backup, upload to storage | P1 |
| 1152 | PostgreSQL Restore Script | Create PostgreSQL restore script: pg_restore, verify integrity, test queries after restore | P1 |
| 1153 | Redis Backup Config | Configure Redis persistence: RDB snapshots, AOF log, backup retention | P1 |
| 1154 | Disaster Recovery Runbook | Document DR runbook: failure scenarios, recovery procedures, RTO/RPO targets, contact escalation | P2 |
| 1155 | Zero-Downtime Migration | Document and implement zero-downtime migration strategy: rolling updates, backward-compatible migrations | P1 |
| 1156 | Health Check Automation | Automated health check script: verify all components, report status, suitable for monitoring integration | P1 |
| 1157 | Scaling Guide | Document horizontal scaling: API instances, worker instances, database read replicas, Redis sentinel | P2 |
| 1158 | Secret Rotation Runbook | Document secret rotation runbook: master key rotation, database password rotation, API key rotation | P1 |
| 1159 | Rollback Procedure | Document rollback procedure: binary rollback, migration rollback, configuration rollback, data recovery | P1 |

### Log, Metric & Alert Configuration (1160-1169)

| # | Name | Description | Priority |
|---|------|-------------|----------|
| 1160 | Grafana Dashboard Templates | Create Grafana dashboard templates: system overview, request metrics, provider health, quota usage, error rates | P1 |
| 1161 | Prometheus Alerting Rules | Create Prometheus alerting rules: error rate > 5%, latency > 5s, circuit breaker trips, quota exhaustion | P1 |
| 1162 | Log Aggregation Config | Document log aggregation setup: Loki/ELK configuration, log parsing, field extraction, retention | P1 |
| 1163 | Trace Collection Config | Document trace collection setup: Jaeger/Zipkin/OTLP configuration, sampling rate, retention | P1 |
| 1164 | Alert Notification Config | Document alert notification setup: email, Slack, PagerDuty, webhook configuration | P1 |
| 1165 | Metric Cardinality Management | Implement metric cardinality controls: limit unique label combinations, aggregate high-cardinality dimensions | P2 |
| 1166 | Log Rotation Config | Configure log rotation: max file size, max files, compression, retention period | P1 |
| 1167 | Dashboard Data API | Implement admin API endpoints providing pre-aggregated dashboard data: time series, top-N, percentiles | P1 |
| 1168 | SLO Tracking | Define and track SLOs: availability > 99.9%, p99 latency < 2s, error rate < 0.1%; report via metrics | P2 |
| 1169 | Incident Response Template | Create incident response template: severity classification, communication, investigation, remediation, postmortem | P2 |

### Operational Runbooks (1170-1179)

| # | Name | Description | Priority |
|---|------|-------------|----------|
| 1170 | Runbook: Provider Outage | Operational runbook for provider outage: detection, impact assessment, circuit breaker management, failover | P1 |
| 1171 | Runbook: Database Issues | Operational runbook for database issues: connection exhaustion, slow queries, replication lag, recovery | P1 |
| 1172 | Runbook: Redis Failures | Operational runbook for Redis failures: fail-open/fail-closed behavior, reconnection, data recovery | P1 |
| 1173 | Runbook: Security Incident | Operational runbook for security incidents: credential leak, unauthorized access, data breach response | P1 |
| 1174 | Runbook: Capacity Planning | Operational runbook for capacity planning: monitoring growth, scaling triggers, resource sizing | P2 |
| 1175 | Runbook: Certificate Renewal | Operational runbook for certificate renewal: TLS certs, CA rotation, client certificate updates | P1 |
| 1176 | Runbook: Master Key Rotation | Operational runbook for master key rotation: generate new key, re-encrypt DEKs, verify, switch over | P1 |
| 1177 | Runbook: Performance Troubleshooting | Operational runbook for performance issues: profiling, bottleneck identification, optimization | P2 |
| 1178 | Runbook: MCP Server Issues | Operational runbook for MCP server issues: unresponsive server, sandbox violations, resource leaks | P1 |
| 1179 | Runbook: Quota Management | Operational runbook for quota management: emergency quota increase, abuse detection, cost containment | P1 |

### Seed Data (11E0-11E2)

| # | Name | Description | Priority |
|---|------|-------------|----------|
| 11E0 | Development Seed Data | Create development seed data: admin user, test providers (mock), sample capabilities, policies, exposures | P1 |
| 11E1 | Demo Seed Data | Create demo seed data: realistic configuration with multiple providers, route graphs, policies; for demonstrations | P2 |
| 11E2 | Seed Data Loader | Implement seed data loader: load from YAML/JSON files, idempotent (skip existing), CLI command `cybercore-cli seed` | P1 |
