# Feature Catalog: Gap — Workflow Orchestration

> **Series**: 2300
> **EPICs**: EPIC-2300 (Workflow Engine), EPIC-2310 (Hooks System), EPIC-2320 (Payload Rules)
> **Gap Source**: diegosouza-omniroute (workflow FSM, payload rules, config hot-reload), cybernetics-core (hooks system, workflow registry, DAG orchestrator)
> **Total Features**: 30

## Gap Analysis Summary

Our catalog defines `KindWorkflow` capability type (129, P2) and references composite workflow capabilities, but lacks any actual workflow or orchestration implementation. The reference repos provide:

- **Workflow FSM** (diegosouza) — multi-step workflow state machine for complex request pipelines
- **Hooks System** (cybernetics-core) — registry of hooks with condition evaluation, BullMQ processing, and execution history
- **Workflow Registry** (cybernetics-core) — YAML workflow definitions, DAG orchestrator, retry policies
- **Payload Rules** (diegosouza) — hot-reloadable JSON rules per model/protocol for request/response transformation

These enable building complex multi-step workflows where a single request triggers a chain of LLM calls, tool executions, conditional branches, and data transformations.

## Classification Guide

- **CORE**: Hooks system (pre/post request hooks), payload rules — essential for request customization
- **EXTENDED**: Workflow engine, DAG orchestrator — valuable for complex pipelines
- **ECOSYSTEM**: Workflow marketplace, visual workflow editor

---

## Features

### Workflow Engine (2300-2309)

| # | Name | Description | Classification | Priority | Proposed EPIC |
|---|------|-------------|---------------|----------|---------------|
| 2300 | Workflow Definition Model | Define `WorkflowDefinition` entity: ID, name, version, steps (ordered), triggers, retry policy, timeout, status, YAML source | EXTENDED | P2 | EPIC-2300 (new) |
| 2301 | Workflow Step Types | Define workflow step types: `llm_call` (invoke model), `tool_call` (invoke MCP tool), `condition` (branch on result), `transform` (map data), `parallel` (fan-out), `wait` (delay/poll) | EXTENDED | P2 | EPIC-2300 |
| 2302 | Workflow DAG Orchestrator | Implement DAG-based workflow orchestrator: parse workflow definition into execution DAG, topologically sort steps, respect dependencies, execute in order | EXTENDED | P2 | EPIC-2300 |
| 2303 | Workflow State Machine | Implement workflow FSM: track workflow execution state (`created` → `running` → `completed`/`failed`/`cancelled`), persist state for resumability | EXTENDED | P2 | EPIC-2300 |
| 2304 | Workflow Step Execution | Execute individual workflow steps: dispatch to appropriate executor (LLM, tool, transform), pass input from previous step, collect output | EXTENDED | P2 | EPIC-2300 |
| 2305 | Workflow Data Flow | Implement data flow between steps: output of step N becomes input of step N+1, support JSONPath expressions for field selection, template interpolation | EXTENDED | P2 | EPIC-2300 |
| 2306 | Workflow Retry Policy | Implement per-step retry policy: max retries, backoff strategy, retryable error classes, retry budget | EXTENDED | P2 | EPIC-2300 |
| 2307 | Workflow Timeout | Enforce per-step and total workflow timeout: cancel long-running steps, fail workflow on total timeout exceeded | EXTENDED | P2 | EPIC-2300 |
| 2308 | Workflow Repository | Implement `WorkflowRepository` — store workflow definitions and execution state in PostgreSQL: definition (YAML/JSON), instances, step results | EXTENDED | P2 | EPIC-2300 |
| 2309 | Workflow Admin Endpoints | Admin endpoints for workflow management: create/update/list/delete definitions, view executions, inspect step results, cancel running workflows | EXTENDED | P2 | EPIC-2300 |

### Hooks System (2310-2319)

| # | Name | Description | Classification | Priority | Proposed EPIC |
|---|------|-------------|---------------|----------|---------------|
| 2310 | Hook Definition Model | Define `Hook` entity: ID, name, trigger point (pre-request, post-request, pre-response, post-response, on-error), conditions, actions, priority, enabled | CORE | P1 | EPIC-2310 (new) |
| 2311 | Hook Registry | Implement hook registry: register hooks with trigger points, sort by priority, enable/disable per hook | CORE | P1 | EPIC-2310 |
| 2312 | Hook Trigger Points | Define hook trigger points: `pre_request` (before processing), `post_request` (before sending to provider), `pre_response` (before returning), `post_response` (after returning), `on_error` | CORE | P1 | EPIC-2310 |
| 2313 | Hook Condition Evaluator | Implement hook condition evaluator: evaluate conditions against request context (model, subject, exposure, headers, parameters) to determine if hook fires | CORE | P1 | EPIC-2310 |
| 2314 | Hook Actions | Implement hook actions: `modify_request` (transform request), `modify_response` (transform response), `inject_header`, `set_parameter`, `log`, `reject`, `add_metadata` | CORE | P1 | EPIC-2310 |
| 2315 | Hook Execution Pipeline | Implement hook execution pipeline: for each trigger point, evaluate conditions, execute matching hooks in priority order, pass modified context to next hook | CORE | P1 | EPIC-2310 |
| 2316 | Hook Repository | Implement `HookRepository` — store hook definitions in PostgreSQL: trigger, conditions, actions, priority, status | CORE | P1 | EPIC-2310 |
| 2317 | Hook Execution History | Track hook execution history: which hooks fired, conditions matched, actions taken, timing, errors; queryable via admin API | EXTENDED | P2 | EPIC-2310 |
| 2318 | Hook Admin Endpoints | Admin endpoints for hook management: create/update/delete hooks, list by trigger point, enable/disable, test hook evaluation | CORE | P1 | EPIC-2310 |
| 2319 | Hook System Tests | Test suite for hooks: condition evaluation, action execution, priority ordering, pipeline, error handling | CORE | P1 | EPIC-2310 |

### Payload Rules & Hot Config (2320-2329)

| # | Name | Description | Classification | Priority | Proposed EPIC |
|---|------|-------------|---------------|----------|---------------|
| 2320 | Payload Rule Model | Define `PayloadRule` entity: ID, name, match criteria (model pattern, protocol, endpoint), transformations, priority, enabled | CORE | P1 | EPIC-2320 (new) |
| 2321 | Payload Rule Engine | Implement payload rule engine: match incoming requests against rules, apply transformations, support both request and response transforms | CORE | P1 | EPIC-2320 |
| 2322 | Request Transformation | Implement request transformations: add/remove/modify parameters, set defaults, enforce constraints, inject headers; configurable per model/endpoint | CORE | P1 | EPIC-2320 |
| 2323 | Response Transformation | Implement response transformations: modify response structure, add metadata, strip fields, rename keys; configurable per model/endpoint | CORE | P1 | EPIC-2320 |
| 2324 | Payload Rule Hot-Reload | Hot-reload payload rules: detect changes without restart, poll config source on configurable interval (default 5s), atomic swap | CORE | P1 | EPIC-2320 |
| 2325 | Model-Specific Defaults | Configure per-model default parameters: temperature, max_tokens, top_p, frequency_penalty; applied when request doesn't specify | CORE | P1 | EPIC-2320 |
| 2326 | Tier Configuration | Implement model tier configuration: define tiers (fast, balanced, quality, economy), assign models to tiers, allow requests by tier name | EXTENDED | P2 | EPIC-2320 |
| 2327 | Config Hot-Reload Framework | Implement general config hot-reload framework: watch config sources (file, database, Redis), detect changes, notify subscribers, atomic update | CORE | P1 | EPIC-2320 |
| 2328 | Payload Rule Admin | Admin endpoints for payload rule management: create/update/delete rules, test rule matching, view rule priority order | CORE | P1 | EPIC-2320 |
| 2329 | Payload Rule Tests | Test suite for payload rules: matching, transformation, hot-reload, model defaults, tier configuration | CORE | P1 | EPIC-2320 |

---

## Cross-References

| Gap Feature | Existing Feature | Relationship |
|-------------|-----------------|--------------|
| 2300 (Workflow Model) | 129 (KindWorkflow) | Implements the workflow capability kind |
| 2302 (DAG Orchestrator) | 602 (RouteGraph DAG) | Similar DAG concepts; workflow DAG is multi-step, route graph is routing |
| 2304 (Step Execution) | 750-752 (Execution Engine) | Workflow steps use execution engine for LLM/tool calls |
| 2310-2315 (Hooks) | 760 (Gateway Handler) | Hooks integrate into gateway handler pipeline |
| 2313 (Hook Conditions) | 505 (Policy Conditions) | Similar condition evaluation; hooks for transformation, policy for access |
| 2320-2323 (Payload Rules) | 147 (RouteNodeTransform) | Payload rules are request-level transforms; route node transform is graph-level |
| 2325 (Model Defaults) | 701 (Provider Config) | Model defaults complement provider config at request level |
| 2327 (Hot-Reload) | 115 (YAML Override) | Hot-reload extends static config with runtime updates |
