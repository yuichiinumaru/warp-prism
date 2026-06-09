# Feature Catalog: Analytics & Monitoring

> **Series**: 104
> **Source**: diegosouza-omniroute sidebar + cybernetics-core + OmniRoute analysis
> **Purpose**: Sidebar-discoverable features from reference repos
> **Total Features**: 27

## Usage

| # | Name | Description | Source Repo | Source File | In Our Catalog? |
|---|------|-------------|-------------|-------------|-----------------|
| 104-001 | Usage Tracking | Per-request token/cost | diegosouza-omniroute | `open-sse/services/usage.ts` | ✅ 850 |
| 104-002 | Usage Analytics | Historical analytics with visualizations | diegosouza-omniroute | `src/lib/usageAnalytics.ts` | ✅ 851 |
| 104-003 | Usage Summary | Aggregated per-key summaries | diegosouza-omniroute | `src/lib/db/usageSummary.ts` | ✅ 852 |
| 104-004 | Spend Batch Writer | Batched writes (60s/1000 entries) | diegosouza-omniroute | `src/lib/spend/batchWriter.ts` | ❌ GAP |
| 104-005 | Token Limit Counter | Per-request token counting | diegosouza-omniroute | `open-sse/services/tokenLimitCounter.ts` | ❌ GAP |

## Combo Health

| # | Name | Description | Source Repo | Source File | In Our Catalog? |
|---|------|-------------|-------------|-------------|-----------------|
| 104-006 | Combo Health Dashboard | Health status of routing combos | diegosouza-omniroute | UI | ❌ GAP (implied by routing) |
| 104-007 | Provider Health | Circuit breaker states, latency | — | — | ✅ 640-642 |

## Cache

| # | Name | Description | Source Repo | Source File | In Our Catalog? |
|---|------|-------------|-------------|-------------|-----------------|
| 104-008 | Cache Stats | Hit/miss rates | diegosouza-omniroute | `open-sse/mcp-server/tools/cacheTools.ts` | ✅ 860 |
| 104-009 | Cache Flush | Clear cache | diegosouza-omniroute | MCP tools | ✅ 860 |

## Compression

| # | Name | Description | Source Repo | Source File | In Our Catalog? |
|---|------|-------------|-------------|-------------|-----------------|
| 104-010 | Compression Stats | Per-request tracking: original/compressed tokens, savings% | diegosouza-omniroute | `open-sse/services/compression/stats.ts` | ❌ GAP (016-010) |
| 104-011 | Compression Cache Stats | Compression analytics | diegosouza-omniroute | `src/lib/db/compressionCacheStats.ts` | ❌ GAP |
| 104-012 | Compression Combos | Named compression configs per routing combo | diegosouza-omniroute | `src/lib/db/compressionCombos.ts` | ❌ GAP (016-015) |

## Provider Stats

| # | Name | Description | Source Repo | Source File | In Our Catalog? |
|---|------|-------------|-------------|-------------|-----------------|
| 104-013 | Provider Stats | Per-provider statistics | diegosouza-omniroute | `src/lib/db/providerStats.ts` | ✅ 840 |
| 104-014 | Provider Cost Data | Per-provider pricing | diegosouza-omniroute | `open-sse/services/providerCostData.ts` | ❌ GAP |
| 104-015 | Pricing Sync | Auto-sync from LiteLLM (24h) | diegosouza-omniroute | `src/lib/pricingSync.ts` | ❌ GAP (025-020) |

## Costs

| # | Name | Description | Source Repo | Source File | In Our Catalog? |
|---|------|-------------|-------------|-------------|-----------------|
| 104-016 | Cost Calculator | Calculates costs from token usage | diegosouza-omniroute | `src/lib/usage/costCalculator.ts` | ✅ 816 |
| 104-017 | Cost Rules | Budget enforcement | diegosouza-omniroute | `src/domain/costRules.ts` | ✅ 816 |
| 104-018 | Budget Guard | Per-key budget enforcement | diegosouza-omniroute | `src/lib/jobs/budgetResetJob.ts` | ✅ 816 |
| 104-019 | Credit Balance | Per-key credit tracking | diegosouza-omniroute | `src/lib/db/creditBalance.ts` | ❌ GAP |
| 104-020 | Batch Cost Estimator | Estimates cost for batch jobs | diegosouza-omniroute | `src/lib/batches/costEstimator.ts` | ❌ GAP |
| 104-021 | Provider Plans | Subscription plan tracking | diegosouza-omniroute | `src/lib/db/providerPlans.ts` | ❌ GAP |
| 104-022 | Budget Policies (cybernetics) | Scope types (global/task/agent), budget kinds (dollar/token), window kinds | cybernetics-core | `runtime-cost-budget.ts` | ❌ GAP (025-025) |

## Evals

| # | Name | Description | Source Repo | Source File | In Our Catalog? |
|---|------|-------------|-------------|-------------|-----------------|
| 104-023 | Eval Runner | Generic eval framework | diegosouza-omniroute | `src/lib/evals/evalRunner.ts` | ❌ GAP |
| 104-024 | Eval Runtime | Execution environment | diegosouza-omniroute | `src/lib/evals/runtime.ts` | ❌ GAP |
| 104-025 | Eval DB | Results persistence | diegosouza-omniroute | `src/lib/db/evals.ts` | ❌ GAP |

## Monitoring

| # | Name | Description | Source Repo | Source File | In Our Catalog? |
|---|------|-------------|-------------|-------------|-----------------|
| 104-026 | Activity Monitoring | Real-time activity dashboard | diegosouza-omniroute | UI | ✅ 840-844 |
| 104-027 | Webhook Dispatcher | HMAC-signed delivery, 7 event types | diegosouza-omniroute | `src/lib/webhookDispatcher.ts` | ❌ GAP (019-001) |
