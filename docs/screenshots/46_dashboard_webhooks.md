# Screenshot 46 — Dashboard: Webhooks

**URL Path:** `Dashboard > Webhooks`
**Application:** Cybernetics Core v1.2.38

---

## Global Layout

Two-column layout: **left sidebar** (dark background, ~180px) and **main content area** (white/light gray background) displaying the Webhooks management page. Top bar has "Quick nav" search (`Ctrl K`), language selector (`EN`), and notification icons.

---

## Left Sidebar (Navigation)

Standard navigation sidebar branded **"Cybernetics Core"**. The **Webhooks** item is highlighted in red (currently active).

Sections visible:
- **OMNIPROXY:** Endpoints, API Keys, Providers, Combos, Combo Studio, Provider Quota, API Endpoints, **Webhooks** (red, active), Proxy
- **ANALYTICS:** Usage, Combo Health, Utilization, Cache, Compression, Search, Evals, Provider Stats
- **MONITORING:** Activity, Logs, Proxy Logs, Console Logs, Audit Log, MCP Audit, A2A Audit, Health, Runtime
- **AGENTIC FEATURES:** Memory, AgentSkills, OmniSkills, MCP Server, A2A Server, Plugins
- **OTHER FEATURES:** Media, Batch Jobs, Files
- **CONFIGURATION:** Storage, Appearance, AI Settings, Global Routing, Resilience, Advanced, Security, Feature Flags, Sidebar
- **HELP:** Docs, Issues, Changelog

Bottom: green "Normal" and red "Shut..." status indicators.

---

## Breadcrumb

`Dashboard > Webhooks` — small gray text.

---

## Page Header

- **Icon:** Red webhook/link icon
- **Title:** "Webhooks" (large, bold)
- **Subtitle:** "Configure HTTP callbacks for system events"
- **"+ Add Webhook"** button — red background, white text, positioned top-right

---

## Statistics Cards

Four stat cards displayed in a horizontal row:

| Card | Label | Value | Icon Color |
|------|-------|-------|------------|
| 1 | **TOTAL** | **0** | Red (light red circle with webhook icon) |
| 2 | **ACTIVE** | **0** | Green (light green circle with checkmark) |
| 3 | **INACTIVE** | **0** | Gray (light gray circle with pause icon) |
| 4 | **ERRORED** | **0** | Red (light red circle with alert icon) |

Each card has a large bold number "0" and the label in small uppercase gray text above it.

---

## Configured Webhooks Section

- **Header:** "Configured Webhooks" in bold
- **Subtitle:** "Manage delivery endpoints, subscribed events, status, and last sends."
- A **refresh icon** (circular arrow) in the top-right of this section
- **Empty state:** Centered icon (light gray webhook/link icon) with text: "No webhooks configured yet."

---

## Right Sidebar: How Webhooks Work

A vertical informational panel on the right side with a light blue/gray background:

- **Header:** "How Webhooks Work" (bold)
- **4 numbered steps:**
  1. "Choose an integration provider (e.g., Slack, Discord, custom webhook) and copy its receiving URL."
  2. "Configure system events to subscribe to (e.g., completion, errors, model deprecation, usage thresholds)."
  3. "Verify the configuration by sending a test payload to make sure the endpoint responds correctly."
  4. "Secure your endpoint by validating the X-Webhook-Signature HMAC-SHA256 header using the webhook's secret."
- **Additional info:**
  - "Webhook deliveries have a timeout of 10 seconds and are retried with exponential backoff."
  - "Failed deliveries are retried up to 5 times with exponential backoff."
- **Link:** "Read the full Webhooks developer guide" (red text, with external link icon)

---

## Visual Style Notes

- **Stats cards:** White background with subtle border, each containing a colored circle icon, bold large number, and gray label
- **Empty state:** Centered layout with gray icon and muted text
- **Right sidebar info panel:** Light blue/gray tinted background, differentiated from main content
- **Step list:** Numbered 1-4 with small gray circular number badges
- **Button:** Red background, white text, rounded corners
- **Overall color scheme:** Red accent for active states and CTAs, gray for inactive/neutral elements
- **Content is sparse** — the page shows an empty state with no webhooks configured, making the info panel the most content-rich part of the view
