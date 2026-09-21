# 01_dashboard.md — Home Dashboard Overview

## Page Title
**Home** — "Welcome to OmniRoute"

## Breadcrumb
`Home`

---

## Global Layout

### Top Bar (macOS Chrome Window)
- macOS traffic-light buttons (red, yellow, green) in the top-left corner.
- Browser URL bar not visible; content fills the viewport.

### Left Sidebar (Collapsible)
- **Header**: Red square icon + "Cybernetics-Core" text, with version "v3.8.38" beneath.
- **Collapse toggle** (`<` button) at top-right of sidebar.

#### Sidebar Navigation Sections

| Section | Items |
|---------|-------|
| **Top** | Home (Dashboard overview) — **active, red text** |
| **OMNIROUTE** | Endpoints (Your AI connection URL), API Keys (Control who can send and access), Providers (Connect model providers), Combos (Build routing rules), Combo Studio (Live routing simulator), Provider Quota (Track provider usage limits), API Endpoint (Request/response stats), Webhooks (Get notified of events), Proxy (HTTP proxy settings) |
| **ANALYTICS** | (collapsed section) |
| **MONITORING** | (collapsed section) |
| **AGENTIC FEATURES** | (collapsed section) |
| **OTHER FEATURES** | (collapsed section) |
| **CONFIGURATION** | (collapsed section) |
| **HELP** | (collapsed section) |

### Sidebar Footer (bottom-left)
- "Report" link and "Shade..." text in small font.

---

## Main Content Area

### 1. Alert Banner — Auto-Routing Active (blue info banner)
- **Icon**: Blue information circle
- **Title**: "Auto-Routing Active"
- **Body text**: "OmniRoute is automatically routing requests using combo-based strategies. View or change your routing configuration on the Combos page."
- **Style**: Light blue/teal background, full-width banner with a close (×) button on the right.

### 2. Update Notification (green banner)
- **Icon**: Green circle with checkmark
- **Title**: "Update Available: v3.8.43"
- **Body text**: "Not a git repository. Download source or use npm install -g"
- **Right side**: "Manual Update" button (green, outlined)

### 3. API Key Warning (top-right toast/notification)
- **Background**: Orange/red gradient header with warning icon (⚠)
- **Title**: "API Key Warning"
- **Body**: "24 API key(s) in warning state due to elevated failure rates. Affected keys: qoder-ai, arnis, baset, opus-13, pcverijo, pcverijrson, arnis, baset, baset, js, pcverijtson, mpn, pcverijo, neonrevolver, 2m, 2m, merglhzevor, Z, 1. Review to prevent rotation issues."
- **Style**: Floating notification card, top-right corner.

### 4. Provider Quota Section
- **Header**: Red house icon + "Provider Quota" title
- **Subtitle**: "Live status across connected accounts"
- **Right side**: "Auto-refreshing 59:59" with circular refresh icon

#### Provider Quota Cards (2×4 grid)

| Provider | Icon | Status/Link |
|----------|------|-------------|
| **Apy** | Blue triangle icon | Badge "15" (blue) |
| **Antigravity** | Blue triangle icon | Badge "11" (blue) |
| **Codex** | Blue circle icon | Badge "12" (blue) |
| **Deepseek** | Blue circle icon | — |
| **Geminid-cl** | Blue square icon | "Refresh All" link (green) |
| **Kimi-coding** | Blue triangle icon | "Refresh All" link (green) |
| **Kiro** | Blue square icon | — |
| **Zai** | Blue triangle icon | "Refresh All" link (green) |

- **Footer**: "View details →" link (right-aligned)

### 5. Quick Start Section
- **Header**: Lightning bolt icon + "Quick Start" title
- **Subtitle**: "Get up and running in 4 steps. Connect providers, route models, monitor everything."
- **Right side**: "Full Docs" button with external link icon

#### Quick Start Steps (2×2 grid of cards)

| Step | Icon | Title | Description |
|------|------|-------|-------------|
| 1 | Blue key icon | **1. Create API key** | "Go to Endpoints → Registered Keys. Generate one key per environment." |
| 2 | Green link icon | **2. Connect providers** | "Add accounts in Providers. Supports OAuth, API Key, and free tiers." |
| 3 | Blue person icon | **3. Point your client** | "Set base URL to http://localhost:22000/v1 in your IDE or API client." |
| 4 | Green checkmark icon | **4. Monitor & optimize** | "Track tokens, cost and errors in Request Logs and Analytics." |

### 6. Provider Topology Section
- **Header**: Network icon + "Provider Topology" title
- **Subtitle**: "Connected providers routing through OmniRoute in real time"
- **Legend** (top-right): Green dot = Active, Orange dot = Recent, Red dot = Error

#### Topology Visualization
- Interactive node-graph diagram showing connected providers as labeled nodes.
- Central node labeled "OmniRoute" (red/orange background) acts as the hub.
- Surrounding nodes represent various providers connected by lines/edges.
- **Controls** (bottom-left of graph): Zoom in (+), zoom out (−), and fit-to-screen buttons.
- **Identifiable provider nodes** (partial list, clockwise from top): Codex, Gemini, various unnamed nodes, plus additional provider labels scattered across the graph.
- The graph shows a hub-and-spoke topology with OmniRoute at the center.

---

## Visual Style Summary
- **Color palette**: White background, red primary accent (sidebar active, icons), green for success/active states, blue for informational badges and secondary elements, orange for warnings.
- **Typography**: Clean sans-serif font (likely Inter or similar), consistent sizing hierarchy.
- **Card style**: Rounded corners, subtle shadows, light gray borders.
- **Overall layout**: Two-column (narrow sidebar + wide main content), vertically stacked sections.
