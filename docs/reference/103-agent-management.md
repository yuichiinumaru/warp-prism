# Feature Catalog: Agent Management

> **Series**: 103
> **Source**: diegosouza-omniroute sidebar + cybernetics-core + OmniRoute analysis
> **Purpose**: Sidebar-discoverable features from reference repos
> **Total Features**: 21

## CLI Code's / CLI Agents

| # | Name | Description | Source Repo | Source File | In Our Catalog? |
|---|------|-------------|-------------|-------------|-----------------|
| 103-001 | Claude Code | Anthropic OAuth | diegosouza-omniroute | `providers.ts:191` | ❌ GAP (provider) |
| 103-002 | OpenAI Codex | Codex CLI OAuth | diegosouza-omniroute | `providers.ts:209` | ❌ GAP |
| 103-003 | Gemini CLI | Google Cloud Code OAuth | diegosouza-omniroute | `providers.ts:141` | ❌ GAP |
| 103-004 | Cursor IDE | Cursor OAuth | diegosouza-omniroute | `providers.ts:231` | ❌ GAP |
| 103-005 | Windsurf (Devin CLI) | Device-code login | diegosouza-omniroute | `providers.ts:291` | ❌ GAP |
| 103-006 | Kilo Code | OAuth | diegosouza-omniroute | `providers.ts:272` | ❌ GAP |
| 103-007 | Cline | Extension OAuth | diegosouza-omniroute | `providers.ts:281` | ❌ GAP |

## ACP Agents

| # | Name | Description | Source Repo | Source File | In Our Catalog? |
|---|------|-------------|-------------|-------------|-----------------|
| 103-008 | ACP Registry | CLI-as-backend transport | diegosouza-omniroute | `src/lib/acp/registry.ts` | ❌ GAP (022-020) |
| 103-009 | ACP Manager | Spawns CLI agents as child processes | diegosouza-omniroute | `src/lib/acp/manager.ts` | ❌ GAP (022-021) |

## Cloud Agents

| # | Name | Description | Source Repo | Source File | In Our Catalog? |
|---|------|-------------|-------------|-------------|-----------------|
| 103-010 | Codex Cloud | Cloud-based agent | diegosouza-omniroute | `src/lib/cloudAgent/agents/codex.ts` | ❌ GAP |
| 103-011 | Devin Cloud | Cloud-based agent | diegosouza-omniroute | `src/lib/cloudAgent/agents/devin.ts` | ❌ GAP |
| 103-012 | Jules Cloud | Cloud-based agent | diegosouza-omniroute | `src/lib/cloudAgent/agents/jules.ts` | ❌ GAP |
| 103-013 | Cloud Agent Base | Abstract base class for cloud agents | diegosouza-omniroute | `src/lib/cloudAgent/` | ❌ GAP |

## Agent Bridge

| # | Name | Description | Source Repo | Source File | In Our Catalog? |
|---|------|-------------|-------------|-------------|-----------------|
| 103-014 | Context Handoff | Serialize/restore session for cross-model handoff | diegosouza-omniroute | `open-sse/services/contextHandoff.ts` | ❌ GAP (016-030) |
| 103-015 | Context-Relay Strategy | Serializes context for cross-model relay | diegosouza-omniroute | `routingStrategies.ts:5` | ❌ GAP (015-005) |

## Traffic Inspector

| # | Name | Description | Source Repo | Source File | In Our Catalog? |
|---|------|-------------|-------------|-------------|-----------------|
| 103-016 | MITM Proxy | Certificate management, DNS handling, target routing | diegosouza-omniroute | `src/mitm/` (18 files) | ❌ GAP (N/A for Go) |
| 103-017 | Traffic Inspector | HTTP proxy for capturing LLM traffic, HAR export | diegosouza-omniroute | `src/lib/inspector/` | ❌ GAP (N/A for Go) |
| 103-018 | Secret Masking (Inspector) | Secrets masked in traffic captures | diegosouza-omniroute | `src/lib/inspector/secretMask.ts` | ❌ GAP |

## Integrations

| # | Name | Description | Source Repo | Source File | In Our Catalog? |
|---|------|-------------|-------------|-------------|-----------------|
| 103-019 | Notion Integration | MCP tools for Notion | diegosouza-omniroute | `open-sse/mcp-server/tools/notionTools.ts` | ❌ GAP (N/A — specific MCP tool) |
| 103-020 | Obsidian Integration | Vault sync | diegosouza-omniroute | `src/lib/obsidianSync.ts` | ❌ GAP (N/A) |
| 103-021 | GitHub Issues | Dashboard issue reporting via PAT | diegosouza-omniroute | `.env.example:1230` | ❌ GAP (N/A) |
