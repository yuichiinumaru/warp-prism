# Feature Catalog: Limits, Observability & Cache

> **Series**: 800
> **EPICs**: EPIC-800, EPIC-810, EPIC-820, EPIC-830, EPIC-840, EPIC-850, EPIC-860, EPIC-870, EPIC-880
> **Tasks**: 0346-0420
> **Total Features**: 75

## Features

### Rate Limiting (800-809)

| # | Name | Description | Priority |
|---|------|-------------|----------|
| 800 | Rate Limit Algorithm | Implement sliding window rate limiter: atomic check-and-increment via Redis Lua script | P0 |
| 801 | Per-Subject Rate Limit | Enforce rate limits per authenticated subject: requests per minute, per hour, per day | P0 |
| 802 | Per-API-Key Rate Limit | Enforce rate limits per API key: independent from subject limits, configurable per key | P0 |
| 803 | Per-Exposure Rate Limit | Enforce rate limits per exposure endpoint: global limit across all subjects | P0 |
| 804 | Per-Provider Rate Limit | Track and enforce provider-side rate limits: sync with provider rate limit headers | P0 |
| 805 | Rate Limit Headers | Return standard rate limit headers: `X-RateLimit-Limit`, `X-RateLimit-Remaining`, `X-RateLimit-Reset`, `Retry-After` | P0 |
| 806 | Rate Limit Redis Script | Implement atomic sliding window Lua script: MULTI/EXEC for check + increment + expiry in single round-trip | P0 |
| 807 | Rate Limit Fail-Open | Rate limit fails open when Redis unavailable (soft category): allow requests, log degradation warning | P0 |
| 808 | Rate Limit Events | Emit events on rate limit triggers: subject, endpoint, limit, current count, window | P0 |
| 809 | Rate Limit Admin Override | Admin API to temporarily override rate limits: increase for specific subject/key, clear current counters | P1 |

### Quotas, Concurrency & Budgets (810-829)

| # | Name | Description | Priority |
|---|------|-------------|----------|
| 810 | Token Quota | Implement per-subject token quotas: daily/monthly token limits, track prompt + completion separately | P0 |
| 811 | Cost Budget | Implement per-subject cost budgets: daily/monthly dollar limits based on model pricing and token usage | P0 |
| 812 | Quota Repository | Implement `QuotaRepository` — store quota configurations and usage in PostgreSQL; current usage counters in Redis | P0 |
| 813 | Quota Check | Implement quota check: estimate request cost/tokens, verify against remaining quota, reject if exceeded | P0 |
| 814 | Quota Recording | Record actual usage after execution: update Redis counters, async persist to PostgreSQL | P0 |
| 815 | Quota Reset | Implement quota reset: automatic reset on period boundary (daily at midnight UTC, monthly on 1st) | P0 |
| 816 | Quota Warning Events | Emit warning events at configurable thresholds: 50%, 75%, 90%, 100% of quota consumed | P1 |
| 817 | Concurrency Semaphore | Implement per-subject concurrency semaphore: max concurrent requests, enforced via Redis SETNX with TTL | P0 |
| 818 | Account Semaphore | Implement account-level concurrency semaphore: shared across all API keys for an account | P0 |
| 819 | Provider Concurrency | Track per-provider concurrent requests: enforce provider-specific concurrency limits | P0 |
| 81A | Concurrency Queue | Optional request queuing when concurrency limit reached: FIFO queue with timeout, reject after queue-full | P2 |
| 81B | Budget Allocation | Allocate budget across capability sets or exposures: sub-budgets that sum to total | P1 |
| 81C | Budget Roll-Over | Optional budget roll-over: unused budget carries forward to next period (configurable cap) | P2 |
| 81D | Budget Alert Webhook | Trigger webhook on budget threshold: configurable URL, includes usage details | P2 |
| 81E | Quota Admin Endpoints | Admin endpoints for quota management: view usage, set limits, reset counters, view history | P0 |
| 81F | Quota Usage History | Store daily quota usage snapshots in PostgreSQL: token counts, cost, request counts per subject | P1 |
| 820 | Concurrency Leak Detection | Detect leaked semaphore slots: background check for slots held longer than max timeout, force-release with warning | P0 |

### Audit Event Store (830-839)

| # | Name | Description | Priority |
|---|------|-------------|----------|
| 830 | Audit Event Repository | Implement `AuditEventRepository` — store audit events in PostgreSQL with partitioning by timestamp | P0 |
| 831 | Audit Event Write | Write audit event: timestamp, subject, action, resource, decision, request ID, metadata; async batching | P0 |
| 832 | Audit Event Query | Query audit events: filter by subject, action, resource, time range, decision; paginated results | P0 |
| 833 | Audit Event Retention | Implement retention policy: configurable retention period, background cleanup of expired events | P1 |
| 834 | Audit Event Export | Export audit events: JSON/CSV format, date range, filtered by criteria; for compliance and analysis | P1 |
| 835 | Audit Async Sink | Implement async audit sink: buffer events in channel, batch write to PostgreSQL, flush on shutdown | P0 |
| 836 | Audit Event Integrity | Implement event integrity: HMAC signature on each event, detect tampering in audit trail | P2 |
| 837 | Audit Event Compression | Compress audit event metadata: gzip large payloads before storage, decompress on read | P2 |
| 838 | Audit Event Admin Endpoints | Admin endpoints for audit event query: search, filter, export, dashboard data | P0 |
| 839 | Audit Event Indexes | Create PostgreSQL indexes for efficient audit queries: subject, action, resource, timestamp, decision | P0 |

### Execution Envelope (840-849)

| # | Name | Description | Priority |
|---|------|-------------|----------|
| 840 | Envelope Builder | Build execution envelope from request + plan + result: all audit fields, redacted credentials, timing | P0 |
| 841 | Envelope Storage | Store execution envelopes in PostgreSQL: partitioned by timestamp, indexed by request ID, subject, model | P0 |
| 842 | Envelope Query | Query execution envelopes: filter by subject, model, time range, status, cost range; paginated | P0 |
| 843 | Envelope Aggregation | Aggregate envelope data: total tokens, cost, latency percentiles, error rate per model/subject/exposure | P1 |
| 844 | Envelope Admin Endpoints | Admin endpoints for envelope inspection: view individual envelope, query, aggregate statistics | P0 |
| 845 | Envelope Retention | Implement retention policy: configurable retention, background cleanup, optional archive to external storage | P1 |
| 846 | Envelope Correlation | Correlate envelopes with audit events, policy decisions, and credential leases via shared request ID | P0 |
| 847 | Envelope Redaction | Redact sensitive fields in envelopes: prompt content (optional), credentials (always), PII (configurable) | P0 |
| 848 | Envelope Schema Validation | Validate envelope schema on creation: all required fields present, types correct, references valid | P0 |
| 849 | Envelope Export | Export envelopes: JSON format, filtered, for external analytics and compliance | P1 |

### Observability: Metrics, Tracing & Logging (850-85F)

| # | Name | Description | Priority |
|---|------|-------------|----------|
| 850 | Prometheus Metrics | Expose Prometheus-compatible metrics endpoint: `/metrics` with standard Go runtime + custom application metrics | P0 |
| 851 | Request Metrics | Track request metrics: count, latency histogram, error rate, active requests per endpoint/model/subject | P0 |
| 852 | Provider Metrics | Track provider metrics: request count, latency, error rate, token throughput per provider/model | P0 |
| 853 | Credential Metrics | Track credential metrics: active leases, acquisition latency, rejection rate per credential/provider | P1 |
| 854 | Policy Metrics | Track policy metrics: evaluation count, allow/deny rate, evaluation latency per policy | P1 |
| 855 | Cache Metrics | Track cache metrics: hit/miss rate, size, eviction rate per cache layer (local, Redis) | P1 |
| 856 | Structured Logging | Implement structured logging: JSON format, log levels, contextual fields (request ID, subject, trace ID) | P0 |
| 857 | Request Context Logging | Propagate request context to all log entries: request ID, subject ID, trace ID, span ID | P0 |
| 858 | Log Level Configuration | Configure log level at runtime: per-package log levels, dynamic level change via admin API | P1 |
| 859 | Log Sampling | Implement log sampling: reduce high-volume log entries, configurable sampling rate per level/category | P1 |
| 85A | OpenTelemetry Tracing | Implement OpenTelemetry tracing: spans for gateway, planning, execution, provider calls; trace propagation | P1 |
| 85B | Trace Context Propagation | Propagate trace context across service boundaries: W3C Trace Context headers, internal span creation | P1 |
| 85C | Custom Span Attributes | Add custom span attributes: model, provider, token count, cost, fallback path, policy decision | P1 |
| 85D | Health Dashboard Metrics | Expose health dashboard metrics: system status, component health, active connections, queue depths | P1 |
| 85E | Error Tracking | Implement error tracking: categorize errors, track frequency, alert on anomalies, link to traces | P1 |
| 85F | Metric Alerting Rules | Define Prometheus alerting rules: high error rate, high latency, credential expiry, quota exhaustion, circuit breaker trips | P1 |

### Usage Aggregation Worker (860-869)

| # | Name | Description | Priority |
|---|------|-------------|----------|
| 860 | Usage Aggregation Worker | Background worker that aggregates usage data from Redis counters to PostgreSQL at regular intervals | P0 |
| 861 | Hourly Usage Rollup | Aggregate hourly usage: token counts, request counts, cost per subject/model/exposure | P0 |
| 862 | Daily Usage Rollup | Aggregate daily usage: sum hourly data, per subject/model/exposure, used for quota/budget enforcement | P0 |
| 863 | Monthly Usage Report | Generate monthly usage reports: total tokens, cost, request counts per subject; stored in PostgreSQL | P1 |
| 864 | Usage Admin Endpoints | Admin endpoints for usage data: current usage, historical trends, per-subject breakdown, cost analysis | P0 |
| 865 | Usage Export | Export usage data: CSV/JSON format, date range, grouped by subject/model/exposure | P1 |
| 866 | Usage Anomaly Detection | Detect usage anomalies: sudden spikes, unusual patterns, potential abuse; emit alert events | P2 |
| 867 | Usage Forecast | Basic usage forecasting: project current usage rate to end of quota period; warn on projected overage | P2 |
| 868 | Cost Allocation | Allocate costs to subjects/teams: per-request cost tracking, aggregate by cost center | P1 |
| 869 | Usage Dashboard Data | Provide pre-aggregated data for dashboard: time series, top users, top models, cost breakdown | P1 |

### Semantic Cache (870-879)

| # | Name | Description | Priority |
|---|------|-------------|----------|
| 870 | Semantic Cache Interface | Define `SemanticCache` interface: `Get(ctx, key) → cached response`, `Put(ctx, key, response, TTL)`, `Invalidate(ctx, key)` | P1 |
| 871 | Exact Match Cache | Implement exact-match cache: cache key = hash(model + messages + parameters); store in Redis with TTL | P1 |
| 872 | Cache Key Generation | Generate cache keys: normalize request (sort parameters, trim whitespace), hash with BLAKE3 for consistency | P1 |
| 873 | Cache Storage | Store cached responses in Redis: compressed, with metadata (timestamp, hit count, original cost) | P1 |
| 874 | Cache TTL Strategy | Implement TTL strategies: static TTL, model-specific TTL, content-based TTL (factual = longer, creative = shorter) | P1 |
| 875 | Cache Hit Metrics | Track cache performance: hit rate, miss rate, stored entries, storage size, cost savings | P1 |
| 876 | Cache Bypass | Support cache bypass: `x-no-cache: true` header, per-subject cache disable, per-model cache disable | P1 |
| 877 | Embedding Similarity Cache | Implement embedding-based similarity cache: find semantically similar cached responses (requires embedding model) | P2 |
| 878 | Cache Invalidation | Implement cache invalidation: by key, by model, by subject, TTL expiry, manual purge via admin API | P1 |
| 879 | Cache Admin Endpoints | Admin endpoints for cache management: view stats, purge by criteria, configure TTL, enable/disable | P1 |

### Benchmark Tests (880-885)

| # | Name | Description | Priority |
|---|------|-------------|----------|
| 880 | Rate Limit Benchmark | Benchmark rate limit check performance: target < 100μs per check including Redis round-trip | P1 |
| 881 | Policy Evaluation Benchmark | Benchmark policy evaluation: target < 50μs for cached snapshot evaluation, < 1ms for compilation | P1 |
| 882 | Descriptor Lookup Benchmark | Benchmark descriptor lookup: target < 10μs for local cache hit, < 500μs for Redis hit | P1 |
| 883 | Gateway Hot Path Benchmark | Benchmark full gateway hot path: auth → descriptor → policy → plan → execute overhead target < 5ms | P1 |
| 884 | Streaming Throughput Benchmark | Benchmark streaming throughput: target > 10K concurrent SSE streams with < 1ms jitter | P1 |
| 885 | Redaction Benchmark | Benchmark log and response redaction: target < 1μs per log entry, < 100μs per response | P1 |

### Integration Tests (886-88C)

| # | Name | Description | Priority |
|---|------|-------------|----------|
| 886 | Rate Limit Integration Test | Integration test: rate limiting with real Redis, verify sliding window, concurrent access, fail-open | P0 |
| 887 | Quota Integration Test | Integration test: quota enforcement with Redis + PostgreSQL, verify daily reset, concurrent updates | P0 |
| 888 | Audit Write Integration Test | Integration test: audit event write and query with real PostgreSQL, verify batching, retention | P0 |
| 889 | Envelope Integration Test | Integration test: execution envelope build, store, query with PostgreSQL, verify all fields | P0 |
| 88A | Cache Integration Test | Integration test: semantic cache with Redis, verify hit/miss, TTL, invalidation, compression | P1 |
| 88B | Metrics Endpoint Test | Integration test: verify Prometheus metrics endpoint returns expected metrics in correct format | P0 |
| 88C | Usage Aggregation Test | Integration test: usage aggregation worker with Redis + PostgreSQL, verify rollups, accuracy | P1 |
