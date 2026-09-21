# 05_dashboard_analytics.md — Usage Analytics (Overview Tab)

## Page Title
**Usage** — "Charts, trends, and evaluation insights"

## Breadcrumb
`Dashboard > Analytics`

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
| **Top** | Home |
| **OMNIROUTE** | Endpoints, API Keys, Providers, Combos, Combo Studio, Provider Quota, API Endpoint, Webhooks, Proxy |
| **ANALYTICS** | Usage (Provider usage stats) — **active, red text with red highlight**, Combo Health (Combo target visibility), Utilization (Provider utilization), Cache (Cache hits), Compression (Token savings stats), Search (Search provider analytics), Evals (Eval suite results), Provider Stats (Latency and performance metrics) |
| **MONITORING** | Activity, Logs, Proxy Logs, Console Logs, Audit Log, MCP Audit, A2A Audit, Health, Runtime |
| **AGENTIC FEATURES** | Memory, AgentSkills, OmniSkills, MCP Server, A2A Server, Plugins |
| **OTHER FEATURES** | (collapsed) |
| **CONFIGURATION** | (collapsed) |
| **HELP** | (collapsed) |

### Sidebar Footer
- "Report" link and "Shade..." text.

---

## Main Content Area

### Sub-tab Navigation
- **Overview** (active), Evals, Search, Utilization, Combo Health, Route Trace

### Page Header
- Red chart icon + **"Usage Analytics"** title

### Filter Controls (top-right)
- "All Keys" dropdown
- Time range: **1D, 7D, 30D** (active, green), **90D, YTD, All**, Custom

---

## 1. Summary Stat Cards (4 cards in a row)

| Metric | Value | Sub-label |
|--------|-------|-----------|
| **TOTAL REQUESTS** (chart icon) | **57.4M** | 822 Requests |
| **INPUT TOKENS** (document icon) | **57.2M** | — |
| **OUTPUT TOKENS** (document icon) | **202.1K** | — |
| **EST. COST** (dollar icon) | **$158.70** | — |

---

## 2. Infrastructure Row

| Metric | Value |
|--------|-------|
| ACCOUNTS | 172 |
| PROVIDERS | 23 |
| API KEYS | 2 |
| MODELS | 30 |

## 3. Performance Row

| Metric | Value |
|--------|-------|
| AVG TOKENS/REQ | 69.8K |
| COST/REQ | $0.1931 |
| I/O RATIO | 283.2x |
| FAST REQUESTS | 0 |

## 4. Highlights Row

| Metric | Value |
|--------|-------|
| TOP MODEL | gpt-5.5-high |
| TOP PROVIDER | codex |
| BUSIEST DAY | Wed |
| DIVERSITY | 0.0% |
| FALLBACK RATE | 0.0% |

---

## 5. Overview Chart + Most Active Day

### Overview Heatmap/Chart
- Title: "OVERVIEW"
- Subtitle: "2 active days · 57.4M tokens · 365 days"
- **X-axis**: Months (Jul, Aug, Sep, Oct, Nov, Dec, Jan, Feb, Mar, Apr, May, Jun)
- **Y-axis**: Days of week (Mon, Wed, Fri)
- **Legend**: Less → More (red gradient blocks)
- Shows a heatmap of activity across the year — most activity appears concentrated in recent days (right side of chart).

### Most Active Day Card
- **Title**: "MOST ACTIVE DAY"
- **Value**: **Wednesday**
- **Detail**: "31 Jul · 57.4M tokens"

### Weekly Bar Chart
- Title: "WEEKLY"
- Bar chart showing day-of-week distribution
- **Tuesday** has the tallest bar (dark orange/red)
- Other days have smaller bars in lighter shades

---

## 6. Model Usage Over Time (Chart)

- **Title**: "MODEL USAGE OVER TIME"
- **Type**: Area chart
- **X-axis**: Dates (Jul 31 through present)
- **Y-axis**: Token count (0 to 45.0M)
- **Series legend** (bottom): Multiple model variants including:
  - gpt-5.5-high (dark blue)
  - gpt-5.5-4 (dark red)
  - gpt-5.5-flash-free (red)
  - deepseek-v4-flash-free (pink)
  - deepseek-v4 (purple)
  - claude-opus-4.0 (dark)
  - gpt-5.5-high (duplicate entries for different configs)
  - Various other model variants

- **Chart shape**: Shows a sharp spike (peak ~45M tokens) around the most recent data point, with minimal activity before that.

---

## 7. Cost by Provider (Donut Chart)

- **Title**: "COST BY PROVIDER"
- **Type**: Donut/pie chart
- **Segments**:
  - **Codex** (orange) — $158.67
  - **Cloudflare-AI** (red) — $11.54
  - **Nvidia** (yellow/green) — $2.06
  - **(Other)** — $0.000081

---

## 8. Service Tier

- **Title**: "SERVICE TIER"
- **Badge**: "Standard" (green checkmark icon)
- **Detail**: "822 requests · 57.4M tokens"
- **Right side**: **$153.79** — "Fast / Fire · Standard API"

---

## 9. Model Usage Over Time (Full Chart)

- **Title**: "MODEL USAGE OVER TIME"
- **Type**: Stacked area chart
- **X-axis**: Jul 31 through present
- **Y-axis**: 0 to 60.0M tokens
- **Dominant series**: gpt-5.5-high (purple/lavender) accounts for the vast majority of usage
- **Legend**: 15+ model variants with color-coded dots
- Shows a massive spike in usage on the most recent day, with virtually zero usage before that.

---

## 10. By Account (Donut Chart)

- **Title**: "BY ACCOUNT"
- **Type**: Donut chart
- **Segments** (color-coded):
  - aranidaisaniprazer@gmail.com — 42.6K
  - caralhoentor — 737.9K
  - merglhzevor — 459.7K
  - baset — 130.6K
  - neonrevolver — 829.7K
  - pcreston — 906.1K
  - pcreston — 642.1K
  - purrhetsonrankn — 35.6M
  - duanmarginala@gmail.com — 6.8M

---

## 11. By API Key (Donut Chart)

- **Title**: "BY API KEY"
- **Type**: Donut chart
- **Segments**:
  - **02 (dc2\*\*\*\*6b81)** — 57.4M (dominant, dark red)
  - opencode (3c3f\*\*\*\*ce19) — 0

---

## 12. Provider Breakdown (Table)

| Provider | Requests | Input | Output | Total | Cost | Share |
|----------|----------|-------|--------|-------|------|-------|
| Codex | 299 | 58.8M | 142.3K | 58.9M | $158.67 | — |
| Cloudflare-AI | 216 | 6.3M | 59.8K | 6.4M | $11.54 | 11.1% |
| Kiro | 55 | 132.9K | 825 | 133.8K | $2.06 | 6.2% |
| Opencode-Zen | 2 | 3.0K | 13 | 3.0K | $0.00 | 0.1% |
| Nvidia | 45 | 558 | 9 | 567 | $0.000081 | 0.1% |
| Windsurf | 48 | 0 | 0 | 0 | $0.00 | 0.0% |
| Openai | 48 | 0 | 0 | 0 | $0.00 | 0.0% |
| Antigravity | 26 | 0 | 0 | 0 | $0.00 | 0.0% |
| Apy | 25 | 0 | 0 | 0 | $0.00 | 0.0% |
| Fireworks | 19 | 0 | 0 | 0 | $0.00 | 0.0% |
| Siliconflow | 17 | 0 | 0 | 0 | $0.00 | 0.0% |
| Freearapikey | 14 | 0 | 0 | 0 | $0.00 | 0.0% |
| Ollama-Cloud | 12 | 0 | 0 | 0 | $0.00 | 0.0% |
| Qoder | 9 | 0 | 0 | 0 | $0.00 | 0.0% |
| Kimi | 8 | 0 | 0 | 0 | $0.00 | 0.0% |
| Nous-Research | 6 | 0 | 0 | 0 | $0.00 | 0.0% |
| Openai-Compatible-Chat-2c3b3277... | 4 | 0 | 0 | 0 | $0.00 | 0.0% |
| Openrouter | 3 | 0 | 0 | 0 | $0.00 | 0.0% |
| Anthropic-Compatible-2c33932a... | 2 | 0 | 0 | 0 | $0.00 | 0.0% |
| Together | 1 | 0 | 0 | 0 | $0.00 | 0.0% |
| Kimi-Web | 1 | 0 | 0 | 0 | $0.00 | 0.0% |
| Duckduckgo-Web | 1 | 0 | 0 | 0 | $0.00 | 0.0% |
| Deepseek | 1 | 0 | 0 | 0 | $0.00 | 0.0% |

---

## 13. API Key Breakdown (Table)

- **Title**: "API KEY BREAKDOWN"
- **Search**: "Search keys..." input

| API Key | Requests | Input | Output | Total | Cost |
|---------|----------|-------|--------|-------|------|
| 02 (dc2\*\*\*\*6b81) | 672 | 57.2M | 202.1K | 57.4M | $158.70 |
| opencode (3c3f\*\*\*\*ce19) | 7 | 0 | 0 | 0 | $0.00 |

---

## 14. Model Breakdown (Table, partial)

| Model | Requests | Input | Output | Total | Cost | Share |
|-------|----------|-------|--------|-------|------|-------|
| gpt-5.5-high | 298 | 58.8M | 142.3K | 58.9M | $158.67 | — |
| kimi-k2.7-code | 285 | 6.3M | 59.0K | 6.4K | $5.98 | — |
| claude-opus-4.8 | 19 | 132.9K | 825 | 133.8K | $2.06 | — |
| deepseek-v4-flash-free | — | 3.0K | 13 | 3.0K | $0.00 | — |
| deepseek-v4-flash | 11 | 558 | 9 | 567 | $0.000081 | — |

*(Table extends beyond viewport)*

---

## Visual Style Summary
- **Color palette**: White background, red accent for active sidebar item, green for active time filter, orange/red for cost and chart series.
- **Typography**: Large bold stat values (57.4M, $158.70), smaller labels, monospace for API key fragments.
- **Layout**: Dashboard grid — summary cards at top, charts in middle, detailed tables at bottom. Multiple chart types: area, donut/pie, heatmap, bar.
- **Data density**: Very high — this is the most data-rich page in the dashboard, combining summary metrics, charts, and three detailed breakdown tables.
- **Key insight**: The vast majority of usage (57.4M of 57.4M tokens, $158.70 of $158.70 cost) comes from a single API key (02/dc2****6b81) routed through Codex with the gpt-5.5-high model.
