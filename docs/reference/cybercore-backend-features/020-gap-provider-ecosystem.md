# Feature Catalog: Gap — Provider Ecosystem

> **Series**: 2000
> **EPICs**: EPIC-2000 (Tier-1 Provider Adapters), EPIC-2010 (Tier-2 Provider Adapters), EPIC-2020 (Self-Hosted/Local Providers), EPIC-2030 (Embedding & Specialty Providers)
> **Gap Source**: diegosouza-omniroute (160+ providers; we only plan OpenAI, Anthropic, Google, Groq, OpenRouter, Generic)
> **Total Features**: 40

## Gap Analysis Summary

Our catalog defines 6 provider adapters: OpenAI (710-719), Anthropic (720-729), OpenRouter (730-734), Generic OpenAI-Compatible (736-738), Google Gemini (740-745), and Groq (746-749). The diegosouza reference supports 160+ providers.

We do NOT need to build 160+ adapters. Most providers speak OpenAI-compatible API and can use our Generic adapter (736). However, several **tier-1 and tier-2 providers** have unique APIs, authentication patterns, or important market share that warrant dedicated adapters or at least documented configuration for the Generic adapter.

### Prioritization Criteria
1. **Market share and usage** — providers developers actually use
2. **API uniqueness** — providers with non-OpenAI-compatible APIs
3. **Strategic importance** — local/self-hosted, enterprise cloud, specialty

## Classification Guide

- **CORE**: Tier-1 providers with unique APIs (Mistral, Azure OpenAI, AWS Bedrock, DeepSeek) — needed for enterprise adoption
- **EXTENDED**: Tier-2 providers, self-hosted (Ollama, vLLM), embedding-only providers
- **ECOSYSTEM**: Long-tail providers that work via Generic adapter

---

## Features

### Tier-1 Provider Adapters (2000-2009)

| # | Name | Description | Classification | Priority | Proposed EPIC |
|---|------|-------------|---------------|----------|---------------|
| 2000 | Mistral AI Adapter | Implement Mistral AI adapter: Mistral-specific API format (similar to OpenAI with differences), `api.mistral.ai`, API key auth, model-specific parameters | CORE | P1 | EPIC-2000 (new) |
| 2001 | Azure OpenAI Adapter | Implement Azure OpenAI adapter: Azure-specific URL format (`{resource}.openai.azure.com`), API version header, deployment-based routing, Azure AD auth option | CORE | P1 | EPIC-2000 |
| 2002 | AWS Bedrock Adapter | Implement AWS Bedrock adapter: AWS SigV4 authentication, Bedrock API format, multi-model invocation (Claude, Titan, Llama via Bedrock), region-based routing | CORE | P1 | EPIC-2000 |
| 2003 | DeepSeek Adapter | Implement DeepSeek adapter: OpenAI-compatible with DeepSeek-specific extensions (reasoning content, `enable_thinking` parameter), `api.deepseek.com` | CORE | P1 | EPIC-2000 |
| 2004 | xAI/Grok Adapter | Implement xAI adapter: Grok model API, `api.x.ai`, API key auth, OpenAI-compatible with xAI-specific model naming | CORE | P1 | EPIC-2000 |
| 2005 | Cohere Adapter | Implement Cohere adapter: Cohere-specific API (`api.cohere.com`), non-OpenAI format for chat/embed/rerank, API key in `Authorization: Bearer` | CORE | P1 | EPIC-2000 |
| 2006 | Vertex AI Adapter | Implement Google Vertex AI adapter: Google Cloud auth (service account), different from Gemini API format, project/region-based endpoint | CORE | P2 | EPIC-2000 |
| 2007 | Azure AI Foundry Adapter | Implement Azure AI Foundry (formerly Azure AI Studio) adapter: model-as-a-service, deployment endpoints, Azure AD auth, multi-model support | EXTENDED | P2 | EPIC-2000 |
| 2008 | Provider Adapter Registry | Registry of all provider adapters: built-in and plugin, lookup by provider name, capability-based selection, auto-detection of compatible adapter | CORE | P1 | EPIC-2000 |
| 2009 | Tier-1 Provider Tests | Test suite for tier-1 providers: mock API responses, auth handling, request/response mapping, error mapping, rate limit header parsing | CORE | P1 | EPIC-2000 |

### Tier-2 Provider Adapters (2010-2019)

| # | Name | Description | Classification | Priority | Proposed EPIC |
|---|------|-------------|---------------|----------|---------------|
| 2010 | Together AI Adapter | Implement Together AI adapter: OpenAI-compatible format, `api.together.xyz`, API key auth, fast inference for open-source models | EXTENDED | P2 | EPIC-2010 (new) |
| 2011 | Fireworks AI Adapter | Implement Fireworks AI adapter: OpenAI-compatible format, `api.fireworks.ai`, API key auth, optimized open-source model serving | EXTENDED | P2 | EPIC-2010 |
| 2012 | Cerebras Adapter | Implement Cerebras adapter: ultra-fast inference, OpenAI-compatible, `api.cerebras.ai`, API key auth | EXTENDED | P2 | EPIC-2010 |
| 2013 | SambaNova Adapter | Implement SambaNova adapter: high-throughput inference, OpenAI-compatible, API key auth | EXTENDED | P2 | EPIC-2010 |
| 2014 | NVIDIA NIM Adapter | Implement NVIDIA NIM adapter: NVIDIA Inference Microservices, OpenAI-compatible with NVIDIA extensions, API key auth | EXTENDED | P2 | EPIC-2010 |
| 2015 | DeepInfra Adapter | Implement DeepInfra adapter: OpenAI-compatible, `api.deepinfra.com`, specialized for open-source models at scale | EXTENDED | P2 | EPIC-2010 |
| 2016 | HuggingFace Inference Adapter | Implement HuggingFace Inference API adapter: model-specific endpoints, HF-specific auth, supports text, embedding, and image generation | EXTENDED | P2 | EPIC-2010 |
| 2017 | Generic Provider Config Templates | Pre-built configuration templates for OpenAI-compatible providers: Together, Fireworks, Cerebras, Lambda, nScale; configurable via Generic adapter | CORE | P1 | EPIC-2010 |
| 2018 | Provider Auto-Detection | Auto-detect provider API compatibility: probe endpoint with test request, determine if OpenAI-compatible, detect provider-specific extensions | EXTENDED | P2 | EPIC-2010 |
| 2019 | Tier-2 Provider Tests | Test suite for tier-2 providers: generic adapter configuration, provider template validation, auto-detection | EXTENDED | P2 | EPIC-2010 |

### Self-Hosted & Local Providers (2020-2029)

| # | Name | Description | Classification | Priority | Proposed EPIC |
|---|------|-------------|---------------|----------|---------------|
| 2020 | Ollama Adapter | Implement Ollama adapter: Ollama-specific API format (`/api/generate`, `/api/chat`), local HTTP, model management (pull/list), custom model config | EXTENDED | P2 | EPIC-2020 (new) |
| 2021 | Ollama Model Management | Support Ollama model management: list available models, pull new models, detect running models; auto-register as capabilities | EXTENDED | P2 | EPIC-2020 |
| 2022 | vLLM Adapter | Implement vLLM adapter: OpenAI-compatible API served by vLLM, custom endpoint URL, model-specific parameters, batching support | EXTENDED | P2 | EPIC-2020 |
| 2023 | LM Studio Adapter | Implement LM Studio adapter: OpenAI-compatible local API, auto-detection of LM Studio on loopback, model discovery | EXTENDED | P2 | EPIC-2020 |
| 2024 | Local Provider Discovery | Auto-discover local providers: scan common ports on localhost (Ollama: 11434, vLLM: 8000, LM Studio: 1234), probe for API compatibility | EXTENDED | P2 | EPIC-2020 |
| 2025 | Local Provider Health | Monitor local provider health: shorter probe interval, detect process crashes, auto-reconnect on restart | EXTENDED | P2 | EPIC-2020 |
| 2026 | Docker Model Runner Adapter | Implement Docker Model Runner adapter: interface with Docker-hosted model containers, lifecycle management, port mapping | ECOSYSTEM | P3 | EPIC-2020 |
| 2027 | NVIDIA Triton Adapter | Implement NVIDIA Triton Inference Server adapter: gRPC + HTTP, model repository, dynamic batching, ensemble models | ECOSYSTEM | P3 | EPIC-2020 |
| 2028 | Local Provider GPU Detection | Detect GPU availability for local providers: report VRAM, GPU model, utilization; used for capacity-aware routing to local models | ECOSYSTEM | P3 | EPIC-2020 |
| 2029 | Self-Hosted Provider Tests | Test suite for self-hosted providers: mock local APIs, model management, discovery, health monitoring | EXTENDED | P2 | EPIC-2020 |

### Embedding & Specialty Providers (2030-2039)

| # | Name | Description | Classification | Priority | Proposed EPIC |
|---|------|-------------|---------------|----------|---------------|
| 2030 | Voyage AI Adapter | Implement Voyage AI adapter: embedding-focused provider, `api.voyageai.com`, specialized for retrieval embeddings (voyage-3, voyage-code-3) | EXTENDED | P2 | EPIC-2030 (new) |
| 2031 | Jina AI Adapter | Implement Jina AI adapter: embedding + reranking, `api.jina.ai`, late-interaction models, multi-modal embeddings | EXTENDED | P2 | EPIC-2030 |
| 2032 | Cohere Embed/Rerank | Extend Cohere adapter with embedding and reranking: `embed-v3` embeddings, `rerank-v3` reranking, batch support | EXTENDED | P2 | EPIC-2030 |
| 2033 | Deepgram Adapter | Implement Deepgram adapter: speech-to-text API, real-time and batch transcription, speaker diarization, language detection | EXTENDED | P2 | EPIC-2030 |
| 2034 | ElevenLabs Adapter | Implement ElevenLabs adapter: text-to-speech API, voice cloning, voice library, streaming audio, SSML support | EXTENDED | P3 | EPIC-2030 |
| 2035 | Stability AI Adapter | Implement Stability AI adapter: image generation (SDXL, SD3), image editing, upscaling, `api.stability.ai` | EXTENDED | P2 | EPIC-2030 |
| 2036 | Provider Pricing Sync | Implement external pricing data sync: fetch pricing from LiteLLM pricing database or equivalent, auto-update model pricing in catalog | CORE | P1 | EPIC-2030 |
| 2037 | Provider Plans Tracking | Track provider subscription plans per credential: free tier limits, paid tier limits, credit balance; inform routing decisions | EXTENDED | P2 | EPIC-2030 |
| 2038 | Provider Credit Balance | Track credit balance per provider credential: available credits, burn rate, estimated depletion; warn on low balance | EXTENDED | P2 | EPIC-2030 |
| 2039 | Specialty Provider Tests | Test suite for embedding and specialty providers: embedding format, reranking, audio, image generation | EXTENDED | P2 | EPIC-2030 |

---

## Cross-References

| Gap Feature | Existing Feature | Relationship |
|-------------|-----------------|--------------|
| 2000-2007 (Provider Adapters) | 710-749 (Existing Adapters) | New adapters follow same patterns, extend provider ecosystem |
| 2001 (Azure OpenAI) | 736 (Generic Adapter) | Azure OpenAI needs dedicated adapter due to unique URL/auth pattern |
| 2002 (AWS Bedrock) | 165 (Credential Broker) | Bedrock needs SigV4 signing via credential broker |
| 2008 (Adapter Registry) | 739 (Adapter Selection) | Extends adapter selection with formal registry |
| 2017 (Config Templates) | 736-738 (Generic Adapter) | Config templates configure the generic adapter per provider |
| 2020-2025 (Local Providers) | 314 (Provider Health) | Local providers use same health tracking with different parameters |
| 2024 (Local Discovery) | cybernetics-core local discovery | Mirrors MetaMCP local service discovery feature |
| 2036 (Pricing Sync) | 323 (Model Pricing Tracking) | External pricing feeds into model pricing tracking |
| 2037-2038 (Plans/Credits) | 811 (Cost Budget) | Provider plans/credits inform budget routing decisions |
