---
name: error-handling
description: |
  Rust error type design, thiserror/anyhow usage, context propagation chains,
  unwrap discipline, panic safety boundaries, and error conversion patterns.
  Use when reviewing or designing error handling in Rust code.
parent: rust
triggers:
  - rust error handling
  - rust error types
  - thiserror
  - anyhow
  - unwrap
  - expect
  - rust panic
  - rust result
  - error context
  - map_err
metadata:
  maturity: draft
  implementation_kind: full
  owner: architects/language-harness
---

# Error Handling

Operational guidance for designing, reviewing, and maintaining Rust error handling:
error type architecture, thiserror/anyhow usage, context propagation, unwrap
discipline, panic safety, and conversion patterns.

## When to Use

- Reviewing error handling in Rust code
- Designing error type hierarchies for a new crate or module
- Auditing unwrap/expect usage in production paths
- Evaluating error context propagation chains
- Reviewing panic safety boundaries (libraries vs applications)
- Assessing Result/Option usage patterns

## When Not to Use

- Full code review (all phases) → use `review` subskill
- Async-specific error handling (retry, timeout) → use `async-concurrency`
- Unsafe/FFI error codes → use `unsafe-soundness`
- Test error assertions → use `testing-verification`

## Core Rules

### Rule 1: Library vs Application Error Strategy

| Context | Strategy | Crate |
|---------|----------|-------|
| **Library code** | Typed errors via `thiserror` | `thiserror` |
| **Application code** | Context-rich errors via `anyhow` | `anyhow` |
| **Library boundaries** | Own error enum, never expose `anyhow` | `thiserror` |
| **Internal plumbing** | `anyhow` is acceptable when errors are not part of public API | `anyhow` |

### Rule 2: Never Swallow Errors

```rust
// CRITICAL VIOLATION: Silent error swallowing
let _ = file.write_all(data);

// CRITICAL VIOLATION: Log and continue without handling
if let Err(e) = operation() {
    log::error!("failed: {e}");
    // continues as if nothing happened
}

// ACCEPTABLE: Explicit intentional discard with justification
// We intentionally ignore flush errors during shutdown
let _ = writer.flush();

// GOOD: Propagate or handle explicitly
file.write_all(data)?;
file.write_all(data).context("writing user data to cache file")?;
```

### Rule 3: Context at Every Boundary

Every `?` at a module or layer boundary should add context. The error message
must answer: **what were we trying to do?**

```rust
// BAD: No context — error message says "No such file" with no clue which file
let config = std::fs::read_to_string(path)?;

// GOOD: Context explains intent
let config = std::fs::read_to_string(path)
    .with_context(|| format!("reading config from {}", path.display()))?;

// GOOD: thiserror with source chain
#[derive(Debug, thiserror::Error)]
pub enum ConfigError {
    #[error("failed to read config from {path}")]
    ReadFailed {
        path: PathBuf,
        #[source]
        source: std::io::Error,
    },
}
```

### Rule 4: Unwrap Discipline

| Location | `unwrap()` / `expect()` | Alternative |
|----------|------------------------|-------------|
| **Production code** | FORBIDDEN | Use `?`, `.context()`, `.unwrap_or()`, `.unwrap_or_else()`, `.unwrap_or_default()` |
| **Tests** | ALLOWED | `unwrap()` is acceptable for clearer test failure messages |
| **Static initialization** | CONDITIONAL | `expect("reason")` is acceptable when the condition is truly impossible (e.g., `Regex::new` with a literal) |
| **Examples / doctests** | ALLOWED | Brevity is acceptable in documentation |

```bash
# Find all unwrap() calls in production code (excluding tests)
sg -p '$EXPR.unwrap()' -l rust
# Find unwrap() in test code (acceptable)
sg -p '$EXPR.unwrap()' -l rust -- tests/
```

### Rule 5: No Stringly-Typed Errors

```rust
// BAD: String errors lose type information and are unmatchable
fn process() -> Result<(), String> {
    Err("something went wrong".to_string())
}

// BAD: Box<dyn Error> loses type information
fn process() -> Result<(), Box<dyn std::error::Error>> {
    Ok(())
}

// GOOD: Typed errors in libraries
#[derive(Debug, thiserror::Error)]
pub enum ProcessError {
    #[error("invalid input: {reason}")]
    InvalidInput { reason: String },
    #[error("connection failed")]
    Connection(#[from] ConnectionError),
}

// GOOD: anyhow for application binaries
fn process() -> anyhow::Result<()> {
    do_thing().context("processing user request")?;
    Ok(())
}
```

## Error Type Design Patterns

### Enum Error Hierarchy

For library crates with multiple failure domains:

```rust
/// Top-level error for the crate
#[derive(Debug, thiserror::Error)]
pub enum Error {
    #[error("configuration error")]
    Config(#[from] ConfigError),
    #[error("storage error")]
    Storage(#[from] StorageError),
    #[error("network error")]
    Network(#[from] NetworkError),
}

/// Config-specific errors
#[derive(Debug, thiserror::Error)]
pub enum ConfigError {
    #[error("missing required field: {field}")]
    MissingField { field: &'static str },
    #[error("invalid value for {field}: {value}")]
    InvalidValue { field: &'static str, value: String },
    #[error("failed to parse config file")]
    Parse(#[source] toml::de::Error),
}
```

### Newtype Error for Single-Variant Wrappers

When wrapping exactly one error source:

```rust
#[derive(Debug, thiserror::Error)]
#[error("database query failed")]
pub struct QueryError(#[source] pub sqlx::Error);
```

### Error Conversion Best Practices

```rust
// From conversions should be lossless and unambiguous
impl From<std::io::Error> for StorageError {
    fn from(e: std::io::Error) -> Self {
        StorageError::Io(e)
    }
}

// When conversion is context-dependent, use explicit .map_err()
let result = do_io()
    .map_err(|e| StorageError::ReadFailed {
        path: path.to_owned(),
        source: e,
    })?;
```

## Panic Safety

### Panic Boundaries

| Boundary | Rule |
|----------|------|
| Library public API | MUST NOT panic for valid inputs; return `Result` |
| Application main | May `unwrap()`/`expect()` at top level after exhausting recovery |
| FFI boundary | MUST use `catch_unwind` — unwind across FFI is UB |
| Trait implementations | Match the trait's contract (e.g., `Index` may panic) |
| `Drop` implementations | SHOULD NOT panic — panicking in `Drop` during stack unwinding causes abort |

### `catch_unwind` for FFI

```rust
#[no_mangle]
pub extern "C" fn rust_process(input: *const c_char) -> i32 {
    let result = std::panic::catch_unwind(|| {
        // SAFETY: caller guarantees non-null, valid UTF-8
        let input = unsafe { CStr::from_ptr(input) };
        process(input.to_str().unwrap())
    });
    match result {
        Ok(Ok(())) => 0,
        Ok(Err(_)) => -1,
        Err(_) => -2, // panic occurred
    }
}
```

## Audit Checklist

- [ ] No `unwrap()` or `expect()` in production code paths (outside tests and static init)
- [ ] No silent error swallowing (`let _ = fallible_op()` without comment)
- [ ] Every `?` at a module boundary has `.context()` or `.map_err()`
- [ ] Library crate errors use `thiserror`, not `String` or `Box<dyn Error>`
- [ ] Error types implement `Debug`, `Display`, and `Error` (via `thiserror`)
- [ ] Error chains preserve the source error (no `to_string()` conversion that drops source)
- [ ] Application code uses `anyhow` with context, not raw `thiserror` enums
- [ ] No panics possible in `Drop` implementations
- [ ] FFI boundary functions use `catch_unwind`
- [ ] Error enum variants are `#[non_exhaustive]` for library crate public APIs

```bash
# Audit: find potential error swallowing
sg -p 'let _ = $EXPR' -l rust
# Audit: find bare ? without context at module boundaries
sg -p '$EXPR?' -l rust
```

## Build Cleanup

After any successful `cargo build`, `cargo check`, or `cargo test`,
ALWAYS run `cargo clean` to free disk space per AGENTS.md §4.4.
