# Warp Prism — Operational State Behavioral Contracts

> **Task**: 1118 — Operational State Vocabulary Expansion
> **Date**: 2026-06-08
> **Status**: Active
> **Source**: `packages/warp_prism_ui/lib/src/tokens/ds_operational_state.dart`

---

## Overview

Each of the 15 operational states carries a behavioral contract that governs
how UI surfaces should render the state and what interactions are available.
These contracts are codified in the `DSOperationalStateUI` extension and
must be respected by all downstream DS components.

---

## Contract Properties

| Property | Type | Description |
|----------|------|-------------|
| `allowsActions` | `bool` | Can the user initiate actions (edit, approve, retry) in this state? |
| `isTerminal` | `bool` | Is this a final state with no automatic transitions? |
| `showsWarning` | `bool` | Should UI surfaces display a warning indicator? |
| `severity` | `DSOperationalSeverity` | Severity level for ambient color and notification routing. |

---

## Full Contract Table

| State | Category | allowsActions | isTerminal | showsWarning | Severity | Screen Reader Label |
|-------|----------|:---:|:---:|:---:|----------|---------------------|
| **Pending** | Lifecycle | ✅ | ❌ | ❌ | info | Pending: awaiting start |
| **Running** | Lifecycle | ✅ | ❌ | ❌ | info | Running: in progress |
| **Approved** | Lifecycle | ✅ | ❌ | ❌ | success | Approved: passed review |
| **Rejected** | Lifecycle | ✅ | ❌ | ⚠️ | error | Rejected: failed review |
| **Promoted** | Lifecycle | ✅ | ❌ | ❌ | success | Promoted: advanced |
| **Archived** | Lifecycle | ❌ | ⚠️ | ❌ | info | Archived: read-only |
| **Healthy** | Health | ❌ | ❌ | ❌ | success | Healthy: operating normally |
| **Degraded** | Health | ✅ | ❌ | ⚠️ | warning | Degraded: reduced quality |
| **Error** | Health | ✅ | ❌ | ⚠️ | error | Error: failure detected |
| **Disabled** | Health | ✅ | ❌ | ❌ | info | Disabled: intentionally off |
| **Unverified** | Verification | ✅ | ❌ | ❌ | info | Unverified: no proof yet |
| **Exposed** | Verification | ✅ | ❌ | ⚠️ | error | Exposed: visible but unreviewed |
| **Redacted** | Verification | ✅ | ❌ | ❌ | warning | Redacted: sensitive hidden |
| **Stale** | Governance | ✅ | ❌ | ⚠️ | warning | Stale: needs refresh |
| **Excluded** | Governance | ❌ | ⚠️ | ❌ | info | Excluded: outside scope |

---

## Severity Levels

| Level | Color | Usage |
|-------|-------|-------|
| `info` | `statusInfo` | Neutral states — no action needed or standard lifecycle positions. |
| `success` | `statusSuccess` | Positive outcomes — approved, healthy, promoted. |
| `warning` | `statusWarning` | Attention needed — degraded, stale, redacted. |
| `error` | `statusError` | Failures detected — rejected, error, exposed. |
| `critical` | `statusError` | Reserved for future use (e.g., cascading failures). |

---

## UI Surface Guidelines

### Status Dots
- Terminal states (`archived`, `excluded`) render as static dots (no animation).
- `running` defaults to animated (pulsing glow) to signal active work.
- All other states render as static colored dots.

### Badges
- `DSBadge.operational(state)` renders the state's label with its canonical color.
- Terminal states use muted backgrounds to signal read-only.

### Action Availability
- Components must check `state.allowsActions` before rendering action buttons.
- Terminal states should show a lock icon or disabled action area.
- Warning states should show an amber indicator alongside the state dot.

### Screen Readers
- `state.semanticLabel` must be used as the `Semantics.label` for all
  state-rendering widgets to ensure screen reader compatibility.

---

## Source

Implementation: `packages/warp_prism_ui/lib/src/tokens/ds_operational_state.dart`
Design vocabulary: `docs/design/operational-state-vocabulary.md`
