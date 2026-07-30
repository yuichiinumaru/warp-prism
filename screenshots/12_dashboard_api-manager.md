# 12 — Dashboard: API Keys (API Manager)

**File**: `12_dashboard_api-manager.png`
**Page**: Dashboard > API Keys
**URL path**: (Dashboard / API Keys)

---

## Page Header

- **Icon**: Red/coral circular icon with a white key symbol.
- **Title**: "API Keys" (bold, large, black text).
- **Subtitle**: "Manage API keys and access control for your OmniRoute instance" (gray, smaller text).

---

## Breadcrumb Navigation

| Segment | State |
|---------|-------|
| Dashboard | Inactive (gray text) |
| API Keys | Active (bold, underlined) |

---

## Search and Filter Bar

### Search Input
- Full-width search field with magnifying glass icon and placeholder text "Search by name or token..." (gray text).

### Active Only Toggle
- **Toggle switch** on the far right with label "Active only" — appears to be **ON** (green/active state).

### Status Filter Tags (horizontal row):

| Tag | Count | State |
|-----|-------|-------|
| **All** | 8 | Active (red/coral background, white text) |
| **Active** | 4 | Inactive (gray outline) |
| **Disabled** | 0 | Inactive (gray outline) |
| **Banned** | 0 | Inactive (gray outline) |
| **Expired** | 0 | Inactive (gray outline) |

### Type Filter Tags (right-aligned):

| Tag | Count | State |
|-----|-------|-------|
| **All** | 8 | Active (red/coral background, white text) |
| **Standard** | 4 | Inactive (gray outline) |
| **Manage** | 0 | Inactive (gray outline) |
| **Restricted** | 0 | Inactive (gray outline) |

---

## Registered Keys Card

A full-width card with a white background:

### Card Header
- **Left icon**: Red/coral shield or key icon.
- **Title**: "Registered Keys (4)" (bold, black, with count in parentheses).
- **Subtitle**: "4 keys registered" (gray text below title).
- **Description**: "Each key isolates usage tracking and can be revoked independently. Keys are masked after creation for security." (gray text).
- **Right side**: **"+ Create API Key"** button (red/coral background, white text).

### Section Header
- **Label**: "Normal keys · 4" (with a settings/gear icon to the left, gray text).

---

## API Keys Table

A table with 5 columns: NAME, KEY, PERMISSIONS, USAGE, CREATED, ACTIONS.

### Table Header Row:
| Column | Style |
|--------|-------|
| NAME | Uppercase, gray, small text |
| KEY | Uppercase, gray, small text |
| PERMISSIONS | Uppercase, gray, small text |
| USAGE | Uppercase, gray, small text |
| CREATED | Uppercase, gray, small text |
| ACTIONS | Uppercase, gray, small text |

### Table Rows (4 keys):

#### Row 1 — opencode
| Field | Value |
|-------|-------|
| **NAME** | `opencode` (with green/teal lock icon to left) |
| **KEY** | `sk-c2c57****f199` (masked, monospace font) |
| **PERMISSIONS** | `All models` (green badge/pill) |
| **USAGE** | `7 reqs` (bold), `$0.05` (gray), "Last: 7/2/2025" (small gray text) |
| **CREATED** | `5/28/2025` |
| **ACTIONS** | (empty or icon — not clearly visible) |

#### Row 2 — hermes
| Field | Value |
|-------|-------|
| **NAME** | `hermes` (with green/teal lock icon to left) |
| **KEY** | `sk-55b69****96f9` (masked, monospace font) |
| **PERMISSIONS** | `All models` (green badge/pill) |
| **USAGE** | `0 reqs` (bold), "Never used" (small gray text) |
| **CREATED** | `6/9/2025` |
| **ACTIONS** | (empty or icon — not clearly visible) |

#### Row 3 — o2
| Field | Value |
|-------|-------|
| **NAME** | `o2` (with green/teal lock icon to left) |
| **KEY** | `sk-55b69****28ba` (masked, monospace font) |
| **PERMISSIONS** | `All models` (green badge/pill) |
| **USAGE** | `672 reqs` (bold), `$28.75` (gray), "Last: 7/2/2025" (small gray text) |
| **CREATED** | `6/7/2025` |
| **ACTIONS** | (empty or icon — not clearly visible) |

#### Row 4 — global
| Field | Value |
|-------|-------|
| **NAME** | `global` (with green/teal lock icon to left) |
| **KEY** | `sk-55b69****6b51` (masked, monospace font) |
| **PERMISSIONS** | `All models` (green badge/pill) |
| **USAGE** | `0 reqs` (bold), "Never used" (small gray text) |
| **CREATED** | `6/11/2025` |
| **ACTIONS** | (empty or icon — not clearly visible) |

### Table Row Styling:
- Each row has a light gray/white alternating background.
- The key name appears in bold dark text with a small green/teal lock icon to the left.
- The API key value is masked (middle characters replaced with `****`) in monospace font.
- The **Permissions** column shows a green pill/badge with "All models" text.
- The **Usage** column shows request count in bold, cost in gray, and "Last:" timestamp in small gray text (or "Never used" for unused keys).
- The **Created** column shows the date in MM/DD/YYYY format.

---

## Left Sidebar

The sidebar is the standard Cybernetics-Core navigation panel. The **API Keys** item is highlighted with a red/coral background and white text, indicating the current active page.

### Sidebar Sections Visible:

**OMNIPROXY section:**
- Endpoints, **API Keys** (ACTIVE — red/coral background, white text), Providers, Combos, Combo Studio, Provider Quota, API Endpoints, Webhooks, Proxy

**ANALYTICS section:**
- Usage, Combo Health, Utilization, Cache, Compression, Search, Evals, Provider Stats

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

This is the **API Keys (API Manager)** page of the OmniRoute dashboard. It provides a management interface for creating, monitoring, and controlling API keys that grant access to the OmniRoute instance.

### Key Statistics:
- **Total keys**: 8 (according to filter counts), with **4 currently Active**.
- **Key types**: All 4 visible keys are "Standard" type with "All models" permissions.
- **Key naming**: Keys are named `opencode`, `hermes`, `o2`, and `global`.

### Usage Highlights:
- **o2** is the most active key with **672 requests** and **$28.75** in costs.
- **opencode** has **7 requests** and **$0.05** in costs.
- **hermes** and **global** have **0 requests** ("Never used").

### Security Features:
- API keys are **masked after creation** (only first 4 and last 4 characters visible: `sk-xxxx****xxxx`).
- Each key has an associated **lock icon** indicating secure credentials.
- Keys can be **filtered** by status (Active, Disabled, Banned, Expired) and type (Standard, Manage, Restricted).
- An **"Active only" toggle** is available to quickly show only active keys.
- The **"+ Create API Key"** button allows creation of new keys.
- Each key **isolates usage tracking** and can be **revoked independently**.
