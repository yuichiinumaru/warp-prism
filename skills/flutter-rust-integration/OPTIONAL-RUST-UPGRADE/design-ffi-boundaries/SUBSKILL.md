---
name: design-ffi-boundaries
parent: rust
description: |
  Design and verify Rust foreign-function boundaries: ABI, repr(C), foreign
  ownership/allocation, callbacks/threads, panic containment, handles, buffer/string
  representation, dynamic-library lifetime, and FFI-facing failures.
triggers:
  - rust ffi boundary
  - extern C
  - repr C
  - foreign callback rust
  - ffi handle
  - ffi buffer ownership
metadata:
  owner: rust
  maturity: candidate
  implementation_kind: full
  negative_triggers:
    - "Flutter↔Rust semantic/transport boundary design -> flutter-rust-integration"
    - "unsafe aliasing/transmute/raw-pointer invariant audit -> rust/unsafe-soundness"
  inputs:
    - foreign ABI/resource surface
    - ownership/lifetime expectations
  outputs:
    - ABI/ownership/lifetime contract
    - evidence plan for FFI-specific invariants
  side_effects: [none]
  evidence_required:
    - source-level ABI/ownership evidence
    - targeted tests/tools appropriate to the unsafe/foreign surface
  completion_signal: "The foreign boundary has explicit ABI, ownership, lifetime, callback/thread, panic, handle, buffer/string, and failure semantics for every material surface."
---

# Design FFI Boundaries

FFI is not synonymous with `unsafe` audit. A boundary can compile and still be
architecturally unsound because ownership, allocation, callback lifetime, thread
entry, panic containment, or handle validity is ambiguous.

## Census

For each foreign function/type/resource record:

- ABI / calling convention;
- representation (`repr(C)` etc.);
- pointer nullability/alignment;
- allocation owner;
- free/release owner;
- buffer length/capacity rules;
- string encoding/termination;
- callback owner and possible thread;
- callback lifetime;
- panic/unwind containment;
- handle validity/stale-handle defense;
- dynamic library/process lifetime assumptions;
- error representation.

## Route

- Flutter↔Rust semantic/transport design → `flutter-rust-integration`.
- Raw pointer/aliasing/transmute/custom Send/Sync invariants → `unsafe-soundness`.
- Async Rust task lifecycle → `async-concurrency`.
- Public Rust API ergonomics independent of FFI → `api-design/design-rust-api`.

## Core rule

The foreign caller must not need to guess who owns memory, when a handle expires,
which thread invokes a callback, or what happens on panic.
