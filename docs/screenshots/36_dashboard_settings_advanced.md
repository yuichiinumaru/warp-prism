# Screenshot Report: Dashboard — Settings > Advanced Page

**File**: `36_dashboard_settings_advanced.png`
**Page Title**: Advanced
**Subtitle**: "Advanced: payload rules, request limits, and proxy API settings"
**Breadcrumb**: Dashboard > Settings > Advanced

---

## Enable Debug Mode Toggle

At the very top of the content area:
- **Label**: "Enable Debug Mode" with a red gear/cog icon.
- **Toggle**: Red/coral toggle switch in the **ON** position (right-aligned).

---

## Payload Rules Section

**Section Header**: "Payload Rules" with a circular arrow/refresh icon.
**Description**: "Configure request payload mutations by model and protocol. Changes are persisted in settings and hot reloaded into the runtime immediately after save."

### Rule Type Cards (4-column row)

| Card | Title | Description |
|------|-------|-------------|
| 1 | **default** | Applies params only when the target path is missing from the outgoing payload. |
| 2 | **override** | Forces values onto the payload, replacing anything already present at that path. |
| 3 | **filter** | Removes blocked params from the payload before the upstream request is sent. |
| 4 | **defaultRaw** | Like default, but string values are parsed as JSON first when possible. The legacy input key default-raw is also accepted on save. |

### Rule Counts (below cards)
- default: 0
- override: 0
- filter: 0
- defaultRaw: 0

### Editor

**Label**: "Editor" (left) and **Status**: "Ready" (right, green text).
**Instruction**: "Use the runtime schema shapes: default, override, filter, defaultRaw. The API also accepts the legacy input key default-raw."

A code editor textarea with a JSON object:
```json
{
  "default": {},
  "override": [],
  "filter": [],
  "defaultRaw": []
}
```

### Action Buttons (below editor)
- **Refresh** — outlined/gray button.
- **Reset** — outlined/gray button.
- **Save Payload Rules** — red/coral filled button.

---

## Request Body Limit Section

**Section Header**: "Request Body Limit" with a settings/gear icon.
**Description**: "Maximum API payload size accepted before a request body is parsed. Dedicated upload routes keep at least their built-in 100 MB limit."

- **Input field**: Shows value "10" in a text input box.
- **Unit label**: "MB" to the right of the input.
- **Save button**: Small red/coral "Save" button next to the unit label.

---

## CLIPProxyAPI Recycle Management Banner

A blue info banner spanning the full width:
- **Icon**: Blue information circle.
- **Text**: "CLIPProxyAPI recycle management (install, start, stop) has moved to Providers → Services. Fallback routing settings below remain here."
- The text "Providers → Services" appears as a link/clickable reference.

---

## CLIPProxyAPI Fallback Section

**Section Header**: "CLIPProxyAPI Fallback" with a green circular arrow icon.
**Description**: "When enabled, failed requests are retried through CLIPProxyAPI (localhost:8117)."
- **Label**: "Enable CLIPProxyAPI Fallback"
- **Toggle**: Toggle switch in the **OFF** position (gray, left-aligned).

---

## CLIPProxyAPI Status Section

**Section Header**: "CLIPProxyAPI Status".
- **Status text**: "Not detected" in gray text.

---

## Sidebar (Left Navigation)

The sidebar shows an expanded **CONFIGURATION** section with the following items visible:

| Icon | Label | Subtitle |
|------|-------|----------|
| Database | Storage | Database and backups |
| Palette | Appearance | Theming and layout |
| Brain | AI Settings | AI behavior defaults |
| Globe | Global Routing | Default model routing |
| Shield | Resilience | Circuit breakers |
| Wrench | **Advanced** | **Currently selected** (highlighted with red/pink background) |
| Lock | Security | Auth and encryption |
| Flag | Feature Flags | Toggle system capabilities |
| PanelLeft | Sidebar | Customize sidebar layout |

### Other Sidebar Sections

- **OMNIPROXY**: Endpoints, API Keys, Providers, Combos, Combo Studio, Provider Quota, API Endpoints, Webhooks, Proxy.
- **ANALYTICS**: Usage, Combo Health, Utilization, Cache, Compression, Search, Eval's, Provider Stats.
- **MONITORING**: Activity, Logs, Proxy Logs, Console Logs, Audit Log, MCP Audit, A2A Audit, Health, Runtime.
- **AGENTIC FEATURES**: Memory, AgentSkills, OmniSkills, MCP Server, A2A Server, Plugins.
- **OTHER FEATURES**: Media, Batch Jobs, Files.
- **HELP**: Docs, Issues, Changelog.

### Footer
- **Restart** — green dot with text.
- **Share** — red/pink power icon with text "Share...".
