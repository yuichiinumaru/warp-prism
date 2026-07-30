# Screenshot 43 — Dashboard Settings: Security

**URL Path:** `Dashboard > Settings > Security`
**Application:** Cybernetics Core v1.2.38

---

## Global Layout

The page uses a two-column layout: a **left sidebar** (dark background, ~180px wide) for navigation and a **main content area** (white background) with the Security settings. The top bar contains a "Quick nav" search field (with `Ctrl K` shortcut), a language selector (`EN`), and notification/help icons.

---

## Left Sidebar

The sidebar is branded **"Cybernetics Core"** at the top with a red square icon. Navigation items are organized in collapsible sections with small gray section headers:

- **OMNIPROXY** section: Endpoints, API Keys, Providers, Combos, Combo Studio, Provider Quota, API Endpoints, Webhooks, Proxy
- **ANALYTICS** section: Usage, Combo Health, Utilization, Cache, Compression, Search, Evals, Provider Stats
- **MONITORING** section: Activity, Logs, Proxy Logs, Console Logs, Audit Log, MCP Audit, A2A Audit, Health, Runtime
- **AGENTIC FEATURES** section: Memory, AgentSkills, OmniSkills, MCP Server, A2A Server, Plugins
- **OTHER FEATURES** section: Media, Batch Jobs, Files
- **CONFIGURATION** section: Storage, Appearance, AI Settings, Global Routing, Resilience, Advanced, Security (highlighted in red text, currently active), Feature Flags, Sidebar
- **HELP** section: Docs, Issues, Changelog

At the very bottom left: two small circular status indicators — a green dot labeled "Normal" and a red dot labeled "Shut...".

---

## Breadcrumb

`Dashboard > Settings > Security` — shown in small gray text above the page title.

---

## Page Header

- **Icon:** Red circular target/crosshair icon
- **Title:** "Security" (large, bold)
- **Subtitle:** "Authentication, authorization, and access control settings" (gray text)

---

## Section 1: Security (Password/Login)

- **Header:** Red lock icon + "Security" in bold
- **Require login** toggle (red toggle, currently **ON**)
  - Description: "When ON, dashboard requires password. When OFF, access without login."
- **Current Password*** field (required) — placeholder: "Enter current password"
- **New Password*** field — placeholder: "Enter new password"
- **Confirm New Password*** field — placeholder: "Confirm new password"
- **"Update Password"** button — red background, white text

---

## Section 2: IP Access Control

- **Header:** Red shield icon + "IP Access Control" in bold
- **Subtitle:** "Block or allow specific IP addresses"
- Four mode buttons arranged horizontally:
  - **Disabled** (red border, currently selected/active)
  - **Blacklist** (gray border)
  - **Whitelist** (gray border)
  - **WL Priority** (gray border)

---

## Section 3: API Endpoint Protection

- **Header:** Red gear icon + "API Endpoint Protection" in bold
- **Active authorization model** (description text):
  - "Client API endpoints (/v1/*, /chat/*, /responses/*, /v1/models/*) require a Bearer API key."
  - "Management endpoints (/, /dashboard, /api/*) require a dashboard session or management credential."
  - "Only login, health, and bootstrap routes are public."
- **Login brute-force protection** — toggle (red, **ON**)
  - Description: "Throttle and lock /api/auth/login after repeated failures from the same IP."
- **CORS allowed origins** — text input field
  - Description: "Comma-separated list of browser origins permitted to call this server. Empty list = no browser CORS access (server-to-server still works). Use CORS_ALLOW_ALL=true env var only for development."
  - Placeholder value shown: `https://app.example.com, https://admin.example.com`

---

## Blocked Providers

- **Header:** "Blocked Providers" in bold
- **Description:** "Hide specific providers from the /v1/models response. Blocked providers will not appear in model listings."
- A large grid/badge list of **all available providers** displayed as small pill-shaped badges with colored icons. Each badge shows a provider name with a small colored icon (various colors: blue, green, red, yellow, orange, purple). Providers include:
  - OpenCode Free, GaskAtClaw CLI Chat, The Old LLM (Free), Cryptic Popper AI (Free), Vox AI Free, MiniCode (Free), Qoder AI, Qwen Code
  - Gemini CLI, Antigravity CLI, Kiro Code, Amazon Q, Claude Code, Antigravity, OpenAI Codex, GitHub Copilot, GitLab Duo, Cursor IDE
  - Zed IDE, Taur, Kilo Coding, Kiro, Claude, Windsurf (Devon AI), Devon CLI (Official), AgentRouter, Command Code
  - OpenRouter, OracleRouter, Api-routerx, Baidu/Qianfan, GLM Coding, GLM Coding (China), GLM Thinking, Alibaba Coding Plan, PPIO
  - Kimi Coding (API Key), Minimax Coding, Minimax (China), CodexL, OpenAI, Azure OpenAI, Azure AI Foundry, Amazon Bedrock
  - IBM watsonx.ai Gateway, OCI Generative AI, SAP Generative AI Hub, Modal, Reka, NLP Cloud, Runway, Anthropic
  - Gemini (Google AI Studio), DeepSeek, QwQ, BlackboxAI, BazaarLinc, GMI (Only), Mistral, Perplexity, Together AI, Fireworks AI
  - Cerebras, Cohere, NVIDIA NIM, Nebius AI, SiliconFlow, Hyperbolic, KIE AI, OctoAI Cloud, HuggingFace, SymplAI
  - Kilo Gateway, Vertex AI, Vertex AI Partners, Vertex AI (Beta), Wal AI, OpenCode Zen, OpenCode Go, Alibaba (China), LongCat, Pollinations AI, Puter AI, UncodeAI, HackClub AI, GitHub Models, Haper, Leonardo AI, Ideogram
  - Suno, Miro, Cloudflare Workers AI, Scaleway AI, Deepstika, Vercel AI Gateway, Lambda AI, SambaNova, xScale, OVHCloud AI
  - Baseten, PublicAI, Meta Llama API, v0 (Vercel), Morph, Featherless AI, LLM.io, xinference, FriendliAI
  - LlamaGate, Galadriel, Weights & Biases Inference, Volcengine, Venice.ai, Upstage, Maritalk, Xiaomi MiMo, Nvidia NIM OpenGateway (NIM Cloud)
  - GigaChat (Sber), Inference.net, NanoGPT, Predibase, Bytez, Heroku AI, Databricks, Snowflake Cortex, CrofAI, AgentRouter
  - Poe, DuckDuckGo Chat, Claude Web, ChatGPT Web (Subscription), Grok Web (Subscription), Gemini Web (Free), Perplexity Web (ProMax), Blackbox Web (Subscription), Moon Spark Web (Mini AI)
  - Claude Web, DeepSeek Web, Microsoft Copilot Web, Kimi Web (Moonshot AI), Doubao Web (ByteDance), Qwen Web (Free)
  - Gemini Business (Enterprise), SERVER, LM Studio, vLLM, Lemonade Server, Llamafile, llama.cpp, NVIDIA Triton, Docker Model Runner
  - Windserve, InWorld.ai, GSD Webui, CoralTty, Perplexity Search, Serper Search, Brave Search, Kiko Search, Tavily Search
  - Google Programmable Search, LinkSearch, SearchAPI, You.com Search, SearXNG Search, Bocha Search, DuckDuckGo Search, AssemblyAI
  - ElevenLabs, Deepgram, PlayHT, Inworld, AWS Polly, PROXY, 1PProxyAPI, Browser, Google Jules, Devin, Coder Cloud
  - Auto (Zero-Config)

---

## Section 4: Banned Keywords

- **Header:** Red warning icon + "Banned Keywords" in bold
- **Description:** "Additional keywords that trigger permanent account ban detection. Built-in keywords always apply."
- Input field with placeholder: "e.g. api key revoked"
- **"+ Add"** button (red text)
- Status text: "No custom keywords. Only built-in keywords are active."

---

## Section 5: Manage-scope bypass

- **Header:** Red shield icon + "Manage-scope bypass" in bold
- **Bypass kill-switch** — toggle (red, **ON**)
  - Description: "Master toggle. When off, no LOCAL_ONLY prefix is reachable from non-loopback regardless of the per-prefix list."
- **Bypassable prefixes**
  - Description: "LOCAL_ONLY prefixes that manage-scope API keys (or dashboard sessions) may reach from non-loopback hosts."
  - A table/list of prefixes, each in a white card with red left border:
    - `/api/mcp/` — "Remove" link (red)
    - `/api/cli-tools/runtime/` — "Spam capable" badge (red)
    - `/api/services/` — "Spam capable" badge (red)
    - `/api/tools/agent-bridge/` — "Spam capable" badge (red)
    - `/api/tools/traffic-inspector/` — "Spam capable" badge (red)
    - `/api/plugins/` — "Spam capable" badge (red)
  - Each entry has gray subtext: "Spam-capable prefix. Compile-time deny cannot be made bypassable. Shown read-only."
- **Add prefix** section:
  - Input field with placeholder: `/api/mcp/v2/`
  - **"Add prefix"** button (red text)
- **"Save changes"** button — red background, white text, bottom-right

---

## Section 6: Authorization Inventory

- **Header:** Red lock icon + "Authorization Inventory" in bold
- **Description:** "5-tier route classification with live bypass policy. Red shows the full taxonomy, mutations re-prompt for the management password."
- **"Local only"** label in red, with badge: "Bypassable via manage-scope"
  - Description: "Loopback-only routes. Spoken child processes; exposing them to non-local traffic is a known CVE class (GHSA-ffh6-4cpv-rpg). Some entries are opt-in bypassable via the manage-scope (kill-switch gated)."
  - Listed routes:
    - `/api/mcp/` — "Bypassable via manage scope" badge (red)
    - `/api/cli-tools/runtime/` — "Spam capable" badge (red)
    - `/api/services/` — (truncated, continues below fold)

---

## Visual Style Notes

- **Primary accent color:** Red (#E53935 or similar) — used for toggles, buttons, active states, badges, and section icons
- **Background:** White (#FFFFFF) for main content, very light gray for sidebar background
- **Text colors:** Dark gray/black for headings, medium gray for descriptions, lighter gray for placeholders
- **Card style:** White cards with subtle shadow/border, rounded corners
- **Toggle style:** Red when ON, gray when OFF — iOS-style pill toggles
- **Badge style:** Small rounded pills with colored backgrounds for provider names in the Blocked Providers grid
- **Spacing:** Generous vertical spacing between sections (~32-48px)
