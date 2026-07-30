# Screenshot 39 — Dashboard: Feature Flags

## Page Title & Breadcrumb

- **Header icon**: Red/orange flag icon
- **Page title**: "Feature Flags" (bold, large)
- **Subtitle line**: "9 active" (green text) · "25 inactive" (gray text) · "0 DB overrides" (blue/purple link text)
- **Breadcrumb**: Dashboard > Settings > Feature Flags

## Global Layout

- **Left sidebar**: Dark charcoal/navy vertical navigation bar with white text. "Feature Flags" under CONFIGURATION is highlighted in red/coral background.
- **Top bar**: White. "Cybernetics-Core v2.5.29" branding on left. Right side: search icon, "Quick nav" button (Cmd+K), EN language selector with US flag, user avatar, bell notification icon, settings gear.
- **Bottom left footer**: Red "Restart" button and "Shut down" button.
- **Main content**: White background, scrollable. Feature flags displayed as a grid of cards, 3 columns wide.

## Top Controls

- **Search input**: "Search flags..." with magnifying glass icon (left of filter)
- **Filter dropdown**: "All" dropdown on the right

## Feature Flag Cards

Each card has a colored category badge (top-left), a toggle switch or dropdown (top-right), the flag name in bold monospace, a description in gray text, and a "Source" label at the bottom.

### Row 1

| Card | Category | Flag Name | Description | State | Source |
|------|----------|-----------|-------------|-------|--------|
| 1 | Security (red) | `REQUIRE_API_KEY` | Require an API key for all incoming requests | Toggle ON (green) | `DEF` |
| 2 | Security (red) | `INPUT_SANITIZER_ENABLED` | Enable input sanitization for all requests | Toggle ON (green) | `DEF` |
| 3 | Security (red) | `INJECTION_GUARD_MODE` | Set the prompt injection guard mode | Dropdown: "off" | `DEF` |

### Row 2

| Card | Category | Flag Name | Description | State | Source |
|------|----------|-----------|-------------|-------|--------|
| 4 | Security (red) | `PII_REDACTION_ENABLED` | Redact personally identifiable information from requests | Toggle OFF (gray) | `DEF` |
| 5 | Security (red) | `PII_RESPONSE_SANITIZATION` | Sanitize PII from provider responses | Toggle OFF (gray) | `DEF` |
| 6 | Security (red) | `PII_RESPONSE_SANITIZATION_MODE` | Mode for PII response sanitization: redact (replace PII), warn (log only), block (reject request) | Dropdown: "redact" | `DEF` |

### Row 3

| Card | Category | Flag Name | Description | State | Source |
|------|----------|-----------|-------------|-------|--------|
| 7 | Security (red) | `OUTBOUND_SSMF_GUARD_ENABLED` | Block outbound requests to private/internal IP ranges | Toggle ON (green) | `DEF` |
| 8 | Security (red) | `ALLOW_API_KEY_REVEAL` | When enabled, allow dashboard users to reveal stored API keys instead of only seeing masked values | Toggle OFF (gray), red dot indicator | `ENV` |
| 9 | Network (orange) | `ENABLE_TLS_FINGERPRINT` | Enable TLS fingerprint stealth mode | Toggle OFF (gray), orange dot | `DEF` |

### Row 4

| Card | Category | Flag Name | Description | State | Source |
|------|----------|-----------|-------------|-------|--------|
| 10 | Network (orange) | `ONEPROXY_ENABLED` | Enable 1proxy request proxying | Toggle ON (green) | `DEF` |
| 11 | Network (orange) | `PROXY_AUTO_SELECT_ENABLED` | When no proxy is assigned to a connection, auto-select the first working proxy from the registry. Off by default — otherwise any single registry... | Toggle OFF (gray), orange dot | `DEF` |
| 12 | Network (orange) | `OMNIRoute_CONTROL_PLANE_PROXY_DIRECT_FALLBACK` | Allow OAuth and provider validation flows to bypass a primed proxy and connect directly when proxy reachability pre-checks fail. Off by default... | Toggle OFF (gray) | `DEF` |

### Row 5

| Card | Category | Flag Name | Description | State | Source |
|------|----------|-----------|-------------|-------|--------|
| 13 | Network (orange) | `MITM_DISABLE_TLS_VERIFY` | Disable TLS certificate verification for MITM proxy | Toggle OFF (gray), red dot, "restart" label | `DEF` |
| 14 | Network (orange) | `OMNIRoute_ALLOW_PRIVATE_PROVIDER_URLS` | Allow provider URLs pointing to private/internal networks | Toggle OFF (gray), orange dot | `DEF` |
| 15 | Network (orange) | `ENABLE_CC_COMPATIBLE_PROVIDER` | Enable Claude Code compatible provider mode | Toggle OFF (gray), "restart" label | `DEF` |

### Row 6

| Card | Category | Flag Name | Description | State | Source |
|------|----------|-----------|-------------|-------|--------|
| 16 | Policies (yellow) | `TOOL_POLICY_MODE` | Set the tool use policy enforcement mode | Dropdown: "disabled" | `DEF` |
| 17 | Policies (yellow) | `RATE_LIMIT_AUTO_ENABLE` | Automatically enable rate limiting based on usage patterns | Toggle OFF (gray) | `DEF` |
| 18 | Policies (yellow) | `ALLOW_MULTI_CONNECTIONS_PER_COMPAT_MODE` | Allow multiple connections per compatibility mode | Toggle OFF (gray) | `DEF` |

### Row 7

| Card | Category | Flag Name | Description | State | Source |
|------|----------|-----------|-------------|-------|--------|
| 19 | Runtime (blue) | `OMNIRoute_MCP_ENFORCE_SCOPES` | Enforce scope restrictions on MCP tool access | Toggle ON (green) | `DEF` |
| 20 | Runtime (blue) | `OMNIRoute_MCP_COMPRESS_DESCRIPTIONS` | Compress MCP tool descriptions to reduce token usage | Toggle OFF (gray) | `DEF` |
| 21 | Runtime (blue) | `OMNIRoute_ENABLE_RUNTIME_BACKGROUND_TASKS` | Enable background task processing at runtime | Toggle OFF (gray) | `DEF` |

### Row 8

| Card | Category | Flag Name | Description | State | Source |
|------|----------|-----------|-------------|-------|--------|
| 22 | Runtime (blue) | `OMNIRoute_DISABLE_BACKGROUND_SERVICES` | Disable all background services (quota refresh, sync, etc.) | Toggle OFF (gray), warning triangle icon | `DEF` |
| 23 | Runtime (blue) | `OMNIRoute_RTK_TRUST_PROJECT_FILTERS` | Trust project-level filters from RTK without validation | Toggle OFF (gray), warning triangle icon | `DEF` |
| 24 | Runtime (blue) | `OMNIRoute_ENABLE_LIVE_WS` | Start the real-time dashboard WebSocket server on import (port 30129, loopback-bound by default). Default: enabled. Set to '0' or 'false' to... | Toggle ON (green) | `DEF` |

### Row 9

| Card | Category | Flag Name | Description | State | Source |
|------|----------|-----------|-------------|-------|--------|
| 25 | Runtime (blue) | `OMNIRoute_CODEX_WS_ENABLED` | Allow Codex to use the Responses-over-WebSocket transport (the default for responsesApiEnabled and codexTransport=websocket). When off... | Toggle ON (green) | `DEF` |
| 26 | Runtime (blue) | `OMNIRoute_EMERGENCY_FALLBACK` | Route budget-exhausted requests to the emergency free fallback provider pool | Toggle ON (green) | `DEF` |
| 27 | Runtime (blue) | `MODEL_CATALOG_INCLUDE_NAMES` | Include display-friendly name fields in /models responses. Disable to return model ID only | Toggle ON (green) | `DEF` |

### Row 10

| Card | Category | Flag Name | Description | State | Source |
|------|----------|-----------|-------------|-------|--------|
| 28 | Runtime (blue) | `ARENA_ELO_SYNC_ENABLED` | Enable the OpenRouter Arena AI leaderboard ELO sync for model intelligence rankings | Toggle ON (green) | `DEF` |
| 29 | CLI (purple) | `CLI_COMPAT_ALL` | Enable compatibility mode for all CLI clients | Toggle OFF (gray) | `DEF` |
| 30 | CLI (purple) | `MODEL_ALIAS_COMPAT_ENABLED` | Enable model alias compatibility layer | Toggle OFF (gray) | `DEF` |

### Row 11

| Card | Category | Flag Name | Description | State | Source |
|------|----------|-----------|-------------|-------|--------|
| 31 | CLI (purple) | `PRICING_SYNC_ENABLED` | Enable automatic pricing data synchronization (requires the PRICING_SYNC_ENABLED environment variable to be set to true) | Toggle OFF (gray) | `DEF` |
| 32 | Health (teal) | `OMNIRoute_DISABLE_LOCAL_HEALTHCHECK` | Disable the local instance health check endpoint | Toggle OFF (gray) | `DEF` |
| 33 | Health (teal) | `OMNIRoute_DISABLE_TOKEN_HEALTHCHECK` | Disable the token validation health check | Toggle OFF (gray) | `DEF` |

### Row 12

| Card | Category | Flag Name | Description | State | Source |
|------|----------|-----------|-------------|-------|--------|
| 34 | Health (teal) | `SKILLS_SANDBOX_NETWORK_ENABLED` | Enable network access in the skills sandbox environment | Toggle OFF (gray), warning triangle | `DEF` |

## Color Palette

- Background: White
- Sidebar: Dark navy/charcoal
- Category badge colors: Security (red), Network (orange), Policies (yellow), Runtime (blue), CLI (purple), Health (teal)
- Toggle ON: Green
- Toggle OFF: Gray
- Warning icons: Yellow triangle
- "restart" labels: Small gray text
- Source badges: `DEF` (green bg), `ENV` (red bg)
- Red dot indicators on some flags (e.g., ALLOW_API_KEY_REVEAL, MITM_DISABLE_TLS_VERIFY)
