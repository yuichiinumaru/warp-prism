---
name: govern-lifecycle
parent: flutter-rust-integration
description: |
  Govern cross-boundary lifecycles for streams, callbacks, tasks, long-running jobs,
  cancellation, native handles, producer/consumer shutdown, and cleanup.
triggers:
  - frb cancellation
  - rust dart stream lifecycle
  - flutter rust long running job
  - native handle lifecycle
  - rust task survives widget
  - stream close dart rust
metadata:
  owner: flutter-rust-integration
  maturity: candidate
  implementation_kind: full
  inputs:
    - lifecycle-bearing operation/resource
    - both-side ownership and runtime behavior
  outputs:
    - lifecycle tuple
    - cancellation/terminal-state protocol
    - cleanup evidence plan
  side_effects: [none]
  evidence_required:
    - evidence from both sides for claimed terminal/cancellation behavior
  completion_signal: "Creation, active lifetime, cancellation, terminal state, cleanup, and failure are defined and can be observed on the owning side(s)."
---

# Govern Lifecycle

Cross-boundary lifecycle bugs often look correct in one language.

## Lifecycle Tuple

For every long-lived operation/resource:

```text
(owner,
 creation,
 active_lifetime,
 cancellation,
 terminal_state,
 cleanup,
 failure)
```

If any field is material and unknown, the integration is not fully designed.

## Long-Running Operation Model

Prefer an explicit model such as:

```text
create/start
→ running
→ progress/events
→ terminal:
   completed | failed | cancelled
→ cleanup
```

Do not encode "cancelled" as merely "Dart stopped listening."

## Cancellation Honesty

Distinguish:

1. **request issued** — Dart/Rust asked for cancellation;
2. **request observed** — other side received it;
3. **work stopped** — actual computation/task ceased;
4. **resources released** — terminal cleanup completed.

A claim of "cancellation works" normally requires at least 3, and often 4.

## Streams

Define:

- producer owner;
- consumer count assumptions;
- ordering guarantees;
- buffering policy;
- backpressure/drop/coalescing behavior;
- terminal event or close semantics;
- what happens when consumer disappears;
- what happens when producer fails;
- cleanup path.

High-frequency telemetry should usually support coalescing or bounded buffering.

## Native Resources / Handles

For handles:

- define who creates;
- define who validates;
- define who releases;
- prevent use-after-release/stale handle ambiguity;
- define process/library restart behavior;
- do not let Dart ownership semantics imply native ownership accidentally.

When stale-handle reuse is possible, consider generation/versioning or another explicit identity defense.

## Widget/Route Lifecycle Is Not Domain Lifecycle

A Flutter widget can disappear while Rust work remains valid.

Decide explicitly whether route/widget disposal means:

- unsubscribe only;
- cancel operation;
- detach UI but keep job alive;
- release native resource.

Do not infer this from `dispose()` automatically.

## Failure

Contain panics/foreign failures before crossing the boundary.

Differentiate:

- semantic/domain failure;
- transport failure;
- cancellation;
- consumer disappearance;
- native resource invalidation;
- process/library failure.

## Evidence

Use in-flight tests, not only already-completed operations.

For cancellation, deliberately start work that is observably active, cancel, and prove
native termination/cleanup.

For streams, prove more than one event plus termination/cleanup when those claims matter.
