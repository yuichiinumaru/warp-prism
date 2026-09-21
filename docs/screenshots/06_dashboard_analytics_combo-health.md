# 06_dashboard_analytics_combo-health.md — Combo Health Page

## Page Title
**Combo Health** — "Real-time health and performance of combo routing configurations"

## Breadcrumb
`Dashboard > Analytics > Combo Health`

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
| **ANALYTICS** | Usage, **Combo Health** (Combo target visibility) — **active, red text with red highlight**, Utilization, Cache, Compression, Search, Evals, Provider Stats |
| **MONITORING** | Activity, Logs, Proxy Logs, Console Logs, Audit Log, MCP Audit, A2A Audit, Health, Runtime |
| **AGENTIC FEATURES** | Memory, AgentSkills, OmniSkills, MCP Server, A2A Server, Plugins |
| **OTHER FEATURES** | (collapsed) |
| **CONFIGURATION** | (collapsed) |
| **HELP** | (collapsed) |

### Sidebar Footer
- "Report" link and "Shade..." text.

---

## Main Content Area

### Header
- Red heart-pulse icon + **"Combo Health"** title
- Subtitle: "Real-time health and performance of combo routing configurations"

### Time Range Controls (top-right)
- **Preset buttons**: 1h, **24h** (active, green), 7d, 30d (active, green)
- **Forecast buttons**: 24h forecast, 7d forecast, **30d forecast** (active, red)

---

## 1. Combo Health Autopilot (Critical Alert Card)

- **Title**: "Combo Health Autopilot" + **CRITICAL** badge (red)
- **Subtitle**: "Prioritized recommendations from combo health, forecasts, quotas, and provider health."

### Summary Metrics (4 stat boxes)

| Metric | Value | Sub-label |
|--------|-------|-----------|
| **ISSUES** | **1,558** | 306 actionable |
| **DOWN** | **29** | — |
| **DEGRADED** | **4** | — |
| **HEALTHY** | **0** | — |

### Critical Issue Cards (5 cards, 2-column grid)

#### Card 1: Combo success rate is below target
- **Severity**: CRITICAL (red badge)
- **Description**: "Inspect failing targets and test fallback order before increasing traffic."
- **Actions**: "→ Run combo test" | "→ Open combo editor"

#### Card 2: Target success rate is degraded
- **Severity**: CRITICAL (red badge)
- **Description**: "Run a focused combo test and consider changing order, weight, or credentials."
- **Actions**: "→ Run combo test" | "→ Open combo editor"

#### Card 3: Target quota is running low
- **Severity**: CRITICAL (red badge)
- **Description**: "Review provider quota and rebalance traffic before the target is exhausted."
- **Actions**: "→ Review quota limits" | "→ Open combo editor"

#### Card 4: Target quota is exhausted
- **Severity**: CRITICAL (red badge)
- **Description**: "Move traffic away from this target or rotate credentials until quota resets."
- **Actions**: "→ Review quota limits" | "→ Open combo editor"

#### Card 5: Target quota is exhausted (duplicate)
- **Severity**: CRITICAL (red badge)
- **Description**: "Move traffic away from this target or rotate credentials until quota resets."
- **Actions**: "→ Review quota limits" | "→ Open combo editor"

### Tracking Status
- "Tracking 33 combos for 24h" (gray text)

---

## 2. Combo Detail — "reviewer"

### Combo Header
- **Name**: "reviewer"
- **Tags**: "High" (red badge), "Down" (red badge)
- **Detail**: "14 models across 1 providers"

### Summary Metrics (4 stat boxes)

| Metric | Value | Sub-label |
|--------|-------|-----------|
| **WORST QUOTA LEFT** | **18%** | — |
| **USAGE SKEW** | **0.40** | Gini coefficient |
| **SUCCESS RATE** | **24.6%** | 57 requests |

### Quota Health Panel
- **Title**: "Quota health"
- **Subtitle**: "Lowest remaining quota across providers with short trend signals."
- **Provider**: "codex" — Remaining quota **17.9%**
- **Status badges**: "⚠ Declining" (yellow), "🔴 Exhausted" (red)

### Usage Skew Panel
- **Title**: "Usage skew"
- **Subtitle**: "Model request share and token share within this combo."

| Model | Request Share | Token Share |
|-------|---------------|-------------|
| reviewer | 59.7% | 59.7% |
| gpt-5.5-high | 40.4% | 100.0% |
| codex/gpt-5.5-high | 0.0% | 0.0% |

*(Bar charts showing request and token distribution per model)*

### Performance Panel
- **Title**: "Performance"
- **Subtitle**: "Reliability and throughput for routed combo traffic."

| Metric | Value |
|--------|-------|
| **AVG LATENCY** | **11,066ms** |
| **SUCCESS RATE** | **24.6%** |
| **TOTAL REQUESTS** | **57** |

---

## 3. Execution Targets (Grid of Target Cards)

- **Title**: "Execution targets"
- **Subtitle**: "Stop-level runtime metrics and quota visibility for structured combo targets."

Each card shows:
- Email address (account identifier)
- Provider/model details
- Status badges (success, latency, quota)
- Quota scope, trend, and state

### Target Cards (visible, 2-column grid)

| Account | Status | Latency | Quota | Trend |
|---------|--------|---------|-------|-------|
| princess866b@gmail.com | — | 1,828ms | 0.0% | Quota scope: connection · Trend: declining |
| yusufnurani@gmail.com | ✅ success | 22,892ms | 0.0% | Quota scope: connection · Trend: stable · Exhausted |
| dovmarginala@gmail.com | — | 0ms | 0.0% | Quota scope: connection · Trend: exhausted |
| aranidaisaniprazer@gmail.com | — | 1,885ms | 35.0% | Quota scope: connection · Trend: improving |
| caralhoentor@gmail.com | — | 3,248ms | 0.0% | Quota scope: connection · Trend: exhausted |
| basellormo@gmail.com | — | 0ms | 0.0% | Quota scope: connection · Trend: exhausted |
| gebrerawilams2084@gmail.com | — | 0ms | 0.0% | Quota scope: connection · Trend: declining |
| juicerjathompson@gmail.com | — | 0ms | 0.0% | Quota scope: connection · Trend: stable · Exhausted |
| supernova.warrior@gmail.com | 14 ms | 40,004ms | 8.0% | Quota scope: connection · Trend: declining |
| neonrevolver2084@gmail.com | error | 3,258ms | 95.0% | Quota scope: connection · Trend: declining |
| merglhzevor@gmail.com | — | 0ms | 0.0% | Quota scope: connection · Trend: exhausted |
| purrhetsonrankn@gmail.com | — | 3,217ms | 95.0% | Quota scope: connection · Trend: exhausted |
| pembonjones@gmail.com | — | 0ms | 0.0% | Quota scope: connection · Trend: exhausted |
| codex/gpt-5.5-high | — | 0ms | 17.9% | Quota scope: provider · Trend: declining · Exhausted |

---

## 4. Intelligent Scoring Inspector

- **Title**: "Intelligent scoring inspector"
- **Subtitle**: "Factor-level explanation for target ranking using current health, forecast, and routing heuristics."
- **Tags**: "Read-only recompute" (red badge), "Task: default", "Selected: task #1"
- **Note**: "Combo strategy is not auto; this is an explanatory recompute, not the real-time strategy."

### Scoring Results (3 columns)

| Rank | Account/Target | Score |
|------|----------------|-------|
| **#1** | purrhetsonrankn@gmail.com | codex · score 0.713 |
| **#2** | neonrevolver2084@gmail.com | codex · score 0.712 |
| **#3** | codex/gpt-5.5-high | codex · score 0.642 |

---

## Visual Style Summary
- **Color palette**: White background, red accent for critical alerts and active sidebar, green for active time filters, yellow/orange for warnings, red badges for CRITICAL severity.
- **Typography**: Large bold metric values (1,558 issues, 24.6%), smaller labels, monospace for email addresses and IDs.
- **Layout**: Stacked sections — critical alerts at top, combo detail in middle, execution target grid below, scoring inspector at bottom.
- **Data density**: Very high — this page combines real-time health monitoring, quota tracking, performance metrics, and an intelligent scoring system.
- **Key insight**: The "reviewer" combo is in critical condition: only 24.6% success rate across 57 requests, 18% worst quota remaining, 1,558 total issues detected (306 actionable), with 29 targets down and 4 degraded. The Codex provider is nearly exhausted at 17.9% quota.
- **State**: All health indicators are red/critical — no healthy combos detected.
