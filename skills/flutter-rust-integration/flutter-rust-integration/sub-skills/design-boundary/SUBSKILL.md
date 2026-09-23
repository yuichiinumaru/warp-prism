---
name: design-boundary
parent: flutter-rust-integration
description: |
  Design a Flutter↔Rust boundary before transport implementation: canonical ownership,
  semantic contracts, projections, adapters, payload classes, transport placement,
  and explicit boundary census.
triggers:
  - design flutter rust boundary
  - decide what crosses FRB
  - rust owns state flutter view
  - bridge API design
  - duplicate state dart rust
metadata:
  owner: flutter-rust-integration
  maturity: candidate
  implementation_kind: full
  inputs:
    - product capability or integration failure
    - current Dart/Flutter and Rust ownership surfaces
    - runtime topology and payload characteristics
  outputs:
    - boundary census
    - canonical owner decisions
    - contract/projection/adapter plan
    - control-plane versus data-plane classification
  side_effects: [none]
  evidence_required:
    - source paths or architecture evidence for current ownership
    - explicit unresolved assumptions
  completion_signal: "Each material state/operation/resource has a canonical owner, transport-independent contract, crossing representation, and lifecycle/data-plane classification where applicable."
  sources:
    - "Recurring project evidence: Warp Prism, Tempest, and Warpblade Flutter↔Rust boundaries"
---

# Design Boundary

Use this before exposing functions/types merely because the bridge can generate them.

## The Boundary Census

For every material capability, answer:

```yaml
capability: <name>

semantic_owner: rust | dart | split-with-justification

operations:
  - name: <operation>
    direction: dart_to_rust | rust_to_dart | bidirectional
    kind: command | query | event | stream | job-control
    contract: <transport-independent meaning>

state:
  - name: <state>
    owner: rust | dart
    dart_representation: view-state | snapshot | diff | id | handle | none
    staleness_policy: <if applicable>

resources:
  - name: <resource>
    owner: rust | dart | platform
    crosses_as: value | id | handle | native-surface | file | bounded-copy
    lifetime_owner: <side>

failure:
  semantic_model: <what failure means independent of transport>

evidence:
  required_claims: [...]
```

This is a **thinking instrument**, not mandatory bureaucracy for trivial calls.

## Decision Sequence

1. Identify the user-visible/domain capability.
2. Identify the authoritative semantic owner.
3. Separate **contract** from **projection**.
4. Separate **projection** from **transport**.
5. Classify each crossing as control plane or data plane.
6. Identify long-lived resources and operations.
7. Decide whether value-copy, ID, handle, or native resource is the right representation.
8. Define failure semantics before transport encoding.
9. Define what evidence would prove the boundary later.
10. Only then route to `implement-frb` or another transport.

## Ownership Heuristics

Prefer Rust ownership for:

- durable/canonical project/domain state;
- native jobs and schedulers;
- persistence and asset truth;
- audio/video/media engines;
- model/runtime supervision;
- native/GPU resources;
- semantics that must survive UI recreation.

Prefer Dart/Flutter ownership for:

- purely presentational state;
- focus/selection/hover that has no domain meaning;
- transient UI composition;
- local animation/presentation state.

Do not use language boundaries as a substitute for domain boundaries.

## Projection Heuristics

Use **value snapshots** when state is small, immutable enough, and ownership is clear.

Use **diffs/events** when full snapshots are needlessly expensive but the consumer
can reconstruct a projection safely.

Use **IDs/handles** when copying the underlying resource would be wrong or expensive.

Use **streams** for ongoing observation, not as a default API shape.

Use **jobs** for long-running work that needs progress/cancellation/terminal states.

## Smells

Investigate before proceeding when you see:

- Dart and Rust both mutating the same conceptual object.
- Widget code naming generated FRB functions directly.
- Rust domain structs shaped around Dart/FRB limitations.
- A bridge call per frame/list row/property getter.
- JSON strings introduced only because type projection was inconvenient.
- Every state change serialized as a full giant object.
- Native resources represented as copied blobs.
- Failure modeled differently on each side without translation ownership.

## Stop Conditions

Do not finalize boundary design while any of these remain unknown for material work:

- canonical owner;
- operation direction/kind;
- resource lifetime;
- heavy payload placement;
- expected failure semantics;
- the oracle needed to prove the integration.
