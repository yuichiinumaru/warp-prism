# Dashboard Screenshot: Combos

**File**: `21_dashboard_combos.png`
**Page Title**: Combos — Model combos with weighted routing and fallback support

---

## Overall Layout

Standard OmniRoute dashboard layout with a left sidebar navigation and main content area. This is a long, scrollable page containing a large number of combo entries.

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
- **Combos** — **Currently selected (highlighted with pink/red background)**
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

- Breadcrumb: Dashboard / Combos
- Right side: Search icon, "Quick nav" with `⌘K`, "EN" language selector, user avatar, notification bell (yellow/orange badge), settings gear icon

---

## Main Content Area

### Page Header
- **Title**: "Combos" (large, bold)
- **Subtitle**: "Create model combos with weighted routing and fallback support" (gray text)
- **Page icon**: Red/pink interlocking circles/arrows icon to the left of the title
- **Action button**: Green "+ Create Combo" button (top right corner)

### Auto-Routing Catalog Banner
- Yellow/amber banner with sparkle icon
- Text: "**Auto-routing catalog** 144 combos" (where "144 combos" appears as a green badge)
- Subtitle: "Built-in auto-generated combos dynamically from connected providers. Use any of these IDs as the model field — no setup needed."
- Expandable (chevron/arrow on the right)

### Getting Started with Combos (Onboarding Panel)
- Red/pink circle icon with combo symbol
- Title: "Getting Started with Combos"
- Subtitle: "Create model combos to route AI traffic intelligently"
- Right side: "Hide" and "Don't show again" text links
- **4-step visual flow** with numbered steps and arrows between them:
  1. **Name Your Combo** (red icon with text cursor) — "Give your combo a proper name to identify it in routing configs."
  2. **Add Models** (red icon with plus) — "Select 1-6 models and arrange their fallback priority order."
  3. **Choose Strategy** (red icon with strategy/routing symbol) — "Pick how requests are distributed across your models. 14 strategies available."
  4. **Review & Save** (red icon with checkmark) — "Review your configuration and activate the combo routing."
- **CTA button**: Pink/red button with "+" icon: "Create Your First Combo" — "or click '+ Create Combo' above"

### Filter Tabs
Three filter tabs below the onboarding panel:
1. **All** — Selected (red/pink background), with count "33"
2. **Intelligent** — With sparkle icon, count "26"
3. **Deterministic** — With checkmark icon, count "7"

### Combo List (scrollable, extensive)

Each combo row contains:
- **Drag handle** (6-dot grid icon, left side)
- **Combo name** (bold text, some with colored badge like "LEAD MODE")
- **Type badge**: Green "LEAD MODE" badge or orange/yellow "PRIORITY" badge
- **Description/details**: Gray text showing the combo composition (e.g., "Combo: gpt-5.5-high · gpt-5.5-high · Custom · Custom · dynamic account")
- **Metrics** (for some): Red/green text showing stats like "1124 rep · 63% success · <1300ms · 1534 failures"
- **Action icons** (right side, row of small icons): Toggle switch (on/off), play button, bar chart, pencil/edit, copy, trash/delete, and other action icons

### Visible Combos (in order from top to bottom):

1. **reviewer** — LEAD MODE badge (green). Combo with gpt-5.5-high variants. Shows metrics: "1124 rep · 63% success · <1300ms · 1534 failures". Toggle ON (green).

2. **architect** — PRIORITY badge (orange). Combo: Claude, gpt-5.5, claude-3. Toggle ON.

3. **builder** — Green combo icon. Various model entries listed. Toggle ON.

4. **researcher** — Combo with "gpt-5-plus" and other models. Toggle ON.

5. **mini** — LEAD MODE badge (green). Combo: gpt-5-0-flash, deepseek-v3 variants, mini-v2.5. Toggle ON.

6. **gpt-5.5-high** — LEAD MODE badge (green). Multiple gpt-5.5-high provider entries with masked API keys (dots). Toggle ON.

7. **claudeoe** — PRIORITY badge (orange). Claude claude-3.5-haiku-20241022, dynamic account, free tier/plan entry, claude-opus-4-0. Toggle ON.

8. **gpt-5.5** — LEAD MODE badge (green). Multiple openai/gpt-5.5-medium entries with masked keys. "+2 more" indicator. Toggle ON.

9. **gpt-5.4-ttae** — LEAD MODE badge (green). Various provider entries. Toggle ON.

10. **mimo-v2.5-pro** — LEAD MODE badge (green). Multiple provider entries. Toggle ON.

11. **deepseek-v4-pro** — LEAD MODE badge (green). siliconflow/deepseek-ai, fireworks/deepseek-v4-pro. Toggle ON.

12. **gemini-3.1-pro** — PRIORITY badge (orange). google/gemini-3.1-pro-high, gemini-3.1-pro-preview. Toggle ON.

13. **kimi-k2.6** — LEAD MODE badge (green). Together, novita, and other providers. Toggle ON.

14. **nex-n2-pro** — LEAD MODE badge (green). siliconflow, cerebras, and other providers. Toggle ON.

15. **qwen3.7-plus** — LEAD MODE badge (green). alibaba entries. Toggle ON.

16. **nemotron-3-ultra** — ROUND ROBIN badge (yellow/orange). openrouter/nvidia entries. Toggle ON.

17. **qwen3.6-plus** — ROUND ROBIN badge (yellow/orange). fireworks entries. Toggle ON.

18. **mimo-v2.5** — LEAD MODE badge (green). opencode-xyz entry. Toggle ON.

19. **deepseek-v4-flash** — LEAD MODE badge (green). nvidia/deepseek-ai entries. Toggle ON.

20. **stepfun-3.7-flash** — LEAD MODE badge (green). stepfun, nvidia entries. Toggle ON.

21. **glm-5** — LEAD MODE badge (green). Multiple kimi/glm-5 entries. Toggle ON.

22. **glm-4.7** — LEAD MODE badge (green). Multiple provider entries. Toggle ON.

23. **gemma4-31b** — MIX badge (yellow). cloudflare, nvidia entries. Toggle ON.

24. **claude-4.5-sonnet** — LEAD MODE badge (green). Multiple kiro, kimi entries. Toggle ON.

25. **deepseek-v4-pro-web** — LEAD MODE badge (green). deepseek-web entries. Toggle ON.

26. **qwen3.7-plus-web** — LEAD MODE badge (green). qwen-web entry. Toggle ON.

27. **gemini-embedding-2** — LEAD MODE badge (green). gemini entries at bottom. Toggle ON.

---

## Color Scheme

- **Primary accent**: Pink/Red (#e74c3c range)
- **Create button**: Green (#2ecc71 range)
- **LEAD MODE badge**: Green background with white text
- **PRIORITY badge**: Orange/yellow background with white text
- **ROUND ROBIN badge**: Yellow/orange background
- **MIX badge**: Yellow background
- **Toggle ON**: Green
- **Metrics failure text**: Red
- **Metrics success text**: Green
- **Auto-routing catalog badge**: Green
- **Onboarding steps**: Red/pink numbered circles
- **Background**: White (#ffffff) main content area, light gray sidebar
