# Screenshot 45 — Dashboard System: Proxy

**URL Path:** `Dashboard > System > Proxy`
**Application:** Cybernetics Core v1.2.38

---

## Global Layout

Two-column layout: **left sidebar** (dark background, ~180px) and **main content area** (white background) showing the Proxy configuration page. Top bar includes "Quick nav" search (`Ctrl K`), language selector (`EN`), and notification icons.

---

## Left Sidebar (Navigation)

Standard navigation sidebar branded **"Cybernetics Core"**. Sections:

- **OMNIPROXY:** Endpoints, API Keys, Providers, Combos, Combo Studio, Provider Quota, API Endpoints, Webhooks, **Proxy** (highlighted in red, currently active)
- **ANALYTICS:** Usage, Combo Health, Utilization, Cache, Compression, Search, Evals, Provider Stats
- **MONITORING:** Activity, Logs, Proxy Logs, Console Logs, Audit Log, MCP Audit, A2A Audit, Health, Runtime
- **AGENTIC FEATURES:** Memory, AgentSkills, OmniSkills, MCP Server, A2A Server, Plugins
- **OTHER FEATURES:** Media, Batch Jobs, Files
- **CONFIGURATION:** Storage, Appearance, AI Settings, Global Routing, Resilience, Advanced, Security, Feature Flags, Sidebar
- **HELP:** Docs, Issues, Changelog

Bottom: green "Normal" and red "Shut..." status indicators.

---

## Breadcrumb

`Dashboard > System > Proxy` — small gray text.

---

## Page Header

- **Icon:** Red shield icon with proxy symbol
- **Title:** "Proxy" (large, bold)
- **Subtitle:** "Configure upstream proxy settings for outbound provider connections"

---

## Tab Navigation

Four tabs displayed horizontally below the breadcrumb:

1. **Global Config** — currently active (red underline)
2. **Proxy Pool**
3. **Free Pool**
4. **Documentation**

---

## Tab Content: Global Config

### Card 1: Global Proxy

- **Header:** Red gear/shield icon + "Global Proxy" in bold
- **Description:** "Configure a global outbound proxy for all API calls. Individual providers, combos, and keys can override this."
- **Status:** "No global proxy configured."
- **"Configure"** button — red background with gear icon, white text

### Card 2: Enable per-key proxy assignment

- **Header:** Red key icon + "Enable per-key proxy assignment" in bold
- **Description:** "When enabled, each provider connection can use its own proxy assignment"
- **Toggle switch** — currently **OFF** (gray)

### Card 3: Bulk Healthcheck

- **Header:** Red pulse/activity icon + "Bulk Healthcheck" in bold
- **Description:** "Test all configured proxies against a target URL to find which ones work."
- **URL input field** — pre-filled with: `https://api.openai.com/v1/models`
- **"Healthcheck All"** button — red background with play icon, white text, positioned to the right of the input

---

## Visual Style Notes

- **Card style:** White cards with subtle shadow, rounded corners, slight elevation
- **Active tab:** Red underline text ("Global Config"), other tabs are gray text
- **Button style:** Red background (#E53935), white text, rounded, with small icons
- **Input field:** Light gray border, rounded corners, white background
- **Toggle:** Standard red (ON) / gray (OFF) pill toggle
- **Content area is mostly empty** — the rest of the page below the three cards is blank white space, indicating the page has minimal content in the Global Config tab
- **Page is scrollable** but content fits in the viewport without scrolling
