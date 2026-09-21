# 02_dashboard_a2a.md — A2A Server Page

## Page Title
**A2A Server** — "Agent-to-Agent protocol tasks and observability"

## Breadcrumb
`Dashboard > A2A`

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
| **Top** | Home (Dashboard overview) |
| **OMNIROUTE** | Endpoints, API Keys, Providers, Combos, Combo Studio, Provider Quota, API Endpoint, Webhooks, Proxy |
| **ANALYTICS** | (collapsed) |
| **MONITORING** | (collapsed) |
| **AGENTIC FEATURES** | Memory (Persistent agent memory), AgentSkills (A2A skill registry), OmniSkills (Sandbox skill registry), MCP Server (MCP server controls), **A2A Server** (A2A protocol server) — **active, red text with red highlight background**, Plugins (Plugin marketplace & installs) |
| **OTHER FEATURES** | (collapsed) |
| **CONFIGURATION** | (collapsed) |
| **HELP** | (collapsed) |

### Sidebar Footer
- "Report" link and "Shade..." text.

---

## Main Content Area

### 1. Info Card — Agent2Agent JSON-RPC 2.0 endpoint
- **Style**: Light gray/white card with subtle border.
- **Content**: Numbered list describing the A2A protocol capabilities:
  1. "Discover the agent card at `/.well-known/agent.json`."
  2. "Send tasks via `POST /a2a`."
  3. "Track and cancel tasks with ease."
- **Right side**: Status indicator showing:
  - Red dot + "Online" label
  - Toggle switch (currently in OFF position, gray)
  - "OFF" text label

### 2. Disabled State Notice
- **Icon**: Gray circle with ℹ (information) icon
- **Title**: "A2A is disabled"
- **Body**: "Enable A2A above to view task telemetry, agent details, and validation tools."
- **Style**: Centered, muted gray text, informational tone.

---

## Visual Style Summary
- **Color palette**: White background, red accent for active sidebar item, gray for disabled/inactive states.
- **Layout**: Single-column main content, minimal elements on this page.
- **State**: The A2A feature is currently **disabled** (toggle OFF), resulting in a mostly empty page with only the protocol description and a disabled-state notice.
- **Sidebar active item**: "A2A Server" is highlighted with a red background pill, indicating current page.
