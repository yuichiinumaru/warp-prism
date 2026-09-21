# Feature Catalog: Gap — Import/Export, Bootstrap & Operational

> **Series**: 2500
> **EPICs**: EPIC-2500 (Config Import/Export), EPIC-2510 (Bootstrap Service), EPIC-2520 (Operational Enhancements), EPIC-2530 (Compliance & No-Log)
> **Gap Source**: diegosouza-omniroute (pricing sync, config hot-reload, quota sharing, volume detector, heap pressure shedding, no-log keys, provider plans, credit balance), cybernetics-core (bootstrap service, config import/export, debug exposure gate, docker hostname transform, OAuth authorization server)
> **Total Features**: 35

## Gap Analysis Summary

Our catalog has CLI import/export (1137, 1138), seed data loading (11E0-11E2), and config loading (110-119). However, we lack several operational features from both reference repos:

- **Config import/export with validation** — preflight validation, redacted secret export, cross-environment promotion
- **Bootstrap service** — automated first-run setup from environment
- **Volume detection & load shedding** — request spike detection, automatic load shedding
- **Quota sharing** — pool quotas across multiple keys/groups
- **Compliance/no-log keys** — GDPR-compliant operation mode
- **Debug exposure gate** — controlled debug info exposure
- **OAuth authorization server** — full RFC-compliant OAuth server (not just client)
- **Docker hostname transforms** — localhost → host.docker.internal in containers

## Classification Guide

- **CORE**: Config import/export, bootstrap, load shedding, no-log keys — operational necessities
- **EXTENDED**: Quota sharing, debug gate, OAuth server, volume detection
- **ECOSYSTEM**: Docker transforms, pricing sync UI

---

## Features

### Config Import/Export (2500-2509)

| # | Name | Description | Classification | Priority | Proposed EPIC |
|---|------|-------------|---------------|----------|---------------|
| 2500 | Config Export Model | Define configuration export format: full system configuration as structured JSON/YAML including providers, capabilities, exposures, policies, route graphs, hooks (secrets redacted) | CORE | P1 | EPIC-2500 (new) |
| 2501 | Config Export Handler | Implement config export: serialize all configuration entities to portable format, redact secrets (show prefix only), include version metadata | CORE | P1 | EPIC-2500 |
| 2502 | Config Import Handler | Implement config import: parse exported config, validate all references, detect conflicts with existing config, preview changes before applying | CORE | P1 | EPIC-2500 |
| 2503 | Import Preflight Validation | Implement preflight validation on import: check all references resolve, detect missing credentials, validate policy syntax, report errors before applying | CORE | P1 | EPIC-2500 |
| 2504 | Import Dry Run | Support import dry run: validate and report what would change without actually applying; show creates, updates, conflicts | CORE | P1 | EPIC-2500 |
| 2505 | Import Merge Strategy | Configure import merge strategy: `create_only` (skip existing), `update_existing` (merge), `replace_all` (destructive), `fail_on_conflict` | CORE | P1 | EPIC-2500 |
| 2506 | Cross-Environment Promotion | Support config promotion across environments: export from staging, import to production with environment-specific overrides (URLs, credentials) | EXTENDED | P2 | EPIC-2500 |
| 2507 | Config Snapshot | Take snapshots of current configuration: timestamped backup before major changes, restore to snapshot on failure | EXTENDED | P2 | EPIC-2500 |
| 2508 | Config Version History | Track configuration version history: log who changed what, when, diff between versions, rollback capability | EXTENDED | P2 | EPIC-2500 |
| 2509 | Config Import/Export Tests | Test suite for import/export: round-trip fidelity, secret redaction, merge strategies, conflict detection, cross-environment | CORE | P1 | EPIC-2500 |

### Bootstrap Service (2510-2519)

| # | Name | Description | Classification | Priority | Proposed EPIC |
|---|------|-------------|---------------|----------|---------------|
| 2510 | Bootstrap Service | Implement first-run bootstrap service: detect empty database, run initial setup from environment variables or config file | CORE | P1 | EPIC-2510 (new) |
| 2511 | Bootstrap: Admin User | Bootstrap initial admin user: create from `ADMIN_EMAIL`/`ADMIN_PASSWORD` environment variables on first run if no users exist | CORE | P1 | EPIC-2510 |
| 2512 | Bootstrap: Default Provider | Bootstrap default provider: create initial provider configuration from environment variables (e.g., `OPENAI_API_KEY` → OpenAI provider) | CORE | P1 | EPIC-2510 |
| 2513 | Bootstrap: Default Exposure | Bootstrap default exposure: create default `/v1/chat/completions` exposure with basic policy on first run | EXTENDED | P2 | EPIC-2510 |
| 2514 | Bootstrap: Default Policy | Bootstrap default deny-all policy plus admin-allow policy on first run; ensure system is secure by default | CORE | P1 | EPIC-2510 |
| 2515 | Bootstrap Idempotency | Ensure bootstrap is idempotent: safe to run multiple times, skip resources that already exist, log what was created vs skipped | CORE | P1 | EPIC-2510 |
| 2516 | Bootstrap from Config File | Support bootstrap from YAML/JSON config file: define initial state (users, providers, capabilities, exposures, policies) in single file | EXTENDED | P2 | EPIC-2510 |
| 2517 | Bootstrap Progress Logging | Log bootstrap progress: what was created, what was skipped, any warnings, total setup time | CORE | P1 | EPIC-2510 |
| 2518 | Docker Hostname Transform | Implement Docker hostname transform: detect Docker environment, transform `localhost` to `host.docker.internal` in provider URLs and MCP server URLs | CORE | P1 | EPIC-2510 |
| 2519 | Bootstrap Tests | Test suite for bootstrap: first run, idempotent re-run, config file loading, Docker detection, admin creation | CORE | P1 | EPIC-2510 |

### Operational Enhancements (2520-2529)

| # | Name | Description | Classification | Priority | Proposed EPIC |
|---|------|-------------|---------------|----------|---------------|
| 2520 | Volume Detector | Implement request volume detector: detect sudden spikes in request rate (configurable threshold, sliding window), emit alert events | CORE | P1 | EPIC-2520 (new) |
| 2521 | Load Shedding | Implement load shedding: when system is overloaded (CPU, goroutines, queue depth), reject low-priority requests with 503, preserve capacity for high-priority | CORE | P1 | EPIC-2520 |
| 2522 | Memory Pressure Shedding | Implement memory-based load shedding: monitor Go runtime heap usage, start shedding requests when heap exceeds configurable threshold (default 85%) | CORE | P1 | EPIC-2520 |
| 2523 | Quota Sharing | Implement quota sharing: pool quota allocation across multiple API keys or user groups; shared budget with per-key sub-limits | EXTENDED | P2 | EPIC-2520 |
| 2524 | Quota Pool Model | Define `QuotaPool` entity: pool name, member keys/users, shared limits (tokens, cost, requests), per-member sub-limits, usage tracking | EXTENDED | P2 | EPIC-2520 |
| 2525 | Debug Exposure Gate | Implement debug exposure gate: control what debug information is exposed in error responses; require acknowledgement token for detailed debug info | EXTENDED | P2 | EPIC-2520 |
| 2526 | Debug Token System | Implement debug token: per-request `X-Debug-Token` header that unlocks detailed error responses, stack traces, timing info; token validated against admin-issued tokens | EXTENDED | P2 | EPIC-2520 |
| 2527 | Adaptive Rate Limiting | Implement adaptive rate limiting: automatically adjust rate limits based on system load; tighten under load, relax when healthy | EXTENDED | P2 | EPIC-2520 |
| 2528 | Operational Metrics | Expose operational metrics: goroutine count, heap usage, GC pressure, open file descriptors, connection pool utilization | CORE | P1 | EPIC-2520 |
| 2529 | Operational Enhancement Tests | Test suite for operational features: load shedding triggers, volume detection, quota sharing, memory pressure, debug gate | CORE | P1 | EPIC-2520 |

### Compliance & No-Log (2530-2534)

| # | Name | Description | Classification | Priority | Proposed EPIC |
|---|------|-------------|---------------|----------|---------------|
| 2530 | No-Log API Keys | Implement no-log API keys: per-key flag that suppresses content logging; only metadata (tokens, cost, latency) recorded; for GDPR/compliance | CORE | P1 | EPIC-2530 (new) |
| 2531 | No-Log Configuration | Configure no-log mode: per API key, per exposure, per subject; specify what is suppressed (content, metadata, both) | CORE | P1 | EPIC-2530 |
| 2532 | No-Log Audit Mode | Audit mode for no-log keys: record that a request was made (timestamp, tokens, cost) without recording content; satisfy audit requirements without privacy violation | CORE | P1 | EPIC-2530 |
| 2533 | Data Retention Policy | Implement configurable data retention policy: per-entity-type retention periods, automatic cleanup, GDPR right-to-erasure support | CORE | P1 | EPIC-2530 |
| 2534 | Compliance Mode | Implement compliance mode: enforce PII protection, no-log, data retention, audit trail integrity; configurable per deployment | EXTENDED | P2 | EPIC-2530 |

---

## Cross-References

| Gap Feature | Existing Feature | Relationship |
|-------------|-----------------|--------------|
| 2500-2504 (Config Export/Import) | 1137, 1138 (CLI export/import) | Gap features are the backend logic; CLI features are the command interface |
| 2507 (Config Snapshot) | 1151 (PostgreSQL Backup) | Config snapshot is logical backup; 1151 is physical backup |
| 2510-2515 (Bootstrap) | 209 (Initial Admin Bootstrap) | Extends admin bootstrap to full system bootstrap |
| 2518 (Docker Hostname) | 19A (Docker Compose Dev) | Docker hostname transform needed for Docker compose environments |
| 2520-2522 (Load Shedding) | 199 (Connection Draining) | Load shedding is proactive; draining is reactive |
| 2523-2524 (Quota Sharing) | 810-814 (Token Quota) | Extends individual quotas with shared pool mechanism |
| 2525-2526 (Debug Gate) | 766 (Gateway Error Handling) | Debug gate controls error detail level |
| 2530 (No-Log Keys) | 220-229 (API Key Management) | Extends API key model with no-log flag |
| 2531 (No-Log Config) | 847 (Envelope Redaction) | No-log controls what goes into envelopes |
| 2533 (Data Retention) | 833 (Audit Event Retention) | Extends audit retention to all entity types |
