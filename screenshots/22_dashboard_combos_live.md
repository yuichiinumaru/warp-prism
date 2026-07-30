# Dashboard Screenshot: Combo Studio (Live)

**File**: `22_dashboard_combos_live.png`
**Page Title**: Combo Studio — Live routing console

---

## Overall Layout

Standard OmniRoute dashboard layout with a left sidebar navigation and main content area. This is a mostly empty state page, as no combo is currently selected or running.

---

## Left Sidebar

**Brand**: Red hexagon icon + "Cybernetics-Core" with "v3.8.29" version below.

### Sidebar Sections (top to bottom):

**Top Section**:
- Home (Dashboard overview)

**OMNIPROXY** (collapsible section, red dot indicator):
- Endpoints — Your AI connection URLs
- API Keys — Manage authentication keys and access
- Providers — Manage AI providers
- Combos — Model routing and failover
- **Combo Studio** — **Currently selected (highlighted with pink/red background)**
- Provider Quota — Track provider usage limits
- API Endpoints — Exposed OpenAI-compatible endpoints
- Webhooks — Get notified of events
- Proxy — HTTP proxy settings

**ANALYTICS** (collapsible section):
- Usage — Real-time usage metrics
- Combo Health — Combo target visibility
- Utilization — Historical utilization
- Cache — Cache hit rates
- Compression — Token savings stats
- Search — Search performance analytics
- Evals — End-to-end results
- Provider Stats — Latency and performance metrics

**MONITORING** (collapsible section):
- Activity — Live feed of recent events
- Logs — Application logs
- Proxy Logs — Proxy access logs
- Console Logs — Console output
- Audit Log — Audit trail record
- MCP Audit — MCP tool audit
- A2A Audit — A2A protocol audit
- Health — System health check
- Runtime — Runtime instance info, vers...

**AGENTIC FEATURES** (collapsible section):
- Memory — Persistent agent memory
- AgentSkills — Agent tool registry
- OmniSkills — Sandbox skill registry
- MCP Server — Model Context Protocol server
- A2A Server — A2A protocol server
- Plugins — Plugin marketplace & installs

**OTHER FEATURES** (collapsible section):
- Media — Generate images, files
- Batch Jobs — Process multiple requests
- Files — Batch input/output files

**CONFIGURATION** (collapsible)
**HELP** (collapsible):
- Docs — Documentation
- Issues — Report a bug
- Changelog — Release notes

### Bottom of sidebar:
- Green "Restart" button (circular arrow icon)
- Orange "Shut..." button (power icon)

---

## Top Bar

- Breadcrumb: Dashboard / Combos / Live
- Right side: Search icon, "Quick nav" with `⌘K`, "EN" language selector, user avatar, notification bell (yellow/orange badge), settings gear icon

---

## Main Content Area

### Page Header
- **Title**: "Combo Studio" (large, bold)
- **Subtitle**: (not visible / absent)
- **Page icon**: Red/pink interlocking circles/arrows icon to the left of the title

### Combo Selector Row
- **Dropdown**: "--- select combo ---" (a dropdown selector to choose which combo to monitor)
- **Two buttons** on the right:
  - **Start** — Green button (appears to be a play/start action)
  - **Reset** — White/outline button

### Status Banner
- **Yellow/amber warning banner** with triangle exclamation icon:
- Text: "⚠ Live disabled — WebSocket disconnected. Showing last known state."

### Main Content Area (Empty State)

The large white content area below the status banner is mostly empty, with a centered empty state message:

- **Centered icon**: A small gray icon (appears to be a disconnected/broken link or similar symbol)
- **Primary text**: "No combo run available." (bold, centered)
- **Secondary text**: "Live data arrives via the WS combo channel." (gray, smaller, centered below)

The rest of the page is empty white space extending to the bottom.

---

## Color Scheme

- **Primary accent**: Pink/Red (#e74c3c range)
- **Selected sidebar item**: Pink/light red background highlight
- **Start button**: Green (#2ecc71 range)
- **Reset button**: White with border/outline
- **Warning banner**: Yellow/amber background with dark text
- **Empty state text**: Gray (#999 range)
- **Background**: White (#ffffff) main content area, light gray sidebar
- **Overall feel**: Minimal, waiting-for-input state
