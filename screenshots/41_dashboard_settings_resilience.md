# Screenshot 41 — Dashboard: Resilience Settings

## Page Title & Breadcrumb

- **Header icon**: Red/orange shield/resilience icon
- **Page title**: "Resilience" (bold, large)
- **Subtitle**: "Circuit breaker, retry, and fallback configuration"
- **Breadcrumb**: Dashboard > Settings > Resilience

## Global Layout

- **Left sidebar**: Dark charcoal/navy vertical navigation bar with white text. "Resilience" under CONFIGURATION is highlighted in red/coral background.
- **Top bar**: White. "Cybernetics-Core v2.5.29" branding on left. Right: search, "Quick nav" (Cmd+K), EN language, avatar, bell (red dot), gear.
- **Bottom left footer**: Red "Restart" and "Shut down" buttons.
- **Main content**: White background, scrollable. Introductory text at top, then a series of collapsible sections each with an icon, title, scope/trigger/effect description, and configuration fields.

## Introductory Text

"Automatic retry, cooldown, and fallback when providers fail. This page only configures behavior. Live breaker state is shown on the Health page. Combo-specific retry and round-robin slot control remain on combo settings."

## Sections (Top to Bottom)

### 1. Auto-Disable Banned Accounts
- **Icon**: Red prohibited/ban icon
- **Title**: "Auto-Disable Banned Accounts"
- **Edit button**: Pencil icon, top-right
- **Description**: "Permanently mark provider connections as deactivated if they return specific terminal ban signals (e.g. HTTP 403 "verify your account"). This removes them from the combo rotation."
- **Checkbox**: "Auto-Disable Banned Accounts" (unchecked)
- **Ban Threshold box** (right side, gray background):
  - "BAN THRESHOLD"
  - "3 failure(s)" (bold)
  - "Consecutive ban signals required before permanent deactivation."

### 2. Request Queue & Rate
- **Icon**: Red queue/list icon
- **Title**: "Request Queue & Rate"
- **Scope/Trigger/Effect** line: "Scope: Per request queue" · "Trigger: Before sending to the upstream" · "Effect: Queues requests, limits concurrency, and spaces out calls"
- **Edit button**: Pencil icon, top-right
- **Description**: "This layer only controls queuing and pacing. It does not store cooldowns or open circuit breakers."
- **Configuration grid** (2 columns):
  - **Auto-enable for API key providers**: "Enabled" (bold)
  - **Requests per minute**: "10000" (bold)
  - **Minimum time between requests**: "100ms" (bold)
  - **Concurrent requests**: "10000" (bold)
  - **Maximum queue wait time**: "90000ms" (bold)

### 3. Connection Cooldown
- **Icon**: Red link/connection icon
- **Title**: "Connection Cooldown"
- **Scope/Trigger/Effect**: "Scope: Individual connection" · "Trigger: When a connection returns a transient upstream failure" · "Effect: Temporarily skip that connection and increase backoff for repeated failures"
- **Edit button**: Pencil icon, top-right
- **Description**: "The base cooldown covers transient connection failures. When upstream retry hints are enabled, the provider's explicit window overrides the local cooldown."
- **Two side-by-side panels**:
  - **Left panel** — "OAUTH PROVIDERS" (orange lock icon):
    - Base cooldown: "300000ms"
    - Use upstream retry hints: "No"
    - Use upstream 429 hints: "Default"
    - Max backoff steps: "3"
  - **Right panel** — "API KEY PROVIDERS" (red key icon):
    - Base cooldown: "300000ms"
    - Use upstream retry hints: "Yes"
    - Use upstream 429 hints: "Default"
    - Max backoff steps: "3"

### 4. Circuit Breaker per Provider
- **Icon**: Red circuit/breaker icon
- **Title**: "Circuit Breaker per Provider"
- **Scope/Trigger/Effect**: "Scope: Entire provider" · "Trigger: Final transport/server failures after connection fallback is exhausted" · "Effect: Temporarily blocks that provider until the reset time expires"
- **Edit button**: Pencil icon, top-right
- **Description**: "Live breaker state appears only on the Health page. Connection-scoped 429 rate limits stay in Connection Cooldown and do not trip the provider breaker."
- **Two side-by-side panels**:
  - **Left panel** — "OAUTH PROVIDERS" (orange lock icon):
    - Failure threshold: "5"
    - Degradation threshold: "4"
    - Reset time: "300000ms"
  - **Right panel** — "API KEY PROVIDERS" (red key icon):
    - Failure threshold: "3"
    - Degradation threshold: "2"
    - Reset time: "300000ms"

### 5. Wait For Cooldown
- **Icon**: Red hourglass/wait icon
- **Title**: "Wait For Cooldown"
- **Scope/Trigger/Effect**: "Scope: Current client request" · "Trigger: When all candidate connections are already cooling down" · "Effect: Waits on the server and retries when the first cooldown expires"
- **Edit button**: Pencil icon, top-right
- **Description**: "This only affects the current request. It does not store connection or provider state."
- **Configuration grid**:
  - **Enable server-side wait**: "Disabled" (bold)
  - **Maximum attempts**: "2"
  - **Maximum wait per attempt**: "120s"

### 6. Provider Cooldown
- **Icon**: Red clock/cooldown icon
- **Title**: "Provider Cooldown"
- **Scope/Trigger/Effect**: "Scope: All combo requests" · "Trigger: When a provider/connection fails" · "Effect: Skips the failed provider for a cooldown period before retrying"
- **Edit button**: Pencil icon, top-right
- **Description**: "Prevents subsequent requests from re-walking the same failing providers. Cooldown scales exponentially with consecutive failures."
- **Configuration grid**:
  - **Enable global provider cooldown**: "Disabled" (bold)
  - **Minimum cooldown**: "5000ms"
  - **Maximum cooldown**: "300000ms"

### 7. Model Lockout
- **Icon**: Red warning/lockout icon
- **Title**: "Model Lockout"
- **Description**: "Configure which HTTP error codes trigger per-model lockout and control the cooldown behavior."
- **Reset defaults button**: Top-right, outlined
- **Enable Model Lockout** toggle (OFF — gray)
- Helper text: "When enabled, models that fail with configured error codes are temporarily locked to prevent retry loops."
- **Error Codes** section:
  - Description: "HTTP status codes that trigger model lockout. Type a code and click Add, or select from suggestions."
  - **Pre-filled error code tags** (red badges with X to remove): `403 X` · `404 X` · `429 X` · `502 X` · `503 X` · `504 X`
  - Input field: "Add error code..." with "Add" button
- **Cooldown configuration** (2 columns):
  - **Base Cooldown (ms)**: "120000" — range note: "5,000ms – 600,000ms", helper: "Initial cooldown duration in milliseconds before a model can be retried."
  - **Max Cooldown (ms)**: "1800000" — range note: "> Base Cooldown – 3,600,000ms", helper: "Maximum cooldown duration in milliseconds. Prevents excessively long lockouts."
- **Exponential Backoff** toggle (ON — green)
  - Helper text: "When enabled, each consecutive failure increases the cooldown duration exponentially."
- **Max Backoff Steps**: "10"
  - Helper text: "Maximum number of backoff steps before the cooldown stops growing. The Max Cooldown cap is reached first in most configurations, making this a safety ceiling for when Max Cooldown is raised."

## Color Palette

- Background: White
- Sidebar: Dark navy/charcoal
- Primary accent: Red/coral for section icons, active sidebar, error code badges
- Section icon backgrounds: Light red/pink circles
- OAuth panels: Orange lock icon header
- API Key panels: Red key icon header
- Config values: Bold black text
- Scope/Trigger/Effect: Gray labels with bold values
- Edit buttons: Outlined with pencil icon
- Toggle ON: Green
- Toggle OFF: Gray
