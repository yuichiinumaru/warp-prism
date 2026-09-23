---
name: rust-review
description: |
  Rust code review protocol and soundness auditing. Comprehensive multi-phase
  review covering security heat map, async cancellation audit, idiomatic/zero-cost
  analysis, logical proof architecture, and deep soundness verification.
  Adapted from code-quality/sub-skills/rust with expanded domain coverage.
parent: rust
triggers:
  - rust review
  - rust code review
  - rust audit
  - rust quality
  - rust soundness
metadata:
  maturity: draft
  implementation_kind: full
  owner: architects/language-harness
  provenance: "Adapted from .agents/skills/code-quality/sub-skills/rust/SUBSKILL.md"
---

# Rust Review Protocol

Combined protocol for reviewing Rust code: ownership safety, unsafe auditing,
async cancellation, FFI boundaries, type-state proofs, and formal verification.

Provenance: adapted from `code-quality/sub-skills/rust/SUBSKILL.md`.
The parent subskill remains intact for backward compatibility.

## When to Use

- Full Rust PR or module review
- Pre-merge quality gate for Rust code
- Ownership/borrow pattern analysis
- Scoring a Rust codebase against the 0-100 rubric
- Post-implementation audit of Rust modules

## When Not to Use

- Cross-language scoring or review workflows → `code-quality`
- Deep unsafe-only audit → `rust/sub-skills/unsafe-soundness`
- Async-only audit → `rust/sub-skills/async-concurrency`
- Error handling design → `rust/sub-skills/error-handling`
- Test strategy design → `rust/sub-skills/testing-verification`
- Go, Python, TS/JS, or Flutter code → respective language harnesses

## Core Axioms (Non-Negotiable)

| # | Axiom | Violation = | Check |
|---|-------|-------------|-------|
| 1 | **Ownership** | Aliasing + Mutation = UB | Every `&mut` is exclusive; no shared mutability without `Cell`/`Mutex` |
| 2 | **Type-State** | Invalid states representable | Use enums/newtypes to make impossible states uncompilable |
| 3 | **Zero-Cost** | Runtime penalty from abstraction | No unnecessary `Box`, `dyn Trait`, or allocation where static dispatch suffices |
| 4 | **Safety Boundary** | Missing `// SAFETY:` | Every `unsafe` block MUST have a `// SAFETY:` comment justifying invariants |
| 5 | **Cancellation Safety** | Resource leak on `Future` drop | Any `.await` point must be safe to drop — use RAII/`Drop` guards |

## Review Phases

### Phase 1: Security Heat Map

#### 1.1 Unsound Safe Abstractions
- Does a `pub` API hide an `unsafe` block that could be violated by specific input combinations?
- Can a caller construct inputs that break the `unsafe` block's preconditions?
- Are type invariants documented and enforced at construction boundaries?

#### 1.2 FFI Boundary Fragility
- Audit every `extern "C"` block
- Ensure raw pointer wrappers correctly implement `Send`/`Sync`
- Check for null pointer dereference in FFI return values
- Verify lifetime of data passed across the FFI boundary
- Check for panics that could unwind across FFI boundaries (UB)

#### 1.3 Async Race Conditions (TOCTOU)
```bash
# Find spawned tasks that capture mutable references
sg -p 'tokio::spawn(async move { $$$BODY })' -l rust
# Find select! blocks (cancellation hazard zones)
sg -p 'tokio::select! { $$$ARMS }' -l rust
```

#### 1.4 Lifetime Variance
- Types wrapping `&T` in `Cell`/`UnsafeCell` must be **invariant**
- Audit generic parameters on structs containing raw pointers
- Check for `PhantomData` usage on types with lifetime parameters
- Verify covariance/contravariance correctness on public generic types

### Phase 2: Async Cancellation Safety Audit

For every `async fn` or `select!` block, perform a **Drop-Proof Audit**:

- [ ] If this task is dropped at each `.await` point, does it leak resources?
- [ ] Is there a `Drop` guard that rolls back partial writes?
- [ ] Are database transactions wrapped in a guard that aborts on drop?
- [ ] Do `select!` branches clean up the losing branch's side effects?
- [ ] Are `tokio::sync::Mutex` guards held across `.await` points? (deadlock risk)
- [ ] Are `JoinHandle`s properly tracked and awaited/aborted on shutdown?

```bash
# Find mutex guards held across await (deadlock risk)
sg -p 'let $GUARD = $MUTEX.lock().await' -l rust
```

### Phase 3: Idiomatic & Zero-Cost Audit

#### Error Handling
- [ ] No `unwrap()` or `expect()` in production paths
- [ ] Error types use `thiserror` (library) or `anyhow` (application)
- [ ] Error context preserved via `.context()` or `.map_err()`
- [ ] No silent error swallowing (`let _ = fallible_op()`)
- [ ] `?` operator used consistently; no manual `match` on `Result` when `?` suffices

#### Allocations & Performance
- [ ] No unnecessary `Box<dyn Trait>` when `impl Trait` suffices
- [ ] No redundant `.clone()`
- [ ] `String` vs `&str` — prefer borrowed where possible
- [ ] `Vec::with_capacity()` for known sizes
- [ ] No `collect()` into intermediate `Vec` when iterator chaining suffices
- [ ] `Cow<'_, str>` for conditional ownership

```bash
sg -p '$EXPR.unwrap()' -l rust
sg -p '$EXPR.clone()' -l rust
sg -p 'Box<dyn $TRAIT>' -l rust
```

#### API Design
- [ ] Public types implement appropriate standard traits (`Debug`, `Display`, `Clone`, `PartialEq`)
- [ ] Builder pattern used for complex construction (>3 optional fields)
- [ ] `From`/`Into` conversions are lossless and unambiguous
- [ ] `Default` implementations are meaningful, not arbitrary
- [ ] Non-exhaustive enums use `#[non_exhaustive]` for library crates

### Phase 4: Logical Proof Architecture

#### Steps
1. **Define Invariant**: State the rule (e.g., "Buffer length never exceeds capacity")
2. **Audit Boundary**: Verify all `&mut self` methods enforce the rule
3. **Proof of Soundness**: Document why the implementation prevents violations
4. **Type-Level Encoding**: Where possible, use the type system to make violations uncompilable

#### Invariant Template
```markdown
### Invariant: [Name]
- **Rule**: [What must always be true]
- **Mutation Points**: [List all `&mut self` methods]
- **Enforcement**: [How each mutation point preserves the invariant]
- **Proof**: [Why it is impossible to violate]
```

### Phase 5: Deep Soundness (When Warranted)

Use when: `unsafe` code, custom allocators, lock-free structures, FFI.

#### 5.1 Miri Verification
```bash
cargo +nightly miri test
MIRIFLAGS="-Zmiri-strict-provenance" cargo +nightly miri test
```

#### 5.2 Model Checking & Property Testing
- `cargo kani` for bounded model checking (create Kani proof harnesses)
- `proptest` for property-based testing of critical state transitions
- `bolero` for unified fuzz/property/Kani interface

#### 5.3 Drop Simulation
Simulate dropping at unusual times (panicking mid-function, dropping async task
at `.await`). Ensure no data leaks or dangling pointers.

#### 5.4 Verification Checklist
1. Miri reports 0 errors and 0 leaks
2. Every `unsafe` block has formal `// SAFETY:` comment
3. No `&mut T` reference allows mutating aliased data
4. All `Send`/`Sync` bounds are justified for types with interior mutability

## Tool Integration

| Tool | Purpose |
|:-----|:--------|
| `rust-analyzer` | LSP definitions/references/hover/call hierarchy/diagnostics |
| `cargo clippy --all-targets -- -D warnings` | Lint gate |
| `cargo audit` | Known vulnerability scan |
| `cargo deny check` | License and advisory check |
| `cargo-geiger` | Unsafe density measurement |
| `cargo-expand` | Macro expansion audit |
| `cargo +nightly miri test` | Dynamic UB detection |
| `cargo kani` | Bounded model checking |
| `ast-grep` / `sg` | Structural pattern search |

LSP note: `rust-analyzer` is the preferred semantic navigation layer, especially
for references and call hierarchy. It complements, but never replaces,
`cargo check`, `cargo test`, `cargo clippy`, and unsafe/soundness proof gates.

## Scoring Reference

All Rust reviews use the unified 0-100 scoring rubric from
`code-quality/references/scoring-rubric.md`.

| Range | Level | Criteria |
|-------|-------|----------|
| 0-30  | **Critical** | Safety axiom violations, security vulnerabilities, memory unsafety |
| 31-50 | **Serious** | Logic races (TOCTOU), unchecked boundaries, silent error swallowing |
| 51-70 | **Debt** | Non-idiomatic patterns, missing type hints, suboptimal data structures |
| 71-85 | **Good** | Safe and performant, minor improvements possible |
| 86-99 | **Elite** | Everything audited, excellent coverage, documented proofs |
| 100   | **Perfect** | Structurally proven correct, all invariants type-encoded |

## Output Format

For task reviews, use the lineage-aware report structure from
`code-quality/workflows/sk-code-quality-review-report-lineage.md`. For ad-hoc
module reviews:

```markdown
## Review: [Module / PR Name]

### Score: [0-100] — [Level]

### Axiom Compliance
| Axiom | Status | Notes |
|-------|--------|-------|
| Ownership | pass/fail | [Details] |
| Type-State | pass/fail | [Details] |
| Zero-Cost | pass/fail | [Details] |
| Safety Boundary | pass/fail | [Details] |
| Cancellation Safety | pass/fail | [Details] |

### Findings
#### Critical (Score < 50)
- [Finding with file:line reference]

#### Debt (Score 50-80)
- [Finding with file:line reference]

#### Improvements (Score 80-99)
- [Finding with file:line reference]

### Path to 100
[Prioritized list of changes needed]
```

## Detailed Rules Reference

For the complete 179 rule set, see
`.agents/skills/code-quality/references/rust-rules.md`.

## Build Cleanup

After any successful `cargo build`, `cargo check`, or `cargo test`,
ALWAYS run `cargo clean` to free disk space per AGENTS.md §4.4.
