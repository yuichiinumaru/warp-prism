# Dashboard: Proxy Logs

**Page Title:** Proxy Logs
**Subtitle:** Upstream proxy request logs and traffic inspection
**Breadcrumb:** Dashboard > Logs > Proxy

---

## Left Sidebar

Identical sidebar to other dashboard pages. Red/pink square icon labeled **Cybernetics-Core** v1.2.28 at top. Navigation sections:

### OMNIPROXY
- Endpoints, API Keys, Providers, Combos, Combo Studio, Provider Quota, API Endpoints, Webhooks, Proxy

### ANALYTICS
- Usage, Combo Health, Utilization, Cache, Compression, Search, Eval, Provider Stats

### MONITORING
- Activity, Logs, **Proxy Logs** (currently selected, highlighted in red/pink text), Console Logs, Audit Log, MCP Audit, A2A Audit

### AGENTIC FEATURES
- Memory, AgentSkills, OmniSkills, MCP Server, A2A Server, Plugins

### OTHER FEATURES
- Media, Batch Jobs, Files

### CONFIGURATION
- (collapsed)

### HELP
- Docs, Issues, Changelog

Bottom: Green **Restart** button, Red **Shut...** button.

---

## Top Bar

- "Quick nav" search with `Ctrl+/` hint
- EN language selector
- Bell, warning triangle, and user/settings icons

---

## Page Header

- **Heading:** "Proxy Logs" with a red/pink proxy icon to the left
- **Breadcrumb:** Dashboard > Logs > Proxy

---

## Filters and Controls

### Row 1:
- **Recording** — red dot indicator with green dot, indicating recording is active
- **Search input:** placeholder "Search host, provider, target..."
- **Dropdowns:** "All Types", "All Levels", "All Providers"
- **Summary stats:**
  - **92** total
  - **30** OK (green badge)
  - **62** ERR (red badge)
  - **0** direct (gray badge)
- **Newest** — sort dropdown
- **Refresh** button (circular arrow icon)

### Row 2 (Column Filter Tags):
- **ALL** (red/active), **Errors** (gray), **Success** (gray), **Timeout** (gray)
- Provider filter tags: **CODEX**, **NVIDIA**, **OPENAI**

### Row 3 (Column Visibility Toggles):
- COLUMNS: **Status**, **Proxy**, **TLS**, **Type**, **Level**, **Provider**, **Target**, **Latency**, **Client IP**, **Time**

---

## Data Table

### Column Headers:
| STATUS | PROXY | TLS | TYPE | LEVEL | PROVIDER | TARGET | LATENCY | CLIENT IP | TIME |

### Table Content (representative rows):

**Top section — Successful requests (SUCCESS):**

| Status | Proxy | TLS | Type | Level | Provider | Target | Latency | Client IP | Time |
|--------|-------|-----|------|-------|----------|--------|---------|-----------|------|
| SUCCESS | — | — | — | — | OPENAI | codex/gpt-5.5-high | 828ms | 172.17.0.1 | 18:13:36 |
| SUCCESS | — | — | — | — | OPENAI | codex/gpt-5.5-high | 775ms | 172.17.0.1 | 18:13:34 |
| SUCCESS | — | — | — | — | OPENAI | codex/gpt-5.5-high | 816ms | 172.17.0.1 | 18:13:25 |
| SUCCESS | — | — | — | — | OPENAI | codex/gpt-5.5-high | 3.4s | 172.17.0.1 | 18:12:57 |
| SUCCESS | — | — | — | — | OPENAI | codex/gpt-5.5-high | 778ms | — | 18:04:53 |
| SUCCESS | — | — | — | — | OPENAI | codex/gpt-5.5-high | 729ms | — | 18:04:19 |
| SUCCESS | — | — | — | — | OPENAI | codex/gpt-5.5-high | 2.8s | — | 18:03:51 |
| SUCCESS | — | — | — | — | OPENAI | codex/gpt-5.5-high | 719ms | — | 18:03:37 |
| SUCCESS | — | — | — | — | OPENAI | codex/gpt-5.5-high | 1.3s | — | 18:03:29 |
| SUCCESS | — | — | — | — | OPENAI | codex/gpt-5.5-high | 772ms | — | 18:03:07 |

**Middle section — Error requests (ERROR):**

A long block of ERROR entries showing:

| Status | Proxy | TLS | Type | Level | Provider | Target | Latency | Client IP | Time |
|--------|-------|-----|------|-------|----------|--------|---------|-----------|------|
| ERROR | — | — | — | — | OPENAI | openai/gpt-5.5 | 418ms | — | 18:31:19 |
| ERROR | — | — | — | — | OPENAI | openai/gpt-5.5 | 461ms | — | 18:31:19 |
| ERROR | — | — | — | — | OPENAI | openai/gpt-5.5 | 397ms | — | 18:31:18 |
| ERROR | — | — | — | — | OPENAI | openai/gpt-5.5 | 404ms | — | 18:31:18 |
| ERROR | — | — | — | — | OPENAI | openai/gpt-5.5 | 419ms | — | 18:31:18 |
| ERROR | — | — | — | — | OPENAI | openai/gpt-5.5 | 386ms | — | 18:31:17 |
| ERROR | — | — | — | — | OPENAI | openai/gpt-5.5 | 476ms | — | 18:31:17 |
| ERROR | — | — | — | — | OPENAI | openai/gpt-5.5 | 419ms | — | 18:31:16 |
| ERROR | — | — | — | — | OPENAI | openai/gpt-5.5 | 427ms | — | 18:31:16 |
| ERROR | — | — | — | — | OPENAI | openai/gpt-5.5 | 422ms | — | 18:31:15 |
| ERROR | — | — | — | — | OPENAI | openai/gpt-5.5 | 398ms | — | 18:31:15 |
| ERROR | — | — | — | — | OPENAI | openai/gpt-5.5 | 422ms | — | 18:31:14 |
| ERROR | — | — | — | — | OPENAI | openai/gpt-5.5 | 400ms | — | 18:31:14 |
| ERROR | — | — | — | — | OPENAI | openai/gpt-5.5 | 411ms | — | 18:31:13 |
| ERROR | — | — | — | — | OPENAI | openai/gpt-5.5 | 418ms | — | 18:31:12 |

These ERROR entries continue for many rows, all targeting `openai/gpt-5.5` with latencies between **385ms–492ms**.

**NVIDIA provider section:**

| Status | Proxy | TLS | Type | Level | Provider | Target | Latency | Client IP | Time |
|--------|-------|-----|------|-------|----------|--------|---------|-----------|------|
| ERROR | — | — | — | — | NVIDIA | nvidia/openai/gpt-oss-120k | 134ms | — | 18:30:43 |
| ERROR | — | — | — | — | NVIDIA | nvidia/openai/gpt-oss-120k | 138ms | — | 18:30:42 |
| ERROR | — | — | — | — | NVIDIA | nvidia/openai/gpt-oss-120k | 124ms | — | 18:30:42 |
| ERROR | — | — | — | — | NVIDIA | nvidia/openai/gpt-oss-120k | 137ms | — | 18:30:42 |
| ERROR | — | — | — | — | NVIDIA | nvidia/openai/gpt-oss-120k | 133ms | — | 18:30:42 |
| ERROR | — | — | — | — | NVIDIA | nvidia/openai/gpt-oss-120k | 3.1s | — | 18:30:39 |
| ERROR | — | — | — | — | NVIDIA | nvidia/openai/gpt-oss-120k | 3.1s | — | 18:30:35 |
| ERROR | — | — | — | — | NVIDIA | nvidia/openai/gpt-oss-120k | 3.1s | — | 18:30:32 |
| ERROR | — | — | — | — | NVIDIA | nvidia/openai/gpt-oss-120k | 3.5s | — | 18:30:29 |
| ERROR | — | — | — | — | OPENAI | openai/gpt-5.5 | 5.8s | — | 18:30:26 |

**Bottom section — More SUCCESS entries with client IPs:**

| Status | Proxy | TLS | Type | Level | Provider | Target | Latency | Client IP | Time |
|--------|-------|-----|------|-------|----------|--------|---------|-----------|------|
| SUCCESS | — | — | — | — | OPENAI | codex/gpt-5.5-high | 693ms | 172.17.0.1 | 18:17:21 |
| SUCCESS | — | — | — | — | OPENAI | codex/gpt-5.5-high | 620ms | 172.17.0.1 | 18:17:00 |
| SUCCESS | — | — | — | — | OPENAI | codex/gpt-5.5-high | 552ms | 172.17.0.1 | 18:16:43 |
| SUCCESS | — | — | — | — | OPENAI | codex/gpt-5.5-high | 952ms | 172.17.0.1 | 18:16:25 |
| SUCCESS | — | — | — | — | OPENAI | codex/gpt-5.5-high | 1.5s | 172.17.0.1 | 18:16:03 |
| SUCCESS | — | — | — | — | OPENAI | codex/connection-test | — | — | 18:14:57 |
| SUCCESS | — | — | — | — | OPENAI | codex/connection-test | — | — | 18:14:55 |
| SUCCESS | — | — | — | — | OPENAI | codex/connection-test | — | — | 18:14:53 |
| SUCCESS | — | — | — | — | OPENAI | codex/connection-test | — | — | 18:14:52 |
| SUCCESS | — | — | — | — | OPENAI | codex/connection-test | — | — | 18:14:49 |
| SUCCESS | — | — | — | — | OPENAI | codex/connection-test | — | — | 18:14:47 |
| SUCCESS | — | — | — | — | OPENAI | codex/connection-test | — | — | 18:14:45 |
| SUCCESS | — | — | — | — | OPENAI | codex/connection-test | — | — | 18:14:43 |
| SUCCESS | — | — | — | — | OPENAI | codex/connection-test | — | — | 18:14:41 |
| SUCCESS | — | — | — | — | OPENAI | codex/connection-test | — | — | 18:14:39 |
| SUCCESS | — | — | — | — | OPENAI | codex/connection-test | — | — | 18:14:37 |
| SUCCESS | — | — | — | — | OPENAI | codex/connection-test | — | — | 18:14:35 |
| SUCCESS | — | — | — | — | OPENAI | codex/connection-test | — | — | 18:14:32 |
| SUCCESS | — | — | — | — | OPENAI | codex/gpt-5.5-high | 13.8s | — | 18:14:13 |

**Final ERROR entries at bottom:**

| Status | Proxy | TLS | Type | Level | Provider | Target | Latency | Client IP | Time |
|--------|-------|-----|------|-------|----------|--------|---------|-----------|------|
| ERROR | — | — | — | — | OPENAI | codex/gpt-5.5-high | 1.7s | 172.17.0.1 | 18:08:34 |
| ERROR | — | — | — | — | OPENAI | codex/gpt-5.5-high | 3.0s | 172.17.0.1 | 18:01:16 |
| ERROR | — | — | — | — | OPENAI | codex/gpt-5.5-high | 618ms | 172.17.0.1 | 17:59:04 |
| ERROR | — | — | — | — | OPENAI | codex/gpt-5.5-high | 1.8s | 172.17.0.1 | 17:58:00 |
| SUCCESS | — | — | — | — | OPENAI | codex/connection-test | — | — | 17:57:52 |

---

## Key Observations

1. **High error rate:** 62 out of 92 total requests (67.4%) resulted in errors, while only 30 were successful.
2. **Target distribution:** Successful requests target `codex/gpt-5.5-high`, while errors target both `openai/gpt-5.5` and `nvidia/openai/gpt-oss-120k`.
3. **Latency patterns:**
   - Successful `codex/gpt-5.5-high` requests: 552ms–3.4s
   - Error `openai/gpt-5.5` requests: 385ms–492ms (consistent, suggesting quick rejection)
   - Error `nvidia/openai/gpt-oss-120k` requests: 124ms–3.5s (bimodal)
4. **Client IP:** Most requests originate from `172.17.0.1` (Docker bridge network), indicating internal/proxy traffic.
5. **Connection tests:** A series of `codex/connection-test` requests appear in the SUCCESS section with no latency data, suggesting health-check pings.
6. **No TLS data:** The TLS column is empty for all entries, indicating TLS information is not being captured or is not applicable.
7. **Column filters:** The provider filter tags (CODEX, NVIDIA, OPENAI) allow quick filtering. The ALL/Errors/Success/Timeout tags filter by status category.
