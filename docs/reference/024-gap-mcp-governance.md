# Feature Catalog: Gap — MCP Governance

> **Series**: 2400
> **EPICs**: EPIC-2400 (Tool Risk Classification), EPIC-2410 (Value-Moving Gate), EPIC-2420 (Tool Design & Quality)
> **Gap Source**: cybernetics-core (tool governance, risk-level classification, family-based risk mapping, value-moving tool action gate, MCP tool design rubric)
> **Total Features**: 25

## Gap Analysis Summary

Our catalog has comprehensive MCP support (Series 900) covering protocol, transports, catalog, sandbox, and execution. However, we lack governance features specific to tool safety and risk classification from the cybernetics-core reference:

- **Tool risk classification** — classifying tools by risk level (low/medium/high/critical) based on their capabilities
- **Family-based risk mapping** — grouping tools into families with inherited risk levels
- **Value-moving tool action gate** — special policy gate for tools that move value (payments, transfers, trades)
- **Tool design rubric** — automated quality assessment for tool definitions (schema quality, naming, descriptions)
- **Runtime provider leases** — time-scoped, permission-bounded credentials for external runtimes

These features are critical for a Capability Operating System where tools can take real-world actions with financial or security implications.

## Classification Guide

- **CORE**: Tool risk classification, value-moving gate — critical for safe tool execution
- **EXTENDED**: Tool design rubric, runtime leases — quality and security enhancements
- **ECOSYSTEM**: Tool quality marketplace, automated rubric scoring

---

## Features

### Tool Risk Classification (2400-2409)

| # | Name | Description | Classification | Priority | Proposed EPIC |
|---|------|-------------|---------------|----------|---------------|
| 2400 | Tool Risk Level Model | Define `ToolRiskLevel` enum: `low` (read-only, informational), `medium` (state-changing, reversible), `high` (state-changing, irreversible), `critical` (value-moving, security-sensitive) | CORE | P1 | EPIC-2400 (new) |
| 2401 | Tool Risk Classifier | Implement tool risk classifier: analyze tool schema, name, description to auto-assign risk level; support manual override | CORE | P1 | EPIC-2400 |
| 2402 | Risk Classification Rules | Define risk classification rules: `read`/`list`/`get`/`search` → low, `create`/`update` → medium, `delete`/`execute`/`run` → high, `pay`/`transfer`/`trade` → critical | CORE | P1 | EPIC-2400 |
| 2403 | Tool Family Registry | Define tool families: group related tools (filesystem, network, database, financial, communication), assign family-level default risk | CORE | P1 | EPIC-2400 |
| 2404 | Family-Based Risk Inheritance | Inherit risk level from tool family: tools in `financial` family default to `critical`, tools in `filesystem.read` family default to `low` | CORE | P1 | EPIC-2400 |
| 2405 | Risk-Based Policy Integration | Integrate tool risk with policy engine: policies can reference risk level as condition; e.g., "deny all critical tools for viewer role" | CORE | P1 | EPIC-2400 |
| 2406 | Risk Level Admin Config | Admin endpoints for risk configuration: override auto-classified risk per tool, configure family risk defaults, view risk report | CORE | P1 | EPIC-2400 |
| 2407 | Risk Level Audit | Audit tool calls with risk context: include risk level in execution envelope, flag high/critical tool calls in audit trail | CORE | P1 | EPIC-2400 |
| 2408 | Risk Dashboard | Provide risk dashboard data: tools by risk level, high/critical call frequency, risk distribution across exposures | EXTENDED | P2 | EPIC-2400 |
| 2409 | Risk Classification Tests | Test suite for tool risk classification: auto-classification accuracy, family inheritance, policy integration, override behavior | CORE | P1 | EPIC-2400 |

### Value-Moving Gate (2410-2419)

| # | Name | Description | Classification | Priority | Proposed EPIC |
|---|------|-------------|---------------|----------|---------------|
| 2410 | Value-Moving Tool Detection | Detect value-moving tools: identify tools that transfer money, trade assets, approve transactions, or modify financial state | CORE | P1 | EPIC-2410 (new) |
| 2411 | Value-Moving Action Gate | Implement value-moving action gate: additional authorization check before executing critical/financial tools; require explicit approval | CORE | P1 | EPIC-2410 |
| 2412 | Approval Flow | Implement approval flow for value-moving actions: hold execution, notify approver (admin or designated user), wait for approval/rejection within timeout | CORE | P1 | EPIC-2410 |
| 2413 | Approval Persistence | Persist approval requests in PostgreSQL: tool call details, requester, approver, status (pending/approved/rejected/expired), timestamps | CORE | P1 | EPIC-2410 |
| 2414 | Spending Limit Gate | Implement spending limit gate: automatically approve value-moving actions below configurable threshold, require approval above | EXTENDED | P2 | EPIC-2410 |
| 2415 | Value-Moving Rate Limit | Enforce rate limits specific to value-moving tools: max transactions per minute/hour/day, separate from general rate limits | CORE | P1 | EPIC-2410 |
| 2416 | Value-Moving Audit Trail | Enhanced audit trail for value-moving actions: complete request/response, approval chain, amounts, counterparties (redacted PII) | CORE | P1 | EPIC-2410 |
| 2417 | Approval Notification | Notify approvers of pending value-moving actions: via admin SSE events, webhook, or email; include action details and timeout | EXTENDED | P2 | EPIC-2410 |
| 2418 | Auto-Approval Rules | Configurable auto-approval rules: approve if amount < threshold AND subject has role AND within business hours | EXTENDED | P2 | EPIC-2410 |
| 2419 | Value-Moving Gate Tests | Test suite for value-moving gate: detection, approval flow, spending limits, rate limits, timeout, rejection | CORE | P1 | EPIC-2410 |

### Tool Design & Quality (2420-2424)

| # | Name | Description | Classification | Priority | Proposed EPIC |
|---|------|-------------|---------------|----------|---------------|
| 2420 | Tool Design Rubric | Implement automated tool design rubric: evaluate tool definitions against quality criteria (description quality, schema completeness, parameter naming, documentation) | EXTENDED | P2 | EPIC-2420 (new) |
| 2421 | Rubric Scoring | Score tool definitions: 0-100 quality score based on: description length (>20 chars), parameter descriptions present, return schema defined, examples provided, naming conventions | EXTENDED | P2 | EPIC-2420 |
| 2422 | Rubric Enforcement | Optional rubric enforcement: reject tool registration below minimum quality score (configurable threshold, default 50) | EXTENDED | P2 | EPIC-2420 |
| 2423 | Tool Quality Report | Generate tool quality report: per-server quality scores, worst-scoring tools, improvement suggestions | EXTENDED | P3 | EPIC-2420 |
| 2424 | Runtime Provider Leases | Implement runtime provider leases: time-scoped, permission-bounded credentials issued to external runtimes (MCP servers, plugins); narrower than general credential leases | EXTENDED | P2 | EPIC-2420 |

---

## Cross-References

| Gap Feature | Existing Feature | Relationship |
|-------------|-----------------|--------------|
| 2400 (Risk Level) | 329 (Tool Status Tracking) | Risk level complements health-based tool status |
| 2401 (Risk Classifier) | 327 (Tool Schema Validation) | Risk classifier analyzes same schemas that validation checks |
| 2405 (Risk-Policy) | 501 (Policy Rule Model) | Risk level becomes a new condition type in policy DSL |
| 2410 (Value-Moving) | 1720 (Tool Calling Policy) | Value-moving gate is specialized tool policy for financial tools |
| 2412 (Approval Flow) | 1220 (Plugin Approval) | Similar approval pattern; tool-level vs plugin-level |
| 2415 (Value Rate Limit) | 800-809 (Rate Limiting) | Specialized rate limits for financial tool calls |
| 2416 (Value Audit) | 830-839 (Audit Event Store) | Enhanced audit records for financial operations |
| 2420 (Design Rubric) | 962 (Manifest Validation) | Rubric is quality assessment; manifest validation is correctness |
| 2424 (Runtime Leases) | 430-439 (Credential Broker) | Extends broker with runtime-scoped, narrower leases |
