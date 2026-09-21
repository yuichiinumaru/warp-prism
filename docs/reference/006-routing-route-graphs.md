# Feature Catalog: Routing & Route Graphs

> **Series**: 600
> **EPICs**: EPIC-600, EPIC-610, EPIC-620, EPIC-630, EPIC-640, EPIC-650, EPIC-660, EPIC-670
> **Tasks**: 0246-0290
> **Total Features**: 45

## Features

### Route Graph Model (600-609)

| # | Name | Description | Priority |
|---|------|-------------|----------|
| 600 | RouteGraph Repository | Implement `RouteGraphRepository` — Create, GetByID, GetByName, Update, Delete, List with PostgreSQL; store as JSONB | P0 |
| 601 | Route Node Serialization | Implement JSON serialization/deserialization for all route node types with discriminator field `type` | P0 |
| 602 | RouteGraph Validation | Validate route graph structure: DAG (no cycles), all referenced capabilities exist, node types valid, terminal nodes reachable | P0 |
| 603 | RouteGraph CRUD Use Cases | Implement `CreateRouteGraph`, `UpdateRouteGraph`, `DeleteRouteGraph`, `ListRouteGraphs` use cases | P0 |
| 604 | RouteGraph Versioning | Support route graph versioning: version on each update, query specific version, rollback to previous version | P1 |
| 605 | RouteGraph Status Lifecycle | Implement status transitions: `draft` → `active` → `deprecated` → `removed`; only one active version per name | P0 |
| 606 | RouteGraph Admin Endpoints | Implement admin REST endpoints for route graph management: CRUD, activate, deprecate, view graph structure | P0 |
| 607 | RouteGraph Visualization | Implement route graph DOT format export for visualization: nodes, edges, labels, capability names | P2 |
| 608 | RouteGraph Event Emission | Emit outbox events on route graph changes: `RouteGraphChanged` with graph ID, action, trigger descriptor recompilation | P0 |
| 609 | RouteGraph Templates | Pre-built route graph templates: simple primary, primary+fallback, weighted load balance, tiered (fast cheap → slow quality) | P2 |

### Workload Classifier (610-619)

| # | Name | Description | Priority |
|---|------|-------------|----------|
| 610 | Workload Classification | Implement workload classifier: inspect incoming request, determine workload kind, extract routing-relevant attributes | P0 |
| 611 | Chat Completion Classification | Classify chat completion requests: model, token estimate, streaming flag, tool use, system prompt length | P0 |
| 612 | Embedding Classification | Classify embedding requests: model, input count, total token estimate, dimensions | P1 |
| 613 | Tool Call Classification | Classify tool call requests: tool name, namespace, input size, expected output size | P0 |
| 614 | Search Classification | Classify search requests: query type, result count, provider preference, freshness requirement | P1 |
| 615 | Cost Estimation | Estimate request cost based on workload classification: token count × model pricing, used for budget enforcement | P0 |
| 616 | Priority Classification | Assign request priority based on workload attributes and subject: critical > high > normal > low > background | P1 |
| 617 | Workload Fingerprinting | Generate workload fingerprint for idempotency: hash of model + messages + parameters for deduplication | P1 |
| 618 | Classification Caching | Cache classification results for identical requests within short window (deduplication support) | P1 |
| 619 | Custom Classifier Rules | Support custom classification rules: regex on model name, header-based routing, metadata-based classification | P2 |

### Plan Builder & Scorer (620-629)

| # | Name | Description | Priority |
|---|------|-------------|----------|
| 620 | Plan Builder | Implement `Planner.Plan()`: given workload + route graph + policies, build ordered `ExecutionPlan` with steps, leases, constraints | P0 |
| 621 | Capability Scoring | Score capabilities for a workload: availability, latency p50, error rate, cost, capacity, priority, health | P0 |
| 622 | Plan Step Generation | Generate execution steps from route graph: resolve nodes to concrete capabilities, order by graph topology | P0 |
| 623 | Credential Lease Planning | Determine credential leases needed for each plan step: match capability to grants, plan acquisition order | P0 |
| 624 | Policy Constraint Application | Apply policy constraints to plan: remove denied capabilities, apply rate limits, add audit requirements | P0 |
| 625 | Plan Cost Estimation | Estimate total plan cost: sum of step costs based on workload classification and model pricing | P0 |
| 626 | Plan Validation | Validate execution plan: at least one viable step, all credentials available, budget not exceeded | P0 |
| 627 | Plan Caching | Cache execution plans for identical workload+graph combinations with short TTL; invalidate on graph/policy change | P1 |
| 628 | Plan Explanation | Generate human-readable plan explanation: why each capability was selected, scoring breakdown, alternatives considered | P1 |
| 629 | Multi-Model Planning | Support plans that span multiple models: e.g., cheap model for classification → expensive model for generation | P2 |

### Load Balancing (630-639)

| # | Name | Description | Priority |
|---|------|-------------|----------|
| 630 | Weighted Round-Robin | Implement weighted round-robin load balancing across capabilities: respect configured weights, track position in Redis | P0 |
| 631 | Least Connections | Implement least-connections load balancing: route to capability with fewest active leases/requests | P0 |
| 632 | Least Latency | Implement least-latency load balancing: route to capability with lowest p50 latency (sliding window) | P1 |
| 633 | Random Weighted | Implement random weighted selection: probabilistic distribution based on weights | P0 |
| 634 | Hash-Based Affinity | Implement hash-based affinity: route same user/session to same capability for consistency | P1 |
| 635 | Capacity-Aware Balancing | Factor remaining quota/rate-limit headroom into balancing decisions: prefer capabilities with more capacity | P0 |
| 636 | Cost-Aware Balancing | Factor cost into balancing decisions: prefer cheaper capabilities when quality is equivalent | P1 |
| 637 | Health-Weighted Balancing | Down-weight unhealthy capabilities: reduce weight based on error rate, increase on recovery | P0 |
| 638 | Balancing State in Redis | Store balancing state (positions, counters, weights) in Redis: shared across API instances | P0 |
| 639 | Balancing Metrics | Track balancing metrics: distribution across capabilities, fairness score, rebalancing events | P1 |

### Circuit Breaker (640-649)

| # | Name | Description | Priority |
|---|------|-------------|----------|
| 640 | Circuit Breaker State Machine | Implement circuit breaker: closed → open → half-open states per capability/provider | P0 |
| 641 | Failure Threshold | Configure failure threshold: trip circuit after N consecutive failures or error rate > X% in window | P0 |
| 642 | Open Duration | Configure open duration: how long circuit stays open before transitioning to half-open | P0 |
| 643 | Half-Open Probe | Implement half-open state: allow limited probe requests, close circuit on success, re-open on failure | P0 |
| 644 | Circuit State in Redis | Store circuit breaker state in Redis: shared across API instances, atomic state transitions via Lua scripts | P0 |
| 645 | Circuit Breaker Events | Emit events on circuit state changes: opened (with reason), half-opened, closed, probing | P0 |
| 646 | Circuit Breaker Metrics | Track circuit metrics: state transitions, time in each state, probe success rate, trip frequency | P1 |
| 647 | Per-Provider Circuits | Separate circuit breakers per provider: one provider failure doesn't affect others | P0 |
| 648 | Per-Capability Circuits | Optional per-capability circuit breakers: finer-grained than per-provider for multi-model providers | P1 |
| 649 | Manual Circuit Control | Admin API to manually open/close circuits: force-open for maintenance, force-close to retry | P1 |

### Fallback & Hedging (650-659)

| # | Name | Description | Priority |
|---|------|-------------|----------|
| 650 | Ordered Fallback | Implement ordered fallback: on primary failure, try next capability in sequence; configurable failure criteria | P0 |
| 651 | Fallback Criteria | Define fallback criteria: HTTP 5xx, timeout, circuit open, rate limited, specific error codes | P0 |
| 652 | Fallback Depth Limit | Configurable max fallback depth: prevent infinite fallback chains, fail after N attempts | P0 |
| 653 | Fallback Latency Budget | Enforce total latency budget across fallback chain: fail if remaining budget insufficient for next attempt | P0 |
| 654 | Hedging: Parallel Execution | Implement hedging: send request to N capabilities in parallel, return first successful response, cancel others | P1 |
| 655 | Hedging: Staggered Start | Implement staggered hedging: start primary, if no response within delay, start secondary in parallel | P1 |
| 656 | Hedging Cost Control | Limit hedging cost: max parallel branches, cancel on first success, track duplicated cost in metrics | P1 |
| 657 | Retry with Backoff | Implement retry with exponential backoff and jitter: configurable max retries, initial delay, max delay | P0 |
| 658 | Retry Budget | Implement retry budget: max retry percentage per time window to prevent retry storms | P0 |
| 659 | Fallback/Retry Metrics | Track fallback/retry metrics: fallback frequency per capability, retry count distribution, success-after-fallback rate | P0 |

### Route Simulation (660-669)

| # | Name | Description | Priority |
|---|------|-------------|----------|
| 660 | Route Simulator | Implement route simulation: given a workload, simulate plan building and execution without making real API calls | P1 |
| 661 | Simulation Request | Define simulation request: workload description, route graph ID (or inline), mock provider states (health, latency, error rate) | P1 |
| 662 | Simulation Response | Define simulation response: execution plan, capability selection reasoning, estimated cost, fallback path, circuit breaker states | P1 |
| 663 | Simulation Admin Endpoint | Implement admin endpoint for route simulation: POST with workload and optional overrides, return simulation result | P1 |
| 664 | What-If Analysis | Support what-if analysis: simulate with modified route graph, policy, or provider health; compare results | P2 |
| 665 | Simulation Batch | Support batch simulation: run multiple workloads through same route graph, aggregate statistics | P2 |
| 666 | Simulation Replay | Simulate replay of historical workloads through new route graph: validate routing changes before activation | P2 |
| 667 | Simulation Metrics | Track simulation usage: frequency, average complexity, most-tested route graphs | P2 |
| 668 | Simulation Caching | Cache simulation results for identical inputs with short TTL | P2 |
| 669 | Simulation Comparison | Compare simulation results side-by-side: old vs new route graph, different policies, different provider states | P2 |

### Pluggable Route Strategy (670-675)

| # | Name | Description | Priority |
|---|------|-------------|----------|
| 670 | Route Strategy Interface | Define `RouteStrategy` interface: `Select(ctx, candidates, workload) → ranked candidates` for pluggable selection logic | P1 |
| 671 | Built-in Strategies | Implement built-in strategies: cost-optimized, latency-optimized, quality-optimized, balanced | P1 |
| 672 | Strategy Registration | Register strategies in composition root; select by name in route graph node configuration | P1 |
| 673 | Custom Strategy Plugin | Support external strategy plugins via gRPC/HTTP: register endpoint, call for selection decisions | P2 |
| 674 | Strategy A/B Testing | Support A/B testing of strategies: split traffic between strategies, compare metrics | P2 |
| 675 | Strategy Metrics | Track per-strategy metrics: selection distribution, cost, latency, error rate; compare across strategies | P2 |
