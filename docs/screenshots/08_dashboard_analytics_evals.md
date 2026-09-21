# 08 — Analytics: Evals

**File**: `08_dashboard_analytics_evals.png`
**Page**: Analytics > Evals
**URL path**: (Dashboard / Analytics / Evals)

---

## Page Header

- **Icon**: Red/coral circular icon with a white flask or beaker symbol (evaluation/testing icon).
- **Title**: "Evals" (bold, large, black text).
- **Subtitle**: "Model evaluation results and performance benchmarks" (gray, smaller text).

---

## Breadcrumb Navigation

Three tabs aligned horizontally below the header:

| Tab | State |
|-----|-------|
| Dashboard | Inactive (gray text) |
| Analytics | Inactive (gray text) |
| Evals | Active (bold, underlined) |

---

## Model Evaluations Info Card

A full-width card at the top of the content area with a light gray background:

- **Left icon**: Purple/violet circular icon with a white flask/science symbol.
- **Title**: "Model Evaluations" (bold, black).
- **Description**: "Test and validate your LLM endpoints by running predefined evaluation suites. Each suite contains test cases that check model quality, compare performance against expected results — helping you detect regressions, compare models, and ensure response quality across providers."
- **Feature badges** (horizontal row below description, each with a colored dot):
  - Green dot — "Quality Validation"
  - Blue dot — "Model Comparison"
  - Yellow/amber dot — "Regression Detection"
  - Purple dot — "Latency Benchmarks"

---

## Summary Statistics Row

Four stat cards displayed horizontally:

| Stat | Value |
|------|-------|
| **SUITES** | `7` (red/coral text) |
| **TEST CASES** | `44` (red/coral text) |
| **MODELS** | `4` (red/coral text) |
| **COVERAGE** | `4 strategies` (red/coral text) |

Each card has a light gray background with uppercase gray label above and the value below in large colored font.

---

## Evaluation Controls Card

A full-width card with a gray background:

- **Left icon**: Orange/amber circular icon with a settings/gear symbol.
- **Title**: "Evaluation Controls" (bold, black).
- **Description**: "Configure your evaluation target and API key, then run suites to validate model quality." (gray text).

### Three dropdown fields in a horizontal row:

| Field | Label | Default Value | Subtext |
|-------|-------|---------------|---------|
| **Target** | "Target" | "Suite defaults" (dropdown) | "Select a model or combo to evaluate." |
| **Compare Target** | "Compare Target" | "Compare (optional)" (dropdown) | "Optionally compare results against a second target." |
| **API Key** | "API Key" | "Auto (use default)" (dropdown) | "Select which API key to use for evaluation requests." |

Each dropdown has a downward-pointing chevron on the right side.

---

## How It Works Card

A collapsible card with:

- **Left icon**: Red/coral circular icon with a question mark or info symbol.
- **Title**: "How It Works" (bold, black).
- **Description**: "Learn how evaluations validate your LLM responses" (gray text).
- **Chevron**: Right-pointing chevron on the far right, indicating the section can be expanded.

---

## Recent Runs Card

- **Left icon**: Blue circular icon with a clock/history symbol.
- **Title**: "Recent Runs" (bold, black).
- **Description**: "Showing the most recent evaluation runs. Click a run to see detailed results." (gray text).
- **Empty state**: A centered icon (gray/teal document with magnifying glass) with text "No evaluation history yet" below it.

---

## Evaluation Suites Card

A full-width card with a white background and subtle border:

- **Left icon**: Purple/violet circular icon with a flask symbol.
- **Title**: "Evaluation Suites" (bold, black).
- **Description**: "Click a suite to view test cases, then run it to evaluate your LLM endpoints." (gray text).

### Action Buttons (top-right of card):
- **Import** button (with upload icon)
- **Run All** button (with play icon)
- **+ New Suite** button (red/coral background, white text)

### Search Bar:
- A search input field with magnifying glass icon and placeholder text "Search suites..." (gray text).

### Suite List (7 rows):

Each suite row contains: a right-pointing chevron (expandable), suite name, badge, case count, description, model tags, and action buttons (Clone, Export, Run Eval).

| # | Suite Name | Badge | Cases | Description | Models | Actions |
|---|-----------|-------|-------|-------------|--------|---------|
| 1 | **OmniRoute Golden Set** | BUILT-IN | 7 cases | "General-purpose prediction checks for LLM response quality across multiple models" | `gpt-4o`, `claude-sonnet-4-20250514`, `gemini-2.5-flash` | Clone, Export, **Run Eval** |
| 2 | **Coding Proficiency** | BUILT-IN | 5 cases | "Tests code generation, debugging, and explanation across languages" | `claude-sonnet-4-20250514`, `gpt-4o`, `gemini-2.5-flash` | Clone, Export, **Run Eval** |
| 3 | **Reasoning & Logic** | BUILT-IN | 5 cases | "Tests logical deduction, math reasoning, and step-by-step thinking" | `claude-sonnet-4-20250514`, `gpt-4o`, `gemini-2.5-flash` | Clone, Export, **Run Eval** |
| 4 | **Multilingual** | BUILT-IN | 5 cases | "Tests translation, language detection, and multilingual understanding" | `gpt-4o`, `claude-sonnet-4-20250514`, `gemini-2.5-flash` | Clone, Export, **Run Eval** |
| 5 | **Safety & Guardrails** | BUILT-IN | 6 cases | "Tests PII handling, harmful content refusal, jailbreak resistance, and bias awareness" | `claude-sonnet-4-20250514`, `gpt-4o`, `gemini-2.5-flash` | Clone, Export, **Run Eval** |
| 6 | **Instruction Following** | BUILT-IN | 5 cases | "Tests format compliance, constraints, word limits, and structured output" | `gpt-4o`, `claude-sonnet-4-20250514`, `gemini-2.5-flash` | Clone, Export, **Run Eval** |
| 7 | **Codex Comparison** | BUILT-IN | 8 cases | "Head-to-head coding tasks for Codex vs GPT-4o vs Claude. Use Compare mode for A/B testing." | `codex` | Clone, Export, **Run Eval** |

### Suite Row Styling:
- Each row has a light gray/white background.
- The suite name is in bold black text.
- The "BUILT-IN" badge appears as small uppercase gray text next to the name.
- Case count appears in gray text (e.g., "7 cases ·").
- Model tags appear as small gray rounded pills/badges.
- **Clone** and **Export** are text/link-style buttons with icons.
- **Run Eval** is a red/coral button with white text.

---

## Left Sidebar

The sidebar is the standard Cybernetics-Core navigation panel. The **Evals** item is highlighted with a red/coral background and white text, indicating the current active page.

### Sidebar Sections Visible:

**OMNIPROXY section:**
- Endpoints, API Keys, Providers, Combos, Combo Studio, Provider Quota, API Endpoints, Webhooks, Proxy

**ANALYTICS section:**
- Usage, Combo Health, Utilization, Cache, Compression, Search, **Evals** (ACTIVE — red/coral background), Provider Stats

**MONITORING section:**
- Activity, Logs, Proxy Logs, Console Logs, Audit Log, MCP Audit, A2A Audit, Health, Runtime

**AGENTIC FEATURES section:**
- Memory, AgentSkills, OmniSkills, MCP Server, A2A Server, Plugins

**Collapsed sections:**
- OTHER FEATURES, CONFIGURATION, HELP

---

## Top-Right Header Bar

- **Quick nav** button with magnifying glass icon
- **"SHORTCUT"** badge (dark background, white text)
- **EN** language selector dropdown
- **User avatar** (green/teal circle with letter)
- **Warning/notification triangle** icon (yellow/amber)
- **Grid/apps** icon

---

## Footer

Two small links at the very bottom-left of the viewport:
- **"Recent"** (green dot + text)
- **"Share..."** (red circle/brand icon + text)

---

## Summary

This is the **Evals (Model Evaluations)** page of the OmniRoute dashboard. It provides a framework for testing and validating LLM endpoints through predefined evaluation suites. The page shows **7 built-in suites** containing **44 total test cases** covering **4 models** (GPT-4o, Claude Sonnet 4, Gemini 2.5 Flash, and Codex) with **4 evaluation strategies** (Quality Validation, Model Comparison, Regression Detection, Latency Benchmarks).

The page is in an **idle state** — no evaluation runs have been executed yet (Recent Runs is empty). The Evaluation Controls section allows the user to configure a target model, an optional comparison target, and an API key before running suites. Each suite can be individually run, cloned, exported, or all suites can be run at once via the "Run All" button. The "+ New Suite" button allows creation of custom evaluation suites.
