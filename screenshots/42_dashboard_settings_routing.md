# Screenshot 42 — Dashboard: Global Routing Settings

## Page Title & Breadcrumb

- **Header icon**: Purple/blue routing/arrows icon
- **Page title**: "Global Routing" (bold, large)
- **Subtitle**: "Routing rules, model aliases, combo defaults, and degradation settings"
- **Breadcrumb**: Dashboard > Settings > Routing

## Global Layout

- **Left sidebar**: Dark charcoal/navy vertical navigation bar with white text. "Global Routing" under CONFIGURATION is highlighted in red/coral background.
- **Top bar**: White. "Cybernetics-Core v2.5.29" branding on left. Right: search, "Quick nav" (Cmd+K), EN language, avatar, bell (red dot), gear.
- **Bottom left footer**: Red "Restart" and "Shut down" buttons.
- **Main content**: White background, scrollable. Multiple card sections.

## Sections (Top to Bottom)

### 1. Combo Defaults
- **Icon**: Purple sliders/routing icon
- **Title**: "Combo Defaults"
- **Label**: "Global combo configuration" (right-aligned, gray)
- **Two info boxes** (top):
  - **Blue info box**: "Advanced routing guidance" — "This strategy is applied to both new combo defaults and global account fallback routing. Use Fill First for predictable account priority, Round Robin plus Sticky Limit for account batches, and P2C for latency resilience."
  - **Orange/warning info box**: "How to tune combo defaults" — "Keep Max Retries low for fast-failover flows; increase timeout only for long generation tasks. Use provider overrides when one provider needs different timeout/retry behavior than global defaults."

- **Default Strategy** section:
  - Description: "Applied to new combos without explicit strategy and synced to global account fallback routing."
  - **Strategy grid** (3 columns × 5 rows of radio-button-style options):
    - Priority · Weighted · Round Robin · Context Relay · Fill First
    - P2C · Random · Least Used · Cost Opt · Reset-Aware RR
    - Reset Window · Strict Random · Auto · LKGP Mode · Context Optimized

- **Form fields** (2-column layout):
  - **Max Retries**: "1"
  - **Retry Delay (ms)**: "2000"
  - **Max Nesting Depth**: "5"
  - **Target timeout (seconds)**: "Inherit request timeout" (placeholder/gray)
  - Helper text: "Combo targets inherit the current request timeout by default. Set a lower value here only when you want faster fallback."

- **Codex session affinity** section:
  - Description: "Keeps one Codex conversation on the same account for this many seconds. 0 disables it."
  - **Affinity TTL (seconds)**: "0"

- **Reset-aware quota cache** section:
  - Description: "Controls the reset-aware quota ordering only. Quota profit still protects requests. 0ff keeps live fetching."
  - **Fresh TTL (second window)**: "0"
  - **Max stale (seconds)**: "0"

- **Toggle rows**:
  - **Track Metrics** (ON — green toggle): "Record per-combo request metrics"
  - **Reasoning tokens buffer** (ON — green toggle): "When enabled, add a buffer to max_tokens header only for known reasoning models when the full buffer fits inside a known output cap."
  - **Zero-latency optimizations** (OFF — gray toggle): "Opt in to halting, preflight TTT stops, and preflight fallback compression. Leave off to prevent these latency features from racing targets or compressing fallback requests."

- **Provider Overrides** section:
  - Description: "Override timeout and retries per provider. Provider settings override global defaults."
  - Input: placeholder "e.g. google, openai..."
  - "Add" button (right-aligned)

- **Save button**: Red "Save Combo Defaults" button

### 2. Model Aliases
- **Icon**: Purple swap/alias icon
- **Title**: "Model Aliases"
- **Description**: "Remap model names using exact matches or wildcard patterns."
- **Two tab buttons**: "Exact Match" (selected) · "Wildcard Pattern"
- **Tab description**: "Use exact aliases for deprecated or renamed model IDs."
- **Form row**: "Deprecated model ID" input → arrow icon → "New model ID" input → red "Add" button
- **CUSTOM ALIASES** section:
  - "No exact-match aliases configured."
- **WILDCARD RULES** section:
  - "No wildcard aliases configured."
- **Collapsible section**: "BUILT-IN ALIASES (29)" with expand arrow

### 3. Fallback Chains
- **Icon**: Purple link/chain icon
- **Title**: "Fallback Chains"
- **Description**: "Define provider fallback order per model"
- **Add button**: Red "+ Add Chain" button (top-right)
- **Empty state**:
  - Large gray illustration (timeline diagram)
  - "No Fallback Chains"
  - "Create a chain to define provider fallback order for a model"

### 4. Model Routing Rules
- **Icon**: Purple route/rules icon
- **Title**: "Model Routing Rules"
- **Description**: "Automatically route models to specific combos using glob patterns"
- **Add button**: Red "+ Add Rule" button (top-right)
- **Empty state text**: "No routing rules configured. Requests use the global combo by default. Add a rule like claude-sonnet* → frontend-combos to automatically route requests."

### 5. Zero-Config Auto-Routing
- **Icon**: Purple auto/zap icon
- **Title**: "Zero-Config Auto-Routing"
- **Description**: "Enable automatic provider selection using the auto/ prefix. When enabled, requests to auto, autocompletions, autofast, etc, will dynamically route across all connected providers."
- **Toggle**: ON (green)
- **Default Auto Variant** section:
  - 6 radio button options in 2 columns:
    - Last Known Good Provider
    - Quality-first for code
    - Low-latency routing
    - Cost-optimized
    - High availability
    - Best discovery (10% explore)

### 6. System-block Transform Pipeline
- **Icon**: Purple transform/pipeline icon
- **Title**: "System-block Transform Pipeline"
- **Description**: "Per-provider ordered pipeline of transforms applied to the request body before forwarding. Supports any provider ID."
- **Add provider** dropdown: "Select a provider..." with "+ Add provider" button
- **Two configured providers** (expandable rows with chevrons):
  - **c:llama** — "Claude (OAUTH)" — "5 ops · enabled" — Toggle ON (green)
  - **anthropic-compat/ble...cc** — "Claude-Code Bridge" — "0 ops · enabled" — Toggle ON (green)
- Helper text: "All transform ops are idempotent re-runs. Changes take effect immediately on the next request."

### 7. CLI Fingerprint Matching
- **Icon**: Purple fingerprint icon
- **Title**: "CLI Fingerprint Matching"
- **Description**: "Normalize request headers and body fields to match the official CLI tool signatures. Enable per provider."
- **Header fingerprint (per provider)** section:
  - "6 providers with CLI fingerprint active."
  - **6 provider cards** (3 columns × 2 rows), each with a green checkmark icon:
    - **Claude Code** — "Anthropic Claude Code CLI"
    - **OpenAI Codex CLI** — "OpenAI Codex CLI"
    - **GitHub Copilot** — "GitHub Copilot CLI compatibility"
    - **Antigravity** — "Google Antigravity IDE compatibility"
    - **Gemini CLI** — "Google Gemini CLI compatibility"
    - **Qwen Code / Qoder** — "Qwen Code and Qoder CLI compatibility"

### 8. Client Cache Control
- **Icon**: Purple cache icon
- **Title**: "Client Cache Control"
- **Description**: "Configure whether OmniRoute preserves client-provided cache_control markers"
- (Section cut off at bottom of screenshot)

## Color Palette

- Background: White
- Sidebar: Dark navy/charcoal
- Primary accent: Red/coral for save buttons, add buttons, active sidebar
- Info boxes: Blue (guidance), Orange (warning/tuning)
- Toggle ON: Green
- Toggle OFF: Gray
- Strategy options: Gray circular radio buttons, selected may show border
- Provider fingerprint cards: Light background with green checkmark
- Empty state illustration: Gray timeline diagram
- Text primary: Dark/black
- Text secondary: Medium gray
