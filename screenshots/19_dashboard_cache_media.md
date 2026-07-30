# Dashboard Screenshot: Media (Cache + Media Generation)

**File**: `19_dashboard_cache_media.png`
**Page Title**: Media — Generate images, videos, and music

---

## Overall Layout

Standard OmniRoute dashboard layout with a left sidebar navigation and main content area. The background is white/light gray.

---

## Left Sidebar

**Brand**: Red hexagon icon + "Cybernetics-Core" with "v3.8.29" version below.

### Sidebar Sections (top to bottom):

**Top Section**:
- Home (Dashboard overview)

**OMNIPROXY** (collapsible section, red dot indicator):
- Endpoints — Your AI connection URLs
- API Keys — Manage authentication keys and scopes
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
- **Media** — **Currently selected (highlighted with pink/red background)**
- Batch Jobs — Process multiple requests
- Files — Batch input/output files

**CONFIGURATION** (collapsible)
**HELP** (collapsible)

### Bottom of sidebar:
- Green "Restart" button (circular arrow icon)
- Orange "Shut..." button (power icon)

---

## Top Bar

- Breadcrumb: Dashboard / Cache / **Media**
- Right side: Search icon, "Quick nav" label with keyboard shortcut `⌘K`, language selector showing "EN" with a flag icon, user avatar, notification bell (yellow/orange badge), settings gear icon

---

## Main Content Area

### Page Header
- **Title**: "Media" (large, bold)
- **Subtitle**: "Generate images, videos, and music" (gray text)
- **Page icon**: Red/pink image icon to the left of the title

### Tab Navigation
Five horizontal tabs at the top of the content area:
1. **Image Generation** — Selected (active, with red/pink image icon)
2. **Video Generation** — Camera icon
3. **Music Generation** — Musical note icon
4. **Text to Speech** — Speaker/audio icon
5. **Transcription** — Microphone icon

### Form (Image Generation Tab Active)

**Row 1 — Provider and Model**:
- **Provider** dropdown: "OpenAI" selected (left side)
- **Model** dropdown: "GPT Image 2" selected (right side)

**Info Banner**: Yellow warning icon with text: "Requires OpenAI API key in Providers" (where "Providers" appears as a clickable red/pink link)

**Row 2 — Source Image and Mask Image**:
- **Source Image** file picker: "Choose File" button + "No file chosen" text
  - Helper text below: "Optional: for image-to-image, editing, and upscale workflows."
- **Mask Image** file picker: "Choose File" button + "No file chosen" text
  - Helper text below: "Optional. Used by inpaint-style models that support masks."

**Row 3 — Prompt**:
- Text input field with placeholder text: "A serene landscape with mountains at sunset..."
- Large multi-line text area spanning full width

**Generate Button**: Full-width gradient button (pink/red to orange/peach gradient) with sparkle icon + text "Generate Image Generation"

### Summary Cards Row (5 cards, horizontal layout)

Each card has a colored icon, title, provider count, method badge, and endpoint path:

| Card | Icon | Title | Count | Method | Endpoint |
|------|------|-------|-------|--------|----------|
| 1 | Pink image icon | Image Generation | 24 providers | POST (pink badge) | `/v1/images/generations` |
| 2 | Green video icon | Video Generation | 12 providers | POST (pink badge) | `/v1/videos/generations` |
| 3 | Purple music icon | Music Generation | 9 providers | POST (pink badge) | `/v1/music/generations` |
| 4 | Purple speaker icon | Text to Speech | 19 providers | POST (pink badge) | `/v1/audio/speech` |
| 5 | Blue microphone icon | Transcription | 17 providers | POST (pink badge) | `/v1/audio/transcriptions` |

### Below the Cards

The remainder of the page below the summary cards is empty white space — no additional content is visible in the screenshot.

---

## Color Scheme

- **Primary accent**: Pink/Red (#e74c3c range)
- **Gradient button**: Pink-to-peach/orange horizontal gradient
- **Selected sidebar item**: Pink/light red background highlight
- **Warning banner**: Yellow icon on light background
- **Method badges**: Pink background with white text ("POST")
- **Background**: White (#ffffff) main content area, light gray sidebar
