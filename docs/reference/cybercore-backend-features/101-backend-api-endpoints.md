# Feature Catalog: Backend API Endpoints

> **Series**: 101
> **Source**: diegosouza-omniroute sidebar + cybernetics-core + OmniRoute analysis
> **Purpose**: Sidebar-discoverable features from reference repos
> **Total Features**: 35

## OmniProxy / Gateway

| # | Name | Description | Source Repo | Source File | In Our Catalog? |
|---|------|-------------|-------------|-------------|-----------------|
| 101-001 | Chat Completions | POST /v1/chat/completions (streaming + non-streaming) | diegosouza-omniroute | `src/app/api/v1/chat/completions/route.ts` | ✅ 780 |
| 101-002 | Responses API | POST /v1/responses | diegosouza-omniroute | `src/app/api/v1/responses/route.ts` | ✅ 781 |
| 101-003 | Embeddings | POST /v1/embeddings with 15 providers | diegosouza-omniroute | `open-sse/handlers/embeddings.ts` | ✅ 782 |
| 101-004 | Models List | GET /v1/models | diegosouza-omniroute | `src/app/api/v1/models/` | ✅ 783 |
| 101-005 | Image Generation | POST /v1/images/generations, 22 providers | diegosouza-omniroute | `open-sse/handlers/imageGeneration.ts` | ❌ GAP (014-001) |
| 101-006 | Audio Transcription (STT) | POST /v1/audio/transcriptions, 10 providers | diegosouza-omniroute | `open-sse/handlers/audioTranscription.ts` | ❌ GAP (014-010) |
| 101-007 | Audio Speech (TTS) | POST /v1/audio/speech, 15 providers | diegosouza-omniroute | `open-sse/handlers/audioSpeech.ts` | ❌ GAP (014-015) |
| 101-008 | Video Generation | POST /v1/videos/generations, 11 providers | diegosouza-omniroute | `open-sse/handlers/videoGeneration.ts` | ❌ GAP (014-020) |
| 101-009 | Music Generation | POST /v1/music/generations, 5 providers | diegosouza-omniroute | `open-sse/handlers/musicGeneration.ts` | ❌ GAP (014-025) |
| 101-010 | Content Moderation | POST /v1/moderations | diegosouza-omniroute | `open-sse/handlers/moderations.ts` | ❌ GAP (014-030) |
| 101-011 | Rerank | POST /v1/rerank, 6 providers | diegosouza-omniroute | `open-sse/handlers/rerank.ts` | ❌ GAP (014-035) |
| 101-012 | Web Search | POST /v1/search, 11 providers | diegosouza-omniroute | `open-sse/handlers/search.ts` | ✅ 1010+ |
| 101-013 | Web Fetch | Content fetching via Firecrawl/Jina/Tavily/Exa | diegosouza-omniroute | `open-sse/handlers/webFetch.ts` | ❌ GAP (014-040) |
| 101-014 | Batch Processing | POST /v1/batches | diegosouza-omniroute | `src/app/api/v1/batches/` | ❌ GAP (014-045) |
| 101-015 | File Operations | POST /v1/files | diegosouza-omniroute | `src/app/api/v1/files/` | ❌ GAP (014-048) |
| 101-016 | Relay Endpoint | POST /v1/relay/chat/completions | diegosouza-omniroute | `src/app/api/v1/relay/` | ❌ GAP |
| 101-017 | SSE Streaming | text/event-stream with [DONE] | diegosouza-omniroute | — | ✅ 784 |
| 101-018 | OpenAI Error Format | {error: {message, type, code}} | diegosouza-omniroute | — | ✅ 786 |

## Endpoint Management (cybernetics-core)

| # | Name | Description | Source Repo | Source File | In Our Catalog? |
|---|------|-------------|-------------|-------------|-----------------|
| 101-019 | Public Endpoint CRUD | Named endpoints mapping to namespaces | cybernetics-core | `apps/backend/src/db/schema.ts:250-293` | ✅ 340 |
| 101-020 | Streamable HTTP Surface | /{endpointName}/mcp | cybernetics-core | `streamable-http.ts` | ✅ 912 |
| 101-021 | SSE Surface | /{endpointName}/sse | cybernetics-core | `sse.ts` | ✅ 911 |
| 101-022 | OpenAPI Surface | Auto-generated REST API from tools | cybernetics-core | `openapi/` | ✅ 1110 |
| 101-023 | Endpoint Discovery | GET /cyberneticscore/ lists all endpoints | cybernetics-core | — | ❌ GAP |

## API Key Management

| # | Name | Description | Source Repo | Source File | In Our Catalog? |
|---|------|-------------|-------------|-------------|-----------------|
| 101-024 | API Key CRUD | Create/list/revoke | — | — | ✅ 220-227 |
| 101-025 | API Key Encryption at Rest | Encrypted key storage | diegosouza-omniroute | `src/lib/db/apiKeys.ts` | ✅ 222 |
| 101-026 | API Key Policy | Rate limits per key (1000/day, 5000/week) | diegosouza-omniroute | `src/shared/utils/apiKeyPolicy.ts` | ❌ GAP (advanced rate limit per key) |
| 101-027 | API Key Rotation | Round-robin between primary + extra keys | diegosouza-omniroute | `open-sse/services/apiKeyRotator.ts` | ❌ GAP (020-040) |
| 101-028 | Registered Keys Management | Lifecycle tracking for registered keys | diegosouza-omniroute | `src/lib/db/registeredKeys.ts` | ❌ GAP |
| 101-029 | MCP Scope-Based Auth | 16 scopes for MCP tools | diegosouza-omniroute | `src/shared/constants/mcpScopes.ts` | ❌ GAP (024-010) |

## Embedded Services

| # | Name | Description | Source Repo | Source File | In Our Catalog? |
|---|------|-------------|-------------|-------------|-----------------|
| 101-030 | LM Studio | localhost:1234/v1 | — | — | ✅ 733 (generic) |
| 101-031 | vLLM | localhost:8000/v1 | — | — | ✅ 733 (generic) |
| 101-032 | Ollama | Via OpenAI-compatible | — | — | ✅ 733 (generic) |
| 101-033 | Docker Model Runner | Docker-native model serving | diegosouza-omniroute | `src/shared/constants/providers.ts:2435` | ❌ GAP |
| 101-034 | ComfyUI | Image generation via ComfyUI | diegosouza-omniroute | `open-sse/handlers/imageGeneration.ts` | ❌ GAP (014-042) |
| 101-035 | SD WebUI | Stable Diffusion WebUI integration | diegosouza-omniroute | — | ❌ GAP (014-043) |
