# Dashboard: MCP Server

**Page Title:** MCP Server
**Subtitle:** Model Context Protocol server management and tools
**Breadcrumb:** Dashboard > MCP

---

## Left Sidebar

Identical sidebar to other dashboard pages. Red/pink square icon labeled **Cybernetics-Core** v1.2.28 at top. Navigation sections:

### OMNIPROXY
- Endpoints, API Keys, Providers, Combos, Combo Studio, Provider Quota, API Endpoints, Webhooks, Proxy

### ANALYTICS
- Usage, Combo Health, Utilization, Cache, Compression, Search, Eval, Provider Stats

### MONITORING
- Activity, Logs, Proxy Logs, Console Logs, Audit Log, MCP Audit, A2A Audit

### AGENTIC FEATURES
- Memory, AgentSkills, OmniSkills, **MCP Server** (currently selected, highlighted in red/pink text), A2A Server, Plugins

### OTHER FEATURES
- Media, Batch Jobs, Files

### CONFIGURATION
- (collapsed)

### HELP
- Docs, Issues, Changelog

Bottom: Green **Restart** button, Red **Shut...** button.

---

## Top Bar

- "Quick nav" search with `Ctrl+/` hint
- EN language selector
- Bell, warning triangle, and user/settings icons

---

## Page Header

- **Heading:** "MCP Server" with a green circuit-like icon to the left
- **Subtitle:** "Model Context Protocol server management and tools"
- **Breadcrumb:** Dashboard > MCP

---

## Info Banner

A light gray info banner at the top of the content area with a green checkmark icon:

> **Model Content Protocol** — 37 tools across 13 scopes, 3 transports (stdio / SSE / Streamable HTTP).
>
> 1. Run via
> 2. Configure your MCP client to connect over stdio transport.
> 3. Invoke tools like and...

**Right side of banner:** Green dot indicator with text "**Online**" and a green toggle switch in the **ON** position.

---

## Transport Mode Section

**Section Title:** `swap_horiz` Transport Mode (with a swap icon)

Three transport mode options displayed as cards:

| Transport | Description | Status |
|-----------|-------------|--------|
| **stdio** | Local — IDE spawns process via omniroute --mcp | (appears selected/active) |
| **SSE** | Remote — Server-Sent Events over HTTP | (not selected) |
| **Streamable HTTP** | Remote — Modern bidirectional HTTP | **selected** (highlighted with blue/purple border) |

Below the cards:
- **link:** `http://localhost:2000/api/mcp/stream`
- **Copy** button (right-aligned)

---

## Process Status Section

Four status cards in a row:

| Card | Value |
|------|-------|
| **PROCESS STATUS** | Online |
| **PID** | — (dash, no value) |
| **SESSION UPTIME** | — (dash, no value) |
| **LAST HEARTBEAT** | — (dash, no value) |

---

## Activity (24h) Section

**Section Title:** "Activity (24h)"

Three metric cards:

| Metric | Value |
|--------|-------|
| **TOTAL CALLS** | 0 |
| **SUCCESS RATE** | 0.0% |
| **AVG LATENCY** | 0ms |

**Top tools:** "No tool calls in the last 24 hours."

**Runtime details:**
- Transport: streamable-http
- Scopes enforced: no
- Last call: — (dash)
- Heartbeat path: `/app/data/runtime/mcp-heartbeat.json`

---

## Operational Controls Section

**Section Title:** "Operational controls"

Three control panels:

### 1. Switch combo
- Dropdown: **reviewer (active)** (currently selected)
- Button: **Deactivate combo**

### 2. Apply resilience profile
- Dropdown: **balanced** (currently selected)
- Button: **Apply profile**

### 3. Reset circuit breakers
- Description: "Clears current breaker state and failure counters for providers."
- Button: **Reset all breakers** (red button)

---

## Tools and Scopes Table

**Section Title:** "Tools and scopes"

A detailed table listing all registered MCP tools with their metadata:

### Column Headers:
| Tool | Scopes | Phase | Audit |

### Table Content (all 37 tools):

| Tool | Scopes | Phase | Audit |
|------|--------|-------|-------|
| omniroute_get_health | read:health | 1 | basic |
| omniroute_list_combos | read:combos | 1 | basic |
| omniroute_get_combo_metrics | read:combos | 1 | basic |
| omniroute_switch_combo | write:combos | 1 | full |
| omniroute_check_quota | read:quota | 1 | basic |
| omniroute_route_request | execute:completions | 1 | full |
| omniroute_cost_report | read:usage | 1 | basic |
| omniroute_list_models_catalog | read:models | 1 | none |
| omniroute_web_search | execute:search | 1 | basic |
| omniroute_simulate_route | read:health, read:combos | 2 | basic |
| omniroute_set_budget_guard | write:budget | 2 | full |
| omniroute_set_routing_strategy | write:combos | 2 | full |
| omniroute_set_resilience_profile | write:resilience | 2 | full |
| omniroute_test_combo | execute:completions, read:combos | 2 | full |
| omniroute_get_provider_metrics | read:health | 2 | basic |
| omniroute_best_combo_for_task | read:combos, read:health | 2 | basic |
| omniroute_explain_route | read:health, read:usage | 2 | basic |
| omniroute_get_session_snapshot | read:usage | 2 | none |
| omniroute_db_health_check | read:health, write:resilience | 2 | full |
| omniroute_sync_pricing | pricing:write | 2 | basic |
| omniroute_cache_stats | read:cache | 2 | basic |
| omniroute_cache_flush | write:cache | 2 | full |
| omniroute_compression_status | read:compression | 2 | basic |
| omniroute_compression_configure | write:compression | 2 | full |
| omniroute_set_compression_engine | write:compression | 2 | full |
| omniroute_list_compression_combos | read:compression | 2 | basic |
| omniroute_compression_combo_stats | read:compression | 2 | basic |
| omniroute_oneproxy_fetch | read:proxies | 2 | basic |
| omniroute_oneproxy_rotate | read:proxies | 2 | basic |
| omniroute_oneproxy_stats | read:proxies | 2 | basic |
| omniroute_agent_skills_list | read:catalog | 2 | none |
| omniroute_agent_skills_get | read:catalog | 2 | none |
| omniroute_agent_skills_coverage | read:catalog | 2 | none |

---

## Audit Log Section

**Section Title:** "Audit log"

- **Calls:** 0 | page 1 of 1
- **Filters:** "All tools" dropdown, "All results" dropdown, "apiKeyId" text input
- **Message:** "No audit entries found for current filters."
- **Pagination:** Previous | Next (both grayed out/disabled)

---

## Key Observations

1. **Server is online:** The green "Online" indicator and toggle confirm the MCP server is running.
2. **Transport:** Streamable HTTP is the selected transport mode, with the endpoint URL `http://localhost:2000/api/mcp/stream`.
3. **No activity:** Zero total calls, 0.0% success rate, and 0ms average latency in the last 24 hours — the server appears freshly started or unused.
4. **37 tools registered:** The tools and scopes table lists all 37 MCP tools spanning health checks, combo management, routing, caching, compression, proxy operations, and agent skills.
5. **Two phases:** Tools are split between Phase 1 (core/basic tools) and Phase 2 (advanced/configuration tools).
6. **Audit levels:** Tools have三种 audit levels — `basic` (most common), `full` (for write/mutation operations), and `none` (for read-only catalog operations).
7. **Operational controls:** The dashboard provides controls for switching combos, applying resilience profiles, and resetting circuit breakers.
8. **No audit entries:** The audit log is empty, consistent with zero tool calls in the last 24 hours.
9. **PID and uptime not shown:** The process status section shows dashes for PID, session uptime, and last heartbeat, suggesting these values are not yet populated or the process info is unavailable.
