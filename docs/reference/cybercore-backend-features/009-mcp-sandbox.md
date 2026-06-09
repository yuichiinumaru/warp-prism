# Feature Catalog: MCP & Sandbox

> **Series**: 900
> **EPICs**: EPIC-900, EPIC-910, EPIC-920, EPIC-930, EPIC-940, EPIC-950, EPIC-960
> **Tasks**: 0421-0460
> **Total Features**: 40

## Features

### MCP Protocol Types & Client (900-909)

| # | Name | Description | Priority |
|---|------|-------------|----------|
| 900 | MCP Protocol Types | Define MCP protocol types: `Tool`, `Resource`, `Prompt`, `ToolCallRequest`, `ToolCallResponse`, `ListToolsRequest/Response`, JSON-RPC envelope | P0 |
| 901 | MCP JSON-RPC Envelope | Implement MCP JSON-RPC 2.0 message envelope: request (id, method, params), response (id, result, error), notification (method, params) | P0 |
| 902 | MCP Client Interface | Define `MCPClient` interface: `ListTools()`, `CallTool(name, args)`, `ListResources()`, `ReadResource(uri)`, `ListPrompts()`, `GetPrompt(name, args)` | P0 |
| 903 | MCP Error Types | Define MCP error types: `MethodNotFound`, `InvalidParams`, `InternalError`, `ResourceNotFound`, `ToolNotFound`, timeout errors | P0 |
| 904 | MCP Message Serialization | Implement JSON serialization/deserialization for all MCP message types with strict schema validation | P0 |
| 905 | MCP Capability Negotiation | Implement MCP capability negotiation: exchange supported features on connection init (tools, resources, prompts, sampling) | P0 |
| 906 | MCP Protocol Versioning | Support MCP protocol version negotiation: advertise supported versions, select compatible version | P0 |
| 907 | MCP Pagination | Implement MCP pagination for list operations: cursor-based, configurable page size | P1 |
| 908 | MCP Notification Handling | Handle MCP notifications: `tools/list_changed`, `resources/list_changed`, `prompts/list_changed` | P0 |
| 909 | MCP Schema Validation | Validate MCP tool input/output against declared JSON Schemas: reject invalid inputs before forwarding to server | P0 |

### MCP Transports: SSE (910-914)

| # | Name | Description | Priority |
|---|------|-------------|----------|
| 910 | MCP SSE Client | Implement MCP SSE transport client: connect to SSE endpoint, receive events, send requests via POST | P0 |
| 911 | SSE Connection Management | Manage SSE connections: reconnect on disconnect, exponential backoff, connection health monitoring | P0 |
| 912 | SSE Event Parsing | Parse SSE events: handle `event`, `data`, `id`, `retry` fields; multi-line data; UTF-8 encoding | P0 |
| 913 | SSE Authentication | Support SSE authentication: Bearer token in initial request, token refresh on reconnect | P0 |
| 914 | SSE Connection Pooling | Pool SSE connections per MCP server: share connection across concurrent tool calls, respect server limits | P1 |

### MCP Transports: Streamable HTTP (915-919)

| # | Name | Description | Priority |
|---|------|-------------|----------|
| 915 | MCP Streamable HTTP Client | Implement MCP Streamable HTTP transport: POST for requests, SSE for streaming responses, session management | P0 |
| 916 | Session Management | Manage Streamable HTTP sessions: session ID tracking, reconnection, session expiry | P0 |
| 917 | Request/Response Correlation | Correlate requests with responses in Streamable HTTP: match by JSON-RPC ID, handle out-of-order responses | P0 |
| 918 | Streamable HTTP Auth | Support authentication for Streamable HTTP: Bearer token, OAuth, custom headers | P0 |
| 919 | Streamable HTTP Retry | Implement retry logic for Streamable HTTP: idempotent requests, retry on network error, backoff | P0 |

### MCP Transports: STDIO (920-924)

| # | Name | Description | Priority |
|---|------|-------------|----------|
| 920 | MCP STDIO Client | Implement MCP STDIO transport client: launch process, communicate via stdin/stdout, JSON-RPC over line-delimited JSON | P0 |
| 921 | Process Lifecycle | Manage MCP STDIO process lifecycle: start, health check, restart on crash, graceful shutdown, resource cleanup | P0 |
| 922 | STDIO Message Framing | Implement line-delimited JSON message framing: write JSON-RPC messages to stdin, read from stdout, stderr for logs | P0 |
| 923 | STDIO Output Limits | Enforce output limits on STDIO: max message size, max total output, kill process on limit exceeded | P0 |
| 924 | STDIO Timeout | Enforce STDIO operation timeouts: per-call timeout, total process lifetime, kill on timeout | P0 |

### MCP Catalog, Mapper & Pools (925-934)

| # | Name | Description | Priority |
|---|------|-------------|----------|
| 925 | MCP Server Registry | Implement MCP server registry: register servers with transport config, auth, namespace, status | P0 |
| 926 | MCP Server Repository | Implement `MCPServerRepository` — store MCP server configs in PostgreSQL: connection info, transport, namespace, status | P0 |
| 927 | Tool Namespace Mapper | Map tools from MCP servers into namespaced capabilities: `server.tool_name`, prevent collisions, track origin | P0 |
| 928 | Resource Namespace Mapper | Map resources from MCP servers into namespaced URIs: `server://resource_uri`, prevent collisions | P0 |
| 929 | MCP Catalog Sync Worker | Background worker: periodically call `ListTools`/`ListResources`/`ListPrompts` on all registered servers, update catalog | P0 |
| 930 | MCP Connection Pool | Pool MCP client connections per server: configurable pool size, health-based eviction, connection reuse | P0 |
| 931 | MCP Session Management | Manage MCP sessions: create on first request, reuse within TTL, close on idle timeout or server restart | P0 |
| 932 | MCP Runtime Lease | Implement MCP runtime leases: track active tool calls per session, enforce concurrency limits, auto-release | P0 |
| 933 | MCP Server Health Monitoring | Monitor MCP server health: periodic ping, error rate tracking, circuit breaker per server | P0 |
| 934 | MCP Server Admin Endpoints | Admin endpoints for MCP server management: register, update, remove, list, health status, trigger catalog sync | P0 |

### MCP Runner & Sandbox (935-944)

| # | Name | Description | Priority |
|---|------|-------------|----------|
| 935 | Runner Process Manager | Implement MCP runner process manager: spawn sandboxed STDIO processes, track lifecycle, enforce limits | P0 |
| 936 | Sandbox: Unprivileged User | Run MCP STDIO processes as unprivileged user: dedicated UID/GID, no root capabilities | P0 |
| 937 | Sandbox: Filesystem Restriction | Restrict sandboxed process filesystem: read-only root, writable temp only, no access to host secrets | P0 |
| 938 | Sandbox: Network Restriction | Restrict sandboxed process network: no outbound by default, configurable egress allowlist via egress policy | P0 |
| 939 | Sandbox: Resource Limits | Enforce resource limits on sandboxed processes: CPU time, memory, file descriptors, process count (cgroups) | P0 |
| 940 | Sandbox: Timeout Enforcement | Enforce execution timeout on sandboxed processes: configurable per-server, kill on timeout, cleanup resources | P0 |
| 941 | Sandbox: Output Capture | Capture sandboxed process output: stdout (JSON-RPC responses), stderr (logs), enforce size limits | P0 |
| 942 | Runner-to-API Communication | Implement runner-to-API communication: authenticated gRPC/HTTP channel for result delivery and health reporting | P1 |
| 943 | Runner Health Reporting | Runner reports health to API: active processes, resource usage, error counts, available capacity | P1 |
| 944 | Runner Scaling | Support multiple runner instances: API distributes STDIO workloads across available runners | P2 |

### MCP Execution & Endpoints (945-954)

| # | Name | Description | Priority |
|---|------|-------------|----------|
| 945 | MCP Tool Executor | Implement MCP tool execution: route tool call to appropriate server/transport, execute, return result | P0 |
| 946 | MCP Tool Result Normalization | Normalize tool results across transports: unified response format, error mapping, content type handling | P0 |
| 947 | MCP Tool Timeout | Enforce per-tool execution timeout: configurable per server/tool, cancel on timeout, return error | P0 |
| 948 | MCP Tool Retry | Implement tool call retry: configurable retry count, retryable error detection, backoff | P0 |
| 949 | MCP Resource Reader | Implement MCP resource reading: route to server, read resource, return content with MIME type | P0 |
| 950 | MCP Prompt Handler | Implement MCP prompt handling: get prompt template, fill arguments, return formatted messages | P1 |
| 951 | MCP Exposure Handler | Implement MCP exposure HTTP handler: serve MCP protocol over HTTP (SSE/Streamable HTTP), authenticate, route to capabilities | P0 |
| 952 | MCP Tool List Endpoint | Implement MCP tools/list endpoint: return available tools filtered by subject authorization and exposure | P0 |
| 953 | MCP Tool Call Endpoint | Implement MCP tools/call endpoint: authenticate, authorize, execute tool, return result | P0 |
| 954 | MCP Resource Endpoints | Implement MCP resource endpoints: list resources, read resource, subscribe to changes | P1 |

### Management MCP Server (955-960)

| # | Name | Description | Priority |
|---|------|-------------|----------|
| 955 | Management MCP Server | Implement Cybernetics Core as MCP server: expose admin operations as MCP tools | P1 |
| 956 | Admin Tools via MCP | Expose admin operations as MCP tools: list/manage capabilities, exposures, policies, credentials, users | P1 |
| 957 | Monitoring Tools via MCP | Expose monitoring as MCP tools: health status, metrics summary, active sessions, recent errors | P1 |
| 958 | Diagnostic Tools via MCP | Expose diagnostics as MCP tools: test provider connectivity, simulate route, inspect descriptor, audit query | P2 |
| 959 | Management MCP Auth | Authenticate management MCP clients: require admin API key or session, scope-based tool access | P1 |
| 960 | Management MCP Transport | Serve management MCP over Streamable HTTP transport: admin port, TLS, CORS restricted to admin origins | P1 |

### Plugin Manifest Contract (961-964)

| # | Name | Description | Priority |
|---|------|-------------|----------|
| 961 | MCP Plugin Manifest | Define plugin manifest for MCP servers: transport type, command (STDIO), URL (SSE/HTTP), auth, egress policy, limits | P1 |
| 962 | Manifest Validation | Validate MCP plugin manifests: required fields, transport-specific config, egress policy format, limit ranges | P1 |
| 963 | Manifest Registry | Store validated manifests in registry: link to MCP server config, version tracking, approval status | P1 |
| 964 | Manifest-Based Provisioning | Auto-provision MCP server from manifest: create server config, set up namespace, configure sandbox, register tools | P2 |
