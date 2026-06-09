# Feature Catalog: Gap — A2A Agent Protocol

> **Series**: 2200
> **EPICs**: EPIC-2200 (A2A Protocol Core), EPIC-2210 (Agent Cards & Skills), EPIC-2220 (A2A Task Management)
> **Gap Source**: diegosouza-omniroute (A2A protocol, JSON-RPC 2.0, task manager, agent card, skills), cybernetics-core (agent profiles registry, skills registry)
> **Total Features**: 30

## Gap Analysis Summary

Our catalog defines A2A-related domain types (`ExposureKindA2ASurface` at 135, P2) and A2A surface exposure config (343, P2) but lacks the actual A2A protocol implementation. The diegosouza reference has a working A2A implementation with JSON-RPC 2.0, task management, and agent cards. The cybernetics-core reference adds agent profiles with ratings, reviews, cloning, and favorites, plus a skills registry with discovery marketplace.

A2A (Agent-to-Agent) protocol is Google's open standard for agent interoperability. As a Capability Operating System, supporting A2A enables our system to act as both an A2A server (exposing capabilities as agent skills) and A2A client (consuming external agents).

## Classification Guide

- **CORE**: A2A protocol types, agent cards, basic task management — needed for agent interop
- **EXTENDED**: Skills registry, agent profiles, advanced task management
- **ECOSYSTEM**: Agent marketplace, ratings/reviews

---

## Features

### A2A Protocol Core (2200-2209)

| # | Name | Description | Classification | Priority | Proposed EPIC |
|---|------|-------------|---------------|----------|---------------|
| 2200 | A2A Protocol Types | Define A2A protocol types per Google spec: `AgentCard`, `Skill`, `Task`, `TaskStatus`, `Message`, `Part` (text, file, data), `Artifact` | CORE | P2 | EPIC-2200 (new) |
| 2201 | A2A JSON-RPC Transport | Implement A2A JSON-RPC 2.0 transport: `tasks/send`, `tasks/get`, `tasks/cancel`, `tasks/list` methods; request/response/notification envelope | CORE | P2 | EPIC-2200 |
| 2202 | A2A Server Handler | Implement A2A server endpoint: handle incoming A2A requests, authenticate, route to internal capabilities, return results | CORE | P2 | EPIC-2200 |
| 2203 | A2A Client | Implement A2A client: discover external agent cards, send tasks to remote agents, poll for results, handle streaming | CORE | P2 | EPIC-2200 |
| 2204 | A2A Authentication | Implement A2A authentication: API key, OAuth 2.0, bearer token for both client and server roles; per-agent auth configuration | CORE | P2 | EPIC-2200 |
| 2205 | A2A Streaming | Implement A2A streaming: SSE-based streaming for task execution progress, partial results, status updates | CORE | P2 | EPIC-2200 |
| 2206 | A2A Error Handling | Implement A2A error handling: JSON-RPC error codes, task failure status, retry-after hints, error categorization | CORE | P2 | EPIC-2200 |
| 2207 | A2A Capability Mapping | Map internal capabilities to A2A skills: expose CapabilitySets as A2A skills, map policies to A2A auth requirements | CORE | P2 | EPIC-2200 |
| 2208 | A2A Exposure Integration | Integrate A2A with exposure system: A2A surface exposures (343) route through policy engine, credential broker, audit | CORE | P2 | EPIC-2200 |
| 2209 | A2A Protocol Tests | Test suite for A2A protocol: JSON-RPC compliance, task lifecycle, streaming, auth, error handling | CORE | P2 | EPIC-2200 |

### Agent Cards & Skills (2210-2219)

| # | Name | Description | Classification | Priority | Proposed EPIC |
|---|------|-------------|---------------|----------|---------------|
| 2210 | Agent Card Generation | Generate agent card from configuration: name, description, version, URL, supported skills, auth requirements, provider info | CORE | P2 | EPIC-2210 (new) |
| 2211 | Agent Card Schema | Define agent card JSON schema per A2A spec: name, description, URL, version, authentication, capabilities (skills), provider metadata | CORE | P2 | EPIC-2210 |
| 2212 | Agent Card Discovery | Serve agent card at well-known URL (`/.well-known/agent.json`): auto-generated from registered capabilities and exposures | CORE | P2 | EPIC-2210 |
| 2213 | Skill Declaration | Declare skills (A2A equivalent of capabilities): name, description, input/output schema, supported modalities (text, file, data) | CORE | P2 | EPIC-2210 |
| 2214 | Skill-to-Capability Mapping | Map internal capabilities to A2A skills: LLM models → chat skill, MCP tools → tool skills, search → search skill | CORE | P2 | EPIC-2210 |
| 2215 | External Agent Registry | Register external A2A agents: store agent card URLs, periodically refresh cards, track health and availability | EXTENDED | P2 | EPIC-2210 |
| 2216 | Agent Profile Model | Define `AgentProfile` entity: agent card data + metadata (owner, visibility, tags, created, updated, rating) | EXTENDED | P3 | EPIC-2210 |
| 2217 | Agent Profile Admin Endpoints | Admin endpoints for agent profile management: register, update, list, search, health check, remove | EXTENDED | P2 | EPIC-2210 |
| 2218 | Skill Registry | Implement skill registry: discover, register, and catalog skills from internal capabilities and external agents | EXTENDED | P3 | EPIC-2210 |
| 2219 | Agent Discovery Protocol | Implement agent discovery: query external registries or DNS for agent cards, auto-register discovered agents | ECOSYSTEM | P3 | EPIC-2210 |

### A2A Task Management (2220-2229)

| # | Name | Description | Classification | Priority | Proposed EPIC |
|---|------|-------------|---------------|----------|---------------|
| 2220 | Task Manager | Implement A2A task manager: create, track status, store results for tasks sent to and received from agents | CORE | P2 | EPIC-2220 (new) |
| 2221 | Task Status Lifecycle | Implement task status lifecycle: `submitted` → `working` → `completed` / `failed` / `cancelled`; status updates via SSE or polling | CORE | P2 | EPIC-2220 |
| 2222 | Task Persistence | Persist tasks in PostgreSQL: task ID, agent, skill, input, output, status, created, updated, completed; queryable history | CORE | P2 | EPIC-2220 |
| 2223 | Task Result Artifacts | Handle task result artifacts: text results, file attachments, structured data; store references, enforce size limits | CORE | P2 | EPIC-2220 |
| 2224 | Task Cancellation | Implement task cancellation: cancel in-progress tasks, propagate cancellation to agent, release resources | CORE | P2 | EPIC-2220 |
| 2225 | Task Timeout | Enforce task timeout: configurable per skill/agent, cancel on timeout, return error with partial results if available | CORE | P2 | EPIC-2220 |
| 2226 | Task History | Query task history: filter by agent, skill, status, time range, subject; paginated results for admin and user | EXTENDED | P2 | EPIC-2220 |
| 2227 | Task Audit Trail | Audit all A2A task operations: creation, status changes, completion, cancellation; include in execution envelope | CORE | P2 | EPIC-2220 |
| 2228 | Multi-Agent Orchestration | Support multi-agent task orchestration: send task to multiple agents, aggregate results, sequential or parallel execution | ECOSYSTEM | P3 | EPIC-2220 |
| 2229 | A2A Task Tests | Test suite for task management: lifecycle, persistence, cancellation, timeout, artifacts, history | CORE | P2 | EPIC-2220 |

---

## Cross-References

| Gap Feature | Existing Feature | Relationship |
|-------------|-----------------|--------------|
| 2200 (A2A Types) | 135 (ExposureKindA2ASurface) | A2A types implement the exposure kind defined in domain |
| 2202 (A2A Server) | 343 (A2A Surface Config) | A2A server implements the surface exposure configuration |
| 2204 (A2A Auth) | 250-259 (Auth Middleware) | A2A auth uses same auth infrastructure |
| 2207 (Capability Mapping) | 306 (CapabilitySet CRUD) | Maps capability sets to A2A skills |
| 2208 (A2A Exposure) | 330-344 (Exposure System) | A2A is an exposure type, routed through same pipeline |
| 2210 (Agent Card) | 156 (Plugin Manifest) | Similar concept: self-describing metadata for interoperability |
| 2218 (Skill Registry) | 325-329 (Tool Catalog) | Skill registry parallels tool catalog at agent level |
| 2228 (Multi-Agent) | 1524 (Pipeline Router) | Multi-agent is agent-level pipeline routing |
