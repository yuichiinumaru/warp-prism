# Screenshot Report: Dashboard — Runtime Page

**File**: `35_dashboard_runtime.png`
**Page Title**: Runtime
**Subtitle**: "Realtime observability — circuit breakers, cooldowns, model lockouts, sessions and quota alerts"
**Breadcrumb**: Dashboard > Runtime
**Timestamp**: 5:19:10:30 (top-right of content area)
**Action Buttons**: Pause (pause icon) and Refresh (circular arrow icon) — top-right.

---

## Summary Cards Row

Four horizontal metric cards with colored icons:

| Card | Icon | Label | Value | Subtitle | Color |
|------|------|-------|-------|----------|-------|
| 1 | Blue person icon | SESSIONS | **1** | 1 lately bound | Blue |
| 2 | Red lightning icon | CIRCUITS | **0 / 30** | 2 recovering | Red |
| 3 | Orange snowflake icon | COOLDOWNS | **0** | 0 connections cooling | Orange |
| 4 | Green lock icon | LOCKOUTS | **0** | 0 models blocked | Green |

---

## Models in Cooldown Section

**Section Header**: "Models in cooldown" with red dot icon.
**Description**: "Models temporarily isolated after a failure. When the cooldown expires they come back automatically."
**Status**: "No models in cooldown right now." (gray text).
**Buttons**: "Refresh" (outlined) and "Reactivate all" (red/coral filled).

---

## 3-Layer Resilience Section

**Section Header**: "3-Layer Resilience" with red shield icon.
**Subtitle**: "All layers protecting every model".
**Health bar**: "99% providers healthy" — full-width green progress bar (nearly 100%).
**Legend**: Green check 29, Yellow warning 1, Red X 0.

### LAYER 1: Provider Circuit Breakers

**Description**: "Stop traffic to providers failing at the upstream level."
**Status badge**: "1 of 39 affected" (yellow/orange badge, right-aligned).

A grid of provider circuit breaker status cards (5 columns), each showing:
- Provider icon + name.
- Status badge: **OK** (green) or **RECO** (yellow/orange, recovering).

#### Provider Grid:

| Provider | Status | Provider | Status | Provider | Status |
|----------|--------|----------|--------|----------|--------|
| agt | OK | siliconflow | OK | codex | OK |
| kiro | OK | freellamaplay | OK | antigravity | OK |
| openai | OK | openrouter | OK | fireworks | OK |
| nvidia | OK | ollama-cloud | OK | cloudflare-ai | OK |
| openai-compatible-ch... | OK | kimi | OK | anthropic-compatible... | OK |
| gemini-cli | OK | opencode-zen | OK | killecode | OK |
| openai-compatible-res... | OK | cerebras | OK | alabcloud | OK |
| trae | OK | together | OK | api-airforce | OK |
| ambite | 1 failure | anthropic-compatible... | OK | anthropic-compatible... | OK |
| gemini | OK | deepseek-web | OK | qwen-web | OK |

### LAYER 2: Connection Cooldowns

**Description**: "Skip one bad account/keyy; other connections keep serving."
**Status badge**: "0 cooling" (green badge).
**Status**: "No connection cooldowns active" (gray text).

### LAYER 3: Model Lockouts

**Description**: "Per model rate and lock; same connection still serves other models."
**Status badge**: "0 locked" (green badge).
**Status**: "No model lockouts" (gray text).

---

## Live Feed Panel (Right Side)

**Section Header**: "Live Feed" with red dot icon.
**Subtitle**: "Last 0 events".
**Filter**: Dropdown showing "All" + "Clear" link.
**Status**: Hourglass icon with text "Waiting for events... (polled every 5s)" (gray text).

---

## Active Sessions Panel

**Section Header**: "Active Sessions" with blue dot icon.
**Subtitle**: "Sticky bound request fingerprints (live)".
**Count badge**: "1 active" (gray badge, right-aligned).

### Table
| Column | Value |
|--------|-------|
| SESSION | c17f9debacc1c... (truncated ID) |
| AGE | 2m 20s |
| IDLE | 1m 24s |
| REQS | 6 |
| BOUND TO | api.airforce-dev (red/coral text) |

---

## Quota Monitors Panel

**Section Header**: "Quota Monitors" with green dot icon.
**Link**: "Open Quota →" (red/coral text, right-aligned).
**Status**: Checkmark icon with text "All quotas healthy" (gray text).

---

## Sidebar

Identical persistent left sidebar. **Runtime** under the MONITORING section is highlighted/active with a red/pink background indicator.
