# Screenshot Report: Dashboard — Providers Page

**File**: `33_dashboard_providers.png`
**Page Title**: Providers
**Subtitle**: "Manage your AI provider connections"
**Breadcrumb**: Dashboard > Providers

---

## Search & Filter Bar

A horizontal toolbar at the top of the content area:

- **Search Providers** — text input with magnifying glass icon, placeholder "Search Providers".
- **Search by model...** — second text input with magnifying glass icon, placeholder "Search by model...".
- **Filter/Toggle Buttons** (right side):
  - Grid/list view toggle icon (currently grid).
  - **Configured** — toggle button.
  - **Compact** — toggle button.
  - **+ Onboarding Wizard** — red/coral filled button.
  - **Test All** — outlined button.

## Filter Chips Row

A row of colored filter chips (toggle pills) below the search bar:

| Chip | Color | Count |
|------|-------|-------|
| Total | Red/coral (filled, active) | 1693/16 |
| OAuth | Blue | 8/16 |
| IDE | Blue | 3/3 |
| Free Tier | Green | 30/111 |
| No Auth | Gray | 102/111 |
| Upstream Proxy | Gray | 5/12 |
| API Key | Orange | 301/14 |
| Compatible | Gray | 7/9 |
| Web Cookie | Purple | 5/22 |
| Search | Gray | 3/13 |
| Web Fetch | Gray | 6/14 |
| Audio | Gray | 0/6 |
| Local | Gray | 0/11 |
| Cloud Agent | Gray | 0/3 |

---

## Section 1: API Key Compatible Providers

**Section Header**: "API Key Compatible Providers" with red notification dot and count "18".
**Description**: "OpenAI-compatible and Anthropic-compatible endpoints you host or configure. Point any OpenAI SDK to your own URL and route requests here."
**Right-side buttons**: "Test All", "+ Add Anthropic-Compatible", "+ Add OpenAI-Compatible" (red/coral buttons).

### Provider Cards (4-column grid, 2 rows visible)

| Provider | Subtitle | Status | Connections | Actions |
|----------|----------|--------|-------------|---------|
| agt | Messages | 1 Error (402) · 23d ago | — | Edit, Test |
| Alibaba-GI | Chat | — | ● 1 Connected (green) | Edit, Test |
| Alibaba-SI | Messages | — | ● 4 Connected (green) | Edit, Test |
| Alibaba-US | Messages | — | ● 2 Connected (green) | Edit, Test |
| LMStudio | Responses | — | No connections | Edit, Test |
| StepanAI | Responses | — | No connections | Edit, Test |
| Tencent Copilot API | Responses | — | ● 3 Connected (green) | Edit, Test |
| Xiaomi-MIMI | Messages | — | 1 Error (Auth) · 23d ago | Edit, Test |

---

## Section 2: OAuth Providers

**Section Header**: "OAuth Providers" with count "9/16".
**Description**: "Providers authenticated via OAuth — sign in once and OmniRoute handles token rotation automatically."
**Right-side button**: "Test All".

### Provider Cards (4-column grid, 4 rows)

| Provider | Status | Connections |
|----------|--------|-------------|
| Amazon Q | Green dot | No connections |
| Antigravity | Green dot | ● 1 Connected |
| Antigravity CLI | Green dot | ● 1 Connected |
| Claude Code | Green dot | No connections |
| Cline | Green dot | No connections |
| Devon CLI (Official) | Green dot, 1 Error (401) · 26d ago | No connections |
| Gemini CLI | Green dot | ● 11 Connected |
| GitHub Copilot | Green dot | No connections |
| GitLab Duo | Green dot | No connections |
| Kilo Code | Green dot | ● 18 Connected |
| Kimi Coding | Green dot | ● 1 Connected |
| Kiro AI | Green dot | ● 10 Connected |
| OpenAI Codex | Green dot | ● 11 Connected |
| Qoder AI | Green dot | No connections |
| Qwen Code | Green dot | No connections |
| Windsurf (Devon CLI) | Green dot | ● 1 Connected, ● 1 Error (Auth) · 5h ago |

---

## Section 3: IDE Providers

**Section Header**: "IDE Providers" with count "1/3".
**Description**: "Editors with built-in AI subscription. Use the provider page to import credentials directly from the IDE keychain."
**Right-side button**: "Test All".

### Provider Cards (4-column grid, 1 row)

| Provider | Status | Connections |
|----------|--------|-------------|
| Cursor IDE | Green dot | No connections |
| Trae | Green dot | ● 4 Connected |
| Zed IDE | Green dot | No connections |

---

## Section 4: Web Cookie Providers

**Section Header**: "Web Cookie Providers" with count "6/22".
**Description**: "These providers use browser web sessions, cookies, or web tokens instead of API keys. Open a provider to add the required session credential."
**Right-side button**: "Test All".

### Provider Cards (4-column grid, 5+ rows)

| Provider | Status | Connections |
|----------|--------|-------------|
| Adapta.ai (Adapta One Web) | Yellow dot | No connections |
| Blackbox Web (Subscription) | Yellow dot | No connections |
| ChatGPT Web (Plus/Pro) | Yellow dot | ● 1 Connected |
| Claude Web | Yellow dot | ● 3 Connected |
| DeepSeek Web | Yellow dot | ● 9 Connected |
| Doubao Web (ByteDance) | Yellow dot | No connections |
| Gemini Business (Enterprise) | Yellow dot | No connections |
| Gemini Web (Free) | Yellow dot | No connections |
| Grok Web (Subscription) | Yellow dot | No connections |
| HuggingChat (Free) | Yellow dot | No connections |
| Inner.ai (Subscription) | Yellow dot | No connections |
| Kimi Web (Moonshot AI) | Yellow dot | ● 1 Connected |
| LMArena (Free) | Yellow dot | No connections |
| Microsoft Copilot Web | Yellow dot | No connections |
| Muse Spark Web (Meta AI) | Yellow dot | No connections |
| Perplexity Web (Pro/Max) | Yellow dot | No connections |
| Phind (Free) | Yellow dot | No connections |
| Poe Web (Subscription) | Yellow dot | No connections |
| Qwen Web (Free) | Yellow dot | ● 1 Connected |
| t3.chat (Pro/Free) | Yellow dot | No connections |
| v0 Vercel Web (Code Gen) | Yellow dot | No connections |
| Venice Web (Privacy) | Yellow dot | No connections |

---

## Section 5: Free Tier Providers

**Section Header**: "Free Tier Providers" with count "98/101".
**Description**: "All providers with free tier (also shown in their native category)."
**Right-side button**: "Test All".

### Provider Cards (4-column grid, many rows — partial list visible)

Notable providers visible with connection indicators:
- **AI/ML API** — ● 1 Connected (green)
- **Antigravity CLI** — ● 1 Connected (green)
- **Api.airforce** — ● 1 Connected (green)
- **Blackbox AI** — ● 1 Connected (green)
- **Cerebras** — ● 10 Connected (green)
- **Cloudflare Workers AI** — ● 4 Connected (green)
- **Fireworks AI** — ● 9 Connected (green)
- **Gemini (Google AI Studio)** — ● 13 Error (429) · 1h ago (red)
- **Gemini CLI** — ● 11 Connected (green)
- **Groq** — ● 1 Connected (green)

Other providers shown without connections: 360 AI, AgentRouter, AI21 Labs, Amazon Q, Arcane AI, Baichuan, Baidu (ERNIE), Baseten, BazaarLink, BluesMinds, Brave Search, BytePlus ModelArk, Bytez, Chipotle Pepper AI (Free), Chutes.ai, Cohere, ComfyUI, Coze, DeepInfra, DeepSeek, Dify, Doubao, DuckDuckGo AI Chat, Exa Search, Featherless AI, Firecrawl, FreeModel.dev, FriendliAI, GitHub Models, GitLab Opengateway (Mini Cloud), GitLab Opengateway (OMo), GLHF Chat, Hackchat AI, HuggingChat, HuggingFace, Hyperbolic, iFlytek Spark.

---

## Sidebar

Identical persistent left sidebar. **Providers** under the OMNIPROXY section is highlighted/active with a red/pink background indicator.
