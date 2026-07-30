# 07 — Analytics: Compression

**File**: `07_dashboard_analytics_compression.png`
**Page**: Analytics > Compression
**URL path**: (Dashboard / Analytics / Compression)

---

## Page Header

- **Icon**: Red/coral circular icon with a white lightning bolt or compression symbol.
- **Title**: "Compression" (bold, large, black text).
- **Subtitle**: "Content compression analytics and token savings" (gray, smaller text).

---

## Breadcrumb Navigation

Three tabs aligned horizontally below the header:

| Tab | State |
|-----|-------|
| Dashboard | Inactive (gray text) |
| Analytics | Inactive (gray text) |
| Compression | Active (bold, underlined) |

---

## Time Range Selector

Four pill-style buttons positioned below the breadcrumb, left-aligned:

| Button | State |
|--------|-------|
| **Last 24h** | Active — green/coral filled background, white text |
| **Last 7d** | Inactive — gray outline, gray text |
| **Last 30d** | Inactive — gray outline, gray text |
| **All time** | Inactive — gray outline, gray text |

---

## Summary Statistics Row

Six stat cards displayed horizontally across the top of the content area:

| Stat | Value | Subtext |
|------|-------|---------|
| **Total Requests** | `0` | (none) |
| **Tokens Saved** | `0` | (none) |
| **Avg Savings** | `0%` | (none) |
| **Avg Duration** | `0ms` | (none) |
| **Recepts** | `0` | "0 read tokens" (small gray text) |
| **Fallbacks** | `0` | "Validation restores" (small gray text) |

Each stat card has a small gray icon to the left of the label. All values are zero, indicating no compression activity has been recorded yet.

---

## Last 24 Hours (Activity) Chart

- **Section header**: Green/coral circle icon + "Last 24 Hours (Activity)" in bold.
- **Chart type**: Horizontal bar/timeline chart with X-axis showing time labels.
- **Time labels visible** (left to right): `10`, `10`, `11`, `11`, `12`, `12`, `1`, `1`, `2`, `2`, `3`, `3`, `4`, `4`, `5`, `5`, `6`, `6`, `7`, `7`, `8` (representing hourly intervals).
- **Y-axis**: Not visible — the chart appears flat with no data bars plotted.
- **Chart state**: Empty — no bars or data points are rendered.
- **Annotations below chart**:
  - `Max requests/hour: 1` (left-aligned, small gray text)
  - `Max tokens/hour: 1` (center-aligned, small gray text)

---

## Empty State

- **Icon**: A red/coral colored icon depicting a document with a warning or empty state symbol.
- **Primary text**: "No compression data yet" (bold, centered, black).
- **Secondary text**: "Use POST /v1/chat/completions with compression configuration to start tracking compression analytics." (centered, gray, smaller text). The code portion `POST /v1/chat/completions` appears in a monospace/code font style.

---

## Info Banner

- **Position**: Below the empty state, spanning the full width of the content area.
- **Style**: Light blue/cyan background with a blue info circle icon on the left.
- **Text**: "Compression analytics: Token savings tracked per mode (off, lite, standard, aggressive, ultra, RTK, stacked), engine, compression combo, and provider. Hover over charts for details. Use the time selector to view different time periods."

---

## Left Sidebar

The sidebar is the standard Cybernetics-Core navigation panel, white background with gray text and icons. The **Compression** item is highlighted with a red/coral background and white text, indicating the current active page.

### Sidebar Sections Visible:

**Top area:**
- Cybernetics-Core logo (red square icon) with version text "v2.1.8" below
- Collapse arrow (chevron left) at the very top left

**OMNIPROXY section** (header in uppercase gray):
- Endpoints
- API Keys
- Providers
- Combos
- Combo Studio
- Provider Quota
- API Endpoints
- Webhooks
- Proxy

**ANALYTICS section** (header in uppercase gray):
- Usage
- Combo Health
- Utilization
- Cache
- **Compression** (ACTIVE — red/coral background, white text)
- Search
- Evals
- Provider Stats

**MONITORING section** (header in uppercase gray):
- Activity
- Logs
- Proxy Logs
- Console Logs
- Audit Log
- MCP Audit
- A2A Audit
- Health
- Runtime

**AGENTIC FEATURES section** (header in uppercase gray):
- Memory
- AgentSkills
- OmniSkills
- MCP Server
- A2A Server
- Plugins

**Collapse sections** (with right-pointing chevrons):
- OTHER FEATURES
- CONFIGURATION
- HELP

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

This is the **Compression Analytics** page of the OmniRoute dashboard. It displays token savings and compression performance metrics. In this screenshot, the page is in a **completely idle/empty state** — all statistics are zero, the activity chart has no data bars, and a prominent empty-state message instructs the user to send requests via `POST /v1/chat/completions` with compression configuration to begin tracking. An informational banner at the bottom explains the tracked compression modes (off, lite, standard, aggressive, ultra, RTK, stacked) and how to interact with the charts.
