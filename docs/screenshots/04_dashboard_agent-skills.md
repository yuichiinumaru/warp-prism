# 04_dashboard_agent-skills.md — AgentSkills Page

## Page Title
**AgentSkills** — "Agent-ready skills catalog with one-click URL copy for AI client integration"

## Breadcrumb
`Dashboard > AgentSkills`

---

## Global Layout

### Top Bar
- macOS traffic-light buttons (red, yellow, green) in the top-left corner.
- **Top-right toolbar**: Search icon, "Quick nav" button with `⌘K` shortcut hint, language selector ("EN" with globe icon), notification bell, alert triangle, and user avatar/profile icon.

### Left Sidebar (Collapsible)
- **Header**: Red square icon + "Cybernetics-Core" text, version "v3.8.38".
- **Collapse toggle** (`<` button) at top-right of sidebar.

#### Sidebar Navigation Sections

| Section | Items |
|---------|-------|
| **Top** | Home (Dashboard overview) |
| **OMNIROUTE** | Endpoints, API Keys, Providers, Combos, Combo Studio, Provider Quota, API Endpoint, Webhooks, Proxy |
| **ANALYTICS** | (collapsed) |
| **MONITORING** | Activity, Logs, Proxy Logs, Console Logs, Audit Log, MCP Audit, A2A Audit, Health, Runtime |
| **AGENTIC FEATURES** | Memory, **AgentSkills** (A2A skill registry) — **active, red text with red highlight**, OmniSkills, MCP Server, A2A Server, Plugins |
| **OTHER FEATURES** | (collapsed) |
| **CONFIGURATION** | (collapsed) |
| **HELP** | (collapsed) |

### Sidebar Footer
- "Report" link and "Shade..." text.

---

## Main Content Area

### 1. Agent Skills — Outbound (Comparison Card)
- **Header**: Red icon + "Agent Skills — Outbound" title
- **Right side**: "Understand the difference →" link (red text)

#### Comparison Table: Agent Skills vs OmniSkills

| Aspect | Agent Skills | OmniSkills |
|--------|-------------|------------|
| **What it is** | Machine-readable SKILL.md that teaches an external agent to operate OmniRoute from outside | Executable skills that OmniRoute injects into LLM requests |
| **Direction** | Outbound — external agent learns to control OmniRoute | Inbound — OmniRoute gives tools to models passing through it |
| **Executor** | External agent (reads markdown → acts via API/CLI) | OmniRoute itself (interprets tool calls, Docker sandbox) |
| **Storage** | Dynamic catalog (`/agent/skills/` — SKILL.md on GitHub) | SQLite (SkillsMP / skills.db / local) |
| **Together** | Teach your agent to use OmniRoute | Give executable tools to OmniRoute models |

### 2. Coverage Bar
- **Title**: "COVERAGE"
- **Progress bar**: Full width, green fill, showing **API: 222/22** and **CLI: 21/21** — both at **100%** coverage.

### 3. MCP URL & A2A Cards (two side-by-side cards)

#### MCP URL Card
- **Title**: Red MCP icon + "MCP URL"
- **URL**: `http://localhost:22000/api/mcp/sse` (monospace)
- **Button**: "Copy URL" (with copy icon)
- **Description**: "Add this MCP URL to your agent to give it OmniRoute tools."

#### A2A Card
- **Title**: Red A2A icon + "A2A"
- **URL**: `http://localhost:22000/.well-known/agent.json` (monospace)
- **Button**: "Copy URL" (with copy icon)
- **Description**: "Register the Agent Card with your runtime to enable A2A task delegation."

### 4. Search & Filter Bar
- **Search input**: "Search skills..." placeholder
- **Filter tabs**: All (active, red background), API, CLI, Config

---

## Skills Catalog (Scrollable List)

Each skill entry has:
- **Icon**: Red/colored circular icon
- **Title**: Bold skill name
- **Tags**: Colored badges (API = red, CLI = green, NEW = green, START = green)
- **Description**: Gray text explaining the skill's purpose

### API Skills (Tag: API)

| # | Skill | Tags | Description |
|---|-------|------|-------------|
| 1 | **Authentication** | API, START | Manage API key authentication and session tokens. Start here to authenticate requests via Bearer token, obtain session cookies, and configure login requirements for the OmniRoute API. |
| 2 | **Providers** | API | Manage provider connections, API keys, OAuth flows, and connection tests via the REST API. List, add, update, remove, and test AI provider integrations (OpenAI, Anthropic, Google, and 10+). |
| 3 | **Models** | API | Browse available AI models across all configured providers. List models, resolve model aliases, and browse the full model catalog including provider-specific variants. |
| 4 | **Combos & Routing** | API, NEW | Create, test, and manage routing combos with 14 strategies (priority, weighted, round-robin, auto-combo, etc.). Configure fallback chains, test routing outcomes, and retrieve combo metrics. |
| 5 | **API Keys** | API | Create, list, rotate, and revoke OmniRoute API keys. Control per-key scopes, spending limits, and expiration. Keys gate access to all proxy and management endpoints. |
| 6 | **Usage & Logs** | API | Access detailed call logs and usage analytics. Filter by provider, model, time range, status, and cost. Export logs and aggregate token usage across all connections. |
| 7 | **Budget & Rate Limits** | API | Configure spending limits, token quotas, and rate-limit policies per API key or globally. Inspect current consumption and enforce cost controls across providers. |
| 8 | **Settings** | API | Read and update global application settings: system prompts, thinking budget, IP filters, payload rules, combo defaults, and require-login configuration. |
| 9 | **Proxy Configuration** | API | Configure HTTP/HTTPS/SOCKS proxies for upstream provider requests. Set per-provider or global proxy rules, test connectivity, and manage proxy rotation. |
| 10 | **Cache** | API | Manage the LLM response cache: view cache statistics, clear entries, configure TTL policies, and control semantic-similarity caching thresholds. |
| 11 | **Compression** | API, NEW | Configure RTK (command output), Caveman (proxy), and stacked compression modes. Manage language packs, custom rules, and test prompt compression reducing tokens by 60-90%. |
| 12 | **Context & RTK** | API, NEW | Configure RTK filters, context engineering rules, and context relay settings. Test compression with real prompt samples and manage context transformation pipelines. |
| 13 | **Resilience & Monitoring** | API, NEW | Monitor provider health, circuit-breaker states, p95/p99 latency metrics, and budget guard alerts. Inspect connection cooldowns and model lockouts in real time. |
| 14 | **CLI Tools** | API | Manage CLI tool integrations exposed via the API. List, configure, and invoke CLI tool plugins that extend OmniRoute's automation surface. |
| 15 | **Tunnels** | API | Create and manage secure tunnels (ngrok, Cloudflare Tunnel, custom) to expose OmniRoute to the internet or share access with remote agents and CI pipelines. |
| 16 | **Cloud Sync** | API | Synchronize configuration, provider connections, and settings to/from cloud storage. Manage cloud worker authentication and remote backup targets. |
| 17 | **Database & Backups** | API | Inspect the SQLite database, restore from backup files, and manage the SQLite database lifecycle. Supports export, import, and incremental snapshot strategies. |
| 18 | **Webhooks** | API | Create, list, and remove webhook endpoints. Configure event subscriptions (request.completed, provider.error, budget.exceeded, etc.) and manage delivery retries. |
| 19 | **MCP Server** | API | Inspect and control the MCP server (27 tools, 3 transports: SSE/stdio/HTTP). Covers routing, cache, compression, streaming, skills, providers, and audit logs across 16 permission scopes. |
| 20 | **Agents & A2A Protocol** | API | Interact with OmniRoute via JSON-RPC 2.0 agent-to-agent protocol. 6 built-in A2A skills: smart routing, quota management, provider discovery, cost analysis, health report, list capabilities. |
| 21 | **Version Manager** | API | Install, start, stop, restart, and update embedded services (BRouter, CLI/ProxyAPK). Monitor service status, retrieve logs, and configure auto-restart for long-lived service endpoints. |
| 22 | **Inference (OpenAI-compatible)** | API | The core OpenAI-compatible inference endpoints: chat completions, embeddings, images, audio (TTS/STT), moderations, rerank, and the Responses API. The primary integration surface for AI agents. |

### CLI Skills (Tag: CLI)

| # | Skill | Tags | Description |
|---|-------|------|-------------|
| 23 | **CLI: Serve** | CLI, START | Start, stop, and restart the OmniRoute server from the CLI. Manage daemon mode, port configuration, auto-recovery, system tray integration, and the dashboard open shortcut. |
| 24 | **CLI: Health** | CLI | Check server health, component status, and live metrics from the CLI. Run `health`, `health --component`, and `health --watch` for a real-time dashboard of circuit breakers and provider status. |
| 25 | **CLI: Providers** | CLI | Manage provider connections from the CLI: list available/configured providers, add, edit, test-all, validate, rotate API keys, and view per-provider metrics. |
| 26 | **CLI: API Keys** | CLI | Create, list, rotate, and revoke OmniRoute API keys from the CLI. Manage OAuth flows for provider authentication and inspect key scopes and expiration. |
| 27 | **CLI: Models** | CLI | Query available AI models, list model aliases, and browse the full model catalog from the CLI. Filter by provider, search by capability, and resolve model name variants. |
| 28 | **CLI: Chat** | CLI | Send chat completions, stream responses, and start an interactive REPL session from the CLI. Supports all OmniRoute providers, combo routing, and system prompt configuration. |
| 29 | **CLI: Routing & Combos** | CLI | Create, list, update, and delete routing combos from the CLI. Test routing strategies, inspect combo metrics, and configure fallback chains interactively. |
| 30 | **CLI: Resilience & Quotas** | CLI | Set and inspect circuit-breaker states, connection cooldowns, quota limits, and backoff levels from the CLI. Reset stuck providers and configure resilience thresholds. |
| 31 | **CLI: Compression** | CLI | Inspect and configure prompt compression from the CLI. Manage RTK filters, Caveman rules, stacked compression modes, and preview compression output with real prompts. |
| 32 | **CLI: Contexts & Sessions** | CLI | Summarize active context-relay, RTK filter sets, and conversation sessions from the CLI. Apply context-relay settings and inspect active context pipelines. |
| 33 | **CLI: Cost & Usage** | CLI | (Partially visible at bottom of viewport) |

### Right Panel (Partial)
- **"Select a skill to preview its documentation."** — Placeholder text with a document icon, indicating a detail panel that populates when a skill is selected from the list.

---

## Visual Style Summary
- **Color palette**: White background, red accent for active sidebar item and skill icons, green for CLI tags and coverage bars, gray for descriptions.
- **Typography**: Bold skill names, regular-weight descriptions, monospace for URLs.
- **Layout**: Two-column — left side is the scrollable skills catalog (takes ~70% width), right side is a skill detail preview panel (~30% width, currently showing placeholder).
- **Density**: Very high — 33+ skills visible in the scrollable list, covering API, CLI, and configuration capabilities.
- **Skill categorization**: Skills are organized by protocol type (API vs CLI) with colored tag badges indicating the access method.
