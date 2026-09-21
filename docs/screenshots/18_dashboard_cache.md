# Screenshot 18 — Cache (Prompt Cache Provider-Side)

## Page Identity

- **Header icon**: Red/orange database/cache icon
- **Title**: "Cache"
- **Subtitle**: "Monitor provider prompt cache efficiency and local semantic response reuse."
- **Breadcrumb**: `Dashboard > Cache`

## Top-Right Actions

- **Refresh** button (outline style, circular arrows icon)

## Tab Navigation

Three tabs displayed horizontally:

| Tab | State |
|-----|-------|
| **Prompt Cache (Provider-Side)** | **ACTIVE** — bold text, red/orange underline indicator |
| Semantic Cache | Inactive — grey text |
| Reasoning Replay | Inactive — grey text |

## Prompt Cache (Provider-Side) — Active Tab Content

### Status Banner

- **Icon**: Green lightning bolt icon (⚡)
- **Badge**: `PROMPT CACHE (PROVIDER-SIDE)` in green text with green background pill
- **Last updated**: "Last updated: 7/2/2026, 7:14:39 PM" (right-aligned, grey text)

### Section Title

- **Title**: "Prompt Cache (Provider-Side)" (bold, large)
- **Description**: "Shows provider-side prompt caching activity from usage history so you can see where cache control is active and how much input reuse you are getting."

### KPI Metric Cards (5 cards in a row)

| Card | Icon | Label | Value | Subtext |
|------|------|-------|-------|---------|
| 1 | Circular arrows (cache icon) | `Cache Rate` | **31.1%** (large, bold) | `256 / 822 requests` |
| 2 | Circular arrows (reuse icon) | `Cache Reuse Ratio` | **46.1%** (large, bold) | `Cache read tokens / Total input tokens` |
| 3 | Database icon | `Cache Read Tokens` | **24,583,808** (large, bold, green) | `Read from cache` |
| 4 | Database-write icon | `Cache Write Tokens` | **0** (large, bold) | `Written to cache` |
| 5 | Dollar sign icon | `Est. Cost Saved` | **$66.3800** (large, bold, green) | `Prompt Cache (Provider-Side)` |

All cards have white backgrounds with subtle borders.

### Breakdown by Provider Section

- **Title**: "Breakdown by Provider" (bold)
- **Description**: "Each provider exposes total input tokens, cache read tokens, and cache write tokens so you can verify the reuse ratio against raw totals."

#### Provider Table

| Column | Description |
|--------|-------------|
| PROVIDER | Provider name + request count |
| TOTAL INPUT TOKENS | Total tokens consumed |
| CACHE READ | Tokens served from cache (green text) |
| CACHE WRITE | Tokens written to cache |
| CACHE REUSE RATIO | Percentage (green text) |
| CACHE RATE | Percentage (green text) |
| CACHED REQUESTS | Fraction of cached vs total |

**Row 1 — coder**
- Requests: `269 requests`
- Total Input Tokens: `49,567,498`
- Cache Read: `24,242,688` (green)
- Cache Write: `0`
- Cache Reuse Ratio: `48.9%` (green)
- Cache Rate: `84.6%` (green)
- Cached Requests: `219 / 269`

**Row 2 — cloudflare-ai**
- Requests: `318 requests`
- Total Input Tokens: `3,746,623`
- Cache Read: `341,120` (green)
- Cache Write: `0`
- Cache Reuse Ratio: `9.1%` (green)
- Cache Rate: `17.1%` (green)
- Cached Requests: `37 / 216`

### Cache Trend (24h) Section

- **Title**: "Cache Trend (24h)" with a line-chart icon (trend line)
- **Description**: "Hourly request volume, cache coverage, and cache read volume across the last 24 hours."
- **Right side**: Clock icon with "16 HOURS TRACKED" (grey text)

#### Summary Metrics

| Metric | Value |
|--------|-------|
| CACHED REQUESTS (24H) | **256** |
| BUSIEST HOUR | **00:00** |
| PEAK CACHE RATE | **100.0%** (green text) |

#### Hourly Activity Table

| HOUR | ACTIVITY (bar + count) | CACHE RATE | CACHE READ |
|------|------------------------|------------|------------|
| 19:00 | Teal bar (short, ~10% width) — `3 requests` | **100.0%** | `252,416` |
| 18:00 | Teal bar (medium, ~50% width) — `72 requests` | **13.9%** | `559,008` |
| 17:00 | Teal bar (very short, ~5% width) — `2 requests` | **0.0%** | `0` |
| 13:00 | Teal bar (medium, ~45% width) — `61 requests` | **0.0%** | `0` |
| 12:00 | Teal bar (very short, ~5% width) — `9 requests` | **0.0%** | `0` |
| 11:00 | Teal bar (short, ~10% width) — `18 requests` | **0.0%** | `0` |

The activity bars are horizontal teal/green colored bars with widths proportional to request count. The "CACHE RATE" and "CACHE READ" columns use green text for non-zero values and grey for zero values.

## Sidebar (Left Navigation)

Identical sidebar to all other dashboard pages. Brand: "Cybernetics-Core" v1.3.18.

### Navigation Sections

**MAIN:**
- Home

**COMPROXY:**
- Endpoints, API Keys, Providers, Combos, Combo Studio, Provider Quota, API Endpoints, Webhooks, Proxy

**ANALYTICS:**
- Usage, Combo Health, Utilization
- **Cache** — **CURRENT PAGE**, highlighted with red/pink background, red text
- Compression, Search, Eval, Provider Stats

**MONITORING:**
- Activity, Logs, Proxy Logs, Console Logs, Audit Log, MCP Audit, A2A Audit

**AGENTIC FEATURES:**
- Health, Runtime, Memory, AgentSkills, OmniSkills, MCP Server, A2A Server, Plugins

**OTHER FEATURES:**
- Media, Batch Jobs, Files

**CONFIGURATION**, **HELP** (collapsed sections)

## Footer (Bottom-Left)

- Green dot with "Ready" text
- Red power icon with "Shutd..." (truncated) text

## Header Bar (Top)

- Left: Collapse chevron (`<`)
- Center: Search bar "Quick nav" with `Ctrl+K` badge
- Right: `EN` language selector with US flag, Dark mode toggle (moon), Warning triangle, User avatar
