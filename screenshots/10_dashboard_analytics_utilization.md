# 10 — Analytics: Utilization

**File**: `10_dashboard_analytics_utilization.png`
**Page**: Analytics > Utilization
**URL path**: (Dashboard / Analytics / Utilization)

---

## Page Header

- **Icon**: Red/coral circular icon with a white gauge/speedometer symbol.
- **Title**: "Utilization" (bold, large, black text).
- **Subtitle**: "Provider utilization metrics and capacity planning" (gray, smaller text).

---

## Breadcrumb Navigation

Three tabs aligned horizontally below the header:

| Tab | State |
|-----|-------|
| Dashboard | Inactive (gray text) |
| Analytics | Inactive (gray text) |
| Utilization | Active (bold, underlined) |

---

## Provider Utilization Chart Card

A large card with a white background containing the main utilization chart:

### Card Header
- **Left icon**: Gray gauge/speedometer icon.
- **Title**: "Provider utilization" (bold, black).
- **Subtitle**: "Last 24 hours" (gray, smaller text).
- **Right-side controls**:
  - **Global View** button (with grid icon, outlined style)
  - **Account Split** button (with user/group icon, outlined style)
  - **Time range pills**: `1h` | `24h` (active — red/coral filled background, white text) | `7d` | `30d`

### Chart
- **Chart type**: Line chart with multiple colored lines.
- **Y-axis**: Percentage scale from `0%` to `100%` with gridlines at 25%, 50%, 75%, 100%.
- **X-axis**: Time labels spanning approximately 8 hours: `02:00 PM`, `03:30 PM`, `04:00 PM`, `05:30 PM`, `08:00 PM`, `09:30 PM`, `10:00 PM`, `10:30 PM`.
- **Legend** (bottom center, color-coded with dots):
  - `← agy` (red/coral)
  - `← antigravity` (red/coral)
  - `← codex` (yellow/amber)
  - `← deepseek` (purple/blue)
  - `← kiro` (green)

### Data Lines Visible:
- **Red/coral line (agy / antigravity)**: Starts near 0%, rises sharply around 08:00 PM to approximately 10-15%, then continues rising to around 20-25% by 10:30 PM. This line shows active utilization growth.
- **Yellow/amber line (codex)**: Remains flat at 0% for most of the chart, with a very slight bump visible near the end (around 10:30 PM).
- **Purple/blue line (deepseek)**: Flat at 0% throughout.
- **Green line (kiro)**: Flat at 0% throughout.

A red/coral horizontal reference line is visible near the top of the chart (close to 100%), likely indicating a threshold or capacity limit.

---

## Provider Status Cards (2 rows, 5 cards total)

Below the chart, five provider cards are arranged in a grid (3 in the first row, 2 in the second row):

### Row 1

#### deepseek
- **Icon**: Blue circle with a white symbol.
- **Status badge**: "Healthy" (green background, white text).
- **Subtitle**: "Latest quota snapshot"
- **Remaining capacity**: `100%` (large bold text)
- **Timestamp**: "Jul 2, 09:00 PM" (gray text, right-aligned)
- **Label**: "Remaining capacity" (gray text below percentage)
- **Progress bar**: Full green bar spanning 100% (0% to 100% scale), with "Remaining quota" label and `100%` marker.

#### kiro
- **Icon**: Purple circle with a white symbol.
- **Status badge**: "Healthy" (green background, white text).
- **Subtitle**: "Latest quota snapshot"
- **Remaining capacity**: `99%` (large bold text)
- **Timestamp**: "Jul 2, 03:10 PM" (gray text, right-aligned)
- **Label**: "Remaining capacity" (gray text below percentage)
- **Progress bar**: Full green bar spanning 99% (0% to 100% scale), with "Remaining quota" label and `100%` marker.

#### codex
- **Icon**: Gray circle with a white symbol.
- **Status badge**: "Exhausted" (red/coral background, white text).
- **Subtitle**: "Latest quota snapshot"
- **Remaining capacity**: `40%` (large bold text)
- **Timestamp**: "Jul 2, 10:10 PM" (gray text, right-aligned)
- **Label**: "Remaining capacity" (gray text below percentage)
- **Progress bar**: Partial yellow/amber bar spanning approximately 40% (0% to 100% scale), with "Remaining quota" label and `100%` marker.

### Row 2

#### agy
- **Icon**: Red/coral circle with a white letter "A".
- **Status badge**: "Exhausted" (red/coral background, white text).
- **Subtitle**: "Latest quota snapshot"
- **Remaining capacity**: `1.9%` (large bold text)
- **Timestamp**: "Jul 2, 09:00 PM" (gray text, right-aligned)
- **Label**: "Remaining capacity" (gray text below percentage)
- **Progress bar**: Nearly empty, with a small red/coral dot at the far left (0% to 100% scale), "Remaining quota" label and `100%` marker.

#### antigravity
- **Icon**: Red/coral circle with a white letter "A".
- **Status badge**: "Exhausted" (red/coral background, white text).
- **Subtitle**: "Latest quota snapshot"
- **Remaining capacity**: `1.9%` (large bold text)
- **Timestamp**: "Jul 2, 09:00 PM" (gray text, right-aligned)
- **Label**: "Remaining capacity" (gray text below percentage)
- **Progress bar**: Nearly empty, with a small red/coral dot at the far left (0% to 100% scale), "Remaining quota" label and `100%` marker.

---

## Left Sidebar

The sidebar is the standard Cybernetics-Core navigation panel. The **Utilization** item is highlighted with a red/coral background and white text, indicating the current active page.

### Sidebar Sections Visible:

**OMNIPROXY section:**
- Endpoints, API Keys, Providers, Combos, Combo Studio, Provider Quota, API Endpoints, Webhooks, Proxy

**ANALYTICS section:**
- Usage, Combo Health, **Utilization** (ACTIVE — red/coral background, white text), Cache, Compression, Search, Evals, Provider Stats

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

This is the **Utilization** page of the OmniRoute dashboard, showing provider quota utilization metrics and capacity planning data. Unlike the other analytics pages, this page has **active data** — it displays a 24-hour line chart and 5 provider status cards.

### Key Observations:

- **deepseek** and **kiro** are **Healthy** with near-full remaining capacity (100% and 99% respectively).
- **codex** is marked **Exhausted** with only 40% remaining capacity.
- **agy** and **antigravity** are both marked **Exhausted** with critically low remaining capacity of only **1.9%** each.
- The utilization chart shows the **agy/antigravity** usage climbing from 0% to approximately 20-25% over the observed period, while all other providers remain at or near 0%.
- The chart supports multiple time ranges (1h, 24h, 7d, 30d) and view modes (Global View, Account Split).
- Each provider card shows a "Latest quota snapshot" with a progress bar visualizing remaining quota as a percentage of total capacity.
