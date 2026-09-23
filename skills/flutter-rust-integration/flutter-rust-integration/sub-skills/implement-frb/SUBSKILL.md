---
name: implement-frb
parent: flutter-rust-integration
description: |
  Implement flutter_rust_bridge as a replaceable projection/transport layer.
  Keeps generated bindings behind adapters, preserves typed semantics where practical,
  and routes version/codegen governance to dependency.
triggers:
  - implement flutter_rust_bridge
  - expose rust api to dart
  - frb generated bindings
  - frb stream
  - frb opaque handle
  - frb dto
metadata:
  owner: flutter-rust-integration
  maturity: candidate
  implementation_kind: full
  negative_triggers:
    - "FRB version tuple, Cargo/pub lockfiles, upgrade policy, codegen tool installation -> dependency"
    - "pure public Dart/Rust contract design -> api-design"
    - "unsafe ABI/raw-pointer details -> rust"
  inputs:
    - approved boundary census or equivalent semantic design
    - current FRB project topology
  outputs:
    - bounded Rust bridge adapter
    - generated projection
    - bounded Dart semantic adapter
    - explicit generated-artifact policy
  side_effects:
    - writes-code
    - writes-generated
    - tool-execution
  evidence_required:
    - codegen command/result when generated surfaces change
    - source evidence that domain/UI layers do not directly own generated transport
    - native-crossing evidence for runtime claims
  completion_signal: "FRB implements the selected projection without becoming a semantic owner; generated surfaces are isolated and reproducible under project dependency policy."
  sources:
    - "flutter_rust_bridge project (current mechanics must be verified against installed/pinned version)"
---

# Implement FRB

FRB is the preferred embedded transport when it fits. It does not decide the domain model.

## Stable Praxis

1. Start from a transport-independent contract.
2. Keep Rust semantic/domain code free of FRB dependencies where practical.
3. Place FRB annotations/export glue in a bridge-facing adapter/crate/module.
4. Keep generated Dart APIs behind a Dart semantic adapter.
5. Expose the smallest coherent surface that preserves semantics.
6. Preserve typed boundaries before using serialized escape hatches.
7. Treat streams/jobs/resources as lifecycle-bearing contracts, not function signatures only.
8. Regenerate; do not hand-edit generated bindings.
9. Route version/lock/codegen policy to `dependency`.
10. Prove a native crossing before claiming the bridge works.

## Typed Projection Ladder

When a semantic type does not project cleanly:

1. Use an FRB-supported typed form if it preserves meaning.
2. Introduce a narrow bridge DTO/projected type.
3. Represent a native resource by stable ID/opaque handle.
4. Use a narrow serialized payload only when serialization is genuinely part of the contract or the preceding choices are materially worse.
5. Record why the escape hatch exists.

Do **not** default to:

```text
complex type
→ JSON string
→ jsonDecode
→ duplicated schema
```

That erases much of the value of a typed bridge and tends to spread transport concerns.

## Generated Surface Containment

Target shape:

```text
Rust domain/core
        ↑
Rust bridge adapter
        ↑
generated FRB projection
        ↓
Dart adapter
        ↓
Flutter presentation
```

Generated names/types may appear in the adapter layer. They should not become the
vocabulary of unrelated domain or UI modules.

## Initialization

Make bridge/native initialization explicit and observable.

A project should be able to distinguish:

- generated code exists;
- native library was built;
- native library loaded;
- bridge initialization completed;
- semantic service is ready.

Do not collapse these into one boolean called `ready`.

## Errors

Preserve semantic failure categories. Transport-specific errors should be wrapped or
translated at the adapter boundary.

Avoid exposing raw generated/FFI exceptions as domain semantics unless they truly are
the contract.

## Version-Sensitive Mechanics

Do not freeze current FRB CLI/config syntax into this subskill.

Load [`../../references/frb-current-practice.md`](../../references/frb-current-practice.md)
and verify it against the project-pinned FRB/runtime/codegen versions before mutation.

## Evidence

Minimum runtime claim ladder:

```text
generated
≠ native library loads
≠ Dart→Rust call crosses
≠ async works
≠ stream works
≠ cancellation works
≠ real host works
```

Use `verify-boundary` to choose the required level.
