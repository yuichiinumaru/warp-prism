# 11 — Dashboard: API Endpoints

**File**: `11_dashboard_api-endpoints.png`
**Page**: Dashboard > API Endpoints
**URL path**: (Dashboard / API Endpoints)

---

## Page Header

- **Icon**: Red/coral circular icon with a white plug or API symbol.
- **Title**: "API Endpoints" (bold, large, black text).
- **Subtitle**: "Manage system API endpoint configurations and routing overrides" (gray, smaller text).

---

## Breadcrumb Navigation

| Segment | State |
|---------|-------|
| Dashboard | Inactive (gray text) |
| API Endpoints | Active (bold, underlined) |

---

## OmniRoute API Info Banner

A full-width card at the top with a white background:

- **Left icon**: Red/coral OmniRoute logo (circle with stylized "O").
- **Title**: "OmniRoute API" (bold, black).
- **Version badge**: `3.8.38` (green pill/badge with white text).
- **Subtitle**: "271 endpoints across 30 categories" (gray text).
- **Right-side buttons**:
  - **YAML** button (with download icon, outlined style)
  - **JSON** button (with download icon, outlined style)

---

## Search and Filter Bar

### Search Input
- Full-width search field with magnifying glass icon and placeholder text "Search endpoints..." (gray text).

### Category Filter Tags (horizontal scrollable row):
| Tag | State |
|-----|-------|
| All | Active (red/coral background, white text) |
| Playground | Inactive (gray outline) |
| Memory | Inactive (gray outline) |
| Chat | Inactive (gray outline) |
| Messages | Inactive (gray outline) |
| Responses | Inactive (gray outline) |
| Embeddings | Inactive (gray outline) |
| Images | Inactive (gray outline) |
| Audio | Inactive (gray outline) |
| +12 more | Inactive (gray text, indicating additional hidden categories) |

### Auth/Visibility Filter Tags (right-aligned):
| Tag | State |
|-----|-------|
| Authenticated | Inactive |
| Localhost | Inactive |
| Always Protected | Inactive |
| Public | Inactive |
| Show Internal | Inactive |

---

## VS Code Token Alias Section

A card with a light background:

- **Header**: "VS CODE TOKEN ALIAS" (uppercase, bold, red/coral text).
- **Description**: "Ready-to-paste compatibility URLs using the /api/v1/vscode/TOKEN-... endpoint." (gray text).
- **Right side**: "CLI Tools" link (red/coral text).

### Three URL rows:

| Label | URL | Copy Icon |
|-------|-----|-----------|
| **VS Code base** | `http://localhost:22000/api/v1/vscode/u-c2c574f02a6eaed-c2d90f-2049f109/` | Clipboard icon |
| **VS Code models** | `http://localhost:22000/api/v1/vscode/u-c2c574f02a6eaed-c2d90f-2049f109/models` | Clipboard icon |
| **VS Code chat** | `http://localhost:22000/api/v1/vscode/u-c2c574f02a6eaed-c2d90f-2049f109/chat/completions` | Clipboard icon |

Each row has a clipboard/copy icon on the far right for easy URL copying.

---

## Endpoint Categories

The main content area lists API endpoint categories, each in its own card/section. Each category has a colored folder icon, category name (uppercase, bold), endpoint count badge, and a list of individual endpoints with HTTP method badges, paths, descriptions, and expand chevrons.

### PLAYGROUND (6 endpoints)

| Method | Path | Description |
|--------|------|-------------|
| POST | `/api/playground/improve-prompt` | Improve prompt via LLM |
| GET | `/api/playground/presets` | List playground presets |
| POST | `/api/playground/presets` | Create playground preset |
| GET | `/api/playground/presets/{id}` | Get playground preset |
| PUT | `/api/playground/presets/{id}` | Update playground preset |
| DELETE | `/api/playground/presets/{id}` | Delete playground preset |

Each endpoint has a lock icon (indicating auth required) and a downward chevron on the far right.

---

### MEMORY (23 endpoints)

| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/memory` | List memory entries |
| POST | `/api/memory` | Create a memory entry |
| GET | `/api/memory/{id}` | Get a single memory entry |
| PUT | `/api/memory/{id}` | Update a memory entry |
| DELETE | `/api/memory/{id}` | Delete a memory entry |
| GET | `/api/memory/health` | Memory store health check |
| POST | `/api/memory/retrieve-preview` | Dry-run memory retrieval (Playground) |
| GET | `/api/memory/embedding-providers` | List embedding providers |
| GET | `/api/memory/engine-status` | Memory engine status |
| GET | `/api/memory/summarize` | Compact old memories |
| POST | `/api/memory/reindex` | Trigger vector reindex |
| GET | `/api/settings/memory` | Get memory settings |
| PUT | `/api/settings/memory` | Update memory settings |
| GET | `/api/settings/qdrant` | Get Qdrant settings |
| PUT | `/api/settings/qdrant` | Update Qdrant settings |
| GET | `/api/settings/qdrant/health` | Qdrant health probe |
| POST | `/api/settings/qdrant/search` | Qdrant semantic search test |
| POST | `/api/settings/qdrant/cleanup` | Clean up expired Qdrant points |
| GET | `/api/settings/qdrant/embedding-models` | List Qdrant embedding models |

Method badges: GET (green), POST (blue), PUT (orange/amber), DELETE (red).

---

### CHAT (3 endpoints)

| Method | Path | Description |
|--------|------|-------------|
| POST | `/api/v1/chat/completions` | Create chat completion |
| POST | `/api/v1/providers/{provider}/chat/completions` | Create chat completion (provider-specific) |
| POST | `/api/v1/api/chat` | Obsolete-compatible chat endpoint |

---

### MESSAGES (2 endpoints)

| Method | Path | Description |
|--------|------|-------------|
| POST | `/api/v1/messages` | Create message (Anthropic-compatible) |
| POST | `/api/v1/messages/count_tokens` | Count tokens for a message |

---

### RESPONSES (1 endpoint)

| Method | Path | Description |
|--------|------|-------------|
| POST | `/api/v1/responses` | Create response (OpenAI Responses...) |

---

### EMBEDDINGS (2 endpoints)

| Method | Path | Description |
|--------|------|-------------|
| POST | `/api/v1/embeddings` | Create embeddings |
| POST | `/api/v1/providers/{provider}/embeddings` | Create embeddings (provider-specific) |

---

### IMAGES (2 endpoints)

| Method | Path | Description |
|--------|------|-------------|
| POST | `/api/v1/images/generations` | Generate images |
| POST | `/api/v1/providers/{provider}/images/generations` | Generate images (provider-specific) |

---

### AUDIO (2 endpoints)

| Method | Path | Description |
|--------|------|-------------|
| POST | `/api/v1/audio/speech` | Generate speech audio |
| POST | `/api/v1/audio/transcriptions` | Transcribe audio |

---

### MODERATIONS (1 endpoint)

| Method | Path | Description |
|--------|------|-------------|
| POST | `/api/v1/moderations` | Create moderation |

---

### RERANK (1 endpoint)

| Method | Path | Description |
|--------|------|-------------|
| POST | `/api/v1/rerank` | Rerank documents |

---

### SYSTEM (25+ endpoints, partially visible)

| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/v1` | API v1 root endpoint |
| GET | `/api/tags` | List available/compliant model tags |
| POST | `/api/auth/login` | Authenticate user |

Additional system endpoints are truncated below the visible viewport.

---

## Endpoint Row Styling

- **HTTP method badges**: Color-coded rounded rectangles:
  - `GET` = green background, white text
  - `POST` = blue background, white text
  - `PUT` = orange/amber background, white text
  - `DELETE` = red background, white text
- **Path**: Monospace font, dark text.
- **Description**: Gray text, right-aligned.
- **Lock icon**: Small lock icon on the right indicating authentication required.
- **Chevron**: Downward-pointing chevron on the far right for expanding endpoint details.

---

## Left Sidebar

The sidebar is the standard Cybernetics-Core navigation panel. The **API Endpoints** item is highlighted with a red/coral background and white text, indicating the current active page.

### Sidebar Sections Visible:

**OMNIPROXY section:**
- Endpoints, API Keys, Providers, Combos, Combo Studio, Provider Quota, **API Endpoints** (ACTIVE — red/coral background, white text), Webhooks, Proxy

**ANALYTICS section:**
- Usage, Combo Health, Utilization, Cache, Compression, Search, Evals, Provider Stats

**MONITORING section:**
- Activity, Logs, Proxy Logs, Console Logs, Audit Log, MCP Audit, A2A Audit, Health, Runtime

**AGENTIC FEATURES section:**
- Memory, AgentSkills, OmniSkills, MCP Server, A2A Server, Plugins

**Collapsed sections:**
- OTHER FEATURES, CONFIGURATION, HELP

---

## Top-Right Header Bar

- **Quick nav** button with magnifying glass icon
- **"SHORTCUT"** badge (dark background, white text)
- **EN** language selector dropdown
- **User avatar** (green/teal circle with letter)
- **Warning/notification triangle** icon (yellow/amber)
- **Grid/apps** icon

---

## Footer

Two small links at the very bottom-left of the viewport:
- **"Recent"** (green dot + text)
- **"Share..."** (red circle/brand icon + text)

---

## Summary

This is the **API Endpoints** management page of the OmniRoute dashboard. It provides a comprehensive catalog of **271 API endpoints across 30 categories**. The page serves as a reference and management interface for all available REST API routes.

Key features include:
- A **VS Code Token Alias** section with ready-to-paste compatibility URLs for VS Code integration.
- A **search bar** and **category filter tags** for quickly finding specific endpoints.
- **Auth/visibility filters** (Authenticated, Localhost, Always Protected, Public, Show Internal).
- **Export options** to download the endpoint catalog in YAML or JSON format.
- Each endpoint is displayed with its **HTTP method** (color-coded), **path**, **description**, and **authentication status** (lock icon). Endpoints can be expanded via chevrons for additional details.

The visible categories include Playground (6), Memory (23), Chat (3), Messages (2), Responses (1), Embeddings (2), Images (2), Audio (2), Moderations (1), Rerank (1), and System (25+), with 12 additional categories hidden behind the "+12 more" filter tag.
