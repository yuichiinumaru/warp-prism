# Feature Catalog: Policy Engine

> **Series**: 500
> **EPICs**: EPIC-500, EPIC-510, EPIC-520, EPIC-530, EPIC-540
> **Tasks**: 0216-0245
> **Total Features**: 30

## Features

### Policy DSL & Model (500-509)

| # | Name | Description | Priority |
|---|------|-------------|----------|
| 500 | Policy Domain Model | Define `Policy` entity: ID, name, version, rules, priority, status (draft/active/archived), created/updated timestamps | P0 |
| 501 | Policy Rule Model | Define `PolicyRule`: subject match (user, role, API key, service, wildcard), resource match (capability, exposure, kind), action (allow/deny/rate-limit/audit/warn), conditions | P0 |
| 502 | Policy Repository | Implement `PolicyRepository` — Create, GetByID, GetByName, Update, Archive, List, GetActiveForResource with PostgreSQL | P0 |
| 503 | Policy DSL: Subject Matchers | Implement subject matching DSL: `user:alice`, `role:admin`, `apikey:prefix_*`, `service:worker`, `*` (any) | P0 |
| 504 | Policy DSL: Resource Matchers | Implement resource matching DSL: `capability:gpt-4`, `kind:llm_model`, `exposure:/v1/chat/*`, `set:production`, `*` (any) | P0 |
| 505 | Policy DSL: Conditions | Implement policy conditions: `time_of_day`, `day_of_week`, `source_ip`, `token_count`, `cost_estimate`, `request_count`, custom attributes | P1 |
| 506 | Policy DSL: Actions | Implement policy actions: `allow`, `deny(reason)`, `rate_limit(rpm, tpd)`, `audit(level)`, `warn(message)` | P0 |
| 507 | Policy Priority & Ordering | Implement policy priority: explicit deny > explicit allow > default deny; within same decision, higher priority wins | P0 |
| 508 | Policy CRUD Use Cases | Implement `CreatePolicy`, `UpdatePolicy`, `ArchivePolicy`, `ActivatePolicy`, `ListPolicies` use cases | P0 |
| 509 | Policy Validation | Validate policy on create/update: DSL syntax, subject/resource references exist, no circular dependencies, conflict detection | P0 |

### Policy Compiler (510-519)

| # | Name | Description | Priority |
|---|------|-------------|----------|
| 510 | Policy Compiler | Implement policy compiler: parse DSL rules into optimized evaluation tree; precompute subject/resource matchers | P0 |
| 511 | Compiled Policy Snapshot | Define `PolicySnapshot`: compiled version of all active policies for a specific resource/exposure; versioned and cached | P0 |
| 512 | Snapshot Caching | Cache compiled policy snapshots in Redis with version key; local in-memory cache (LRU) with TTL | P0 |
| 513 | Snapshot Invalidation | Invalidate snapshots on policy change: outbox event triggers recompilation of affected snapshots | P0 |
| 514 | Snapshot Compilation Worker | Background worker that recompiles policy snapshots when outbox events indicate policy or resource changes | P0 |
| 515 | Compilation Error Handling | Handle compilation errors gracefully: reject invalid policy without affecting active policies; report errors via admin API | P0 |
| 516 | Policy Dry Run | Support policy dry-run: compile and evaluate without persisting; return evaluation result for testing | P1 |
| 517 | Policy Diff | Support policy diff: compare two policy versions or snapshots; show added/removed/changed rules | P1 |
| 518 | Compilation Metrics | Track compilation metrics: compilation time, snapshot size, cache hit rate, invalidation frequency | P1 |
| 519 | Policy Import/Export | Support policy import/export as JSON/YAML: for migration, backup, and cross-environment promotion | P2 |

### Policy Evaluator (520-529)

| # | Name | Description | Priority |
|---|------|-------------|----------|
| 520 | Policy Evaluator | Implement `PolicyEngine.Authorize(ctx, AuthorizationRequest) → AuthorizationDecision`: evaluate compiled snapshot against request | P0 |
| 521 | Authorization Request | Define `AuthorizationRequest`: subject, resource (capability/exposure), action, context (IP, time, metadata) | P0 |
| 522 | Authorization Decision | Define `AuthorizationDecision`: decision (allow/deny/rate-limit), reason, matched policy ID, evaluation time, audit flag | P0 |
| 523 | Deny-by-Default | Implement deny-by-default: if no policy explicitly allows, deny; explicit deny always overrides allow | P0 |
| 524 | Multi-Policy Evaluation | Evaluate multiple policies for same request: aggregate decisions, explicit deny wins, most restrictive rate limit wins | P0 |
| 525 | Evaluation Caching | Cache recent evaluation results in local memory (short TTL) for repeated identical requests | P1 |
| 526 | Evaluation Audit Trail | Log policy evaluations: request, matched rules, decision, evaluation time; configurable verbosity | P0 |
| 527 | Policy Decision Metrics | Track decision metrics: allow/deny/rate-limit counts per policy, evaluation latency, cache hit rate | P1 |
| 528 | Evaluation Error Handling | Handle evaluation errors: missing snapshot → deny with log, corrupt snapshot → recompile and deny, timeout → deny | P0 |
| 529 | Policy Hot Path Optimization | Optimize evaluator for hot path: no allocations in critical path, precomputed matchers, fast subject/resource lookup | P0 |

### Policy Snapshots & Admin (530-539)

| # | Name | Description | Priority |
|---|------|-------------|----------|
| 530 | Policy Admin Endpoints | Implement admin REST endpoints: CRUD for policies, list active policies, view compiled snapshots | P0 |
| 531 | Policy Activation Endpoint | Implement policy activation endpoint: validate, compile, cache snapshot, activate; atomic operation | P0 |
| 532 | Policy Test Endpoint | Implement policy test endpoint: submit test authorization request, return evaluation result without side effects | P1 |
| 533 | Policy History | Track policy history: version log with diffs, who changed, when, from which state | P1 |
| 534 | Policy Snapshot Inspection | Admin endpoint to inspect compiled snapshot: view evaluation tree, matched rules, resource bindings | P1 |
| 535 | Policy Conflict Detection | Detect conflicting policies: overlapping subject/resource matchers with different decisions; warn on create/update | P1 |
| 536 | Policy Templates | Pre-built policy templates: deny-all, allow-authenticated, rate-limit-by-role, audit-all, read-only | P2 |
| 537 | Policy Binding to Exposure | Bind policies to exposures: manage which policies apply to which exposures; validate on exposure creation | P0 |
| 538 | Policy Binding to CapabilitySet | Bind policies to capability sets: policies inherited by all capabilities in set | P0 |
| 539 | Policy Event Emission | Emit outbox events on policy changes: `PolicyChanged` with policy ID, action (created/updated/activated/archived) | P0 |

### External Policy Evaluator Plugins (540-545)

| # | Name | Description | Priority |
|---|------|-------------|----------|
| 540 | External Evaluator Interface | Define interface for external policy evaluator plugins: gRPC/HTTP endpoint, request/response schema, timeout | P2 |
| 541 | OPA Integration | Implement Open Policy Agent (OPA) plugin: send policy evaluation requests to OPA sidecar/service | P2 |
| 542 | External Evaluator Registration | Register external evaluators via plugin manifest: endpoint, auth, capabilities, timeout, fallback behavior | P2 |
| 543 | External Evaluator Caching | Cache external evaluator decisions: configurable TTL, cache key based on request hash | P2 |
| 544 | External Evaluator Fallback | Fallback behavior when external evaluator unavailable: deny-by-default, use cached decision, or evaluate locally | P2 |
| 545 | External Evaluator Audit | Audit external evaluator calls: request, response, latency, errors; include in execution envelope | P2 |
