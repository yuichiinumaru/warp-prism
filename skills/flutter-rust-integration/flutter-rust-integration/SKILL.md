---
name: flutter-rust-integration
description: |
  Flutter↔Rust boundary engineering. READ THIS FIRST when Flutter/Dart and Rust
  must communicate in the same product, especially via flutter_rust_bridge.
  Owns boundary semantics, transport isolation, lifecycle across the boundary,
  native data-plane routing, and evidence that the real boundary works.
  FRB is the preferred embedded transport when justified; it is not the domain architecture.
sub-skills-index:
  - design-boundary: "Decide ownership, semantic contracts, projections, adapters, transport shape, payload classes, and boundary placement before implementation."
  - implement-frb: "Implement flutter_rust_bridge as a replaceable transport adapter without leaking generated bindings or transport semantics into domain/UI layers."
  - govern-lifecycle: "Design and prove stream, cancellation, resource, task, callback, and shutdown lifecycles across Dart↔Rust."
  - route-data-plane: "Keep heavy media/GPU/audio/tensor payloads on the appropriate native data plane; choose handles, surfaces, buffers, files, or bounded copies deliberately."
  - verify-boundary: "Map integration claims to admissible evidence and distinguish adapter tests, generated-binding checks, actual native crossings, lifecycle proof, and real-host proof."
workflows:
  - sk-flutter-rust-add-capability: "Ordered path from semantic requirement to contract, Rust implementation, bridge projection, Dart adapter, native proof, and host proof."
  - sk-flutter-rust-prove-vertical-slice: "Calibrate a real embedded boundary through sync, async, stream, error, cancellation, cleanup, and host execution."
triggers:
  - flutter rust integration
  - flutter_rust_bridge
  - flutter rust bridge
  - FRB
  - dart rust ffi
  - flutter rust ffi
  - native rust backend for flutter
  - rust backend flutter
  - generated rust dart bindings
  - rust to dart stream
  - dart to rust cancellation
  - native texture flutter rust
  - flutter rust data plane
  - flutter rust lifecycle
metadata:
  maturity: candidate
  implementation_kind: full
  owner: architects/integration-harness
  negative_triggers:
    - condition: "The work is pure Flutter/Dart with no Rust/native boundary."
      reason: "Flutter-only engineering belongs to the flutter skill."
      delegate_to:
        skill: flutter
        surface: .agents/skills/flutter/SKILL.md
    - condition: "The work is pure Rust with no Flutter/Dart/native consumer boundary."
      reason: "Rust-only engineering belongs to the rust skill."
      delegate_to:
        skill: rust
        surface: .agents/skills/rust/SKILL.md
    - condition: "The main problem is public API semantics independent of the bridge transport."
      reason: "Public contract design belongs to api-design; this skill consumes those contracts."
      delegate_to:
        skill: api-design
        surface: .agents/skills/api-design/SKILL.md
    - condition: "The main problem is pub/Cargo lockfiles, FRB version tuple, toolchain pinning, generated drift policy, or dependency upgrade."
      reason: "Dependency/toolchain/codegen version governance belongs to dependency."
      delegate_to:
        skill: dependency
        surface: .agents/skills/dependency/SKILL.md
    - condition: "The main problem is diagnosing an already-failing Flutter runtime surface."
      reason: "Remediation owns diagnosis and routes back here only when the failure is actually cross-boundary."
      delegate_to:
        skill: remediation
        surface: .agents/skills/remediation/SKILL.md
    - condition: "The request is independent acceptance, score, promotion, or final review verdict."
      reason: "This skill produces domain evidence; code-quality owns independent judgment and acceptance."
      delegate_to:
        skill: code-quality
        surface: .agents/skills/code-quality/SKILL.md
  inputs:
    - semantic requirement or observed cross-boundary failure
    - current Flutter/Dart and Rust source boundaries
    - runtime topology (embedded, native resource, daemon, or remote)
    - relevant public contracts and dependency/toolchain state
  outputs:
    - boundary classification and ownership map
    - selected subskill/workflow route
    - explicit boundary/lifecycle/data-plane decisions where material
    - evidence packet describing exactly what was and was not proven
  side_effects:
    - read-only by default
    - implementation workflows may write code/generated artifacts when invoked by an authorized builder
    - scripts may execute compilers/codegen/tests only when explicitly requested
  evidence_required:
    - source evidence for ownership and import/dependency boundaries
    - actual native-crossing evidence for claims that the bridge works
    - lifecycle evidence for cancellation/stream/resource claims
    - real-host evidence when the claim includes application composition
  completion_signal: |
    The requested Flutter↔Rust capability or diagnosis is expressed in transport-independent
    semantics, transport leakage is bounded to authorized adapters, lifecycle/data-plane choices
    are explicit where material, and each claimed property is backed by an oracle capable of
    observing it. This skill does not itself grant task acceptance.
  known_failures:
    - treating FRB as domain architecture
    - direct Widget/UI imports of generated FRB bindings
    - Rust domain crates depending on flutter_rust_bridge
    - replacing difficult bridge types with JSON strings by reflex
    - duplicating canonical state in Dart and Rust
    - claiming cancellation because Dart requested it without proving Rust stopped
    - streaming realtime heavy payloads through Dart without measurement
    - interpreting package/unit tests as proof that a native boundary was crossed
    - hand-editing generated bindings
---

# Flutter↔Rust Integration

> **Lobe Gateway.** Load this root, then load exactly the relevant subskill(s).
> Do not execute from the root alone.

This skill owns the **praxis of the boundary** between Flutter/Dart presentation
and Rust-native semantics. It exists because the costly mistakes happen neither
inside Flutter alone nor Rust alone, but in the seam: duplicated truth, transport
leakage, chatty APIs, dishonest cancellation, resource lifetime splits, generated
surface leakage, and heavy data crossing the wrong runtime.

It is deliberately **not** a `flutter_rust_bridge` manual. FRB is the current
golden path for embedded Flutter↔Rust transport when evidence supports it.
Semantic contracts must remain more durable than the transport.

## Domain Ontology

Use these ten primitives before choosing implementation details:

1. **Semantic Owner** — the side that owns canonical truth/behavior.
2. **Contract** — the promise that remains meaningful if transport changes.
3. **Projection** — the representation of that contract across a boundary.
4. **Adapter** — the layer isolating semantic code from transport mechanics.
5. **Transport** — FRB, FFI, native handle, local IPC/RPC, etc.
6. **Payload** — command, event, snapshot, diff, metadata, buffer, frame, tensor.
7. **Resource / Handle** — identity referring to state that should not be copied.
8. **Lifetime / Flow** — creation, activity, ordering, cancellation, close, cleanup.
9. **Failure** — transport-independent meaning plus transport representation.
10. **Evidence** — an observation capable of proving the specific boundary claim.

See [`references/domain-ontology.md`](references/domain-ontology.md).

## Axioms

### I. Semantics outrank transport

The domain must remain understandable without knowing FRB generated names,
annotations, CLI commands, or file layout.

### II. Canonical state has one owner

Dart and Rust may hold projections/caches/view state. They must not independently
own the same authoritative state and "synchronize by hope."

### III. Generated bindings are projections, not architecture

Generated FRB surfaces belong behind adapters. UI widgets and Rust domain cores
must not acquire transport-shaped APIs merely because codegen made them convenient.

### IV. Transport friction is diagnostic evidence

If every nontrivial type requires JSON escape hatches, duplicated DTO trees, or
manual state reconstruction, inspect the boundary model before blaming the bridge.

### V. Control-plane crossings are cheap assumptions; data-plane crossings require proof

Commands, events, compact snapshots, progress, errors, IDs, and capabilities are
natural bridge traffic. Realtime PCM, decoded video frames, tensors, GPU surfaces,
and huge buffers need an explicit data-plane decision and measurement.

### VI. Cross-boundary lifecycle closes on both sides

A Dart cancellation request is not proof that Rust cancelled. A dropped widget is
not proof that a producer task stopped. Every long-lived operation needs an owner,
terminal state, cleanup route, and observable completion.

### VII. Boundary claims require boundary-capable evidence

A Dart adapter unit test can prove Dart mapping. It cannot prove native library
loading or that Rust executed. `cargo test` can prove Rust semantics. It cannot
prove Flutter host composition.

## Routing

| Question | Load |
|---|---|
| What belongs on each side? What should cross? | `design-boundary` |
| How should FRB expose/project it? | `implement-frb` |
| Streams, cancellation, callbacks, long-running jobs, resource cleanup | `govern-lifecycle` |
| Frames, PCM, tensors, GPU/native resources, large buffers | `route-data-plane` |
| What evidence actually proves this integration claim? | `verify-boundary` |

Common bundles:

- New ordinary capability: `design-boundary` → `implement-frb` → `verify-boundary`
- Streaming/long-running command: add `govern-lifecycle`
- Media/audio/GPU workload: add `route-data-plane`
- Public DTO/API design: additionally route to `api-design`
- Cargo/pub/FRB version/codegen mutation: additionally route to `dependency`
- Foreign ABI/unsafe boundary issue: additionally route to `rust` and its FFI/unsafe praxis

## Preferred Layering

```text
Flutter UI / presentation
        │
        ▼
Dart semantic adapter
        │
════════╪════════ transport boundary
        ▼
FRB generated projection
        │
        ▼
Rust bridge adapter
        │
        ▼
Rust semantic/domain core
```

The names may differ by project. The ownership shape should not.

For native heavy data, a second path may exist:

```text
Rust/native data producer
        │
native handle / surface / ring / shared resource
        │
Flutter host primitive
```

That path is **not** permission to bypass the semantic control plane.

## Canonical Owner Boundaries

- **flutter** — widgets, Flutter lifecycle, host composition, view state, focus/accessibility.
- **rust** — Rust ownership/soundness, native resource implementation, async internals.
- **api-design** — durable public semantic contracts.
- **dependency** — manifests, lockfiles, version tuples, codegen/toolchain mutation policy.
- **coding-execution** — builder implementation and self-proof production.
- **code-quality** — independent claim evaluation and acceptance.
- **remediation** — diagnosis of an existing failure.
- **this skill** — the cross-language seam itself.

## Start Here

For nontrivial new integration work, run the **Boundary Census** from
`design-boundary` before exposing functions through FRB.

For a new project or major bridge rewrite, prefer
[`workflows/sk-flutter-rust-prove-vertical-slice.md`](workflows/sk-flutter-rust-prove-vertical-slice.md)
before building a broad API surface.

For an ordinary capability on an already-proven bridge, use
[`workflows/sk-flutter-rust-add-capability.md`](workflows/sk-flutter-rust-add-capability.md).

## Maturity

This package should enter as **candidate**. Activate it only after behavioral evals
show positive delta over generic Flutter + Rust reasoning and after independent
harness review. See [`evals/README.md`](evals/README.md).
