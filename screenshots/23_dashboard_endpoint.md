# Dashboard Screenshot: Endpoints

**File**: `23_dashboard_endpoint.png`
**Page Title**: Endpoints — Manage your endpoints, MCP, A2A, and API endpoints

---

## Overall Layout

Standard OmniRoute dashboard layout with a left sidebar navigation and main content area. The page is densely packed with endpoint information organized into clear sections.

---

## Left Sidebar

**Brand**: Red hexagon icon + "Cybernetics-Core" with "v3.8.29" version below.

### Sidebar Sections (top to bottom):

**Top Section**:
- Home (Dashboard overview)

**OMNIPROXY** (collapsible section, red dot indicator):
- **Endpoints** — **Currently selected (highlighted with pink/red background)** — Your AI connection URLs
- API Keys — Manage authentication keys and access
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

- Breadcrumb: Dashboard / Endpoints
- Right side: Search icon, "Quick nav" with `⌘K`, "EN" language selector, user avatar, notification bell (yellow/orange badge), settings gear icon

---

## Main Content Area

### Page Header
- **Title**: "Endpoints" (large, bold)
- **Subtitle**: "Manage your endpoints, MCP, A2A, and API endpoints" (gray text)
- **Page icon**: Red/pink plug/connection icon to the left of the title

### Tab Navigation
Four horizontal tabs:
1. **APIs** — Selected (active, with red/pink icon and underline)
2. **MCP** — With icon
3. **A2A** — With icon
4. **Content Sources** — With icon

---

### Section 1: API Endpoint (White Card)

**Card Title**: "API Endpoint" (bold)

**ACTIVE ENDPOINTS** sub-section:
- **Green dot** indicator + "ACTIVE ENDPOINTS" label (green text)
- Row: Green dot + "Local" — URL: `http://localhost:22069/v1` — with a copy/clipboard icon on the right

**Local Server** row:
- Server/rack icon + "Local Server" — IP address shown: `127.0.0.1:22069 (12.11.0.0:2102845)` (partially visible)
- **Green dot** + "Running" status badge
- Copy icon on the right

**TUNNELS** sub-section:
- Tunnel icon + "TUNNELS" label — "0/0 active" (gray text)

**Cloud OmniRoute** row:
- Cloud icon + "Cloud OmniRoute"
- Gray dot + "Disabled" status
- "Not configured" text

---

### Section 2: Available Endpoints (White Card)

**Card Title**: "Available Endpoints" (bold)
**Subtitle**: "2654 models across 15 endpoints"

#### CORE APIS (red/pink star icon, section header)

Four endpoint cards in a row:

| Card | Icon | Endpoint Name | Model Count | Method Badge | Path | Copy Icon |
|------|------|---------------|-------------|--------------|------|-----------|
| 1 | Green chat bubble | Chat Completions | 1,953 models | POST | `/v1/chat/completions` | Yes |
| 2 | Blue/purple arrow | Responses | 1,953 models | POST | `/v1/responses` | Yes |
| 3 | Red/pink "Tr" | Completions (Legacy) | 1,953 models | POST | `/v1/completions` | Yes |
| 4 | Purple/gray dash | Messages | — | POST | `/v1/messages` | Yes |

#### MEDIA & MULTI-MODAL (red/pink star icon, section header)

Seven endpoint cards in two rows:

**Row 1**:
| Card | Icon | Endpoint Name | Model Count | Path | Copy Icon |
|------|------|---------------|-------------|------|-----------|
| 1 | Blue/purple grid | Embeddings | 34 models | `/v1/embeddings` | Yes |
| 2 | Green image | Image Generation | 20 models | `/v1/images/generations` | Yes |
| 3 | Blue image | Image Edits | 20 models | `/v1/images/edits` | Yes |
| 4 | Red/pink microphone | Audio Transcription | 19 models | `/v1/audio/transcriptions` | Yes |

**Row 2**:
| Card | Icon | Endpoint Name | Model Count | Path | Copy Icon |
|------|------|---------------|-------------|------|-----------|
| 5 | Blue/purple speaker | Text to Speech | 11 models | `/v1/audio/speech` | Yes |
| 6 | Purple music note | Music Generation | 0 models | `/v1/music/generations` | Yes |
| 7 | Green video camera | Video Generation | 6 models | `/v1/videos/generations` | Yes |

#### SEARCH & DISCOVERY (red/pink star icon, section header)

One endpoint card:
| Card | Icon | Endpoint Name | Model Count | Path | Copy Icon |
|------|------|---------------|-------------|------|-----------|
| 1 | Purple magnifier | Web Search | 12 models | `/v1/search` | Yes |

#### UTILITY & MANAGEMENT (red/pink star icon, section header)

Five endpoint cards in two rows:

**Row 1**:
| Card | Icon | Endpoint Name | Model Count | Path | Copy Icon |
|------|------|---------------|-------------|------|-----------|
| 1 | Orange bar chart | Rerank | 11 models | `/v1/rerank` | Yes |
| 2 | Yellow shield | Moderations | 1 model | `/v1/moderations` | Yes |
| 3 | Red/pink layers | Batch API | OPENAI badge | `/v1/batches` | Yes |
| 4 | Orange file | Files API | — | `/v1/files` | Yes |

**Row 2**:
| Card | Icon | Endpoint Name | Path | Copy Icon |
|------|------|---------------|------|-----------|
| 1 | Purple list | List Models | `/v1/models` | Yes |

---

### Section 3: VS CODE TOKEN ALIAS (White Card)

**Card Header**: "VS CODE TOKEN ALIAS" (green/teal text)
**Right side**: "CLI Tools" link (pink/red text)
**Description**: "Ready-to-paste compatibility URLs using the /api/v1/vscode/TOKEN/... endpoint."

Three URL rows, each with a copy icon:

1. **VS Code base**: `http://localhost:22069/api/v1/vscode/sk-c2c313e476268a6a02d9f-294df219b/`
2. **VS Code models**: `http://localhost:22069/api/v1/vscode/sk-c2c313e476268a6a02d9f-294df219b/models`
3. **VS Code chat**: `http://localhost:22069/api/v1/vscode/sk-c2c313e476268a6a02d9f-294df219b/chat/completions`

---

## Color Scheme

- **Primary accent**: Pink/Red (#e74c3c range)
- **Selected sidebar item**: Pink/light red background highlight
- **ACTIVE ENDPOINTS label**: Green text
- **Running status**: Green dot + green text badge
- **Disabled status**: Gray dot + gray text
- **Method badges**: Pink/red background with white text ("POST")
- **Section headers (CORE APIS, etc.)**: Red/pink star icon with gray text
- **Copy icons**: Gray, small clipboard icons
- **VS CODE TOKEN ALIAS header**: Teal/green text
- **CLI Tools link**: Pink/red text
- **Background**: White (#ffffff) main content area, light gray sidebar
- **Card borders**: Light gray/white rounded cards with subtle borders
