# Screenshot 44 — Dashboard Settings: Sidebar Customization

**URL Path:** `Dashboard > Settings > Sidebar`
**Application:** Cybernetics Core v1.2.38

---

## Global Layout

Two-column layout: **left sidebar** (dark background, ~180px) for navigation and **main content area** (white background) displaying the Sidebar Customization settings. Top bar has "Quick nav" search (`Ctrl K`), language selector (`EN`), and notification icons.

---

## Left Sidebar (Navigation)

Identical to other dashboard pages. Branded **"Cybernetics Core"** at top. Sections:

- **OMNIPROXY:** Endpoints, API Keys, Providers, Combos, Combo Studio, Provider Quota, API Endpoints, Webhooks, Proxy
- **ANALYTICS:** Usage, Combo Health, Utilization, Cache, Compression, Search, Evals, Provider Stats
- **MONITORING:** Activity, Logs, Proxy Logs, Console Logs, Audit Log, MCP Audit, A2A Audit, Health, Runtime
- **AGENTIC FEATURES:** Memory, AgentSkills, OmniSkills, MCP Server, A2A Server, Plugins
- **OTHER FEATURES:** Media, Batch Jobs, Files
- **CONFIGURATION:** Storage, Appearance, AI Settings, Global Routing, Resilience, Advanced, Security, Feature Flags, **Sidebar** (highlighted in red, currently active)
- **HELP:** Docs, Issues, Changelog

Bottom: green "Normal" and red "Shut..." status indicators.

---

## Breadcrumb

`Dashboard > Settings > Sidebar` — small gray text.

---

## Page Header

- **Icon:** Red square icon (sidebar representation)
- **Title:** "Sidebar" (large, bold)
- **Subtitle:** "Control which items appear in the sidebar and their order"

---

## Presets Section

- **Header:** "Presets" in bold
- **Description:** "Start from a role-based layout. Any change after applying a preset switches to Custom."
- **Active:** "Custom" (bold label)
- Four preset cards arranged horizontally:
  1. **All** — "Show everything" — with a grid/boxes icon
  2. **Minimal** — "Core pages only" — with a dash/minus icon
  3. **Developer** — "Dev & monitor tools" — with a code bracket icon `</>`
  4. **Admin** — "Monitoring & audit" — with a person/shield icon

---

## Visibility & Order Section

- **Header:** "Visibility & Order" in bold
- **Description:** "Toggle items on/off and drag to reorder sections and their entries."
- **"Reset to default"** link (red text) — top-right

The section is organized into collapsible groups, each with a section header in uppercase gray text. Each item has:
- A **drag handle** (six-dot grid icon) on the far left
- An **icon** (various: home, key, cube, link, etc.)
- A **label** (item name)
- A **toggle switch** (red = ON, gray = OFF) on the far right

### HOME Section
- **Home** — toggle: **ON** (red)

### OMNIPROXY Section
- **Endpoints** — toggle: **ON**
- **API Keys** — toggle: **ON**
- **Providers** — toggle: **ON**
- **Embedded Services** — toggle: **OFF** (gray)
- **Combos** — toggle: **ON**
- **Combo Studio** — toggle: **ON**
- **Provider Quota** — toggle: **ON**
- **Quota Sharing** — toggle: **OFF**

### INTEGRATIONS Sub-section (with collapse arrow)
- Counter label: `3/2` and "Separators" toggle
- **API Endpoints** — toggle: **ON**
- **Webhooks** — toggle: **ON**
- **Proxy** — toggle: **ON**

### TOOLS Sub-section
- Counter label: `0/8` and "Separators" toggle
- **CLI Coders** — toggle: **OFF**
- **CLI Agents** — toggle: **OFF**
- **ACP Agents** — toggle: **OFF**
- **Cloud Agents** — toggle: **OFF**
- **Agent Bridge** — toggle: **OFF**
- **Traffic Inspector** — toggle: **OFF**

### COMPRESSION CONTEXT Sub-section
- Counter label: `0/12` and "Separators" toggle
- **Compression Settings** — toggle: **OFF**
- **Caveman** — toggle: **OFF**
- **RTK** — toggle: **OFF**
- **Headroom** — toggle: **OFF**
- **Session Dedup** — toggle: **OFF**
- **CCR** — toggle: **OFF**
- **LLMLingua** — toggle: **OFF**
- **Lite** — toggle: **OFF**
- **Aggressive** — toggle: **OFF**
- **Ultra** — toggle: **OFF**
- **Engine Combos** — toggle: **OFF**
- **Compression Studio** — toggle: **OFF**

### ANALYTICS Section
- **Usage** — toggle: **ON**
- **Combo Health** — toggle: **ON**
- **Utilization** — toggle: **ON**
- **Cache** — toggle: **ON**
- **Compression** — toggle: **ON**
- **Search** — toggle: **ON**
- **Evals** — toggle: **ON**
- **Provider Stats** — toggle: **ON**

### COSTS Section
- **Overview** — toggle: **OFF**
- **Pricing** — toggle: **OFF**
- **Budget** — toggle: **OFF**
- **Free-Tier Budget** — toggle: **OFF**
- **Free Provider Rankings** — toggle: **OFF**

### MONITORING Section
- **Activity** — toggle: **ON**
- **LOGS** Sub-section (with collapse arrow):
  - Counter: `3/3` and "Separators" toggle
  - **Logs** — toggle: **ON**
  - **Proxy Logs** — toggle: **ON**
  - **Console Logs** — toggle: **ON**
- **AUDIT** Sub-section:
  - Counter: `3/3` and "Separators" toggle
  - **Audit Log** — toggle: **ON**
  - **MCP Audit** — toggle: **ON**
  - **A2A Audit** — toggle: **ON**
- **SYSTEM** Sub-section:
  - Counter: `0/2` and "Separators" toggle
  - **Health** — toggle: **OFF**
  - **Runtime** — toggle: **OFF**

### AGENTIC FEATURES Section
- **Memory** — toggle: **ON**
- **AgentSkills** — toggle: **ON**
- **OmniSkills** — toggle: **ON**
- **MCP Server** — toggle: **ON**
- **A2A Server** — (truncated, continues below fold)

---

## Visual Style Notes

- **Toggle switches:** Red pill toggles when ON, gray when OFF
- **Drag handles:** Six-dot grid icons (⠿) on the left of each row, indicating drag-and-drop reordering
- **Section headers:** Uppercase gray text (e.g., "HOME", "OMNIPROXY", "ANALYTICS")
- **Sub-section headers:** Smaller uppercase gray text with collapse/expand chevrons
- **Counter labels:** Small gray text showing enabled/total count (e.g., "3/2", "0/8")
- **Preset cards:** White cards with light border, centered icon above label and description
- **Spacing:** Clean vertical spacing between items (~8-12px per row)
- **Active sidebar item:** "Sidebar" in the left navigation is highlighted in red text
