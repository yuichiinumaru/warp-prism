# Feature Catalog: Gap — Guardrails & Safety

> **Series**: 1700
> **EPICs**: EPIC-1700 (Prompt Injection Guard), EPIC-1710 (PII Protection), EPIC-1720 (Tool Calling Policy), EPIC-1730 (Vision Bridge), EPIC-1740 (Response Safety)
> **Gap Source**: diegosouza-omniroute (prompt injection guard, PII masker/sanitizer, vision bridge, tool calling policy, response sanitizer)
> **Total Features**: 35

## Gap Analysis Summary

Our catalog defines a `Guardrail` domain type (15D), a `GuardrailEvaluator` interface (168), and plugin-based guardrails (1250-1254) including content filter, PII detection, and injection detection. However, the existing features are primarily at the plugin/interface level and lack:

- **Concrete prompt injection detection** with multiple modes (warn/block/redact)
- **PII masking/sanitizer** for both input AND output with pattern-specific handling
- **Vision bridge** — bridging image inputs for non-vision providers
- **Tool calling policy** — allowlist/denylist/disabled per exposure/model
- **Response sanitizer** — post-call output sanitization pipeline
- **Guardrail metrics and audit** — detailed tracking of guardrail decisions

The diegosouza reference has production-level implementations of these features, not just interfaces.

## Classification Guide

- **CORE**: Prompt injection guard, PII protection, tool calling policy — critical for security
- **EXTENDED**: Vision bridge, response sanitizer, advanced PII techniques
- **ECOSYSTEM**: Custom guardrail marketplace

---

## Features

### Prompt Injection Guard (1700-1709)

| # | Name | Description | Classification | Priority | Proposed EPIC |
|---|------|-------------|---------------|----------|---------------|
| 1700 | Injection Detection Engine | Implement prompt injection detection: pattern matching against known injection techniques, scoring system, confidence threshold | CORE | P1 | EPIC-1700 (new) |
| 1701 | Injection Detection Patterns | Maintain injection pattern database: system prompt override attempts, role confusion, instruction ignoring, delimiter injection, encoding attacks | CORE | P1 | EPIC-1700 |
| 1702 | Injection Mode: Warn | Warn mode: detect potential injection, log warning, add `x-injection-warning` header, allow request through | CORE | P1 | EPIC-1700 |
| 1703 | Injection Mode: Block | Block mode: detect injection above threshold, reject request with 400 error, log blocked attempt with details | CORE | P1 | EPIC-1700 |
| 1704 | Injection Mode: Redact | Redact mode: detect injection patterns, sanitize/redact suspicious portions, forward cleaned request | EXTENDED | P2 | EPIC-1700 |
| 1705 | Injection Scoring | Score injection likelihood: 0.0-1.0 confidence score, configurable threshold per exposure, log all scores above warning level | CORE | P1 | EPIC-1700 |
| 1706 | Injection Configuration | Configure injection guard per exposure/model: mode (off/warn/block/redact), threshold, custom patterns, bypass for trusted subjects | CORE | P1 | EPIC-1700 |
| 1707 | Injection Audit Trail | Log injection detection events: input sample (redacted), score, patterns matched, mode, action taken, subject | CORE | P1 | EPIC-1700 |
| 1708 | Injection Bypass for Admins | Allow trusted subjects (admin role, specific API keys) to bypass injection detection; logged but not blocked | CORE | P1 | EPIC-1700 |
| 1709 | Injection Detection Tests | Test suite for injection detection: known injection patterns, false positive rates, scoring accuracy, mode behavior | CORE | P1 | EPIC-1700 |

### PII Protection (1710-1719)

| # | Name | Description | Classification | Priority | Proposed EPIC |
|---|------|-------------|---------------|----------|---------------|
| 1710 | PII Scanner Engine | Implement PII scanning engine: detect PII patterns in both input (user messages) and output (model responses) | CORE | P1 | EPIC-1710 (new) |
| 1711 | PII Pattern: Email | Detect email addresses: RFC 5322 compliant regex, handle obfuscation attempts (at→@, dot→.) | CORE | P1 | EPIC-1710 |
| 1712 | PII Pattern: Phone | Detect phone numbers: international formats, US/EU/APAC patterns, with/without country codes | CORE | P1 | EPIC-1710 |
| 1713 | PII Pattern: SSN | Detect Social Security Numbers: XXX-XX-XXXX format, partial SSN detection, similar patterns from other countries | CORE | P1 | EPIC-1710 |
| 1714 | PII Pattern: Credit Card | Detect credit card numbers: Luhn validation, major card formats (Visa, MasterCard, Amex, Discover), partial card detection | CORE | P1 | EPIC-1710 |
| 1715 | PII Mode: Block | Block mode: detect PII, reject request/response with error indicating PII detected (without echoing the PII) | CORE | P1 | EPIC-1710 |
| 1716 | PII Mode: Redact | Redact mode: replace detected PII with type-specific placeholders (`[EMAIL_REDACTED]`, `[PHONE_REDACTED]`, `[SSN_REDACTED]`); forward cleaned content | CORE | P1 | EPIC-1710 |
| 1717 | PII Mode: Warn | Warn mode: detect PII, log warning, add header, allow through; useful for monitoring before enforcing | CORE | P1 | EPIC-1710 |
| 1718 | PII Input vs Output | Apply PII detection to both input (user → model) and output (model → user): configurable per direction | CORE | P1 | EPIC-1710 |
| 1719 | PII Configuration | Configure PII protection per exposure: mode (off/warn/block/redact), which PII types to detect, direction (input/output/both) | CORE | P1 | EPIC-1710 |

### Tool Calling Policy (1720-1729)

| # | Name | Description | Classification | Priority | Proposed EPIC |
|---|------|-------------|---------------|----------|---------------|
| 1720 | Tool Calling Policy Engine | Implement tool calling policy: control which tools a model can call per exposure/subject; allowlist, denylist, or disabled | CORE | P1 | EPIC-1720 (new) |
| 1721 | Tool Allowlist | Implement tool allowlist: only explicitly listed tools are available to the model; all others stripped from request | CORE | P1 | EPIC-1720 |
| 1722 | Tool Denylist | Implement tool denylist: explicitly blocked tools are stripped from request; all others allowed | CORE | P1 | EPIC-1720 |
| 1723 | Tool Calling Disabled | Support disabling tool calling entirely per exposure: strip `tools` and `tool_choice` from requests | CORE | P1 | EPIC-1720 |
| 1724 | Tool Policy Per Subject | Per-subject tool policies: different subjects may have access to different tool sets for the same exposure | CORE | P1 | EPIC-1720 |
| 1725 | Tool Call Validation | Validate tool calls in model responses against policy: reject responses containing calls to disallowed tools | CORE | P1 | EPIC-1720 |
| 1726 | Tool Usage Limits | Per-tool usage limits: max calls per request, max calls per minute, max concurrent tool executions | EXTENDED | P2 | EPIC-1720 |
| 1727 | Tool Call Audit | Audit all tool calls: which tools called, by which model, for which subject, arguments (redacted if sensitive), results (redacted) | CORE | P1 | EPIC-1720 |
| 1728 | Tool Policy Admin | Admin endpoints for tool calling policy management: create/update/delete policies, assign to exposures/subjects | CORE | P1 | EPIC-1720 |
| 1729 | Tool Policy Tests | Test suite for tool calling policy: allowlist filtering, denylist filtering, disabled mode, per-subject policies | CORE | P1 | EPIC-1720 |

### Vision Bridge (1730-1734)

| # | Name | Description | Classification | Priority | Proposed EPIC |
|---|------|-------------|---------------|----------|---------------|
| 1730 | Vision Bridge | Implement vision bridge: automatically handle image inputs when routing to non-vision models; extract text description, convert, or strip images | EXTENDED | P2 | EPIC-1730 (new) |
| 1731 | Image Content Detection | Detect image content in messages: base64 encoded images, image URLs, multipart content with images | EXTENDED | P2 | EPIC-1730 |
| 1732 | Vision-to-Text Fallback | When routing to non-vision model: optionally describe images using a vision model first, inject description as text, then route to target model | EXTENDED | P2 | EPIC-1730 |
| 1733 | Image Stripping | Simple image stripping: remove image content from messages before forwarding to non-vision models; add note "[image removed]" | EXTENDED | P2 | EPIC-1730 |
| 1734 | Vision Capability Check | Check model vision capability before routing: use model capability matrix to determine if model supports image input | EXTENDED | P2 | EPIC-1730 |

### Response Safety (1740-1745)

| # | Name | Description | Classification | Priority | Proposed EPIC |
|---|------|-------------|---------------|----------|---------------|
| 1740 | Response Sanitizer Pipeline | Implement response sanitizer pipeline: post-processing pipeline that runs on model output before returning to user | CORE | P1 | EPIC-1740 (new) |
| 1741 | Response PII Scan | Scan model responses for PII leakage: detect PII patterns in output, apply configured action (block/redact/warn) | CORE | P1 | EPIC-1740 |
| 1742 | Response Injection Check | Check model responses for embedded prompt injections: detect attempts to inject instructions via model output | EXTENDED | P2 | EPIC-1740 |
| 1743 | Response Content Filter | Filter model response content: configurable keyword/regex/category filters on output, block toxic/harmful content | CORE | P1 | EPIC-1740 |
| 1744 | Response Sanitizer Configuration | Configure response sanitizer per exposure: which checks to run, mode per check, ordering, bypass rules | CORE | P1 | EPIC-1740 |
| 1745 | Response Safety Metrics | Track response safety metrics: PII detection rate in output, content filter trigger rate, injection attempts in output | CORE | P1 | EPIC-1740 |

---

## Cross-References

| Gap Feature | Existing Feature | Relationship |
|-------------|-----------------|--------------|
| 1700 (Injection Detection) | 1253 (Injection Detection Plugin) | 015 gap is concrete implementation; 1253 is plugin interface |
| 1710 (PII Scanner) | 1252 (PII Detection Plugin) | 016 gap is concrete implementation; 1252 is plugin interface |
| 1720 (Tool Policy) | 501 (Policy Rule Model) | Tool policy extends policy engine with tool-specific rules |
| 1725 (Tool Call Validation) | 713, 723 (Function Calling) | Validates tool calls produced by provider adapters |
| 1730 (Vision Bridge) | 715, 724 (Vision Support) | Vision bridge handles routing when vision isn't available on target |
| 1740 (Response Sanitizer) | 168 (Guardrail Evaluator) | Response sanitizer is output-side guardrail evaluation |
| 1741 (Response PII) | 451 (Response Redaction) | Extends response redaction from secrets to PII |
