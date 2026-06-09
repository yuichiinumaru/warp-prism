# Feature Catalog: Gap — Advanced Caching

> **Series**: 2100
> **EPICs**: EPIC-2100 (Signature & Prompt Cache), EPIC-2110 (Request Deduplication & Idempotency), EPIC-2120 (Reasoning Cache)
> **Gap Source**: diegosouza-omniroute (signature cache, prompt cache, reasoning cache, request dedup, idempotency layer)
> **Total Features**: 25

## Gap Analysis Summary

Our catalog has a semantic cache system (870-879) covering exact-match caching,  cache key generation, TTL strategies, and embedding-based similarity cache. We also have workload fingerprinting (617), classification caching (618), and request deduplication (784 at P2). However, we lack:

- **Signature cache** — content-aware request dedup beyond simple hash matching
- **Prompt cache** — deduplicate identical system prompts across requests (50 entries, 2MB, 5min TTL)
- **Reasoning cache** — cache and re-inject reasoning/thinking content across turns
- **Full idempotency layer** — `X-Request-Id` / `Idempotency-Key` based dedup with storage
- **Request coalescing** — coalesce concurrent identical requests into single upstream call

These are orthogonal to our existing semantic cache and represent important optimization layers.

## Classification Guide

- **CORE**: Idempotency layer, request dedup/coalescing — essential for production reliability
- **EXTENDED**: Prompt cache, signature cache, reasoning cache — optimization features

---

## Features

### Signature & Prompt Cache (2100-2109)

| # | Name | Description | Classification | Priority | Proposed EPIC |
|---|------|-------------|---------------|----------|---------------|
| 2100 | Signature Cache | Implement content-signature cache: generate signature from normalized request content (model + messages + params), deduplicate identical requests within configurable window | EXTENDED | P2 | EPIC-2100 (new) |
| 2101 | Signature Generation | Generate request signatures: normalize request (sort params, trim whitespace, canonicalize messages), hash with BLAKE3; signature used for dedup and cache lookup | EXTENDED | P2 | EPIC-2100 |
| 2102 | Prompt Cache | Implement prompt cache: cache system prompts by content hash; when same system prompt appears in multiple requests, reuse cached token count and preprocessing | EXTENDED | P2 | EPIC-2100 |
| 2103 | Prompt Cache Limits | Enforce prompt cache limits: max entries (default 50), max total size (default 2MB), TTL (default 5min); LRU eviction | EXTENDED | P2 | EPIC-2100 |
| 2104 | Prompt Cache Key | Generate prompt cache key: hash of system prompt content + model; different models may tokenize differently | EXTENDED | P2 | EPIC-2100 |
| 2105 | Provider Prompt Caching | Forward provider-side prompt caching hints: OpenAI `cached_prompt_tokens`, Anthropic `cache_creation_input_tokens`; track cache savings | CORE | P1 | EPIC-2100 |
| 2106 | Cache-Aware Cost Calculation | Adjust cost calculation for cache hits: provider-cached prompts cost less (Anthropic: 10% of normal), track savings separately | CORE | P1 | EPIC-2100 |
| 2107 | Cache Layer Hierarchy | Implement cache layer hierarchy: L1 local in-memory (sub-ms) → L2 Redis (1-5ms) → L3 cache miss (upstream); configurable per cache type | CORE | P1 | EPIC-2100 |
| 2108 | Cache Warming | Support cache warming: precompute cache entries for known-frequent requests (scheduled or trigger-based) | ECOSYSTEM | P3 | EPIC-2100 |
| 2109 | Signature Cache Tests | Test suite for signature and prompt caching: key generation, hit/miss, eviction, TTL, cost savings tracking | EXTENDED | P2 | EPIC-2100 |

### Request Deduplication & Idempotency (2110-2119)

| # | Name | Description | Classification | Priority | Proposed EPIC |
|---|------|-------------|---------------|----------|---------------|
| 2110 | Idempotency Key Support | Implement `Idempotency-Key` header support: store response for idempotency key in Redis, return stored response on duplicate request within window | CORE | P1 | EPIC-2110 (new) |
| 2111 | X-Request-Id Dedup | Implement `X-Request-Id` based dedup: detect duplicate request IDs within configurable window, return cached or in-progress result | CORE | P1 | EPIC-2110 |
| 2112 | Idempotency Store | Store idempotency records in Redis: key → {status, response, created, expires}; configurable TTL (default 24h) | CORE | P1 | EPIC-2110 |
| 2113 | Idempotency Conflict Detection | Detect idempotency conflicts: same key with different request body → return 422 Unprocessable Entity; prevent accidental key reuse | CORE | P1 | EPIC-2110 |
| 2114 | Request Coalescing | Implement request coalescing: detect concurrent identical requests (same signature), send single upstream request, share result with all waiters | CORE | P1 | EPIC-2110 |
| 2115 | Coalescing Wait Group | Implement coalescing wait group: first request triggers upstream call, subsequent identical requests join wait group, all receive same response | CORE | P1 | EPIC-2110 |
| 2116 | Coalescing Timeout | Enforce coalescing timeout: waiters timeout independently, coalescing key expires after last waiter leaves or TTL | CORE | P1 | EPIC-2110 |
| 2117 | Idempotency for Streaming | Handle idempotency for streaming requests: replay stored stream chunks on duplicate request, or buffer and replay complete response | EXTENDED | P2 | EPIC-2110 |
| 2118 | Dedup Metrics | Track dedup metrics: idempotency hit rate, coalescing rate, upstream calls saved, duplicate request volume | CORE | P1 | EPIC-2110 |
| 2119 | Dedup & Idempotency Tests | Test suite for dedup: idempotency key storage, conflict detection, request coalescing, concurrent waiters, streaming replay | CORE | P1 | EPIC-2110 |

### Reasoning Cache (2120-2124)

| # | Name | Description | Classification | Priority | Proposed EPIC |
|---|------|-------------|---------------|----------|---------------|
| 2120 | Reasoning Content Cache | Cache reasoning/thinking content from reasoning models: store thinking output keyed by conversation hash, re-inject on follow-up turns to preserve reasoning chain | EXTENDED | P2 | EPIC-2120 (new) |
| 2121 | Reasoning Cache Injection | Re-inject cached reasoning content on multi-turn conversations: include previous thinking as context to reduce re-computation and improve consistency | EXTENDED | P2 | EPIC-2120 |
| 2122 | Reasoning Cache Key | Generate reasoning cache key: hash of conversation history + model; invalidate when conversation diverges | EXTENDED | P2 | EPIC-2120 |
| 2123 | Reasoning Cache TTL | Configure reasoning cache TTL: per-model, per-exposure; shorter TTL for creative tasks, longer for analytical | EXTENDED | P2 | EPIC-2120 |
| 2124 | Reasoning Cache Tests | Test suite for reasoning cache: cache hit/miss, injection, key generation, TTL, multi-model handling | EXTENDED | P2 | EPIC-2120 |

---

## Cross-References

| Gap Feature | Existing Feature | Relationship |
|-------------|-----------------|--------------|
| 2100 (Signature Cache) | 871 (Exact Match Cache) | Signature cache is content-normalized version of exact match |
| 2101 (Signature Gen) | 617 (Workload Fingerprinting) | Extends fingerprinting with normalization for cache use |
| 2102 (Prompt Cache) | 1613 (System Prompt Dedup) | Prompt cache is runtime; dedup is compression-time |
| 2105 (Provider Caching) | 718, 727 (Rate Limit Parsing) | Similar pattern: parse provider response metadata |
| 2106 (Cache-Aware Cost) | 615 (Cost Estimation) | Adjusts cost calculation for cached tokens |
| 2107 (Cache Hierarchy) | 352, 873 (Local + Redis Cache) | Formalizes existing two-level caching pattern |
| 2110-2111 (Idempotency) | 759 (Execution Idempotency) | Extends execution-level idempotency to full request lifecycle |
| 2114-2116 (Request Coalescing) | 784 (Request Dedup) | Concrete implementation of the P2 dedup feature |
| 2120-2121 (Reasoning Cache) | 1625 (Reasoning Content Caching) | Same concept; cross-referenced between memory and cache catalogs |
