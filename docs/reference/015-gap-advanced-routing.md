# Feature Catalog: Gap — Advanced Routing Strategies

> **Series**: 1500
> **EPICs**: EPIC-1500 (Advanced Load Balancing), EPIC-1510 (Intelligent Routing), EPIC-1520 (Specialized Routers), EPIC-1530 (Multi-Factor Auto Routing)
> **Gap Source**: diegosouza-omniroute (priority, context-relay, fill-first, P2C, random, least-used, reset-aware, auto scoring, LKGP, intent classifier, task-aware, deprecation router, wildcard router, tag router, eval-based, pipeline router)
> **Total Features**: 40

## Gap Analysis Summary

Our catalog covers core routing strategies (weighted round-robin, least-connections, least-latency, random weighted, hash-based affinity, capacity-aware, cost-aware, health-weighted) in Series 630-639 and pluggable strategies in 670-675. However, the diegosouza reference implements ~20 additional routing strategies that represent meaningful capability gaps:

1. **Priority-based routing** — simple but essential, not explicitly in our catalog
2. **Quota/reset-aware routing** — routes based on quota windows, not just capacity
3. **Context relay** — cross-model session handoff (novel)
4. **Multi-factor auto scoring** — composite scoring with sub-strategy combination
5. **Intent/task classification** — intelligent routing based on request semantics
6. **Model management routers** — deprecation routing, model family fallback, wildcard matching
7. **Pipeline routing** — multi-step sequential model chains (partially covered by 629)

Many of these extend rather than replace existing EPIC-630/640/650/670 features.

## Classification Guide

- **CORE**: Priority routing, quota-aware routing, LKGP, model deprecation routing, wildcard routing — essential for production gateway
- **EXTENDED**: Auto scoring, intent classifier, task-aware, context relay, pipeline routing — valuable for intelligent routing
- **ECOSYSTEM**: Eval-based routing, tag router — nice-to-have, niche

---

## Features

### Advanced Load Balancing Strategies (1500-1509)

| # | Name | Description | Classification | Priority | Proposed EPIC |
|---|------|-------------|---------------|----------|---------------|
| 1500 | Priority Routing | Implement ordered priority routing: iterate providers in explicit priority order, first available wins; simpler than weighted for strict preference ordering | CORE | P1 | EPIC-1500 (new) or extend EPIC-630 |
| 1501 | Fill-First Routing | Implement fill-first load balancing: maximize usage on primary provider before moving to next; fill quota on preferred provider before spilling over | CORE | P1 | EPIC-1500 |
| 1502 | Power of Two Choices (P2C) | Implement P2C load balancing: randomly pick two candidates, select the less loaded one; O(1) with good distribution | EXTENDED | P2 | EPIC-1500 |
| 1503 | Least-Used Routing | Implement least-used routing: route to provider with lowest total historical usage in current period; differs from least-connections (current vs cumulative) | CORE | P1 | EPIC-1500 |
| 1504 | True Random Routing | Implement strict random routing without fallback weighting: uniform distribution, useful for A/B testing and load distribution experiments | EXTENDED | P2 | EPIC-1500 |
| 1505 | Reset-Aware Routing | Implement reset-aware routing: consider provider quota reset windows; prefer providers whose quotas reset soonest (use capacity about to expire) | CORE | P1 | EPIC-1500 |
| 1506 | Reset-Window Ordering | Implement reset-window ordering: sort providers by quota reset timestamp, route to provider with nearest reset to maximize utilization before reset | CORE | P1 | EPIC-1500 |
| 1507 | LKGP (Last Known Good Provider) | Implement LKGP routing: track last provider that returned a successful response for this workload type; prefer it for subsequent requests; fast recovery after transient failures | CORE | P1 | EPIC-1500 |
| 1508 | Emergency Fallback Provider | Implement emergency fallback: configure a last-resort stable provider (e.g., free tier) that activates only when all primary/secondary providers are down | CORE | P1 | EPIC-1500 |
| 1509 | Strategy Composition | Support composing multiple strategies: primary strategy + tiebreaker strategy + emergency fallback; configurable per route graph node | EXTENDED | P2 | EPIC-1500 |

### Intelligent Routing (1510-1519)

| # | Name | Description | Classification | Priority | Proposed EPIC |
|---|------|-------------|---------------|----------|---------------|
| 1510 | Intent Classifier Router | Implement intent-based routing: classify request intent (coding, creative writing, analysis, translation, summarization) and route to models optimized for that intent | EXTENDED | P2 | EPIC-1510 (new) |
| 1511 | Task-Aware Router | Implement task-aware routing: analyze task characteristics (input length, expected output length, complexity, domain) and route to appropriate model tier | EXTENDED | P2 | EPIC-1510 |
| 1512 | Context-Optimized Router | Implement context-optimized routing: select model based on context window requirements; route long-context requests to models with larger context windows | CORE | P1 | EPIC-1510 |
| 1513 | Context Relay Router | Implement context relay: serialize conversation context, hand off to different model mid-conversation; restore session context on receiving model; enables cross-model session continuity | EXTENDED | P2 | EPIC-1510 |
| 1514 | Cost-Quality Tiered Router | Implement tiered routing: classify request complexity, route simple requests to cheap/fast models, complex requests to expensive/capable models; auto-tier based on input analysis | EXTENDED | P2 | EPIC-1510 |
| 1515 | Eval-Based Routing | Implement eval-based routing: maintain per-model eval scores (from eval framework), reorder routing targets by eval performance for specific task types | EXTENDED | P3 | EPIC-1510 |
| 1516 | Intent Classification Rules | Define configurable intent classification rules: keyword-based, regex-based, model-based (use small model to classify intent before routing) | EXTENDED | P2 | EPIC-1510 |
| 1517 | Routing Decision Explanation | For intelligent routers, generate human-readable explanation of routing decision: why this model was selected, what signals were considered | EXTENDED | P2 | EPIC-1510 |
| 1518 | Routing Feedback Loop | Collect routing outcome feedback: track success/failure per routing decision, use to improve future routing (online learning) | EXTENDED | P3 | EPIC-1510 |
| 1519 | Intent Router Tests | Test suite for intelligent routing: intent classification accuracy, task analysis, context-aware selection, tiered routing correctness | EXTENDED | P2 | EPIC-1510 |

### Specialized Routers (1520-1529)

| # | Name | Description | Classification | Priority | Proposed EPIC |
|---|------|-------------|---------------|----------|---------------|
| 1520 | Model Deprecation Router | Implement deprecation-aware routing: detect deprecated models in requests, auto-route to configured successor model; log migration, notify user of deprecation | CORE | P1 | EPIC-1520 (new) |
| 1521 | Model Family Fallback | Implement model family fallback: on failure, fall back within same model family (e.g., gpt-4o → gpt-4o-mini → gpt-4-turbo) before trying different providers | CORE | P1 | EPIC-1520 |
| 1522 | Wildcard Route Matching | Implement wildcard route matching: `gpt-*` matches any GPT model, `claude-*` matches any Claude model; useful for broad routing rules and model aliasing | CORE | P1 | EPIC-1520 |
| 1523 | Tag-Based Router | Implement tag-based routing: providers and models tagged with metadata (fast, cheap, compliant, region:eu, tier:premium); route based on requested tags | EXTENDED | P2 | EPIC-1520 |
| 1524 | Pipeline Router | Implement pipeline routing: multi-step sequential model calls within a single request; e.g., classify → generate → summarize; each step uses different model | EXTENDED | P2 | EPIC-1520 |
| 1525 | Model Alias Rewriting | Implement legacy model alias rewriting: map old model names to current equivalents (e.g., `gpt-3.5-turbo` → `gpt-4o-mini`); configurable alias table with hot-reload | CORE | P1 | EPIC-1520 |
| 1526 | Deprecation Schedule | Track model deprecation schedules: known deprecation dates, auto-activate deprecation routing before sunset, emit warnings | CORE | P1 | EPIC-1520 |
| 1527 | Model Family Registry | Define model families: group models by family (GPT-4, Claude 3.x, Gemini 2.x), track intra-family compatibility for fallback purposes | CORE | P1 | EPIC-1520 |
| 1528 | Pipeline Step Configuration | Configure pipeline router steps: model per step, input/output mapping between steps, conditional step execution, error handling per step | EXTENDED | P2 | EPIC-1520 |
| 1529 | Specialized Router Tests | Test suite for specialized routers: deprecation routing, family fallback, wildcard matching, pipeline execution, alias rewriting | CORE | P1 | EPIC-1520 |

### Multi-Factor Auto Routing (1530-1539)

| # | Name | Description | Classification | Priority | Proposed EPIC |
|---|------|-------------|---------------|----------|---------------|
| 1530 | Auto Scoring Engine | Implement multi-factor auto scoring: composite score from configurable weighted factors (cost, latency, error rate, capacity, compliance, eco, SLA) | CORE | P1 | EPIC-1530 (new) |
| 1531 | Scoring Factor: Cost | Cost scoring factor: rank providers by per-token cost, normalize to 0-1 score, configurable weight | CORE | P1 | EPIC-1530 |
| 1532 | Scoring Factor: Latency | Latency scoring factor: rank by p50/p99 latency from sliding window, normalize to 0-1 score | CORE | P1 | EPIC-1530 |
| 1533 | Scoring Factor: Error Rate | Error rate scoring factor: rank by recent error rate from sliding window, penalize high error rates | CORE | P1 | EPIC-1530 |
| 1534 | Scoring Factor: Capacity | Capacity scoring factor: rank by remaining quota/rate-limit headroom, penalize providers near limits | CORE | P1 | EPIC-1530 |
| 1535 | Scoring Factor: SLA Compliance | SLA scoring factor: rank by SLA compliance percentage (uptime, latency targets), penalize SLA violations | EXTENDED | P2 | EPIC-1530 |
| 1536 | Scoring Factor: Eco/Carbon | Eco scoring factor: optional carbon-awareness weighting, prefer providers with lower energy/carbon footprint | EXTENDED | P3 | EPIC-1530 |
| 1537 | Auto Score Configuration | Configure auto scoring per route graph: enable/disable factors, set weights, set minimum score threshold | CORE | P1 | EPIC-1530 |
| 1538 | Score Caching | Cache computed scores with short TTL: avoid re-computing on every request, refresh on provider state change | CORE | P1 | EPIC-1530 |
| 1539 | Auto Scoring Metrics | Track auto scoring metrics: score distribution per provider, factor contribution breakdown, selection frequency | CORE | P1 | EPIC-1530 |

---

## Cross-References

| Gap Feature | Existing Feature | Relationship |
|-------------|-----------------|--------------|
| 1500 (Priority) | 650 (Ordered Fallback) | Priority routing is strict ordering; fallback is failure-triggered |
| 1503 (Least-Used) | 631 (Least Connections) | Least-used is cumulative; least-connections is concurrent |
| 1507 (LKGP) | 637 (Health-Weighted) | LKGP is per-workload-type stickiness; health-weighted is global |
| 1510-1511 (Intent/Task) | 616 (Priority Classification) | Intent router extends workload classification to routing |
| 1512 (Context-Optimized) | 324 (Model Capability Matrix) | Uses capability matrix data for context window matching |
| 1520 (Deprecation) | 303 (Capability Status) | Deprecation router uses capability status lifecycle |
| 1522 (Wildcard) | 322 (Model Alias) | Wildcard extends alias system with pattern matching |
| 1524 (Pipeline) | 629 (Multi-Model Planning) | Pipeline is explicit multi-step; 629 is planner-driven |
| 1525 (Alias Rewriting) | 322 (Model Alias System) | Extends existing alias system with hot-reload and deprecation |
| 1530 (Auto Scoring) | 621 (Capability Scoring) | Auto scoring is a multi-factor extension of capability scoring |
