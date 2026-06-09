# Feature Catalog: Gap — Multimodal Endpoints

> **Series**: 1400
> **EPICs**: EPIC-1400 (Multimodal Endpoint Framework), EPIC-1410 (Image Generation), EPIC-1420 (Audio Endpoints), EPIC-1430 (Video & Music Generation), EPIC-1440 (Moderation & Rerank), EPIC-1450 (Batch Processing)
> **Gap Source**: diegosouza-omniroute (image gen, audio, video, music, moderation, rerank, batch endpoints)
> **Total Features**: 50

## Gap Analysis Summary

Our catalog currently defines domain types for image generation (`KindImageGen`, `KindAudio`) and skeleton OpenAI endpoints (`776`, `777`, `778`) at P2 priority, but lacks:
- Full multimodal endpoint framework with provider routing
- Video generation endpoints
- Music generation endpoints
- Content moderation endpoint
- Reranking endpoint
- Batch processing API
- File operations API for batch inputs
- Relay endpoint for cross-model hand-off

These are significant gaps. The diegosouza reference supports 22 image gen providers, 10 STT providers, 15 TTS providers, 11 video gen providers, 5 music gen providers, and 6 reranking providers.

## Classification Guide

- **CORE**: Image generation, audio (TTS/STT), moderation, rerank — needed for a complete OpenAI-compatible gateway
- **EXTENDED**: Video generation, music generation, batch processing — valuable but not essential for v1
- **ECOSYSTEM**: Relay endpoint, niche multimodal features

---

## Features

### Multimodal Endpoint Framework (1400-1409)

| # | Name | Description | Classification | Priority | Proposed EPIC |
|---|------|-------------|---------------|----------|---------------|
| 1400 | Multimodal Provider Interface | Define `MultimodalProvider` interface: `GenerateImage(ctx, req)`, `Transcribe(ctx, req)`, `Synthesize(ctx, req)`, `Moderate(ctx, req)`, `Rerank(ctx, req)` — unified interface for non-LLM capabilities | CORE | P1 | EPIC-1400 |
| 1401 | Multimodal Request/Response Models | Define unified request/response models for each multimodal type: image gen request (prompt, size, quality, n), audio request (file, language, format), rerank request (query, documents, model) | CORE | P1 | EPIC-1400 |
| 1402 | Multimodal Workload Classification | Extend workload classifier for multimodal requests: `WorkloadKindImageGen`, `WorkloadKindAudioSTT`, `WorkloadKindAudioTTS`, `WorkloadKindVideoGen`, `WorkloadKindRerank`, `WorkloadKindModeration` | CORE | P1 | EPIC-1400 |
| 1403 | Multimodal Route Graph Support | Support multimodal capabilities in route graphs: image gen nodes, audio nodes, video nodes route to appropriate provider adapters | CORE | P1 | EPIC-1400 |
| 1404 | Multimodal Cost Tracking | Track cost per multimodal request: per-image pricing, per-minute audio pricing, per-video pricing; integrate with quota/budget system | CORE | P1 | EPIC-1400 |
| 1405 | Multimodal File Handling | Handle file uploads for multimodal endpoints: audio file upload (transcription), image file upload (editing), multipart/form-data parsing with size limits | CORE | P1 | EPIC-1400 |
| 1406 | Multimodal Response Streaming | Support streaming for applicable multimodal endpoints: chunked audio streaming (TTS), progressive image rendering | EXTENDED | P2 | EPIC-1400 |
| 1407 | Multimodal Provider Discovery | Auto-discover multimodal capabilities from providers: which providers support image gen, audio, reranking; update capability registry | CORE | P1 | EPIC-1400 |
| 1408 | Multimodal Rate Limiting | Per-endpoint type rate limits for multimodal: image gen limit separate from chat completions, audio limits separate | CORE | P1 | EPIC-1400 |
| 1409 | Multimodal Compatibility Matrix | Track per-provider multimodal capabilities: which sizes, formats, voices, languages each provider supports; used by planner | CORE | P1 | EPIC-1400 |

### Image Generation Endpoints (1410-1419)

| # | Name | Description | Classification | Priority | Proposed EPIC |
|---|------|-------------|---------------|----------|---------------|
| 1410 | POST /v1/images/generations | Implement OpenAI-compatible image generation endpoint: prompt, size, quality, style, n, response_format (url/b64_json) | CORE | P1 | EPIC-1410 |
| 1411 | Image Generation Provider Routing | Route image generation to appropriate provider: DALL-E, Stability AI, Fal.ai, etc. based on route graph and capability matching | CORE | P1 | EPIC-1410 |
| 1412 | Image Generation Size Normalization | Normalize image size parameters across providers: map standard sizes (1024x1024, 1792x1024) to provider-specific formats | CORE | P1 | EPIC-1410 |
| 1413 | Image Generation Quality Options | Support quality/style options: standard, hd, natural, vivid; map to provider-specific parameters | EXTENDED | P2 | EPIC-1410 |
| 1414 | POST /v1/images/edits | Implement image editing endpoint: original image + mask + prompt, provider routing for edit-capable providers | EXTENDED | P2 | EPIC-1410 |
| 1415 | POST /v1/images/variations | Implement image variation endpoint: original image → variations, provider routing | EXTENDED | P2 | EPIC-1410 |
| 1416 | Image Response Format | Support image response formats: URL (temporary signed URL) and base64-encoded JSON; handle provider-specific response formats | CORE | P1 | EPIC-1410 |
| 1417 | Image Generation Cost Estimation | Estimate image generation cost per request: size-based, quality-based, provider-based pricing | CORE | P1 | EPIC-1410 |
| 1418 | Image Generation Metrics | Track image generation metrics: requests per provider, generation time, sizes, costs, error rates | CORE | P1 | EPIC-1410 |
| 1419 | Image Generation Tests | Test suite for image generation: request validation, provider routing, response format, error handling, cost estimation | CORE | P1 | EPIC-1410 |

### Audio Endpoints (1420-1429)

| # | Name | Description | Classification | Priority | Proposed EPIC |
|---|------|-------------|---------------|----------|---------------|
| 1420 | POST /v1/audio/transcriptions | Implement OpenAI-compatible audio transcription (STT) endpoint: file upload (mp3/wav/m4a/webm), language, response_format (json/text/srt/vtt) | CORE | P1 | EPIC-1420 |
| 1421 | POST /v1/audio/translations | Implement audio translation endpoint: transcribe + translate to English; provider routing for translation-capable providers | EXTENDED | P2 | EPIC-1420 |
| 1422 | POST /v1/audio/speech | Implement OpenAI-compatible text-to-speech (TTS) endpoint: input text, model, voice, response_format, speed | CORE | P1 | EPIC-1420 |
| 1423 | Audio Transcription Provider Routing | Route transcription to provider: Whisper (OpenAI), Deepgram, AssemblyAI, Groq Whisper; based on route graph | CORE | P1 | EPIC-1420 |
| 1424 | Audio TTS Provider Routing | Route TTS to provider: OpenAI, ElevenLabs, PlayHT, Cartesia; based on route graph and voice availability | CORE | P1 | EPIC-1420 |
| 1425 | Audio File Format Handling | Handle audio file formats: validate input format, transcode if needed (ffmpeg), enforce file size limits | CORE | P1 | EPIC-1420 |
| 1426 | Audio Streaming TTS | Support streaming TTS: chunk-based audio streaming for low-latency playback, provider-specific stream handling | EXTENDED | P2 | EPIC-1420 |
| 1427 | Audio Duration/Cost Estimation | Estimate audio processing cost: per-minute transcription pricing, per-character TTS pricing; integrate with quotas | CORE | P1 | EPIC-1420 |
| 1428 | Audio Timestamp Support | Support word-level timestamps in transcription: return timestamps per segment/word when provider supports it | EXTENDED | P2 | EPIC-1420 |
| 1429 | Audio Endpoint Tests | Test suite for audio endpoints: file upload handling, format validation, provider routing, response formats | CORE | P1 | EPIC-1420 |

### Video & Music Generation (1430-1439)

| # | Name | Description | Classification | Priority | Proposed EPIC |
|---|------|-------------|---------------|----------|---------------|
| 1430 | POST /v1/videos/generations | Implement video generation endpoint: prompt, duration, resolution, model; async with polling for result | EXTENDED | P2 | EPIC-1430 |
| 1431 | Video Generation Provider Routing | Route video generation to provider: Runway, Pika, Stable Video, Kling; based on capability matching | EXTENDED | P2 | EPIC-1430 |
| 1432 | Video Generation Async Polling | Implement async polling for video generation: submit job → poll status → retrieve result URL; generation can take minutes | EXTENDED | P2 | EPIC-1430 |
| 1433 | Video Generation Cost Estimation | Estimate video generation cost: per-second, per-resolution pricing; warn on expensive operations | EXTENDED | P2 | EPIC-1430 |
| 1434 | POST /v1/music/generations | Implement music generation endpoint: prompt, duration, genre/style, model; async with polling | EXTENDED | P3 | EPIC-1430 |
| 1435 | Music Generation Provider Routing | Route music generation to provider: Suno, Udio, MusicGen; based on capability matching | EXTENDED | P3 | EPIC-1430 |
| 1436 | Async Job Manager | Implement generic async job manager for long-running generation tasks: submit, poll status, retrieve result, cancel, expire | EXTENDED | P2 | EPIC-1430 |
| 1437 | Async Job Status Endpoint | GET /v1/jobs/:id — check status of async generation job: pending, processing, completed, failed, cancelled | EXTENDED | P2 | EPIC-1430 |
| 1438 | Async Job Webhook Notification | Optionally notify via webhook when async generation job completes: URL configured per request or globally | EXTENDED | P3 | EPIC-1430 |
| 1439 | Video/Music Generation Tests | Test suite for video and music generation: async flow, polling, provider routing, cost estimation | EXTENDED | P2 | EPIC-1430 |

### Moderation & Reranking (1440-1449)

| # | Name | Description | Classification | Priority | Proposed EPIC |
|---|------|-------------|---------------|----------|---------------|
| 1440 | POST /v1/moderations | Implement OpenAI-compatible content moderation endpoint: input text, return category scores (hate, violence, sexual, self-harm, etc.), flagged boolean | CORE | P1 | EPIC-1440 |
| 1441 | Moderation Provider Routing | Route moderation to provider: OpenAI moderation, custom guardrail plugins; integrate with guardrail pipeline | CORE | P1 | EPIC-1440 |
| 1442 | Moderation Result Model | Define `ModerationResult`: categories (hate, violence, sexual, self-harm, harassment), category scores, flagged, model | CORE | P1 | EPIC-1440 |
| 1443 | Inline Moderation Check | Support optional inline moderation: check input before sending to LLM, check output before returning; configurable per exposure | CORE | P1 | EPIC-1440 |
| 1444 | POST /v1/rerank | Implement reranking endpoint: query + documents array, return reranked results with relevance scores | CORE | P1 | EPIC-1440 |
| 1445 | Rerank Provider Routing | Route reranking to provider: Cohere, Voyage AI, Jina AI, BGE; based on route graph | CORE | P1 | EPIC-1440 |
| 1446 | Rerank Response Model | Define `RerankResponse`: ranked document indices, relevance scores, model, usage | CORE | P1 | EPIC-1440 |
| 1447 | Rerank Top-N Support | Support top_n parameter: return only top N most relevant documents from reranking | CORE | P1 | EPIC-1440 |
| 1448 | Moderation/Rerank Metrics | Track moderation and rerank metrics: request count, latency, flag rate (moderation), cost per provider | CORE | P1 | EPIC-1440 |
| 1449 | Moderation/Rerank Tests | Test suite for moderation and reranking: request validation, provider routing, response format, scoring accuracy | CORE | P1 | EPIC-1440 |

### Batch Processing & File Operations (1450-1459)

| # | Name | Description | Classification | Priority | Proposed EPIC |
|---|------|-------------|---------------|----------|---------------|
| 1450 | POST /v1/batches | Implement batch processing endpoint: submit batch of requests (JSONL), async processing, return batch ID | EXTENDED | P2 | EPIC-1450 |
| 1451 | Batch JSONL Parser | Parse JSONL batch input: validate each line as valid request, report line-level errors, enforce max batch size | EXTENDED | P2 | EPIC-1450 |
| 1452 | Batch Processing Worker | Background worker for batch processing: dequeue batch jobs, process requests sequentially or in parallel, track progress | EXTENDED | P2 | EPIC-1450 |
| 1453 | Batch Status Endpoint | GET /v1/batches/:id — check batch status: total requests, completed, failed, in-progress, output file ID | EXTENDED | P2 | EPIC-1450 |
| 1454 | Batch Result Retrieval | Retrieve batch results: download completed JSONL output file with results for each request including errors | EXTENDED | P2 | EPIC-1450 |
| 1455 | Batch Cost Estimation | Estimate batch cost before processing: sum of individual request cost estimates; confirm or auto-approve | EXTENDED | P2 | EPIC-1450 |
| 1456 | Batch Retry on Failure | Retry failed requests within batch: configurable retry count, exponential backoff, partial success support | EXTENDED | P2 | EPIC-1450 |
| 1457 | POST /v1/files | Implement file upload endpoint: upload JSONL for batch input, store temporarily, return file ID | EXTENDED | P2 | EPIC-1450 |
| 1458 | GET /v1/files/:id | Retrieve uploaded file metadata: filename, size, purpose, created time, status | EXTENDED | P2 | EPIC-1450 |
| 1459 | Batch Processing Metrics | Track batch processing metrics: jobs submitted, completion rate, average processing time, cost, error rate | EXTENDED | P2 | EPIC-1450 |

---

## Cross-References

| Gap Feature | Existing Feature | Relationship |
|-------------|-----------------|--------------|
| 1402 (Multimodal Classification) | 610-618 (Workload Classifier) | Extends classifier with new workload kinds |
| 1403 (Multimodal Route Graph) | 600-609 (Route Graph Model) | Route graphs must support multimodal node types |
| 1404 (Multimodal Cost) | 811, 615 (Budget, Cost Estimation) | Extends cost system for non-text modalities |
| 1410 (Image Gen) | 776 (Image endpoint skeleton) | Replaces P2 skeleton with full implementation |
| 1420 (Audio STT) | 778 (Audio transcription skeleton) | Replaces P2 skeleton with full implementation |
| 1422 (Audio TTS) | 777 (Audio speech skeleton) | Replaces P2 skeleton with full implementation |
| 1440 (Moderation) | 1251 (Content Filter Plugin) | Moderation endpoint is external-facing; plugin is internal guardrail |
| 1444 (Rerank) | 125 (KindReranker) | Domain type already defined; this adds the endpoint and routing |
