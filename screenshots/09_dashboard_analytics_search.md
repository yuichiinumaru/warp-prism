# 09 — Analytics: Search

**File**: `09_dashboard_analytics_search.png`
**Page**: Analytics > Search
**URL path**: (Dashboard / Analytics / Search)

---

## Page Header

- **Icon**: Red/coral circular icon with a white magnifying glass over a globe or search-related symbol.
- **Title**: "Search" (bold, large, black text).
- **Subtitle**: "Search query analytics, cache hit rates, and cost tracking" (gray, smaller text).

---

## Breadcrumb Navigation

Three tabs aligned horizontally below the header:

| Tab | State |
|-----|-------|
| Dashboard | Inactive (gray text) |
| Analytics | Inactive (gray text) |
| Search | Active (bold, underlined) |

---

## Summary Statistics Row

Four stat cards displayed horizontally across the top of the content area:

| Stat | Value | Subtext |
|------|-------|---------|
| **Total Searches** | `0` | "0 today" (small gray text below) |
| **Cache Hit Rate** | `0%` | "0 cached requests" (small gray text below) |
| **Total Cost** | `$0.0000` | "search API costs" (small gray text below) |
| **Avg Response** | `0ms` | "no errors" (small gray text below) |

Each stat card has a small gray icon to the left of the label. All values are zero, indicating no search activity has been recorded yet. The Total Cost value uses a monospace/code-style font with four decimal places.

---

## Empty State

- **Icon**: A red/coral colored icon depicting a document with a warning or empty state symbol (same style as the Compression page empty state).
- **Primary text**: "No searches yet" (bold, centered, black).
- **Secondary text**: "Use POST /v1/search to start routing web searches." (centered, gray, smaller text). The code portion `POST /v1/search` appears in a monospace/code font style.

---

## Free Tier Info Banner

- **Position**: Below the empty state, spanning the full width of the content area.
- **Style**: Light green/mint background with a green checkmark/circle icon on the left.
- **Text**: "Free tier available: Serper (2,500/mo), Brave (2,000/mo), Exa (1,000/mo), Tavily (1,000/mo) — total 6,500+ free searches/month with automatic failover."

The four search providers are listed with their respective monthly free quotas:
- **Serper**: 2,500 searches/month
- **Brave**: 2,000 searches/month
- **Exa**: 1,000 searches/month
- **Tavily**: 1,000 searches/month

The total free tier capacity is stated as **6,500+ free searches/month** with automatic failover between providers.

---

## Left Sidebar

The sidebar is the standard Cybernetics-Core navigation panel. The **Search** item is highlighted with a red/coral background and white text, indicating the current active page.

### Sidebar Sections Visible:

**OMNIPROXY section:**
- Endpoints, API Keys, Providers, Combos, Combo Studio, Provider Quota, API Endpoints, Webhooks, Proxy

**ANALYTICS section:**
- Usage, Combo Health, Utilization, Cache, Compression, **Search** (ACTIVE — red/coral background, white text), Evals, Provider Stats

**MONITORING section:**
- Activity, Logs, Proxy Logs, Console Logs, Audit Log, MCP Audit, A2A Audit, Health, Runtime

**AGENTIC FEATURES section:**
- Memory, AgentSkills, OmniSkills, MCP Server, A2A Server, Plugins

**Collapsed sections:**
- OTHER FEATURES, CONFIGURATION, HELP

---

## Top-Right Header Bar

- **Quick nav** button with magnifying glass icon
- **"SHORTCUT"** badge (dark background, white text)
- **EN** language selector dropdown
- **User avatar** (green/teal circle with letter)
- **Warning/notification triangle** icon (yellow/amber)
- **Grid/apps** icon

---

## Footer

Two small links at the very bottom-left of the viewport:
- **"Recent"** (green dot + text)
- **"Share..."** (red circle/brand icon + text)

---

## Summary

This is the **Search Analytics** page of the OmniRoute dashboard. It tracks web search query analytics, cache hit rates, and API costs. The page is in a **completely idle/empty state** — all statistics are zero and no search data has been recorded. The empty-state message instructs the user to send requests via `POST /v1/search` to begin routing web searches.

A green info banner at the bottom highlights the **free tier availability** across four integrated search providers (Serper, Brave, Exa, Tavily), totaling over 6,500 free searches per month with automatic failover between providers. This suggests OmniRoute provides a built-in cost-optimized web search routing layer that aggregates multiple search APIs.
