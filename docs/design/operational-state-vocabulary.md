# Warp Prism — Operational State Vocabulary

> **Task**: 1102 — Warp Prism Control Surface Inventory
> **Date**: 2026-06-08
> **Status**: Active
> **Evidence**: Mock task frontmatter in `assets/mock_workspace/docs/tasks/`, CyberCore domain entity lifecycle states from `docs/reports/cybercore-domain-ui-mapping-20260608.md`, existing `DSStateType` in `lib/design_system/molecules/ds_state_surface.dart`

---

## 1. Current State

The existing `DSStateType` enum (source: `lib/design_system/molecules/ds_state_surface.dart` line 194) defines only 3 **data-loading states**:

```dart
enum DSStateType { empty, loading, error }
```

This is insufficient. The ASW Observatory and CyberCore pilot require **operational states** that describe the lifecycle, health, verification, and governance status of workspace entities — not merely whether a fetch succeeded.

Additional state fragments exist scattered across components:

| Source | States | Gap |
|--------|--------|-----|
| `DSTaskCard._proofColor` | complete, partial, missing, null | Only proof; no lifecycle states |
| `DSSemantics.forProofState()` | complete, partial, missing, null | Same |
| `DSStatusDot` constructors | success, warning, error, info, neutral | No degraded/disabled/running |
| `DSColors.status*` | success, warning, error, info | No operational semantics |
| Mock task frontmatter `status` | planning, open, doing, review, completed | Task lanes, not universal states |
| Mock task frontmatter `proof_state` | none, partial, complete | Proof only |
| `ProofState` enum (`task_contracts.dart`) | none, partial, complete, verified | 4 proof states |
| `DiagnosticSeverity` enum | info, warning, error, critical | Diagnostic only |
| `ChangelogType` enum | feature, fix, refactor, docs, chore, governance, audit, migration | Change type, not state |
| CyberCore entity lifecycles | draft→active→deprecated→removed, closed→open→half-open, registered→approved→enabled→disabled→removed, etc. | 11 state machines from domain mapping report |

---

## 2. Design Principles

1. **Operational states are entity-lifecycle states**, not UI-loading states. They answer "what is the health/status/verification/lifecycle position of this entity?"
2. **States are composable**: a task can be `running` AND `stale`; an agent can be `healthy` AND `promoted`. The vocabulary defines atomic state atoms; combinations are expressed through multiple state fields.
3. **Each state has exactly one canonical color, one canonical icon, and one behavioral contract** — no ambiguity.
4. **States map to real mock workspace evidence**: every state defined here can be found in the mock corpus task frontmatter or CyberCore domain entity mapping.
5. **The vocabulary is flat and extensible**: new states are added as enum values, not nested hierarchies.

---

## 3. Universal Operational States

### 3.1 Lifecycle States

States that describe where an entity is in its lifecycle progression.

| State | ID | Canonical Color | Icon | Behavioral Contract | Mock Evidence | CyberCore Mapping |
|-------|----|-----------------|------|---------------------|---------------|-------------------|
| **Pending** | `pending` | `textTertiary` (`#8888A0`) | `DSIcons.pending` (schedule) | Entity exists but has not started processing. No active work. Awaiting assignment, dependency resolution, or queue position. | Task status `open` with `proof_state: none` (T004-T008) | draft (Capability, Exposure, Policy, RouteGraph) |
| **Running** | `running` | `accentGold` (`#FFB800`) | `DSIcons.doing` (trending_up) | Entity is actively being worked on. Resources committed. Progress may be partial. | Task status `doing` (T009-T013) | running (WorkflowExecution), working (Task A2A) |
| **Approved** | `approved` | `statusSuccess` (`#10B981`) | `DSIcons.success` (check_circle_outline) | Entity has passed review or approval gate. Ready for promotion or use. | Task `review_score: ≥8.0` + `proof_state: complete` in review lane (T015) | approved (Plugin lifecycle) |
| **Rejected** | `rejected` | `statusError` (`#EF4444`) | `DSIcons.error` (error_outline) | Entity failed review or quality gate. Requires rework or archival. Returned to sender. | Task status `review` with `review_score: <6.0` or explicit return (T014 title: "Review returned") | rejected (review outcome) |
| **Promoted** | `promoted` | `accentCyan` (`#00D4FF`) | `DSIcons.canonical` (verified_outlined) | Entity has been advanced to a higher trust or canonicality level. E.g., mock→childLocal, childLocal→parentCanonical. | Completed tasks with `proof_state: complete` + high `review_score` (T018-T022) | enabled (Plugin lifecycle), active (Capability, Exposure, Policy) |
| **Archived** | `archived` | `textDisabled` (`#505060`) | `DSIcons.archive` (inventory_2_outlined) | Entity is no longer active but preserved for provenance. Read-only. Cannot transition back to running. | Completed tasks (T018-T022 final state), archived mock corpus files | removed (Capability, Exposure, Plugin), archived (Policy) |

### 3.2 Health States

States that describe the current health or quality of an entity.

| State | ID | Canonical Color | Icon | Behavioral Contract | Mock Evidence | CyberCore Mapping |
|-------|----|-----------------|------|---------------------|---------------|-------------------|
| **Healthy** | `healthy` | `statusSuccess` (`#10B981`) | `DSIcons.success` (check_circle_outline) | Entity is operating normally. All dependencies resolved. No warnings. Proof complete. | Completed tasks with `proof_state: complete` and `review_score: ≥9.0` (T018, T019) | healthy (Provider, MCPTool, MCP Server), closed (CircuitBreaker) |
| **Degraded** | `degraded` | `statusWarning` (`#F59E0B`) | `DSIcons.warning` (warning_amber_outlined) | Entity is operational but with reduced quality, missing dependencies, or partial verification. Attention needed but not blocking. | Tasks with `proof_state: partial` in doing lane (T009, T010, T012) | degraded (Provider, MCPTool), half-open (CircuitBreaker) |
| **Error** | `error` | `statusError` (`#EF4444`) | `DSIcons.error` (error_outline) | Entity has encountered a failure. May be recoverable. Requires intervention. | Tasks with `proof_state: none` in review lane (T017), governance warnings | down (Provider), unavailable (MCPServer), failed (WorkflowExecution) |
| **Disabled** | `disabled` | `textDisabled` (`#505060`) | `DSIcons.block` (block) | Entity has been intentionally deactivated. Not available for use. May be re-enabled. Preserves configuration. | Not present in mock corpus (read-only observatory) | disabled (Plugin), suspended (User), paused (WebhookEndpoint) |

### 3.3 Verification States

States that describe the proof/verification position of an entity.

| State | ID | Canonical Color | Icon | Behavioral Contract | Mock Evidence | CyberCore Mapping |
|-------|----|-----------------|------|---------------------|---------------|-------------------|
| **Unverified** | `unverified` | `textTertiary` (`#8888A0`) | `DSIcons.pending` (schedule) | Entity has not yet been subjected to verification. No proof attempted. | Tasks with `proof_state: none` (T001-T008, T011, T013) | N/A (proof is Warp Prism specific) |
| **Exposed** | `exposed` | `statusError` (`#EF4444`) | `DSIcons.warning` (warning_amber_outlined) | Entity has been published or made visible but has not been reviewed for safety, correctness, or governance compliance. Risk of leakage. | Tasks in `open` or `doing` lanes with `proof_state: none` and high priority (P0/P1) | active but unreviewed exposure |
| **Redacted** | `redacted` | `accentViolet` (`#8B5CF6`) | `DSIcons.local` (home_outlined) | Entity has been intentionally obscured or access-restricted. Sensitive content hidden. Display shows placeholder, not actual content. | Credential display in CyberCore (masked values) | Credential masked display, API key prefix-only |

### 3.4 Governance States

States that describe the staleness or provenance of an entity.

| State | ID | Canonical Color | Icon | Behavioral Contract | Mock Evidence | CyberCore Mapping |
|-------|----|-----------------|------|---------------------|---------------|-------------------|
| **Stale** | `stale` | `statusWarning` (`#F59E0B`) | `DSIcons.warning` (warning_amber_outlined) | Entity has not been updated within expected timeframe, or depends on outdated data. May be functionally correct but governance risk. | Tasks in `doing` lane with old `updated` dates, skills with no recent changelog entries | staleIndex, staleReference (DiagnosticCategory) |
| **Excluded** | `excluded` | `textDisabled` (`#505060`) | `DSIcons.block` (block) | Entity is intentionally excluded from a scope, filter, or analysis. Not an error — deliberate boundary. | Tasks not matching current filter, assets filtered out by kind/lane/provenance filter | N/A |

---

## 4. Composite State Matrix

A single entity can carry multiple state fields simultaneously. The following matrix shows which state fields apply to which asset kinds:

| Asset Kind | Lifecycle | Health | Verification | Governance |
|------------|-----------|--------|--------------|------------|
| Agent | — | healthy/degraded/error/disabled | — | stale |
| Skill | — | healthy/degraded/error/disabled | — | stale |
| Workflow | pending/running/approved/rejected/promoted/archived | healthy/degraded/error/disabled | — | stale |
| Task | pending/running/approved/rejected/promoted/archived | healthy/degraded/error | unverified/exposed/redacted | stale/excluded |
| Changelog | — | — | — | stale |
| Script | — | healthy/degraded/error/disabled | — | stale |
| Reference | — | — | unverified/exposed | stale |
| Rule | pending/running/approved/rejected/archived | healthy/degraded/error | — | stale |

---

## 5. State Transitions

### 5.1 Task Lifecycle (Primary)

```
pending → running → approved → promoted → archived
              ↘         ↗
               rejected
    pending → running → degraded → error → archived
```

### 5.2 Health Progression

```
healthy → degraded → error → disabled
                ↘
                 healthy (recovered)
```

### 5.3 Verification Progression

```
unverified → exposed → approved
                ↘
                 redacted (sensitive)
```

### 5.4 Governance Progression

```
(stale is terminal until refreshed)
(stale) → (fresh) [after update]
(excluded) → (included) [after filter change]
```

---

## 6. Color Token Integration

### 6.1 New Color Tokens Required

The existing `DSColors` class needs these additions:

| Token | Hex | Usage |
|-------|-----|-------|
| `statusDegraded` | `#F59E0B` (reuse `statusWarning`) | Degraded health state |
| `statusDisabled` | `#505060` (reuse `textDisabled`) | Disabled state |
| `statusPending` | `#8888A0` (reuse `textTertiary`) | Pending/unverified state |
| `statusPromoted` | `#00D4FF` (reuse `accentCyan`) | Promoted state |
| `statusRedacted` | `#8B5CF6` (reuse `accentViolet`) | Redacted state |
| `statusStale` | `#F59E0B` (reuse `statusWarning`) | Stale state |

No new hex values are required — the existing token palette covers all operational states through semantic reuse. The new tokens are semantic aliases, not new colors.

### 6.2 New Icon Mappings

| State | Icon | DSIcons constant |
|-------|------|------------------|
| pending | `Icons.schedule` | `DSIcons.pending` (exists) |
| running | `Icons.trending_up` | `DSIcons.doing` (exists) |
| approved | `Icons.check_circle_outline` | `DSIcons.success` (exists) |
| rejected | `Icons.error_outline` | `DSIcons.error` (exists) |
| promoted | `Icons.verified_outlined` | `DSIcons.canonical` (exists) |
| archived | `Icons.inventory_2_outlined` | `DSIcons.archive` (exists) |
| healthy | `Icons.check_circle_outline` | `DSIcons.success` (exists) |
| degraded | `Icons.warning_amber_outlined` | `DSIcons.warning` (exists) |
| disabled | `Icons.block` | `DSIcons.block` (exists) |
| unverified | `Icons.schedule` | `DSIcons.pending` (exists) |
| exposed | `Icons.warning_amber_outlined` | `DSIcons.warning` (exists) |
| redacted | `Icons.home_outlined` | `DSIcons.local` (exists) |
| stale | `Icons.warning_amber_outlined` | `DSIcons.warning` (exists) |
| excluded | `Icons.block` | `DSIcons.block` (exists) |

All icons already exist in `DSIcons`. No new icon constants needed.

---

## 7. Implementation Contract

### 7.1 Expanded DSStateType (Proposed)

```dart
/// Operational states for workspace entities.
///
/// Replaces the 3-state [DSStateType] (empty/loading/error) which
/// remains for data-loading states only. [OperationalState] covers
/// entity lifecycle, health, verification, and governance.
enum OperationalState {
  // Lifecycle
  pending,
  running,
  approved,
  rejected,
  promoted,
  archived,

  // Health
  healthy,
  degraded,
  error,
  disabled,

  // Verification
  unverified,
  exposed,
  redacted,

  // Governance
  stale,
  excluded,
}
```

### 7.2 DSStateType Preservation

The existing `DSStateType` should **not** be removed. It describes UI/data-loading states (empty, loading, error) which are orthogonal to operational states. A screen can show `DSStateType.loading` while fetching data, then display entities that each carry an `OperationalState`.

### 7.3 Extension Method (Proposed)

```dart
extension OperationalStateUI on OperationalState {
  Color get color {
    switch (this) {
      case OperationalState.pending: return DSColors.statusPending;
      case OperationalState.running: return DSColors.accentGold;
      case OperationalState.approved: return DSColors.statusSuccess;
      case OperationalState.rejected: return DSColors.statusError;
      case OperationalState.promoted: return DSColors.accentCyan;
      case OperationalState.archived: return DSColors.textDisabled;
      case OperationalState.healthy: return DSColors.statusSuccess;
      case OperationalState.degraded: return DSColors.statusWarning;
      case OperationalState.error: return DSColors.statusError;
      case OperationalState.disabled: return DSColors.textDisabled;
      case OperationalState.unverified: return DSColors.textTertiary;
      case OperationalState.exposed: return DSColors.statusError;
      case OperationalState.redacted: return DSColors.accentViolet;
      case OperationalState.stale: return DSColors.statusWarning;
      case OperationalState.excluded: return DSColors.textDisabled;
    }
  }

  IconData get icon { /* maps to DSIcons constants */ }
  String get label { /* human-readable label */ }
}
```

### 7.4 Status Dot Integration

`DSStatusDot` needs new named constructors:

```dart
DSStatusDot.pending(...)
DSStatusDot.running(animated: true, ...)
DSStatusDot.approved(...)
DSStatusDot.rejected(...)
DSStatusDot.promoted(...)
DSStatusDot.archived(...)
DSStatusDot.degraded(...)
DSStatusDot.disabled(...)
DSStatusDot.stale(...)
```

### 7.5 Provenance Pill Integration

`DSProvenancePill` handles canonicality (parentCanonical/childLocal/generated/appendOnly/archive/mock). Operational states are complementary — they layer on top. A task can be `running` (lifecycle) + `childLocal` (canonicality) + `degraded` (health) + `partial` (proof).

---

## 8. Behavioral Contracts Per State

| State | Screen Reader Label | Visual Treatment | Action Availability |
|-------|--------------------|--------------------|---------------------|
| Pending | "Pending: awaiting start" | Muted border, neutral dot | Start/assign (if authorized) |
| Running | "Running: in progress" | Gold animated dot, gold accent border | Pause/complete (if authorized) |
| Approved | "Approved: passed review" | Green dot, green accent | Promote (if authorized) |
| Rejected | "Rejected: failed review" | Red dot, red accent, strikethrough optional | Rework/re-submit |
| Promoted | "Promoted: advanced" | Cyan dot, cyan accent, glow | Archive |
| Archived | "Archived: read-only" | Disabled text, no accent | None (read-only) |
| Healthy | "Healthy: operating normally" | Green dot | No action needed |
| Degraded | "Degraded: reduced quality" | Yellow dot, yellow accent border | Investigate/repair |
| Error | "Error: failure detected" | Red dot, red accent, alert icon | Retry/escalate |
| Disabled | "Disabled: intentionally off" | Gray dot, gray text | Re-enable (if authorized) |
| Unverified | "Unverified: no proof yet" | Neutral dot, dashed border | Verify/begin verification |
| Exposed | "Exposed: visible but unreviewed" | Red dot, orange accent border | Review/approve/restrict |
| Redacted | "Redacted: sensitive hidden" | Violet dot, masked text (••••) | Reveal (if authorized) |
| Stale | "Stale: needs refresh" | Yellow dot, warning icon | Refresh/re-validate |
| Excluded | "Excluded: outside scope" | Gray text, no dot | Include (filter change) |

---

## 9. Mock Corpus State Pattern Analysis

### 9.1 Task Status Distribution (22 mock tasks)

| status (frontmatter) | Count | Maps to OperationalState |
|---------------------|-------|--------------------------|
| planning | 3 | `pending` |
| open | 5 | `pending` |
| doing | 5 | `running` |
| review | 4 | `running` (awaiting approval) |
| completed | 5 | `approved` → `promoted` → `archived` |

### 9.2 Proof State Distribution

| proof_state | Count | Maps to Verification State |
|------------|-------|---------------------------|
| none | 12 | `unverified` |
| partial | 5 | `exposed` (has some proof but incomplete) |
| complete | 5 | N/A (verification complete — carries no separate operational state) |

### 9.3 Review Score Distribution

| Range | Count | Implies |
|-------|-------|---------|
| n/a (null) | 12 | No review attempted |
| 7.0-7.9 | 3 | Borderline — may map to `degraded` |
| 8.0-8.9 | 3 | Acceptable — `approved` |
| 9.0-9.5 | 4 | Excellent — `approved` + `promoted` candidate |

### 9.4 CyberCore Entity Lifecycle States (11 state machines)

Source: `docs/reports/cybercore-domain-ui-mapping-20260608.md` §2

| State Machine | States | Coverage by OperationalState |
|--------------|--------|------------------------------|
| Capability/Exposure lifecycle | draft→active→deprecated→removed | pending→running→degraded→archived |
| Circuit breaker | closed→open→half-open→probe | healthy→error→degraded→running |
| Plugin lifecycle | registered→approved→enabled→disabled→removed | pending→approved→promoted→disabled→archived |
| Policy lifecycle | draft→active→archived | pending→running→archived |
| Route graph lifecycle | draft→active→deprecated→removed | pending→running→degraded→archived |
| Credential lifecycle | active→rotating→expired/revoked | running→running→error→archived |
| Session lifecycle | active→expired/revoked | running→error→archived |
| Task lifecycle (A2A) | submitted→working→completed/failed/cancelled | pending→running→approved/error/archived |
| Workflow execution | created→running→completed/failed/cancelled | pending→running→approved/error/archived |
| Memory lifecycle | active→decayed→expired | running→degraded→archived |
| Tool risk classification | low→medium→high→critical | healthy→degraded→error→exposed |

The 15-state `OperationalState` vocabulary covers all 11 CyberCore state machines through composition.

---

## 10. Source Evidence

| Source | Relevance |
|--------|-----------|
| `lib/design_system/molecules/ds_state_surface.dart` line 194 | Current 3-state DSStateType |
| `lib/design_system/tokens/ds_semantics.dart` | Existing semantic text styles for status/governance/proof |
| `lib/design_system/tokens/ds_colors.dart` | Existing color tokens for status/lane/governance |
| `lib/design_system/atoms/ds_status_dot.dart` | Current 5-variant status dot |
| `lib/design_system/atoms/ds_icon.dart` | Existing DSIcons constants |
| `lib/data/models/task_contracts.dart` | ProofState (4 states), TaskLane (5 lanes) |
| `lib/data/models/governance_diagnostics.dart` | DiagnosticSeverity (4 levels), DiagnosticCategory (9 categories) |
| `assets/mock_workspace/docs/tasks/` (22 tasks) | Real task frontmatter status/proof_state/review_score patterns |
| `docs/reports/cybercore-domain-ui-mapping-20260608.md` | 11 CyberCore entity state machines |
| `docs/reports/ads-gap-analysis-20260608.md` GAP-I5 | Identified operational state vocabulary as a PARTIAL gap |
| `docs/prompt.txt` lines 536-572 | Task card fields: proof state, review score, lane, priority |
