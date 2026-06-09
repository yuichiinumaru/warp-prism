# Feature Catalog: Gap — Prompt Compression & Context Management

> **Series**: 1600
> **EPICs**: EPIC-1600 (Context Manager), EPIC-1610 (Compression Pipeline), EPIC-1620 (Thinking Budget)
> **Gap Source**: diegosouza-omniroute (7-mode compression pipeline, context manager, thinking budget, progressive aging)
> **Total Features**: 35

## Gap Analysis Summary

Our catalog has no features related to prompt compression, context window management, or thinking token budgets. The diegosouza reference implements a sophisticated 7-mode compression pipeline (off/lite/standard/aggressive/ultra/rtk/stacked) with progressive message aging, caveman compression (semantic condensation), and rule-based tool output compression. This is a significant gap — context management is essential for cost optimization and handling large conversations.

Key gaps:
- **Context window management** — enforcing model context limits, token estimation
- **Prompt compression** — reducing token count while preserving semantics
- **Progressive aging** — older messages get progressively compressed
- **Thinking budget** — allocating reasoning tokens for thinking models (o1, Claude extended thinking)
- **Tool output truncation** — compressing verbose tool results
- **System prompt deduplication** — eliminating repeated system prompt content

## Classification Guide

- **CORE**: Context manager, token estimation, basic compression, thinking budget — essential for production use
- **EXTENDED**: Advanced compression modes, progressive aging, caveman compression — valuable optimization
- **ECOSYSTEM**: Ultra compression with external SLM, language packs for caveman compression

---

## Features

### Context Manager (1600-1609)

| # | Name | Description | Classification | Priority | Proposed EPIC |
|---|------|-------------|---------------|----------|---------------|
| 1600 | Token Estimator | Implement fast token estimation: approximate token count for messages before sending to provider; support tiktoken for OpenAI models, character-based fallback for others | CORE | P0 | EPIC-1600 (new) |
| 1601 | Context Window Enforcer | Enforce model context window limits: estimate total tokens (system + messages + tools + response reserve), reject or auto-truncate if exceeded | CORE | P0 | EPIC-1600 |
| 1602 | Response Token Reserve | Reserve tokens for response: configurable reserve (default: max_tokens or 4096), subtract from available context before checking messages | CORE | P0 | EPIC-1600 |
| 1603 | Message Truncation Strategy | Implement message truncation when context exceeded: remove oldest messages first (keep system prompt), truncate middle of long messages, keep recent N turns | CORE | P1 | EPIC-1600 |
| 1604 | Tool Result Size Limit | Limit tool result size in context: truncate verbose tool outputs to configurable max tokens, preserve structure (first/last lines + summary) | CORE | P1 | EPIC-1600 |
| 1605 | System Prompt Token Tracking | Track system prompt token usage separately: warn when system prompt consumes >25% of context window, suggest compression | CORE | P1 | EPIC-1600 |
| 1606 | Context Window Metadata | Expose context window metadata in response: `x-context-tokens-used`, `x-context-tokens-available`, `x-context-window-size` headers | EXTENDED | P2 | EPIC-1600 |
| 1607 | Context Window Selection | Select model based on context requirements: if estimated tokens exceed model context, auto-upgrade to larger context model if available in route graph | CORE | P1 | EPIC-1600 |
| 1608 | Per-Model Token Limits | Configure per-model token limits: override default context window with custom limits (e.g., limit expensive model to 4K context despite 128K capability) | EXTENDED | P2 | EPIC-1600 |
| 1609 | Context Manager Tests | Test suite for context management: token estimation accuracy, truncation strategies, context enforcement, model selection | CORE | P1 | EPIC-1600 |

### Compression Pipeline (1610-1624)

| # | Name | Description | Classification | Priority | Proposed EPIC |
|---|------|-------------|---------------|----------|---------------|
| 1610 | Compression Pipeline Framework | Implement compression pipeline: configurable compression level (off/lite/standard/aggressive), sequential stages, before-and-after token count tracking | CORE | P1 | EPIC-1610 (new) |
| 1611 | Compression Level: Off | No compression: pass messages through unchanged; default for short conversations within context window | CORE | P1 | EPIC-1610 |
| 1612 | Compression Level: Lite | Lite compression: whitespace normalization (collapse multiple spaces/newlines), trailing whitespace removal, empty message removal | CORE | P1 | EPIC-1610 |
| 1613 | System Prompt Deduplication | Deduplicate system prompt content: detect repeated system instructions across messages, consolidate into single system message | CORE | P1 | EPIC-1610 |
| 1614 | Tool Output Truncation | Truncate tool outputs: configurable max tokens per tool result, preserve JSON structure, add "[truncated N tokens]" marker | CORE | P1 | EPIC-1610 |
| 1615 | Compression Level: Standard | Standard compression: lite + system prompt dedup + tool output truncation + code block compression (collapse large outputs) | CORE | P1 | EPIC-1610 |
| 1616 | Progressive Message Aging | Implement progressive aging: older messages get more aggressively compressed; recent messages preserved fully, older messages summarized | EXTENDED | P2 | EPIC-1610 |
| 1617 | Message Summarization | Summarize older messages: use cheap/fast model to generate summary of early conversation turns; replace original messages with summary | EXTENDED | P2 | EPIC-1610 |
| 1618 | Compression Level: Aggressive | Aggressive compression: standard + progressive aging + automatic summarization of old turns + removal of redundant assistant confirmations | EXTENDED | P2 | EPIC-1610 |
| 1619 | Caveman Compression | Implement semantic condensation: rewrite messages in compressed form preserving meaning, remove filler words, shorten sentences | EXTENDED | P2 | EPIC-1610 |
| 161A | Rule-Based Tool Compression (RTK) | Implement rule-based terminal/tool output compression: detect common patterns (stack traces, log output, JSON), apply structure-aware compression | EXTENDED | P2 | EPIC-1610 |
| 161B | Code Block Compression | Compress code blocks: detect repeated/similar code blocks, dedup, collapse large outputs, preserve final version | EXTENDED | P2 | EPIC-1610 |
| 161C | Compression Metrics | Track compression metrics: tokens before/after per level, compression ratio, cost savings, latency overhead | CORE | P1 | EPIC-1610 |
| 161D | Compression Configuration | Configure compression per exposure/model/route: default level, max context percentage, excluded roles (never compress system prompts) | CORE | P1 | EPIC-1610 |
| 161E | Compression Pipeline Tests | Test suite for compression: each level, token count accuracy, semantic preservation, edge cases (empty, single message, tool-heavy) | CORE | P1 | EPIC-1610 |

### Thinking Budget (1620-1629)

| # | Name | Description | Classification | Priority | Proposed EPIC |
|---|------|-------------|---------------|----------|---------------|
| 1620 | Thinking Token Budget | Implement thinking token budget: allocate separate token budget for reasoning/thinking in models that support it (o1, Claude extended thinking) | CORE | P1 | EPIC-1620 (new) |
| 1621 | Thinking Budget Configuration | Configure thinking budget per model/exposure: max thinking tokens, thinking budget as percentage of total budget, disable thinking | CORE | P1 | EPIC-1620 |
| 1622 | Thinking Token Tracking | Track thinking token usage separately: prompt tokens, completion tokens, thinking tokens; include in cost calculation and quota | CORE | P1 | EPIC-1620 |
| 1623 | Thinking Budget Enforcement | Enforce thinking budget: set `max_thinking_tokens` or equivalent parameter per provider, cap reasoning effort | CORE | P1 | EPIC-1620 |
| 1624 | Thinking Cost Calculation | Calculate thinking token cost: some providers charge differently for thinking tokens vs output tokens; track separately | CORE | P1 | EPIC-1620 |
| 1625 | Reasoning Content Caching | Cache reasoning/thinking content: for multi-turn conversations, optionally cache and re-inject previous reasoning to reduce re-thinking | EXTENDED | P2 | EPIC-1620 |
| 1626 | Thinking Budget Auto-Adjust | Auto-adjust thinking budget based on task complexity: simple tasks get lower thinking budget, complex tasks get higher | EXTENDED | P3 | EPIC-1620 |
| 1627 | Thinking Content Visibility | Configure thinking content visibility: expose/hide thinking content in API response, audit trail always records | CORE | P1 | EPIC-1620 |
| 1628 | Provider Thinking Integration | Integrate thinking budget with each provider adapter: OpenAI o1 (`reasoning_effort`), Anthropic extended thinking (`thinking.budget_tokens`), DeepSeek (`enable_thinking`) | CORE | P1 | EPIC-1620 |
| 1629 | Thinking Budget Tests | Test suite for thinking budget: allocation, enforcement, cost calculation, multi-provider handling, caching | CORE | P1 | EPIC-1620 |

---

## Cross-References

| Gap Feature | Existing Feature | Relationship |
|-------------|-----------------|--------------|
| 1600 (Token Estimator) | 615 (Cost Estimation) | Token estimation is prerequisite for cost estimation |
| 1601 (Context Enforcer) | 324 (Model Capability Matrix) | Uses capability matrix for context window info |
| 1603 (Truncation) | 782 (Request Size Limit) | Truncation is content-level; 782 is byte-level |
| 1607 (Context Window Selection) | 1512 (Context-Optimized Router) | Context manager triggers context-optimized routing |
| 1610 (Compression) | 870-879 (Semantic Cache) | Compression reduces cache key entropy; consider compressing before caching |
| 1620 (Thinking Budget) | 725 (Anthropic Extended Thinking) | Thinking budget governs the extended thinking feature |
| 1622 (Thinking Tracking) | 810-814 (Token Quota) | Thinking tokens count toward quotas |
