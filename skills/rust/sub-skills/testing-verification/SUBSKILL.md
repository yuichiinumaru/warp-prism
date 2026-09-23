---
name: testing-verification
description: |
  Cargo test discipline, property-based testing with proptest/bolero, Miri
  UB detection, Kani bounded model checking, benchmarks with criterion,
  coverage measurement, fixture and test isolation patterns. Use when
  designing, reviewing, or improving Rust test suites.
parent: rust
triggers:
  - rust testing
  - cargo test
  - rust test
  - proptest
  - rust benchmark
  - criterion
  - cargo bench
  - rust coverage
  - test isolation
  - rust fixtures
  - kani proof
  - miri test
  - rust tdd
metadata:
  maturity: draft
  implementation_kind: full
  owner: architects/language-harness
---

# Testing & Verification

Operational guidance for Rust testing discipline: cargo test best practices,
property-based testing, formal verification with Miri and Kani, benchmarking,
coverage measurement, and test isolation patterns.

## When to Use

- Designing test strategy for a new Rust module
- Reviewing test quality and coverage
- Writing property-based tests for state machines or algorithms
- Setting up Miri or Kani proof harnesses
- Creating benchmarks with criterion
- Evaluating test isolation and fixture patterns
- Auditing test-to-production code correspondence

## When Not to Use

- Full code review (all phases) → use `review` subskill
- Async-specific concerns without test focus → use `async-concurrency`
- Error type design → use `error-handling`
- Unsafe soundness proofs without broader test strategy → use `unsafe-soundness`

## Test Organization

### Directory Structure

```
src/
├── lib.rs
├── module.rs
└── module/
    └── tests.rs        # unit tests co-located (or inline #[cfg(test)])
tests/
├── integration_test.rs # integration tests (separate compilation)
└── common/
    └── mod.rs          # shared test helpers
benches/
└── benchmark.rs        # criterion benchmarks
```

### Unit vs Integration vs Property vs Proof

| Type | Location | Purpose | Tool |
|------|----------|---------|------|
| **Unit** | `#[cfg(test)] mod tests` in source file | Test private functions, edge cases | `cargo test` |
| **Integration** | `tests/` directory | Test public API, multi-module flows | `cargo test` |
| **Property** | Either location | Verify invariants over random inputs | `proptest`, `bolero` |
| **Proof** | `#[cfg(kani)] mod proofs` | Bounded model checking | `cargo kani` |
| **Benchmark** | `benches/` | Measure performance | `criterion` |
| **Miri** | Any test | Detect undefined behavior | `cargo miri test` |

## Cargo Test Best Practices

### Test Naming

```rust
#[cfg(test)]
mod tests {
    use super::*;

    // GOOD: Describes behavior, not implementation
    #[test]
    fn empty_buffer_returns_none_on_read() { ... }

    // GOOD: Documents edge case
    #[test]
    fn push_beyond_capacity_triggers_reallocation() { ... }

    // BAD: Implementation-focused name
    #[test]
    fn test_vec_len() { ... }

    // BAD: Vague
    #[test]
    fn it_works() { ... }
}
```

### Test Structure: Arrange-Act-Assert

```rust
#[test]
fn user_with_expired_token_is_rejected() {
    // Arrange
    let expired_token = Token::new(Utc::now() - Duration::hours(1));
    let validator = TokenValidator::new();

    // Act
    let result = validator.validate(&expired_token);

    // Assert
    assert!(result.is_err());
    assert!(matches!(result, Err(AuthError::TokenExpired)));
}
```

### Required Test Scenarios

Every public function should have at minimum:

- [ ] **Happy path**: Normal expected input → expected output
- [ ] **Empty/zero/None input**: What happens with nothing?
- [ ] **Boundary values**: Max, min, exactly-at-limit
- [ ] **Error case**: Invalid input → correct error variant
- [ ] **Round-trip**: serialize → deserialize → assert equality (for data types)

For state machines, also test:

- [ ] **Every valid transition**: State A → State B → State C
- [ ] **Invalid transitions**: State A → State C (should fail)
- [ ] **Terminal states**: Cannot transition out of Done/Error

## Property-Based Testing

### When to Use Properties

- **Data structures**: insertion preserves invariants, removal finds existing items
- **Serialization**: roundtrip encode/decode preserves data
- **Algorithms**: sort output is sorted, search finds inserted items
- **State machines**: no invalid state transitions

### proptest Example

```rust
use proptest::prelude::*;

proptest! {
    #[test]
    fn roundtrip_serialization(input in any::<MyType>()) {
        let bytes = input.serialize();
        let output = MyType::deserialize(&bytes).unwrap();
        prop_assert_eq!(input, output);
    }

    #[test]
    fn sorted_output_is_sorted(mut input in prop::collection::vec(any::<i32>(), 0..1000)) {
        input.sort();
        for window in input.windows(2) {
            prop_assert!(window[0] <= window[1]);
        }
    }
}
```

### Implementing `Arbitrary` for Custom Types

```rust
impl Arbitrary for MyConfig {
    type Parameters = ();
    type Strategy = BoxedStrategy<Self>;

    fn arbitrary_with(_: Self::Parameters) -> Self::Strategy {
        (1..=100u32, any::<bool>(), "[a-z]{1,10}")
            .prop_map(|(count, enabled, name)| MyConfig {
                count,
                enabled,
                name,
            })
            .boxed()
    }
}
```

## Miri for UB Detection

### Integration with Test Suite

```bash
# Run all tests under Miri
cargo +nightly miri test

# Run specific test
cargo +nightly miri test -- test_name

# Strict provenance
MIRIFLAGS="-Zmiri-strict-provenance" cargo +nightly miri test
```

### Limitations

Miri cannot test:
- FFI calls to real C libraries
- System calls (file I/O, networking)
- Inline assembly
- Some platform-specific intrinsics

For these cases, use `#[cfg_attr(miri, ignore)]` on individual tests.

## Kani Bounded Model Checking

### Setting Up Proof Harnesses

```rust
#[cfg(kani)]
mod proofs {
    use super::*;

    #[kani::proof]
    fn index_is_always_in_bounds() {
        let size: usize = kani::any();
        kani::assume(size > 0 && size <= 256);
        let buffer = Buffer::new(size);
        let idx: usize = kani::any();
        kani::assume(idx < size);
        // This should never panic
        let _ = buffer.get(idx);
    }

    #[kani::proof]
    #[kani::unwind(5)]
    fn state_machine_never_enters_invalid_state() {
        let mut machine = StateMachine::new();
        for _ in 0..4 {
            let action: Action = kani::any();
            machine.step(action);
            assert!(machine.is_valid());
        }
    }
}
```

```bash
cargo kani --harness index_is_always_in_bounds
```

## Benchmarking with Criterion

### Setup

```toml
# Cargo.toml
[dev-dependencies]
criterion = { version = "0.5", features = ["html_reports"] }

[[bench]]
name = "my_benchmark"
harness = false
```

### Writing Benchmarks

```rust
use criterion::{criterion_group, criterion_main, Criterion, BenchmarkId};

fn bench_process(c: &mut Criterion) {
    let mut group = c.benchmark_group("process");
    for size in [100, 1_000, 10_000] {
        let input = generate_input(size);
        group.bench_with_input(
            BenchmarkId::from_parameter(size),
            &input,
            |b, input| b.iter(|| process(input)),
        );
    }
    group.finish();
}

criterion_group!(benches, bench_process);
criterion_main!(benches);
```

```bash
cargo bench
# Compare against baseline
cargo bench -- --save-baseline before
# ... make changes ...
cargo bench -- --baseline before
```

## Coverage Measurement

```bash
# Using cargo-llvm-cov
cargo install cargo-llvm-cov
cargo llvm-cov --html --open          # HTML report
cargo llvm-cov --lcov --output-path lcov.info  # for CI

# Using source-based coverage (nightly)
RUSTFLAGS="-C instrument-coverage" cargo +nightly test
grcov . --binary-path target/debug/ -s . -t html --ignore-not-existing -o coverage/
```

### Coverage Guidelines

| Type | Target | Reasoning |
|------|--------|-----------|
| Library public API | ≥90% | Public contract must be exercised |
| Unsafe code | 100% | Every unsafe path must be tested + Miri'd |
| Error paths | ≥80% | Known failure modes must be tested |
| Internal helpers | ≥70% | Private code covered through public API tests |

## Test Isolation Rules

1. **No shared mutable state between tests**: Use `tempdir()` or unique identifiers
2. **No filesystem side effects**: Write to `tempdir`, not project directories
3. **No network calls in unit tests**: Mock or use test fixtures
4. **Deterministic ordering**: Tests must pass regardless of execution order
5. **Clean up resources**: Use RAII; drop handles, close connections

```rust
use tempfile::tempdir;

#[test]
fn writes_output_file() {
    let dir = tempdir().unwrap();
    let path = dir.path().join("output.txt");
    write_output(&path).unwrap();
    assert!(path.exists());
    // dir is cleaned up on drop
}
```

## Test Audit Checklist

- [ ] Every public function has at least one test
- [ ] Edge cases are explicitly tested (empty, zero, max, boundary)
- [ ] Error paths are tested (invalid inputs → correct error variant)
- [ ] No `#[ignore]` without documented reason
- [ ] No tests that always pass (trivial assertions)
- [ ] Tests use `assert_eq!` / `assert_matches!` with descriptive messages
- [ ] Async tests use `#[tokio::test]` (not a manual runtime build)
- [ ] No test dependencies leak into production binary
- [ ] Unsafe code has Miri coverage
- [ ] Critical invariants have property-based tests

## Build Cleanup

After any successful `cargo test`, `cargo bench`, or `cargo miri test`,
ALWAYS run `cargo clean` to free disk space per AGENTS.md §4.4.
