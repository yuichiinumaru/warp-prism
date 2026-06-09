# CyberCore Fixture Schema

> **Task**: 1109
> **Date**: 2026-06-08
> **Status**: Active
> **Location**: `assets/cybercore_fixtures/` (derived from `assets/mock_workspace/`)

This document defines the JSON schemas for the fixed mock fixtures to power the first-wave CyberCore Flutter frontend routes.

---

## 1. Dashboard Fixture Schema
**File**: `dashboard_summary.json`

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "title": "DashboardSummary",
  "type": "object",
  "properties": {
    "agentMetrics": {
      "type": "object",
      "properties": {
        "total": { "type": "integer" },
        "healthy": { "type": "integer" },
        "degraded": { "type": "integer" }
      },
      "required": ["total", "healthy", "degraded"]
    },
    "skillMetrics": {
      "type": "object",
      "properties": {
        "total": { "type": "integer" },
        "withTriggers": { "type": "integer" },
        "noTriggers": { "type": "integer" }
      },
      "required": ["total", "withTriggers", "noTriggers"]
    },
    "workflowMetrics": {
      "type": "object",
      "properties": {
        "total": { "type": "integer" },
        "orphaned": { "type": "integer" },
        "active": { "type": "integer" }
      },
      "required": ["total", "orphaned", "active"]
    },
    "executionMetrics": {
      "type": "object",
      "properties": {
        "planning": { "type": "integer" },
        "open": { "type": "integer" },
        "doing": { "type": "integer" },
        "review": { "type": "integer" },
        "completed": { "type": "integer" }
      },
      "required": ["planning", "open", "doing", "review", "completed"]
    },
    "recentActivity": {
      "type": "object",
      "properties": {
        "total": { "type": "integer" },
        "lastWeek": { "type": "integer" },
        "types": {
          "type": "object",
          "additionalProperties": { "type": "integer" }
        }
      },
      "required": ["total", "lastWeek", "types"]
    }
  },
  "required": ["agentMetrics", "skillMetrics", "workflowMetrics", "executionMetrics", "recentActivity"]
}
```

---

## 2. Registry Fixtures Schema
**Files**: `registry_agents.json`, `registry_skills.json`, `registry_workflows.json`

### Agent Array Schema
```json
{
  "type": "array",
  "items": {
    "type": "object",
    "properties": {
      "id": { "type": "string" },
      "name": { "type": "string" },
      "model": { "type": ["string", "null"] },
      "mode": { "type": "string" },
      "description": { "type": "string" },
      "skills": { "type": "array", "items": { "type": "string" } },
      "workflows": { "type": "array", "items": { "type": "string" } },
      "operationalState": { "type": "string" }
    },
    "required": ["id", "name", "mode", "description", "skills", "workflows", "operationalState"]
  }
}
```

### Skill Array Schema
```json
{
  "type": "array",
  "items": {
    "type": "object",
    "properties": {
      "id": { "type": "string" },
      "name": { "type": "string" },
      "triggers": { "type": "array", "items": { "type": "string" } },
      "subSkills": { "type": "array", "items": { "type": "string" } },
      "canonicality": { "type": "string" }
    },
    "required": ["id", "name", "triggers", "subSkills", "canonicality"]
  }
}
```

### Workflow Array Schema
```json
{
  "type": "array",
  "items": {
    "type": "object",
    "properties": {
      "id": { "type": "string" },
      "name": { "type": "string" },
      "kind": { "type": "string" },
      "skills": { "type": "array", "items": { "type": "string" } },
      "agents": { "type": "array", "items": { "type": "string" } },
      "triggers": { "type": "array", "items": { "type": "string" } }
    },
    "required": ["id", "name", "kind", "skills", "agents", "triggers"]
  }
}
```

---

## 3. Task Board Fixture Schema
**File**: `task_board.json`

```json
{
  "type": "array",
  "items": {
    "type": "object",
    "properties": {
      "id": { "type": "string" },
      "title": { "type": "string" },
      "lane": { "type": "string" },
      "priority": { "type": ["string", "null"] },
      "owner": { "type": ["string", "null"] },
      "proofState": { "type": "string" },
      "reviewScore": { "type": ["number", "null"] },
      "dependsOn": { "type": "array", "items": { "type": "string" } },
      "operationalState": { "type": "string" }
    },
    "required": ["id", "title", "lane", "proofState", "dependsOn", "operationalState"]
  }
}
```

---

## 4. Audit Trail Fixture Schema
**File**: `audit_trail.json`

```json
{
  "type": "array",
  "items": {
    "type": "object",
    "properties": {
      "id": { "type": "string" },
      "date": { "type": "string", "format": "date-time" },
      "project": { "type": "string" },
      "task": { "type": "string" },
      "type": { "type": "string" },
      "impact": { "type": "string" },
      "skills": { "type": "array", "items": { "type": "string" } },
      "body": { "type": ["string", "null"] }
    },
    "required": ["id", "date", "project", "task", "type", "impact", "skills"]
  }
}
```

---

## 5. Governance Fixture Schema
**File**: `governance_diagnostics.json`

```json
{
  "type": "object",
  "properties": {
    "orphanWorkflows": {
      "type": "array",
      "items": { "type": "string" }
    },
    "noTriggerSkills": {
      "type": "array",
      "items": { "type": "string" }
    },
    "unverifiedTasks": {
      "type": "array",
      "items": {
        "type": "object",
        "properties": {
          "taskId": { "type": "string" },
          "title": { "type": "string" },
          "priority": { "type": "string" }
        },
        "required": ["taskId", "title", "priority"]
      }
    },
    "canonicalityBoundary": {
      "type": "object",
      "additionalProperties": { "type": "integer" }
    },
    "fanInHotspots": {
      "type": "array",
      "items": {
        "type": "object",
        "properties": {
          "skillName": { "type": "string" },
          "referenceCount": { "type": "integer" }
        },
        "required": ["skillName", "referenceCount"]
      }
    }
  },
  "required": [
    "orphanWorkflows",
    "noTriggerSkills",
    "unverifiedTasks",
    "canonicalityBoundary",
    "fanInHotspots"
  ]
}
```