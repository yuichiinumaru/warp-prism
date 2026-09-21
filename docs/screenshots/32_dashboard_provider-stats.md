# Screenshot Report: Dashboard — Provider Stats Page

**File**: `32_dashboard_provider-stats.png`
**Page Title**: Provider Stats
**Breadcrumb**: Dashboard > Provider Stats
**Last Updated**: 7:15:12 PM (displayed top-right of content area with a refresh icon)

---

## Summary Cards Row (Top)

Four horizontal metric cards with colored left borders:

| Card | Icon | Label | Value | Border Color |
|------|------|-------|-------|--------------|
| 1 | ClipboardList | Total Requests | **991** | Red/coral |
| 2 | Clock | Avg Latency | **6.6s** | Gray/blue |
| 3 | CheckCircle | Success Rate | **42.1%** | Green |
| 4 | Server | Active Providers | **39** | Purple |

## Provider Breakdown Table

**Section Header**: "Provider Breakdown" with a bar-chart icon. Shows "39 providers" in gray text on the right.

### Table Columns
| Column | Description |
|--------|-------------|
| Provider | Provider name (left-aligned, bold) |
| Requests | Total request count (with sort arrow) |
| Success | Number of successful requests |
| Rate | Success rate percentage (color-coded: green ≥50%, orange/red <50%) |
| Avg Latency | Average response latency |
| Tokens In | Input tokens consumed |
| Tokens Out | Output tokens generated |
| TTFT After Tool | Time-to-first-token after tool (mostly shows "—") |
| Gap After Tool | Gap after tool (mostly shows "—" with right-arrow chevrons) |

### Data Rows (sorted by Requests descending)

| Provider | Requests | Success | Rate | Avg Latency | Tokens In | Tokens Out |
|----------|----------|---------|------|-------------|-----------|------------|
| OpenAI Codex | 273 | 247 | **90.5%** | 14.4s | 50.8M | 142.3K |
| Cloudflare Workers AI | 218 | 61 | **28.0%** | 15.6s | 6.3M | 59.0K |
| OpenAI | 60 | 12 | **20.0%** | 814ms | 0 | 0 |
| Kiro AI | 56 | 15 | **26.8%** | 4.4s | 132.9K | 825 |
| Windsurf (Devon CLI) | 49 | 0 | **0.0%** | 223ms | 0 | 0 |
| NVIDIA NIM | 49 | 2 | **4.1%** | 2.7s | 558 | 9 |
| Gemini (Google AI Studio) | 42 | 41 | **97.6%** | 627ms | 0 | 0 |
| FreeAPIApiKey | 30 | 1 | **3.3%** | 732ms | 0 | 0 |
| Qoder AI | 27 | 15 | **55.6%** | 3.8s | 0 | 0 |
| Antigravity | 27 | 0 | **0.0%** | 65.4s | 0 | 0 |
| Antigravity CLI | 26 | 0 | **0.0%** | 77.9s | 0 | 0 |
| Fireworks AI | 20 | 0 | **0.0%** | 11.0s | 0 | 0 |
| SiliconFlow | 18 | 1 | **5.6%** | 2.8s | 0 | 0 |
| Ollama Cloud | 13 | 1 | **7.7%** | 2.3s | 0 | 0 |
| Kilo Code | 11 | 11 | **100.0%** | 407ms | 0 | 0 |
| Z.AI | 10 | 0 | **0.0%** | 36ms | 0 | 0 |
| Tencent Copilot API | 8 | 0 | **0.0%** | 5.9s | 0 | 0 |
| Kimi | 8 | 0 | **0.0%** | 1.2s | 0 | 0 |
| Nous Research | 6 | 0 | **0.0%** | 2.7s | 0 | 0 |
| OpenRouter | 4 | 1 | **25.0%** | 793ms | 0 | 0 |
| OpenCode Zen | 4 | 2 | **50.0%** | 1.9s | 3.0K | 13 |
| Alibaba-GI | 4 | 0 | **0.0%** | 6.4s | 0 | 0 |
| DeepSeek | 4 | 2 | **50.0%** | 720ms | 0 | 0 |
| Claude Web | 4 | 0 | **0.0%** | 1.2s | 0 | 0 |
| Together AI | 3 | 1 | **33.3%** | 1.5s | 0 | 0 |
| Xiaomi-MIMI | 3 | 0 | **0.0%** | 5.7s | 0 | 0 |
| Kimi Web (Moonshot AI) | 2 | 0 | **0.0%** | 1.1s | 0 | 0 |
| Synthetic | 1 | 1 | **100.0%** | 804ms | 0 | 0 |
| Qwen Web (Free) | 1 | 0 | **0.0%** | 4.9s | 0 | 0 |
| OpenCode Free | 1 | 0 | **0.0%** | 58ms | 0 | 0 |
| StepfunAI | 1 | 1 | **100.0%** | 2.6s | 0 | 0 |
| MMuCode (Free) | 1 | 0 | **0.0%** | 55ms | 0 | 0 |
| DuckDuckGo AI Chat | 1 | 0 | **0.0%** | 958ms | 0 | 0 |
| Devon CLI (Official) | 1 | 0 | **0.0%** | 4.9s | 0 | 0 |
| DeepSeek Web | 1 | 0 | **0.0%** | 1.6s | 0 | 0 |
| ChatGPT Web (Plus/Pro) | 1 | 0 | **0.0%** | 181ms | 0 | 0 |
| Cerebras | 1 | 1 | **100.0%** | 2.0s | 0 | 0 |
| Blackbox AI | 1 | 1 | **100.0%** | 1.9s | 0 | 0 |
| Api.airforce | 1 | 0 | **0.0%** | 3.7s | 0 | 0 |

## Combo Metrics Section

**Section Header**: "Combo Metrics" with subtitle "Per-combo latency and throughput from streaming".

### Table
| Combo | Requests | Avg TTFT | Avg Total | Success |
|-------|----------|----------|-----------|---------|
| reviewer | 24 | — | — | **6300.0%** |

## Request Telemetry Section

**Section Header**: "Request Telemetry" with subtitle "7-phase pipeline breakdown (last 5 minutes)".

### Metrics Displayed
| Metric | Value |
|--------|-------|
| COUNT | **4** |
| AVG | **17.2K** |
| P50 | **15.7K** |
| P95 | **22.8K** |
| P99 | **22.8K** |

## Sidebar

Identical persistent left sidebar as other dashboard pages. "Provider Stats" under the ANALYTICS section is highlighted/active with a red/pink background indicator.
