# Feature Catalog: Combos & Provider Routing

> **Series**: 102
> **Source**: diegosouza-omniroute sidebar + cybernetics-core + OmniRoute analysis
> **Purpose**: Sidebar-discoverable features from reference repos
> **Total Features**: 25

## Combos

| # | Name | Description | Source Repo | Source File | In Our Catalog? |
|---|------|-------------|-------------|-------------|-----------------|
| 102-001 | Combo Routing Engine | Multi-model ordered fallback, 4567 lines | diegosouza-omniroute | `open-sse/services/combo.ts` | ❌ GAP (015-001) |
| 102-002 | Combo Config | Throughput modes, high-throughput settings | diegosouza-omniroute | `open-sse/services/comboConfig.ts` | ❌ GAP |
| 102-003 | Combo Resolver | Resolves combo config into executable targets | diegosouza-omniroute | `src/domain/comboResolver.ts` | ❌ GAP |
| 102-004 | Combo Metrics | Intent, request metrics, parallelism data | diegosouza-omniroute | `open-sse/services/comboMetrics.ts` | ❌ GAP |
| 102-005 | Combo Agent Middleware | Model tag injection | diegosouza-omniroute | `open-sse/services/comboAgentMiddleware.ts` | ❌ GAP |
| 102-006 | Model-Combo Mappings | Map model names to specific combos | diegosouza-omniroute | `src/lib/db/modelComboMappings.ts` | ❌ GAP |
| 102-007 | Composite Tiers | Multi-tier routing with intelligent groupings | diegosouza-omniroute | `src/lib/combos/compositeTiers.ts` | ❌ GAP |
| 102-008 | Provider Pool Creator | Creates pools from provider connections | diegosouza-omniroute | `src/lib/combos/providerPoolCreator.ts` | ❌ GAP |

## Provider Quota

| # | Name | Description | Source Repo | Source File | In Our Catalog? |
|---|------|-------------|-------------|-------------|-----------------|
| 102-009 | Quota Monitoring | Real-time monitoring, preflight checks | diegosouza-omniroute | `open-sse/services/quotaMonitor.ts` | ✅ 810 |
| 102-010 | Quota Preflight | Pre-check before dispatching | diegosouza-omniroute | `open-sse/services/quotaPreflight.ts` | ✅ 819 |
| 102-011 | Quota Cache | In-memory snapshots, pre-loaded at startup | diegosouza-omniroute | `src/domain/quotaCache.ts` | ❌ GAP |
| 102-012 | Provider Limits Tracking | Upstream header parsing | diegosouza-omniroute | `src/lib/db/providerLimits.ts` | ❌ GAP |
| 102-013 | Provider Attempt Ledger | Records each attempt with status | cybernetics-core | `provider-attempt-ledger.ts` | ❌ GAP |

## Quota Sharing

| # | Name | Description | Source Repo | Source File | In Our Catalog? |
|---|------|-------------|-------------|-------------|-----------------|
| 102-014 | Quota Pool Sharing | Across keys/groups, fair-share, saturation | diegosouza-omniroute | `src/lib/quota/` (16 files) | ❌ GAP |
| 102-015 | Burn Rate Monitoring | Tracks quota consumption rate | diegosouza-omniroute | `src/lib/quota/` | ❌ GAP |

## Compression Context

| # | Name | Description | Source Repo | Source File | In Our Catalog? |
|---|------|-------------|-------------|-------------|-----------------|
| 102-016 | Context Manager | 3-layer compression, provider-aware token limits | diegosouza-omniroute | `open-sse/services/contextManager.ts` | ❌ GAP (016-001) |
| 102-017 | Thinking Budget | Thinking token allocation for o1/o3 | diegosouza-omniroute | `open-sse/services/thinkingBudget.ts` | ❌ GAP (016-020) |
| 102-018 | Payload Budget | Payload size budgets with tier limits | diegosouza-omniroute | `open-sse/services/payloadBudget.ts` | ❌ GAP |

## Engine Combos

| # | Name | Description | Source Repo | Source File | In Our Catalog? |
|---|------|-------------|-------------|-------------|-----------------|
| 102-019 | Auto-Combo Engine | Self-managing with scoring, bandit exploration | diegosouza-omniroute | `open-sse/services/autoCombo/engine.ts` | ❌ GAP (015-030) |
| 102-020 | Auto-Combo Scoring | Multi-factor: latency, cost, task fitness, reliability | diegosouza-omniroute | `autoCombo/scoring.ts` | ❌ GAP (015-031) |
| 102-021 | Auto-Combo Self-Healing | Auto-recovers from provider failures | diegosouza-omniroute | `autoCombo/selfHealing.ts` | ❌ GAP (015-032) |
| 102-022 | Auto-Combo Task Fitness | Rates providers by task suitability | diegosouza-omniroute | `autoCombo/taskFitness.ts` | ❌ GAP (015-033) |
| 102-023 | Auto-Combo Mode Packs | Preset configuration bundles | diegosouza-omniroute | `autoCombo/modePacks.ts` | ❌ GAP (015-034) |

## Tools

| # | Name | Description | Source Repo | Source File | In Our Catalog? |
|---|------|-------------|-------------|-------------|-----------------|
| 102-024 | Tool Calling Policy | Allowlist/denylist/disabled | diegosouza-omniroute | `src/lib/toolPolicy.ts` | ❌ GAP (017-020) |
| 102-025 | Tool Name Cloaking | Deterministic aliasing for Anthropic | diegosouza-omniroute | `open-sse/config/toolCloaking.ts` | ❌ GAP |
