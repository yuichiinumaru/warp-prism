---
name: unsafe-soundness
description: |
  Unsafe block auditing, FFI boundary analysis, raw pointer safety, Send/Sync
  correctness, and formal verification with Miri and Kani. Use when reviewing
  or writing code that involves unsafe blocks, extern "C" interfaces, raw
  pointers, custom allocators, or lock-free data structures.
parent: rust
triggers:
  - unsafe rust
  - unsafe block
  - ffi boundary
  - extern C
  - raw pointer
  - safety comment
  - send sync
  - miri
  - cargo miri
  - cargo kani
  - kani proof
  - soundness
  - cargo-geiger
metadata:
  maturity: draft
  implementation_kind: full
  owner: architects/language-harness
---

# Unsafe Soundness & FFI Boundaries

Operational guidance for auditing, writing, and proving the correctness of
`unsafe` Rust code, FFI boundaries, raw pointers, and custom `Send`/`Sync`
implementations.

## When to Use

- Reviewing code that contains `unsafe` blocks
- Auditing `extern "C"` / FFI interfaces
- Verifying custom `Send`/`Sync` implementations
- Writing or reviewing code with raw pointers (`*const T`, `*mut T`)
- Auditing custom allocators or lock-free data structures
- Running Miri or Kani proof campaigns
- Measuring unsafe density with `cargo-geiger`

## When Not to Use

- Safe Rust code with no `unsafe`, FFI, or raw pointers → use `review` subskill
- Async/cancellation concerns without unsafe → use `async-concurrency`
- General error handling → use `error-handling`
- Test strategy without soundness proofs → use `testing-verification`

## The SAFETY Comment Contract

Every `unsafe` block MUST have a `// SAFETY:` comment that:

1. **States the precondition**: What must be true for this code to be sound?
2. **States the invariant**: What invariant does this code maintain?
3. **Justifies why the precondition holds**: What guarantees it at this call site?
4. **Documents lifetime obligations**: If raw pointers are involved, who owns the memory?

### Template

```rust
// SAFETY:
// - Precondition: `ptr` is non-null and aligned to `T`, obtained from `Box::into_raw`
// - Invariant: We take exclusive ownership; no other code holds this pointer
// - Guarantee: `ptr` was allocated by the global allocator in `new()` on line 42
// - Lifetime: The pointed-to value lives until this `Drop` impl runs
unsafe { Box::from_raw(ptr) }
```

### Anti-Patterns (Reject These)

```rust
// BAD: No SAFETY comment
unsafe { *raw_ptr }

// BAD: Vacuous comment
// SAFETY: this is safe
unsafe { transmute(x) }

// BAD: Wrong granularity (one comment for multiple unrelated operations)
// SAFETY: we checked the length
unsafe {
    let a = *ptr_a;           // unrelated to length check
    slice[unchecked_index];   // actually related
}
```

## FFI Boundary Audit Checklist

For every `extern "C"` block or `#[no_mangle]` function:

- [ ] **Null checks**: Are all pointer parameters checked for null before dereference?
- [ ] **Lifetime correctness**: Who owns the memory? Is it caller-owned or callee-owned? Is this documented?
- [ ] **Alignment**: Are pointer casts between types alignment-safe?
- [ ] **Panic safety**: Can the Rust side panic and unwind across the FFI boundary? (This is UB — use `catch_unwind` or `abort`)
- [ ] **Send/Sync**: If a pointer wrapper is shared across threads, are `Send`/`Sync` correctly implemented?
- [ ] **ABI compatibility**: Is `repr(C)` used on all types crossing the boundary?
- [ ] **Error codes**: Are C-style error codes checked and converted to `Result`?
- [ ] **String encoding**: Is string data handled as `CStr`/`CString`, not raw `&str`?
- [ ] **Callback lifetimes**: If Rust closures are passed as C function pointers, are lifetimes managed (Box::into_raw pattern)?

```bash
# Find all extern blocks
sg -p 'extern "C" { $$$BODY }' -l rust
# Find #[no_mangle] exports
sg -p '#[no_mangle]' -l rust
# Find transmute (high-risk)
sg -p 'transmute($$$ARGS)' -l rust
sg -p 'transmute_copy($$$ARGS)' -l rust
```

## Raw Pointer Analysis

### Pointer Provenance Rules

1. **Every raw pointer must trace back to a valid allocation**: `Box::into_raw`, `alloc::alloc`, or an FFI-provided allocation with documented ownership.
2. **No pointer arithmetic without bounds proof**: If `ptr.add(n)` is used, prove `n` is within the allocation.
3. **No aliasing violations**: If you create `*mut T` from `&T`, you must not write through it unless you have exclusive access.
4. **Provenance must be preserved**: Use `ptr::addr` / `ptr::with_addr` for tagged pointer schemes, not integer-to-pointer casts.

### Strict Provenance Verification

```bash
# Run Miri with strict provenance checking
MIRIFLAGS="-Zmiri-strict-provenance -Zmiri-symbolic-alignment-check" cargo +nightly miri test
```

## Send/Sync Audit

Custom `unsafe impl Send/Sync` requires formal justification:

| Question | Required Answer |
|----------|----------------|
| Does the type contain raw pointers? | If yes, document ownership model |
| Does the type use interior mutability? | If yes, verify thread safety (Mutex, atomic, etc.) |
| Can the type be dropped from a different thread? | If yes, verify `Drop` impl is thread-safe |
| Does the type hold OS resources (fd, handle)? | If yes, verify OS API thread safety |

### Template for Custom Send/Sync

```rust
/// SAFETY: `MyType` is Send because:
/// - The raw pointer `data` points to heap memory owned exclusively by this instance
/// - No shared references to the pointed-to data exist outside this type
/// - The Drop impl deallocates using the same allocator from any thread
unsafe impl Send for MyType {}

/// SAFETY: `MyType` is Sync because:
/// - All access to interior state goes through `AtomicU64` (lock-free, thread-safe)
/// - The raw pointer is only read (never written) after construction
/// - External mutation requires `&mut self` (exclusive access)
unsafe impl Sync for MyType {}
```

## Miri Verification Protocol

### When to Run Miri

- **Always**: Code with `unsafe` blocks
- **Always**: Custom `Send`/`Sync` implementations
- **Always**: FFI wrappers
- **Recommended**: Code using `Cell`/`UnsafeCell`/`RefCell` in complex patterns
- **Recommended**: Custom collections or data structures

### Miri Flags

```bash
# Standard check
cargo +nightly miri test

# Strict provenance (catches more issues)
MIRIFLAGS="-Zmiri-strict-provenance" cargo +nightly miri test

# With leak checking
MIRIFLAGS="-Zmiri-strict-provenance -Zmiri-check-number-validity" cargo +nightly miri test

# Isolation (for tests that access the filesystem)
MIRIFLAGS="-Zmiri-disable-isolation" cargo +nightly miri test
```

### Interpreting Miri Output

| Miri Error | Meaning | Fix |
|------------|---------|-----|
| `Undefined Behavior: ... pointer ... tag ... does not exist` | Stacked borrows violation (aliasing) | Restructure to avoid aliasing `&mut` |
| `Undefined Behavior: accessing ... which is not dereferenceable` | Use after free or OOB | Fix lifetime/bounds |
| `memory leaked` | Allocated memory was never freed | Ensure `Drop` is implemented or use RAII |
| `thread ... data race detected` | Concurrent access without synchronization | Add atomic/mutex or restructure |

## Kani Bounded Model Checking

For critical state machines and invariant proofs:

```rust
#[cfg(kani)]
mod proofs {
    use super::*;

    #[kani::proof]
    fn buffer_never_exceeds_capacity() {
        let cap: usize = kani::any();
        kani::assume(cap > 0 && cap <= 1024);
        let mut buf = Buffer::with_capacity(cap);
        let data: Vec<u8> = kani::any();
        kani::assume(data.len() <= cap);
        buf.write(&data);
        assert!(buf.len() <= buf.capacity());
    }
}
```

```bash
cargo kani --harness buffer_never_exceeds_capacity
```

## Unsafe Density Measurement

```bash
# Measure unsafe usage across the crate
cargo geiger --all-features --all-targets
```

Interpret results:
- **0 unsafe expressions in own code**: Ideal for application crates
- **Unsafe in deps only**: Acceptable; audit critical deps
- **Unsafe in own code**: Each block must have SAFETY comment and Miri coverage

## Build Cleanup

After any successful `cargo build`, `cargo check`, `cargo test`, or `cargo miri test`,
ALWAYS run `cargo clean` to free disk space per AGENTS.md §4.4.
