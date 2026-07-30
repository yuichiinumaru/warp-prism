# 03_dashboard_activity.md — Activity Feed

## Page Title
**Activity** — "Recent events feed"

## Breadcrumb
`Dashboard > Activity`

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
| **MONITORING** | Activity (Recently observed events) — **active, red text with red highlight**, Logs (Application logs), Proxy Logs (Proxy traffic logs), Console Logs (Console output), Audit Log (Auth/audit events), MCP Audit (MCP tool audit), A2A Audit (A2A protocol audit), Health (Service health checks), Runtime (Realtime resilience & scoring) |
| **AGENTIC FEATURES** | Memory, AgentSkills, OmniSkills, MCP Server, A2A Server, Plugins |
| **OTHER FEATURES** | (collapsed) |
| **CONFIGURATION** | (collapsed) |
| **HELP** | (collapsed) |

### Sidebar Footer
- "Report" link and "Shade..." text.

---

## Main Content Area

### Header
- **Title**: Red house/activity icon + "Activity"
- **Subtitle**: "Recent events feed"
- **Right side**: "Refresh" button (white, with refresh icon, outlined)

### Filter Tabs (horizontal row)
- **All** — active (green background, white text)
- **Providers** — inactive
- **Combos** — inactive
- **API Keys** — inactive
- **Settings** — inactive
- **Auth** — inactive
- **System** — inactive

### Date Header
- **"TODAY"** — section divider, uppercase, gray text

---

## Activity Feed (Chronological List)

Each entry has:
- **Left icon**: Colored circular icon indicating event type (green = auth/sign-in, blue = credential creation, orange = credential update)
- **Event text**: Bold action verb + description
- **Timestamp**: Right-aligned, gray text ("just now", "X min ago")

### Event Log (most recent first)

| # | Event | Target | Timestamp |
|---|-------|--------|-----------|
| 1 | **admin signed in** | dashboard-auth | just now |
| 2 | **admin signed in** | dashboard-auth | just now |
| 3 | **admin signed in** | dashboard-auth | just now |
| 4 | **admin created credentials for** | zai:5 | 21 min ago |
| 5 | **admin created credentials for** | zai:4 | 22 min ago |
| 6 | **admin created credentials for** | zai:3 | 22 min ago |
| 7 | **admin created credentials for** | zai:2 | 28 min ago |
| 8 | **admin updated credentials for** | zai:1 | 28 min ago |
| 9 | **admin created credentials for** | zai:1 | 28 min ago |
| 10 | **admin created credentials for** | openai:asd:sd | 37 min ago |
| 11 | **admin created credentials for** | openai:asd | 38 min ago |
| 12 | **admin created credentials for** | openai:jj | 39 min ago |
| 13 | **admin created credentials for** | openai:jj | 40 min ago |
| 14 | **admin created credentials for** | openai:cc | 41 min ago |
| 15 | **admin updated credentials for** | openai:ad | 41 min ago |
| 16 | **admin created credentials for** | openai:bi | 41 min ago |
| 17 | **admin batch-revoked credentials** | (global) | 42 min ago |
| 18 | **admin updated credentials for** | openai:ad | 43 min ago |
| 19 | **admin created credentials for** | openai:ad | 45 min ago |
| 20 | **admin updated credentials for** | openai Key 50 | 46 min ago |
| 21 | **admin bulk-created credentials** | (global) | 46 min ago |
| 22–50+ | **admin created credentials for** | openai Key 50, openai Key 49, openai Key 48, openai Key 47, openai Key 46, openai Key 45, openai Key 44, openai Key 43, openai Key 42, openai Key 41, openai Key 40, openai Key 39, openai Key 38, openai Key 37, openai Key 36, openai Key 35, openai Key 34, openai Key 33, openai Key 32, openai Key 31, openai Key 30, openai Key 29, openai Key 28, openai Key 27, openai Key 26, openai Key 25, openai Key 24, openai Key 23, openai Key 22, openai Key 21, openai Key 20, openai Key 19, openai Key 18, openai Key 17, openai Key 16 | All at 46 min ago |

### Event Types Observed
1. **Admin sign-in** (green icon with person silhouette) — dashboard authentication events.
2. **Credential creation** (blue icon with key/plus) — creating new API credentials for providers.
3. **Credential update** (orange icon with pencil) — modifying existing credentials.
4. **Batch operations** — "admin batch-revoked credentials" and "admin bulk-created credentials" indicating bulk management.

---

## Visual Style Summary
- **Color palette**: White background, red accent for active sidebar item and page icon, green for active filter tab, blue/orange/green for event type icons.
- **Typography**: Bold action verbs in event descriptions, regular weight for target names, gray for timestamps.
- **Layout**: Single-column scrollable feed, infinite scroll behavior (feed extends beyond viewport).
- **Density**: High-density list with ~50+ entries visible, all from "TODAY" within a ~46-minute window.
- **Notable pattern**: Heavy bulk credential management activity — admin created/updated OpenAI keys (Key 16 through Key 50) in rapid succession, plus provider-specific credentials for zai and openai variants.
