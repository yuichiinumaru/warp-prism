# Dashboard: Memory

**Page Title:** Memory
**Subtitle:** Persistent conversational memory with semantic search and FTS5 full-text indexing
**Breadcrumb:** Dashboard > Memory

---

## Left Sidebar

Identical sidebar to other dashboard pages. Red/pink square icon labeled **Cybernetics-Core** v1.2.28 at top. Navigation sections:

### OMNIPROXY
- Endpoints, API Keys, Providers, Combos, Combo Studio, Provider Quota, API Endpoints, Webhooks, Proxy

### ANALYTICS
- Usage, Combo Health, Utilization, Cache, Compression, Search, Eval, Provider Stats

### MONITORING
- Activity, Logs, Proxy Logs, Console Logs, Audit Log, MCP Audit, A2A Audit

### AGENTIC FEATURES
- **Memory** (currently selected, highlighted in red/pink text), AgentSkills, OmniSkills, MCP Server, A2A Server, Plugins

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

- **Heading:** "Memory" with a red/pink brain/database icon to the left
- **Subtitle:** "Persistent conversational memory with semantic search and FTS5 full-text indexing"
- **Breadcrumb:** Dashboard > Memory

---

## Info Banner

A light blue/gray info banner at the top of the content area with a green brain icon:

> **Conversational Memory**
> Your agent learns and evolves from every conversation — remembering facts, episodes, procedures, and semantic concepts that make responses more accurate and context-aware.
>
> **How it works** (red/pink collapsible link with a downward chevron)

---

## Tabs

Three tabs below the banner:

| Tab | Status |
|-----|--------|
| **Memories** | Active/selected (underlined) |
| **Engine** | Inactive |
| **Playground** | Inactive |

**Right side:** "Memory enabled" label with a **toggle switch** in the **OFF** position (gray).

---

## Action Buttons (Top-Right)

| Button | Style |
|--------|-------|
| **Check health** | Outlined, with green dot indicator |
| **Export** | Outlined |
| **Import** | Outlined |
| **Compact old** | Outlined |
| **Add Memory** | Red/filled (primary action) |

---

## Stats Cards

Two stat cards in a row:

| Card | Value | Icon |
|------|-------|------|
| **Total Entries** | 0 | Info icon (circle with i) |
| **Tokens Used** | 0 | Info icon (circle with i) |

---

## Memories Section

**Section Title:** "Memories"

### Search and Filter Controls (Right-aligned):
- **Search input:** placeholder "Search memories..."
- **Dropdown:** "All Types"

### Empty State

The center of the memories area displays an empty state:

- **Icon:** Gray brain/database icon
- **Heading:** "No memories yet"
- **Description:** "Memories are created automatically from conversations. You can also add them manually using the button above."
- **Button:** "Add Memory" (red/filled button)

---

## Key Observations

1. **Memory is disabled:** The "Memory enabled" toggle is in the OFF position, meaning the memory system is not currently active.
2. **No data:** Both stat cards show 0 — zero total entries and zero tokens used.
3. **Empty state:** The memories list is empty with a clear call-to-action to add memories manually.
4. **Semantic search capability:** The page subtitle mentions "semantic search and FTS5 full-text indexing," indicating the memory system supports both vector-based semantic search and SQLite FTS5 full-text search.
5. **Three tabs:** The Memories tab is the default view. The Engine tab likely provides configuration for the memory backend (embedding model, storage, indexing). The Playground tab likely offers a testing interface for querying memories.
6. **Health check:** The "Check health" button allows verifying the memory subsystem's status.
7. **Import/Export:** The Import and Export buttons suggest memory data can be migrated between instances or backed up.
8. **Compact old:** The "Compact old" button likely triggers garbage collection or compaction of stale/expired memory entries.
9. **How it works:** The collapsible "How it works" section in the info banner likely explains the memory extraction, storage, and retrieval pipeline.
10. **Agent learning context:** The description emphasizes that memories are "created automatically from conversations," indicating an extraction pipeline that pulls facts, episodes, and procedures from chat interactions.
