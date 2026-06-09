# Feature Catalog: Execution & Providers

> **Series**: 700
> **EPICs**: EPIC-700, EPIC-710, EPIC-720, EPIC-730, EPIC-740, EPIC-750, EPIC-760, EPIC-770, EPIC-780
> **Tasks**: 0291-0345
> **Total Features**: 55

## Features

### Provider Interfaces (700-709)

| # | Name | Description | Priority |
|---|------|-------------|----------|
| 700 | LLM Provider Interface | Define `LLMProvider` interface: `ChatCompletion(ctx, req) → response`, `StreamChatCompletion(ctx, req) → <-chan chunk`, `ListModels()` | P0 |
| 701 | Provider Config Model | Define `ProviderConfig`: base URL, auth header name, auth token source, custom headers, timeout, retry config | P0 |
| 702 | Provider Request Model | Define unified `ProviderRequest`: model, messages, temperature, max tokens, tools, response format, stream flag | P0 |
| 703 | Provider Response Model | Define unified `ProviderResponse`: choices, usage (prompt/completion/total tokens), model, finish reason, tool calls | P0 |
| 704 | Stream Chunk Model | Define `StreamChunk`: delta content, role, tool call delta, finish reason, usage (final chunk), index | P0 |
| 705 | Provider Error Model | Define `ProviderError`: HTTP status, error code, message, provider-specific details, retryable flag | P0 |
| 706 | Provider Timeout Config | Configure per-provider timeouts: connect, read, write, total; streaming timeout separate from non-streaming | P0 |
| 707 | Provider Retry Config | Configure per-provider retry: max retries, retryable status codes, backoff strategy, retry budget | P0 |
| 708 | Provider Header Injection | Inject custom headers per provider: API version headers, organization headers, beta feature headers | P1 |
| 709 | Provider Response Normalization | Normalize provider responses to unified model: map provider-specific fields to standard response structure | P0 |

### OpenAI Adapter (710-719)

| # | Name | Description | Priority |
|---|------|-------------|----------|
| 710 | OpenAI Client | Implement OpenAI HTTP client: base URL, auth, request serialization, response deserialization | P0 |
| 711 | OpenAI Chat Completion | Implement `ChatCompletion` for OpenAI: map unified request to OpenAI format, send, map response back | P0 |
| 712 | OpenAI Streaming | Implement SSE streaming for OpenAI: parse `data: [DONE]` termination, map delta chunks to unified format | P0 |
| 713 | OpenAI Function Calling | Support OpenAI function/tool calling: map tool definitions, parse tool call responses, multi-turn tool use | P0 |
| 714 | OpenAI JSON Mode | Support OpenAI JSON mode: set `response_format`, validate JSON output, retry on invalid JSON | P1 |
| 715 | OpenAI Vision | Support OpenAI vision: image URLs and base64 in messages, multi-modal content parts | P1 |
| 716 | OpenAI Embeddings | Implement embedding endpoint: support batch input, dimension selection, normalize output | P1 |
| 717 | OpenAI Model List | Implement OpenAI model listing: fetch `/v1/models`, map to capability metadata | P0 |
| 718 | OpenAI Rate Limit Parsing | Parse OpenAI rate limit headers: `x-ratelimit-limit-*`, `x-ratelimit-remaining-*`, `x-ratelimit-reset-*`; feed to coordination plane | P0 |
| 719 | OpenAI Error Mapping | Map OpenAI error responses to unified `ProviderError`: 401 → auth, 429 → rate limit, 500+ → server error | P0 |

### Anthropic Adapter (720-729)

| # | Name | Description | Priority |
|---|------|-------------|----------|
| 720 | Anthropic Client | Implement Anthropic HTTP client: base URL, `x-api-key` auth, `anthropic-version` header, request/response mapping | P0 |
| 721 | Anthropic Chat Completion | Implement `ChatCompletion` for Anthropic: map unified format to Anthropic Messages API, system prompt handling | P0 |
| 722 | Anthropic Streaming | Implement SSE streaming for Anthropic: parse event types (`message_start`, `content_block_delta`, `message_stop`) | P0 |
| 723 | Anthropic Tool Use | Support Anthropic tool use: map tool definitions to `tools` parameter, parse `tool_use` content blocks | P0 |
| 724 | Anthropic Vision | Support Anthropic vision: base64 image content blocks, media type handling | P1 |
| 725 | Anthropic Extended Thinking | Support Anthropic extended thinking: `thinking` content blocks, budget tokens configuration | P2 |
| 726 | Anthropic System Prompt | Handle Anthropic system prompt format: separate `system` field (not in messages array) | P0 |
| 727 | Anthropic Rate Limit Parsing | Parse Anthropic rate limit headers: `anthropic-ratelimit-*` headers; feed to coordination plane | P0 |
| 728 | Anthropic Error Mapping | Map Anthropic error responses to unified `ProviderError`: `overloaded_error`, `rate_limit_error`, etc. | P0 |
| 729 | Anthropic Model List | Implement Anthropic model listing: static catalog (Anthropic doesn't expose model list API), update on release | P1 |

### OpenRouter & Generic Adapters (730-739)

| # | Name | Description | Priority |
|---|------|-------------|----------|
| 730 | OpenRouter Client | Implement OpenRouter HTTP client: OpenAI-compatible format with OpenRouter-specific headers and model naming | P0 |
| 731 | OpenRouter Model Routing | Support OpenRouter model routing: model name → provider, `X-Title`, `HTTP-Referer` headers, transforms parameter | P0 |
| 732 | OpenRouter Streaming | Implement OpenRouter streaming: SSE with OpenAI-compatible format, handle OpenRouter-specific extensions | P0 |
| 733 | OpenRouter Rate Limits | Parse OpenRouter rate limit and credit headers; handle free-tier vs paid-tier limits | P0 |
| 734 | OpenRouter Error Handling | Handle OpenRouter-specific errors: model unavailable, credit exhaustion, provider errors, moderation | P0 |
| 735 | OpenRouter Model Discovery | Fetch OpenRouter model list from API: pricing, context length, capabilities per model | P1 |
| 736 | Generic OpenAI-Compatible Adapter | Implement generic adapter for any OpenAI-compatible API: configurable base URL, auth, model mapping | P0 |
| 737 | Generic Adapter Config | Configure generic adapter: custom headers, request transforms, response mapping, feature flags | P1 |
| 738 | Generic Adapter Validation | Validate generic adapter connectivity on registration: test endpoint, verify model availability | P1 |
| 739 | Adapter Selection by Capability | Route to correct adapter based on capability metadata: provider field determines which adapter handles request | P0 |

### Google Gemini Adapter (740-745)

| # | Name | Description | Priority |
|---|------|-------------|----------|
| 740 | Gemini Client | Implement Google Gemini HTTP client: API key or OAuth auth, `generativelanguage.googleapis.com` base URL | P1 |
| 741 | Gemini Chat Completion | Implement `ChatCompletion` for Gemini: map unified format to Gemini `generateContent` API, role mapping (user/model) | P1 |
| 742 | Gemini Streaming | Implement Gemini streaming: SSE with `streamGenerateContent`, parse Gemini delta format | P1 |
| 743 | Gemini Function Calling | Support Gemini function calling: `tools` and `tool_config`, parse `functionCall` responses | P1 |
| 744 | Gemini Model List | Fetch Gemini model list from API: `/v1beta/models`, map to capability metadata | P1 |
| 745 | Gemini Error Mapping | Map Gemini error responses to unified `ProviderError`: gRPC-style error codes to HTTP semantics | P1 |

### Groq Adapter (746-749)

| # | Name | Description | Priority |
|---|------|-------------|----------|
| 746 | Groq Client | Implement Groq HTTP client: OpenAI-compatible format with Groq base URL and API key | P1 |
| 747 | Groq Chat Completion | Implement `ChatCompletion` for Groq: standard OpenAI-compatible format, handle Groq speed metadata | P1 |
| 748 | Groq Streaming | Implement Groq streaming: SSE with OpenAI-compatible format, ultra-low-latency handling | P1 |
| 749 | Groq Rate Limit Parsing | Parse Groq rate limit headers: requests/min, tokens/min; feed to coordination plane | P1 |

### Execution Engine (750-759)

| # | Name | Description | Priority |
|---|------|-------------|----------|
| 750 | Execution Engine | Implement `Executor.Execute()`: given execution plan, acquire leases, execute steps in order, handle fallback, return result | P0 |
| 751 | Stream Execution | Implement `Executor.Stream()`: streaming execution with SSE output, handle provider-specific stream formats | P0 |
| 752 | Step Executor | Execute individual plan step: select adapter, inject credentials from lease, call provider, collect metrics | P0 |
| 753 | Execution Timeout | Enforce per-step and total execution timeout: cancel on timeout, release leases, record timeout in metrics | P0 |
| 754 | Execution Fallback Handler | Handle step failure: check if fallback available, transition to next step, update execution path record | P0 |
| 755 | Execution Cancellation | Support request cancellation: propagate context cancellation to provider, release leases, record partial result | P0 |
| 756 | Stream Normalizer | Normalize streaming output across providers: unified SSE format, consistent delta structure, usage in final chunk | P0 |
| 757 | Execution Metrics Collection | Collect per-execution metrics: latency, token usage, cost, fallback count, provider, model, error details | P0 |
| 758 | Execution Envelope Builder | Build `ExecutionEnvelope` from execution result: all audit fields populated for observability | P0 |
| 759 | Execution Idempotency | Support idempotent execution: detect duplicate requests via workload fingerprint, return cached result if available | P1 |

### Data Plane Gateway (760-769)

| # | Name | Description | Priority |
|---|------|-------------|----------|
| 760 | Gateway Handler | Implement data plane gateway: receive request → authenticate → load descriptor → authorize → classify → plan → execute → stream → audit | P0 |
| 761 | Descriptor Lookup | Look up compiled `EndpointDescriptor` from cache (local → Redis → compile); reject if not found | P0 |
| 762 | Gateway Authentication | Authenticate request in gateway: extract subject, validate credentials, set in context | P0 |
| 763 | Gateway Authorization | Authorize request in gateway: evaluate cached policy snapshot, reject if denied | P0 |
| 764 | Gateway Rate Check | Check rate limits in gateway: per-subject, per-key, per-exposure limits from Redis coordination plane | P0 |
| 765 | Gateway Streaming | Handle streaming in gateway: SSE for chat completions, proper flush, heartbeat for long-running streams | P0 |
| 766 | Gateway Error Handling | Map internal errors to OpenAI-compatible error responses: proper HTTP status, error object, retry hints | P0 |
| 767 | Gateway Request Logging | Log gateway requests: request ID, subject, model, stream flag, tokens, latency (never log content) | P0 |
| 768 | Gateway Timeout | Enforce gateway-level timeout: configurable per exposure, includes planning + execution + streaming time | P0 |
| 769 | Gateway Metrics | Expose gateway metrics: request count, latency histogram, error rate, active streams, token throughput | P0 |

### OpenAI-Compatible Endpoints (770-786)

| # | Name | Description | Priority |
|---|------|-------------|----------|
| 770 | POST /v1/chat/completions | Implement OpenAI-compatible chat completions endpoint: full request/response compatibility | P0 |
| 771 | POST /v1/chat/completions (stream) | Implement streaming chat completions: SSE format, `data: [DONE]` termination, usage in final chunk | P0 |
| 772 | GET /v1/models | Implement model listing endpoint: return available models based on subject's authorized capabilities | P0 |
| 773 | GET /v1/models/:model | Implement model detail endpoint: return specific model metadata, availability, pricing | P0 |
| 774 | POST /v1/completions | Implement legacy completions endpoint: text completion format, map to chat completion internally | P1 |
| 775 | POST /v1/embeddings | Implement embeddings endpoint: batch input, dimension selection, provider-aware routing | P1 |
| 776 | POST /v1/images/generations | Implement image generation endpoint: DALL-E compatible format, provider routing | P2 |
| 777 | POST /v1/audio/speech | Implement text-to-speech endpoint: voice selection, format, speed; provider routing | P2 |
| 778 | POST /v1/audio/transcriptions | Implement audio transcription endpoint: file upload, language, format; provider routing | P2 |
| 779 | OpenAI Error Format | Return OpenAI-compatible error format: `{ "error": { "message": ..., "type": ..., "code": ... } }` | P0 |
| 77A | Usage Headers | Return usage information in response headers: `x-usage-prompt-tokens`, `x-usage-completion-tokens`, `x-usage-total-tokens` | P1 |
| 77B | Model Aliasing in Requests | Support model aliasing in requests: resolve alias to concrete model before routing | P0 |
| 77C | Request Validation | Validate OpenAI-compatible requests: required fields, parameter ranges, message format, tool definitions | P0 |
| 77D | Response Formatting | Format responses to match OpenAI specification exactly: field names, types, optional fields, timestamps | P0 |
| 77E | Content-Type Negotiation | Handle content-type negotiation: `application/json` for non-streaming, `text/event-stream` for streaming | P0 |
| 780 | SSE Heartbeat | Implement SSE heartbeat: send comment lines (`: heartbeat`) during long-running streams to prevent proxy timeouts | P0 |
| 781 | Stream Backpressure | Implement stream backpressure: detect slow clients, buffer to limit, cancel on overflow | P1 |
| 782 | Request Size Limit | Enforce request size limits: configurable max body size per endpoint, reject with 413 before parsing | P0 |
| 783 | Concurrent Request Limit | Enforce per-subject concurrent request limit: reject with 429 when limit reached | P0 |
| 784 | Request Deduplication | Detect and deduplicate identical concurrent requests from same subject: return shared result | P2 |
| 785 | Graceful Stream Termination | Handle client disconnect during streaming: detect, cancel upstream, release resources, log partial usage | P0 |
| 786 | OpenAI Compatibility Tests | Comprehensive test suite verifying OpenAI API compatibility: request/response format, error codes, streaming, edge cases | P0 |
