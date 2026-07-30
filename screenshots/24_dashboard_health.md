# Dashboard Screenshot: Health

**File**: `24_dashboard_health.png`
**Page Title**: Health — System health overview: providers, circuit breakers, rate limits, and database

---

## Overall Layout

Standard OmniRoute dashboard layout with a left sidebar navigation and main content area. This is a very long, scrollable page with multiple sections displaying system health data, provider health details, and a provider health matrix.

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
- Combo Studio — Live routing console
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
- **Health** — **Currently selected (highlighted with pink/red background)** — System health check
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

- Breadcrumb: Dashboard / Health
- Right side: Search icon, "Quick nav" with `⌘K`, "EN" language selector, user avatar, notification bell (yellow/orange badge), settings gear icon

---

## Main Content Area

### Page Header
- **Title**: "Health" (large, bold) with red/pink heart/pulse icon
- **Subtitle**: "System health overview: providers, circuit breakers, rate limits, and database" (gray text)
- **Right side**: "Updated 7:14:53 PM" timestamp with a circular refresh icon

---

### Section 1: All Systems Operational Banner

- **Green banner** spanning full width with green checkmark icon
- Text: "All systems operational" (green text on light green background)

---

### Section 2: System Telemetry (White Card)

**Card Header**:
- Red/pink heartbeat/pulse icon + "System Telemetry" (bold)
- Subtitle: "Rolling request, runtime, session, and memory signals from this OmniRoute process."
- "Updated 7:14:53 PM" timestamp
- **Refresh** button (circular arrow icon, top right)

**Metrics Grid** (2 rows × 3 columns):

| Metric | Value | Icon | Color |
|--------|-------|------|-------|
| UPTIME | **1h 29m** | Blue clock icon (circle) | Blue |
| TOTAL REQUESTS | **4** | Red/pink document icon | Red/Pink |
| AVG LATENCY | **17218ms** | Orange/red speedometer icon | Orange |
| ERROR RATE | **0.00%** | Green checkmark circle icon | Green |
| ACTIVE CONNECTIONS | **1** | Blue/purple network icon | Blue |
| MEMORY USAGE | **887.2 MB** | Purple brain/chip icon | Purple |

**Sparkline Charts** (3 small charts below the metrics):
- **Latency trend**: Small line chart, value "22766ms p95"
- **Throughput trend**: Small line chart, value "4"
- **Memory trend**: Small line chart, value "364.7 MB"

---

### Section 3: Provider Health Autopilot (White Card)

**Card Header**:
- Red/pink crosshair/target icon + "Provider Health Autopilot" (bold)
- Subtitle: "Finds unstable providers, account cooldowns, stale errors, and safe manual fixes."
- **Refresh** button (top right)

**Summary Stats Row** (4 columns):

| Stat | Value | Color |
|------|-------|-------|
| STATUS | **Critical** | Red text |
| ISSUES | **139** | Bold black |
| ACTIONS | **27** | Bold black |
| CONNECTIONS | **344** | Bold black |

#### Provider Details (expandable rows, each with provider name, score, and issue cards):

**anthropic-compatible-b4cba380-b8e6-4ff2-8de9-c8ccb3967453**
- Score: 65% · Active: 1/1 · Cooldown: 0 · Model lockouts: 0
- Red "locked" badge
- Issue: "12 has a terminal account state"
  - "Check billing, re-authenticate, or replace the credential before reactivating it."
  - "12 - code 401 - unauthorized"
- Red "Reset" button on the right

**deepinfra**
- Score: 65% · Active: 1/1 · Cooldown: 0 · Model lockouts: 0
- Red "locked" badge
- Issue: "jj has a terminal account state"
  - "Check billing, re-authenticate, or replace the credential before reactivating it."
  - "jj - code 402 - quota_exceeded"
- Red "Reset" button

**deepseek**
- Score: 65% · Active: 5/5 · Cooldown: 0 · Model lockouts: 0
- Red "locked" badge
- Multiple issues (3 visible):
  1. "PF has a terminal account state" — code 402 - quota_exceeded
  2. "NR has a terminal account state" — code 402 - quota_exceeded
  3. "JJ has a terminal account state" — code 402 - quota_exceeded
  4. "AQ has a terminal account state" — code 402 - quota_exceeded
- Red "Reset" button

**freemodel-dev**
- Score: 65% · Active: 1/1 · Cooldown: 0 · Model lockouts: 0
- Red "locked" badge
- Issue: "l has a terminal account state"
  - code 402.0 - quota_exceeded
- Red "Reset" button

**gemini**
- Score: 65% · Active: 13/13 · Cooldown: 0 · Model lockouts: 0
- Red "locked" badge
- Multiple issues (4 visible):
  1. "pb has a terminal account state" — code no_refresh_token - no_refresh_token
  2. "yi has a terminal account state" — code no_refresh_token - no_refresh_token
  3. "sw has a terminal account state" — code no_refresh_token - no_refresh_token
  4. "pf has a terminal account state" — code no_refresh_token - no_refresh_token
- Red "Reset" button

**hyperbolic**
- Score: 65% · Active: 1/1 · Cooldown: 0 · Model lockouts: 0
- Red "locked" badge
- Issue: "2m has a terminal account state"
  - code 402.0 - quota_exceeded
- Red "Reset" button

---

### Section 4: Provider Health Matrix (White Card)

**Card Header**:
- Red/pink grid icon + "Provider Health Matrix" (bold)
- Subtitle: "Provider × account × model state from breakers, cooldowns, lockouts and logs."
- **Updated** timestamp: "Updated Jul 2, 07:14 PM"
- **Controls** (top right):
  - "24h" dropdown selector
  - "Provider Filter" text input
  - "Only Issues" checkbox/toggle
  - **Refresh** button (green)

**Summary Stats Row** (5 columns):

| Stat | Value |
|------|-------|
| PROVIDERS | **69** |
| ACCOUNTS | **344** |
| MODELS | **2313** |
| ISSUES | **386** |
| DEGRADED | **15** |
| DOWN | **14** |

#### Provider Entry: agy

- **Provider name**: "agy" with eye icon
- **Badges**: "CB CLOSED" (green badge)
- Subtitle: "0/0 active accounts · 0 req · — success · — avg"
- Expandable (chevron up/down on the right)

**Score Summary Row**:
| Metric | Value |
|--------|-------|
| SCORE | **100%** |
| LAST REQUEST | — |
| LAST ERROR | — |
| INACTIVE | **0** |

**Account List** (each row shows a masked email, UUID, model count, and health status):

1. **m***@gmail.com — UUID: `03467264-8530-4727-8252-0c142960996` — 0 models — "No synced models or recent traffic yet." — Green "● healthy" badge
2. **g***@gmail.com — UUID: `44c04295-4799-4077-a688894326c` — 0 models — "No synced models or recent traffic yet." — Green "● healthy" badge
3. **b***@gmail.com — UUID: `31e00127-1ea4-49b4-9841-d735991cab00` — 0 models — "No synced models or recent traffic yet." — Green "● healthy" badge
4. **p***@gmail.com — UUID: `4711018b-8784-45ed-a1cb-96af0531fdee` — 0 models — "No synced models or recent traffic yet." — Green "● healthy" badge
5. **s***@gmail.com — UUID: `65c1e8b0-6019-40da-9310-01a4933df3c5` — 0 models — "No synced models or recent traffic yet." — Green "● healthy" badge
6. **a***@gmail.com — UUID: `fa02a2795-89c1-40e2-9122-f7ada935d5df` — 0 models — "No synced models or recent traffic yet." — Green "● healthy" badge
7. **j***@gmail.com — UUID: `e99e9ad8-a629-4c63-b642b4867dab` — 0 models — "No synced models or recent traffic yet." — Green "● healthy" badge

---

## Color Scheme

- **Primary accent**: Pink/Red (#e74c3c range)
- **Operational banner**: Green background, green text, green checkmark
- **Critical status**: Red text
- **Locked badges**: Red background with white text
- **Reset buttons**: Red/pink background with white text
- **Healthy badges**: Green text with green dot
- **CB CLOSED badge**: Green background
- **Metric icons**: Blue (uptime), Red/Pink (requests), Orange (latency), Green (error rate), Purple (memory)
- **Score 100%**: Bold black
- **Background**: White (#ffffff) main content area, light gray sidebar
- **Card borders**: Light gray rounded cards with subtle shadows
- **Overall density**: High — this is the most data-dense page in the dashboard
