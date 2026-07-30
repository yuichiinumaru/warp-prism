# Screenshot 37 — Dashboard: AI Settings

## Page Title & Breadcrumb

- **Header icon**: Purple brain/AI icon
- **Page title**: "AI Settings" (bold, large)
- **Subtitle**: "AI behavior: thinking budgets, vision, and memory settings"
- **Breadcrumb**: Dashboard > Settings > AI Settings

## Global Layout

- **Left sidebar**: Dark charcoal/navy vertical navigation bar (~180px wide) with white text. Grouped into sections: OMNIPROXY, ANALYTICS, MONITORING, AGENTIC FEATURES, OTHER FEATURES, CONFIGURATION, HELP.
- **Top bar**: White. Left side: "Cybernetics-Core v2.5.29" branding in red. Right side: search icon, "Quick nav" button (Cmd+K), EN language selector with US flag, user avatar, bell notification icon (red dot), settings gear.
- **Bottom left footer**: Red "Restart" button and "Shut down" button with power icon.
- **Main content**: White background, scrollable, ~800px content width, centered. Settings are arranged in card-like sections separated by light gray horizontal lines.

## Sections (Top to Bottom)

### 1. Thinking Budget
- **Icon**: Purple brain icon
- **Description**: "Control AI reasoning token usage across all requests"
- **Layout**: 2×2 grid of selectable cards
  - **Top-left card** (selected, highlighted with pink/red border): Icon (purple arrow right), "PassThrough", "No changes — client controls thinking budget"
  - **Top-right card**: Icon (purple wand), "Auto Combo", "Self-healing smart routing pool (Performance optimized)"
  - **Bottom-left card**: Icon (sliders), "Custom", "Set a fixed token budget for all requests"
  - **Bottom-right card**: Icon (purple lightning), "Adaptive", "Scale token based on request complexity"

### 2. Vision Bridge
- **Icon**: Purple eye icon
- **Description**: "Run an automatic vision-to-text fallback before routing image requests to text-only models."
- **Components**:
  - **Enabled** toggle (currently OFF — gray)
  - **Description text**: "Toggle the pre-call bridge that replaces image parts with extracted text."
  - **Bridge Model** dropdown: shows "gemini/gemini-2.5-flash-lite"
  - Helper text: "Any OmniRoute model ID that supports vision can be used here."
  - **Bridge Prompt** textarea: "Describe this image concisely in 2-3 sentences. Focus on the most relevant data / visual details."
  - Helper text: "Sent to the vision model before the extracted description is injected back into the original request."
  - **Timeout (ms)** input: "30000"
  - **Max Images Per Request** input: "10"

### 3. Global System Prompt
- **Icon**: Purple chat/prompt icon
- **Title**: "Global System Prompt"
- **Toggle**: OFF (gray) — collapsed section

### 4. Responses State
- **Icon**: Purple arrows/exchange icon
- **Title**: "Responses State"
- **Description**: "Control how OmniRoute forwards previous_response_id."
- **Dropdown**: "previous_response_id handling" set to "Auto"
- Helper text: "Auto strips previous_response_id unless a connection explicitly enables OpenAI Responses storage. Strip is safest for stateless clients such as VS Code Copilot Extension; context then depends on the client sending full history."

### 5. Usage Token Buffer
- **Icon**: Purple database/token icon
- **Title**: "Usage Token Buffer"
- **Description**: "Extra tokens added to reported usage to account for system prompt overhead."
- **Input field**: "2000" with a red "Save" button to the right
- Helper text: "Set to 0 to report raw provider token counts. Default: 2000."

### 6. Codex Fast Tier
- **Icon**: Purple lightning bolt icon
- **Title**: "Codex Fast Tier"
- **Description**: "Globally inject service_tier=priority for OpenAI Codex requests."
- **Toggle**: OFF (gray)
- Explanatory text below about OpenAI Enterprise API key and ChatGPT auth paths.

### 7. Claude Fast Mode
- **Icon**: Purple bolt icon
- **Title**: "Claude Fast Mode"
- **Description**: "Opt selected Claude requests into Anthropic Fast Mode (speed: fast)."
- **Toggle**: OFF (gray)
- Explanatory text about Anthropic's official Fast Mode support.

### 8. Memory
- **Icon**: Purple brain/memory icon
- **Title**: "Memory"
- **Description**: "Persistent cross-session conversational memory"
- **Enable Memory** toggle (OFF, gray)
- Helper text: "When enabled, OmniRoute will inject relevant past context."

### 9. Qdrant (Vector Memory)
- **Icon**: Purple database icon
- **Title**: "Qdrant (Vector memory)"
- **Description**: "Optional. Indexes semantic memories in an external vector database for faster retrieval."
- **Status badge**: Top-right, "Disabled" in gray text
- **Enable Qdrant** toggle (OFF, gray)
- **Test connection** toggle (OFF, gray)
- **Host** input: "http://127.0.0.1"
- **Port** input: "6333" (helper: "Without port. Example: 127.0.0.1 or http://qdrant", "Qdrant default: 6333")
- **Collection** input: "omniroute_memory" (helper: "Where memory points will be stored.")
- **Embedding model** dropdown: "Quick select from discovered models..." with "openai/text-embedding-3-small" shown. Helper: "Format: provider/model. The provider credential must be configured."
- **API Key (Optional)** input: placeholder "(leave empty if not used)". Helper text about host/port/collection/model. Red "Save" button.
- **Search test** section with input placeholder "Example: user preferences, history, etc" and "Search" button on the right.
- **Retention and cleanup** section: "Removes expired and old points based on Retention (60 Days)." with "Clean now" button on the right.

### 10. Skills
- **Icon**: Purple puzzle piece icon
- **Title**: "Skills"
- **Description**: "Tools for models"
- **Enable Skills** toggle (OFF, gray)
- Helper text: "Allows agents to trigger functions."

### 11. SkillsMP Marketplace
- **Icon**: Purple marketplace/store icon
- **Title**: "SkillsMP Marketplace"
- **Description**: "Connect to SkillsMP to discover and install skills from the marketplace."
- **API Key** input: masked (dots). Red "Save" button on the right.
- Helper text: "Get your API key from skilltmp.com. Rate limit: 500 requests/day."

### 12. Active Skills Provider
- **Icon**: Purple provider icon
- **Title**: "Active Skills Provider"
- **Description**: "Choose which provider the Skills page uses for search and install."
- **Two radio/selection options**:
  - **Left option** (selected, green border): "SkillsMP Marketplace" — "Authenticated marketplace (uses your SkillsMP API key)."
  - **Right option** (green background): "Skills.sh Directory" — "Public directory provider (no API key required)."

## Color Palette

- Background: White (#FFFFFF)
- Sidebar: Dark navy/charcoal (#1E293B approximately)
- Primary accent: Red/coral (#EF4444) for save buttons, active sidebar items
- Toggle OFF: Gray (#D1D5DB)
- Toggle ON: Green (#22C55E)
- Card borders: Light gray (#E5E7EB)
- Selected card border: Pink/red (#F87171)
- Text primary: Dark gray/black (#111827)
- Text secondary: Medium gray (#6B7280)
- Green badges: Emerald (#10B981)
