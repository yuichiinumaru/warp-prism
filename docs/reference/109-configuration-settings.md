# Feature Catalog: Configuration & Settings

> **Series**: 109
> **Source**: diegosouza-omniroute sidebar + cybernetics-core + OmniRoute analysis
> **Purpose**: Sidebar-discoverable features from reference repos
> **Total Features**: 47

## General Settings

| # | Name | Description | Source Repo | Source File | In Our Catalog? |
|---|------|-------------|-------------|-------------|-----------------|
| 109-001 | Config Loading | Env + optional YAML | — | — | ✅ 110-115 |
| 109-002 | Config Key-Value Store | Dynamic config storage | cybernetics-core | `config.service.ts` | ✅ 110 |
| 109-003 | Bootstrap Service | Env-based automated setup | cybernetics-core | `bootstrap.service.ts` | ❌ GAP (025-010) |
| 109-004 | Config Import/Export | JSON with redacted secrets | cybernetics-core | `mcp-config-import-export.ts` | ❌ GAP (025-001) |
| 109-005 | Legacy Router Backup Import | Import from legacy OmniRoute backups | cybernetics-core | `legacy-router-backup-import.ts` | ❌ GAP |

## AI Settings

| # | Name | Description | Source Repo | Source File | In Our Catalog? |
|---|------|-------------|-------------|-------------|-----------------|
| 109-006 | Model Alias System | Legacy model alias rewriting | diegosouza-omniroute | `src/lib/modelAliasSeed.ts` | ❌ GAP |
| 109-007 | Model Deprecation Handler | Auto-route deprecated models | diegosouza-omniroute | `open-sse/services/modelDeprecation.ts` | ❌ GAP (015-020) |
| 109-008 | Model Family Fallback | Intra-family fallback | diegosouza-omniroute | `open-sse/services/modelFamilyFallback.ts` | ❌ GAP (015-021) |
| 109-009 | Default Model Settings | Temperature, max_tokens, top_p defaults | diegosouza-omniroute | config | ✅ 702 |

## Global Routing

| # | Name | Description | Source Repo | Source File | In Our Catalog? |
|---|------|-------------|-------------|-------------|-----------------|
| 109-010 | Routing Strategies (16) | Priority, weighted, round-robin, context-relay, fill-first, p2c, random, least-used, cost-optimized, reset-aware, reset-window, strict-random, auto, lkgp, context-optimized | diegosouza-omniroute | `routingStrategies.ts` | ❌ GAP (015-001 through 015-016) |
| 109-011 | Emergency Fallback | Last-resort to free provider | diegosouza-omniroute | `open-sse/services/emergencyFallback.ts` | ❌ GAP (015-022) |
| 109-012 | Wildcard Router | gpt-* matching | diegosouza-omniroute | `open-sse/services/wildcardRouter.ts` | ❌ GAP (015-023) |
| 109-013 | Intent Classifier | Classify request intent | diegosouza-omniroute | `open-sse/services/intentClassifier.ts` | ❌ GAP (015-024) |
| 109-014 | Task-Aware Router | Route by task characteristics | diegosouza-omniroute | `open-sse/services/taskAwareRouter.ts` | ❌ GAP (015-025) |
| 109-015 | Tag Router | Route by connection tags | diegosouza-omniroute | `src/domain/tagRouter.ts` | ❌ GAP (015-026) |
| 109-016 | Eval-Based Routing | Reorder by eval scores | diegosouza-omniroute | `open-sse/services/evalRouting.ts` | ❌ GAP (015-027) |
| 109-017 | Pipeline Router | Multi-step sequential model calls | diegosouza-omniroute | `autoCombo/pipelineRouter.ts` | ❌ GAP (015-028) |

## Resilience

| # | Name | Description | Source Repo | Source File | In Our Catalog? |
|---|------|-------------|-------------|-------------|-----------------|
| 109-018 | Circuit Breaker | Per-provider with configurable thresholds | — | — | ✅ 640-642 |
| 109-019 | Rate Limit Manager | Token bucket per key+provider | — | — | ✅ 800-808 |
| 109-020 | Account Semaphore | Per-account concurrency | diegosouza-omniroute | `open-sse/services/accountSemaphore.ts` | ✅ 814 |
| 109-021 | Account Fallback | Switch account on quota/rate limit | diegosouza-omniroute | `open-sse/services/accountFallback.ts` | ❌ GAP |
| 109-022 | Volume Detector | Detect spikes, trigger load-shedding | diegosouza-omniroute | `open-sse/services/volumeDetector.ts` | ❌ GAP |
| 109-023 | Request Deduplication | Dedup concurrent identical requests | diegosouza-omniroute | `open-sse/services/requestDedup.ts` | ❌ GAP (021-010) |
| 109-024 | Idempotency Layer | X-Request-Id / Idempotency-Key | diegosouza-omniroute | `src/lib/idempotencyLayer.ts` | ❌ GAP (021-015) |
| 109-025 | Degradation Framework | Full→Reduced→Minimal→Safe Default | diegosouza-omniroute | `src/domain/degradation.ts` | ❌ GAP |

## Advanced

| # | Name | Description | Source Repo | Source File | In Our Catalog? |
|---|------|-------------|-------------|-------------|-----------------|
| 109-026 | Payload Rules | Hot-reloadable JSON rules per model/protocol | diegosouza-omniroute | `open-sse/services/payloadRules.ts` | ❌ GAP (023-030) |
| 109-027 | Tier Configuration | Multi-tier model configs | diegosouza-omniroute | `open-sse/services/tierConfig.ts` | ❌ GAP |
| 109-028 | CLI Fingerprint Compat | Reorder headers/body to match official CLIs | diegosouza-omniroute | `cliFingerprints.ts` | ❌ GAP (N/A) |
| 109-029 | User-Agent Overrides | Custom UA per provider | diegosouza-omniroute | `.env.example:719` | ❌ GAP (N/A) |
| 109-030 | TLS Fingerprint Spoofing | Chrome 124 TLS mimic | diegosouza-omniroute | — | ❌ GAP (N/A) |
| 109-031 | Docker Hostname Transform | localhost→host.docker.internal | cybernetics-core | `.env:37` | ❌ GAP |
| 109-032 | Split-Port Mode | Dashboard and API on separate ports | diegosouza-omniroute | `src/lib/runtime/ports.ts` | ❌ GAP |
| 109-033 | Upstream Proxy | Route calls through HTTP/SOCKS5 proxy | diegosouza-omniroute | `.env.example:369` | ❌ GAP |

## Security

| # | Name | Description | Source Repo | Source File | In Our Catalog? |
|---|------|-------------|-------------|-------------|-----------------|
| 109-034 | SSRF Protection | DNS pinning, private range blocking | — | — | ✅ 1C0-1C8 |
| 109-035 | CORS Configuration | Configurable CORS policies | — | — | ✅ 245 |
| 109-036 | CSRF Protection | Token-based CSRF prevention | — | — | ✅ 240-244 |
| 109-037 | API Key Encryption | Encrypted key storage at rest | — | — | ✅ 222 |
| 109-038 | Storage Encryption | Full DB encryption at rest | diegosouza-omniroute | `src/lib/db/encryption.ts` | ❌ GAP |
| 109-039 | Web Cookie Provider Blocking | Blocks -web/-browser-session providers | cybernetics-core | `web-cookie-provider-policy.ts` | ❌ GAP |
| 109-040 | Value-Moving Tool Gate | Policy gate for trade/transfer/payment | cybernetics-core | `value-moving-tool-action-gate.ts` | ❌ GAP (024-015) |
| 109-041 | Machine Token Auth | HMAC-SHA256 CLI machine-ID auth | diegosouza-omniroute | `src/lib/machineToken.ts` | ❌ GAP |
| 109-042 | Compliance / No-Log Keys | GDPR no-logging | diegosouza-omniroute | `src/lib/compliance/` | ❌ GAP (025-030) |

## Feature Flags

| # | Name | Description | Source Repo | Source File | In Our Catalog? |
|---|------|-------------|-------------|-------------|-----------------|
| 109-043 | Feature Flags | Toggleable feature flags | — | — | ✅ 119 |
| 109-044 | Feature Flags (DB-backed) | Persistent feature flag storage | diegosouza-omniroute | `src/lib/db/featureFlags.ts` | ✅ 119 |

## Registration Controls

| # | Name | Description | Source Repo | Source File | In Our Catalog? |
|---|------|-------------|-------------|-------------|-----------------|
| 109-045 | Disable Signup | Block new user registration | cybernetics-core | `DISABLE_SIGNUP` | ❌ GAP |
| 109-046 | Disable SSO Signup | Block SSO-based registration | cybernetics-core | `DISABLE_SSO_SIGNUP` | ❌ GAP |
| 109-047 | Disable Basic Auth | Disable username/password auth | cybernetics-core | `DISABLE_BASIC_AUTH` | ❌ GAP |
