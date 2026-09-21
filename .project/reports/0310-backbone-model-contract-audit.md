# 0310 — Backbone Model Contract Audit Report

> **Audit Date**: 2026-06-07
> **Auditor**: Hermes Agent (Task 0310 execution)
> **Scope**: Data model backbone contract — current vs required
> **Method**: Direct source reads of models.dart, workspace_parser.dart, prompt.txt, research.md, mock-workspace-corpus-contract.md

---

## 1. Executive Summary

The current `models.dart` (598 lines) defines a generic `Asset`/`AssetType`/`AssetEdge` contract that covers only 5 of the 9 required asset kinds, uses freeform strings for edge types, omits canonicality entirely, and bakes pipeline-oriented metadata (SkillInput/SkillOutput/SkillStep, WorkflowTrigger/WorkflowStage/RetryPolicy) into classes that should instead carry frontmatter data. The normalized backbone contract has been defined and implemented across 4 new files totaling ~220 lines of focused Dart, with a barrel export and comprehensive tests.

---

## 2. Current State Audit

### 2.1 AssetType (current) vs AssetKind (required)

| Current AssetType | Required AssetKind | Status |
|---|---|---|
| `agent` | `agent` | ✅ Present |
| `skill` | `skill` | ✅ Present |
| — | `subskill` | ❌ MISSING |
| `workflow` | `workflow` | ✅ Present |
| `task` | `task` | ✅ Present |
| `doc` | — | ⚠️ Not in required contract; replaced by specific kinds |
| — | `changelog` | ❌ MISSING |
| — | `script` | ❌ MISSING |
| — | `reference` | ❌ MISSING |
| — | `rule` | ❌ MISSING |

**Gap**: 4 of 9 required kinds are missing. The `doc` value has no direct equivalent in the prompt contract.

### 2.2 Edge Type

| Aspect | Current | Required |
|---|---|---|
| Type | `String edgeType` (freeform) | `EdgeKind` enum (7 values) |
| Values | `"uses"`, `"triggers"`, `"references"`, `"delegates"` (comment only) | `contains`, `routesTo`, `dependsOn`, `references`, `changedBy`, `proves`, `uses` |

**Gap**: No typed enum. Freeform strings invite inconsistency.

### 2.3 Canonicality

| Aspect | Current | Required |
|---|---|---|
| Exists? | No | Yes — 6 values |
| Values | — | `parentCanonical`, `childLocal`, `generated`, `appendOnly`, `archive`, `mock` |

**Gap**: Completely absent. The research.md and prompt.txt both require provenance classification.

### 2.4 Base Class

| Aspect | Current (Asset) | Required (WorkspaceAsset) |
|---|---|---|
| `id` | ✅ | ✅ |
| `kind` | Via `assetType` getter | `AssetKind kind` |
| `name` | ✅ | ✅ |
| `path` | ❌ Missing | ✅ Required |
| `description` | ✅ | ✅ |
| `canonicality` | ❌ Missing | ✅ Required |
| `frontmatter` | ❌ (uses `metadata: Map`) | ✅ Required |
| `tags` | ✅ | ✅ |
| `triggers` | ❌ Missing | ✅ Required |
| `edges` | ❌ Missing (separate `AssetEdge` list) | ✅ Inline |
| `version` | ✅ | ❌ Not in target contract |
| `createdAt/updatedAt` | ✅ | ❌ Not in target (dates in frontmatter) |

**Gap**: `path`, `canonicality`, `frontmatter`, `triggers`, `edges` missing from current. `version`, `createdAt`, `updatedAt` are not in the target contract (they live in frontmatter).

### 2.5 Specialized Classes

| Current Class | Target Approach | Assessment |
|---|---|---|
| `Agent` (status, model, systemPrompt, capabilities, tools, skillIds, workflowIds) | Flat frontmatter: name, model (string), mode, description, skills, workflows | Current is over-structured; target is simpler frontmatter |
| `AgentModel` (provider, name, temperature, maxTokens) | Replaced by `model: "provider/name"` string | Remove |
| `AgentTool`, `ToolParameter` | Not in target contract | Remove |
| `Skill` (inputs, outputs, steps, usedByAgentIds) | Frontmatter: name, description, triggers, sub_skills, canonicality, tags | Current is pipeline-oriented; target is frontmatter-oriented |
| `SkillInput`, `SkillOutput`, `SkillStep` | Not in target contract | Remove |
| `Workflow` (trigger, stages, errorHandling, avgDuration, successRate) | Frontmatter: name, description, uses_skills, kind | Current is pipeline-oriented; target is simpler |
| `WorkflowTrigger`, `WorkflowStage`, `WorkflowErrorHandling`, `RetryPolicy`, `FallbackRule` | Not in target contract | Remove |
| `Task` (status, priority, assignedAgentId, workflowId, startedAt, completedAt, progress) | Frontmatter: id, title, status, priority, owner, created, updated, skills, workflows, depends_on, proof_state, review_score | Different field set |
| `ChangelogEntry` (summary, changes, affectedAssets, evidence, author) | Frontmatter: id, date, project, task, type, impact, skills; body: Why/Changed/Evidence | Completely different structure |
| `AssetEdge` (sourceId, targetId, edgeType: String) | `WorkspaceEdge` (sourceId, targetId, kind: EdgeKind, metadata) | Superseded by typed edge |

### 2.6 Parser (workspace_parser.dart)

| Parser | Current | Target |
|---|---|---|
| `parseAgent` | Parses full YAML (AgentModel, tools, capabilities) | Parse frontmatter from .md |
| `parseSkill` | Parses full YAML (inputs, outputs, steps) | Parse frontmatter from .md |
| `parseWorkflow` | Parses full YAML (trigger, stages, errorHandling) | Parse frontmatter from .md |
| `parseTask` | Does not exist | New parser needed |
| `parseChangelog` | Heading-based markdown parsing | Frontmatter extraction |
| `parseFrontmatter` | Does not exist | New utility needed |
| Graph normalizer | Does not exist | New: build WorkspaceEdge list from cross-references |

---

## 3. Normalized Backbone Implemented

### 3.1 New Files Created

| File | Purpose | Lines |
|---|---|---|
| `lib/data/models/workspace_graph.dart` | AssetKind, EdgeKind, Canonicality, WorkspaceAsset, WorkspaceEdge | ~160 |
| `lib/data/models/task_contracts.dart` | TaskLane, ProofState, TaskMetadata, parsing extensions | ~150 |
| `lib/data/models/changelog_contracts.dart` | ChangelogType, ChangelogMetadata, parsing extension | ~100 |
| `lib/data/models/governance_diagnostics.dart` | DiagnosticSeverity, DiagnosticCategory, GovernanceDiagnostic | ~110 |
| `lib/data/models/data_models.dart` | Barrel export for all backbone files | ~15 |
| `test/data/models/workspace_graph_models_test.dart` | Comprehensive backbone contract tests | ~280 |

### 3.2 Existing Files Modified

| File | Change |
|---|---|
| `lib/data/models/models.dart` | Added SUPERSEDED notice in doc comment; file retained for backward compatibility with workspace_parser.dart |

### 3.3 Decision: Legacy Retention

The legacy `models.dart` is **retained but superseded**. It is the only file imported by `workspace_parser.dart`, which is the only consumer. Removing it would break the existing parser immediately. The new backbone is the canonical contract; downstream tasks (0311-0315) will migrate the parser and any other consumers to the new types, at which point `models.dart` can be archived.

---

## 4. Validation Commands

> **Path note**: After monorepo migration, models live under
> `apps/observatory/lib/data/models/` (not repo-root `lib/`).

| Command (cwd `apps/observatory`) | Expected Result | Actual Result |
|---|---|---|
| `flutter analyze lib/data/models test/data/models` | 0 errors | **PASS 2026-07-09**: No issues found! |
| `flutter test test/data/models/workspace_graph_models_test.dart` | 0 failures | **PASS 2026-07-09**: +27 All tests passed! |

**Prior blocker cleared**: Flutter 3.44.1 / Dart 3.12.1 available. Scoped
OOM-safe analyze + model tests only.

---

## 5. Downstream Impact

| Task | Impact |
|---|---|
| Task 0311 (Parser rewrite) | Can now target `WorkspaceAsset`, `TaskMetadata`, `ChangelogMetadata` types |
| Task 0312 (Repository) | Can now build repositories returning `WorkspaceAsset` lists |
| Task 0313 (Graph normalization) | Can now use `WorkspaceEdge` with typed `EdgeKind` |
| Task 0314 (Diagnostics service) | Can now produce `GovernanceDiagnostic` payloads |
| Task 0315 (Provider contracts) | Can now consume all backbone types in Riverpod providers |

---

## 6. Key Design Decisions

1. **WorkspaceAsset carries raw frontmatter**: Rather than duplicating every frontmatter field as a Dart property, `WorkspaceAsset.frontmatter` holds the raw map. Kind-specific metadata (TaskMetadata, ChangelogMetadata) is extracted by parsers and stored alongside. This keeps the backbone lean while supporting typed access.

2. **Equality is shallow**: WorkspaceAsset and WorkspaceEdge equality is based on identity fields (id, kind, name, path for assets; sourceId, targetId, kind for edges), not deep frontmatter comparison. This supports efficient graph operations.

3. **Parsing extensions live with their types**: `TaskLaneParsing`, `ProofStateParsing`, `ChangelogTypeParsing`, and `DiagnosticSeverityParsing` are extension methods co-located with their enums. This keeps parsing logic discoverable without polluting the enum definitions.

4. **GovernanceDiagnostic is asset-scoped**: Each diagnostic entry references exactly one `assetId`. Multi-asset diagnostics (e.g., broken edges) use the source asset id. This simplifies the UI grouping model.

---

*Report generated by Task 0310 audit execution. All findings based on direct source inspection.*
