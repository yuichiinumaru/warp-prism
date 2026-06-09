# Feature Catalog: System & Development Tools

> **Series**: 106
> **Source**: diegosouza-omniroute sidebar + cybernetics-core + OmniRoute analysis
> **Purpose**: Sidebar-discoverable features from reference repos
> **Total Features**: 15

## System / Health

| # | Name | Description | Source Repo | Source File | In Our Catalog? |
|---|------|-------------|-------------|-------------|-----------------|
| 106-001 | Health Check | GET /healthz, DB + Redis status | — | — | ✅ 191 |
| 106-002 | Readiness Probe | Deep readiness with dependency checks | — | — | ✅ 192 |
| 106-003 | Proxy Health Checks | Fast-fail (2s timeout), 30s cache TTL | diegosouza-omniroute | `src/lib/proxyHealth.ts` | ❌ GAP |
| 106-004 | DB Health Check | Periodic integrity checks (6h default) | diegosouza-omniroute | `src/lib/db/healthCheck.ts` | ❌ GAP |
| 106-005 | Runtime Info | Go version, binary version, uptime, config summary | — | — | ✅ 107 |

## Runtime

| # | Name | Description | Source Repo | Source File | In Our Catalog? |
|---|------|-------------|-------------|-------------|-----------------|
| 106-006 | Config Hot-Reload | 5s polling for runtime changes | diegosouza-omniroute | `src/lib/config/hotReload.ts` | ❌ GAP |
| 106-007 | Version Manager | Track and manage versions | diegosouza-omniroute | `src/lib/versionManager/` | ❌ GAP |
| 106-008 | Graceful Shutdown | Wait in-flight (30s) before force exit | — | — | ✅ 181 |

## Dev Tools / Translator

| # | Name | Description | Source Repo | Source File | In Our Catalog? |
|---|------|-------------|-------------|-------------|-----------------|
| 106-009 | Request Translator | OpenAI↔Anthropic, OpenAI↔Gemini format translation | diegosouza-omniroute | `open-sse/translator/request/` | ❌ GAP |
| 106-010 | Response Translator | Upstream responses back to client format | diegosouza-omniroute | `open-sse/translator/response/` | ❌ GAP |
| 106-011 | Format Registry | Registered format mappings | diegosouza-omniroute | `open-sse/translator/registry.ts` | ❌ GAP |
| 106-012 | Responses Transformer | Chat Completions SSE → Responses API events | diegosouza-omniroute | `open-sse/transformer/responsesTransformer.ts` | ❌ GAP |

## Playground

| # | Name | Description | Source Repo | Source File | In Our Catalog? |
|---|------|-------------|-------------|-------------|-----------------|
| 106-013 | Playground Studio | Interactive prompt testing with compare mode (4 columns) | diegosouza-omniroute | `src/lib/playground/` | ❌ GAP (UI feature, implies backend API) |
| 106-014 | Prompt Improvement | AI-assisted prompt refinement | diegosouza-omniroute | `src/lib/playground/` | ❌ GAP |

## Search Tools

| # | Name | Description | Source Repo | Source File | In Our Catalog? |
|---|------|-------------|-------------|-------------|-----------------|
| 106-015 | Search Provider Testing | Test search providers from admin | diegosouza-omniroute | UI | ✅ 1161 (CLI) |
