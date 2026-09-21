# Dashboard: OmniSkills

**Page Title:** OmniSkills
**Subtitle:** Install and manage sandbox skills for automated prompt and tool execution
**Breadcrumb:** Dashboard > Omni skills

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
- Memory, AgentSkills, **OmniSkills** (currently selected, highlighted in red/pink text), MCP Server, A2A Server, Plugins

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

- **Heading:** "OmniSkills" with a red/pink wrench/tool icon to the left
- **Subtitle:** "Install and manage sandbox skills for automated prompt and tool execution"
- **Breadcrumb:** Dashboard > Omni skills

---

## Comparison Banner

A light gray info banner comparing **Agent Skills** vs **Omni Skills**:

**Section Title:** "Omni Skills — Inbound"

**Right side link:** "Understand the difference →" (red/pink text with arrow)

### Comparison Table:

| Dimension | Agent Skills | Omni Skills |
|-----------|-------------|-------------|
| **What is** | Machine-readable SKILL.md that teaches an external agent to operate OmniRoute | Executable tools that OmniRoute injects as tools into LLM requests passing through |
| **Direction** | Outbound — external agent learns to control OmniRoute | Inbound — OmniRoute gives tools to models passing through it |
| **Executor** | External agent (reads markdown, acts via API/CLI) | OmniRoute itself (intercepts tool_calls, Docker sandbox) |
| **Storage** | Dynamic catalog (loagent/skills/) — SKILL.md on GitHub | SQLite (SkillMP) / skills.wh / local |
| **Tagline** | Teach your agent to use OmniRoute | Give executable tools to OmniRoute models |

---

## Stats Cards

Four stat cards in a row:

| Card | Value | Color |
|------|-------|-------|
| **TOTAL SKILLS** | 0 | Purple text |
| **ENABLED** | 0 | Green text |
| **EXECUTIONS** | 0 | Blue text |
| **SUCCESS RATE** | 0% | Red/pink text |

**Right side:** "Install Skill" button (purple filled button)

---

## Tabs

Four tabs below the stats:

| Tab | Status |
|-----|--------|
| **Skills** | Active/selected (underlined, purple text) |
| **Executions** | Inactive |
| **Sandbox** | Inactive |
| **Marketplace** | Inactive |

---

## Skills Tab Content

### Filter Controls:
- **Search input:** placeholder "Filter skills by name, description..."
- **Dropdown:** "All modes"
- **Button:** "Apply filters" (purple filled button)

### Popular Providers Section:
- Label: "Popular by default for selected provider:"
- Provider tags (gray outlined pills): **all**, **anthropic**, **openai**, **deepseek**, **google**

### Skills List Area:
- **Empty state:** "No skills found" centered text
- **Pagination:** "Page 1 of 1 (0 total)" with Previous | Next (both grayed out)

### Right Panel (Inspector):
- **Empty state icon:** Gray magnifying glass over document
- **Message:** "Selecione uma skill à esquerda para inspecionar." (Portuguese: "Select a skill on the left to inspect it.")

---

## Key Observations

1. **No skills installed:** All stat cards show zero — no total skills, no enabled skills, no executions, and 0% success rate.
2. **Two skill types:** The comparison banner clearly distinguishes between Agent Skills (outbound, teaching external agents) and Omni Skills (inbound, injecting tools into LLM requests).
3. **Omni Skills are inbound:** They intercept `tool_calls` from models and execute them in a Docker sandbox, giving models executable capabilities.
4. **Agent Skills are outbound:** They are SKILL.md files that teach external agents how to use OmniRoute's API/CLI.
5. **Marketplace tab:** The presence of a Marketplace tab suggests a browsable/installable skill registry (similar to a package manager).
6. **Sandbox tab:** The Sandbox tab likely provides isolation controls and resource limits for skill execution.
7. **Executions tab:** The Executions tab likely shows a history of skill invocations with status, timing, and output.
8. **Provider filtering:** The "Popular by default for selected provider" section shows supported providers (all, anthropic, openai, deepseek, google) for skill compatibility filtering.
9. **Install Skill button:** The purple "Install Skill" button is the primary action for adding new skills to the system.
10. **Portuguese text:** The inspector panel message is in Portuguese ("Selecione uma skill à esquerda para inspecionar."), indicating the UI supports i18n and this instance may have a Portuguese locale configured.
11. **Mode filtering:** The "All modes" dropdown suggests skills can be filtered by execution mode (e.g., sandbox, direct, etc.).
12. **Skill inspection:** The right panel is designed to show detailed information about a selected skill, but is currently empty since no skills are installed.
