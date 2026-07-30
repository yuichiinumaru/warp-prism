# Dashboard: Request Logs

**Page Title:** Logs
**Subtitle:** Real-time request logs, error traces, and streaming event inspector
**Breadcrumb:** Dashboard > Logs

---

## Left Sidebar

The sidebar is light gray with a white background. At the top is a red/pink square icon labeled **Cybernetics-Core** with version **v1.2.28** below it. The sidebar contains the following navigation sections and items:

### OMNIPROXY
- Endpoints — Your AI connection URLs
- API Keys — Create and manage access
- Providers — Manage AI providers
- Combos — Smart model combos to follow
- Combo Studio — Mix, match, optimize
- Provider Quota — Track provider usage limits
- API Endpoints — External API access
- Webhooks — Get notified of events
- Proxy — HTTP proxy settings

### ANALYTICS
- Usage — Explore your usage data
- Combo Health — Combo target reliability
- Utilization — Resource utilization
- Cache — Cache hit rates
- Compression — Token savings stats
- Search — Search query analytics
- Eval — Eval suite results
- Provider Stats — Latency and performance m...

### MONITORING
- Activity — Real-time feed of recent events
- **Logs** — Application logs (currently selected, highlighted in red/pink text)
- Proxy Logs — Upstream proxy logs
- Console Logs — Console output
- Audit Log — Historical audit
- MCP Audit — MCP tool audit
- A2A Audit — A2A protocol audit

### AGENTIC FEATURES
- Memory — Persistent memory
- AgentSkills — Auto-install plugins
- OmniSkills — Sandbox skill registry
- MCP Server — Model Context Protocol
- A2A Server — A2A protocol server
- Plugins — Plugin marketplace & install

### OTHER FEATURES
- Media — Manage uploaded files
- Batch Jobs — Process multiple requests
- Files — Batch upload/import files

### CONFIGURATION
- (collapsed section)

### HELP
- Docs — Documentation
- Issues — Report a bug
- Changelog — Latest updates

At the very bottom of the sidebar: a green **Restart** button and a red **Shut...** (shutdown) button.

---

## Top Bar

- **Search:** "Quick nav" with keyboard shortcut hint `Ctrl+/`
- **Language selector:** EN dropdown
- **Icons:** Bell notification icon, warning triangle icon, user/settings icon

---

## Page Header

- **Heading:** "Request Logs" in large bold text
- **Buttons (top-right of heading):**
  - "Clean history" — outlined button
  - "Export" — dark/filled button

---

## Filters and Controls

### Row 1:
- **Recording** — red dot indicator with green dot, indicating recording is active
- **Pipeline logs off** — toggle switch (off state)
- **Search input:** placeholder "Search models, provide..."
- **Dropdowns:** "All providers", "All models", "All accounts", "All API keys"

### Row 2 (Summary Stats):
- **181** Total
- **32** Success (green badge)
- **68** Error (red badge)
- **14** Combo (orange badge)
- **1** Keys (blue badge)
- **101** Shown
- **Newest** — sort dropdown
- Pagination: `< 10 >` with a refresh button

### Row 3 (Column Filter Tags):
- **ALL** (red/active), **Error** (gray), **Success** (gray), **Combo** (gray)
- Provider filter tags: **CODEX**, **NVIDIA**, **OPENAI**, **ZAI**

### Row 4 (Column Visibility Toggles):
- COLUMNS: **Status**, **Cache Source**, **Model**, **Requested**, **Provider**, **Request Protocol**, **Account**, **API Key**, **Combo**, **Tokens**, **TPS**, **Duration**, **Time**

---

## Data Table

### Column Headers:
| STATUS | CACHE SOURCE | MODEL | REQUESTED | PROVIDER | REQUEST PROTOCOL | ACCOUNT | API KEY | COMBO | TOKENS | TPS | DURATION | TIME |

### Table Content (representative rows):

**Top section — Successful requests (200 OK):**

| Status | Cache Source | Model | Requested | Provider | Protocol | Account | API Key | Combo | Tokens | TPS | Duration | Time |
|--------|-------------|-------|-----------|----------|----------|---------|---------|-------|--------|-----|----------|------|
| 200 | (yellow dot) | gpt-5.5-high | — | OPENAI | — | — | — | TI: 171,794, TD: 152 | 25.4 | — | 10.2s | 18:13:55 |
| 200 | UPSTREAM | gpt-5.5-high | — | OPENAI | — | — | — | TI: 171,681, TD: 152 | 17.2 | — | 18.9s | 18:13:31 |
| 200 | UPSTREAM | gpt-5.5-high | — | OPENAI | — | — | — | TI: 150,478, TD: 730 | 23.9 | — | 6.9s | 18:13:24 |
| 200 | UPSTREAM | gpt-5.5-high | — | OPENAI | — | — | — | TI: 154,804, TD: 1,186 | 27.5 | — | 224.7s | 18:08:37 |
| 200 | UPSTREAM | gpt-5.5-high | — | OPENAI | — | — | — | TI: 135,117, TD: 891 | 26.4 | — | 33.7s | 18:04:52 |
| 200 | UPSTREAM | gpt-5.5-high | — | OPENAI | — | — | — | TI: 128,889, TD: 670 | 22.8 | — | 29.4s | 18:04:18 |
| 200 | UPSTREAM | gpt-5.5-high | — | OPENAI | — | — | — | TI: 137,507, TD: 238 | 29.7 | — | 11.5s | 18:04:12 |
| 200 | UPSTREAM | gpt-5.5-high | — | OPENAI | — | — | — | TI: 119,583, TD: 132 | 28.4 | — | 9.2s | 18:03:37 |
| 200 | UPSTREAM | gpt-5.5-high | — | OPENAI | — | — | — | TI: 111,494, TD: 537 | 25.6 | — | 21.8s | 18:03:27 |

**Middle section — Error requests (502) and model1-sync entries:**

| Status | Cache Source | Model | Requested | Provider | Protocol | Account | API Key | Combo | Tokens | TPS | Duration | Time |
|--------|-------------|-------|-----------|----------|----------|---------|---------|-------|--------|-----|----------|------|
| 502 | UPSTREAM | model1-sync | — | — | — | — | 5 | — | TI: 0, TD: 0 | — | — | 18:52:39 |
| 502 | UPSTREAM | model1-sync | — | — | — | — | 4 | — | TI: 0, TD: 0 | — | 64ms | 18:52:30 |
| 502 | UPSTREAM | model1-sync | — | — | — | — | 4 | — | — | — | 18s | 18:52:03 |
| 502 | UPSTREAM | model1-sync | — | — | — | — | — | — | — | — | 56s | 18:52:03 |
| 200 | UPSTREAM | model1-sync | — | — | — | — | — | — | — | — | 17s | 18:51:56 |
| 200 | UPSTREAM | model1-sync | — | — | — | — | — | — | — | — | 17ms | 18:51:56 |
| 502 | UPSTREAM | model1-sync | — | — | — | — | 3 | — | — | — | 54s | 18:51:06 |
| 200 | UPSTREAM | model1-sync | — | — | — | — | 2 | — | — | — | 48ms | 18:47:59 |
| 502 | UPSTREAM | model1-sync | — | — | — | — | 2 | — | — | — | 1.8s | 18:47:56 |
| 200 | UPSTREAM | model1-sync | — | — | — | — | 1 | — | — | — | 42ms | 18:46:54 |
| 502 | UPSTREAM | model1-sync | — | — | — | — | 1 | — | — | — | 1.0s | 18:45:54 |

Some rows show `island` or `cc` or `i` or `ti` as the account identifier.

**Bottom section — OpenAI GPT-3.5 requests:**

A long series of rows showing:

| Status | Cache Source | Model | Requested | Provider | Protocol | Account | API Key | Combo | Tokens | TPS | Duration | Time |
|--------|-------------|-------|-----------|----------|----------|---------|---------|-------|--------|-----|----------|------|
| 429 | UPSTREAM | gpt-3.5 | openai/gpt-3.5 | OPENAI | — | Key 1 | — | TI: 0, TD: 0 | — | 416ms | 18:31:19 |
| 429 | UPSTREAM | gpt-3.5 | openai/gpt-3.5 | OPENAI | — | Key 2 | — | TI: 0, TD: 0 | — | 449ms | 18:31:19 |
| 429 | UPSTREAM | gpt-3.5 | openai/gpt-3.5 | OPENAI | — | Key 3 | — | TI: 0, TD: 0 | — | 397ms | 18:31:18 |
| 429 | UPSTREAM | gpt-3.5 | openai/gpt-3.5 | OPENAI | — | Key 4 | — | TI: 0, TD: 0 | — | 402ms | 18:31:18 |
| 429 | UPSTREAM | gpt-3.5 | openai/gpt-3.5 | OPENAI | — | Key 5 | — | TI: 0, TD: 0 | — | 417ms | 18:31:18 |
| ... | ... | ... | ... | ... | ... | Key 6–Key 50 | ... | ... | ... | 386ms–3.4s | 18:30:46–18:31:17 |

These rows all show status **429** (rate limited), provider **OPENAI**, model **gpt-3.5**, requested as **openai/gpt-3.5**, with accounts labeled **Key 1** through **Key 50**. Token counts are all **TI: 0, TD: 0**. Durations range from **386ms** to **3.4s**.

### Key Observations:
- The table is sorted by **Newest** first.
- The top entries are high-value requests to `gpt-5.5-high` with large token counts (100K–170K+ tokens).
- The middle section shows `model1-sync` requests with a mix of 200 and 502 statuses.
- The bottom section shows a burst of 429 rate-limited requests to `gpt-3.5` across 50 different API keys, suggesting a load test or automated key rotation scenario.
- Provider filter tags (CODEX, NVIDIA, OPENAI, ZAI) allow quick filtering by provider.
- Column visibility toggles allow the user to show/hide specific table columns.
