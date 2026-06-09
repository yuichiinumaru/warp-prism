# Warp Prism — Operational State Transition Rules

> **Task**: 1118 — Operational State Vocabulary Expansion
> **Date**: 2026-06-08
> **Status**: Active
> **Source**: `docs/design/operational-state-vocabulary.md` §5, CyberCore domain mapping

---

## Overview

State transitions define valid next-states per entity type. These rules are
informational for the read-only observatory — they document domain semantics,
not enforce runtime mutations. When operational surfaces display "next step"
affordances, they should respect these transitions.

---

## Entity Transition Tables

### Task Lifecycle

| Current State | Valid Next States | Notes |
|---------------|-------------------|-------|
| `pending` | `running`, `archived` | Start work or cancel |
| `running` | `approved`, `rejected`, `degraded`, `error`, `archived` | Complete, fail, or cancel |
| `approved` | `promoted`, `archived` | Advance or archive |
| `rejected` | `running`, `archived` | Rework or abandon |
| `promoted` | `archived` | Terminal progression |
| `archived` | _(none)_ | **Terminal** — no return |

### Health Progression

| Current State | Valid Next States | Notes |
|---------------|-------------------|-------|
| `healthy` | `degraded`, `error` | Quality may decrease |
| `degraded` | `healthy`, `error` | May recover or worsen |
| `error` | `healthy`, `degraded`, `disabled` | May recover or be disabled |
| `disabled` | `healthy` | Re-enable (if authorized) |

### Verification Progression

| Current State | Valid Next States | Notes |
|---------------|-------------------|-------|
| `unverified` | `exposed`, `approved` | Publish or verify |
| `exposed` | `approved`, `redacted` | Review or restrict |
| `redacted` | `exposed` | Reveal (if authorized) |

### Governance Progression

| Current State | Valid Next States | Notes |
|---------------|-------------------|-------|
| `stale` | _(any fresh state)_ | Terminal until refreshed |
| `excluded` | _(included)_ | Terminal until filter changes |

---

## CyberCore State Machine Mapping

The 15-state vocabulary covers all 11 CyberCore backend state machines
through composition (source: `docs/reports/cybercore-domain-ui-mapping-20260608.md`).

| Backend State Machine | States | Operational State Mapping |
|----------------------|--------|--------------------------|
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

---

## Composite State Notes

A single entity can carry multiple state fields simultaneously:

- A **task** can be `running` (lifecycle) + `degraded` (health) + `unverified` (verification) + `stale` (governance).
- An **agent** can be `healthy` (health) + `stale` (governance).
- A **workflow** can be `approved` (lifecycle) + `healthy` (health).

The composite state matrix in `docs/design/operational-state-vocabulary.md` §4
defines which state categories apply to which asset kinds.

---

## Source

Vocabulary: `docs/design/operational-state-vocabulary.md`
Behavioral contracts: `docs/design/operational-state-behavioral-contracts.md`
CyberCore mapping: `docs/reports/cybercore-domain-ui-mapping-20260608.md`
