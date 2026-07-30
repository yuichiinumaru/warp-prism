# Screenshot 13 — Audit Log (Compliance Audit)

## Page Identity

- **Header icon**: Red/orange shield icon (compliance symbol)
- **Title**: "Audit Log"
- **Subtitle**: "Compliance audit trail of API key usage, MCP tool calls, and policy events"
- **Breadcrumb**: `Dashboard > Audit`

## Top-Right Actions

- **Refresh** button (outline style, circular arrows icon)
- **Export** button (red/orange filled, download icon)

## Summary Line

- Text: "Showing 50 of 205 events"

## Filter Bar

Five filter inputs in a horizontal row:

| Filter | Type | Placeholder / Value |
|--------|------|---------------------|
| EVENT TYPE | Text input | "Filter by action or event" |
| ACTOR | Text input | "Filter by actor" |
| SEVERITY | Dropdown | "All severities" (selected, with chevron) |
| FROM | Date/time picker | "mm/dd/yyyy, --:-- --" with calendar icon |
| TO | Date/time picker | "mm/dd/yyyy, --:-- --" with calendar icon |

- **Clear filters** link (right-aligned, teal/green text)

## Audit Log Table

### Column Headers

`TIMESTAMP` | `EVENT TYPE` | `SEVERITY` | `SOURCE IP` | `USER / KEY` | `ACTION` | `RESULT` | `DETAILS`

### Table Data (all 50 rows visible)

All rows share these common values:
- **SEVERITY**: `INFO` (shown as a blue/teal rounded pill badge on every row)
- **SOURCE IP**: `172.17.0.1` (all rows)
- **USER / KEY**: `admin` (all rows)
- **RESULT**: `success` (all rows, green-tinted text)
- **DETAILS**: `View details` (link, teal/green text, on every row)

#### Distinct Event Types and Actions (in order of appearance):

| Rows (approx.) | EVENT TYPE | ACTION |
|-----------------|------------|--------|
| 1–3 | `Login Success` | `dashboard-auth` |
| 4–6 | `Provider Credentials Created` | `zai.5`, `zai.4`, `zai.3` |
| 7 | `Provider Credentials Created` | `zai.2` |
| 8 | `Provider Credentials Updated` | `zai.1` |
| 9 | `Provider Credentials Created` | `zai.1` |
| 10 | `Provider Credentials Created` | `openai.asdasd` |
| 11 | `Provider Credentials Created` | `openai.asd` |
| 12 | `Provider Credentials Created` | `openai.jj` |
| 13 | `Provider Credentials Created` | `openai.jj` |
| 14 | `Provider Credentials Created` | `openai.cc` |
| 15 | `Provider Credentials Updated` | `openai.ad` |
| 16 | `Provider Credentials Created` | `openai.ba` |
| 17 | `Provider Credentials Batch Revoked` | `provider_credentials` |
| 18 | `Provider Credentials Updated` | `openai.ad` |
| 19 | `Provider Credentials Created` | `openai.ad` |
| 20 | `Provider Credentials Updated` | `openai.Key 50` |
| 21 | `Provider Credentials Bulk Created` | `provider_credentials` |
| 22–50 | `Provider Credentials Created` | Sequential `openai.Key 50` through `openai.Key 22` (descending) |

#### Timestamps

All entries are dated **7/2/2026** with times ranging from **7:13:57 PM** (most recent, top) down to **6:27:28 PM** (bottom of page). The Login Success entries cluster around 7:13 PM; Provider Credential entries span 6:27–6:52 PM.

## Pagination

- Bottom-right: **Previous** (greyed out/disabled) and **Next"** (active, bold) links

## Sidebar (Left Navigation)

### Brand
- Logo: Red/orange hexagon icon with "Cybernetics-Core" text and version `v1.3.18`

### Navigation Sections

**MAIN:**
- Home (house icon)

**COMPROXY:**
- Endpoints (link icon)
- API Keys (key icon)
- Providers (server icon)
- Combos (layers icon)
- Combo Studio (blocks icon)
- Provider Quota (gauge icon)
- API Endpoints (plug icon)
- Webhooks (bell icon)
- Proxy (shield icon)

**ANALYTICS:**
- Usage (bar chart icon)
- Combo Health (heart icon)
- Utilization (pie chart icon)
- Cache (database icon) — highlighted with light red/pink background and red text
- Compression (arrow-compress icon)
- Search (magnifying glass icon)
- Eval (checklist icon)
- Provider Stats (graph icon)

**MONITORING:**
- Activity (activity icon)
- Logs (file-text icon)
- Proxy Logs (file-text icon)
- Console Logs (terminal icon)
- **Audit Log** (shield-check icon) — **CURRENT PAGE**, highlighted with red/pink background, red text
- MCP Audit (box icon)
- A2A Audit (people icon)

**AGENTIC FEATURES:**
- Health (heart-pulse icon)
- Runtime (gauge icon)
- Memory (brain icon)
- AgentSkills (puzzle icon)
- OmniSkills (sparkles icon)
- MCP Server (server icon)
- A2A Server (people icon)
- Plugins (puzzle-piece icon)

**OTHER FEATURES** (collapsed chevron)
**CONFIGURATION** (collapsed chevron)
**HELP** (collapsed chevron)

## Footer (Bottom-Left)

- Green dot with "Ready" text
- Red power icon with "Shutd..." (truncated "Shutdown") text

## Header Bar (Top)

- Left: Collapse chevron (`<`)
- Center: Search bar placeholder "Quick nav" with `Ctrl+K` badge
- Right: `EN` language selector with US flag, Dark mode toggle (moon icon), Warning triangle icon, User avatar icon
