# Screenshot 48 — Dashboard: Home

**URL Path:** `Dashboard > Home`
**Application:** Cybernetics Core v1.2.38

---

## Global Layout

Two-column layout: **left sidebar** (dark background, ~180px) and **main content area** (white/light gray background) displaying the Home dashboard. Top bar includes "Quick nav" search (`Ctrl K`), language selector (`EN`), and notification icons.

---

## Left Sidebar (Navigation)

Standard navigation sidebar branded **"Cybernetics Core"**. **Home** is highlighted in red text (currently active).

Sections:
- **OMNIPROXY:** Endpoints, API Keys, Providers, Combos, Combo Studio, Provider Quota, API Endpoints, Webhooks, Proxy
- **ANALYTICS:** Usage, Combo Health, Utilization, Cache, Compression, Search, Evals, Provider Stats
- **MONITORING:** Activity, Logs, Proxy Logs, Console Logs, Audit Log, MCP Audit, A2A Audit, Health, Runtime
- **AGENTIC FEATURES:** Memory, AgentSkills, OmniSkills, MCP Server, A2A Server, Plugins
- **OTHER FEATURES:** Media, Batch Jobs, Files
- **CONFIGURATION:** Storage, Appearance, AI Settings, Global Routing, Resilience, Advanced, Security, Feature Flags, Sidebar
- **HELP:** Docs, Issues, Changelog

Bottom: green "Normal" and red "Shut..." status indicators.

---

## Top-Right Alert Toast

A **yellow/amber warning toast notification** is displayed in the top-right corner:

- **Title:** "API Key Warning" (bold, with warning triangle icon)
- **Body text:** "24 API key(s) in warning state due to elevated failure rate. Providers with issues: codestral, ppio, opencode, pPIO, pp, ppc, 123, ppcproxi, ppcproxi14, antigravity, openai, zai, pp, ppco, ppco1a, ppco1a3, ppco14, ppco1234, openai/openrouter, 2.1, mergewindow, 2.1. Review to prevent rotation issues."
- Small close "X" button in the top-right of the toast

---

## Page Header

- **Icon:** Red house/home icon
- **Title:** "Home" (large, bold)
- **Subtitle:** "Welcome to OmniRoute"

---

## Breadcrumb

`Home` — single-level breadcrumb in small gray text.

---

## Alert Banners

### Banner 1: Auto-Routing Active (Blue)

- Blue left border, light blue background
- **Icon:** Blue circle with "i" info symbol
- **Text:** "**Auto-Routing Active** OmniRoute is automatically routing requests using combo-based strategies. View or change your routing configuration on the Combos page."
- "Combos page" is a red link
- Close "X" button on the right

### Banner 2: Update Available (Yellow/Orange)

- Yellow/orange left border, light yellow background
- **Icon:** Yellow circle with download arrow
- **Text:** "**Update Available: v3.8.43** Not a git repository. Download source or use npm install -g."
- **"Manual Update"** button — red background, white text, positioned on the right

---

## Provider Quota Section

- **Header:** Red grid icon + "Provider Quota" in bold
- **Subtitle:** "Live status across connected accounts"
- **"Auto-refreshing 59:59"** — countdown timer with green dot indicator, top-right

### Provider Cards (2 rows of 4)

Each card shows: provider icon (colored), provider name, quota count, and a refresh action.

| Row | Provider | Quota | Refresh |
|-----|----------|-------|---------|
| 1 | **Apy** (blue A icon) | 11 | — |
| 1 | **Antigravity** (gray icon) | 11 | — |
| 1 | **Codex** (green circle icon) | 12 | — |
| 1 | **Deepseek** (blue icon) | 3 | — |
| 2 | **Gemini-cl** (blue diamond icon) | 10 | "Refresh All" (red text) |
| 2 | **Kimi-coding** (orange icon) | 11 | "Refresh All" (red text) |
| 2 | **Kiro** (red icon) | 1 | — |
| 2 | **Zai** (blue Z icon) | 2 | — |

- **"View details →"** link (red text) — bottom-right of the section

---

## Quick Start Section

- **Header:** "Quick Start" in bold
- **Subtitle:** "Get up and running in 4 steps. Connect providers, route models, monitor everything."
- **"Full Docs"** link with external icon — top-right

### Four Steps (2x2 grid)

| Step | Icon | Title | Description |
|------|------|-------|-------------|
| 1 | Red key icon | **1. Create API key** | "Go to Endpoints → Registered Keys. Generate one key per environment." |
| 2 | Green plug icon | **2. Connect providers** | "Add accounts in Providers. Supports OAuth, API Key, and free tiers." |
| 3 | Blue link icon | **3. Point your client** | "Set base URL to http://localhost:22000/v1/ in your IDE or API client." |
| 4 | Yellow chart icon | **4. Monitor & optimize** | "Track tokens, cost, and errors in Request Logs and Analytics." |

---

## Provider Topology Section

- **Header:** "Provider Topology" in bold
- **Subtitle:** "Connected providers routing through OmniRoute in real time"
- **Legend:** Three colored dots in the top-right:
  - 🟢 Active
  - 🟡 Recent
  - 🔴 Error

### Topology Graph

An interactive node-and-edge graph visualization showing provider connections:

- **Central node:** "OmniRoute" (red/orange node in the center)
- **Surrounding nodes:** Multiple provider nodes arranged in a radial/force-directed layout, connected by gray lines/edges to the center
- Visible provider nodes include various colored icons representing different AI providers (blue, green, yellow, red, gray dots)
- Some nodes are clustered together, others are more spread out
- The graph has a light/white background with subtle grid or clean background

### Graph Controls (bottom-left of graph)

- **"+"** button — zoom in
- **"-"** button — zoom out
- **Expand/fullscreen** button — two arrows pointing outward

---

## Visual Style Notes

- **Alert banners:** Colored left borders (blue for info, yellow for warnings) with light tinted backgrounds
- **Toast notification:** Dark background with white text, yellow warning accent, positioned top-right with slight shadow
- **Provider cards:** White cards with subtle border, colored provider icons, bold numbers
- **Quick Start steps:** White cards with colored icons, numbered titles, gray description text
- **Topology graph:** Interactive force-directed graph with colored nodes on white background
- **Primary accent:** Red for buttons, links, active states, and the central OmniRoute node
- **Auto-refresh countdown:** Green pulsing dot with timer text
- **Content is vertically stacked** — sections flow top to bottom with clear visual separation
- **Page has significant vertical content** — the topology graph extends below the fold
