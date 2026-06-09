# Feature Catalog: Agentic Features

> **Series**: 107
> **Source**: diegosouza-omniroute sidebar + cybernetics-core + OmniRoute analysis
> **Purpose**: Sidebar-discoverable features from reference repos
> **Total Features**: 33

## Memory

| # | Name | Description | Source Repo | Source File | In Our Catalog? |
|---|------|-------------|-------------|-------------|-----------------|
| 107-001 | Memory Extraction | Extracts memorable facts from conversations | diegosouza-omniroute | `src/lib/memory/extraction.ts` | ❌ GAP (018-001) |
| 107-002 | Memory Injection | Injects relevant memories into prompts | diegosouza-omniroute | `src/lib/memory/injection.ts` | ❌ GAP (018-002) |
| 107-003 | Memory Retrieval | Vector search retrieval | diegosouza-omniroute | `src/lib/memory/retrieval.ts` | ❌ GAP (018-003) |
| 107-004 | Memory Summarization | Conversation summarization for compact storage | diegosouza-omniroute | `src/lib/memory/summarization.ts` | ❌ GAP (018-004) |
| 107-005 | Memory Store | Persistent storage backend | diegosouza-omniroute | `src/lib/memory/store.ts` | ❌ GAP (018-005) |
| 107-006 | Vector Store | sqlite-vec with hybrid RRF search | diegosouza-omniroute | `src/lib/memory/vectorStore.ts` | ❌ GAP (018-010) |
| 107-007 | Qdrant Integration | External vector DB | diegosouza-omniroute | `src/lib/memory/qdrant.ts` | ❌ GAP (018-015) |
| 107-008 | Memory Types | FACTUAL, EPISODIC, PROCEDURAL, SEMANTIC | diegosouza-omniroute | `src/lib/memory/` | ❌ GAP (018-001) |

## AgentSkills / OmniSkills

| # | Name | Description | Source Repo | Source File | In Our Catalog? |
|---|------|-------------|-------------|-------------|-----------------|
| 107-009 | Skills Registry | DB-backed registration and discovery | diegosouza-omniroute | `src/lib/skills/registry.ts` | ❌ GAP (023-020) |
| 107-010 | Skills Executor | Execution with timeout/retry in sandbox | diegosouza-omniroute | `src/lib/skills/executor.ts` | ❌ GAP (023-021) |
| 107-011 | Skills Sandbox | Isolation with resource/time limits | diegosouza-omniroute | `src/lib/skills/sandbox.ts` | ❌ GAP (023-022) |
| 107-012 | Built-in Skills | Ship with system | diegosouza-omniroute | `src/lib/skills/builtins.ts` | ❌ GAP |
| 107-013 | Custom Skills | User-provided with sandbox isolation | diegosouza-omniroute | `src/lib/skills/custom.ts` | ❌ GAP |
| 107-014 | Skill Interception | Pre/post processing hooks | diegosouza-omniroute | `src/lib/skills/interception.ts` | ❌ GAP |
| 107-015 | Skill Injection | Inject context into prompts | diegosouza-omniroute | `src/lib/skills/injection.ts` | ❌ GAP |
| 107-016 | Skills Registry (cybernetics) | Discovery marketplace, installable, tag-based | cybernetics-core | `apps/backend/src/routers/discovery.ts` | ❌ GAP |

## MCP Server

| # | Name | Description | Source Repo | Source File | In Our Catalog? |
|---|------|-------------|-------------|-------------|-----------------|
| 107-017 | MCP Protocol Types | Core MCP protocol type definitions | — | — | ✅ 900 |
| 107-018 | MCP Client | MCP client implementation | — | — | ✅ 901 |
| 107-019 | MCP Server | MCP server implementation | — | — | ✅ 902 |
| 107-020 | MCP Transports (3) | stdio, SSE, streamable HTTP | — | — | ✅ 910-914 |
| 107-021 | MCP Tool Catalog | Tool catalog management | — | — | ✅ 920 |
| 107-022 | MCP Tool Mapper | Tool name/description mapping | — | — | ✅ 921 |
| 107-023 | MCP Tool Override | Tool behavior overrides | — | — | ✅ 922 |
| 107-024 | MCP Pool Management | Connection pool for MCP sessions | — | — | ✅ 923 |
| 107-025 | MCP Scope-Based Auth (diegosouza) | 16 scopes for MCP tools | diegosouza-omniroute | `src/shared/constants/mcpScopes.ts` | ❌ GAP (024-010) |
| 107-026 | MCP Description Compressor | Reduce token spend for tool lists | diegosouza-omniroute | `open-sse/mcp-server/descriptionCompressor.ts` | ❌ GAP |
| 107-027 | Management MCP Server (cybernetics) | Full implementation ~1019 lines | cybernetics-core | `management-mcp-server.ts` | ✅ 950 |
| 107-028 | Tool Output Redaction | Sanitize MCP tool results | cybernetics-core | `tool-output-redaction.ts` | ❌ GAP (024-005) |
| 107-029 | Tool Sync Cache | Hash-based change detection for tools | cybernetics-core | `tools-sync-cache.ts` | ❌ GAP |

## A2A Server

| # | Name | Description | Source Repo | Source File | In Our Catalog? |
|---|------|-------------|-------------|-------------|-----------------|
| 107-030 | A2A Protocol | JSON-RPC 2.0 v0.3 | — | — | ✅ 022-001 |
| 107-031 | A2A Task Manager | State machine lifecycle | — | — | ✅ 022-010 |
| 107-032 | A2A Agent Card | .well-known/agent.json | — | — | ✅ 022-015 |
| 107-033 | A2A Skills (6) | smartRouting, quotaManagement, providerDiscovery, costAnalysis, healthReport, listCapabilities | diegosouza-omniroute | `src/lib/a2a/skills/` | ❌ GAP (022-005) |
