---
name: async-concurrency
description: |
  Tokio async cancellation safety, select! hazards, mutex-across-await deadlocks,
  spawned task lifecycle management, Send/Sync bounds on futures, and structured
  concurrency patterns. Use when reviewing or writing async Rust code, tokio
  runtime work, or concurrent state management.
parent: rust
triggers:
  - rust async
  - tokio
  - async await rust
  - cancellation safety
  - select! rust
  - spawn rust
  - JoinHandle
  - tokio::sync
  - async drop
  - rust concurrency
  - rust futures
metadata:
  maturity: draft
  implementation_kind: full
  owner: architects/language-harness
---

# Async & Concurrency Patterns

Operational guidance for writing and reviewing async Rust code with Tokio,
focusing on cancellation safety, structured concurrency, and common pitfalls.

## When to Use

- Reviewing async functions, futures, or spawned tasks
- Auditing `select!` blocks for cancellation hazards
- Checking for deadlocks from mutex guards held across `.await`
- Designing task lifecycle management (spawn, abort, graceful shutdown)
- Reviewing `Send`/`Sync` bounds on futures and streams
- Evaluating channel usage, semaphore patterns, or async mutex design
- Writing or reviewing structured concurrency with `JoinSet` or `TaskTracker`

## When Not to Use

- Synchronous Rust code without async → use `review` subskill
- Unsafe code or FFI → use `unsafe-soundness`
- Error handling design without async-specific concerns → use `error-handling`
- Test harness design → use `testing-verification`

## Cancellation Safety: The Core Problem

In Rust's async model, a future can be **dropped at any `.await` point**. This
means any `.await` is a potential cancellation boundary. Code that performs
partial state mutations between `.await` points risks leaving state in an
inconsistent state if the future is dropped.

### The Cancellation Audit

For every `async fn`, answer these questions at each `.await` point:

1. **Has state been partially mutated?** If the future is dropped here, is the
   state consistent?
2. **Are resources acquired but not released?** (file handles, locks, DB
   transactions, network connections)
3. **Is there a `Drop` guard** that can roll back partial mutations?
4. **Is the operation idempotent?** Can it be safely retried if dropped and
   restarted?

### The Drop-Proof Pattern

```rust
struct WriteGuard<'a> {
    state: &'a mut State,
    committed: bool,
}

impl<'a> WriteGuard<'a> {
    fn new(state: &'a mut State) -> Self {
        Self { state, committed: false }
    }

    fn commit(mut self) {
        self.committed = true;
    }
}

impl Drop for WriteGuard<'_> {
    fn drop(&mut self) {
        if !self.committed {
            self.state.rollback();
        }
    }
}

async fn safe_update(state: &mut State) -> Result<()> {
    let guard = WriteGuard::new(state);
    // If dropped at this .await, guard rolls back
    let data = fetch_data().await?;
    guard.state.apply(data);
    guard.commit(); // only reached on success
    Ok(())
}
```

## `select!` Hazards

`tokio::select!` cancels all non-winning branches. This is the **most common
source of cancellation bugs** in Tokio-based code.

### Audit Checklist for `select!`

- [ ] **Side effects in non-winning branches**: Does each branch perform
  side effects that need cleanup if cancelled?
- [ ] **Pinned futures reuse**: If using `pin!()` with `select!` in a loop,
  are futures correctly recreated or resumed?
- [ ] **Biased selection**: Is `biased;` used intentionally? Random selection
  (default) can starve slow branches.
- [ ] **Channel recv in select**: Are messages lost if recv wins but processing
  is cancelled before completion?

### Common Anti-Patterns

```rust
// BAD: Message received but processing can be cancelled
tokio::select! {
    msg = rx.recv() => {
        // If this branch wins but another select! cancels us
        // before process() completes, the message is lost
        process(msg).await;
    }
    _ = shutdown.recv() => {}
}

// GOOD: Make processing cancellation-safe
tokio::select! {
    msg = rx.recv() => {
        // Spawn a task so processing continues even if parent is cancelled
        tokio::spawn(async move { process(msg).await });
    }
    _ = shutdown.recv() => {}
}

// ALTERNATIVE: Use a loop with cancel token
loop {
    tokio::select! {
        Some(msg) = rx.recv() => {
            // Process inline if cancellation-safe
            process_sync(msg);
        }
        _ = cancel.cancelled() => break,
    }
}
```

## Mutex-Across-Await Deadlock

Holding a `tokio::sync::Mutex` guard across an `.await` point is a **deadlock
risk** because the executor may schedule another task that needs the same lock
on the same thread.

### Detection

```bash
# Find mutex guards held across await
sg -p 'let $GUARD = $MUTEX.lock().await' -l rust
```

### Fix Patterns

```rust
// BAD: Guard held across .await
let guard = mutex.lock().await;
do_async_work().await;  // deadlock risk
drop(guard);

// GOOD: Release guard before .await
{
    let guard = mutex.lock().await;
    let data = guard.clone();
} // guard dropped here
do_async_work_with(data).await;

// GOOD: Use std::sync::Mutex for short sync operations
let data = {
    let guard = std_mutex.lock().unwrap();
    guard.clone()
};
do_async_work_with(data).await;
```

**Rule of thumb**: Use `std::sync::Mutex` for short, synchronous critical
sections (data access). Use `tokio::sync::Mutex` only when you genuinely need
to hold a lock across an `.await` point and have verified no deadlock exists.

## Spawned Task Lifecycle

Every `tokio::spawn` creates a task that runs independently. Untracked tasks
are resource leaks and make graceful shutdown impossible.

### Task Tracking Pattern

```rust
use tokio::task::JoinSet;

struct Service {
    tasks: JoinSet<Result<(), Error>>,
}

impl Service {
    async fn spawn_worker(&mut self, work: Work) {
        self.tasks.spawn(async move {
            work.process().await
        });
    }

    async fn shutdown(mut self) {
        // Cancel all running tasks
        self.tasks.shutdown().await;
        // Or: wait for completion
        while let Some(result) = self.tasks.join_next().await {
            match result {
                Ok(Ok(())) => {},
                Ok(Err(e)) => tracing::error!("Task error: {e}"),
                Err(e) => tracing::error!("Task panicked: {e}"),
            }
        }
    }
}
```

### Anti-Patterns

```rust
// BAD: Fire-and-forget spawn — no way to track, abort, or observe errors
tokio::spawn(async { do_work().await });

// BAD: Ignoring JoinHandle
let _ = tokio::spawn(async { do_work().await });

// GOOD: Track with JoinSet or store handle for later abort/join
let handle = tokio::spawn(async { do_work().await });
handles.push(handle);
```

## Send/Sync Bounds on Futures

Tokio's multi-threaded runtime requires spawned futures to be `Send`. This
constrains what can be captured in `async move` blocks.

### Common Issues

| Problem | Cause | Fix |
|---------|-------|-----|
| `future is not Send` | Non-Send type held across `.await` | Drop before `.await` or use `Send`-safe alternative |
| `Rc` in async | `Rc` is not `Send` | Use `Arc` instead |
| `RefCell` in async | `RefCell` borrow guard is not `Send` | Use `tokio::sync::Mutex` or restructure |
| `MutexGuard` across `.await` | `std::sync::MutexGuard` is not `Send` | Use `tokio::sync::Mutex` or drop guard before `.await` |

### Verification

```rust
// Compile-time Send assertion
fn assert_send<T: Send>(_: &T) {}
let fut = my_async_fn();
assert_send(&fut);
```

## Structured Concurrency Patterns

### Fan-Out/Fan-In with JoinSet

```rust
let mut set = JoinSet::new();
for item in items {
    set.spawn(async move { process(item).await });
}
let mut results = Vec::with_capacity(items.len());
while let Some(res) = set.join_next().await {
    results.push(res??);
}
```

### Timeout Pattern

```rust
match tokio::time::timeout(Duration::from_secs(30), operation()).await {
    Ok(result) => result?,
    Err(_) => return Err(Error::Timeout),
}
```

### Graceful Shutdown with CancellationToken

```rust
use tokio_util::sync::CancellationToken;

let token = CancellationToken::new();
let child_token = token.child_token();

tokio::spawn(async move {
    loop {
        tokio::select! {
            _ = child_token.cancelled() => break,
            _ = do_periodic_work() => {},
        }
    }
});

// Later: initiate shutdown
token.cancel();
```

## Build Cleanup

After any successful `cargo build`, `cargo check`, or `cargo test`,
ALWAYS run `cargo clean` to free disk space per AGENTS.md §4.4.
